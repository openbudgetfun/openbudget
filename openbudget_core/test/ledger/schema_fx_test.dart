import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

void main() {
  test('division rounds 12 significant digits above and below one', () {
    for (final (a, b, expected) in [
      ('1', '3', '0.333333333333'),
      ('2', '3', '0.666666666667'),
      ('1000000000000', '3', '333333333333'),
      ('1', '3000000000000', '0.000000000000333333333333'),
    ]) {
      expect(
        ExactDecimal.tryParse(a)!.divide(ExactDecimal.tryParse(b)!).toString(),
        expected,
      );
    }
  });
  test('provider decimal normalization expands exponents and rejects zero', () {
    expect(ExactDecimal.fromDouble(1e-7).toString(), '0.0000001');
    expect(ExactDecimal.fromDouble(123456.789).toString(), '123456.789');
    for (final value in [0.0, -1.0, double.nan, double.infinity]) {
      expect(ExactDecimal.fromDouble(value), isNull);
    }
  });
  test('cross and implied rates respect zero and three decimal currencies', () {
    final rate = crossRate(
      fromPerUsd: ExactDecimal.tryParse('0.8')!,
      toPerUsd: ExactDecimal.tryParse('150')!,
    );
    expect(
      convertMinorUnits(
        amountMinor: 10000,
        exchangeRate: rate,
        transactionExponent: 2,
        functionalExponent: 0,
      ),
      18750,
    );
    final back = crossRate(
      fromPerUsd: ExactDecimal.tryParse('150')!,
      toPerUsd: ExactDecimal.tryParse('0.8')!,
    );
    expect(
      convertMinorUnits(
        amountMinor: 18750,
        exchangeRate: back,
        transactionExponent: 0,
        functionalExponent: 2,
      ),
      10000,
    );
    final implied = impliedRate(
      fromMinor: 1000,
      toMinor: 250,
      fromExponent: 3,
      toExponent: 0,
    );
    expect(
      convertMinorUnits(
        amountMinor: 1000,
        exchangeRate: implied,
        transactionExponent: 3,
        functionalExponent: 0,
      ),
      250,
    );
  });
  test('safe integer bounds reject both input and converted overflow', () {
    for (final sign in [-1, 1]) {
      expect(
        convertMinorUnits(
          amountMinor: sign * maxSafeMinor,
          exchangeRate: ExactDecimal.one,
          transactionExponent: 0,
          functionalExponent: 0,
        ),
        sign * maxSafeMinor,
      );
      expect(
        () => convertMinorUnits(
          amountMinor: sign * (maxSafeMinor + 1),
          exchangeRate: ExactDecimal.one,
          transactionExponent: 0,
          functionalExponent: 0,
        ),
        throwsRangeError,
      );
      expect(
        () => convertMinorUnits(
          amountMinor: sign * maxSafeMinor,
          exchangeRate: ExactDecimal.tryParse('2')!,
          transactionExponent: 0,
          functionalExponent: 0,
        ),
        throwsRangeError,
      );
    }
  });
  test(
    'split residue goes to first largest line and preserves mixed signs',
    () {
      final rate = ExactDecimal.tryParse('0.5')!;
      expect(
        splitBaseAmounts(
          lineAmounts: [1, 1],
          baseTotal: 1,
          rate: rate,
          fromExponent: 2,
          toExponent: 2,
        ),
        [0, 1],
      );
      expect(
        splitBaseAmounts(
          lineAmounts: [1, 3],
          baseTotal: 2,
          rate: rate,
          fromExponent: 2,
          toExponent: 2,
        ),
        [1, 1],
      );
      final lines = splitBaseAmounts(
        lineAmounts: [-3333, 1000],
        baseTotal: -1866,
        rate: ExactDecimal.tryParse('0.8')!,
        fromExponent: 2,
        toExponent: 2,
      );
      expect(lines.reduce((a, b) => a + b), -1866);
    },
  );
  test('every starter chart has a bank clearing role', () {
    for (final country in TaxJurisdiction.values) {
      for (final kind in [EntityKind.company, EntityKind.soleTrader]) {
        final chart = LedgerChartTemplate.forBooks(
          jurisdiction: country,
          entityKind: kind,
        )!;
        expect(
          chart.accounts.where(
            (a) => a.systemRole == LedgerSystemRole.bankClearing,
          ),
          hasLength(1),
        );
      }
    }
  });
}
