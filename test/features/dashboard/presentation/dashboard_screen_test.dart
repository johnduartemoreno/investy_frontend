import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:investy/features/dashboard/data/models/activity_item_model.dart';
import 'package:investy/features/dashboard/data/models/dashboard_response_model.dart';
import 'package:investy/features/dashboard/domain/entities/holding.dart';
import 'package:investy/features/dashboard/domain/entities/user_profile.dart';
import 'package:investy/features/dashboard/presentation/screens/dashboard_screen.dart';

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

void main() {
  group('DashboardScreen — REST data pipeline', () {
    Widget buildSubject() {
      return ProviderScope(
        overrides: [
          // Override the REST dashboard provider directly.
          // Bypasses Firebase Auth check and HTTP — proves the precision pipeline.
          restDashboardProvider.overrideWith((ref) async => _mockResponse),

          // Override Firestore stream providers (not covered by the REST contract).
          // AsyncLoading header is acceptable; only Cash to Invest is asserted.
          userProfileStreamProvider
              .overrideWith((ref) => Stream<UserProfile>.empty()),
          holdingsStreamProvider
              .overrideWith((ref) => Stream.value(<Holding>[])),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      );
    }

    testWidgets(
      'Cash to Invest card renders \$2,500.00 from REST totalBalance 250000 cents',
      (tester) async {
        await tester.pumpWidget(buildSubject());

        // Resolve FutureProvider and rebuild
        await tester.pumpAndSettle();

        // 250000 cents / 100.0 = 2500.0 → CurrencyFormatter → '$2,500.00'
        expect(
          find.text('\$2,500.00'),
          findsOneWidget,
          reason: 'Cash to Invest must show the REST totalBalance of '
              '250000 cents as \$2,500.00, proving the integer-cents '
              '→ double-dollars precision pipeline is wired end-to-end.',
        );
      },
    );

    testWidgets(
      'Recent Activity renders 2 items from REST recentActivity',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        // The trailing amounts prove each activity item was mapped from int cents correctly.
        // BUY item: 50000 cents / 100 = $500.00, non-withdrawal → '+ $500.00'
        expect(find.text('+ \$500.00'), findsOneWidget,
            reason:
                'BUY activity item (50000 cents) must render as + \$500.00');

        // DEPOSIT item: 10000 cents / 100 = $100.00, non-withdrawal → '+ $100.00'
        expect(find.text('+ \$100.00'), findsOneWidget,
            reason:
                'DEPOSIT activity item (10000 cents) must render as + \$100.00');

        // 'Deposit' title is unique — does not collide with Quick Action button labels
        expect(find.text('Deposit'), findsOneWidget);
      },
    );
  });
}
