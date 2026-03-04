import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet.freezed.dart';
part 'wallet.g.dart';

/// Entity representing the user's wallet.
/// Maps to Firestore: users/{uid}/wallet/main
@freezed
class Wallet with _$Wallet {
  const factory Wallet({
    @JsonKey(name: 'available_cash') @Default(0.0) double availableCash,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Wallet;

  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);
}
