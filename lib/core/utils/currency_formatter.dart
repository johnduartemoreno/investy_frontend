import 'package:intl/intl.dart';

/// Centralized currency formatter for the entire Presentation Layer.
///
/// All UI surfaces must use this class to display monetary values,
/// ensuring consistent formatting (e.g., "$27,500.00") across the app.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _usdFmt =
      NumberFormat.simpleCurrency(decimalDigits: 2);

  /// Formats [value] as USD: "$1,234.56".
  static String format(double value) => _usdFmt.format(value);

  /// Formats [value] with the given ISO 4217 [currencyCode] (e.g. "EUR" → "€1,234.56").
  /// Falls back to USD formatting if the currency code is unknown.
  static String formatWithCurrency(double value, String currencyCode) {
    try {
      final fmt = NumberFormat.simpleCurrency(
          name: currencyCode, decimalDigits: 2);
      return fmt.format(value);
    } catch (_) {
      return _usdFmt.format(value);
    }
  }

  /// The raw [NumberFormat] instance for widgets that need to pass it around.
  static NumberFormat get instance => _usdFmt;
}
