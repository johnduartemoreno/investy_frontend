import 'package:intl/intl.dart';

/// Centralized currency formatter for the entire Presentation Layer.
///
/// All UI surfaces must use this class to display monetary values, ensuring
/// consistent formatting across the app.
///
/// Locale-aware (B51): the number's grouping and decimal separators follow the
/// app's presentation locale (`Intl.getCurrentLocale()`, kept in sync with the
/// in-app language selector) — "$1,234.56" in en, "$1.234,56" in es/pt. The
/// currency symbol stays a stable prefix so screen layouts don't shift with the
/// language.
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Formats [value] as USD in the current locale: "$1,234.56" / "$1.234,56".
  static String format(double value) => formatWithCurrency(value, 'USD');

  /// Formats [value] with the given ISO 4217 [currencyCode] (e.g. "EUR" →
  /// "€1.234,56"). Falls back to USD if the currency code is unknown.
  static String formatWithCurrency(double value, String currencyCode) {
    final symbol = symbolFor(currencyCode);
    final sign = value < 0 ? '-' : '';
    final number =
        NumberFormat('#,##0.00', Intl.getCurrentLocale()).format(value.abs());
    return '$sign$symbol$number';
  }

  /// Returns the currency symbol for the given ISO 4217 [currencyCode] (e.g.
  /// "EUR" → "€").
  static String symbolFor(String currencyCode) {
    try {
      return NumberFormat.simpleCurrency(name: currencyCode).currencySymbol;
    } catch (_) {
      return '\$';
    }
  }
}
