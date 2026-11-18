import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/src/features/budget/widgets/budget_amount_keypad.dart';

void main() {
  group('parseBudgetAmountInputToMinor', () {
    test('converts keypad digits into exact minor units', () {
      expect(
        parseBudgetAmountInputToMinor(input: '1234', currencyCode: 'USD'),
        123400,
      );
      expect(
        parseBudgetAmountInputToMinor(input: '1200', currencyCode: 'JPY'),
        1200,
      );
      expect(
        parseBudgetAmountInputToMinor(input: '-1234', currencyCode: 'USD'),
        -123400,
      );
      expect(
        parseBudgetAmountInputToMinor(input: '', currencyCode: 'USD'),
        isNull,
      );
      expect(
        parseBudgetAmountInputToMinor(input: '-', currencyCode: 'USD'),
        isNull,
      );
    });

    test('refuses anything the keypad cannot type', () {
      // The keypad only appends digits and a single leading minus, so a dotted
      // amount is refused rather than reinterpreted.
      expect(
        parseBudgetAmountInputToMinor(input: '12.345', currencyCode: 'USD'),
        isNull,
      );
      expect(
        parseBudgetAmountInputToMinor(input: 'abc', currencyCode: 'USD'),
        isNull,
      );
    });
  });

  group('formatBudgetAmountInputForField', () {
    test('renders the exact amount without floating point rounding', () {
      expect(
        formatBudgetAmountInputForField(input: '1234', currencyCode: 'USD'),
        '1234.00',
      );
      expect(
        formatBudgetAmountInputForField(
          input: '123456789',
          currencyCode: 'USD',
        ),
        '123456789.00',
      );
      expect(
        formatBudgetAmountInputForField(input: '1234', currencyCode: 'JPY'),
        '1234',
      );
      expect(
        formatBudgetAmountInputForField(input: '-1234', currencyCode: 'USD'),
        '-1234.00',
      );
    });

    test('stays empty for empty or unparseable input', () {
      expect(
        formatBudgetAmountInputForField(input: '', currencyCode: 'USD'),
        '',
      );
      expect(
        formatBudgetAmountInputForField(input: '12.345', currencyCode: 'USD'),
        '',
      );
    });
  });
}
