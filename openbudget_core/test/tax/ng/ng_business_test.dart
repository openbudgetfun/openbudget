import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

import 'ng_test_helpers.dart';

TaxReport soleTraderReport({
  bool vat = false,
  List<TaxEntry> entries = const [],
}) => ngRules.report(
  ngInput(
    profile: ngSoleTrader(vat: vat),
    entries: entries,
  ),
);

TaxReport companyReport({
  bool vat = false,
  List<TaxEntry> entries = const [],
}) => ngRules.report(
  ngInput(
    profile: ngCompany(vat: vat),
    entries: entries,
  ),
);

void main() {
  group('sole trader', () {
    test(
      'profit is turnover less allowable expenses and capital allowance',
      () {
        final report = soleTraderReport(
          entries: [
            ngEntry('ng.biz.revenue.sales', 10_000_000),
            ngEntry('ng.biz.expense.other', 2_000_000),
            ngEntry('ng.biz.capital.plant', 4_000_000),
          ],
        );
        expect(ngLine(report, 'Assessable profits').amountMinor, 800_000_000);
        expect(
          ngLine(report, 'Total capital allowance').amountMinor,
          80_000_000,
        );
        expect(ngLine(report, 'Profit chargeable').amountMinor, 720_000_000);
        expect(report.liabilities, isEmpty);
        expect(report.alreadyPaidMinor, 0);
        expect(report.entityKind, TaxEntityKind.soleTrader);
      },
    );

    test('business use percent reduces the allowable expense', () {
      final report = soleTraderReport(
        entries: [
          ngEntry('ng.biz.revenue.sales', 2_000_000),
          ngEntry('ng.biz.expense.other', 1_000_000, businessUsePercent: 50),
        ],
      );
      expect(ngLine(report, 'Profit chargeable').amountMinor, 150_000_000);
    });

    test('unused capital allowance is carried forward', () {
      final report = soleTraderReport(
        entries: [
          ngEntry('ng.biz.revenue.sales', 2_000_000),
          ngEntry('ng.biz.capital.other', 10_000_000),
        ],
      );
      expect(ngLine(report, 'Assessable profits').amountMinor, 200_000_000);
      expect(
        ngLine(report, 'Total capital allowance').amountMinor,
        250_000_000,
      );
      expect(
        ngLine(report, 'Unused capital allowance').amountMinor,
        50_000_000,
      );
      expect(ngLine(report, 'Profit chargeable').amountMinor, 0);
    });

    test('registered VAT is output less input', () {
      final report = soleTraderReport(
        vat: true,
        entries: [
          ngEntry('ng.biz.revenue.sales', 10_750_000, salesTaxNaira: 750_000),
          ngEntry('ng.biz.expense.other', 2_150_000, salesTaxNaira: 150_000),
        ],
      );
      expect(ngLine(report, 'Profit chargeable').amountMinor, 800_000_000);
      final vat = ngLiability(report, 'Value added tax');
      expect(vat.amountMinor, 60_000_000);
      expect(vat.bands.map((band) => band.taxMinor), [75_000_000, -15_000_000]);
    });

    test(
      'unregistered VAT is part of the cost and there is no VAT liability',
      () {
        final report = soleTraderReport(
          entries: [
            ngEntry('ng.biz.revenue.sales', 10_750_000, salesTaxNaira: 750_000),
            ngEntry('ng.biz.expense.other', 2_150_000, salesTaxNaira: 150_000),
          ],
        );
        expect(ngLine(report, 'Profit chargeable').amountMinor, 785_000_000);
        expect(report.liabilities, isEmpty);
      },
    );

    test('unregistered input VAT recorded separately is a cost', () {
      final report = soleTraderReport(
        entries: [
          ngEntry('ng.biz.revenue.sales', 10_000_000),
          ngEntry('ng.biz.expense.other', 2_000_000),
          ngEntry('ng.biz.vat.input', 150_000),
        ],
      );
      expect(ngLine(report, 'Profit chargeable').amountMinor, 785_000_000);
    });

    test('an input VAT credit is carried forward, not refunded', () {
      final report = soleTraderReport(
        vat: true,
        entries: [
          ngEntry('ng.biz.revenue.sales', 10_750_000, salesTaxNaira: 750_000),
          ngEntry('ng.biz.expense.other', 21_500_000, salesTaxNaira: 1_500_000),
        ],
      );
      expect(ngLiability(report, 'Value added tax').amountMinor, 0);
      expect(ngLine(report, 'VAT credit').amountMinor, 75_000_000);
    });

    test('capital allowance rates are 10%, 20% and 25% by class', () {
      final report = soleTraderReport(
        entries: [
          ngEntry('ng.biz.revenue.sales', 10_000_000),
          ngEntry('ng.biz.capital.building', 1_000_000),
          ngEntry('ng.biz.capital.plant', 1_000_000),
          ngEntry('ng.biz.capital.motor_vehicle', 1_000_000),
        ],
      );
      expect(ngLine(report, 'Total capital allowance').amountMinor, 55_000_000);
      expect(ngLine(report, 'Profit chargeable').amountMinor, 945_000_000);
    });
  });

  group('company small status', () {
    test('a company with no entries is a small company owing nothing', () {
      final report = companyReport();
      expect(ngLiability(report, 'Companies income tax').amountMinor, 0);
      expect(report.totalLiabilityMinor, 0);
    });

    test('turnover within N50,000,000 pays 0%', () {
      final report = companyReport(
        entries: [
          ngEntry('ng.co.revenue.sales', 10_000_000),
          ngEntry('ng.co.expense.other', 1_000_000),
        ],
      );
      expect(ngLine(report, 'Total profits').amountMinor, 900_000_000);
      final cit = ngLiability(report, 'Companies income tax');
      expect(cit.amountMinor, 0);
      expect(cit.label, contains('small company'));
      expect(report.totalLiabilityMinor, 0);
    });

    test('exactly N50,000,000 still qualifies', () {
      final report = companyReport(
        entries: [
          ngEntry('ng.co.revenue.sales', 50_000_000),
          ngEntry('ng.co.expense.other', 10_000_000),
        ],
      );
      expect(ngLiability(report, 'Companies income tax').amountMinor, 0);
    });

    test('one naira above the ceiling pays 30%', () {
      final report = companyReport(
        entries: [
          ngEntry('ng.co.revenue.sales', 50_000_001),
          ngEntry('ng.co.expense.other', 10_000_000),
        ],
      );
      expect(
        ngLiability(report, 'Companies income tax').amountMinor,
        1_200_000_030,
      );
    });

    test('turnover between the two statutory ceilings flags the conflict', () {
      bool flagsConflict(int turnoverNaira) => companyReport(
        entries: [ngEntry('ng.co.revenue.sales', turnoverNaira)],
      ).assumptions.any((text) => text.contains('section 147'));

      expect(flagsConflict(50_000_000), isFalse);
      expect(flagsConflict(80_000_000), isTrue);
      expect(flagsConflict(100_000_000), isTrue);
      expect(flagsConflict(100_000_001), isFalse);
    });

    test('professional services are never a small company', () {
      final report = companyReport(
        entries: [
          ngEntry('ng.co.revenue.professional_services', 10_000_000),
          ngEntry('ng.co.expense.other', 1_000_000),
        ],
      );
      expect(
        ngLiability(report, 'Companies income tax').amountMinor,
        270_000_000,
      );
      expect(ngLiability(report, 'Development levy').amountMinor, 36_000_000);
    });

    test('capital additions above N250,000,000 break small status', () {
      final report = companyReport(
        entries: [
          ngEntry('ng.co.revenue.sales', 10_000_000),
          ngEntry('ng.co.expense.other', 1_000_000),
          ngEntry('ng.co.capital.building', 300_000_000),
        ],
      );
      expect(ngLiability(report, 'Development levy').amountMinor, 36_000_000);
      expect(
        ngLine(report, 'Unused capital allowance').amountMinor,
        2_100_000_000,
      );
      expect(ngLine(report, 'Total profits').amountMinor, 0);
    });
  });

  group('company tax and levy', () {
    test('30% companies income tax and 4% development levy', () {
      final report = companyReport(
        entries: [
          ngEntry('ng.co.revenue.sales', 60_000_000),
          ngEntry('ng.co.expense.other', 10_000_000),
        ],
      );
      expect(
        ngLiability(report, 'Companies income tax').amountMinor,
        1_500_000_000,
      );
      expect(ngLiability(report, 'Development levy').amountMinor, 200_000_000);
      expect(report.totalLiabilityMinor, 1_700_000_000);
    });

    test('chargeable gains join total profits', () {
      final report = companyReport(
        entries: [
          ngEntry('ng.co.revenue.sales', 60_000_000),
          ngEntry('ng.co.expense.other', 10_000_000),
          ngEntry('ng.co.gain.proceeds', 5_000_000),
          ngEntry('ng.co.gain.cost', 3_000_000),
        ],
      );
      expect(ngLine(report, 'Chargeable gains').amountMinor, 200_000_000);
      expect(ngLine(report, 'Total profits').amountMinor, 5_200_000_000);
      expect(
        ngLiability(report, 'Companies income tax').amountMinor,
        1_560_000_000,
      );
    });

    test('a capital loss does not reduce total profits', () {
      final report = companyReport(
        entries: [
          ngEntry('ng.co.revenue.sales', 60_000_000),
          ngEntry('ng.co.expense.other', 10_000_000),
          ngEntry('ng.co.gain.proceeds', 1_000_000),
          ngEntry('ng.co.gain.cost', 3_000_000),
        ],
      );
      expect(ngLine(report, 'Capital loss').amountMinor, 200_000_000);
      expect(ngLine(report, 'Total profits').amountMinor, 5_000_000_000);
      expect(
        ngLiability(report, 'Companies income tax').amountMinor,
        1_500_000_000,
      );
    });

    test('tax paid at source reduces the balance due', () {
      final report = companyReport(
        entries: [
          ngEntry('ng.co.revenue.sales', 60_000_000),
          ngEntry('ng.co.expense.other', 10_000_000),
          ngEntry('ng.co.tax.wht', 1_000_000),
        ],
      );
      expect(report.alreadyPaidMinor, 100_000_000);
      expect(report.balanceDueMinor, 1_600_000_000);
    });

    test('registered VAT is a separate net liability', () {
      final report = companyReport(
        vat: true,
        entries: [
          ngEntry('ng.co.revenue.sales', 10_750_000, salesTaxNaira: 750_000),
          ngEntry('ng.co.expense.other', 1_075_000, salesTaxNaira: 75_000),
        ],
      );
      expect(ngLiability(report, 'Companies income tax').amountMinor, 0);
      expect(ngLiability(report, 'Value added tax').amountMinor, 67_500_000);
      expect(report.totalLiabilityMinor, 67_500_000);
    });
  });

  group('company categorization', () {
    test('a sole trade code is counted as uncategorized', () {
      final report = companyReport(
        entries: [
          ngEntry('ng.co.revenue.sales', 1_000_000),
          ngEntry('ng.biz.revenue.sales', 2_000_000),
        ],
      );
      expect(report.uncategorizedCount, 1);
      expect(ngLine(report, 'Total profits').amountMinor, 100_000_000);
    });
  });
}
