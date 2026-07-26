import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:investy/core/utils/currency_formatter.dart';

void main() {
  final original = Intl.defaultLocale;
  tearDown(() => Intl.defaultLocale = original);

  group('locale-aware number grouping (B51)', () {
    test('en: USD with comma grouping and dot decimal', () {
      Intl.defaultLocale = 'en';
      expect(CurrencyFormatter.format(1234.56), r'$1,234.56');
    });

    test('es: USD with dot grouping and comma decimal', () {
      Intl.defaultLocale = 'es';
      expect(CurrencyFormatter.format(1234.56), r'$1.234,56');
    });

    test('es: EUR symbol with es number format', () {
      Intl.defaultLocale = 'es';
      expect(CurrencyFormatter.formatWithCurrency(1234.56, 'EUR'), '€1.234,56');
    });
  });

  group('sign handling', () {
    test('negative keeps the sign before the symbol', () {
      Intl.defaultLocale = 'en';
      expect(CurrencyFormatter.format(-5), r'-$5.00');
    });
  });

  group('symbolFor', () {
    test('known codes resolve to their symbol', () {
      expect(CurrencyFormatter.symbolFor('USD'), r'$');
      expect(CurrencyFormatter.symbolFor('EUR'), '€');
    });
  });
}
