# ELSTER Umsatzsteuer and Lohnsteuer forms, and the KSt/GewSt gap

Primary: official BMF Vordruckmuster, text extracted locally by the researcher. Base = Bemessungsgrundlage (net whole euros), Tax = Steuer (euros and cents). Where the Kz order of a two-box line was ambiguous in the layout extraction it is flagged. Research date 5 Nov 2026.

## UStVA 2026, form USt 1 A

Source: [BMF Vordruckmuster USt-Voranmeldung 2026, letter 29 Dec 2025, GZ III C 3 - S 7344/00039/007/036](https://www.bundesfinanzministerium.de/Content/DE/Downloads/BMF_Schreiben/Steuerarten/Umsatzsteuer/2025-12-29-vordruckmuster-USt-voranmeldung-2026.pdf?__blob=publicationFile&v=7). Kz are stable year to year. The 2025 Zeilen (letter 9 Dec 2024, forms USt 1 A, 1 H, 1 E, [Haufe](https://www.haufe.de/steuern/finanzverwaltung/umsatzsteuer-voranmeldungs-und-vorauszahlungsverfahren-2025_164_638438.html)) were not opened; they are inferred to match because the 2026 letter lists only editorial changes plus SAFE (Kz 43), the §24 UStG 2026 average rate (19% minus flat input-tax rate, tax in Z18) and the Umsatzsteuerlager transition (§27 Abs. 40a UStG, to 31 Dec 2029; its Vorsteuer goes in Kz 66).

| Z     | Kz                   | Meaning                                                                                                            |
| ----- | -------------------- | ------------------------------------------------------------------------------------------------------------------ |
| 1     | none                 | Steuernummer / W-IdNr                                                                                              |
| 6-9   | not labelled         | Voranmeldungszeitraum: tick a month or quarter box (codes not confirmed for the UStVA)                             |
| 10    | 10                   | Berichtigte Anmeldung (1 = Ja)                                                                                     |
| 11    | 22                   | Belege beigefügt (1 = Ja)                                                                                          |
| 12    | 70                   | Datum des Wechsels von Kleinunternehmer-Regelung zur Regelbesteuerung                                              |
| 13    | 81                   | **Steuerpflichtige Umsätze 19%** (base only; ELSTER computes the tax)                                              |
| 14    | 86                   | **Umsätze 7%** (base only)                                                                                         |
| 15    | 87                   | Umsätze 0% (§12 Abs. 3 UStG, PV)                                                                                   |
| 16    | 35 (base) / 36 (tax) | Umsätze zu anderen Steuersätzen                                                                                    |
| 17    | 77                   | §24 UStG Lieferungen an Abnehmer mit USt-IdNr (Land- und Forstwirte)                                               |
| 18    | 76 / 80              | §24 UStG Umsätze with tax to pay; which of 76/80 is base vs tax not confirmed                                      |
| 19    | 41                   | **Innergemeinschaftliche Lieferungen** an Abnehmer mit USt-IdNr (§4 Nr. 1 b)                                       |
| 20    | 44                   | ig Lieferungen neuer Fahrzeuge an Abnehmer ohne USt-IdNr                                                           |
| 21    | 49                   | Neue Fahrzeuge außerhalb eines Unternehmens (§2a)                                                                  |
| 22    | 43                   | Weitere steuerfreie Umsätze mit Vorsteuerabzug (Ausfuhr, §4 Nr. 2-7, EU-Verordnungen, incl. SAFE from 2026)        |
| 23    | 48                   | **Steuerfreie Umsätze ohne Vorsteuerabzug** (for example §4 Nr. 8-29, §19 Abs. 1 UStG)                             |
| 24    | 91                   | Steuerfreie ig Erwerbe (§4b, §25c)                                                                                 |
| 25    | 89                   | **ig Erwerbe 19%**                                                                                                 |
| 26    | 93                   | ig Erwerbe 7%                                                                                                      |
| 27    | 90                   | ig Erwerbe 0%                                                                                                      |
| 28    | 95 (base) / 98 (tax) | ig Erwerbe other rates                                                                                             |
| 29    | 96 / 94              | Neue Fahrzeuge from suppliers without USt-IdNr (order not confirmed)                                               |
| 30    | 46 (base) / 47 (tax) | **§13b Abs. 1** sonstige Leistungen EU-Unternehmer (§3a Abs. 2)                                                    |
| 31    | 73 / 74              | §13b Abs. 2 Nr. 3 Grundstückslieferungen (GrEStG)                                                                  |
| 32    | 84 / 85              | **§13b** andere Leistungen (Abs. 2 Nr. 1, 2, 4 bis 12)                                                             |
| 33    | 42                   | Lieferungen des ersten Abnehmers im ig Dreiecksgeschäft (§25b)                                                     |
| 34    | 60                   | Umsätze des leistenden Unternehmers where the recipient owes §13b Abs. 5 tax                                       |
| 35    | 21                   | Nicht steuerbare sonstige Leistungen §18b Satz 1 Nr. 2                                                             |
| 36    | 45                   | Übrige nicht steuerbare Umsätze (Leistungsort nicht im Inland)                                                     |
| 37    | none                 | Umsatzsteuer total (computed)                                                                                      |
| 38    | 66                   | **Vorsteuer aus Rechnungen** (enter the tax)                                                                       |
| 39    | 61                   | Vorsteuer from ig Erwerben (§15 Abs. 1 Nr. 3)                                                                      |
| 40    | 62                   | **Einfuhrumsatzsteuer** (§15 Abs. 1 Nr. 2)                                                                         |
| 41    | 67                   | **Vorsteuer from §13b services** (§15 Abs. 1 Nr. 4)                                                                |
| 42    | 63                   | Vorsteuer nach Durchschnittssätzen (§23a)                                                                          |
| 43    | 59                   | Vorsteuerabzug for ig Lieferungen neuer Fahrzeuge and Kleinunternehmer (§15 Abs. 4a)                               |
| 44    | 64                   | Berichtigung des Vorsteuerabzugs (§15a)                                                                            |
| 45    | none                 | Verbleibender Betrag (computed)                                                                                    |
| 46    | 65                   | Steuer from Wechsel der Besteuerungsform, Nachsteuer wegen Steuersatzänderung                                      |
| 47    | 69                   | §14c unrichtig/unberechtigt ausgewiesene Steuer, plus other §6a/§17/§25b/§27 Abs. 40a amounts                      |
| 48    | none                 | Vorauszahlung/Überschuss (computed)                                                                                |
| 49    | 39                   | Abzug festgesetzte Sondervorauszahlung (Dauerfristverlängerung; usually only in the last Voranmeldung of the year) |
| 50    | 83                   | **Verbleibende USt-Vorauszahlung** or Überschuss (negative with minus), always to be filled                        |
| 51    | 50                   | Minderung der Bemessungsgrundlage §17 Abs. 1 (included in Z13-18)                                                  |
| 52    | 37                   | Minderung der abziehbaren Vorsteuer §17                                                                            |
| 53-54 | 129 / 126            | Verrechnung des Erstattungsbetrags erwünscht / SEPA-Lastschriftmandat nicht verwenden (1 = Ja)                     |
| 55    | garbled              | "Ergänzende Angaben zur Steueranmeldung" flag 1/2/3/4; Kz not read reliably                                        |

Confirmed by a secondary explainer: Kz 46 base and 47 tax, Kz 81/86 net turnover entered with tax computed by ELSTER, Kz 66/61/62/67 Vorsteuer, Kz 89 ig Erwerb net, Kz 83 Zahllast (positive pay by the 10th, negative refund) ([onlinebilanz.de](https://onlinebilanz.de/umsatzsteuervoranmeldung/formular/)). Base/tax assignment for 35/36, 73/74, 84/85, 95/98 follows the annual form's pattern (base then tax, for example 846/847). Kz 76/80 and 96/94 are unconfirmed; the USt 1 E instructions (2026 letter pages 8 to 17) were not read.

Typical domestic checklist (inferred): Z13 Kz 81, Z14 Kz 86, Z38 Kz 66, Z50 Kz 83 (computed). Bought EU reverse-charge services: Z30 Kz 46/47 and Z41 Kz 67 (net zero if fully deductible). Bought domestic §13b construction or cleaning: Z32 Kz 84/85 plus Z41 Kz 67. Sold §13b services: Z34 Kz 60.

### Dauerfristverlängerung (USt 1 H 2026)

Kz 38 = Sondervorauszahlung (1/11 of the sum of the remaining prepayments of the prior year plus the previous Sondervorauszahlung). Quarterly filers need none.

## Annual Umsatzsteuererklärung 2025 / 2026 (USt 2 A)

2025: letter 9 Dec 2024, GZ III C 3 - S 7344/19/10002 :007, via a copy ([taxpool.net](https://umsatzsteuer-erklaerung.taxpool.net/Umsatzsteuererkl%C3%A4rung-2025.pdf)). 2026: [BMF letter 29 Dec 2025, GZ III C 3 - S 7344/00040/008/034](https://www.bundesfinanzministerium.de/Content/DE/Downloads/BMF_Schreiben/Steuerarten/Umsatzsteuer/2025-12-29-muster-USt-erklaerung-2026.pdf?__blob=publicationFile&v=5). The 2026 form inserts lines (new Kz 308/309/310 for Reiseleistungen and Differenzbesteuerung), so Zeilen differ. Annual USt 2026 Zeilen for Z1 to Z21 and Anlage UN/FV were not listed.

| Z 2025 (2026)                           | Kz                          | Meaning                                                                                                                                  |
| --------------------------------------- | --------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| 3                                       | 1101                        | Berichtigte Steuererklärung                                                                                                              |
| 16 (18)                                 | 136                         | Date of change from Kleinunternehmer to Regelbesteuerung (also the date the 100,000 limit was crossed; for a waiver of §19 enter 01.01.) |
| 18-19                                   | 133                         | Steuer berechnet nach 1 = vereinbarten Entgelten (§16), 2 = vereinnahmten (§20), 3 = partly                                              |
| 20                                      | 129                         | Verrechnung des Erstattungsbetrags erwünscht                                                                                             |
| 21                                      | 1231                        | More or deviating information attached                                                                                                   |
| 22 (24)                                 | 177 (base)                  | Lieferungen und sonstige Leistungen 19% (tax computed)                                                                                   |
| 23 / 24                                 | 178 / 179                   | Unentgeltliche Wertabgaben 19% (Lieferungen §3 Abs. 1b / sonstige §3 Abs. 9a)                                                            |
| 25 (27)                                 | 275                         | Umsätze 7%                                                                                                                               |
| 26 / 27                                 | 195 / 196                   | Unentgeltliche Wertabgaben 7%                                                                                                            |
| 28-30 (30-32)                           | 157 / 158 / 159             | Umsätze 0% (incl. Wertabgaben)                                                                                                           |
| 31 (33)                                 | 155 (base) / 156 (tax)      | Other rates                                                                                                                              |
| 33 (35)                                 | 346 / 347                   | §24 UStG with tax to pay                                                                                                                 |
| 37 (new 2026)                           | 308 (base) / 309 (tax)      | New in 2026: steuerpflichtige Umsätze nach §25 UStG (Reiseleistungen); in 2025 in Z44 within Kz 237                                      |
| 38 (new 2026)                           | 310 (base)                  | New in 2026: Differenzbesteuerung §25a                                                                                                   |
| 38 (42)                                 | 741                         | ig Lieferungen an USt-IdNr customers                                                                                                     |
| 41 (45)                                 | 752                         | Ausfuhrlieferungen                                                                                                                       |
| 45 (50)                                 | 237                         | Summe weitere steuerfreie Umsätze mit Vorsteuerabzug (2026: also SAFE in Z48)                                                            |
| 46 / 47 (51 / 52)                       | 286 / 287                   | Steuerfreie Umsätze ohne Vorsteuerabzug not counted in the Gesamtumsatz (§4 Nr. 12 rent etc.)                                            |
| 48 (53)                                 | 236                         | Steuerfreie Umsätze §19 Abs. 1 UStG (Kleinunternehmer turnover within the Gesamtumsatz)                                                  |
| 51-54 (57-60)                           | 781 / 793 / 780 / 798-799   | ig Erwerbe 19% / 7% / 0% / other                                                                                                         |
| 59-63                                   | 742, 751, 746, 750, 747/748 | ig Dreiecksgeschäfte                                                                                                                     |
| 65 / 66 / 67 (71 / 72 / 73)             | 846-847 / 873-874 / 877-878 | **§13b** (base-tax pairs)                                                                                                                |
| 70                                      | 209                         | §13b Abs. 5 turnovers where the recipient owes tax                                                                                       |
| 74                                      | 721                         | Nicht steuerbare sonstige Leistungen §18b                                                                                                |
| 75                                      | 205                         | Übrige nicht steuerbare Umsätze                                                                                                          |
| 79 (85)                                 | 320                         | **Vorsteuer aus Rechnungen**                                                                                                             |
| 80                                      | 761                         | Vorsteuer from ig Erwerben                                                                                                               |
| 81                                      | 762                         | Einfuhrumsatzsteuer                                                                                                                      |
| 83 (89)                                 | 467                         | Vorsteuer aus §13b Leistungen                                                                                                            |
| 84                                      | 334                         | §23a Durchschnittssatz                                                                                                                   |
| 85                                      | 759                         | §15 Abs. 4a                                                                                                                              |
| 88                                      | 63                          | Minderung Vorsteuer §17                                                                                                                  |
| 102                                     | 357 / 359                   | §15a Berichtigung nachträglich abziehbar / zurückzuzahlen                                                                                |
| 113                                     | 318                         | §14c unrichtig ausgewiesene Steuer                                                                                                       |
| 114                                     | 331                         | §17 Abs. 1 Satz 7 UStG                                                                                                                   |
| 115                                     | 391                         | Frühere Besteuerungszeiträume (Kleinunternehmer only)                                                                                    |
| 118 (2026 text: "816" at same position) | 816                         | **Verbleibende Umsatzsteuer / Überschuss** (negative = Überschuss)                                                                       |
| 120                                     | 820                         | **Abschlusszahlung or Erstattungsanspruch** (negative)                                                                                   |

Several rows show a 2025 Zeile with no 2026 value because the research did not list one; do not infer the 2026 Zeile.

## Lohnsteuer-Anmeldung 2026

Source: [BMF Muster Lohnsteuer-Anmeldung 2026, letter 21 Aug 2025 GZ IV C 5 - S 2533/00120/006/009](https://www.bundesfinanzministerium.de/Content/DE/Downloads/BMF_Schreiben/Steuerarten/Lohnsteuer/2025-08-14-Muster-Lohnsteuer-Anmeldung-2026.pdf?__blob=publicationFile&v=6). Haufe lists Kz 86, 42, 49, 61, 62 as the usually filled ones ([Haufe](https://www.haufe.de/id/beitrag/lohnsteuer-anmeldung-und-beitragsnachweis-verfahren-21-auszufuellende-kennziffern-HI2581618.html)); Haufe's mixing of 47 and 49 is resolved by the BMF form.

| Z     | Kz                                                           | Meaning                                                                                                                                             |
| ----- | ------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| 7-12  | 2601-2612 (months), 2641-2644 (quarters I-IV), 2619 (annual) | Anmeldungszeitraum codes (year 26 plus period)                                                                                                      |
| 13    | 10                                                           | Berichtigte Anmeldung (1 = ja)                                                                                                                      |
| 14    | 86                                                           | Zahl der Arbeitnehmer (incl. Aushilfs- und Teilzeitkräfte)                                                                                          |
| 15    | 90                                                           | Zahl der Arbeitnehmer mit BAV-Förderbetrag                                                                                                          |
| 16    | 92                                                           | Negativer Gesamtbetrag aufgrund Lohnsteuerjahresausgleich (1 = ja)                                                                                  |
| 18    | 42                                                           | **Summe der einzubehaltenden Lohnsteuer** (negative with minus)                                                                                     |
| 19    | 41                                                           | Summe der pauschalen Lohnsteuer ohne §37b                                                                                                           |
| 20    | 44                                                           | Pauschale Lohnsteuer nach §37b                                                                                                                      |
| 21    | 33                                                           | Abzüglich Kürzungsbetrag Handelsschiff crews                                                                                                        |
| 22    | 45                                                           | Abzüglich BAV-Förderbetrag (§100 EStG)                                                                                                              |
| 23    | 48                                                           | **Verbleiben** (computed)                                                                                                                           |
| 24    | 49                                                           | **Solidaritätszuschlag**                                                                                                                            |
| 25    | 47                                                           | Pauschale Kirchensteuer im vereinfachten Verfahren                                                                                                  |
| 26    | 61                                                           | **Evangelische Kirchensteuer**                                                                                                                      |
| 27    | 62                                                           | **Römisch-katholische Kirchensteuer**                                                                                                               |
| 28-32 | 63-78                                                        | Land-specific lines (Alt-Katholisch 63, Israelitisch/Jüdisch 64, freireligiös 65-67, Arbeitnehmerkammer Bremen 68, Arbeitskammer Saarland 70, etc.) |
| 33    | 83                                                           | **Gesamtbetrag** (negative = refund)                                                                                                                |
| 35    | 29                                                           | Verrechnung des Erstattungsbetrags erwünscht                                                                                                        |
| 36    | 26                                                           | SEPA-Lastschriftmandat widerrufen für diesen Zeitraum                                                                                               |
| 37    | 23                                                           | Ergänzende Angaben flag                                                                                                                             |

Periods and due date: see `vat-payroll-deadlines.md`. The checklist can only transcribe amounts the user's payroll produced; do not compute Lohnsteuer.

## Gewerbesteuer and Körperschaftsteuer forms (gap)

No German KSt 1, Anlage GK, Anlage ZVE or GewSt 1 A Kz table was retrieved (the FMS could not be fetched headlessly; the ELSTER help page was truncated at 100,000 of 195,477 characters; the Gewerbesteuer help returned navigation only). §35 data sit in Anlage G Z51 to Z57 (see `elster-est-forms.md`). For a small GmbH/UG the corporate return is: KSt 1 (cover), Anlage GK from the Jahresüberschuss with adjustments, Anlage ZVE, a separate Gewerbesteuererklärung (GewSt 1 A) and an E-Bilanz XBRL transmission. Read the BMF/ELSTER forms before shipping a GmbH checklist; until then show GmbH checklists as "amounts only, form lines to be confirmed".
