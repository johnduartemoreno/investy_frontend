import 'package:freezed_annotation/freezed_annotation.dart';

part 'asset.freezed.dart';
part 'asset.g.dart';

/// Entity representing an investable asset.
/// Maps to Firestore: assets/{symbol}
@freezed
class Asset with _$Asset {
  const factory Asset({
    /// Unique identifier (e.g., 'AAPL', 'BTC').
    required String symbol,
    required String name,
    @JsonKey(name: 'logo_url') required String? logoUrl,
    @JsonKey(name: 'current_price') required double currentPrice,
  }) = _Asset;

  factory Asset.fromJson(Map<String, dynamic> json) => _$AssetFromJson(json);
}
