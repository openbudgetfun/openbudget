# VAT, input recovery, returns, e-invoicing, withholding tax

Tags: P primary (gazette read), P-snip, S secondary, I inferred, K general knowledge. NTA gazette: https://www.lirs.gov.ng/assets/docs/Gazette%20-%20NIGERIA%20TAX%20ACT,%202025.pdf; NTAA gazette: https://tat.gov.ng/Nigeria-Tax-Act-2025.pdf.

## VAT (NTA, from 1 January 2026)

- Rate 7.5% (s.148). P.
- Zero-rated, s.187 (P): basic food items; all medical and pharmaceutical products; educational books and materials; fertilisers, locally produced agricultural chemicals, veterinary medicine and animal feed; live cattle, goats, sheep and poultry; agricultural seeds and seedlings; medical services; tuition for nursery, primary, secondary or tertiary education; exported goods (excluding oil and gas), exported services and exported incorporeal property; medical equipment; electric vehicles and their parts. Some secondary summaries call healthcare and education "exempt"; the gazette zero-rates them. Zero-rating keeps input VAT recoverable.
- Exempt, s.186 (P): baby products; locally manufactured sanitary products; shared passenger road transport; agricultural equipment hire or purchase; land and buildings; money and securities; government licences; assistive devices. Exempt supplies carry no output VAT and no input recovery.
- Input VAT, s.156(5): input tax on "any taxable supply, including services and fixed assets" is deductible only to the extent incurred for taxable supplies; mixed supplies apportioned (a); deduction window five years after the end of the tax period (b). s.156(6): only supplies made from commencement. Excess input VAT carries forward as a credit or the taxpayer may request a refund (s.156(1)-(2)); a 0%-rated supplier may request refund of VAT paid on inputs (s.156(4)). Refund claims within 12 months of the transaction, authority to refund within 30 days (NTAA text partly read; EY https://www.ey.com/en_gl/technical/tax-alerts/nigeria-tax-act-2025-has-been-signed-highlights, S).
- Invoice content (s.153): supplier tax ID, sequential invoice number, supplier name and address, registration number, date of supply, purchaser name, gross amount, VAT charged and rate. Invoices are required whether or not payment has been made. The Service may direct a taxable person to adopt electronic invoices on at least 30 days' notice (s.153(4)); taxable persons must implement the Service's fiscalisation system (s.158).
- Government and agencies withhold VAT on supplies to them and remit by the 14th of the following month (s.155(4)).

## VAT returns and the small-business rule (NTAA, P)

- s.22: file "on or before the 21st day of the following month", whether or not any economic activity occurred; shows input tax, output tax and VAT payable; an extension to file does not extend time to pay. No NRS guidance was read on weekends or the exact form.
- s.22(4): the monthly-return duty does not apply to a small business. s.22(5): a small business may opt out of the exemption by written notice to the Service (registration, charging VAT, filing). s.22(6): a business ceasing to be small files monthly. s.22(7): capital-asset sales and sales of the whole business are excluded when testing the threshold.
- Small business = gross turnover N100m or less and total fixed assets N250m or less, not providing professional services (NTAA definition). Several secondary guides still say N25m (the old VATA registration threshold, Finance Act 2019, S) and one says N50m. Use the NTAA definition with a configurable override and a warning.
- The N100m figure sits next to the N50m small-company conflict: do not link the two parameters.
- Sole proprietors and small companies under the threshold have no VAT return duty but must prepare invoices if they register or opt in (I).

## E-invoicing and the NRS Merchant-Buyer Solution (S)

- NRS launched MBS for large taxpayers on 1 August 2025. A 17 February 2026 public notice set a 31 July 2026 deadline for large taxpayers (gross turnover of N5bn and above) to adopt fully: onboard through an approved Access Point Provider or System Integrator, validate, transmit invoices, and receive only invoices with an Invoice Reference Number (IRN). Medium taxpayers (N1bn to N5bn) 1 July 2026 (one source). BusinessDay says small businesses join from July 2027; no NRS notice for small taxpayers was found. One source (tryduplo.com, 17 August 2026) reports a three-month extension for large taxpayers; official coverage does not mention it. Sources: https://www.channelstv.com/2026/07/19/e-invoicing-nrs-sets-july-31-deadline-for-large-taxpayers-warns-defaulters/, https://www.vanguardngr.com/2026/07/nrs-sets-july-31-deadline-for-large-taxpayers-to-adopt-e-invoicing-system/, https://www.mondaq.com/nigeria/tax-authorities/1821672/nrs-begins-compliance-monitoring-for-large-taxpayers-under-the-national-e-invoicing-system.
- Data model (I): `einvoice_phase` per taxpayer tier with a `mandatory_from` date; the invoice record carries an `irn` field and the submission status. Tiers and dates are versioned data with an S tag.

## Withholding tax

- NTAA s.51 (P): the payer deducts at the date of payment "at the rate prescribed in regulations relating to deduction of tax at source". For non-resident recipients, WHT on dividends, interest, rent, royalties, directors' fees and entertainers is the final tax. Dividends and interest on short-term securities or corporate bonds received by individuals after WHT are not charged to further tax. NTA s.28 treats income subject to final WHT as a deduction from total income. s.51(8): a 5% final deduction applies to services from non-resident companies to labelled startups. NTAA s.107 penalises failure to remit; amounts at s.65 and in `gains-digital-penalties.md`.
- Deduction of Tax at Source (Withholding) Regulations 2024 rate table (S, PwC https://taxsummaries.pwc.com/nigeria/corporate/withholding-taxes; the regulation PDF https://isc.ng/wp-content/uploads/2024/08/DEDUCTION-OF-TAX-AT-SOURCE-WITHHOLDING-REGULATIONS-2024-Final-Review.pdf is scanned and was not read):

| Transaction                                                       | Company resident | Company non-resident | Individual resident | Individual non-resident |
| ----------------------------------------------------------------- | ---------------- | -------------------- | ------------------- | ----------------------- |
| Dividends and interest                                            | 10%              | 10%                  | 10%                 | 10%                     |
| Royalty                                                           | 10%              | 10%                  | 5%                  | 5%                      |
| Rent, hire, lease                                                 | 10%              | 10%                  | 10%                 | 10%                     |
| Commission, consultancy, technical, management, professional fees | 5%               | 10%                  | 5%                  | 10%                     |
| Supply of goods (not by manufacturer or producer)                 | 2%               | n/a                  | 2%                  | n/a                     |
| Other services                                                    | 2%               | 5%                   | 2%                  | 5%                      |
| Construction (roads, bridges, buildings, power plants)            | 2%               | 5%                   | 2%                  | 5%                      |
| Other construction and related                                    | 5%               | 10%                  | 5%                  | 10%                     |
| Brokerage                                                         | 5%               | 10%                  | 5%                  | 10%                     |
| Directors' fees                                                   | n/a              | n/a                  | 15%                 | 20%                     |
| Compensation for loss of employment                               | n/a              | n/a                  | 10%                 | 10%                     |
| Winnings                                                          | n/a              | n/a                  | 5%                  | 15%                     |

- No TIN: twice the rate, up to 20% (PwC). The regulations were gazetted 2 October 2024 and effective 1 January 2025 per one summary; another says 1 July 2024 (S). One guide says VAT and WHT rates did not change when the NTA took effect (S, https://owoode.com/guides/nigeria-tax-rates-2026). No NTAA-era WHT regulation was found in 2026; whether the 2024 regulations survive the repeal of their parent laws is unconfirmed.
- Small suppliers: a small company (turnover N25m or less) and equivalent unincorporated bodies need not deduct WHT when the supplier has a valid TIN and the transaction value is N2m or less in the month; sources differ whether the cap is monthly or annual (S, EY https://taxnews.ey.com/news/2024-1347-nigeria-issues-deduction-of-tax-at-source-withholding-regulations-2024, TaxSpire https://blog.taxspire.com/wht-rates-nigeria-2026/). Use a WHT-specific threshold parameter, not the company or VAT ones.
- Remittance by the 21st of the month after deduction; the payer issues a WHT credit note; failure to deduct or remit attracts 10% of the tax plus interest (S, TaxSpire).
- Receiving side: record the credit note and use it as a credit against tax due, not as an income deduction (I). The exact credit-note form and e-filing channel (NRS vs State IRS for individuals) were not found.
- Test vectors: `test-vectors.md` (W1 to W5).

## Pack status (as of 5 November 2026)

Implemented: 7.5% output less input VAT for registered persons, small-business tip using N100m / N250m / professional-services tests, 21st-of-month reminder, WHT credit-note categories. Not implemented or differing:

- The `exempt` revenue category description lists "medical services" as exempt; the gazette zero-rates medical services (s.187) and exempts land and buildings (s.186).
- A VAT credit is carried forward and never refunded unless the supplies are zero-rated; the gazette also allows a refund request for excess input VAT (s.156(1)-(2)).
- No five-year recovery window, no apportionment (input VAT treated as fully recoverable, stated in assumptions), no government VAT withholding, no e-invoicing or IRN fields, no WHT rate table or deduction, no payer-side small-supplier test.
- Fixed assets are proxied by current-year capital additions in the small-business test.
