import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/wallet.dart';
import 'activity_item_model.dart';

part 'dashboard_response_model.g.dart';

/// REST DTO for GET /api/v1/users/{userId}/dashboard.
/// Corresponds to the DashboardResponse schema in docs/openapi.yaml.
/// All monetary values are integer cents: $1.00 = 100.
@JsonSerializable(explicitToJson: true)
class DashboardResponseModel {
  /// Total wallet balance in integer cents. $1.00 = 100. Never a double.
  final int totalBalance;

  /// Total market value of all holdings in integer cents. $1.00 = 100.
  /// Calculated server-side: SUM(QuantityUnits * CurrentPriceCents / 10^8).
  final int investedValue;

  /// ISO 4217 currency code (e.g. "USD").
  final String currency;

  /// Most recent transactions, newest-first.
  final List<ActivityItemModel> recentActivity;

  const DashboardResponseModel({
    required this.totalBalance,
    required this.investedValue,
    required this.currency,
    required this.recentActivity,
  });

  factory DashboardResponseModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardResponseModelToJson(this);

  /// Maps integer cents → domain Wallet entity (double dollars).
  /// Precision rule: totalBalance (int cents) / 100.0 → Wallet.availableCash (double dollars).
  Wallet toDomainWallet() {
    return Wallet(availableCash: totalBalance / 100.0); // cents → dollars
  }
}
