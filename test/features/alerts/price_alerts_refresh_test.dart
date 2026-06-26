import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:investy/core/presentation/widgets/primary_button.dart';
import 'package:investy/core/providers/current_user_provider.dart';
import 'package:investy/features/alerts/data/datasources/alerts_remote_data_source.dart';
import 'package:investy/features/alerts/data/models/price_alert_model.dart';
import 'package:investy/features/alerts/presentation/screens/price_alerts_screen.dart';
import 'package:investy/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:investy/features/dashboard/data/models/asset_search_result_model.dart';
import 'package:investy/l10n/app_localizations.dart';

/// In-memory stand-in for the backend: allows duplicate alerts and re-creates
/// after deletion, exactly like the real `price_alerts` table (no uniqueness).
class _FakeAlertsDataSource implements AlertsRemoteDataSource {
  final List<PriceAlertModel> store = [];
  int _seq = 0;

  @override
  Future<List<PriceAlertModel>> getAlerts(String userId) async =>
      List.of(store);

  @override
  Future<PriceAlertModel> createAlert(
    String userId, {
    required String symbol,
    required String direction,
    required int targetPriceCents,
  }) async {
    final alert = PriceAlertModel(
      id: 'id-${_seq++}',
      symbol: symbol,
      direction: direction,
      targetPriceCents: targetPriceCents,
      status: 'active',
      createdAt: '2026-06-25T00:00:00Z',
    );
    store.add(alert);
    return alert;
  }

  @override
  Future<void> deleteAlert(String userId, String alertId) async {
    store.removeWhere((a) => a.id == alertId);
  }
}

class _FakeDashboardDataSource implements DashboardRemoteDataSource {
  @override
  Future<List<AssetSearchResultModel>> searchAssets(String query) async => const [
        AssetSearchResultModel(
          symbol: 'AAPL',
          name: 'Apple Inc.',
          assetClass: 'stock',
          currentPriceCents: 27500,
        ),
      ];

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Widget _subject(_FakeAlertsDataSource alerts) {
  return ProviderScope(
    overrides: [
      currentUserIdProvider.overrideWithValue('u1'),
      alertsRemoteDataSourceProvider.overrideWithValue(alerts),
      dashboardRemoteDataSourceProvider
          .overrideWithValue(_FakeDashboardDataSource()),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: PriceAlertsScreen(),
    ),
  );
}

Future<void> _createAlertViaSheet(WidgetTester tester, String price) async {
  // Open the sheet
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();

  // Search → pick AAPL (first TextFormField is the asset search field)
  await tester.enterText(find.byType(TextFormField).first, 'AAPL');
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ListTile, 'AAPL'));
  await tester.pumpAndSettle();

  // Target price (second TextFormField is the price field)
  await tester.enterText(find.byType(TextFormField).at(1), price);
  await tester.pumpAndSettle();

  // Create
  await tester.ensureVisible(find.byType(PrimaryButton));
  await tester.tap(find.byType(PrimaryButton));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
      'created alert appears in the list, survives delete-all, and re-appears '
      'on re-create (B12 refresh regression)', (tester) async {
    final fake = _FakeAlertsDataSource();
    await tester.pumpWidget(_subject(fake));
    await tester.pumpAndSettle();

    // Starts empty
    expect(find.text('You have no price alerts yet.'), findsOneWidget);

    // 1) Create above $300 → must show in the list (the bug: it didn't)
    await _createAlertViaSheet(tester, '300');
    expect(find.text('AAPL'), findsNWidgets(2)); // GradientIconBox + title
    expect(find.text('Alert created'), findsOneWidget); // snackbar

    // 2) Delete it → list goes back to empty
    await tester.tap(find.byTooltip('Delete alert'));
    await tester.pumpAndSettle();
    expect(find.text('You have no price alerts yet.'), findsOneWidget);

    // 3) Re-create the SAME alert → must show again (no phantom "already created")
    await _createAlertViaSheet(tester, '300');
    expect(find.text('AAPL'), findsNWidgets(2));
    expect(fake.store.length, 1);
  });
}
