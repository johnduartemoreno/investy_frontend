/// Daily closing price series for one asset (B43 — asset detail chart).
/// Prices are int USD cents on the wire; UI applies fxRate at render (ADR-03).
class AssetHistoryPoint {
  final String date; // YYYY-MM-DD
  final int priceCents;

  const AssetHistoryPoint({required this.date, required this.priceCents});

  factory AssetHistoryPoint.fromJson(Map<String, dynamic> json) {
    return AssetHistoryPoint(
      date: json['date'] as String,
      priceCents: (json['priceCents'] as num).toInt(), // strict (B40-F7)
    );
  }

  double get price => priceCents / 100.0;
}

class AssetHistoryModel {
  final String symbol;
  final String range;
  final List<AssetHistoryPoint> points;

  const AssetHistoryModel({
    required this.symbol,
    required this.range,
    required this.points,
  });

  factory AssetHistoryModel.fromJson(Map<String, dynamic> json) {
    final raw = json['points'] as List<dynamic>? ?? const [];
    return AssetHistoryModel(
      symbol: json['symbol'] as String? ?? '',
      range: json['range'] as String? ?? '',
      points: raw
          .map((e) => AssetHistoryPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
