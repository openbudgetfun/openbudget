# Anlage EÜR 2025 and 2026: Zeile and Kennzahl

Primary: the official BMF form PDFs. 2025: [BMF letter 29 Aug 2025, GZ IV C 6 - S 2142/00023/010/001](https://www.bundesfinanzministerium.de/Content/DE/Downloads/BMF_Schreiben/Steuerarten/Einkommensteuer/2025-08-29-anlage-EUER-2025.pdf?__blob=publicationFile&v=3). 2026: [BMF letter 1 Sep 2026, GZ IV C 6 - S 2142/00024/010/001](https://www.bundesfinanzministerium.de/Content/DE/Downloads/BMF_Schreiben/Steuerarten/Einkommensteuer/2026-09-01-anlage-EUER-2026.pdf?__blob=publicationFile&v=4). Text was extracted locally by the researcher. Research date 5 Nov 2026.

## The 2026 shift

The Kennzahlen are identical in 2025 and 2026. The 2026 form inserts one new line at Z27 (Rücklage Tierbewertung for Land- und Forstwirte, no Kz), so **every Zeile from Z27 on is 2025 Z + 1 in 2026**. The Gewinn Kz 219 is on Z97 (2025) and Z98 (2026). Store values by Kz and section and render the Zeile from a per-year lookup.

Two caveats the checklist builder must handle:

1. **Kz are not unique inside the form.** The general block (Z4 to Z6) and the expense block share Kz: 100 (Z6 Art des Betriebs; Z27 Waren), 131 (Z4 abweichender Beginn; Z32 AfA immaterielle WG), 132 (Z4 abweichendes Ende; Z36 GWG), 120 (Z30 Personal; Rücklage block), 123 (Z87 Gewinnzuschlag; Z107 Einlagen) and 187 (Z88 IAB-Abzug; Rücklage block Z99). Key by (section, Kz).
2. **One row in the research is inconsistent with the +1 rule**: Waren/Rohstoffe is listed "Z27 (2026: 29)". The +1 rule says Z28. Treat the 2026 Zeile for Kz 100 (Waren) as unverified and read the form.

## Table (Zeile 2025, with 2026 in parentheses where it differs)

| Z 2025 (2026)               | Kz                                | Meaning                                                                                                                        |
| --------------------------- | --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| 4                           | 131 / 132                         | Abweichender Beginn / Ende des Wirtschaftsjahres                                                                               |
| 5                           | 101                               | W-IdNr                                                                                                                         |
| 6                           | 100                               | Art des Betriebs                                                                                                               |
| 7-8                         | none (1033)                       | Einkunftsart: 1 = Land- und Forstwirtschaft, 2 = Gewerbebetrieb, 1033 = selbständige Arbeit                                    |
| 9                           | 1043                              | Betriebsinhaber (1 = person A, 2 = person B, 1043 = both)                                                                      |
| 10                          | 1112                              | Betrieb beendet (1 = Veräußerung/Aufgabe, 1112 = unentgeltliche Übertragung)                                                   |
| 11                          | 1202                              | Grundstücke entnommen/veräußert (1 = Ja / Nein)                                                                                |
| 12                          | 111                               | Betriebseinnahmen als Kleinunternehmer (§19 Abs. 1 UStG), without amounts in Z18-22                                            |
| 13                          | 119                               | Of which nicht steuerbare Umsätze and §19 Abs. 2 Umsätze                                                                       |
| 14                          | 104                               | Betriebseinnahmen Land- und Forstwirt (§24 UStG)                                                                               |
| 15                          | 112                               | Umsatzsteuerpflichtige Betriebseinnahmen (not 0% rate)                                                                         |
| 16                          | 103                               | Steuerfreie, nicht steuerbare, 0%-rate or §13b-reverse-charge Betriebseinnahmen                                                |
| 17                          | 140                               | Vereinnahmte Umsatzsteuer and USt on unentgeltliche Wertabgaben                                                                |
| 18                          | 141                               | Vom Finanzamt erstattete USt (10-day rule §11 Abs. 1 Satz 2 EStG)                                                              |
| 19                          | 102                               | Veräußerung oder Entnahme von Anlagevermögen                                                                                   |
| 20                          | 106                               | Private Kfz-Nutzung                                                                                                            |
| 21                          | 108                               | Sonstige Sach-, Nutzungs- und Leistungsentnahmen                                                                               |
| 22                          | none                              | Auflösung Rücklagen/Ausgleichsposten (from Z105; 2026: Z106)                                                                   |
| 23                          | 159                               | **Summe Betriebseinnahmen**                                                                                                    |
| 24                          | 195                               | Betriebsausgabenpauschale for certain professions                                                                              |
| (27 new)                    | none                              | 2026 only: Bildung Rücklage Tierbewertung (Land- und Forstwirte)                                                               |
| 27 (2026: 29, unverified)   | 100                               | Waren, Rohstoffe, Hilfsstoffe                                                                                                  |
| 29 (30)                     | 110                               | Bezogene Fremdleistungen                                                                                                       |
| 30 (31)                     | 120                               | Ausgaben für eigenes Personal                                                                                                  |
| 31 (32)                     | 136                               | AfA on Grundstücke (from AVEÜR Z22)                                                                                            |
| 32 (33)                     | 131                               | AfA on immaterielle Wirtschaftsgüter                                                                                           |
| 33 (34)                     | 130                               | AfA on bewegliche Wirtschaftsgüter                                                                                             |
| 34 (35)                     | 134                               | Sonderabschreibungen §7b and §7g Abs. 5, 6                                                                                     |
| 35 (36)                     | 138                               | Herabsetzungsbeträge §7g Abs. 2 Satz 3                                                                                         |
| 36 (37)                     | 132                               | **GWG** (§6 Abs. 2 EStG)                                                                                                       |
| 37 (38)                     | 137                               | Auflösung Sammelposten (§6 Abs. 2a EStG)                                                                                       |
| 38 (39)                     | 135                               | Restbuchwerte ausgeschiedener Anlagegüter                                                                                      |
| 39 (40)                     | 150                               | Miete/Pacht Geschäftsräume                                                                                                     |
| 40 (41)                     | 152                               | Doppelte Haushaltsführung                                                                                                      |
| 41 / 42 (42 / 43)           | 151 / 153                         | Sonstige Grundstücksaufwendungen / of which Erhaltungsaufwendungen                                                             |
| 43 (44)                     | 280                               | Telekommunikation                                                                                                              |
| 44 (45)                     | 221                               | Übernachtung and Reisenebenkosten                                                                                              |
| 45 (46)                     | 281                               | Fortbildungskosten                                                                                                             |
| 46 (47)                     | 194                               | Rechts- und Steuerberatung, Buchführung                                                                                        |
| 47 (48)                     | 222                               | Miete/Leasing bewegliche WG (ohne Kfz)                                                                                         |
| 48 (49)                     | 225                               | Erhaltungsaufwendungen (not building or Kfz)                                                                                   |
| 49 (50)                     | 223                               | Beiträge, Gebühren, Abgaben, Versicherungen (not building or Kfz)                                                              |
| 50 (51)                     | 228                               | Laufende EDV-Kosten                                                                                                            |
| 51 (52)                     | 229                               | Arbeitsmittel (Bürobedarf, Porto, Fachliteratur)                                                                               |
| 52 (53)                     | 226                               | Abfallbeseitigung                                                                                                              |
| 53 (54)                     | 227                               | Verpackung und Transport                                                                                                       |
| 54 (55)                     | 224                               | Werbekosten                                                                                                                    |
| 55 (56)                     | 232                               | Schuldzinsen for Anschaffung/Herstellung Anlagevermögen                                                                        |
| 56 (57)                     | 234                               | Übrige Schuldzinsen                                                                                                            |
| 57 (58)                     | 185                               | **Gezahlte, nach §15 UStG abziehbare Vorsteuer**                                                                               |
| 58 (59)                     | 186                               | **An das Finanzamt gezahlte USt** (10-day rule §11 Abs. 2 Satz 2 EStG)                                                         |
| 60 (61)                     | 183                               | Übrige unbeschränkt abziehbare Betriebsausgaben                                                                                |
| 62 (63)                     | 164 (nicht abz.) / 174 (abz.)     | Geschenke                                                                                                                      |
| 63 (64)                     | 165 / 175                         | Bewirtungsaufwendungen (70% deductible)                                                                                        |
| 64 (65)                     | 171                               | Verpflegungsmehraufwendungen                                                                                                   |
| 65 (66)                     | 162 / 172                         | Häusliches Arbeitszimmer (nicht abziehbar / abziehbar)                                                                         |
| 66 (67)                     | 163                               | **Tagespauschale** for work in the home (Homeoffice)                                                                           |
| 67 (68)                     | 168 / 177                         | Sonstige beschränkt abziehbare Betriebsausgaben                                                                                |
| 68 (69)                     | 144                               | Kfz: Leasingkosten                                                                                                             |
| 69 (70)                     | 145                               | Kfz: Steuern, Versicherungen, Maut                                                                                             |
| 70 (71)                     | 146                               | Sonstige tatsächliche Fahrtkosten                                                                                              |
| 71 (72)                     | 147                               | Fahrtkosten for non-business vehicles (Nutzungseinlage)                                                                        |
| 72 (73)                     | 142                               | Wohnung-erste Betriebsstätte (minus)                                                                                           |
| 73 (74)                     | 176                               | Mindestens abziehbar: Entfernungspauschale (plus)                                                                              |
| 74 (75)                     | 139                               | Nicht abziehbare Beträge                                                                                                       |
| 75 (76)                     | 199                               | **Summe Betriebsausgaben**                                                                                                     |
| 78 / 79 / 80 (79 / 80 / 81) | 240 / 241 / 242                   | Steuerfreie Einnahmen §3 Nr. 26, 26a, 26b; other §3; §3a                                                                       |
| 81-83 (82-84)               | 243 / 244 / 245                   | Nicht abziehbare Betriebsausgaben related to those                                                                             |
| 84 / 85 / 86 (85 / 86 / 87) | 180 / 181 / 182                   | **Hinzurechnung IAB §7g Abs. 2** from 3, 2, 1 years back (2025 form: IAB of 2022 / 2023 / 2024; 2026 form: 2023 / 2024 / 2025) |
| 87 (88)                     | 123                               | Gewinnzuschlag §6c/6b                                                                                                          |
| 88 (89)                     | 187                               | **Abzug IAB §7g Abs. 1** (new IAB for the year)                                                                                |
| 89 (90)                     | 250                               | Wechsel der Gewinnermittlungsart                                                                                               |
| 91 (92)                     | 255                               | Ergebnisanteile aus Personengesellschaften                                                                                     |
| 92 (93)                     | 290                               | Korrigierter Gewinn/Verlust                                                                                                    |
| 93 (94)                     | 263 / 264                         | InvStG-exempt amounts                                                                                                          |
| 94 (95)                     | 261 / 262                         | Teileinkünfteverfahren / §8b KStG amounts                                                                                      |
| 95 (96)                     | 293                               | Steuerpflichtiger Gewinn vor §4 Abs. 4a                                                                                        |
| 96 (97)                     | 271                               | Hinzurechnungsbetrag §4 Abs. 4a (Schuldzinsen)                                                                                 |
| 97 (98)                     | 219                               | **Steuerpflichtiger Gewinn/Verlust** (goes to Anlage S Z6 Kz 100/300 or Anlage G Z6 Kz 10/11)                                  |
| 99-105 (100-106)            | 187, 170, 191, 190, 120, 125, 124 | Bildung/Auflösung Rücklagen §6c/§6b and Ausgleichsposten §4g                                                                   |
| 106 / 107 (107 / 108)       | 122 / 123                         | Entnahmen / Einlagen incl. Sach-, Leistungs- and Nutzungs- (for §4 Abs. 4a)                                                    |

Some 2025 Zeilen (for example Z25, Z26, Z28, Z59, Z61, Z76, Z77, Z90, Z98) were not listed by the research (headers or unlabelled lines). The AVEÜR Anlageverzeichnis Kz: Z4-8 Grund und Boden (100, 101, 102, 105, 106); Z9-15 Gebäude (110-116); Z16-21 andere (120-126); Z22 Kz 190 total AfA on land; Z23-27 and Z28-33 Arbeitszimmer (200-216); immaterielle WG Z34-39 (320-326); bewegliche WG Kz 400-406 (Kfz) and so on. Full lists are on pages 7 to 12 of the 2025 PDF; AVEÜR 2026 differences were not diffed.

Other rules from the letters:

- Anlage SZ must be filed when Schuldzinsen exceed 2,050 (non-deductible interest threshold).
- Körperschaften submit EÜR only to Z75 (2025) / Z76 (2026); Anlage GK completes the Einkünfte.
- 2026 adds a Rücklage for Umstellungsgewinn on Tierbewertung (Anlage LuF), referring to a BMF letter of 8 Dec 2025 (BStBl I S. 2042). Registration wording changed from "Zertifikat" to "Registrierung über Mein ELSTER".
- Not read: the Anleitung pages (13 to 44) on how to enter GWG or the degressive AfA split between Kz 130 and AVEÜR lines, the Tagespauschale 2026 requirements for Kz 163.

## Checklist rules for a freelancer (inferred)

Minimal checklist: Kz 112 (taxable turnover net), Kz 140 (USt collected), Kz 159 total; expenses by category Kz; Kz 185 (Vorsteuer paid) and Kz 186 (USt paid to the Finanzamt); AfA Kz 130/131/136, GWG Kz 132, IAB Kz 187, Kz 199 total, Kz 219 Gewinn. Kleinunternehmer use Kz 111 for all turnover and have no USt lines. Bewirtung: record the full invoice, show Kz 175 at 70% and Kz 165 at 30%.

Under EÜR, Umsatzsteuer and Vorsteuer are Betriebseinnahmen and Betriebsausgaben (Kz 140/141 and 185/186) for regular VAT payers; keep expense categories net of VAT elsewhere or the Gewinn double counts. The 10-day rule (§11 EStG) decides the year of regular recurring payments around year-end.
