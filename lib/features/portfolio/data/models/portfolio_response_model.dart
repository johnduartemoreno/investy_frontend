import 'dart:convert';

/// Wire model for GET /api/v1/users/{userId}/portfolio.
/// All monetary values arrive as integer cents from the backend.
/// Quantity arrives as int64 scaled ×10^8 (1 share = 100_000_000 units).
class PortfolioResponseModel {
  final List<PortfolioHoldingModel> holdings;
  final int totalInvestedCents; // integer cents
  final String currency;

  const PortfolioResponseModel({
    required this.holdings,
    required this.totalInvestedCents,
    required this.currency,
  });

  /// Total invested value in display dollars.
  double get totalInvestedAmount => totalInvestedCents / 100.0;

  factory PortfolioResponseModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['holdings'] as List<dynamic>? ?? [];
    return PortfolioResponseModel(
      holdings: rawList
          .map((e) => PortfolioHoldingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalInvestedCents: (json['totalInvestedCents'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
    );
  }

  static PortfolioResponseModel fromJsonString(String source) =>
      PortfolioResponseModel.fromJson(
          json.decode(source) as Map<String, dynamic>);
}

class PortfolioHoldingModel {
  final String symbol;
  final String name;
  final String assetClass; // "stock" | "crypto" | "etf"
  final int quantityUnits; // scaled ×10^8
  final int avgCostCents; // integer cents
  final int currentPriceCents; // integer cents
  final String logoUrl;

  const PortfolioHoldingModel({
    required this.symbol,
    required this.name,
    required this.assetClass,
    required this.quantityUnits,
    required this.avgCostCents,
    required this.currentPriceCents,
    this.logoUrl = '',
  });

  // --- Display helpers ---

  /// Quantity in human-readable units (shares / coins).
  double get quantity => quantityUnits / 1e8;

  /// Average cost per unit in display dollars.
  double get avgCost => avgCostCents / 100.0;

  /// Current price per unit in display dollars.
  double get currentPrice => currentPriceCents / 100.0;

  /// Current market value of the holding in display dollars.
  double get marketValue => quantity * currentPrice;

  /// Total cost basis of the holding in display dollars.
  double get costBasis => quantity * avgCost;

  /// Unrealized gain/loss in display dollars.
  double get unrealizedGainLoss => marketValue - costBasis;

  /// Return percentage: ((currentPrice - avgCost) / avgCost) * 100.
  /// Returns 0 if avgCost is zero to avoid division by zero.
  double get returnPct =>
      avgCostCents > 0 ? ((currentPrice - avgCost) / avgCost) * 100 : 0.0;

  factory PortfolioHoldingModel.fromJson(Map<String, dynamic> json) {
    return PortfolioHoldingModel(
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      assetClass: json['assetClass'] as String? ?? 'stock',
      quantityUnits: (json['quantityUnits'] as num?)?.toInt() ?? 0,
      avgCostCents: (json['avgCostCents'] as num?)?.toInt() ?? 0,
      currentPriceCents: (json['currentPriceCents'] as num?)?.toInt() ?? 0,
      logoUrl: json['logoUrl'] as String? ?? '',
    );
  }
}
