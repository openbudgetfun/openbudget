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
/// instead of guessing. A saving is quantified only on primary-grade
/// figures: the Basisrente headroom follows the `basisrenteCap` figure's
/// grade in the year's rule set, and the GmbH Gehalt-versus-Ausschüttung
/// comparison is signpost-only under the German perimeter (StBerG §5),
/// so it explains the general rule and points to a Steuerberater.
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

/// The named figure [id] of [table]'s year, or null when the rule set does
/// not name it.
TaxFigure? _figureFor(DeTaxTable table, String id) =>
    deRuleSetFor(table.startYear).figures[id];

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
        title: 'Freistellungsauftrag und Sparer-Pauschbetrag',
        explanation:
            'Der Sparer-Pauschbetrag von ${deEuro(assessment.sparerPauschbetrag)} ist nicht ausgeschöpft. Mit einem Freistellungsauftrag bei der Bank werden Kapitalerträge bis zu dieser Grenze ohne Abgeltungsteuer ausgezahlt.',
        source: Uri.parse('https://www.gesetze-im-internet.de/estg/__20.html'),
        estimatedSavingMinor: saving,
        ruleYear: input.year.label,
        assumptions: const [
          'Bei mehreren Banken gilt der Pauschbetrag insgesamt einmal und wird auf die Freistellungsaufträge verteilt.',
          'Die Schätzung setzt voraus, dass die Bank die einbehaltene Kapitalertragsteuer angibt.',
        ],
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
        title: 'Homeoffice-Pauschale und Höchstgrenze',
        explanation:
            'Für jeden Kalendertag mit überwiegend häuslicher Tätigkeit sind ${deEuro(daily)} abziehbar, höchstens ${deEuro(homeOfficeMax)} im Jahr (§ 4 Abs. 5 Satz 1 Nr. 6c EStG). Erfasst sind bisher ${deEuro(homeOfficeClaimed)}; es fehlen $remainingDays Tage (${deEuro(shortfall)}) bis zur Höchstgrenze.',
        source: Uri.parse('https://www.gesetze-im-internet.de/estg/__4.html'),
        estimatedSavingMinor:
            math.min(shortfall, assessment.taxableIncome) *
            assessment.marginalRateBasisPoints ~/
            10000,
        ruleYear: input.year.label,
        needsEvidence: true,
        deadline: DateTime.utc(table.startYear, 12, 31),
        assumptions: const [
          'Die Tage mit überwiegend häuslicher Tätigkeit sind aufgezeichnet oder werden geschätzt; ein Tagesnachweis ist die Grundlage.',
          'Die Pauschale und ein Arbeitszimmer können sich nicht überlappen.',
        ],
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
    // The headroom follows the named figure's grade: primary in 2026,
    // inferred in 2025, and never quantified on an unverified grade.
    final basisrenteGrade = _figureFor(table, 'basisrenteCap')?.grade;
    final saving = basisrenteGrade == TaxEvidenceGrade.primary
        ? usableBasisrente * assessment.marginalRateBasisPoints ~/ 10000
        : null;
    opportunities.add(
      TaxOpportunity(
        id: 'de.basisrente_hoechstbetrag',
        title: 'Basisrente und Höchstbetrag nach § 10 EStG',
        explanation:
            'Beiträge zu einer basisrentenversicherten Rente (Basisrente, Rürup) sind bis ${deEuro(basisrenteCap)} im Jahr als Sonderausgaben abziehbar (§ 10 Abs. 3 EStG${profile.jointAssessment ? '; bei Zusammenveranlagung verdoppelter Höchstbetrag' : ''}${assessment.statutoryPension > 0 ? ', gemindert um ${deEuro(assessment.statutoryPension)} Beiträge zur gesetzlichen Rentenversicherung' : ''}). Erfasst sind bisher ${deEuro(assessment.basisrentePaid)}. ${basisrenteGrade == TaxEvidenceGrade.primary ? 'Die Ersparnis gilt für zusätzliche Beiträge bis zur Höhe des zu versteuernden Einkommens; die Auszahlung der Rente ist später steuerpflichtig.' : 'Für dieses Jahr ist der Höchstbetrag nur abgeleitet; bis der Gesetzestext geprüft ist, wird keine Ersparnis beziffert.'}',
        source: Uri.parse('https://www.gesetze-im-internet.de/estg/__10.html'),
        estimatedSavingMinor: saving,
        ruleYear: input.year.label,
        grade: basisrenteGrade ?? TaxEvidenceGrade.inferred,
        needsEvidence: true,
        deadline: DateTime.utc(table.startYear, 12, 31),
        assumptions: const [
          'Die Beiträge gelten für einen basisrentenversicherten Vertrag; die Beitragsbestätigung ist der Nachweis.',
          'Die Auszahlung der Rente ist später steuerpflichtig.',
          'Bei Zusammenveranlagung verdoppelt sich der Höchstbetrag.',
        ],
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
          title: 'Günstigerprüfung für Kapitalerträge',
          explanation: 'Der persönliche Steuersatz liegt unter 25 %. Auf Antrag werden die Kapitalerträge statt mit der Abgeltungsteuer mit dem Tarif besteuert (§ 32d Abs. 6 EStG). Die Schätzung vergleicht nur die Einkommensteuer, nicht die Zuschlagsteuern.',
          source: Uri.parse(
            'https://www.gesetze-im-internet.de/estg/__32d.html',
          ),
          estimatedSavingMinor: saving,
          ruleYear: input.year.label,
          deadline: deFilingDeadline(table.startYear),
          assumptions: const [
            'Der Antrag wird in der Steuererklärung gestellt; die Bank behält zunächst die Abgeltungsteuer ein.',
            'Die Schätzung vergleicht nur die Einkommensteuer, nicht die Zuschlagsteuern.',
          ],
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
    // Signpost-only: Gehalt-versus-Ausschüttung comparisons for a GmbH
    // are reserved advice territory under StBerG §5, so the row explains
    // the general mechanics, names the vGA risk and points to a
    // Steuerberater, without quantifying either route.
    opportunities.add(
      TaxOpportunity(
        id: 'de.geschaeftsfuehrer_vergleich',
        title: 'Gehalt und Gewinnausschüttung im Vergleich',
        explanation: 'Ein Gesellschafter-Geschäftsführer kann den Gewinn als Gehalt oder als Ausschüttung beziehen; beide Wege sind unterschiedlich besteuert (Gehalt: Einkommensteuer mit Zuschlagsteuern; Ausschüttung: Körperschaftsteuer, Gewerbesteuer und Abgeltungsteuer, ab 25 % Beteiligung Teileinkünfteverfahren, § 32d Abs. 2 Nr. 3 EStG). Ein unangemessen niedriges Gehalt kann als verdeckte Gewinnausschüttung gelten; Angemessenheit und Sozialversicherung sind Einzelfallfragen. Dieser Vergleich wird nicht beziffert: Er gehört in die Beratung durch einen Steuerberater, der die volle Situation prüft.',
        source: Uri.parse(
          'https://www.gesetze-im-internet.de/estg/__32d.html',
        ),
        ruleYear: input.year.label,
        signpostOnly: true,
        assumptions: const [
          'Gehalts- und Ausschüttungswege hängen von Beteiligung, Angemessenheit und Sozialversicherung ab.',
          'Die Zahlen dieses Unternehmens werden hier nicht verglichen; ein Steuerberater kann beide Wege beziffern.',
        ],
      ),
    );
    break;
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
        title: 'Investitionsabzugsbetrag nach § 7g EStG',
        explanation:
            'Für geplante Anschaffungen lassen sich bis zu ${table.investmentDeduction.rateBasisPoints ~/ 100} % der voraussichtlichen Kosten gewinnmindernd abziehen, insgesamt höchstens ${deEuro(table.investmentDeduction.maxPerBusiness)} je Betrieb. Der Gewinn liegt unter ${deEuro(table.investmentDeduction.profitLimit)}, die Gewinngrenze ist damit eingehalten. Die Höhe der Ersparnis hängt von der geplanten Investition und dem Steuersatz ab.',
        source: Uri.parse('https://www.gesetze-im-internet.de/estg/__7g.html'),
        ruleYear: input.year.label,
        deadline: deFilingDeadline(table.startYear),
        assumptions: const [
          'Die Investition muss im Ansatzjahr geplant und innerhalb von drei Jahren durchgeführt werden; andernfalls wird der Abzug hinzugerechnet.',
          'Die Ersparnis hängt von der Höhe der geplanten Investition und dem Steuersatz ab.',
        ],
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
      title: 'Kleinunternehmerregelung nach § 19 UStG',
      explanation:
          'Der Vorjahresumsatz von ${deEuro(profile.previousYearTurnoverMinor)} und der diesjährige Umsatz von ${deEuro(turnover)} liegen unter den Grenzen von ${deEuro(table.vat.smallBusinessPreviousYearTurnover)} (Vorjahr) und ${deEuro(table.vat.smallBusinessCurrentYearTurnover)} (laufendes Jahr). Bleibt der laufende Umsatz unter der Grenze, entfällt die Umsatzsteuer; dafür entfällt auch der Vorsteuerabzug. Die Ersparnis ist die bisherige Zahllast.',
      source: Uri.parse(
        'https://www.gesetze-im-internet.de/ustg_1980/__19.html',
      ),
      estimatedSavingMinor: math.max(0, vatDue),
      ruleYear: input.year.label,
      deadline: deFilingDeadline(table.startYear),
      assumptions: const [
        'Der Vorjahresumsatz und der laufende Umsatz bleiben unter den Grenzen des § 19 UStG.',
        'Ohne Umsatzsteuer entfällt auch der Vorsteuerabzug; die Ersparnis ist die bisherige Zahllast.',
      ],
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
    ruleYear: '${table.startYear}',
    deadline: selfFiled,
    assumptions: const [
      'Die Fristen folgen § 149 AO; mit Steuerberater oder Lohnsteuerhilfeverein gilt die verlängerte Frist.',
      'Fällt eine Frist auf einen Samstag, Sonntag oder Feiertag, verschiebt sie sich auf den nächsten Werktag.',
    ],
  );
}
