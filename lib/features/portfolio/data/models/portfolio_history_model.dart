/// One daily point of the portfolio-value series (B43). All money is int cents
/// on the wire; the UI converts to display currency at render (ADR-03).
class PortfolioHistoryPoint {
  final String date; // YYYY-MM-DD
  final int totalCents;
  final int investedCents;
  final int cashCents;

  const PortfolioHistoryPoint({
    required this.date,
    required this.totalCents,
    required this.investedCents,
    required this.cashCents,
  });

  // Strict money parsing (B40-F7): no silent defaults on critical money fields.
  factory PortfolioHistoryPoint.fromJson(Map<String, dynamic> json) {
    return PortfolioHistoryPoint(
      date: json['date'] as String,
      totalCents: (json['totalCents'] as num).toInt(),
      investedCents: (json['investedCents'] as num).toInt(),
      cashCents: (json['cashCents'] as num).toInt(),
    );
  }

  double get totalAmount => totalCents / 100.0;
}

class PortfolioHistoryModel {
  final String range;
  final String currency; // always USD; UI applies fxRate
  final List<PortfolioHistoryPoint> points;

  const PortfolioHistoryModel({
    required this.range,
    required this.currency,
    required this.points,
  });

  factory PortfolioHistoryModel.fromJson(Map<String, dynamic> json) {
    final rawPoints = json['points'] as List<dynamic>? ?? const [];
    return PortfolioHistoryModel(
      range: json['range'] as String? ?? '',
      currency: json['currency'] as String? ?? 'USD',
      points: rawPoints
          .map((e) => PortfolioHistoryPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
