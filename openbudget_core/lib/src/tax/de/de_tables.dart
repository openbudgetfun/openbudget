import 'package:meta/meta.dart';
import 'package:openbudget_core/src/tax/de/de_tariff.dart';
import 'package:openbudget_core/src/tax/tax_model.dart';
import 'package:openbudget_core/src/tax/tax_rule_pack.dart';

/// Pauschbeträge and caps that § 32a EStG leaves out of the tariff itself.
@immutable
final class DeAllowances {
  const DeAllowances({
    required this.werbungskostenPauschbetrag,
    required this.sonderausgabenPauschbetrag,
    required this.sonderausgabenPauschbetragJoint,
    required this.sparerPauschbetrag,
    required this.sparerPauschbetragJoint,
    required this.homeOfficeDailyAllowance,
    required this.homeOfficeAnnualMax,
    required this.homeOfficeRoomAnnualMax,
    required this.businessMealRateBasisPoints,
    required this.gwgLimit,
  });

  /// § 9a Satz 1 Nr. 1 Buchst. a EStG: Arbeitnehmer-Pauschbetrag.
  final int werbungskostenPauschbetrag;

  /// § 10c Satz 1 EStG.
  final int sonderausgabenPauschbetrag;

  /// § 10c Satz 2 EStG doubles the Pauschbetrag for joint assessment.
  final int sonderausgabenPauschbetragJoint;

  /// § 20 Abs. 9 Satz 1 EStG.
  final int sparerPauschbetrag;

  /// § 20 Abs. 9 Satz 2 EStG.
  final int sparerPauschbetragJoint;

  /// § 4 Abs. 5 Satz 1 Nr. 6c EStG: Tagespauschale.
  final int homeOfficeDailyAllowance;

  /// § 4 Abs. 5 Satz 1 Nr. 6c EStG: annual cap of the Tagespauschale.
  final int homeOfficeAnnualMax;

  /// § 4 Abs. 5 Satz 1 Nr. 6b Satz 3 EStG: Jahrespauschale for a room.
  final int homeOfficeRoomAnnualMax;

  /// § 4 Abs. 5 Satz 1 Nr. 2 EStG: 70 % of a business meal is deductible.
  final int businessMealRateBasisPoints;

  /// § 6 Abs. 2 Satz 1 EStG: GWG threshold, net of input tax.
  final int gwgLimit;
}

/// § 4 SolzG 1995: the surcharge, its Freigrenze and its Milderungszone.
@immutable
final class DeSolidaritySurcharge {
  const DeSolidaritySurcharge({
    required this.rateBasisPoints,
    required this.mildRateBasisPoints,
    required this.freigrenze,
    required this.freigrenzeJoint,
  });

  /// 5.5 % of the income tax.
  final int rateBasisPoints;

  /// 11.9 % of the amount by which the tax exceeds the Freigrenze.
  final int mildRateBasisPoints;

  /// § 3 Abs. 3 Satz 1 Nr. 2 SolzG 1995, applied to the income tax itself.
  final int freigrenze;

  /// § 3 Abs. 3 Satz 1 Nr. 1 SolzG 1995 for joint assessment.
  final int freigrenzeJoint;
}

/// The taxes a business pays on its own profit.
@immutable
final class DeBusinessTaxes {
  const DeBusinessTaxes({
    required this.corporateTaxRateBasisPoints,
    required this.tradeTaxFreeAmount,
    required this.tradeTaxMesszahlBasisPoints,
    required this.assumedTradeTaxHebesatz,
  });

  /// § 23 Abs. 1 KStG.
  final int corporateTaxRateBasisPoints;

  /// § 11 Abs. 1 Satz 3 Nr. 1 GewStG, for natural persons and partnerships.
  final int tradeTaxFreeAmount;

  /// § 11 Abs. 2 GewStG.
  final int tradeTaxMesszahlBasisPoints;

  /// A Hebesatz is set by the municipality (§ 16 GewStG); 400 % is the
  /// assumption this pack computes with.
  final int assumedTradeTaxHebesatz;
}

/// § 12 and § 19 UStG.
@immutable
final class DeVatRules {
  const DeVatRules({
    required this.standardRateBasisPoints,
    required this.reducedRateBasisPoints,
    required this.smallBusinessPreviousYearTurnover,
    required this.smallBusinessCurrentYearTurnover,
  });

  /// § 12 Abs. 1 UStG.
  final int standardRateBasisPoints;

  /// § 12 Abs. 2 UStG, for the supplies listed in Anlage 2.
  final int reducedRateBasisPoints;

  /// § 19 Abs. 1 Satz 1 UStG: the previous year's total turnover.
  final int smallBusinessPreviousYearTurnover;

  /// § 19 Abs. 1 Satz 1 UStG: the current year's total turnover.
  final int smallBusinessCurrentYearTurnover;
}

/// § 7g EStG, the Investitionsabzugsbetrag.
@immutable
final class DeInvestmentDeduction {
  const DeInvestmentDeduction({
    required this.rateBasisPoints,
    required this.maxPerBusiness,
    required this.profitLimit,
  });

  /// § 7g Abs. 1 Satz 1 EStG: up to 50 % of the planned cost.
  final int rateBasisPoints;

  /// § 7g Abs. 1 Satz 4 EStG: the running total per business.
  final int maxPerBusiness;

  /// § 7g Abs. 1 Satz 2 Nr. 1 Buchst. b EStG: the profit ceiling.
  final int profitLimit;
}

/// § 32 EStG and § 31 EStG: the Kinderfreibeträge and the Kindergeld of one
/// year.
@immutable
final class DeChildRules {
  const DeChildRules({
    required this.kinderfreibetragPerChildMinor,
    required this.kindergeldMonthlyMinor,
  });

  /// Kinderfreibetrag plus BEA-Freibetrag for one child, both parents
  /// combined, for a full year. Each parent claims half.
  final int kinderfreibetragPerChildMinor;

  /// Kindergeld per month and child.
  final int kindergeldMonthlyMinor;
}

/// One tier of the Entfernungspauschale: from [fromKm] up to and including
/// [toKm], [minorPerKm] per full kilometre. A null [toKm] is the open top
/// tier.
@immutable
final class DeCommuterTier {
  const DeCommuterTier({
    required this.fromKm,
    required this.minorPerKm,
    this.toKm,
  });

  /// First full kilometre the rate applies to, 1-based.
  final int fromKm;

  /// Last full kilometre, inclusive; null for the open top tier.
  final int? toKm;

  /// Cents per full kilometre, in minor units: `30` is 0.30 Euro.
  final int minorPerKm;
}

/// § 9 Abs. 1 Satz 3 Nr. 4 EStG: the Entfernungspauschale schedule of one
/// year and its annual cap.
@immutable
final class DeCommuterRules {
  const DeCommuterRules({required this.tiers, required this.annualCapMinor});

  /// Ascending by [DeCommuterTier.fromKm], the first tier starts at km 1.
  final List<DeCommuterTier> tiers;

  /// § 9 Abs. 1 Satz 3 Nr. 4 EStG caps the deduction at 4 500 Euro per year,
  /// except for journeys in an own or provided car, which the pack cannot
  /// tell apart.
  final int annualCapMinor;
}

/// Every figure one German tax year needs, in one place.
@immutable
final class DeTaxTable {
  const DeTaxTable({
    required this.startYear,
    required this.tariff,
    required this.solidarity,
    required this.allowances,
    required this.businessTaxes,
    required this.vat,
    required this.investmentDeduction,
    required this.basisrenteMax,
    required this.children,
    required this.commuter,
  });

  final int startYear;
  final DeTariff tariff;
  final DeSolidaritySurcharge solidarity;
  final DeAllowances allowances;
  final DeBusinessTaxes businessTaxes;
  final DeVatRules vat;
  final DeInvestmentDeduction investmentDeduction;

  /// § 10 Abs. 3 Satz 1 EStG caps Vorsorgeaufwendungen at the Höchstbeitrag zur
  /// knappschaftlichen Rentenversicherung, rounded up to whole euros. That is
  /// 24.7 % of the knappschaftliche Beitragsbemessungsgrenze.
  final int basisrenteMax;

  /// Kinderfreibeträge and Kindergeld of the year.
  final DeChildRules children;

  /// Entfernungspauschale schedule of the year.
  final DeCommuterRules commuter;
}

/// The Veranlagungszeiträume this pack knows, keyed by calendar year.
const Map<int, DeTaxTable> deTaxTables = {
  2025: DeTaxTable(
    startYear: 2025,
    tariff: DeTariff(
      grundfreibetrag: 12096,
      zoneOneEnd: 17443,
      zoneTwoEnd: 68480,
      topZoneStart: 277825,
      zoneOneCoefficientHundredths: 93230,
      zoneTwoCoefficientHundredths: 17664,
      zoneTwoOffsetHundredths: 101513,
      zoneThreeOffsetHundredths: 1091192,
      zoneFourOffsetHundredths: 1924667,
    ),
    solidarity: DeSolidaritySurcharge(
      rateBasisPoints: 550,
      mildRateBasisPoints: 1190,
      freigrenze: 1995000,
      freigrenzeJoint: 3990000,
    ),
    allowances: DeAllowances(
      werbungskostenPauschbetrag: 123000,
      sonderausgabenPauschbetrag: 3600,
      sonderausgabenPauschbetragJoint: 7200,
      sparerPauschbetrag: 100000,
      sparerPauschbetragJoint: 200000,
      homeOfficeDailyAllowance: 600,
      homeOfficeAnnualMax: 126000,
      homeOfficeRoomAnnualMax: 126000,
      businessMealRateBasisPoints: 7000,
      gwgLimit: 80000,
    ),
    businessTaxes: DeBusinessTaxes(
      corporateTaxRateBasisPoints: 1500,
      tradeTaxFreeAmount: 2450000,
      tradeTaxMesszahlBasisPoints: 350,
      assumedTradeTaxHebesatz: 400,
    ),
    vat: DeVatRules(
      standardRateBasisPoints: 1900,
      reducedRateBasisPoints: 700,
      smallBusinessPreviousYearTurnover: 2500000,
      smallBusinessCurrentYearTurnover: 10000000,
    ),
    investmentDeduction: DeInvestmentDeduction(
      rateBasisPoints: 5000,
      maxPerBusiness: 20000000,
      profitLimit: 20000000,
    ),
    // Kinderfreibetrag plus BEA 9 600 per child (secondary; the itemisation
    // 6 672 + 2 928 is inferred, only the total is sourced), Kindergeld 255
    // per month.
    children: DeChildRules(
      kinderfreibetragPerChildMinor: 960000,
      kindergeldMonthlyMinor: 25500,
    ),
    // § 9 Abs. 1 Satz 3 Nr. 4 EStG 2025: 0.30 Euro for km 1 to 20, 0.38 Euro
    // from km 21 (Anleitung Anlage N 2025).
    commuter: DeCommuterRules(
      tiers: [
        DeCommuterTier(fromKm: 1, toKm: 20, minorPerKm: 30),
        DeCommuterTier(fromKm: 21, minorPerKm: 38),
      ],
      annualCapMinor: 450000,
    ),
    basisrenteMax: 2934400,
  ),
  2026: DeTaxTable(
    startYear: 2026,
    tariff: DeTariff(
      grundfreibetrag: 12348,
      zoneOneEnd: 17799,
      zoneTwoEnd: 69878,
      topZoneStart: 277825,
      zoneOneCoefficientHundredths: 91451,
      zoneTwoCoefficientHundredths: 17310,
      zoneTwoOffsetHundredths: 103487,
      zoneThreeOffsetHundredths: 1113563,
      zoneFourOffsetHundredths: 1947038,
    ),
    solidarity: DeSolidaritySurcharge(
      rateBasisPoints: 550,
      mildRateBasisPoints: 1190,
      freigrenze: 2035000,
      freigrenzeJoint: 4070000,
    ),
    allowances: DeAllowances(
      werbungskostenPauschbetrag: 123000,
      sonderausgabenPauschbetrag: 3600,
      sonderausgabenPauschbetragJoint: 7200,
      sparerPauschbetrag: 100000,
      sparerPauschbetragJoint: 200000,
      homeOfficeDailyAllowance: 600,
      homeOfficeAnnualMax: 126000,
      homeOfficeRoomAnnualMax: 126000,
      businessMealRateBasisPoints: 7000,
      gwgLimit: 80000,
    ),
    businessTaxes: DeBusinessTaxes(
      corporateTaxRateBasisPoints: 1500,
      tradeTaxFreeAmount: 2450000,
      tradeTaxMesszahlBasisPoints: 350,
      assumedTradeTaxHebesatz: 400,
    ),
    vat: DeVatRules(
      standardRateBasisPoints: 1900,
      reducedRateBasisPoints: 700,
      smallBusinessPreviousYearTurnover: 2500000,
      smallBusinessCurrentYearTurnover: 10000000,
    ),
    investmentDeduction: DeInvestmentDeduction(
      rateBasisPoints: 5000,
      maxPerBusiness: 20000000,
      profitLimit: 20000000,
    ),
    // Kinderfreibetrag 6 828 plus BEA 2 928 = 9 756 per child, Kindergeld 259
    // per month (secondary, familienservice.de and steuerberater-tabak.com).
    children: DeChildRules(
      kinderfreibetragPerChildMinor: 975600,
      kindergeldMonthlyMinor: 25900,
    ),
    // § 9 Abs. 1 Satz 3 Nr. 4 EStG from 1 Jan 2026 (Steueränderungsgesetz
    // 2025, BGBl. 2025 I Nr. 363): 0.38 Euro for every full kilometre.
    commuter: DeCommuterRules(
      tiers: [DeCommuterTier(fromKm: 1, minorPerKm: 38)],
      annualCapMinor: 450000,
    ),
    basisrenteMax: 3082600,
  ),
};

/// The day the figures in [deTaxTables] were last checked.
final DateTime deRulesVerifiedOn = DateTime.utc(2026, 11, 5);

/// The pages every figure came from.
final List<Uri> deSources = List.unmodifiable([
  Uri.parse('https://www.gesetze-im-internet.de/estg/__32a.html'),
  Uri.parse('https://www.bmf-steuerrechner.de/interface/programmablauf.xhtml'),
  Uri.parse(
    'https://www.bmf-steuerrechner.de/javax.faces.resource/2025_10_14_Tarifhistorie_Steuerrechner.pdf.xhtml',
  ),
  Uri.parse('https://www.recht.bund.de/bgbl/1/2024/449/regelungstext.pdf'),
  Uri.parse('https://www.gesetze-im-internet.de/solzg_1995/__3.html'),
  Uri.parse('https://www.gesetze-im-internet.de/solzg_1995/__4.html'),
  Uri.parse('https://www.gesetze-im-internet.de/estg/__4.html'),
  Uri.parse('https://www.gesetze-im-internet.de/estg/__6.html'),
  Uri.parse('https://www.gesetze-im-internet.de/estg/__7g.html'),
  Uri.parse('https://www.gesetze-im-internet.de/estg/__9.html'),
  Uri.parse('https://www.gesetze-im-internet.de/estg/__9a.html'),
  Uri.parse('https://www.gesetze-im-internet.de/estg/__10.html'),
  Uri.parse('https://www.gesetze-im-internet.de/estg/__10c.html'),
  Uri.parse('https://www.gesetze-im-internet.de/estg/__20.html'),
  Uri.parse('https://www.gesetze-im-internet.de/estg/__31.html'),
  Uri.parse('https://www.gesetze-im-internet.de/estg/__32d.html'),
  Uri.parse('https://www.gesetze-im-internet.de/estg/__35.html'),
  Uri.parse('https://www.gesetze-im-internet.de/estg/__51a.html'),
  Uri.parse('https://www.gesetze-im-internet.de/gewstg/__11.html'),
  Uri.parse('https://www.gesetze-im-internet.de/gewstg/__16.html'),
  Uri.parse('https://www.gesetze-im-internet.de/kstg_1977/__23.html'),
  Uri.parse('https://www.gesetze-im-internet.de/ustg_1980/__12.html'),
  Uri.parse('https://www.gesetze-im-internet.de/ustg_1980/__19.html'),
  Uri.parse('https://www.gesetze-im-internet.de/ao_1977/__108.html'),
  Uri.parse('https://www.gesetze-im-internet.de/ao_1977/__149.html'),
  Uri.parse('https://www.gesetze-im-internet.de/svbezgrv_2025/__4.html'),
  Uri.parse('https://www.gesetze-im-internet.de/svbezgrv_2026/__4.html'),
  Uri.parse('https://www.gesetze-im-internet.de/rvbeitrsbek_2025/----.html'),
  Uri.parse('https://www.gesetze-im-internet.de/rvbeitrsbek_2026/----.html'),
]);

/// The named figures knowledge cards quote for [table]'s year, each with
/// the page it came from. The values are the tables' own; naming them adds
/// no new number. The 2025 Soli Freigrenze and Basisrente cap carry the
/// grades the germany-tax skill recorded.
Map<String, TaxFigure> deFiguresFor(DeTaxTable table) {
  final y2025 = table.startYear == 2025;
  return Map.unmodifiable({
    for (final figure in [
      TaxFigure(
        id: 'grundfreibetrag',
        value: table.tariff.grundfreibetrag * 100,
        unit: TaxFigureUnit.currencyMinor,
        source: Uri.parse('https://www.gesetze-im-internet.de/estg/__32a.html'),
        grade: TaxEvidenceGrade.primary,
        verifiedOn: deRulesVerifiedOn,
      ),
      TaxFigure(
        id: 'sparerPauschbetrag',
        value: table.allowances.sparerPauschbetrag,
        unit: TaxFigureUnit.currencyMinor,
        source: Uri.parse('https://www.gesetze-im-internet.de/estg/__20.html'),
        grade: TaxEvidenceGrade.primary,
        verifiedOn: deRulesVerifiedOn,
      ),
      TaxFigure(
        id: 'werbungskostenPauschbetrag',
        value: table.allowances.werbungskostenPauschbetrag,
        unit: TaxFigureUnit.currencyMinor,
        source: Uri.parse('https://www.gesetze-im-internet.de/estg/__9a.html'),
        grade: TaxEvidenceGrade.primary,
        verifiedOn: deRulesVerifiedOn,
      ),
      TaxFigure(
        id: 'soliFreigrenze',
        value: table.solidarity.freigrenze,
        unit: TaxFigureUnit.currencyMinor,
        source: Uri.parse(
          'https://www.gesetze-im-internet.de/solzg_1995/__3.html',
        ),
        grade: y2025 ? TaxEvidenceGrade.secondary : TaxEvidenceGrade.primary,
        verifiedOn: deRulesVerifiedOn,
      ),
      TaxFigure(
        id: 'basisrenteCap',
        value: table.basisrenteMax,
        unit: TaxFigureUnit.currencyMinor,
        source: Uri.parse('https://www.gesetze-im-internet.de/estg/__10.html'),
        grade: y2025 ? TaxEvidenceGrade.inferred : TaxEvidenceGrade.primary,
        verifiedOn: deRulesVerifiedOn,
      ),
      TaxFigure(
        id: 'gewerbesteuerFreibetrag',
        value: table.businessTaxes.tradeTaxFreeAmount,
        unit: TaxFigureUnit.currencyMinor,
        source: Uri.parse(
          'https://www.gesetze-im-internet.de/gewstg/__11.html',
        ),
        grade: TaxEvidenceGrade.primary,
        verifiedOn: deRulesVerifiedOn,
      ),
      TaxFigure(
        id: 'koerperschaftsteuerRate',
        value: table.businessTaxes.corporateTaxRateBasisPoints,
        unit: TaxFigureUnit.rateBasisPoints,
        source: Uri.parse(
          'https://www.gesetze-im-internet.de/kstg_1977/__23.html',
        ),
        grade: TaxEvidenceGrade.primary,
        verifiedOn: deRulesVerifiedOn,
      ),
      TaxFigure(
        id: 'ustStandardRate',
        value: table.vat.standardRateBasisPoints,
        unit: TaxFigureUnit.rateBasisPoints,
        source: Uri.parse(
          'https://www.gesetze-im-internet.de/ustg_1980/__12.html',
        ),
        grade: TaxEvidenceGrade.primary,
        verifiedOn: deRulesVerifiedOn,
      ),
      TaxFigure(
        id: 'ustReducedRate',
        value: table.vat.reducedRateBasisPoints,
        unit: TaxFigureUnit.rateBasisPoints,
        source: Uri.parse(
          'https://www.gesetze-im-internet.de/ustg_1980/__12.html',
        ),
        grade: TaxEvidenceGrade.primary,
        verifiedOn: deRulesVerifiedOn,
      ),
      TaxFigure(
        id: 'kleinunternehmerPreviousYearLimit',
        value: table.vat.smallBusinessPreviousYearTurnover,
        unit: TaxFigureUnit.currencyMinor,
        source: Uri.parse(
          'https://www.gesetze-im-internet.de/ustg_1980/__19.html',
        ),
        grade: TaxEvidenceGrade.primary,
        verifiedOn: deRulesVerifiedOn,
      ),
    ])
      figure.id: figure,
  });
}

/// What the germany-tax skill could not verify, as data (its "Unverified
/// and changing" list). Re-check dates follow that list.
final List<TaxRuleCaveat> deRuleCaveats = [
  TaxRuleCaveat(
    id: 'de.est-2026-forms',
    text:
        'The 2026 ESt forms (Anlage N, S, G, KAP, V, Vorsorgeaufwand, '
        'Sonderausgaben, AUS) were not published as of 5 November 2026, so '
        'checklists use the 2025 lines.',
    grade: TaxEvidenceGrade.inferred,
    sections: const {TaxSection.personalReturn, TaxSection.selfEmployment},
    recheckBy: DateTime.utc(2026, 12, 31),
  ),
  TaxRuleCaveat(
    id: 'de.soli-2025-secondary',
    text:
        'The 2025 Soli Freigrenze of 19,950 euro and the 2025 zone '
        'constant of 19,246.67 are secondary; they must be checked against '
        'BGBl. 2024 I Nr. 449 and the BMF Tarifhistorie.',
    grade: TaxEvidenceGrade.secondary,
    sections: const {TaxSection.personalReturn},
    recheckBy: DateTime.utc(2026, 12, 31),
  ),
  TaxRuleCaveat(
    id: 'de.basisrente-2025',
    text:
        'The 2025 Basisrente cap of 29,344 euro and its doubling for joint '
        'assessment were not in the research.',
    grade: TaxEvidenceGrade.inferred,
    sections: const {TaxSection.personalReturn},
    recheckBy: DateTime.utc(2026, 12, 31),
  ),
  TaxRuleCaveat(
    id: 'de.church-tax-details',
    text:
        'Kirchensteuer Kappung, state rates beyond 8 and 9 per cent and '
        'the rounding of church tax were not researched.',
    grade: TaxEvidenceGrade.inferred,
    sections: const {TaxSection.personalReturn},
    recheckBy: DateTime.utc(2026, 12, 31),
  ),
  TaxRuleCaveat(
    id: 'de.entfernungspauschale-2026-source',
    text:
        'The 2026 Entfernungspauschale statutory reference (BGBl. 2025 I '
        'Nr. 363) comes from a secondary source.',
    grade: TaxEvidenceGrade.secondary,
    sections: const {TaxSection.personalReturn, TaxSection.selfEmployment},
    recheckBy: DateTime.utc(2026, 12, 31),
  ),
  TaxRuleCaveat(
    id: 'de.announced-2027',
    text:
        'Announced but not enacted as of 5 November 2026: the 2027 income '
        'tax reform draft, a 280 per cent Gewerbesteuer minimum Hebesatz '
        'from 2027, the 2027 social-security contribution ceilings, the 633 '
        'euro Minijob limit and the 14.60 euro minimum wage.',
    grade: TaxEvidenceGrade.secondary,
    sections: const {
      TaxSection.personalReturn,
      TaxSection.selfEmployment,
      TaxSection.companyReturn,
    },
    recheckBy: DateTime.utc(2026, 12, 31),
    announced: true,
  ),
  TaxRuleCaveat(
    id: 'de.not-researched-topics',
    text:
        'The Übungsleiter and Ehrenamt allowances, the 2026 restaurant VAT '
        'rate, §233a AO interest, Pflichtveranlagung, the §34c foreign tax '
        'credit detail, the U1/U2/U3 levies, E-Bilanz, the KSt and GewSt '
        'form Kennzahlen, the Lohnsteuer PAP and vGA criteria were not '
        'researched.',
    grade: TaxEvidenceGrade.inferred,
    sections: const {TaxSection.companyReturn, TaxSection.payroll},
    recheckBy: DateTime.utc(2026, 12, 31),
  ),
  TaxRuleCaveat(
    id: 'de.anlage-lines',
    text:
        'Anlage V lines below Z54 and the Anlage KAP lines after 2025 '
        '(which reportedly shift) need a read of the official form.',
    grade: TaxEvidenceGrade.inferred,
    sections: const {TaxSection.personalReturn},
    recheckBy: DateTime.utc(2026, 12, 31),
  ),
];

/// The version, sources, verification date, caveats and named figures of
/// each supported year.
final Map<int, TaxRuleSet> deRuleSetsByStartYear = Map.unmodifiable({
  for (final entry in deTaxTables.entries)
    entry.key: TaxRuleSet(
      startYear: entry.key,
      revision: 1,
      verifiedOn: deRulesVerifiedOn,
      sources: deSources,
      caveats: deRuleCaveats,
      figures: deFiguresFor(entry.value),
    ),
});

/// The rule set for [startYear], or the unsupported-year error.
TaxRuleSet deRuleSetFor(int startYear) {
  final ruleSet = deRuleSetsByStartYear[startYear];
  if (ruleSet == null) {
    throw UnsupportedTaxYearException(TaxJurisdiction.de, startYear);
  }
  return ruleSet;
}

/// What the German pack covers, and how mature it is.
///
/// The company return covers Körperschaftsteuer, Gewerbesteuer and
/// Solidaritätszuschlag but not a full tax balance sheet. Indirect tax
/// covers the Umsatzsteuer from line data and the Kleinunternehmer test, not
/// every Voranmeldung box. Capital gains cover investment income, not share
/// disposals. Digital assets and payroll are not built.
const TaxPackManifest deTaxManifest = TaxPackManifest(
  maturity: TaxPackMaturity.preview,
  sections: {
    TaxSection.personalReturn: TaxSectionCoverage.full,
    TaxSection.selfEmployment: TaxSectionCoverage.full,
    TaxSection.companyReturn: TaxSectionCoverage.partial,
    TaxSection.indirectTax: TaxSectionCoverage.partial,
    TaxSection.capitalGains: TaxSectionCoverage.partial,
    TaxSection.digitalAssets: TaxSectionCoverage.notBuilt,
    TaxSection.filingCalendar: TaxSectionCoverage.partial,
    TaxSection.payroll: TaxSectionCoverage.notBuilt,
  },
);

/// § 149 Abs. 2 AO: seven months after the end of the calendar year, moved
/// forward by [deRollForward] when it falls on a weekend or holiday.
DateTime deFilingDeadline(int startYear) =>
    deRollForward(DateTime.utc(startYear + 1, 7, 31));

/// § 149 Abs. 3 AO: the last day of February in the second following year,
/// moved forward by [deRollForward].
///
/// For the Veranlagungszeiträume before 2025 the Übergangsfristen of
/// Art. 97 § 36 Abs. 3 EGAO replace that rule: 30 Apr 2026 for VZ 2024,
/// 31 May 2025 for VZ 2023, 31 Jul 2024 for VZ 2022, 31 Aug 2023 for VZ
/// 2021 and 31 Aug 2022 for VZ 2020. From VZ 2025 on the general rule
/// applies again.
DateTime deAdvisorFilingDeadline(int startYear) {
  final transition = _advisedTransitionDeadlines[startYear];
  return deRollForward(
    transition ?? DateTime.utc(startYear + 2, 3, 0),
  );
}

/// The Art. 97 § 36 Abs. 3 EGAO advised deadlines, keyed by Veranlagungszeitraum.
final Map<int, DateTime> _advisedTransitionDeadlines = {
  2024: DateTime.utc(2026, 4, 30),
  2023: DateTime.utc(2025, 5, 31),
  2022: DateTime.utc(2024, 7, 31),
  2021: DateTime.utc(2023, 8, 31),
  2020: DateTime.utc(2022, 8, 31),
};

/// § 108 Abs. 3 AO: a deadline that falls on a Saturday, Sunday or public
/// holiday moves to the next working day.
///
/// The holiday check covers the nationwide Feiertage only. Länder-specific
/// holidays (Fronleichnam, Allerheiligen, Reformationstag, Buß- und Bettag
/// and the like) are not modelled, so in a Land with such a holiday the
/// shown deadline can be a day earlier than the law allows, never later.
/// That errs towards filing on time.
DateTime deRollForward(DateTime deadline) {
  var day = DateTime.utc(deadline.year, deadline.month, deadline.day);
  while (_isRestDay(day)) {
    day = DateTime.utc(day.year, day.month, day.day + 1);
  }
  return day;
}

bool _isRestDay(DateTime day) =>
    day.weekday == DateTime.saturday ||
    day.weekday == DateTime.sunday ||
    _nationwideHolidays(day.year).contains(day);

/// The Feiertage every Land observes (§ 2 Abs. 1 Feiertagsgesetz der Länder
/// in derselben Fassung): Neujahr, Karfreitag, Ostermontag, Tag der Arbeit,
/// Christi Himmelfahrt, Pfingstmontag, Tag der Deutschen Einheit and the
/// two Weihnachtstage.
Set<DateTime> _nationwideHolidays(int year) {
  final easterSunday = _easterSunday(year);
  DateTime dayOf(int month, int day) => DateTime.utc(year, month, day);
  DateTime fromEaster(int days) => DateTime.utc(
    easterSunday.year,
    easterSunday.month,
    easterSunday.day + days,
  );
  return {
    dayOf(1, 1),
    fromEaster(-2), // Karfreitag
    fromEaster(1), // Ostermontag
    dayOf(5, 1),
    fromEaster(39), // Christi Himmelfahrt
    fromEaster(50), // Pfingstmontag
    dayOf(10, 3),
    dayOf(12, 25),
    dayOf(12, 26),
  };
}

/// Anonymous Gregorian algorithm (Meeus/Jones/Butcher): Easter Sunday of
/// [year], the anchor of the movable Feiertage.
DateTime _easterSunday(int year) {
  final a = year % 19;
  final b = year ~/ 100;
  final c = year % 100;
  final d = b ~/ 4;
  final e = b % 4;
  final f = (b + 8) ~/ 25;
  final g = (b - f + 1) ~/ 3;
  final h = (19 * a + b - d - g + 15) % 30;
  final i = c ~/ 4;
  final k = c % 4;
  final l = (32 + 2 * e + 2 * i - h - k) % 7;
  final m = (a + 11 * h + 22 * l) ~/ 451;
  final month = (h + l - 7 * m + 114) ~/ 31;
  final day = (h + l - 7 * m + 114) % 31 + 1;
  return DateTime.utc(year, month, day);
}
