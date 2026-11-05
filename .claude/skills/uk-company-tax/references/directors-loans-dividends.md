# Director's loan account, s455, dividends and extraction

Grades: **[P]** primary, **[S]** secondary, **[I]** inferred. Research date 5 November 2026. This is guidance for the user to review; load `tax-planning-guardrails` before writing any text that suggests an action.

## Director's loan account (DLA) and s455 tax

- s455 rate: **35.75%** of the original loan for loans made or benefits conferred on or after 6 April 2026; 33.75% for 6 April 2022 to 5 April 2026; 32.5% before 6 April 2022. Aligned to the dividend upper rate. [P] https://www.gov.uk/guidance/changes-and-issues-affecting-the-corporation-tax-online-service , https://www.gov.uk/government/publications/income-tax-changes-to-tax-rates-for-property-savings-and-dividend-income/income-tax-changes-to-tax-rates-for-property-savings-and-dividend-income , https://www.gov.uk/hmrc-internal-manuals/company-taxation-manual/ctm61505 (rate summary via search, S)
- GOV.UK's "Director's loans: if you owe your company money" still shows 33.75% and "deduct Class 1 NI" wording. Treat as stale. https://www.gov.uk/directors-loans/you-owe-your-company-money
- Due date: 9 months and 1 day after the end of the AP in which the loan was made (aligned to the main CT due date), unless repaid, released or written off within 9 months of AP end. Later repayment gives relief due 9 months and 1 day after the end of the AP in which the repayment occurs (CTA 2010 s458). Relief is claimed on CT600A for claims within two years of the loan's AP, otherwise form L2P; claims within four years. [P] https://www.gov.uk/hmrc-internal-manuals/company-taxation-manual/ctm61610 , https://www.gov.uk/hmrc-internal-manuals/company-taxation-manual/ctm61625
- s455 is a company-side CT charge, not income tax, and is refundable on relief. Multiple rates can apply on one loan account (loans before and after 6 April 2026).
- Bed and breakfasting: repayments over £5,000 within a 30-day period are matched against later loans or chargeable payments (30-day rule, for repayments from 20 March 2013). The "arrangements" rule applies where the 30-day rule does not: GOV.UK describes another loan of £5,000 or more within 30 days before or after, and a separate case for loans over £15,000 where a loan was arranged while repaying. HMRC example CTM61640: a repayment matched to a later loan leaves the year-end balance unrelieved, producing s455 of £75,000 over two APs. [P] https://www.gov.uk/hmrc-internal-manuals/company-taxation-manual/ctm61640
- No relief for return payments on or after 30 October 2024 (s464A and s464B TAAR). [P] CTM61610 and CTM61625.
- Not examined: s455 on benefits (s464A) in detail; the exclusion for loans up to £15,000 to full-time working participators with under 5% (CTM61540).
- Reporting: CT600A shows loans to participators and the s455 tax; box A80 feeds CT600 box 480. HMRC's CT online service will not apply 35.75% until 6 April 2027; earlier returns with post-6 April 2026 loans must be amended afterwards.

Data model [I]: one row per advance (date, amount, rate by date made) and one row per repayment or release (date, amount, route), plus a computed matching of repayments to later loans for the 30-day rule. Derive the AP balance and s455 from those rows; never store a single running balance as the source of truth.

## Beneficial loan (benefit in kind)

A shareholder-director owing more than £10,000 at any time in the tax year is treated as receiving a beneficial loan. Official rate 3.75% from 6 April 2025 and still 3.75% from 6 April 2026 (can change in-year from 2025). Benefit = interest at the official rate less interest paid. Average method: `(opening + closing) / 2 x months outstanding / 12 x rate`. Class 1A NIC is due on the benefit; the Class 1A rate was not confirmed (a search summary suggested 15%). [P] https://www.gov.uk/government/publications/rates-and-allowances-beneficial-loan-arrangements-hmrc-official-rates/beneficial-loan-arrangements-hmrc-official-rates , https://www.gov.uk/guidance/beneficial-loan-arrangements-480-chapter-17 , https://www.gov.uk/hmrc-internal-manuals/national-insurance-manual/nim16671

## Dividends: legality and paperwork

- CA 2006 s830: distributions only from profits available for the purpose (accumulated realised profits less accumulated realised losses). s836: refer to "relevant accounts". s847: a member who knew or had reasonable grounds to believe the distribution was unlawful must repay it. [P] https://www.legislation.gov.uk/ukpga/2006/46/section/830
- An unlawful dividend to a director is usually treated as a director's loan. HMRC accepts correction through revised accounts and DLA adjustment. [P] https://www.gov.uk/guidance/director-information-hub-dividends , https://www.gov.uk/hmrc-internal-manuals/company-taxation-manual/ctm15205
- Product rule [I]: before a dividend can be recorded as "paid" the app checks distributable reserves from the books (after CT provision), then asks the user to confirm board minutes and a dividend voucher exist. The companies act does not require a voucher, HMRC practice expects one, and voucher and minute contents were **not researched**. Do not generate legal documents; offer a checklist.
- Personal dividend tax from 6 April 2026: 10.75% basic, 35.75% higher, 39.35% additional, allowance £500 (Budget 2025 measure 1.5). [P for the rates] https://www.gov.uk/government/publications/budget-2025-overview-of-tax-legislation-and-rates-ootlar/budget-2025-overview-of-tax-legislation-and-rates-ootlar ; [S for the £500 allowance] https://www.evelyn.com/insights-and-events/insights/autumn-budget-dividend-income-tax-increase/
- Pre-6 April 2026 rates in the repo are 8.75% and 33.75%; the research notes did not source them.
- Budget 2026 reportedly raises savings and property income rates by two points from 6 April 2027 (sources disagree on size); dividends unchanged in 2027/28 per secondary sources. Announced only.

## Salary versus dividend: method

Compare total cost across a grid of director salaries for the AP's tax year. The research did not retrieve NIC rates, thresholds, the personal allowance, Employment Allowance or optimal splits; the figures below come from the repo's rule data (verified there on 4 November 2026) and are **not** independently confirmed by this research. [I]

```
for salary in candidates:               # 0, secondary threshold, personal allowance, UEL, all profit
  employerNic   = max(0, salary - secondaryThreshold) * employerRate
  companyProfit = profit - salary - employerNic
  ct            = corporationTax(companyProfit, associates)     # MR applies
  dividend      = companyProfit - ct                            # only if distributable
  incomeTax     = tax(nonSavings + salary, savings, dividends + dividend)
  employeeNic   = class1Employee(salary)
  cost          = ct + employerNic + incomeTax + employeeNic
```

2026/27 figures in the repo: personal allowance £12,570, secondary threshold £5,000, employer rate 15%, employee primary threshold £12,570, upper earnings limit £50,270, employee 8% and 2%, dividend allowance £500.

Must be stated with the result: assumes all post-tax profit is distributed; no Employment Allowance (and sole-director companies are excluded from it, background [I]); no associated companies unless entered; no pension contributions; no NI credit effect from salary below the lower earnings limit; dividends must be legal (reserves); salary has to be genuinely paid via PAYE with RTI. If the books already include director pay, the result is illustrative. Show every candidate column, not just the cheapest. Never say "you should".

Announced: NICs on salary-sacrificed pension contributions above £2,000 a year from 6 April 2029 (Budget 2025 measure 2.9); employer NIC secondary threshold stays £5,000 from April 2028 to April 2031 (measure 2.2). [P] OOTLAR URL above. A consultation exists on close companies reporting payments to participators (loans, cash withdrawals, dividends): https://www.gov.uk/government/consultations/reporting-company-payments-to-participators/reporting-company-payments-to-participators-modernising-the-reporting-framework

## Pensions

Not sourced: whether employer pension contributions are allowable (and the spreading rule for large ones). Do not state it as fact; signpost an accountant. See `tax-planning-guardrails` for the personal-side pension levers.
