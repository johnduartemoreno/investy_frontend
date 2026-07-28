import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:investy/features/dashboard/presentation/screens/dashboard_screen.dart'
    show displayCurrencyProvider, fxRateProvider;
import 'package:investy/features/portfolio/data/models/portfolio_response_model.dart';
import 'package:investy/features/portfolio/presentation/portfolio_screen.dart';
import 'package:investy/features/portfolio/presentation/providers/rest_portfolio_provider.dart';
import 'package:investy/l10n/app_localizations.dart';

const _empty = PortfolioResponseModel(
  holdings: [],
  totalInvestedCents: 0,
  currency: 'USD',
);

Widget _subject() {
  final router = GoRouter(
    initialLocation: '/portfolio',
    routes: [
      GoRoute(
        path: '/portfolio',
        builder: (_, __) => const PortfolioScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const Scaffold(body: Text('HOME')),
        routes: [
          GoRoute(
            path: 'buy-asset',
            builder: (_, __) => const Scaffold(body: Text('BUY ASSET SCREEN')),
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      displayCurrencyProvider.overrideWith((ref) => 'USD'),
      fxRateProvider.overrideWith((ref) async => 1.0),
      restPortfolioProvider.overrideWith((ref) async => _empty),
    ],
    child: MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

void main() {
  group('PortfolioScreen — first-use empty state (B54)', () {
    testWidgets('shows the message once, not duplicated', (tester) async {
      await tester.pumpWidget(_subject());
      await tester.pumpAndSettle();

      expect(find.text('No holdings yet'), findsOneWidget);
      expect(
        find.text('Buy your first asset to start building your portfolio.'),
        findsOneWidget,
      );
    });

    testWidgets('the CTA goes to the buy flow, not back to Home',
        (tester) async {
      await tester.pumpWidget(_subject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Buy my first asset'));
      await tester.pumpAndSettle();

      expect(find.text('BUY ASSET SCREEN'), findsOneWidget);
      expect(find.text('HOME'), findsNothing);
    });
  });
}
