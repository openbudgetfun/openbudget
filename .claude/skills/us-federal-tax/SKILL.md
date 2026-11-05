---
name: us-federal-tax
description: US federal return preparation for calendar tax years 2025 and 2026 after the One Big Beautiful Bill Act (OBBBA, P.L. 119-21). Covers Form 1040 (brackets, standard deduction, IRS Tax Table, SALT cap, Schedule 1-A tips/overtime/car-loan/senior deductions, CTC, capital gains, NIIT, Additional Medicare, AMT), Schedule C/SE/QBI/home office/mileage/Section 179/bonus depreciation, retirement limits, Schedules B/D/E, Forms 8949/1116/2555/8938, FBAR, estimated tax, 1099 thresholds, S-corp (1120-S), C-corp (1120), LLC elections, payroll forms and state-return detection. Load before touching openbudget_core/lib/src/tax/us/, any US tax figure, or any Form 1040 box-by-box output.
---

# US federal tax

OpenBudget prepares a US federal return and shows a box-by-box checklist; the user reviews and files it (the app never files). This skill gives the rules a US rule pack must not get wrong for calendar tax years 2025 and 2026, the figures with their sources, and the test vectors.

Today is 5 November 2026. TY2025 returns were due 15 April 2026 (extended deadline 15 October 2026 has passed). TY2026 returns are due 15 April 2027; the only 2026 estimated payment still open is due 15 January 2027.

## When to use

- Editing `UsTaxYearTable`, `UsTaxRules`, US categories or any US figure (bracket, deduction, threshold, limit).
- Adding Schedule 1-A deductions, SALT cap, credits, AMT, Form 8959/8960, Tax Table logic or itemized-deduction rules.
- Building Schedule C/SE/QBI, depreciation (Form 4562), Schedule E, Schedule D/Form 8949, Form 1116/2555, FBAR/8938 prompts.
- Estimated-tax (Form 1040-ES / 2210 / 1120 estimates), safe-harbour or penalty features.
- 1099-NEC/MISC/K tracking, W-9 collection, payroll (941/940/W-2), S-corp or C-corp or LLC-election features.
- Deciding whether a user needs a state return.

## Source-of-truth rules

- Money is integer cents. No `double` for any amount or rate; rates are basis points or exact decimals. The IRS rounds to whole dollars on forms: compute in cents, round each form line to whole dollars (50 cents and up rounds up) when producing the checklist.
- Every figure lives in versioned per-tax-year data in `openbudget_core/lib/src/tax/us/` (`UsTaxYearTable`), with a source URL and a quality tag, never inline in UI or server code.
- Inflation-indexed figures are loaded per tax year. The 2027 figures (Rev. Proc. for 2027) were not published as of 5 November 2026. When they publish, add `usTaxYear2027` as new data, extend `supportedStartYears`, and keep 2025/2026 untouched. Do not extrapolate 2027 values. Statutory figures that move by formula (SALT cap 101% a year, SS wage base) are also data, loaded when the official number exists.
- Quality tags in the references: **P** primary (IRS, SSA, Treasury, IRB or statute text read in the research), **P-snip** (official page seen only through a search summary), **S** secondary (adviser, think tank, CRS, blog), **I** inferred (computed from cited inputs or reasoned), **K** general knowledge not read in the research. Never present S, I or K as settled; show a "verify" flag in the product.
- `rulesVerifiedOn` on every report must be the date the data was last checked against the sources.

## Core rules

1. **Tax Table below $100,000.** For taxable income under $100,000 the IRS Tax Table, not the bracket formula, gives the tax. The engine must reproduce it: take the midpoint of the band that contains the (whole-dollar) taxable income and apply the bracket formula to the midpoint, rounded to whole dollars. Bands are $50 wide from $3,000 to $100,000 and $25 wide from $25 to $3,000 (plus three narrow rows 0-5, 5-15, 15-25 at the bottom). At $100,000 and above use the Tax Computation Worksheet (the plain formula). The Qualified Dividends and Capital Gain Tax Worksheet uses the same rule for both of its comparisons. Details and examples in `references/individual-return.md`; vectors in `references/test-vectors.md` (formula and Tax Table results differ by $5 to $6).
2. **Computation order (Form 1040):** wages + business (Sch 1) + investment = total income; minus adjustments (half SE tax, SE health insurance, SEP/solo 401(k), IRA, HSA, student loan interest) = AGI; minus standard or itemized deduction; minus QBI (line 13a) and Schedule 1-A total (line 13b) = taxable income; tax by bracket/Table and the capital-gain worksheet; plus AMT, SE tax, NIIT, Additional Medicare; minus credits; minus payments. Placing QBI and Schedule 1-A below AGI is I (from line placement).
3. **OBBBA changes already law for 2025:** standard deduction $15,750 / $31,500 / $23,625; CTC $2,200; SALT cap $40,000 with 30% phase-down to a $10,000 floor; four Schedule 1-A deductions for 2025 to 2028 only; 100% bonus depreciation permanent for property acquired after 19 January 2025; Section 179 $2.5m/$4m; QBI permanent. The pre-OBBBA 2025 figures in Rev. Proc. 2024-40 are superseded for these items. Never use them.
4. **Schedule 1-A** (tips, overtime, passenger-vehicle loan interest, senior) is allowed with the standard deduction or itemizing, requires SSNs, and married filers must file jointly for tips, overtime and senior. MAGI adds back FEIE and other section 911/931/933 exclusions. Phase-outs and caps are in `references/individual-return.md`; the engine must model them, not skip them.
5. **SALT cap** is the lesser of the cap and the phase-down: cap minus 30% of MAGI over $500,000 ($505,000 for 2026), floored at $10,000 ($5,000 MFS). Add back FEIE for the threshold test. Cap: $40,000 (2025), $40,400 (2026), then +1% a year to 2029, then $10,000.
6. **Itemizing from 2026:** 0.5%-of-AGI floor on charitable gifts, 5.4% (2/37) reduction for high earners (exact mechanics S/P-snip), and a non-itemizer cash-gift deduction up to $1,000 ($2,000 MFJ). Do not apply these to 2025.
7. **Self-employment:** SE tax 15.3% on 92.35% of net profit (12.4% up to the wage base $176,100 in 2025, $184,500 in 2026; 2.9% uncapped; 0.9% Additional Medicare above $200,000/$250,000/$125,000 with the threshold reduced by wages). Half of the 15.3% part is an adjustment; Additional Medicare is not deductible. SE tax is owed at net earnings of $400 or more. FEIE does not reduce SE tax.
8. **QBI:** 20% deduction, lesser of 20% of QBI (net of half SE tax, SE health insurance and SE retirement contributions) or 20% of taxable income before QBI minus net capital gain. Above the threshold apply the W-2 wage/UBIA limit and SSTB phase-out (Form 8995-A). From 2026 the phase-in range is $75,000 ($150,000 joint) and a $400 minimum deduction applies with at least $1,000 of QBI from active businesses.
9. **Capital gains:** short-term is ordinary income; long-term and qualified dividends use 0/15/20% bands stacked on top of ordinary taxable income; 28% collectibles and Section 1202, 25% unrecaptured Section 1250 are special; net loss deduction $3,000 ($1,500 MFS), indefinite carryforward; Form 8949 then Schedule D. NIIT 3.8% on the lesser of net investment income or MAGI over $200,000 / $250,000 / $125,000 (MAGI adds back FEIE only; tax-exempt interest is not added back).
10. **Estimated tax:** pay four instalments (15 Apr, 15 Jun, 15 Sep, 15 Jan; shifted for weekends) if you expect to owe $1,000 or more; safe harbour is the smaller of 90% of current-year tax or 100% of prior-year tax (110% if prior-year AGI exceeded $150,000, $75,000 MFS). TY2025 dates: 15 Apr 2025, 16 Jun 2025, 15 Sep 2025, 15 Jan 2026. TY2026: 15 Apr, 15 Jun, 15 Sep 2026, 15 Jan 2027. Corporations: 15th day of months 4, 6, 9, 12 if tax is $500 or more.
11. **Information returns:** 1099-NEC/MISC threshold is $600 for payments made in 2025 and $2,000 for payments made after 31 December 2025 (indexed from 2027). 1099-K for payment apps (TPSOs) is back to over $20,000 and over 200 transactions. Payments to C/S corporations are generally not reportable (exceptions: attorneys, medical). Card and PayPal payments go on 1099-K, not 1099-NEC. Backup withholding 24%.
12. **Entities:** single-member LLC is disregarded by default (Schedule C or E); multi-member is a partnership; Form 8832 elects corporate status; Form 2553 elects S status (within 2 months 15 days of the tax year start). S-corp shareholder-employees must receive reasonable compensation before distributions; never output a single "correct" salary, show a facts-and-circumstances range and require user confirmation. C-corp pays a flat 21% (K, statute) on Form 1120.
13. **Foreign income:** citizens abroad choose FEIE (Form 2555: $130,000 for 2025, $132,900 for 2026) or foreign tax credit (Form 1116) per income; FBAR (FinCEN 114) over $10,000 aggregate; Form 8938 thresholds depend on residence and filing status. The app prompts for these and never computes penalties.
14. **State returns:** the app only detects whether a state return is likely required (residency periods, income by state, state rule table) and prompts; it does not compute state tax. Do not add state rates to the federal pack.

## Where it lives in OpenBudget

- `openbudget_core/lib/src/tax/us/us_tax_tables.dart`: `UsTaxYearTable`, `usTaxYear2025`, `usTaxYear2026`, source list, `usRulesVerifiedOn`.
- `.../us/us_tax_rules.dart` (`UsTaxRules implements TaxRulePack`): individual, Schedule C and C-corp reports; `.../us/us_tax_categories.dart`: category codes.
- Contract: `openbudget_core/lib/src/tax/tax_rule_pack.dart` (`applyTaxBands`, `sumBandTax`, `TaxInput`), `tax_model.dart`, `tax_profile.dart` (`UsTaxProfile`, `UsFilingStatus`).
- Tests: `openbudget_core/test/tax/us/us_tax_rules_test.dart`.
- New code belongs in the same folder: Tax Table lookup as a pure function beside the tables; Schedule 1-A, SALT, credits and AMT as separate pure functions called from `UsTaxRules`; S-corp and payroll as new entity kinds only after `TaxEntityKind` is extended in the contract. Server code calls the pack; it never repeats a figure.
- Pack status against this skill (as of 5 November 2026) is in `references/individual-return.md` ("Pack status"). Gaps include: no Tax Table, no Schedule 1-A, SALT, CTC, AMT, no `qualifyingSurvivingSpouse` filing status, NIIT MAGI adds tax-exempt interest, QBI is zero above the threshold, home-office cap applied to all methods.

## Testing

- Encode every vector in `references/test-vectors.md` for both methods (formula as a unit test of the bracket function; Tax Table as the return-level expectation under $100,000).
- Compare whole-dollar results exactly; in cents compare after the line rounding rules. No tolerance on rates or thresholds. Tolerance of 1 dollar only where a vector is marked I and the rounding order differs.
- Boundary tests: every threshold at, one cent below and one cent above (SALT phase-down start and floor, tip/overtime/senior/car-loan phase-outs, QBI threshold and phase-in end, NIIT/Additional Medicare thresholds, SS wage base, 1099 $2,000).
- Year tests: the same input must give different results for 2025 and 2026; an unsupported year (2027) must throw `UnsupportedTaxYearException`, not fall back.
- Failure paths: missing SSN flags for Schedule 1-A items, married-filing-separately cannot claim tips/overtime/senior, uncategorised entries listed in assumptions.

## Unverified and changing

Re-check dates: 2027 Rev. Proc. as soon as published (expected October to November 2026, not found on 5 November 2026; re-check by 1 December 2026); everything else before the TY2026 filing season opens (January 2027).

- 2027 inflation-adjusted figures and the 2027 SS wage base ($192,300 seen only in a search result, SSA page returned 403). Not settled.
- Schedule 1-A line mechanics: whether the senior phase-out is applied per person or on the aggregate for a couple; rounding of "or portion thereof" for tips, overtime and senior; the IRS tipped-occupation list. Not retrieved.
- CTC phase-out rate ($50 per $1,000 over threshold) and ACTC formula (15% of earned income over $2,500): statute, not read (K).
- 5.4% itemized-deduction reduction exact base and the 35% cap description: from IRS forms via search summary and a CRS report (S).
- FEIE stacking rule, Form 1116 limitation formula and carryover periods, housing base amount (16% of FEIE): not confirmed from IRS pages (K).
- Schedule B threshold ($1,500), Form 8949 box codes, 27.5-year rental depreciation, QBI rental safe harbour (250 hours), de minimis safe harbour ($2,500), Form 7004 six months, 21% corporate rate, individual late-filing penalties: not read (K).
- 2025 standard mileage rate (70 cents) derived from the 2026 notice and Schedule E instructions; Notice 2025-5 not read.
- HSA limits in the pack ($4,300/$8,550 for 2025; $4,400/$8,750 for 2026) are not in the research notes (K; verify against Rev. Proc. 2025-19 and Rev. Proc. 2024-25).
- Excess business loss 2026 threshold; Form 2210 and Schedule AI mechanics; FBAR penalty dollar figures; FUTA credit-reduction states; deposit schedules.
- State data (nine no-wage-tax states, flat-rate list, Washington capital-gains tax) is secondary (Tax Foundation); confirm with each state revenue department before relying on it.
- Information-return penalty amounts, 1099-K payee reporting, 2026 1099-K form revision.

## References

- `references/figures-2025-2026.md`: all figures by tax year with source URL and quality tag (brackets, deductions, LTCG, AMT, EITC, CTC, SALT, limits, thresholds).
- `references/individual-return.md`: Form 1040 computation, Tax Table method, Schedule 1-A, SALT, credits, NIIT, Additional Medicare, AMT, pack status.
- `references/business-and-entities.md`: Schedule C/SE, QBI, home office, mileage, 179/bonus, retirement plans, S-corp, C-corp, LLC, payroll, 1099.
- `references/schedules-international-estimates.md`: Schedules B/D/E, Forms 8949/1116/2555/8938, FBAR, estimated tax and safe harbours, state-return detection.
- `references/test-vectors.md`: worked examples with expected outputs for both methods.
