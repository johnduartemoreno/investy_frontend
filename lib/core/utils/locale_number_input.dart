import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Locale-aware, tolerant numeric input engine shared by the money and quantity
/// input formatters (B51).
///
/// ## Why this exists
/// The old formatters parsed and formatted statically in `en_US`: they stripped
/// every `,` as a thousands separator and hardcoded `.` as the only decimal
/// separator. On a device whose locale uses a comma decimal (es-*, pt-*), the
/// decimal key the keyboard offers is `,` — which the formatter deleted as if it
/// were a grouping separator. Result: no decimal could be typed at all, so a
/// fractional order (`0,001`, `232,10`) was impossible.
///
/// ## Two ideas
/// 1. **Locale-aware display**: grouping and decimal characters come from the
///    app's presentation locale (`Intl.getCurrentLocale()`, kept in sync with the
///    in-app language selector). es/pt → `1.234,56`; en → `1,234.56`.
/// 2. **Tolerant input**: the user might have their phone region set to one locale
///    (which drives the keyboard's decimal key) while the app language is another.
///    So we never trust the *character* the keyboard produced. Instead we use the
///    fact that **the user never types a grouping separator — the formatter inserts
///    those**. Therefore *any* separator the user types (`.` or `,`) is decimal
///    intent, and every other separator already in the field is grouping.
class LocaleNumberInput {
  LocaleNumberInput._();

  /// Resolves the grouping and decimal separators for [locale] (defaults to the
  /// app's current Intl locale).
  static ({String group, String decimal}) separatorsFor([String? locale]) {
    final symbols =
        NumberFormat.decimalPattern(locale ?? Intl.getCurrentLocale()).symbols;
    return (group: symbols.GROUP_SEP, decimal: symbols.DECIMAL_SEP);
  }

  /// Core `TextInputFormatter` logic shared by both formatters.
  ///
  /// [maxDecimals] caps the fractional part (rejects extra digits). [grouping]
  /// toggles thousands separators on the integer part. Returns the value the
  /// field should display, or [oldValue] when the edit is rejected.
  static TextEditingValue format(
    TextEditingValue oldValue,
    TextEditingValue newValue, {
    required int maxDecimals,
    required bool grouping,
    String? locale,
  }) {
    final newText = newValue.text;
    if (newText.isEmpty) return newValue;

    // Only digits and the two possible separator characters are ever valid.
    if (RegExp(r'[^0-9.,]').hasMatch(newText)) return oldValue;

    final sep = separatorsFor(locale);
    final g = sep.group;
    final d = sep.decimal;

    // Reduce the edited text to a canonical form: digits with at most one '.'
    // decimal marker. Grouping separators are removed.
    final String canonical;
    final oldText = oldValue.text;
    final isSingleInsert = newText.length == oldText.length + 1;

    if (isSingleInsert && _isSeparator(newText[_insertedCharIndex(oldText, newText)])) {
      // The user typed a separator → decimal intent, regardless of which char.
      // Reject a second decimal point if the field already has one.
      if (oldText.contains(d)) return oldValue;
      final i = _insertedCharIndex(oldText, newText);
      // Everything before the typed char is the integer part, everything after is
      // the fractional part; strip any grouping separators from both sides.
      final before = _digitsOnly(newText.substring(0, i));
      final after = _digitsOnly(newText.substring(i + 1));
      canonical = '$before.$after';
    } else {
      // Digit insert, paste, multi-char edit, or deletion → interpret the text
      // canonically by locale (grouping = g, decimal = d).
      canonical = newText.replaceAll(g, '').replaceAll(d, '.');
    }

    // Validate the canonical form: digits with at most one decimal point.
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(canonical)) return oldValue;

    final hasDecimal = canonical.contains('.');
    final splitAt = canonical.indexOf('.');
    final rawInt = hasDecimal ? canonical.substring(0, splitAt) : canonical;
    final decDigits = hasDecimal ? canonical.substring(splitAt + 1) : '';

    // Enforce the decimal cap by rejecting the edit (never silently truncate).
    if (decDigits.length > maxDecimals) return oldValue;

    // Strip leading zeros on the integer part, keeping a single leading zero
    // (so "0.5" survives but "05" becomes "5").
    final intDigits = rawInt.replaceFirst(RegExp(r'^0+(?=\d)'), '');

    final groupedInt = grouping ? _group(intDigits, g) : intDigits;
    final display = hasDecimal ? '$groupedInt$d$decDigits' : groupedInt;

    return TextEditingValue(
      text: display,
      selection: TextSelection.collapsed(offset: display.length),
    );
  }

  /// Parses locale-formatted [text] into a canonical [double].
  ///
  /// Locale-based: strips the locale grouping separator and maps the locale
  /// decimal separator to `.`. Because the formatter only ever emits canonical
  /// locale text (grouping = g, decimal = d), this is unambiguous. Returns null
  /// on invalid input rather than defaulting to a silent zero.
  static double? parse(String text, {String? locale}) {
    if (text.isEmpty) return null;
    final sep = separatorsFor(locale);
    final canonical =
        text.replaceAll(sep.group, '').replaceAll(sep.decimal, '.');
    return double.tryParse(canonical);
  }

  /// Formats a numeric [value] into locale input text (grouping + locale decimal
  /// separator, no trailing zeros), for **pre-filling** a field that an input
  /// formatter will then maintain. Setting `controller.text` with a dot-decimal
  /// string (e.g. `toStringAsFixed(2)`) breaks in comma-decimal locales, where a
  /// re-parse would read the dot as a thousands separator.
  static String forField(double value,
      {required int maxDecimals, String? locale}) {
    final pattern = '#,##0.${'#' * maxDecimals}';
    return NumberFormat(pattern, locale ?? Intl.getCurrentLocale())
        .format(value);
  }

  static bool _isSeparator(String ch) => ch == '.' || ch == ',';

  static String _digitsOnly(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

  /// Index in [newText] of the single character inserted vs [oldText].
  /// Assumes `newText.length == oldText.length + 1`.
  static int _insertedCharIndex(String oldText, String newText) {
    var i = 0;
    while (i < oldText.length && oldText[i] == newText[i]) {
      i++;
    }
    return i;
  }

  /// Inserts [groupChar] every three digits from the right. Works on the digit
  /// string directly to avoid `int` overflow on large amounts.
  static String _group(String intDigits, String groupChar) {
    if (intDigits.length <= 3) return intDigits;
    final buffer = StringBuffer();
    for (var i = 0; i < intDigits.length; i++) {
      if (i > 0 && (intDigits.length - i) % 3 == 0) buffer.write(groupChar);
      buffer.write(intDigits[i]);
    }
    return buffer.toString();
  }
}
