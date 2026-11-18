import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

void main() {
  group('ExactDecimal', () {
    test('parses plain decimal strings exactly', () {
      final rate = ExactDecimal.tryParse('1.234567')!;
      expect(rate.numerator, BigInt.from(1234567));
      expect(rate.denominator, BigInt.from(1000000));
    });

    test('parses whole-number strings', () {
      final rate = ExactDecimal.tryParse('2')!;
      expect(rate.isOne, isFalse);
      expect(rate.toString(), '2');
    });

    test('round-trips through toString', () {
      expect(ExactDecimal.tryParse('0.5')!.toString(), '0.5');
      expect(ExactDecimal.tryParse('1.234567')!.toString(), '1.234567');
      expect(ExactDecimal.tryParse('10')!.toString(), '10');
    });

    test('recognises one exactly', () {
      expect(ExactDecimal.tryParse('1')!.isOne, isTrue);
      expect(ExactDecimal.tryParse('1.0')!.isOne, isTrue);
      expect(ExactDecimal.tryParse('1.000')!.isOne, isTrue);
    });

    test('rejects signs, exponent notation and separators', () {
      for (final raw in [
        '-1',
        '+1',
        '1e3',
        '1,234.5',
        '',
        ' ',
        '0',
        '0.00',
        'one',
      ]) {
        expect(ExactDecimal.tryParse(raw), isNull, reason: '"$raw"');
      }
    });
  });

  group('exponentForCurrency', () {
    test('returns the per-currency exponent', () {
      expect(exponentForCurrency('JPY'), 0);
      expect(exponentForCurrency('GBP'), 2);
      expect(exponentForCurrency('BTC'), 8);
    });

    test('is case-insensitive and null for unknown codes', () {
      expect(exponentForCurrency('gbp'), 2);
      expect(exponentForCurrency('XYZ'), isNull);
    });
  });

  group('convertMinorUnits', () {
    test('rounds negative amounts half up on their absolute value', () {
      for (final exponent in [0, 2, 3, 8]) {
        for (final (amount, rate, expected) in [
          (-5, '0.5', -3),
          (-3333, '0.8', -2666),
          (-10, '1', -10),
        ]) {
          expect(
            convertMinorUnits(
              amountMinor: amount,
              exchangeRate: ExactDecimal.tryParse(rate)!,
              transactionExponent: exponent,
              functionalExponent: exponent,
            ),
            expected,
          );
        }
      }
    });

    int convert({
      required int amountMinor,
      required String rate,
      required int fromExponent,
      required int toExponent,
    }) => convertMinorUnits(
      amountMinor: amountMinor,
      exchangeRate: ExactDecimal.tryParse(rate)!,
      transactionExponent: fromExponent,
      functionalExponent: toExponent,
    );

    test('converts at one exactly', () {
      expect(
        convert(
          amountMinor: 12345,
          rate: '1',
          fromExponent: 2,
          toExponent: 2,
        ),
        12345,
      );
    });

    test('handles differing exponents (T4.2, EUR VAT into GBP)', () {
      // EUR 200.00 VAT at 0.862069 GBP per EUR is 172.41 GBP:
      // 20000 * 0.862069 = 17241.38 minor, rounds half up.
      expect(
        convert(
          amountMinor: 20000,
          rate: '0.862069',
          fromExponent: 2,
          toExponent: 2,
        ),
        17241,
      );
    });

    test('rounds half up on zero-exponent functional currency', () {
      // USD 100.00 (10000 minor) at 1.5 JPY per USD is 150 JPY exactly.
      expect(
        convert(
          amountMinor: 10000,
          rate: '1.5',
          fromExponent: 2,
          toExponent: 0,
        ),
        150,
      );
      // USD 0.67 (67 minor) at 1.5 JPY per USD is 1.005 JPY, rounds to 1.
      expect(
        convert(amountMinor: 67, rate: '1.5', fromExponent: 2, toExponent: 0),
        1,
      );
      // USD 0.33 (33 minor) at 1.5 JPY per USD is 0.495 JPY, rounds to 0.
      expect(
        convert(amountMinor: 33, rate: '1.5', fromExponent: 2, toExponent: 0),
        0,
      );
    });

    test('reproduces the T6.1 day-1 booking exactly', () {
      // USD 1000.00 (100000 minor) at 0.8 GBP per USD = 800.00 GBP.
      expect(
        convert(
          amountMinor: 100000,
          rate: '0.8',
          fromExponent: 2,
          toExponent: 2,
        ),
        80000,
      );
    });

    test('reproduces the T6.4 rounding case', () {
      // USD 33.33 (3333 minor) at 0.8 GBP per USD is 26.664 GBP, which
      // rounds half up to 26.66.
      expect(
        convert(amountMinor: 3333, rate: '0.8', fromExponent: 2, toExponent: 2),
        2666,
      );
    });
  });
}
