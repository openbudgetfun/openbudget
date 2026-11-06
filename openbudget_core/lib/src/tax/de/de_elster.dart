import 'package:meta/meta.dart';

/// One ELSTER Kennzahl locator: which form, which year, which block of the
/// form, which small field number.
///
/// Kennzahlen are not unique inside a form — Anlage N reuses 110 and 111 for
/// the wage block and the commute block, Anlage EÜR reuses 100, 120, 123,
/// 131, 132 and 187 between its general, expense and Rücklage blocks — so a
/// field is identified by the form, the tax year, the section and the Kz
/// together, never by the Kz alone. The Zeile is a display locator for one
/// year only and may be null where the form was not read.
@immutable
final class DeKennzahl {
  const DeKennzahl({
    required this.form,
    required this.year,
    required this.section,
    required this.kz,
    required this.meaning,
    this.zeile,
    this.person,
  });

  /// The form the Kz is printed on, such as `Anlage N` or `Anlage EÜR`.
  final String form;

  /// The tax year the locator was read for. ESt forms for 2026 were not
  /// published when the pack was researched, so their entries stay at 2025
  /// and checklists reuse them with a visible warning.
  final int year;

  /// The block of the form, so a repeated Kz stays unambiguous.
  final String section;

  /// The Kennzahl printed beside the entry box.
  final int kz;

  /// What the field holds, in the form's own language.
  final String meaning;

  /// The printed Zeile for [year], or null when the form line was not read.
  final int? zeile;

  /// `A` (taxpayer) or `B` (spouse) when the form pairs the columns by
  /// person, null when the line has a single column.
  final String? person;
}

/// Every ELSTER Kennzahl the researched forms give, by tax category code.
///
/// Sources: Anlage N, KAP, Vorsorgeaufwand, Sonderausgaben, S and G 2025
/// (BMF forms via third-party copies), Anlage EÜR 2025 and 2026 (BMF
/// letters of 29 Aug 2025 and 1 Sep 2026), UStVA 2026 (BMF letter of
/// 29 Dec 2025; the Kz are stable year to year). Company forms (KSt 1,
/// Anlage GK, Anlage ZVE, GewSt 1 A) were not retrieved, so no company
/// category carries Kz yet.
const Map<String, List<DeKennzahl>> deKennzahlenByCategory = {
  'de.ind.arbeitslohn': [
    DeKennzahl(
      form: 'Anlage N',
      year: 2025,
      section: 'Arbeitslohn',
      kz: 110,
      zeile: 5,
      meaning: 'Bruttoarbeitslohn (Steuerklasse 1-5)',
    ),
    DeKennzahl(
      form: 'Anlage N',
      year: 2025,
      section: 'Arbeitslohn',
      kz: 111,
      zeile: 5,
      meaning: 'Bruttoarbeitslohn (Steuerklasse 6 oder Urlaubskasse)',
    ),
  ],
  'de.ind.lohnsteuer': [
    DeKennzahl(
      form: 'Anlage N',
      year: 2025,
      section: 'Lohnsteuer',
      kz: 140,
      zeile: 6,
      meaning: 'Einbehaltene Lohnsteuer',
      person: 'A',
    ),
    DeKennzahl(
      form: 'Anlage N',
      year: 2025,
      section: 'Lohnsteuer',
      kz: 141,
      zeile: 6,
      meaning: 'Einbehaltene Lohnsteuer',
      person: 'B',
    ),
  ],
  'de.ind.werbungskosten': [
    DeKennzahl(
      form: 'Anlage N',
      year: 2025,
      section: 'Werbungskosten',
      kz: 310,
      zeile: 53,
      meaning: 'Beiträge zu Berufsverbänden',
    ),
    DeKennzahl(
      form: 'Anlage N',
      year: 2025,
      section: 'Werbungskosten',
      kz: 320,
      zeile: 56,
      meaning: 'Arbeitsmittel (Summe)',
    ),
    DeKennzahl(
      form: 'Anlage N',
      year: 2025,
      section: 'Werbungskosten',
      kz: 330,
      zeile: 60,
      meaning: 'Fortbildungskosten',
    ),
    DeKennzahl(
      form: 'Anlage N',
      year: 2025,
      section: 'Werbungskosten',
      kz: 380,
      zeile: 64,
      meaning: 'Fähr-, Flug- und sonstige Kosten (Summe)',
    ),
  ],
  'de.ind.homeoffice': [
    DeKennzahl(
      form: 'Anlage N',
      year: 2025,
      section: 'Homeoffice, erster Beschäftigungsort nicht besucht',
      kz: 335,
      zeile: 58,
      meaning:
          'Homeoffice-Tagespauschale: Tage ohne Besuch des ersten '
          'Beschäftigungsorts',
    ),
    DeKennzahl(
      form: 'Anlage N',
      year: 2025,
      section: 'Homeoffice, kein anderer Tätigkeitsort',
      kz: 336,
      zeile: 59,
      meaning:
          'Homeoffice-Tagespauschale: Tage ohne dauerhaft verfügbaren '
          'anderen Tätigkeitsort',
    ),
  ],
  'de.ind.arbeitszimmer': [
    DeKennzahl(
      form: 'Anlage N',
      year: 2025,
      section: 'Häusliches Arbeitszimmer',
      kz: 325,
      zeile: 57,
      meaning:
          'Häusliches Arbeitszimmer: tatsächliche Kosten oder '
          'Jahrespauschale 1 260 Euro',
    ),
  ],
  'de.ind.kapitalertraege': [
    DeKennzahl(
      form: 'Anlage KAP',
      year: 2025,
      section: 'Kapitalerträge mit Steuerabzug',
      kz: 210,
      zeile: 7,
      meaning: 'Kapitalerträge, die dem deutschen Steuerabzug unterlagen',
      person: 'A',
    ),
    DeKennzahl(
      form: 'Anlage KAP',
      year: 2025,
      section: 'Kapitalerträge mit Steuerabzug',
      kz: 410,
      zeile: 7,
      meaning: 'Kapitalerträge, die dem deutschen Steuerabzug unterlagen',
      person: 'B',
    ),
  ],
  'de.ind.kapitalertragsteuer': [
    DeKennzahl(
      form: 'Anlage KAP',
      year: 2025,
      section: 'Einbehaltene Steuer',
      kz: 280,
      zeile: 37,
      meaning: 'Einbehaltene Kapitalertragsteuer',
      person: 'A',
    ),
    DeKennzahl(
      form: 'Anlage KAP',
      year: 2025,
      section: 'Einbehaltene Steuer',
      kz: 281,
      zeile: 38,
      meaning: 'Einbehaltener Solidaritätszuschlag',
      person: 'A',
    ),
    DeKennzahl(
      form: 'Anlage KAP',
      year: 2025,
      section: 'Einbehaltene Steuer',
      kz: 480,
      zeile: 37,
      meaning: 'Einbehaltene Kapitalertragsteuer',
      person: 'B',
    ),
    DeKennzahl(
      form: 'Anlage KAP',
      year: 2025,
      section: 'Einbehaltene Steuer',
      kz: 481,
      zeile: 38,
      meaning: 'Einbehaltener Solidaritätszuschlag',
      person: 'B',
    ),
  ],
  'de.ind.basisrente': [
    DeKennzahl(
      form: 'Anlage Vorsorgeaufwand',
      year: 2025,
      section: 'Altersvorsorge',
      kz: 303,
      zeile: 8,
      meaning: 'Beiträge zur Basisrente (Rürup)',
      person: 'A',
    ),
    DeKennzahl(
      form: 'Anlage Vorsorgeaufwand',
      year: 2025,
      section: 'Altersvorsorge',
      kz: 403,
      zeile: 8,
      meaning: 'Beiträge zur Basisrente (Rürup)',
      person: 'B',
    ),
  ],
  'de.ind.spenden': [
    DeKennzahl(
      form: 'Anlage Sonderausgaben',
      year: 2025,
      section: 'Spenden',
      kz: 123,
      zeile: 5,
      meaning: 'Spenden und Mitgliedsbeiträge, inland (laut Bestätigungen)',
      person: 'A',
    ),
    DeKennzahl(
      form: 'Anlage Sonderausgaben',
      year: 2025,
      section: 'Spenden',
      kz: 124,
      zeile: 5,
      meaning: 'Spenden und Mitgliedsbeiträge, inland (laut Betriebsfinanzamt)',
      person: 'B',
    ),
  ],
  'de.euer.betriebseinnahmen': [
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2025,
      section: 'Betriebseinnahmen',
      kz: 112,
      zeile: 15,
      meaning: 'Umsatzsteuerpflichtige Betriebseinnahmen',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2026,
      section: 'Betriebseinnahmen',
      kz: 112,
      zeile: 15,
      meaning: 'Umsatzsteuerpflichtige Betriebseinnahmen',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2025,
      section: 'Kleinunternehmer',
      kz: 111,
      zeile: 12,
      meaning: 'Betriebseinnahmen als Kleinunternehmer (§ 19 Abs. 1 UStG)',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2026,
      section: 'Kleinunternehmer',
      kz: 111,
      zeile: 12,
      meaning: 'Betriebseinnahmen als Kleinunternehmer (§ 19 Abs. 1 UStG)',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2025,
      section: 'Summe Betriebseinnahmen',
      kz: 159,
      zeile: 23,
      meaning: 'Summe der Betriebseinnahmen',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2026,
      section: 'Summe Betriebseinnahmen',
      kz: 159,
      zeile: 23,
      meaning: 'Summe der Betriebseinnahmen',
    ),
  ],
  'de.euer.wareneinkauf': [
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2025,
      section: 'Wareneinkauf',
      kz: 100,
      zeile: 27,
      meaning: 'Waren, Rohstoffe und Hilfsstoffe',
    ),
    // The 2026 form inserts a Zeile before this block; the research lists
    // "Z29" against the +1 rule, so the Zeile stays unread.
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2026,
      section: 'Wareneinkauf',
      kz: 100,
      meaning: 'Waren, Rohstoffe und Hilfsstoffe',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2025,
      section: 'Fremdleistungen',
      kz: 110,
      zeile: 29,
      meaning: 'Bezogene Fremdleistungen',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2026,
      section: 'Fremdleistungen',
      kz: 110,
      zeile: 30,
      meaning: 'Bezogene Fremdleistungen',
    ),
  ],
  'de.euer.personal': [
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2025,
      section: 'Personal',
      kz: 120,
      zeile: 30,
      meaning: 'Ausgaben für eigenes Personal',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2026,
      section: 'Personal',
      kz: 120,
      zeile: 31,
      meaning: 'Ausgaben für eigenes Personal',
    ),
  ],
  'de.euer.afa': [
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2025,
      section: 'AfA Grundstücke',
      kz: 136,
      zeile: 31,
      meaning: 'AfA auf Grundstücke',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2026,
      section: 'AfA Grundstücke',
      kz: 136,
      zeile: 32,
      meaning: 'AfA auf Grundstücke',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2025,
      section: 'AfA immaterielle Wirtschaftsgüter',
      kz: 131,
      zeile: 32,
      meaning: 'AfA auf immaterielle Wirtschaftsgüter',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2026,
      section: 'AfA immaterielle Wirtschaftsgüter',
      kz: 131,
      zeile: 33,
      meaning: 'AfA auf immaterielle Wirtschaftsgüter',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2025,
      section: 'AfA bewegliche Wirtschaftsgüter',
      kz: 130,
      zeile: 33,
      meaning: 'AfA auf bewegliche Wirtschaftsgüter',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2026,
      section: 'AfA bewegliche Wirtschaftsgüter',
      kz: 130,
      zeile: 34,
      meaning: 'AfA auf bewegliche Wirtschaftsgüter',
    ),
  ],
  'de.euer.gwg': [
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2025,
      section: 'Geringwertige Wirtschaftsgüter',
      kz: 132,
      zeile: 36,
      meaning: 'Geringwertige Wirtschaftsgüter (§ 6 Abs. 2 EStG)',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2026,
      section: 'Geringwertige Wirtschaftsgüter',
      kz: 132,
      zeile: 37,
      meaning: 'Geringwertige Wirtschaftsgüter (§ 6 Abs. 2 EStG)',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2025,
      section: 'Sammelposten',
      kz: 137,
      zeile: 37,
      meaning: 'Auflösung Sammelposten (§ 6 Abs. 2a EStG)',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2026,
      section: 'Sammelposten',
      kz: 137,
      zeile: 38,
      meaning: 'Auflösung Sammelposten (§ 6 Abs. 2a EStG)',
    ),
  ],
  'de.euer.raumkosten': [
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2025,
      section: 'Raumkosten',
      kz: 150,
      zeile: 39,
      meaning: 'Miete und Pacht für Geschäftsräume',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2026,
      section: 'Raumkosten',
      kz: 150,
      zeile: 40,
      meaning: 'Miete und Pacht für Geschäftsräume',
    ),
  ],
  'de.euer.arbeitszimmer': [
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2025,
      section: 'Häusliches Arbeitszimmer',
      kz: 162,
      zeile: 65,
      meaning: 'Häusliches Arbeitszimmer, nicht abziehbar',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2026,
      section: 'Häusliches Arbeitszimmer',
      kz: 162,
      zeile: 66,
      meaning: 'Häusliches Arbeitszimmer, nicht abziehbar',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2025,
      section: 'Häusliches Arbeitszimmer',
      kz: 172,
      zeile: 65,
      meaning: 'Häusliches Arbeitszimmer, abziehbar',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2026,
      section: 'Häusliches Arbeitszimmer',
      kz: 172,
      zeile: 66,
      meaning: 'Häusliches Arbeitszimmer, abziehbar',
    ),
  ],
  'de.euer.homeoffice': [
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2025,
      section: 'Homeoffice',
      kz: 163,
      zeile: 66,
      meaning: 'Tagespauschale für Arbeit im Haushalt (Homeoffice)',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2026,
      section: 'Homeoffice',
      kz: 163,
      zeile: 67,
      meaning: 'Tagespauschale für Arbeit im Haushalt (Homeoffice)',
    ),
  ],
  'de.euer.fahrtkosten': [
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2025,
      section: 'Fahrtkosten',
      kz: 146,
      zeile: 70,
      meaning: 'Sonstige tatsächliche Fahrtkosten',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2026,
      section: 'Fahrtkosten',
      kz: 146,
      zeile: 71,
      meaning: 'Sonstige tatsächliche Fahrtkosten',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2025,
      section: 'Fahrten mit privatem Fahrzeug',
      kz: 147,
      zeile: 71,
      meaning: 'Fahrtkosten mit einem nicht betrieblichen Fahrzeug',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2026,
      section: 'Fahrten mit privatem Fahrzeug',
      kz: 147,
      zeile: 72,
      meaning: 'Fahrtkosten mit einem nicht betrieblichen Fahrzeug',
    ),
  ],
  'de.euer.bewirtung': [
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2025,
      section: 'Bewirtung',
      kz: 165,
      zeile: 63,
      meaning: 'Bewirtungskosten, nicht abziehbar (30 %)',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2026,
      section: 'Bewirtung',
      kz: 165,
      zeile: 64,
      meaning: 'Bewirtungskosten, nicht abziehbar (30 %)',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2025,
      section: 'Bewirtung',
      kz: 175,
      zeile: 63,
      meaning: 'Bewirtungskosten, abziehbar (70 %)',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2026,
      section: 'Bewirtung',
      kz: 175,
      zeile: 64,
      meaning: 'Bewirtungskosten, abziehbar (70 %)',
    ),
  ],
  'de.euer.telekommunikation': [
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2025,
      section: 'Telekommunikation',
      kz: 280,
      zeile: 43,
      meaning: 'Telekommunikationskosten',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2026,
      section: 'Telekommunikation',
      kz: 280,
      zeile: 44,
      meaning: 'Telekommunikationskosten',
    ),
  ],
  'de.euer.fortbildung': [
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2025,
      section: 'Fortbildung',
      kz: 281,
      zeile: 45,
      meaning: 'Fortbildungskosten',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2026,
      section: 'Fortbildung',
      kz: 281,
      zeile: 46,
      meaning: 'Fortbildungskosten',
    ),
  ],
  'de.euer.versicherungen': [
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2025,
      section: 'Versicherungen',
      kz: 223,
      zeile: 49,
      meaning: 'Beiträge, Gebühren, Abgaben und Versicherungen',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2026,
      section: 'Versicherungen',
      kz: 223,
      zeile: 50,
      meaning: 'Beiträge, Gebühren, Abgaben und Versicherungen',
    ),
  ],
  'de.euer.sonstige': [
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2025,
      section: 'Sonstige Betriebsausgaben',
      kz: 183,
      zeile: 60,
      meaning: 'Übrige unbeschränkt abziehbare Betriebsausgaben',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2026,
      section: 'Sonstige Betriebsausgaben',
      kz: 183,
      zeile: 61,
      meaning: 'Übrige unbeschränkt abziehbare Betriebsausgaben',
    ),
  ],
  'de.euer.entnahmen': [
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2025,
      section: 'Entnahmen und Einlagen',
      kz: 122,
      zeile: 106,
      meaning: 'Entnahmen einschließlich Sach- und Nutzungsentnahmen',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2026,
      section: 'Entnahmen und Einlagen',
      kz: 122,
      zeile: 107,
      meaning: 'Entnahmen einschließlich Sach- und Nutzungsentnahmen',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2025,
      section: 'Entnahmen und Einlagen',
      kz: 123,
      zeile: 107,
      meaning: 'Einlagen einschließlich Sach-, Leistungs- und Nutzungseinlagen',
    ),
    DeKennzahl(
      form: 'Anlage EÜR',
      year: 2026,
      section: 'Entnahmen und Einlagen',
      kz: 123,
      zeile: 108,
      meaning: 'Einlagen einschließlich Sach-, Leistungs- und Nutzungseinlagen',
    ),
  ],
  'de.euer.gewerbesteuer': [
    DeKennzahl(
      form: 'Anlage G',
      year: 2025,
      section: '§ 35 EStG Messbetrag',
      kz: 64,
      zeile: 51,
      meaning: 'Festzusetzender Gewerbesteuer-Messbetrag',
      person: 'A',
    ),
    DeKennzahl(
      form: 'Anlage G',
      year: 2025,
      section: '§ 35 EStG Messbetrag',
      kz: 65,
      zeile: 51,
      meaning: 'Festzusetzender Gewerbesteuer-Messbetrag',
      person: 'B',
    ),
    DeKennzahl(
      form: 'Anlage G',
      year: 2025,
      section: '§ 35 EStG Gewerbesteuer',
      kz: 66,
      zeile: 52,
      meaning: 'An der Einkommensteuer anzurechnende Gewerbesteuer',
      person: 'A',
    ),
    DeKennzahl(
      form: 'Anlage G',
      year: 2025,
      section: '§ 35 EStG Gewerbesteuer',
      kz: 67,
      zeile: 52,
      meaning: 'An der Einkommensteuer anzurechnende Gewerbesteuer',
      person: 'B',
    ),
  ],
  'de.ust.ausgang': [
    DeKennzahl(
      form: 'UStVA',
      year: 2025,
      section: 'Steuerpflichtige Umsätze',
      kz: 81,
      meaning: 'Umsätze zum Steuersatz 19 % (Bemessungsgrundlage)',
    ),
    DeKennzahl(
      form: 'UStVA',
      year: 2025,
      section: 'Steuerpflichtige Umsätze',
      kz: 86,
      meaning: 'Umsätze zum Steuersatz 7 % (Bemessungsgrundlage)',
    ),
    DeKennzahl(
      form: 'UStVA',
      year: 2026,
      section: 'Steuerpflichtige Umsätze',
      kz: 81,
      zeile: 13,
      meaning: 'Umsätze zum Steuersatz 19 % (Bemessungsgrundlage)',
    ),
    DeKennzahl(
      form: 'UStVA',
      year: 2026,
      section: 'Steuerpflichtige Umsätze',
      kz: 86,
      zeile: 14,
      meaning: 'Umsätze zum Steuersatz 7 % (Bemessungsgrundlage)',
    ),
  ],
  'de.ust.eingang': [
    DeKennzahl(
      form: 'UStVA',
      year: 2025,
      section: 'Vorsteuer',
      kz: 66,
      meaning: 'Vorsteuerbeträge aus Rechnungen',
    ),
    DeKennzahl(
      form: 'UStVA',
      year: 2026,
      section: 'Vorsteuer',
      kz: 66,
      zeile: 38,
      meaning: 'Vorsteuerbeträge aus Rechnungen',
    ),
  ],
};

/// The Kennzahlen of [categoryCode] for the tax year [year], empty when the
/// pack has none (company forms, Anlage SO and the not-extracted Anlagen).
List<DeKennzahl> deKennzahlenFor(String categoryCode, int year) => [
  for (final entry
      in deKennzahlenByCategory[categoryCode] ?? const <DeKennzahl>[])
    if (entry.year == year) entry,
];
