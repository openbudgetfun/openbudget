# Sales invoices, supplier bills, credit notes, numbering, required contents, e-invoicing

Tags: **P** primary read; **P-snip** official page seen via search summary; **S** secondary; **I** inferred; **K** general knowledge.

## 1. Lifecycle (sales invoice; bill is symmetrical) [I]

Reference behaviour from Xero (statuses Draft, Awaiting Approval, Awaiting Payment, Paid, Voided, Deleted; approve on creation or later; an Awaiting Payment invoice can be edited but voiding is better once sent) [S] https://central.xero.com/0/article/Approve-an-invoice , https://central.xero.com/0/article/Edit-an-invoice-UK

Stored states and effects:

| State                          | Ledger effect           | Editable                                       | Number             |
| ------------------------------ | ----------------------- | ---------------------------------------------- | ------------------ |
| `draft`                        | none                    | fully, deletable                               | not issued         |
| `awaiting_approval` (optional) | none                    | fully                                          | not issued         |
| `approved`                     | journal posted          | only non-financial fields (notes, attachments) | assigned           |
| `voided`                       | reversal journal posted | no                                             | kept, never reused |

- `sent` is a delivery log, not a state. Keep every PDF version sent.
- `partially_paid`, `paid`: derived from `amount_due`. Cache `amount_due_minor`, rebuilt from allocations.
- `overdue`: derived, `due_date < today AND amount_due > 0`.
- `written_off`: derived from an allocation to a bad-debt journal.
- Voiding needs allocations removed first. A paid invoice's payment becomes an unallocated overpayment, not deleted money.
- A currency change after approval is not allowed; void and recreate.
- A negative invoice is a credit note with its own series.

## 2. Number assignment

- Assign at approval, inside the posting transaction, from `invoice_series(budget_id, series, next_value)` read with `SELECT ... FOR UPDATE`. A rolled-back transaction must not consume a number. [I]
- UK: HMRC requires "a sequential number, based on one or more series, which uniquely identifies the document"; alphanumeric allowed; a series need not start at 1 but must run consecutively. [P-snip] https://www.gov.uk/hmrc-internal-manuals/vat-trader-records/vatrec5010 , https://www.gov.uk/guidance/record-keeping-for-vat-notice-70021
- Germany §14 Abs. 4 Nr. 4 UStG: `eine einmalig vergebene fortlaufende Nummer`. Several ranges are used in practice if each is unique; store the series explicitly (for example `RE-2026-0001`). [P] https://www.gesetze-im-internet.de/ustg_1980/__14.html
- Nigeria: sequential numbering plus the NRS-issued IRN and QR once clearance applies. NTA 2025 s.152 cited, unverified. Do not change the number after clearance. [S]
- US: no federal rule found. Use unique sequential numbers as an audit and customer expectation. [I]

## 3. Credit notes, allocations, overpayments, prepayments, refunds, write-offs

- Xero has three credit objects: credit notes, overpayments, prepayments. An overpayment created while reconciling carries no tax by default. Before editing or voiding an overpayment, remove its allocation and any refund. Refunds are recorded against the credit object and reconciled to the bank line. [S] https://central.xero.com/0/article/Record-an-overpayment , https://central.xero.com/0/article/Edit-or-void-a-sales-overpayment , https://central.xero.com/0/article/Process-a-customer-or-supplier-refund
- Credit note [I]: own document type and series, references the original invoice, reversing journal (Dr Sales returns, Dr VAT output, Cr AR). Allocation is a link row `allocation(credit_id, document_id, amount_minor, date)` and posts nothing. AR control is unaffected by allocation because both documents already sit in AR. Allocation matters for open-item balances and aged reports.
- Overpayment [I]: Dr Bank, Cr AR (party credit) for the excess, or Cr `customer_credit`. A refund is Dr party credit, Cr Bank.
- Prepayment received [I]: Dr Bank, Cr `customer_credit` (a liability to deliver). VAT treatment is jurisdictional. German advance payments (Anzahlung): §14 Abs. 4 Nr. 6 UStG uses the receipt date as the supply date when fixed. [P] same §14 link.
- Write-off [I]: Dr bad debt expense (net), Dr VAT output adjustment where bad-debt relief applies, Cr AR. Model it as a credit-note-like document so aged AR and tax reports work. UK VAT bad-debt relief conditions (commonly six months after due date and written off in the accounts) were not sourced here [K].
- Allocation is independent of payment date. Removing an allocation restores `amount_due` exactly. Past-dated reports use allocation dates. [I]

## 4. Required invoice contents

### United Kingdom

- Full VAT invoice (supply over GBP 250, or GBP 250 or less if the customer asks): sequential number, tax point, date of issue if different, supplier name, address and VAT number, customer name and address, description, quantity or extent, VAT rate, amount excluding VAT per line, total excluding VAT, cash-discount rate, unit price, total VAT chargeable in sterling. [P-snip] https://www.gov.uk/hmrc-internal-manuals/vat-trader-records/vatrec5010 , https://www.gov.uk/guidance/vat-guide-notice-700
- Simplified invoice (GBP 250 or less, customer agrees): supplier name, address and VAT number, tax point, description, and per rate the total payable including VAT and the rate. No customer details. [P-snip] https://www.gov.uk/hmrc-internal-manuals/vat-trader-records/vatrec16042
- Foreign-currency invoice: any currency allowed for net and gross, but total VAT chargeable must be shown in sterling. [P] https://www.gov.uk/guidance/record-keeping-for-vat-notice-70021
- A zero-rated invoice is not a VAT invoice in the Notice 700 sense (para 3.5 as quoted), but zero-rated sales still appear at 0%. [P] https://www.gov.uk/guidance/vat-guide-notice-700
- E-invoices are optional, need customer agreement, carry the same information as paper, and any format is acceptable if the data is present (EDI, XML, CSV, PDF). No UK e-invoicing mandate appears (page last updated 26 May 2022). [P] https://www.gov.uk/guidance/electronic-invoicing-notice-70063
- Time limit to issue a VAT invoice (commonly 30 days) and credit/debit note content (Notice 700 s.18): not retrieved [K].

### Germany (§14 Abs. 4 UStG) [P] https://www.gesetze-im-internet.de/ustg_1980/__14.html

Full name and address of supplier and recipient; Steuernummer or USt-IdNr.; issue date; consecutive unique number; quantity and type or scope of service; supply date (for advance payments the receipt date if fixed and different); net consideration by rate and exemption plus agreed reductions; rate and tax amount or exemption note; note on the recipient's retention duty where applicable (Nr. 9); the word `Gutschrift` for recipient-issued (self-billing) invoices. This `Gutschrift` is not the English "credit note".

- An e-invoice (§14 Abs. 1) is issued, transmitted and received in a structured electronic format allowing electronic processing; paper and PDF are `sonstige Rechnung`.
- Invoicing within six months applies to B2B services and certain property services; where both parties are resident in Germany that invoice must be electronic.
- Kleinunternehmer (§19 UStG): from 1 January 2025 limits are EUR 25,000 net prior-year and EUR 100,000 net current-year (hard limit; the supply crossing it is taxable). Invoice shows no VAT, carries all §14 content except tax, and states the exemption; no official wording found (a vendor example is "Gemäß § 19 UStG wird keine Umsatzsteuer berechnet"). Unchanged for 2026 and 2027. [S] https://www.finanz.de/business/kleinunternehmerregelung/ , https://taxfix.de/ratgeber/selbststaendige/kleinunternehmergrenze/ . Whether Kleinunternehmer are exempt from the e-invoice issuing duty is believed true but unsourced.

### Nigeria (all secondary; the NRS site blocked fetches)

- Particulars listed by secondary sources: supplier and buyer TIN and details, unique invoice number, date, document type, transaction detail, VAT rate and amount shown separately. [S] https://invoicemonk.com/en/blog/firs-invoice-requirements-nigeria , https://taxstreem.com/resources/articles/the-ultimate-value-added-tax-guide-for-nigeria
- One commercial source says an invoice without an IRN or QR does not support input VAT credit; unverified. [S] https://vatit.com/e-invoicing-guide/nigeria/

### United States

No federal invoice-content rule was found. Sales-tax lines are by jurisdiction. [I]

## 5. Document model fields [I]

- Seller legal name, address, tax identifiers (VAT number, Steuernummer, USt-IdNr, TIN); customer legal name, address, tax ID (B2B).
- Number and series, issue date, supply or tax-point date, due date, currency and, for UK, the sterling VAT amount when not GBP.
- Lines: description, quantity, unit price, discount, net, tax code, tax rate, tax amount, gross.
- Per-rate tax summary, exemption or reverse-charge note, payment terms, bank details, VAT rounding method (per line or per invoice).
- E-invoice envelope: Leitweg-ID or buyer reference (XRechnung), IRN, QR payload, validation response and timestamp (Nigeria), original structured XML as an immutable attachment (Germany).

Invoice profile table (data, not code):

| Region              | Mode                                                                     | Mandatory elements                                           | Notes                                         |
| ------------------- | ------------------------------------------------------------------------ | ------------------------------------------------------------ | --------------------------------------------- |
| UK                  | full or simplified (GBP 250 or less)                                     | sequential number, tax point, VAT number, sterling VAT total | PDF acceptable                                |
| DE                  | EN 16931 e-invoice (XRechnung or ZUGFeRD); PDF allowed during transition | §14 Abs. 4 content                                           | receive now; archive the XML original         |
| DE Kleinunternehmer | no VAT shown, §19 reference                                              | §14 content minus tax                                        | switch profile on the date VAT status changes |
| NG                  | MBS-cleared invoice for in-scope taxpayers                               | TIN, IRN, QR                                                 | block `issued` until clearance returns        |
| US                  | free-form                                                                | none federal                                                 | sales-tax lines by jurisdiction               |

## 6. E-invoicing timelines (check dates before each release)

### Germany [S] https://www.ihk.de/dresden/hauptnavigation/recht-steuern/erechnung-6232764 , https://www.ihk-muenchen.de/ratgeber/steuern/steuerliche-sonderthemen/elektronische-rechnungen/ , https://www.haufe.de/steuern/gesetzgebung-politik/elektronische-rechnung-wird-pflicht-e-rechnung-im-ueberblick_168_605558.html

- Since 1 January 2025: every business must be able to receive e-invoices (an email inbox suffices).
- Issuing mandatory from 1 January 2027 for prior-year turnover above EUR 800,000; from 1 January 2028 for all. At or below EUR 800,000 other invoices (including PDF) are allowed until 31 December 2027.
- Format must conform to EN 16931. XRechnung and ZUGFeRD 2.x (from 2.0.1; MINIMUM and BASIC-WL excluded) and Factur-X satisfy it; a plain PDF does not. Peppol BIS Billing 3.0 is also EN 16931. No government platform; XRechnung is mandatory for federal B2G. [S] https://www.cleartax.com/de/en/e-invoicing-germany , https://edicomgroup.com/blog/germany-b2b-electronic-invoice
- BMF letters 15 October 2024 and 15 October 2025 (second covers error classes, validation, retention, per Ecovis); totals-only structured data tolerated until 31 December 2027 in certain gross-price cases. GoBD letter 14 July 2025: keep the structured XML as the original. [S] https://ecovis-kso.com/blog/neues-bmf-schreiben-zur-pflicht-e-rechnung-vom-15-10-2025/ , https://www.datext.de/blog/artikel/gobd-im-handwerksbetrieb-was-seit-juli-2025-zusaetzlich-gilt
- Primary BMF text was not read (one fetch returned 503).
- Software must: receive and parse XRechnung (UBL or CII XML) and ZUGFeRD (PDF/A-3 with embedded CII XML), validate against EN 16931 before posting a purchase invoice, keep the XML, export ZUGFeRD or XRechnung for sales from 2027, support `Gutschrift` labelling and Leitweg-ID. [I]

### Nigeria (NRS Merchant-Buyer Solution; secondary sources) [S] https://sovos.com/regulatory-updates/vat/nigeria-nrs-publishes-e-invoicing-timeline/ , https://nairametrics.com/2026/02/17/nrs-launches-phased-e-invoicing-fiscal-monitoring-system/ , https://www.vanguardngr.com/2026/07/nrs-sets-july-31-deadline-for-large-taxpayers-to-adopt-e-invoicing-system/

| Tier     | Turnover       | Go-live                                            | Enforcement                                           |
| -------- | -------------- | -------------------------------------------------- | ----------------------------------------------------- |
| Large    | above NGN 5bn  | late 2025 (sources differ: 1 Aug or November 2025) | April 2026; 31 July 2026 compliance deadline reported |
| Medium   | NGN 1bn to 5bn | 1 July 2026                                        | January 2027; review October to November 2026         |
| Emerging | below NGN 1bn  | 1 July 2027                                        | January 2028                                          |

- Integration through approved Access Point Providers and System Integrators, real-time transmission.
- One source: B2B and B2G need real-time clearance before issuance; B2C reported within 24 hours. Unverified against NRS text.
- Design [I]: clearance is an async step between `approved` and `issued`. Persist the submission payload, response code and IRN; offer a retry queue; resubmission never renumbers.

### United Kingdom and United States

No e-invoicing mandate was verified for either. UK MTD (VAT now, Income Tax from 6 April 2026) governs digital records, not invoice format.
