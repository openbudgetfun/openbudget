import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

/// One entry in euros, dated inside 2026 unless a month is given.
TaxEntry entry(String code, int euros, {int year = 2026, int month = 6}) =>
    TaxEntry(
      date: DateTime.utc(year, month, 15),
      amountMinor: euros * 100,
      categoryCode: code,
    );

const rules = DeTaxRules();

TaxInput individualInput(
  List<TaxEntry> entries, {
  int year = 2026,
  bool joint = false,
  bool church = false,
  List<TaxInput> linked = const [],
}) => TaxInput(
  profile: DeTaxProfile(
    entityKind: TaxEntityKind.individual,
    jointAssessment: joint,
    churchTax: church,
  ),
  year: rules.taxYear(year),
  entries: entries,
  linked: linked,
);

TaxInput soleTraderInput(
  List<TaxEntry> entries, {
  bool vatRegistered = true,
  bool smallBusinessExemption = false,
  int year = 2026,
}) => TaxInput(
  profile: DeTaxProfile(
    entityKind: TaxEntityKind.soleTrader,
    salesTaxRegistered: vatRegistered,
    smallBusinessExemption: smallBusinessExemption,
  ),
  year: rules.taxYear(year),
  entries: entries,
);

TaxInput companyInput(List<TaxEntry> entries, {int year = 2026}) => TaxInput(
  profile: const DeTaxProfile(
    entityKind: TaxEntityKind.company,
    salesTaxRegistered: true,
    smallBusinessExemption: false,
  ),
  year: rules.taxYear(year),
  entries: entries,
);

int liability(TaxReport report, String label) =>
    report.liabilities.firstWhere((item) => item.label == label).amountMinor;

void main() {
  group('tax years', () {
    test('a calendar year runs from 1 January to 1 January', () {
      final year = rules.taxYear(2026);
      expect(year.start, DateTime.utc(2026));
      expect(year.end, DateTime.utc(2027));
      expect(year.label, '2026');
      expect(year.jurisdiction, TaxJurisdiction.de);
    });

    test('31 December belongs to its own year', () {
      expect(rules.taxYearFor(DateTime.utc(2026, 12, 31)).startYear, 2026);
      expect(rules.taxYearFor(DateTime(2026, 12, 31, 23, 59)).startYear, 2026);
    });

    test('1 January starts the next year', () {
      expect(rules.taxYearFor(DateTime.utc(2025, 12, 31)).startYear, 2025);
      expect(rules.taxYearFor(DateTime.utc(2026)).startYear, 2026);
      expect(rules.taxYearFor(DateTime(2026, 1, 1, 0, 1)).startYear, 2026);
      expect(
        () => rules.taxYearFor(DateTime.utc(2027)),
        throwsA(isA<UnsupportedTaxYearException>()),
      );
    });

    test('an unsupported year throws', () {
      expect(
        () => rules.taxYear(2024),
        throwsA(isA<UnsupportedTaxYearException>()),
      );
      expect(
        () => rules.taxYearFor(DateTime.utc(2030, 6)),
        throwsA(isA<UnsupportedTaxYearException>()),
      );
      expect(
        () => rules.report(
          TaxInput(
            profile: const DeTaxProfile(entityKind: TaxEntityKind.individual),
            year: TaxYear(
              jurisdiction: TaxJurisdiction.de,
              startYear: 2024,
              start: DateTime.utc(2024),
              end: DateTime.utc(2025),
              label: '2024',
            ),
            entries: const [],
          ),
        ),
        throwsA(isA<UnsupportedTaxYearException>()),
      );
    });

    test('2025 and 2026 are both supported', () {
      expect(rules.supportedStartYears, {2025, 2026});
    });
  });

  group('individual 2026', () {
    test('employment income uses the Arbeitnehmer-Pauschbetrag', () {
      final report = rules.report(
        individualInput([
          entry('de.ind.arbeitslohn', 100000),
          entry('de.ind.lohnsteuer', 25000),
        ]),
      );
      // 100 000 - 1 230 - 36 = 98 734 Euro taxable income.
      expect(liability(report, 'Einkommensteuer'), 3033200);
      expect(liability(report, 'Solidaritätszuschlag'), 118785);
      expect(report.alreadyPaidMinor, 2500000);
      expect(report.balanceDueMinor, 651985);
      expect(
        report.lines
            .firstWhere((line) => line.label == 'Zu versteuerndes Einkommen')
            .amountMinor,
        9873400,
      );
    });

    test('actual Werbungskosten above the Pauschbetrag are used', () {
      final report = rules.report(
        individualInput([
          entry('de.ind.arbeitslohn', 100000),
          entry('de.ind.werbungskosten', 5000),
          entry('de.ind.homeoffice', 1260),
        ]),
      );
      // 100 000 - 6 260 - 36 = 93 704 Euro.
      expect(
        report.lines
            .firstWhere((line) => line.label == 'Zu versteuerndes Einkommen')
            .amountMinor,
        9370400,
      );
      expect(liability(report, 'Einkommensteuer'), 2822000);
    });

    test('joint assessment applies the splitting method', () {
      final report = rules.report(
        individualInput([entry('de.ind.arbeitslohn', 200000)], joint: true),
      );
      // Half of 198 698 Euro twice: 2 * 30 590 = 61 180 Euro.
      expect(liability(report, 'Einkommensteuer'), 6118000);
      expect(liability(report, 'Solidaritätszuschlag'), 243712);
      expect(
        report.assumptions,
        contains(
          'Zusammenveranlagung: alle Beträge gelten als gemeinsames Einkommen '
          'beider Ehegatten (Splitting-Verfahren, § 32a Abs. 5 EStG).',
        ),
      );
    });

    test('capital income is taxed at 25 % after the Sparer-Pauschbetrag', () {
      final report = rules.report(
        individualInput([
          entry('de.ind.kapitalertraege', 10000),
          entry('de.ind.kapitalertragsteuer', 2374),
        ]),
      );
      expect(liability(report, 'Einkommensteuer'), 0);
      expect(liability(report, 'Abgeltungsteuer auf Kapitalerträge'), 225000);
      expect(
        liability(report, 'Solidaritätszuschlag auf Abgeltungsteuer'),
        12375,
      );
    });

    test('Kirchensteuer raises the burden on capital income', () {
      final report = rules.report(
        individualInput([entry('de.ind.kapitalertraege', 10000)], church: true),
      );
      // 9 000 / 4.09 = 2 200.48 Euro Abgeltungsteuer.
      expect(liability(report, 'Abgeltungsteuer auf Kapitalerträge'), 220048);
      expect(liability(report, 'Kirchensteuer'), 19804);
      expect(report.assumptions, contains(contains('Kirchensteuer 9 %')));
    });

    test('a linked business feeds the profit and the § 35 credit', () {
      final business = soleTraderInput([
        entry('de.euer.betriebseinnahmen', 100000),
        entry('de.euer.wareneinkauf', 40000),
      ]);
      final report = rules.report(
        individualInput(
          [entry('de.ind.arbeitslohn', 100000)],
          linked: [business],
        ),
      );
      // 98 770 + 60 000 - 36 = 158 734 Euro; 55 532 - 4 970 = 50 562 Euro.
      expect(liability(report, 'Einkommensteuer'), 5056200);
      expect(
        report.lines
            .firstWhere((line) => line.label == 'Anrechnung nach § 35 EStG')
            .amountMinor,
        -497000,
      );
      expect(report.assumptions, contains(contains('§ 35 EStG')));
    });

    test('the bands add up to the income tax', () {
      for (final joint in [false, true]) {
        final report = rules.report(
          individualInput([entry('de.ind.arbeitslohn', 120000)], joint: joint),
        );
        final incomeTax = report.liabilities.firstWhere(
          (item) => item.label == 'Einkommensteuer',
        );
        expect(
          incomeTax.bands.fold(0, (sum, band) => sum + band.taxMinor),
          incomeTax.amountMinor,
          reason: 'joint: $joint',
        );
      }
    });

    test('unknown categories are counted, not computed', () {
      final report = rules.report(
        individualInput([
          entry('de.ind.arbeitslohn', 50000),
          entry('de.zzz.unknown', 1200),
        ]),
      );
      expect(report.uncategorizedCount, 1);
      expect(
        report.lines.any((line) => line.code == 'de.zzz.unknown'),
        isFalse,
      );
    });

    test('the report states its assumptions, sources and check date', () {
      final report = rules.report(
        individualInput([entry('de.ind.arbeitslohn', 50000)]),
      );
      expect(report.assumptions, isNotEmpty);
      expect(report.sources, isNotEmpty);
      expect(report.rulesVerifiedOn, DateTime.utc(2026, 11, 4));
      expect(report.currencyCode, 'EUR');
      expect(
        report.assumptions.join(' '),
        contains('Unbeschränkt steuerpflichtig'),
      );
    });
  });

  group('sole trader 2026', () {
    test('computes the EÜR, Gewerbesteuer and Umsatzsteuer', () {
      final report = rules.report(
        soleTraderInput([
          entry('de.euer.betriebseinnahmen', 100000),
          entry('de.euer.wareneinkauf', 40000),
          entry('de.ust.ausgang', 19000),
          entry('de.ust.eingang', 4000),
        ]),
      );
      // (60 000 - 24 500) * 3.5 % = 1 242.50 Euro Messbetrag; * 400 %.
      expect(
        liability(report, 'Gewerbesteuer (Annahme Gewerbebetrieb)'),
        497000,
      );
      expect(liability(report, 'Umsatzsteuer-Zahllast'), 1500000);
      expect(
        report.lines
            .firstWhere(
              (line) =>
                  line.label ==
                  'Gewinn (Betriebseinnahmen ./. Betriebsausgaben)',
            )
            .amountMinor,
        6000000,
      );
      expect(
        report.assumptions.join(' '),
        contains('Hebesatz der Gewerbesteuer: 400 %'),
      );
    });

    test('Bewirtungskosten are only 70 % deductible', () {
      final report = rules.report(
        soleTraderInput([
          entry('de.euer.betriebseinnahmen', 10000),
          entry('de.euer.bewirtung', 1000),
        ]),
      );
      expect(
        report.lines
            .firstWhere((line) => line.code == 'de.euer.bewirtung')
            .amountMinor,
        -70000,
      );
    });

    test('a Kleinunternehmer pays no Umsatzsteuer', () {
      final report = rules.report(
        soleTraderInput(
          [
            entry('de.euer.betriebseinnahmen', 20000),
            entry('de.ust.ausgang', 3800),
          ],
          vatRegistered: false,
          smallBusinessExemption: true,
        ),
      );
      expect(
        report.liabilities.any((item) => item.label == 'Umsatzsteuer-Zahllast'),
        isFalse,
      );
      expect(
        report.assumptions.join(' '),
        contains('Kleinunternehmerregelung nach § 19 UStG'),
      );
    });

    test('a profit under the Freibetrag owes no Gewerbesteuer', () {
      final report = rules.report(
        soleTraderInput([
          entry('de.euer.betriebseinnahmen', 20000),
          entry('de.euer.wareneinkauf', 5000),
        ]),
      );
      expect(report.liabilities, isEmpty);
      expect(
        report.lines
            .firstWhere(
              (line) =>
                  line.label ==
                  'Gewinn (Betriebseinnahmen ./. Betriebsausgaben)',
            )
            .amountMinor,
        1500000,
      );
    });
  });

  group('company 2026', () {
    test('adds Körperschaftsteuer, its surcharge, Gewerbesteuer and USt', () {
      final report = rules.report(
        companyInput([
          entry('de.co.umsatzerloese', 200000),
          entry('de.co.sonstige', 50000),
          entry('de.ust.ausgang', 38000),
          entry('de.ust.eingang', 9500),
        ]),
      );
      expect(liability(report, 'Körperschaftsteuer'), 2250000);
      expect(
        liability(report, 'Solidaritätszuschlag auf Körperschaftsteuer'),
        123750,
      );
      expect(liability(report, 'Gewerbesteuer'), 2100000);
      expect(liability(report, 'Umsatzsteuer-Zahllast'), 2850000);
      expect(report.totalLiabilityMinor, 7323750);
    });

    test('the company report names its tax rates', () {
      final report = rules.report(
        companyInput([entry('de.co.umsatzerloese', 100000)]),
      );
      expect(
        report.assumptions.join(' '),
        allOf(contains('Körperschaftsteuer 15 %'), contains('Hebesatz 400 %')),
      );
    });
  });

  group('opportunities', () {
    test('an employee is shown the deadline, home office and Basisrente', () {
      final input = individualInput([entry('de.ind.arbeitslohn', 100000)]);
      final ids = rules
          .opportunities(input, rules.report(input))
          .map((item) => item.id)
          .toSet();
      expect(ids, contains('de.frist_steuererklaerung'));
      expect(ids, contains('de.homeoffice_pauschale'));
      expect(ids, contains('de.basisrente_hoechstbetrag'));
      expect(ids, isNot(contains('de.sparer_pauschbetrag')));
    });

    test('an unused Sparer-Pauschbetrag estimates the refund', () {
      final input = individualInput([
        entry('de.ind.kapitalertraege', 800),
        entry('de.ind.kapitalertragsteuer', 200),
      ]);
      final opportunity = rules
          .opportunities(input, rules.report(input))
          .firstWhere((item) => item.id == 'de.sparer_pauschbetrag');
      expect(opportunity.estimatedSavingMinor, 20000);
      expect(opportunity.source.toString(), contains('estg/__20'));
    });

    test('a low earner is shown the Günstigerprüfung', () {
      final input = individualInput([
        entry('de.ind.arbeitslohn', 20000),
        entry('de.ind.kapitalertraege', 5000),
      ]);
      final opportunity = rules
          .opportunities(input, rules.report(input))
          .firstWhere((item) => item.id == 'de.guenstigerpruefung');
      // 1 000 Euro Abgeltungsteuer against 999 Euro extra tariff tax.
      expect(opportunity.estimatedSavingMinor, 100);
    });

    test('a small business is shown the Kleinunternehmerregelung', () {
      final input = soleTraderInput([
        entry('de.euer.betriebseinnahmen', 20000),
        entry('de.ust.ausgang', 3800),
      ]);
      final ids = rules
          .opportunities(input, rules.report(input))
          .map((item) => item.id)
          .toSet();
      expect(ids, contains('de.kleinunternehmerregelung'));
      expect(ids, contains('de.investitionsabzugsbetrag'));
    });

    test('a shareholder sees the salary-or-dividend comparison', () {
      final company = companyInput([entry('de.co.umsatzerloese', 150000)]);
      final input = individualInput(
        [entry('de.ind.arbeitslohn', 100000)],
        linked: [company],
      );
      final opportunity = rules
          .opportunities(input, rules.report(input))
          .firstWhere((item) => item.id == 'de.geschaeftsfuehrer_vergleich');
      expect(opportunity.estimatedSavingMinor, greaterThan(0));
    });

    test('every opportunity cites an official source', () {
      final input = soleTraderInput([
        entry('de.euer.betriebseinnahmen', 30000),
      ]);
      final opportunities = rules.opportunities(input, rules.report(input));
      expect(opportunities, isNotEmpty);
      for (final opportunity in opportunities) {
        expect(
          opportunity.source.toString(),
          startsWith('https://www.gesetze-im-internet.de/'),
        );
        expect(opportunity.deadline, isNotNull);
      }
    });
  });

  group('category catalog', () {
    test('every entity kind has categories in return order', () {
      for (final kind in TaxEntityKind.values) {
        final categories = rules.categoriesFor(kind);
        expect(categories, isNotEmpty);
        expect(
          categories.map((item) => item.code).toSet(),
          hasLength(categories.length),
        );
        for (final category in categories) {
          expect(category.entityKinds, contains(kind));
          expect(category.code, startsWith('de.'));
        }
      }
    });

    test('looks a category up by code', () {
      expect(
        rules.category('de.euer.betriebseinnahmen')?.kind,
        TaxCategoryKind.income,
      );
      expect(
        rules.category('de.ust.ausgang')?.kind,
        TaxCategoryKind.salesTaxCollected,
      );
      expect(rules.category('de.zzz.unknown'), isNull);
    });

    test('the shipped rule table uses the pack', () {
      expect(TaxRules.forJurisdiction(TaxJurisdiction.de), isA<DeTaxRules>());
    });
  });
}
