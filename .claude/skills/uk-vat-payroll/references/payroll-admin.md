# Payroll administration: RTI, statutory pay, benefits, auto-enrolment, director salary analysis

Research date: 5 November 2026. Tags: **P** primary, **P-snip** (official page seen via search or fetch summary), **S** secondary, **I** inferred or the researcher's own analysis.

## 1. RTI submissions and year-end forms

| Item                           | Rule                                                                                                                                                                                 | Tag              |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------- |
| FPS (Full Payment Submission)  | on or before each payday, reporting pay, payrolled benefits and deductions, unless an exception applies; the payment date is the regular payday even if paid on a nearby working day | P-snip, P (CWG2) |
| EPS (Employer Payment Summary) | by the 19th of the following tax month; sent instead of an FPS if no employee is paid in a whole tax month                                                                           | P-snip           |
| P60                            | give to employees working for you on 5 April by 31 May                                                                                                                               | P-snip           |
| P11D and P11D(b)               | file online and copies to employees by 6 July                                                                                                                                        | P-snip           |
| Class 1A                       | 15% in both years; pay by 19 July (cheque) or 22 July (electronic)                                                                                                                   | P-snip           |
| Late P11D(b)                   | 100 per 50 employees per month or part month                                                                                                                                         | P-snip           |
| Pension deductions             | must reach the scheme by the 19th (cheque) or 22nd (electronic) of the following month                                                                                               | P (CWG2)         |

Sources: [payroll information to report](https://www.gov.uk/guidance/what-payroll-information-to-report-to-hmrc), [P60](https://www.gov.uk/paye-forms-p45-p60-p11d/p60), [expenses and benefits deadlines](https://www.gov.uk/employer-reporting-expenses-benefits/deadlines), [CWG2 2026 to 2027](https://www.gov.uk/government/publications/cwg2-further-guide-to-paye-and-national-insurance-contributions/2026-to-2027-employer-further-guide-to-paye-and-national-insurance-contributions).

**FPS data model (I; the HMRC RTI technical pack field list was not read):** per employee per pay run: NI number, employee details, tax code and basis, pay date, pay frequency, gross pay in period and year to date, taxable pay YTD, tax YTD, NIC lines (category, earnings at LEL, PT and UEL, employee and employer NIC), student loan deductions, pay after statutory deductions, starter declaration, hours-worked band, irregular payment indicator, payrolled benefits (from 2027). P45 content and timing and the late-FPS penalty regime (monthly by headcount) were not retrieved.

**Limitation for a prepare-only app:** OpenBudget computes payslips, NIC and RTI-ready figures and shows what to report; it does not send RTI. Sending an FPS or EPS needs HMRC-recognised RTI software (or HMRC's Basic PAYE Tools for very small employers, not researched). Direct RTI filing by a self-built product needs HMRC recognition and is out of scope here. Tell the user which figures to load into their payroll or RTI software.

## 2. Payrolled benefits: mandatory from April 2027

Source: [Mandatory reporting of benefits in kind in RTI from April 2027](https://www.gov.uk/government/publications/changes-to-reporting-of-benefits-in-kind-from-april-2027/mandatory-reporting-of-benefits-in-kind-in-real-time-information-rti-from-april-2027), [Employer Bulletin October 2026](https://www.gov.uk/government/publications/employer-bulletin-october-2026/october-2026-issue-of-the-employer-bulletin) (P-snip).

- **Phase 1, 6 April 2027:** company cars, vans, car and van fuel, and medical benefits are reported and taxed through the FPS in real time (Income Tax and Class 1A). **Phase 2, 6 April 2028:** most remaining benefits, excluding loans and accommodation. This corrects an assumption that all benefits are mandatory from April 2027.
- Globally mobile employees can be voluntarily excluded (P11D route). The voluntary payrolling registration service re-opens on 5 November 2026. From April 2027 voluntary payrolling must include Class 1A in payroll too. No inaccuracy penalties for errors in 2027/28 mandatory payrolling returns unless deliberate (late filing and late payment penalties still apply). HMRC will remove the benefit from tax codes. About 280,000 employers affected.
- Effect (I): a small owner-managed company with no company cars or private medical cover is largely unaffected in 2027/28; any such benefit must move off the P11D onto the FPS.
- Payrolled benefits count in pay (`pbik`) for the tax calculation and are excluded from the 50% regulatory-limit base. SA102 box 1.1 reports payrolled benefits included in box 1.

## 3. Statutory payments (2025/26 and 2026/27)

- **SSP changes from 6 April 2026** (Employment Rights Act 2025; business.gov.uk and the GOV.UK factsheet, P-snip): the lower earnings limit is removed, waiting days are removed (payable from the first full day of absence), and the rate is the **lower** of the flat weekly rate and 80% of average weekly earnings. UK-wide; up to 1.3 million workers newly entitled. Qualifying criteria beyond earnings (4 or more consecutive days of incapacity and so on) were not re-verified after April 2026.
  - Weekly rate **118.75** (2025/26); **123.25** (2026/27) or 80% of AWE if lower. Daily rates 2026/27 by qualifying days: 7 days 17.61; 6 days 20.55; 5 days 24.65; 4 days 30.82; 3 days 41.09; 2 days 61.63; 1 day 123.25. SSP is not recoverable. Sources: [2025 to 2026 rates](https://www.gov.uk/guidance/rates-and-thresholds-for-employers-2025-to-2026), [2026 to 2027 rates](https://www.gov.uk/guidance/rates-and-thresholds-for-employers-2026-to-2027) (P), [business.gov.uk SSP changes](https://www.business.gov.uk/campaign/employment-changes/employers/statutory-sick-pay/), [SSP factsheet](https://assets.publishing.service.gov.uk/media/695fb36d47867b8e14f764fb/statutory-sick-pay-factsheet.pdf) (P-snip).
  - Examples (I): a 5-day worker on 600 a week: 80% x 600 = 480, above 123.25, so weekly SSP 123.25, daily 24.65. A worker averaging 100 a week: 80% = 80, below 123.25, so SSP 80 (previously nothing, below the LEL).
- **SMP, SPP, SAP, shared parental, bereavement, neonatal:** first 6 weeks (SMP, SAP) 90% of average weekly earnings, then the lower of the flat rate and 90% of AWE. Flat rate **187.18** (2025/26), **194.32** (2026/27). Recovery 92% if the previous year's total Class 1 NIC exceeded 45,000, otherwise 108.5% (2025/26 page) and 109% (2026/27 page); the two pages differ. P (rates pages).
- National Living Wage from 1 April 2026: 12.71 (21 and over), 10.85 (18 to 20), 8.00 (under 18 and apprentices). **S only** ([PayFit](https://payfit.com/blog/ni-changes/)); verify against GOV.UK before use.

## 4. Auto-enrolment

- Thresholds, identical in 2025/26 and 2026/27 (P, [The Pensions Regulator earnings thresholds](https://www.thepensionsregulator.gov.uk/en/employers/new-employers/im-an-employer-who-has-to-provide-a-pension/declare-your-compliance/ongoing-duties-for-employers/earnings-thresholds)):

| Level                     | Year   | Week | 2 weeks | 4 weeks | Month | Quarter | Half-year |
| ------------------------- | ------ | ---- | ------- | ------- | ----- | ------- | --------- |
| Lower qualifying earnings | 6,240  | 120  | 240     | 480     | 520   | 1,560   | 3,120     |
| Earnings trigger          | 10,000 | 192  | 384     | 768     | 833   | 2,499   | 4,998     |
| Upper qualifying earnings | 50,270 | 967  | 1,934   | 3,867   | 4,189 | 12,568  | 25,135    |

DWP announced the 2026/27 annual figures; they take effect from 6 April.

- Minimum contributions (from April 2019): employer 3%, employee 5%, total 8% of qualifying earnings in the pay reference period, "however calculated". GOV.UK: contributions are based on total earnings between 6,240 and 50,270 a year before tax ([what you, your employer and the government pay](https://www.gov.uk/workplace-pensions/what-you-your-employer-and-the-government-pay), P). Pay reference period options: 12 months from duties start, the usual interval between regular pay, or the period by which the jobholder is paid; if thresholds change on 6 April the old figures apply to days before and the new to the rest of a straddling period ([TPR appendix C](https://www.thepensionsregulator.gov.uk/en/document-library/automatic-enrolment-detailed-guidance/4-pension-schemes-under-the-employer-duties-appendix-c-the-relevant-pay-reference-period), P).
- Assessment (I): an eligible jobholder is aged 22 to State Pension age and earns above the trigger for the period; the age bands and the 16 to 74 opt-in were not in a primary page opened (statutory background). Whether a company with only a sole director and no other workers has any duty (believed not) was **not verified**.
- Qualifying earnings in a period = max(0, min(gross, upper) minus lower), using the per-period figures. Monthly 3,000: 3,000 minus 520 = 2,480; employee 5% = **124.00**; employer 3% = **74.40**.
- **Tax relief arrangement** ([GOV.UK managing your pension](https://www.gov.uk/workplace-pensions/managing-your-pension), P):
  - **Net pay:** the employer takes the contribution before tax; taxable pay (and cumulative taxable pay) falls; NIC-able pay and student-loan pay do not; a non-taxpayer gets no relief. Example: taxable = floor(3,000 minus 124 minus 1,048.26) = 1,827, tax **365.40**; NIC and student loan unchanged.
  - **Relief at source:** taken after tax and NIC; the provider claims 20% at source whatever the earnings; taxable pay is unaffected. For a gross 5% minimum the employee pays 4% and 1% arrives as relief (standard split, I; the primary page did not state it; verify with the scheme provider's rules). Self Assessment: relief-at-source payments go in SA100 TR 4 box 1 grossed up; net-pay contributions are not entered.
- **Rounding of contributions is not published** (TPR is silent). Make it a documented configuration choice; nearest penny is recommended. Net-pay low-earner top-up was not read in full. No HMRC vectors exist for auto-enrolment.
- Example payslip (I, 2026/27, England, 1257L, month 1, gross 3,000, net-pay pension, Plan 2): pension 124.00; taxable pay 1,827; tax **365.40**; employee NIC **156.16**; student loan 9% x (3,000 minus 2,448.75) = 49.6125 -> **49**; net pay = 3,000 minus 124 minus 365.40 minus 156.16 minus 49 = **2,305.44**; employer NIC 387.45; employer pension 74.40; employer cost 3,000 + 387.45 + 74.40 = **3,461.85**.
- Payslip without pension (I): gross 3,000: tax 390.20; employee NIC 156.16; net **2,453.64**; employer cost **3,387.45**. Gross 6,000: tax **1,352.06**; employee NIC 287.50; net **4,360.44**; employer NIC 837.45; employer cost 6,837.45. (The earlier note's net of 4,360.50 used the wrong tax figure 1,352.00.)

## 5. Optimal director salary (the researcher's analysis; not a published recommendation)

Under the thresholds in `nic-student-loans.md`, a director salary equal to the Primary Threshold (12,570) beats both the Lower Earnings Limit salary and the Secondary Threshold salary for any company paying corporation tax above about **13.04%** (= 15 / 115), because each pound of salary up to the PT costs 1.15 pre-tax against 1 / (1 minus t) for the same pound as a dividend. Employer NIC on the director is 15% above 5,000.

Assumptions (all I): the director has no other income; dividends fill the unused personal allowance; total extraction 12,570; salary and employer NIC are deductible for corporation tax; t is the marginal corporation tax rate. Corporation tax rates were not sourced in this research (19% small profits up to 50,000, 25% over 250,000, marginal relief between: general knowledge, to verify; use the existing company rules in the tax pack, not this file).

| Option                                     | Company cost (before relief)                               | Notes                 |
| ------------------------------------------ | ---------------------------------------------------------- | --------------------- |
| A: salary 12,570, no Employment Allowance  | 12,570 + 1,135.50 = 13,705.50, net of relief x (1 minus t) | employee NIC 0, tax 0 |
| B (2026/27): salary 6,708 + dividend 5,862 | 6,708 + 256.20 = 6,964.20 net of relief + 5,862            |                       |
| C: salary 5,000 + dividend 7,570           | no employer NIC                                            |                       |

A minus B = 879.30 minus 6,741.30 t (2026/27): at t = 19%: **minus 401.55** (A cheaper); at 25%: **minus 806.03**; break-even 13.04%. 2025/26 (salary 6,500, dividend 6,070, employer NIC 225): A minus B = 910.50 minus 6,980.50 t; at 19%: **minus 415.80**; break-even 13.04%. A minus C = 1,135.50 minus 8,705.50 t; at 19%: **minus 518.55** (the source note rounded this to 518.50).

With Employment Allowance available (a second person paid above ST) the employer NIC on the director's 12,570 is covered and A is strictly better. Salary above the PT triggers 8% employee NIC and is not generally beneficial.

Caveats to surface in the product: the director's other income, dividend allowance use, retained profit needed to pay dividends, a State Pension qualifying year (needs earnings at or above the LEL), and Employment Allowance eligibility (single-director exclusion). **Never hard-code "optimal" figures**; compute from the year's thresholds and label the result guidance. Student loan interactions, Scottish taxpayers and company pension contributions were not modelled.
