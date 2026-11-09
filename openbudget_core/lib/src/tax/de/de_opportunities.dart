import 'dart:math' as math;

import 'package:openbudget_core/src/tax/de/de_assessment.dart';
import 'package:openbudget_core/src/tax/de/de_categories.dart';
import 'package:openbudget_core/src/tax/de/de_format.dart';
import 'package:openbudget_core/src/tax/de/de_reports.dart';
import 'package:openbudget_core/src/tax/de/de_tables.dart';
import 'package:openbudget_core/src/tax/de/de_tariff.dart';
import 'package:openbudget_core/src/tax/tax_model.dart';
import 'package:openbudget_core/src/tax/tax_profile.dart';
import 'package:openbudget_core/src/tax/tax_rule_pack.dart';

/// Legal ways for [input] to owe less, given the figures in [report].
///
/// Every saving is recomputed from [input] with the same pure functions that
/// built [report], so a recommendation can never drift from the liability
/// above it. Where a saving depends on facts the books do not hold, the
/// opportunity says so and leaves [TaxOpportunity.estimatedSavingMinor] empty
/// instead of guessing.
List<TaxOpportunity> deOpportunities(
  TaxInput input,
  TaxReport report,
  DeTaxTable table,
) {
  final profile = input.profile;
  if (profile is! DeTaxProfile) {
    return const [];
  }
  return [
    _filingDeadline(table),
    ...switch (profile.entityKind) {
      EntityKind.individual => _individualOpportunities(
        input,
        profile,
        table,
      ),
      EntityKind.soleTrader => _soleTraderOpportunities(
        input,
        profile,
        table,
      ),
      EntityKind.company => _companyOpportunities(input, profile, table),
    },
  ];
}

List<TaxOpportunity> _individualOpportunities(
  TaxInput input,
  DeTaxProfile profile,
  DeTaxTable table,
) {
  final assessment = deIndividual(input, table);
  final churchRate = profile.churchTaxRateBasisPoints;
  final opportunities = <TaxOpportunity>[];

  final unusedAllowance =
      assessment.sparerPauschbetrag -
      math.min(assessment.capitalIncome, assessment.sparerPauschbetrag);
  if (assessment.capitalIncome > 0 && unusedAllowance > 0) {
    final capitalTax = deCapitalIncomeTaxMinor(
      baseMinor: assessment.capitalIncome,
      churchTaxRateBasisPoints: churchRate,
    );
    final taxOnIncome = capitalTax + deCapitalIncomeSoliMinor(capitalTax);
    final saving = assessment.kapitalertragsteuer > 0
        ? math.min(taxOnIncome, assessment.kapitalertragsteuer)
        : null;
    opportunities.add(
      TaxOpportunity(
        id: 'de.sparer_pauschbetrag',
        title: 'Freistellungsauftrag nutzen',
        explanation:
            'Der Sparer-Pauschbetrag von ${deEuro(assessment.sparerPauschbetrag)} ist nicht ausgeschöpft. Mit einem Freistellungsauftrag bei der Bank werden Kapitalerträge bis zu dieser Grenze ohne Abgeltungsteuer ausgezahlt.',
        source: Uri.parse('https://www.gesetze-im-internet.de/estg/__20.html'),
        estimatedSavingMinor: saving,
      ),
    );
  }

  // § 4 Abs. 5 Satz 1 Nr. 6c EStG: 6 Euro per day, capped at the annual
  // maximum. The opportunity stays silent when an Arbeitszimmer is claimed,
  // because the two claims must not overlap in time.
  final homeOfficeClaimed = assessment.homeoffice;
  final homeOfficeMax = table.allowances.homeOfficeAnnualMax;
  if (assessment.arbeitszimmer == 0 &&
      homeOfficeClaimed < homeOfficeMax &&
      assessment.marginalRateBasisPoints > 0) {
    final daily = table.allowances.homeOfficeDailyAllowance;
    final remainingDays = (homeOfficeMax - homeOfficeClaimed) ~/ daily;
    final shortfall = homeOfficeMax - homeOfficeClaimed;
    opportunities.add(
      TaxOpportunity(
        id: 'de.homeoffice_pauschale',
        title: 'Homeoffice-Pauschale ausschöpfen',
        explanation:
            'Für jeden Kalendertag mit überwiegend häuslicher Tätigkeit sind ${deEuro(daily)} abziehbar, höchstens ${deEuro(homeOfficeMax)} im Jahr (§ 4 Abs. 5 Satz 1 Nr. 6c EStG). Erfasst sind bisher ${deEuro(homeOfficeClaimed)}; es fehlen $remainingDays Tage (${deEuro(shortfall)}) bis zur Höchstgrenze.',
        source: Uri.parse('https://www.gesetze-im-internet.de/estg/__4.html'),
        estimatedSavingMinor:
            math.min(shortfall, assessment.taxableIncome) *
            assessment.marginalRateBasisPoints ~/
            10000,
        deadline: DateTime.utc(table.startYear, 12, 31),
      ),
    );
  }

  final basisrenteCap = assessment.basisrenteCap;
  final basisrenteShortfall = basisrenteCap - assessment.basisrentePaid;
  final usableBasisrente = math.min(
    basisrenteShortfall,
    assessment.taxableIncome,
  );
  if (usableBasisrente > 0) {
    opportunities.add(
      TaxOpportunity(
        id: 'de.basisrente_hoechstbetrag',
        title: 'Basisrente bis zum Höchstbetrag einzahlen',
        explanation:
            'Beiträge zu einer Basisrente sind bis ${deEuro(basisrenteCap)} im Jahr als Sonderausgaben abziehbar (§ 10 Abs. 3 EStG${profile.jointAssessment ? '; bei Zusammenveranlagung verdoppelter Höchstbetrag' : ''}${assessment.statutoryPension > 0 ? ', gemindert um ${deEuro(assessment.statutoryPension)} Beiträge zur gesetzlichen Rentenversicherung' : ''}). Erfasst sind bisher ${deEuro(assessment.basisrentePaid)}. Die Ersparnis gilt für zusätzliche Beiträge bis zur Höhe des zu versteuernden Einkommens; die Auszahlung der Rente ist später steuerpflichtig.',
        source: Uri.parse('https://www.gesetze-im-internet.de/estg/__10.html'),
        estimatedSavingMinor:
            usableBasisrente * assessment.marginalRateBasisPoints ~/ 10000,
        deadline: DateTime.utc(table.startYear, 12, 31),
      ),
    );
  }

  if (assessment.capitalBase > 0) {
    final withCapital = assessment.taxableIncome + assessment.capitalBase;
    final extraTariff =
        (profile.jointAssessment
            ? 2 * deIncomeTaxMinor(withCapital ~/ 2, table.tariff)
            : deIncomeTaxMinor(withCapital, table.tariff)) -
        assessment.tariffTax;
    final saving = assessment.capitalIncomeTax - extraTariff;
    if (saving > 0 && assessment.marginalRateBasisPoints < 2500) {
      opportunities.add(
        TaxOpportunity(
          id: 'de.guenstigerpruefung',
          title: 'Günstigerprüfung bei Kapitalerträgen beantragen',
          explanation: 'Der persönliche Steuersatz liegt unter 25 %. Auf Antrag werden die Kapitalerträge statt mit der Abgeltungsteuer mit dem Tarif besteuert (§ 32d Abs. 6 EStG). Die Schätzung vergleicht nur die Einkommensteuer, nicht die Zuschlagsteuern.',
          source: Uri.parse(
            'https://www.gesetze-im-internet.de/estg/__32d.html',
          ),
          estimatedSavingMinor: saving,
          deadline: deFilingDeadline(table.startYear),
        ),
      );
    }
  }

  for (final linked in input.linked) {
    final linkedProfile = linked.profile;
    if (linkedProfile is! DeTaxProfile ||
        linkedProfile.entityKind != EntityKind.company) {
      continue;
    }
    final company = deCompanyResult(linked, table);
    final profit = math.max(0, company.profitMinor);
    if (profit == 0) {
      continue;
    }
    final corporateTax =
        profit * table.businessTaxes.corporateTaxRateBasisPoints ~/ 10000;
    final corporateSolidarity = corporateTax * 55 ~/ 1000;
    final messbetrag = deTradeTaxMessbetragMinor(
      profitMinor: profit,
      freeAmountMinor: 0,
      messzahlBasisPoints: table.businessTaxes.tradeTaxMesszahlBasisPoints,
    );
    final companyTax =
        corporateTax +
        corporateSolidarity +
        deTradeTaxMinor(
          messbetragMinor: messbetrag,
          hebesatz: table.businessTaxes.assumedTradeTaxHebesatz,
        );
    final dividend = profit - companyTax;
    final dividendTax = deCapitalIncomeTaxMinor(
      baseMinor: dividend,
      churchTaxRateBasisPoints: churchRate,
    );
    final dividendSolidarity = deCapitalIncomeSoliMinor(dividendTax);
    final dividendRoute = companyTax + dividendTax + dividendSolidarity;

    final salaryTax = profit * assessment.marginalRateBasisPoints ~/ 10000;
    final salaryRoute =
        salaryTax +
        salaryTax * 55 ~/ 1000 +
        (churchRate > 0 ? salaryTax * churchRate ~/ 10000 : 0);

    if (salaryRoute < dividendRoute) {
      opportunities.add(
        TaxOpportunity(
          id: 'de.geschaeftsfuehrer_vergleich',
          title: 'Gehalt statt Gewinnausschüttung prüfen',
          explanation:
              'Ein Gesellschafter-Geschäftsführer kann seinen Gewinn als Gehalt oder als Ausschüttung beziehen. Bei ${deEuro(profit)} Gewinn kostet die Ausschüttung rund ${deEuro(dividendRoute)} Steuern (Körperschaftsteuer, Solidaritätszuschlag, Gewerbesteuer und Abgeltungsteuer), das Gehalt rund ${deEuro(salaryRoute)} (Einkommensteuer mit Zuschlagsteuern). Angemessenheit des Gehalts und Sozialversicherung sind nicht geprüft; ab 25 % Beteiligung kommt statt der Abgeltungsteuer das Teileinkünfteverfahren in Betracht (§ 32d Abs. 2 Nr. 3 EStG).',
          source: Uri.parse(
            'https://www.gesetze-im-internet.de/estg/__32d.html',
          ),
          estimatedSavingMinor: dividendRoute - salaryRoute,
        ),
      );
    }
  }

  return opportunities;
}

List<TaxOpportunity> _soleTraderOpportunities(
  TaxInput input,
  DeTaxProfile profile,
  DeTaxTable table,
) {
  final business = deEuer(input, table);
  final opportunities = <TaxOpportunity>[];

  if (business.profitMinor > 0 &&
      business.profitMinor <= table.investmentDeduction.profitLimit) {
    opportunities.add(
      TaxOpportunity(
        id: 'de.investitionsabzugsbetrag',
        title: 'Investitionsabzugsbetrag nach § 7g EStG bilden',
        explanation:
            'Für geplante Anschaffungen lassen sich bis zu ${table.investmentDeduction.rateBasisPoints ~/ 100} % der voraussichtlichen Kosten gewinnmindernd abziehen, insgesamt höchstens ${deEuro(table.investmentDeduction.maxPerBusiness)} je Betrieb. Der Gewinn liegt unter ${deEuro(table.investmentDeduction.profitLimit)}, die Gewinngrenze ist damit eingehalten. Die Höhe der Ersparnis hängt von der geplanten Investition und dem Steuersatz ab.',
        source: Uri.parse('https://www.gesetze-im-internet.de/estg/__7g.html'),
        deadline: deFilingDeadline(table.startYear),
      ),
    );
  }

  opportunities.addAll(_smallBusinessOpportunity(input, profile, table));
  return opportunities;
}

List<TaxOpportunity> _companyOpportunities(
  TaxInput input,
  DeTaxProfile profile,
  DeTaxTable table,
) => _smallBusinessOpportunity(input, profile, table);

List<TaxOpportunity> _smallBusinessOpportunity(
  TaxInput input,
  DeTaxProfile profile,
  DeTaxTable table,
) {
  if (!deChargesVat(profile)) {
    return const [];
  }
  final Map<String, int> totals;
  if (profile.entityKind == EntityKind.company) {
    totals = deCompanyResult(input, table).totals;
  } else {
    totals = deEuer(input, table).totals;
  }
  var turnover = 0;
  for (final entry in totals.entries) {
    final category = deCategories[entry.key];
    if (category?.kind == TaxCategoryKind.income) {
      turnover += entry.value;
    }
  }
  // § 19 Abs. 1 Satz 1 UStG from 2025: the previous year's Gesamtumsatz must
  // stay at or below 25 000 Euro and the current year's at or below
  // 100 000 Euro. Both limits are "at most".
  if (profile.previousYearTurnoverMinor >
          table.vat.smallBusinessPreviousYearTurnover ||
      turnover > table.vat.smallBusinessCurrentYearTurnover) {
    return const [];
  }
  final vatDue =
      (totals['de.ust.ausgang'] ?? 0) - (totals['de.ust.eingang'] ?? 0);
  return [
    TaxOpportunity(
      id: 'de.kleinunternehmerregelung',
      title: 'Kleinunternehmerregelung nach § 19 UStG prüfen',
      explanation:
          'Der Vorjahresumsatz von ${deEuro(profile.previousYearTurnoverMinor)} und der diesjährige Umsatz von ${deEuro(turnover)} liegen unter den Grenzen von ${deEuro(table.vat.smallBusinessPreviousYearTurnover)} (Vorjahr) und ${deEuro(table.vat.smallBusinessCurrentYearTurnover)} (laufendes Jahr). Bleibt der laufende Umsatz unter der Grenze, entfällt die Umsatzsteuer; dafür entfällt auch der Vorsteuerabzug. Die Ersparnis ist die bisherige Zahllast.',
      source: Uri.parse(
        'https://www.gesetze-im-internet.de/ustg_1980/__19.html',
      ),
      estimatedSavingMinor: math.max(0, vatDue),
      deadline: deFilingDeadline(table.startYear),
    ),
  ];
}

TaxOpportunity _filingDeadline(DeTaxTable table) {
  final selfFiled = deFilingDeadline(table.startYear);
  final advised = deAdvisorFilingDeadline(table.startYear);
  return TaxOpportunity(
    id: 'de.frist_steuererklaerung',
    title: 'Abgabefrist der Steuererklärung',
    explanation:
        'Die Steuererklärung für ${table.startYear} ist bis ${deDate(selfFiled)} abzugeben (§ 149 Abs. 2 AO). Mit Steuerberater oder Lohnsteuerhilfeverein verlängert sich die Frist bis ${deDate(advised)} (§ 149 Abs. 3 AO). Fällt eine Frist auf einen Samstag, Sonntag oder Feiertag, verschiebt sie sich auf den nächsten Werktag (§ 108 Abs. 3 AO).',
    source: Uri.parse('https://www.gesetze-im-internet.de/ao_1977/__149.html'),
    deadline: selfFiled,
  );
}
