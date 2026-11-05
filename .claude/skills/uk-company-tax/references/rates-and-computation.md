# Rates, marginal relief and the computation

Grades: **[P]** primary (read on an official site), **[S]** secondary, **[I]** inferred. Research date 5 November 2026.

## Rates

| Item                  | Value                                                 | FY           | Grade | Source                                                                                                                                                       |
| --------------------- | ----------------------------------------------------- | ------------ | ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Small profits rate    | 19% up to £50,000                                     | 2023 to 2026 | P     | https://www.gov.uk/government/publications/rates-and-allowances-corporation-tax/rates-and-allowances-corporation-tax                                         |
| Main rate             | 25% over £250,000                                     | 2023 to 2026 | P     | same                                                                                                                                                         |
| Marginal relief       | between £50,000 and £250,000, standard fraction 3/200 | 2023 to 2026 | P     | https://www.gov.uk/guidance/corporation-tax-marginal-relief                                                                                                  |
| Rates held for FY2027 | 25% and 19% (Budget 2025 measure 1.30)                | 2027         | P     | https://www.gov.uk/government/publications/budget-2025-overview-of-tax-legislation-and-rates-ootlar/budget-2025-overview-of-tax-legislation-and-rates-ootlar |

From 1 April 2023 there is no single rate for non-ring-fence profits. Over £250,000 no marginal relief is available.

The repo's stale assumption text says the 2027 rates "were not set"; measure 1.30 sets them equal to FY2026. The five days of April 2027 inside tax year 2026/27 therefore need no apportionment.

## Marginal relief

`MR = F x (U - A) x (N / A)`, F = 3/200, U = upper limit, A = augmented profits, N = taxable total profits. MR is deducted from tax at the main rate. [P] https://www.gov.uk/hmrc-internal-manuals/company-taxation-manual/ctm03925

HMRC example: N £90,000, exempt distributions £8,000, A £98,000, U £250,000. Tax at 25% is £22,500, MR is (3/200 x £152,000) x (90,000 / 98,000) = £2,094, CT £20,406. [P] CTM03925.

Implementation [I], pence-safe:

```
lower = 50_000 * apDays / fyDays / (1 + associates)
upper = 250_000 * apDays / fyDays / (1 + associates)
N = taxable total profits; A = N + exemptDistributions
if A <= lower: tax = 19% * N
elif A >= upper: tax = 25% * N
else: tax = 25% * N - (3/200) * (upper - A) * (N / A)
```

Do not use a rate-by-profit shortcut. Keep `N / A` as an exact ratio of integers.

## Associated companies

Limits are divided by 1 + the number of associated companies (the total number of companies including the subject company). HMRC example with three associates: divisor 4, limits £12,500 and £62,500. [P] https://www.gov.uk/hmrc-internal-manuals/company-taxation-manual/ctm03935

Not read: the statutory definition (CTA 2010 s25, control tests, CTM03940 to CTM03951) and whether dormant or non-trading companies count. Ask the user a plain question ("Do you or people connected to you control other companies?") and record the count; never infer it.

CT600 boxes 326 (associated companies in the period), 327 and 328 (first and second financial year), 329 (small profits rate or MR entitlement). [P] https://www.gov.uk/guidance/the-company-tax-return-guide

## Short and straddling periods

- Short AP: both limits reduced proportionately. HMRC's worked example uses months (9/12) but says strictly the calculation is by days (CTM03930). Example: profits £55,000, AP 1 Jan to 30 Sep 2024, limits £37,500 and £187,500, tax at 25% £13,750, MR 3/200 x (187,500 - 55,000) = £1,987.50, CT £11,762.50. [P] https://www.gov.uk/hmrc-internal-manuals/company-taxation-manual/ctm03930
- Leap-year denominator (365 vs 366): not confirmed. Use the number of days in the relevant FY and say so. [I]
- Straddle (CTM03955): split the AP into notional parts, apportion profits by days in the AP, scale limits by days in the part over days in the FY (366 for FY2023), divide by associates, compute each part separately. An associate that exists in only one part does not reduce the other part's limits. [P] https://www.gov.uk/hmrc-internal-manuals/company-taxation-manual/ctm03955
- HMRC regression: AP 1 Jan to 31 Dec 2023, profits £175,000, 3 companies. Part 1 £43,151 at 19% = £8,198.69; part 2 £131,849 at 25% = £32,962.25 (above the adjusted upper limit £62,614); total £41,160.94. Regression only; no current year straddle needs it.

## Profit-to-taxable adjustments

Start from accounting profit before tax, then:

1. Add back depreciation and amortisation, loss or profit on disposal of assets, fines and penalties, client entertaining, non-qualifying gifts, general provisions, capital items expensed. Only entertaining and gifts are sourced (BIM45000, https://www.gov.uk/hmrc-internal-manuals/business-income-manual/bim45000, P). The rest are standard practice [I].
2. Gift exceptions: small gifts, free samples, gifts to charities, gifts to employees (BIM45065 to BIM45074, P). Staff entertaining may be inside an exception. Assets used for entertainment get no capital allowances.
3. Deduct capital allowances (AIA, WDA, FYA, full expensing). Capital allowances replace depreciation; never both.
4. Employer pension contributions are generally allowable but no source was retrieved (BIM46000 unread, spreading rule for large contributions unread). Do not hard-code. [I]
5. Pre-trading expenses (relief as if incurred on the first trading day, seven-year lookback) are standard practice, not sourced here. [I]

Worked full chain: see `test-vectors.md` vector A.

## Losses

- Carried-forward loss restriction (since 1 April 2017): losses can reduce profits after in-year reliefs only up to the deductions allowance (£5m per 12-month AP, group-shared, reduced for short APs) plus 50% of profits above it. No restriction when profits are within the allowance. The allowance must be stated on the return. [P] https://www.gov.uk/hmrc-internal-manuals/company-taxation-manual/ctm05010 and https://www.gov.uk/hmrc-internal-manuals/company-taxation-manual/ctm04830
- CT600 loss boxes: 160 trading losses b/f set against trading profits; 275 trading losses of this or a later AP; 280 amounts carried back from later APs; 285 trading losses carried forward and claimed against total profits. [P] https://www.gov.uk/guidance/the-company-tax-return-guide
- Not sourced: current-year set-off, carry-back period and limits, terminal loss relief, group relief. Reference page exists: https://www.gov.uk/guidance/corporation-tax-calculating-and-claiming-a-loss (unread). Ask the user to confirm with an agent before claiming.

## R&D (for awareness, not for production use)

- Merged RDEC for APs beginning on or after 1 April 2024: credit 20%, taxable; notional tax rate for loss-makers 19%; ERIS for loss-making R&D-intensive SMEs: extra 86% deduction (186% total) and payable credit up to 14.5% of the surrenderable loss; intensity condition 30% of total expenditure (was 40%) with a one-year grace. [P] https://www.gov.uk/guidance/research-and-development-rd-tax-relief-the-merged-scheme-and-enhanced-rd-intensive-support
- CT600L supplementary page; box 530 is the R&D credit. [P] https://www.gov.uk/guidance/changes-and-issues-affecting-the-corporation-tax-online-service
- Not researched: PAYE and NIC cap, step order, ERIS surrenderable loss definition, notification and Additional Information Form. Do not hard-code. Illustrative only: £100,000 qualifying spend gives £20,000 gross RDEC; a loss-maker's notional tax at 19% leaves £16,200 before the cap.

## Dormant companies

HMRC dormancy (no trading and no other income, and HMRC told) differs from Companies House dormancy (no significant accounting transactions). A company with only bank interest is not dormant for CT but can be for Companies House. Model two flags: `dormantForHmrc`, `dormantForCompaniesHouse`. [P] https://www.gov.uk/dormant-company/dormant-for-corporation-tax and https://www.gov.uk/dormant-company/dormant-for-companies-house
