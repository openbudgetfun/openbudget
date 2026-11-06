import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/ledger/ledger_formatting.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

void main() {
  group('parseAmountToMinor', () {
    test('parses whole and fractional figures', () {
      expect(parseAmountToMinor('12.34', 2), 1234);
      expect(parseAmountToMinor('10', 2), 1000);
      expect(parseAmountToMinor('0.1', 2), 10);
      expect(parseAmountToMinor('.5', 2), 50);
      expect(parseAmountToMinor('12.', 2), 1200);
      expect(parseAmountToMinor('1,234.56', 2), 123456);
    });

    test('honours the currency exponent', () {
      expect(parseAmountToMinor('7', 0), 7);
      expect(parseAmountToMinor('1234', 0), 1234);
      expect(parseAmountToMinor('7.5', 0), isNull);
    });

    test('rejects anything that is not a clean non-negative amount', () {
      expect(parseAmountToMinor('', 2), isNull);
      expect(parseAmountToMinor('   ', 2), isNull);
      expect(parseAmountToMinor('-1', 2), isNull);
      expect(parseAmountToMinor('abc', 2), isNull);
      expect(parseAmountToMinor('12.3.4', 2), isNull);
      expect(parseAmountToMinor('12.345', 2), isNull);
    });
  });

  group('minorToPlainString', () {
    test('renders minor units as a plain figure', () {
      expect(minorToPlainString(1234, 2), '12.34');
      expect(minorToPlainString(5, 2), '0.05');
      expect(minorToPlainString(-5, 2), '-0.05');
      expect(minorToPlainString(0, 2), '0.00');
      expect(minorToPlainString(123400, 2), '1234.00');
    });

    test('renders zero-decimal currencies without a fraction', () {
      expect(minorToPlainString(7, 0), '7');
      expect(minorToPlainString(-9, 0), '-9');
    });
  });

  group('ledgerErrorMessage', () {
    test('uses the server validation text when present', () {
      final error = ValidationException(message: 'Journal is locked.');
      expect(ledgerErrorMessage(error, 'fallback'), 'Journal is locked.');
    });

    test('falls back when the server sends no message', () {
      final error = ValidationException(message: '');
      expect(ledgerErrorMessage(error, 'fallback'), 'fallback');
    });

    test('falls back for other errors', () {
      expect(ledgerErrorMessage(Exception('boom'), 'fallback'), 'fallback');
    });
  });

  group('ledgerIssueMessage', () {
    test('localizes the line-count rule', () {
      final message = ledgerIssueMessage(
        _l10n,
        const LedgerValidationIssue('atLeastTwoLines', 'A journal needs…'),
      );
      expect(message, 'A journal needs at least two lines.');
    });

    test('localizes the one-sided rule with the line number', () {
      final message = ledgerIssueMessage(
        _l10n,
        const LedgerValidationIssue(
          'lineOneSideRequired',
          'Line 2 (1000) must carry a positive debit or a positive credit, '
              'not both and not neither.',
        ),
      );
      expect(message, 'Line 2 needs a positive amount on one side.');
    });

    test('localizes the functional balance rule', () {
      final message = ledgerIssueMessage(
        _l10n,
        const LedgerValidationIssue('unbalancedFunctional', 'does not balance'),
      );
      expect(message, 'Debits and credits do not match yet.');
    });

    test('falls back to the core text for unexpected rules', () {
      final message = ledgerIssueMessage(
        _l10n,
        const LedgerValidationIssue('invalidExchangeRate', 'core text'),
      );
      expect(message, 'core text');
    });
  });

  group('ledgerCalendarDate', () {
    test('strips the time of day', () {
      final date = ledgerCalendarDate(DateTime(2026, 11, 5, 14, 30));
      expect(date, DateTime(2026, 11, 5));
    });
  });
}

AppLocalizations get _l10n => lookupAppLocalizations(const Locale('en'));
