# Coexisting with envelope budgeting, and the gaps

Everything in this file is **inferred** (engineering recommendation) from reading the current server models. Review with an accountant and the product owner before building. Files read: `openbudget_server/lib/src/transactions/`, `accounts/`, `categories/`, plus `envelopes/`, `payees/`, `budgets/`, `fx_rates/`, `tax/tax_entry_builder.dart`, `tax/tax_profile.spy.yaml`, `transaction_rules/`, `recurring_transactions/`.

## 1. What exists today

| Concept           | Model                                                                                                                                                                                                                                             | Facts that matter for a ledger                                                                                                                         |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Budget            | `Budget` (`currencyCode`, `ownerId`)                                                                                                                                                                                                              | One currency per budget. This is the natural boundary for one set of books.                                                                            |
| Tax profile       | `TaxProfileRecord` (`budgetId` unique, `jurisdiction`, `entityKind`, `linkedBudgetId`)                                                                                                                                                            | `entityKind` is `individual`, `soleTrader` or `company`. A business budget links to the owner's personal budget.                                       |
| Bank/cash account | `Account` (`accountType` free String, `balanceCents`, `currencyCode`, `onBudget`, `sourceType`, `externalAccountId`)                                                                                                                              | `balanceCents` is a stored, mutable number set by the user or by sync (Plaid and Solana code assign it directly). It is not derived from transactions. |
| Transaction       | `Transaction` (`amountCents` signed, `currencyCode`, `accountId?`, `envelopeId?`, `payeeId?`, `transactionDate`, `cleared`, `reconciled`, `transferPairId?`, `parentTransactionId?`, `taxCategoryCode?`, `businessUsePercent?`, `salesTaxCents?`) | Single-entry, mutable, deletable (`update` and `delete` in `transaction_service.dart`). One signed amount, one account. `accountId` is nullable.       |
| Envelope          | `Envelope` (`budgetedAmountCents`, `spentAmountCents`, `taxCategoryCode?`)                                                                                                                                                                        | `spentAmountCents` is a stored aggregate, written through the endpoint. Planning, not accounting.                                                      |
| Category          | `Category`                                                                                                                                                                                                                                        | A display group of envelopes. Not a chart-of-accounts node.                                                                                            |
| Payee             | `Payee` (`name`, unique per budget)                                                                                                                                                                                                               | A name only: no address, tax ID, terms or customer/supplier flag.                                                                                      |
| FX                | `FxRateSnapshot`, `FxRateEntry` (`rate: double`)                                                                                                                                                                                                  | Provider snapshots at fetch times. Not per-document, not exact.                                                                                        |
| Reconciliation    | `Transaction.cleared/reconciled`; `reconcileWithBalance`                                                                                                                                                                                          | A boolean flag per transaction. A mismatch creates a plug transaction dated now.                                                                       |
| Duplicates        | `findDuplicates`                                                                                                                                                                                                                                  | Same absolute amount within one day. No stable external ID on `Transaction`.                                                                           |
| Tax               | `buildTaxEntries`                                                                                                                                                                                                                                 | Reads `Transaction` rows, skips transfers, uses split children, falls back to the envelope's `taxCategoryCode`, converts currency.                     |

## 2. The no-two-sources-of-truth rule

For any one real-world cash movement in any one bank account, exactly one record is authoritative.

- **Personal budgets (`individual`):** unchanged. `Transaction` is authoritative. No ledger.
- **Business budgets with the ledger on (`soleTrader`, `company`):** the **ledger** is authoritative. `Transaction` rows for that budget are a **projection** of posted journal lines that touch bank-type ledger accounts. Do not allow independent `Transaction` creation, amount edits, date edits or deletes there.
- **Envelopes** in a ledger budget are a planning overlay on cash. Assigning money to an envelope, moving it, or spending against it never posts a journal. Envelope data is not accounting data and must never feed the trial balance.
- **Tax figures** for a ledger budget come from ledger lines (account `tax_category_code`, line override), never from the projection and the ledger together. `buildTaxEntries` gets a ledger-backed variant selected by a budget flag so no figure is counted twice.

Decision to confirm with the owner: a per-budget `accountingMode` (`envelope` or `ledger`). Switching `envelope` to `ledger` is a migration of existing `Transaction` rows into opening balances plus history journals (see `xero-migration` for the pattern); switching back is not supported.

## 3. Mapping between the two models

| Budgeting concept                                                         | Ledger concept                                                                                                 | Rule                                                                                                                                                                            |
| ------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Account` (bank, card, cash, loan)                                        | `ledger_account` of type asset or liability, `system_role` NULL, flagged bank                                  | Add `ledgerAccountId` to `Account`. `balanceCents` becomes a derived cache of the ledger balance in the account currency; sync code stops writing it for ledger budgets.        |
| `Transaction` (ledger budget)                                             | `journal_line` on the bank account                                                                             | Add `journalId` and `journalLineId`. Read-only. One bank line per `Transaction`; the other side of the journal is the coding (expense, income, AR, AP).                         |
| Split transaction                                                         | multi-line journal                                                                                             | Parent and children collapse to one journal with several lines; the projection may keep `parentTransactionId` for display only.                                                 |
| Transfer pair                                                             | one transfer journal (Dr bank B, Cr bank A)                                                                    | `transferPairId` is derived from the journal.                                                                                                                                   |
| `Envelope` / `Category`                                                   | default coding account per envelope                                                                            | Add optional `defaultLedgerAccountId` to `Envelope`. Used by `TransactionRule` and bank rules to pre-code bank lines. Many envelopes may map to one ledger account.             |
| `Payee`                                                                   | `party`                                                                                                        | Add a `party` model (kind customer, supplier or both; address; tax IDs; terms; default accounts) or extend `Payee`. A `Payee` without a party stays valid for personal budgets. |
| `cleared`, `reconciled`                                                   | `reconciliation_match` rows                                                                                    | The boolean becomes derived (`reconciled` = has a match). `reconcileWithBalance`'s plug transaction is replaced by an explicit, audited adjustment journal to `suspense`.       |
| `salesTaxCents`, `businessUsePercent`, `taxCategoryCode` on `Transaction` | `journal_line.tax_code`, `tax_amount_minor`, account `tax_category_code`; business-use split as separate lines | Capture at coding time; for ledger budgets these fields on `Transaction` are projection-only.                                                                                   |
| `RecurringTransaction`                                                    | `scheduled_journal` or recurring invoice/bill template                                                         | For ledger budgets it generates approved documents or journals, not raw `Transaction` rows.                                                                                     |
| `TransactionRule` (payee to envelope)                                     | bank rule (conditions, account, tax code, party)                                                               | Extend rather than duplicate: one rule engine.                                                                                                                                  |

## 4. Personal and business books

A sole trader or director has a business budget (ledger) linked to a personal budget (envelope) through `TaxProfileRecord.linkedBudgetId`. Money between them (drawings, dividends, salary, director's loan) is recorded **once per book**, each as its own side:

- Business ledger: Dr drawings (or dividends, or salary expense) and Cr bank, with a `counterpart_budget_id` reference.
- Personal budget: an income `Transaction` on the personal account with the same reference.

Do not build a consolidated ledger across entities. A pairing reference lets a report show unmatched sides. The personal side is not a duplicate source: it is the owner's separate book.

## 5. Concrete gaps between the current model and a ledger

1. No journals, journal lines, ledger accounts or chart of accounts. `Category` and `Envelope` are not accounting accounts.
2. `Transaction` is single-entry and mutable. `update` and `delete` exist; there is no reversal, void or audit trail.
3. No immutability enforcement: no append-only constraint, no `posted_at`, no hash chain, no audit event table.
4. No period or lock dates, and no tax-filing locks.
5. `Account.balanceCents` is a stored value rather than derived from entries; sync code sets it directly. Plaid balances are converted through `double` multiplication (`balance * 100` rounded), which is wrong for non-2-decimal currencies and risks float error.
6. Cents are assumed everywhere (field names `*Cents`), although `CurrencyCode.decimals` exists in `openbudget_core`. Ledger fields should be named `*Minor` and use the per-currency exponent.
7. Rates are `double` (`FxRateEntry.rate`); there is no per-document locked rate, rate source or rate date on a transaction, and no realised or unrealised FX posting.
8. `Transaction` has a single `currencyCode`; there is no pair of transaction-currency and functional-currency amounts, and no functional currency per ledger beyond `Budget.currencyCode`.
9. No parties: `Payee` has no address, tax ID, terms, bank details or customer/supplier role.
10. No documents: no invoice, bill, credit note, line items, tax codes, tax rates with effective dates, numbering series, allocation, overpayment, prepayment or write-off.
11. No VAT or sales-tax accounts, tax codes or returns reconciliation; only `salesTaxCents` on a transaction.
12. No AR or AP control accounts, aged reports, or control-account integrity checks.
13. Reconciliation is a per-transaction boolean. There are no imported statement lines, statement balances, matches (split or group), or bank rules. The mismatch handler writes a plug transaction dated now.
14. No stable external identifier on `Transaction` for feed dedupe; `findDuplicates` is a same-amount, plus-or-minus-one-day heuristic.
15. No fixed-asset register, depreciation runs, scheduled journals (prepayments, accruals), or auto-reversal.
16. No year-end close, opening-balance journal, historical-adjustment handling or snapshot reports.
17. No statements (trial balance, P&L, balance sheet, cash flow). `buildTaxEntries` is the only report path and it reads transactions.
18. No retention metadata (`retain_until`, legal hold), immutable artefact storage, or e-invoice envelope fields (IRN, QR, XML original, Leitweg-ID, clearance state).
19. No invoice or bank rules data in `openbudget_core` (invoice profiles per country with effective dates, retention table, e-invoice timeline).
20. No DATEV or SKR mapping and no machine-readable full export.
21. Serverpod migrations are limited to one per PR and `.spy.yaml` cannot declare triggers; an append-only guarantee needs a decision on how to ship SQL constraints (open question).

## 6. Suggested stacked-PR order (one migration each)

1. Core schema: `ledger_account`, `journal`, `journal_line`, `audit_event`, `period_lock`; posting service and invariants; `openbudget_core/lib/src/ledger/` money and validation; trial balance.
2. Parties and documents: `party`, invoice, bill, credit note, lines, series, allocation; numbering; approval posting; aged AR/AP.
3. Banking: statement lines, reconciliation, rules; projection of `Transaction`; `Account` link.
4. FX, fixed assets, scheduled journals, year-end close, statements, retention and export.
5. E-invoicing adapters per country; DATEV export.
