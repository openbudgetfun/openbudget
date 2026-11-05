# ELSTER Einkommensteuer forms, tax year 2025: Zeile and Kennzahl

Quality: the figures come from the official BMF forms and Anleitungen, but the text was extracted from copies hosted by third parties (steuern.de for ESt 1 A, N, KAP, V, Vorsorgeaufwand, Sonderausgaben, AUS; steuerrat24.de for S and G; form codes in the footers such as `2025AnlN031NET - Oktober 2025`). Tag: **primary (third-party copy)**. The FMS download at formulare-bfinv.de needs a browser session and was not fetched. Research date 5 Nov 2026.

**2026 forms: not published as of 5 Nov 2026 in anything the research found. 2026 ESt checklists are provisional and must reuse these Kz with a visible warning.** The Steueränderungsgesetz 2025 changed the Entfernungspauschale from 2026, so the 2026 Anlage N will drop the 0.30 tier and the Z29 to Z34 block may keep its Kz but change the km split (unverified).

## Conventions

- Z = Zeile printed on the form. Kz = Kennzahl, the small field number beside the entry box.
- A pair `140/141` on Anlage N means the columns "Steuerklasse 1-5" and "Steuerklasse 6 or Urlaubskasse". On Anlagen S, G, KAP, AUS and Vorsorgeaufwand, the first Kz is person A (taxpayer/Ehemann), the second person B (Ehefrau). Explicit on Vorsorgeaufwand and AUS; inferred from the layout for S, G and KAP. Each spouse with income files their own Anlage N, S, G and KAP, so the data model needs a person dimension.
- Kz are not unique within a form. Anlage N 2025 uses Kz 110 and 111 on Z5 (Bruttoarbeitslohn) and on Z29/Z30 (days, km), and Kz 115 on Z18 and Z28. Key by (form, year, section or Zeile role, Kz) with a stable semantic id, not by Kz alone.
- Most Anlage N Z5 to Z9 values are pre-filled by the electronically transmitted Lohnsteuerbescheinigung; the form marks them with an electronic symbol.
- Show the Zeile only as a per-year locator. If a Kz row is missing or flagged "not extracted", render "text field, see form".

## Hauptvordruck ESt 1 A 2025

[Form copy](https://www.steuern.de/fileadmin/user_upload/Steuerformulare_2025/Hauptvordruck_ESt_1_A_2025_steuern-de.pdf), [Anleitung via FMS](https://www.formulare-bfinv.de/ffw/action/invoke.do?id=034037_25).

| Z     | Kz              | Meaning                                                                                                                                                  |
| ----- | --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 7-17  | none extracted  | Taxpayer A personal data (IdNr, birth date, name, Religionsschlüssel EV/RK/VD, address, Familienstand dates)                                             |
| 18-19 | not extracted   | Veranlagungsart (Zusammenveranlagung or Einzelveranlagung), Gütergemeinschaft                                                                            |
| 20-28 | none extracted  | Person B personal data, optional deviating address                                                                                                       |
| 30-33 | not extracted   | IBAN (domestic Z30, foreign Z31), BIC, Kontoinhaber                                                                                                      |
| 34    | 17 (A) / 18 (B) | Antrag Arbeitnehmer-Sparzulage for electronically reported Vermögensbildungsbescheinigungen (1 = Ja)                                                     |
| 35    | 120 / 121       | Einkommensersatzleistungen under Progressionsvorbehalt (Arbeitslosengeld, Elterngeld, Krankengeld, Mutterschaftsgeld), excluding amounts in Anlage N Z20 |
| 36    | 136 / 137       | Comparable EU/EWR/Swiss benefits                                                                                                                         |
| 37    | 500             | Ergänzende Angaben flag 1/2/3/4                                                                                                                          |
| 39-40 | none extracted  | Tax advisor flag and name                                                                                                                                |

## Anlage N 2025 (Vordruck 055, Oktober 2025)

[Form copy](https://www.steuern.de/fileadmin/user_upload/Steuerformulare_2025/Anlage_N_2025_steuern-de.pdf), [Anleitung via FMS](https://www.formulare-bfinv.de/ffw/action/invoke.do?id=034027_25).

| Z            | Kz                                                                                       | Meaning                                                                                                                                                                                                                                                                   |
| ------------ | ---------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 4            | 168                                                                                      | Steuerklasse                                                                                                                                                                                                                                                              |
| 5            | 110 (class 1-5) / 111 (class 6 or Urlaubskasse)                                          | Bruttoarbeitslohn incl. Sachbezüge (Lohnsteuerbescheinigung Nr. 3), sum over certificates                                                                                                                                                                                 |
| 6            | 140 / 141                                                                                | Lohnsteuer                                                                                                                                                                                                                                                                |
| 7            | 150 / 151                                                                                | Solidaritätszuschlag                                                                                                                                                                                                                                                      |
| 8            | 142 / 143                                                                                | Kirchensteuer of the employee                                                                                                                                                                                                                                             |
| 9            | 144 / 145                                                                                | Kirchensteuer for spouse (only for differing religious affiliation)                                                                                                                                                                                                       |
| 10           | 197                                                                                      | Flag: Z5 deviates because of Firmenwagen correction (1 = Ja)                                                                                                                                                                                                              |
| 11-16        | 200/210, 201/211, 206/216, 202-203/212-213, 204/214, 209/219                             | Versorgungsbezüge block (not relevant for ordinary employees)                                                                                                                                                                                                             |
| 17           | 165                                                                                      | Arbeitslohn for several years / Entschädigungen (Fünftelregelung only applied in the assessment from 2025)                                                                                                                                                                |
| 18           | 115                                                                                      | Taxable wages without Steuerabzug                                                                                                                                                                                                                                         |
| 19           | 118                                                                                      | Steuerfreie Aufwandsentschädigungen (for example Übungsleiter)                                                                                                                                                                                                            |
| 20           | 119                                                                                      | Kurzarbeitergeld, Mutterschaftsgeld-Zuschuss, Aufstockungsbeträge (Bescheinigung Nr. 15), Progressionsvorbehalt                                                                                                                                                           |
| 21 / 22 / 23 | 139 / 136 / 178                                                                          | Steuerfreier Arbeitslohn under DBA / Auslandstätigkeitserlass / besondere Lohnbestandteile (sums from Anlage N-AUS)                                                                                                                                                       |
| 25           | 127                                                                                      | Belgian residence wages                                                                                                                                                                                                                                                   |
| 26           | 117 (wages), 116 (CHF/EUR), 135 (Swiss Abzugsteuer)                                      | Grenzgänger                                                                                                                                                                                                                                                               |
| 27-30        | 115 (Z28 disability flag), 110 (Z29 days visited), 111 (Z30 one-way distance in full km) | Entfernungspauschale, 1st workplace                                                                                                                                                                                                                                       |
| 31-34        | 112 / 113 / 114                                                                          | Z31 km by own or provided car; Z32 km by employer collective transport; Z34 public transport costs (the km in Z33 has no Kz)                                                                                                                                              |
| 35-42        | 135 / 130 / 131 / 132 / 133 / 134                                                        | Same block, 2nd workplace                                                                                                                                                                                                                                                 |
| 43-50        | 155 / 150 / 151 / 152 / 153 / 154                                                        | Same block, 3rd workplace                                                                                                                                                                                                                                                 |
| 51 / 52      | 290, 295 / 291                                                                           | Arbeitgeberleistungen Nr. 17 and 18; Agentur-für-Arbeit/Jobcenter Fahrtkostenzuschüsse                                                                                                                                                                                    |
| 53           | 310                                                                                      | Beiträge zu Berufsverbänden                                                                                                                                                                                                                                               |
| 54-56        | 320 (Summe Z56)                                                                          | Arbeitsmittel (itemised Z54-55)                                                                                                                                                                                                                                           |
| 57           | 325                                                                                      | Häusliches Arbeitszimmer (Mittelpunkt der Tätigkeit): actual costs or Jahrespauschale 1,260 (time-proportional)                                                                                                                                                           |
| 58           | 335                                                                                      | Tagespauschale (Homeoffice): days with work at home, first workplace not visited, another workplace available                                                                                                                                                             |
| 59           | 336                                                                                      | Tagespauschale: days when no other workplace is permanently available (a day may not be in both Z58 and Z59; Z57 and Z58/Z59 must not overlap in time)                                                                                                                    |
| 60           | 330                                                                                      | Fortbildungskosten                                                                                                                                                                                                                                                        |
| 61-64        | 380 (Summe Z64)                                                                          | Fähr- und Flugkosten (Z61), Sonstiges (Bewerbungskosten, Kontoführungsgebühren, Z62-63)                                                                                                                                                                                   |
| 65-69        | 401 (Z65 flag), 410 (Summe Z69)                                                          | Reisekosten Auswärtstätigkeit: Fahrtkosten Z66, Übernachtung Z67, Nebenkosten Z68                                                                                                                                                                                         |
| 70-77        | 411, 420, 470, 471, 472, 473, 474, 490                                                   | Berufskraftfahrer-Pauschbeträge (Z70 Kz 411), steuerfrei ersetzt (Z71 Kz 420), Verpflegungsmehraufwand: more than 8 h days Z72 Kz 470, An-/Abreisetage Z73 Kz 471, 24 h days Z74 Kz 472, Kürzung Mahlzeiten Z75 Kz 473, Ausland Z76 Kz 474, steuerfrei ersetzt Z77 Kz 490 |
| 78-83        | 682, 659, 660, 657, 656, 675                                                             | Werbungskosten in Sonderfällen (Versorgungsbezüge Z78, Versorgungsbezüge mehrere Jahre Z79, Arbeitslohn mehrere Jahre Z80, steuerfreier Auslandslohn Z81, Lohn ohne Steuerabzug Z82, Belgien Z83)                                                                         |

The Anleitung states: the Arbeitnehmer-Pauschbetrag of 1,230 is applied automatically; no Anlage N is needed if the employer reported electronically and Werbungskosten stay below 1,230; Fünftelregelung is no longer applied at withholding from 2025.

Minimal employee checklist (inferred): Z4 to Z8 (Kz 168, 110, 140, 150, 142), plus Z27 to Z34 (commute) and Z53 to Z60 when Werbungskosten exceed 1,230.

Practitioner pages disagree on Anlage N Homeoffice Zeilen (Z45, Z58/59, Z61/62). The official form shows Z58/Z59 with Kz 335/336; ignore the others.

## Anlage S 2025 (Einkünfte aus selbständiger Arbeit, September 2025)

[Copy](https://www.steuerrat24.de/images/bestand-pdf/Anlage-S-2025.pdf). A separate Anlage EÜR (or Bilanz) is required per business. Older layouts put the Gewinn on "Zeile 4"; the 2025 form uses Z6.

| Z     | Kz (A / B)              | Meaning                                                                                 |
| ----- | ----------------------- | --------------------------------------------------------------------------------------- |
| 4-6   | 100 / 300 (entry in Z6) | Gewinn aus freiberuflicher Tätigkeit (Berufsbezeichnung Z4, Steuernummer Z5, W-IdNr Z6) |
| 7-9   | 101 / 301               | Gewinn aus einer weiteren freiberuflichen Tätigkeit                                     |
| 10-12 | 110 / 310               | Gewinn laut gesonderter Feststellung                                                    |
| 13-15 | 120 / 320               | Gewinn from 1st Beteiligung                                                             |
| 16    | 130 / 330               | Gewinn from all further Beteiligungen                                                   |
| 18-20 | 140 / 340               | Gewinn aus sonstiger selbständiger Arbeit (for example Aufsichtsrat)                    |
| 21    | 150 / 350               | Gewinn aus allen weiteren Tätigkeiten                                                   |
| 22    | 160 / 360               | Steuerfreier Teil under Teileinkünfteverfahren not included above                       |
| 35    | 200 / 400               | Veräußerungsgewinn before Freibetrag §16 Abs. 4                                         |

## Anlage G 2025 (Einkünfte aus Gewerbebetrieb, September 2025)

[Copy](https://www.steuerrat24.de/images/bestand-pdf/Anlage-G-2025.pdf). Takes the Gewinn from EÜR Kz 219. Older layouts put §35 in "Zeilen 16-22"; the 2025 form uses Z51 to Z57.

| Z       | Kz                    | Meaning                                                                                                  |
| ------- | --------------------- | -------------------------------------------------------------------------------------------------------- |
| 4-6     | 10 / 11 (entry in Z6) | Gewinn als Einzelunternehmer, 1st Betrieb (Gewerbebezeichnung Z4, Steuernummer Z5, W-IdNr Z6)            |
| 7-9     | 62 / 63               | Gewinn, 2nd Betrieb                                                                                      |
| 10      | 12 / 13               | Weitere Betriebe                                                                                         |
| 11-13   | 58 / 59               | Gewinn laut gesonderter Feststellung                                                                     |
| 14-16   | 14 / 15               | Gewinn as Mitunternehmer, 1st Beteiligung (further: 16/17, 18/19, 20/21, 22/23, 28/29, 30/31, ... 38/39) |
| 47      | 24 / 25               | Steuerfreier Teil under Teileinkünfteverfahren not in Z6-45                                              |
| 51      | 64 / 65               | §35 EStG: festzusetzender (anteiliger) Gewerbesteuer-Messbetrag of the Betrieb                           |
| 52      | 66 / 67               | Gewerbesteuer actually payable on the Messbetrag in Z51                                                  |
| 53 / 54 | 68 / 69, 70 / 71      | Same pair for a 2nd Betrieb                                                                              |
| 55 / 56 | 85 / 86, 81 / 82      | Sum of all further Messbeträge, and the Gewerbesteuer payable on them                                    |
| 57      | 74 / 75               | Höchstbeträge nach §35 Abs. 1 Satz 5 from indirect Beteiligungen                                         |
| 61      | 24 / 25               | Veräußerungsgewinn before Freibetrag (§16) (same Kz as Z47: collision)                                   |

## Anlage KAP 2025 (Oktober 2025)

[Copy](https://www.steuern.de/fileadmin/user_upload/Steuerformulare_2025/Anlage_KAP_2025_steuern-de.pdf), [Anleitung](https://www.formulare-bfinv.de/ffw/action/invoke.do?id=034024_25). BMF letter of 16 May 2025 says some Zeilen change after 2025 (snippet only, not opened).

| Z              | Kz (A / B)                                         | Meaning                                                                                                                       |
| -------------- | -------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| 4              | 201 / 401                                          | Antrag Günstigerprüfung for all Kapitalerträge (1 = Ja)                                                                       |
| 5              | 202 / 402                                          | Antrag Überprüfung des Steuereinbehalts                                                                                       |
| 6              | 203 / 403                                          | Erklärung: kirchensteuerpflichtig, KapESt withheld without Kirchensteuer                                                      |
| 7              | 210 / 410 (per certificate), 220 / 420 (corrected) | Kapitalerträge subject to German Steuerabzug                                                                                  |
| 8              | 212 / 412, 222 / 422                               | Of which Gewinne aus Aktienveräußerungen                                                                                      |
| 9              | 611 / 811, 621 / 821                               | Stillhalterprämien and Termingeschäft gains                                                                                   |
| 11             | 214 / 414, 224 / 424                               | Ersatzbemessungsgrundlage                                                                                                     |
| 12 / 13        | 215 / 415, 216 / 416                               | Nicht ausgeglichene Verluste (ohne Aktien / aus Aktien)                                                                       |
| 14 / 15        | 615 / 815, 616 / 816                               | Termingeschäft losses; Ausfall losses                                                                                         |
| 16             | 217 / 417                                          | Used Sparer-Pauschbetrag on Z7-15, 30, 33 income (enter 0 if none)                                                            |
| 17             | 218 / 418                                          | Used Sparer-Pauschbetrag on income not reported in the Anlage                                                                 |
| 18             | 230 / 430                                          | Inländische Kapitalerträge without Steuerabzug                                                                                |
| 19             | 234 / 434                                          | Ausländische Kapitalerträge without Steuerabzug                                                                               |
| 20             | 232 / 432                                          | Included Aktienveräußerungsgewinne                                                                                            |
| 22 / 23        | 235 / 435, 236 / 436                               | Included losses (non-share, share)                                                                                            |
| 26             | 260 / 460                                          | Zinsen vom Finanzamt for Steuererstattungen                                                                                   |
| 26a            | 237 / 437                                          | Prozess- und Verzugszinsen                                                                                                    |
| 28             | 270 / 470                                          | Laufende Einkünfte from sonstige Kapitalforderungen, stille Gesellschaft, partiarische Darlehen                               |
| 30             | 268 / 468                                          | Kapitalerträge aus Lebensversicherungen                                                                                       |
| 31 / 32b / 32c | 1 = Ja / 272 / 472                                 | Z31 application for tariff taxation of income in Z32b (unternehmerische Beteiligung, Teileinkünfteverfahren); Z32c revocation |
| 33             | 277 / 477                                          | Bezüge nach §32d Abs. 2 Nr. 4 (Korrespondenzprinzip)                                                                          |
| 37             | 280 / 480                                          | Kapitalertragsteuer withheld (Z7-23 income)                                                                                   |
| 38             | 281 / 481                                          | Solidaritätszuschlag                                                                                                          |
| 39             | 282 / 482                                          | Kirchensteuer zur KapESt                                                                                                      |
| 40 / 41 / 42   | 283 / 483, 284 / 484, 285 / 485                    | Angerechnete ausländische Steuern; anrechenbare noch nicht angerechnete; fiktive Quellensteuer                                |
| 43 / 44 / 45   | 286 / 486, 287 / 487, 288 / 488                    | KapESt, Soli, KiSt to be credited for income in Z28-34 and other types                                                        |
| 46             | 206 / 406                                          | Beschränkung der Anrechenbarkeit §36a EStG / §31 Abs. 3 InvStG flag                                                           |

## Anlage V 2025 (one per property, September 2025; Kz two-digit, not paired)

[Copy](https://www.steuern.de/fileadmin/user_upload/Steuerformulare_2025/Anlage_V_2025_steuern-de.pdf), [Anleitung](https://www.formulare-bfinv.de/ffw/action/invoke.do?id=034032_25). **The Z55 to Z82 block lost line labels in extraction; treat Z/Kz pairs below Z54 as indicative and verify against the PDF.**

| Z       | Kz           | Meaning                                                                                                                                  |
| ------- | ------------ | ---------------------------------------------------------------------------------------------------------------------------------------- |
| 4-5     | none         | Address of the property                                                                                                                  |
| 6       | 00           | Aktenzeichen Grundsteuermessbescheid                                                                                                     |
| 9       | none         | W-IdNr                                                                                                                                   |
| 10      | 61 / 63 / 62 | Flags: Ferienwohnung, kurzfristige Vermietung, Vermietung an Angehörige (1 = Ja / 2 = Nein)                                              |
| 11      | 54           | Gesamtwohnfläche m2                                                                                                                      |
| 12      | 55 / 56      | Eigengenutzt/unentgeltlich überlassen m2; als Ferienwohnung genutzt m2                                                                   |
| 15      | 01           | Summe Mieteinnahmen Wohnungen (without Umlagen and USt)                                                                                  |
| 18      | 02           | Einnahmen andere Räume                                                                                                                   |
| 19      | 03           | Einnahmen an Angehörige vermietete Wohnungen                                                                                             |
| 20 / 21 | 04 / 11      | Umgelegte Nebenkosten (laufend) and Nachzahlungen/Erstattungen                                                                           |
| 22 / 23 | 05 / 12      | Same for Z19                                                                                                                             |
| 24      | 13           | Nebenkosten not separately agreed (1 = Ja)                                                                                               |
| 25      | 06           | Vereinnahmte Mieten for früher Jahre, Kautionen                                                                                          |
| 26      | 07           | Einnahmen aus Garagen, Werbeflächen                                                                                                      |
| 27 / 28 | 09 / 10      | Vereinnahmte USt / vom Finanzamt erstattete USt                                                                                          |
| 31      | 08           | Ergebnis Z29 and Z30 (Zuschüsse, sonstige Einnahmen)                                                                                     |
| 35      | 30           | AfA Gebäude                                                                                                                              |
| 38      | 70           | Sonderabschreibung §7b                                                                                                                   |
| 41      | 31           | Erhöhte Absetzungen §7h, §7i                                                                                                             |
| 45      | 60           | AfA on non-building assets                                                                                                               |
| 48      | 33           | Schuldzinsen                                                                                                                             |
| 51      | 34           | Geldbeschaffungskosten                                                                                                                   |
| 54      | 35           | Renten, dauernde Lasten                                                                                                                  |
| 55 / 56 | 36 / 37      | Erhaltungsaufwendungen (direct / proportional); year-spread blocks Kz 38-42 for older years and 52, 48, 58, 49 further down (indicative) |
| 83      | none         | Summe der Werbungskosten                                                                                                                 |
| 86      | 20 / 21      | Zurechnung of the Überschuss between persons                                                                                             |
| 87      | 50           | Kürzung der Werbungskosten bei verbilligter Vermietung (%)                                                                               |

## Anlage Vorsorgeaufwand 2025 (A / B, Oktober 2025)

[Copy](https://www.steuern.de/fileadmin/user_upload/Steuerformulare_2025/Anlage_Vorsorgeaufwand_2025_steuern-de.pdf), [Anleitung](https://www.formulare-bfinv.de/ffw/action/invoke.do?id=034098_25).

| Z            | Kz (A / B)                           | Meaning                                                                                                                                       |
| ------------ | ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------- |
| 4            | 300 / 400                            | Arbeitnehmeranteil gesetzliche Rentenversicherung (Lohnsteuerbescheinigung Nr. 23 a/b)                                                        |
| 5            | 301 / 401                            | Beiträge landwirtschaftliche Alterskasse / berufsständische Versorgung                                                                        |
| 6            | 302 / 402                            | Beiträge gesetzliche Rentenversicherung (not via Z4)                                                                                          |
| 7            | 309 / 409                            | Erstattete Beiträge and steuerfreie Zuschüsse to Z4-6                                                                                         |
| 8            | 303 / 403                            | **Basisrente (Rürup) contributions**                                                                                                          |
| 9 / 10       | 304 / 404, 306 / 406                 | Arbeitgeberanteil / -zuschuss; Arbeitgeberanteil Minijob (pauschal)                                                                           |
| 11           | 320 / 420                            | Arbeitnehmerbeiträge gesetzliche KV (Nr. 25)                                                                                                  |
| 12           | 322 / 422                            | Of which no Krankengeld entitlement                                                                                                           |
| 13           | 323 / 423                            | Arbeitnehmerbeiträge soziale PV (Nr. 26)                                                                                                      |
| 14 / 15      | 324 / 424, 325 / 425                 | Erstattete Beiträge; of which no Krankengeld entitlement                                                                                      |
| 16-21        | 326, 328, 329, 330, 331, 332 (/ 4xx) | Self-paying GKV/PV (for example pensioners), Zuschuss                                                                                         |
| 22           | 338 / 438                            | KV Wahlleistungen, Zusatzversicherungen                                                                                                       |
| 23-27        | 350, 351, 352, 353, 354 (/ 4xx)      | PKV Basisabsicherung (Z23 Kz 350), Pflege-Pflichtversicherung (Kz 351), refunds (352), third-party Zuschuss (353), Wahlleistungen (354)       |
| 28-33        | 333-337, 339 (/ 4xx)                 | Foreign KV and PV                                                                                                                             |
| 34 / 35 / 36 | 360 / 361 / 362 (/ 46x)              | Steuerfreie Arbeitgeberzuschüsse: GKV (Nr. 24 a), PKV (24 b), PV (24 c)                                                                       |
| 37-42        | 600-604                              | Premiums paid as policyholder for other persons                                                                                               |
| 43           | 370 / 470                            | Arbeitnehmerbeiträge Arbeitslosenversicherung (Nr. 27)                                                                                        |
| 44-48        | 500, 501, 502, 503                   | Other Versicherungen: unemployment, Erwerbs-/Berufsunfähigkeit, Unfall/Haftpflicht/Risiko, Rentenversicherung mit Kapitalwahlrecht (pre-2005) |
| 50-52        | 380 / 480, 382 / 482                 | Anwartschaft auf Altersversorgung flags: Beamter (Z50), Geschäftsführer-type (Z51), other (Z52)                                               |

## Anlage Sonderausgaben 2025 (A / B, September 2025)

[Copy](https://www.steuern.de/fileadmin/user_upload/Steuerformulare_2025/Anlage_Sonderausgaben_2025_steuern-de.pdf), [Anleitung](https://www.formulare-bfinv.de/ffw/action/invoke.do?id=035006_25).

| Z       | Kz                                   | Meaning                                                                                       |
| ------- | ------------------------------------ | --------------------------------------------------------------------------------------------- |
| 4       | 103 (gezahlt) / 104 (erstattet)      | Kirchensteuer paid / refunded in 2025 (not the Zuschlag to Abgeltungsteuer)                   |
| 5       | 123 / 124                            | Spenden und Mitgliedsbeiträge, inland recipient (laut Bestätigungen / laut Betriebsfinanzamt) |
| 6       | 133 / 134                            | Spenden EU/EWR recipient                                                                      |
| 7       | 127 / 128                            | Parteien (§34g, §10b)                                                                         |
| 8       | 129 / 130                            | Unabhängige Wählervereinigungen                                                               |
| 9-12    | 208-215, 224, 225                    | Spenden in the Vermögensstock of a Stiftung                                                   |
| 13 / 14 | 200 / 201                            | Eigene Berufsausbildung (person A / B)                                                        |
| 15      | 102 (% abziehbar), 101 (EUR gezahlt) | Versorgungsleistungen aus Renten                                                              |
| 22-27   | 100, 161, 144, 155 etc.              | Dauernde Lasten                                                                               |

## Anlage AUS 2025 (three country columns, Oktober 2025)

[Copy](https://www.steuern.de/fileadmin/user_upload/Steuerformulare_2025/Anlage_AUS_2025_steuern-de.pdf), [Anleitung](https://www.formulare-bfinv.de/ffw/action/invoke.do?id=034010_25). §34c foreign tax credit detail not researched.

| Z       | Kz (1st / 2nd / 3rd state) | Meaning                                                 |
| ------- | -------------------------- | ------------------------------------------------------- |
| 4       | 19 / 29                    | Staat (country selection)                               |
| 7       | 107 / 127 / 147            | Einkünfte (incl. §3 Nr. 40 and §3c Abs. 2 exempt parts) |
| 8       | 108 / 128 / 148            | Of which with §3 Nr. 40 / §3c Abs. 2                    |
| 9       | 115 / 135 / 155            | Teilfreistellungsbeträge InvStG                         |
| 10 / 11 | 113 / 133 / 153            | Ausländische Steuern abgezogen nach §34c Abs. 2 and 3   |
| 12      | 109 / 129 / 149            | Anzurechnende ausländische Steuern for all income types |
| 14      | 800                        | Pauschal zu besteuernde Einkünfte §34c Abs. 5           |
| 15 / 16 | 827 / 828                  | §50d Abs. 7 Einkünfte and Steuer                        |
| 17 / 18 | 824 / 825                  | §50d Abs. 10                                            |
| 22-24   | 801, 802, 803              | Hinzurechnungsbesteuerung AStG                          |
| 28-30   | 818, 819, 820              | Familienstiftung §15 AStG                               |

## Not extracted

Anlage Kind, Anlage AV, Anlage Haushaltsnahe Aufwendungen, Anlage Außergewöhnliche Belastungen, Anlage R, Anlage SO. Form copies are listed at [steuern.de form list](https://www.steuern.de/steuerformulare).
