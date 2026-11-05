# Test vectors

Provenance: every number below was computed from the cited inputs in the research; none is IRS-published. "Formula" means the bracket formula on the exact amount. "Table" means the IRS Tax Table method in `individual-return.md` (midpoint of the row, whole dollars, half up), which applies to taxable income under 100,000. Table results were computed for this skill from that method and must be confirmed once against the printed Tax Table. Amounts in dollars; store cents.

## Income tax, formula vs Tax Table

| ID | Year, status                                                                           | Taxable income           | Formula                                                | Table (filed result)                                                    |
| -- | -------------------------------------------------------------------------------------- | ------------------------ | ------------------------------------------------------ | ----------------------------------------------------------------------- |
| A  | 2025 single, wages 85,000, standard deduction 15,750                                   | 69,250                   | 10,149.00                                              | 10,155 (row 69,250-69,300, midpoint 69,275: 10,154.50)                  |
| B  | 2025 MFJ, wages 150,000, two children under 17, standard 31,500                        | 118,500                  | 15,898.00 (above 100,000, formula is the filed method) | 15,898; CTC 2 x 2,200 = 4,400; tax after credits 11,498                 |
| C  | 2026 single, wages 60,000 plus 20,000 qualified dividends/LTCG, standard 16,100        | 63,900 (ordinary 43,900) | 7,187.50                                               | 7,191: ordinary 5,023 (row midpoint 43,925) + 15% line 2,168 (2,167.50) |
| D  | 2025 single age 66, wages 90,000 incl. 6,000 overtime premium, car-loan interest 3,000 | 58,150                   | 7,707.00                                               | 7,713 (midpoint 58,175: 7,712.50)                                       |
| E  | 2025 single sole proprietor, Schedule C profit 100,000                                 | 61,748 (see below)       | 8,498.56                                               | 8,494 (midpoint 61,725: 8,493.50)                                       |

Bracket arithmetic for A (2025 single): 11,925 x 10% = 1,192.50; (48,475 - 11,925) x 12% = 4,386.00; (69,250 - 48,475) x 22% = 4,570.50; total 10,149.00.
C: 2026 single ordinary part: 1,240.00 + (43,900 - 12,400) x 12% = 5,020.00 by formula; 0% LTCG room 49,450 - 43,900 = 5,550; remaining 14,450 x 15% = 2,167.50; formula total 7,187.50. In the Qualified Dividends worksheet the smaller of "ordinary + preferential" and "tax on all 63,900 as ordinary" is used (the latter is 8,776 by Table), so 7,191 stands.
D: Schedule 1-A total = 6,000 overtime + 3,000 interest + senior (6,000 - 6% x (90,000 - 75,000) = 5,100) = 14,100; standard deduction 15,750 + 2,000 = 17,750; taxable 90,000 - 14,100 - 17,750 = 58,150. Overtime premium is exempt from the 150,000 phase-out because MAGI is 90,000.

Table-boundary checks for single 2025 (I): taxable 4 gives 0; 5 gives 1; 14 gives 1; 24 gives 2; 25 gives 4 (midpoint 37.5 = 3.75); 2,999 gives 299 (midpoint 2,987.5); 3,000 gives 303 (midpoint 3,025); 3,049 gives 303; 3,050 gives 308; 10,000 gives 1,003; 99,999 gives 16,909; 100,000 and above use the formula (100,000 formula = 16,914.00, so the formula must never be used under 100,000 for the filed figure).

## Self-employment (TY2025-E, single, no other income, standard deduction)

- Net earnings 92,350; Social Security 12.4% = 11,451.40; Medicare 2.9% = 2,678.15; SE tax 14,129.55.
- Half SE 7,064.78 (rounded); AGI 92,935.22; taxable before QBI 77,185.22.
- QBI: 20% x (100,000 - 7,064.78) = 18,587.04; 20% x 77,185.22 = 15,437.04; deduction 15,437.04 (taxable-income limit binds). Taxable income 61,748.18.
- Formula tax 8,498.60 (research rounding) or 8,498.56 on 61,748 whole dollars; Table 8,494. Total tax = income tax + SE tax 14,129.55: formula 22,628.15, Table 22,623.55 (I).
- Safe harbour planning: 90% of 22,628.15 = 20,365.34, or 5,091.33 per quarter; if prior-year AGI under 150,000, 100% of prior-year tax is the alternative.

TY2026-F: net profit 250,000 gives net earnings 230,875; SS 12.4% x 184,500 = 22,878.00; Medicare 2.9% x 230,875 = 6,695.38; SE tax 29,573.38. Additional Medicare 0.9% x (230,875 - 200,000) = 277.88 for a single filer with no wages (base uses the 92.35% figure per Form 8959 mechanics; marked verify). Half SE tax adjustment excludes the 277.88.

S-corp comparison (TY2025, single owner, 200,000 net income before owner pay) (I): sole proprietor SE tax 27,192.70 (SS 21,836.40 + Medicare 5,356.30). S corp with salary 90,000: employer FICA 6,885 + employee FICA 6,885 = 13,770; FUTA 42; K-1 ordinary income 200,000 - 90,000 - 6,885 - 42 = 103,073 with no SE tax. Payroll-tax difference about 13,380 before compliance cost and QBI differences. Demonstrates the calculation only; salary level is the user's reasonable-compensation judgement.

## Section 179 (2026)

- 3,000,000 of qualifying purchases: under the 4,090,000 phase-out start, deduction limit 2,560,000.
- 4,500,000 of purchases: limit 2,560,000 - (4,500,000 - 4,090,000) = 2,150,000.

## Schedule 1-A and phase-outs (single unless noted)

- Tips 25,000 at MAGI 170,000: 25,000 - 100 x 20 = 23,000.
- Car-loan interest 8,000 at MAGI 120,000: cap 10,000 - 200 x 20 = 6,000; deduct 6,000. At MAGI 150,000 the cap is 0; at 149,999.99 the partial-thousand rule gives a cap of 10,000 - 200 x 50 = 0 (verify rounding).
- Overtime 12,500 MFJ at MAGI 320,000: cap 25,000 - 100 x 20 = 23,000; deduction limited by the actual premium 12,500.
- Senior single, age 66, MAGI 90,000: 6,000 - 6% x 15,000 = 5,100. MAGI 175,000: 6,000 - 6,000 = 0 (reached at 75,000 + 100,000).
- MFS filer claiming tips, overtime or senior: not allowed.
- Partial-thousand rounding for tips, overtime and senior: I (not read); encode as data with a verify flag.

## SALT

- 2025 MFJ, MAGI 520,000, state and local taxes 60,000: cap 40,000 - 30% x 20,000 = 34,000, deduction 34,000.
- 2025 MFJ, MAGI 600,000: cap 40,000 - 30% x 100,000 = 10,000 (the floor).
- 2026 single, MAGI 550,000: 40,400 - 30% x 45,000 = 26,900. The floor of 10,000 is reached at MAGI 505,000 + 30,400 / 0.30 = 606,333.33.
- MFS 2025: cap 20,000, threshold 250,000, floor 5,000.

## NIIT and Additional Medicare

- Single, wages 250,000: Additional Medicare 0.9% x 50,000 = 450.
- Single, MAGI 260,000, net investment income 30,000: NIIT 3.8% x min(30,000, 60,000) = 1,140.
- Tax-exempt interest 10,000 with MAGI 195,000 and NII 30,000 single: NIIT 0 (tax-exempt interest is not added to MAGI); FEIE 10,000 with the same figures adds to MAGI (205,000 gives 3.8% x 5,000 = 190).

## AMT phase-out (I)

- 2025 completes at 626,350 + 88,100 / 0.25 = 978,750.
- 2026 completes at 500,000 + 90,100 / 0.5 = 680,200, matching Rev. Proc. 2025-32.

## Estimated tax

- E1, TY2026: prior-year tax 20,000, prior AGI 160,000 gives 110% = 22,000; expected 2026 tax 30,000 gives 90% = 27,000; required annual payment min = 22,000, 5,500 per instalment. Withholding 8,000 (2,000 a quarter by default) leaves 14,000 of estimates, 3,500 each. With prior AGI 140,000: 100% x 20,000 = 20,000 required.
- E2, penalty sketch: a missed 5,500 Q3 2026 instalment (due 15 September 2026) paid on 15 April 2027 is 212 days; 5,500 x 7% x 212 / 365 = 223.6 simple. Q1 2027 rate unknown; use Form 2210 for a real figure.
- 2025 dates 15 Apr, 16 Jun, 15 Sep 2025, 15 Jan 2026; 2026 dates 15 Apr, 15 Jun, 15 Sep 2026, 15 Jan 2027.

## Payroll (TY2026)

- Wages 200,000: employee SS 11,439.00 (6.2% x 184,500), Medicare 2,900.00, Additional Medicare 0; employer SS 11,439.00, Medicare 2,900.00; FUTA 42.
- Wages 260,000: employee Medicare 3,770 plus Additional Medicare 0.9% x 60,000 = 540; employer Medicare 3,770.

## Foreign income

- FEIE partial year: 130,000 x 140 / 365 = 49,863.01 (shown as 49,863).
- Foreign wages 150,000, single abroad, 2025: FEIE 130,000, remaining taxable foreign wages 20,000; the tax is computed under the stacking rule (not implemented; do not ship without reading the foreign earned income tax worksheet).

## Entity illustration

- C corp, taxable income 100,000: tax 21,000 at 21% (K); distribution of 79,000 taxed at 15% to the shareholder is 11,850; combined 32,850.

## Failure and year tests

- Taxable income exactly 100,000: use the worksheet, not the Table.
- Taxable income 99,999.50 rounds to 100,000 for form purposes (half up) and then uses the worksheet; document the rounding order.
- Tax year 2027 input raises `UnsupportedTaxYearException`.
- Same inputs for 2025 and 2026 give different results (standard deduction, brackets, wage base, CTC unchanged at 2,200).
- 1099 threshold: 700 paid to a non-corporate payee in 2025 is reportable; in 2026 it is not; 2,000 is reportable in 2026.
