/// Wire model for GET /api/v1/assets?q={query}.
class AssetSearchResultModel {
  final String symbol;
  final String name;
  final String assetClass;
  final int currentPriceCents;
  final String logoUrl;

  const AssetSearchResultModel({
    required this.symbol,
    required this.name,
    required this.assetClass,
    required this.currentPriceCents,
    this.logoUrl = '',
  });

  /// Current price in display dollars.
  double get currentPrice => currentPriceCents / 100.0;

  factory AssetSearchResultModel.fromJson(Map<String, dynamic> json) {
    return AssetSearchResultModel(
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      assetClass: json['assetClass'] as String? ?? 'stock',
      // No default — this price feeds the BUY flow; a fake $0.00 here
      // would let the user submit a zero-priced order (B40-F7).
      currentPriceCents: (json['currentPriceCents'] as num).toInt(),
      logoUrl: json['logoUrl'] as String? ?? '',
    );
  }
}
