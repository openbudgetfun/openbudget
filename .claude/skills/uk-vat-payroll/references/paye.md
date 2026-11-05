# PAYE income tax: HMRC "Specification for PAYE tax table routines" v24.0

Research date: 5 November 2026. This file supersedes the earlier reconstruction (whole-pound band limits, free pay 241.91 / 1,048.25, annual tax 4,684.20). Those were wrong. The researcher implemented the algorithm below and it reproduced all 336 rows of HMRC's published 2025/26 and 2026/27 PAYE test data (327 to the penny, 9 within HMRC's stated 0.01 tolerance, all 9 in the 2025/26 Scottish workbook). Those counts are the researcher's, not an HMRC statement.

Tags: **P** primary (the specification, rates pages or HMRC test workbook read directly), **I** inferred (the researcher's own computation from the specification).

Source: [Specification for PAYE tax table routines, v24.0, Feb 2026 (ODT)](https://assets.publishing.service.gov.uk/media/698c9824bd090be481c2879a/PAYErout-v24-0.odt), listed on [Payroll technical specifications: Income Tax](https://www.gov.uk/government/publications/payroll-technical-specifications-income-tax). v23.0 (January 2025) covered 2025/26. HMRC's own manual tells developers to use the specification ([PAYE70030](https://www.gov.uk/hmrc-internal-manuals/paye-manual/paye70030)). Scottish 2026/27 parameters were "subject to parliamentary approval" at issue.

## 1. Parameters (Appendices A to C)

England, Northern Ireland and Wales (Wales identical; prefix C) - **P**:

|   | Rate | Bandwidth | Cumulative band C | Cumulative annual tax K |
| - | ---- | --------- | ----------------- | ----------------------- |
| 1 | 10%  | 0         | 0                 | 0                       |
| 2 | 20%  | 37,700    | 37,700            | 7,540                   |
| 3 | 40%  | 87,440    | 125,140           | 42,516                  |
| 4 | 45%  |           |                   |                         |

G (basic-rate pointer) = 2; Maxrate M = 50%. Identical for 2025/26 and 2026/27.

Scotland (prefix S), rates 19 / 20 / 21 / 42 / 45 / 48% (SR1 to SR6) - **P**:

|         | SC1   | SC2    | SC3    | SC4    | SC5     | SK1    | SK2      | SK3      | SK4       | SK5       |
| ------- | ----- | ------ | ------ | ------ | ------- | ------ | -------- | -------- | --------- | --------- |
| 2025/26 | 2,827 | 14,921 | 31,092 | 62,430 | 125,140 | 537.13 | 2,955.93 | 6,351.84 | 19,513.80 | 47,733.30 |
| 2026/27 | 3,967 | 16,956 | 31,092 | 62,430 | 125,140 | 753.73 | 3,351.53 | 6,320.09 | 19,482.05 | 47,701.55 |

G1 = 2. The 2026/27 rates page agrees with these ceilings. Emergency codes 2026/27: 1257L W1, 1257L M1, 1257L X (2025/26 the same). A single emergency code applies to the whole UK, so no S or C prefix. Spec paras 3.3.2: allow tax codes up to 7 characters (example 999999T).

[Rates and thresholds for employers 2026 to 2027](https://www.gov.uk/guidance/rates-and-thresholds-for-employers-2026-to-2027), [2025 to 2026](https://www.gov.uk/guidance/rates-and-thresholds-for-employers-2025-to-2026).

## 2. Free pay and additional pay (spec para 4.3)

- Cumulative pay Pn = P(n-1) + pn, no rounding. pn includes payrolled benefits in kind (pbik). Para 1.5: "week" also means "month", and 52 means 12.
- Free pay (suffix codes L, M, N, T, P, V, Y) or additional pay (K, SK, CK prefix) for period n is **n times the Week 1 / Month 1 value**.
- Week 1 value from the numeric part of the code: 0 gives 0. For 1 to 500: annual value = (number x 10) + 9, divided by 52 (or 12), calculated to **4 decimal places without correction (truncated)**, then **rounded up to the next 1p**. Over 500: take quotient q and remainder r of (code minus 1) / 500, with r increased by 1; value = (r-value as above) + q x 96.16 (weekly) or q x 416.67 (monthly). 500 x 10 / 52 rounded up is 96.16; 500 x 10 / 12 rounded up is 416.67.
- **1257L: 241.92 weekly and 1,048.26 monthly** (not 241.91 / 1,048.25).
- K codes are annual negative allowances in steps of 10; negative allowances of 1 to 19 are code 0T. There is no K0. 0T is a suffix code with numeric part 0.
- Suffix letters play no part in the calculation (they only let HMRC uplift under P7X/P9X). All suffix codes including NT reset to cumulative on carry forward to a new year (para 15.6).
- Taxable pay to date Un: suffix codes Un = Pn minus n x a1; K codes Un = Pn + n x e1 (always go to the tax stage). If Un <= 0 for a suffix code, Ln = 0.

## 3. Tax to date (paras 3.3.4 and 4.4)

- Thresholds: c_i = C_i x n / 52 (or 12), to 4 dp **truncated**. Cvalue v_i = c_i rounded up to the next whole pound. Threshold tax k_i = K_i x n / 52, 4 dp truncated. Same for Scottish (Sc, Sv, Sk) and Welsh (Wk with the English c).
- Income Tests: is Un <= v1? then Formula 1; else Un <= v2? then Formula 2; and so on to Test x; if the last test fails use Formula x+1. **The test uses the unrounded Un.**
- Having chosen the formula, round Un **down to whole pounds** to give Tn. Formula 1: Ln = Tn x R1. Formula 2: Ln = k1 + (Tn minus c1) x R2. Formula 3: Ln = k2 + (Tn minus c2) x R3. General: Formula (x+1): Ln = k(x) + (Tn minus c(x)) x R(x+1). "Take the calculations for all Tax Formulae to 4 decimal places of a pound without applying any correction to the final place, and then finally round down the result if necessary to the nearest multiple of 1p below."
- With the English table B1 = 0, so Test 1 (Un <= 0) never selects Formula 1 for positive pay: Formula 2 gives 20% x Tn, Formula 3 gives k2 + (Tn minus c2) x 40%, Formula 4 gives k3 + (Tn minus c3) x 45%. Scotland tests against SC1 to SC5 and Formula 1 gives Tn x 19%.
- Manual Tables A and B to D round band ranges to whole pounds, so spec results can differ from manual-table results by 1p (rarely 2p). The optional refined calculation (para 16.2) is not recommended (para 16.4). HMRC accepts differences of up to 0.01: "As long as those results differ by no more than 0.01 then this is acceptable." (test workbook footer).
- The spec does not say whether the intermediate (Tn minus c) x R product is truncated separately; the researcher's tests could not distinguish the two readings (gap).

## 4. Period tax and the 50% regulatory limit (para 4.5, 8.3)

- Cumulative: ln = Ln minus L(n-1); positive is a deduction, negative a refund.
- **Regulatory limit:** maximum deducted = M (50%) x (pn minus pbik), 4 dp then rounded **down** to 1p. It applies to **all** tax codes (para 8.3), not just K codes. Where it bites on a cumulative code, Ln = L(n-1) + M x (pn minus pbik), so the shortfall is recovered later. On Week 1 / Month 1 the shortfall is not carried forward and need not be reported on P45 or P60. Refunds are not limited.
- Negative pay: set the limit for that payment to zero so cumulative refunds still work; on a Week 1 / Month 1 basis nothing is refunded and tax is nil (para 4.5.4).

## 5. Other code types

- **BR / SBR / CBR (cumulative):** taxable pay = cumulative pay rounded down to whole pounds, all at rate G (20%; SBR uses G1 = SR2 = 20%; CBR uses WR2 = 20%). Period tax = Ln minus L(n-1).
- **D0 / D1 / D2 (SD, CD):** whole rounded pay at rate G+1, G+2, G+3. England and Wales: D0 = 40%, D1 = 45%. **Scotland: SD0 = 21%, SD1 = 42%, SD2 = 45%, SD3 = 48%** (2026/27), not 40/45%. Confirmed by HMRC rows: SD0 99.99 gives 20.79; SD3 1,450.03 gives 696.00.
- **NT:** no tax; no S or C prefix. First applied cumulatively a refund of tax to date may be due (Ln = 0); on Week 1 / Month 1 do not refund.
- Leavers' later standard payments use 0T (S0T, C0T) non-cumulatively on week 1 or month 1 (CWG2 1.14): [CWG2 2026 to 2027](https://www.gov.uk/government/publications/cwg2-further-guide-to-paye-and-national-insurance-contributions/2026-to-2027-employer-further-guide-to-paye-and-national-insurance-contributions).
- **Week 1 / Month 1 (paras 8 to 11):** each payment is treated alone as the first of the year (n = 1, period 1/52 or 1/12): taxable pay = pay minus Week 1 free pay (or plus Week 1 additional pay for K); same tests and formulae; the regulatory limit uses this period's pay only. BR and D codes: pay rounded down to whole pounds x rate, result rounded down to 1p.
- **Irregular intervals (para 13):** cumulative codes use the table for the period containing the payment date; Week 1 / Month 1 uses the number of weeks (or months) since the last payment (last paid week 10, now week 13 gives the Week 3 table). BR, D and NT do not depend on interval.
- **Week 53, 54, 56 (para 14):** use the Week 1, Week 2 or Week 4 tables (weekly, fortnightly, four-weekly) on a non-cumulative basis with taxable pay rounded down and the regulatory limit applied. Fortnightly cumulative: first payment after 5 April uses week 2, then week 4 and so on; the 27th payday uses week 2 non-cumulatively. Four-weekly: weeks 4, 8, ...; the 14th payday uses week 4 non-cumulatively. Quarterly: months 3, 6, ...; half-yearly months 6 and 12; yearly month 12 (CWG2 1.7). Irregular intervals over a week but not a multiple: NIC exact percentage method with daily thresholds, and a cumulative code uses the week containing the payment date (week 53 uses week 52 unless HMRC says otherwise).
- Status change mid-year: the cumulative values Tn and Ln carry over; only the rate and band set changes (paras 1.3, 1.4).

## 6. Reference algorithm (validated; port to Dart with `Decimal` or scaled integers, never `double`)

```
free_pay_w1(num, N):                   # N = 52 or 12
  if num == 0: return 0.00
  (q, r) = divmod(num - 1, 500); r += 1
  base = ceil_to_1p( trunc4( (r*10 + 9) / N ) )
  return base + q * (96.16 if N == 52 else 416.67)

tax_to_date(code, P_n, n, N, region, year):
  if NT: return 0
  if BR: return floor_1p( floor_pound(P_n) * R[G] )
  if Dk: return floor_1p( floor_pound(P_n) * R[G+1+k] )      # k = 0..3
  a1 = free_pay_w1(num, N)
  U = P_n - n*a1   (suffix)   or   P_n + n*a1   (K)
  if U <= 0: return 0
  c_i = trunc4(C_i * n / N); v_i = ceil_pound(c_i); k_i = trunc4(K_i * n / N)
  T = floor_pound(U)
  f = lowest i with U <= v_i (UNROUNDED U); if none, f = x + 1   # x = number of cumulative bands
  if f == 1:  L = trunc4(T * R_1)
  else:       L = trunc4( k_(f-1) + trunc4((T - c_(f-1)) * R_f) )
  return floor_1p(L)
  # England: C = [0, 37700, 125140], R = [10%, 20%, 40%, 45%]; f is 2, 3 or 4 for positive pay

period_tax:
  cumulative: l = L_n - L_(n-1)        W1/M1: n = 1, L_(n-1) = 0, P = this pay only
  limit = floor_1p( 0.5 * (p_n - pbik) )   (0 if pay <= 0)
  if l > limit: l = limit; if cumulative: L_n = L_(n-1) + limit
```

## 7. Worked examples (2026/27, England, 1257L, monthly cumulative; I)

| Case                                  | Result                                                                                                                                                                                 |
| ------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Free pay 1257L                        | 241.92 weekly, 1,048.26 monthly                                                                                                                                                        |
| Gross 3,000, month 1                  | taxable 1,951.74, Tn 1,951, tax **390.20**                                                                                                                                             |
| Gross 3,000, month 2                  | Pn 6,000, free pay 2,096.52, Tn 3,903, Ln 780.60, period tax **390.40**                                                                                                                |
| 12 x 3,000                            | Tn = floor(36,000 minus 12,579.12) = 23,420, annual tax **4,684.00**                                                                                                                   |
| Gross 6,000, month 1                  | U 4,951.74 > v2 3,142: Formula 3: k2 628.3333 + (4,951 minus 3,141.6666) x 40% = 1,352.0666, tax **1,352.06**                                                                          |
| Scotland S1257L, gross 3,000, month 1 | Sv2 1,413 < U 1,951.74 <= Sv3 2,591: Sk2 279.2941 + (1,951 minus 1,413) x 21% = 392.2741, tax **392.27**                                                                               |
| Wales C1257L, gross 6,000, month 1    | identical to England: **1,352.06**                                                                                                                                                     |
| BR gross 3,000.99 M1                  | floor 3,000 x 20% = **600.00**; D0 1,200.00; D1 1,350.00; SD0 630.00; SD1 1,260.00                                                                                                     |
| K1000, gross 500, month 1             | additional pay 10,009 / 12 = 834.09, U 1,334.09, Tn 1,334, tables 266.80, but limit 50% x 500 = **250.00**; cumulative liability becomes 250.00; month 2 at 500 deducts another 250.00 |

The K1000 row is the researcher's own computation from spec paras 4.3 to 4.5; HMRC's published data has no regulatory-limit case. Gross 3,000 with a 124 net-pay pension: taxable = floor(3,000 minus 124 minus 1,048.26) = 1,827, tax 365.40.

Limits of the HMRC data: no 50% limit case, no pbik case, no negative pay, no code above 1001L, no week 53/54/56 or irregular interval case, and the 2025/26 Scottish workbook is 1p below the v24 Appendix B arithmetic (consistent with an SK3 of 6,351.83). The behaviours in those gaps come from specification text only.
