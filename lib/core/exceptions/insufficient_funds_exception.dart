import '../utils/currency_formatter.dart';

/// Exception thrown when a financial operation requires more funds
/// than are currently available in the user's wallet.
class InsufficientFundsException implements Exception {
  /// Available balance in human-readable dollars (double).
  final double available;

  /// Requested amount in human-readable dollars (double).
  final double requested;

  /// The action that was attempted (e.g., 'withdrawal', 'buy').
  final String action;

  const InsufficientFundsException({
    required this.available,
    required this.requested,
    required this.action,
  });

  @override
  String toString() => 'Insufficient funds for $action. '
      'Available: ${CurrencyFormatter.format(available)}, '
      'Requested: ${CurrencyFormatter.format(requested)}';
}
