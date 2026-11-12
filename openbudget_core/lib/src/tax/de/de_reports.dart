import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:openbudget_core/src/tax/de/de_assessment.dart';
import 'package:openbudget_core/src/tax/de/de_categories.dart';
import 'package:openbudget_core/src/tax/de/de_format.dart';
import 'package:openbudget_core/src/tax/de/de_tables.dart';
import 'package:openbudget_core/src/tax/de/de_tariff.dart';
import 'package:openbudget_core/src/tax/tax_model.dart';
import 'package:openbudget_core/src/tax/tax_profile.dart';
import 'package:openbudget_core/src/tax/tax_rule_pack.dart';

/// A sole trader's EÜR, reduced to the figures the report needs.
typedef DeEuerResult = ({
  Map<String, int> totals,
  int profitMinor,
  int messbetragMinor,
  int tradeTaxMinor,
});

/// A company's profit and the taxes computed on it.
typedef DeCompanyResult = ({
  Map<String, int> totals,
  int profitMinor,
  int messbetragMinor,
  int corporateTaxMinor,
  int solidarityMinor,
  int tradeTaxMinor,
  int vatDueMinor,
});

/// Every figure of one person's Einkommensteuer assessment.
///
/// The report and the opportunities both read this, so a recommendation can
/// never quote a different marginal rate than the liability above it.
@immutable
final class DeIndividualAssessment {
  const DeIndividualAssessment({
    required this.totals,
    required this.employment,
    required this.employedSpouses,
    required this.werbungskosten,
    required this.werbungskostenPauschbetrag,
    required this.usesWerbungskostenPauschbetrag,
    required this.homeoffice,
    required this.arbeitszimmer,
    required this.entfernungspauschale,
    required this.businessProfit,
    required this.otherIncome,
    required this.capitalIncome,
    required this.sparerPauschbetrag,
    required this.capitalBase,
    required this.basisrentePaid,
    required this.basisrenteCap,
    required this.basisrente,
    required this.statutoryPension,
    required this.donations,
    required this.sonderausgaben,
    required this.children,
    required this.kinderfreibetrag,
    required this.kindergeld,
    required this.usesKinderfreibetrag,
    required this.taxableIncome,
    required this.surchargeBase,
    required this.marginalRateBasisPoints,
    required this.tariffTax,
    required this.section35Credit,
    required this.incomeTax,
    required this.solidarity,
    required this.churchTaxRateBasisPoints,
    required this.churchTax,
    required this.capitalIncomeTax,
    required this.capitalSolidarity,
    required this.lohnsteuer,
    required this.kapitalertragsteuer,
  });

  final Map<String, int> totals;
  final int employment;

  /// How many employed spouses the assessment covers: two under
  /// Zusammenveranlagung when the spouse earns wages too, one otherwise,
  /// zero without wage income.
  final int employedSpouses;
  final int werbungskosten;

  /// The Arbeitnehmer-Pauschbetrag applied in total, once per employed
  /// spouse.
  final int werbungskostenPauschbetrag;
  final bool usesWerbungskostenPauschbetrag;

  /// The Homeoffice-Tagespauschale after the € 6 day floor, the annual cap
  /// and the Arbeitszimmer exclusion.
  final int homeoffice;

  /// The Häusliches Arbeitszimmer claim. When it is set, the Tagespauschale
  /// is not applied, because the two claims must not overlap in time.
  final int arbeitszimmer;

  /// The Entfernungspauschale of § 9 Abs. 1 Satz 3 Nr. 4 EStG.
  final int entfernungspauschale;
  final int businessProfit;
  final int otherIncome;
  final int capitalIncome;
  final int sparerPauschbetrag;
  final int capitalBase;
  final int basisrentePaid;

  /// The Höchstbetrag this assessment can use: doubled under
  /// Zusammenveranlagung, reduced by the statutory pension contributions.
  final int basisrenteCap;
  final int basisrente;
  final int statutoryPension;
  final int donations;
  final int sonderausgaben;
  final int children;

  /// The Kinderfreibeträge the tax was recomputed with. § 3 Abs. 2 SolzG and
  /// § 51a Abs. 1 EStG base the Solidaritätszuschlag and the Kirchensteuer
  /// on the tax with Kinderfreibeträge in all cases, even when the
  /// Günstigerprüfung kept the Kindergeld.
  final int kinderfreibetrag;

  /// The Kindergeld of a full year, what the Günstigerprüfung compares
  /// against.
  final int kindergeld;
  final bool usesKinderfreibetrag;
  final int taxableIncome;

  /// The income tax the Zuschlagsteuern are computed on: the tariff with
  /// Kinderfreibeträge less the § 35 credit on that tariff, without the
  /// Kindergeld add-back (§ 3 Abs. 2 SolzG, § 51a Abs. 1 EStG).
  final int surchargeBase;
  final int marginalRateBasisPoints;
  final int tariffTax;
  final int section35Credit;
  final int incomeTax;
  final int solidarity;
  final int churchTaxRateBasisPoints;
  final int churchTax;
  final int capitalIncomeTax;
  final int capitalSolidarity;
  final int lohnsteuer;
  final int kapitalertragsteuer;
}

/// Computes the German report for [input].
///
/// The report's lines carry expenses and reliefs with a negative amount, so a
/// section adds up to its profit or taxable income. Liabilities are positive,
/// except an Umsatzsteuer credit, which the report shows as a negative
/// liability.
TaxReport deReport(TaxInput input, DeTaxTable table) {
  final profile = input.profile;
  if (profile is! DeTaxProfile) {
    throw ArgumentError.value(
      profile,
      'input.profile',
      'is not a German tax profile',
    );
  }
  return switch (profile.entityKind) {
    EntityKind.individual => _individualReport(input, profile, table),
    EntityKind.soleTrader => _soleTraderReport(input, profile, table),
    EntityKind.company => _companyReport(input, profile, table),
  };
}

/// Whether the business charges and reclaims Umsatzsteuer.
bool deChargesVat(DeTaxProfile profile) =>
    profile.salesTaxRegistered && !profile.smallBusinessExemption;

/// The EÜR of one sole trader.
DeEuerResult deEuer(TaxInput input, DeTaxTable table) {
  final profile = input.profile as DeTaxProfile;
  final totals = _totalsFor(
    input,
    netAmounts: deChargesVat(profile),
    table: table,
  );
  // § 4 Abs. 5 Satz 1 Nr. 6b und 6c EStG: the Arbeitszimmer excludes the
  // Tagespauschale, the same rule the personal return applies.
  if ((totals['de.euer.arbeitszimmer'] ?? 0) > 0 &&
      (totals['de.euer.homeoffice'] ?? 0) != 0) {
    totals['de.euer.homeoffice'] = 0;
  }
  final profit = _balance(totals);
  // A Freiberufler owes no Gewerbesteuer (§ 2 Abs. 1 Satz 1 Nr. 3 GewStG,
  // § 18 EStG); only a Gewerbebetrieb is measured.
  final isGewerblich = profile.einkunftsArt == DeEinkunftsArt.gewerblich;
  final messbetrag = isGewerblich
      ? deTradeTaxMessbetragMinor(
          profitMinor: profit,
          freeAmountMinor: table.businessTaxes.tradeTaxFreeAmount,
          messzahlBasisPoints: table.businessTaxes.tradeTaxMesszahlBasisPoints,
        )
      : 0;
  return (
    totals: totals,
    profitMinor: profit,
    messbetragMinor: messbetrag,
    tradeTaxMinor: deTradeTaxMinor(
      messbetragMinor: messbetrag,
      hebesatz: table.businessTaxes.assumedTradeTaxHebesatz,
    ),
  );
}

/// The profit of one company and the taxes computed on it.
DeCompanyResult deCompanyResult(TaxInput input, DeTaxTable table) {
  final profile = input.profile as DeTaxProfile;
  final totals = _totalsFor(
    input,
    netAmounts: deChargesVat(profile),
    table: table,
  );
  final profit = _balance(totals);
  final taxable = math.max(0, profit);
  final corporateTax =
      taxable * table.businessTaxes.corporateTaxRateBasisPoints ~/ 10000;
  final messbetrag = deTradeTaxMessbetragMinor(
    profitMinor: taxable,
    freeAmountMinor: 0,
    messzahlBasisPoints: table.businessTaxes.tradeTaxMesszahlBasisPoints,
  );
  return (
    totals: totals,
    profitMinor: profit,
    messbetragMinor: messbetrag,
    corporateTaxMinor: corporateTax,
    solidarityMinor: corporateTax * 55 ~/ 1000,
    tradeTaxMinor: deTradeTaxMinor(
      messbetragMinor: messbetrag,
      hebesatz: table.businessTaxes.assumedTradeTaxHebesatz,
    ),
    vatDueMinor:
        (totals['de.ust.ausgang'] ?? 0) - (totals['de.ust.eingang'] ?? 0),
  );
}

/// The Einkommensteuer assessment of one person.
DeIndividualAssessment deIndividual(TaxInput input, DeTaxTable table) {
  final profile = input.profile as DeTaxProfile;
  final allowances = table.allowances;
  final totals = _totalsFor(input, netAmounts: false, table: table);

  final employment = totals['de.ind.arbeitslohn'] ?? 0;
  final arbeitszimmer = totals['de.ind.arbeitszimmer'] ?? 0;
  // § 4 Abs. 5 Satz 1 Nr. 6b und 6c EStG: the Arbeitszimmer and the
  // Tagespauschale must not be claimed for the same period, so the pack
  // applies the Tagespauschale only when no Arbeitszimmer is claimed. The
  // Tagespauschale is 6 Euro per whole day and capped at the year's annual
  // cap, so a claim is floored to whole days before the cap applies.
  final homeoffice = arbeitszimmer > 0
      ? 0
      : _homeofficeTagespauschale(totals['de.ind.homeoffice'] ?? 0, table);
  final entfernungspauschale = deEntfernungspauschaleMinor(
    days: profile.commuteDays,
    kmOneWay: profile.commuteKmOneWay,
    rules: table.commuter,
  );

  final actualWerbungskosten =
      (totals['de.ind.werbungskosten'] ?? 0) +
      homeoffice +
      arbeitszimmer +
      entfernungspauschale;
  // § 9a Satz 1 Nr. 1 a EStG: every employed spouse claims their own
  // Arbeitnehmer-Pauschbetrag and files their own Anlage N. The books hold
  // one shared pot of Werbungskosten, so the Pauschbetrag is compared with
  // the pot in total.
  final employedSpouses = employment <= 0
      ? 0
      : profile.jointAssessment && profile.spouseEmployed
      ? 2
      : 1;
  final pauschbetrag = employedSpouses * allowances.werbungskostenPauschbetrag;
  final usesPauschbetrag =
      employment > 0 && actualWerbungskosten <= pauschbetrag;
  final werbungskosten = employment <= 0
      ? 0
      : usesPauschbetrag
      ? pauschbetrag
      : actualWerbungskosten;
  final employmentIncome = employment - werbungskosten;

  var businessProfit = 0;
  var tradeTaxMessbetrag = 0;
  var tradeTaxPaidByBusinesses = 0;
  for (final linked in input.linked) {
    final linkedProfile = linked.profile;
    if (linkedProfile is DeTaxProfile &&
        linkedProfile.entityKind == EntityKind.soleTrader &&
        linkedProfile.einkunftsArt == DeEinkunftsArt.gewerblich) {
      // Only a Gewerbebetrieb pays Gewerbesteuer and earns the § 35 credit;
      // a Freiberufler files Anlage S and owes none.
      final business = deEuer(linked, table);
      businessProfit += business.profitMinor;
      tradeTaxMessbetrag += business.messbetragMinor;
      tradeTaxPaidByBusinesses += business.tradeTaxMinor;
    } else if (linkedProfile is DeTaxProfile &&
        linkedProfile.entityKind == EntityKind.soleTrader) {
      businessProfit += deEuer(linked, table).profitMinor;
    }
  }

  final otherIncome = totals['de.ind.sonstige_einkuenfte'] ?? 0;
  final capitalIncome = totals['de.ind.kapitalertraege'] ?? 0;
  final sparer = profile.jointAssessment
      ? allowances.sparerPauschbetragJoint
      : allowances.sparerPauschbetrag;
  final capitalBase = math.max(0, capitalIncome - sparer);

  final basisrentePaid = totals['de.ind.basisrente'] ?? 0;
  final statutoryPension = profile.statutoryPensionMinor;
  final basisrenteCap = deBasisrenteCapMinor(
    basisrenteMaxMinor: table.basisrenteMax,
    jointAssessment: profile.jointAssessment,
    statutoryPensionMinor: statutoryPension,
  );
  final basisrente = math.min(basisrentePaid, basisrenteCap);
  final donations = totals['de.ind.spenden'] ?? 0;
  final sonderausgabenPauschbetrag = profile.jointAssessment
      ? allowances.sonderausgabenPauschbetragJoint
      : allowances.sonderausgabenPauschbetrag;
  final sonderausgaben = math.max(donations, sonderausgabenPauschbetrag);

  final incomeAfterDeductions =
      employmentIncome +
      businessProfit +
      otherIncome -
      basisrente -
      sonderausgaben;
  final kinderfreibetrag = deChildAllowanceMinor(
    children: profile.children,
    jointAssessment: profile.jointAssessment,
    rules: table.children,
  );
  final kindergeld = deKindergeldMinor(
    children: profile.children,
    rules: table.children,
  );
  int tariffOn(int baseMinor) {
    final income = math.max(0, baseMinor);
    return profile.jointAssessment
        ? 2 * deIncomeTaxMinor(income ~/ 2, table.tariff)
        : deIncomeTaxMinor(income, table.tariff);
  }

  final taxWithoutChildren = tariffOn(incomeAfterDeductions);
  final taxWithChildren = tariffOn(incomeAfterDeductions - kinderfreibetrag);
  // § 31 Abs. 4 EStG: the Finanzamt picks per child whichever costs less,
  // the Kinderfreibetrag or the Kindergeld. The pack compares the totals and
  // states the assumption.
  final usesKinderfreibetrag =
      kinderfreibetrag > 0 && taxWithoutChildren - taxWithChildren > kindergeld;
  final taxableIncome = math.max(
    0,
    incomeAfterDeductions - (usesKinderfreibetrag ? kinderfreibetrag : 0),
  );
  // § 3 Abs. 2 SolzG and § 51a Abs. 1 EStG: the base of Solidaritätszuschlag
  // and Kirchensteuer is the tax that would be fixed with Kinderfreibeträge
  // in every case, so it is recalculated with them and still reduced by the
  // § 35 credit below.
  final surchargeTariffTax = tariffOn(
    incomeAfterDeductions - kinderfreibetrag,
  );
  final tariffTax = tariffOn(taxableIncome);

  var positiveIncome = 0;
  if (employmentIncome > 0) {
    positiveIncome += employmentIncome;
  }
  if (businessProfit > 0) {
    positiveIncome += businessProfit;
  }
  if (otherIncome > 0) {
    positiveIncome += otherIncome;
  }
  final credit = deSection35CreditMinor(
    incomeTaxMinor: tariffTax,
    businessProfitMinor: businessProfit,
    positiveIncomeMinor: positiveIncome,
    tradeTaxMinor: tradeTaxPaidByBusinesses,
    messbetragMinor: tradeTaxMessbetrag,
  );
  // § 31 Satz 4 and § 2 Abs. 6 Satz 3 EStG: when the Kinderfreibeträge win
  // the Günstigerprüfung, the Kindergeld already received is added back to
  // the income tax.
  final incomeTax =
      tariffTax - credit + (usesKinderfreibetrag ? kindergeld : 0);
  final surchargeBase =
      surchargeTariffTax -
      deSection35CreditMinor(
        incomeTaxMinor: surchargeTariffTax,
        businessProfitMinor: businessProfit,
        positiveIncomeMinor: positiveIncome,
        tradeTaxMinor: tradeTaxPaidByBusinesses,
        messbetragMinor: tradeTaxMessbetrag,
      );

  final freigrenze = profile.jointAssessment
      ? table.solidarity.freigrenzeJoint
      : table.solidarity.freigrenze;
  final solidarity = deSolidaritySurchargeMinor(
    incomeTaxMinor: surchargeBase,
    freigrenzeMinor: freigrenze,
    rules: table.solidarity,
  );
  final churchRate = profile.churchTaxRateBasisPoints;
  final capitalIncomeTax = deCapitalIncomeTaxMinor(
    baseMinor: capitalBase,
    churchTaxRateBasisPoints: churchRate,
  );
  // The church tax follows the same base as the Solidaritätszuschlag, plus
  // the tax on capital income the Abgeltungsteuer settles.
  final churchTax = (surchargeBase + capitalIncomeTax) * churchRate ~/ 10000;

  return DeIndividualAssessment(
    totals: totals,
    employment: employment,
    employedSpouses: employedSpouses,
    werbungskosten: werbungskosten,
    werbungskostenPauschbetrag: pauschbetrag,
    usesWerbungskostenPauschbetrag: usesPauschbetrag,
    homeoffice: homeoffice,
    arbeitszimmer: arbeitszimmer,
    entfernungspauschale: entfernungspauschale,
    businessProfit: businessProfit,
    otherIncome: otherIncome,
    capitalIncome: capitalIncome,
    sparerPauschbetrag: sparer,
    capitalBase: capitalBase,
    basisrentePaid: basisrentePaid,
    basisrenteCap: basisrenteCap,
    basisrente: basisrente,
    statutoryPension: statutoryPension,
    donations: donations,
    sonderausgaben: sonderausgaben,
    children: profile.children,
    kinderfreibetrag: kinderfreibetrag,
    kindergeld: kindergeld,
    usesKinderfreibetrag: usesKinderfreibetrag,
    taxableIncome: taxableIncome,
    surchargeBase: surchargeBase,
    marginalRateBasisPoints: deMarginalRateBasisPoints(
      profile.jointAssessment ? taxableIncome ~/ 2 : taxableIncome,
      table.tariff,
    ),
    tariffTax: tariffTax,
    section35Credit: credit,
    incomeTax: incomeTax,
    solidarity: solidarity,
    churchTaxRateBasisPoints: churchRate,
    churchTax: churchTax,
    capitalIncomeTax: capitalIncomeTax,
    capitalSolidarity: deCapitalIncomeSoliMinor(capitalIncomeTax),
    lohnsteuer: totals['de.ind.lohnsteuer'] ?? 0,
    kapitalertragsteuer: totals['de.ind.kapitalertragsteuer'] ?? 0,
  );
}

/// The Tagespauschale claim: floored to whole days of 6 Euro, then capped at
/// the year's annual cap of 1 260 Euro (210 days).
int _homeofficeTagespauschale(int claimedMinor, DeTaxTable table) {
  final daily = table.allowances.homeOfficeDailyAllowance;
  final wholeDays = claimedMinor ~/ daily;
  return math.min(
    wholeDays * daily,
    table.allowances.homeOfficeAnnualMax,
  );
}

TaxReport _individualReport(
  TaxInput input,
  DeTaxProfile profile,
  DeTaxTable table,
) {
  final assessment = deIndividual(input, table);
  final counts = _entryCounts(input);
  final totals = assessment.totals;
  final joint = profile.jointAssessment;

  final lines = <TaxReportLine>[
    if (assessment.employment > 0) _line('de.ind.arbeitslohn', totals, counts),
    if (assessment.werbungskosten > 0)
      TaxReportLine(
        label: assessment.usesWerbungskostenPauschbetrag
            ? joint && assessment.employedSpouses > 1
                  ? 'Arbeitnehmer-Pauschbetrag (je Ehegatte)'
                  : 'Arbeitnehmer-Pauschbetrag'
            : 'Werbungskosten (tatsächlich)',
        amountMinor: -assessment.werbungskosten,
        reportReference: joint && !assessment.usesWerbungskostenPauschbetrag
            ? 'Anlage N je Ehegatte – Werbungskosten'
            : 'Anlage N – Werbungskosten',
        entryCount: assessment.usesWerbungskostenPauschbetrag
            ? 0
            : (counts['de.ind.werbungskosten'] ?? 0) +
                  (counts['de.ind.homeoffice'] ?? 0) +
                  (counts['de.ind.arbeitszimmer'] ?? 0),
      ),
    if (assessment.businessProfit != 0)
      TaxReportLine(
        label: 'Gewinn aus verlinkten Betrieben',
        amountMinor: assessment.businessProfit,
        reportReference: 'Anlage G / Anlage S – Gewinn',
      ),
    if (assessment.otherIncome != 0)
      _line('de.ind.sonstige_einkuenfte', totals, counts),
    if (assessment.capitalIncome != 0)
      _line('de.ind.kapitalertraege', totals, counts),
    if (assessment.capitalIncome > 0)
      TaxReportLine(
        label: 'Sparer-Pauschbetrag',
        amountMinor: -math.min(
          assessment.capitalIncome,
          assessment.sparerPauschbetrag,
        ),
        reportReference: '§ 20 Abs. 9 EStG',
      ),
    if (assessment.basisrente > 0)
      TaxReportLine(
        label: 'Basisrente (Sonderausgaben)',
        amountMinor: -assessment.basisrente,
        reportReference: 'Anlage Vorsorgeaufwand Z8 (Kz 303/403) – Basisrente',
        entryCount: counts['de.ind.basisrente'] ?? 0,
      ),
    if (assessment.usesKinderfreibetrag)
      TaxReportLine(
        label: joint
            ? 'Kinderfreibeträge (günstiger als Kindergeld)'
            : 'Kinderfreibeträge (halber Satz, günstiger als Kindergeld)',
        amountMinor: -assessment.kinderfreibetrag,
        reportReference: '§ 31 und § 32 EStG – Anlage Kind',
      ),
    TaxReportLine(
      label:
          assessment.donations >
              (joint
                  ? table.allowances.sonderausgabenPauschbetragJoint
                  : table.allowances.sonderausgabenPauschbetrag)
          ? 'Spenden und Mitgliedsbeiträge'
          : 'Sonderausgaben-Pauschbetrag',
      amountMinor: -assessment.sonderausgaben,
      reportReference: '§ 10b / § 10c EStG',
      entryCount: assessment.donations > 0
          ? (counts['de.ind.spenden'] ?? 0)
          : 0,
    ),
    TaxReportLine(
      label: 'Zu versteuerndes Einkommen',
      amountMinor: assessment.taxableIncome,
      reportReference: '§ 32a Abs. 1 EStG',
    ),
    if (assessment.section35Credit > 0)
      TaxReportLine(
        label: 'Anrechnung nach § 35 EStG',
        amountMinor: -assessment.section35Credit,
        reportReference: 'Anlage G Z51/Z52 (Kz 64-67) – § 35 EStG',
      ),
    if (assessment.usesKinderfreibetrag && assessment.kindergeld > 0)
      TaxReportLine(
        label: 'Hinzurechnung Kindergeld',
        amountMinor: assessment.kindergeld,
        reportReference: '§ 31 Satz 4 EStG',
      ),
    if (assessment.lohnsteuer > 0) _line('de.ind.lohnsteuer', totals, counts),
    if (assessment.kapitalertragsteuer > 0)
      _line('de.ind.kapitalertragsteuer', totals, counts),
  ];

  return TaxReport(
    year: _year(table),
    entityKind: profile.entityKind,
    lines: lines,
    liabilities: [
      TaxLiability(
        label: 'Einkommensteuer',
        amountMinor: assessment.incomeTax,
        bands: _incomeTaxSlices(
          assessment.taxableIncome,
          table,
          joint: joint,
        ),
      ),
      if (assessment.solidarity > 0)
        TaxLiability(
          label: 'Solidaritätszuschlag',
          amountMinor: assessment.solidarity,
          bands: [
            TaxBandSlice(
              label: 'Solidaritätszuschlag 5,5 %',
              baseMinor: assessment.surchargeBase,
              rateBasisPoints: _effectiveRate(
                assessment.solidarity,
                assessment.surchargeBase,
              ),
              taxMinor: assessment.solidarity,
            ),
          ],
        ),
      if (assessment.churchTax > 0)
        TaxLiability(label: 'Kirchensteuer', amountMinor: assessment.churchTax),
      if (assessment.capitalIncomeTax > 0)
        TaxLiability(
          label: 'Abgeltungsteuer auf Kapitalerträge',
          amountMinor: assessment.capitalIncomeTax,
          bands: [
            TaxBandSlice(
              label: assessment.churchTaxRateBasisPoints > 0
                  ? 'Abgeltungsteuer § 32d EStG (mit Kirchensteuerfaktor)'
                  : 'Abgeltungsteuer 25 %',
              baseMinor: assessment.capitalBase,
              rateBasisPoints: _effectiveRate(
                assessment.capitalIncomeTax,
                assessment.capitalBase,
              ),
              taxMinor: assessment.capitalIncomeTax,
            ),
          ],
        ),
      if (assessment.capitalSolidarity > 0)
        TaxLiability(
          label: 'Solidaritätszuschlag auf Abgeltungsteuer',
          amountMinor: assessment.capitalSolidarity,
        ),
    ],
    alreadyPaidMinor: assessment.lohnsteuer + assessment.kapitalertragsteuer,
    assumptions: _individualAssumptions(
      profile: profile,
      table: table,
      assessment: assessment,
    ),
    sources: deSources,
    rulesVerifiedOn: deRulesVerifiedOn,
    uncategorizedCount: _uncategorizedCount(input),
  );
}

TaxReport _soleTraderReport(
  TaxInput input,
  DeTaxProfile profile,
  DeTaxTable table,
) {
  final business = deEuer(input, table);
  final totals = business.totals;
  final counts = _entryCounts(input);
  final chargesVat = deChargesVat(profile);
  final vatDue =
      (totals['de.ust.ausgang'] ?? 0) - (totals['de.ust.eingang'] ?? 0);
  final paid = totals['de.euer.gewerbesteuer'] ?? 0;
  final freiberuflich = profile.einkunftsArt == DeEinkunftsArt.freiberuflich;

  final lines = <TaxReportLine>[
    for (final category in deSoleTraderCategories)
      if (category.code != 'de.euer.gewerbesteuer' &&
          (chargesVat || !_isSalesTaxCategory(category)) &&
          (totals[category.code] ?? 0) != 0)
        _line(category.code, totals, counts),
    TaxReportLine(
      label: 'Gewinn (Betriebseinnahmen ./. Betriebsausgaben)',
      amountMinor: business.profitMinor,
      reportReference: freiberuflich
          ? 'Anlage S Z6 (Kz 100/300) – Gewinn aus freiberuflicher Tätigkeit'
          : 'Anlage G Z6 (Kz 10/11) – Gewinn aus Gewerbebetrieb',
    ),
    if (business.messbetragMinor > 0)
      TaxReportLine(
        label: 'Gewerbesteuer-Messbetrag',
        amountMinor: business.messbetragMinor,
        reportReference: '§ 11 GewStG',
      ),
    if (business.messbetragMinor > 0)
      TaxReportLine(
        label: 'Anrechnung nach § 35 EStG (beim Inhaber)',
        amountMinor: business.messbetragMinor * 4,
        reportReference: 'Anlage G Z51/Z52 (Kz 64-67) – § 35 EStG',
      ),
    if (chargesVat)
      TaxReportLine(
        label: 'Umsatzsteuer-Zahllast',
        amountMinor: vatDue,
        reportReference: 'USt-Voranmeldung',
      ),
  ];

  return TaxReport(
    year: _year(table),
    entityKind: profile.entityKind,
    lines: lines,
    liabilities: [
      if (business.tradeTaxMinor > 0)
        TaxLiability(
          label: 'Gewerbesteuer',
          amountMinor: business.tradeTaxMinor,
          bands: [
            TaxBandSlice(
              label:
                  'Hebesatz ${table.businessTaxes.assumedTradeTaxHebesatz} % des Messbetrags',
              baseMinor: business.messbetragMinor,
              rateBasisPoints:
                  table.businessTaxes.assumedTradeTaxHebesatz * 100,
              taxMinor: business.tradeTaxMinor,
            ),
          ],
        ),
      if (chargesVat && vatDue != 0)
        TaxLiability(label: 'Umsatzsteuer-Zahllast', amountMinor: vatDue),
    ],
    alreadyPaidMinor: paid,
    assumptions: [
      if (freiberuflich) ...[
        'Der Betrieb ist freiberuflich (§ 18 EStG): die Einkünfte gehören in die Anlage S, es fällt keine Gewerbesteuer an (§ 2 GewStG) und die Anrechnung nach § 35 EStG greift nicht.',
      ] else ...[
        'Der Betrieb ist gewerblich (§ 15 EStG): die Einkünfte gehören in die Anlage G, die Gewerbesteuer ist berechnet und nicht im Gewinn abgezogen.',
        'Hebesatz der Gewerbesteuer: ${table.businessTaxes.assumedTradeTaxHebesatz} %. Der Freibetrag von 24 500 Euro gilt nur für natürliche Personen (§ 11 Abs. 1 Satz 3 Nr. 1 GewStG).',
      ],
      'Gewinnermittlung als Einnahmen-Überschuss-Rechnung nach § 4 Abs. 3 EStG; Entnahmen und Einlagen ändern den Gewinn nicht.',
      'Absetzungen für Abnutzung und geringwertige Wirtschaftsgüter werden als Betrag übernommen; eine AfA-Tabelle führt der Pack nicht.',
      'Bewirtungskosten sind zu 70 % abgezogen (§ 4 Abs. 5 Satz 1 Nr. 2 EStG).',
      if (chargesVat)
        'Umsatzsteuer: 19 % Regelsteuersatz und 7 % Ermäßigung (§ 12 UStG); die Zahllast ist Ausgangssteuer abzüglich Vorsteuer.'
      else if (profile.smallBusinessExemption)
        'Kleinunternehmerregelung nach § 19 UStG: keine Umsatzsteuer berechnet und keine Vorsteuer abgezogen; erfasste Umsatzsteuerbeträge bleiben unberücksichtigt.'
      else
        'Nicht zur Umsatzsteuer registriert: keine Umsatzsteuer berechnet.',
      'Unbeschränkt steuerpflichtig; alle Beträge in Euro.',
      'Abgabefrist: ${deDate(deFilingDeadline(table.startYear))} ohne, ${deDate(deAdvisorFilingDeadline(table.startYear))} mit Steuerberater oder Lohnsteuerhilfeverein (§ 149 Abs. 2 und 3 AO; Wochenenden und Feiertage nach § 108 Abs. 3 AO verschoben).',
    ],
    sources: deSources,
    rulesVerifiedOn: deRulesVerifiedOn,
    uncategorizedCount: _uncategorizedCount(input),
  );
}

TaxReport _companyReport(
  TaxInput input,
  DeTaxProfile profile,
  DeTaxTable table,
) {
  final company = deCompanyResult(input, table);
  final totals = company.totals;
  final counts = _entryCounts(input);
  final chargesVat = deChargesVat(profile);

  final lines = <TaxReportLine>[
    for (final category in deCompanyCategories)
      if (category.kind != TaxCategoryKind.taxPaid &&
          (chargesVat || !_isSalesTaxCategory(category)) &&
          (totals[category.code] ?? 0) != 0)
        _line(category.code, totals, counts),
    TaxReportLine(
      label: 'Jahresüberschuss/-fehlbetrag (Gewinn vor Steuern)',
      amountMinor: company.profitMinor,
      reportReference: 'Anlage GK Z11 – Jahresüberschuss/-fehlbetrag',
    ),
    TaxReportLine(
      label: 'Einkommen (zu versteuerndes Einkommen der Körperschaft)',
      amountMinor: math.max(0, company.profitMinor),
      reportReference:
          'Anlage ZVE Z32 – Einkommen im Sinne des § 9 Abs. 2 Satz 1 KStG',
    ),
    if (chargesVat)
      TaxReportLine(
        label: 'Umsatzsteuer-Zahllast',
        amountMinor: company.vatDueMinor,
        reportReference: 'USt-Voranmeldung',
      ),
  ];

  return TaxReport(
    year: _year(table),
    entityKind: profile.entityKind,
    lines: lines,
    liabilities: [
      TaxLiability(
        label: 'Körperschaftsteuer',
        amountMinor: company.corporateTaxMinor,
        bands: [
          TaxBandSlice(
            label: 'Körperschaftsteuer 15 %',
            baseMinor: math.max(0, company.profitMinor),
            rateBasisPoints: table.businessTaxes.corporateTaxRateBasisPoints,
            taxMinor: company.corporateTaxMinor,
          ),
        ],
      ),
      if (company.solidarityMinor > 0)
        TaxLiability(
          label: 'Solidaritätszuschlag auf Körperschaftsteuer',
          amountMinor: company.solidarityMinor,
        ),
      if (company.tradeTaxMinor > 0)
        TaxLiability(
          label: 'Gewerbesteuer',
          amountMinor: company.tradeTaxMinor,
          bands: [
            TaxBandSlice(
              label:
                  'Hebesatz ${table.businessTaxes.assumedTradeTaxHebesatz} % des Messbetrags',
              baseMinor: company.messbetragMinor,
              rateBasisPoints:
                  table.businessTaxes.assumedTradeTaxHebesatz * 100,
              taxMinor: company.tradeTaxMinor,
            ),
          ],
        ),
      if (chargesVat && company.vatDueMinor != 0)
        TaxLiability(
          label: 'Umsatzsteuer-Zahllast',
          amountMinor: company.vatDueMinor,
        ),
    ],
    alreadyPaidMinor:
        (totals['de.co.kst_vorauszahlungen'] ?? 0) +
        (totals['de.co.gewst_vorauszahlungen'] ?? 0),
    assumptions: [
      'Körperschaftsteuer 15 % des zu versteuernden Einkommens (§ 23 Abs. 1 KStG); der Satz sinkt ab 2028 gestuft auf 10 %.',
      'Solidaritätszuschlag 5,5 % der Körperschaftsteuer ohne Freigrenze (§ 3 Abs. 3 SolzG 1995 gilt nur für einkommensteuerpflichtige Personen).',
      'Gewerbesteuer ohne Freibetrag; Hebesatz ${table.businessTaxes.assumedTradeTaxHebesatz} % (§ 11 Abs. 1 GewStG, § 16 GewStG).',
      if (chargesVat)
        'Umsatzsteuer: 19 % Regelsteuersatz und 7 % Ermäßigung (§ 12 UStG); die Zahllast ist Ausgangssteuer abzüglich Vorsteuer.'
      else if (profile.smallBusinessExemption)
        'Kleinunternehmerregelung nach § 19 UStG: keine Umsatzsteuer berechnet.'
      else
        'Nicht zur Umsatzsteuer registriert: keine Umsatzsteuer berechnet.',
      'Gewinn vor Steuern; Körperschaftsteuer und Gewerbesteuer sind keine Betriebsausgaben (§ 4 Abs. 5b EStG, § 8 Abs. 1 KStG).',
      'Unbeschränkt steuerpflichtig; alle Beträge in Euro.',
      'Abgabefrist: ${deDate(deFilingDeadline(table.startYear))} ohne, ${deDate(deAdvisorFilingDeadline(table.startYear))} mit Steuerberater oder Lohnsteuerhilfeverein (§ 149 Abs. 2 und 3 AO; Wochenenden und Feiertage nach § 108 Abs. 3 AO verschoben).',
    ],
    sources: deSources,
    rulesVerifiedOn: deRulesVerifiedOn,
    uncategorizedCount: _uncategorizedCount(input),
  );
}

List<String> _individualAssumptions({
  required DeTaxProfile profile,
  required DeTaxTable table,
  required DeIndividualAssessment assessment,
}) => [
  'Unbeschränkt steuerpflichtig; alle Beträge in Euro.',
  if (profile.jointAssessment)
    'Zusammenveranlagung: alle Beträge gelten als gemeinsames Einkommen beider Ehegatten (Splitting-Verfahren, § 32a Abs. 5 EStG).'
  else
    'Einzelveranlagung ohne Splitting-Verfahren.',
  if (profile.jointAssessment && assessment.employedSpouses > 1)
    'Der Arbeitnehmer-Pauschbetrag von ${deEuro(table.allowances.werbungskostenPauschbetrag)} wird je erwerbstätigem Ehegatten angesetzt; jede Anlage N wird je Ehegatte ausgefüllt. Die Bücher führen die Werbungskosten nicht je Ehegatte getrennt, daher vergleicht der Pack den Gesamtbetrag mit den Pauschbeträgen beider Ehegatten.'
  else if (profile.jointAssessment)
    'Nur ein Ehegatte hat Arbeitslohn erfasst, daher ist der Arbeitnehmer-Pauschbetrag einmal angesetzt.',
  'Zu versteuerndes Einkommen und Steuerbetrag sind auf volle Euro abgerundet (§ 32a Abs. 1 EStG).',
  if (assessment.churchTaxRateBasisPoints > 0)
    'Kirchensteuer ${assessment.churchTaxRateBasisPoints ~/ 100} % der Bemessungsgrundlage${profile.churchTaxState == null ? '; der Satz ist eine Annahme, weil kein Bundesland angegeben ist (Bayern und Baden-Württemberg erheben 8 %, alle anderen Länder 9 %)' : ' (Land: ${profile.churchTaxState!.label})'}.'
  else
    'Keine Kirchensteuer.',
  if (assessment.children > 0) ...[
    'Kinder: ${assessment.children} Kind(er). Kindergeld ${deEuro(assessment.kindergeld)} im Jahr (zwölf Monate je Kind angenommen). Die Günstigerprüfung nach § 31 Abs. 4 EStG hat ${assessment.usesKinderfreibetrag ? 'die Kinderfreibeträge gewählt, weil sie mehr Steuer sparen als das Kindergeld' : 'das Kindergeld gewählt, weil es mehr bringt als die Kinderfreibeträge'}.',
    'Solidaritätszuschlag und Kirchensteuer sind stets an der Steuer mit Kinderfreibeträgen bemessen (§ 3 Abs. 2 SolzG 1995, § 51a Abs. 1 EStG), auch wenn das Kindergeld steuerlich günstiger ist.',
    if (!profile.jointAssessment) 'Ohne Zusammenveranlagung zählt der halbe Kinderfreibetrag je Kind; eine Übertragung des Freibetrags des anderen Elternteils (§ 32 Abs. 6 Satz 2 EStG) ist nicht geprüft.',
  ],
  if (assessment.arbeitszimmer > 0)
    'Häusliches Arbeitszimmer nach § 4 Abs. 5 Satz 1 Nr. 6b EStG angesetzt; die Homeoffice-Tagespauschale bleibt außen vor, weil beide Ansprüche zeitlich nicht zusammen laufen dürfen (§ 4 Abs. 5 Satz 1 Nr. 6c EStG).'
  else if (assessment.homeoffice > 0)
    'Homeoffice-Tagespauschale: ${assessment.homeoffice ~/ table.allowances.homeOfficeDailyAllowance} Tage zu je ${deEuro(table.allowances.homeOfficeDailyAllowance)}, höchstens ${deEuro(table.allowances.homeOfficeAnnualMax)} im Jahr (§ 4 Abs. 5 Satz 1 Nr. 6c EStG).',
  if (assessment.entfernungspauschale > 0)
    'Entfernungspauschale nach § 9 Abs. 1 Satz 3 Nr. 4 EStG: ${profile.commuteDays} Fahrttage mit ${profile.commuteKmOneWay} km einfacher Weg, höchstens ${deEuro(table.commuter.annualCapMinor)} im Jahr; Fahrten im eigenen oder zur Verfügung gestellten Fahrzeug dürfen den Höchstbetrag überschreiten.',
  if (assessment.section35Credit > 0) 'Die Gewerbesteuer der verlinkten Betriebe steht im jeweiligen Betriebsreport; hier ist nur die Anrechnung nach § 35 EStG enthalten.',
  if (assessment.capitalIncome > 0)
    'Kapitalerträge werden mit der Abgeltungsteuer nach § 32d EStG besteuert; eine Günstigerprüfung ist nicht eingerechnet.'
  else
    'Keine Kapitalerträge erfasst.',
  if (assessment.basisrentePaid > 0)
    'Basisrente: abziehbar bis ${deEuro(assessment.basisrenteCap)} (§ 10 Abs. 3 EStG${profile.jointAssessment ? '; bei Zusammenveranlagung verdoppelter Höchstbetrag' : ''}${assessment.statutoryPension > 0 ? ', gemindert um ${deEuro(assessment.statutoryPension)} Beiträge zur gesetzlichen Rentenversicherung' : ''}).'
  else
    'Keine Beiträge zur Basisrente erfasst.',
  'Keine weiteren Einkünfte, Sonderausgaben oder außergewöhnlichen Belastungen außerhalb von OpenBudget.',
  'Kein Verlustvortrag und keine Vorauszahlungen außer den erfassten Steuerabzügen.',
  'Abgabefrist: ${deDate(deFilingDeadline(table.startYear))} ohne, ${deDate(deAdvisorFilingDeadline(table.startYear))} mit Steuerberater oder Lohnsteuerhilfeverein (§ 149 Abs. 2 und 3 AO; Wochenenden und Feiertage nach § 108 Abs. 3 AO verschoben).',
];

Map<String, int> _totalsFor(
  TaxInput input, {
  required bool netAmounts,
  required DeTaxTable table,
}) {
  final totals = totalsByCategory(
    input.entries,
    amountOf: (entry) {
      final gross = entry.amountMinor * entry.businessUsePercent ~/ 100;
      final kind = deCategories[entry.categoryCode]?.kind;
      if (kind == TaxCategoryKind.salesTaxCollected ||
          kind == TaxCategoryKind.salesTaxPaid) {
        return gross;
      }
      return netAmounts ? entry.allowableMinor : gross;
    },
  );
  for (final code in const ['de.euer.bewirtung', 'de.co.bewirtung']) {
    final amount = totals[code];
    if (amount != null) {
      totals[code] =
          amount * table.allowances.businessMealRateBasisPoints ~/ 10000;
    }
  }
  return totals;
}

int _balance(Map<String, int> totals) {
  var profit = 0;
  for (final entry in totals.entries) {
    final kind = deCategories[entry.key]?.kind;
    if (kind == TaxCategoryKind.income) {
      profit += entry.value;
    } else if (kind == TaxCategoryKind.expense) {
      profit -= entry.value;
    }
  }
  return profit;
}

Map<String, int> _entryCounts(TaxInput input) {
  final counts = <String, int>{};
  for (final entry in input.entries) {
    counts.update(entry.categoryCode, (count) => count + 1, ifAbsent: () => 1);
  }
  return counts;
}

int _uncategorizedCount(TaxInput input) => input.entries
    .where((entry) => !deCategories.containsKey(entry.categoryCode))
    .length;

List<TaxBandSlice> _incomeTaxSlices(
  int taxableIncome,
  DeTaxTable table, {
  required bool joint,
}) {
  if (!joint) {
    return deTariffSlices(taxableIncome, table.tariff);
  }
  final half = deTariffSlices(taxableIncome ~/ 2, table.tariff);
  return [
    for (final slice in half)
      TaxBandSlice(
        label: slice.label,
        baseMinor: slice.baseMinor * 2,
        rateBasisPoints: slice.rateBasisPoints,
        taxMinor: slice.taxMinor * 2,
      ),
  ];
}

int _effectiveRate(int taxMinor, int baseMinor) =>
    baseMinor > 0 ? taxMinor * 10000 ~/ baseMinor : 0;

TaxReportLine _line(
  String code,
  Map<String, int> totals,
  Map<String, int> counts,
) {
  final category = deCategories[code]!;
  return TaxReportLine(
    label: category.label,
    amountMinor: (totals[code] ?? 0) * _sign(category.kind),
    code: code,
    reportReference: category.reportReference,
    entryCount: counts[code] ?? 0,
  );
}

bool _isSalesTaxCategory(TaxCategory category) =>
    category.kind == TaxCategoryKind.salesTaxCollected ||
    category.kind == TaxCategoryKind.salesTaxPaid;

int _sign(TaxCategoryKind kind) => switch (kind) {
  TaxCategoryKind.expense ||
  TaxCategoryKind.relief ||
  TaxCategoryKind.salesTaxPaid => -1,
  _ => 1,
};

TaxYear _year(DeTaxTable table) => TaxYear(
  jurisdiction: TaxJurisdiction.de,
  startYear: table.startYear,
  start: DateTime.utc(table.startYear),
  end: DateTime.utc(table.startYear + 1),
  label: '${table.startYear}',
);
