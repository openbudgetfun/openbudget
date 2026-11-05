# CT600, iXBRL and the filing channel

Grades: **[P]** primary, **[S]** secondary, **[I]** inferred. Research date 5 November 2026.

## What a return is, and who can file it

- Form: CT600 (2026) Version 3 (HMRC 04/26) for APs starting on or after 1 April 2015. [P] https://assets.publishing.service.gov.uk/media/69c543424a06660f085442bd/ct600.pdf. Guidance page last modified 2 June 2026: https://www.gov.uk/guidance/the-company-tax-return-guide
- A Company Tax Return is the CT600, supplementary pages, the company accounts and the tax computations. Returns must be filed online for APs ending after 31 March 2010. Accounts and computations must be iXBRL. Third-party commercial software is required. [P] https://www.gov.uk/guidance/company-tax-return-obligations
- **HMRC's free online CT filing service closed on 31 March 2026.** [P] same page.
- Consequence for OpenBudget (prepare-only): the user must use filing software that submits through the HMRC gateway, or an agent, to file the CT600. The same applies to Companies House accounts: filing is software-only from 1 April 2028 (web and paper accounts filing close), with web filing presumably available until then [I]. State this plainly in the product: "OpenBudget prepares your numbers and a checklist. To file, you need filing software or an accountant."
- What to export: (1) the populated CT600 data set with supplementary pages, (2) accounts content ready for iXBRL tagging to the FRC taxonomy, (3) a computation ready for tagging to HMRC's computation taxonomy, (4) PDF supporting documents. The product must not claim to be a recognised submission channel. [I]
- Taxonomies: accounts conform to the FRC suite; computations to the HMRC tax computation taxonomy; accounts and computations are separate iXBRL instance documents; group accounts need not be tagged; unincorporated charities may file PDF accounts but still need iXBRL computations. [P] https://www.gov.uk/government/publications/directions-under-regulations-3-and-10-of-the-income-and-corporation-taxes-electronic-communications-regulations-2003-si-2003282/income-and-corporation-taxes-electronic-communications-direction and https://assets.publishing.service.gov.uk/media/5a757244e5274a1242c9e61c/company-accounts.pdf
- Structured computation format: HMRC published specifications (accounts adjustments and capital allowances, notice of 13 August 2026), but it is not mandatory until "phase 2" and a timetable. Treat as information. [P] https://www.gov.uk/guidance/changes-and-issues-affecting-the-corporation-tax-online-service
- Not researched: exact tagging requirements, taxonomy version names, mandatory tags, HMRC's technical validation pack.

## Box map (labels from the guidance page) [P]

Source for all rows: https://www.gov.uk/guidance/the-company-tax-return-guide

| Box                          | Label                                                                                                                                                                                                        |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1, 2, 3, 4                   | company name, registration number, UTR, type of company                                                                                                                                                      |
| 30, 35                       | period start, period end                                                                                                                                                                                     |
| 40, 45                       | repayments this period; claim or relief affecting an earlier period                                                                                                                                          |
| 145                          | total turnover from trade                                                                                                                                                                                    |
| 155                          | trading profits                                                                                                                                                                                              |
| 160                          | trading losses brought forward set against trading profits                                                                                                                                                   |
| 165                          | net trading profits                                                                                                                                                                                          |
| 235                          | profits before other deductions and reliefs                                                                                                                                                                  |
| 240, 245, 250, 255           | unquoted share losses; management expenses; UK property business losses; capital allowances for management of the business                                                                                   |
| 260, 263                     | non-trade loan relationship deficits (this period, carried forward)                                                                                                                                          |
| 265, 275, 280, 285, 290      | non-trading losses on intangibles; trading losses of this or a later AP; amounts carried back from later APs; trading losses carried forward and claimed against total profits; non-trade capital allowances |
| 295, 300                     | total deductions and reliefs; profits before qualifying donations and group relief                                                                                                                           |
| 305, 310, 312                | qualifying donations; group relief; group relief for carried-forward losses                                                                                                                                  |
| 315                          | profits chargeable to Corporation Tax                                                                                                                                                                        |
| 320                          | ring fence profits included                                                                                                                                                                                  |
| 326, 327, 328, 329           | associated companies in the period; in first FY; in second FY; small profits rate or MR entitlement                                                                                                          |
| 430, 435, 440                | Corporation Tax; marginal relief; Corporation Tax chargeable                                                                                                                                                 |
| 445, 450, 455, 460, 465, 470 | community investment relief; double taxation relief; underlying rate relief; amount carried back from later period; ACT; total reliefs and deductions in terms of tax                                        |
| 475                          | net Corporation Tax liability                                                                                                                                                                                |
| 480                          | tax payable on loans and arrangements to participators (equals CT600A box A80)                                                                                                                               |
| 500, 501, 502, 505           | CFC tax, bank levy, bank surcharge, RPDT; EPL; electricity generator levy; supplementary charge                                                                                                              |
| 510                          | tax chargeable                                                                                                                                                                                               |
| 515, 520                     | income tax deducted from gross income included in profits; income tax repayable                                                                                                                              |
| 525, 526, 527, 528           | self-assessment of tax payable before restitution tax and coronavirus overpayments; coronavirus support overpayment; restitution tax; self-assessment of tax payable                                         |
| 530                          | R&D credit                                                                                                                                                                                                   |
| 600, 605                     | tax outstanding; tax overpaid                                                                                                                                                                                |
| 688 to 695, 705              | capital allowance boxes (see `capital-allowances.md`)                                                                                                                                                        |
| 725, 750, 760                | FYA claim amounts and qualifying expenditure (interim use for the 40% FYA and zero-emission cars)                                                                                                            |

Minimum box set for a typical owner-managed trading company [I]: 1, 2, 3, 4, 30, 35, 145, 155, 165, 235, 300, 315, 326 to 329, 430, 435, 440, 475, 480 (if loans), 510, 528, the capital allowance boxes in use, and 600 or 605 as outputs. Whether box 155 is stated after capital allowances is **not confirmed**; do not rely on the repo's "Trading profit = turnover - expenses - capital allowances" mapping to 155 without reading the form.

Supplementary pages: CT600A (loans and arrangements to participators; A80 feeds 480), CT600E (charities), CT600L (R&D), CT600P (creative industry reliefs; must be included when claiming). [P] https://www.gov.uk/guidance/company-tax-return-obligations and https://assets.publishing.service.gov.uk/media/69ce28cab5210036050bc6ce/CT600L.pdf

## Online service known issues for 2026-27 [P]

Source: https://www.gov.uk/guidance/changes-and-issues-affecting-the-corporation-tax-online-service

- Two new CT600 boxes for the 40% FYA arrive in April 2027; use 725, 750 and 760 until then.
- The s455 rate of 35.75% will not be reflected in the service until 6 April 2027. A return filed earlier that includes loans made on or after 6 April 2026 must be amended afterwards. Show the correct 35.75% figure in OpenBudget and warn the user.
- CT600P and R&D box workarounds are fixed in April 2027.

## Deadlines and penalties

- Tax due 9 months and 1 day after AP end, paid electronically. Return due 12 months after AP end. [P] https://www.gov.uk/guidance/company-tax-return-obligations
- Examples [I]: AP ending 31 March 2026: tax 1 January 2027, return 31 March 2027. AP ending 31 December 2026: tax 1 October 2027, return 31 December 2027.
- Fixed late filing penalties for returns due on or after 1 April 2026 roughly double: late £100 to £200; over 3 months late £200 to £400; late after three successive failures £500 to £1,000; over 3 months late after three successive failures £1,000 to £2,000. The source lists the figures without saying whether the over-3-months amount is additional to or inclusive of the first; confirm on GOV.UK before showing a total. [P] Budget 2025 OOTLAR measure 1.79 (URL in `capital-allowances.md`).
- Not retrieved: late payment interest rates, tax-geared penalties at 6 and 12 months, large-company quarterly instalments (not relevant to a small company), record-keeping duration (six years for tax is commonly cited but unsourced here), HMRC record-keeping penalties.
