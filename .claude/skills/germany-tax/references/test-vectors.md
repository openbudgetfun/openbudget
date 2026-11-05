# Test vectors

All money in whole euros unless a cent value is shown; encode as integer cents. "Verified" means the researcher computed it with the cited formula and a second implementation (integer arithmetic, floor at each statutory rounding step) reproduced it during skill authoring. Vectors depend on the figures in `income-tax.md`: 2026 constants are primary, 2025 constants and the 2025 Soli Freigrenze are secondary, so 2025 vectors are only as good as those inputs.

Rounding: zvE floored to whole euros; tariff floored to whole euros; Soli floored to the cent; Kirchensteuer at 9% shown exact (no rounding case occurs below). Withholding on capital income: tolerance one cent.

## §32a tariff and Soli (single, Grundtarif)

| Year | zvE     | ESt     | Soli     | KiSt 9%   | KiSt 8%  |
| ---- | ------- | ------- | -------- | --------- | -------- |
| 2025 | 12,096  | 0       | 0        | 0         | 0        |
| 2025 | 12,348  | 35      | 0        | 3.15      | 2.80     |
| 2025 | 17,443  | 1,015   | 0        | 91.35     | 81.20    |
| 2025 | 30,000  | 4,303   | 0        | 387.27    | 344.24   |
| 2025 | 50,000  | 10,691  | 0        | 962.19    | 855.28   |
| 2025 | 68,480  | 17,849  | 0        | 1,606.41  | 1,427.92 |
| 2025 | 100,000 | 31,088  | 1,325.42 | 2,797.92  | 2,487.04 |
| 2025 | 277,825 | 105,774 | 5,817.57 | 9,519.66  | 8,461.92 |
| 2025 | 277,826 | 105,775 | 5,817.62 | 9,519.75  | 8,462.00 |
| 2025 | 300,000 | 115,753 | 6,366.41 | 10,417.77 | 9,260.24 |
| 2026 | 12,348  | 0       | 0        | 0         | 0        |
| 2026 | 12,349  | 0       | 0        | 0         | 0        |
| 2026 | 15,000  | 435     | 0        | 39.15     | 34.80    |
| 2026 | 17,799  | 1,034   | 0        | 93.06     | 82.72    |
| 2026 | 17,800  | 1,035   | 0        | 93.15     | 82.80    |
| 2026 | 30,000  | 4,217   | 0        | 379.53    | 337.36   |
| 2026 | 50,000  | 10,548  | 0        | 949.32    | 843.84   |
| 2026 | 69,878  | 18,213  | 0        | 1,639.17  | 1,457.04 |
| 2026 | 69,879  | 18,213  | 0        | 1,639.17  | 1,457.04 |
| 2026 | 100,000 | 30,864  | 1,251.16 | 2,777.76  | 2,469.12 |
| 2026 | 277,825 | 105,550 | 5,805.25 | 9,499.50  | 8,444.00 |
| 2026 | 277,826 | 105,551 | 5,805.30 | 9,499.59  | 8,444.08 |
| 2026 | 300,000 | 115,529 | 6,354.09 | 10,397.61 | 9,242.32 |

Soli above is for a single person with no children (Kinderfreibeträge not modelled). Total burden, single, 2026, zvE 100,000, 9% church tax: 30,864 + 1,251.16 + 2,777.76 = 34,892.92.

Continuity at the zone 3 to 4 edge: 2026 zvE 69,878 and 69,879 both give 18,213.

## Splitting (joint zvE halved, tax doubled)

| Year | Joint zvE              | ESt     | Joint Soli                                                       |
| ---- | ---------------------- | ------- | ---------------------------------------------------------------- |
| 2026 | 24,696                 | 0       | 0                                                                |
| 2026 | 30,000 (half 15,000)   | 870     | 0                                                                |
| 2026 | 60,000 (half 30,000)   | 8,434   | 0 (below 40,700)                                                 |
| 2026 | 100,000 (half 50,000)  | 21,096  | 0                                                                |
| 2026 | 200,000 (half 100,000) | 61,728  | 2,502.33 (Milderungszone: 11.9% × (61,728 − 40,700) = 2,502.332) |
| 2025 | 100,000                | 21,382  | 0                                                                |
| 2025 | 600,000 (half 300,000) | 231,506 | 12,732.83 (5.5% × 231,506, above the Milderungszone)             |

## Soli Milderungszone, 2026 single, tax as input

| Tax    | Soli                                                                             |
| ------ | -------------------------------------------------------------------------------- |
| 20,350 | 0                                                                                |
| 20,351 | 0.11 (11.9% × 1 = 0.119, floored)                                                |
| 21,000 | 77.35 (min(1,155.00, 11.9% × 650 = 77.35); a float implementation returns 77.34) |
| 25,000 | 553.35                                                                           |
| 30,000 | 1,148.35                                                                         |
| 40,000 | 2,200.00 (min(2,200.00, 2,339.35))                                               |

Zone end tax: 37,838.28 (2026), 37,094.53 (2025). 2025 single with tax 25,000: min(1,375.00, 11.9% × 5,050 = 600.95) = 600.95.

## Abgeltungsteuer on 1,000 capital income (after allowance)

`KapESt = 1,000 / (4 + k)` (k as a fraction), Soli 5.5% of KapESt, KiSt = k × KapESt. Tolerance one cent; the research rounded half up where an integer-floor implementation gives one cent less.

| k  | KapESt                  | Soli                  | KiSt  | Total        |
| -- | ----------------------- | --------------------- | ----- | ------------ |
| 0  | 250.00                  | 13.75                 | 0     | 263.75       |
| 9% | 244.50 (exact 244.4988) | 13.45 (exact 13.4474) | 22.00 | about 27.99% |
| 8% | 245.10 (exact 245.0980) | 13.48                 | 19.61 |              |

The formula is §32d Abs. 1 (primary); the vector values are the researcher's arithmetic.

## Gewerbesteuer and §35 (sole trader, Gewerbeertrag 60,000)

| Hebesatz | Gewerbeertrag after Freibetrag | Messbetrag (3.5%) | GewSt    | §35 credit                                          | Net cost |
| -------- | ------------------------------ | ----------------- | -------- | --------------------------------------------------- | -------- |
| 400%     | 35,500                         | 1,242.50          | 4,970.00 | 4,970.00 (min(4 × 1,242.50, GewSt paid, ESt share)) | 0        |
| 450%     | 35,500                         | 1,242.50          | 5,591.25 | 4,970.00                                            | 621.25   |

Worked income tax case, 2026 single, only this business, profit 60,000, Sonderausgaben-Pauschbetrag 36, Hebesatz 400%: zvE 59,964, tariff tax 14,219, credit 4,970, income tax 9,249 (ESt share cap does not bite because the business is the only income). Flooring of the Messbetrag to full euros would change the cents only; unresolved, see `business-tax.md`.

GmbH, Gewerbeertrag 60,000: no Freibetrag, Messbetrag 2,100, GewSt 8,400, no §35.

## GmbH, taxable profit 100,000, Hebesatz 400%

| Year       | KSt    | Soli   | GewSt (100,000 × 3.5% × 4) | Total            |
| ---------- | ------ | ------ | -------------------------- | ---------------- |
| 2026       | 15,000 | 825.00 | 14,000                     | 29,825 (29.825%) |
| 2028 (14%) | 14,000 | 770.00 | 14,000                     | 28,770           |

## Kleinunternehmer (§19 UStG from 2025)

| Prior-year turnover | Current-year turnover  | Result                                                        |
| ------------------- | ---------------------- | ------------------------------------------------------------- |
| 24,999              | forecast under 100,000 | exempt                                                        |
| 25,001              | any                    | regular taxation                                              |
| 25,000              | 100,000                | exempt (limits are "at most")                                 |
| 24,000              | reaches 100,001        | the invoice that crosses 100,000 and all later ones carry VAT |

## UStVA periods (prior-year tax)

| Prior-year tax | Period                                    |
| -------------- | ----------------------------------------- |
| 9,001          | monthly                                   |
| 9,000          | quarterly                                 |
| 2,001          | quarterly                                 |
| 2,000          | quarterly or exempt on Finanzamt decision |

## Degressive AfA

Straight-line rate for a 13-year life is 1/13 = 7.692%; degressive rate is 3 × that, capped at 30%: 23.08% (23.077% exact). A 10-year life gives 30% (3 × 10% = 30%). A purchase on 30 Jun 2025 is outside; 1 Jul 2025 and 31 Dec 2027 are inside (inferred from "acquired between"). Monthly pro-rating of the first year is statute knowledge, not in the research.

## Social insurance, gross 4,000 per month, 2026 (inferred)

Zusatzbeitrag 2.9%, employee with children, below BBG: RV 9.3% = 372.00; AV 1.3% = 52.00; KV 7.3% + 1.45% = 350.00; PV 1.8% = 72.00; total 846.00. Minijob limit 603 per month in 2026 (13.90 × 130 / 3 = 602.33, rounded up) and 556 in 2025 (12.82 × 130 / 3 = 555.53, rounded up).

## Deadlines (computed days of the week)

| Case                                             | Date                                                                         |
| ------------------------------------------------ | ---------------------------------------------------------------------------- |
| VZ 2025 self-filer                               | Fri 31 Jul 2026                                                              |
| VZ 2025 advised                                  | 28 Feb 2027 is a Sunday, so Mon 1 Mar 2027                                   |
| VZ 2026 self-filer                               | 31 Jul 2027 is a Saturday, so Mon 2 Aug 2027                                 |
| VZ 2026 advised                                  | Tue 29 Feb 2028                                                              |
| VZ 2024 advised                                  | Thu 30 Apr 2026                                                              |
| UStVA or LStA filing date 10 Jan 2027 (a Sunday) | Mon 11 Jan 2027, assuming §108 Abs. 3 applies (unverified for these filings) |

Verspätungszuschlag (§152 Abs. 5): assessed tax net of prepayments 4,000, return three started months late: 0.25% × 4,000 = 10 per month, minimum 25 per started month, so 75. Assessed tax 20,000, two started months: 50 per month, so 100. Cap 25,000. The 14-month mandatory threshold for VZ 2025 is end of February 2027.

## Lohnsteuer-Anmeldung period

| Prior-year Lohnsteuer | Period    |
| --------------------- | --------- |
| 5,001                 | monthly   |
| 5,000                 | quarterly |
| 1,081                 | quarterly |
| 1,080                 | annual    |

## Checklist generator consistency (EÜR)

For any generated EÜR: sum of income Kz (Kz 112, 103, 140, 141, 102, 106, 108 and the others of Z12 to Z22 that apply) equals Kz 159; sum of expense Kz equals Kz 199; Kz 219 equals Kz 159 − Kz 199 adjusted by the Z78 to Z96 lines (Kz 240-245, 180-182, 187, 250, 255, 290-293, 271). Run the same checks for tax years 2025 and 2026 and assert that the Kz sets are identical while the Zeile locators differ by +1 from Z27 in 2026.
