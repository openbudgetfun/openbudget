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
  DeBundesland? churchState,
  int children = 0,
  bool spouseEmployed = false,
  int statutoryPensionMinor = 0,
  int commuteKmOneWay = 0,
  int commuteDays = 0,
  List<TaxInput> linked = const [],
}) => TaxInput(
  profile: DeTaxProfile(
    entityKind: EntityKind.individual,
    jointAssessment: joint,
    churchTax: church,
    churchTaxState: churchState,
    children: children,
    spouseEmployed: spouseEmployed,
    statutoryPensionMinor: statutoryPensionMinor,
    commuteKmOneWay: commuteKmOneWay,
    commuteDays: commuteDays,
  ),
  year: rules.taxYear(year),
  entries: entries,
  linked: linked,
);

TaxInput soleTraderInput(
  List<TaxEntry> entries, {
  bool vatRegistered = true,
  bool smallBusinessExemption = false,
  DeEinkunftsArt einkunftsArt = DeEinkunftsArt.gewerblich,
  int previousYearTurnoverMinor = 0,
  int year = 2026,
}) => TaxInput(
  profile: DeTaxProfile(
    entityKind: EntityKind.soleTrader,
    salesTaxRegistered: vatRegistered,
    smallBusinessExemption: smallBusinessExemption,
    einkunftsArt: einkunftsArt,
    previousYearTurnoverMinor: previousYearTurnoverMinor,
  ),
  year: rules.taxYear(year),
  entries: entries,
);

TaxInput companyInput(List<TaxEntry> entries, {int year = 2026}) => TaxInput(
  profile: const DeTaxProfile(
    entityKind: EntityKind.company,
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
            profile: const DeTaxProfile(entityKind: EntityKind.individual),
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

    test('joint assessment applies one Pauschbetrag per employed spouse', () {
      final report = rules.report(
        individualInput(
          [entry('de.ind.arbeitslohn', 200000)],
          joint: true,
          spouseEmployed: true,
        ),
      );
      // Two Pauschbeträge: 200 000 - 2 460 - 72 = 197 468 Euro; half 98 734
      // taxed twice = 2 * 30 332 = 60 664 Euro.
      expect(liability(report, 'Einkommensteuer'), 6066400);
      expect(
        report.lines
            .firstWhere(
              (line) => line.label == 'Arbeitnehmer-Pauschbetrag (je Ehegatte)',
            )
            .amountMinor,
        -246000,
      );
      expect(
        report.assumptions.join(' '),
        contains('je erwerbstätigem Ehegatten'),
      );
    });

    test('Kinderfreibeträge beat the Kindergeld under joint assessment', () {
      final report = rules.report(
        individualInput(
          [entry('de.ind.arbeitslohn', 200000)],
          joint: true,
          children: 2,
        ),
      );
      // 198 698 - 2 * 9 756 = 179 186 Euro; half 89 593 taxed twice:
      // 2 * 26 493 = 52 986 Euro, more than the 6 216 Euro Kindergeld saves.
      expect(
        report.lines
            .firstWhere((line) => line.label == 'Zu versteuerndes Einkommen')
            .amountMinor,
        17918600,
      );
      // § 31 Satz 4 EStG adds the Kindergeld back: 52 986 + 6 216 Euro.
      expect(
        report.lines
            .firstWhere((line) => line.label == 'Hinzurechnung Kindergeld')
            .amountMinor,
        621600,
      );
      expect(liability(report, 'Einkommensteuer'), 5920200);
      // Soli on the KFB tax: 11.9 % of (52 986 - 40 700) = 1 462.03.
      expect(liability(report, 'Solidaritätszuschlag'), 146203);
    });

    test(
      'the Kindergeld wins but Soli and Kirchensteuer use the KFB tax',
      () {
        final report = rules.report(
          individualInput(
            [entry('de.ind.arbeitslohn', 60000)],
            children: 2,
            churchState: DeBundesland.hessen,
          ),
        );
        // 60 000 - 1 230 - 36 = 58 734 Euro; with 2 halved KFB 9 756 Euro the
        // tax is 10 191 Euro, so the 6 216 Euro Kindergeld wins and the
        // assessed tax stays 13 747 Euro.
        expect(
          report.lines
              .firstWhere((line) => line.label == 'Zu versteuerndes Einkommen')
              .amountMinor,
          5873400,
        );
        expect(liability(report, 'Einkommensteuer'), 1374700);
        // Soli and Kirchensteuer are computed on the 10 191 Euro KFB tax
        // (§ 3 Abs. 2 SolzG, § 51a Abs. 1 EStG); 9 % of 10 191 = 917.19.
        expect(liability(report, 'Kirchensteuer'), 91719);
        // 10 191 Euro is below the Soli Freigrenze, so no surcharge is due.
        expect(
          report.liabilities.where(
            (item) => item.label == 'Solidaritätszuschlag',
          ),
          isEmpty,
        );
        expect(
          report.assumptions.join(' '),
          contains('das Kindergeld gewählt'),
        );
      },
    );

    test('the Basisrente cap doubles jointly and shrinks by pension dues', () {
      final single = rules.report(
        individualInput(
          [
            entry('de.ind.arbeitslohn', 50000),
            entry('de.ind.basisrente', 35000),
          ],
          statutoryPensionMinor: 1000000,
        ),
      );
      // Cap 30 826 - 10 000 = 20 826 Euro of the 35 000 Euro paid.
      expect(
        single.lines
            .firstWhere((line) => line.label == 'Basisrente (Sonderausgaben)')
            .amountMinor,
        -2082600,
      );
      final joint = rules.report(
        individualInput(
          [
            entry('de.ind.arbeitslohn', 100000),
            entry('de.ind.basisrente', 45000),
          ],
          joint: true,
          statutoryPensionMinor: 2000000,
        ),
      );
      // Cap 2 * 30 826 - 20 000 = 41 652 Euro of the 45 000 Euro paid.
      expect(
        joint.lines
            .firstWhere((line) => line.label == 'Basisrente (Sonderausgaben)')
            .amountMinor,
        -4165200,
      );
    });

    test('the Homeoffice-Pauschale caps at 1 260 Euro in whole days', () {
      // A 2 000 Euro claim is cut to the annual cap: 100 000 - 1 260 - 36 =
      // 98 704 Euro.
      final report = rules.report(
        individualInput([
          entry('de.ind.arbeitslohn', 100000),
          entry('de.ind.homeoffice', 2000),
        ]),
      );
      expect(
        report.lines
            .firstWhere((line) => line.label == 'Zu versteuerndes Einkommen')
            .amountMinor,
        9870400,
      );
      // 1 263 Euro is 210.5 days; only whole days count, so the claim floors
      // to 1 260 Euro and the same zvE results.
      final floored = rules.report(
        individualInput([
          entry('de.ind.arbeitslohn', 100000),
          entry('de.ind.homeoffice', 1263),
        ]),
      );
      expect(
        floored.lines
            .firstWhere((line) => line.label == 'Zu versteuerndes Einkommen')
            .amountMinor,
        9870400,
      );
      expect(
        floored.assumptions.join(' '),
        contains('210 Tage'),
      );
    });

    test('an Arbeitszimmer excludes the Homeoffice-Tagespauschale', () {
      final report = rules.report(
        individualInput([
          entry('de.ind.arbeitslohn', 100000),
          entry('de.ind.arbeitszimmer', 1260),
          entry('de.ind.homeoffice', 1260),
        ]),
      );
      // Only the Arbeitszimmer counts: 100 000 - 1 260 - 36 = 98 704 Euro.
      expect(
        report.lines
            .firstWhere((line) => line.label == 'Zu versteuerndes Einkommen')
            .amountMinor,
        9870400,
      );
      expect(
        report.assumptions.join(' '),
        contains('bleibt außen vor'),
      );
      final opportunityIds = rules
          .opportunities(
            individualInput([
              entry('de.ind.arbeitslohn', 100000),
              entry('de.ind.arbeitszimmer', 1260),
            ]),
            report,
          )
          .map((item) => item.id)
          .toSet();
      expect(opportunityIds, isNot(contains('de.homeoffice_pauschale')));
    });

    test('the Entfernungspauschale is a Werbungskosten input', () {
      final report = rules.report(
        individualInput(
          [
            entry('de.ind.arbeitslohn', 60000),
            entry('de.ind.werbungskosten', 1000),
          ],
          commuteKmOneWay: 25,
          commuteDays: 100,
        ),
      );
      // 2026: 25 km * 0.38 * 100 days = 950 Euro; 1 000 + 950 > 1 230, so the
      // actual costs apply: 60 000 - 1 950 - 36 = 58 014 Euro.
      expect(
        report.lines
            .firstWhere((line) => line.label == 'Zu versteuerndes Einkommen')
            .amountMinor,
        5801400,
      );
      expect(
        report.assumptions.join(' '),
        contains('Entfernungspauschale'),
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
      // The § 35 credit also reduces the Soli base (§ 3 Abs. 2 SolzG):
      // 5.5 % of 50 562 Euro, not of the 55 532 Euro tariff tax.
      expect(liability(report, 'Solidaritätszuschlag'), 278091);
      expect(
        report.lines
            .firstWhere((line) => line.label == 'Anrechnung nach § 35 EStG')
            .amountMinor,
        -497000,
      );
      expect(report.assumptions, contains(contains('§ 35 EStG')));
    });

    test('a linked Freiberufler feeds the profit but earns no § 35 credit', () {
      final business = soleTraderInput(
        [
          entry('de.euer.betriebseinnahmen', 100000),
          entry('de.euer.wareneinkauf', 40000),
        ],
        einkunftsArt: DeEinkunftsArt.freiberuflich,
      );
      final report = rules.report(
        individualInput(
          [entry('de.ind.arbeitslohn', 100000)],
          linked: [business],
        ),
      );
      // Same profit, but no Gewerbesteuer and therefore no § 35 credit:
      // 98 770 + 60 000 - 36 = 158 734 Euro taxed fully.
      expect(liability(report, 'Einkommensteuer'), 5553200);
      expect(
        report.lines.any((line) => line.label == 'Anrechnung nach § 35 EStG'),
        isFalse,
      );
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
      expect(report.rulesVerifiedOn, DateTime.utc(2026, 11, 5));
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
      expect(liability(report, 'Gewerbesteuer'), 497000);
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

    test('a Freiberufler owes no Gewerbesteuer and files Anlage S', () {
      final report = rules.report(
        soleTraderInput([
          entry('de.euer.betriebseinnahmen', 100000),
          entry('de.euer.wareneinkauf', 40000),
        ], einkunftsArt: DeEinkunftsArt.freiberuflich),
      );
      expect(report.liabilities, isEmpty);
      expect(
        report.lines
            .firstWhere(
              (line) =>
                  line.label ==
                  'Gewinn (Betriebseinnahmen ./. Betriebsausgaben)',
            )
            .reportReference,
        contains('Anlage S'),
      );
      expect(
        report.assumptions.join(' '),
        contains('freiberuflich'),
      );
      expect(
        report.assumptions.join(' '),
        isNot(contains('Hebesatz')),
      );
    });

    test('an Arbeitszimmer excludes the Tagespauschale in the EÜR', () {
      final report = rules.report(
        soleTraderInput([
          entry('de.euer.betriebseinnahmen', 30000),
          entry('de.euer.arbeitszimmer', 1260),
          entry('de.euer.homeoffice', 1260),
        ]),
      );
      // 30 000 - 1 260 Arbeitszimmer (Tagespauschale dropped) = 28 740 Euro.
      expect(
        report.lines
            .firstWhere(
              (line) =>
                  line.label ==
                  'Gewinn (Betriebseinnahmen ./. Betriebsausgaben)',
            )
            .amountMinor,
        2874000,
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

    test('company lines reference Anlage GK and ZVE, not KSt 1', () {
      final report = rules.report(
        companyInput([entry('de.co.umsatzerloese', 100000)]),
      );
      final profit = report.lines.firstWhere(
        (line) =>
            line.label == 'Jahresüberschuss/-fehlbetrag (Gewinn vor Steuern)',
      );
      expect(profit.reportReference, contains('Anlage GK'));
      expect(profit.amountMinor, 10000000);
      final taxable = report.lines.firstWhere(
        (line) => line.label.startsWith('Einkommen'),
      );
      expect(taxable.reportReference, contains('Anlage ZVE'));
      expect(taxable.amountMinor, 10000000);
      for (final line in report.lines) {
        expect(line.reportReference, isNot(contains('KSt 1')));
      }
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

    test('the Basisrente row follows the named figure grade per year', () {
      TaxOpportunity basisrente(int year) {
        final input = individualInput(
          [entry('de.ind.arbeitslohn', 100000, year: year)],
          year: year,
        );
        return rules
            .opportunities(input, rules.report(input))
            .firstWhere((item) => item.id == 'de.basisrente_hoechstbetrag');
      }

      final y2026 = basisrente(2026);
      expect(y2026.grade, TaxEvidenceGrade.primary);
      expect(y2026.estimatedSavingMinor, greaterThan(0));
      // The 2025 cap is only derived, so the row is graded inferred and
      // quantifies nothing.
      final y2025 = basisrente(2025);
      expect(y2025.grade, TaxEvidenceGrade.inferred);
      expect(y2025.estimatedSavingMinor, isNull);
    });

    test('filing deadlines roll off weekends (§ 108 Abs. 3 AO)', () {
      // VZ 2026: 31 Jul 2027 is a Saturday, so Monday 2 Aug 2027.
      final input2026 = individualInput([
        entry('de.ind.arbeitslohn', 100000),
      ]);
      final opportunity2026 = rules
          .opportunities(input2026, rules.report(input2026))
          .firstWhere((item) => item.id == 'de.frist_steuererklaerung');
      expect(opportunity2026.deadline, DateTime.utc(2027, 8, 2));
      // VZ 2025: 28 Feb 2027 (advised) is a Sunday, so Monday 1 Mar 2027.
      final input2025 = individualInput(
        [entry('de.ind.arbeitslohn', 100000)],
        year: 2025,
      );
      final report2025 = rules.report(input2025);
      expect(
        report2025.assumptions.join(' '),
        contains('01.03.2027'),
      );
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

    test('the Kleinunternehmer test uses both years and both limits', () {
      List<TaxOpportunity> opportunities({
        required int previousYearMinor,
        required int currentYearEuros,
      }) => rules
          .opportunities(
            soleTraderInput(
              [entry('de.euer.betriebseinnahmen', currentYearEuros)],
              previousYearTurnoverMinor: previousYearMinor,
            ),
            rules.report(
              soleTraderInput(
                [entry('de.euer.betriebseinnahmen', currentYearEuros)],
                previousYearTurnoverMinor: previousYearMinor,
              ),
            ),
          )
          .where((item) => item.id == 'de.kleinunternehmerregelung')
          .toList();

      // 24 999 prior and current under 100 000: exempt.
      expect(
        opportunities(previousYearMinor: 2499900, currentYearEuros: 20000),
        hasLength(1),
      );
      // 25 000 prior is still "at most".
      expect(
        opportunities(previousYearMinor: 2500000, currentYearEuros: 100000),
        hasLength(1),
      );
      // 25 001 prior: regular taxation, no opportunity.
      expect(
        opportunities(previousYearMinor: 2500100, currentYearEuros: 20000),
        isEmpty,
      );
      // Current year crossing 100 000: the 100 001st euro carries VAT.
      expect(
        opportunities(previousYearMinor: 2400000, currentYearEuros: 100001),
        isEmpty,
      );
    });

    test('a shareholder sees the signpost-only salary-or-dividend row', () {
      final company = companyInput([entry('de.co.umsatzerloese', 150000)]);
      final input = individualInput(
        [entry('de.ind.arbeitslohn', 100000)],
        linked: [company],
      );
      final opportunity = rules
          .opportunities(input, rules.report(input))
          .firstWhere((item) => item.id == 'de.geschaeftsfuehrer_vergleich');
      // GmbH owner-pay comparisons are signpost-only under the German
      // perimeter: the row explains the rule, names the vGA risk and
      // quantifies nothing.
      expect(opportunity.signpostOnly, isTrue);
      expect(opportunity.estimatedSavingMinor, isNull);
      expect(opportunity.explanation, contains('verdeckte Gewinnausschüttung'));
      expect(opportunity.explanation, contains('Steuerberater'));
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
      for (final kind in EntityKind.values) {
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
