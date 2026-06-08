/// REST DTO for POST /api/v1/users/{userId}/transactions.
///
/// DEPOSIT/WITHDRAWAL: send [amount] in integer cents ($1.00 = 100).
/// BUY/SELL: send [quantity] as decimal string + [priceCents] per unit.
///   The backend converts quantity → quantity_units (×10^8) internally.
///   The frontend never handles the ×10^8 scale.
class TransactionRequestModel {
  final int? amount;      // DEPOSIT/WITHDRAWAL: total cents
  final String type;      // BUY | SELL | DEPOSIT | WITHDRAWAL
  final String? symbol;   // required for BUY/SELL
  final String? quantity; // BUY/SELL: decimal string e.g. "2.5"
  final int? priceCents;  // BUY/SELL: price per unit in integer cents
  final String? goalId;   // BUY: optional goal (UUID) to assign this purchase to

  const TransactionRequestModel({
    this.amount,
    required this.type,
    this.symbol,
    this.quantity,
    this.priceCents,
    this.goalId,
  });

  /// For DEPOSIT / WITHDRAWAL — sends total amount in cents.
  factory TransactionRequestModel.forCash(double amountDollars, String type) {
    return TransactionRequestModel(
      amount: (amountDollars * 100).round(),
      type: type.toUpperCase(),
    );
  }

  /// For BUY / SELL — sends quantity (string) + priceCents separately.
  /// The backend handles the internal ×10^8 conversion.
  factory TransactionRequestModel.forTrade({
    required String type,
    required String symbol,
    required double quantity,
    required double pricePerUnit,
    String? goalId,
  }) {
    return TransactionRequestModel(
      type: type.toUpperCase(),
      symbol: symbol,
      quantity: quantity.toString(),
      priceCents: (pricePerUnit * 100).round(),
      goalId: goalId,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        if (amount != null) 'amount': amount,
        if (symbol != null) 'symbol': symbol,
        if (quantity != null) 'quantity': quantity,
        if (priceCents != null) 'priceCents': priceCents,
        if (goalId != null) 'goalId': goalId,
      };
}
