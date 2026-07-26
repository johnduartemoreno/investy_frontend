import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:investy/core/utils/quantity_input_formatter.dart';

/// Simulates typing [next] into a field currently holding [current].
/// Returns the text the field ends up showing.
String type(QuantityInputFormatter f, String current, String next) {
  return f
      .formatEditUpdate(
        TextEditingValue(text: current),
        TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        ),
      )
      .text;
}

void main() {
  final crypto = QuantityInputFormatter(isCrypto: true);
  final stock = QuantityInputFormatter(isCrypto: false);

  group('QuantityInputFormatter — crypto', () {
    // The regression that started B41: the money formatter capped quantities at 2
    // decimals, which made the app's headline use case impossible to type.
    test('accepts 0.001 BTC', () {
      expect(type(crypto, '0.00', '0.001'), '0.001');
    });

    test('accepts all 8 decimals — one satoshi is expressible', () {
      expect(type(crypto, '0.0000000', '0.00000001'), '0.00000001');
    });

    test('rejects a 9th decimal — finer than the backend can store', () {
      // Below the ×10^8 unit scale, so it could not survive a round-trip anyway.
      expect(type(crypto, '0.00000001', '0.000000012'), '0.00000001');
    });

    test('groups thousands on the integer part', () {
      expect(type(crypto, '123456', '1234567'), '1,234,567');
    });
  });

  group('QuantityInputFormatter — non-crypto', () {
    test('accepts 6 decimals — matches the sell screen percentage chips', () {
      expect(type(stock, '0.12345', '0.123456'), '0.123456');
    });

    test('rejects a 7th decimal', () {
      expect(type(stock, '0.123456', '0.1234567'), '0.123456');
    });

    // The old money formatter would have stopped at 2 here.
    test('accepts a fractional share beyond 2 decimals', () {
      expect(type(stock, '1.23', '1.234'), '1.234');
    });
  });

  group('QuantityInputFormatter — shared behaviour', () {
    test('empty input passes through', () {
      expect(type(crypto, '1', ''), '');
    });

    test('rejects letters', () {
      expect(type(crypto, '1', '1a'), '1');
    });

    test('rejects a second decimal point', () {
      expect(type(crypto, '1.5', '1.5.'), '1.5');
    });

    test('allows a leading decimal point', () {
      expect(type(crypto, '', '.'), '.');
    });
  });

  group('parseFormatted', () {
    test('strips grouping separators', () {
      expect(QuantityInputFormatter.parseFormatted('1,234.5678'), 1234.5678);
    });

    test('parses full crypto precision', () {
      expect(QuantityInputFormatter.parseFormatted('0.00000001'), 0.00000001);
    });

    test('returns null on garbage rather than a silent zero', () {
      expect(QuantityInputFormatter.parseFormatted('abc'), isNull);
    });
  });

  group('decimal limits', () {
    test('crypto allows 8, everything else 6', () {
      expect(crypto.maxDecimals, 8);
      expect(stock.maxDecimals, 6);
    });
  });

  group('es locale — comma decimal (B51)', () {
    setUp(() => Intl.defaultLocale = 'es');
    tearDown(() => Intl.defaultLocale = null);

    test('0,001 BTC is typeable with a comma keyboard', () {
      var t = type(crypto, '0', '0,');
      t = type(crypto, t, '${t}0');
      t = type(crypto, t, '${t}0');
      t = type(crypto, t, '${t}1');
      expect(t, '0,001');
    });

    test('parseFormatted reads a comma-decimal quantity', () {
      expect(QuantityInputFormatter.parseFormatted('0,001'), 0.001);
    });
  });
}
