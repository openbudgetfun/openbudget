import 'package:meta/meta.dart';
import 'package:openbudget_core/src/tax/de/de_tariff.dart';

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
    basisrenteMax: 3082600,
  ),
};

/// The Kirchensteuer this pack assumes: 9 % of the income tax.
///
/// Kirchensteuer is state and church law, not federal law. Bayern and
/// Baden-Württemberg levy 8 %, which this pack does not model; it states the
/// 9 % assumption in every report that charges it.
const int deKirchensteuerRateBasisPoints = 900;

/// The day the figures in [deTaxTables] were last checked.
final DateTime deRulesVerifiedOn = DateTime.utc(2026, 11, 4);

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
  Uri.parse('https://www.gesetze-im-internet.de/estg/__9a.html'),
  Uri.parse('https://www.gesetze-im-internet.de/estg/__10.html'),
  Uri.parse('https://www.gesetze-im-internet.de/estg/__10c.html'),
  Uri.parse('https://www.gesetze-im-internet.de/estg/__20.html'),
  Uri.parse('https://www.gesetze-im-internet.de/estg/__32d.html'),
  Uri.parse('https://www.gesetze-im-internet.de/estg/__35.html'),
  Uri.parse('https://www.gesetze-im-internet.de/gewstg/__11.html'),
  Uri.parse('https://www.gesetze-im-internet.de/gewstg/__16.html'),
  Uri.parse('https://www.gesetze-im-internet.de/kstg_1977/__23.html'),
  Uri.parse('https://www.gesetze-im-internet.de/ustg_1980/__12.html'),
  Uri.parse('https://www.gesetze-im-internet.de/ustg_1980/__19.html'),
  Uri.parse('https://www.gesetze-im-internet.de/ao_1977/__149.html'),
  Uri.parse('https://www.gesetze-im-internet.de/svbezgrv_2025/__4.html'),
  Uri.parse('https://www.gesetze-im-internet.de/svbezgrv_2026/__4.html'),
  Uri.parse('https://www.gesetze-im-internet.de/rvbeitrsbek_2025/----.html'),
  Uri.parse('https://www.gesetze-im-internet.de/rvbeitrsbek_2026/----.html'),
]);

/// § 149 Abs. 2 AO: seven months after the end of the calendar year.
DateTime deFilingDeadline(int startYear) => DateTime.utc(startYear + 1, 7, 31);

/// § 149 Abs. 3 AO: the last day of February in the second following year.
DateTime deAdvisorFilingDeadline(int startYear) =>
    DateTime.utc(startYear + 2, 3, 0);
