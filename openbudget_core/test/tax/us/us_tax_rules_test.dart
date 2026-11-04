import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

const rules = UsTaxRules();

TaxEntry entryMinor(
  int year,
  String code,
  int amountMinor, {
  int salesTaxMinor = 0,
  int businessUsePercent = 100,
}) => TaxEntry(
  date: DateTime.utc(year, 6, 15),
  amountMinor: amountMinor,
  categoryCode: code,
  salesTaxMinor: salesTaxMinor,
  businessUsePercent: businessUsePercent,
);

TaxEntry entryDollars(int year, String code, int dollars) =>
    entryMinor(year, code, dollars * 100);

TaxInput individualInput({
  UsFilingStatus status = UsFilingStatus.single,
  int year = 2026,
  List<TaxEntry> entries = const [],
  List<TaxInput> linked = const [],
}) => TaxInput(
  profile: UsTaxProfile(
    entityKind: TaxEntityKind.individual,
    filingStatus: status,
  ),
  year: rules.taxYear(year),
  entries: entries,
  linked: linked,
);

TaxInput soleTraderInput({
  int year = 2026,
  List<TaxEntry> entries = const [],
}) => TaxInput(
  profile: const UsTaxProfile(entityKind: TaxEntityKind.soleTrader),
  year: rules.taxYear(year),
  entries: entries,
);

TaxInput companyInput({int year = 2026, List<TaxEntry> entries = const []}) =>
    TaxInput(
      profile: const UsTaxProfile(entityKind: TaxEntityKind.company),
      year: rules.taxYear(year),
      entries: entries,
    );

TaxInput businessInput({
  int year = 2026,
  int grossReceiptsDollars = 0,
  List<TaxEntry> entries = const [],
}) => soleTraderInput(
  year: year,
  entries: [
    if (grossReceiptsDollars != 0)
      entryDollars(year, 'us.sch_c.gross_receipts', grossReceiptsDollars),
    ...entries,
  ],
);

TaxReportLine lineWithCode(TaxReport report, String code) =>
    report.lines.firstWhere((line) => line.code == code);

TaxReportLine lineNamed(TaxReport report, String label) =>
    report.lines.firstWhere((line) => line.label == label);

TaxLiability liabilityWithLabel(TaxReport report, String label) =>
    report.liabilities.firstWhere((liability) => liability.label == label);

bool hasLineNamed(TaxReport report, String label) =>
    report.lines.any((line) => line.label == label);

void main() {
  group('TaxRules registry', () {
    test('returns the US pack for the US jurisdiction', () {
      final pack = TaxRules.forJurisdiction(TaxJurisdiction.us);
      expect(pack, isA<UsTaxRules>());
      expect(pack!.jurisdiction, TaxJurisdiction.us);
    });
  });

  group('tax years', () {
    test('uses calendar years labelled with the start year', () {
      final year = rules.taxYear(2026);
      expect(year.jurisdiction, TaxJurisdiction.us);
      expect(year.startYear, 2026);
      expect(year.start, DateTime.utc(2026));
      expect(year.end, DateTime.utc(2027));
      expect(year.label, '2026');
      expect(year.contains(DateTime.utc(2026, 12, 31, 23, 59)), isTrue);
      expect(year.contains(DateTime.utc(2027)), isFalse);
    });

    test('taxYearFor respects December 31 and January 1', () {
      expect(
        rules.taxYearFor(DateTime.utc(2025, 12, 31, 23, 59)).startYear,
        2025,
      );
      expect(rules.taxYearFor(DateTime.utc(2026)).startYear, 2026);
      expect(rules.taxYearFor(DateTime(2026)).label, '2026');
    });

    test('supports 2025 and 2026 only', () {
      expect(rules.supportedStartYears, equals({2025, 2026}));
    });

    test('throws UnsupportedTaxYearException for an unknown year', () {
      final input = individualInput(
        year: 2024,
        entries: [entryDollars(2024, 'us.ind.wages', 1000)],
      );
      expect(
        () => rules.report(input),
        throwsA(
          isA<UnsupportedTaxYearException>()
              .having(
                (error) => error.jurisdiction,
                'jurisdiction',
                TaxJurisdiction.us,
              )
              .having((error) => error.startYear, 'startYear', 2024),
        ),
      );
    });

    test('rejects a profile from another jurisdiction', () {
      final input = TaxInput(
        profile: const GbTaxProfile(entityKind: TaxEntityKind.individual),
        year: rules.taxYear(2026),
        entries: const [],
      );
      expect(() => rules.report(input), throwsArgumentError);
    });

    test('rejects a tax year from another jurisdiction', () {
      final input = TaxInput(
        profile: const UsTaxProfile(entityKind: TaxEntityKind.individual),
        year: TaxYear(
          jurisdiction: TaxJurisdiction.gb,
          startYear: 2026,
          start: DateTime.utc(2026, 4, 6),
          end: DateTime.utc(2027, 4, 6),
          label: '2026/27',
        ),
        entries: const [],
      );
      expect(() => rules.report(input), throwsArgumentError);
    });
  });

  group('category catalog', () {
    final individualCategories = rules.categoriesFor(TaxEntityKind.individual);
    final soleTraderCategories = rules.categoriesFor(TaxEntityKind.soleTrader);
    final companyCategories = rules.categoriesFor(TaxEntityKind.company);
    final allCategories = [
      ...individualCategories,
      ...soleTraderCategories,
      ...companyCategories,
    ];

    test('codes are unique and prefixed with us.', () {
      final codes = allCategories.map((category) => category.code).toList();
      expect(codes.toSet(), hasLength(codes.length));
      expect(codes.every((code) => code.startsWith('us.')), isTrue);
    });

    test('every category is returned for a kind it supports', () {
      for (final category in individualCategories) {
        expect(category.entityKinds, contains(TaxEntityKind.individual));
      }
      for (final category in soleTraderCategories) {
        expect(category.entityKinds, contains(TaxEntityKind.soleTrader));
      }
      for (final category in companyCategories) {
        expect(category.entityKinds, contains(TaxEntityKind.company));
      }
    });

    test('category lookup finds every code', () {
      for (final category in allCategories) {
        expect(rules.category(category.code), category);
      }
      expect(rules.category('us.nope'), isNull);
    });

    test('individual and business catalogs do not mix', () {
      expect(
        individualCategories.any(
          (category) => category.code == 'us.sch_c.gross_receipts',
        ),
        isFalse,
      );
      expect(
        soleTraderCategories.any((category) => category.code == 'us.ind.wages'),
        isFalse,
      );
      expect(
        companyCategories.any(
          (category) => category.code == 'us.sch_c.gross_receipts',
        ),
        isFalse,
      );
    });

    test('spot-checks IRS line references and labels', () {
      expect(
        rules.category('us.sch_c.home_office')!.reportReference,
        'Schedule C (Form 1040), line 30',
      );
      expect(
        rules.category('us.sch_c.meals')!.reportReference,
        'Schedule C (Form 1040), line 24b',
      );
      expect(
        rules.category('us.co.gross_receipts')!.reportReference,
        'Form 1120, line 1a',
      );
      expect(
        rules.category('us.ind.qualified_dividends')!.reportReference,
        'Form 1040, line 3a',
      );
      expect(
        rules.category('us.co.estimated_tax_payments')!.kind,
        TaxCategoryKind.taxPaid,
      );
    });
  });

  group('2025 worked examples from the Form 1040 tax table', () {
    // 2025 Form 1040 instructions, tax table row $50,000-$50,050:
    // https://www.irs.gov/pub/irs-pdf/i1040gi.pdf
    // The table rounds to whole dollars; the pack keeps cents.
    final cases = <(UsFilingStatus, int, int)>[
      (UsFilingStatus.single, 6577500, 591950),
      (UsFilingStatus.marriedFilingJointly, 8152500, 552600),
      (UsFilingStatus.marriedFilingSeparately, 6577500, 591950),
      (UsFilingStatus.headOfHousehold, 7365000, 566300),
    ];
    for (final (status, wagesMinor, expectedTax) in cases) {
      test('${status.name} at '
          r'$50,025 taxable income', () {
        final report = rules.report(
          individualInput(
            status: status,
            year: 2025,
            entries: [entryMinor(2025, 'us.ind.wages', wagesMinor)],
          ),
        );
        expect(lineNamed(report, 'Taxable income').amountMinor, 5002500);
        expect(
          lineNamed(report, 'Federal income tax').amountMinor,
          expectedTax,
        );
      });
    }
  });

  group('bracket boundaries', () {
    final cases = <(UsFilingStatus, int, int, int, int)>[
      (UsFilingStatus.single, 2025, 1192500, 1575000, 119250),
      (UsFilingStatus.marriedFilingJointly, 2025, 2385000, 3150000, 238500),
      (UsFilingStatus.marriedFilingSeparately, 2025, 1192500, 1575000, 119250),
      (UsFilingStatus.headOfHousehold, 2025, 1700000, 2362500, 170000),
      (UsFilingStatus.single, 2026, 1240000, 1610000, 124000),
      (UsFilingStatus.marriedFilingJointly, 2026, 2480000, 3220000, 248000),
      (UsFilingStatus.marriedFilingSeparately, 2026, 1240000, 1610000, 124000),
      (UsFilingStatus.headOfHousehold, 2026, 1770000, 2415000, 177000),
    ];
    for (final (status, year, taxable, standard, expectedTax) in cases) {
      test('${status.name} $year top of the 10% band', () {
        final report = rules.report(
          individualInput(
            status: status,
            year: year,
            entries: [entryMinor(year, 'us.ind.wages', taxable + standard)],
          ),
        );
        expect(lineNamed(report, 'Standard deduction').amountMinor, standard);
        expect(lineNamed(report, 'Taxable income').amountMinor, taxable);
        expect(
          lineNamed(report, 'Federal income tax').amountMinor,
          expectedTax,
        );
      });
    }

    test('2026 single continues through the 12% and 22% bands', () {
      final at12 = rules.report(
        individualInput(entries: [entryMinor(2026, 'us.ind.wages', 6650000)]),
      );
      expect(lineNamed(at12, 'Taxable income').amountMinor, 5040000);
      expect(lineNamed(at12, 'Federal income tax').amountMinor, 580000);

      final at22 = rules.report(
        individualInput(entries: [entryMinor(2026, 'us.ind.wages', 12180000)]),
      );
      expect(lineNamed(at22, 'Taxable income').amountMinor, 10570000);
      expect(lineNamed(at22, 'Federal income tax').amountMinor, 1796600);
    });
  });

  group('all ordinary rate-band ceilings', () {
    final cases = <(UsFilingStatus, int, int, int, int)>[
      // 2025 Rev. Proc. 2024-40 rate tables and amended standard deduction.
      (UsFilingStatus.single, 2025, 1192500, 1575000, 119250),
      (UsFilingStatus.single, 2025, 4847500, 1575000, 557850),
      (UsFilingStatus.single, 2025, 10335000, 1575000, 1765100),
      (UsFilingStatus.single, 2025, 19730000, 1575000, 4019900),
      (UsFilingStatus.single, 2025, 25052500, 1575000, 5723100),
      (UsFilingStatus.single, 2025, 62635000, 1575000, 18876975),
      (UsFilingStatus.marriedFilingJointly, 2025, 2385000, 3150000, 238500),
      (UsFilingStatus.marriedFilingJointly, 2025, 9695000, 3150000, 1115700),
      (UsFilingStatus.marriedFilingJointly, 2025, 20670000, 3150000, 3530200),
      (UsFilingStatus.marriedFilingJointly, 2025, 39460000, 3150000, 8039800),
      (UsFilingStatus.marriedFilingJointly, 2025, 50105000, 3150000, 11446200),
      (UsFilingStatus.marriedFilingJointly, 2025, 75160000, 3150000, 20215450),
      (UsFilingStatus.marriedFilingSeparately, 2025, 1192500, 1575000, 119250),
      (UsFilingStatus.marriedFilingSeparately, 2025, 4847500, 1575000, 557850),
      (
        UsFilingStatus.marriedFilingSeparately,
        2025,
        10335000,
        1575000,
        1765100,
      ),
      (
        UsFilingStatus.marriedFilingSeparately,
        2025,
        19730000,
        1575000,
        4019900,
      ),
      (
        UsFilingStatus.marriedFilingSeparately,
        2025,
        25052500,
        1575000,
        5723100,
      ),
      (
        UsFilingStatus.marriedFilingSeparately,
        2025,
        37580000,
        1575000,
        10107725,
      ),
      (UsFilingStatus.headOfHousehold, 2025, 1700000, 2362500, 170000),
      (UsFilingStatus.headOfHousehold, 2025, 6485000, 2362500, 744200),
      (UsFilingStatus.headOfHousehold, 2025, 10335000, 2362500, 1591200),
      (UsFilingStatus.headOfHousehold, 2025, 19730000, 2362500, 3846000),
      (UsFilingStatus.headOfHousehold, 2025, 25050000, 2362500, 5548400),
      (UsFilingStatus.headOfHousehold, 2025, 62635000, 2362500, 18703150),
      // 2026 Rev. Proc. 2025-32 rate tables.
      (UsFilingStatus.single, 2026, 1240000, 1610000, 124000),
      (UsFilingStatus.single, 2026, 5040000, 1610000, 580000),
      (UsFilingStatus.single, 2026, 10570000, 1610000, 1796600),
      (UsFilingStatus.single, 2026, 20177500, 1610000, 4102400),
      (UsFilingStatus.single, 2026, 25622500, 1610000, 5844800),
      (UsFilingStatus.single, 2026, 64060000, 1610000, 19297925),
      (UsFilingStatus.marriedFilingJointly, 2026, 2480000, 3220000, 248000),
      (UsFilingStatus.marriedFilingJointly, 2026, 10080000, 3220000, 1160000),
      (UsFilingStatus.marriedFilingJointly, 2026, 21140000, 3220000, 3593200),
      (UsFilingStatus.marriedFilingJointly, 2026, 40355000, 3220000, 8204800),
      (UsFilingStatus.marriedFilingJointly, 2026, 51245000, 3220000, 11689600),
      (UsFilingStatus.marriedFilingJointly, 2026, 76870000, 3220000, 20658350),
      (UsFilingStatus.marriedFilingSeparately, 2026, 1240000, 1610000, 124000),
      (UsFilingStatus.marriedFilingSeparately, 2026, 5040000, 1610000, 580000),
      (
        UsFilingStatus.marriedFilingSeparately,
        2026,
        10570000,
        1610000,
        1796600,
      ),
      (
        UsFilingStatus.marriedFilingSeparately,
        2026,
        20177500,
        1610000,
        4102400,
      ),
      (
        UsFilingStatus.marriedFilingSeparately,
        2026,
        25622500,
        1610000,
        5844800,
      ),
      (
        UsFilingStatus.marriedFilingSeparately,
        2026,
        38435000,
        1610000,
        10329175,
      ),
      (UsFilingStatus.headOfHousehold, 2026, 1770000, 2415000, 177000),
      (UsFilingStatus.headOfHousehold, 2026, 6745000, 2415000, 774000),
      (UsFilingStatus.headOfHousehold, 2026, 10570000, 2415000, 1615500),
      (UsFilingStatus.headOfHousehold, 2026, 20175000, 2415000, 3920700),
      (UsFilingStatus.headOfHousehold, 2026, 25620000, 2415000, 5663100),
      (UsFilingStatus.headOfHousehold, 2026, 64060000, 2415000, 19117100),
    ];
    for (final (status, year, taxable, standard, expectedTax) in cases) {
      test('${status.name} $year at ${taxable ~/ 100}', () {
        final report = rules.report(
          individualInput(
            status: status,
            year: year,
            entries: [entryMinor(year, 'us.ind.wages', taxable + standard)],
          ),
        );
        expect(lineNamed(report, 'Taxable income').amountMinor, taxable);
        expect(
          lineNamed(report, 'Federal income tax').amountMinor,
          expectedTax,
        );
      });
    }
  });

  group('long-term capital gains and qualified dividends', () {
    test('2026 single crosses the 0% to 15% threshold', () {
      final report = rules.report(
        individualInput(
          entries: [
            entryMinor(2026, 'us.ind.wages', 5610000),
            entryMinor(2026, 'us.ind.long_term_capital_gains', 2000000),
          ],
        ),
      );
      expect(lineNamed(report, 'Taxable income').amountMinor, 6000000);
      expect(
        liabilityWithLabel(report, 'Income tax (ordinary rates)').amountMinor,
        455200,
      );
      final capitalGains = liabilityWithLabel(
        report,
        'Income tax (capital gains and qualified dividends)',
      );
      expect(capitalGains.amountMinor, 158250);
      expect(capitalGains.bands.map((band) => band.label), ['0%', '15%']);
      expect(capitalGains.bands.map((band) => band.baseMinor), [
        945000,
        1055000,
      ]);
    });

    test('2026 single crosses the 15% to 20% threshold', () {
      final report = rules.report(
        individualInput(
          entries: [
            entryMinor(2026, 'us.ind.wages', 11610000),
            entryMinor(2026, 'us.ind.long_term_capital_gains', 50000000),
          ],
        ),
      );
      final capitalGains = liabilityWithLabel(
        report,
        'Income tax (capital gains and qualified dividends)',
      );
      expect(capitalGains.amountMinor, 7772500);
      expect(capitalGains.bands.map((band) => band.label), ['15%', '20%']);
    });

    test(r'2025 single starts the 15% band at $48,350', () {
      final report = rules.report(
        individualInput(
          year: 2025,
          entries: [
            entryMinor(2025, 'us.ind.wages', 6410000),
            entryMinor(2025, 'us.ind.long_term_capital_gains', 100000),
          ],
        ),
      );
      final capitalGains = liabilityWithLabel(
        report,
        'Income tax (capital gains and qualified dividends)',
      );
      expect(capitalGains.amountMinor, 15000);
    });

    test(r'2025 married filing jointly starts the 15% band at $96,700', () {
      final report = rules.report(
        individualInput(
          status: UsFilingStatus.marriedFilingJointly,
          year: 2025,
          entries: [
            entryMinor(2025, 'us.ind.wages', 12820000),
            entryMinor(2025, 'us.ind.long_term_capital_gains', 100000),
          ],
        ),
      );
      final capitalGains = liabilityWithLabel(
        report,
        'Income tax (capital gains and qualified dividends)',
      );
      expect(capitalGains.amountMinor, 15000);
    });

    test('qualified dividends use the same preferential bands', () {
      final report = rules.report(
        individualInput(
          entries: [
            entryMinor(2026, 'us.ind.wages', 5610000),
            entryMinor(2026, 'us.ind.qualified_dividends', 2000000),
          ],
        ),
      );
      final capitalGains = liabilityWithLabel(
        report,
        'Income tax (capital gains and qualified dividends)',
      );
      expect(capitalGains.amountMinor, 158250);
    });
  });

  group('net investment income tax', () {
    test('3.8% on the lesser of investment income and excess MAGI', () {
      final report = rules.report(
        individualInput(
          entries: [
            entryMinor(2026, 'us.ind.wages', 25000000),
            entryMinor(2026, 'us.ind.taxable_interest', 5000000),
          ],
        ),
      );
      expect(
        lineNamed(report, 'Net investment income tax').amountMinor,
        190000,
      );
    });

    test('tax-exempt interest raises MAGI but is not investment income', () {
      final report = rules.report(
        individualInput(
          entries: [
            entryMinor(2026, 'us.ind.wages', 19000000),
            entryMinor(2026, 'us.ind.tax_exempt_interest', 2000000),
            entryMinor(2026, 'us.ind.taxable_interest', 1000000),
          ],
        ),
      );
      expect(lineNamed(report, 'Net investment income tax').amountMinor, 38000);
    });

    test(r'married filing jointly uses the $250,000 threshold', () {
      final report = rules.report(
        individualInput(
          status: UsFilingStatus.marriedFilingJointly,
          entries: [
            entryMinor(2026, 'us.ind.wages', 30000000),
            entryMinor(2026, 'us.ind.taxable_interest', 10000000),
          ],
        ),
      );
      expect(
        lineNamed(report, 'Net investment income tax').amountMinor,
        380000,
      );
    });

    test(r'married filing separately uses the $125,000 threshold', () {
      final report = rules.report(
        individualInput(
          status: UsFilingStatus.marriedFilingSeparately,
          entries: [
            entryMinor(2026, 'us.ind.wages', 15000000),
            entryMinor(2026, 'us.ind.taxable_interest', 5000000),
          ],
        ),
      );
      expect(
        lineNamed(report, 'Net investment income tax').amountMinor,
        190000,
      );
    });
  });

  group('self-employment tax', () {
    test(r'2026 business profit of $100,000', () {
      final report = rules.report(
        individualInput(linked: [businessInput(grossReceiptsDollars: 100000)]),
      );
      expect(lineNamed(report, 'Self-employment tax').amountMinor, 1412955);
      expect(
        lineNamed(report, 'Deductible part of self-employment tax').amountMinor,
        706477,
      );
      expect(lineNamed(report, 'Adjusted gross income').amountMinor, 9293523);
    });

    test(r'2026 business profit of $200,000 stays below the wage base', () {
      final report = rules.report(
        individualInput(linked: [businessInput(grossReceiptsDollars: 200000)]),
      );
      expect(lineNamed(report, 'Self-employment tax').amountMinor, 2823430);
    });

    test('2026 business profit above the Social Security wage base', () {
      final report = rules.report(
        individualInput(linked: [businessInput(grossReceiptsDollars: 500000)]),
      );
      expect(lineNamed(report, 'Self-employment tax').amountMinor, 3862450);
      final liability = liabilityWithLabel(report, 'Self-employment tax');
      final additional = liability.bands.firstWhere(
        (band) => band.label == 'Additional Medicare 0.9%',
      );
      expect(additional.baseMinor, 26175000);
      expect(additional.taxMinor, 235575);
    });

    test(r'2025 uses the $176,100 wage base', () {
      final report = rules.report(
        individualInput(
          year: 2025,
          linked: [businessInput(year: 2025, grossReceiptsDollars: 200000)],
        ),
      );
      expect(lineNamed(report, 'Self-employment tax').amountMinor, 2719270);
    });

    test('wages above the wage base remove the Social Security part', () {
      final report = rules.report(
        individualInput(
          entries: [entryMinor(2026, 'us.ind.wages', 20000000)],
          linked: [businessInput(grossReceiptsDollars: 50000)],
        ),
      );
      expect(lineNamed(report, 'Self-employment tax').amountMinor, 175464);
      final liability = liabilityWithLabel(report, 'Self-employment tax');
      expect(
        liability.bands.any((band) => band.label == 'Social Security 12.4%'),
        isFalse,
      );
    });

    test(r'no self-employment tax below the $400 net earnings threshold', () {
      final report = rules.report(
        individualInput(linked: [businessInput(grossReceiptsDollars: 400)]),
      );
      expect(
        report.liabilities.any(
          (liability) => liability.label == 'Self-employment tax',
        ),
        isFalse,
      );
    });

    test(r'self-employment tax starts just above the $400 threshold', () {
      final report = rules.report(
        individualInput(linked: [businessInput(grossReceiptsDollars: 500)]),
      );
      expect(lineNamed(report, 'Self-employment tax').amountMinor, 7064);
    });
  });

  group('qualified business income deduction', () {
    test('2026 applies the 20% deduction and the taxable-income limit', () {
      final report = rules.report(
        individualInput(linked: [businessInput(grossReceiptsDollars: 100000)]),
      );
      expect(
        lineNamed(report, 'Qualified business income deduction').amountMinor,
        1536704,
      );
      expect(lineNamed(report, 'Taxable income').amountMinor, 6146819);
    });

    test('2025 applies the 20% deduction without the 2026 minimum', () {
      final report = rules.report(
        individualInput(
          year: 2025,
          linked: [businessInput(year: 2025, grossReceiptsDollars: 100000)],
        ),
      );
      expect(
        lineNamed(report, 'Qualified business income deduction').amountMinor,
        1543704,
      );
    });

    test('no deduction above the threshold', () {
      final report = rules.report(
        individualInput(
          entries: [entryMinor(2026, 'us.ind.wages', 25000000)],
          linked: [businessInput(grossReceiptsDollars: 100000)],
        ),
      );
      expect(
        hasLineNamed(report, 'Qualified business income deduction'),
        isFalse,
      );
    });

    test(r'2026 applies the $400 minimum when QBI exceeds $1,000', () {
      final report = rules.report(
        individualInput(
          entries: [entryMinor(2026, 'us.ind.wages', 2000000)],
          linked: [businessInput(grossReceiptsDollars: 1500)],
        ),
      );
      expect(
        lineNamed(report, 'Qualified business income deduction').amountMinor,
        40000,
      );
    });

    test('2025 does not apply the minimum deduction', () {
      final report = rules.report(
        individualInput(
          year: 2025,
          entries: [entryMinor(2025, 'us.ind.wages', 2000000)],
          linked: [businessInput(year: 2025, grossReceiptsDollars: 1500)],
        ),
      );
      expect(
        lineNamed(report, 'Qualified business income deduction').amountMinor,
        27880,
      );
    });
  });

  group('standard deduction versus itemized deductions', () {
    test('uses itemized deductions when they are larger', () {
      final report = rules.report(
        individualInput(
          entries: [
            entryMinor(2026, 'us.ind.wages', 10000000),
            entryMinor(2026, 'us.ind.itemized_deductions', 2000000),
          ],
        ),
      );
      expect(
        lineWithCode(report, 'us.ind.itemized_deductions').amountMinor,
        2000000,
      );
      expect(hasLineNamed(report, 'Standard deduction'), isFalse);
      expect(lineNamed(report, 'Taxable income').amountMinor, 8000000);
      expect(lineNamed(report, 'Federal income tax').amountMinor, 1231200);
    });

    test('uses the standard deduction when itemized is smaller', () {
      final report = rules.report(
        individualInput(
          entries: [
            entryMinor(2026, 'us.ind.wages', 10000000),
            entryMinor(2026, 'us.ind.itemized_deductions', 1000000),
          ],
        ),
      );
      expect(lineNamed(report, 'Standard deduction').amountMinor, 1610000);
      expect(
        lineWithCode(report, 'us.ind.itemized_deductions').amountMinor,
        1000000,
      );
      expect(lineNamed(report, 'Taxable income').amountMinor, 8390000);
      expect(lineNamed(report, 'Federal income tax').amountMinor, 1317000);
    });
  });

  group('capital losses', () {
    test('offsets long-term gains and allows the excess against income', () {
      final report = rules.report(
        individualInput(
          entries: [
            entryMinor(2026, 'us.ind.wages', 5000000),
            entryMinor(2026, 'us.ind.long_term_capital_gains', 1000000),
            entryMinor(2026, 'us.ind.capital_losses', 1200000),
          ],
        ),
      );
      expect(lineNamed(report, 'Adjusted gross income').amountMinor, 4800000);
      expect(lineNamed(report, 'Taxable income').amountMinor, 3190000);
      expect(lineNamed(report, 'Federal income tax').amountMinor, 358000);
      expect(
        report.liabilities.any(
          (liability) =>
              liability.label ==
              'Income tax (capital gains and qualified dividends)',
        ),
        isFalse,
      );
    });

    test(r'limits the ordinary loss to $3,000', () {
      final report = rules.report(
        individualInput(
          entries: [
            entryMinor(2026, 'us.ind.wages', 5000000),
            entryMinor(2026, 'us.ind.long_term_capital_gains', 1000000),
            entryMinor(2026, 'us.ind.capital_losses', 2000000),
          ],
        ),
      );
      expect(lineNamed(report, 'Adjusted gross income').amountMinor, 4700000);
      expect(lineNamed(report, 'Taxable income').amountMinor, 3090000);
      expect(lineNamed(report, 'Federal income tax').amountMinor, 346000);
      expect(
        lineWithCode(report, 'us.ind.capital_losses').amountMinor,
        2000000,
      );
    });

    test(r'married filing separately limits the ordinary loss to $1,500', () {
      final report = rules.report(
        individualInput(
          status: UsFilingStatus.marriedFilingSeparately,
          entries: [
            entryMinor(2026, 'us.ind.wages', 5000000),
            entryMinor(2026, 'us.ind.long_term_capital_gains', 1000000),
            entryMinor(2026, 'us.ind.capital_losses', 2000000),
          ],
        ),
      );
      expect(lineNamed(report, 'Adjusted gross income').amountMinor, 4850000);
      expect(lineNamed(report, 'Taxable income').amountMinor, 3240000);
      expect(lineNamed(report, 'Federal income tax').amountMinor, 364000);
    });
  });

  group('payments', () {
    test('withholding and estimated payments reduce the balance due', () {
      final report = rules.report(
        individualInput(
          entries: [
            entryMinor(2026, 'us.ind.wages', 10000000),
            entryMinor(2026, 'us.ind.federal_withholding', 1000000),
            entryMinor(2026, 'us.ind.estimated_tax_payments', 500000),
          ],
        ),
      );
      expect(lineNamed(report, 'Total tax').amountMinor, 1317000);
      expect(report.alreadyPaidMinor, 1500000);
      expect(report.balanceDueMinor, -183000);
      expect(lineNamed(report, 'Amount overpaid').amountMinor, 183000);
    });
  });

  group('Schedule C', () {
    test('computes gross profit, expenses, home office, and net profit', () {
      final report = rules.report(
        soleTraderInput(
          entries: [
            entryDollars(2026, 'us.sch_c.gross_receipts', 100000),
            entryDollars(2026, 'us.sch_c.returns_and_allowances', 5000),
            entryDollars(2026, 'us.sch_c.cost_of_goods_sold', 20000),
            entryDollars(2026, 'us.sch_c.advertising', 3000),
            entryDollars(2026, 'us.sch_c.meals', 2000),
            entryDollars(2026, 'us.sch_c.home_office', 2000),
          ],
        ),
      );
      expect(lineNamed(report, 'Gross profit').amountMinor, 7500000);
      expect(lineNamed(report, 'Gross income').amountMinor, 7500000);
      expect(
        lineNamed(
          report,
          'Total expenses before expenses for business use of home',
        ).amountMinor,
        400000,
      );
      expect(
        lineNamed(report, 'Tentative profit or (loss)').amountMinor,
        7100000,
      );
      expect(lineNamed(report, 'Net profit or (loss)').amountMinor, 6950000);
      expect(lineWithCode(report, 'us.sch_c.meals').amountMinor, 100000);
      expect(lineWithCode(report, 'us.sch_c.home_office').amountMinor, 150000);
      expect(report.liabilities, isEmpty);
      expect(report.alreadyPaidMinor, 0);
      expect(report.assumptions, contains(contains('simplified method')));
    });

    test('reports a loss', () {
      final report = rules.report(
        soleTraderInput(
          entries: [
            entryDollars(2026, 'us.sch_c.gross_receipts', 10000),
            entryDollars(2026, 'us.sch_c.advertising', 20000),
          ],
        ),
      );
      expect(lineNamed(report, 'Net profit or (loss)').amountMinor, -1000000);
    });

    test('strips sales tax and applies business use', () {
      final report = rules.report(
        soleTraderInput(
          entries: [
            entryMinor(
              2026,
              'us.sch_c.advertising',
              100000,
              salesTaxMinor: 10000,
              businessUsePercent: 50,
            ),
          ],
        ),
      );
      expect(lineWithCode(report, 'us.sch_c.advertising').amountMinor, 45000);
    });

    test('counts unknown categories without including them', () {
      final report = rules.report(
        soleTraderInput(
          entries: [
            entryDollars(2026, 'us.unknown', 100),
            entryDollars(2026, 'us.sch_c.gross_receipts', 1000),
          ],
        ),
      );
      expect(report.uncategorizedCount, 1);
      expect(lineNamed(report, 'Net profit or (loss)').amountMinor, 100000);
    });
  });

  group('C corporation', () {
    test('applies a flat 21% rate to taxable income', () {
      final report = rules.report(
        companyInput(
          entries: [
            entryDollars(2026, 'us.co.gross_receipts', 1000000),
            entryDollars(2026, 'us.co.cost_of_goods_sold', 400000),
            entryDollars(2026, 'us.co.salaries_and_wages', 200000),
            entryDollars(2026, 'us.co.advertising', 50000),
            entryDollars(2026, 'us.co.other_deductions', 10000),
          ],
        ),
      );
      expect(lineNamed(report, 'Gross profit').amountMinor, 60000000);
      expect(lineNamed(report, 'Total income').amountMinor, 60000000);
      expect(lineNamed(report, 'Total deductions').amountMinor, 26000000);
      expect(lineNamed(report, 'Taxable income').amountMinor, 34000000);
      expect(lineNamed(report, 'Total tax').amountMinor, 7140000);
      expect(
        liabilityWithLabel(report, 'Federal income tax (21%)').amountMinor,
        7140000,
      );
    });

    test('a capital loss reduces total income', () {
      final report = rules.report(
        companyInput(
          entries: [
            entryDollars(2026, 'us.co.gross_receipts', 100000),
            entryDollars(2026, 'us.co.capital_loss', 20000),
          ],
        ),
      );
      expect(lineNamed(report, 'Total income').amountMinor, 8000000);
      expect(lineNamed(report, 'Total deductions').amountMinor, 0);
      expect(lineNamed(report, 'Taxable income').amountMinor, 8000000);
      expect(lineNamed(report, 'Total tax').amountMinor, 1680000);
      expect(lineWithCode(report, 'us.co.capital_loss').amountMinor, 2000000);
    });

    test('a loss produces no current tax', () {
      final report = rules.report(
        companyInput(
          entries: [
            entryDollars(2026, 'us.co.gross_receipts', 100000),
            entryDollars(2026, 'us.co.cost_of_goods_sold', 50000),
            entryDollars(2026, 'us.co.salaries_and_wages', 100000),
          ],
        ),
      );
      expect(lineNamed(report, 'Taxable income').amountMinor, -5000000);
      expect(report.liabilities, isEmpty);
      expect(report.totalLiabilityMinor, 0);
    });

    test('credits estimated tax payments', () {
      final report = rules.report(
        companyInput(
          entries: [
            entryDollars(2026, 'us.co.gross_receipts', 100000),
            entryDollars(2026, 'us.co.estimated_tax_payments', 10000),
          ],
        ),
      );
      expect(report.alreadyPaidMinor, 1000000);
      expect(report.balanceDueMinor, 1100000);
      expect(lineNamed(report, 'Amount owed').amountMinor, 1100000);
    });
  });

  group('zero income and dates', () {
    test('zero income produces no liabilities', () {
      final report = rules.report(individualInput());
      expect(report.liabilities, isEmpty);
      expect(report.totalLiabilityMinor, 0);
      expect(report.alreadyPaidMinor, 0);
      expect(report.balanceDueMinor, 0);
      expect(lineNamed(report, 'Taxable income').amountMinor, 0);
      expect(lineNamed(report, 'Total tax').amountMinor, 0);
      expect(report.uncategorizedCount, 0);
    });

    test('zero income on a company produces no tax', () {
      final report = rules.report(companyInput());
      expect(report.liabilities, isEmpty);
      expect(lineNamed(report, 'Taxable income').amountMinor, 0);
      expect(lineNamed(report, 'Total tax').amountMinor, 0);
    });

    test('ignores linked businesses from another tax year', () {
      final report = rules.report(
        individualInput(
          entries: [entryMinor(2026, 'us.ind.wages', 1000000)],
          linked: [businessInput(year: 2025, grossReceiptsDollars: 100000)],
        ),
      );
      expect(hasLineNamed(report, 'Schedule C net profit'), isFalse);
      expect(lineNamed(report, 'Total income').amountMinor, 1000000);
    });

    test('ignores entries outside the tax year', () {
      final report = rules.report(
        individualInput(
          entries: [
            entryDollars(2025, 'us.ind.wages', 1000),
            entryDollars(2027, 'us.ind.wages', 1000),
          ],
        ),
      );
      expect(report.uncategorizedCount, 0);
      expect(hasLineNamed(report, 'Wages, salaries, tips'), isFalse);
      expect(report.lines.every((line) => line.code != 'us.ind.wages'), isTrue);
    });
  });

  group('assumptions, sources, and verification date', () {
    final report = rules.report(
      individualInput(entries: [entryDollars(2026, 'us.ind.wages', 100000)]),
    );

    test('states the federal-only scope and missing credits', () {
      expect(
        report.assumptions,
        contains('Federal only; no state income tax.'),
      );
      expect(report.assumptions, contains('No credits computed.'));
      expect(report.assumptions, contains(contains('whole-dollar rounding')));
    });

    test('cites the IRS sources', () {
      expect(
        report.sources,
        contains(Uri.parse('https://www.irs.gov/pub/irs-drop/rp-24-40.pdf')),
      );
      expect(
        report.sources,
        contains(Uri.parse('https://www.irs.gov/pub/irs-drop/rp-25-32.pdf')),
      );
      expect(
        report.sources,
        contains(
          Uri.parse(
            'https://www.irs.gov/businesses/small-businesses-self-employed/'
            'self-employment-tax-social-security-and-medicare-taxes',
          ),
        ),
      );
      expect(
        report.sources,
        contains(Uri.parse('https://www.irs.gov/publications/p969')),
      );
      expect(report.sources.every((uri) => uri.host == 'www.irs.gov'), isTrue);
    });

    test('reports the verification date and currency', () {
      expect(report.rulesVerifiedOn, DateTime.utc(2026, 11, 4));
      expect(report.currencyCode, 'USD');
      expect(report.year.label, '2026');
    });
  });

  group('opportunities', () {
    test('finds retirement, HSA, QBI, and estimated-tax opportunities', () {
      final input = individualInput(
        linked: [businessInput(grossReceiptsDollars: 100000)],
      );
      final report = rules.report(input);
      final opportunities = rules.opportunities(input, report);
      final ids = opportunities.map((opportunity) => opportunity.id).toSet();
      expect(ids, contains('us.sep_ira_or_solo_401k'));
      expect(ids, contains('us.traditional_ira'));
      expect(ids, contains('us.hsa'));
      expect(ids, contains('us.qbi'));
      expect(ids, contains('us.estimated_tax'));
      expect(ids, hasLength(opportunities.length));
      expect(
        opportunities
            .where((opportunity) => opportunity.estimatedSavingMinor != null)
            .every((opportunity) => opportunity.estimatedSavingMinor! > 0),
        isTrue,
      );
      expect(
        opportunities.every(
          (opportunity) => opportunity.source.host == 'www.irs.gov',
        ),
        isTrue,
      );
    });

    test('explains the HSA high-deductible requirement', () {
      final input = individualInput(
        linked: [businessInput(grossReceiptsDollars: 100000)],
      );
      final report = rules.report(input);
      final hsa = rules
          .opportunities(input, report)
          .firstWhere((opportunity) => opportunity.id == 'us.hsa');
      expect(hsa.explanation, contains('high-deductible'));
      expect(hsa.explanation, contains('family limit'));
    });

    test('finds tax-loss harvesting and sets a December 31 deadline', () {
      final input = individualInput(
        entries: [
          entryMinor(2026, 'us.ind.wages', 7000000),
          entryMinor(2026, 'us.ind.long_term_capital_gains', 1000000),
        ],
      );
      final report = rules.report(input);
      final harvesting = rules
          .opportunities(input, report)
          .firstWhere(
            (opportunity) => opportunity.id == 'us.tax_loss_harvesting',
          );
      expect(harvesting.deadline, DateTime.utc(2026, 12, 31));
      expect(harvesting.estimatedSavingMinor, 150000);
    });

    test('compares the standard deduction and itemized total', () {
      final input = individualInput(
        entries: [
          entryMinor(2026, 'us.ind.wages', 10000000),
          entryMinor(2026, 'us.ind.itemized_deductions', 2000000),
        ],
      );
      final report = rules.report(input);
      final election = rules
          .opportunities(input, report)
          .firstWhere(
            (opportunity) => opportunity.id == 'us.standard_vs_itemized',
          );
      expect(election.title, 'Itemize deductions');
      expect(election.estimatedSavingMinor, greaterThan(0));
    });

    test('uses the exact quarterly due dates for each year', () {
      final cases = <(int, String)>[
        (2025, 'June 16, 2025'),
        (2026, 'June 15, 2026'),
      ];
      for (final (year, juneDate) in cases) {
        final input = individualInput(
          year: year,
          linked: [businessInput(year: year, grossReceiptsDollars: 100000)],
        );
        final report = rules.report(input);
        final estimated = rules
            .opportunities(input, report)
            .firstWhere((opportunity) => opportunity.id == 'us.estimated_tax');
        expect(estimated.explanation, contains(juneDate));
        expect(estimated.deadline, DateTime.utc(year + 1, 1, 15));
      }
    });

    test(r'offers corporate estimated tax above $500', () {
      final input = companyInput(
        entries: [entryDollars(2026, 'us.co.gross_receipts', 100000)],
      );
      final report = rules.report(input);
      final opportunities = rules.opportunities(input, report);
      expect(opportunities.single.id, 'us.company_estimated_tax');
      expect(opportunities.single.deadline, DateTime.utc(2026, 12, 15));
    });

    test('a sole trader report has no separate opportunities', () {
      final input = soleTraderInput(
        entries: [entryDollars(2026, 'us.sch_c.gross_receipts', 1000)],
      );
      final report = rules.report(input);
      expect(rules.opportunities(input, report), isEmpty);
    });
  });
}
