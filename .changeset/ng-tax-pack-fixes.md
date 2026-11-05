---
openbudget_core: fix
openbudget_app: fix
---

# Correct the Nigeria tax rule pack and add the 2025 old-regime year

- Add the 2025 year of assessment under the repealed PITA and CITA regime: the PITA progressive bands (7% to 24%) after the consolidated relief allowance, the 1% minimum tax where it exceeds the progressive tax, CITA turnover tiers of 0%, 20% and 30% with the 3% tertiary education tax, and the old N25,000,000 VAT registration threshold. The regime follows the year of assessment, and every 2025 figure is marked secondary-sourced in the report assumptions because the repealed Act texts were not read.
- Apply the 15% minimum effective tax rate trigger correctly (NTA s.57): aggregate turnover of N20bn or more, or membership of a multinational group, not the previous N50bn / EUR 750m wording.
- Make the small-company turnover ceiling a profile choice between the conflicting statutory figures (N50m in the Nigeria Tax Act gazette, N100m in the Administration Act) and always explain the conflict in the company report whenever turnover falls between the two.
- Correct the VAT category descriptions: medical services are zero-rated (s.187), land and buildings are exempt (s.186); excess input VAT is carried forward as a credit or refundable on request (s.156(1)-(2)).
- Treat foreign dividend, interest, rent and royalty brought in through approved channels as exempt (s.163(1)(s)) with dedicated out-of-scope categories.
- Remove an unverifiable claim that a Presidential Order can cut the 30% companies income tax rate; the gazette shows only 0% and 30%.
- Align statute citations with the gazette research and mark unverified section numbers as unverified instead of citing them.
- `NgTaxProfile` gains `smallCompanyCeiling` and `mneGroupMember` (JSON round-tripped with defaults for stored profiles); the tax profile form asks both questions with new localised strings.
