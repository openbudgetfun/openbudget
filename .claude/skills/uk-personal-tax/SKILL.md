---
name: uk-personal-tax
description: UK Self Assessment preparation for individuals and sole traders for tax years 2025/26 and 2026/27 - income tax bands (England/NI, Scotland, Wales), dividends, savings, Class 2 and 4 NIC, SA103S/SA103F self-employment, SA102, SA105 property, SA106 foreign and the FIG regime, SA108 capital gains, pension and Gift Aid relief, HICBC, student loans, payments on account, penalties and interest, Making Tax Digital for Income Tax, and the SA100 box-by-box checklist. Load before touching openbudget_core/lib/src/tax/gb/ individual or sole-trader logic, any SA box mapping, MTD quarterly updates, or HMRC deadline, penalty or interest code.
---

# UK personal tax: Self Assessment preparation

OpenBudget prepares a UK individual's or sole trader's Self Assessment figures and shows a box-by-box checklist. The user reviews and submits the return themselves; the app never files. This skill gives the rules an implementation must not get wrong for 2025/26 (return due 31 January 2027) and 2026/27 (current year).

Today is 5 November 2026. The October 2026 Budget (Budget 2026) changes are announced, not enacted.

## When to use

- Changing `GbTaxYearRates`, `computeGbIncomeTax`, `GbTaxRules` individual or sole-trader reports, `gb_categories.dart`, or `GbTaxProfile`.
- Adding or mapping SA100, SA103S/F, SA102, SA105, SA106, SA108, SA110 boxes, or any "what to type into HMRC" checklist.
- Adding reliefs (pension, Gift Aid, Marriage Allowance, Blind Person's Allowance), HICBC, student loans, payments on account, deadlines, penalties, interest, or MTD ITSA quarterly updates.
- Adding 2027/28 or any later year. Corporation tax, PAYE and VAT are other skills: company profits are in `uk-company-tax`; payroll and VAT are in `uk-vat-payroll`.

## Source-of-truth rules

- Amounts are integers in pence; rates in basis points or exact decimals. No `double`. The pack already follows this (`gb_rates.dart`).
- Rates, bands, thresholds, allowances, mileage rates, interest rates and penalty parameters are **versioned per-tax-year rule data** in `openbudget_core/lib/src/tax/gb/`, each year a separate `GbTaxYearRates` row keyed by `startYear`. Never inline them in UI or server code, and never reuse a year's row for the next year.
- **Announced-not-enacted figures never enter a live year row.** 2027/28 changes change structure (savings and property rates, ordering rule, trading allowance), not only values: keep them in a separate announced data set, labelled as such, until Finance Act text exists, then build a new year row.
- Interest rates and the penalty regime are dated tables read from configuration, with an effective date per row. The 7.75% late-payment rate is a snapshot (Bank Rate + 4%) and goes stale.
- SA box maps are keyed by `(taxYear, form, page, section, box)` and re-verified each April when HMRC publishes the new forms. Keep the online label next to the box number: online filing shows labels, not numbers.
- Tag every figure in data and docs: **primary** (read in an official source), **secondary**, **inferred**. Do not present secondary or inferred values as settled. Each reference file below carries the URLs.
- Where the HMRC payroll-specification findings and the earlier Self Assessment notes disagree, the payroll findings win (see Corrections in `references/rates-and-allowances.md`).

## Core rules

1. **Stack order.** Non-savings income first, then savings, then dividends. The Personal Allowance (PA) is set against non-savings first, then savings, then dividends. Bands are measured on income **after** allowances, so the PA is never counted twice. Scottish bands apply only to non-savings income; savings and dividends use UK rates for everyone. Wales is 20/40/45 as England in both years (secondary source; Welsh rates held at 10p per band).
2. **PA taper.** Lose 1 of PA per 2 of adjusted net income over 100,000; nil at 125,140. In the taper zone a higher-rate taxpayer faces an effective 60% marginal rate (inferred: 40% plus the lost allowance). Pension and Gift Aid gross payments reduce adjusted net income.
3. **Savings.** Starting rate 0% on up to 5,000 reduced pound for pound by taxable non-savings income. Personal Savings Allowance 1,000 (basic-rate), 500 (higher-rate), nil (additional-rate). Dividend allowance 500 still consumes band space. Dividend rates 8.75/33.75/39.35% in 2025/26 and 10.75/35.75/39.35% in 2026/27.
4. **Rounding.** The pack rounds taxable income down to whole pounds and each band slice down to the penny. HMRC's exact slice rounding was not verified from a primary source; keep the rule in one place and state it in tests. The paper-form display convention is whole pounds, income rounded down, expenses and tax paid rounded up.
5. **Class 4 and Class 2.** Class 4 is 6% between 12,570 and 50,270 and 2% above, both years, on combined profits after loss relief, not reduced by pension or Gift Aid. Compulsory Class 2 is abolished: profits at or above the Small Profits Threshold (6,845 / 7,105) are treated as paid; below it only a voluntary flag is needed, with the 31 January 2027 payment deadline. Exempt people (State Pension age, under 16, non-resident) tick SA103F box 101 / SA103S box 37.
6. **Self-employment.** SA103S if turnover under 90,000 and no adjustments; SA103F otherwise. Cash basis is the default; tick traditional accounting only if used. Trading allowance (1,000; announced 3,000 from 6 April 2027) is an alternative to expenses, cannot create a loss, and excludes capital allowances and sideways loss relief. Simplified expenses: 2026/27 mileage 55p to 10,000 miles then 25p; home-use flat rates 10/18/26 a month. The capital-allowance, loss and basis-period rules are in `references/income-sources.md`. In SA103F, capital allowances are inside box 64 and the trading allowance is deducted later at box 73; total taxable profit is box 76.
7. **Reliefs.** Relief-at-source pension: enter the **gross** amount (net / 0.8) in SA100 TR 4 box 1; it extends the basic-rate band and reduces adjusted net income. Net-pay contributions are not entered. Annual allowance 60,000 with taper and 3-year carry forward. Whether Gift Aid TR 4 box 5 wants net or gross is unverified: check the SA150 note.
8. **HICBC.** 1% of Child Benefit per 200 of adjusted net income over 60,000, fully repaid at 80,000; charge falls on the higher earner. Box 1 counts Mondays (52 in 2025/26, 53 in 2026/27). Rounding of the percentage is unconfirmed.
9. **Student loans.** 9% above the plan threshold (6% postgraduate), SA110 box 3 and 3.1 round **down to whole pounds**, and box 3 applies only if TR 5 student-loan box 1 is ticked. Plan 4 2025/26 is 32,745 (the SA110 notes' 31,395 is stale). A person can have an undergraduate plan and a postgraduate loan together. The income base excludes pension relief and part of unearned income; see `references/rates-and-allowances.md` section 9.
10. **Property.** Residential finance costs are not deducted: enter the total in SA105 box 44 and show the 20% credit separately (SA110 working sheet). Property allowance 1,000 excludes expenses. FHL regime abolished from 5 April 2025. Property losses carry forward against property profits only.
11. **Payments on account.** Two instalments of 50% of last year's **Income Tax plus Class 4** net of tax at source, due 31 January and 31 July; not needed under 1,000 or over 80% at source. They do not cover CGT, student loan, HICBC or Class 2. The balance due on the 31 January is **not** the base for the instalments. The reduction boxes (10, 11, 17) are on the SA110 summary, not SA100 TR 6.
12. **Penalties.** The 2025/26 return uses the current regime (100, then 10 a day to 900, then 5% or 300 at 6 and 12 months; 5% late-payment at 30 days, 6 months, 12 months). The points-and-percentage regime starts per taxpayer from the year they join MTD ITSA and for everyone from April 2027; which regime a non-MTD filer's 2026/27 return uses is ambiguous, so model it as dated per-taxpayer configuration.
13. **MTD ITSA limitation.** A prepare-only app cannot satisfy MTD ITSA for a mandated user. Updates and the final declaration must be sent to HMRC through MTD-compatible software; no GOV.UK web form for hand-keyed updates was found or checked. The app can hold digital records, export cumulative per-category totals by update period for a digital link into bridging software, and warn on deadlines (next: 7 November 2026, 7 February 2027, 7 May 2027). Thresholds: over 50,000 from 6 April 2026; over 30,000 from 6 April 2027; over 20,000 from 6 April 2028. Tell the user this plainly. See `references/payments-penalties-mtd.md`.
14. **Flag, do not compute.** FIG regime claims, non-residence, split year, chargeable event gains, trust income, partnership, SA101 beyond a few fields: show "needs manual review". A FIG claim removes the PA, Blind Person's and Marriage Allowance and the CGT exempt amount.
15. **Guardrails.** Output is guidance for the user to review and submit, not regulated advice; include the disclaimer already used in the app. Say what the figures exclude (income held elsewhere, reliefs not modelled). Never claim a return is correct or complete. Do not send personal or tax data to a third party without the privacy design the repo requires.

## Where it lives in OpenBudget

- `openbudget_core/lib/src/tax/gb/gb_rates.dart`: `GbTaxYearRates`, `gbRatesByStartYear` (2025 and 2026), `GbStudentLoanTerms`, `gbRateSources`, `gbRulesVerifiedOn`. Add a year here; do not branch in code.
- `gb_income_tax.dart`: `computeGbIncomeTax` (stack, PA taper, starting rate, PSA, dividend allowance).
- `gb_tax_rules.dart`: `GbTaxRules` reports, assumptions and opportunities (trading allowance, director split, payments on account note, VAT threshold watch). `gb_categories.dart`: category codes and `reportReference` strings. Tests: `openbudget_core/test/tax/gb/`.
- Tax contract: `tax_rule_pack.dart`, `tax_model.dart`, `tax_profile.dart` (`GbTaxProfile` has `scottishTaxpayer` and one `studentLoanPlan`). Server: `openbudget_server/lib/src/tax/` (profiles, reports endpoint, `tax_entry_builder.dart`).
- New pure logic (reliefs, HICBC, payments-on-account schedule, penalty and interest calculators, MTD period calendar, box maps as versioned data) belongs in `openbudget_core/lib/src/tax/gb/` as new files, with no Flutter dependency. Persistence and endpoints go in `openbudget_server/lib/src/tax/`. Widgets are hook widgets, strings come from `AppLocalizations`, at most one migration per PR, and every user-facing flow needs a Patrol test.
- Known gaps in the current pack versus this research are not modelled yet: pension and Gift Aid band extension, Marriage Allowance and Blind Person's Allowance, property allowance and finance-cost credit, HICBC, SA103S mapping and box 76/73 flow, voluntary Class 2 and Class 4 exemption, BADR, loss carry-forward, MTD calendar. Treat each as new work with its own vectors.

## Testing

- Encode every vector in `references/test-vectors.md` as table-driven unit tests in `openbudget_core/test/tax/gb/`. Assert integer pence with exact equality. State the slice-rounding rule in the test name: vectors list unrounded tax, and the pack's per-slice truncation can differ by 1p per slice.
- HMRC publishes no Self Assessment test vectors; the vectors are self-computed. Cross-check against a real SA302 or HMRC's tax calculation before trusting them, and record the check date.
- Add tests for the cliffs: PA taper boundaries (100,000, 125,140), basic-rate ceiling, starting-rate boundary, PSA tier changes, trading allowance versus expenses, Class 2 threshold, 31 January and 31 July due-date generation including weekends, MTD period and deadline calendar for standard and calendar periods.
- Rule-data tests: every year row has sources and a verified-on date; no 2027/28 value appears in a 2026/27 row.
- Run `melos run test` and `melos run analyze` before committing.

## Unverified and changing

Re-check on **30 January 2027** (before the 2025/26 deadline), on Finance Bill 2026-27 publication, and in **April 2027** when the 2026/27 forms appear.

- Announced, not enacted: savings and property rates 24/44/49% from 6 April 2027; ordering rule; trading allowance 3,000 and reporting threshold; BADR limit 500,000 and Founders' Relief; mileage 35p over 10,000; 2027/28 allowances (Class 2, Blind Person's, Married Couple's, Child Benefit); Child Benefit overpayment offset against HICBC; duty to correct errors (April 2028); employment-expenses threshold removal (April 2028); payments-on-account reform (April 2029); no points for 2027/28 quarterly updates; extra MTD exemptions. The exact Budget date (28 October is inferred) and the finance-cost relief rate under Budget 2026 are not stated in the sources read.
- 2025/26 forms only: all box numbers. SA103F boxes 3 to 5, 11 to 12, 61, 63, 66 to 67, 69 to 70; SA106 columns A to F; SA101 full map; SA109 boxes 11 to 60; SA110 summary boxes 14 to 16 purpose; SA110 form PDF not opened.
- Welsh primary rate table and the Welsh 2027/28 position; Scottish 2027/28 property or savings rates.
- Gift Aid box 5 net or gross; HICBC percentage rounding; student-loan unearned-income threshold mechanics; HMRC's per-slice rounding; adjusted-net-income definition (inferred).
- Interest rate of 7.75% (and any Bank Rate change after 30 September 2026); day-count basis; interest on late payments on account.
- Which penalty regime applies to a non-MTD filer's 2026/27 return; MTD 20,000 threshold under Budget 2026; MTD digital-link rules for ITSA; whether HMRC offers any manual quarterly-update route; API field validation (OpenAPI schemas were not retrievable).
- Married Couple's Allowance income limit conflict (39,200 table versus 40,600 narrative); employee homeworking deduction removal status.
- Class 4 for people who also have Class 1 earnings (annual maximum) was not researched.

## References

- `references/rates-and-allowances.md`: bands, allowances, NIC, CGT, pensions, HICBC, student loans, simplified expenses, announced 2027/28 changes, corrections.
- `references/income-sources.md`: SA103 rules, cash basis, trading allowance, capital allowances, losses, SA102, SA105, SA106, FIG, SA108.
- `references/payments-penalties-mtd.md`: deadlines, payments on account, penalties (old and new), interest table, MTD ITSA rules, limitation, API shape.
- `references/sa-box-map.md`: box-by-box map for SA100 (TR 1 to TR 8), SA103S, SA103F, SA110 and pointers to SA102/105/106/108.
- `references/test-vectors.md`: fifteen worked examples with expected outputs and suggested property tests.
