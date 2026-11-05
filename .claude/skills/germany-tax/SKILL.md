---
name: germany-tax
description: German tax preparation for tax years 2025 and 2026 (individuals, Freiberufler, Gewerbetreibende, small GmbH/UG). Load before touching `openbudget_core/lib/src/tax/de/`, German tax categories, the §32a EStG tariff, Soli, Kirchensteuer, Anlage N/S/G/KAP/EÜR, UStVA, Umsatzsteuererklärung, Lohnsteuer-Anmeldung, Gewerbesteuer, Körperschaftsteuer, AfA/GWG/IAB, e-invoicing, GoBD or any ELSTER Kennzahl checklist.
---

# Germany tax preparation (2025 and 2026)

OpenBudget prepares German returns and shows the user an ELSTER checklist (form, Zeile, Kennzahl, value). The user enters or submits it themselves. This skill holds the rules, the exact figures per year, and the form maps. Output is guidance, not Steuerberatung.

## When to use

- Editing or extending the German rule pack, tax categories, profiles, reports or opportunities.
- Building the ELSTER checklist generator (`Kz` tables), deadline calendar, UStVA/USt/LStA preparation, EÜR or GmbH reports.
- Any German income tax, Soli, Kirchensteuer, Abgeltungsteuer, AfA, Gewerbesteuer, VAT, payroll or GoBD question.

## Scope: what OpenBudget does not do

Direct filing to ELSTER is out of scope. It would need the ERiC library (registered Hersteller-ID from the Bavarian tax office, a native library per OS, licence terms that bind the vendor and reportedly exclude open-source use), the taxpayer's Mein ELSTER certificate (.pfx) and PIN or the new "Registrierung über Mein ELSTER", and secure custody of both. No ERiC-free hand-over route to Mein ELSTER exists (weak evidence, no official statement found). So the product renders a checklist (and optionally a PDF) for manual entry. Model each return as data keyed by form, year and Kz (the shape ERiC consumes) so XML output could be added later without a remodel.

## Source-of-truth rules

- All rates, thresholds, coefficients and Pauschbeträge live in versioned per-year data in `openbudget_core` (`DeTaxTable`, keyed by calendar year). Never inline them in UI, server or the checklist code.
- Money is integer cents, or exact decimals. Never `double`. The research found a float error in Soli (21,000 Euro tax gave 77.34 instead of 77.35). The tariff uses integer hundredths of the coefficients and `BigInt` for the quadratic zones; keep that.
- Every figure stored carries a quality tag (primary, secondary, inferred) and a source URL, and the report prints the date the rules were last verified. See `references/` for the tags.
- Form data is keyed by `(form, tax year, section, Kennzahl)` plus a stable semantic field id. Zeile numbers are a per-year display locator only. Kennzahlen are stable between 2025 and 2026 on the forms checked, Zeilen are not (Anlage EÜR Zeilen shift by +1 from Z27 in 2026 because one new line was inserted; the Kz do not change). Kz are NOT globally unique inside a form: Anlage N 2025 reuses 110, 111 and 115; Anlage EÜR reuses 100, 120, 123, 131, 132 and 187 between its general block and its expense or Rücklage blocks; Anlage G reuses 24/25. A bare Kz map is therefore not enough, key by section as well. Details in `references/elster-euer.md` and `references/elster-est-forms.md`.
- 2026 Einkommensteuer forms (ESt 1 A, N, S, G, KAP, V, Vorsorgeaufwand, Sonderausgaben, AUS) were not published as of 5 Nov 2026 in anything the research could find. Mark 2026 ESt checklists "provisional, based on 2025 form" until the BMF 2026 forms are read. EÜR 2026, UStVA 2026, USt 2026 and Lohnsteuer-Anmeldung 2026 are published and read.
- Rounding: zu versteuerndes Einkommen floored to whole euros, tariff result floored to whole euros, Soli floored to the cent. Rounding of Kirchensteuer and of withholding on capital income is not sourced; use a one-cent tolerance in tests.

## Core rules

**§32a EStG tariff** (x = zvE in whole euros, floored; y and z are (x - zone start) / 10,000; result floored). Constants are in `references/income-tax.md`; the shape never changes: zone 1 is zero, zone 2 `(a*y + 1400)*y`, zone 3 `(b*z + 2397)*z + c`, zone 4 `0.42*x - d`, zone 5 `0.45*x - e`. Coefficients differ per year. 2026 zone ends: Grundfreibetrag 12,348, 17,799, 69,878, 277,825. 2025: 12,096, 17,443, 68,480, 277,825.

**Splitting** (§32a Abs. 5, joint assessment): tax = 2 × tax(floor(joint zvE / 2)). The Grundfreibetrag doubles through the halving. Also applies to certain widowed taxpayers (Abs. 6).

**Soli**: 5.5% of income tax, but zero at or below the Freigrenze, and inside the Milderungszone `min(5.5% × tax, 11.9% × (tax - Freigrenze))`. Freigrenze compares with the income tax (after Kinderfreibeträge, not the taxable income): 2026 20,350 single / 40,700 joint, 2025 19,950 / 39,900. Zone ends at tax = Freigrenze × 0.119 / 0.064 (37,838.28 in 2026, 37,094.53 in 2025). KSt and Abgeltungsteuer carry Soli with no Freigrenze.

**Kirchensteuer**: 8% (Bayern, Baden-Württemberg) or 9% (other states) of income tax. State and church law, so the rate is a profile input, not a constant. Caps (Kappung) vary by church and state and are not researched. Church tax paid is a Sonderausgabe (Anlage Sonderausgaben Kz 103), except church tax settled with Abgeltungsteuer.

**Abgeltungsteuer** (§32d Abs. 1): 25% flat on capital income above the Sparer-Pauschbetrag (1,000 single / 2,000 joint). With church tax rate k the withheld tax is `income / (4 + k)`, then Soli 5.5% on that. Günstigerprüfung (§32d Abs. 6, Anlage KAP Kz 201/401) taxes all capital income at the tariff when cheaper. Teileinkünfteverfahren (§32d Abs. 2 Nr. 3, Kz 272/472): holdings of at least 25%, or at least 1% with professional involvement; 40% of the dividend is exempt (§3 Nr. 40 d); application lasts five years unless revoked.

**Werbungskosten and Pauschbeträge** (both years): Arbeitnehmer-Pauschbetrag 1,230 (applied automatically, no Anlage N needed below it); Versorgungsbezüge and sonstige Einkünfte 102; Sonderausgaben-Pauschbetrag 36 / 72 joint. Each spouse with wages gets their own 1,230.

**Entfernungspauschale**: 2025: 0.30 per full km for km 1 to 20, 0.38 from km 21. From 1 Jan 2026: 0.38 for every full km (Steueränderungsgesetz 2025). Cap 4,500 per year except own or provided car. One trip per working day, shortest road connection. Key the rate schedule by year.

**Homeoffice and Arbeitszimmer**: Tagespauschale 6 per day, cap 1,260 (210 days), Anlage N Z58/Z59 Kz 335/336 (the Finanzamt computes the amount from days), EÜR Kz 163. Arbeitszimmer Jahrespauschale 1,260, reduced by 1/12 per month without the conditions, Anlage N Kz 325, EÜR Kz 162/172. Never claim Arbeitszimmer and Tagespauschale for the same period.

**Children**: 2026 Kinderfreibetrag 6,828 per child (3,414 per parent) plus BEA 2,928 (1,464 per parent), total 9,756; 2025 total 9,600. Kindergeld 259 per month in 2026 (255 in 2025). The Finanzamt picks the better of Kindergeld and Freibeträge automatically. The Soli and Kirchensteuer base uses the Kinderfreibeträge in all cases.

**Sonderausgaben incl. Basisrente**: Basisrente is deductible up to the Höchstbetrag (24.7% of the knappschaftliche Beitragsbemessungsgrenze): 2026 30,826, 2025 29,344. The statute doubles it for joint assessment and reduces it for employer contributions to statutory pension (inferred, not in the research). Deductions go in Anlage Vorsorgeaufwand Kz 303/403.

**EÜR vs Bilanz**: §141 AO duty applies only after Finanzamt notice, at 800,000 turnover or 80,000 profit (from 2024), Gewerbetreibende and Land- und Forstwirte only; Freiberufler never. §241a HGB relief covers Einzelkaufleute only, so a GmbH/UG always keeps double-entry books and has no EÜR route (it still files EÜR data down to Z75/Z76 with Anlage GK, see references).

**AfA/GWG/IAB**: GWG immediate deduction up to 800 net (EÜR Kz 132); alternative Sammelposten 250.01 to 1,000 net over five years (Kz 137 for the dissolution), chosen per year, never mixed (inferred). Degressive AfA for movable assets acquired 1 Jul 2025 to 31 Dec 2027: three times the straight-line rate, capped at 30% of book value (a 13-year life gives 23.08%); not for buildings or intangibles. 75% first-year AfA for new electric vehicles bought 30 Jun 2025 to 31 Dec 2027. IAB (§7g) 50% of planned cost, Sonderabschreibung 40%, combinable with degressive AfA (EÜR Kz 187 for new IAB, 180/181/182 for add-backs).

**Gewerbesteuer and §35**: Freibetrag 24,500 for sole traders and partnerships, none for GmbH/UG. Messzahl 3.5%. Gewerbeertrag floored to 100 euro before the Freibetrag. GewSt = Messbetrag × Hebesatz (municipal, minimum 200%). §35 credit = 4.0 × Messbetrag, capped by GewSt actually paid and by the income tax attributable to the business income. GmbH/UG get no §35. Freiberufler owe no GewSt. Prepayments 15 Feb, 15 May, 15 Aug, 15 Nov (min 50).

**Umsatzsteuer**: rates 19% and 7% (statute, not re-fetched). Kleinunternehmer from 1 Jan 2025: prior-year turnover at most 25,000 and current-year at most 100,000 (hard limit; the turnover that crosses 100,000 is already taxed). Opt-out binds five years. UStVA period: prior-year tax above 9,000 monthly; above 2,000 to 9,000 quarterly; 2,000 or less, the Finanzamt may exempt (annual return only). Dauerfristverlängerung gives one extra month, with a Sondervorauszahlung of 1/11 for monthly filers. Ist-Versteuerung needs approval (prior-year Gesamtumsatz at most 800,000, or §148 AO bookkeeping exemption, or Freiberufler). §13b reverse charge makes the recipient the tax debtor; reported in UStVA Kz 46/47, 73/74, 84/85 with the matching Vorsteuer in Kz 67. §19a lets a German Kleinunternehmer use the exemption in other EU states through BZSt (EU-wide limit 100,000).

**E-invoicing**: receiving structured e-invoices (XRechnung, ZUGFeRD/Factur-X, EN 16931) is mandatory since 1 Jan 2025. Issuing: paper and plain PDF stay valid until 31 Dec 2026; from 1 Jan 2027 businesses with 2026 turnover above 800,000 must issue structured invoices; from 1 Jan 2028 everyone except Kleinunternehmer. Keep the structured XML as the original.

**GmbH/UG**: KSt 15% plus 5.5% Soli (no Freigrenze) in 2025 to 2027, then 14% (2028), 13% (2029), 12% (2030), 11% (2031), 10% from 2032 (enacted, BGBl. 2025 I Nr. 161). Make the KSt rate a function of the year. A vGA does not reduce income (§8 Abs. 3 KStG) and is dividend for the shareholder. Dividends to private shareholders: 25% Abgeltungsteuer, or Teileinkünfteverfahren on application. Combined burden at Hebesatz 400% on retained profit: 15.825% + 14.0% = 29.825%. Publication, E-Bilanz taxonomy, vGA criteria and Geschäftsführergehalt benchmarks are not researched: signpost only.

**Payroll basics 2026**: Beitragsbemessungsgrenzen RV/AV 101,400 per year (8,450 per month), KV/PV 69,750 (5,812.50). Rates: KV 14.6% plus Zusatzbeitrag (shared), PV 3.6% (childless surcharge brings it to 4.2%), RV 18.6%, AV 2.6%. Minijob limit 603 per month (2025: 556), minimum wage 13.90 (2025: 12.82), Midijob 603.01 to 2,000. Lohnsteuer-Anmeldung period by prior-year Lohnsteuer: above 5,000 monthly, above 1,080 up to 5,000 quarterly, 1,080 or less annual (the 2,000/8,000 figures in the first research note are wrong; the BMF form overrides). Due the 10th after the period. Kz: 42 Lohnsteuer, 49 Soli, 61 ev., 62 rk., 47 pauschale KiSt, 83 total. Do not compute Lohnsteuer yourself; the BMF Programmablaufplan was not researched.

**Deadlines** (see `references/deadlines-gobd.md`): self-filers 31 Jul of the following year; advised returns end of February of the second following year; §108 Abs. 3 AO moves a deadline that falls on a Saturday, Sunday or public holiday to the next working day. Examples: VZ 2025 advised: 28 Feb 2027 is a Sunday, so Mon 1 Mar 2027; VZ 2026 self-filers: 31 Jul 2027 is a Saturday, so Mon 2 Aug 2027. Verspätungszuschlag (§152 AO): 0.25% of assessed tax per started month, at least 25 per month, cap 25,000; mandatory after 14 months for annual returns. The deadline function must be `(tax year, advised)` plus the weekend and holiday roll.

**GoBD**: append-only journal, corrections by reversal (Storno), timestamps and user attribution, originals kept with hash, Verfahrensdokumentation. Retention since 1 Jan 2025: Buchungsbelege 8 years, books/Jahresabschlüsse/Verfahrensdokumentation 10, §22 UStG records 10, business letters 6. The clock starts at the end of the calendar year of the document (inferred).

## Guardrails

- Present outputs as general rules applied to the user's own figures, with a disclaimer; avoid "Handlungsempfehlung für Ihren Einzelfall". §5 StBerG prohibits unauthorised commercial Hilfeleistung in Steuersachen; no ruling on AI tax apps was found. Treat this as an open legal question for counsel.
- Offer only statutory reliefs. §42 AO (Gestaltungsmissbrauch) was not read. GmbH versus sole-trader or salary versus dividend comparisons must be calculators with stated assumptions and a "ask a Steuerberater" signpost; no holding structures.
- Flag vGA risk when a shareholder-manager is paid above an arm's-length level.

## Where it lives in OpenBudget

- Rule pack: `openbudget_core/lib/src/tax/de/` (`de_tables.dart` per-year data, `de_tariff.dart` §32a, `de_assessment.dart` Soli/KapESt/GewSt/§35, `de_reports.dart`, `de_opportunities.dart`, `de_categories.dart`). Tests in `openbudget_core/test/tax/de/`. Contract: `tax_rule_pack.dart`, `tax_model.dart`, `tax_profile.dart` (`DeTaxProfile`).
- New data to add to `DeTaxTable`, not elsewhere: Kinderfreibetrag/Kindergeld, per-year KSt rate schedule, Entfernungspauschale schedule, Kirchensteuer state rate as profile input, deadline roll.
- New code to add: an ELSTER checklist model (form, year, section, Kz, Zeile locator, person A/B, value in cents, quality tag) in `openbudget_core`, per-form Kz tables as versioned data, and a deadline calendar in `openbudget_core`. Server exposure goes through the existing tax reports endpoint in `openbudget_server/lib/src/tax/`.
- UI follows `CLAUDE.md`: hook widgets only, strings from `AppLocalizations`, Riverpod via `@riverpod`.

## Testing

Encode every vector in `references/test-vectors.md` as exact integer cents. Tariff, splitting, Soli, Gewerbesteuer and §35 results must match to the cent; Kapitalertragsteuer with church tax and Kirchensteuer to one cent. Add boundary cases on each zone edge (x and x+1), the Soli Freigrenze (tax 20,350 and 20,351), the Kleinunternehmer limits (24,999 / 25,001, 100,000 / 100,001), and weekend deadlines. Test the checklist generator by asserting that the sum of the EÜR income Kz equals Kz 159 and expenses equal Kz 199, and that Kz 219 equals the difference.

## Unverified and changing

Re-check all of these on or before the date shown. Full list with sources in the references.

- 2026 ESt forms (Anlage N, S, G, KAP, V, Vorsorgeaufwand, Sonderausgaben, AUS): not published as of 5 Nov 2026. Re-check on publication, before building any 2026 return checklist.
- 2025 Soli Freigrenze 19,950 and 2025 zone 5 constant 19,246.67: secondary only. Check against BGBl. 2024 I Nr. 449 and the BMF Tarifhistorie before 31 Dec 2026.
- Basisrente 2025 (29,344) and doubling for joint assessment: not in the research.
- Kirchensteuer Kappung, state-specific rates beyond 8%/9%, rounding of church tax.
- Entfernungspauschale 2026 BGBl. reference (BGBl. 2025 I Nr. 363) from a secondary source.
- Announced, not enacted as of 5 Nov 2026: Einkommensteuerreformgesetz 2027 (draft), Gewerbesteuer minimum Hebesatz 280% from 2027 (one secondary source), 2027 Beitragsbemessungsgrenzen (cabinet draft of 7 Oct 2026: RV/AV 106,200, KV/PV 76,500), Minijob limit 633 and minimum wage 14.60 for 2027 (one secondary source), Steuerklassen III/V abolition (sources conflict, no dated law). Re-check by 31 Dec 2026 and again when the 2027 Bundesgesetzblatt entries appear.
- Not researched: Übungsleiter and Ehrenamt allowances, restaurant VAT rate changes for 2026, §233a AO interest, Pflichtveranlagung rules, §34c foreign tax credit detail, Umlagen U1/U2/U3, E-Bilanz taxonomy, KSt 1/Anlage GK/ZVE/GewSt 1 A Kennzahlen, Lohnsteuer PAP, vGA criteria.
- Anlage V lines below Z54 and Anlage KAP Zeilen after 2025 (reportedly shift) need a read of the official form.

## References

- `references/income-tax.md`: tariff coefficients per year with sources, Soli, Kirchensteuer, children, Pauschbeträge, deductions, Abgeltungsteuer, Teileinkünfte.
- `references/business-tax.md`: EÜR vs Bilanz, AfA/GWG/IAB, Gewerbesteuer, §35, GmbH/UG, vGA, dividends.
- `references/vat-payroll-deadlines.md`: Umsatzsteuer rules, e-invoicing, payroll, deadlines, Verspätungszuschlag, GoBD, ERiC/ELSTER.
- `references/elster-est-forms.md`: Kz tables for ESt 1 A, Anlage N, S, G, KAP, V, Vorsorgeaufwand, Sonderausgaben, AUS (2025).
- `references/elster-euer.md`: Anlage EÜR Kz table with 2025 and 2026 Zeilen, Anlage AVEÜR, how to build the checklist.
- `references/elster-ust-lst.md`: UStVA 2026, annual Umsatzsteuererklärung 2025/2026, Lohnsteuer-Anmeldung 2026, KSt/GewSt form gaps.
- `references/test-vectors.md`: worked examples with expected outputs.
