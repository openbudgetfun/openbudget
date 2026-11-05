# Einkommensteuer 2025 and 2026: tariff, Soli, Kirchensteuer, children, deductions

Quality tags: **primary** read in an official source; **secondary** practitioner or search-summary only; **inferred** derived by the researcher or from general statute knowledge. Research date 5 Nov 2026.

## §32a EStG tariff

x = taxable income floored to whole euros. Result floored to whole euros. y = (x - Z1) / 10,000, z = (x - Z2) / 10,000, where Z1 is the Grundfreibetrag and Z2 the end of the first progressive zone.

### Tax year 2026 (primary)

| Zone | x (EUR)           | Tax                                                            |
| ---- | ----------------- | -------------------------------------------------------------- |
| 1    | up to 12,348      | 0                                                              |
| 2    | 12,349 to 17,799  | (914.51 · y + 1,400) · y, y = (x − 12,348) / 10,000            |
| 3    | 17,800 to 69,878  | (173.10 · z + 2,397) · z + 1,034.87, z = (x − 17,799) / 10,000 |
| 4    | 69,879 to 277,825 | 0.42 · x − 11,135.63                                           |
| 5    | from 277,826      | 0.45 · x − 19,470.38                                           |

Source: [§32a EStG](https://www.gesetze-im-internet.de/estg/__32a.html), cross-check [dejure.org](https://dejure.org/gesetze/EStG/32a.html). Haufe printed 68,878 as the zone 3 bound, a typo ([Haufe](https://www.haufe.de/id/norm/einkommensteuergesetz-32a-einkommensteuertarif-HI854593_p32a.html)).

### Tax year 2025 (secondary, consistent across BMF Lohnsteuer-Handbuch and Bundesrat Drs. 637/24 per search result; not opened in full)

| Zone | x (EUR)           | Tax                                                            |
| ---- | ----------------- | -------------------------------------------------------------- |
| 1    | up to 12,096      | 0                                                              |
| 2    | 12,097 to 17,443  | (932.30 · y + 1,400) · y, y = (x − 12,096) / 10,000            |
| 3    | 17,444 to 68,480  | (176.64 · z + 2,397) · z + 1,015.13, z = (x − 17,443) / 10,000 |
| 4    | 68,481 to 277,825 | 0.42 · x − 10,911.92                                           |
| 5    | from 277,826      | 0.45 · x − 19,246.67                                           |

The zone 5 constant 19,246.67 comes from one site only (taxrep.us); verify against the Bundesgesetzblatt text. Legal basis: law of 23 Dec 2024, BGBl. 2024 I Nr. 449 ([buzer.de](https://www.buzer.de/gesetz/4499/al210146-0.htm), [BMF LStH 2025 §32a](https://lsth.bundesfinanzministerium.de/lsth/2025/A-Einkommensteuergesetz/IV-Tarif-31-34b/Paragraf-32a/inhalt.html), [Bundesrat Drs. 637/24](https://www.bundesrat.de/SharedDocs/drucksachen/2024/0601-0700/637-24.pdf?__blob=publicationFile&v=1)). The researcher's recomputed test vectors at the zone edges are continuous (zone 4 at 69,879 in 2026 gives 18,213, same as 69,878), which supports the constants.

Grundfreibetrag: 2026 12,348 (24,696 joint), 2025 12,096 (24,192 joint) ([lohnsteuer-kompakt.de](https://www.lohnsteuer-kompakt.de/steuerwissen/grundfreibetrag-und-steuertarife-aenderungen-2024-bis-2026/), secondary).

### Implementation

Store coefficients as integer hundredths: 914.51 is 91451. Evaluate zone 2 as `((a·e + 1,400·10^6)·e) / 10^10` and zone 3 as `((b·e + 2,397·10^6)·e + c·10^8) / 10^10` with integer division (floor), where e = x − zone start, a/b/c are the hundredths constants. Use `BigInt` or 64-bit integers; the intermediate fits 64-bit for the numbers involved but keep `BigInt` for safety. Zones 4 and 5: `(42·x − d_hundredths) / 100` floored.

## Splitting (primary)

§32a Abs. 5: for spouses assessed jointly (§§26, 26b), tax = 2 × tax(Abs. 1) on half of the joint zvE. Abs. 6 extends it to certain widowed taxpayers and to the year a marriage ended. [§32a EStG](https://www.gesetze-im-internet.de/estg/__32a.html).

## Solidaritätszuschlag

- Rate 5.5% of the tax. Freigrenze (the Bemessungsgrundlage is the income tax under §3 Abs. 2 SolzG, which uses Kinderfreibeträge in all cases, so it is not the actually assessed tax): **2026 20,350 single, 40,700 joint (primary for the numbers; the fetched §3 text showed no year label)**; **2025 19,950 single, 39,900 joint (secondary)**. [§3 SolzG](https://www.gesetze-im-internet.de/solzg_1995/__3.html), [finanzklug.de](https://finanzklug.de/steuern/solidaritaetszuschlag/), [deutschland-rechner.de](https://www.deutschland-rechner.de/soli-rechner).
- Monthly wages: thresholds divided by 12; Lohnsteuerklasse III uses the higher figure.
- Milderungszone (primary for rate): Soli = min(5.5% × tax, 11.9% × (tax − Freigrenze)). The zone ends at tax = Freigrenze × 0.119 / (0.119 − 0.055): 37,838.28 (2026), 37,094.53 (2025) (inferred arithmetic).
- Corporation tax and Abgeltungsteuer carry Soli without a Freigrenze (§32d Abs. 3 and 4 tax is subject to Soli regardless) ([steuern.de](https://www.steuern.de/solidaritaetszuschlag), secondary).

## Kirchensteuer (secondary)

8% of income tax in Bayern and Baden-Württemberg, 9% elsewhere. Church tax paid is a Sonderausgabe in full except church tax on capital income settled by Abgeltungsteuer. Kappung (2.75% to 4% of taxable income) varies by state and church; sources disagree (for example BW "on request"). [Sparkasse](https://www.sparkasse.de/pk/ratgeber/finanzplanung/finanzen-und-haushalt/steuern-sparen/kirchensteuer.html), [lohnklar.de](https://lohnklar.de/blog/kirchensteuer-hebesatz-bundesland). Religionsschlüssel on ESt 1 A: EV, RK, VD.

## Children (secondary)

|                            | 2026                     | 2025                                      |
| -------------------------- | ------------------------ | ----------------------------------------- |
| Kinderfreibetrag per child | 6,828 (3,414 per parent) | not itemised in research (inferred 6,672) |
| BEA-Freibetrag per child   | 2,928 (1,464 per parent) | not itemised (inferred 2,928)             |
| Total                      | 9,756                    | 9,600                                     |
| Kindergeld per month       | 259 (3,108 per year)     | 255                                       |

The Finanzamt runs the Günstigerprüfung between Kindergeld and Freibeträge automatically. [familienservice.de](https://www.familienservice.de/-/mehr-geld-fuer-familien-kindergeld-kinderfreibetrag), [TABAK](https://steuerberater-tabak.com/steuer-glossar/kinderfreibetrag/), [rechner-portal.de](https://rechner-portal.de/finanzen/steuern/kinderfreibetrag-rechner). A draft Einkommensteuerreformgesetz 2027 was not law as of 27 Sep 2026.

## Pauschbeträge and caps

| Item                                                                     | Value (2025 and 2026)                                                          | Source quality                                                                                                                                                                                                                                                                                            |
| ------------------------------------------------------------------------ | ------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Arbeitnehmer-Pauschbetrag (§9a Satz 1 Nr. 1 a)                           | 1,230                                                                          | primary ([§9a](https://www.gesetze-im-internet.de/estg/__9a.html), Anleitung Anlage N 2025)                                                                                                                                                                                                               |
| Pauschbetrag Versorgungsbezüge and sonstige Einkünfte (§22 Nr. 1, 1a, 5) | 102                                                                            | primary (same)                                                                                                                                                                                                                                                                                            |
| Sonderausgaben-Pauschbetrag (§10c)                                       | 36 single, 72 joint, for §10 Abs. 1 Nr. 4, 5, 7, 9, Abs. 1a and §10b           | primary ([§10c](https://www.gesetze-im-internet.de/estg/__10c.html))                                                                                                                                                                                                                                      |
| Sparer-Pauschbetrag (§20 Abs. 9)                                         | 1,000 single, 2,000 joint                                                      | secondary (stated in the task, not fetched)                                                                                                                                                                                                                                                               |
| Basisrente Höchstbetrag (§10 Abs. 3)                                     | 2026: 30,826 (24.7% of knappschaftliche BBG 124,800, rounded up). 2025: 29,344 | 2026 secondary ([ISAR e.V.](https://www.isar-ev.com/meldung/steueraenderungen-2026.html), snippet; BBG Knappschaft 124,800 from [lohnsteuer-kompakt.de](https://www.lohnsteuer-kompakt.de/steuerwissen/beitragsbemessungsgrenzen-2026-diese-werte-gelten-ab-januar/)). 2025 inferred, not in the research |

Joint doubling of the Basisrente Höchstbetrag and the reduction for pension-insurance employer contributions: statute knowledge, not in the research.

Not verified in the research: §10 Abs. 4a (Günstigerprüfung Vorsorgeaufwendungen), §10 Abs. 3 details, Riester (2,100 cap), außergewöhnliche Belastungen (zumutbare Belastung), Basis-KV deduction rules, §52 EStG year applicability.

## Werbungskosten rules (Anleitung Anlage N 2025, primary content)

- No Anlage N is needed if the employer reported electronically and Werbungskosten stay below 1,230. Fünftelregelung is no longer applied at withholding from 2025 (only in the assessment).
- **Entfernungspauschale 2025**: 0.30 per full km for the first 20 km, 0.38 for each further km; cap 4,500 per year except own or provided car; once per working day; days not visited do not count (illness, vacation, Dienstreise, Heimarbeit, Kurzarbeit); shortest road connection (a longer one only if obviously more efficient and regularly used).
- **Entfernungspauschale from 1 Jan 2026**: §9 Abs. 1 Satz 3 Nr. 4 EStG reads 0.38 for every full km, cap 4,500. Introduced by the Steueränderungsgesetz 2025 (Bundestag 4 Dec 2025, Bundesrat 19 Dec 2025, BGBl. 2025 I Nr. 363 per a secondary source). The BMF Lohnsteuer-Handbuch 2026 confirms. It also applies to Familienheimfahrten in doppelter Haushaltsführung. [§9 EStG](https://www.gesetze-im-internet.de/estg/__9.html), [lohn-info.de](https://www.lohn-info.de/fahrkostenersatz_entfernungspauschale.html), [DIHK](https://www.dihk.de/de/newsroom/steueraenderungsgesetz-2025-lohnsteuerliche-aenderungen-zum-jahreswechsel-156344), [BMF LStH 2026 Anhang 14](https://ao.bundesfinanzministerium.de/lsth/2026/B-Anhaenge/Anhang-14/inhalt.html).
- **Homeoffice and Arbeitszimmer** (§4 Abs. 5 Satz 1 Nr. 6b and 6c, primary [§4 EStG](https://www.gesetze-im-internet.de/estg/__4.html)): Arbeitszimmer costs not deductible, but a Jahrespauschale of 1,260 per calendar year, reduced by 1/12 for each full month the conditions are not met. Tagespauschale 6 per day, cap 1,260 per year (210 days). The Z57 and Z58/59 lines must not overlap in time. The exact "Mittelpunkt der Tätigkeit" wording of Nr. 6b was not read in full.
- **Bewirtungskosten**: 70% deductible (§4 Abs. 5 Satz 1 Nr. 2); EÜR splits non-deductible Kz 165 and deductible Kz 175.
- **Vorsorgepauschale in wage-tax withholding, reworked from 2026** (BMF letter of 14 Aug 2025, secondary summary): components RV, GKV/soziale PV share, new Arbeitslosenversicherung component, actual Basis-KV/Pflege for the privately insured via ELStAM; the Mindestvorsorgepauschale is abolished from 2026. Affects payroll withholding only, not the return. [Haufe](https://www.haufe.de/steuern/finanzverwaltung/vorsorgepauschale-im-lohnsteuerabzugsverfahren-ab-2026_164_658714.html).

## Lohnsteuerklassen and Faktorverfahren (primary statute)

§38b EStG: I single or married/widowed/divorced where III/IV do not apply; II like I plus Entlastungsbetrag Alleinerziehende (§24b); III married with spouse in V (also widowed in the year after death); IV married, both unlimited taxpayers, not permanently separated; V married with spouse in III; VI second and further jobs. §39f: IV with Faktor (Y : X to three decimals) replaces III/V when the Faktor is below 1, valid to the end of the following calendar year. A Steuerklassen III/V abolition from 2030 is reported by one site and denied by others; no dated law found. [§38b](https://www.gesetze-im-internet.de/estg/__38b.html), [§39f](https://www.gesetze-im-internet.de/estg/__39f.html), [steuerschroeder.de](https://www.steuerschroeder.de/Faktorverfahren.html), [SpeedTax](https://speedtax.eu/de/blog/steuerklasse-3-und-5-werden-abgeschafft-was-bedeutet-das-fur-dich/), [myfinance.rocks](https://myfinance.rocks/blog/steuerklassen-reform-2026).

## Abgeltungsteuer, Anlage KAP, Teileinkünfte

- §32d Abs. 1 (primary): flat 25%. With church tax: (e − 4q) / (4 + k), q the creditable foreign tax, k the church tax rate as a fraction. [§32d](https://www.gesetze-im-internet.de/estg/__32d.html).
- Günstigerprüfung §32d Abs. 6: on application the tariff applies to all capital income if lower including surcharges; both spouses for joint assessment. Kz 201/401.
- Teileinkünfteverfahren §32d Abs. 2 Nr. 3 and §3 Nr. 40 d: holdings at least 25%, or at least 1% with significant professional influence; application no later than the return of the first year it applies; holds until revoked and four further years without re-proof; revocation no later than the return for the first year it should not apply, which bars a new application for that holding. 40% of dividends exempt, but only if the payment did not reduce the corporation's income (not for vGA that reduced income). Kz 272/472 (Z32b), revocation Z32c.
- Interaction (inferred): break-even marginal rate between about 41.7% (Soli on both sides, 25% / 0.6) and 44% (the research's comparison of 26.4% with 60% of the marginal rate). §3c Abs. 2 (only 60% of expenses deductible under TEV) not read.
- Kapitalertragsteuer rates in the Anlage KAP rows are in `elster-est-forms.md`. BMF letter of 16 May 2025 on Steuerbescheinigungen says some Anlage KAP Zeilen change after 2025 (for example Zeile 11 instead of 12); snippet only.
