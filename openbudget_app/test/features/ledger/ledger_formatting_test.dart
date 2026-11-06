import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/ledger/ledger_formatting.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

void main() {
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
          lineIndex: 1,
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
