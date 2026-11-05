# Companies: CIT, small company, development levy, minimum ETR, filing

Tags: P primary (gazette read), P-snip, S secondary, I inferred, K general knowledge. NTA gazette: https://www.lirs.gov.ng/assets/docs/Gazette%20-%20NIGERIA%20TAX%20ACT,%202025.pdf; NTAA gazette: https://tat.gov.ng/Nigeria-Tax-Act-2025.pdf.

## Rates and the small company (2026 basis periods)

- s.56: tax on total profits is "(a) a small company, at 0%; and (b) any other company, at the rate of 30 per cent from the commencement of this Act". No scheduled reduction to 25% appears in the gazette text read (P). The pack mentions a Presidential Order power to reduce to 25%; the research did not find that provision (verify).
- NTA definition of small company: "gross turnover of N50,000,000 or less per annum with total fixed assets not exceeding N250,000,000, provided that any business providing professional services shall not be classified as a small company" (P, interpretation section).
- NTAA definition of "Small Business": gross turnover of "N100,000,000.00 or less per annum with total fixed assets not more than N250,000,000.00", same professional-services exclusion (P). It drives VAT registration and the small-business return rules.
- Conflict: Taiwo Oyedele (chair of the Presidential Fiscal Policy and Tax Reforms Committee) said N100m is correct and N50m an error from gazetting, with a corrective finance law under way (April 2026). A 27 October 2026 article says the Act still states N50m and the June 2026 transition guidance refers to N100m. KPMG (July 2025) summarised the NTA as N100m, consistent with an earlier draft. No enacted correction found as of 5 November 2026. (S: https://www.thecable.ng/spotted-nigeria-tax-act-contradicts-ntaa-on-turnover-cap-for-small-business/, https://allafrica.com/stories/202604130589.html, https://www.withinnigeria.com/2026/10/27/taxes-and-levies-nigerian-small-business-owners-should-know-in-2026/; KPMG note only via TheCable.)
- Product rule (I): `smallCompanyTurnoverCeiling` is a per-tax-year parameter with two named options (`nta_gazette: N50m`, `ntaa_intended: N100m`), default `nta_gazette`, switchable by the user (or an admin data update when a corrective law is enacted). When turnover is above N50m and at or below N100m show a warning with both outcomes (30% plus 4% levy vs 0%). Never silently choose.
- Professional services: a company with professional-services business is never small regardless of turnover. Fixed assets are not tracked by the books; ask for total fixed assets as a profile input instead of using capital additions as a proxy.
- Small company return may contain "a statement of accounts attested by the taxpayer in place of audited financial statements" (NTAA s.11(1)(b) proviso).

## Development levy (P)

- s.59: 4% "on the assessable profits of all companies chargeable to tax under Chapters Two and Three of this Act, other than small companies and non-resident companies". Collected by the Service into a special account. Distribution includes TETFund 50%, Nigerian Education Loan 15%, NITDA 8%, NASENI 8%, National Board for Technological Incubation 4% (other recipients continue in the gazette).
- Under the Transition Guidelines the TETFund, NASENI and NITDA levies apply only to periods ending before commencement (S).
- Base: "assessable profits". Whether this is before or after losses and capital allowances is not defined in the text read. One secondary source says before (I): use assessable profits before losses and capital allowances and flag it. Whether chargeable gains sit inside assessable profits for the levy is also unconfirmed.

## Minimum effective tax rate (P, s.57)

- Where a company's effective tax rate is below 15% it pays additional tax to reach 15%. Applies to (a) constituent entities of an MNE group and (b) "any other company with an aggregate turnover of N20,000,000,000 and above". "Profits" = net profits before tax per audited financial statements, less 5% of depreciation and personnel cost.
- Skip unless turnover is N20bn or more or the company is in an MNE group. Small companies never reach it.

## Total profits, allowances, losses

- s.27(1): total profits = total assessable profits from all sources including chargeable gains, less losses (s.27(5)) and capital allowances (First Schedule Part I). Capital allowances are not prorated where non-taxable income is below 10% of total income (s.27(4)).
- s.27(5): losses are deducted only from the same trade or business, from the first year after the loss onward until used; no cap on carry-forward years in the text read. s.27(6): digital-asset losses only against digital-asset profits.
- Capital allowance classes 10/20/25% as in `personal-and-sole-proprietor.md`.

## Filing (NTAA, P)

- s.11(1): every company, "whether or not it is liable to pay tax", files a self-assessment return at least yearly: completed form, audited financial statements, tax computation and capital allowance computation (small companies may use attested accounts), evidence of payment, the effective tax rate and additional tax computation where applicable, and an attestation signed by a principal officer.
- s.11(5): due (a) for a company in business more than 18 months, not more than six months after the end of its accounting year; (b) for a new company, the earlier of 18 months from incorporation or six months after its first accounting period; (c) on cessation, six months after cessation. Calendar-year companies: 30 June of the next year (31 December year end).
- s.11(6): designate a representative for tax matters; a paid agent must be an accredited tax agent.
- s.49(1): tax payable on or before the filing due date, lump sum or instalments. Nil returns are required.
- Company form names were not found.

## 2025 old regime for comparison (S)

- CITA as amended: small companies (turnover up to N25m) 0%, medium (N25m to N100m) 20%, large 30%; Tertiary Education Tax 3% of assessable profit, small companies exempt. Sources: https://assets.kpmg.com/content/dam/kpmg/ng/pdf/clarification-on-the-exemption-of-small-companies-from-income-tax.pdf and https://www.commenda.io/nigeria/corporate-tax-rates; guides conflict on the Finance Act 2023 changes. NITDA, NASENI and Police Trust Fund levy rates for 2025 and the medium-company rules were not verified. Build the 2025 table only with a flagged "secondary" source note.

## Pack status (as of 5 November 2026)

Implemented: 30% CIT, 0% small company with turnover and professional-services tests, 4% levy on assessable profits, one-year capital allowance, VAT lines, six-month filing opportunity. Not implemented or differing:

- Small-company turnover ceiling is fixed at N50m; the N50m-N100m warning exists but is only an assumption text, not a switch. Fixed assets are proxied by current-year capital additions.
- Minimum ETR assumption text says N50bn of aggregate turnover and EUR 750m for MNE groups; the gazette says N20bn (EUR 750m is not in the research).
- Section references in comments and assumptions ("section 202" of the NTA, "section 147" of the NTAA) were not found in the research; the research cites the interpretation sections and NTAA s.22(4).
- No 2025 regime, no loss carry-forward store, no prior-year allowance pool, no non-calendar periods, no development-levy gains question, no new-company 18-month filing rule.
