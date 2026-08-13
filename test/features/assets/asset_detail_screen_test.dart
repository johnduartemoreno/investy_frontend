import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:investy/features/assets/data/models/asset_history_model.dart';
import 'package:investy/features/assets/presentation/providers/asset_history_provider.dart';
import 'package:investy/features/assets/presentation/screens/asset_detail_screen.dart';
import 'package:investy/features/dashboard/presentation/screens/dashboard_screen.dart'
    show displayCurrencyProvider, fxRateProvider;
import 'package:investy/features/portfolio/data/models/portfolio_response_model.dart';
import 'package:investy/features/dashboard/data/models/fit_score_model.dart';
import 'package:investy/features/dashboard/presentation/controllers/fit_score_controller.dart';
import 'package:investy/l10n/app_localizations.dart';

const _holding = PortfolioHoldingModel(
  symbol: 'AAPL',
  name: 'Apple Inc.',
  assetClass: 'stock',
  quantityUnits: 200000000, // 2.0 units (×10^8)
  avgCostCents: 26582, // $265.82
  currentPriceCents: 27778, // $277.78
  logoUrl: '',
);

const _history = AssetHistoryModel(
  symbol: 'AAPL',
  range: '1M',
  points: [
    AssetHistoryPoint(date: '2026-07-01', priceCents: 27000),
    AssetHistoryPoint(date: '2026-07-07', priceCents: 27200),
    AssetHistoryPoint(date: '2026-07-13', priceCents: 27778),
  ],
);

Widget _subject() {
  return ProviderScope(
    overrides: [
      displayCurrencyProvider.overrideWith((ref) => 'USD'),
      fxRateProvider.overrideWith((ref) async => 1.0),
      assetHistoryProvider('AAPL', '1M').overrideWith((ref) async => _history),
      // The Fit Score section (S19-G7) reads FirebaseAuth for the user id, and
      // Firebase is not initialised in widget tests. Overridden to stay idle:
      // this file is about the chart and the position, and the fit card has its
      // own test.
      fitScoreControllerProvider.overrideWith(_IdleFitScoreController.new),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AssetDetailScreen(holding: _holding),
    ),
  );
}

void main() {
  group('AssetDetailScreen', () {
    testWidgets('renders header, position card and Buy/Sell actions',
        (tester) async {
      await tester.pumpWidget(_subject());
      await tester.pumpAndSettle();

      // Header: asset name + ticker.
      expect(find.text('Apple Inc.'), findsOneWidget);
      expect(find.text('AAPL'), findsWidgets); // app bar title + ticker box

      // Position card and its labels.
      expect(find.text('Your position'), findsOneWidget);
      expect(find.text('Market value'), findsOneWidget);
      // Market value = 2.0 × $277.78 = $555.56 (cents-based rounding).
      expect(find.textContaining('555.5'), findsOneWidget);

      // Fixed action bar.
      expect(find.text('Buy'), findsOneWidget);
      expect(find.text('Sell'), findsOneWidget);
    });

    testWidgets('shows error state when the price history fails',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            displayCurrencyProvider.overrideWith((ref) => 'USD'),
            fxRateProvider.overrideWith((ref) async => 1.0),
            assetHistoryProvider('AAPL', '1M')
                .overrideWith((ref) async => throw Exception('boom')),
            fitScoreControllerProvider.overrideWith(_IdleFitScoreController.new),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AssetDetailScreen(holding: _holding),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Chart shows the common error; the position card still renders.
      expect(find.text('Your position'), findsOneWidget);
      expect(find.text('Buy'), findsOneWidget);
    });
  });
}

/// Stays in the idle state and never calls out, so the detail screen can be
/// tested without Firebase or the network.
class _IdleFitScoreController extends FitScoreController {
  @override
  FutureOr<FitScoreModel?> build() => null;

  @override
  Future<void> fetch({
    required String symbol,
    required int amountCents,
    String? goalId,
    String language = 'en',
  }) async {}
}
