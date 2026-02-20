import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_core/openbudget_core.dart';

void main() {
  group('currency_code_utils', () {
    test('parseCurrencyCode falls back to USD for unknown values', () {
      expect(parseCurrencyCode('ZZZ'), CurrencyCode.usd);
      expect(parseCurrencyCode('EUR'), CurrencyCode.eur);
    });

    test('aggregateCentsByCurrency sums values per currency', () {
      final rows = [
        ('USD', 100),
        ('EUR', 200),
        ('USD', -40),
      ];
      final totals = aggregateCentsByCurrency(
        rows,
        currencyCodeOf: (row) => row.$1,
        amountCentsOf: (row) => row.$2,
      );

      expect(totals[CurrencyCode.usd], 60);
      expect(totals[CurrencyCode.eur], 200);
    });

    test('formatCurrencyBreakdown prints code-prefixed totals', () {
      final label = formatCurrencyBreakdown({
        CurrencyCode.usd: 12345,
        CurrencyCode.eur: 6789,
      });

      expect(label, contains('USD'));
      expect(label, contains('EUR'));
      expect(label, contains(r'$123.45'));
      expect(label, contains('€67.89'));
    });
  });
}
