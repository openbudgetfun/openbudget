import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

JournalLineDraft _gbpLine({
  required String accountCode,
  required bool isDebit,
  required int amountMinor,
  String? description,
}) => JournalLineDraft(
  accountCode: accountCode,
  description: description,
  debitMinor: isDebit ? amountMinor : 0,
  creditMinor: isDebit ? 0 : amountMinor,
  currencyCode: 'GBP',
  functionalDebitMinor: isDebit ? amountMinor : 0,
  functionalCreditMinor: isDebit ? 0 : amountMinor,
  exchangeRate: '1',
  rateDate: DateTime(2026, 11, 5),
  rateSource: 'functional',
);

JournalLineDraft _fxLine({
  required String accountCode,
  required bool isDebit,
  required int amountMinor,
  required int functionalAmountMinor,
  required String exchangeRate,
  String currencyCode = 'USD',
}) => JournalLineDraft(
  accountCode: accountCode,
  debitMinor: isDebit ? amountMinor : 0,
  creditMinor: isDebit ? 0 : amountMinor,
  currencyCode: currencyCode,
  functionalDebitMinor: isDebit ? functionalAmountMinor : 0,
  functionalCreditMinor: isDebit ? 0 : functionalAmountMinor,
  exchangeRate: exchangeRate,
  rateDate: DateTime(2026, 11, 5),
  rateSource: 'manual',
);

List<String> codes(JournalDraft draft) =>
    draft.validate().map((issue) => issue.code).toList();

void main() {
  group('JournalDraft.validate (T1 posting invariants)', () {
    test('accepts a balanced two-line journal', () {
      final draft = JournalDraft(
        functionalCurrency: 'GBP',
        lines: [
          _gbpLine(
            accountCode: '5600',
            isDebit: true,
            amountMinor: 1250,
            description: 'Bank fee',
          ),
          _gbpLine(accountCode: '1000', isDebit: false, amountMinor: 1250),
        ],
      );

      expect(draft.validate(), isEmpty);
    });

    test('rejects a journal with one line', () {
      final draft = JournalDraft(
        functionalCurrency: 'GBP',
        lines: [
          _gbpLine(accountCode: '1000', isDebit: true, amountMinor: 10000),
        ],
      );

      expect(codes(draft), contains('atLeastTwoLines'));
    });

    test('rejects debits that do not equal credits (T1)', () {
      final draft = JournalDraft(
        functionalCurrency: 'GBP',
        lines: [
          _gbpLine(accountCode: '1000', isDebit: true, amountMinor: 10000),
          _gbpLine(accountCode: '4000', isDebit: false, amountMinor: 9999),
        ],
      );

      expect(codes(draft), contains('unbalancedFunctional'));
    });

    test('rejects a line with both debit and credit (T1)', () {
      final line = JournalLineDraft(
        accountCode: '1000',
        debitMinor: 100,
        creditMinor: 100,
        currencyCode: 'GBP',
        functionalDebitMinor: 100,
        functionalCreditMinor: 0,
        exchangeRate: '1',
        rateDate: DateTime(2026, 11, 5),
        rateSource: 'manual',
      );
      final draft = JournalDraft(
        functionalCurrency: 'GBP',
        lines: [
          line,
          _gbpLine(accountCode: '4000', isDebit: false, amountMinor: 100),
        ],
      );

      expect(codes(draft), contains('lineOneSideRequired'));
    });

    test('rejects a zero line (T1)', () {
      final draft = JournalDraft(
        functionalCurrency: 'GBP',
        lines: [
          _gbpLine(accountCode: '1000', isDebit: true, amountMinor: 0),
          _gbpLine(accountCode: '4000', isDebit: false, amountMinor: 100),
        ],
      );

      expect(codes(draft), contains('lineOneSideRequired'));
    });

    test('rejects negative amounts', () {
      final draft = JournalDraft(
        functionalCurrency: 'GBP',
        lines: [
          _gbpLine(accountCode: '1000', isDebit: true, amountMinor: 100),
          _gbpLine(accountCode: '4000', isDebit: false, amountMinor: -100),
        ],
      );

      expect(codes(draft), contains('lineOneSideRequired'));
    });

    test('rejects sides that point in different directions', () {
      final draft = JournalDraft(
        functionalCurrency: 'GBP',
        lines: [
          JournalLineDraft(
            accountCode: '1000',
            debitMinor: 100,
            creditMinor: 0,
            currencyCode: 'USD',
            functionalDebitMinor: 0,
            functionalCreditMinor: 80,
            exchangeRate: '0.8',
            rateDate: DateTime(2026, 11, 5),
            rateSource: 'manual',
          ),
          _gbpLine(accountCode: '4000', isDebit: false, amountMinor: 80),
        ],
      );

      expect(codes(draft), contains('lineSideMismatch'));
    });

    test('rejects a malformed exchange rate', () {
      final draft = JournalDraft(
        functionalCurrency: 'GBP',
        lines: [
          _fxLine(
            accountCode: '1000',
            isDebit: true,
            amountMinor: 10000,
            functionalAmountMinor: 8000,
            exchangeRate: '1.25 USD',
          ),
          _gbpLine(accountCode: '4000', isDebit: false, amountMinor: 8000),
        ],
      );

      expect(codes(draft), contains('invalidExchangeRate'));
    });

    test('rejects unsupported transaction currencies', () {
      final draft = JournalDraft(
        functionalCurrency: 'GBP',
        lines: [
          _fxLine(
            accountCode: '1000',
            isDebit: true,
            amountMinor: 10000,
            functionalAmountMinor: 8000,
            currencyCode: 'XXX',
            exchangeRate: '0.8',
          ),
          _gbpLine(accountCode: '4000', isDebit: false, amountMinor: 8000),
        ],
      );

      expect(codes(draft), contains('unsupportedCurrency'));
    });

    test('rejects an unsupported functional currency', () {
      final draft = JournalDraft(
        functionalCurrency: 'XYZ',
        lines: [
          _gbpLine(accountCode: '1000', isDebit: true, amountMinor: 100),
          _gbpLine(accountCode: '4000', isDebit: false, amountMinor: 100),
        ],
      );

      expect(codes(draft), ['unsupportedFunctionalCurrency']);
    });
  });

  group('JournalDraft.validate (T1 multi-currency imbalance)', () {
    test(
      'rejects USD lines balanced in GBP but not in USD',
      () {
        // USD 100.00 Dr at 0.80 = GBP 80.00; USD 99.00 Cr at 0.808080...
        // is also GBP 80.00, so the journal balances in the functional
        // currency while the USD group does not. Must be rejected.
        final draft = JournalDraft(
          functionalCurrency: 'GBP',
          lines: [
            _fxLine(
              accountCode: '1000',
              isDebit: true,
              amountMinor: 10000,
              functionalAmountMinor: 8000,
              exchangeRate: '0.8',
            ),
            _fxLine(
              accountCode: '4000',
              isDebit: false,
              amountMinor: 9900,
              functionalAmountMinor: 8000,
              exchangeRate: '0.808081',
            ),
          ],
        );

        expect(codes(draft), contains('unbalancedTransactionCurrency'));
      },
    );
  });

  group('JournalDraft.validate (T6 realised FX settlement)', () {
    test('accepts the T6.1 realised-loss journal', () {
      // Day 20: USD 1000.00 received at 0.769231 GBP per USD = 769.23;
      // AR releases at the booked rate 0.8 = 800.00; realised loss 30.77.
      final draft = JournalDraft(
        functionalCurrency: 'GBP',
        lines: [
          _fxLine(
            accountCode: '1000',
            isDebit: true,
            amountMinor: 100000,
            functionalAmountMinor: 76923,
            exchangeRate: '0.769231',
          ),
          _gbpLine(accountCode: '5800', isDebit: true, amountMinor: 3077),
          _fxLine(
            accountCode: '1100',
            isDebit: false,
            amountMinor: 100000,
            functionalAmountMinor: 80000,
            exchangeRate: '0.8',
          ),
        ],
      );

      expect(draft.validate(), isEmpty);
    });

    test('rejects a functional amount that contradicts the stated rate', () {
      final draft = JournalDraft(
        functionalCurrency: 'GBP',
        lines: [
          _fxLine(
            accountCode: '1000',
            isDebit: true,
            amountMinor: 100000,
            functionalAmountMinor: 76923,
            exchangeRate: '0.8',
          ),
          _gbpLine(accountCode: '5800', isDebit: true, amountMinor: 3077),
          _fxLine(
            accountCode: '1100',
            isDebit: false,
            amountMinor: 100000,
            functionalAmountMinor: 80000,
            exchangeRate: '0.8',
          ),
        ],
      );

      expect(codes(draft), contains('functionalMismatch'));
    });

    test('accepts the T6.4 three-line rounding split', () {
      // Three USD 33.33 lines at 0.8 GBP per USD land on 26.66 each
      // (26.664 rounds to 26.66), totalling GBP 79.98 against USD 99.99.
      final draft = JournalDraft(
        functionalCurrency: 'GBP',
        lines: [
          for (final accountCode in ['5000', '5000', '5000'])
            _fxLine(
              accountCode: accountCode,
              isDebit: true,
              amountMinor: 3333,
              functionalAmountMinor: 2666,
              exchangeRate: '0.8',
            ),
          _gbpLine(accountCode: '1000', isDebit: false, amountMinor: 7998),
        ],
      );

      expect(draft.validate(), isEmpty);
    });
  });

  group('JournalDraft.validate (T7.8 opening balances)', () {
    test('accepts the opening-balance journal', () {
      // Cash 5,000 Dr, AR 2,000 Dr, AP 1,500 Cr, share capital 100 Cr,
      // retained earnings 5,400 Cr: debits 7,000 = credits 7,000.
      final draft = JournalDraft(
        functionalCurrency: 'GBP',
        lines: [
          _gbpLine(accountCode: '1000', isDebit: true, amountMinor: 500000),
          _gbpLine(accountCode: '1100', isDebit: true, amountMinor: 200000),
          _gbpLine(accountCode: '2100', isDebit: false, amountMinor: 150000),
          _gbpLine(accountCode: '3000', isDebit: false, amountMinor: 10000),
          _gbpLine(accountCode: '3100', isDebit: false, amountMinor: 540000),
        ],
      );

      expect(draft.validate(), isEmpty);
    });

    test('rejects when the opening journal does not balance', () {
      final draft = JournalDraft(
        functionalCurrency: 'GBP',
        lines: [
          _gbpLine(accountCode: '1000', isDebit: true, amountMinor: 500000),
          _gbpLine(accountCode: '1100', isDebit: true, amountMinor: 200000),
          _gbpLine(accountCode: '2100', isDebit: false, amountMinor: 150000),
          _gbpLine(accountCode: '3000', isDebit: false, amountMinor: 10000),
          _gbpLine(accountCode: '3100', isDebit: false, amountMinor: 540001),
        ],
      );

      expect(codes(draft), contains('unbalancedFunctional'));
    });
  });

  group('JournalDraft.validate (single-foreign-currency balance)', () {
    test('accepts a single foreign currency that balances', () {
      final draft = JournalDraft(
        functionalCurrency: 'GBP',
        lines: [
          _fxLine(
            accountCode: '1000',
            isDebit: true,
            amountMinor: 5000,
            functionalAmountMinor: 4000,
            exchangeRate: '0.8',
          ),
          _fxLine(
            accountCode: '4000',
            isDebit: false,
            amountMinor: 5000,
            functionalAmountMinor: 4000,
            exchangeRate: '0.8',
          ),
        ],
      );

      expect(draft.validate(), isEmpty);
    });

    test('rejects a single foreign currency that does not balance', () {
      final draft = JournalDraft(
        functionalCurrency: 'GBP',
        lines: [
          _fxLine(
            accountCode: '1000',
            isDebit: true,
            amountMinor: 5000,
            functionalAmountMinor: 4000,
            exchangeRate: '0.8',
          ),
          _fxLine(
            accountCode: '4000',
            isDebit: false,
            amountMinor: 4000,
            functionalAmountMinor: 3200,
            exchangeRate: '0.8',
          ),
        ],
      );

      expect(
        codes(draft),
        containsAll([
          'unbalancedFunctional',
          'unbalancedTransactionCurrency',
        ]),
      );
    });
  });
}
