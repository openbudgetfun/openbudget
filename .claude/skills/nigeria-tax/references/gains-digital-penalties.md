# Capital gains, digital assets, penalties, interest, objections

Tags: P primary (gazette read), P-snip, S secondary, I inferred, K general knowledge. NTA gazette: https://www.lirs.gov.ng/assets/docs/Gazette%20-%20NIGERIA%20TAX%20ACT,%202025.pdf; NTAA gazette: https://tat.gov.ng/Nigeria-Tax-Act-2025.pdf.

## Capital gains (no separate CGT)

- CGTA is repealed (s.196). Chargeable gains are part of taxable income for individuals (s.28(2)(a)(v)) and total profits for companies (s.27(1)). Individuals pay at the personal bands (top 25%); companies at 30% through total profits (0% small company). P.
- Chargeable assets (s.34): "all forms of property" including shares, options, rights, debts, digital or virtual assets and incorporeal property. P.
- Computation: where capital allowances were claimed, only the residue is deducted from proceeds (s.39(a)); otherwise acquisition cost (s.39(b)); incidental disposal costs deductible (s.40). Gains of an individual are taken from disposals "during the year immediately preceding the year of assessment" (s.26(3)). P.
- Share exemption (s.34(1) proviso): gains on shares in a Nigerian company are not chargeable where (i) aggregate proceeds are less than N150,000,000 and the chargeable gain does not exceed N10,000,000 in any 12 consecutive months, (ii) the shares are in a regulated securities lending transaction, or (iii) proceeds are reinvested within the same year of assessment in Nigerian company shares (proportionate to the part reinvested). Encode "less than" for proceeds and "does not exceed" for the gain exactly. P.
- Section 50: compensation or damages up to N50m, including loss of office, is not a chargeable gain; only the excess is chargeable; the payer deducts and remits tax on the excess. Section 51: gains on a dwelling house and up to one acre of adjoining non-commercial land, once in a lifetime; mixed-use apportioned. Section 52: personal chattels exempt if aggregate consideration in the period does not exceed N5,000,000 or three times the annual national minimum wage, whichever is higher; linked disposals aggregated; currency excluded. Section 53: private motor vehicles, up to two per individual per year. Section 54: gifts with no consideration. Section 163(1)(m): angel, venture capital and similar gains on labelled startups held at least 24 months. P.
- Non-resident share disposals that change ownership or group membership of a Nigerian company are chargeable (s.47). P.
- Software (I): per-disposal ledger (cost basis, date, proceeds, fees); a separate pool for digital-asset losses; a 12-month rolling window for the share exemption; a lifetime flag for the residence exemption; a two-vehicle cap per year. No indexation or inflation relief appears in the text read. No acquisition-cost method (FIFO, average) is stated.

## Digital assets

- "Digital assets" means a digital representation of value that can be digitally exchanged, including crypto assets, utility tokens, security tokens, NFTs and similar assets or derivatives (interpretation). Digital assets are situated in Nigeria where the beneficial owner is resident or has a Nigerian permanent establishment (s.46(n)). Losses on digital or virtual assets can only be deducted against profits or gains from digital or virtual assets (ss.27(6), 28(3)(iv)). P.
- VASP reporting default: NTAA s.109 N10,000,000 for the first month and N1,000,000 for each later month (P-snip via Banwo & Ighodalo https://www.banwo-ighodalo.com/grey-matter/nigerias-new-tax-regime-a-taxpayers-guide-to-compliance-offences-penalties-enforcement-and-dispute-resolution/).
- Secondary reports say the NRS published Guidelines on the Taxation of Virtual Assets on 31 July 2026: VASPs report customer and transaction data (names, tax IDs, naira-equivalent values), may withhold on qualifying sales, charge VAT on their fees and file multiple returns; record retention six or seven years (sources differ). S (https://practiceguides.chambers.com/practice-guides/blockchain-crypto-assets-2026/nigeria/trends-and-developments, https://techcabal.com/2026/08/10/virtual-asset-rules-for-nigerian-vasps/ via search summary). No official guidelines text was retrieved.
- Two low-quality sources say individuals pay a flat 10% on crypto gains; this conflicts with the statute and the Big Four summaries and looks outdated. Do not use.
- Self-custody wallets and DeFi gains: no guidance found. VASP-reported data should be reconcilable against the user's own records (I).

## TIN and bank reporting (NTAA, P)

- Registration, TIN rules: see `law-and-transition.md`.
- s.29(1): financial institutions file annual returns of customers whose cumulative monthly transactions reach N50,000,000 (individuals) or N250,000,000 (body corporate). A law-firm summary gave N25m and N100m; the gazette text read says N50m and N250m, so prefer it.

## Penalties and interest (NTAA, P unless noted)

| Offence                                                               | Section        | Penalty                                                                                |
| --------------------------------------------------------------------- | -------------- | -------------------------------------------------------------------------------------- |
| Failure to register                                                   | s.100(1)       | N50,000 first month, N25,000 each subsequent month                                     |
| Contracting with an unregistered person                               | s.100(2)       | N5,000,000                                                                             |
| Failure to file, or knowingly filing incomplete or inaccurate returns | s.101          | N100,000 first month, N50,000 each subsequent month                                    |
| Late payment                                                          | s.65(1)(a)     | 10% of tax payable                                                                     |
| Late payment, interest                                                | s.65(1)(b)-(c) | naira: CBN MPR plus a spread set by the Minister; foreign currency: SOFR plus a spread |
| Non-compliance with a notice                                          | s.130          | N20,000,000 plus N2,000,000 per day, or six months' imprisonment                       |
| VASP reporting default                                                | s.109          | N10,000,000 first month, N1,000,000 each later month                                   |

- Sources: gazette ss.65, 100, 101 and Banwo & Ighodalo. One summary (1stattorneys https://1stattorneys.com/articles/2025/06/28/the-nigerian-2025-tax-reform-acts-legal-review-and-implications-for-stakeholders/) gives N50,000 / N25,000 for late filing, which is the registration penalty, not s.101.
- Penalty and interest are not treated as tax paid for relief (s.65(3)). A demand notice follows; enforcement may start 30 days after service (s.65(2)). The authority may remit penalty or interest "for any good cause shown" (s.66). If an extension to pay is granted and payment is missed, penalty and interest run from the original due date (s.49(6)).
- Interest order: the Nigeria Tax Administration (Interest on Late Payment of Tax) Order, 2026, made under s.65, effective 1 October 2026 (S, https://www.lawyard.org/news/fg-overhauls-late-tax-interest-regime-market-rates-to-dictate-penalties-from-october-1/, https://guardian.ng/news/fg-tightens-late-tax-payment-rules-introduces-market-linked-interest/): naira MPR plus 1 percentage point, floored at the 364-day Treasury Bill yield; foreign currency SOFR plus 6 points; simple interest calculated daily from the due date; one rate per calendar month, published by the NRS by the third business day of the month; interest accrued before 1 October 2026 stays under the old rules; the 10% penalty is unchanged; the same rate applies to State IRS taxpayers. No published monthly rate was found; day-count basis (365 or 360) is not stated.
- Month counting for s.100 and s.101 (calendar months vs 30-day periods) is not defined in the text read. The checker must show the formula and the assumption.
- Objections and appeals (S, Banwo & Ighodalo): notice of objection within 30 days of service of the assessment (s.41); the authority must respond within 90 days or the objection is upheld; appeal to the Tax Appeal Tribunal within 30 days.
- Test vectors: `test-vectors.md` (P1 to P3).
