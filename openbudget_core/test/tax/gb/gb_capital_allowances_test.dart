import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

void main() {
  final rates2026 = gbRatesByStartYear[2026]!;

  group('the Annual Investment Allowance cap', () {
    test('spend above the cap leaves the excess unrelieved', () {
      final allowances = computeGbCapitalAllowances(
        rates: rates2026,
        aiaCapMinor: 100000000,
        additions: const GbCapitalAllowanceAdditions(
          otherQualifyingMinor: 120000000,
        ),
      );
      expect(allowances.annualInvestmentAllowanceMinor, 100000000);
      expect(allowances.unrelievedMinor, 20000000);
      expect(allowances.aiaCapMinor, 100000000);
    });

    test('spend below the cap is fully relieved', () {
      final allowances = computeGbCapitalAllowances(
        rates: rates2026,
        aiaCapMinor: 100000000,
        additions: const GbCapitalAllowanceAdditions(
          otherQualifyingMinor: 6000000,
        ),
      );
      expect(allowances.annualInvestmentAllowanceMinor, 6000000);
      expect(allowances.unrelievedMinor, 0);
    });

    test('cars never reach the Annual Investment Allowance', () {
      final allowances = computeGbCapitalAllowances(
        rates: rates2026,
        aiaCapMinor: 100000000,
        additions: const GbCapitalAllowanceAdditions(
          otherQualifyingMinor: 5000000,
          carMinor: 1800000,
        ),
      );
      expect(allowances.annualInvestmentAllowanceMinor, 5000000);
      expect(allowances.unrelievedMinor, 1800000);
    });
  });

  group('the pro-rated cap', () {
    test('vector C: a nine-month period gets three quarters of the cap', () {
      // HMRC's own example: nine months of a £1,000,000 cap is £750,000.
      final cap = rates2026.annualInvestmentAllowanceCapMinor * 9 ~/ 12;
      expect(cap, 75000000);
      final allowances = computeGbCapitalAllowances(
        rates: rates2026,
        aiaCapMinor: cap,
        additions: const GbCapitalAllowanceAdditions(
          otherQualifyingMinor: 100000000,
        ),
      );
      expect(allowances.annualInvestmentAllowanceMinor, 75000000);
      expect(allowances.unrelievedMinor, 25000000);
    });

    test('the cap follows whole calendar months of the period', () {
      final ap = GbAccountingPeriod(
        start: DateTime.utc(2026),
        end: DateTime.utc(2026, 9, 30),
      );
      expect(gbAccountingPeriodMonths(ap), 9);
      expect(
        rates2026.annualInvestmentAllowanceCapMinor *
            gbAccountingPeriodMonths(ap) ~/
            12,
        75000000,
      );
    });
  });

  group('full expensing and the special-rate first-year allowance', () {
    test('companies fully expense new main-rate plant', () {
      final allowances = computeGbCapitalAllowances(
        rates: rates2026,
        aiaCapMinor: 100000000,
        additions: const GbCapitalAllowanceAdditions(
          newMainRatePlantMinor: 1000000,
        ),
        company: true,
      );
      expect(allowances.fullExpensingMinor, 1000000);
      expect(allowances.specialRateFirstYearAllowanceMinor, 0);
      expect(allowances.unrelievedMinor, 0);
      expect(allowances.totalMinor, 1000000);
    });

    test('companies take 50% on new special-rate plant', () {
      final allowances = computeGbCapitalAllowances(
        rates: rates2026,
        aiaCapMinor: 100000000,
        additions: const GbCapitalAllowanceAdditions(
          newSpecialRatePlantMinor: 1000000,
        ),
        company: true,
      );
      expect(allowances.specialRateFirstYearAllowanceMinor, 500000);
      // The other half waits for the special-rate pool, not modelled yet.
      expect(allowances.unrelievedMinor, 500000);
    });

    test('new plant still takes the AIA route for sole traders', () {
      final allowances = computeGbCapitalAllowances(
        rates: rates2026,
        aiaCapMinor: 100000000,
        additions: const GbCapitalAllowanceAdditions(
          newMainRatePlantMinor: 1000000,
          newSpecialRatePlantMinor: 500000,
        ),
      );
      expect(allowances.fullExpensingMinor, 0);
      expect(allowances.specialRateFirstYearAllowanceMinor, 0);
      expect(allowances.annualInvestmentAllowanceMinor, 1500000);
    });

    test('cars stay out of every 100% route', () {
      final allowances = computeGbCapitalAllowances(
        rates: rates2026,
        aiaCapMinor: 100000000,
        additions: const GbCapitalAllowanceAdditions(
          newMainRatePlantMinor: 500000,
          carMinor: 2000000,
        ),
        company: true,
      );
      expect(allowances.fullExpensingMinor, 500000);
      expect(allowances.unrelievedMinor, 2000000);
    });

    test('the AIA cap and full expensing do not stack on one pound', () {
      final allowances = computeGbCapitalAllowances(
        rates: rates2026,
        aiaCapMinor: 100000000,
        additions: const GbCapitalAllowanceAdditions(
          newMainRatePlantMinor: 150000000,
          otherQualifyingMinor: 100000000,
        ),
        company: true,
      );
      expect(allowances.fullExpensingMinor, 150000000);
      expect(allowances.annualInvestmentAllowanceMinor, 100000000);
      expect(allowances.unrelievedMinor, 0);
      expect(allowances.totalMinor, 250000000);
    });
  });
}
