import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_core/openbudget_core.dart';

void main() {
  group('currency_code_utils', () {
    test('aggregateCentsByCurrency sums values per currency', () {
      final rows = [('USD', 100), ('EUR', 200), ('USD', -40)];
      final totals = aggregateCentsByCurrency(
        rows,
        currencyCodeOf: (row) => row.$1,
        amountCentsOf: (row) => row.$2,
      );

      expect(totals, {'USD': 60, 'EUR': 200});
    });

    test('aggregateCentsByCurrency keeps unknown codes separate from USD', () {
      final rows = [('USD', 100), ('XYZ', 250), ('xyz', 50), (' usd ', 25)];
      final totals = aggregateCentsByCurrency(
        rows,
        currencyCodeOf: (row) => row.$1,
        amountCentsOf: (row) => row.$2,
      );

      expect(totals, {'USD': 125, 'XYZ': 300});
      expect(totals[CurrencyCode.usd.code], isNot(400));
    });

    test('formatCurrencyBreakdown prints code-prefixed totals', () {
      final label = formatCurrencyBreakdown({'USD': 12345, 'EUR': 6789});

      expect(label, r'EUR €67.89 · USD $123.45');
    });

    test('formatCurrencyBreakdown prints unknown codes as plain amounts', () {
      final label = formatCurrencyBreakdown({'USD': 12345, 'XYZ': 1250});

      expect(label, r'USD $123.45 · XYZ 12.50');
      expect(label, isNot(contains(r'XYZ $')));
    });
  });

  group('formatCentsForCode', () {
    test('uses the known currency symbol and precision', () {
      expect(formatCentsForCode(1250, 'USD'), r'$12.50');
      expect(formatCentsForCode(12345, 'JPY'), '¥12,345');
      expect(formatCentsForCode(1250, ' eur '), '€12.50');
    });

    test('falls back to the raw code and a plain two-decimal amount', () {
      expect(formatCentsForCode(1250, 'XYZ'), 'XYZ 12.50');
      expect(formatCentsForCode(-125000, 'xyz'), 'XYZ -1,250.00');
      expect(formatCentsForCode(0, ''), '0.00');
    });
  });
}
