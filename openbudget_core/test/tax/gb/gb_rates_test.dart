import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

void main() {
  final rates2025 = gbRatesByStartYear[2025]!;
  final rates2026 = gbRatesByStartYear[2026]!;

  group('the tables cover the supported years', () {
    test('2025 and 2026 only', () {
      expect(gbRatesByStartYear.keys, unorderedEquals([2025, 2026]));
      expect(rates2025.label, '2025/26');
      expect(rates2026.label, '2026/27');
    });

    test('the sources are gov.uk pages checked on 2026-11-04', () {
      expect(gbRateSources, isNotEmpty);
      expect(
        gbRateSources.every(
          (source) => source.host == 'www.gov.uk' || source.host == 'gov.uk',
        ),
        isTrue,
      );
      expect(
        gbRateSources,
        contains(Uri.parse('https://www.gov.uk/income-tax-rates')),
      );
      expect(gbRulesVerifiedOn, DateTime.utc(2026, 11, 4));
    });
  });

  group('personal allowance', () {
    for (final rates in [rates2025, rates2026]) {
      test('${rates.label} is frozen at £12,570', () {
        expect(rates.personalAllowanceMinor, 1257000);
        expect(rates.personalAllowanceIncomeLimitMinor, 10000000);
        expect(rates.personalAllowanceFor(10000000), 1257000);
        expect(rates.personalAllowanceFor(11000000), 757000);
        expect(rates.personalAllowanceFor(12514000), 0);
      });
    }
  });

  group('England, Wales and Northern Ireland bands', () {
    for (final rates in [rates2025, rates2026]) {
      test('${rates.label} basic, higher and additional rates', () {
        expect(rates.rukBands.map((band) => band.rateBasisPoints), [
          2000,
          4000,
          4500,
        ]);
        expect(rates.rukBands.map((band) => band.ceilingMinor), [
          3770000,
          12514000,
          null,
        ]);
        expect(rates.basicRateLimitMinor, 3770000);
        expect(rates.higherRateLimitMinor, 12514000);
      });
    }
  });

  group('Scottish bands', () {
    test('2025/26 ceilings and rates', () {
      expect(rates2025.scottishBands.map((band) => band.rateBasisPoints), [
        1900,
        2000,
        2100,
        4200,
        4500,
        4800,
      ]);
      expect(rates2025.scottishBands.map((band) => band.ceilingMinor), [
        282700,
        1492100,
        3109200,
        6243000,
        12514000,
        null,
      ]);
    });

    test('2026/27 ceilings and rates', () {
      expect(rates2026.scottishBands.map((band) => band.rateBasisPoints), [
        1900,
        2000,
        2100,
        4200,
        4500,
        4800,
      ]);
      expect(rates2026.scottishBands.map((band) => band.ceilingMinor), [
        396700,
        1695600,
        3109200,
        6243000,
        12514000,
        null,
      ]);
    });
  });

  group('savings and dividends', () {
    for (final rates in [rates2025, rates2026]) {
      test('${rates.label} savings allowances', () {
        expect(rates.startingRateForSavingsMinor, 500000);
        expect(rates.personalSavingsAllowanceBasicMinor, 100000);
        expect(rates.personalSavingsAllowanceHigherMinor, 50000);
        expect(rates.dividendAllowanceMinor, 50000);
        expect(rates.savingsBands.map((band) => band.rateBasisPoints), [
          2000,
          4000,
          4500,
        ]);
      });
    }

    test('dividend rates rose in 2026/27', () {
      expect(rates2025.dividendBands.map((band) => band.rateBasisPoints), [
        875,
        3375,
        3935,
      ]);
      expect(rates2026.dividendBands.map((band) => band.rateBasisPoints), [
        1075,
        3575,
        3935,
      ]);
    });
  });

  group('capital gains', () {
    for (final rates in [rates2025, rates2026]) {
      test('${rates.label} annual exempt amount and rates', () {
        expect(rates.capitalGainsAnnualExemptAmountMinor, 300000);
        expect(rates.capitalGainsBasicRateBasisPoints, 1800);
        expect(rates.capitalGainsHigherRateBasisPoints, 2400);
      });
    }
  });

  group('national insurance', () {
    test('Class 2 small profits thresholds', () {
      expect(rates2025.class2SmallProfitsThresholdMinor, 684500);
      expect(rates2025.class2WeeklyRateMinor, 350);
      expect(rates2026.class2SmallProfitsThresholdMinor, 710500);
      expect(rates2026.class2WeeklyRateMinor, 365);
    });

    test('Class 4 limits and rates', () {
      for (final rates in [rates2025, rates2026]) {
        expect(rates.class4LowerProfitsLimitMinor, 1257000);
        expect(rates.class4UpperProfitsLimitMinor, 5027000);
        expect(rates.class4LowerRateBasisPoints, 600);
        expect(rates.class4UpperRateBasisPoints, 200);
      }
    });

    test('Class 1 annual thresholds for the director comparison', () {
      for (final rates in [rates2025, rates2026]) {
        expect(rates.class1PrimaryThresholdMinor, 1257000);
        expect(rates.class1SecondaryThresholdMinor, 500000);
        expect(rates.class1UpperEarningsLimitMinor, 5027000);
        expect(rates.class1EmployeeRateBasisPoints, 800);
        expect(rates.class1EmployeeUpperRateBasisPoints, 200);
        expect(rates.class1EmployerRateBasisPoints, 1500);
      }
    });
  });

  group('student loans', () {
    test('2025/26 thresholds', () {
      expect(
        rates2025.studentLoans[GbStudentLoanPlan.plan1]!.thresholdMinor,
        2606500,
      );
      expect(
        rates2025.studentLoans[GbStudentLoanPlan.plan2]!.thresholdMinor,
        2847000,
      );
      expect(
        rates2025.studentLoans[GbStudentLoanPlan.plan4]!.thresholdMinor,
        3274500,
      );
      expect(
        rates2025.studentLoans[GbStudentLoanPlan.plan5]!.thresholdMinor,
        isNull,
      );
      expect(
        rates2025.studentLoans[GbStudentLoanPlan.postgraduate]!.thresholdMinor,
        2100000,
      );
    });

    test('2026/27 thresholds', () {
      expect(
        rates2026.studentLoans[GbStudentLoanPlan.plan1]!.thresholdMinor,
        2690000,
      );
      expect(
        rates2026.studentLoans[GbStudentLoanPlan.plan2]!.thresholdMinor,
        2938500,
      );
      expect(
        rates2026.studentLoans[GbStudentLoanPlan.plan4]!.thresholdMinor,
        3379500,
      );
      expect(
        rates2026.studentLoans[GbStudentLoanPlan.plan5]!.thresholdMinor,
        2500000,
      );
      expect(
        rates2026.studentLoans[GbStudentLoanPlan.postgraduate]!.thresholdMinor,
        2100000,
      );
    });

    test('the repayment percentages', () {
      for (final rates in [rates2025, rates2026]) {
        expect(
          rates.studentLoans[GbStudentLoanPlan.plan1]!.rateBasisPoints,
          900,
        );
        expect(
          rates.studentLoans[GbStudentLoanPlan.postgraduate]!.rateBasisPoints,
          600,
        );
      }
    });
  });

  group('business taxes', () {
    for (final rates in [rates2025, rates2026]) {
      test('${rates.label} Corporation Tax', () {
        expect(rates.corporationTaxSmallProfitsRateBasisPoints, 1900);
        expect(rates.corporationTaxMainRateBasisPoints, 2500);
        expect(rates.corporationTaxLowerLimitMinor, 5000000);
        expect(rates.corporationTaxUpperLimitMinor, 25000000);
        expect(rates.corporationTaxMarginalReliefBasisPoints, 150);
      });

      test('${rates.label} VAT', () {
        expect(rates.vatRegistrationThresholdMinor, 9000000);
        expect(rates.vatStandardRateBasisPoints, 2000);
      });

      test('${rates.label} allowances', () {
        expect(rates.tradingAllowanceMinor, 100000);
        expect(rates.isaAllowanceMinor, 2000000);
        expect(rates.pensionAnnualAllowanceMinor, 6000000);
      });
    }
  });
}
