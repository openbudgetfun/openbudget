---
openbudget_core: fix
openbudget_app: fix
---

# Fix the UK tax rule pack

Corrects the defects found while auditing the GB pack against the domain skills, with each fix backed by the skills' test vectors.

## Personal tax

- The personal allowance taper now uses adjusted net income: gross relief-at-source pension contributions and gross Gift Aid donations recorded on the books reduce the taper base instead of only total income.
- Student loan repayments round down to whole pounds (SA110 boxes 3 and 3.1), the repayment base follows the SA110 working sheet (savings and dividends count only above £2,000, gross pension contributions reduce it), and a profile can now hold an undergraduate plan and a postgraduate loan at the same time. Profiles that stored the postgraduate loan in `studentLoanPlan` still parse.
- Payments on account are now the statutory rule: two instalments of 50% of the year's Income Tax plus Class 4, net of tax collected at source, excluding Capital Gains Tax, student loans and the High Income Child Benefit Charge, skipped under £1,000 or when more than 80% was collected at source. The thresholds and instalment share are rule data, and the instalments fall due with the return (31 January and 31 July two years after the year starts), not on half the balance.
- SA103F references where the trading allowance applies: the allowance deducts at box 73 and the taxable profit is box 76, the figure that flows to the SA100 (was box 16.1 and box 64).

## VAT

- Business-use apportionment applies to input tax only. Output VAT is owed on the whole sale, so sales entries with a private-use percentage no longer reduce the VAT charged.

## Company tax

- Corporation Tax runs on the company's accounting period, not the 6 April tax year. `GbTaxProfile` gains an accounting-period end date (default 31 March), and profits are apportioned by day across the 1 April financial years the period straddles, each part charged with its own year's rates. The FY2027 hold at 19%/25% is stated instead of the stale assumption text.
- The profile also carries an associated-companies count, and each one divides the £50,000/£250,000 limits; short periods pro-rate the limits by days (CTM03930/CTM03935).
- Capital allowances: the Annual Investment Allowance is capped at £1,000,000 and pro-rated by whole months for a short period, cars never reach it, and the pure module now also models company full expensing (100% of new main-rate plant) and the 50% special-rate first-year allowance. Pools and writing-down allowances are still not modelled: spend above the cap or in cars is shown as unrelieved.
- The director salary comparison compares the year's Class 1 thresholds from rule data including the lower earnings limit, credits the Employment Allowance when the books show wages above the secondary threshold beyond the director's pay (s2(4A): a sole director who is the only employee above the threshold cannot claim it), and is labelled guidance, never "optimal".

## Rule data

New per-year figures with sources: Class 1 lower earnings limit (6,500 / 6,708), Employment Allowance (10,500), payments-on-account minimum (1,000), collected-at-source share (80) and instalment share (50), student-loan unearned-income threshold (2,000), pension relief-at-source basic rate (20%), AIA cap (£1,000,000), full-expensing (100%) and special-rate FYA (50%) rates. All arithmetic stays in integer minor units.

## App

- The GB tax profile form asks the new questions: postgraduate loan, and for companies the accounting period end and associated companies. New localised strings and widget tests.

## Not covered here

- The server's profile sanitizer (`openbudget_server/lib/src/tax/tax_service.dart`) still whitelists the old GB profile keys, so `postgraduateLoan`, `accountingPeriodEnd*` and `associatedCompanies` are dropped at the endpoint until the server is updated; a local report computes with the defaults.
- Pools, writing-down allowances, balancing charges, exempt distributions and the s455 charge remain unmodelled (stated in report assumptions).
