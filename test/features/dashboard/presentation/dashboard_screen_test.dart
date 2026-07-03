import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:investy/features/dashboard/data/models/activity_item_model.dart';
import 'package:investy/features/dashboard/data/models/dashboard_response_model.dart';
import 'package:investy/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:investy/features/goals/presentation/providers/rest_goals_provider.dart';
import 'package:investy/features/settings/presentation/providers/avatar_upload_provider.dart';
import 'package:investy/l10n/app_localizations.dart';

/// Minimal mock DashboardResponseModel: totalBalance = 250000 cents = $2,500.00, investedValue = 100000 cents = $1,000.00
const _mockResponse = DashboardResponseModel(
  userName: 'Alex',
  totalBalance: 250000,
  investedValue: 100000,
  currency: 'USD',
  recentActivity: [
    ActivityItemModel(
      id: 'txn-uuid-001',
      amount: 50000, // $500.00
      type: 'BUY',
      timestamp: '2026-03-01T10:00:00Z',
    ),
    ActivityItemModel(
      id: 'txn-uuid-002',
      amount: 10000, // $100.00
      type: 'DEPOSIT',
      timestamp: '2026-02-28T15:30:00Z',
    ),
  ],
);

/// B39 F2 (B34): the header watches avatarUrlProvider (no more synchronous
/// FirebaseAuth.instance read during build), so tests stub it with a null URL
/// and render the initial-letter avatar — no Firebase app required.
class _StubAvatarUrl extends AvatarUrl {
  @override
  String? build() => null;
}

void main() {
  group('DashboardScreen — REST data pipeline', () {
    /// The Owl AI mascot schedules its next blink with a 3–5s Future.delayed.
    /// Unmount the screen and advance the fake clock so the pending timer
    /// fires (as a no-op) — otherwise the test fails with "Timer is still
    /// pending".
    Future<void> drainOwlTimers(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 6));
    }

    Widget buildSubject() {
      return ProviderScope(
        overrides: [
          // Override the REST dashboard provider directly.
          // Bypasses Firebase Auth check and HTTP — proves the precision pipeline.
          restDashboardProvider.overrideWith((ref) async => _mockResponse),
          // S18: dashboard now renders goal chips — stub the goals list so the
          // test does not hit FirebaseAuth/HTTP.
          restGoalsProvider.overrideWith((ref) async => []),
          // B39 F2 (B34): header avatar comes from this provider now.
          avatarUrlProvider.overrideWith(_StubAvatarUrl.new),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: DashboardScreen(),
        ),
      );
    }

    testWidgets(
      'Cash to Invest card renders \$2,500.00 from REST totalBalance 250000 cents',
      (tester) async {
        await tester.pumpWidget(buildSubject());

        // Resolve FutureProvider and rebuild. Do NOT pumpAndSettle: the Owl AI
        // mascot runs looping animations (breath/blink) that never settle.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // 250000 cents / 100.0 = 2500.0 → CurrencyFormatter → '$2,500.00'
        expect(
          find.text('\$2,500.00'),
          findsOneWidget,
          reason: 'Cash to Invest must show the REST totalBalance of '
              '250000 cents as \$2,500.00, proving the integer-cents '
              '→ double-dollars precision pipeline is wired end-to-end.',
        );

        await drainOwlTimers(tester);
      },
    );

    testWidgets(
      'Recent Activity renders 2 items from REST recentActivity',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // The trailing amounts prove each activity item was mapped from int cents correctly.
        // BUY item: 50000 cents / 100 = $500.00, debit (money out) → '- $500.00'
        expect(find.text('- \$500.00'), findsOneWidget,
            reason:
                'BUY activity item (50000 cents) must render as - \$500.00');

        // DEPOSIT item: 10000 cents / 100 = $100.00, non-withdrawal → '+ $100.00'
        expect(find.text('+ \$100.00'), findsOneWidget,
            reason:
                'DEPOSIT activity item (10000 cents) must render as + \$100.00');

        // 'Deposit' title is unique — does not collide with Quick Action button labels
        expect(find.text('Deposit'), findsOneWidget);

        await drainOwlTimers(tester);
      },
    );
  });
}
