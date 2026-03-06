/// REST DTO for POST /api/v1/users/{userId}/transactions.
///
/// [amount] is in integer cents — $1.00 = 100. Never a float.
/// [type] matches the OpenAPI enum: BUY | SELL | DEPOSIT | WITHDRAWAL.
/// [symbol] is required for BUY/SELL; omitted for DEPOSIT/WITHDRAWAL.
class TransactionRequestModel {
  final int amount; // integer cents: $1.00 = 100
  final String type; // BUY | SELL | DEPOSIT | WITHDRAWAL
  final String? symbol; // required for BUY/SELL

  const TransactionRequestModel({
    required this.amount,
    required this.type,
    this.symbol,
  });

  /// Converts a UI [double] dollar amount to integer cents.
  ///
  /// [amount] is in dollars (e.g. 500.00 → 50000 cents).
  /// Uses `.round()` to eliminate floating-point drift (e.g. 9.99 * 100 = 998.9999...).
  factory TransactionRequestModel.fromDomain(
    double amount,
    String type, {
    String? symbol,
  }) {
    return TransactionRequestModel(
      amount: (amount * 100).round(),
      type: type.toUpperCase(),
      symbol: symbol,
    );
  }

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'type': type,
        if (symbol != null) 'symbol': symbol,
      };
}
