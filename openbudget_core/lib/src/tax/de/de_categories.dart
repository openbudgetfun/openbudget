import 'package:openbudget_core/src/tax/tax_model.dart';

/// Umsatzsteuer charged on the business's own invoices (§ 12 UStG).
const TaxCategory deVatOutput = TaxCategory(
  code: 'de.ust.ausgang',
  label: 'Umsatzsteuer (Ausgangsrechnungen)',
  kind: TaxCategoryKind.salesTaxCollected,
  entityKinds: {TaxEntityKind.soleTrader, TaxEntityKind.company},
  reportReference: 'USt 2A – Umsätze zum Steuersatz',
  description: 'Die in Rechnungen offen ausgewiesene Umsatzsteuer. Nur relevant, wenn die Kleinunternehmerregelung nicht gilt.',
);

/// Vorsteuer paid on the business's own receipts (§ 15 UStG).
const TaxCategory deVatInput = TaxCategory(
  code: 'de.ust.eingang',
  label: 'Vorsteuer (Eingangsrechnungen)',
  kind: TaxCategoryKind.salesTaxPaid,
  entityKinds: {TaxEntityKind.soleTrader, TaxEntityKind.company},
  reportReference: 'USt-Voranmeldung – Vorsteuer',
  description: 'Die in Eingangsrechnungen enthaltene Umsatzsteuer, abziehbar nach § 15 UStG.',
);

/// The categories of a person's own return (Einkommensteuer).
const List<TaxCategory> deIndividualCategories = [
  TaxCategory(
    code: 'de.ind.arbeitslohn',
    label: 'Arbeitslohn',
    kind: TaxCategoryKind.income,
    entityKinds: {TaxEntityKind.individual},
    reportReference: 'Anlage N – Arbeitslohn',
    description: 'Bruttoarbeitslohn vor Abzug der Lohnsteuer.',
  ),
  TaxCategory(
    code: 'de.ind.werbungskosten',
    label: 'Werbungskosten',
    kind: TaxCategoryKind.expense,
    entityKinds: {TaxEntityKind.individual},
    reportReference: 'Anlage N – Werbungskosten',
    description: 'Tatsächliche Werbungskosten. Ist der Betrag niedriger als der Arbeitnehmer-Pauschbetrag, wird dieser abgezogen.',
  ),
  TaxCategory(
    code: 'de.ind.arbeitszimmer',
    label: 'Häusliches Arbeitszimmer',
    kind: TaxCategoryKind.expense,
    entityKinds: {TaxEntityKind.individual},
    reportReference: 'Anlage N Z57 (Kz 325) – Häusliches Arbeitszimmer',
    description:
        'Jahrespauschale von 1 260 Euro, wenn das Arbeitszimmer den Mittelpunkt '
        'der Tätigkeit bildet, sonst die tatsächlichen Kosten '
        '(§ 4 Abs. 5 Satz 1 Nr. 6b EStG). Nicht zusammen mit der '
        'Homeoffice-Tagespauschale für dieselben Tage.',
  ),
  TaxCategory(
    code: 'de.ind.homeoffice',
    label: 'Homeoffice-Pauschale',
    kind: TaxCategoryKind.expense,
    entityKinds: {TaxEntityKind.individual},
    reportReference:
        'Anlage N Z58/Z59 (Kz 335/336) – Homeoffice-Tagespauschale',
    description:
        '6 Euro je Kalendertag, höchstens 1 260 Euro im Jahr '
        '(§ 4 Abs. 5 Satz 1 Nr. 6c EStG). Der Finanzbetrag wird je Tag '
        'erfasst; Z57 und Z58/Z59 dürfen sich zeitlich nicht überlappen.',
  ),
  TaxCategory(
    code: 'de.ind.sonstige_einkuenfte',
    label: 'Sonstige Einkünfte',
    kind: TaxCategoryKind.income,
    entityKinds: {TaxEntityKind.individual},
    reportReference: 'Anlage SO – Sonstige Einkünfte',
    description: 'Einkünfte, die dem Tarif unterliegen und in keiner anderen Kategorie erfasst sind.',
  ),
  TaxCategory(
    code: 'de.ind.kapitalertraege',
    label: 'Kapitalerträge',
    kind: TaxCategoryKind.income,
    entityKinds: {TaxEntityKind.individual},
    reportReference: 'Anlage KAP – Kapitalerträge',
    description: 'Zinsen, Dividenden und Veräußerungsgewinne. Sie unterliegen der Abgeltungsteuer nach § 32d EStG.',
  ),
  TaxCategory(
    code: 'de.ind.basisrente',
    label: 'Basisrente (Rürup)',
    kind: TaxCategoryKind.relief,
    entityKinds: {TaxEntityKind.individual},
    reportReference: 'Anlage Vorsorgeaufwand – Altersvorsorgebeiträge',
    description: 'Beiträge zu einer Basisrente, abziehbar bis zum Höchstbetrag nach § 10 Abs. 3 EStG.',
  ),
  TaxCategory(
    code: 'de.ind.spenden',
    label: 'Spenden und Mitgliedsbeiträge',
    kind: TaxCategoryKind.relief,
    entityKinds: {TaxEntityKind.individual},
    reportReference: 'Anlage Sonderausgaben – Spenden',
    description: 'Zuwendungen nach § 10b EStG. Mindestens der Sonderausgaben-Pauschbetrag nach § 10c EStG wird abgezogen.',
  ),
  TaxCategory(
    code: 'de.ind.lohnsteuer',
    label: 'Lohnsteuer',
    kind: TaxCategoryKind.taxPaid,
    entityKinds: {TaxEntityKind.individual},
    reportReference: 'Anlage N – Lohnsteuer',
    description:
        'Einbehaltene Lohnsteuer, die auf die Steuerschuld angerechnet wird.',
  ),
  TaxCategory(
    code: 'de.ind.kapitalertragsteuer',
    label: 'Kapitalertragsteuer',
    kind: TaxCategoryKind.taxPaid,
    entityKinds: {TaxEntityKind.individual},
    reportReference: 'Anlage KAP – Kapitalertragsteuer',
    description: 'Einbehaltene Kapitalertragsteuer einschließlich Solidaritätszuschlag auf die Abgeltungsteuer.',
  ),
];

/// The EÜR categories of a sole trader, in Anlage EÜR order.
const List<TaxCategory> deSoleTraderCategories = [
  TaxCategory(
    code: 'de.euer.betriebseinnahmen',
    label: 'Betriebseinnahmen',
    kind: TaxCategoryKind.income,
    entityKinds: {TaxEntityKind.soleTrader},
    reportReference: 'Anlage EÜR – Betriebseinnahmen',
    description: 'Vereinnahmte Entgelte für Lieferungen und Leistungen.',
  ),
  TaxCategory(
    code: 'de.euer.wareneinkauf',
    label: 'Wareneinkauf',
    kind: TaxCategoryKind.expense,
    entityKinds: {TaxEntityKind.soleTrader},
    reportReference: 'Anlage EÜR – Wareneinkauf und Fremdleistungen',
  ),
  TaxCategory(
    code: 'de.euer.personal',
    label: 'Personalaufwand',
    kind: TaxCategoryKind.expense,
    entityKinds: {TaxEntityKind.soleTrader},
    reportReference: 'Anlage EÜR – Personalaufwand',
    description: 'Löhne, Gehälter und Sozialabgaben der Beschäftigten.',
  ),
  TaxCategory(
    code: 'de.euer.afa',
    label: 'Absetzungen für Abnutzung (AfA)',
    kind: TaxCategoryKind.expense,
    entityKinds: {TaxEntityKind.soleTrader},
    reportReference: 'Anlage EÜR – Absetzungen für Abnutzung',
    description: 'Die Jahres-AfA der abnutzbaren Wirtschaftsgüter. Die AfA-Tabelle wird nicht geführt; der Betrag wird übernommen.',
  ),
  TaxCategory(
    code: 'de.euer.gwg',
    label: 'Geringwertige Wirtschaftsgüter (GWG)',
    kind: TaxCategoryKind.expense,
    entityKinds: {TaxEntityKind.soleTrader},
    reportReference: 'Anlage EÜR – Geringwertige Wirtschaftsgüter',
    description: 'Sofort abziehbar bis 800 Euro netto je Wirtschaftsgut (§ 6 Abs. 2 EStG).',
  ),
  TaxCategory(
    code: 'de.euer.raumkosten',
    label: 'Raumkosten',
    kind: TaxCategoryKind.expense,
    entityKinds: {TaxEntityKind.soleTrader},
    reportReference: 'Anlage EÜR – Raumkosten',
    description:
        'Miete, Nebenkosten und Grundsteuer betrieblich genutzter Räume.',
  ),
  TaxCategory(
    code: 'de.euer.arbeitszimmer',
    label: 'Häusliches Arbeitszimmer (Jahrespauschale)',
    kind: TaxCategoryKind.expense,
    entityKinds: {TaxEntityKind.soleTrader},
    reportReference: 'Anlage EÜR Z65 (Kz 162/172) – Häusliches Arbeitszimmer',
    description: '1 260 Euro im Jahr, wenn das Arbeitszimmer den Mittelpunkt der Tätigkeit bildet (§ 4 Abs. 5 Satz 1 Nr. 6b EStG). Nicht zusammen mit der Tagespauschale für dieselben Tage.',
  ),
  TaxCategory(
    code: 'de.euer.homeoffice',
    label: 'Homeoffice-Pauschale (Tagespauschale)',
    kind: TaxCategoryKind.expense,
    entityKinds: {TaxEntityKind.soleTrader},
    reportReference: 'Anlage EÜR Z66 (Kz 163) – Homeoffice-Pauschale',
    description: '6 Euro je Kalendertag, höchstens 1 260 Euro im Jahr (§ 4 Abs. 5 Satz 1 Nr. 6c EStG). Der Finanzbetrag wird je Tag erfasst.',
  ),
  TaxCategory(
    code: 'de.euer.fahrtkosten',
    label: 'Fahrtkosten',
    kind: TaxCategoryKind.expense,
    entityKinds: {TaxEntityKind.soleTrader},
    reportReference: 'Anlage EÜR – Fahrtkosten',
    description: 'Fahrten zwischen Wohnung und Betriebsstätte nach § 4 Abs. 5 Satz 1 Nr. 6 EStG, Dienstreisen und Fahrten zu Kunden.',
  ),
  TaxCategory(
    code: 'de.euer.bewirtung',
    label: 'Bewirtungskosten (70 % abzugsfähig)',
    kind: TaxCategoryKind.expense,
    entityKinds: {TaxEntityKind.soleTrader},
    reportReference: 'Anlage EÜR – Bewirtungskosten',
    description: 'Die Rechnung in voller Höhe erfassen; abgezogen werden 70 % (§ 4 Abs. 5 Satz 1 Nr. 2 EStG).',
  ),
  TaxCategory(
    code: 'de.euer.telekommunikation',
    label: 'Telekommunikation',
    kind: TaxCategoryKind.expense,
    entityKinds: {TaxEntityKind.soleTrader},
    reportReference: 'Anlage EÜR – Telekommunikationskosten',
    description: 'Telefon, Internet und Porto. Bei gemischter Nutzung den betrieblichen Anteil erfassen.',
  ),
  TaxCategory(
    code: 'de.euer.fortbildung',
    label: 'Fortbildung',
    kind: TaxCategoryKind.expense,
    entityKinds: {TaxEntityKind.soleTrader},
    reportReference: 'Anlage EÜR – Fortbildungskosten',
    description:
        'Fachliteratur, Kurse und Seminare zur betrieblichen Tätigkeit.',
  ),
  TaxCategory(
    code: 'de.euer.versicherungen',
    label: 'Versicherungen',
    kind: TaxCategoryKind.expense,
    entityKinds: {TaxEntityKind.soleTrader},
    reportReference: 'Anlage EÜR – Versicherungsbeiträge',
    description:
        'Betriebliche Versicherungen, etwa Berufs- und Betriebshaftpflicht.',
  ),
  TaxCategory(
    code: 'de.euer.sonstige',
    label: 'Sonstige Betriebsausgaben',
    kind: TaxCategoryKind.expense,
    entityKinds: {TaxEntityKind.soleTrader},
    reportReference: 'Anlage EÜR – Sonstige Betriebsausgaben',
  ),
  deVatOutput,
  deVatInput,
  TaxCategory(
    code: 'de.euer.gewerbesteuer',
    label: 'Gewerbesteuer-Vorauszahlungen',
    kind: TaxCategoryKind.taxPaid,
    entityKinds: {TaxEntityKind.soleTrader},
    reportReference: 'GewSt 1 – Vorauszahlungen',
    description: 'Gezahlte Gewerbesteuer. Sie ist keine Betriebsausgabe (§ 4 Abs. 5b EStG) und wird auf die Steuerschuld angerechnet.',
  ),
  TaxCategory(
    code: 'de.euer.entnahmen',
    label: 'Entnahmen und Einlagen',
    kind: TaxCategoryKind.outOfScope,
    entityKinds: {TaxEntityKind.soleTrader},
    reportReference: 'Anlage EÜR – Entnahmen und Einlagen',
    description: 'Private Geldbewegungen zwischen Betrieb und Inhaber. Sie ändern den Gewinn nicht.',
  ),
];

/// The categories of a GmbH or UG. The income statement lands on Anlage GK
/// (the KSt 1 Hauptvordruck carries no Besteuerungsgrundlagen) and the
/// taxable income on Anlage ZVE; the Kennzahlen of both forms were not
/// retrieved when the pack was researched.
const List<TaxCategory> deCompanyCategories = [
  TaxCategory(
    code: 'de.co.umsatzerloese',
    label: 'Umsatzerlöse',
    kind: TaxCategoryKind.income,
    entityKinds: {TaxEntityKind.company},
    reportReference: 'Anlage GK – Umsatzerlöse',
  ),
  TaxCategory(
    code: 'de.co.sonstige_ertraege',
    label: 'Sonstige betriebliche Erträge',
    kind: TaxCategoryKind.income,
    entityKinds: {TaxEntityKind.company},
    reportReference: 'Anlage GK – Sonstige betriebliche Erträge',
  ),
  TaxCategory(
    code: 'de.co.materialaufwand',
    label: 'Material- und Wareneinsatz',
    kind: TaxCategoryKind.expense,
    entityKinds: {TaxEntityKind.company},
    reportReference: 'Anlage GK – Materialaufwand',
  ),
  TaxCategory(
    code: 'de.co.personal',
    label: 'Personalaufwand',
    kind: TaxCategoryKind.expense,
    entityKinds: {TaxEntityKind.company},
    reportReference: 'Anlage GK – Personalaufwand',
    description: 'Auch das Gehalt eines Gesellschafter-Geschäftsführers mindert den Gewinn.',
  ),
  TaxCategory(
    code: 'de.co.afa',
    label: 'Abschreibungen (AfA)',
    kind: TaxCategoryKind.expense,
    entityKinds: {TaxEntityKind.company},
    reportReference: 'Anlage GK – Absetzungen für Abnutzung',
  ),
  TaxCategory(
    code: 'de.co.gwg',
    label: 'Geringwertige Wirtschaftsgüter (GWG)',
    kind: TaxCategoryKind.expense,
    entityKinds: {TaxEntityKind.company},
    reportReference: 'Anlage GK – Geringwertige Wirtschaftsgüter',
    description: 'Sofort abziehbar bis 800 Euro netto je Wirtschaftsgut (§ 6 Abs. 2 EStG).',
  ),
  TaxCategory(
    code: 'de.co.raumkosten',
    label: 'Raumkosten',
    kind: TaxCategoryKind.expense,
    entityKinds: {TaxEntityKind.company},
    reportReference: 'Anlage GK – Raumkosten',
  ),
  TaxCategory(
    code: 'de.co.fahrtkosten',
    label: 'Fahrtkosten',
    kind: TaxCategoryKind.expense,
    entityKinds: {TaxEntityKind.company},
    reportReference: 'Anlage GK – Fahrtkosten',
  ),
  TaxCategory(
    code: 'de.co.bewirtung',
    label: 'Bewirtungskosten (70 % abzugsfähig)',
    kind: TaxCategoryKind.expense,
    entityKinds: {TaxEntityKind.company},
    reportReference: 'Anlage GK – Bewirtungskosten',
    description: 'Die Rechnung in voller Höhe erfassen; abgezogen werden 70 % (§ 4 Abs. 5 Satz 1 Nr. 2 EStG).',
  ),
  TaxCategory(
    code: 'de.co.versicherungen',
    label: 'Versicherungen',
    kind: TaxCategoryKind.expense,
    entityKinds: {TaxEntityKind.company},
    reportReference: 'Anlage GK – Versicherungen',
  ),
  TaxCategory(
    code: 'de.co.sonstige',
    label: 'Sonstige betriebliche Aufwendungen',
    kind: TaxCategoryKind.expense,
    entityKinds: {TaxEntityKind.company},
    reportReference: 'Anlage GK – Sonstige betriebliche Aufwendungen',
  ),
  deVatOutput,
  deVatInput,
  TaxCategory(
    code: 'de.co.kst_vorauszahlungen',
    label: 'Körperschaftsteuer-Vorauszahlungen',
    kind: TaxCategoryKind.taxPaid,
    entityKinds: {TaxEntityKind.company},
    reportReference: 'KSt 1 – Vorauszahlungen (Formlinie nicht verifiziert)',
  ),
  TaxCategory(
    code: 'de.co.gewst_vorauszahlungen',
    label: 'Gewerbesteuer-Vorauszahlungen',
    kind: TaxCategoryKind.taxPaid,
    entityKinds: {TaxEntityKind.company},
    reportReference:
        'GewSt 1 A – Vorauszahlungen (Formlinie nicht verifiziert)',
  ),
];

/// Every category the pack knows, by code.
final Map<String, TaxCategory> deCategories = Map.unmodifiable({
  for (final category in [
    ...deIndividualCategories,
    ...deSoleTraderCategories,
    ...deCompanyCategories,
  ])
    category.code: category,
});
