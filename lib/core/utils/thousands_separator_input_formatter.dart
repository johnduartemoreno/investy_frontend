import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Adds thousands separators in real-time as the user types.
///
/// As the user types "258855" the field displays "258,855".
/// Supports up to 2 decimal places.
/// Raw numeric value can be extracted via [parseFormatted].
///
/// Usage:
/// ```dart
/// TextFormField(
///   inputFormatters: [ThousandsSeparatorInputFormatter()],
///   keyboardType: const TextInputType.numberWithOptions(decimal: true),
/// )
/// ```
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static final _numberFormat = NumberFormat('#,##0.##', 'en_US');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final raw = newValue.text.replaceAll(',', '');
    if (!RegExp(r'^\d*\.?\d{0,2}$').hasMatch(raw)) return oldValue;

    if (raw.contains('.')) {
      final parts = raw.split('.');
      final formattedInt = parts[0].isEmpty
          ? ''
          : _numberFormat.format(int.parse(parts[0]));
      final formatted = '$formattedInt.${parts[1]}';
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    final number = int.tryParse(raw);
    if (number == null) return oldValue;
    final formatted = _numberFormat.format(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Strips commas and parses to [double]. Returns null if invalid.
  static double? parseFormatted(String text) {
    final raw = text.replaceAll(',', '');
    return double.tryParse(raw);
  }
}
