---
name: nigeria-tax
description: Nigerian tax under the Nigeria Tax Act 2025 (NTA) and Nigeria Tax Administration Act 2025 (NTAA), in force from 1 January 2026, plus the old regime (PITA, CITA, VATA) that still governs income and supplies of 2025. Covers which law applies to which year, personal income tax bands and section 30 deductions (rent relief), minimum-wage exemption, PAYE via state IRS, sole proprietors, 30% CIT, the small-company threshold conflict (N50m NTA vs N100m NTAA), 4% development levy, minimum ETR, VAT 7.5% with zero-rated and exempt items, input VAT recovery, monthly VAT return by the 21st, NRS e-invoicing (MBS), WHT, capital gains, digital assets, TIN, penalties and interest, residency and the UK treaty. Load before touching openbudget_core/lib/src/tax/ng/ or any Nigerian tax figure, return or deadline.
---

# Nigeria tax

OpenBudget prepares Nigerian returns for individuals, sole proprietors and small limited companies and shows a checklist; the user reviews and files (the app never files). Nigeria's tax system changed on 1 January 2026, and the two laws and their effective dates are the main trap.

Today is 5 November 2026. The year of assessment is the calendar year, 1 January to 31 December. Amounts are naira (N), stored as integer kobo (N1 = 100 kobo).

## When to use

- Editing `NgTaxRules`, `_NgTaxTable`, Nigerian categories or reports, or any Nigerian rate, band, threshold or deadline.
- Adding the 2025 (old-regime) tax year, PAYE or employer returns, rent relief, minimum-wage exemption or residency logic.
- Adding VAT returns, input-VAT recovery, e-invoicing (NRS MBS), WHT credit notes or withholding.
- Handling capital gains, digital assets, foreign income, the UK treaty, TIN or penalty and interest calculators.
- Anything that says "which tax year does this transaction belong to".

## Source-of-truth rules

- Integer kobo, no `double`, rates in basis points. Every threshold, rate, band, penalty, deadline and e-invoicing date is versioned data per tax year in `openbudget_core/lib/src/tax/ng/` with a source URL and a quality tag, never inline in UI or server code.
- Quality tags: **P** primary (gazetted NTA or NTAA text read in the research), **P-snip** (official page seen only through a search summary), **S** secondary (law-firm, Big Four, press, adviser), **I** inferred (my computation or reading), **K** general knowledge not read. Never present S, I or K as settled.
- Section numbers are as printed in the gazette. Other sources use different numbers; cite the gazette. Gazette copies: NTA https://www.lirs.gov.ng/assets/docs/Gazette%20-%20NIGERIA%20TAX%20ACT,%202025.pdf (also https://www.nrs.gov.ng/uploads/NIGERIA_TAX_ACT_2025_ef6bb812a5.pdf); NTAA https://tat.gov.ng/Nigeria-Tax-Act-2025.pdf (the file names on that host are swapped: the file called Nigeria-Tax-Act-2025.pdf is the NTAA).
- Keep **basis period** (the income period) and **filing year** as separate fields. Do not hard-code "year of assessment = income year" (see Core rule 1).
- A threshold that two laws define differently is a per-tax configurable parameter with a visible warning, not a constant (small company, WHT small-supplier test, VAT small business).
- Reports carry `rulesVerifiedOn` and the sources; every `S`/`I`/`K` item carries a "verify" flag in the UI.

## Core rules

1. **Which law applies.** NTA in force 1 January 2026 (s.203); it repeals CITA, PITA, CGTA, VATA, PPTA, the Stamp Duties Act and others (s.196). The June 2026 Transition Guidelines (S, law-firm summaries; text not read) decide by basis period, not filing date:
   - Income earned in calendar 2025 and filed in 2026: old law (PITA bands, CRA, 1% minimum tax; CITA tiers). Individual returns for 2025 were due 31 March 2026.
   - Income from 1 January 2026: NTA. First individual returns under the NTA are for 2026 income, filed in 2027 (default 31 March 2027, configurable: the gazette gives no date).
   - Companies: a basis period ending before 1 January 2026 stays under the old law; ending on or after 1 January 2026 goes wholly under the NTA, even if it began in 2025 (30 June 2026 year end is wholly NTA).
   - Goods delivered or services rendered up to 31 December 2025 stay under the old VAT, WHT and stamp duty law whenever paid.
   - Monthly PAYE remittances and final filings for 2025 stay under the old law.
2. **Personal income tax (2026, P).** Chargeable income = total income minus s.30 eligible deductions: NHF, NHIS, Pension Reform Act contributions, interest on a loan to develop an owner-occupied home, life insurance premium/annuity, and rent relief (20% of annual rent, maximum N500,000, only with an accurate declaration of rent paid). Bands: first N800,000 at 0%, next N2.2m at 15%, next N9m at 18%, next N13m at 21%, next N25m at 23%, above N50m at 25%. CRA and the 1% minimum tax no longer exist. Every deduction needs a written claim and documents (ss.31-32): capture a document reference per deduction line.
3. **Minimum wage.** An employee whose gross employment income is at or below the national minimum wage pays nothing (ss.58, 163(1)(t)). The wage amount is configurable data (N70,000 a month is K, not verified); the monthly-vs-annual comparison is unspecified, so show the assumption.
4. **PAYE and returns.** State/FCT internal revenue services administer tax on resident individuals (NTAA s.3(2)). Employers file an annual return by 31 January (NTAA s.14); employees still file their own return from all sources (s.14(3), s.13). Monthly PAYE remittance is commonly by the 10th (S; configurable per state IRS). The form names (Form H1, Form A) are not in the gazette; use "employer annual PAYE return (NTAA s.14)" and let the state portal define the template.
5. **Sole proprietor.** Taxed as an individual on assessable profit (s.20 expenses wholly and exclusively incurred; s.21 non-deductibles), with capital allowances after losses (First Schedule: 10% class 1, 20% class 2, 25% class 3), loss carry-forward against the same trade only (s.28(3)); return can attach "a statement of accounts attested to by the taxpayer" instead of audit (NTAA s.13(2)). The allowance method (straight-line vs reducing balance) is unconfirmed (I): flag.
6. **Companies (2026).** CIT 30% (s.56(b)), 0% for a small company (s.56(a)); no 20% medium tier. **Small company conflict:** NTA definition says gross turnover of N50m or less (fixed assets not above N250m, no professional services); the NTAA "small business" definition says N100m. Officials say N100m is intended and N50m a gazetting error; no enacted correction was found as of 5 November 2026. Store both values, default to the NTA (the law that charges CIT), show a warning for turnover between N50m and N100m, and let the user switch. A professional-services business is never small. Development levy 4% of assessable profits, not for small or non-resident companies (s.59). Minimum ETR 15% only for MNE constituents and companies with aggregate turnover of N20bn or more (s.57).
7. **VAT (P).** 7.5% (s.148). Zero-rated (s.187) includes basic food, medicines and medical products and services, educational books and tuition, exports, fertiliser and farm inputs, medical equipment and electric vehicles. Exempt (s.186) includes land and buildings, money and securities, shared road transport, baby products, assistive devices. Input VAT on any taxable supply, including services and fixed assets, is deductible to the extent used for taxable supplies, apportioned for mixed use, within five years (s.156(5)); excess carries forward or can be refunded on request; zero-rated suppliers may request refund. Monthly return by the 21st of the next month, even if nil (NTAA s.22). Small businesses (turnover N100m or less, fixed assets N250m or less, no professional services) are outside VAT unless they opt in (s.22(4)-(5)).
8. **WHT.** Rates come from regulations, not the NTA (NTAA s.51); the 2024 Regulations rate table (S, via PwC) is assumed to continue. Non-TIN payees pay double. WHT withheld from the user's income is a credit (WHT credit note), not a deduction. Final-tax cases: dividends and short-term-securities or bond interest of individuals after WHT, and non-resident dividends, interest, rent, royalties, directors' fees.
9. **Gains.** No CGT: gains are income (s.28(2)(a)(v) individuals, s.27(1) companies). Digital and virtual assets are chargeable assets, and their losses can offset only digital-asset gains (ss.27(6), 28(3)). Exemptions (s.34, ss.50-54, 163(1)(m)) must be modelled before computing tax: see `references/gains-digital-penalties.md`.
10. **Identity and penalties.** Every taxable person needs a Tax ID; financial institutions must require it for accounts (NTAA s.8(2)). Penalties are fixed monthly amounts; late payment is 10% plus interest at the NRS-published monthly rate since 1 October 2026 (S). Always show the formula and the month-counting assumption.
11. **Residency and foreign income.** Residents are taxed on worldwide income; foreign-source dividend, interest, rent or royalty brought in through approved channels is exempt (s.163(1)(s)); foreign tax credit is the lower of Nigerian tax attributable and foreign tax paid (s.120). UK treaty applies; no Germany treaty found: do not apply treaty rates for Germany.

## Where it lives in OpenBudget

- `openbudget_core/lib/src/tax/ng/ng_tax_rates.dart` (`_NgTaxTable`, `_ngTable2026`, `_ngTables`), `ng_tax_rules.dart` (`NgTaxRules implements TaxRulePack`, `supportedStartYears {2026}`), `ng_individual_report.dart`, `ng_business_report.dart`, `ng_company_report.dart`, `ng_opportunities.dart`, `ng_tax_categories.dart`, `ng_reports.dart`.
- Contract: `tax_rule_pack.dart`, `tax_model.dart`, `tax_profile.dart` (`NgTaxProfile.annualRentMinor`). Tests: `openbudget_core/test/tax/ng/`.
- New code goes in the same folder: a `_ngTable2025` old-regime table and a separate old-regime computation (CRA, minimum tax, CIT tiers, TET), keyed by basis-period end date; small-company thresholds as parameters on the profile or a per-year override; exemptions, FTC and VASP data as additional pure functions. The pack rounds every slice down to a whole kobo (documented in `NgTaxRules`): keep that.
- Pack status as of 5 November 2026 is summarised in `references/personal-and-sole-proprietor.md` and `references/company-and-levies.md` ("Pack status").

## Testing

- Encode every vector in `references/test-vectors.md`; amounts are exact in kobo, no tolerance on tax figures.
- Band boundaries: chargeable income at N800,000, N3m, N12m, N25m, N50m, one kobo either side. Rent relief at N1.2m, N2.5m (exactly the cap), N3m, N0.
- Year tests: 2025 basis period gives old-regime results; 2026 gives NTA; a basis period ending 30 June 2026 gives NTA; an unsupported year throws `UnsupportedTaxYearException`.
- Threshold tests: small company at N50m exactly, N50m plus one kobo, N100m; professional services at N1; VAT small business at N100m; share-disposal exemption at proceeds N150m (strictly less than) and gain N10m (at or below).
- Penalty tests: show formula inputs, month-counting assumption and the interest-rate source; use a placeholder rate only in tests, never in product data.

## Unverified and changing

Re-check dates: before 31 December 2026 for the small-company fix and Transition Guidelines text; before 31 March 2027 for the individual filing date; monthly for the NRS interest rate.

- N50m vs N100m small-company threshold; the announced corrective finance law (April 2026) has no enacted text found.
- Transition Guidelines (issued 18 June 2026) known only through law-firm summaries; the NRS (Establishment) Act text was not read.
- 2025 old-regime figures (PITA bands, CRA, 1% minimum tax, CIT 0/20/30, TET 3%) are S (PwC and others); PITA and CITA text were not read. A claimed "N30,000 a month" minimum tax is unverified and probably wrong.
- Individual filing date for 2026 income (default 31 March 2027, I), PAYE remittance date (10th, S), exact form names, employer return form.
- Capital allowance method (straight-line vs reducing balance), 1% notional carry, development levy base (before or after losses and allowances).
- WHT rates and the N25m / N2m small-supplier exemption (S; the 2024 Regulations PDF was scanned and unread). No NTAA-era WHT regulation found; whether the 2024 rates survive the repeal of CITA/PITA is unconfirmed.
- E-invoicing dates: large taxpayers (N5bn and above) 31 July 2026, medium (N1bn to N5bn) 1 July 2026, small from July 2027 (S, press); one source claims a three-month extension for large taxpayers.
- Interest on late tax: the 2026 Order (MPR plus 1 point, floored at the 364-day T-bill yield; SOFR plus 6 for foreign currency) is S; no published monthly rate was found; day-count basis unknown.
- Virtual-asset guidelines reported as published 31 July 2026 (S); VASP record retention six or seven years (sources differ).
- Month counting for s.100 and s.101 penalties; the credit-claim time limit in ss.121-122; UK treaty rates (10% across the board per PwC vs 10/10/5 per a garbled KPMG table); Germany treaty (none found).
- National minimum wage amount and the monthly-vs-annual test; PRA, NHF and NHIS contribution rates (use user-entered amounts).
- Personal data: store TINs and NINs as sensitive fields, never in logs or analytics.

## References

- `references/law-and-transition.md`: repealed laws, effective dates, Transition Guidelines, basis period vs filing year, residency and foreign income, UK treaty, TIN.
- `references/personal-and-sole-proprietor.md`: 2026 bands, s.30 deductions, exemptions, PAYE and returns, 2025 old regime, sole-proprietor profit and allowances, pack status.
- `references/company-and-levies.md`: CIT, the small-company conflict, development levy, minimum ETR, losses, allowances, filing, 2025 comparison, pack status.
- `references/vat-wht-einvoicing.md`: VAT rate, zero-rated and exempt lists, input recovery, returns, small-business rule, e-invoicing timeline, WHT tables.
- `references/gains-digital-penalties.md`: capital gains, exemptions, digital assets, TIN, penalties, interest order, objections.
- `references/test-vectors.md`: worked examples with expected outputs.
