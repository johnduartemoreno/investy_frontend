import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:investy/features/alerts/data/models/price_alert_model.dart';
import 'package:investy/features/alerts/presentation/providers/alerts_provider.dart';
import 'package:investy/features/alerts/presentation/screens/price_alerts_screen.dart';
import 'package:investy/l10n/app_localizations.dart';

const _activeAlert = PriceAlertModel(
  id: 'a1',
  symbol: 'AAPL',
  direction: 'above',
  targetPriceCents: 20000, // $200.00
  status: 'active',
  createdAt: '2026-06-19T10:00:00Z',
);

Widget _buildSubject(List<PriceAlertModel> alerts) {
  return ProviderScope(
    overrides: [
      alertsProvider.overrideWith((ref) async => alerts),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: PriceAlertsScreen(),
    ),
  );
}

void main() {
  group('PriceAlertsScreen', () {
    testWidgets('renders an alert tile with symbol, condition and status',
        (tester) async {
      await tester.pumpWidget(_buildSubject([_activeAlert]));
      await tester.pumpAndSettle();

      // ticker appears twice: GradientIconBox label + tile title
      expect(find.text('AAPL'), findsNWidgets(2));
      // condition: "Above $200.00" — proves the cents → dollars pipeline
      expect(find.textContaining('\$200.00'), findsOneWidget);
      // active status badge
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('shows empty state when there are no alerts', (tester) async {
      await tester.pumpWidget(_buildSubject([]));
      await tester.pumpAndSettle();

      expect(find.text('You have no price alerts yet.'), findsOneWidget);
    });

    testWidgets('opens the create sheet from the app bar action',
        (tester) async {
      await tester.pumpWidget(_buildSubject([]));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('New price alert'), findsOneWidget);
    });
  });
}
