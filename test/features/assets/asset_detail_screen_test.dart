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
      // Firebase is not initialised in widget tests. The double records the
      // call rather than swallowing it — see the class comment.
      fitScoreControllerProvider('detail')
                .overrideWith(_RecordingFitScoreController.new),
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
    // The asset detail screen has no purchase in progress, so it asks about the
    // position as it stands — amount zero. Nothing asserted this before, which
    // is half of why the S19 audit's finding went unnoticed: the real controller
    // rejected zero and the card silently never appeared.
    testWidgets('pide el fit de la posición actual, con monto cero',
        (tester) async {
      _RecordingFitScoreController.lastAmountCents = null;
      _RecordingFitScoreController.lastSymbol = null;

      await tester.pumpWidget(_subject());
      await tester.pumpAndSettle();

      expect(_RecordingFitScoreController.lastSymbol, 'AAPL');
      expect(_RecordingFitScoreController.lastAmountCents, 0,
          reason: 'un monto inventado produciría un veredicto sobre una compra '
              'que nadie está haciendo');
    });

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
            fitScoreControllerProvider('detail')
                .overrideWith(_RecordingFitScoreController.new),
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

/// Records what the screen asked for instead of calling out, so the detail
/// screen can be tested without Firebase or the network.
///
/// It records rather than no-ops on purpose. The S19 audit found that the real
/// controller refused `amountCents: 0` and the card therefore never rendered —
/// and the earlier version of this double, whose `fetch` was an empty `async {}`,
/// would have passed identically with or without that defect. A double that
/// swallows the call cannot notice the call being wrong.
class _RecordingFitScoreController extends FitScoreController {
  static int? lastAmountCents;
  static String? lastSymbol;

  @override
  FutureOr<FitScoreModel?> build(String scope) => null;

  @override
  Future<void> fetch({
    required String symbol,
    required int amountCents,
    String? goalId,
    String language = 'en',
  }) async {
    lastSymbol = symbol;
    lastAmountCents = amountCents;
  }
}
