import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

import 'ng_test_helpers.dart';

/// Builds an individual report for the 2025 old regime (PITA).
TaxReport oldIndividualReport({
  int employmentNaira = 0,
  int annualRentNaira = 0,
  List<TaxEntry> extra = const [],
}) => ngRules.report(
  ngInput(
    startYear: 2025,
    profile: ngIndividual(annualRentNaira: annualRentNaira),
    entries: [
      if (employmentNaira > 0)
        ngEntry('ng.ind.employment.salary', employmentNaira),
      ...extra,
    ],
  ),
);

/// Builds a company report for the 2025 old regime (CITA).
TaxReport oldCompanyReport({required int turnoverNaira, int profitNaira = 0}) {
  final expense = turnoverNaira - profitNaira;
  return ngRules.report(
    ngInput(
      startYear: 2025,
      profile: ngCompany(),
      entries: [
        ngEntry('ng.co.revenue.sales', turnoverNaira),
        if (expense > 0) ngEntry('ng.co.expense.other', expense),
      ],
    ),
  );
}

void main() {
  group('regime selection', () {
    test('a 2025 year follows the old regime and 2026 the NTA', () {
      const salary = 1_000_000;
      final old = ngRules.report(
        ngInput(
          startYear: 2025,
          profile: ngIndividual(),
          entries: [ngEntry('ng.ind.employment.salary', salary)],
        ),
      );
      final nta = ngRules.report(
        ngInput(
          profile: ngIndividual(),
          entries: [ngEntry('ng.ind.employment.salary', salary)],
        ),
      );
      // Old regime: CRA lifts the N300,000 tax-free slice into a N300,000
      // chargeable slice at 7%; the NTA taxes only the slice above the free
      // N800,000 (vector T2).
      expect(old.liabilities.single.amountMinor, 5_400_000);
      expect(nta.liabilities.single.amountMinor, 3_000_000);
      expect(
        ngLine(old, 'Consolidated relief allowance'),
        isNotNull,
      );
      expect(
        old.lines.any((line) => line.label.startsWith('Rent relief')),
        isFalse,
      );
    });

    test('a basis period ending 30 June 2026 falls in the 2026 NTA year', () {
      expect(ngRules.taxYearFor(DateTime.utc(2026, 6, 30)).startYear, 2026);
    });
  });

  group('PITA bands and the consolidated relief allowance', () {
    test('O1: gross 6,000,000 with pension and NHF pays N776,000', () {
      final report = oldIndividualReport(
        employmentNaira: 6_000_000,
        extra: [
          ngEntry('ng.ind.relief.pension', 400_000),
          ngEntry('ng.ind.relief.nhf', 100_000),
        ],
      );
      // CRA = max(200,000, 1% x 6,000,000) + 20% x 6,000,000 = 1,400,000.
      expect(
        ngLine(report, 'Consolidated relief allowance').amountMinor,
        140_000_000,
      );
      expect(ngLine(report, 'Chargeable income').amountMinor, 410_000_000);
      expect(report.liabilities.single.amountMinor, 77_600_000);
    });

    test('O2: minimum tax replaces the lower progressive tax', () {
      final report = oldIndividualReport(
        employmentNaira: 300_000,
      );
      // CRA = max(200,000, 3,000) + 60,000 = 260,000; chargeable 40,000;
      // progressive tax 2,800; minimum tax 1% x 300,000 = 3,000.
      expect(
        ngLine(report, 'Consolidated relief allowance').amountMinor,
        26_000_000,
      );
      expect(ngLine(report, 'Chargeable income').amountMinor, 4_000_000);
      expect(report.liabilities.single.amountMinor, 300_000);
      final bands = report.liabilities.single.bands;
      expect(bands, hasLength(1));
      expect(bands.single.label, contains('Minimum tax'));
      expect(bands.single.rateBasisPoints, 100);
    });

    test('progressive tax applies where it exceeds the minimum tax', () {
      final report = oldIndividualReport(employmentNaira: 6_000_000);
      // Progressive tax on 4,600,000 chargeable (89,600,000 kobo) is far
      // above the 1% minimum tax of 60,000 kobo.
      expect(report.liabilities.single.amountMinor, 89_600_000);
      final bands = report.liabilities.single.bands;
      expect(bands.first.label, isNot(contains('Minimum tax')));
    });

    test('O3: gross 30,000,000 without reliefs pays N5,480,000 in 2025', () {
      final report = oldIndividualReport(employmentNaira: 30_000_000);
      expect(
        ngLine(report, 'Consolidated relief allowance').amountMinor,
        630_000_000,
      );
      expect(ngLine(report, 'Chargeable income').amountMinor, 2_370_000_000);
      expect(report.liabilities.single.amountMinor, 548_000_000);
    });

    test('O3 pays more in 2026 without rent, and rent relief narrows it', () {
      final withoutRent = ngRules.report(
        ngInput(
          profile: ngIndividual(),
          entries: [ngEntry('ng.ind.employment.salary', 30_000_000)],
        ),
      );
      expect(withoutRent.liabilities.single.amountMinor, 583_000_000);

      final withRent = ngRules.report(
        ngInput(
          profile: ngIndividual(annualRentNaira: 3_000_000),
          entries: [ngEntry('ng.ind.employment.salary', 30_000_000)],
        ),
      );
      expect(withRent.liabilities.single.amountMinor, 571_500_000);
    });

    test('the 2025 rent input is ignored and the assumption says so', () {
      final report = oldIndividualReport(
        employmentNaira: 6_000_000,
        annualRentNaira: 3_000_000,
      );
      expect(
        report.lines.any((line) => line.label.startsWith('Rent relief')),
        isFalse,
      );
      expect(
        report.assumptions.any(
          (assumption) => assumption.contains('not used for 2025'),
        ),
        isTrue,
      );
    });

    test('the 2025 bands run from 7% to 24%', () {
      final report = oldIndividualReport(employmentNaira: 10_000_000);
      final bands = report.liabilities.single.bands;
      expect(bands.map((band) => band.rateBasisPoints), [
        700,
        1100,
        1500,
        1900,
        2100,
        2400,
      ]);
    });
  });

  group('CITA turnover tiers and tertiary education tax', () {
    test('a small company at or below N25m owes nothing', () {
      final report = oldCompanyReport(
        turnoverNaira: 20_000_000,
        profitNaira: 8_000_000,
      );
      expect(ngLiability(report, 'Companies income tax').amountMinor, 0);
      expect(
        report.liabilities.where(
          (liability) => liability.label.startsWith('Tertiary'),
        ),
        isEmpty,
      );
      expect(report.totalLiabilityMinor, 0);
      expect(
        ngLiability(report, 'Companies income tax').label,
        contains('small company'),
      );
    });

    test(
      'a medium company above N25m and at or below N100m pays 20% and 3%',
      () {
        final report = oldCompanyReport(
          turnoverNaira: 50_000_000,
          profitNaira: 10_000_000,
        );
        expect(
          ngLiability(report, 'Companies income tax').amountMinor,
          200_000_000,
        );
        expect(
          ngLiability(report, 'Tertiary education tax').amountMinor,
          30_000_000,
        );
      },
    );

    test('a large company above N100m pays 30% and 3%', () {
      final report = oldCompanyReport(
        turnoverNaira: 150_000_000,
        profitNaira: 30_000_000,
      );
      expect(
        ngLiability(report, 'Companies income tax').amountMinor,
        900_000_000,
      );
      expect(
        ngLiability(report, 'Tertiary education tax').amountMinor,
        90_000_000,
      );
    });

    test('the tier boundaries sit at N25m and N100m to the kobo', () {
      // Exactly N25m is small; one kobo above is medium at 20%.
      final atSmall = ngRules.report(
        ngInput(
          startYear: 2025,
          profile: ngCompany(),
          entries: [
            ngEntry('ng.co.revenue.sales', 0, amountMinor: 2_500_000_000),
          ],
        ),
      );
      expect(
        ngLiability(atSmall, 'Companies income tax').label,
        contains('small company'),
      );

      final aboveSmall = ngRules.report(
        ngInput(
          startYear: 2025,
          profile: ngCompany(),
          entries: [
            ngEntry('ng.co.revenue.sales', 0, amountMinor: 2_500_000_001),
          ],
        ),
      );
      expect(
        ngLiability(aboveSmall, 'Companies income tax').amountMinor,
        // 20% of a total profit of N25,000,000.01, floored to the kobo.
        500_000_000,
      );

      // Exactly N100m is medium; one kobo above is large.
      final atMedium = ngRules.report(
        ngInput(
          startYear: 2025,
          profile: ngCompany(),
          entries: [
            ngEntry('ng.co.revenue.sales', 0, amountMinor: 10_000_000_000),
            ngEntry('ng.co.expense.other', 0, amountMinor: 9_000_000_000),
          ],
        ),
      );
      expect(
        ngLiability(atMedium, 'Companies income tax').amountMinor,
        200_000_000,
      );

      final aboveMedium = ngRules.report(
        ngInput(
          startYear: 2025,
          profile: ngCompany(),
          entries: [
            ngEntry('ng.co.revenue.sales', 0, amountMinor: 10_000_000_001),
            ngEntry('ng.co.expense.other', 0, amountMinor: 9_000_000_000),
          ],
        ),
      );
      expect(
        ngLiability(aboveMedium, 'Companies income tax').amountMinor,
        // 30% of N1,000,000.01 of total profits.
        300_000_000,
      );
    });

    test(
      'the 2025 report never mentions the NTA conflict or the s.57 rate',
      () {
        final report = oldCompanyReport(
          turnoverNaira: 80_000_000,
          profitNaira: 10_000_000,
        );
        expect(
          report.assumptions.any((text) => text.contains('disagree')),
          isFalse,
        );
        expect(
          report.assumptions.any(
            (text) => text.contains('minimum effective tax rate'),
          ),
          isFalse,
        );
        expect(
          report.assumptions.any(
            (text) => text.contains('secondary-sourced'),
          ),
          isTrue,
        );
      },
    );
  });

  group('2025 VAT', () {
    test('the old registration threshold is N25,000,000', () {
      final smallInput = ngInput(
        startYear: 2025,
        profile: ngSoleTrader(),
        entries: [ngEntry('ng.biz.revenue.sales', 20_000_000)],
      );
      final small = ngRules.report(smallInput);
      final opportunity = ngRules
          .opportunities(smallInput, small)
          .firstWhere((item) => item.id == 'ng.vat_registration');
      expect(opportunity.title, contains('exemption'));

      final aboveInput = ngInput(
        startYear: 2025,
        profile: ngSoleTrader(),
        entries: [ngEntry('ng.biz.revenue.sales', 26_000_000)],
      );
      final above = ngRules.report(aboveInput);
      final aboveOpportunity = ngRules
          .opportunities(aboveInput, above)
          .firstWhere((item) => item.id == 'ng.vat_registration');
      expect(aboveOpportunity.title, 'Register for VAT');
      expect(aboveOpportunity.explanation, contains('N25000000'));
    });

    test('output less input VAT still nets to the balance due', () {
      final report = ngRules.report(
        ngInput(
          startYear: 2025,
          profile: ngSoleTrader(vat: true),
          entries: [
            ngEntry('ng.biz.revenue.sales', 10_750_000, salesTaxNaira: 750_000),
            ngEntry('ng.biz.expense.other', 2_150_000, salesTaxNaira: 150_000),
          ],
        ),
      );
      expect(ngLiability(report, 'Value added tax').amountMinor, 60_000_000);
    });
  });

  group('old-regime opportunities', () {
    test('rent relief is not offered for 2025', () {
      final input = ngInput(
        startYear: 2025,
        profile: ngIndividual(),
        entries: [ngEntry('ng.ind.employment.salary', 2_800_000)],
      );
      final opportunities = ngRules.opportunities(input, ngRules.report(input));
      expect(
        opportunities.any((item) => item.id == 'ng.rent_relief'),
        isFalse,
      );
      expect(
        opportunities.any((item) => item.id == 'ng.voluntary_pension'),
        isTrue,
      );
    });

    test('the 2025 small company opportunity names the CITA ceiling', () {
      final input = ngInput(
        startYear: 2025,
        profile: ngCompany(),
        entries: [
          ngEntry('ng.co.revenue.sales', 20_000_000),
          ngEntry('ng.co.expense.other', 2_000_000),
        ],
      );
      final opportunity = ngRules
          .opportunities(input, ngRules.report(input))
          .firstWhere((item) => item.id == 'ng.small_company');
      expect(opportunity.title, 'Small company status');
      expect(opportunity.explanation, contains('N25000000'));
    });
  });
}
