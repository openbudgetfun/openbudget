import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

import 'ng_test_helpers.dart';

void main() {
  group('taxYear', () {
    test('is the calendar year', () {
      final year = ngRules.taxYear(2026);
      expect(year.label, '2026');
      expect(year.start, DateTime.utc(2026));
      expect(year.end, DateTime.utc(2027));
      expect(year.jurisdiction, TaxJurisdiction.ng);
    });

    test('taxYearFor uses the calendar date on both sides of new year', () {
      expect(ngRules.taxYearFor(DateTime.utc(2026, 12, 31)).startYear, 2026);
      expect(ngRules.taxYearFor(DateTime.utc(2027)).startYear, 2027);
      expect(
        ngRules.taxYearFor(DateTime(2025, 12, 31, 23, 59)).startYear,
        2025,
      );
      expect(ngRules.taxYearFor(DateTime(2026)).startYear, 2026);
    });

    test('supports 2026 only', () {
      expect(ngRules.supportedStartYears, {2026});
    });
  });

  group('registration', () {
    test('TaxRules resolves the Nigeria pack', () {
      expect(TaxRules.forJurisdiction(TaxJurisdiction.ng), isA<NgTaxRules>());
      expect(TaxRules.forJurisdiction(TaxJurisdiction.gb), isNull);
    });
  });

  group('category catalog', () {
    final individual = ngRules.categoriesFor(TaxEntityKind.individual);
    final soleTrader = ngRules.categoriesFor(TaxEntityKind.soleTrader);
    final company = ngRules.categoriesFor(TaxEntityKind.company);
    final all = [...individual, ...soleTrader, ...company];

    test('uses the entity prefix', () {
      expect(individual.every((c) => c.code.startsWith('ng.ind.')), isTrue);
      expect(soleTrader.every((c) => c.code.startsWith('ng.biz.')), isTrue);
      expect(company.every((c) => c.code.startsWith('ng.co.')), isTrue);
    });

    test('has unique codes and a lookup for every category', () {
      expect(all.map((c) => c.code).toSet(), hasLength(all.length));
      for (final category in all) {
        expect(ngRules.category(category.code), same(category));
      }
      expect(ngRules.category('ng.unknown'), isNull);
    });

    test('covers every category kind', () {
      expect(
        all.map((c) => c.kind).toSet(),
        containsAll(TaxCategoryKind.values),
      );
      expect(all.every((c) => c.entityKinds.isNotEmpty), isTrue);
    });

    test('marks professional services so small company status is testable', () {
      expect(
        ngRules.category('ng.co.revenue.professional_services'),
        isNotNull,
      );
      expect(
        ngRules.category('ng.biz.revenue.professional_services'),
        isNotNull,
      );
    });
  });

  group('errors', () {
    test('an unsupported year throws UnsupportedTaxYearException', () {
      final input = ngInput(
        profile: ngIndividual(),
        entries: const [],
        startYear: 2025,
      );
      expect(
        () => ngRules.report(input),
        throwsA(
          isA<UnsupportedTaxYearException>()
              .having((error) => error.startYear, 'startYear', 2025)
              .having(
                (error) => error.jurisdiction,
                'jurisdiction',
                TaxJurisdiction.ng,
              ),
        ),
      );
    });

    test('a non-Nigerian tax year is rejected', () {
      final year = TaxYear(
        jurisdiction: TaxJurisdiction.gb,
        startYear: 2026,
        start: DateTime.utc(2026),
        end: DateTime.utc(2027),
        label: '2026/27',
      );
      expect(
        () => ngRules.report(
          TaxInput(profile: ngIndividual(), year: year, entries: const []),
        ),
        throwsArgumentError,
      );
    });

    test('a non-Nigerian profile is rejected', () {
      expect(
        () => ngRules.report(
          TaxInput(
            profile: const GbTaxProfile(entityKind: TaxEntityKind.individual),
            year: ngRules.taxYear(2026),
            entries: const [],
          ),
        ),
        throwsArgumentError,
      );
    });
  });

  group('report metadata', () {
    test('carries the sources, verification date and assumptions', () {
      final report = ngRules.report(
        ngInput(
          profile: ngIndividual(),
          entries: [ngEntry('ng.ind.employment.salary', 1_000_000)],
        ),
      );
      expect(report.currencyCode, 'NGN');
      expect(report.year.label, '2026');
      expect(report.sources, isNotEmpty);
      expect(report.sources.every((uri) => uri.scheme == 'https'), isTrue);
      expect(report.rulesVerifiedOn, DateTime.utc(2026, 11, 4));
      expect(report.assumptions, isNotEmpty);
      expect(
        report.assumptions.any((assumption) => assumption.contains('Resident')),
        isTrue,
      );
    });
  });

  group('opportunities', () {
    test('rent relief shows the tax it saves', () {
      final input = ngInput(
        profile: ngIndividual(annualRentNaira: 1_000_000),
        entries: [ngEntry('ng.ind.employment.salary', 2_800_000)],
      );
      final opportunity = ngRules
          .opportunities(input, ngRules.report(input))
          .firstWhere((item) => item.id == 'ng.rent_relief');
      expect(opportunity.estimatedSavingMinor, 3_000_000);
      expect(opportunity.source.scheme, 'https');
    });

    test('rent relief without rent has no estimate', () {
      final input = ngInput(
        profile: ngIndividual(),
        entries: [ngEntry('ng.ind.employment.salary', 2_800_000)],
      );
      final opportunity = ngRules
          .opportunities(input, ngRules.report(input))
          .firstWhere((item) => item.id == 'ng.rent_relief');
      expect(opportunity.estimatedSavingMinor, isNull);
    });

    test('pension contributions show the tax they save', () {
      final input = ngInput(
        profile: ngIndividual(),
        entries: [
          ngEntry('ng.ind.employment.salary', 2_800_000),
          ngEntry('ng.ind.relief.pension', 1_000_000),
        ],
      );
      final opportunity = ngRules
          .opportunities(input, ngRules.report(input))
          .firstWhere((item) => item.id == 'ng.voluntary_pension');
      expect(opportunity.estimatedSavingMinor, 15_000_000);
    });

    test('individual filing is flagged without a federal date', () {
      final input = ngInput(
        profile: ngIndividual(),
        entries: [ngEntry('ng.ind.employment.salary', 1_000_000)],
      );
      final opportunity = ngRules
          .opportunities(input, ngRules.report(input))
          .firstWhere((item) => item.id == 'ng.annual_return');
      expect(opportunity.deadline, isNull);
      expect(opportunity.source.scheme, 'https');
    });

    test('small company status and levy exemption are quantified', () {
      final input = ngInput(
        profile: ngCompany(),
        entries: [
          ngEntry('ng.co.revenue.sales', 10_000_000),
          ngEntry('ng.co.expense.other', 1_000_000),
        ],
      );
      final report = ngRules.report(input);
      final opportunities = ngRules.opportunities(input, report);
      final small = opportunities.firstWhere(
        (item) => item.id == 'ng.small_company',
      );
      expect(small.estimatedSavingMinor, 270_000_000);
      final levy = opportunities.firstWhere(
        (item) => item.id == 'ng.development_levy',
      );
      expect(levy.estimatedSavingMinor, 36_000_000);
    });

    test('a company above the threshold has no small company estimate', () {
      final input = ngInput(
        profile: ngCompany(),
        entries: [
          ngEntry('ng.co.revenue.sales', 60_000_000),
          ngEntry('ng.co.expense.other', 10_000_000),
        ],
      );
      final opportunity = ngRules
          .opportunities(input, ngRules.report(input))
          .firstWhere((item) => item.id == 'ng.small_company');
      expect(opportunity.estimatedSavingMinor, isNull);
      expect(opportunity.title, contains('not available'));
    });

    test('company return is due six months after a December year end', () {
      final input = ngInput(
        profile: ngCompany(),
        entries: [ngEntry('ng.co.revenue.sales', 1_000_000)],
      );
      final opportunity = ngRules
          .opportunities(input, ngRules.report(input))
          .firstWhere((item) => item.id == 'ng.company_return');
      expect(opportunity.deadline, DateTime.utc(2027, 6, 30));
    });

    test('VAT threshold guidance follows turnover and registration', () {
      final small = ngInput(
        profile: ngSoleTrader(),
        entries: [ngEntry('ng.biz.revenue.sales', 10_000_000)],
      );
      final smallOpportunity = ngRules
          .opportunities(small, ngRules.report(small))
          .firstWhere((item) => item.id == 'ng.vat_registration');
      expect(smallOpportunity.title, contains('exemption'));

      final large = ngInput(
        profile: ngSoleTrader(),
        entries: [ngEntry('ng.biz.revenue.sales', 120_000_000)],
      );
      final largeOpportunity = ngRules
          .opportunities(large, ngRules.report(large))
          .firstWhere((item) => item.id == 'ng.vat_registration');
      expect(largeOpportunity.title, 'Register for VAT');
    });

    test('the VAT small business threshold is N100,000,000', () {
      final at = ngInput(
        profile: ngSoleTrader(),
        entries: [ngEntry('ng.biz.revenue.sales', 100_000_000)],
      );
      expect(
        ngRules
            .opportunities(at, ngRules.report(at))
            .firstWhere((item) => item.id == 'ng.vat_registration')
            .title,
        contains('exemption'),
      );

      final above = ngInput(
        profile: ngSoleTrader(),
        entries: [ngEntry('ng.biz.revenue.sales', 100_000_001)],
      );
      expect(
        ngRules
            .opportunities(above, ngRules.report(above))
            .firstWhere((item) => item.id == 'ng.vat_registration')
            .title,
        'Register for VAT',
      );
    });

    test('professional services break the small business VAT exemption', () {
      final input = ngInput(
        profile: ngSoleTrader(),
        entries: [ngEntry('ng.biz.revenue.professional_services', 10_000_000)],
      );
      final opportunity = ngRules
          .opportunities(input, ngRules.report(input))
          .firstWhere((item) => item.id == 'ng.vat_registration');
      expect(opportunity.title, 'Register for VAT');
    });
  });
}
