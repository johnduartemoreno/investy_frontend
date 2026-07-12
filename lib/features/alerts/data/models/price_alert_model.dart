/// Wire model for the price-alerts REST endpoints (B12).
/// All monetary values are integer cents: $1.00 = 100. Never a double.
class PriceAlertModel {
  final String id;
  final String symbol;

  /// 'above' | 'below' — comparison applied between live price and target.
  final String direction;

  /// Target price in integer cents. $1.00 = 100.
  final int targetPriceCents;

  /// 'active' | 'triggered'.
  final String status;

  /// RFC 3339 timestamp of creation.
  final String createdAt;

  /// RFC 3339 timestamp of when the alert fired; empty while active.
  final String triggeredAt;

  const PriceAlertModel({
    required this.id,
    required this.symbol,
    required this.direction,
    required this.targetPriceCents,
    required this.status,
    required this.createdAt,
    this.triggeredAt = '',
  });

  factory PriceAlertModel.fromJson(Map<String, dynamic> json) {
    return PriceAlertModel(
      id: json['id'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      direction: json['direction'] as String? ?? 'above',
      // No default — a null target price must fail loudly (B40-F7).
      targetPriceCents: (json['targetPriceCents'] as num).toInt(),
      status: json['status'] as String? ?? 'active',
      createdAt: json['createdAt'] as String? ?? '',
      triggeredAt: json['triggeredAt'] as String? ?? '',
    );
  }

  /// Target price in display dollars.
  double get targetPrice => targetPriceCents / 100.0;

  bool get isAbove => direction == 'above';
  bool get isActive => status == 'active';
  bool get isTriggered => status == 'triggered';

  DateTime get createdAtDate => DateTime.parse(createdAt).toLocal();
}
