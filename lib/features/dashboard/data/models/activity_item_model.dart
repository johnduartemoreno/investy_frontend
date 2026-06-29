import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/contribution.dart';
import '../../domain/entities/transaction.dart';

part 'activity_item_model.g.dart';

/// REST DTO for a single item in the dashboard activity feed.
/// Corresponds to the ActivityItem schema in docs/openapi.yaml.
/// All monetary values are integer cents: $1.00 = 100.
@JsonSerializable()
class ActivityItemModel {
  @JsonKey(defaultValue: '')
  final String id;

  /// Amount in integer cents. $1.00 = 100. Never a double.
  @JsonKey(defaultValue: 0)
  final int amount;

  /// Transaction type as returned by the API: "BUY", "SELL", "DEPOSIT", "WITHDRAWAL".
  @JsonKey(defaultValue: 'UNKNOWN')
  final String type;

  /// RFC 3339 timestamp string. Defaults to empty string when absent.
  @JsonKey(defaultValue: '')
  final String timestamp;

  /// Asset ticker symbol. Non-empty for BUY/SELL items only.
  @JsonKey(defaultValue: '')
  final String symbol;

  /// Quantity in units × 10^8. Non-zero for BUY/SELL items only.
  @JsonKey(defaultValue: 0)
  final int quantityUnits;

  /// Price per unit in integer cents. Non-zero for BUY/SELL items only.
  @JsonKey(defaultValue: 0)
  final int priceCents;

  /// Net realized P&L in cents for SELL transactions.
  /// Formula: (sell_price - avg_cost_at_sell) * qty / 1e8 - fee_cents.
  /// Zero means: BUY, DEPOSIT, WITHDRAWAL, or pre-migration SELL (avg cost unknown).
  @JsonKey(defaultValue: 0)
  final int realizedPnlCents;

  const ActivityItemModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.timestamp,
    this.symbol = '',
    this.quantityUnits = 0,
    this.priceCents = 0,
    this.realizedPnlCents = 0,
  });

  factory ActivityItemModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityItemModelToJson(this);

  DateTime get _parsedAt => timestamp.isEmpty
      ? DateTime.now().toUtc()
      : DateTime.parse(timestamp).toLocal();

  /// Maps integer cents → domain Contribution entity (double dollars).
  Contribution toDomain() {
    return Contribution(
      id: id,
      amount: amount / 100.0,
      type: type.toLowerCase(),
      createdAt: _parsedAt,
    );
  }

  /// Maps BUY/SELL fields → domain Transaction entity (double dollars, quantity in units).
  /// quantityUnits uses 10^8 fixed-point: divide by 1e8 for human-readable quantity.
  Transaction toTransaction() {
    return Transaction(
      id: id,
      symbol: symbol,
      type: type.toLowerCase(),
      quantity: quantityUnits / 1e8,
      price: priceCents / 100.0,
      totalBeforeFees: amount / 100.0,
      realizedPnlCents: realizedPnlCents,
      createdAt: _parsedAt,
    );
  }
}
