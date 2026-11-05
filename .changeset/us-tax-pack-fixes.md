---
openbudget_core: fix
openbudget_app: fix
openbudget_server: fix
---

# Fix the US federal tax rule pack

The US rule pack in `openbudget_core` now reproduces the filed figures:

- Taxable income below $100,000 is taxed with the IRS Tax Table (the
  bracket formula on the midpoint of the row containing the taxable
  income, rounded to whole dollars); $100,000 and above keep the Tax
  Computation Worksheet formula. The Qualified Dividends and Capital Gain
  Tax Worksheet comparison uses the same $100,000 rule.
- Net investment income MAGI adds back only the foreign earned income
  exclusion (new profile field); tax-exempt interest is no longer added.
- The qualified business income deduction no longer drops to zero above
  the threshold: the section 199A phase-in range, the W-2 wage / UBIA
  limitation, and the specified-service phase-out are applied (Form
  8995-A mechanics, combined businesses). The 2026 $400 minimum deduction
  stays.
- The $1,500 home office cap applies to the simplified Schedule C method
  only; the profile selects the method, and the regular Form 8829 method
  is uncapped.
- `UsFilingStatus` gains `qualifyingSurvivingSpouse`, which uses the MFJ
  brackets, standard deduction, and thresholds; stored profile JSON still
  parses.
- Additional Medicare tax now covers wages plus self-employment income
  together (Form 8959) and is reported separately from Schedule SE.
  Adjusted gross income may be negative; taxable income still floors at
  zero.
- Itemizers get the SALT cap ($40,000 for 2025, $40,400 for 2026) with
  the 30% phase-down to the $10,000 floor, and the Schedule 1-A
  deductions (tips, overtime, passenger-vehicle loan interest, senior)
  with their caps, phase-outs, SSN flags, and the married-filing-
  separately exclusions.
- The child tax credit and credit for other dependents are computed from
  the new dependents profile fields, with the $50-per-$1,000 phase-out
  (flagged as unverified) and nonrefundable application.
- New US categories: state and local taxes (Schedule A line 5d), the
  three Schedule 1-A amounts, and the unadjusted basis of qualified
  property for the QBI wage limitation.
- `openbudget_app` adds the matching questions to the US tax profile
  form (filing status option, dependents, age and SSN switches, foreign
  earned income exclusion, home office method, specified service flag)
  with localized strings and widget tests.
- `openbudget_server` whitelists the new US profile fields (and the
  surviving-spouse filing status) so they persist through saveProfile.
- Every new figure is versioned per tax year in `UsTaxYearTable` with a
  source note; `usRulesVerifiedOn` is 5 November 2026.
