# Box-by-box checklist map: SA100, SA103S, SA103F, SA102, SA105, SA106, SA108, SA110

Box numbers below are the **2025/26 forms** ("Tax Return 2026", HMRC 12/25). The 2026/27 forms are published in April 2027; every map must be re-verified then. SA103F numbering already changed between years (16.1, 52.1, 73.3, 73.4, 76.1 and 77.1 are recent; boxes 5, 11 and 12 are unused).

## Keying convention

Key every checklist row by `(taxYear, form, page, section, box)`. SA100 numbering restarts inside pages and sections (SA100 TR 5 has a Student Loan section with boxes 1 to 3, then a Child Benefit section with boxes 1 to 3, then Marriage Allowance 1 to 5, then Winter Fuel Payment 1), so "box 1" alone is ambiguous. Supplementary pages (SA103, SA102, SA105 and so on) use one numbering per form.

Online filing and commercial software show questions and labels, not box numbers. Show each row as: online section name, field label, form and box key, value, lineage (the ledger or transaction rows that sum to it), and a warning when the value depends on a user choice (trading allowance vs expenses, cash vs traditional accounting, FIG). Group rows in HMRC online section order: employment, self-employment, UK property, savings and dividends, pensions and reliefs, capital gains, tax summary. Include a reconciliation block so the user can compare with HMRC's tax calculation (SA302): total income, PA, taxable income by type, tax at each rate, Class 4, student loan, HICBC, finance-cost credit, payments on account, balancing payment, next year's payments on account.

Paper-form rules: whole pounds; round income down, round expenses and tax paid up; leave non-applicable boxes blank. Treat this as a display convention. Source for all of this file unless stated: [SA100 2025/26 form](https://assets.publishing.service.gov.uk/media/69c14d07cfa346b9d4704a8d/SA100-2026.pdf), [SA150 notes](https://assets.publishing.service.gov.uk/media/6a9ea8a5df4246cf45e469e0/SA150_Notes_2026.pdf). Tag **P** unless marked.

## SA100 page TR 1 and TR 2

TR 1: 1 date of birth; 2 name and address if different; 3 telephone; 4 National Insurance number.
TR 2 (questions, Yes/No and counts): 1 Employment (number of pages); 2 Self-employment; 3 Partnership; 4 UK property; 5 Foreign; 6 Trusts etc; 7 Capital Gains Tax summary; 8 Residence and FIG regime etc (SA109); 9 Additional information (SA101).

## SA100 page TR 3: Income (all boxes verified from the form)

| Box | Label                                                                                                 |
| --- | ----------------------------------------------------------------------------------------------------- |
| 1   | Taxed UK interest, net amount after tax                                                               |
| 2   | Untaxed UK interest                                                                                   |
| 3   | Untaxed foreign interest (up to 2,000)                                                                |
| 4   | Dividends from UK companies                                                                           |
| 5   | Other dividends (unit trusts, OEICs, investment trusts, reinvested accumulation units)                |
| 6   | Foreign dividends (up to 500), sterling amount after foreign tax                                      |
| 7   | Tax taken off foreign dividends (sterling equivalent)                                                 |
| 8   | State Pension, amount entitled to in the year                                                         |
| 9   | State Pension lump sum, gross                                                                         |
| 10  | Tax taken off box 9                                                                                   |
| 11  | Pensions other than State Pension, retirement annuities, taxable lump sums treated as pensions, gross |
| 12  | Tax taken off box 11                                                                                  |
| 13  | Taxable Incapacity Benefit and contribution-based ESA                                                 |
| 14  | Tax taken off Incapacity Benefit in box 13                                                            |
| 15  | Jobseeker's Allowance                                                                                 |
| 16  | Total of other taxable State Pensions and benefits                                                    |
| 17  | Other taxable income, before expenses and tax taken off                                               |
| 18  | Total allowable expenses                                                                              |
| 19  | Any tax taken off box 17                                                                              |
| 20  | Benefit from pre-owned assets                                                                         |
| 21  | Description of income in boxes 17 and 20                                                              |

REIT/PAIF property income distributions go in box 17 with tax in box 19; stock dividends go on SA101; close-company dividends also in SA102 box 7.3. Box 19 on TR 7 is "Any other information" (a different page). The HMRC working sheet cannot be used with an entry in TR 3 box 20.

## SA100 page TR 4: Tax reliefs

| Box    | Label                                                                                                                             |
| ------ | --------------------------------------------------------------------------------------------------------------------------------- |
| 1      | Payments to registered pension schemes where the provider claims basic-rate relief (relief at source): enter the **gross** amount |
| 1.1    | One-off payments included in box 1                                                                                                |
| 2      | Payments to retirement annuity contracts where basic-rate relief is not claimed by the provider                                   |
| 3      | Payments to your employer's scheme not deducted from pay before tax                                                               |
| 4      | Payments to an overseas pension scheme                                                                                            |
| 5      | Gift Aid payments made in the year to 5 April 2026 (net vs gross not verified, see below)                                         |
| 6      | One-off payments in box 5                                                                                                         |
| 7      | Gift Aid made in the year to 5 April 2026 but treated as made in the year to 5 April 2025                                         |
| 8      | Gift Aid made after 5 April 2026 treated as made in 2025/26                                                                       |
| 9      | Qualifying shares or securities gifted                                                                                            |
| 10     | Qualifying land and buildings gifted                                                                                              |
| 11, 12 | Not in use                                                                                                                        |
| 13     | X if registered blind or severely sight impaired                                                                                  |
| 14     | Name of local authority or register (write "Scotland", "Northern Ireland" or "specialist" in the cases described)                 |
| 15     | X to claim spouse's surplus allowance                                                                                             |
| 16     | X to give your surplus allowance to spouse                                                                                        |

Spouse's name and NI number for Blind Person's Allowance go in "Any other information" (TR 7 box 19). Annual allowance excess: SA101 page Ai 4 boxes 10 to 12. No Gift Aid relief for gifts to non-UK charities after 5 April 2024. **Gift Aid box 5 net or gross: not verified**; read the SA150 note for box 5 before displaying a value.

## SA100 page TR 5

Student Loan and Postgraduate Loan section (the 2025/26 form): **1** X if the Student Loans Company notified that repayment was due before 6 April 2026; **2** Student Loan repayments deducted by employer (total of all PAYE employments from P60/payslips); **3** Postgraduate Loan repayments deducted by employer.

High Income Child Benefit Charge section (numbering restarts): **1** total Child Benefit for full weeks where a Monday falls in the tax year (52 Mondays for 2025/26: first week starts 7 April 2025, last Monday 30 March 2026; include only from the start date or to the stop date in partial years); **2** number of children Child Benefit was received for on 5 April 2026; **3** date all Child Benefit stopped if before 6 April 2026. Applies where income is over 60,000 and you or your partner got Child Benefit; in couples, the higher income.

Marriage Allowance section: 1 spouse first name; 2 last name; 3 NI number; 4 date of birth; 5 date of marriage. Transferor completes; recipient leaves blank.

Winter Fuel Payment / Pension Age Winter Heating Payment charge section: **1** total received in 2025/26 (over State Pension age, total income over 35,000, no qualifying benefit).

## SA100 page TR 6, TR 7, TR 8

TR 6: 1 tax refunded or set off; 2 X if you do not want a balance under 3,000 collected through your 2027/28 code (paper by 31 October 2026, online by 30 December 2026); 3 X if you do not want tax on savings, casual earnings and/or HICBC for 2026/27 collected through your 2026/27 code; 4 bank name; 5 account holder; 6 sort code; 7 account number; 8 building society reference; 9 X no UK account; 10 X nominee; 11 X nominee is tax adviser; 12 nominee address; 13 postcode; 14 nominee signature.
TR 7: 15 adviser name; 16 phone; 17 address; 18 reference; 19 any other information.
TR 8: 20 X provisional figures; 21 X enclosing separate supplementary pages; 22 declaration signature and date; 23 capacity if signing for someone; 24 name of person signed for; 25 your name; 26 your address.

Payments-on-account reduction is **not** on SA100: it is on the SA110 summary (below).

## SA103S: short self-employment (2025/26, turnover under 90,000)

[Form](https://assets.publishing.service.gov.uk/media/69c12ae013101e9908704a53/SA103S-2026.pdf), [notes](https://assets.publishing.service.gov.uk/media/69ce15395cf899414a0bc69f/SA103S_Notes_2026.pdf). Verified from the PDFs (this corrects the earlier note, which had box 29 as the net loss).

| Box    | Label                                                                                                                        |
| ------ | ---------------------------------------------------------------------------------------------------------------------------- |
| 1      | Description of business                                                                                                      |
| 2      | Postcode of business address                                                                                                 |
| 3      | X if name, description, address or postcode changed in the last 12 months                                                    |
| 4      | X if foster carer or shared lives carer                                                                                      |
| 5Q / 5 | Started after 5 April 2025? Yes/No; start date                                                                               |
| 6Q / 6 | Ceased before 6 April 2026? Yes/No; final trading date                                                                       |
| 7      | Date books made up to (31 March to 5 April 2026, or final trading date)                                                      |
| 8      | X if traditional accounting rather than cash basis                                                                           |
| 9      | Turnover                                                                                                                     |
| 10     | Other business income not in box 9                                                                                           |
| 10.1   | Trading income allowance                                                                                                     |
| 11     | Cost of goods bought for resale or used                                                                                      |
| 12     | Car, van and travel expenses, after private use                                                                              |
| 13     | Wages, salaries and other staff costs                                                                                        |
| 14     | Rent, rates, power and insurance                                                                                             |
| 15     | Repairs and maintenance of property and equipment                                                                            |
| 16     | Accountancy, legal and other professional fees                                                                               |
| 17     | Interest and bank and credit card financial charges                                                                          |
| 18     | Phone, fax, stationery and other office costs                                                                                |
| 19     | Other allowable expenses (client entertaining not allowable)                                                                 |
| 20     | Total allowable expenses (boxes 11 to 19; may be used alone if turnover under 90,000)                                        |
| 21     | Net profit (9 + 10 minus 20, if positive)                                                                                    |
| 22     | Net loss (20 minus (9 + 10), if positive)                                                                                    |
| 23     | Annual Investment Allowance                                                                                                  |
| 24     | Allowance for small balance of unrelieved expenditure                                                                        |
| 24.1   | Zero-emission car allowance                                                                                                  |
| 25     | Other capital allowances                                                                                                     |
| 25.1   | Structures and Buildings Allowance                                                                                           |
| 25.2   | Freeport and Investment Zones SBA                                                                                            |
| 26     | Total balancing charges                                                                                                      |
| 27     | Goods and/or services for own use                                                                                            |
| 28     | Net business profit for tax purposes: 21 + 26 + 27 minus (22 to 25.2), if positive; if 10.1 is used, 21 + 26 + 27 minus 10.1 |
| 29     | Loss brought forward set against this year's profit, up to the amount in box 28                                              |
| 30     | Other business income not in box 9 or 10                                                                                     |
| 31     | Total taxable profits: 28 + 30 minus 29, if positive                                                                         |
| 32     | Net business loss for tax purposes: (22 to 25.2) minus (21 + 26 + 27), if positive                                           |
| 33     | Loss from this year set against other income for 2025/26                                                                     |
| 34     | Loss to carry back to previous years                                                                                         |
| 35     | Total loss to carry forward after all set-offs                                                                               |
| 36     | X if profits under 6,845 and you choose voluntary Class 2                                                                    |
| 37     | X if exempt from Class 4                                                                                                     |
| 38     | Total CIS deductions (box 9 must show full income before CIS)                                                                |

If box 10.1 is claimed leave boxes 11 to 20 blank. Compute 20, 21, 22, 28, 29, 31, 32 from the others using the workings in `income-sources.md`.

## SA103F: full self-employment (2025/26)

[Notes](https://assets.publishing.service.gov.uk/media/69c26565cfa346b9d4704b35/SA103F_Notes_2026.pdf).

- **Business:** 1 name; 2 description; 3 to 5 address and postcode area (labels not read); 6Q/6 started after 5 April 2025; 7Q/7 ceased; 8 books start; 9 books made up to; 10 X traditional accounting (cash basis otherwise); 13 special arrangements (foster carers HS236, farmers HS224); 14 X if 2025/26 profit already reported last year.
- **Income:** 15 turnover; 16 other business income; 16.1 trading income allowance.
- **Allowable expenses:** 17 cost of goods; 18 construction subcontractors; 19 wages and staff; 20 car, van, travel; 21 rent, rates, power, insurance (including business use of home); 22 repairs and maintenance; 23 phone, stationery, office; 24 advertising and business entertainment; 25 interest on loans; 26 bank and financial charges; 27 irrecoverable debts (traditional only); 28 accountancy, legal, professional; 29 depreciation and loss/profit on sale (traditional only); 30 other (includes net VAT paid and transition adjustments); 31 total.
- **Disallowable add-backs:** 32 to 45 pair with 17 to 30 in order (32 with 17, 33 with 18, ... 45 with 30); 46 total. If a non-allowable element sits in an expense box, repeat it in the paired box.
- **Result:** 47 net profit; 48 net loss.
- **Capital allowances:** 49 AIA; 50 main-pool WDA (18%, cars 1 to 50g/km, small pools); 51 special-rate pool WDA (6%, cars over 50g/km); 52 zero-emission goods vehicles (expenditure to 5 April 2025); 52.1 zero-emission car 100% FYA; 53 SBA; 53.1 Freeport and Investment Zone SBA; 54 electric charge-point; 55 100% and other enhanced allowances (R&D; 40% FYA on expenditure from 1 January 2026); 56 allowances on sale or cessation; 57 total; 58 and 59 balancing charges (59 includes BPRA); 60 goods and services for own use; 62 receipts included but not taxable as profits.
- **Profit or loss for tax:** 64 net business profit for tax purposes; 65 net loss; 68 accounting-period adjustment; 71 change of accounting practice; 72 averaging adjustment; 73 adjusted profit; 73.3 transition profit spread; 73.4 loss b/f against transition profit; 74 loss b/f against adjusted profit; 75 other business income not in 15, 16, 60; 76 total taxable profits (excludes transition profit); 76.1 FIG claim; 77 adjusted loss; 77.1 FIG loss adjustment.
- **Losses:** 78 sideways against other income; 79 carried back; 80 carried forward.
- **Tax taken off:** 81 CIS deductions (turnover in box 15 must be gross); 82 other tax taken off trading income.
- **Balance sheet:** 83 to 99 (94 net business assets; 95 balance at start; 96 net profit or loss).
- **NIC:** 100 voluntary Class 2; 101 Class 4 exempt; 102 Class 4 adjustments; 103 any other information.
- Not read: boxes 3 to 5, 11 to 12, 61, 63, 66 to 67, 69 to 70 labels. The 2026/27 SA103F is published April 2027.

## SA102 employment, SA105 property, SA106 foreign, SA108 gains

Full box lists are in `income-sources.md` sections 2 to 5 (SA102 boxes 1 to 20; SA105 boxes 3 to 45; SA106 boxes 1 to 32 plus 33 and 37 to 40; SA108 boxes 3 to 54). SA101 (additional information) and SA109 (residence, FIG) are listed there too; SA101's full map and SA109 boxes 11 to 60 were not extracted.

## SA110: Tax calculation summary and working sheet (2025/26)

Source: [SA110 notes](https://assets.publishing.service.gov.uk/media/69c4fc274a06660f0854422a/SA110-Notes-2026.pdf), pages TCSN 28 and 29. The SA110 form PDF itself was not opened; summary boxes 1 to 17 come from the notes' confirmation table.

| Summary box | Content                                                                                               | Working-sheet source |
| ----------- | ----------------------------------------------------------------------------------------------------- | -------------------- |
| 1           | Total tax, Student Loan repayment and Class 4 NIC due before payments on account                      | A343                 |
| 2           | Total overpaid                                                                                        | A343a                |
| 3           | Student Loan repayment due (whole pounds, rounded down; only if SA100 TR 5 student loan box 1 ticked) | A333                 |
| 3.1         | Postgraduate Loan repayment due (whole pounds, rounded down)                                          | A334                 |
| 4           | Class 4 NIC due                                                                                       | A329                 |
| 4.1         | Class 2 NIC due (voluntary or required)                                                               | A330                 |
| 5           | Capital Gains Tax due                                                                                 | A341                 |
| 6           | Pension charges due                                                                                   | A275                 |
| 7           | Underpaid tax for earlier years in the 2025/26 code                                                   | A332                 |
| 8           | Underpaid tax for 2025/26 in the 2026/27 code                                                         | A338                 |
| 9           | Outstanding debt in the 2025/26 code                                                                  | from the code        |
| 10          | X if reducing 2026/27 payments on account (reason in box 17)                                          |                      |
| 11          | First payment on account for 2026/27 (when reducing)                                                  | A360                 |
| 12, 13      | Blind person's / married couple's surplus allowance                                                   |                      |
| 14 to 16    | Adjustments for other tax years, loss carry-back credit (purpose inferred)                            | A346, A348, A349     |
| 17          | Reason for reducing payments on account                                                               |                      |

Working sheets: Student loan (section 21, TCSN 49 to 52): K1 to K7 employment income, K10 to K20 earned income, unearned income above a 2,000 threshold (K31, K32), minus loss and pension relief (TR 4 boxes 1 + 2 + 3 + 4), K37 total, K38 = K37 minus plan amount, K39 = K38 x 9%, K40 = SA100 TR 5 student loan deducted (the sheet misprints "box 13"; the form box is 2), K41 = K39 minus K40; postgraduate K42 = K37 minus 21,000, K43 x 6%, K44 = TR 5 box 3, K45. HICBC (section 20, TCSN 48): J1 to J8 as in `rates-and-allowances.md`, copied to A277. State Pension lump sum tax (TCSN 47): 20%, 40% or 45% (Scotland 42% or 48%) by where A164 falls. The working sheet cannot be used with certain Additional Information, Lloyd's, Trusts, FIG and Foreign page entries (listed on TCSN 1).

## Surface guards

Trading allowance claimed: hide expense boxes. Rent-a-Room used: no expenses. Residential finance costs: total in SA105 box 44 and the 20% credit shown separately. Paired disallowable boxes 32 to 45: only when the full cost was entered. FIG claim: warn about lost allowances. Mark any value that depends on a user choice.
