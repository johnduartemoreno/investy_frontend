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

  /// The broker's settlement currency. Everything the broker executes settles in
  /// USD — ADR-01 (internal storage is USD cents; DriveWealth/Alpaca settle in
  /// USD). This is an architectural invariant, NOT a per-user setting: if it ever
  /// changed it would be an ADR-level change, not a config value. Kept as a single
  /// named constant so "USD" isn't a magic string scattered across the app.
  static const String brokerCurrency = 'USD';

  /// Formats [value] as USD in the current locale: "$1,234.56" / "$1.234,56".
  static String format(double value) => formatWithCurrency(value, brokerCurrency);

  /// Formats [value] with the given ISO 4217 [currencyCode] (e.g. "EUR" →
  /// "€1.234,56"). Falls back to USD if the currency code is unknown.
  static String formatWithCurrency(double value, String currencyCode) {
    final symbol = symbolFor(currencyCode);
    final sign = value < 0 ? '-' : '';
    final number =
        NumberFormat('#,##0.00', Intl.getCurrentLocale()).format(value.abs());
    return '$sign$symbol$number';
  }

  /// A USD amount with its currency code made explicit, for broker/trade
  /// contexts where the value settles in USD and must not be mistaken for the
  /// user's display currency (B50) — e.g. "USD $1,234.56". The number itself is
  /// still grouped in the current locale.
  static String formatUsd(double value) => '$brokerCurrency ${format(value)}';

  /// The "≈ <display currency>" reference line for a USD [value], converted at
  /// [fxRate] (ADR-03: convert at render time only). Returns null when the
  /// display currency is USD, so callers can omit the line entirely.
  static String? equivalentOf(double value, double fxRate, String displayCurrency) {
    if (displayCurrency == brokerCurrency) return null;
    return '≈ ${formatWithCurrency(value * fxRate, displayCurrency)}';
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
