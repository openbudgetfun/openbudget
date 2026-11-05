# Retention, immutability checklist, edge cases

Tags: **P** primary read; **P-snip** official page via search summary; **S** secondary; **I** inferred.

## 1. Retention per country

### United Kingdom

- VAT records: generally at least 6 years; HMRC may allow less where storage causes serious problems. Records include the VAT account, copies of invoices issued and received, credit and debit notes, bank statements, import and export documents. [P] https://www.gov.uk/guidance/record-keeping-for-vat-notice-70021
- E-invoices: keep copies of issued and received invoices for 6 years with authenticity and integrity guaranteed. Scans may replace paper if legible. Storage outside the UK or EU is allowed if data protection applies and records can be produced readably. [P] https://www.gov.uk/guidance/electronic-invoicing-notice-70063
- Companies Act 2006 s.388(4): private companies keep accounting records 3 years from the date made, public companies 6 years; tax law may require longer. HMRC's general rule is the sixth anniversary of the end of the accounting period (CH14600). Records are kept at the registered office or another place the directors choose. [P-snip] https://www.legislation.gov.uk/ukpga/2006/46/section/388 , https://www.gov.uk/hmrc-internal-manuals/compliance-handbook/ch14600
- Sole-trader Self Assessment retention (commonly 5 years after the 31 January filing deadline) was not sourced.

### United States

IRS: 3 years by default; 4 years for employment tax; 6 years if more than 25% of gross income was omitted; 7 years for a worthless-securities loss or bad-debt deduction; indefinitely if no return was filed or the return was fraudulent. Property records until the limitation period for the disposal year expires. [P] https://www.irs.gov/businesses/small-businesses-self-employed/how-long-should-i-keep-records . State rules (sales tax, payroll) were not researched.

### Germany

- §257 HGB: 10 years for books, inventories, opening balance sheets, annual accounts, management reports, group accounts; 8 years for Buchungsbelege (10 for banks, insurers, certain securities firms); 6 years for received and sent Handelsbriefe. The period starts at the end of the calendar year in which the record was made, finalised, received or sent. [P] https://www.gesetze-im-internet.de/hgb/__257.html
- BEG IV cut Buchungsbelege from 10 to 8 years from 1 January 2025. §22 UStG records stay at 10 years per a BMF letter (secondary, dated 8 July 2025 in the source). [S] https://bcis.de/aufbewahrungsfristen-unternehmen/ , https://www.datext.de/blog/artikel/gobd-im-handwerksbetrieb-was-seit-juli-2025-zusaetzlich-gilt
- §146 AO: data readable, available, non-alterable in ways that hide the original; storage in Germany or approved locations; penalties of EUR 2,500 to EUR 250,000 for unauthorised relocation. [P] https://www.gesetze-im-internet.de/ao_1977/__146.html
- GoBD 14 July 2025 (secondary): keep the structured XML part of an e-invoice in original form.
- GoBD primary text, including Verfahrensdokumentation duties for software vendors, was not read.

### Nigeria

NTAA 2025 (secondary, citing s.31): books and records for not less than 6 years after the year of assessment; an audit begun earlier may continue; records of transactions through the Electronic Fiscal System must be accurate. Sources disagree on a separate 7-year e-invoice archive (VATit says 7; VATupdate says no new uniform period). Primary text not read. [S] https://qeeva.com/essential-tax-records-every-business-should-maintain/ , https://vatit.com/e-invoicing-guide/nigeria/ , https://www.vatupdate.com/2026/02/19/briefing-document-podcast-e-invoicing-and-e-reporting-in-nigeria/

### Default policy table [I] (configurable per organisation and document type)

| Jurisdiction | Default minimum                                                               | Notes                                                                                    |
| ------------ | ----------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| UK           | 6 years after end of accounting period                                        | covers VAT and corporation tax; Companies Act floor is 3 years                           |
| US           | 7 years                                                                       | covers all IRS triggers except fraud and non-filing; employment records at least 4 years |
| Nigeria      | 6 years after year of assessment; offer 7 for e-invoices                      | conservative until NRS and statute are confirmed                                         |
| Germany      | 10 years books and statements, 8 vouchers, 6 letters, 10 for UStG §22 records | count from the end of the creation calendar year                                         |

## 2. Implementation notes [I]

- Store `retain_until` per record. UK and Nigeria count from period end; Germany from calendar-year end.
- A purge job lists candidates and requires admin confirmation. A legal-hold flag blocks deletion. Never auto-purge.
- Erasure requests pseudonymise ledger-relevant party data while retention applies; they do not delete it.
- Store original e-invoice artefacts as immutable blobs with SHA-256 recorded in the journal's source reference.
- Provide a full machine-readable export (German Datenzugriff, HMRC access).

## 3. Immutability checklist [I]

- Posted journals are insert-only at database level. Corrections only via reversal journals.
- Changes to master records that affect reporting (account type, tax rate, party tax ID) are audit-logged with before and after values.
- Version the invoice PDF and keep every version sent to a customer.
- Timestamp postings server-side.

## 4. Edge cases that commonly break accounting software [I]

1. **VAT rounding method.** Per line and per invoice differ. Three lines of GBP 0.10 at 5%: per line 0.005 rounds half up to 0.01 each, total 0.03; per invoice 0.30 x 5% = 0.015 rounds to 0.02. Store the method on the document so reprints never change.
2. **Allocation order** is independent of payment date; removal restores `amount_due` exactly.
3. **Voiding a paid invoice** first un-allocates payments, leaving an unallocated overpayment.
4. **Backdated entries into locked periods:** reject, or require an audited override, or post to the first open period.
5. **Duplicate imports:** idempotent on external IDs.
6. **Currency change after posting:** not allowed; void and recreate.
7. **Tax rate change mid-year:** tax codes have effective ranges; use the rate at the tax point.
8. **Time zones:** transaction dates are calendar dates in the organisation's zone.
9. **Negative invoices:** credit notes with their own series.
10. **Control-account drift:** nightly check per currency; block period close on mismatch.
11. **Concurrent numbering:** see vector T3.3.
12. **Zero-decimal and three-decimal currencies:** use per-currency minor-unit exponents.
13. **Kleinunternehmer status change** mid-year changes invoice profile, tax codes and account mapping; test on the exact date.
14. **Nigeria clearance failure:** an invoice approved in the ledger but rejected by NRS is not "issued"; allow resubmission without renumbering.
15. **E-invoice archive integrity:** keep the original XML hash; regenerating a PDF never replaces the stored original.
