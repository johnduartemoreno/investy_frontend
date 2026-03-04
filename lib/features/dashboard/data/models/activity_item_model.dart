import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/contribution.dart';

part 'activity_item_model.g.dart';

/// REST DTO for a single item in the dashboard activity feed.
/// Corresponds to the ActivityItem schema in docs/openapi.yaml.
/// All monetary values are integer cents: $1.00 = 100.
@JsonSerializable()
class ActivityItemModel {
  final String id;

  /// Amount in integer cents. $1.00 = 100. Never a double.
  final int amount;

  /// Transaction type as returned by the API: "BUY", "SELL", "DEPOSIT", "WITHDRAWAL".
  final String type;

  final String timestamp;

  const ActivityItemModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.timestamp,
  });

  factory ActivityItemModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityItemModelToJson(this);

  /// Maps integer cents → domain Contribution entity (double dollars).
  /// Precision rule: amount (int cents) / 100.0 → Contribution.amount (double dollars).
  /// Normalises type to lowercase ("BUY" → "buy") for domain entity consistency.
  Contribution toDomain() {
    return Contribution(
      id: id,
      amount: amount / 100.0, // cents → dollars: $1.00 = 100
      type: type.toLowerCase(),
      createdAt: DateTime.parse(timestamp),
    );
  }
}
