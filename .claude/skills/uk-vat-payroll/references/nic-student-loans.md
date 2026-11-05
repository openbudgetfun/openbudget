# Class 1 National Insurance, directors, Employment Allowance, student and postgraduate loans

Research date: 5 November 2026. Tags: **P** primary, **P-snip** (official page seen via summary), **S** secondary, **I** inferred. The payroll-specification note's rounding findings override the earlier note.

## 1. Thresholds (2025/26 and 2026/27)

| Threshold                                                                  | 2025/26 week / month / year | 2026/27 week / month / year | Tag |
| -------------------------------------------------------------------------- | --------------------------- | --------------------------- | --- |
| Lower Earnings Limit (LEL)                                                 | 125 / 542 / 6,500           | 129 / 559 / 6,708           | P   |
| Primary Threshold (PT)                                                     | 242 / 1,048 / 12,570        | same                        | P   |
| Secondary Threshold (ST)                                                   | 96 / 417 / 5,000            | same                        | P   |
| Upper Earnings Limit (UEL); under-21, apprentice-under-25 and veterans UST | 967 / 4,189 / 50,270        | same                        | P   |
| Freeport (FUST) and Investment Zone (IZUST)                                | 481 / 2,083 / 25,000        | same                        | P   |

Sources: [Rates and thresholds for employers 2025 to 2026](https://www.gov.uk/guidance/rates-and-thresholds-for-employers-2025-to-2026), [2026 to 2027](https://www.gov.uk/guidance/rates-and-thresholds-for-employers-2026-to-2027). The only change between years is the LEL. Budget 2025: income tax and equivalent NIC thresholds frozen to April 2031; the ST held at its current level from April 2028 to April 2031 (P-snip). Salary-sacrifice pension above 2,000 a year attracts NIC from 6 April 2029 (announced, not enacted).

Per-period thresholds for other pay intervals use annual x n / 52 rounded **up** to a whole pound (workbook-implied; **I**). Do not multiply the weekly figure: the 4-weekly PT is 967, not 968.

| Period (2026/27) | LEL | PT    | ST  | UEL   | FUST/IZUST |
| ---------------- | --- | ----- | --- | ----- | ---------- |
| Weekly           | 129 | 242   | 96  | 967   | 481        |
| 2-weekly         | 258 | 484   | 193 | 1,934 | 962        |
| 4-weekly         | 516 | 967   | 385 | 3,867 | 1,924      |
| Monthly          | 559 | 1,048 | 417 | 4,189 | 2,083      |

2025/26: LEL 125 / 250 / 500 / 542; everything else the same. Pro rata director thresholds follow the same round-up rule (category M, 48 weeks: UEL 46,404, PT 11,604, LEL 6,192).

## 2. Rates by category letter (2026/27; 2025/26 identical for the letters its page lists)

| Letter                                             | Employee LEL to PT    | PT to UEL | Above UEL | Employer                   | Above UEL |
| -------------------------------------------------- | --------------------- | --------- | --------- | -------------------------- | --------- |
| A standard                                         | 0%                    | 8%        | 2%        | 15% above ST               | 15%       |
| B married women/widows reduced                     | 0%                    | 1.85%     | 2%        | 15%                        | 15%       |
| C over State Pension age                           | nil                   | nil       | nil       | 15%                        | 15%       |
| H apprentice under 25                              | 0%                    | 8%        | 2%        | 0% up to UST, then 15%     | 15%       |
| J deferment                                        | 0%                    | 2%        | 2%        | 15%                        | 15%       |
| M under 21                                         | 0%                    | 8%        | 2%        | 0% up to UST               | 15%       |
| Z under 21 deferment                               | 0%                    | 2%        | 2%        | 0% up to UST               | 15%       |
| V veteran                                          | 0%                    | 8%        | 2%        | 0% up to UST               | 15%       |
| D, E, F, I, K, L, N, S (Investment Zone, Freeport) | as listed on the page |           |           | 0% to FUST/IZUST, then 15% | 15%       |

- Class 1A and 1B 15%. Employment Allowance 10,500 in both years. Apprenticeship Levy 0.5% of pay bill over 3,000,000 with a 15,000 allowance (2025/26 page).
- The 2025/26 page lists A, B, C, H, J, M, Z only (no V and no Freeport or Investment Zone letters).
- **Category X** is not on the rates pages. CWG2 uses X for employees under 16 (no NIC) and where software needs a category for pension payments from a registered scheme that are not NIC-able. Behaviour (no NIC) is inferred from that wording.
- When an employee turns 21 or an apprenticeship ends, M, Z or H stop being appropriate; use A or J. [CWG2](https://www.gov.uk/government/publications/cwg2-further-guide-to-paye-and-national-insurance-contributions/2026-to-2027-employer-further-guide-to-paye-and-national-insurance-contributions) 1.14.

## 3. Calculation: exact percentage method and rounding (I, validated on 1,792 HMRC rows)

- Earnings periods: weekly uses weekly figures; fortnightly, 4-weekly, quarterly, half-yearly, yearly can use the table route (divide earnings by 2, 4, 3, 6, 12 and multiply the table amount back up) or the exact percentage method with matching multi-week or multi-month limits. Irregular intervals: exact percentage method with LEL per day = weekly / 7 x calendar days and PT, ST, UEL, UST = annual / 365 x calendar days. Periods under a week use one week. Use one method per employee per tax year unless the employee moves to a payroll already using the other. Multiple pay intervals: add all payments and use the shorter interval. Payments on a non-banking regular payday are treated as paid on the regular payday. [CWG2](https://www.gov.uk/government/publications/cwg2-further-guide-to-paye-and-national-insurance-contributions/2026-to-2027-employer-further-guide-to-paye-and-national-insurance-contributions) 1.7, 1.8, 3.1.4, 3.3 (P).
- CWG2's wording: "the resulting figures should be calculated to the nearest penny. Amounts of 0.005 or less should be disregarded."
- **Rounding that reproduced every HMRC row:** compute each band's contribution **separately**; truncate that band's amount to **3 decimal places**; round to the penny with exactly 0.005 rounding **down**; then sum the bands. CWG2 does not state the truncation or per-band step; both were inferred from the test data.
  - Weekly 242.07 category A: 0.07 x 8% = 0.0056, truncated 0.005, rounded **0.00**; 242.08: 0.0064 -> 0.006 -> **0.01**; 242.32: 0.0256 -> 0.025 -> **0.02** (plain rounding gives 0.03).
  - Category B 2-weekly 1,934.05: 1,450.00 x 1.85% = 26.825 -> 26.82; 0.05 x 2% = 0.001 -> 0.00; total **26.82** (rounding the sum 26.826 would give 26.83, which HMRC does not).

```
ee = round_band((min(E,UEL) - PT) * r_pt_uel) if E > PT  +  round_band((E - UEL) * r_above) if E > UEL
er = sum over bands above ST of round_band((min(E,hi) - lo) * er_rate(band))   # ST..LEL, LEL..FUST/UST, ..UEL, above UEL
round_band(x) = round_half_down_2dp( trunc_3dp(x) )
```

- NIC earnings are the same gross figure used for student loans. Net-pay pension reduces taxable pay but not NIC-able pay unless it is salary sacrifice.
- Examples (2026/27, monthly): category A 3,000: employee **156.16**, employer **387.45**; 6,000: employee **287.50**, employer **837.45**; category M or H 3,000: employee 156.16, employer **0.00**; B: employee 36.11; J: employee 39.04.
- Holiday-pay examples (HMRC, 2025/26, category A, exact percentage; CWG2 2.7.5): weekly 400: employer 45.60, employee 12.64; weekly 200: employer 15.60; 266.67: employer 25.60, employee 1.97; 100: employer 0.60, employee nil.
- The printed CA38 table route was not opened and can differ by a penny; only the exact method is verified.

## 4. Directors: annual earnings period

- A director has an **annual earnings period (AEP)** whatever the payment interval; annual LEL and UEL are the weekly figures x 52. A director on 6 April, or who ceases during the year, has the full AEP. A director appointed during the year has a **pro rata** AEP of the weeks remaining including the appointment week (52-week basis; appointed in week 53 counts as 1 week). Pro rata thresholds = annual / 52 x weeks rounded up to a whole pound; LEL = weekly LEL x weeks. Earnings before appointment are excluded. [NIM12021](https://www.gov.uk/hmrc-internal-manuals/national-insurance-manual/nim12021), [NIM12022](https://www.gov.uk/hmrc-internal-manuals/national-insurance-manual/nim12022) (P).
- **Standard (cumulative) method:** each payment's NIC = NIC due on cumulative earnings minus NIC already paid. HMRC example (2025/26, 3,000 on the 28th each month, category A): employer NIC from month 2 on cumulative (6,000 minus 5,000) x 15% = 150.00; employee NIC starts when cumulative exceeds 12,570 (month 5: (15,000 minus 12,570) x 8% = 194.40). [NIM12028](https://www.gov.uk/hmrc-internal-manuals/national-insurance-manual/nim12028) (P).
- **Alternative arrangement:** pay "on account" using ordinary earnings periods, then at the end of the year (or pro rata period) compute the correct total on the annual figure. [NIM12026](https://www.gov.uk/hmrc-internal-manuals/national-insurance-manual/nim12026). The CA44 2026/27 text could not be read (font encoding); behaviour comes from NIM12026 and HMRC's directors' test workbook. Verify before choosing which method to implement; the standard annual method is the confirmed one.
- **HMRC directors' test data 2026/27** ([NI test data zip](https://assets.publishing.service.gov.uk/media/69676c2297d42030a67b0d60/NI-test-data-examples-from-April-2026-v1-0__1_.zip), P):
  - Alternative arrangement, category A, 1,000 weekly for 52 weeks: each week employee **58.66**, employer **135.60** (58.00 + 33 x 2% = 58.66). Annual calculation on 52,000 (LEL 6,708, PT-UEL 37,700): employee **3,050.60**, employer **7,050.00**. YTD at week 51: employee 2,991.66, employer 6,915.60. Week 52 reconciliation: employee **58.94**, employer **134.40**.
  - Standard annual, category A, 52,000 in one payment: employee 3,050.60, employer 7,050.00.
  - Category M, appointed 4 May 2026, 1,000 weekly from week 5 (48 weeks pro rata, 48,000): LEL 6,192, PT-UEL band 34,800; employee **2,815.92**, employer **239.40**. YTD at week 51: employee 2,757.02, employer 232.65. Week 52: employee 58.90, employer 6.75. As one annual payment: the same totals.
- Director NIC examples (I, 2026/27, no Employment Allowance): salary 12,570 paid 1,047.50 a month, category A: employee NIC 0.00 throughout (cumulative never exceeds 12,570); employer NIC by cumulative earnings: payment 4 (4,190.00) 0; payment 5 (5,237.50) (237.50 x 15% = 35.625 -> **35.62** per the per-band rule); payment 6 (6,285.00) 192.75 cumulative, 157.13 this payment; payment 8 (8,380.00) 507.00; payment 12 (12,570.00) **1,135.50** cumulative. Income tax 0.00 each month (1,047.50 is below free pay 1,048.26). Employer cost 13,705.50.
- Director at the LEL: 2026/27 6,708: employee 0, employer (6,708 minus 5,000) x 15% = **256.20**; 2025/26 6,500: **225.00**. At 5,000 employer NIC is nil but earnings are below the LEL, so no qualifying year for State Pension (general knowledge, not read in a source).
- Director appointed in tax week 27 (26 weeks remaining): pro rata ST = 5,000 / 52 x 26 = 2,500; PT = 6,285; employer NIC begins once cumulative earnings since appointment exceed 2,500. The week-counting convention is from a NIM12022 summary and not tested against an HMRC numeric example.

## 5. Employment Allowance

- 10,500 a year in both years; claimed through the EPS. NIM06545, [Single-director companies and Employment Allowance](https://www.gov.uk/government/publications/employment-allowance-more-detailed-guidance/single-director-companies-and-employment-allowance-further-employer-guidance), [NIM06545](https://www.gov.uk/hmrc-internal-manuals/national-insurance-manual/nim06545) (P-snip for the examples).
- **Single-director exclusion** (s2(4A) NICA 2014): a company cannot qualify for a tax year if all its secondary Class 1 earnings payments in that year go to the same employee who is a director when each payment is made. Tested each tax year. Examples:
  - Director the only employee: not eligible.
  - Director above ST and other employees all below ST: not eligible.
  - Director below ST and another employee at or above ST: eligible.
  - Director and another employee both above ST: eligible, against both.
  - Two or more directors, only one above ST: not eligible; more than one director above ST: eligible.
  - Sole director at the start of the year, then an employee above ST is added: eligible for the whole year; after that employee leaves it can keep claiming until the allowance is exhausted, then ineligible next year.
- Claim mechanics (EPS indicator), the de minimis state-aid declaration and the connected-company rule were not retrieved.
- Example (I): the same director (employer NIC 1,135.50) plus another employee on 20,000 (employer NIC 2,250): 3,385.50 is under 10,500, so nothing is payable and the allowance remaining after the director is 9,364.50.

## 6. Student and postgraduate loan deductions (payroll)

| Plan         | 2025/26 year / month / week | 2026/27 year / month / week | Tag |
| ------------ | --------------------------- | --------------------------- | --- |
| Plan 1       | 26,065 / 2,172.08 / 501.25  | 26,900 / 2,241.66 / 517.30  | P   |
| Plan 2       | 28,470 / 2,372.50 / 547.50  | 29,385 / 2,448.75 / 565.09  | P   |
| Plan 4       | 32,745 / 2,728.75 / 629.71  | 33,795 / 2,816.25 / 649.90  | P   |
| Plan 5       | not on the 2025/26 page     | 25,000 / 2,083.33 / 480.76  | P   |
| Postgraduate | 21,000 / 1,750 / 403.84     | 21,000 / 1,750 / 403.84     | P   |

Rates 9% (Plans 1, 2, 4, 5) and 6% (postgraduate). Plan 4 2025/26 is **32,745**; the SA110 notes' 31,395 is stale. Sources: the rates pages above, [SL3 2025 to 2026](https://www.gov.uk/government/publications/sl3-student-loan-deduction-tables/2025-to-2026-student-and-postgraduate-loan-deduction-tables), [SL3 2026 to 2027](https://www.gov.uk/government/publications/sl3-student-loan-deduction-tables/2026-to-2027-student-and-postgraduate-loan-deduction-tables).

- Earnings base = "the same gross pay amount that you would use to calculate your employer's secondary Class 1 NICs". Pay period = NIC earnings period; under 7 days uses one week.
- Deduction = 9% (or 6%) of the excess over the period threshold, **rounded down to a whole pound**; pay is not rounded; **non-cumulative**. HMRC examples: Plan 1 weekly 565.00: excess 47.70 x 9% = 4.29 -> **4**; postgraduate monthly 2,083: 333 x 6% = 19.98 -> **19**.
- Multiples of a week or month: average to a weekly or monthly amount, find the deduction, multiply by the number of weeks or months. Odd periods: threshold = days x annual threshold / days in year, **rounded down to the nearest penny**, then excess x rate rounded down to whole pounds. HMRC: 25 days, Plan 1, 2,050: threshold 25 x 26,900 / 365 = 1,842.46; excess 207.54 x 9% = 18.67 -> **18**; 25 days postgraduate 1,998: threshold 1,438.35, excess 559.65 x 6% = 33.57 -> **33**.

```
thr = trunc_2dp(annual * mult / div)     # (mult, div) = (1,52) weekly, (2,52) fortnightly, (4,52) four-weekly, (1,12) monthly
deduction = floor_pound((pay - thr) * rate) if pay > thr else 0
```

- Verified on 234 HMRC rows. Edge: Plan 1 weekly 528.42 minus 517.30 = 11.12 x 9% = 1.0008 -> 1, but 528.41 gives 0.9999 -> 0: the penny-level threshold matters. 2026/27 multi-week thresholds (Plan 1): 2-weekly 1,034.61 (26,900 x 2 / 52 = 1,034.615 truncated), 4-weekly 2,069.23, monthly 2,241.66. Samples: Plan 1 weekly 528.41 gives 0, 528.42 gives 1; monthly 2,252.77 gives 0, 2,252.78 gives 1, 8,586.11 gives 571.
- Plan 2 on 3,000 monthly: 9% x 551.25 = 49.6125 -> **49**.
- Payslip software computes student loan on the NIC earnings base (before net-pay pension relief), after NIC inputs, never cumulatively.
- The SL3 whole-pound lookup tables were not tabulated; the formula is equivalent for whole-pound earnings.
- Collection from 6 April 2026 (Plan 5): [Collection of student loans from 6 April 2026](https://www.gov.uk/government/publications/payroll-technical-specifications-student-loans/collection-of-student-loans-from-6-april-2026).
