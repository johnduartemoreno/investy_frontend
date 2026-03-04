import 'package:freezed_annotation/freezed_annotation.dart';

part 'contribution.freezed.dart';
part 'contribution.g.dart';

/// Entity representing a contribution (deposit or withdrawal).
/// Maps to Firestore: users/{uid}/contributions/{contributionId}
/// This is an immutable ledger — entries are never updated after creation.
@freezed
class Contribution with _$Contribution {
  const factory Contribution({
    required String id,
    required double amount,

    /// Type of contribution: "deposit" or "withdrawal"
    required String type,

    /// Audit: immutable creation time.
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Optional human-readable description (e.g., "Buy AAPL").
    String? description,

    /// Links to the transaction that created this contribution (e.g., a buy).
    /// Null for standalone deposits/withdrawals.
    @JsonKey(name: 'transaction_id') String? transactionId,

    /// Wallet balance after this transaction.
    @JsonKey(name: 'running_balance') double? runningBalance,
  }) = _Contribution;

  factory Contribution.fromJson(Map<String, dynamic> json) =>
      _$ContributionFromJson(json);
}
