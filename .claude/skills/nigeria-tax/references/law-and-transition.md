# Law, transition, residency, foreign income, TIN

Tags: P primary (gazette read), P-snip, S secondary, I inferred, K general knowledge. Gazette URLs: NTA https://www.lirs.gov.ng/assets/docs/Gazette%20-%20NIGERIA%20TAX%20ACT,%202025.pdf (other copies https://irs.gm.gov.ng/docs/national/NIGERIA_TAX_ACT_2025.pdf, https://africacheck.org/sites/default/files/media/documents/2025-07/NIGERIA-TAX-ACT-2025.pdf); NTAA https://tat.gov.ng/Nigeria-Tax-Act-2025.pdf (misnamed file; the file named NIGERIA-TAX-ADMINISTRATION-ACT-2025.pdf on that host is the NTA).

## Laws and dates

- NTA (2025 No. 7, signed 26 June 2025) "shall come into effect on the first day of January, 2026" (s.203). P.
- NTAA (2025 No. 5) is the procedural companion. P.
- Section 196 repeals: Capital Gains Tax Act, Casino Act, Companies Income Tax Act, Deep Offshore and Inland Basin Act, Industrial Development (Income Tax Relief) Act, Income Tax (Authorised Communications) Act, Personal Income Tax Act, Petroleum Profits Tax Act, Stamp Duties Act, Taxes and Levies (Approved List for Collection) Act, Value Added Tax Act, Venture Capital (Incentives) Act. P.
- Year of assessment = government tax year, 1 January to 31 December (interpretation section). P.
- FIRS is succeeded by the Nigeria Revenue Service (NRS) under the NRS (Establishment) Act; the NTAA refers to "the Service". The NRS cites that Act, the NTAA and the NTA as the legal basis of e-invoicing enforcement (S, Vanguard https://www.vanguardngr.com/2026/07/nrs-sets-july-31-deadline-for-large-taxpayers-to-adopt-e-invoicing-system/). The Establishment Act text was not read.
- The NTA mentions a "Joint Revenue Board" (s.29: presumptive-tax regulations made on its advice). It appears to succeed the Joint Tax Board; no source says so (I).
- State and FCT tax authorities administer tax on resident individuals under the First Schedule (NTAA s.3(2)). P.

## General Transition Guidelines (issued 18 June 2026) (S)

Source: https://www.legal500.com/intelligence/nigeria/tax/overview-of-key-provisions-of-the-general-transition-guidelines-for-the-tax-acts-2025 and https://www.lawyard.org/news/fg-unveils-tax-acts-2025-transition-framework-clarity-for-businesses-ahead-of-2026-commencement/. The Guidelines text itself was not read (finance.gov.ng was down).

- Apply to returns due from 1 January 2026; treatment follows the basis period, not the filing year.
- Company basis periods ending before 1 January 2026 stay under the repealed law; ending on or after 1 January 2026 go under the Tax Acts. Early adoption by companies is possible with written approval.
- Individuals on direct assessment: "2025 income filed in 2026 shall be taxed based on the repealed legislation"; income from January 2026 is under the Tax Acts.
- Monthly PAYE remittances and final filings for calendar 2025 stay under the repealed law.
- Goods delivered or services rendered up to 31 December 2025 are governed by the repealed WHT, VAT and stamp duty law whenever paid.
- TETFund, NASENI and NITDA levies apply only to accounting periods ending before commencement; later periods pay the 4% development levy.
- Old forms are valid for returns due before commencement; "existing forms and procedures will remain temporarily valid".
- A second summary says Rev360 was configured for 2026 year-of-assessment filings under the new Acts before the Guidelines were published, which conflicts with the Guidelines.

## Basis period vs filing year (I)

- A return filed in 2026 for 2025 income follows PITA/CITA: old bands, CRA, old CIT tiers and levies.
- A return filed in 2027 for 2026 income follows the NTA.
- NTA s.22(1) still says business assessable profits are "the profits of the accounting period immediately preceding the year of assessment" (preceding-year basis). Section 26(1) takes employment income as the income "of the year of assessment" (current year). NTAA s.13(2)(b) asks for income "for the year preceding the year of assessment". The text is internally inconsistent; follow the Transition Guidelines.
- Data model: each `TaxInput` carries `basisPeriodStart`, `basisPeriodEnd` and the law version chosen from the end date (before 1 January 2026 gives `old`, otherwise `nta`). `filingYear` is a separate field. The current pack uses a calendar-year cash basis and a 31 December company year end (stated in its assumptions).
- No authoritative source covers a non-calendar business year straddling 1 January 2026 and filing a "2026 YoA" return.

## Residency and foreign income (P unless noted)

- Resident individual in a year of assessment if any: (a) domiciled in Nigeria, (b) a permanent place available for domestic use, (c) a place of habitual abode, (d) substantial economic and immediate family ties, (e) sojourns 183 days or more in a 12-month period (leave and temporary absence included), (f) serves as a diplomat of Nigeria abroad. A non-resident meets none (NTA interpretation).
- Residents: worldwide income; non-residents: Nigeria-sourced income (S: KPMG https://kpmg.com/xx/en/our-insights/gms-flash-alert/flash-alert-2025-168.html, PwC https://taxsummaries.pwc.com/nigeria/individual/significant-developments). Trust and estate income of a resident includes foreign income (Fifth Schedule).
- Exempt foreign income: s.163(1)(s) exempts "dividend, interest, rent or royalty derived from outside Nigeria and brought into Nigeria through approved channels". Not an exemption for foreign employment or business income.
- Foreign tax credit (s.120): for a resident's foreign-source income taxed abroad, credit = lower of Nigerian tax attributable and foreign tax paid; attributable tax = (foreign income / total income) x Nigerian tax. Treaty credits (ss.121-122) follow the same lower-of rule, need ratification or domestication, are not available to non-residents, and no deduction is allowed for foreign tax. A time limit for credit claims exists but the text was truncated in the research.
- S (PwC): resident creatives lose the exemption on foreign-currency foreign earned income repatriated; domiciliary-account interest is no longer exempt. Remote workers are taxed in Nigeria if resident or working in Nigeria; non-resident employees of qualifying start-ups or tech and creative companies are exempt where taxed in their residence country (KPMG).
- Residency engine: count days in Nigeria including leave; yes/no flags for the other tests; do not default to resident silently.
- Digital assets are situated in Nigeria where the direct or indirect beneficial owner is resident or has a Nigerian permanent establishment (s.46(n)).

## Treaties (S)

- Source: PwC https://taxsummaries.pwc.com/nigeria/corporate/withholding-taxes. UK 10% on dividends, interest, royalties and management/technical fees. A garbled KPMG table (https://assets.kpmg.com/content/dam/kpmg/ng/pdf/tax/firs-terminates-uniform-wht-rate-for-residents-of-treaty-countries.pdf) may show 10/10/5; unresolved. FIRS ended the uniform 7.5% treaty WHT rate from 1 July 2022 (S).
- In force per PwC: Belgium, Canada, China, Czech Republic, France, Netherlands, Pakistan, Philippines, Romania, Singapore, Slovakia, South Africa, Spain, Sweden, UK. Not in force or not ratified: various ECOWAS countries, South Korea, Kenya, Mauritius, Poland. Germany is absent: treat German treaty relief as unavailable (I); do not apply it.
- UK side (S, PwC UK): interest and royalties to Nigerian residents 12.5%. Treaty rules for individuals (employment, pensions, 183-day tests) were not researched. Verify against the treaty text before showing any treaty rate.

## Tax ID (TIN) (P)

- NTAA s.4: every taxable person must register and obtain a Tax ID. s.7(5): a person with a valid Tax ID shall not obtain another. s.7(3): the authority may register a person on information it has. s.9: notify changes within 30 days.
- s.8(1): the Tax ID goes on returns, notices, correspondence and transaction documents and is a condition for contracting with federal or state bodies. s.8(2): banking, insurance, stock-broking and other financial services shall make the Tax ID a precondition for opening or operating an account. Regulators said there would be no blanket account blocks on 1 January 2026 (S). Enforcement status unverified.
- s.100(2): contracting with an unregistered person costs N5,000,000. See penalties.
- NIN/TIN linkage for individuals: only a low-quality source mentions it; unverified.
