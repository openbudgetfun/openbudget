import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/src/utils/money_input.dart';

void main() {
  group('parseMoneyInput', () {
    test('parses typed amounts into exact minor units', () {
      expect(parseMoneyInput('12.34', decimals: 2), 1234);
      expect(parseMoneyInput('1,200.05', decimals: 2), 120005);
      expect(parseMoneyInput(' 7 ', decimals: 2), 700);
      expect(parseMoneyInput('0.00000042', decimals: 8), 42);
      expect(parseMoneyInput('12', decimals: 0), 12);
    });

    test('refuses amounts with more decimals than the currency', () {
      expect(parseMoneyInput('12.345', decimals: 2), isNull);
      expect(parseMoneyInput('12.34', decimals: 0), isNull);
    });

    test('refuses empty and malformed input', () {
      expect(parseMoneyInput('', decimals: 2), isNull);
      expect(parseMoneyInput('abc', decimals: 2), isNull);
      expect(parseMoneyInput('12.3.4', decimals: 2), isNull);
      expect(parseMoneyInput('.', decimals: 2), isNull);
    });

    test('refuses negative amounts unless the field allows them', () {
      expect(parseMoneyInput('-12.34', decimals: 2), isNull);
      expect(
        parseMoneyInput('-12.34', decimals: 2, allowNegative: true),
        -1234,
      );
      expect(parseMoneyInput('-', decimals: 2, allowNegative: true), isNull);
      expect(
        parseMoneyInput('--12.34', decimals: 2, allowNegative: true),
        isNull,
      );
    });
  });

  group('moneyInputError', () {
    const message = 'Enter a valid amount';

    test('stays quiet for empty and exact amounts', () {
      expect(moneyInputError('', decimals: 2, message: message), isNull);
      expect(moneyInputError('  ', decimals: 2, message: message), isNull);
      expect(moneyInputError('12.34', decimals: 2, message: message), isNull);
    });

    test('reports over-precise amounts', () {
      expect(
        moneyInputError('12.345', decimals: 2, message: message),
        message,
      );
    });

    test('reports negatives only where they are refused', () {
      expect(
        moneyInputError('-12.34', decimals: 2, message: message),
        message,
      );
      expect(
        moneyInputError(
          '-12.34',
          decimals: 2,
          message: message,
          allowNegative: true,
        ),
        isNull,
      );
    });
  });
}
