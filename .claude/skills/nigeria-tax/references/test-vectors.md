# Test vectors

Provenance: all numbers are my computations from the gazetted rates or the cited secondary sources; none is published by the NRS or a State IRS. Per the research they are candidate vectors to confirm against the NRS and State IRS calculators before the product states them as authoritative. Amounts in naira; store kobo. Rounding: round each slice down to a whole kobo (as the pack does). Vectors marked (S) depend on secondary sources.

## Personal income tax, 2026 (NTA bands, no other deductions)

| ID  | Chargeable income | Tax                                        |
| --- | ----------------- | ------------------------------------------ |
| T1  | 800,000           | 0                                          |
| T2  | 1,000,000         | 30,000                                     |
| T3  | 3,000,000         | 330,000                                    |
| T4  | 5,100,000         | 708,000 (330,000 + 18% x 2,100,000)        |
| T4b | 5,500,000         | 780,000                                    |
| T5  | 12,000,000        | 1,950,000                                  |
| T6  | 25,000,000        | 4,680,000                                  |
| T7  | 50,000,000        | 10,430,000                                 |
| T8  | 60,000,000        | 12,930,000 (10,430,000 + 25% x 10,000,000) |

Also test one kobo either side of each band top (for example 800,000.01 gives 0.15 naira of tax).

## Rent relief (s.30(2)(a)(vi))

- Rent 1,200,000: relief 240,000. Rent 2,500,000: relief 500,000 (exactly the cap). Rent 3,000,000: relief 500,000. Rent 0: relief 0. Rent 1,500,000: relief 300,000.

## Employee, gross 6,000,000, 2026

- Pension 400,000, NHF 100,000, rent paid 2,000,000. Rent relief = min(400,000, 500,000) = 400,000. Deductions 900,000. Chargeable 5,100,000. Tax 708,000 (T4). Average monthly PAYE 59,000.
- Without rent: chargeable 5,500,000, tax 780,000.

## 2025 old regime comparison (S, PwC and secondary calculator write-ups)

- O1, gross 6,000,000, pension 400,000, NHF 100,000: CRA = max(200,000, 60,000) + 1,200,000 = 1,400,000; taxable 4,100,000; tax = 21,000 + 33,000 + 75,000 + 95,000 + 336,000 + 24% x 900,000 (216,000) = 776,000.
- O2, minimum tax, gross 300,000: CRA 200,000 + 60,000 = 260,000; taxable 40,000; progressive tax 2,800; minimum tax 3,000 (1% of gross); payable 3,000.
- O3, gross 30,000,000, no other reliefs: 2025 CRA = max(200,000, 300,000) + 6,000,000 = 6,300,000; taxable 23,700,000; tax 5,480,000. 2026 with no rent: 5,830,000; 2026 with rent relief 500,000: chargeable 29,500,000, tax 5,715,000. A high earner without rent can pay more under the new law.

## Minimum wage (configurable amount; I)

- Gross employment income at or below the configured minimum wage (annual comparison unit): tax 0. Just above: normal bands, first 800,000 at 0%. Test the monthly-vs-annual unit explicitly and surface the assumption.

## Sole proprietor, 2026

- Turnover 18,000,000; allowable expenses 9,000,000; pre-allowance profit 9,000,000. Capital allowance on 1,000,000 of class 2 equipment at 20% = 200,000 (one year; method unconfirmed). Total income 8,800,000. Rent paid 1,500,000, relief 300,000. Chargeable 8,500,000. Tax = 330,000 + 18% x 5,500,000 = 1,320,000. VAT: small business (turnover under N100m, not professional): no registration or returns unless opted in.
- Loss: 1,000,000 trade loss carried forward; next year profit 4,000,000 gives 3,000,000 after relief before other deductions.

## Companies, 2026 basis (resident)

| ID  | Facts                                                                                                               | CIT       | Levy    | Total     |
| --- | ------------------------------------------------------------------------------------------------------------------- | --------- | ------- | --------- |
| C1  | Turnover 40,000,000, fixed assets 100,000,000, non-professional, profit 8,000,000                                   | 0         | 0       | 0         |
| C2  | Turnover 80,000,000 under the gazetted N50m definition (not small), assessable profit 10,000,000, no allowances     | 3,000,000 | 400,000 | 3,400,000 |
| C2b | Same as C2 if the N100m figure is selected                                                                          | 0         | 0       | 0         |
| C3  | Assessable profit 20,000,000; loss brought forward 2,000,000; capital allowance 5,000,000; total profits 13,000,000 | 3,900,000 | 800,000 | 4,700,000 |

- C3: levy base is assessable profit before losses and allowances (I; verify). C2 and C2b must both be reachable through the configurable small-company parameter with the warning shown.
- Boundary: turnover exactly N50,000,000 is small under the NTA; N50,000,000.01 is not; fixed assets N250,000,000 inclusive; professional services always not small.
- Minimum ETR: applies only at aggregate turnover of N20,000,000,000 or more or MNE constituents; below that, skip.

## VAT

- Monthly return: sales 1,000,000 net: output VAT 75,000; input on services 400,000 net: input VAT 30,000; net payable 45,000, due by the 21st of the next month. Zero-rated supply: output VAT 0, input VAT 30,000 recoverable and refundable on request.
- Apportionment: input VAT 100,000 of which 60% relates to taxable supplies: recoverable 60,000.
- Small business (turnover N100m or less, fixed assets N250m or less, not professional): no return duty; opted-in business files monthly.
- Medical services, basic food and tuition: zero-rated (output 0, input recoverable); land and buildings: exempt (output none, input not recoverable).

## WHT (S, 2024 Regulations rate table, resident payee with TIN)

- W1: consultant individual paid 500,000: 5% = 25,000; net 475,000.
- W2: goods from a trading company worth 1,000,000: 2% = 20,000.
- W3: same purchase, vendor without TIN: 2 x 2% = 40,000.
- W4: director's fee 1,000,000 to a resident individual: 15% = 150,000.
- W5: rent 2,000,000 to a company landlord: 10% = 200,000.
- The payer-side small-supplier exemption test uses N25m / N2m (S), not the company or VAT thresholds.

## Capital gains and digital assets (individual)

- G1: share sale, proceeds 100,000,000, gain 9,000,000: exempt (proceeds under 150m and gain at or under 10m).
- G2: proceeds 200,000,000, gain 30,000,000: taxable; add 30,000,000 to total income.
- G3: employment chargeable income 5,100,000 plus taxable gain 5,000,000 = 10,100,000; tax = 330,000 + 18% x 7,100,000 = 1,608,000.
- G4: crypto gain 2,000,000 and stock-market loss 3,000,000: the loss cannot be set against the crypto gain; chargeable gain stays 2,000,000.
- G5: crypto gain 2,000,000 and crypto loss 500,000: net 1,500,000.
- G6: chattel sale 4,000,000: exempt (below N5m); 6,000,000: taxable unless three times the annual minimum wage is higher.
- G7: company asset sale with a 10,000,000 gain: added to total profits, taxed at 30% = 3,000,000, unless small company (0%).
- Boundaries: proceeds exactly N150,000,000 is not exempt (strictly less than); gain exactly N10,000,000 meets the gain limit.

## Penalties and interest (S for the interest order)

- P1: registration default of 4 months: 50,000 + 3 x 25,000 = 125,000.
- P2: late filing of 3 months: 100,000 + 2 x 50,000 = 200,000. Unfiled 2025-income return on 5 November 2026 with April 2026 as month 1 is month 8: 100,000 + 7 x 50,000 = 450,000 (month counting unconfirmed).
- P3: late payment of 1,000,000 for 90 days at a placeholder 30% a year: penalty 100,000; interest 1,000,000 x 0.30 x 90 / 365 = 73,972.60. Use only in tests: the real rate is the NRS monthly rate (not yet found); day-count basis unknown.

## Foreign income

- Resident with foreign employment or business income 10,000,000 (taxed abroad at 1,500,000) and total income 20,000,000, no deductions: Nigerian tax 3,630,000 (1,950,000 + 21% x 8,000,000); attributable = 10/20 x 3,630,000 = 1,815,000; credit = min(1,815,000, 1,500,000) = 1,500,000; payable 2,130,000.
- Resident with 3,000,000 of UK dividends received through approved channels: exempt (s.163(1)(s)); credit moot.

## Transition mapping

- Individual, income earned 2025, filed 2026: old regime; income earned 2026: NTA.
- Company year ending 31 December 2025: old law; 30 June 2026: NTA for the whole period; 31 December 2026: NTA.
- Goods delivered 20 December 2025, paid 15 January 2026: old VAT and WHT law.
- Unsupported basis year (2027 data not loaded): throws `UnsupportedTaxYearException`.
