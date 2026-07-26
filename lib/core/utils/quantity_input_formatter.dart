import 'package:flutter/services.dart';
import 'locale_number_input.dart';

/// Formats an asset QUANTITY as the user types — not an amount of money.
///
/// Quantities and money are different things and had been sharing a formatter.
/// The money formatter caps input at 2 decimals, which is right for dollars and
/// wrong for assets: it silently made 0.001 BTC untypeable, and its `\d{0,2}`
/// regex was — by accident — the ONLY thing standing between the app and a
/// zero-value order (B41). A quantity limit belongs here; an order minimum
/// belongs on the server.
///
/// Locale-aware (B51): grouping and decimal characters follow the app's
/// presentation locale and input is tolerant of whichever decimal key the
/// device keyboard offers. See [LocaleNumberInput].
///
/// Decimals allowed:
///  - crypto: 8 — matches the ×10^8 unit scale the backend stores, so anything
///    typeable is representable, and one satoshi is expressible.
///  - everything else: 6 — matches the fractional-share precision the sell
///    screen's percentage chips already produce.
///
/// Usage:
/// ```dart
/// TextFormField(
///   inputFormatters: [QuantityInputFormatter(isCrypto: asset.isCrypto)],
///   keyboardType: const TextInputType.numberWithOptions(decimal: true),
/// )
/// ```
class QuantityInputFormatter extends TextInputFormatter {
  QuantityInputFormatter({required this.isCrypto});

  final bool isCrypto;

  /// Unit scale of the backend is 10^8 — a quantity finer than this cannot be
  /// stored, so there is no point letting it be typed.
  static const int cryptoDecimals = 8;
  static const int defaultDecimals = 6;

  int get maxDecimals => isCrypto ? cryptoDecimals : defaultDecimals;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return LocaleNumberInput.format(
      oldValue,
      newValue,
      maxDecimals: maxDecimals,
      grouping: true,
    );
  }

  /// Parses locale-formatted text to a [double]. Returns null if invalid.
  static double? parseFormatted(String text) => LocaleNumberInput.parse(text);
}
