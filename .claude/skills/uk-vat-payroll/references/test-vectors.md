# Test vectors: HMRC published data samples and worked examples

Tags: **P** an HMRC-published number (read in HMRC's workbook, specification or guidance); **I** the researcher's own derivation. Prefer loading the full HMRC workbooks (see Testing in `SKILL.md`) over copying these samples; the samples below are a smoke set and a guide to the layout.

All 2026/27 unless stated. Money in pounds; assert in pence.

## 1. HMRC PAYE samples (P): rest of UK, code 1257L, cumulative monthly

Columns: gross pay this period, period, tax this period, tax to date. Tolerance 0.01 on tax.

| Gross               | Period | Tax             | Tax to date |
| ------------------- | ------ | --------------- | ----------- |
| 1,156.25            | M1     | 21.40           | 21.40       |
| 1,156.26            | M2     | 21.60           | 43.00       |
| 31,123.26           | M3     | 10,188.00       | 10,231.00   |
| 14,465.71           | M4     | 4,838.60        | 15,069.60   |
| 52,681.25           | M5     | 22,085.10       | 37,154.70   |
| 50,000.00           | M6     | 20,878.65       | 58,033.35   |
| 15,000.00           | M7     | 5,128.20        | 63,161.55   |
| 14,000.55           | M8     | 4,679.10        | 67,840.65   |
| 12,590.45 (code BR) | M9     | minus 29,406.05 | 38,434.60   |
| 11,245.05 (code NT) | M10    | minus 38,434.60 | 0.00        |

Weekly cumulative 1257L: 267.07 W1 5.00; 266.08 W2 4.80 (9.80); 853.05 W3 122.20 (132.00); 2,021.09 W4 355.80 (487.80); 9,834.16 W5 3,599.60 (4,087.40); 15,000 W6 6,375.68 (10,463.08); 242.84 W7 refund minus 264.87 (10,198.21); 243.83 W8 minus 264.43 (9,933.78); BR 632.84 W9 minus 4,061.78 (5,872.00); NT 2,893.83 W10 minus 5,872.00 (0.00).

Week 1 / Month 1: 45L monthly 39.24 gives 0.00; 39.25 gives 0.20; 3,164.24 gives 625.00; 3,164.25 gives 625.20; 10,450.24 gives 3,536.06; 10,500.78 gives 3,558.15; 12,539.24 gives 4,475.25; 12,539.25 gives 4,475.70; BR 99.99 gives 19.80; D0 99.99 gives 39.60; D1 99.99 gives 44.55. 145L weekly 29.05 gives 0.00; 29.06 gives 0.20; 750.06 gives 144.40; 2,913.06 gives 1,032.92.

K and large codes: K585 cumulative monthly 895 (276.60), 1,250 (347.60, to date 624.20), 765 (250.60, to date 874.80); K630 weekly 150 (54.20), 300 (84.20), 245 (73.40); K45 W1/M1 950 gives 197.60; K285 1,120 gives 271.60; K401 885 gives 243.80; 999L 2,500 monthly gives 333.20; 1000L 3,000 gives 433.00; 1001L 5,000 gives 1,037.66. Weekly large codes: 999L 750 gives 111.40; 1000L 900 gives 141.40; 1001L 1,500 gives 377.80.

Scotland S1257L cumulative monthly: 1,156.25 gives 20.33; 1,156.26 gives 20.52 (40.85); 31,123.26 gives 11,436.78 (11,477.63); then SBR M9 minus 35,496.19 (38,434.60); NT M10. Scottish W1/M1: S45L 3,164.24 gives 750.95; SD0 99.99 gives 20.79; SD1 41.58; SD2 44.55; SD3 47.52. SK585 cumulative: 895 gives 273.29; 1,250 gives 347.24 (620.53); 765 gives 245.70 (866.23). Wales C1257L cumulative monthly matches the rest-of-UK figures (21.40, 21.60 ...) and CBR M9 minus 29,406.05.

2025/26 Scotland: HMRC's workbook is 1p below the v24 Appendix B arithmetic in 9 rows (for example S45L month 1 on 3,164.24: spec 753.60, workbook 753.59). Assert plus or minus 0.01 there, not equality.

## 2. Derived PAYE examples (I)

See the table in `paye.md` section 7: 1257L free pay 241.92 / 1,048.26; 3,000 month 1 tax 390.20; month 2 390.40; 12 x 3,000 annual 4,684.00; 6,000 month 1 1,352.06; Scotland S1257L 3,000 month 1 392.27; Wales C1257L 6,000 month 1 1,352.06; BR 3,000.99 600.00; K1000 on 500 capped at 250.00 (the only vector for the 50% regulatory limit, labelled own-derivation, not HMRC).

## 3. HMRC NIC samples (P): category A, 2026/27

| Period   | Gross    | Employee | Employer |
| -------- | -------- | -------- | -------- |
| Weekly   | 96.03    |          | 0.00     |
| Weekly   | 96.04    |          | 0.01     |
| Weekly   | 129.00   |          | 4.95     |
| Weekly   | 242.07   | 0.00     | 21.91    |
| Weekly   | 242.08   | 0.01     |          |
| Weekly   | 481.03   | 19.12    | 57.75    |
| Weekly   | 966.64   | 57.97    | 130.60   |
| Weekly   | 967.05   | 58.00    | 130.66   |
| Monthly  | 417.04   |          | 0.01     |
| Monthly  | 559.00   |          | 21.30    |
| Monthly  | 1,048.08 | 0.01     | 94.66    |
| Monthly  | 2,083.05 | 82.80    | 249.91   |
| Monthly  | 4,189.05 | 251.28   | 565.81   |
| 2-weekly | 193.04   |          | 0.01     |
| 2-weekly | 258.00   |          | 9.75     |
| 2-weekly | 1,934.05 | 116.00   | 261.16   |
| 4-weekly | 385.04   |          | 0.01     |
| 4-weekly | 516.00   |          | 19.65    |
| 4-weekly | 3,867.05 | 232.00   | 522.31   |

Blank cells are values the note did not record; load the workbook for them. Derived (I): monthly 3,000 category A employee 156.16 employer 387.45; 6,000 employee 287.50 employer 837.45; category M or H 3,000 employer 0.00; B 3,000 employee 36.11; J 3,000 employee 39.04. Rounding vectors: weekly A 242.07 -> 0.00, 242.08 -> 0.01, 242.32 -> 0.02; category B 2-weekly 1,934.05 employee 26.82.

Directors (P, HMRC directors' workbook): see `nic-student-loans.md` section 4 (52,000 annual: employee 3,050.60, employer 7,050.00; weekly alternative arrangement 58.66 / 135.60, week 52 true-up 58.94 / 134.40; category M appointed 4 May 2026 on 48,000: employee 2,815.92, employer 239.40).

## 4. HMRC student loan samples (P)

Plan 1 weekly 528.41 gives 0; 528.42 gives 1. Monthly 2,252.77 gives 0; 2,252.78 gives 1; 8,586.11 gives 571. Thresholds: 2-weekly 1,034.61; 4-weekly 2,069.23; monthly 2,241.66. SL3 examples: Plan 1 weekly 565.00 -> 4; postgraduate monthly 2,083 -> 19; 25 days Plan 1 2,050 -> 18; 25 days postgraduate 1,998 -> 33. Plan 2 monthly 3,000 -> 49 (I).

## 5. Auto-enrolment and payslip (I)

Monthly 3,000: qualifying earnings 2,480; employee 124.00; employer 74.40. Full payslip: see `payroll-admin.md` section 4 (net pay 2,305.44, employer cost 3,461.85). SSP 2026/27: 5-day worker on 600 a week: 123.25 weekly, 24.65 daily; on 100 a week: 80.00. No HMRC vectors exist for auto-enrolment, SSP, 50% regulatory limit, payrolled benefits, negative pay, codes above 1001L, week 53/54/56 or irregular intervals.

## 6. VAT (I unless stated)

Standard quarter: box 1 11,600.00; box 3 11,600.00; box 4 4,100.00; box 5 7,500.00 payable; box 6 65,000; box 7 21,500; boxes 2, 8, 9 zero (inputs in `vat.md` section 8). Credit note issued net 1,000 VAT 200: box 1 minus 200, box 6 minus 1,000. Domestic reverse charge received net 10,000: box 1 + 2,000, box 4 + 2,000, box 7 + 10,000, box 6 unchanged. Flat Rate 14.5% on 30,000 inclusive: box 1 4,350.00; first year 13.5%: 4,050.00; limited cost 16.5%: 4,950.00. Cash accounting: invoice 20 September paid 5 October is next quarter. Annual accounting: four 25% instalments, year-end balance = box 5 minus instalments. Penalty (P, HMRC example): 15,000 paid 51 days late = 450 + 450 + 86.30 = **986.30**. Due dates: quarter ending 30 September 2026 due 7 November 2026; ending 31 October due 7 December.

## 7. Employer figures (I)

Sole director salary 12,570 paid monthly 1,047.50, category A, no Employment Allowance: employee NIC 0.00; employer NIC payment 5 = 35.62, payment 6 cumulative 192.75, payment 12 cumulative **1,135.50**; income tax 0.00. Director at the LEL: employer NIC 256.20 (2026/27), 225.00 (2025/26). With a second employee on 20,000: employer NIC 1,135.50 + 2,250.00 = 3,385.50, fully covered by the 10,500 Employment Allowance, 9,364.50 remaining after the director.

## 8. Property tests worth adding

- NIC: per-band rounded sum never differs from the exact decimal sum by more than 1p per band; NIC is monotonic in earnings within a category.
- PAYE: cumulative over 12 months equals the annual calculation (modulo the 1p tolerance); a Week 1 / Month 1 payment never depends on prior pay.
- Student loan: deduction is a whole number of pounds, non-negative, and zero at or below the truncated threshold.
- Director annual method: the sum of per-payment NIC equals the annual NIC computed on total earnings.
