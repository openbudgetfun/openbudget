# Deadlines, payments on account, penalties, interest and MTD for Income Tax

Research date: 5 November 2026. Tags: **P** primary (official page read), **P-snip** (official page seen via summary), **S** secondary, **I** inferred.

## 1. Deadlines for the 2025/26 return

| Date             | Event                                                                                                                                                     | Tag |
| ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- | --- |
| 5 October 2026   | Last day to tell HMRC you need to file (first-time). Registering later gets a deadline 3 months from HMRC's letter, but tax is still due 31 January 2027. | P   |
| 31 October 2026  | Paper return deadline (passed).                                                                                                                           | P   |
| 30 December 2026 | Last day to file online if a balance under 3,000 is to be collected through the 2027/28 tax code.                                                         | P   |
| 31 January 2027  | Online return (11:59pm), balancing payment for 2025/26, first payment on account for 2026/27, last day to pay voluntary Class 2 for 2025/26 through SA.   | P   |
| 31 July 2027     | Second payment on account for 2026/27.                                                                                                                    | P   |
| 31 January 2028  | Last day to amend the 2025/26 return (12 months after the filing deadline); also the 2026/27 return and payment deadline.                                 | P   |

- Coding out (SA100 TR 6 box 2 to refuse): balances under 3,000 can be collected through PAYE; Class 2 cannot be coded out. Source: [GOV.UK deadlines](https://www.gov.uk/self-assessment-tax-returns/deadlines), [SA150 notes](https://assets.publishing.service.gov.uk/media/6a9ea8a5df4246cf45e469e0/SA150_Notes_2026.pdf).
- Amendments within 12 months of the deadline: [HMRC guide, updates at tax year end](https://developer.service.hmrc.gov.uk/guides/income-tax-mtd-end-to-end-service-guide/documentation/make-updates-at-tax-year-end.html), [Submit your tax return](https://www.gov.uk/guidance/use-making-tax-digital-for-income-tax/submit-your-tax-return).

## 2. Payments on account and the balancing payment

- Two instalments, each 50% of the previous year's **Income Tax plus Class 4 NIC** net of tax deducted at source, due 31 January (in the tax year) and 31 July (after it). **P**: [GOV.UK payments on account](https://www.gov.uk/understand-self-assessment-bill/payments-on-account).
- Not required if last year's SA bill (Income Tax + Class 4, less amounts collected at source) was under 1,000, or if more than 80% of last year's tax was collected at source. SA110 working sheet: A356 = A340 minus (A330 + A333 + A334 + A353); no payments on account if A356 is under 1,000 or A356 is less than A358 (20% of A357); each payment = 50% of A356; due 31 January 2027 = A355 + A361. **P**.
- **Payments on account cover Income Tax and Class 4 only.** CGT, student loan repayments, HICBC and Class 2 are settled in the balancing payment on 31 January after the year.
- Balancing payment = total liability minus payments on account.
- Reducing payments: SA303 or online; on the paper summary, SA110 box 10 (X), box 11 (reduced first payment) and box 17 (reason). The second payment can be reduced independently (**I**). Interest is charged if reduced too far.
- Reform announced for April 2029 ("More Timely Payments for Self Assessment"); not enacted.

## 3. Penalties: current regime (applies to the 2025/26 return)

| Offence           | Penalty                                                                                                                                                             | Tag |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --- |
| Late return       | 100 immediately; after 3 months 10 a day up to 900 (90 days); after 6 months the greater of 5% of the tax due or 300; after 12 months another greater of 5% or 300. | P   |
| Late payment      | 5% of the unpaid tax at 30 days, at 6 months and at 12 months, plus interest.                                                                                       | P   |
| Failure to notify | Possible penalty if you register after 5 October and do not pay everything by 31 January.                                                                           | P   |

Pay penalties within 30 days of notice; appeal with a reasonable excuse. Sources: [GOV.UK penalties](https://www.gov.uk/self-assessment-tax-returns/penalties), [SA100 form](https://assets.publishing.service.gov.uk/media/69c14d07cfa346b9d4704a8d/SA100-2026.pdf).

## 4. Penalties: new regime for Income Tax Self Assessment

[GOV.UK: penalties for MTD for Income Tax](https://www.gov.uk/guidance/penalties-for-making-tax-digital-for-income-tax) (**P**):

- Replaces the late-submission and late-payment penalties on the personal return from "the tax year you join". Example given: joining on 6 April 2026 leaves the 2025/26 return (31 January 2027) under current penalties. From April 2027 the new penalties apply to everyone who files a personal SA return. They do not apply to non-resident company, trust, estate or partnership returns.
- **Late submission points:** one point per missed deadline (quarterly update for years after 2026/27, or the return). At 4 points a 200 penalty, and 200 for each further miss (threshold 2 points for those exempt and annual-filing in 2027/28). Points expire after 24 months below the threshold. **No points for missed quarterly updates in 2026/27**; Budget 2026 also removes them for 2027/28 (announced).
- **Late payment** (balancing payments and amounts after amendment or assessment; payments on account excluded): up to 15 days no penalty; days 16 to 30 a penalty of 3% (2026/27) or 4% (2027/28) of the tax owed at day 15; from day 31 a further 3% or 4% of the tax owed at day 30, plus a second penalty at 10% a year on the outstanding amount from day 31 for up to 2 years. In the first year of the new penalties the 15-day window is 30 days (once only). A payment plan pauses penalties from the contact date. Interest is charged separately.
- **Ambiguity (do not guess):** the guidance does not say whether "from April 2027" means tax year 2027/28 or deadlines falling after April 2027. A non-MTD filer's 2026/27 return (due 31 January 2028) probably stays under the old penalties (**I**). Model the regime as dated, per-taxpayer configuration with the assumption recorded.

## 5. Interest

- Late payment interest = Bank Rate + 4% (from 6 April 2025; was +2.5%). Repayment interest = Bank Rate minus 1%, floor 0.5%. Applies to Income Tax, NIC, CGT and others; runs from the first day payment is late.
- Rate history on GOV.UK (page last updated 30 September 2026, showing no change after 9 January 2026): **P**: [HMRC interest rates](https://www.gov.uk/government/publications/rates-and-allowances-hmrc-interest-rates-for-late-and-early-payments/rates-and-allowances-hmrc-interest-rates).

| From             | Late payment | Repayment |
| ---------------- | ------------ | --------- |
| 25 February 2025 | 7.00%        | 3.50%     |
| 6 April 2025     | 8.50%        | 3.50%     |
| 28 May 2025      | 8.25%        | 3.25%     |
| 27 August 2025   | 8.00%        | 3.00%     |
| 9 January 2026   | 7.75%        | 2.75%     |

- Store this as a dated rate table in versioned data, never a constant. HMRC applies a lag after Bank Rate changes. A third-party note says Bank Rate was held at 3.75% on 17 September 2026 (**S**). Day-count basis (365) and interest on late payments on account were not read from HMRC manuals (SALF305); simple daily interest on a 365-day year is the working assumption (**I**).

## 6. Making Tax Digital for Income Tax (MTD ITSA)

### Who must join (P)

Qualifying income is total turnover before expenses from self-employment and UK property, taken from the stated year's return. [Using MTD for Income Tax for the first time](https://www.gov.uk/guidance/use-making-tax-digital-for-income-tax/using-making-tax-digital-for-income-tax-for-the-first-time).

| Qualifying income | From the return for | Mandatory from |
| ----------------- | ------------------- | -------------- |
| over 50,000       | 2024/25             | 6 April 2026   |
| over 30,000       | 2025/26             | 6 April 2027   |
| over 20,000       | 2026/27             | 6 April 2028   |

Whether Budget 2026 changed the 20,000 step was not found. Deferrals and exemptions: see `rates-and-allowances.md` section 11.

### What the user must do

- Keep **digital records** of income and expenses for self-employment and property (amount, date, category; same categories as SA). Record-keeping starts 6 April 2026 (accounting period ending 5 April, standard periods) or 1 April 2026 (period ending 31 March, calendar periods). The "digital links" and no-manual-rekeying rules for MTD ITSA were not read (gap).
- Send **quarterly updates** from compatible software, one per sole trade and per property business. Each update is **cumulative** from 6 April to the period end; corrections appear in the next update; an update is required even with no income or expenses. Each update gives an in-year tax estimate.
- Standard periods and deadlines: 6 April to 5 July due 7 August; to 5 October due 7 November; to 5 January due 7 February; to 5 April due 7 May. Calendar periods (1 April to 30 June etc.) have the same deadlines; updates can be sent from the period end (or up to 10 days before); software defaults to standard; calendar election only for 1 April to 31 March accounting periods and before the first update of the tax year. Deadline = one month and 2 days after the period end. The 2021 Digital Requirements Regulations still read 5th; follow HMRC guidance (7th). **P**: [Send quarterly updates](https://www.gov.uk/guidance/use-making-tax-digital-for-income-tax/send-quarterly-updates), [HMRC guide: updates during the tax year](https://developer.service.hmrc.gov.uk/guides/income-tax-mtd-end-to-end-service-guide/documentation/make-updates-during-tax-year.html), [2021 Regulations](https://www.legislation.gov.uk/uksi/2021/1076/made/data.xht?amp=&view=snippet&wrap=true).
- 2026/27 deadlines: 7 August 2026, **7 November 2026** (a Saturday: send on or before), 7 February 2027, 7 May 2027; final declaration by 31 January 2028.
- **Final declaration** replaces the end-of-period statement: confirm complete, check the calculation, declare. HMRC adds PAYE employment, pensions, taxable benefits, CIS, residential property CGT disposals, Marriage Allowance and student loan details. The user adds savings interest, partnership share, dividends, payrolled benefits not subject to Class 1A, other income and gains. Amend within 12 months of the deadline.

### The limitation for a prepare-only app (state it to the user)

OpenBudget prepares figures and a checklist and does not submit. **A prepare-only app cannot by itself satisfy MTD ITSA for a mandated user.** Quarterly updates and the final declaration must be sent to HMRC through software that calls HMRC's MTD APIs. HMRC's APIs are used by recognised software, and this research did not find or check any GOV.UK web form that lets a mandated user key a quarterly update by hand; do not assume one exists. What the app can do:

1. Be the digital record, exporting per-category cumulative totals for each update period (the cumulative totals described under "Cumulative update content") so the user can load them into bridging or MTD software through a digital link (file import such as CSV; manual retyping and copy-and-paste break the digital-link rule where it applies).
2. Show which update period is current, the due date, and a prominent warning when a deadline is within days.
3. Tell a mandated user plainly that they also need MTD-compatible software to send updates and the final declaration.

If OpenBudget later becomes MTD software itself, that is a separate scope: HMRC recognition and production credentials, Government Gateway OAuth, fraud-prevention headers (which carry device data and need a privacy design first). Not researched.

### Cumulative update content (API shape; secondary and snip quality)

- Self-employment (Self Employment Business API v5.0): `PUT /individuals/business/self-employment/{nino}/{businessId}/cumulative/{taxYear}`; body `periodDates` (start, end), `periodIncome` (`turnover`, `other`, `taxTakenOffTradingIncome`), `periodExpenses` as **either** `consolidatedExpenses` **or** itemised fields; returns 204; the PUT replaces everything previously held for the tax year. Sending both returns `RULE_BOTH_EXPENSES_SUPPLIED`. Consolidated expenses are allowed only while annual turnover is under 90,000 (checked on each cumulative submission). **S/P-snip**: [freeCodeCamp walkthrough](https://www.freecodecamp.org/news/how-to-submit-a-quarterly-update-to-hmrc-making-tax-digital-api), [HMRC end-to-end guide](https://developer.service.hmrc.gov.uk/guides/income-tax-mtd-end-to-end-service-guide/documentation/make-updates-during-tax-year.html).
- Itemised expense names: `costOfGoods`, `paymentsToSubcontractors`, `wagesAndStaffCosts`, `carVanTravelExpenses`, `premisesRunningCosts`, `maintenanceCosts`, `adminCosts`, `interestOnBankOtherLoans`, `financeCharges`, `irrecoverableDebts`, `professionalFees`, `depreciation`, `otherExpenses`, `advertisingCosts`, `businessEntertainmentCosts`. [HMRC tax logic guide](https://developer.service.hmrc.gov.uk/guides/tax-logic-service-guide/documentation/income-and-benefits.html).
- UK property (Property Business API v6.0): income `periodAmount`, `premiumsOfLeaseGrant`, `reversePremiums`, `otherIncome`, `rentARoom.rentsReceived`; expenses `consolidatedExpenses` or `premisesRunningCosts`, `repairsAndMaintenance`, `financialCosts`, `professionalFees`, `costOfServices`, `travelCosts`, `other`; residential finance costs held separately.
- Other API versions named by HMRC: Business Details 2.0, Obligations 3.0, BSAS 7.0, Individual Calculations 8.0, Individual Losses 7.0, Reliefs 3.0, Charges 3.0, Dividends 2.0, CGT 3.0.
- Because every update is a cumulative PUT, store the ledger and recompute year-to-date totals per category at each period end; never send deltas. Wait at least 10 seconds after a period-type change before a cumulative update. Primary OAS schemas were not retrievable; field validation rules are unverified.
- **Year-end order (HMRC recommended):** confirm accounting type; periods of account and late accounting date rule; annual submissions (allowances: trading, property and Rent-a-Room cannot be combined with other expenses, so remove expenses from the final cumulative update); BSAS accounting adjustments; losses; trigger calculation with `finalDeclaration: true`; show the calculation (at least SA302 equivalent); final declaration with the confirmed calculation ID; check obligations. Post-final amendments: `intent-to-amend` then `confirm-amendment`. Additional income (employment, dividends, savings, pensions, foreign, CGT after year end, reliefs, charges including HICBC and Winter Fuel Payment from 2026/27) must be submitted before the final declaration.
