# Import order, conversion balances, validation gates

Tags: **S** secondary (vendor or adviser), **I** inferred (engineering recommendation). The migration strategy is industry practice described by vendors; the gates are this project's design.

## 1. How others do it

- FreeAgent: the trial balance dated the day before the start date is the most important item; import opening balances by template or own CSV; compare to the old system and fix before any HMRC submission. [S] https://support.freeagent.com/hc/en-gb/articles/360019910020-Switching-to-FreeAgent-from-another-software
- MMC Convert: opening trial balance as a single journal; the earliest open receivable or payable date sets the start date; open sales invoices as one line (unpaid amount) to Sales; open purchase invoices as one line to Purchase Clearing; opening bank balance as Money In or Out; overpayments via credit note plus receive-money. [S] https://www.mmcconvert.com/faqs/faq-xero-to-freeagent-conversion
- Intuit (Dataswitcher) pre-conversion checklist: reconcile every bank account; export Sales Tax report, Account Transactions (all columns, no grouping) and Trial Balance for all periods; produce validation reports as at the conversion date (Income Statement, Balance Sheet, Trial Balance, Aged Receivables and Payables Summary, list of outstanding invoices); match outstanding payments and credits to invoices beforehand. Up to 2 fiscal years free; older data collapses into an opening balance. Cash-basis organisations should convert after a tax period closes. [S] https://quickbooks.intuit.com/learn-support/en-us/help-article/accounting-bookkeeping/convert-xero-quickbooks-online/L9gVqsNT4_US_en_US
- Post-conversion checks (Intuit): compare P&L, Balance Sheet, Trial Balance and AR/AP ageing against Xero; check balances at several dates; spot-check contacts; confirm the suspense account is empty; reconcile migrated bank transactions in bulk from the last Xero reconciliation ending balance and date; for cash-basis organisations compare trial balances on accrual. [S] same Intuit link.

## 2. Xero conversion balances

- Path: Accounting > Advanced > Conversion balances. Conversion date is the month and year of first day-to-day use; enter the old-system trial balance dated the day before; bank accounts take a conversion balance from the prior-day closing statement; any imbalance is posted automatically to the **Historical Adjustment** system account; saving posts a conversion journal and sets a period lock to the day before the conversion date; GST conversion balances are entered exclusive of GST; a Comparative Balances button shows prior-period figures. [S] https://digit.business/insights/xero/xero-conversion-balances-setup-guide , https://outbooks.co.uk/training-and-support/bookkeeping-vat-return/conversion-balance-in-xero/ , https://developer.xero.com/documentation/guides/how-to-guides/conversions (outline only)
- Unpaid invoices and bills dated before the conversion date must be entered to support AR and AP opening balances. Non-base-currency balances cannot be imported directly; foreign-currency accounts are added later. [S] https://central.xero.com/0/article/Enter-conversion-balances , https://central.xero.com/0/article/The-accounting-behind-Xero-conversion-balances
- When reading a Xero organisation that itself used conversion balances, the conversion journal and Historical Adjustment balance appear in the GL. Carry them across unchanged as an opening-balance set; do not net them away. [I]

## 3. Import order [I]

Each step writes to staging first. Steps 1 to 7 are master data; step 8 onward posts.

1. **Organisation settings.** Base currency, financial year-end, accounting basis (accrual or cash), tax regime (UK VAT, US sales tax, DE USt, NG VAT), and conversion date. Default conversion date: last locked-period end in Xero plus one day.
2. **Currencies and FX rates** referenced by the GL and aged detail. Keep Xero's foreign-per-base direction and its 6-decimal values.
3. **Tax rates.** A mapping table from Xero rate name to local tax code, rate, jurisdiction and effective dates. The user confirms ambiguous names.
4. **Tracking categories and options** (maximum two) become dimensions or tags.
5. **Chart of accounts** (Code, Name, Type, Tax Code, Description, flags). Map Xero types to ledger classes and `system_role`. Identify system accounts by attribute or type plus name with manual confirmation. Preserve codes as strings.
6. **Contacts.** Customers and suppliers with bank details and default tax or account. Show near-duplicate names for review.
7. **Bank accounts** (chart type Bank) with account numbers; then fixed asset register and inventory items if present.
8. **Opening balances.** Post ONE journal dated conversion date minus one day from the as-at Trial Balance. Debits equal credits. AR and AP control lines tie to the open items in step 9. Any unresolved imbalance goes to a visible Historical Adjustment suspense account, never silently.
9. **Open AR and AP documents** from Aged Receivables and Payables Detail: original date, due date, currency, outstanding amount. Unapplied credit notes, overpayments and prepayments come in as open credits. The sub-ledger must tie to the control accounts.
10. **History.** Either (a) summarised monthly journals from the GL for P&L continuity, or (b) full detail from the GL or GL Detail plus invoice and bill exports as documents, including payments and bank transactions. Dates after the conversion date are live; older data is read-only and locked.
11. **Manual journals and depreciation or fixed-asset adjustments** as posted in the GL.
12. **Attachments** last, by third-party zip export or the Files and Attachments API, linked by invoice number, date and contact. Xero cannot bulk-export them.

After posting: lock through the conversion date minus one day; keep the Xero conversion journal as the single opening-balance journal line set. [I]

## 4. Validation gates [I]

Hard gates fail unless the user overrides a gate by name, and each override is audited. Run all gates at the conversion date and again at several later dates. Run them on both accrual and (if applicable) cash basis.

| Gate               | Pass condition                                                                                                           | Failure output                                                |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------- |
| G1 journal balance | for each imported journal, sum of debits equals sum of credits, also per transaction currency                            | journal ID, difference                                        |
| G2 trial balance   | ledger balance per account at the conversion date equals the Xero as-at Trial Balance, per account, in the base currency | account code and name, Xero amount, ledger amount, difference |
| G3 AR tie-out      | AR control balance = sum of imported open AR items (less credits) = Xero Aged Receivables total, per currency            | per-contact diffs                                             |
| G4 AP tie-out      | the same for AP                                                                                                          | per-contact diffs                                             |
| G5 bank tie-out    | each bank account's ledger balance = last reconciled statement balance, and unreconciled items listed                    | account, statement balance, ledger balance                    |
| G6 statements      | P&L and Balance Sheet for the last full period equal Xero's reports                                                      | line-level diffs                                              |
| G7 residuals       | Historical Adjustment, rounding and FX accounts are empty or explicitly accepted                                         | balances, linked journals                                     |
| G8 coverage        | counts of contacts, accounts, documents, journals imported vs rows seen; every skipped row has a reason                  | skipped-row report                                            |

Soft checks: duplicate contacts, tax-rate names with no mapping, documents with no matching GL lines, GL lines with no document, sign anomalies, dates in the future, foreign-currency documents without a rate.

The import report is stored immutably: file names and SHA-256 hashes, row counts, mapping tables used, gate results, overrides and who made them. [I]

## 5. Locked-period handling [I]

Import history into the period before the conversion date, then lock through the day before the conversion date. Lock semantics in Xero (organisation lock vs adviser lock) were not retrieved; do not copy them.

## 6. Gaps

- No source describes Dataswitcher's or MMC Convert's internal schemas or fees beyond Intuit's "2 years free".
- Little evidence on personal (non-business) Xero use; no source addressed personal-finance migration.
- Default US chart system-account codes not retrieved.
