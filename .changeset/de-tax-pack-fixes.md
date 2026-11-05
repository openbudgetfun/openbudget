---
openbudget_core: fix
openbudget_app: fix
---

# Fix the German tax rule pack

- Filing deadlines roll forward to the next working day under § 108 Abs. 3 AO (VZ 2025 advised: 1 Mar 2027; VZ 2026 self-filers: 2 Aug 2027) and the Art. 97 § 36 Abs. 3 EGAO transition deadlines are honoured.
- Kirchensteuer takes the Bundesland from the tax profile (8 % in Bayern and Baden-Württemberg, 9 % elsewhere); profiles saved with only the old flag keep the 9 % assumption.
- Joint assessment gives each employed spouse their own Arbeitnehmer-Pauschbetrag and their own Anlage N, doubles the Basisrente Höchstbetrag, and subtracts statutory pension contributions from the Basisrente headroom.
- Children add Kinderfreibeträge with the Kindergeld Günstigerprüfung, and Solidaritätszuschlag and Kirchensteuer are computed on the tax recalculated with Kinderfreibeträge (§ 3 Abs. 2 SolzG, § 51a Abs. 1 EStG).
- Sole traders declare Freiberufler (Anlage S, no Gewerbesteuer, no § 35 credit) or Gewerbetreibender (Anlage G, Gewerbesteuer with the § 35 credit) in the profile.
- The Kleinunternehmer test now checks prior-year turnover of at most €25,000 and current-year turnover of at most €100,000 (§ 19 UStG from 2025), instead of the current year against €25,000.
- Homeoffice claims are capped at €6 per day and €1,260 per year in whole days, a separate Arbeitszimmer category exists, and the two claims exclude each other because they may not overlap in time.
- Company report lines reference Anlage GK and Anlage ZVE instead of KSt 1, the Homeoffice line cites Anlage N Z58/Z59 (Kz 335/336) versus Arbeitszimmer Z57 (Kz 325), and German categories carry their ELSTER Kennzahlen keyed by (form, year, section, Kz).
- The Entfernungspauschale is an Anlage N profile input computed from the year's schedule (2025 tiered 0.30 to km 20 then 0.38, 2026 flat 0.38 from km 1, capped at €4,500).

All tax arithmetic stays in integer cents; every new figure is versioned per year with a source comment.
