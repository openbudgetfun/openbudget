# Income sources: self-employment, employment, property, foreign income and FIG, capital gains

Research date: 5 November 2026. Tags: **P** primary (official form or notes read), **P-snip** (official page seen only through a summary), **S** secondary, **I** inferred. Box numbers are for the 2025/26 forms (HMRC 12/25 editions) and are keyed by tax year in `sa-box-map.md`.

## 1. Self-employment (SA103S and SA103F)

### Which form

- Use **SA103F** (full) if turnover is 90,000 or more; the accounting period ended before 31 March 2026, is not 12 months or does not end in the tax year; there is adjustment income from a change of basis; Class 4 adjustments are needed; or the person is in the Managing Serious Defaulters programme. Otherwise **SA103S** (short). **P**: [SA103F notes](https://assets.publishing.service.gov.uk/media/69c26565cfa346b9d4704b35/SA103F_Notes_2026.pdf), [SA103S notes](https://assets.publishing.service.gov.uk/media/69ce15395cf899414a0bc69f/SA103S_Notes_2026.pdf).
- Turnover under 90,000 (and not in MSD): a single total expenses figure is allowed (SA103F box 31, SA103S box 20).
- Provisional figures are allowed if the final figure is unknown by the deadline: on SA103F fill boxes 1 to 16, 47 or 48, 64 or 65, 73, 76 or 77 (plus 73.3, 73.4, 74 if applicable) and explain in box 103; tick SA100 TR 8 box 20.
- Both forms have the same expense headings: 14 on the full form, 9 on the short form. The paired disallowable boxes (SA103F 32 to 45) matter only when the full cost is entered and a non-allowable part is derived. Design choice (**I**): store only the allowable amount per category and leave boxes 32 to 46 blank unless the user wants the computation trail.

### Accounting basis

- **Cash basis is the default** on the 2025/26 forms. Tick SA103F box 10 / SA103S box 8 only for traditional (accruals) accounting. Cash basis: income when received, expenses when paid; limited companies cannot use it. Under cash basis, capital allowances are available only for cars; other capital purchases are deducted as expenses. Irrecoverable debts (box 27) and depreciation (box 29) exist only under traditional accounting, where depreciation is disallowed and AIA/WDA apply. A change of basis may give an adjustment in SA103F box 71. **P**: [Simpler Income Tax: cash basis](https://www.gov.uk/simpler-income-tax-cash-basis).
- VAT-registered cash-basis users may include VAT: net VAT paid goes in box 30, net VAT repayment received in box 16 (SA103F). **P**.
- Property cash basis only if UK property income is up to 150,000 (SA105 box 20.2). **P**.
- Tax-year basis applies from 2024/25 (2023/24 was the transition year). An accounting year ending 31 March to 4 April may be treated as ending 5 April; other period ends need apportionment (SA103F box 68). Transition profit spread: 33.3% of the remaining amount in each remaining year, shown in box 73.3; acceleration election allowed (details in box 103). **P**.

### Trading allowance

- Receipts up to 1,000 a year across all self-employment and miscellaneous income are exempt and need not be reported (unless from a connected party).
- Above 1,000 choose **either** the allowance or actual expenses. The allowance is split across businesses and miscellaneous income (maximum 1,000 total), cannot create a loss, cannot be combined with capital allowances or loss sideways relief, and if claimed boxes 17 to 31 (SA103F) or 11 to 20 (SA103S) stay blank. SA103F box 16.1 / SA103S box 10.1.
- Rent-a-Room via SA103: if receipts exceed 7,500 (3,750 shared) put 7,500 in SA103S box 19 / SA103F box 30; no expenses, capital allowances or trading allowance.
- MTD users: remove expenses from the final cumulative update before claiming the trading allowance in the annual submission. **P**: [HMRC guide: updates at tax year end](https://developer.service.hmrc.gov.uk/guides/income-tax-mtd-end-to-end-service-guide/documentation/make-updates-at-tax-year-end.html).
- Announced: allowance rises to 3,000 from 6 April 2027 (not enacted; see `rates-and-allowances.md`).

### Simplified expenses

Rates are in `rates-and-allowances.md`. Flat-rate vehicle goes into SA103F box 20 / SA103S box 12; home-use flat rate into box 21 / box 14. Simplified expenses cover vehicle costs and **either** business use of home **or** private use of business premises, not both. Source: [vehicles](https://www.gov.uk/simpler-income-tax-simplified-expenses/vehicles), [working from home](https://www.gov.uk/simpler-income-tax-simplified-expenses/working-from-home).

### Capital allowances

- Annual Investment Allowance 1,000,000 (since 1 January 2019), pro-rated for periods not 12 months; not available on cars. [GOV.UK AIA](https://www.gov.uk/capital-allowances/annual-investment-allowance) **P**.
- Writing-down: 18% main pool, 6% special-rate pool; small pools allowance for balances up to 1,000; zero-emission cars 100% first-year allowance (SA103F box 52.1); 40% first-year allowance for qualifying plant and machinery expenditure on or after 1 January 2026 (box 55); Structures and Buildings Allowance box 53; electric charge-point 100% box 54; private-use items go in single-asset pools. **P** (SA103F notes).
- SA103F boxes: 49 AIA; 50 main pool WDA; 51 special pool WDA; 52 zero-emission goods vehicles (expenditure to 5 April 2025 only); 52.1; 53; 53.1; 54; 55; 56 allowances on sale or cessation; 57 total; 58 to 59 balancing charges.

### Losses

- **Sideways** (SA103F box 78 / SA103S box 33): against other income of the same year, limited to the greater of 50,000 or 25% of adjusted total income; unused loss can be set against same-year gains; not available with the trading allowance.
- **Carry-back** (box 79 / SA103S 34): against 2024/25 income then gains; against the 3 earlier years (2022/23 to 2024/25, earliest first) only if the business began after 5 April 2022 (early-years relief); terminal loss relief on cessation (final 12 months, same business, final year and 3 earlier years).
- **Carry forward** (box 80 / SA103S 35): against future profits of the same business; brought-forward losses go in box 74 (SA103F) / SA103S 29 and first against transition profit via 73.4.
- Property losses carry forward against future property profits only (SA105 boxes 39, 41 to 43); only agricultural expenses or capital allowances losses go against other income (box 42, same 50,000 / 25% cap).
- Loss-relief rules were not quoted from legislation (ITA 2007 ss.64, 72, 83, 89, 96). **I**.

### Profit workings (SA103F, HMRC SEFN 12 to 13)

- Box 47 net profit = boxes 15 + 16 minus 31; box 48 net loss.
- Box 64 / 65 = (47 or minus 48) + 46 + balancing charges 58, 59 + 60 minus capital allowances 57 + 62. **Capital allowances are in box 64; the trading allowance is not.**
- Box 73 adjusted profit = 64 + positive 68 minus 16.1 minus negative 68 + 71 +/- 72.
- Box 76 total taxable profits = (73 minus 74) + 75; transition profit shown separately in 73.3. This is the figure that flows to the SA100 tax calculation.
- SA103S workings: A = net profit (21) or loss (22); B = balancing charges (26); C = own use (27); D = A + B + C; E = capital allowances (23 to 25.2) or trading allowance (10.1); F = D minus E (positive to box 28, negative to box 32); G = brought-forward loss (29, up to box 28); H = F minus G; I = other business income (30); J = H + I to box 31.
- CIS: turnover (SA103F box 15, SA103S box 9) must be gross, before CIS deductions; deductions go in SA103F box 81 / SA103S box 38.

## 2. Employment (SA102, one page per employment)

Box 1 pay (P60/P45); 1.1 payrolled benefits included in box 1; 2 UK tax taken off; 3 tips and other payments not on P60; 4 employer PAYE reference; 5 employer name; 6 director (6.1 ceased); 7 close company (7.1 name, 7.2 number, 7.3 dividends received, 7.4 shareholding); 8 off-payroll working income; 9 company cars and vans; 10 fuel; 11 private medical and dental; 12 vouchers, credit cards, excess mileage allowance; 13 goods and other assets; 14 accommodation; 15 other benefits (including loans); 16 expenses payments received and balancing charges; 17 business travel and subsistence; 18 fixed deductions (flat rate); 19 professional fees and subscriptions; 20 other expenses and capital allowances. Dividends from a close company also go in box 7.3. **P**: [SA102 notes](https://assets.publishing.service.gov.uk/media/69bd6a9c13101e99087049cc/SA102-Notes-2026.pdf). Student-loan earnings base uses boxes 1 + 3 + 12 + 16 minus 1.1. Details of boxes 6 to 8 completion were not extracted.

## 3. UK property (SA105)

- Use if property income exceeds 1,000 (including foreign property). Furnished holiday lettings regime abolished from 5 April 2025: FHL income is now ordinary property income.
- **Property allowance 1,000** (box 20.1): cannot be combined with expenses; unavailable if any income is from a connected party; maximum 1,000 across all property businesses; if claimed leave boxes 24 to 29 (or 30, 32 to 36) blank. Premiums, reverse premiums and balancing charges count as income for the allowance.
- Boxes: 3 jointly let; 4 Rent a Room; 20 total rents; 20.1; 20.2 traditional accounting (cash basis only if UK property income is up to 150,000); 21 tax taken off; 22 premiums; 23 reverse premiums; 24 rent, rates, insurance, ground rents; 25 repairs; 26 non-residential finance costs; 27 legal, management, professional fees; 28 services including wages; 29 other allowable expenses (if income under 90,000 a single total excluding residential finance costs may go in box 29); 30 private use adjustment; 31 balancing charges; 32 AIA (not for dwelling-house equipment); 33 SBA (33.1 EV charge-point, 33.2 Freeport SBA); 34.1 zero-emission car; 35 other capital allowances; 36 replacement of domestic items; 37 Rent a Room exempt amount; 38 adjusted profit; 39 loss brought forward used; 41 adjusted loss; 42 loss against total income (agricultural/capital allowances only); 43 loss to carry forward; 44 residential finance costs; 45 unused finance costs brought forward.
- **Residential finance costs are not deducted.** Enter the total (not 20%) in box 44; the tax reduction (20% of the lowest of finance costs, property profit, and adjusted total income above the PA) is computed in the SA110 working sheet. Source for "enter the total": SA105 notes plus an HMRC community forum reply ([thread](https://community.hmrc.gov.uk/customerforums/ifp/a24d382c-e750-ee11-a81c-002248c632e8)), **P-snip** quality for the forum part.
- Joint property: spouses taxed 50/50 unless a Form 17 beneficial-interest declaration; an accounting period ending 31 March to 4 April may be treated as ending 5 April.
- Property is non-savings income today; from 6 April 2027 it gets its own rate (announced).
- Source: [SA105 notes](https://assets.publishing.service.gov.uk/media/69cbb66fa60a12ca3913c62a/UK_property_notes.pdf).

## 4. Foreign income (SA106) and the FIG regime (SA109)

- **FIG regime** replaced the remittance basis from 6 April 2025. A qualifying new resident is in one of the first 4 years of UK residence after at least 10 consecutive years of non-residence; not an MP or peer; nationality, domicile and past remittance-basis use are irrelevant; claim each year (years do not roll over). Claim on SA109 box 28 for 2025/26. **P**: [GOV.UK 4-year FIG guidance](https://www.gov.uk/guidance/check-if-you-can-claim-the-4-year-foreign-income-and-gains-regime), [SA109 notes](https://assets.publishing.service.gov.uk/media/6ab6778c8cb3c0580e5011fb/sa109_notes_2026.pdf).
- A FIG claim loses the Personal Allowance, Blind Person's Allowance, Marriage Allowance and the CGT annual exempt amount; no relief for losses on wholly-foreign businesses; foreign losses of that year cannot be carried forward (SA108 box 47 note); people who used the remittance basis cannot claim relief for pre-6 April 2025 income or gains. Temporary Repatriation Facility designation is on SA109 boxes 50 to 53.
- FIG claim fields: SA103F 76.1, 77.1; SA106 4.1, 6.1, 30.1; SA108 6.1, 17.0, 26.1, 34.1.
- SA109 cannot be filed as an attachment; online filing needs commercial software or an agent. Other SA109 boxes: 1 non-resident; 3/3.1 split year; 4 resident in 2024/25; 6 date; 7 third automatic overseas test; 8 gap between employments; 9 home overseas; 10 days in UK; 54 other information. Boxes 11 to 60 not fully extracted.
- **SA106**: box 1 X if some foreign income could not be transferred to the UK; box 2 total foreign tax credit relief (FTCR) only if the user calculates it (HS263 working sheet) - HMRC calculates if blank (do not enter box 2 online). Overseas savings interest: columns A to F; D total to box 3, F total to box 4, 4.1 FIG claim. Foreign dividends: box 5 (D total), 6 (F total), 6.1 FIG. Remitted pre-6-April-2025 income 7.1 to 7.5. Column E X claims FTCR; column F = column B if claiming FTCR, otherwise B minus C. FTCR cannot be claimed on income relieved under FIG. Savings starting rate, PSA and dividend allowance and rates do not apply to remitted foreign income.
- Foreign property: 14 total rents; 14.1 allowance; 14.2 traditional accounting; 16 premiums paid; 17 allowable expenses; 19 private use; 20 balancing charges; 21 capital allowances; 21.1; 22.1; 22.2; 23 replacement items; 24 adjusted profit or loss; 24.1 residential finance costs; 24.2 unused finance costs; 26 loss brought forward; 27 total taxable profits; 30 total taxable amount; 30.1 FIG relief; 31 loss against total income; 32 loss to carry forward. Foreign capital gains FTCR: boxes 33 and 37 to 40 (not in box 2); gains must also be on SA108.
- Small amounts: untaxed foreign interest up to 2,000 and foreign dividends up to 500 (deduction relief) can go on SA100 TR 3 boxes 3, 6 and 7 instead of SA106. Credit and deduction relief cannot be mixed on one source.
- SA106 column labels A to F were not fully extracted. Model foreign income as per-source rows: country, amount in original currency, GBP amount at a stored rate and rate source, foreign tax, FTCR claim flag.
- Source: [SA106 notes](https://assets.publishing.service.gov.uk/media/69bbd6144c478213a823ce14/SA106_Notes_2026.pdf), [SA150 notes](https://assets.publishing.service.gov.uk/media/6a9ea8a5df4246cf45e469e0/SA150_Notes_2026.pdf).
- **Manual-review triggers (I):** FIG claim, non-residence, split year, chargeable event gains, trust income, partnership, remittance of pre-April-2025 income, SA101 items beyond a handful. Detect and flag; do not compute.

## 5. Capital gains (SA108)

Rates and exempt amount are in `rates-and-allowances.md`. Box groups (2025/26): residential property 3 to 13C (3 number; 4 proceeds; 5 costs; 6 gains; 6.1 FIG; 7 losses; 8 claim code; 9 gains on 60-day returns; 10 tax already charged; 11 non-UK residential and carried interest on real-time returns; 12 tax paid; 13 to 13C carried interest); cryptoassets 13.1 to 13.8; other property, assets and gains 14 to 22 (box 18 unused; 17.1 non-residential land; 17.2 to 17.4 BADR parts); listed shares 23 to 30; unlisted shares 31 to 44 (39 employee-shareholder; 40 SEIS; 41 to 44 share loss relief against income); losses 45 to 48 (45 brought forward used only to reduce gains to the annual exempt amount; 46 income losses against gains; 47 carried forward; 48 against earlier year); 49 Investors' Relief gains; 50 BADR gains (max 1,000,000); 50.1 lifetime claimed; 51 adjustments; 52.x NRCGT; 53 X if estimates; 54 other information (computations must be enclosed). Source: [SA108 notes](https://assets.publishing.service.gov.uk/media/6a02e5df4fb0713aa63ea77c/SA108-Notes-2026.pdf), [SA108 form](https://assets.publishing.service.gov.uk/media/69bd8990cfa346b9d47049e4/SA108-2026.pdf). **P**.

Share matching, pooling and crypto cost-basis rules are outside this skill; the tax pack takes proceeds and cost as entered.
