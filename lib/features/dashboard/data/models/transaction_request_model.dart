/// REST DTO for POST /api/v1/users/{userId}/transactions.
///
/// [amount] is in integer cents — $1.00 = 100. Never a float.
/// [type] matches the OpenAPI enum: BUY | SELL | DEPOSIT | WITHDRAWAL.
class TransactionRequestModel {
  final int amount; // integer cents: $1.00 = 100
  final String type; // BUY | SELL | DEPOSIT | WITHDRAWAL

  const TransactionRequestModel({required this.amount, required this.type});

  /// Converts a UI [double] dollar amount to integer cents.
  ///
  /// [amount] is in dollars (e.g. 500.00 → 50000 cents).
  /// Uses `.round()` to eliminate floating-point drift (e.g. 9.99 * 100 = 998.9999...).
  factory TransactionRequestModel.fromDomain(double amount, String type) {
    return TransactionRequestModel(
      amount: (amount * 100).round(),
      type: type.toUpperCase(),
    );
  }

  Map<String, dynamic> toJson() => {'amount': amount, 'type': type};
}
