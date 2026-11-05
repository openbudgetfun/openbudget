import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

final GbTaxYearRates _rates2025 = gbRatesByStartYear[2025]!;
final GbTaxYearRates _rates2026 = gbRatesByStartYear[2026]!;

void main() {
  group('computeGbPaymentsOnAccount', () {
    test('TC1: half of Income Tax plus Class 4, on the statutory dates', () {
      // Sole-trade profit £60,000 in 2025/26: £11,432.00 Income Tax plus
      // £2,456.60 Class 4 -> £6,944.30 each.
      final payments = computeGbPaymentsOnAccount(
        rates: _rates2025,
        startYear: 2025,
        incomeTaxAndClass4Minor: 1143200 + 245660,
        taxCollectedAtSourceMinor: 0,
      );
      expect(payments.required, isTrue);
      expect(payments.baseMinor, 1388860);
      expect(payments.instalmentMinor, 694430);
      expect(payments.totalMinor, 1388860);
      expect(payments.firstDue, DateTime.utc(2027, 1, 31));
      expect(payments.secondDue, DateTime.utc(2027, 7, 31));
      expect(payments.collectedSharePercent, 0);
    });

    test('TC14: an £8,000 bill gives £4,000 instalments', () {
      final payments = computeGbPaymentsOnAccount(
        rates: _rates2025,
        startYear: 2025,
        incomeTaxAndClass4Minor: 800000,
        taxCollectedAtSourceMinor: 0,
      );
      expect(payments.required, isTrue);
      expect(payments.instalmentMinor, 400000);
    });

    test('odd pence halve downward, never up', () {
      final payments = computeGbPaymentsOnAccount(
        rates: _rates2026,
        startYear: 2026,
        incomeTaxAndClass4Minor: 100001,
        taxCollectedAtSourceMinor: 0,
      );
      expect(payments.instalmentMinor, 50000);
    });

    test('not required under the £1,000 minimum', () {
      final under = computeGbPaymentsOnAccount(
        rates: _rates2026,
        startYear: 2026,
        incomeTaxAndClass4Minor: 99999,
        taxCollectedAtSourceMinor: 0,
      );
      expect(under.required, isFalse);
      expect(under.totalMinor, 0);

      final exactly = computeGbPaymentsOnAccount(
        rates: _rates2026,
        startYear: 2026,
        incomeTaxAndClass4Minor: 100000,
        taxCollectedAtSourceMinor: 0,
      );
      expect(exactly.required, isTrue);
    });

    test('not required when more than 80% was collected at source', () {
      // £3,486.00 with £2,789.00 collected: the base £697.00 is under 20%
      // of the year's tax (SA110 A358), so nothing is due even though the
      // floored share reads 80%.
      final atEighty = computeGbPaymentsOnAccount(
        rates: _rates2026,
        startYear: 2026,
        incomeTaxAndClass4Minor: 348600,
        taxCollectedAtSourceMinor: 278900,
      );
      expect(atEighty.required, isFalse);
      expect(atEighty.collectedSharePercent, 80);

      // Exactly 80% collected leaves exactly the 20% base: still required.
      final exactShare = computeGbPaymentsOnAccount(
        rates: _rates2026,
        startYear: 2026,
        incomeTaxAndClass4Minor: 1000000,
        taxCollectedAtSourceMinor: 800000,
      );
      expect(exactShare.required, isTrue);
      expect(exactShare.instalmentMinor, 100000);

      final moreThanEighty = computeGbPaymentsOnAccount(
        rates: _rates2026,
        startYear: 2026,
        incomeTaxAndClass4Minor: 100000,
        taxCollectedAtSourceMinor: 81000,
      );
      expect(moreThanEighty.required, isFalse);
    });

    test('tax collected above the liability leaves nothing to pay', () {
      final payments = computeGbPaymentsOnAccount(
        rates: _rates2026,
        startYear: 2026,
        incomeTaxAndClass4Minor: 100000,
        taxCollectedAtSourceMinor: 150000,
      );
      expect(payments.baseMinor, 0);
      expect(payments.required, isFalse);
    });

    test('no liability gives no payments and a nil share', () {
      final payments = computeGbPaymentsOnAccount(
        rates: _rates2026,
        startYear: 2026,
        incomeTaxAndClass4Minor: 0,
        taxCollectedAtSourceMinor: 0,
      );
      expect(payments.required, isFalse);
      expect(payments.collectedSharePercent, 0);
      expect(payments.baseMinor, 0);
    });
  });
}
