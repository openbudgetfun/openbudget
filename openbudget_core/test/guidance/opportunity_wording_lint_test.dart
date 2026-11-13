import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

/// One fixture per opportunity id, for one tax year.
typedef OpportunityFixture = List<TaxInput> Function(int year);

/// The wording lint of the tax-planning-guardrails skill, run over every
/// opportunity string every pack can produce, for every supported year:
/// titles are neutral noun phrases, explanations carry no advice
/// language, and the guardrail invariants (no saving on a non-primary
/// grade, on an announced rule, or on a signpost-only row) hold.
void main() {
  const years = [2025, 2026];
  final packs = <TaxRulePack>[
    const GbTaxRules(),
    const UsTaxRules(),
    const NgTaxRules(),
    const DeTaxRules(),
  ];
  final builders = <TaxRulePack, Map<String, OpportunityFixture>>{
    const GbTaxRules(): _gbFixtures,
    const UsTaxRules(): _usFixtures,
    const NgTaxRules(): _ngFixtures,
    const DeTaxRules(): _deFixtures,
  };

  List<TaxInput> inputsFor(TaxRulePack pack, String id) => [
    for (final year in years) ...builders[pack]![id]!(year),
  ];

  List<TaxOpportunity> opportunitiesOf(TaxRulePack pack, TaxInput input) =>
      pack.opportunities(input, pack.report(input));

  test('the fixtures cover every opportunity of every pack in every year', () {
    for (final pack in packs) {
      for (final id in builders[pack]!.keys) {
        for (final input in inputsFor(pack, id)) {
          expect(
            opportunitiesOf(
              pack,
              input,
            ).any((opportunity) => opportunity.id == id),
            isTrue,
            reason:
                'no ${pack.jurisdiction.countryCode} fixture produces $id '
                'for ${input.year.startYear}',
          );
        }
      }
    }
  });

  test('every opportunity string passes the wording lint', () {
    for (final pack in packs) {
      for (final id in builders[pack]!.keys) {
        for (final input in inputsFor(pack, id)) {
          for (final opportunity in opportunitiesOf(pack, input)) {
            final issues = findWordingIssues(
              title: opportunity.title,
              explanation: opportunity.explanation,
            );
            expect(
              issues,
              isEmpty,
              reason:
                  '${opportunity.id} '
                  '(${pack.jurisdiction.countryCode} '
                  '${input.year.startYear}): $issues',
            );
          }
        }
      }
    }
  });

  test('every opportunity states its rule year', () {
    for (final pack in packs) {
      for (final id in builders[pack]!.keys) {
        for (final input in inputsFor(pack, id)) {
          for (final opportunity in opportunitiesOf(pack, input)) {
            expect(
              opportunity.ruleYear,
              input.year.label,
              reason:
                  '${opportunity.id} states '
                  '"${opportunity.ruleYear}" for ${input.year.label}',
            );
          }
        }
      }
    }
  });

  test('savings appear only on primary, enacted, computed rows', () {
    for (final pack in packs) {
      for (final id in builders[pack]!.keys) {
        for (final input in inputsFor(pack, id)) {
          for (final opportunity in opportunitiesOf(pack, input)) {
            if (opportunity.estimatedSavingMinor == null) continue;
            expect(
              opportunity.grade,
              TaxEvidenceGrade.primary,
              reason:
                  '${opportunity.id} carries a saving on a '
                  '${opportunity.grade.name} figure',
            );
            expect(opportunity.announced, isFalse);
            expect(opportunity.signpostOnly, isFalse);
          }
        }
      }
    }
  });

  test('opportunities built on secondary figures carry no saving', () {
    // NG-4: the disputed small-company threshold is secondary, so the
    // small-company and development-levy rows quantify nothing.
    final ngCompanyInput = _ngCompany(2026, [
      _ngNaira(2026, 'ng.co.revenue.sales', 10_000_000),
      _ngNaira(2026, 'ng.co.expense.other', 1_000_000),
    ]);
    for (final opportunity in opportunitiesOf(
      const NgTaxRules(),
      ngCompanyInput,
    )) {
      if (opportunity.id == 'ng.small_company' ||
          opportunity.id == 'ng.development_levy') {
        expect(opportunity.grade, TaxEvidenceGrade.secondary);
        expect(opportunity.estimatedSavingMinor, isNull);
      }
    }

    // DE-1 for 2025: the Basisrente cap is inferred that year, so the row
    // carries the grade and no number.
    final de2025 = _deIndividual(
      2025,
      [_deEuros(2025, 'de.ind.arbeitslohn', 100000)],
    );
    final basisrente = opportunitiesOf(const DeTaxRules(), de2025).firstWhere(
      (item) => item.id == 'de.basisrente_hoechstbetrag',
    );
    expect(basisrente.grade, TaxEvidenceGrade.inferred);
    expect(basisrente.estimatedSavingMinor, isNull);
  });

  test('signpost-only rows explain and quantify nothing', () {
    // The one signpost-only topic in the packs today: the German GmbH
    // owner-pay comparison, reserved under StBerG §5.
    final input = _deIndividual(
      2026,
      [_deEuros(2026, 'de.ind.arbeitslohn', 100000)],
      linked: [
        _deCompany(2026, [_deEuros(2026, 'de.co.umsatzerloese', 150000)]),
      ],
    );
    final opportunity = opportunitiesOf(const DeTaxRules(), input).firstWhere(
      (item) => item.id == 'de.geschaeftsfuehrer_vergleich',
    );
    expect(opportunity.signpostOnly, isTrue);
    expect(opportunity.estimatedSavingMinor, isNull);
    final perimeter = guidancePerimeterFor(TaxJurisdiction.de)!;
    expect(
      perimeter.topic('de.gmbh-owner-structures')!.boundary,
      GuidanceBoundary.signpostOnly,
    );
  });
}

// ── Fixtures ───────────────────────────────────────────────────────────

final Map<String, OpportunityFixture> _gbFixtures = {
  'gb.pension_annual_allowance': (year) => [
    _gbIndividual(year, [_gbPounds(year, 'gb.ind.employment', 30000)]),
  ],
  'gb.pension_taper': (year) => [
    _gbIndividual(year, [_gbPounds(year, 'gb.ind.employment', 110000)]),
  ],
  'gb.isa_allowance': (year) => [
    _gbIndividual(year, [
      _gbPounds(year, 'gb.ind.employment', 30000),
      _gbPounds(year, 'gb.ind.savings', 2000),
    ]),
  ],
  'gb.trading_allowance': (year) => [
    _gbIndividual(
      year,
      [_gbPounds(year, 'gb.ind.employment', 30000)],
      linked: [
        _gbSoleTrade(year, [
          _gbPounds(year, 'gb.se.turnover', 30000),
          _gbPounds(year, 'gb.se.cost_of_goods', 400),
        ]),
      ],
    ),
  ],
  'gb.capital_gains_annual_exempt_amount': (year) => [
    _gbIndividual(year, [
      _gbPounds(year, 'gb.ind.employment', 32570),
      TaxEntry(
        date: DateTime.utc(year, 6),
        amountMinor: 100000,
        categoryCode: 'gb.ind.capital_gains_proceeds',
      ),
    ]),
  ],
  'gb.director_salary_vs_dividend': (year) => [
    _gbIndividual(
      year,
      const [],
      linked: [
        _gbCompany(year, [_gbPounds(year, 'gb.co.turnover', 60000)]),
      ],
    ),
  ],
  'gb.self_assessment_deadline': (year) => [
    _gbIndividual(year, [_gbPounds(year, 'gb.ind.employment', 30000)]),
  ],
  'gb.vat_registration_threshold': (year) => [
    _gbSoleTrade(year, [_gbPounds(year, 'gb.se.turnover', 80000)]),
    _gbCompany(year, [_gbPounds(year, 'gb.co.turnover', 80000)]),
  ],
};

final Map<String, OpportunityFixture> _usFixtures = {
  'us.sep_ira_or_solo_401k': (year) => [_usWorkerWithBusiness(year)],
  'us.qbi': (year) => [_usWorkerWithBusiness(year)],
  'us.traditional_ira': (year) => [_usWorkerWithBusiness(year)],
  'us.hsa': (year) => [_usWorkerWithBusiness(year)],
  'us.estimated_tax': (year) => [_usWorkerWithBusiness(year)],
  'us.standard_vs_itemized': (year) => [
    // Both variants: itemized above the standard deduction, and below it.
    _usIndividual(year, [
      _usDollars(year, 'us.ind.wages', 100000),
      _usDollars(year, 'us.ind.itemized_deductions', 40000),
    ]),
    _usIndividual(year, [
      _usDollars(year, 'us.ind.wages', 100000),
      _usDollars(year, 'us.ind.itemized_deductions', 2000),
    ]),
  ],
  'us.tax_loss_harvesting': (year) => [
    _usIndividual(year, [
      _usDollars(year, 'us.ind.wages', 70000),
      _usDollars(year, 'us.ind.long_term_capital_gains', 10000),
    ]),
  ],
  'us.company_estimated_tax': (year) => [
    _usCompany(year, [_usDollars(year, 'us.co.gross_receipts', 100000)]),
  ],
};

TaxInput _usWorkerWithBusiness(int year) => TaxInput(
  profile: const UsTaxProfile(entityKind: EntityKind.individual),
  year: const UsTaxRules().taxYear(year),
  entries: const [],
  linked: [
    TaxInput(
      profile: const UsTaxProfile(entityKind: EntityKind.soleTrader),
      year: const UsTaxRules().taxYear(year),
      entries: [_usDollars(year, 'us.sch_c.gross_receipts', 100000)],
    ),
  ],
);

final Map<String, OpportunityFixture> _ngFixtures = {
  'ng.rent_relief': (year) => year >= 2026
      ? [
          _ngIndividual(year, salaryNaira: 2_800_000, rentNaira: 1_000_000),
          _ngIndividual(year, salaryNaira: 2_800_000),
        ]
      : const <TaxInput>[],
  'ng.voluntary_pension': (year) => [
    _ngIndividual(year, salaryNaira: 2_800_000, pensionNaira: 1_000_000),
    _ngIndividual(year, salaryNaira: 2_800_000),
  ],
  'ng.annual_return': (year) => [_ngIndividual(year, salaryNaira: 1_000_000)],
  'ng.capital_allowance': (year) => [
    _ngSoleTrade(year, [
      _ngNaira(year, 'ng.biz.revenue.sales', 10_000_000),
      _ngNaira(year, 'ng.biz.capital.plant', 2_000_000),
    ]),
  ],
  'ng.small_company': (year) => [
    _ngCompany(year, [
      _ngNaira(year, 'ng.co.revenue.sales', 10_000_000),
      _ngNaira(year, 'ng.co.expense.other', 1_000_000),
    ]),
    _ngCompany(year, [
      _ngNaira(year, 'ng.co.revenue.sales', 60_000_000),
      _ngNaira(year, 'ng.co.expense.other', 10_000_000),
    ]),
  ],
  'ng.development_levy': (year) => [
    _ngCompany(year, [
      _ngNaira(year, 'ng.co.revenue.sales', 10_000_000),
      _ngNaira(year, 'ng.co.expense.other', 1_000_000),
    ]),
  ],
  'ng.vat_registration': (year) => [
    _ngSoleTrade(year, [_ngNaira(year, 'ng.biz.revenue.sales', 10_000_000)]),
    _ngCompany(year, [_ngNaira(year, 'ng.co.revenue.sales', 60_000_000)]),
  ],
  'ng.company_return': (year) => [
    _ngCompany(year, [_ngNaira(year, 'ng.co.revenue.sales', 1_000_000)]),
  ],
};

final Map<String, OpportunityFixture> _deFixtures = {
  'de.frist_steuererklaerung': (year) => [_deEmployee(year)],
  'de.homeoffice_pauschale': (year) => [_deEmployee(year)],
  'de.basisrente_hoechstbetrag': (year) => [_deEmployee(year)],
  'de.sparer_pauschbetrag': (year) => [
    _deIndividual(year, [
      _deEuros(year, 'de.ind.kapitalertraege', 800),
      _deEuros(year, 'de.ind.kapitalertragsteuer', 200),
    ]),
  ],
  'de.guenstigerpruefung': (year) => [
    _deIndividual(year, [
      _deEuros(year, 'de.ind.arbeitslohn', 10000),
      _deEuros(year, 'de.ind.kapitalertraege', 5000),
    ]),
  ],
  'de.geschaeftsfuehrer_vergleich': (year) => [
    _deIndividual(
      year,
      [_deEuros(year, 'de.ind.arbeitslohn', 100000)],
      linked: [
        _deCompany(year, [_deEuros(year, 'de.co.umsatzerloese', 150000)]),
      ],
    ),
  ],
  'de.investitionsabzugsbetrag': (year) => [..._deSoleTrade(year)],
  'de.kleinunternehmerregelung': (year) => [
    ..._deSoleTrade(year),
    _deKleinCompany(year),
  ],
};

TaxInput _deEmployee(int year) => _deIndividual(
  year,
  [_deEuros(year, 'de.ind.arbeitslohn', 60000)],
);

List<TaxInput> _deSoleTrade(int year) => [
  _deSoleTradeInput(year, [
    _deEuros(year, 'de.euer.betriebseinnahmen', 20000),
    _deEuros(year, 'de.ust.ausgang', 3800),
  ]),
];

// ── Entry and input builders ───────────────────────────────────────────

TaxEntry _gbPounds(int year, String code, int pounds) => TaxEntry(
  date: DateTime.utc(year, 6),
  amountMinor: pounds * 100,
  categoryCode: code,
);

TaxInput _gbIndividual(
  int year,
  List<TaxEntry> entries, {
  List<TaxInput> linked = const [],
}) => TaxInput(
  profile: const GbTaxProfile(entityKind: EntityKind.individual),
  year: const GbTaxRules().taxYear(year),
  entries: entries,
  linked: linked,
);

TaxInput _gbSoleTrade(int year, List<TaxEntry> entries) => TaxInput(
  profile: const GbTaxProfile(entityKind: EntityKind.soleTrader),
  year: const GbTaxRules().taxYear(year),
  entries: entries,
);

TaxInput _gbCompany(int year, List<TaxEntry> entries) => TaxInput(
  profile: const GbTaxProfile(entityKind: EntityKind.company),
  year: const GbTaxRules().taxYear(year),
  entries: entries,
);

TaxEntry _usDollars(int year, String code, int dollars) => TaxEntry(
  date: DateTime.utc(year, 6, 15),
  amountMinor: dollars * 100,
  categoryCode: code,
);

TaxInput _usIndividual(
  int year,
  List<TaxEntry> entries, {
  List<TaxInput> linked = const [],
}) => TaxInput(
  profile: const UsTaxProfile(entityKind: EntityKind.individual),
  year: const UsTaxRules().taxYear(year),
  entries: entries,
  linked: linked,
);

TaxInput _usCompany(int year, List<TaxEntry> entries) => TaxInput(
  profile: const UsTaxProfile(entityKind: EntityKind.company),
  year: const UsTaxRules().taxYear(year),
  entries: entries,
);

TaxEntry _ngNaira(int year, String code, int naira) => TaxEntry(
  date: DateTime.utc(year, 6, 15),
  amountMinor: naira * 100,
  categoryCode: code,
);

TaxInput _ngIndividual(
  int year, {
  required int salaryNaira,
  int rentNaira = 0,
  int pensionNaira = 0,
}) => TaxInput(
  profile: NgTaxProfile(
    entityKind: EntityKind.individual,
    annualRentMinor: rentNaira * 100,
  ),
  year: const NgTaxRules().taxYear(year),
  entries: [
    _ngNaira(year, 'ng.ind.employment.salary', salaryNaira),
    if (pensionNaira > 0) _ngNaira(year, 'ng.ind.relief.pension', pensionNaira),
  ],
);

TaxInput _ngSoleTrade(int year, List<TaxEntry> entries) => TaxInput(
  profile: const NgTaxProfile(entityKind: EntityKind.soleTrader),
  year: const NgTaxRules().taxYear(year),
  entries: entries,
);

TaxInput _ngCompany(int year, List<TaxEntry> entries) => TaxInput(
  profile: const NgTaxProfile(entityKind: EntityKind.company),
  year: const NgTaxRules().taxYear(year),
  entries: entries,
);

TaxEntry _deEuros(int year, String code, int euros) => TaxEntry(
  date: DateTime.utc(year, 6, 15),
  amountMinor: euros * 100,
  categoryCode: code,
);

TaxInput _deIndividual(
  int year,
  List<TaxEntry> entries, {
  List<TaxInput> linked = const [],
}) => TaxInput(
  profile: const DeTaxProfile(entityKind: EntityKind.individual),
  year: const DeTaxRules().taxYear(year),
  entries: entries,
  linked: linked,
);

TaxInput _deSoleTradeInput(int year, List<TaxEntry> entries) => TaxInput(
  profile: const DeTaxProfile(
    entityKind: EntityKind.soleTrader,
    salesTaxRegistered: true,
    smallBusinessExemption: false,
  ),
  year: const DeTaxRules().taxYear(year),
  entries: entries,
);

TaxInput _deCompany(int year, List<TaxEntry> entries) => TaxInput(
  profile: const DeTaxProfile(
    entityKind: EntityKind.company,
    salesTaxRegistered: true,
    smallBusinessExemption: false,
  ),
  year: const DeTaxRules().taxYear(year),
  entries: entries,
);

/// A GmbH under the § 19 UStG limits, so the Kleinunternehmerregelung row
/// appears for the company kind too.
TaxInput _deKleinCompany(int year) => _deCompany(
  year,
  [_deEuros(year, 'de.co.umsatzerloese', 20000)],
);
