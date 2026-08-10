import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:investy/features/kyc/data/models/kyc_status_model.dart';
import 'package:investy/features/kyc/presentation/providers/kyc_provider.dart';
import 'package:investy/features/kyc/presentation/widgets/kyc_status_refresher.dart';

/// Mounts the refresher with a permanent watcher underneath it.
///
/// The watcher is not scaffolding for the test's convenience — it *is* the
/// production shape. `settings_screen`, `broker_gate_banner` and
/// `kyc_gate_banner` all watch this provider from screens that outlive the KYC
/// screen, which is why the provider never auto-disposes and why an explicit
/// invalidation is the only thing that refreshes it (B80). Without a listener
/// here, `invalidate` would merely drop the cached value and nothing would ever
/// rebuild — the test would pass or fail for reasons production never sees.
///
/// Returns a closure reading how many times the provider produced a value;
/// each one is a backend round trip in production.
Future<int Function()> _mount(WidgetTester tester, String status) async {
  var reads = 0;
  await tester.pumpWidget(ProviderScope(
    overrides: [
      kycStatusProvider.overrideWith((_) async {
        reads++;
        return KycStatusModel(status: status);
      }),
    ],
    child: MaterialApp(
      home: KycStatusRefresher(
        child: Consumer(
          builder: (_, ref, __) {
            final async = ref.watch(kycStatusProvider);
            return Text(async.valueOrNull?.status ?? 'loading',
                textDirection: TextDirection.ltr);
          },
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
  return () => reads;
}

Future<int> _resumeAndCount(
    WidgetTester tester, int Function() reads) async {
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  await tester.pumpAndSettle();
  return reads();
}

void main() {
  // The core of B80: a decision that lands while the app is backgrounded has
  // to be picked up on return, without the user navigating anywhere.
  testWidgets('resuming re-reads a non-terminal status', (tester) async {
    final reads = await _mount(tester, 'submitted');
    final before = reads();

    expect(await _resumeAndCount(tester, reads), greaterThan(before),
        reason: 'resume must re-read a pending KYC status');
  });

  // retry is NOT terminal — a user who was told to retry can still become
  // approved, and that transition has to arrive on its own like any other.
  testWidgets('resuming re-reads a retry status', (tester) async {
    final reads = await _mount(tester, 'retry');
    final before = reads();

    expect(await _resumeAndCount(tester, reads), greaterThan(before));
  });

  // Approved is terminal. Re-reading it on every app resume would put a network
  // round trip in front of every already-verified user, forever.
  testWidgets('resuming does NOT re-read an approved status', (tester) async {
    final reads = await _mount(tester, 'approved');
    final before = reads();

    expect(await _resumeAndCount(tester, reads), before,
        reason: 'a terminal status must not cost a backend read on resume');
  });

  testWidgets('resuming does NOT re-read a final rejection', (tester) async {
    final reads = await _mount(tester, 'rejected');
    final before = reads();

    expect(await _resumeAndCount(tester, reads), before);
  });

  // Only `resumed` matters. Reacting to `paused`/`inactive` would fire a read
  // every time the user swipes up or a call comes in.
  testWidgets('other lifecycle states do not trigger a read', (tester) async {
    final reads = await _mount(tester, 'submitted');
    final before = reads();

    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.paused,
      AppLifecycleState.detached,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
      await tester.pumpAndSettle();
    }

    expect(reads(), before);
  });

  // The observer must come off the binding on dispose, or a dead widget keeps
  // reacting to lifecycle events for the rest of the app's life.
  testWidgets('the observer is removed on dispose', (tester) async {
    final reads = await _mount(tester, 'submitted');

    // Swap the child out from under the same ProviderScope — replacing the
    // scope itself is a different test that says nothing about the observer.
    await tester.pumpWidget(ProviderScope(
      overrides: [
        kycStatusProvider.overrideWith((_) async {
          return const KycStatusModel(status: 'submitted');
        }),
      ],
      child: const MaterialApp(home: SizedBox.shrink()),
    ));
    await tester.pumpAndSettle();
    final after = reads();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(reads(), after,
        reason: 'a disposed refresher must not react to lifecycle events');
  });
}
