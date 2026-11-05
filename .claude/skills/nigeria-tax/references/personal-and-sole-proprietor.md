# Personal income tax, PAYE, returns, 2025 old regime, sole proprietors

Tags: P primary (gazette read), P-snip, S secondary, I inferred, K general knowledge. NTA gazette: https://www.lirs.gov.ng/assets/docs/Gazette%20-%20NIGERIA%20TAX%20ACT,%202025.pdf; NTAA gazette: https://tat.gov.ng/Nigeria-Tax-Act-2025.pdf.

## 2026 regime (income from 1 January 2026)

Bands (Fourth Schedule, s.58) (P; also KPMG https://kpmg.com/xx/en/our-insights/gms-flash-alert/flash-alert-2025-168.html):

| Slice             | Rate | Cumulative tax at band top |
| ----------------- | ---- | -------------------------- |
| First N800,000    | 0%   | 0                          |
| Next N2,200,000   | 15%  | N330,000 (at N3m)          |
| Next N9,000,000   | 18%  | N1,950,000 (at N12m)       |
| Next N13,000,000  | 21%  | N4,680,000 (at N25m)       |
| Next N25,000,000  | 23%  | N10,430,000 (at N50m)      |
| Above N50,000,000 | 25%  |                            |

- Section 28: total income = taxable income (assessable profits from trade, business, profession, vocation; employment income; investment income; other income; chargeable gains) minus deductions for losses, capital allowances, exempt income and income on which WHT is the final tax (P).
- Section 30: chargeable income = total income minus eligible deductions paid in the year: (i) NHF, (ii) NHIS, (iii) Pension Reform Act contributions, (iv) interest on a loan to develop an owner-occupied residential house, (v) annuity or premium on life insurance (own life or spouse) or deferred annuity (as drafted, "paid ... during the year preceding the year of assessment": do not silently reinterpret), (vi) rent relief of 20% of annual rent paid, maximum N500,000, "whichever is lower", provided the individual accurately declares rent paid and other prescribed information (P).
- No statutory caps for NHF, NHIS, pension or mortgage interest in s.30 itself; PRA 8% employee / 10% employer, NHF 2.5% of basic and NHIS rates are K and unverified: use user-entered actuals.
- Section 31: no deduction unless "claimed in writing in such form as the relevant tax authority may prescribe". Section 32: the authority may require documentary evidence and may refuse the deduction; an objection must attach available evidence or a declaration that none exists (P). Capture a document reference per deduction line.
- CRA (old regime) is removed; housing benefits in kind are capped at 20% of gross income (s.14(6) per PwC, S); compensation for loss of office is exempt up to N50m (was N10m) (S/P: s.50 for the gain).
- Other exempt income, s.163(1) (P): pension, gratuity and retirement benefits under the PRA (i); State or Federal government bond income (n); foreign dividend, interest, rent or royalty brought in through approved channels (s); angel/VC/startup gains held at least 24 months (m).
- Minimum wage: s.58 taxes individuals "other than an individual earning the Minimum Wage"; s.163(1)(t) exempts "income of a person from an employment where such person earns gross income of national minimum wage or less". "National Minimum Wage" is the rate under the National Minimum Wage (Amendment) Act 2024 (P). The amount (N70,000 a month) is K; whether the test is monthly or annualised is not in the text; interaction with the N800,000 band for mixed-income individuals is not clarified.
- Employment income arises day to day (s.26); bonuses, commissions and allowances paid on one occasion or at intervals above one month are income of the day of payment; paid after employment ends, income of the last day of employment (P).
- Section 29: presumptive taxation by regulation where income cannot be ascertained or no records are kept (P).
- The NTAA s.15 lets the authority issue guidelines for a simplified return for low-income or informal-sector persons.

## PAYE, employer and individual returns (P unless noted)

- NTAA s.14(1): employer files a return "not later than 31st January of each year" for all employees of the preceding year: gross emoluments including allowances and benefits in kind, total deductions, net emoluments, tax deducted. s.14(3): employees still file their own annual return from all sources (s.13).
- NTAA s.13: every taxable person files a return each year of assessment without notice "whether or not liable to pay tax": completed self-assessment form, income from every source, personal relief and tax computation, for business income an audited financial statement or a statement of accounts attested by the taxpayer, and evidence of payment of tax due.
- NTAA s.51(6)-(7): income tax on an employee is deducted from emoluments and the aggregate deducted must equal the tax chargeable for the year. s.28: those who deduct and remit file monthly returns "as specified in the regulation". s.49(1): tax is due on or before the filing due date, in one sum or instalments, final instalment by the filing date. s.34: a submitted self-assessment return is a deemed assessment, including nil returns, even when pre-filled by the authority.
- 2025 individual returns were due 31 March 2026 (S, BusinessDay https://businessday.ng/news/article/personal-income-tax-march-31-deadline-puts-nigerias-new-tax-system-to-test/), filed with the State IRS of residence (for example LIRS eTax in Lagos); PAYE earners must file too. 2026-income return date: gazette silent; default 31 March 2027 as configurable data (I).
- PAYE monthly remittance by the 10th of the next month to the State IRS of the employee's residence (FCT-IRS for Abuja) is S (AnooreHR https://anoorehr.com/blog/state-paye-remittance-nigeria-2026), inherited from PITA practice. Each state with employees needs separate registration.
- Late-filing check on 5 November 2026 for the unfiled 2025-income return, counting April 2026 as month 1: this is month 8; penalty N100,000 + 7 x N50,000 = N450,000 (I, month-counting unconfirmed).

## 2025 old regime (income earned in calendar 2025, PITA) (S)

Source: PwC https://taxsummaries.pwc.com/nigeria/individual/significant-developments; formula details from secondary summaries (a developer calculator write-up). PITA text not read.

| Slice            | Rate |
| ---------------- | ---- |
| First N300,000   | 7%   |
| Next N300,000    | 11%  |
| Next N500,000    | 15%  |
| Next N500,000    | 19%  |
| Next N1,600,000  | 21%  |
| Above N3,200,000 | 24%  |

- CRA = higher of N200,000 or 1% of annual gross income, plus 20% of gross income. Taxable income = gross minus CRA minus pension, NHF and other allowable reliefs.
- Minimum tax = 1% of gross income; payable = max(progressive tax, minimum tax). Removed from 2026.
- Comparison cases in `test-vectors.md` (O1 to O3). A claim of "N30,000 a month" minimum tax under a 2025 Finance Act conflicts with the other sources and is unverified; do not use.

## Sole proprietors and business income (P unless noted)

- A sole proprietor (including under a registered business name) is taxed as an individual on assessable profit using the personal bands. Individuals do not get the 0% small-company rate.
- s.20: assessable profit = profit after all expenses "wholly and exclusively incurred in the production of the income"; includes interest on debt (subject to the Third Schedule), rent, salaries and benefits, repairs, pension contributions to PRA-approved schemes, bad and doubtful debts, research and development, assistive-device expenses. s.20(4): foreign-currency expenses deductible only at the CBN official rate for the date or period.
- s.21 non-deductible: capital items, private or domestic expense, income taxes, unapproved pension contributions, depreciation, impairment and unrealised FX differences, fines and penalties, expenses connected with exempt income, expenses on which VAT was due but not charged, or imports where duty or levy was not paid.
- Basis period (s.22): the preceding accounting period; first-year profits run from commencement to the end of the first accounting period; change of accounting date needs notice at least 30 days before the usual filing due date (s.23(2)); on cessation tax is payable within six months (s.24(1)).
- Capital allowances (First Schedule Part I Table I): class 1 at 10% (buildings, agricultural, mast, intangible, heavy transport), class 2 at 20% (plant, agricultural equipment, furniture and fittings, mining, other equipment), class 3 at 25% (motor vehicles, software, other capital expenditure). A notional 1% of qualifying expenditure is carried in the schedule until disposal and does not reduce the allowance claimable. Part-year basis periods get a proportionate allowance. The asset must be owned and in use at the end of the basis period. Unclaimed allowance carries forward. Expenditure on which VAT was due but not charged, or import duty unpaid, does not qualify. Allowances are deducted after losses (s.27(2)).
- Method gap: whether allowances are straight-line on cost or reducing balance is not stated plainly. The transitional paragraph (para 23) refers to "the number of years of assessment for which allowance is to be made", which suggests straight-line over 10, 5 and 4 years (I). Verify before coding multi-year schedules.
- Loss relief (s.28(3)): trade losses carry forward to the first and subsequent years until recouped, against the same trade only; aggregate deductions cannot exceed the loss; digital or virtual asset losses only against digital or virtual asset gains.
- Return: self-assessment form, income by source, relief and tax computation, "an audited financial statement or a statement of accounts attested to by the taxpayer", evidence of payment (NTAA s.13(2)).
- VAT: a sole proprietor or unincorporated business meeting the small-business test (turnover N100m or less, fixed assets N250m or less, not professional services) is outside VAT registration and filing unless it opts in (NTAA s.22(4)-(5)). "Professional services" is not defined in the text read.
- WHT: the 2024 regulations exclude small companies (turnover N25m or less) and equivalent unincorporated bodies from the duty to deduct, on conditions (S; see `vat-wht-einvoicing.md`).
- Worked example: `test-vectors.md` (S1).

## Pack status (as of 5 November 2026)

Implemented: 2026 bands, rent relief (20%, cap N500,000, rounded down), s.30 reliefs as user-entered categories, linked sole-trader profit, chargeable gains as proceeds minus cost, franked dividends and final-tax interest out of scope, WHT credit categories. Not implemented or differing:

- No 2025 old-regime tax year (`supportedStartYears` is `{2026}`).
- Foreign dividend, interest, rent, royalty are taxed as income; the s.163(1)(s) exemption has no category.
- No minimum-wage exemption, residency test, foreign tax credit, benefits-in-kind cap, loss-of-office exemption, document reference per deduction, or proportionate part-year allowance.
- Capital allowance is one year at table rate on current-year additions only (method unconfirmed).
- Gains: no s.34 share exemption, no s.50 to 54 exemptions, no digital-asset ring-fence, no per-disposal ledger.
- Calendar-year cash basis, not the basis-period rules.
