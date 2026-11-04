import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

import 'ng_test_helpers.dart';

/// Builds an individual report for 2026.
TaxReport individualReport({
  int employmentNaira = 0,
  int annualRentNaira = 0,
  int pensionNaira = 0,
  List<TaxEntry> extra = const [],
  List<TaxInput> linked = const [],
}) => ngRules.report(
  ngInput(
    profile: ngIndividual(annualRentNaira: annualRentNaira),
    entries: [
      if (employmentNaira > 0)
        ngEntry('ng.ind.employment.salary', employmentNaira),
      if (pensionNaira > 0) ngEntry('ng.ind.relief.pension', pensionNaira),
      ...extra,
    ],
    linked: linked,
  ),
);

void main() {
  group('Fourth Schedule bands', () {
    test('an empty return owes nothing', () {
      final report = individualReport();
      expect(ngLine(report, 'Total income').amountMinor, 0);
      expect(ngLine(report, 'Chargeable income').amountMinor, 0);
      expect(report.totalLiabilityMinor, 0);
    });

    // Worked from the Fourth Schedule to the Nigeria Tax Act 2025:
    // https://www.nrs.gov.ng/uploads/NIGERIA_TAX_ACT_2025_ef6bb812a5.pdf
    const cases = <(int, int)>[
      (800_000, 0),
      (3_000_000, 330_000),
      (12_000_000, 1_950_000),
      (25_000_000, 4_680_000),
      (50_000_000, 10_430_000),
      (60_000_000, 12_930_000),
    ];

    for (final (income, expectedTax) in cases) {
      test('N$income of employment income pays N$expectedTax', () {
        final report = individualReport(employmentNaira: income);
        expect(report.liabilities.single.amountMinor, expectedTax * 100);
        expect(report.balanceDueMinor, expectedTax * 100);
      });
    }

    test('the first N800,000 is tax free', () {
      final report = individualReport(employmentNaira: 800_000);
      expect(ngLine(report, 'Chargeable income').amountMinor, 80_000_000);
      final bands = report.liabilities.single.bands;
      expect(bands, hasLength(1));
      expect(bands.single.rateBasisPoints, 0);
      expect(bands.single.taxMinor, 0);
    });

    test('a kobo above the tax-free band still pays nothing', () {
      final report = ngRules.report(
        ngInput(
          profile: ngIndividual(),
          entries: [
            ngEntry('ng.ind.employment.salary', 0, amountMinor: 80_000_001),
          ],
        ),
      );
      expect(report.liabilities.single.amountMinor, 0);
    });

    test('one kobo into the 18% band pays the floored slice', () {
      final report = ngRules.report(
        ngInput(
          profile: ngIndividual(),
          entries: [
            ngEntry('ng.ind.employment.salary', 0, amountMinor: 300_000_001),
          ],
        ),
      );
      expect(report.liabilities.single.amountMinor, 33_000_000);
    });

    test('the band bases and rates follow the Fourth Schedule', () {
      final report = individualReport(employmentNaira: 60_000_000);
      final bands = report.liabilities.single.bands;
      expect(bands.map((band) => band.baseMinor), [
        80_000_000,
        220_000_000,
        900_000_000,
        1_300_000_000,
        2_500_000_000,
        1_000_000_000,
      ]);
      expect(bands.map((band) => band.rateBasisPoints), [
        0,
        1500,
        1800,
        2100,
        2300,
        2500,
      ]);
      expect(bands.map((band) => band.taxMinor), [
        0,
        33_000_000,
        162_000_000,
        273_000_000,
        575_000_000,
        250_000_000,
      ]);
    });
  });

  group('eligible deductions', () {
    test('rent relief is 20% of rent and capped at N500,000', () {
      final report = individualReport(
        employmentNaira: 10_000_000,
        annualRentNaira: 3_000_000,
      );
      expect(ngLine(report, 'Rent relief').amountMinor, 50_000_000);
      expect(ngLine(report, 'Chargeable income').amountMinor, 950_000_000);
      expect(report.liabilities.single.amountMinor, 150_000_000);
    });

    test('rent relief below the cap is 20% of the rent', () {
      final report = individualReport(
        employmentNaira: 2_800_000,
        annualRentNaira: 1_000_000,
      );
      expect(ngLine(report, 'Rent relief').amountMinor, 20_000_000);
      expect(ngLine(report, 'Chargeable income').amountMinor, 260_000_000);
      expect(report.liabilities.single.amountMinor, 27_000_000);
    });

    test(
      'pension, NHF, NHIS, life insurance and housing loan interest add up',
      () {
        final report = individualReport(
          employmentNaira: 5_000_000,
          pensionNaira: 1_000_000,
          extra: [
            ngEntry('ng.ind.relief.nhf', 200_000),
            ngEntry('ng.ind.relief.nhis', 100_000),
            ngEntry('ng.ind.relief.life_insurance', 100_000),
            ngEntry('ng.ind.relief.housing_loan_interest', 300_000),
          ],
        );
        expect(ngLine(report, 'Chargeable income').amountMinor, 330_000_000);
        expect(report.liabilities.single.amountMinor, 38_400_000);
      },
    );
  });

  group('tax deducted at source', () {
    test('PAYE and withholding tax reduce the balance due', () {
      final report = individualReport(
        employmentNaira: 2_800_000,
        annualRentNaira: 1_000_000,
        extra: [
          ngEntry('ng.ind.tax.paye', 50_000),
          ngEntry('ng.ind.tax.wht', 20_000),
        ],
      );
      expect(report.liabilities.single.amountMinor, 27_000_000);
      expect(report.alreadyPaidMinor, 7_000_000);
      expect(report.balanceDueMinor, 20_000_000);
    });
  });

  group('chargeable gains', () {
    test('gains join the bands as total income', () {
      final report = individualReport(
        employmentNaira: 1_000_000,
        extra: [
          ngEntry('ng.ind.gain.proceeds', 5_000_000),
          ngEntry('ng.ind.gain.cost', 3_000_000),
        ],
      );
      expect(ngLine(report, 'Chargeable gains').amountMinor, 200_000_000);
      expect(ngLine(report, 'Total income').amountMinor, 300_000_000);
      expect(report.liabilities.single.amountMinor, 33_000_000);
    });

    test('a capital loss is carried forward and does not reduce income', () {
      final report = individualReport(
        employmentNaira: 1_000_000,
        extra: [
          ngEntry('ng.ind.gain.proceeds', 1_000_000),
          ngEntry('ng.ind.gain.cost', 3_000_000),
        ],
      );
      expect(ngLine(report, 'Capital loss').amountMinor, 200_000_000);
      expect(ngLine(report, 'Total income').amountMinor, 100_000_000);
      expect(report.liabilities.single.amountMinor, 3_000_000);
    });
  });

  group('linked sole trades', () {
    test('business profit is added to total income', () {
      final business = ngInput(
        profile: ngSoleTrader(),
        entries: [
          ngEntry('ng.biz.revenue.sales', 5_000_000),
          ngEntry('ng.biz.expense.other', 2_000_000),
          ngEntry('ng.biz.tax.wht', 20_000),
        ],
      );
      final report = individualReport(
        employmentNaira: 1_000_000,
        linked: [business],
      );
      expect(
        ngLine(report, 'Profit from linked business').amountMinor,
        300_000_000,
      );
      expect(ngLine(report, 'Total income').amountMinor, 400_000_000);
      expect(report.liabilities.single.amountMinor, 51_000_000);
      expect(report.alreadyPaidMinor, 2_000_000);
    });

    test('a business loss is carried forward, not offset', () {
      final business = ngInput(
        profile: ngSoleTrader(),
        entries: [
          ngEntry('ng.biz.revenue.sales', 1_000_000),
          ngEntry('ng.biz.expense.other', 2_000_000),
        ],
      );
      final report = individualReport(
        employmentNaira: 1_000_000,
        linked: [business],
      );
      expect(
        ngLine(report, 'Loss from linked business').amountMinor,
        100_000_000,
      );
      expect(ngLine(report, 'Total income').amountMinor, 100_000_000);
      expect(report.liabilities.single.amountMinor, 3_000_000);
    });

    test('a linked company is left out and explained', () {
      final company = ngInput(
        profile: ngCompany(),
        entries: [ngEntry('ng.co.revenue.sales', 10_000_000)],
      );
      final report = individualReport(
        employmentNaira: 1_000_000,
        linked: [company],
      );
      expect(ngLine(report, 'Total income').amountMinor, 100_000_000);
      expect(
        report.assumptions.any((line) => line.contains('not sole trades')),
        isTrue,
      );
    });
  });

  group('uncategorized entries', () {
    test('unknown and wrong-entity codes are counted and left out', () {
      final report = ngRules.report(
        ngInput(
          profile: ngIndividual(),
          entries: [
            ngEntry('ng.ind.employment.salary', 1_000_000),
            ngEntry('ng.co.revenue.sales', 5_000_000),
            ngEntry('ng.unknown', 3_000_000),
          ],
        ),
      );
      expect(report.uncategorizedCount, 2);
      expect(ngLine(report, 'Total income').amountMinor, 100_000_000);
      expect(report.liabilities.single.amountMinor, 3_000_000);
    });
  });
}
