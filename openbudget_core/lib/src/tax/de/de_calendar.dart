import 'package:openbudget_core/src/tax/de/de_profile.dart';
import 'package:openbudget_core/src/tax/de/de_tables.dart';
import 'package:openbudget_core/src/tax/tax_calendar.dart';
import 'package:openbudget_core/src/tax/tax_model.dart';

final Uri _ao149 = Uri.parse(
  'https://www.gesetze-im-internet.de/ao_1977/__149.html',
);
final Uri _egao = Uri.parse(
  'https://www.gesetze-im-internet.de/aoeg_1977/art_97__36.html',
);
final Uri _estg37 = Uri.parse(
  'https://www.gesetze-im-internet.de/estg/__37.html',
);
final Uri _gewstg19 = Uri.parse(
  'https://www.gesetze-im-internet.de/gewstg/__19.html',
);
final Uri _ustg18 = Uri.parse(
  'https://www.gesetze-im-internet.de/ustg_1980/__18.html',
);
final Uri _lstAnmeldung = Uri.parse(
  'https://www.bundesfinanzministerium.de/Content/DE/Downloads/BMF_Schreiben/Steuerarten/Lohnsteuer/2025-08-14-Muster-Lohnsteuer-Anmeldung-2026.pdf?__blob=publicationFile&v=6',
);

const List<(int, String)> _quarters = [
  (3, '1. Quartal'),
  (6, '2. Quartal'),
  (9, '3. Quartal'),
  (12, '4. Quartal'),
];

/// The filing and payment dates the Veranlagungszeitraum [period] creates
/// for a German taxpayer, from the germany-tax skill.
///
/// The annual returns use the § 149 AO deadlines of `de_tables.dart`, moved
/// to the next working day by § 108 Abs. 3 AO. The prepayments and the
/// Voranmeldungen are payment dates, which § 108 does not move, so they are
/// shown unmoved: the date can only be a day early, never late. The titles
/// use the authority's German wording, as the pack's categories do.
List<TaxDeadline> deDeadlines(TaxYear period, DeTaxProfile profile) {
  final year = period.startYear;
  final next = year + 1;
  final entityKind = profile.entityKind;
  final deadlines = <TaxDeadline>[];

  void add({
    required String id,
    required String title,
    required TaxDeadlineKind kind,
    required DateTime dueDate,
    required Uri source,
    required String citation,
    required TaxEvidenceGrade grade,
    String? note,
    bool dependsOnProfile = false,
    DateTime? periodStart,
    DateTime? periodEnd,
    String? periodLabel,
    DateTime? rolledFrom,
  }) => deadlines.add(
    TaxDeadline(
      id: id,
      title: title,
      kind: kind,
      dueDate: dueDate,
      periodStart: periodStart ?? period.start,
      periodEnd: periodEnd ?? period.end,
      periodLabel: periodLabel ?? period.label,
      source: source,
      citation: citation,
      grade: grade,
      dependsOnProfile: dependsOnProfile,
      note: note,
      rolledFrom: rolledFrom,
    ),
  );

  final returns = switch (entityKind) {
    EntityKind.individual => 'Einkommensteuererklärung',
    EntityKind.soleTrader =>
      'Einkommensteuer-, Gewerbesteuer- und Umsatzsteuererklärung',
    EntityKind.company =>
      'Körperschaftsteuer-, Gewerbesteuer- und Umsatzsteuererklärung',
  };

  final nominalSelf = DateTime.utc(next, 7, 31);
  final self = deFilingDeadline(year);
  add(
    id: 'de.erklaerung.abgabe',
    title: 'Abgabe der $returns',
    kind: TaxDeadlineKind.filing,
    dueDate: self,
    source: _ao149,
    citation:
        '§ 149 Abs. 2 AO: sieben Monate nach Ablauf des Kalenderjahres; '
        '§ 108 Abs. 3 AO',
    grade: TaxEvidenceGrade.primary,
    note:
        'Gilt ohne Steuerberater oder Lohnsteuerhilfeverein. Wer nicht zur '
        'Abgabe verpflichtet ist, hat eigene Fristen.',
    rolledFrom: self == nominalSelf ? null : nominalSelf,
  );

  final advised = deAdvisorFilingDeadline(year);
  final nominalAdvised = DateTime.utc(year + 2, 3, 0);
  final transition = year <= 2024;
  add(
    id: 'de.erklaerung.abgabe-beraten',
    title: 'Abgabe der $returns mit Steuerberater',
    kind: TaxDeadlineKind.filing,
    dueDate: advised,
    source: transition ? _egao : _ao149,
    citation: transition
        ? 'Art. 97 § 36 Abs. 3 EGAO: Übergangsfrist; § 108 Abs. 3 AO'
        : '§ 149 Abs. 3 AO: Ende Februar des zweiten Folgejahres; '
              '§ 108 Abs. 3 AO',
    grade: TaxEvidenceGrade.primary,
    note:
        'Gilt, wenn ein Steuerberater oder Lohnsteuerhilfeverein die '
        'Erklärung erstellt.',
    rolledFrom: transition || advised == nominalAdvised ? null : nominalAdvised,
  );

  if (entityKind != EntityKind.company) {
    for (final (month, ordinal) in [
      (3, 'Erste'),
      (6, 'Zweite'),
      (9, 'Dritte'),
      (12, 'Vierte'),
    ]) {
      add(
        id: 'de.est.vorauszahlung',
        title: '$ordinal Einkommensteuer-Vorauszahlung',
        kind: TaxDeadlineKind.payment,
        dueDate: DateTime.utc(year, month, 10),
        source: _estg37,
        citation:
            '§ 37 EStG: 10. März, 10. Juni, 10. September und '
            '10. Dezember',
        grade: TaxEvidenceGrade.primary,
        note:
            'Gilt, wenn das Finanzamt Vorauszahlungen festgesetzt hat; das '
            'geschieht ab 400 € im Jahr und 100 € je Termin.',
      );
    }
  }

  final tradeTax =
      entityKind == EntityKind.company ||
      (entityKind == EntityKind.soleTrader &&
          profile.einkunftsArt == DeEinkunftsArt.gewerblich);
  if (tradeTax) {
    for (final (month, ordinal) in [
      (2, 'Erste'),
      (5, 'Zweite'),
      (8, 'Dritte'),
      (11, 'Vierte'),
    ]) {
      add(
        id: 'de.gewst.vorauszahlung',
        title: '$ordinal Gewerbesteuer-Vorauszahlung',
        kind: TaxDeadlineKind.payment,
        dueDate: DateTime.utc(year, month, 15),
        source: _gewstg19,
        citation:
            '§ 19 GewStG: 15. Februar, 15. Mai, 15. August und '
            '15. November',
        grade: TaxEvidenceGrade.primary,
        dependsOnProfile: entityKind == EntityKind.soleTrader,
        note:
            'Gilt, wenn die Gemeinde Vorauszahlungen festgesetzt hat; der '
            'Mindestbetrag je Termin ist 50 €.',
      );
    }
  }

  if (entityKind != EntityKind.individual &&
      profile.salesTaxRegistered &&
      !profile.smallBusinessExemption) {
    for (final (endMonth, label) in _quarters) {
      add(
        id: 'de.ust.voranmeldung',
        title: 'Umsatzsteuer-Voranmeldung und -Zahlung',
        kind: TaxDeadlineKind.filingAndPayment,
        dueDate: DateTime.utc(year, endMonth + 1, 10),
        periodStart: DateTime.utc(year, endMonth - 2),
        periodEnd: DateTime.utc(year, endMonth + 1),
        periodLabel: '$label $year',
        source: _ustg18,
        citation: '§ 18 UStG: der 10. Tag nach Ablauf des Zeitraums',
        grade: TaxEvidenceGrade.primary,
        dependsOnProfile: true,
        note:
            'Geht vom Quartal aus; bei über 9.000 € Vorjahressteuer gilt der '
            'Monat. Mit Dauerfristverlängerung verschiebt sich der Termin '
            'um einen Monat.',
      );
    }
  }

  if (entityKind == EntityKind.company) {
    for (final (endMonth, label) in _quarters) {
      add(
        id: 'de.lohnsteuer.anmeldung',
        title: 'Lohnsteuer-Anmeldung und -Zahlung',
        kind: TaxDeadlineKind.filingAndPayment,
        dueDate: DateTime.utc(year, endMonth + 1, 10),
        periodStart: DateTime.utc(year, endMonth - 2),
        periodEnd: DateTime.utc(year, endMonth + 1),
        periodLabel: '$label $year',
        source: _lstAnmeldung,
        citation:
            'BMF Muster Lohnsteuer-Anmeldung 2026: der 10. Tag nach Ablauf '
            'des Zeitraums',
        grade: TaxEvidenceGrade.primary,
        note:
            'Gilt, wenn die Firma Lohn zahlt. Der Zeitraum richtet sich nach '
            'der Vorjahressteuer: Monat über 5.000 €, Quartal über 1.080 €, '
            'sonst Jahr; hier steht das Quartal.',
      );
    }
  }

  return sortTaxDeadlines(deadlines);
}
