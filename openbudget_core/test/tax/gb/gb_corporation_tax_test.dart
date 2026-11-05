import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

void main() {
  final ap2026 = GbAccountingPeriod(
    start: DateTime.utc(2026, 4),
    end: DateTime.utc(2027, 3, 31),
  );
  const ratesForFY = gbRatesForFinancialYear;

  int tax({
    required GbAccountingPeriod ap,
    required int profitPounds,
    int associates = 0,
  }) => computeGbCorporationTax(
    ap: ap,
    chargeableProfitsMinor: profitPounds * 100,
    associatedCompanies: associates,
  ).taxMinor;

  group('the accounting period follows the company year end', () {
    test('a 31 March end lines up with the financial year', () {
      final ap = gbAccountingPeriodFor(
        taxYear: const GbTaxRules().taxYear(2026),
        endMonth: 3,
        endDay: 31,
      );
      expect(ap.start, DateTime.utc(2026, 4));
      expect(ap.end, DateTime.utc(2027, 3, 31));
      expect(ap.days, 365);
    });

    test('a 31 December end starts before the tax year', () {
      final ap = gbAccountingPeriodFor(
        taxYear: const GbTaxRules().taxYear(2026),
        endMonth: 12,
        endDay: 31,
      );
      expect(ap.start, DateTime.utc(2025, 12, 31).add(const Duration(days: 1)));
      expect(ap.end, DateTime.utc(2026, 12, 31));
    });

    test('a 30 June end ends inside the tax year', () {
      final ap = gbAccountingPeriodFor(
        taxYear: const GbTaxRules().taxYear(2026),
        endMonth: 6,
        endDay: 30,
      );
      expect(ap.start, DateTime.utc(2025, 7));
      expect(ap.end, DateTime.utc(2026, 6, 30));
    });

    test('a 29 February end falls back to 28 February', () {
      final ap = gbAccountingPeriodFor(
        taxYear: const GbTaxRules().taxYear(2025),
        endMonth: 2,
        endDay: 29,
      );
      expect(ap.end, DateTime.utc(2026, 2, 28));
      expect(ap.start, DateTime.utc(2025, 3));
    });

    test('whole calendar months are counted for the AIA pro-rating', () {
      expect(gbAccountingPeriodMonths(ap2026), 12);
      expect(
        gbAccountingPeriodMonths(
          GbAccountingPeriod(
            start: DateTime.utc(2026),
            end: DateTime.utc(2026, 9, 30),
          ),
        ),
        9,
      );
      expect(
        gbAccountingPeriodMonths(
          GbAccountingPeriod(
            start: DateTime.utc(2026, 4),
            end: DateTime.utc(2026, 9, 30),
          ),
        ),
        6,
      );
    });
  });

  group('Corporation Tax test vectors', () {
    // uk-company-tax test vectors 1 to 6, 8, 11 and 12, computed in pence
    // and rounded down. Vector 9 uses HMRC's months basis, so the days
    // basis the pack must use (CTM03930) gives a different figure and is
    // covered by vector 11 instead. Vector 7 needs exempt distributions,
    // which the pack does not model.
    test('vector 1: £30,000 pays the small profits rate', () {
      expect(tax(ap: ap2026, profitPounds: 30000), 570000);
    });

    test('vector 2: exactly £50,000, marginal relief to £9,500', () {
      expect(tax(ap: ap2026, profitPounds: 50000), 950000);
    });

    test('vector 3: £100,000', () {
      expect(tax(ap: ap2026, profitPounds: 100000), 2275000);
    });

    test('vector 4: £150,000', () {
      expect(tax(ap: ap2026, profitPounds: 150000), 3600000);
    });

    test('vector 5: exactly £250,000 pays the main rate', () {
      expect(tax(ap: ap2026, profitPounds: 250000), 6250000);
    });

    test('vector 6: £300,000', () {
      expect(tax(ap: ap2026, profitPounds: 300000), 7500000);
    });

    test('vector 8: one associate divides the limits', () {
      // Limits £25,000 and £125,000: £15,000 gross less £975.
      expect(tax(ap: ap2026, profitPounds: 60000, associates: 1), 1402500);
    });

    test('vector 11: a short period scales the limits by days', () {
      // AP 1 April to 30 September 2026: 183 of 365 days. Limits
      // £25,068.49 and £125,342.46, gross £15,000, relief £980.13, CT
      // £14,019.87 against the vector's "about £14,019.86" (tolerance £1:
      // the rounding of the limits is unconfirmed).
      final ap = GbAccountingPeriod(
        start: DateTime.utc(2026, 4),
        end: DateTime.utc(2026, 9, 30),
      );
      expect(ap.days, 183);
      expect(tax(ap: ap, profitPounds: 60000), 1401987);
    });

    test('vector 12: the band boundaries are exact', () {
      expect(tax(ap: ap2026, profitPounds: 50000), 950000);
      expect(tax(ap: ap2026, profitPounds: 250000), 6250000);
    });

    test('the marginal band reads as 19% plus 26.5%', () {
      // £100,000: 19% x £50,000 + 26.5% x £50,000 = £22,750.
      expect(tax(ap: ap2026, profitPounds: 100000), 950000 + 1325000);
    });
  });

  group('financial-year straddling', () {
    test('profits are apportioned by day and each part is charged alone', () {
      // AP 1 January to 31 December 2027: 90 days in FY2026 (365 days) and
      // 275 days in FY2027, which runs 1 April 2027 to 31 March 2028 and so
      // has 366 days.
      final ap = GbAccountingPeriod(
        start: DateTime.utc(2027),
        end: DateTime.utc(2027, 12, 31),
      );
      final assessment = computeGbCorporationTax(
        ap: ap,
        chargeableProfitsMinor: 10000000,
        associatedCompanies: 0,
      );
      expect(assessment.parts, hasLength(2));
      expect(assessment.parts[0].financialYearStartYear, 2026);
      expect(assessment.parts[0].days, 90);
      expect(assessment.parts[0].financialYearDays, 365);
      expect(assessment.parts[1].financialYearStartYear, 2027);
      expect(assessment.parts[1].days, 275);
      expect(assessment.parts[1].financialYearDays, 366);
      // The day-apportioned parts add back up.
      expect(
        assessment.parts[0].profitMinor + assessment.parts[1].profitMinor,
        10000000,
      );
      expect(
        assessment.taxMinor,
        assessment.parts[0].taxMinor + assessment.parts[1].taxMinor,
      );
    });

    test('the held FY2027 rates equal the FY2026 rates', () {
      expect(
        ratesForFY(2026).corporationTaxMainRateBasisPoints,
        ratesForFY(2027).corporationTaxMainRateBasisPoints,
      );
      expect(
        ratesForFY(2027).corporationTaxLowerLimitMinor,
        5000000,
      );
      expect(
        ratesForFY(2027).corporationTaxUpperLimitMinor,
        25000000,
      );
    });

    test('a period inside one financial year gives a single part', () {
      final assessment = computeGbCorporationTax(
        ap: ap2026,
        chargeableProfitsMinor: 5000000,
        associatedCompanies: 0,
      );
      expect(assessment.parts, hasLength(1));
      expect(assessment.parts.single.financialYearStartYear, 2026);
      expect(assessment.taxMinor, 950000);
    });

    test('no profits give a nil assessment', () {
      final assessment = computeGbCorporationTax(
        ap: ap2026,
        chargeableProfitsMinor: 0,
        associatedCompanies: 0,
      );
      expect(assessment.parts, isEmpty);
      expect(assessment.taxMinor, 0);
      expect(assessment.grossTaxMinor, 0);
      expect(assessment.marginalReliefMinor, 0);
    });
  });
}
