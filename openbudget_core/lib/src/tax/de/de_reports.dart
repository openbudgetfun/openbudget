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
    required this.werbungskosten,
    required this.usesWerbungskostenPauschbetrag,
    required this.businessProfit,
    required this.otherIncome,
    required this.capitalIncome,
    required this.sparerPauschbetrag,
    required this.capitalBase,
    required this.basisrentePaid,
    required this.basisrente,
    required this.donations,
    required this.sonderausgaben,
    required this.taxableIncome,
    required this.marginalRateBasisPoints,
    required this.tariffTax,
    required this.section35Credit,
    required this.incomeTax,
    required this.solidarity,
    required this.churchTax,
    required this.capitalIncomeTax,
    required this.capitalSolidarity,
    required this.lohnsteuer,
    required this.kapitalertragsteuer,
  });

  final Map<String, int> totals;
  final int employment;
  final int werbungskosten;
  final bool usesWerbungskostenPauschbetrag;
  final int businessProfit;
  final int otherIncome;
  final int capitalIncome;
  final int sparerPauschbetrag;
  final int capitalBase;
  final int basisrentePaid;
  final int basisrente;
  final int donations;
  final int sonderausgaben;
  final int taxableIncome;
  final int marginalRateBasisPoints;
  final int tariffTax;
  final int section35Credit;
  final int incomeTax;
  final int solidarity;
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
    TaxEntityKind.individual => _individualReport(input, profile, table),
    TaxEntityKind.soleTrader => _soleTraderReport(input, profile, table),
    TaxEntityKind.company => _companyReport(input, profile, table),
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
  final profit = _balance(totals);
  final messbetrag = deTradeTaxMessbetragMinor(
    profitMinor: profit,
    freeAmountMinor: table.businessTaxes.tradeTaxFreeAmount,
    messzahlBasisPoints: table.businessTaxes.tradeTaxMesszahlBasisPoints,
  );
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
  final actualWerbungskosten =
      (totals['de.ind.werbungskosten'] ?? 0) +
      (totals['de.ind.homeoffice'] ?? 0);
  final usesPauschbetrag =
      actualWerbungskosten <= allowances.werbungskostenPauschbetrag;
  final werbungskosten = employment <= 0
      ? 0
      : usesPauschbetrag
      ? allowances.werbungskostenPauschbetrag
      : actualWerbungskosten;
  final employmentIncome = employment - werbungskosten;

  var businessProfit = 0;
  var tradeTaxMessbetrag = 0;
  var tradeTaxPaidByBusinesses = 0;
  for (final linked in input.linked) {
    final linkedProfile = linked.profile;
    if (linkedProfile is DeTaxProfile &&
        linkedProfile.entityKind == TaxEntityKind.soleTrader) {
      final business = deEuer(linked, table);
      businessProfit += business.profitMinor;
      tradeTaxMessbetrag += business.messbetragMinor;
      tradeTaxPaidByBusinesses += business.tradeTaxMinor;
    }
  }

  final otherIncome = totals['de.ind.sonstige_einkuenfte'] ?? 0;
  final capitalIncome = totals['de.ind.kapitalertraege'] ?? 0;
  final sparer = profile.jointAssessment
      ? allowances.sparerPauschbetragJoint
      : allowances.sparerPauschbetrag;
  final capitalBase = math.max(0, capitalIncome - sparer);

  final basisrentePaid = totals['de.ind.basisrente'] ?? 0;
  final basisrente = math.min(basisrentePaid, table.basisrenteMax);
  final donations = totals['de.ind.spenden'] ?? 0;
  final sonderausgabenPauschbetrag = profile.jointAssessment
      ? allowances.sonderausgabenPauschbetragJoint
      : allowances.sonderausgabenPauschbetrag;
  final sonderausgaben = math.max(donations, sonderausgabenPauschbetrag);

  final income = employmentIncome + businessProfit + otherIncome;
  final taxableIncome = math.max(0, income - basisrente - sonderausgaben);
  final tariffIncome = profile.jointAssessment
      ? taxableIncome ~/ 2
      : taxableIncome;
  final tariffTax = profile.jointAssessment
      ? 2 * deIncomeTaxMinor(tariffIncome, table.tariff)
      : deIncomeTaxMinor(tariffIncome, table.tariff);

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
  final incomeTax = tariffTax - credit;

  final freigrenze = profile.jointAssessment
      ? table.solidarity.freigrenzeJoint
      : table.solidarity.freigrenze;
  final solidarity = deSolidaritySurchargeMinor(
    incomeTaxMinor: incomeTax,
    freigrenzeMinor: freigrenze,
    rules: table.solidarity,
  );
  final churchRate = profile.churchTax ? deKirchensteuerRateBasisPoints : 0;
  final capitalIncomeTax = deCapitalIncomeTaxMinor(
    baseMinor: capitalBase,
    churchTaxRateBasisPoints: churchRate,
  );
  // § 32d Abs. 1 Satz 3 EStG reduces the tax on capital income by 25 % of the
  // church tax on it; the church tax itself is still 9 % of the whole income
  // tax, so it is charged on both parts.
  final churchTax = (incomeTax + capitalIncomeTax) * churchRate ~/ 10000;

  return DeIndividualAssessment(
    totals: totals,
    employment: employment,
    werbungskosten: werbungskosten,
    usesWerbungskostenPauschbetrag: usesPauschbetrag,
    businessProfit: businessProfit,
    otherIncome: otherIncome,
    capitalIncome: capitalIncome,
    sparerPauschbetrag: sparer,
    capitalBase: capitalBase,
    basisrentePaid: basisrentePaid,
    basisrente: basisrente,
    donations: donations,
    sonderausgaben: sonderausgaben,
    taxableIncome: taxableIncome,
    marginalRateBasisPoints: deMarginalRateBasisPoints(
      tariffIncome,
      table.tariff,
    ),
    tariffTax: tariffTax,
    section35Credit: credit,
    incomeTax: incomeTax,
    solidarity: solidarity,
    churchTax: churchTax,
    capitalIncomeTax: capitalIncomeTax,
    capitalSolidarity: deCapitalIncomeSoliMinor(capitalIncomeTax),
    lohnsteuer: totals['de.ind.lohnsteuer'] ?? 0,
    kapitalertragsteuer: totals['de.ind.kapitalertragsteuer'] ?? 0,
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

  final lines = <TaxReportLine>[
    if (assessment.employment > 0) _line('de.ind.arbeitslohn', totals, counts),
    if (assessment.werbungskosten > 0)
      TaxReportLine(
        label: assessment.usesWerbungskostenPauschbetrag
            ? 'Arbeitnehmer-Pauschbetrag'
            : 'Werbungskosten (tatsächlich)',
        amountMinor: -assessment.werbungskosten,
        reportReference: 'Anlage N – Werbungskosten',
        entryCount: assessment.usesWerbungskostenPauschbetrag
            ? 0
            : (counts['de.ind.werbungskosten'] ?? 0) +
                  (counts['de.ind.homeoffice'] ?? 0),
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
        reportReference: 'Anlage Vorsorgeaufwand',
        entryCount: counts['de.ind.basisrente'] ?? 0,
      ),
    TaxReportLine(
      label:
          assessment.donations >
              (profile.jointAssessment
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
        reportReference: '§ 35 EStG',
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
          joint: profile.jointAssessment,
        ),
      ),
      if (assessment.solidarity > 0)
        TaxLiability(
          label: 'Solidaritätszuschlag',
          amountMinor: assessment.solidarity,
          bands: [
            TaxBandSlice(
              label: 'Solidaritätszuschlag 5,5 %',
              baseMinor: assessment.incomeTax,
              rateBasisPoints: _effectiveRate(
                assessment.solidarity,
                assessment.incomeTax,
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
              label: profile.churchTax
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

  final lines = <TaxReportLine>[
    for (final category in deSoleTraderCategories)
      if (category.code != 'de.euer.gewerbesteuer' &&
          (chargesVat || !_isSalesTaxCategory(category)) &&
          (totals[category.code] ?? 0) != 0)
        _line(category.code, totals, counts),
    TaxReportLine(
      label: 'Gewinn (Betriebseinnahmen ./. Betriebsausgaben)',
      amountMinor: business.profitMinor,
      reportReference: 'Anlage EÜR – Gewinn',
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
        reportReference: '§ 35 EStG',
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
          label: 'Gewerbesteuer (Annahme Gewerbebetrieb)',
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
      'Der Betrieb wird als Gewerbebetrieb behandelt; die Gewerbesteuer ist deshalb berechnet und nicht im Gewinn abgezogen.',
      'Freiberufler und andere nicht gewerbliche Selbständige schulden keine Gewerbesteuer (§ 2 GewStG, § 18 EStG). Die Art der Tätigkeit steht nicht im Profil; in diesem Fall ist die Gewerbesteuer-Zeile zu ignorieren.',
      'Hebesatz der Gewerbesteuer: ${table.businessTaxes.assumedTradeTaxHebesatz} %. Der Freibetrag von 24 500 Euro gilt nur für natürliche Personen (§ 11 Abs. 1 Satz 3 Nr. 1 GewStG).',
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
      'Abgabefrist: ${deDate(deFilingDeadline(table.startYear))} ohne, ${deDate(deAdvisorFilingDeadline(table.startYear))} mit Steuerberater (§ 149 Abs. 2 und 3 AO).',
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
      label: 'Gewinn vor Steuern',
      amountMinor: company.profitMinor,
      reportReference: 'KSt 1 – Einkommen',
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
      'Abgabefrist: ${deDate(deFilingDeadline(table.startYear))} ohne, ${deDate(deAdvisorFilingDeadline(table.startYear))} mit Steuerberater (§ 149 Abs. 2 und 3 AO).',
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
  if (profile.jointAssessment) 'Der Arbeitnehmer-Pauschbetrag wird bei Zusammenveranlagung einmal angesetzt, weil die Bücher nicht nach Ehegatten getrennt sind.',
  'Zu versteuerndes Einkommen und Steuerbetrag sind auf volle Euro abgerundet (§ 32a Abs. 1 EStG).',
  if (profile.churchTax)
    'Kirchensteuer 9 % der Einkommensteuer. Bayern und Baden-Württemberg erheben 8 %; der Satz ist eine Annahme, keine bundesrechtliche Regelung.'
  else
    'Keine Kirchensteuer.',
  if (assessment.section35Credit > 0) 'Die Gewerbesteuer der verlinkten Betriebe steht im jeweiligen Betriebsreport; hier ist nur die Anrechnung nach § 35 EStG enthalten.',
  if (assessment.capitalIncome > 0)
    'Kapitalerträge werden mit der Abgeltungsteuer nach § 32d EStG besteuert; eine Günstigerprüfung ist nicht eingerechnet.'
  else
    'Keine Kapitalerträge erfasst.',
  if (assessment.basisrentePaid > 0)
    'Basisrente: abziehbar bis ${deEuro(table.basisrenteMax)} (§ 10 Abs. 3 EStG).'
  else
    'Keine Beiträge zur Basisrente erfasst.',
  'Keine weiteren Einkünfte, Sonderausgaben oder außergewöhnlichen Belastungen außerhalb von OpenBudget.',
  'Kein Verlustvortrag und keine Vorauszahlungen außer den erfassten Steuerabzügen.',
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
