# Schedules B/D/E, Forms 8949/1116/2555/8938, FBAR, estimated tax, state detection

Tags: P primary, P-snip, S secondary, I inferred, K general knowledge. Figures: `figures-2025-2026.md`.

## Schedules B, D and Form 8949

- Form 8949 feeds Schedule D, which feeds Form 1040 line 7a; a net capital loss is limited to 3,000 (1,500 MFS) a year (P, https://www.irs.gov/taxtopics/tc409).
- Schedule B is required when interest or dividends exceed the reporting threshold: 1,500 (K, not retrieved in the research); also required for foreign accounts questions (Part III, K).
- Capital gain distributions (Form 1099-DIV box 2a) go to line 7a directly when there is no other Schedule D reason (K).
- Special rates: 28% collectibles and Section 1202, 25% unrecaptured Section 1250 (P, Topic 409). Wash-sale adjustments (code W on Form 8949) and the holding-period rule (more than one year for long-term) are K.

## Schedule E (P, https://www.irs.gov/instructions/i1040se)

- Part I rental and royalty: line 3 rents received, 4 royalties, expenses lines 5 to 19 (6 auto and travel at 70 cents a mile for 2025; 12 and 13 mortgage interest; 14 repairs; 17 telephone; 18 depreciation and depletion; 19 other), 20 total expenses, 21 income or loss after at-risk (Form 6198), 22 after passive limits (Form 8582), 23a to 23e totals. Residential rental depreciation is 27.5 years (K).
- Passive loss allowance 25,000 (12,500 MFS) needs active participation and MAGI of 100,000 or less (50,000 MFS); the allowance phases out above that (K); otherwise Form 8582.
- Real estate professional: more than half of personal services and more than 750 hours in real property trades or businesses with material participation; election to aggregate. Vacation-home rule: personal use over the greater of 14 days or 10% of rental days; under 15 rental days, no income or deductions.
- Part II partnerships and S corporations (K-1). Form 7203 for S-corp shareholders with losses, distributions or stock disposals.
- NIIT applies to rents, royalties and passive income (P, Topic 559). QBI rental safe harbour (250 hours) is K.

## Foreign income: Form 1116 vs Form 2555

- **FEIE (Form 2555):** 130,000 (2025), 132,900 (2026); both spouses qualifying up to 260,000 for 2025 (P). Tests: bona fide residence for a full tax year, or physically present 330 full days in any 12 consecutive months. Only personal-service earned income. No deductions against excluded income (pro-rated). Partial year pro-rated by qualifying days over 365 (example 130,000 x 140/365 = 49,863; P). Housing exclusion computed first; FEIE limited to earned income minus housing exclusion. Housing limit 30% of FEIE (39,000 for 2025, 39,870 for 2026); location caps in Notice 2026-25 (P). Housing base amount 16% of FEIE (I). Form 2555 attaches to Form 1040.
- Excluded income still counts toward MAGI for NIIT, Schedule 1-A and SALT phase-outs (statute, P).
- Stacking rule (tax on remaining income computed as if the exclusion sat at the bottom of the brackets) and the no-double-benefit rule for foreign tax credit on excluded income: K, not confirmed in fetched pages. Do not ship FEIE tax computation until the Form 1040 instructions foreign earned income tax worksheet is read.
- **Form 1116:** skip the form when all foreign income is passive, shown on payee statements, and creditable foreign tax is at most 300 (600 MFJ). Separate form per category: section 951A, foreign branch, passive, general (plus 901(j), treaty re-sourced). OBBBA: the new senior deduction must be removed from taxable income in the limitation computation (2025 to 2028); 10% of certain taxes on section 959(a) amounts is disallowed after 28 June 2025 (P, https://www.irs.gov/instructions/i1116). Limitation formula and carryback 1 year / carryforward 10 years: K.
- **Abroad deadlines (P, Pub. 54):** automatic 2-month extension to 15 June for taxpayers abroad on the due date; letter request for 15 December; Form 4868 extends to 15 October. Net SE earnings of 400 or more require a return regardless of gross income. TY2026 abroad return: 15 June 2027 automatic, 15 October 2027 extended (I).
- Engine data (I): per-person Form 2555 inputs (qualifying days, tax home, housing amounts); either exclusion or credit on the same income, not both.

## FBAR (FinCEN 114) and Form 8938

- FBAR: aggregate foreign account value over 10,000 at any time in the calendar year; filed electronically with FinCEN via BSA E-Filing, not with the return; due 15 April with automatic extension to 15 October (no request); non-willful penalty up to 10,000 (inflation-adjusted), willful up to the greater of 100,000 (adjusted) or 50% of the balance. TY2026: 15 April 2027, extended 15 October 2027 (I). Covers accounts at foreign branches of US institutions and signature-authority accounts. (P, https://www.irs.gov/newsroom/how-to-report-foreign-bank-and-financial-accounts, https://www.irs.gov/newsroom/details-on-reporting-foreign-bank-and-financial-accounts)
- Form 8938 (attached to the return, due with it including extensions): US residents unmarried more than 50,000 on the last day or 75,000 at any time; MFJ 100,000 / 150,000; abroad unmarried 200,000 / 300,000; MFJ 400,000 / 600,000. Penalty up to 10,000 plus up to 10,000 per 30 days after notice (maximum 60,000). Covers foreign stock and securities not held in accounts, foreign partnership interests, hedge and private-equity funds. Neither form covers directly held foreign real estate, currency, precious metals or personal property. Both forms may be required (P, https://www.irs.gov/businesses/comparison-of-form-8938-and-fbar-requirements).
- The "abroad" 8938 thresholds use the same residence tests as FEIE (I; Gaps).
- Engine (I): per-account maximum value in USD at the Treasury year-end rate (rate source not fetched); aggregate for FBAR; a single account at 10,001 triggers the FBAR for the whole set. Product behaviour: prompt and checklist only; never compute or display a penalty as a liability. FBAR civil penalty current dollar amounts (31 CFR 1010.821) were not retrieved.

## Estimated tax (Form 1040-ES, 2210) (P, https://www.irs.gov/businesses/small-businesses-self-employed/estimated-taxes, https://www.irs.gov/publications/p505)

- Required when you expect to owe 1,000 or more after withholding and credits (corporations 500). Four instalments; each is 25% of the required annual payment unless the annualised income method (Form 2210 Schedule AI) is used.
- Required annual payment = smaller of 90% of current-year tax or 100% of prior-year tax (the prior return must cover 12 months); 110% if prior-year AGI exceeded 150,000 (75,000 MFS). Farmers and fishers: 66 2/3% of current tax with a single 15 January date, or file by 1 March and pay all tax.
- Dates, TY2025: 15 Apr 2025, 16 Jun 2025, 15 Sep 2025, 15 Jan 2026 (I). TY2026: 15 Apr, 15 Jun, 15 Sep 2026, 15 Jan 2027 (P, Pub. 505 2026). TY2027 (I, verify when Pub. 505 publishes): 15 Apr, 15 Jun, 15 Sep 2027, 18 Jan 2028. The January payment is not required if you file by 31 January and pay in full.
- Withholding is treated as paid in equal fourths unless you elect actual dates. Additional Medicare and NIIT must be included in the estimate; estimates can cover SE tax and AMT.
- Penalty (I from the Form 2210 simplified view): underpayment x quarterly rate x days outstanding / 365. Rates: 7% Q1 2026, 6% Q2, 7% Q3, 7% Q4 (P, https://www.irs.gov/payments/quarterly-interest-rates); Q1 2027 unknown. Waivers for casualty or disaster, or retired after 62 or disabled with reasonable cause. Use the Form 2210 line method for any real figure; label simple computations as estimates.
- Late filing and payment penalties for individuals (5% and 0.5% a month, 25% cap, 60-day minimum penalty) are K; corporate numbers are in `business-and-entities.md`.
- Worked case and penalty sketch: `test-vectors.md` (E1, E2).

## State-return detection (S, https://taxfoundation.org/data/all/state/state-income-tax-rates-2026/)

- The app only needs to say whether a state return is likely required. Data model (I): `residency_periods[] {state, start, end}`, `income_by_state[] {state, type: wage|self_employment|rental|capital_gain|k1, amount}`, entity registration states, and a rule table `{state, taxes_wages, taxes_interest_div, taxes_cap_gains, has_business_level_tax, conforms_to_federal_agi}`.
- A state return is likely required if the user was resident in a state that taxes the income type, earned source income in a taxing state (nonresident return), or an S corp must file a composite or pass-through-entity return.
- No tax on wages (9): Alaska, Florida, Nevada, New Hampshire, South Dakota, Tennessee, Texas, Washington, Wyoming (S). Washington taxes capital gains only (top rate 9% over 1,000,000, retroactive to 1 January 2025). Missouri taxes wages but exempts capital gains. New Hampshire repealed its interest and dividends tax from 2025 and keeps a Business Profits Tax (7.5%, S).
- Flat-rate states 2026 (S): AZ 2.50%, CO 4.40%, GA 5.19%, ID 5.30%, IL 4.95%, IN 2.95%, IA 3.80%, KY 3.50%, LA 3.00%, MI 4.25%, MS 4.00%, NC 3.99%, OH 2.75% over 26,050, PA 3.07%, UT 4.50%. Do not use these to compute tax; store only for prompts.
- Some states do not conform to the OBBBA standard deduction increase; some keep lower 1099-K thresholds (S, P-snip).
- Sales tax, franchise and gross-receipts taxes (Washington B&O, Texas franchise, New Hampshire BPT) and pass-through-entity tax workarounds for the SALT cap are separate registrations: prompt only. Local income taxes, reciprocity agreements and state sales-tax rules were not researched.
- Primary state revenue-department confirmation of this table is still missing.
