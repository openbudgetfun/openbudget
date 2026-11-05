# Worked examples with expected outputs

Quality: these are **inferred (I)**: arithmetic from the cited rates, cross-checked with a small reference calculation by the researcher. HMRC publishes no Self Assessment test vectors. Cross-check against a real SA302 or HMRC's online calculation where possible.

Conventions: pounds shown, assert in pence. England unless stated. No other income. Class 2 is nil (profits above the Small Profits Threshold). Tax per band is shown unrounded; the current pack truncates each band slice to the penny, which changes the result by up to 1p per slice, so state the rounding rule in each test and keep the rounding choice in one place. Whether HMRC truncates each slice or rounds the total is **not verified**.

## TC1: sole trader, profit 60,000, 2025/26

Taxable 47,430. Tax 37,700 x 20% = 7,540.00 + 9,730 x 40% = 3,892.00 = **11,432.00**. Class 4: 37,700 x 6% = 2,262.00 + 9,730 x 2% = 194.60 = **2,456.60**. Total 13,888.60. Payments on account for 2026/27: (11,432.00 + 2,456.60) / 2 = **6,944.30** each. If 5,000 + 5,000 were paid on account for 2025/26 the balancing payment is 3,888.60; the 31 January 2027 total is 3,888.60 + 6,944.30 = 10,832.90.

## TC2: profit 30,000, savings interest 800, dividends 2,000

Non-savings taxable 17,430 x 20% = 3,486.00. Starting-rate band nil. PSA 1,000 covers the 800 at 0%. Dividends: first 500 at 0%; 1,500 at 8.75% = 131.25 (2025/26) or at 10.75% = 161.25 (2026/27). Income Tax **3,617.25** (2025/26), **3,647.25** (2026/27). Class 4 17,430 x 6% = 1,045.80.

## TC3: profit 110,000, 2025/26 (PA taper)

PA = 12,570 minus (10,000 / 2) = 7,570; taxable 102,430. Tax 7,540 + 64,730 x 40% = 25,892 = **33,432.00**. Class 4 2,262.00 + 59,730 x 2% = 1,194.60 = 3,456.60. PA is nil at 125,140 and above; PA at 120,000 = 2,570.

## TC4: relief-at-source pension, profit 60,000, net 8,000 (gross 10,000), 2025/26

Basic-rate band extended to 47,700; taxable 47,430 all at 20% = **9,486.00** (11,432.00 without; saving 1,946.00 beyond the 2,000 the provider claims). Class 4 unchanged 2,456.60. Adjusted net income = 50,000. Enter **10,000** in SA100 TR 4 box 1.

## TC5: Gift Aid, profit 55,000, net gift 800 (gross 1,000), 2025/26

Without: taxable 42,430 = 7,540 + 4,730 x 40% = 9,432.00. With: basic band 38,700; 7,740 + 3,730 x 40% = 1,492 = **9,232.00** (relief 200). Whether TR 4 box 5 takes 800 or 1,000 is open; do not assert.

## TC6: Scotland

2026/27 profit 50,000: taxable 37,430. Starter 3,967 x 19% = 753.73; basic 12,989 x 20% = 2,597.80; intermediate 14,136 x 21% = 2,968.56; higher 6,338 x 42% = 2,661.96. Income Tax **8,982.05**. Class 4 (UK-wide) 37,430 x 6% = 2,245.80. Total 11,227.85.
2025/26 profit 40,000: taxable 27,430. 2,827 x 19% = 537.13; 12,094 x 20% = 2,418.80; 12,509 x 21% = 2,626.89. Income Tax **5,582.82**; Class 4 1,645.80.

## TC7: mixed income, profit 45,000, savings 3,000, dividends 10,000

Non-savings taxable 32,430 x 20% = 6,486.00. Total taxable 45,430 is above 37,700, so a higher-rate taxpayer for PSA: PSA 500 (500 at 0%, 2,500 at 20% = 500.00). Dividends start at 35,430: allowance 500; 1,770 in the basic band; 7,730 in the higher band.

- 2025/26: 1,770 x 8.75% = 154.875; 7,730 x 33.75% = 2,608.875; Income Tax **9,749.75** unrounded (9,749.74 if each slice is truncated to the penny).
- 2026/27: 1,770 x 10.75% = 190.275; 7,730 x 35.75% = 2,763.475; **9,939.75** unrounded (9,939.74 truncated).
- Class 4 32,430 x 6% = 1,945.80.

## TC8: UK property with residential mortgage interest, 2025/26

Employment pay 40,000 (PAYE ignored); rent 20,000; expenses 4,000; mortgage interest 6,000. SA105: box 20 = 20,000; box 29 = 4,000; box 44 = **6,000** (total, not 20%); box 38 = 16,000. Non-savings 56,000, taxable 43,430: 7,540 + 5,730 x 40% = 2,292 = 9,832.00. Finance-cost credit 20% x min(6,000, 16,000, 43,430) = **1,200.00**. Income Tax **8,632.00** before PAYE credit. Announced 2027/28: credit at the property basic rate (24%, not law, rate not stated).

## TC9: trading and property allowance choice

Receipts 900: nothing to report. Receipts 1,500, expenses 300: claim the allowance (profit 500) rather than expenses (profit 1,200). Receipts 1,500, expenses 1,800: do not claim; report a loss of 300 (SA103F box 48, 65, 77; SA103S box 22). Announced: 3,000 from 6 April 2027.

## TC10: capital gains

2025/26 shares gain 20,000, taxable income after PA 25,000, 12,700 of basic band left: 20,000 minus 3,000 = 17,000; 12,700 x 18% = 2,286.00 + 4,300 x 24% = 1,032.00 = **3,318.00**.
BADR gain 100,000, no other gains: (100,000 minus 3,000) x 14% (2025/26) = 13,580.00; x 18% (2026/27) = 17,460.00 (simplification: exempt amount set against the BADR gain; in practice it may be set against the highest-rate gains first).

## TC11: Plan 2 student loan, income 45,000

2025/26: 9% x (45,000 minus 28,470) = 1,487.70 -> SA110 box 3 is whole pounds rounded down: **1,487**. 2026/27: 9% x (45,000 minus 29,385) = 1,405.35 -> **1,405**. Assumes the income base equals profit and no pension or loss relief.

## TC12: HICBC, 2026/27

Adjusted net income 70,000: percentage (70,000 minus 60,000) / 200 = 50%. With 2,000 of Child Benefit the charge is 1,000. ANI of 80,000 or more: 100%. A full year of eldest-child benefit in 2026/27 = 53 Mondays x 27.05 = **1,433.65** (2025/26 had 52 Mondays). Whether the percentage is truncated to a whole 1% is unconfirmed.

## TC13: Marriage Allowance

Transferor income 11,000, recipient a basic-rate taxpayer: transferor PA reduced by 1,260 (still no tax as 11,000 is below 11,310); recipient tax reduced by **252.00**.

## TC14: payments on account cycle

Liability for 2025/26 of 8,000 Income Tax + Class 4, nothing collected at source: 2026/27 payments on account 4,000 on 31 January 2027 and 4,000 on 31 July 2027. If the 2026/27 liability is 10,000: balancing payment 2,000 plus first payment on account for 2027/28 of 5,000 = 7,000 due 31 January 2028 (plus any CGT or student loan). No payments on account if the prior-year bill is under 1,000 or over 80% was collected at source.
Late return illustration (2025/26 return filed 15 June 2027, current regime): 100 on 1 February 2027; 10 a day from 1 May 2027 for 46 days = 460; total **560**. The 900 cap is reached after 90 days. The 6-month charge applies only if still unfiled from 1 August 2027. Day count inclusive from 1 May, unverified to the day.
Late payment: 5,000 unpaid at 30 days: 5% = 250 (3 March 2027), 5% more at 6 months and 12 months, plus interest.
Interest: 5,000 for 60 days at 7.75% = 5,000 x 0.0775 x 60 / 365 = **63.70**; 5,000 for 40 days = **42.47**.

## TC15: MTD cumulative updates, one sole trader, standard periods, 2026/27

Q1 (6 April to 5 July 2026, due 7 August 2026): turnover 10,000; costOfGoods 2,000; carVanTravelExpenses 500 -> `periodDates {startDate 2026-04-06, endDate 2026-07-05}`, `periodIncome {turnover 10000, other 0}`, `periodExpenses {costOfGoods 2000, carVanTravelExpenses 500}`.
Q2 (6 April to 5 October 2026, due 7 November 2026): cumulative turnover 22,000, costOfGoods 4,100, carVanTravelExpenses 900 (not the delta). Q3 to 5 January 2027 due 7 February 2027; Q4 to 5 April 2027 due 7 May 2027; final declaration by 31 January 2028. Consolidated expenses are available only while cumulative turnover is under 90,000; once year-to-date turnover crosses 90,000 the next update must itemise. The JSON is illustrative; field validation was not verified against the OpenAPI specification.

## Property tests worth adding

- Every band-slice sum equals the total; no slice base is negative.
- Taxable income is monotonic in profit; total liability never falls as profit rises (except at documented cliffs: PA taper zone has a 60% marginal rate between 100,000 and 125,140).
- Pension gross-up: adding a relief-at-source contribution never increases liability.
- A Scottish taxpayer's savings and dividend tax equals the England figure for identical savings and dividends sitting at the same position in the stack.
