import 'package:intl/intl.dart';

/// Centralized currency formatter for the entire Presentation Layer.
///
/// All UI surfaces must use this class to display monetary values,
/// ensuring consistent formatting (e.g., "$27,500.00") across the app.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _fmt =
      NumberFormat.simpleCurrency(decimalDigits: 2);

  /// Formats a [value] as "$1,234.56".
  static String format(double value) => _fmt.format(value);

  /// The raw [NumberFormat] instance for widgets that need to pass it around.
  static NumberFormat get instance => _fmt;
}
