# Form 1040 computation, tax years 2025 and 2026

Tags: P primary, P-snip, S secondary, I inferred, K general knowledge. Figures are in `figures-2025-2026.md`.

## Computation order (I, from Form 1040 line placement)

1. Total income (line 9): wages (1a), taxable interest (2b), ordinary dividends (3b), capital gain or loss (7a via Schedule D / Form 8949), Schedule 1 income (business line 3, rental/K-1 line 5, other).
2. Adjustments (Schedule 1, line 26): half of SE tax (line 15), SE health insurance, SEP / solo 401(k) / SIMPLE, deductible IRA, HSA, student loan interest. Result: AGI (line 11).
3. Deduction (line 12): the larger of standard (plus age/blind additions) or itemized (Schedule A).
4. Line 13a QBI, line 13b Schedule 1-A total. Taxable income (line 15) = AGI minus lines 12, 13a, 13b, floored at zero.
5. Tax (line 16): Tax Table or worksheet; Qualified Dividends and Capital Gain Tax Worksheet or Schedule D Tax Worksheet when there are qualified dividends or long-term gain.
6. Other taxes (Schedule 2): SE tax, Additional Medicare (Form 8959), NIIT (Form 8960), AMT (Form 6251).
7. Credits (Schedule 3 and line 19): CTC, credit for other dependents, foreign tax credit (Form 1116), saver's credit, EITC (refundable, line 27), ACTC (refundable).
8. Payments: withholding, estimated tax, refundable credits. Result: refund or balance due.

Form line numbers change each year; store them as data on the checklist template, per tax year, and verify against the filed form each January.

## Tax Table method (the engine must reproduce it)

Status: the Tax Table is Form 1040 instructions practice. The research marks it as general IRS practice not fetched (K). The method below must be checked against the printed 2025 and 2026 Tax Table once before release.

Rules:

- Taxable income is a whole-dollar figure on the form. Round taxable income to whole dollars first (half up) when it comes from cents.
- Under $100,000 the tax is read from the Tax Table row that contains the taxable income. The row value is the tax on the midpoint of the row, rounded to a whole dollar (half up).
- Row widths: $50 from $3,000 to $100,000 (for example 61,700 to 61,750, midpoint 61,725); $25 from $25 to $3,000 (25-50, 50-75, ...); and three narrow rows 0-5, 5-15, 15-25 (midpoints 2.50, 10, 20; tax 0, 1, 2). "At least X, but less than Y": the top of a row belongs to the next row.
- At $100,000 and above use the Tax Computation Worksheet: the bracket formula on the exact whole-dollar taxable income, no midpoint.
- Midpoint tax is computed with the filing status's brackets of that year.
- Qualified Dividends and Capital Gain Tax Worksheet (K): it computes the tax on the ordinary part (taxable income minus qualified dividends and net long-term gain taxed at preferential rates) with the Table or worksheet by the same $100,000 rule, adds 0/15/20% tax on the preferential part, computes the tax on the whole taxable income by the same rule, and takes the smaller. Both Table lookups use the whole-dollar rule above.
- Implement as a pure function `usIncomeTaxFromTable(taxableIncomeCents, status, year) -> cents` beside `UsTaxYearTable`. The bracket function stays for estimates and for $100,000+.
- Midpoint of a $50 row is X + 25. Examples for single 2025: taxable 61,748 is in row 61,700-61,750, midpoint 61,725, tax 8,493.50, whole dollar 8,494 (the formula on 61,748 gives 8,498.56). Taxable 69,250 is in row 69,250-69,300, midpoint 69,275, tax 10,154.50, whole dollar 10,155 (formula on 69,250 gives 10,149.00).
- Estimated-tax planning, the "what if" features and opportunity savings may use the formula; the filed-return checklist must use the Table.

## Standard vs itemized

- Offer the larger; always show both. Standard deduction additions: per box checked for age 65+ and blind (amounts in the figures file); dependents use the dependent standard deduction; MFS where the spouse itemizes forces itemizing (K).
- SALT cap and phase-down: see `figures-2025-2026.md`. Algorithm: `cap = baseCap(year, status)`; if MAGI over threshold then `cap = max(floor, cap - 0.30 * (MAGI - threshold))`; deductible state and local taxes = min(actual, cap). MFS halves cap, threshold and floor. 2025: https://www.irs.gov/instructions/i1040sca (P).
- Medical over 7.5% of AGI; charity 30% (cash), 20% (capital-gain property) of AGI; 2026 charity 0.5% floor, non-itemizer cash deduction (1,000 / 2,000 MFJ); 2026 5.4% reduction. Do not apply the 2026 rules to 2025.
- Mortgage interest cap, filing thresholds and MFS SALT items: not read (K).

## Schedule 1-A (tax years 2025 to 2028 only)

Compute each deduction after AGI/MAGI is known, cap it, then phase it out. Never allow when the sunset year has passed (data: `lastTaxYear: 2028`).

- **Qualified tips:** deduction = min(tips eligible, 25,000) minus 100 per 1,000 (or portion of 1,000, treat as full: I, verify) of MAGI over 150,000 (300,000 MFJ), floor 0. Test vector: 25,000 at MAGI 170,000 gives 25,000 - 100 x 20 = 23,000.
- **Qualified overtime:** deduction = min(premium amount actually paid, 12,500 or 25,000 MFJ) minus 100 per 1,000 over 150,000 (300,000 MFJ). Only the premium (the "half" of time-and-a-half) counts.
- **Vehicle loan interest:** deduction = min(interest, 10,000) minus 200 per 1,000 (or portion) of MAGI over 100,000 (200,000 MFJ); zero at 150,000 / 250,000. Test vector: 8,000 interest at MAGI 120,000 gives cap 10,000 - 200 x 20 = 6,000, deduct 6,000. Needs VIN, new vehicle, US final assembly, loan originated after 31 December 2024; no joint-return requirement in the statute.
- **Senior:** 6,000 per person aged 65 by 31 December, minus 6% of MAGI over 75,000 (150,000 MFJ), floor 0. Whether a couple applies the 6% to the 150,000 joint threshold once to the 12,000 total or per person is not confirmed (Gaps; research says verify against the Schedule 1-A instructions).
- Eligibility inputs the app must collect: SSN present for taxpayer, spouse, and (for CTC) each child; occupation or payee statement for tips; employer or Form 4137 evidence; MFS cannot claim tips, overtime, senior.
- "Rounding of a partial 1,000": statute text for vehicle interest says "or portion thereof" (P); the same treatment for tips, overtime and senior is I until the Schedule 1-A instructions are read.
- 1040 line 13b gets the sum; the form is Schedule 1-A.
- Tips deduction for the self-employed is limited to the business's net income after other deductions and excludes SSTB (specified service trade or business) income. Overtime excludes tips.

## Child tax credit and EITC

- CTC: 2,200 per qualifying child under 17; ACTC up to 1,700 per child; phase-out above 200,000 (400,000 MFJ) at 50 per 1,000 (K); credit for other dependents 500. Requires SSN valid for employment, issued by the return due date including extensions.
- EITC: use the tables in the figures file; disqualified when investment income exceeds the limit (11,950 for 2025; 12,200 for 2026); MFS rules and the age/residency tests for 0 children are K.

## NIIT and Additional Medicare

- NIIT = 3.8% x min(net investment income, MAGI minus threshold). Thresholds: 250,000 MFJ/QSS, 125,000 MFS, 200,000 single/HoH. MAGI = AGI plus FEIE (P, Topic 559). Do not add tax-exempt interest to MAGI. Net investment income includes interest, dividends, capital gains, rents, royalties, annuities and passive income; it excludes wages, SE income, active business, tax-exempt interest. Form 8960.
- Additional Medicare Tax = 0.9% on Medicare wages plus SE income over the threshold (250,000 MFJ, 125,000 MFS, 200,000 other); employers withhold above 200,000 of wages regardless of status, and over-withholding is a credit on Form 8959. For SE income the threshold is reduced (not below zero) by Medicare wages; SE losses ignored. The base for the SE part is the 92.35% figure on Form 8959 (K; the research says verify).

## AMT (Form 6251)

- 26% and 28% rates; the 28% starts above 239,100 ($119,550 MFS) for 2025 and 244,500 ($122,250 MFS) for 2026. Exemptions and phase-outs in the figures file. OBBBA doubled the phase-out rate to 50% and reset thresholds for 2026 (I, computed and matching Rev. Proc. 2025-32).
- The app computes AMT only as a flag unless implemented in full: preference items (state tax add-back, ISO spread, private-activity bond interest) need input categories that do not exist. Prompt the user when AMT is plausible (large SALT, ISO exercises); do not silently report zero. The existing pack states "no AMT computed"; keep that assumption visible.

## Capital gains and losses

- Net short-term and long-term separately, then combine. Net long-term gain and qualified dividends are taxed at 0/15/20% with the bands stacked above ordinary taxable income (the bands in the figures file are on total taxable income).
- Net loss deduction 3,000 (1,500 MFS) per year, carryforward indefinite and keeps its character. The pack nets losses ST first then LT without a carryforward store; add carryforward as a profile input.
- Form 8949 rows come from the user's lots: description, dates, proceeds, basis, adjustment code, gain. Box choice depends on whether Form 1099-B reported basis (K).

## Pack status (as of 5 November 2026)

Implemented in `openbudget_core/lib/src/tax/us/`: brackets, standard deduction, LTCG bands, SE tax, QBI at or below the threshold with the 2026 minimum deduction, NIIT, simple Schedule C, 21% C-corp, estimated-tax and retirement opportunities. Not implemented or differing from this skill:

- No Tax Table (formula to the cent; no whole-dollar rounding).
- No Schedule 1-A, SALT cap, credits (CTC, EITC, other), AMT, age/blind or dependent standard deduction, itemized line detail, Additional Medicare on wages, Form 8959.
- `UsFilingStatus` has no qualifying surviving spouse.
- NIIT MAGI adds tax-exempt interest (should add FEIE only).
- QBI is zero above the threshold (no phase-in, no W-2 wage/UBIA, no SSTB).
- Home-office cap of 1,500 is applied to every amount entered, including Form 8829 actual expenses.
- No S-corp, payroll, 1099, Form 1116/2555/8938/FBAR, state detection.
- Keep `assumptions` on each report honest until each item is built.
