import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formats an asset QUANTITY as the user types — not an amount of money.
///
/// Quantities and money are different things and had been sharing a formatter.
/// [ThousandsSeparatorInputFormatter] caps input at 2 decimals, which is right for
/// dollars and wrong for assets: it silently made 0.001 BTC untypeable, and its
/// `\d{0,2}` regex was — by accident — the ONLY thing standing between the app and
/// a zero-value order (B41). A quantity limit belongs here; an order minimum
/// belongs on the server.
///
/// Decimals allowed:
///  - crypto: 8 — matches the ×10^8 unit scale the backend stores, so anything
///    typeable is representable, and one satoshi is expressible.
///  - everything else: 6 — matches the fractional-share precision the sell screen's
///    percentage chips already produce (25% of a holding is rarely round).
///
/// Usage:
/// ```dart
/// TextFormField(
///   inputFormatters: [QuantityInputFormatter(isCrypto: asset.isCrypto)],
///   keyboardType: const TextInputType.numberWithOptions(decimal: true),
/// )
/// ```
class QuantityInputFormatter extends TextInputFormatter {
  QuantityInputFormatter({required this.isCrypto})
      : _allowed = RegExp(
          '^\\d*\\.?\\d{0,${isCrypto ? cryptoDecimals : defaultDecimals}}\$',
        );

  final bool isCrypto;

  /// Built once per formatter rather than per keystroke.
  final RegExp _allowed;

  /// Unit scale of the backend is 10^8 — a quantity finer than this cannot be
  /// stored, so there is no point letting it be typed.
  static const int cryptoDecimals = 8;
  static const int defaultDecimals = 6;

  int get maxDecimals => isCrypto ? cryptoDecimals : defaultDecimals;

  static final _numberFormat = NumberFormat('#,##0.########', 'en_US');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final raw = newValue.text.replaceAll(',', '');
    if (!_allowed.hasMatch(raw)) return oldValue;

    if (raw.contains('.')) {
      final parts = raw.split('.');
      final formattedInt =
          parts[0].isEmpty ? '' : _numberFormat.format(int.parse(parts[0]));
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

  /// Strips grouping separators and parses to [double]. Returns null if invalid.
  static double? parseFormatted(String text) =>
      double.tryParse(text.replaceAll(',', ''));
}
