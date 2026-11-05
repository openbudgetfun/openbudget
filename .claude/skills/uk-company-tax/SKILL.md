---
name: uk-company-tax
description: UK limited company Corporation Tax and statutory accounts for small owner-managed companies (financial years 2025 and 2026). Load before touching `openbudget_core/lib/src/tax/gb/` company code, CT600 or CT600A boxes, marginal relief, associated companies, capital allowances (AIA, full expensing, writing-down, first-year allowances), iXBRL, FRS 105 or FRS 102 1A accounts, Companies House filings, confirmation statements, director's loan accounts, s455 tax, dividend legality or salary-versus-dividend logic.
---

# UK company tax and statutory accounts

OpenBudget prepares UK limited company numbers for a small owner-managed company: Corporation Tax (CT), the CT600 checklist, statutory accounts content, Companies House duties, and the director's loan and dividend rules. It does not file. This skill holds the rules an implementer must not get wrong. Dense tables, URLs and source grades are in `references/`.

Financial years (FY) run 1 April to 31 March and are named by the start year: FY2025 = 1 Apr 2025 to 31 Mar 2026, FY2026 = 1 Apr 2026 to 31 Mar 2027. Research date: 5 November 2026.

## When to use

- Editing company computations or categories in `openbudget_core/lib/src/tax/gb/` (`gb_tax_rules.dart` `_companyFigures` and `_corporationTax`, `gb_rates.dart`, `gb_categories.dart` `gb.co.*`).
- Adding a CT600, CT600A or iXBRL export, an accounts generator, or Companies House reminders.
- Adding director's loan, s455, beneficial-loan or dividend features, or the salary-versus-dividend comparison (`gb.director_salary_vs_dividend`).
- Writing any user-facing text about company tax. Also load `tax-planning-guardrails` if the text suggests an action.

## Source-of-truth rules

- Every rate, limit, threshold and fee is per-FY (or per-tax-year for personal figures) rule data in `openbudget_core`, with `effective_from`, a source URL and a verified-on date. Never inline in UI or server code.
- Money is integer pence. Ratios are exact: marginal relief fraction is 3/200 (150 basis points of the gap), hybrid rates are rational numbers of days. No binary floating point.
- Grade every figure **primary** (read on GOV.UK, HMRC manuals, legislation.gov.uk), **secondary**, or **inferred**. Show announced-not-enacted figures behind an `announced` flag that never feeds a liability.
- GOV.UK's "Director's loans" page is stale on the s455 rate (33.75%). The CT online service notice and CTM61505 say 35.75% for loans from 6 April 2026. Do not copy rates from a page without checking its date.

## Core rules

1. **The unit is the accounting period (AP), not the personal tax year.** A CT AP is at most 12 months. Today's `gb` company report uses the 6 April tax year as the AP; a company year end of 31 December or 31 March does not match it. New code takes explicit AP start and end dates. A longer accounts period (inferred, not sourced) produces two CT periods and two CT600s.
2. **Rates (FY2023 to FY2026, held for FY2027):** 19% up to £50,000, 25% above £250,000, main rate less marginal relief between. [primary]
3. **Marginal relief:** `MR = 3/200 x (U - A) x (N / A)`. `N` is taxable total profits, `A` is augmented profits (N plus exempt distributions from non-group companies), `U` is the upper limit. Tax = `25% x N - MR`. With A = N this is 19% of the lower limit plus 26.5% of the excess.
4. **Limits scale.** Divide both limits by `1 + associated companies` (all companies under common control, counting the subject company) and multiply by `apDays / fyDays` for a short AP. HMRC says use days (CTM03930).
5. **Straddling APs.** Rates and limits are identical across FY2023 to FY2026, so no split is needed today. Build the splitter anyway (days-based apportionment of profits, per-part limits, each part computed separately). The capital allowance hybrid rate uses the same day counts.
6. **Profit adjustments.** Add back depreciation, entertaining and non-allowable items; replace depreciation with capital allowances; never net the two. Customer entertaining and most gifts are not deductible (BIM45000).
7. **Capital allowances.** The AIA is £1,000,000 per AP, pro-rated for short APs, not for cars, shared across companies under common control. Full expensing (100%) and the 50% special-rate FYA are for companies on new and unused plant bought from 1 April 2023, not cars. Main pool WDA is 18% for periods before 1 April 2026, 14% from 1 April 2026, hybrid for straddling periods; special rate pool is 6%. Current code models only the AIA, uncapped. See `references/capital-allowances.md`.
8. **Announced, not enacted (Budget 2026, policy paper of 29 October 2026):** main pool WDA to 12% for periods beginning on or after 1 April 2027, main-rate FYA from 40% to 50% for expenditure from 1 January 2027. Finance Bill 2026-27 will legislate. Model as `announced`; the FY2025 and FY2026 results must not change.
9. **Losses.** Carried-forward loss use is capped at the £5m deductions allowance plus 50% of profits above it (per 12-month AP, shared across a group). Most small companies are inside the allowance. Current-year, carry-back and terminal relief rules were not sourced; do not hard-code them.
10. **Filing reality.** HMRC's free online CT filing service closed on 31 March 2026. A Company Tax Return is the CT600 plus supplementary pages plus **iXBRL accounts** and **iXBRL tax computations** (separate instance documents), filed through commercial software or by an agent. A prepare-only OpenBudget therefore leaves the user needing filing software or an agent for the CT600, and for Companies House accounts (software-only from 1 April 2028; the web service is expected to stay until then, which is inferred). The product exports a populated CT600 data set, a computation, accounts content and a box checklist, and says this plainly. See `references/ct600-and-filing.md`.
11. **Deadlines.** CT is due 9 months and 1 day after AP end; the return is due 12 months after AP end. A 31 March 2026 year end gives 1 January 2027 and 31 March 2027. Returns due on or after 1 April 2026 face doubled fixed late-filing penalties (£200, £400, £1,000, £2,000 tiers).
12. **Statutory accounts.** Micro-entity (FRS 105) needs two of: turnover £1m, balance sheet £500,000, 10 employees. Small (FRS 102 Section 1A) needs two of: £15m, £7.5m, 50. These apply to financial years starting on or after 6 April 2025. The 23 October 2026 notice paused the requirement for small and micro companies to file a profit and loss account from April 2028; abridged and filleted accounts continue. Full accounts still go to members and HMRC. Do not model a mandatory P&L filing at Companies House. See `references/statutory-accounts-and-companies-house.md`.
13. **Companies House duties.** Confirmation statement every 12 months (£50 online), director identity verification before it can be filed, PSC changes within 14 days. The 12-month identity verification transition began 18 November 2025 and ends about 18 November 2026 (inferred). Build a per-director and per-PSC verification checklist.
14. **Director's loan account (DLA).** A participator who owes the company money triggers s455 tax of **35.75%** for loans or benefits from 6 April 2026 (33.75% for 6 April 2022 to 5 April 2026, 32.5% earlier), due 9 months and 1 day after AP end unless repaid, released or written off first, and refundable on relief. Repayments over £5,000 within 30 days of a later loan are matched (bed and breakfasting), and the arrangements rule applies beyond that. Track loan by loan with date, rate, repayments. A balance over £10,000 at any time in the tax year is a beneficial loan: official rate 3.75% for 2026/27, Class 1A NIC on the benefit. See `references/directors-loans-dividends.md`.
15. **Dividends** may come only from distributable profits (CA 2006 s830, relevant accounts s836). A member who knew or should have known is liable to repay (s847). An unlawful dividend to a director is normally treated as a loan. Require a reserves check, board minutes and a voucher before recording a dividend as paid. Personal dividend rates from 6 April 2026: 10.75%, 35.75%, 39.35%, allowance £500.
16. **Salary versus dividend** compares total cost (CT, employer and employee NIC, income tax) for realistic salary levels. Show both columns, the assumptions, and the distributable-reserves check. It is a comparison, never an instruction. Load `tax-planning-guardrails`.

## Where it lives in OpenBudget

- Rule data: `openbudget_core/lib/src/tax/gb/gb_rates.dart` (`GbTaxYearRates`, `gbRatesByStartYear`, `gbRateSources`, `gbRulesVerifiedOn`). Company CT figures sit in the same per-tax-year table; move them to a per-FY company table keyed by FY start year when APs are introduced.
- Computation: `gb_tax_rules.dart` (`_companyFigures`, `_corporationTax`, `_companyReport`, `_directorSplitOpportunity`, `_directorCost`, `_companyAssumptions`). Categories: `gb_categories.dart` (`gb.co.*`, CT600 box references).
- Contract: `tax_rule_pack.dart` (`TaxRulePack`, `TaxInput.linked` for director books), `tax_model.dart` (`TaxReportLine.reportReference`, `TaxOpportunity`).
- Server surface: `openbudget_server/lib/src/tax/` and `openbudget_server/lib/src/agent/agent_tax_reports.dart`.
- New code belongs in `openbudget_core` as pure functions: `ctAssessment(ap, profits, associates, exemptDistributions)`, `capitalAllowances(pools, additions, ap)`, `s455(loans, repayments)`, `distributableReserves(...)`. Exports (CT600 data set, iXBRL) belong behind an interface in the server.

## Testing

Encode every case in `references/test-vectors.md`. Compare pence exactly. HMRC's own example rounds MR to whole pounds (£2,094); compute in pence, round down to the penny as the repo does, and document the tolerance (vector 7 allows ±£1). Test rate and limit boundaries (50,000 and 250,000 exactly), associated-company scaling, short AP, hybrid WDA, AIA short period, s455 across the 6 April 2026 rate change, the 30-day matching rule, and dividend legality. Tests for announced rules must assert the FY2025 and FY2026 outputs do not move.

## Unverified and changing

Re-check all of these by **1 December 2026**, and again when Finance Bill 2026-27 receives Royal Assent.

- Budget 2026 capital allowance changes (12% WDA, 50% FYA): announced only. Whether Royal Assent has happened for the 14% WDA and 40% FYA was not read (the cars page already says 14%).
- Interaction of the 40% FYA with AIA and full expensing on one asset: not stated in the policy paper.
- Pre-trading expenses, full disallowable list, loss relief beyond the restriction, group relief, R&D PAYE cap and step order: not sourced.
- CT600 box 155, 160 and 165 long descriptions, boxes 330 to 425 (financial-year tables), boxes after 752: not read. Boxes 170 and 205 used by the repo are not in the research notes.
- Whether dormant associates count in the associates divisor, the leap-year days denominator, and exempt distribution treatment: not confirmed.
- Companies House accounts deadline of 9 months (21 months first accounts) is user-stated, not read. Accounting reference date rules, record-keeping periods and HMRC record penalties: not sourced.
- NIC rates, Employment Allowance, Class 1A rate (15% suggested by a search summary), employer pension contribution deductibility, dividend voucher content: not sourced. The repo's NIC and threshold figures were verified by the repo on 4 November 2026, not by this research.
- Companies House 28 January 2026 delay announcement is from a search summary. Identity verification transition end date has no stated day. PSC 25% threshold and registered office rules not read.
- Close company payments reporting: a consultation exists (Budget 2025); no rule yet.
- Structured computation format ("phase 2"): no mandatory date.

## References

- `references/rates-and-computation.md`: rates, MR, associates, short and straddling APs, adjustments, losses, R&D, source URLs.
- `references/capital-allowances.md`: AIA, full expensing, FYAs, pools, cars, hybrid rate, announced changes.
- `references/ct600-and-filing.md`: CT600 box map, supplementary pages, iXBRL, filing channel, deadlines, penalties.
- `references/statutory-accounts-and-companies-house.md`: thresholds, FRS 105 and 102 1A, 2026 pause, 2028 changes, ID verification, confirmation statement, dormancy.
- `references/directors-loans-dividends.md`: DLA, s455, beneficial loans, dividend legality, salary versus dividend method.
- `references/test-vectors.md`: worked examples with expected outputs.
