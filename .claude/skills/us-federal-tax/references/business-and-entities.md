# Self-employment, business deductions, entities, payroll and information returns

Tags: P primary, P-snip, S secondary, I inferred, K general knowledge. Figures: `figures-2025-2026.md`.

## Schedule SE and self-employment tax

- Owed when net earnings from self-employment are 400 dollars or more (P, https://www.irs.gov/taxtopics/tc554). Net earnings = net profit x 92.35%. Church-employee threshold 108.28.
- SE tax = 12.4% up to the wage base (reduced by W-2 wages already subject to Social Security) + 2.9% on all net earnings. Additional Medicare 0.9% is separate (Form 8959) and not deductible. Half of the 12.4% + 2.9% part is a Schedule 1 adjustment (line 15).
- Wage base: 176,100 (2025), 184,500 (2026). FEIE does not reduce SE tax (P).
- Optional methods exist for low income (P, Topic 554); not modelled.
- Schedule SE feeds Schedule 2. Losses from SE reduce nothing for SE tax (net earnings below zero count as zero).
- Statutory employees report W-2 box 1 as Schedule C line 1.

## Schedule C (2025 form line map, P, https://www.irs.gov/instructions/i1040sc)

- Part I: line 1 gross receipts, 2 returns and allowances, 6 other income, 7 gross income.
- Part II: 8 advertising (K), 9 car and truck, 10 commissions and fees, 11 contract labor, 12 depletion, 13 depreciation and Section 179 (Form 4562), 14 employee benefit programs, 15 insurance (not health), 16a/16b interest, 17 legal and professional, 18 office, 19 pension and profit sharing, 20a/20b rent or lease, 21 repairs, 22 supplies, 23 taxes and licenses, 24a travel, 24b deductible meals (50%; 80% for DOT-regulated workers), 25 utilities, 26 wages, 27a energy-efficient commercial buildings deduction, 27b other (Part V), 28 total expenses, 29 tentative profit, 30 business use of home, 31 net profit or loss.
- Part III cost of goods sold (lines 33 to 42), Part IV vehicle information, Part V other expenses (amortization, bad debts, start-up costs, de minimis safe harbour). Line numbers 3-5, 7-8, 28-29, 32 and 32-47 were not captured in the research text; store the form map as per-year data and confirm against the printed form.
- The tips deduction is on Schedule 1-A, not Schedule C. A Schedule C loss may be limited by the excess business loss rule (Form 461): 626,000 joint / 313,000 others for 2025 (P); 2026 not found.
- De minimis safe harbour (2,500 per item or invoice, K), 50% meals, employer-provided meals largely nondeductible from 2026 (P).

## Home office (P, https://www.irs.gov/publications/p587)

- Simplified: 5 dollars x business square feet, maximum 300 sq ft, maximum 1,500; cannot exceed gross income from the business use; no depreciation; unrelated business expenses remain deductible.
- Regular (Form 8829): area used exclusively and regularly (principal place of business, etc.); actual expenses limited to gross income from the business use with carryover; depreciation on the business portion of an owned home as 39-year nonresidential property in the first year; result to Schedule C line 30. Employees cannot deduct.
- The app must ask which method; the 1,500 cap applies only to the simplified method.

## Vehicle

- Standard mileage rate: business 72.5 cents (2026), 70 cents (2025, I/P Schedule E); medical and moving 20.5 (2026), 21 (2025); charitable 14 both years (P). Use the actual-expense method only with Form 4562 depreciation and a mileage log; a mileage log (date, miles, purpose) is required either way (K). Choosing standard mileage in the first year the car is used for business generally locks that method (K).
- Passenger-vehicle loan interest (Schedule 1-A) is a personal-use deduction; business vehicle interest goes on Schedule C line 16 (K).
- Section 179 SUV cap 32,000 (2026), 31,300 pre-OBBBA 2025 (superseded for the limit and phase-out; the SUV cap for 2025 is not restated in the notes: verify).

## Section 179 and bonus depreciation (P)

- 2025: 2,500,000 limit, phase-out start 4,000,000 (OBBBA). 2026: 2,560,000 / 4,090,000 (Rev. Proc. 2025-32). The limit is reduced dollar for dollar above the phase-out start: 4,500,000 of purchases in 2026 gives 2,560,000 minus 410,000 = 2,150,000.
- Section 179 is limited to business taxable income (K); Form 4562 Part I.
- Bonus (168(k)): 100% permanent for property acquired after 19 January 2025; elect-out by class; 40% or 60% election for the first year ending after 19 January 2025 (Notice 2026-11). Acquisition date, not placed-in-service date, decides eligibility: store `acquired_on` on every asset.
- Qualified production property 100% expensing (168(n)) and Section 174A: see the figures file.
- MACRS classes and 27.5/39-year buildings: K; not read.

## QBI, Section 199A (P, https://www.law.cornell.edu/uscode/text/26/199A, https://www.irs.gov/instructions/i8995)

- Deduction (line 13a) = lesser of combined QBI amount or 20% x (taxable income before QBI minus net capital gain including qualified dividends). Permanent (OBBBA removed the sunset).
- QBI = business profit minus half SE tax, SE health insurance and SE retirement contributions (I, from QBI regulations not fetched).
- At or below the threshold use Form 8995; above use Form 8995-A with the W-2 wage / UBIA limit (greater of 50% of W-2 wages, or 25% of wages plus 2.5% of UBIA) and the SSTB phase-out. Negative QBI carries forward.
- Thresholds: see the figures file. 2026 phase-in range is 75,000 (150,000 joint); minimum deduction 400 when QBI from active businesses is at least 1,000 (material participation).
- The engine must not return zero above the threshold. Implement at least the phase-in and SSTB logic, or refuse to compute and show a "needs Form 8995-A" flag.

## Retirement plans for the self-employed

- Limits in the figures file. SEP: 20% of net SE earnings (net of half SE tax) for a sole proprietor; contribution limit 70,000 (2025), 72,000 (2026). Solo 401(k): employee deferral (23,500 / 24,500) plus employer contribution, total capped at 415(c); sole-proprietor employer rate is 20% of net SE earnings after half SE tax (25% for corporations) (K, Pub. 560; research Gaps).
- Deadline: SEP and employer contributions by the return due date including extensions; solo 401(k) employee deferrals must be elected by year end (K).
- SE health insurance (162(l)): deductible above the line, limited to net profit from the business, not allowed in any month eligible for a subsidised employer plan (K). S corporation more-than-2% shareholders: premiums go in W-2 box 1 only (not boxes 3 and 5), the shareholder takes 162(l) if the S corp established the plan; they cannot use QSEHRA, FSA or HRA (P, https://www.irs.gov/businesses/small-businesses-self-employed/s-corporation-compensation-and-medical-insurance-issues).

## Entities

### LLC (P, https://www.irs.gov/businesses/small-businesses-self-employed/limited-liability-company-llc)

- Single-member: disregarded (Schedule C, E or F) by default; multiple members: partnership (Form 1065, K-1s, not covered here). Form 8832 elects corporate classification, effective up to 75 days before or 12 months after filing. A disregarded LLC is a separate entity for employment taxes. A foreign-owned disregarded entity files Form 5472 with a pro forma 1120 (P).

### S corporation (P unless noted)

- Form 2553: file no more than 2 months and 15 days after the start of the tax year the election takes effect, or any time in the preceding year; domestic corporation or eligible entity; 100 or fewer shareholders (individuals, estates, certain trusts, certain exempt organizations); no nonresident-alien shareholders; one class of stock; all shareholders consent; late relief under Rev. Proc. 2013-30 within 3 years and 75 days. A valid S election makes Form 8832 unnecessary (https://www.irs.gov/instructions/i2553).
- Form 1120-S due the 15th day of the 3rd month after year end (16 March 2026 for TY2025, because 15 March was a Sunday; 15 March 2027 for TY2026, I); Form 7004 extends six months (K). Penalty 255 dollars per shareholder per month (up to 12) when no tax is due; plus 5% a month of unpaid tax up to 25%; minimum for returns over 60 days late is the smaller of tax or 525 (instructions ambiguous on which filing year the 255 and 525 apply to; verify for TY2025 vs TY2026) (https://www.irs.gov/instructions/i1120s).
- Schedule K-1 to shareholders with the return; shareholder reports on Schedule E Part II and attaches Form 7203 for losses, distributions or stock disposition (https://www.irs.gov/instructions/i1040se). Shareholder basis limits losses.
- Reasonable compensation (P, https://www.irs.gov/businesses/small-businesses-self-employed/s-corporation-compensation-and-medical-insurance-issues): shareholder-employees must be paid reasonable pay before non-wage distributions; the IRS may recharacterise distributions as wages subject to FICA and FUTA. Factors: training and experience, duties, time and effort, comparable pay, distribution history, compensation agreements. Receipts from the shareholder's own services are wages.
- Guardrail: the app must not output a "correct salary". Show the factors, a user-entered figure, comparable-pay prompts and the payroll-tax effect, and label it guidance. The research example (200,000 of profit, 90,000 salary) shows about 13,380 of payroll tax difference before compliance cost and QBI effects (I).
- Payroll consequence: the owner is a W-2 employee; run payroll (941, 940, W-2), keep a basis schedule, and track accountable-plan reimbursements (K).

### C corporation

- Form 1120 due the 15th day of the 4th month (15 April 2027 for TY2026; 15 April 2026 for TY2025 passed); 7004 extends six months to 15 October (K). Late filing 5% a month up to 25%; late payment 0.5% a month up to 25%; minimum penalty the smaller of tax or 525. Schedule M-3 when assets are 10 million or more, otherwise M-1 (P, https://www.irs.gov/instructions/i1120).
- Tax rate 21% flat (K, IRC 11(b); not on a fetched page). NOL 80% limit, dividends-received deduction percentages and accumulated earnings tax are K and not modelled.
- Estimated tax: instalments on the 15th of months 4, 6, 9, 12 by EFT when tax is expected to be 500 dollars or more; Form 2220 (P).
- Charitable contributions: 1% floor and 10% cap from 2026 (P). Section 163(j): EBITDA-based ATI for years after 2024, above 31 million average gross receipts (P).
- Double tax illustration (I): 100,000 of income taxed at 21% = 21,000; distributing 79,000 as a qualified dividend taxed at 15% = 11,850; combined 32,850.

## Payroll (P, https://www.irs.gov/publications/p15, https://www.irs.gov/instructions/i940)

- FICA 6.2% (to the wage base) + 1.45% each for employer and employee; employee-only Additional Medicare 0.9% above 200,000 of wages. FUTA 6.0% on the first 7,000, credit up to 5.4%, net 0.6% (42 dollars per employee) when state unemployment tax is paid on time; credit-reduction states are reported on Schedule A of Form 940 (list for 2025 not fetched).
- Form 941 quarterly: 30 April, 31 July, 31 October, 31 January (next business day on a weekend). Form 940 annual: 31 January (2 February 2026 for TY2025; 10 February if all deposits were timely). Form 944 only by IRS notice (expected employment tax 1,000 or less). W-2 and W-3 due 31 January (2 February 2026), K. FUTA deposit when cumulative liability exceeds 500 dollars by the end of the month after quarter end.
- Supplemental wages: 22% flat, 37% over 1,000,000 a year; backup withholding 24%.
- Qualified tips and overtime stay subject to FICA; from 2026 employers report them separately on W-2 or 1099 with transition relief for 2025. 2% shareholder premiums: W-2 box 1 only.
- Deposit schedules (monthly vs semiweekly, 100,000 next-day rule, 2,500 quarterly threshold), per-employee reconciliation lines and SUTA rates and wage bases were not researched.
- Payroll test, 2026 wages 200,000: employee SS 11,439, Medicare 2,900, additional Medicare 0, employer same, FUTA 42. At 260,000: employee Medicare 3,770 plus 540 additional (I).

## Information returns (P, https://www.irs.gov/instructions/i1099mec, https://www.irs.gov/instructions/i1099k, https://www.irs.gov/newsroom/form-1099-k-faqs-general-information)

- 1099-NEC box 1a: nonemployee compensation of 600 or more for payments made in 2025, 2,000 or more for payments made after 31 December 2025 (indexed from 2027). 1099-MISC: 10 for royalties and broker substitute payments; 600 gross proceeds to attorneys; 2,000 rents, prizes, other income, medical and health care, crop insurance, certain deferred compensation; 5,000 direct sales of consumer products for resale. Backup withholding threshold also rises from 600 to 2,000 for 2026 (Pub. 15).
- Due: 1099-NEC to IRS and payee 31 January (2 February 2026 for TY2025; 1 February 2027 for TY2026, I); 1099-MISC payee 31 January, IRS 28 February paper / 31 March electronic.
- 1099-K: third-party settlement organizations need not file unless gross payments exceed 20,000 and transactions exceed 200 (both required; OBBBA, retroactive to the pre-ARPA rule); card processors have no de minimis; income stays taxable without a form; some states keep lower thresholds. Proposed regulations (IR-2026-03, 8 January 2026) apply the same threshold to backup withholding for TPSOs.
- Payments to corporations are generally not reportable (exceptions: attorneys, medical and health care); card and third-party-network payments go on 1099-K; wages go on W-2.
- Engine behaviour (I): collect W-9 (name, business type, TIN) before the first payment; sum non-corporate payee payments per year excluding card/PayPal; flag when the threshold for the payment year is crossed; apply 24% backup withholding when there is no TIN. Per-return penalty amounts were not read.
