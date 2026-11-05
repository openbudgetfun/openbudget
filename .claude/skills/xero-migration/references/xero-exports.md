# Xero exports: columns, quirks, system accounts, API alternative

**Native Xero export headers are unverified.** The research could not fetch Xero Central or developer-portal article bodies. Tags: **S** secondary (vendor, adviser, or a third-party copy of a Xero template), **I** inferred. No **P** (primary read) entries exist for headers. Capture real exports from a Xero Demo Company as fixtures before finalising any parser (see `SKILL.md`).

## 1. Overview

Xero has no single export-everything button. Master data (chart, contacts, items) and invoices and bills export as CSV from list screens. Ledger-level data comes from reports (Excel, PDF, Google Sheets; CSV only by re-saving) or the tab-delimited "Export accounting data" General Ledger file. Import templates (chart, contacts, invoices, bills) have documented fixed headers that are a good guide to the export side. Attachments and the audit trail are not exportable in bulk. [S] https://www.syscloud.com/saas-data-protection-center/xero/how-to-export-xero-data/ , https://www.getboxkite.com/blog/what-data-can-you-export-from-xero-and-what-you-can-t (vendors selling export tools)

Formats named: Excel, CSV, MYE, TXT, PDF. One source says there is no native report CSV; another says Trial Balance offers CSV. Treat as region or version dependent. [S] https://xo-report.com/xero-to-excel/how-to-export vs https://ledgeriq.ai/blog/export-trial-balance-from-xero

Accept in the importer [I]: (a) Trial Balance as-at the conversion date, (b) GL export or GL Detail for history, (c) Aged Receivables and Payables Detail, (d) chart of accounts CSV, (e) contacts CSV, (f) invoice and bill exports (concatenate 500-row batches), (g) fixed asset register and inventory item export as optional.

## 2. Export-by-export

Required columns below are the _intended_ minimum; the alias table may widen them once fixtures exist.

### Chart of accounts

- Path: Accounting > Chart of accounts > Export or Import.
- Import-template header (third-party copy of Xero's sample): `*Code, Report Code, *Name, Reporting Name, *Type, *Tax Code, Description, Dashboard, Expense Claims, Enable Payments, Balance`. [S] https://www.accountantmaster.com/wp-content/uploads/2022/12/Xero-Chart-of-Accounts.csv
- Rules (Xero Central snippet): Code and Name must each be unique; unspecified Tax Code imports as No Tax; bank accounts must use No Tax; tax rates must already exist; Reporting Name not available for Bank type; changing both Code and Name in one import archives the account and creates new ones. Excel strips leading zeros from exported codes. [S] https://central.xero.com/s/article/Import-a-chart-of-accounts?userregion=true
- Account types to map to ledger classes [S]: Bank, Current Asset, Fixed Asset, Inventory, Non-current Asset, Prepayment, Current Liability, Liability, Non-current Liability, Equity, Direct Costs, Expense, Overhead, Depreciation, Revenue, Sales, Other Income.

### Contacts

- Path: Contacts > All contacts > menu > Import > Download template; export from Customers or Suppliers three-dots > Export (CSV).
- Template headers: `ContactName` (required), `EmailAddress`, `FirstName`, `LastName`, `AccountNumber`, `BankAccountName`, `BankAccountNumber`, `BankAccountParticulars`, `TaxNumber`, `PhoneNumber`, `POAddressLine1-4`, `POCity`, `PORegion`, `POPostalCode`, `POCountry`, `POAttentionTo`, `SAAddressLine1-4`, `SACity`, `SARegion`, `SAPostalCode`, `SACountry`, `SAAttentionTo`, `BrandingTheme`, `Person[x]FirstName/LastName/Email/IncludeInEmail`.
- Limits: 50 chars (AccountName, postal codes, countries, TaxNumber, CompanyNumber, bank fields), 255 (names, cities, regions), 500 (emails, address lines); 1,000 contacts per import file; admin permission to import bank details. [S] https://help.xero.com/us/Contacts_Import , https://www.caseware.com/docs/en/cloud/caseware-cloud/engagement-management/data-export-from-third-party-tools/export-data-via-xero
- Do not import open-balance amounts from contact files; import open invoices and bills so balances arise from documents. [S] https://quickbooksfilerepair.com/Xero-to-Quickbooks-Online.aspx (third party)
- Contact matching is on exact name; near-matches create duplicates. Surface near-duplicates for the user instead of merging. [S]

### Sales invoices

- Import template, 27 columns in order: `*ContactName, EmailAddress, POAddressLine1-4, POCity, PORegion, POPostalCode, POCountry, *InvoiceNumber, Reference, *InvoiceDate, *DueDate, InventoryItemCode, *Description, *Quantity, *UnitAmount, Discount, *AccountCode, *TaxType, TrackingName1, TrackingOption1, TrackingName2, TrackingOption2, Currency, BrandingTheme`. One row per line; rows with the same InvoiceNumber are one invoice. Headings must match; the leading asterisk is optional. `TaxType` is the tax-rate **name**, not a percentage. At upload the user picks tax-inclusive or exclusive for the whole file. Imports land as Drafts. Third-party guide also mentions Total, TaxTotal and Status columns seen elsewhere, unconfirmed. [S] https://syslumelab.com/guides/xero-sales-invoice-import-csv
- Export: Business > Invoices (or Bills to pay) > Export on any status tab. One row per line item; 500 transactions per batch. Reported columns: ContactName, InvoiceNumber, Reference, InvoiceDate, DueDate, Description, Quantity, UnitAmount, AccountCode, TaxType, TaxAmount, plus tracking columns only if tracking categories exist. Payments, currency and exchange rate **not confirmed** in the export. [S] https://zigaflow.com/resources/glossary/xero-invoice-export-to-excel

### Supplier bills

- UK import header: `*ContactName, EmailAddress, POAddressLine1-4, POCity, PORegion, POPostalCode, POCountry, *InvoiceNumber, *InvoiceDate, *DueDate, Total, InventoryItemCode, Description, *Quantity, *UnitAmount, *AccountCode, *TaxType, TaxAmount, TrackingName1, TrackingOption1, TrackingName2, TrackingOption2, Currency`. Path Purchases > Bills > New bill > Import from CSV. Currency is a 3-letter ISO code and must already be enabled. [S] https://kedgework.com/blog/xero-bill-import-csv-uk/ , https://stratas.co.uk/blog/import-bills-xero
- Whether credit notes have their own export or are in the invoice and bill export is unknown.

### Trial Balance

- Path: Accounting > Reports > Trial Balance (Taxes and Balances) > Export > Excel (CSV only by Save As).
- Use the standard Trial Balance (as-at), **not** "Trial Balance by Date Range", which omits brought-forward balances. As-at layout has Debit, Credit and YTD Debit, YTD Credit columns. [S] https://www.caseware.com/docs/en/cloud/caseware-cloud/engagement-management/data-export-from-third-party-tools/export-data-via-xero , https://xo-report.com/xero-to-excel/trial-balance , https://ledgeriq.ai/blog/export-trial-balance-from-xero
- Excel quirk: some amounts show 0.00 until Enable Editing is clicked. Read xlsx directly instead of relying on a user re-save. [S] https://xo-report.com/xero-to-excel/aged-receivables

### General ledger

- Path: Accounting > Advanced > Export accounting data > General Ledger (date range, Accrual or Cash basis). Produces a tab-delimited `.txt` (rename to `.csv`). The Caseware variant includes a Journal ID. `JournalDate` is DMY in UK/AU/NZ regions. In Canadian Xero the path is Reporting > Reporting settings > Export accounting data. [S] https://support.mindbridge.ai/hc/en-us/articles/5873992135447-Xero-Export-the-general-ledger , https://support.validis.com/hc/en-gb/articles/37948517395860-Downloading-GL-TB-from-Xero , https://www.caseware.com/docs/en/cloud/caseware-cloud/engagement-management/data-export-from-third-party-tools/export-data-via-xero
- General Ledger Detail report replaces the retired Detailed Account Transactions report: customisable columns; Journal ID, Account Type and Source columns reportedly available; contact shown for invoice and bill lines; a "tax rates" common format exists. No posting date or posted-by column. In Account Transactions the Description column shows the contact for bank, AR, AP and tax accounts; run the report on the revenue or expense account to see line descriptions. [S] https://central.xero.com/0/article/General-Ledger-Detail-report-US , https://productideas.xero.com/forums/967133-reports-tax/suggestions/46453135-general-ledger-details-add-posted-date-and-poste , https://productideas.xero.com/forums/967133-reports-tax/suggestions/45791245-account-transactions-report-show-description-of
- The GL is the ledger source of truth for history. Invoice CSVs cannot reproduce it. [I]

### Aged Receivables and Payables

- Path: Reports > Payables and Receivables > Aged Receivables or Payables, Summary or Detail > Export > Excel.
- Summary columns: Contact, Current, 1-30, 31-60, 61-90, Over 90 (periods configurable), Total. Detail: one row per outstanding invoice, credit note or overpayment; reported fields include Date, Reference or Number, Due Date, Status, Currency, Total, Paid, Credited, Due, and Due in base currency (one vendor's view; native names unverified). [S] https://xo-report.com/xero-to-excel/aged-receivables , https://support.mindbridge.ai/hc/en-us/articles/360061793893-Xero-Accounts-Payable-Data , https://www.caseware.com/docs/en/cloud/caseware-cloud/engagement-management/data-export-from-third-party-tools/export-data-via-xero

### Other exports

- Receivable or Payable Invoice Summary or Detail (Reports > Payables and Receivables); Inventory Item Summary or Detail (Reports > Transactions); Inventory Item List (Reports > Reconciliations). [S] Caseware link above.
- Fixed asset register, bank transactions, inventory and GL Detail are listed as exportable with no menu path or limits. [S] https://www.getboxkite.com/blog/what-data-can-you-export-from-xero-and-what-you-can-t
- Manual Journals exist in the API; the native export format is unconfirmed. [S] https://www.apideck.com/blog/xero-api-pricing-and-the-app-partner-program
- Not exportable in bulk: attachments (Xero says no plans for bulk download), audit trail, user activity logs. Custom reports need recreation. Workarounds are third-party zip exports or the Files and Attachments API. [S] https://productideas.xero.com/forums/967121-users-setup/suggestions/44960626-files-bulk-export-print-attached-files , https://www.getboxkite.com/blog/how-to-export-all-files-and-attachments-from-xero

## 3. Tax, tracking and currency in exports

- `TaxType` is the tax-rate name from Settings > Tax rates; a wrong inclusive/exclusive choice at upload typically shows totals off by exactly 10% (GST) or 20% (VAT). [S] https://syslumelab.com/guides/xero-sales-invoice-import-csv
- Tax is calculated and rounded **per line** (rates up to 4 decimal places, tax amounts 2). Two 45.45 lines at 10% = 4.55 each, total 9.10. Inclusive: net = line total / (1 + rate) rounded to 2 dp, tax = line total minus net (14.78 / 1.1 = 13.44, tax 1.34). API default LineAmountTypes is Exclusive; Inclusive must be set explicitly. In the UI the Tax Amount can be overridden per line and Xero adds an adjustment line. [S] https://developer.xero.com/documentation/best-practices/data-integrity/taxes , https://developer.xero.com/documentation/guides/how-to-guides/tax-in-xero , https://kb.clouddepot.com/knowledge/rounding-issues-in-xero-invoices
- Tracking: up to two categories, as `TrackingName1/TrackingOption1/TrackingName2/TrackingOption2`; export includes tracking columns only if categories exist. [S]
- Currency: `CurrencyRate` is foreign per base, rounded to 6 dp and 10 significant figures; amounts 2 dp. [S] https://developer.xero.com/documentation/best-practices/data-integrity/multicurrency/
- Model each line as (net, tax, gross, tax-rate reference, rate-name snapshot, tracking x2, currency, fx rate, base amounts). Never recompute tax from the rate on import; store the stated TaxAmount, reconcile to the GL, and show per-document rounding deltas as a rounding line. Store FX with an explicit direction flag. [I]
- Unknown: whether the invoice export shows exchange rate or base totals; how the GL export shows foreign amounts; whether a tax-rate list can be exported (none confirmed). [S]

## 4. Dates, signs and text

- Dates follow the organisation's regional setting (DD/MM/YYYY or 25 Dec 2026 style). Take an explicit date-format parameter; detect only from unambiguous dates. Excel can mangle dates on re-save. [S] https://syslumelab.com/guides/xero-sales-invoice-import-csv
- Descriptions beginning with `=`, `+`, `-` or `@` can be read as Excel formulas. When the importer writes any CSV back out (for example an import report), prefix such cells to neutralise them. [S for the quirk, I for the mitigation]
- Sign conventions are undocumented in the sources. Treat report amounts as natural-sign and validate by checking debits equal credits per journal. [I]
- Voids: Xero voids reportedly leave reversing journals in the GL (unconfirmed). Ingest GL lines only and ignore voided invoice rows to avoid double counting. [I]

## 5. System accounts

- Locked, cannot be deleted or archived, lock icon in the chart; names and codes are editable. API `SystemAccount` values: `DEBTORS` (Accounts Receivable), `CREDITORS` (Accounts Payable), `HISTORICAL`, `REALISEDCURRENCYGAIN`, `RETAINEDEARNINGS`, `ROUNDING`, `UNREALISEDCURRENCYGAIN`. [S] https://developer.xero.com/documentation/api/accounting/types
- Default codes vary: UK and AU Historical Adjustment 840, Retained Earnings 960, Unrealised Currency Gains 498, Rounding 860; AR 610 and AP 800 in default charts; Demo Company uses different codes. [S] https://www.linggardandthomas.co.uk/blog/xero-chart-of-accounts-cheat-sheet
- A community thread says invoice lines cannot use 610, 800, 497 (Bank Revaluations), 877 (Tracking Transfers), 801 (Unpaid Expense Claims) or 498. [S] https://community.xero.com/developer/discussion/82441
- UK 810 is Income in Advance (a normal liability), not unrealised gains, per one source. [S] https://www.vjmglobal.com/feeds/blog/xero-chart-accounts-codes-uk
- Identify system accounts by attribute or type plus name, with a manual-confirm step; never by code. [I]
- Other tools' behaviour worth designing against: Dataswitcher turns renamed system accounts into suspense customers or vendors and multiple AR or AP accounts into "zCustomer" or "zVendor" entries, and does not convert draft journals, attachments, fixed assets, budgets, payroll or project data. MMC Convert does not convert voided transactions, attachments, unreconciled entries, fixed assets, budgets, inventory tracking or repeating invoices after the convert date, and collapses custom tax rates into standard rates with an adjustment journal. [S] https://quickbooks.intuit.com/learn-support/en-us/help-article/accounting-bookkeeping/convert-xero-quickbooks-online/L9gVqsNT4_US_en_US , https://www.mmcconvert.com/faqs/faq-xero-to-freeagent-conversion

## 6. API alternative

- The Accounting API (OAuth 2.0; Custom Connections for single-organisation private use) can fetch everything including attachments. Since 2026 usage is tiered by connections and data egress. [S] https://developer.xero.com/pricing
- Plans (AUD ex tax, as read): Starter free, 5 connections, 1,000 requests per day per organisation; Core 35 per month, 50 connections, 10 GB egress, 5,000 per day; Plus 245 per month, 1,000 connections, 50 GB; Advanced 1,445 per month, 10,000 connections, 250 GB; Enterprise by application. Overage 2.40 per GB. Connection counts visible from 4 December 2025; five-tier model effective 2 March 2026 (secondary). Concurrency reported as 5 concurrent calls and 60 per minute per organisation. [S] https://developer.xero.com/pricing , https://www.activepieces.com/blog/xero-api-setup-authentication-and-limits-2026
- The Journals endpoint, XPM API and bulk connections need the Advanced plan, a security assessment and use-case approval. Manual Journals stay on all tiers. On lower tiers rebuild the ledger from invoices, payments, bank transactions, manual journals and the report endpoints (Trial Balance, GL). [S] https://developer.xero.com/pricing , https://www.apideck.com/blog/xero-api-pricing-and-the-app-partner-program
- **AI training ban:** updated developer terms prohibit using Xero API data to train or fine-tune AI or ML models; bespoke single-client integrations are reportedly exempt. Secondary sources only: verify in Xero's terms. [S] https://www.activepieces.com/blog/xero-api-setup-authentication-and-limits-2026 , https://7sqrdlabs.com.au/insights/xero-api-pricing-integration/
- For a one-off import, CSV and Excel are cheaper and avoid the terms issue. The API is attractive for attachments and a direct "Connect Xero" flow within the free Starter limit. A multi-user product will need a paid tier and certification. [I]
- Custom Connections eligibility, OAuth scope changes and the exact daily limits (sources conflict; the pricing page is treated as authoritative) were not confirmed.
