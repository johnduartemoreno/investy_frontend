import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

/// Entity representing a transaction (buy or sell).
/// Maps to Firestore: users/{uid}/transactions/{transactionId}
/// This is an immutable receipt — entries are never updated after creation.
@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required String symbol,

    /// Type of transaction: "buy" or "sell"
    required String type,
    required double quantity,
    required double price,
    @JsonKey(name: 'total_before_fees') required double totalBeforeFees,

    /// Audit: immutable creation time.
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}
