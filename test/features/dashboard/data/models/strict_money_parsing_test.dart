import 'package:flutter_test/flutter_test.dart';
import 'package:investy/features/alerts/data/models/price_alert_model.dart';
import 'package:investy/features/dashboard/data/models/asset_search_result_model.dart';
import 'package:investy/features/dashboard/data/models/dashboard_response_model.dart';
import 'package:investy/features/portfolio/data/models/portfolio_response_model.dart';

/// B40-F7 strict data governance: money fields have no silent defaults.
/// A missing/null money field from the backend must throw during parsing —
/// never render as a fake $0 value.
void main() {
  group('strict money parsing (B40-F7)', () {
    test('AssetSearchResultModel throws when currentPriceCents is missing',
        () {
      expect(
        () => AssetSearchResultModel.fromJson(const {
          'symbol': 'AAPL',
          'name': 'Apple Inc.',
          'assetClass': 'stock',
          'logoUrl': '',
        }),
        throwsA(isA<TypeError>()),
      );
    });

    test('AssetSearchResultModel parses when currentPriceCents is present',
        () {
      final m = AssetSearchResultModel.fromJson(const {
        'symbol': 'AAPL',
        'name': 'Apple Inc.',
        'assetClass': 'stock',
        'currentPriceCents': 19850,
        'logoUrl': '',
      });
      expect(m.currentPriceCents, 19850);
      expect(m.currentPrice, 198.50);
    });

    test('PriceAlertModel throws when targetPriceCents is null', () {
      expect(
        () => PriceAlertModel.fromJson(const {
          'id': 'a1',
          'symbol': 'BTC',
          'direction': 'above',
          'targetPriceCents': null,
          'status': 'active',
          'createdAt': '2026-07-08T00:00:00Z',
        }),
        throwsA(isA<TypeError>()),
      );
    });

    test('DashboardResponseModel throws when totalBalance is missing', () {
      expect(
        () => DashboardResponseModel.fromJson(const {
          'userName': 'Ana',
          'investedValue': 5000,
          'currency': 'USD',
          'recentActivity': <dynamic>[],
        }),
        throwsA(isA<TypeError>()),
      );
    });

    test('Portfolio holding throws when avgCostCents is missing', () {
      expect(
        () => PortfolioResponseModel.fromJson(const {
          'totalInvestedCents': 100000,
          'currency': 'USD',
          'holdings': [
            {
              'symbol': 'VTI',
              'name': 'Vanguard Total',
              'assetClass': 'etf',
              'quantityUnits': 100000000,
              'currentPriceCents': 25000,
              'logoUrl': '',
            }
          ],
        }),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
