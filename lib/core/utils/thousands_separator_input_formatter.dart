import 'package:flutter/services.dart';
import 'locale_number_input.dart';

/// Adds thousands separators in real-time as the user types a MONEY amount.
///
/// Locale-aware (B51): grouping and decimal characters follow the app's
/// presentation locale — "1,234.56" in en, "1.234,56" in es/pt — and the input
/// is tolerant of whichever decimal key the device keyboard offers. See
/// [LocaleNumberInput] for the full rationale.
///
/// Money is capped at 2 decimals. Raw numeric value via [parseFormatted].
///
/// Usage:
/// ```dart
/// TextFormField(
///   inputFormatters: [ThousandsSeparatorInputFormatter()],
///   keyboardType: const TextInputType.numberWithOptions(decimal: true),
/// )
/// ```
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static const int decimals = 2;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return LocaleNumberInput.format(
      oldValue,
      newValue,
      maxDecimals: decimals,
      grouping: true,
    );
  }

  /// Parses locale-formatted text to a [double]. Returns null if invalid.
  static double? parseFormatted(String text) => LocaleNumberInput.parse(text);
}
