import 'package:freezed_annotation/freezed_annotation.dart';

part 'holding.freezed.dart';
part 'holding.g.dart';

/// Entity representing a user's holding.
/// Maps to Firestore: users/{uid}/holdings/{holdingId}
@freezed
class Holding with _$Holding {
  const Holding._();

  const factory Holding({
    required String id,
    required String symbol,
    required double quantity,
    @JsonKey(name: 'avg_cost') required double avgCost,
    @JsonKey(name: 'asset_class') required String assetClass,

    /// Current price fetched from external API.
    /// Nullable until price is fetched. Not persisted to Firestore.
    @JsonKey(includeFromJson: false, includeToJson: false) double? currentPrice,

    /// Audit: last update timestamp.
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Holding;

  factory Holding.fromJson(Map<String, dynamic> json) =>
      _$HoldingFromJson(json);

  /// Returns the current price or 0.0 if not yet fetched.
  double get currentPriceOrZero => currentPrice ?? 0.0;

  /// Calculates the current market value of this holding.
  double get marketValue => quantity * currentPriceOrZero;

  /// Calculates the total cost basis for this holding.
  double get costBasis => quantity * avgCost;

  /// Calculates the unrealized gain/loss.
  double get unrealizedGainLoss => marketValue - costBasis;
}
