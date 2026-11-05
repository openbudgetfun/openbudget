# Test vectors: UK company tax

Amounts in pounds here; encode as integer pence. Tolerance is zero pence unless stated. Round profits down to whole pounds and tax down to the penny as the repo does, and document any case where HMRC's own example rounds differently. Grade: **[P]** copied from an HMRC example, **[I]** computed from the cited rules.

## Corporation Tax, 12-month AP, one company, no distributions (unless stated)

| #  | Input                                                                                        | Expected CT                                                                                                  | Grade               |
| -- | -------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ | ------------------- |
| 1  | N 30,000                                                                                     | 5,700.00                                                                                                     | I                   |
| 2  | N 50,000                                                                                     | 9,500.00 (25% = 12,500 less MR 0.015 x 200,000 = 3,000)                                                      | I                   |
| 3  | N 100,000                                                                                    | 22,750.00 (25,000 - 2,250)                                                                                   | I                   |
| 4  | N 150,000                                                                                    | 36,000.00 (37,500 - 1,500)                                                                                   | I                   |
| 5  | N 250,000                                                                                    | 62,500.00                                                                                                    | I                   |
| 6  | N 300,000                                                                                    | 75,000.00                                                                                                    | I                   |
| 7  | N 90,000, exempt distributions 8,000 (A 98,000)                                              | 20,406.12 unrounded; HMRC prints MR 2,094 and CT 20,406 (tolerance 1.00)                                     | P (CTM03925)        |
| 8  | N 60,000, 1 associate (limits 25,000 and 125,000)                                            | 14,025.00 (15,000 - 975)                                                                                     | I                   |
| 9  | N 55,000, AP 1 Jan to 30 Sep 2024, months basis (9/12)                                       | 11,762.50                                                                                                    | P (CTM03930)        |
| 10 | CTM03955 regression: AP 1 Jan to 31 Dec 2023, N 175,000, 3 companies in total (2 associates) | 41,160.94 (part 1 8,198.69 + part 2 32,962.25)                                                               | P (regression only) |
| 11 | Days-based short AP: AP 1 Apr 2026 to 30 Sep 2026 (183 days of 365), N 60,000, no associates | lower 25,068.49, upper 125,342.47, CT about 14,019.86; rounding of the limits is unconfirmed, tolerance 1.00 | I                   |
| 12 | Boundary: N exactly 50,000.00 and exactly 250,000.00                                         | 9,500.00 and 62,500.00                                                                                       | I                   |

Marginal rate check: between the limits with A = N and no associates, `CT = 19% x 50,000 + 26.5% x (N - 50,000)`.

## A. Full chain, AP 1 Apr 2025 to 31 Mar 2026 (FY2025), no associates, distributions or losses

```
Accounting profit before tax                        120,000
 + depreciation                                       3,000
 + client entertaining                                1,500
 + fines                                                250
Adjusted trading profit before CAs                  124,750
 - AIA (office equipment 6,000)       box 690         6,000
 - main pool WDA 10,000 x 18%         box 705         1,800
Taxable trading profit / chargeable profits (box 315) 116,950
CT at 25%                                            29,237.50
MR = 3/200 x (250,000 - 116,950)                      1,995.75
CT liability                                         27,241.75   (check 9,500 + 26.5% x 66,950)
```

Employer pension contributions are not added back here only because deductibility is unsourced; the vector contains none.

## B. Capital allowances, AP 1 Apr 2026 to 31 Mar 2027 (WDA 14%)

Main pool b/f 20,000; car CO2 45g/km 18,000 into the main pool (no AIA); AIA on equipment 10,000.
AIA 10,000; main pool 38,000 x 14% = 5,320; total allowances 15,320; main pool TWDV c/f 32,680. The same pool at 18% (FY2025 period) gives 6,840.

## C. Hybrid and AIA short period

- AP 1 Jan to 31 Dec 2026: rate `(90 x 18% + 275 x 14%) / 365 = 14.9863%`; on a 38,000 pool 5,694.79 (tolerance 0.01).
- AP 1 Jan to 31 Dec 2027 (announced, flag `announced`): `(90 x 14% + 275 x 12%) / 365 = 12.4932%`.
- 9-month AP: AIA ceiling 750,000.
- Assert FY2025 and FY2026 outputs are identical with and without the announced 12% and 50% rules loaded.

## D. Salary versus dividend, tax year 2026/27 (inferred from the repo's rule data; tolerance 1.00)

Profit before director pay and CT £60,000. Director has no other income. No Employment Allowance, no associates, all post-CT profit paid as a legal dividend.

| Salary | Employer NIC | Company profit | CT        | Dividend  | Dividend tax | Employee NIC | Total cost |
| ------ | ------------ | -------------- | --------- | --------- | ------------ | ------------ | ---------- |
| 0      | 0            | 60,000         | 12,150.00 | 47,850.00 | 3,738.85     | 0            | 15,888.85  |
| 5,000  | 0            | 55,000         | 10,825.00 | 44,175.00 | 3,881.29     | 0            | 14,706.29  |
| 12,570 | 1,135.50     | 46,294.50      | 8,795.86  | 37,498.64 | 3,977.35     | 0            | 13,908.71  |

Workings: salary 0: 12,570 personal allowance covers dividends, taxable 35,280, 500 at 0% then 34,780 at 10.75%. Salary 12,570: employer NIC (12,570 - 5,000) x 15%; CT on profits rounded down to 46,294 at 19%; dividend band 37,700 not exceeded. Cheapest in this grid is salary 12,570, saving 1,980.14 against dividends only. The output must list all columns, not only the cheapest.

## E. s455 and loans

| #      | Scenario                                                                         | Expected                                                                                                                                             |
| ------ | -------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| s455-1 | Loan 20,000 made 1 Aug 2026, AP end 31 Mar 2027, outstanding at 1 Jan 2028       | s455 7,150.00 (35.75%), due 1 Jan 2028; relief window ends 31 Dec 2027                                                                               |
| s455-2 | Same loan fully repaid on 31 Dec 2027, no matching redraw within 30 days         | s455 0                                                                                                                                               |
| s455-3 | Same loan, 5,000 repaid in the window                                            | 15,000 x 35.75% = 5,362.50                                                                                                                           |
| s455-4 | Loan 10,000 on 1 Mar 2026 (33.75%) plus 20,000 on 1 Aug 2026 (35.75%), both open | 3,375.00 + 7,150.00 = 10,525.00; CT600A needs both rates; HMRC's service will not apply 35.75% until April 2027, so warn that an amendment is needed |
| s455-5 | Repay 8,000 on day 0, redraw 6,000 on day 15                                     | The 30-day rule matches the repayment to the later loan; not full relief                                                                             |
| bik-1  | 20,000 loan outstanding all of 2026/27, no interest paid                         | benefit 750.00 (3.75%); Class 1A applies at the employer rate, which is unverified                                                                   |
| bik-2  | Balance 10,000 or less at all times                                              | no benefit                                                                                                                                           |
| bik-3  | Opening 8,000, closing 14,000, 12 months, no interest paid                       | threshold exceeded; average method (8,000 + 14,000) / 2 x 3.75% = 412.50                                                                             |

## F. Dividends

| #     | Scenario                                         | Expected                                                                                                                                                             |
| ----- | ------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| div-1 | Distributable reserves 100,000; dividend 60,000  | lawful                                                                                                                                                               |
| div-2 | Distributable reserves 100,000; dividend 150,000 | unlawful; treat the excess 50,000 as a director's loan                                                                                                               |
| div-3 | Salary 12,570, dividends 47,430 (2026/27)        | dividend band: 500 at 0%, 37,200 at 10.75% = 3,999.00, 9,730 at 35.75% = 3,478.475; total 7,477.48 unrounded (repo rounds each slice down: 7,477.47; tolerance 0.01) |

## G. Dates, penalties, size tests

| #      | Case                                                                                      | Expected                                                                                                            |
| ------ | ----------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| date-1 | AP end 31 Mar 2026                                                                        | CT due 1 Jan 2027; return due 31 Mar 2027                                                                           |
| date-2 | AP end 31 Dec 2026                                                                        | CT due 1 Oct 2027; return due 31 Dec 2027                                                                           |
| pen-1  | Companies House accounts late by 20, 45, 120, 200 days                                    | 150, 375, 750, 1,500                                                                                                |
| pen-2  | CT return due after 1 Apr 2026 filed late (first offence, within 3 months; over 3 months) | tier amounts 200 and 400; whether the second is additional or cumulative is unconfirmed, so assert tier lookup only |
| size-1 | Turnover 900,000, balance sheet 600,000, 8 employees (FY starting 1 Jun 2026)             | two of three met (turnover, employees): micro                                                                       |
| size-2 | Same figures, FY starting 1 Jun 2024 (old limits 632,000 and 316,000)                     | only employees met: not micro                                                                                       |
| cs-1   | Review period ends 10 Jan 2027                                                            | file by 24 Jan 2027, fee 50 online                                                                                  |
