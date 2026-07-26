import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:investy/core/utils/thousands_separator_input_formatter.dart';

String type(ThousandsSeparatorInputFormatter f, String current, String next) {
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
  final f = ThousandsSeparatorInputFormatter();
  final original = Intl.defaultLocale;
  tearDown(() => Intl.defaultLocale = original);

  group('en_US', () {
    setUp(() => Intl.defaultLocale = 'en');

    test('groups thousands with a comma', () {
      expect(type(f, '1234', '12345'), '12,345');
    });

    test('accepts up to 2 decimals', () {
      expect(type(f, '12.3', '12.34'), '12.34');
    });

    test('rejects a 3rd decimal', () {
      expect(type(f, '12.34', '12.345'), '12.34');
    });

    test('parseFormatted strips grouping', () {
      expect(ThousandsSeparatorInputFormatter.parseFormatted('1,234.56'), 1234.56);
    });
  });

  group('es (comma decimal, dot group)', () {
    setUp(() => Intl.defaultLocale = 'es');

    test('a comma decimal survives — the B51 fix', () {
      expect(type(f, '232', '232,'), '232,');
    });

    test('groups thousands with a dot', () {
      expect(type(f, '1234', '12345'), '12.345');
    });

    test('parseFormatted reads a comma-decimal amount', () {
      expect(
          ThousandsSeparatorInputFormatter.parseFormatted('1.234,56'), 1234.56);
    });
  });
}
