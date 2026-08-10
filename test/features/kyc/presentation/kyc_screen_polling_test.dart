import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:investy/features/kyc/data/models/kyc_status_model.dart';
import 'package:investy/features/kyc/presentation/providers/kyc_provider.dart';
import 'package:investy/features/kyc/presentation/screens/kyc_screen.dart';
import 'package:investy/l10n/app_localizations.dart';

/// Drives KycScreen with a status the test controls, counting backend reads.
///
/// This is the mechanism that actually closes B80's three-second race: the
/// webhook set "submitted" at 01:42:56, the app read it at 01:42:57, and
/// "approved" landed at 01:43:00 with nothing left to ask again. Everything
/// else in the fix (foreground refresh, push) either needs the user to leave
/// and come back, or needs APNs, which iOS does not have (B37).
Future<int Function()> _pumpScreen(
  WidgetTester tester,
  String Function() status,
) async {
  var reads = 0;
  await tester.pumpWidget(ProviderScope(
    overrides: [
      kycStatusProvider.overrideWith((_) async {
        reads++;
        return KycStatusModel(status: status());
      }),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: KycScreen(),
    ),
  ));
  await tester.pumpAndSettle();
  return () => reads;
}

/// Unmounts the screen so its timer is cancelled — a pending timer fails the
/// test, which is itself the leak check.
Future<void> _dispose(WidgetTester tester) async {
  await tester.pumpWidget(ProviderScope(
    // The override list has to keep the same length across pumps — Riverpod
    // asserts on it — so the screen is swapped out, not the scope.
    overrides: [
      kycStatusProvider.overrideWith(
          (_) async => const KycStatusModel(status: 'approved')),
    ],
    child: const MaterialApp(home: SizedBox.shrink()),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('polls the backend while the review is outstanding',
      (tester) async {
    final reads = await _pumpScreen(tester, () => 'submitted');
    final before = reads();

    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();

    expect(reads(), greaterThan(before),
        reason: 'a pending review must be re-read without user action');

    await _dispose(tester);
  });

  // The whole point: the decision arrives on its own, seconds later, and the
  // screen must follow it without the user touching anything.
  testWidgets('picks up an approval that lands while the screen is open',
      (tester) async {
    var status = 'submitted';
    await _pumpScreen(tester, () => status);

    expect(find.text('Under Review'), findsOneWidget);

    status = 'approved'; // the webhook lands
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();

    expect(find.text('Verified'), findsOneWidget,
        reason: 'the screen must follow the decision on its own (B80)');
    expect(find.text('Under Review'), findsNothing);

    await _dispose(tester);
  });

  // Once approved there is nothing left to learn; polling on would be a
  // backend read every 5 seconds for a user who is already done.
  testWidgets('stops polling once the status is terminal', (tester) async {
    final reads = await _pumpScreen(tester, () => 'approved');
    final settled = reads();

    await tester.pump(const Duration(seconds: 30));
    await tester.pumpAndSettle();

    expect(reads(), settled, reason: 'terminal status must not be polled');

    await _dispose(tester);
  });

  testWidgets('does not poll a final rejection', (tester) async {
    final reads = await _pumpScreen(tester, () => 'rejected');
    final settled = reads();

    await tester.pump(const Duration(seconds: 30));
    await tester.pumpAndSettle();

    expect(reads(), settled);

    await _dispose(tester);
  });

  // A user who merely opened the screen and never started must not generate
  // traffic — the poll widens past "submitted" only after the flow is launched.
  testWidgets('does not poll for a user who never started', (tester) async {
    final reads = await _pumpScreen(tester, () => 'not_started');
    final settled = reads();

    await tester.pump(const Duration(seconds: 30));
    await tester.pumpAndSettle();

    expect(reads(), settled,
        reason: 'no flow launched yet — nothing to wait for');

    await _dispose(tester);
  });

  // Unbounded polling would keep an idle screen hitting the backend for as
  // long as the app stays open.
  testWidgets('gives up after the bound instead of polling forever',
      (tester) async {
    final reads = await _pumpScreen(tester, () => 'submitted');
    final before = reads();

    // One tick per pump: the bound is 36 ticks, so 40 takes us past it.
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(seconds: 5));
    }
    await tester.pumpAndSettle();
    final atBound = reads();

    expect(atBound - before, lessThanOrEqualTo(36),
        reason: 'the poll must stop at its bound');

    // Well past the bound, nothing more may happen.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(seconds: 5));
    }
    await tester.pumpAndSettle();

    expect(reads(), atBound,
        reason: 'polling must stop at the bound, not run for the session');

    await _dispose(tester);
  });
}
