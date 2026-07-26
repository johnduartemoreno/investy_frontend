import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:investy/core/utils/locale_number_input.dart';

/// Simulates typing [next] into a field currently holding [current], for a
/// given [locale], [maxDecimals] and [grouping]. Returns the resulting text.
String typeIn(
  String current,
  String next, {
  required String locale,
  required int maxDecimals,
  bool grouping = true,
}) {
  return LocaleNumberInput.format(
    TextEditingValue(text: current),
    TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    ),
    locale: locale,
    maxDecimals: maxDecimals,
    grouping: grouping,
  ).text;
}

void main() {
  group('separatorsFor', () {
    test('en uses dot decimal / comma group', () {
      final s = LocaleNumberInput.separatorsFor('en');
      expect(s.decimal, '.');
      expect(s.group, ',');
    });

    test('es uses comma decimal / dot group', () {
      final s = LocaleNumberInput.separatorsFor('es');
      expect(s.decimal, ',');
      expect(s.group, '.');
    });

    test('pt uses comma decimal / dot group', () {
      final s = LocaleNumberInput.separatorsFor('pt');
      expect(s.decimal, ',');
      expect(s.group, '.');
    });
  });

  group('es-* comma decimal (the B51 regression)', () {
    // The exact bug: the comma the keyboard offered was deleted as a grouping
    // separator, so no decimal could be typed.
    test('typing a comma decimal is preserved, not deleted', () {
      expect(typeIn('232', '232,', locale: 'es', maxDecimals: 2), '232,');
    });

    test('builds a full comma-decimal money amount', () {
      var t = typeIn('232', '232,', locale: 'es', maxDecimals: 2);
      t = typeIn(t, '${t}1', locale: 'es', maxDecimals: 2);
      t = typeIn(t, '${t}0', locale: 'es', maxDecimals: 2);
      expect(t, '232,10');
    });

    test('groups thousands with a dot in es', () {
      expect(typeIn('1234', '12345', locale: 'es', maxDecimals: 2), '12.345');
    });

    test('a fractional crypto quantity 0,001 is typeable', () {
      var t = typeIn('0', '0,', locale: 'es', maxDecimals: 8);
      t = typeIn(t, '${t}0', locale: 'es', maxDecimals: 8);
      t = typeIn(t, '${t}0', locale: 'es', maxDecimals: 8);
      t = typeIn(t, '${t}1', locale: 'es', maxDecimals: 8);
      expect(t, '0,001');
    });
  });

  group('device/app mismatch tolerance', () {
    // App language es (comma decimal) but device keyboard offers a dot: the dot
    // the user types must still register as the decimal separator.
    test('a dot typed in an es field becomes the locale comma decimal', () {
      expect(typeIn('232', '232.', locale: 'es', maxDecimals: 2), '232,');
    });

    // App language en (dot decimal) but device keyboard offers a comma.
    test('a comma typed in an en field becomes the locale dot decimal', () {
      expect(typeIn('232', '232,', locale: 'en', maxDecimals: 2), '232.');
    });
  });

  group('en dot decimal', () {
    test('builds a dot-decimal money amount with comma grouping', () {
      var t = typeIn('1234', '12345', locale: 'en', maxDecimals: 2);
      expect(t, '12,345');
      t = typeIn(t, '$t.', locale: 'en', maxDecimals: 2);
      t = typeIn(t, '${t}5', locale: 'en', maxDecimals: 2);
      expect(t, '12,345.5');
    });
  });

  group('decimal cap is enforced by rejection, not truncation', () {
    test('money rejects a 3rd decimal', () {
      expect(typeIn('1.23', '1.234', locale: 'en', maxDecimals: 2), '1.23');
    });

    test('crypto rejects a 9th decimal', () {
      expect(
        typeIn('0.00000001', '0.000000012', locale: 'en', maxDecimals: 8),
        '0.00000001',
      );
    });
  });

  group('shared behaviour', () {
    test('rejects a second decimal point', () {
      expect(typeIn('1,5', '1,5,', locale: 'es', maxDecimals: 8), '1,5');
    });

    test('rejects letters', () {
      expect(typeIn('1', '1a', locale: 'en', maxDecimals: 2), '1');
    });

    test('empty passes through', () {
      expect(typeIn('1', '', locale: 'en', maxDecimals: 2), '');
    });

    test('strips leading zeros but keeps a single one before a decimal', () {
      expect(typeIn('0', '05', locale: 'en', maxDecimals: 2), '5');
      expect(typeIn('0', '0.', locale: 'en', maxDecimals: 2), '0.');
    });
  });

  group('parse — locale-aware, tolerant', () {
    test('es: 1.234,56 → 1234.56', () {
      expect(LocaleNumberInput.parse('1.234,56', locale: 'es'), 1234.56);
    });

    test('en: 1,234.56 → 1234.56', () {
      expect(LocaleNumberInput.parse('1,234.56', locale: 'en'), 1234.56);
    });

    test('es: 232,10 → 232.10', () {
      expect(LocaleNumberInput.parse('232,10', locale: 'es'), 232.10);
    });

    test('es: 0,001 → 0.001', () {
      expect(LocaleNumberInput.parse('0,001', locale: 'es'), 0.001);
    });

    test('returns null on garbage rather than a silent zero', () {
      expect(LocaleNumberInput.parse('abc', locale: 'en'), isNull);
      expect(LocaleNumberInput.parse('', locale: 'en'), isNull);
    });
  });
}
