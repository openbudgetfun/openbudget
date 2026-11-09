import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

void main() {
  test('balance targets include carryover and signed activity', () {
    expect(
      underfundedMinor(
        (kind: 'targetBalance', amountMinor: 1000, targetDate: null),
        202611,
        500,
        200,
        -100,
      ),
      400,
    );
    expect(
      underfundedMinor(
        (kind: 'targetBalance', amountMinor: 100, targetDate: null),
        202611,
        500,
        200,
        -100,
      ),
      0,
    );
  });
  test('monthly funding ignores carryover and activity', () {
    expect(
      underfundedMinor(
        (kind: 'monthlyFunding', amountMinor: 1000, targetDate: null),
        202611,
        500,
        200,
        -100,
      ),
      800,
    );
  });
  test('target date funding rounds up without floating point', () {
    expect(
      underfundedMinor(
        (
          kind: 'targetByDate',
          amountMinor: 1000,
          targetDate: DateTime.utc(2027, 2),
        ),
        202611,
        0,
        0,
        0,
      ),
      334,
    );
    expect(
      underfundedMinor(
        (
          kind: 'targetByDate',
          amountMinor: 1000,
          targetDate: DateTime.utc(2026, 10),
        ),
        202611,
        200,
        100,
        0,
      ),
      700,
    );
  });
  test(
    'revaluation journals allow zero native amounts and require base balance',
    () {
      JournalLineDraft line(String code, int debit, int credit) =>
          JournalLineDraft(
            accountCode: code,
            debitMinor: 0,
            creditMinor: 0,
            currencyCode: 'USD',
            functionalDebitMinor: debit,
            functionalCreditMinor: credit,
            exchangeRate: '0.8',
            rateDate: DateTime.utc(2026, 11, 1),
            rateSource: 'market',
          );
      final lines = [line('bank', 100, 0), line('unrealisedFx', 0, 100)];
      expect(
        JournalDraft(
          functionalCurrency: 'GBP',
          source: JournalSource.revaluation,
          lines: lines,
        ).validate(),
        isEmpty,
      );
      expect(
        JournalDraft(functionalCurrency: 'GBP', lines: lines).validate(),
        isNotEmpty,
      );
      expect(
        JournalDraft(
          functionalCurrency: 'GBP',
          source: JournalSource.revaluation,
          lines: [line('bank', 100, 0), line('unrealisedFx', 0, 99)],
        ).validate().map((issue) => issue.code),
        contains('unbalancedFunctional'),
      );
    },
  );
}
