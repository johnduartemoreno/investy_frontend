import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:investy/features/dashboard/data/models/owl_session_model.dart';
import 'package:investy/features/dashboard/data/models/recommendation_model.dart';
import 'package:investy/features/dashboard/presentation/providers/owl_history_provider.dart';
import 'package:investy/features/dashboard/presentation/screens/owl_history_screen.dart';
import 'package:investy/l10n/app_localizations.dart';

final _session = OwlSessionModel(
  id: 'sess-1',
  language: 'en',
  createdAt: DateTime.now().toUtc(),
  recommendations: const [
    RecommendationModel(
      ticker: 'VTI',
      name: 'Vanguard Total Stock Market',
      reason: 'Broad diversification.',
      suggestedAmountCents: 50000,
      strong: true,
    ),
  ],
  contextSnapshot: const OwlContextSnapshot(
    portfolioValueCents: 1200000,
    cashBalanceCents: 350000,
    riskProfile: 'moderate',
    holdingsCount: 4,
  ),
);

Widget _buildSubject(List<OwlSessionModel> sessions) {
  return ProviderScope(
    overrides: [
      owlHistoryProvider.overrideWith((ref) async => sessions),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: OwlHistoryScreen(),
    ),
  );
}

void main() {
  group('OwlHistoryScreen', () {
    testWidgets('renders session card with ticker chip and today badge',
        (tester) async {
      await tester.pumpWidget(_buildSubject([_session]));
      await tester.pumpAndSettle();

      expect(find.text('VTI'), findsOneWidget);
      // Session created now → "Today" badge (owlHistoryDaysAgo, days = 0)
      expect(find.text('Today'), findsOneWidget);
      // Context snapshot caption proves the cents → dollars pipeline
      expect(find.textContaining('\$12,000.00'), findsOneWidget);
    });

    testWidgets('shows empty state when no sessions exist', (tester) async {
      await tester.pumpWidget(_buildSubject([]));
      await tester.pumpAndSettle();

      expect(
        find.text(
            'No sessions yet. Ask Owl for recommendations to start your history.'),
        findsOneWidget,
      );
    });

    testWidgets('tapping a session opens the read-only detail sheet',
        (tester) async {
      await tester.pumpWidget(_buildSubject([_session]));
      await tester.pumpAndSettle();

      await tester.tap(find.text('VTI'));
      await tester.pumpAndSettle();

      // Detail sheet shows the recommendation reason (read-only view)
      expect(find.text('Broad diversification.'), findsOneWidget);
      // Suggested amount: 50000 cents = $500.00
      expect(find.text('\$500.00'), findsOneWidget);
    });

    testWidgets('detail sheet close button dismisses the sheet',
        (tester) async {
      await tester.pumpWidget(_buildSubject([_session]));
      await tester.pumpAndSettle();

      await tester.tap(find.text('VTI'));
      await tester.pumpAndSettle();
      expect(find.text('Broad diversification.'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Broad diversification.'), findsNothing);
    });
  });
}
