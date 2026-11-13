import 'package:openbudget_core/openbudget_core.dart';

/// A minimal GB rule pack for tests.
///
/// Reports echo the shape of the input into their lines so tests can assert
/// how the service assembled entries and links.
class FakeTaxPack implements TaxRulePack {
  FakeTaxPack({this.supportedStartYears = const {2025, 2026}});

  static const turnover = TaxCategory(
    code: 'gb.test.turnover',
    label: 'Turnover',
    kind: TaxCategoryKind.income,
    entityKinds: {
      EntityKind.individual,
      EntityKind.soleTrader,
      EntityKind.company,
    },
  );

  static const officeCosts = TaxCategory(
    code: 'gb.test.office_costs',
    label: 'Office costs',
    kind: TaxCategoryKind.expense,
    entityKinds: {
      EntityKind.individual,
      EntityKind.soleTrader,
      EntityKind.company,
    },
  );

  static const employment = TaxCategory(
    code: 'gb.test.employment',
    label: 'Employment',
    kind: TaxCategoryKind.income,
    entityKinds: {EntityKind.individual},
  );

  static const List<TaxCategory> categories = [
    turnover,
    officeCosts,
    employment,
  ];

  static const TaxPackManifest fakeManifest = TaxPackManifest(
    maturity: TaxPackMaturity.preview,
    sections: {
      TaxSection.personalReturn: TaxSectionCoverage.partial,
      TaxSection.selfEmployment: TaxSectionCoverage.partial,
      TaxSection.companyReturn: TaxSectionCoverage.partial,
      TaxSection.indirectTax: TaxSectionCoverage.notBuilt,
      TaxSection.capitalGains: TaxSectionCoverage.notBuilt,
      TaxSection.digitalAssets: TaxSectionCoverage.notBuilt,
      TaxSection.filingCalendar: TaxSectionCoverage.notBuilt,
      TaxSection.payroll: TaxSectionCoverage.notBuilt,
    },
  );

  @override
  TaxJurisdiction get jurisdiction => TaxJurisdiction.gb;

  @override
  TaxPackManifest get manifest => fakeManifest;

  @override
  final Set<int> supportedStartYears;

  @override
  TaxRuleSet ruleSet(int startYear) {
    if (!supportedStartYears.contains(startYear)) {
      throw UnsupportedTaxYearException(jurisdiction, startYear);
    }
    return TaxRuleSet(
      startYear: startYear,
      revision: 1,
      verifiedOn: DateTime.utc(2026, 4, 6),
      sources: [Uri.parse('https://example.test/fake-tax')],
    );
  }

  @override
  TaxYear taxYearFor(DateTime date) => taxYear(date.toUtc().year);

  @override
  TaxYear taxYear(int startYear) {
    if (!supportedStartYears.contains(startYear)) {
      throw UnsupportedTaxYearException(jurisdiction, startYear);
    }
    return TaxYear(
      jurisdiction: jurisdiction,
      startYear: startYear,
      start: DateTime.utc(startYear),
      end: DateTime.utc(startYear + 1),
      label: '$startYear',
    );
  }

  @override
  List<TaxCategory> categoriesFor(EntityKind kind) => [
    for (final category in categories)
      if (category.entityKinds.contains(kind)) category,
  ];

  @override
  TaxCategory? category(String code) {
    for (final category in categories) {
      if (category.code == code) return category;
    }
    return null;
  }

  @override
  String? mapUniversalCategory(String universalCode, EntityKind kind) =>
      switch (universalCode) {
        'universal.income.employment' =>
          kind == EntityKind.individual ? FakeTaxPack.employment.code : null,
        'universal.expense.office' => FakeTaxPack.officeCosts.code,
        _ => null,
      };

  @override
  TaxReport report(TaxInput input) => TaxReport(
    year: input.year,
    entityKind: input.profile.entityKind,
    lines: [
      TaxReportLine(label: 'Entries', amountMinor: input.entries.length),
      TaxReportLine(
        label: 'Linked books',
        amountMinor: input.linked.length,
      ),
      TaxReportLine(
        label: 'Linked entries',
        amountMinor: input.linked.fold(
          0,
          (sum, linked) => sum + linked.entries.length,
        ),
      ),
    ],
    liabilities: const [TaxLiability(label: 'Test tax', amountMinor: 0)],
    alreadyPaidMinor: 0,
    assumptions: const ['Test pack assumption.'],
    sources: [Uri.parse('https://example.test/fake-tax')],
    rulesVerifiedOn: DateTime.utc(2026, 4, 6),
    rulesVersion: ruleSet(input.year.startYear).versionFor(jurisdiction),
    maturity: manifest.maturity,
    coverage: manifest.sections,
    caveats: ruleSet(input.year.startYear).caveatsTouching(
      sections: {TaxSection.personalReturn},
    ),
    uncategorizedCount: input.entries
        .where((entry) => category(entry.categoryCode) == null)
        .length,
  );

  @override
  List<TaxOpportunity> opportunities(TaxInput input, TaxReport report) => [
    TaxOpportunity(
      id: 'gb.test.opportunity',
      title: 'Test opportunity',
      explanation: 'A test-only opportunity.',
      estimatedSavingMinor: 1234,
      deadline: input.year.end,
      source: Uri.parse('https://example.test/fake-tax/opportunity'),
    ),
  ];
}
