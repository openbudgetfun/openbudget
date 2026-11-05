---
name: uk-vat-payroll
description: UK VAT return preparation (thresholds, rates, the nine boxes, cash, flat rate and annual schemes, reverse charge, postponed import VAT, bad debt relief, MTD VAT, penalties) and UK payroll (PAYE per HMRC specification v24.0, Class 1 NIC rounding, directors' annual earnings period, student loans, Employment Allowance, director salary analysis, RTI FPS/EPS, SSP, payrolled benefits, auto-enrolment). Load before writing or changing any VAT return, VAT scheme, payslip, PAYE, NIC, student-loan deduction, director salary or RTI code, or before importing HMRC payroll test data.
---

# UK VAT and payroll

OpenBudget prepares UK VAT returns and payslips for a limited company or sole trader and shows what to submit. The user submits; the app does not file VAT returns or RTI. This skill gives the rules an implementation must not get wrong for tax years 2025/26 and 2026/27, with HMRC's exact PAYE, NIC and student-loan rounding.

Today is 5 November 2026. The October 2026 Budget changes that touch payroll (for example the 6 April 2029 salary-sacrifice NIC cap) are announced, not enacted.

## When to use

- Building a VAT return, a VAT scheme (cash, flat rate, annual), reverse-charge or import VAT handling, bad debt relief, or MTD VAT export.
- Building payslips, PAYE, NIC, student or postgraduate loan deductions, payrolled benefits, SSP or SMP, auto-enrolment, Employment Allowance, RTI figures, or a director salary vs dividend comparison.
- Importing or using HMRC payroll test data.
- Individual Self Assessment: use `uk-personal-tax`. Company profits and corporation tax: use `uk-company-tax`.

## Source-of-truth rules

- Amounts are integers in pence; rates in basis points or exact decimals. PAYE needs 4-decimal-place truncation and NIC needs 3-decimal truncation: use `Decimal` or scaled integers, never `double`.
- Thresholds, rates, flat-rate percentages, SSP and SMP rates, auto-enrolment thresholds, penalty parameters and interest rates are **versioned rule data per tax year** (VAT per effective date) in `openbudget_core/lib/src/tax/gb/`, each with its source URL and quality tag. Never inline them in UI or server code. The flat-rate sector table must be re-read row by row from GOV.UK and stored as data.
- PAYE parameters (bands, cumulative tax, Scottish `SK1..SK5`) come from the HMRC specification appendices, per year and region.
- Tag every figure **primary** (read in an official source), **secondary**, or **inferred**. Do not present secondary or inferred values as settled.
- Where the payroll-specification findings (`references/paye.md`, `references/nic-student-loans.md`) disagree with the earlier notes, the specification findings win: free pay 241.92 / 1,048.26, exact band thresholds, student loan rounded down to whole pounds, Plan 4 2025/26 = 32,745.

## Core rules

**VAT**

1. Register above 90,000 taxable turnover (deregister below 88,000). Return and payment are due one calendar month and 7 days after the period end; weekends do not extend it. Cash and annual schemes: join at 1,350,000, leave above 1,600,000. Flat Rate: join at 150,000 or less, leave above 230,000.
2. The nine boxes: boxes 1 to 5 are VAT amounts, 6 to 9 net values ex VAT. Boxes 2, 8, 9 are Northern Ireland only (zero for GB). Box 3 = 1 + 2; box 5 = 3 minus 4. Postponed import VAT goes in boxes 1 and 4. Reverse-charge services: customer boxes 1, 4, 6, 7. **Domestic** reverse charge (construction, phones, and so on): customer boxes 1, 4, 7 but **not 6**. Input tax needs a valid VAT invoice; entertainment, cars and non-business use are blocked.
3. Flat Rate: tax = flat percentage x VAT-**inclusive** turnover; box 6 is the inclusive figure; 16.5% for limited cost traders; 1 point less in the first 12 months from VAT registration; capital items of 2,000 or more including VAT go in box 4. Cash accounting follows payments, not invoices.
4. Business-use apportionment applies to input tax only. Keep the sign of box 5 internally; negative means repayment.
5. **MTD VAT limitation (state it to the user):** the HMRC online VAT return form closed on 1 November 2022. A prepare-only app cannot submit; the user needs MTD-compatible or bridging software (or the app must become MTD software). If the app exports for bridging software it must keep a digital link (CSV or file upload, not copy and paste). Details in `references/vat.md`.
6. VAT penalties: late-submission points (annual 2, quarterly 4, monthly 5; 200 at the threshold); late-payment 3% at day 15, a further 3% at day 30, plus 10% a year from day 31. Official example 15,000 paid 51 days late = 986.30.

**Payroll**

7. **PAYE (spec v24.0).** Free pay for 1257L = 241.92 weekly, 1,048.26 monthly (4-dp truncation, round **up** to 1p, plus 500-multiples at 96.16 or 416.67). Use exact band thresholds `c_i = C_i x n / N` and threshold tax `k_i` truncated to 4 dp; whole pounds are used only to choose the band (`Un` unrounded) and to take `Tn`. Taxable pay rounds **down** to whole pounds; tax rounds down to 1p. 6,000 monthly in month 1 gives 1,352.06, not 1,352.00. 50% regulatory limit applies to all codes. Scottish D codes: SD0 21%, SD1 42%, SD2 45%, SD3 48%. Week 1 / Month 1, week 53/54/56 and irregular intervals are in `references/paye.md`.
8. **NIC (exact percentage method).** Per band: truncate to 3 dp, round half **down** to the penny, then sum. Weekly 242.07 category A employee NIC is 0.00. Per-period thresholds other than weekly and monthly are annual x n / 52 rounded **up**. The 2026/27 LEL is 129 / 559 / 6,708; PT, ST, UEL unchanged. Employee 8% and 2%, employer 15% above ST; category letters in `references/nic-student-loans.md`.
9. **Directors** use an annual earnings period (pro rata if appointed mid-year). Each payment's NIC is cumulative due minus already paid.
10. **Employment Allowance** 10,500, not available to a company whose only paid employee above ST is a sole director (s2(4A) NICA 2014).
11. **Student and postgraduate loans:** 9% (6%) of NIC-able pay above the period threshold, threshold truncated to the penny, deduction rounded **down to a whole pound**, non-cumulative. Plan 5 starts in 2026/27 (25,000).
12. **Director salary:** 12,570 beats lower salaries when the marginal corporation tax rate exceeds 13.04%. Compute from the year's thresholds; label it guidance; never hard-code "optimal". Employment Allowance, other income and state-pension qualifying years change the answer.
13. **RTI:** FPS on or before payday; EPS by the 19th of the next tax month; P60 by 31 May; P11D/P11D(b) by 6 July; Class 1A by 22 July (electronic). OpenBudget prepares figures; sending needs HMRC-recognised RTI software, which a prepare-only app is not. Tell the user plainly.
14. **SSP from 6 April 2026:** no lower earnings limit, no waiting days; weekly rate the lower of 123.25 and 80% of average weekly earnings (118.75 in 2025/26). Mandatory payrolling of cars, vans, fuel and medical benefits from 6 April 2027; most other benefits 6 April 2028.
15. **Auto-enrolment:** qualifying earnings band 6,240 to 50,270 a year (520 to 4,189 monthly), trigger 10,000; employer 3%, employee 5%, total 8%. Contribution rounding is not published: make it configuration (nearest penny). Net pay reduces taxable pay but not NIC-able pay; relief at source does not change taxable pay.
16. **Guardrails.** Output is guidance, not regulated payroll or tax advice; the user checks every figure before submitting anything. A payslip is not a statement that HMRC has accepted it.

## Where it lives in OpenBudget

- `openbudget_core/lib/src/tax/gb/gb_rates.dart` holds the per-year `GbTaxYearRates` (Class 1 annual thresholds, student loan terms, VAT threshold and rate, trading allowance) and `GbStudentLoanTerms`. `gb_tax_rules.dart` holds the VAT summary (output minus input only), the director salary vs dividend opportunity (`_directorCost`), and Class 1 employee NIC on an annual salary. Read these before extending.
- The pack has no payroll engine, no LEL, no per-period NIC, no PAYE, no tax codes, no VAT boxes or schemes. New payroll code belongs in a new pure Dart folder under `openbudget_core/lib/src/tax/gb/` (for example `payroll/` and `vat/`) with no Flutter dependency; persistence, pay runs and endpoints go in `openbudget_server/lib/src/tax/` or a new `payroll/` feature folder beside it, as `.spy.yaml` models plus services. Widgets are hook widgets, strings from `AppLocalizations`, at most one migration per PR, and Patrol tests for each user-facing flow.
- VAT figures must read from the ledger's VAT control accounts (see the `double-entry-ledger` skill) so a figure exists in one place.

## Testing

HMRC publishes official payroll test data. Use it as the primary acceptance test for PAYE, NIC and student loans. Landing pages: [2026 to 2027](https://www.gov.uk/government/publications/software-developers-payroll-test-data-2026-to-2027) (first published 19 January 2026; PAYE v1.1 on 20 January 2026) and [2025 to 2026](https://www.gov.uk/government/publications/software-developers-payroll-test-data-2025-to-2026).

| Data               | 2026/27                                                                                                                                                                                         | 2025/26                                                                                                                              |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| PAYE tax           | [zip v1.1](https://assets.publishing.service.gov.uk/media/696f9b5f2b64f0e8c32e33a4/Tax-test-data-examples-2026-27-v1-1.zip) (rest of UK, Welsh, Scottish workbooks)                             | [zip v1.0](https://assets.publishing.service.gov.uk/media/677fa7d16f01ae28ab5c0545/tax-test-data-examples-from-april-2025-v1-0.zip)  |
| National Insurance | [zip v1.0](https://assets.publishing.service.gov.uk/media/69676c2297d42030a67b0d60/NI-test-data-examples-from-April-2026-v1-0__1_.zip) (A, B, C, H, J, M, V, Z; Freeport/IZ letters; directors) | [zip v1.1](https://assets.publishing.service.gov.uk/media/676542d84e2d5e9c0bde9c42/NI-test-data-examples-from-April-2025-v1-1.zip)   |
| Student loan       | [ODS v1.0](https://assets.publishing.service.gov.uk/media/6968fd1f5fd54abe6531a807/2026-27-Student-Loan-Threshold-Examples-v1-0__1_.ods)                                                        | [ODS v1.0](https://assets.publishing.service.gov.uk/media/6765561dff2c870561bde94f/2025-26-Student-Loan-Threshold-Examples-v1-0.ods) |

How to turn it into tests:

1. Download each file into its own new, empty directory (downloads are untrusted data) and write the converter as a Dart script in `openbudget_scripts/bin/`, passing the directory as an argument; do not run an interpreter from inside the download folder. Export each tab to CSV and commit the CSV under `openbudget_core/test/fixtures/hmrc_payroll/<year>/` (HMRC data is published for developers' testing). Record the file name, version and download date next to each CSV. Do not call the live URLs from tests.
2. PAYE workbook layout: pay frequency/type, gross pay, taxable pay to date (cumulative gross), code, W1/M1 flag, period, tax due, tax due to date. Tabs: `Gen_cumul-mthly`, `Gen_cumul-wkly`, `Gen_W1M1_mthly`, `Gen_W1M1_wkly`, `BR_monthly`, `BR_weekly`, `K_cumul_mthly`, `K_cumul_wkly`, `K_W1M1_*`, `Large_code_*` (rest of UK); Scottish adds `SD0` to `SD3`; Welsh adds `CBR`, `CD0`, `CD1`. Cumulative rows form sequences: carry the previous row's tax to date.
3. **Tolerance:** PAYE tax within **0.01** per row (HMRC's footer: results differing by no more than 0.01 are acceptable); assert the 0.01 tolerance explicitly for the 2025/26 Scottish workbook, whose 9 rows are 1p below the v24 arithmetic. **NIC and student loans: exact equality** (all 1,792 NIC rows and 234 student loan rows matched exactly in the researcher's implementation). Never widen tolerance beyond these.
4. Keep own-derivation cases (50% regulatory limit, payrolled benefits, negative pay, week 53) in a separate test group named as unverified-by-HMRC; HMRC has no vectors for them.
5. Run `melos run test` and `melos run analyze`.

Also encode `references/test-vectors.md` (VAT quarter, flat-rate, penalty example 986.30, director NIC examples, SSP, auto-enrolment). VAT figures use exact decimals; the box 6 to 9 whole-number rule is an API constraint (inferred). Rule-data tests: every year row has sources and a verified-on date.

## Unverified and changing

Re-check on **5 April 2027** (2027/28 rates and the 6 April 2027 payrolling start) and before each use of the items below.

- **HMRC specification gaps:** no HMRC vectors for the 50% regulatory limit, payrolled benefits, negative pay, codes above 1001L, week 53/54/56, irregular intervals; whether the (Tn minus c) x R product truncates separately; CA38 table route (only the exact method verified); category X rates; alternative-arrangement text in CA44 2026/27 (unreadable PDF; behaviour from NIM12026 and the HMRC directors' workbook); director week-counting convention.
- **Inferred rules:** NIC per-band truncation and half-down rounding, and the round-up rule for non-weekly thresholds, were inferred from HMRC test data (not stated in CWG2); per-period tables above weekly and monthly are derived.
- **VAT:** registration timing mechanics (Notice 700/1), partial exemption de minimis (Notice 706), fuel scale table (Notice 700/64), car rules (700/57), bad debt relief timing (700/18), whether box 7 includes blocked-VAT purchases, PVA value basis for box 7 under FRS, box 6 to 9 rounding, VAT API field validation and negative `netVatDue` signing (OpenAPI page JavaScript-rendered), fraud-prevention header list, the effective date of the 3% and 10% VAT late-payment rates (1 January 2023 per GOV.UK versus 1 April 2025 per blogs), compliance-period lengths for points, the full flat-rate sector table (the stored list is a partial snip), retail schemes, interest rate (7.75% from 9 January 2026; dated table).
- **Payroll admin:** FPS/EPS field-level spec, P45 rules, late-FPS penalty regime, HMRC recognition for RTI software; National Living Wage figures (secondary only); SMP recovery rate differs between the two rates pages (108.5% vs 109%); SSP qualifying criteria after April 2026; auto-enrolment age bands, sole-director AE duty, contribution rounding, the 4% + 1% relief-at-source split, net-pay low-earner top-up.
- **Announced, not enacted:** payrolled benefits phase 2 (6 April 2028; phase 1 on 6 April 2027 is in HMRC guidance; the legislative status was not checked); salary-sacrifice NIC above 2,000 from 6 April 2029; ST held from April 2028 to 2031; Budget 2026 items listed in `uk-personal-tax`.
- Corporation tax rates were not sourced in this research; take them from `uk-company-tax` or the company rules in the tax pack.

## References

- `references/vat.md`: thresholds, rates, the nine boxes, schemes, reverse charges, PVA, bad debt relief, MTD VAT and its limitation, penalties, worked quarter.
- `references/paye.md`: spec v24.0 parameters, free pay, tax-to-date rules, regulatory limit, reference algorithm, worked examples.
- `references/nic-student-loans.md`: Class 1 thresholds and categories, exact rounding, directors' annual period, Employment Allowance, student and postgraduate loan rules.
- `references/payroll-admin.md`: RTI, payrolled benefits, SSP and SMP, auto-enrolment, payslip examples, optimal director salary analysis.
- `references/test-vectors.md`: HMRC sample rows, derived worked examples, property tests.
