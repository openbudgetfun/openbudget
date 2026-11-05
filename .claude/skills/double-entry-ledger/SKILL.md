---
name: double-entry-ledger
description: Double-entry general ledger, chart of accounts, journals, period locks, sales invoices, supplier bills, credit notes, bank reconciliation, multi-currency FX, fixed assets, year-end close, financial statements and record retention for UK, US, Nigerian and German entities. Load before adding or changing any ledger, journal, invoice, bill, chart-of-accounts, trial balance, P&L, balance sheet, aged AR/AP, VAT-control or e-invoicing (XRechnung, ZUGFeRD, NRS/MBS) code, or before touching Transaction, Account or Category when a business entity needs accounting.
---

# Double-entry ledger

OpenBudget today is a single-entry envelope budget. To replace Xero for a sole trader or limited company it needs a real double-entry ledger underneath business budgets, without creating a second source of truth next to `Transaction`, `Account` and `Envelope`. This skill gives the rules a ledger, invoicing and reporting implementation must not get wrong, and the plan for coexisting with the budgeting model.

Today is 5 November 2026. The app prepares records and reports for the user to review; it is guidance, not regulated accounting or tax advice, and it does not file anything.

## When to use

- Creating or changing journals, ledger accounts, posting rules, lock dates, year-end close or opening balances.
- Building sales invoices, supplier bills, credit notes, allocations, overpayments, write-offs or invoice numbering.
- Building bank reconciliation, foreign-currency handling, fixed-asset depreciation, prepayments or accruals.
- Producing trial balance, P&L, balance sheet, cash flow, aged AR/AP, or VAT/sales-tax control reconciliations.
- Adding invoice content rules, e-invoice formats, retention rules, or an accounting export (for example DATEV).
- Importing from Xero: also load `xero-migration`. Tax computation: use the tax rule packs, not this skill.

## Source-of-truth rules

- Money is an integer in the currency's minor unit (pence, cents, kobo). Use the per-currency `decimals` already in `openbudget_core/lib/src/constants/currencies.dart`; do not assume 2. No `double` for any amount or rate. FX rates are exact decimals (scaled integer or `Decimal`), never `double`. The current `FxRateEntry.rate` is a `double`; do not reuse it for posting.
- Thresholds, VAT/sales-tax rates, invoice-content profiles, e-invoice timelines, retention periods and lock rules are versioned data with an effective date, in `openbudget_core` (beside `lib/src/tax/`), never inline in UI or server code. Every row carries its source URL and quality tag.
- A posted journal is never updated or deleted. Corrections are reversal journals plus a new journal. Audit events and a server-side `posted_at` timestamp are mandatory.
- Cite each rule with a tag: **primary** (official text read), **secondary** (IHK, adviser or vendor page), **inferred** (engineering recommendation). Do not present secondary or inferred rules as settled. The tags in the references use: P, P-snip (official page seen only in a search summary), S, I, K (general knowledge, not in the research notes).
- Never hard-code SKR03/SKR04 account numbers as keys. Internal accounts carry a stable `system_role`; DATEV numbers are mapping data.

## Core rules

1. **Balanced, atomic posting.** A journal has at least two lines; debits equal credits in the functional currency and also per transaction currency; no zero lines; no line with both sides. Enforce in the database, not only in Dart.
2. **Append-only.** Posted rows are insert-only (trigger or permission model). Voiding an invoice posts a reversal and keeps the number. Un-reconcile before voiding a reconciled bank line, and audit it.
3. **Lock dates.** One `assert_open(date, actor)` gates every post, edit and void. An organisation lock blocks everyone; an optional adviser-only lock exists. After a tax return is filed, lock that period; later corrections post in the open period.
4. **Ledger is accrual; cash basis is a query.** Invoices and bills post to AR/AP on approval. Cash-basis reports attribute cash movements through payment allocations using `settled_percentage`; never rewrite the ledger.
5. **Control accounts.** AR, AP, VAT control and payroll liabilities reject manual journals without a party and document reference. A check compares each control balance with the sum of open documents per currency. A mismatch blocks period close.
6. **Numbering.** Assign an invoice number at approval inside the posting transaction, from a per-organisation, per-series counter row locked `FOR UPDATE`. Never use a database sequence (it skips on rollback). Voided numbers stay and are never reused.
7. **Status is derived where possible.** Store `draft`, `approved`, `voided`; derive `partially_paid`, `paid`, `overdue` from allocations and due date.
8. **FX.** Store `fx_rate` as functional per 1 transaction currency, with `rate_source` and `rate_date`. The document locks its rate at approval. Realise FX on settlement; revalue open monetary items at period end (auto-reverse). Per-line rounding residue goes to the largest line; the `rounding` account is a last resort.
9. **Dates are calendar dates** in the organisation's time zone, not UTC instants. Tax codes have effective-date ranges; the rate in force at the tax point applies.
10. **Book depreciation is not tax depreciation.** Keep capital allowances, MACRS and AfA separate from book depreciation.
11. **Retention.** Never auto-purge financial records. Store `retain_until` per record; erasure requests pseudonymise parties while retention applies. Store original e-invoice artefacts (XML, PDF, clearance response) as immutable blobs with SHA-256.
12. **Reports are queries over one function** `ledger_balance(account, range, currency, basis)`. A trial balance whose debits differ from credits is a hard error, not a row labelled "difference".

## Where it lives in OpenBudget

Read `references/openbudget-coexistence.md` first for the mapping. Summary:

- A budget with a business `TaxEntityKind` (`soleTrader`, `company`) can turn on a ledger. Personal (`individual`) budgets stay envelope-only. One budget = one set of books.
- For a ledger budget the ledger is the single source of truth for money movements. `Transaction` rows for it become a projection of posted journal lines on bank-type accounts; amount, date and account become read-only there. Envelopes remain a planning overlay on cash and never post journals.
- `Account.balanceCents` becomes a derived cache for ledger accounts. `Payee` is extended or paired with a `party` (customer/supplier). `Category`/`Envelope` map to default ledger accounts for coding bank lines.
- Pure logic (money, journal validation, report builders, numbering formats, invoice profiles, retention tables) goes in `openbudget_core/lib/src/ledger/`. Persistence, posting services and endpoints go in `openbudget_server/lib/src/ledger/` as `.spy.yaml` models plus services, following the `accounts/` and `transactions/` layout. Widgets are `HookConsumerWidget`/`HookWidget`, providers use `@riverpod`, strings come from `AppLocalizations`.
- The tax engine (`openbudget_server/lib/src/tax/tax_entry_builder.dart`) currently reads `Transaction`. For ledger budgets it must read ledger lines instead, so that a figure exists in one place only.
- Serverpod rule: at most one migration per PR. Split the ledger into stacked PRs, each with its own single migration (core schema, documents, banking, assets/close).
- E2E: every user-facing flow needs Patrol coverage using the page-object pattern.

## Testing

- Encode every vector in `references/test-vectors.md` as unit tests in `openbudget_core`; assert on integer minor units, exact equality, no tolerance. Tolerance applies only to report comparisons against an external system (for example a Xero report), where the allowed difference is zero unless a documented rounding line explains it.
- Rounding mode: round half up on the absolute value to the minor unit, except where a vector states otherwise. Record the VAT rounding method (per line or per invoice) on the document.
- Property tests: random journal sets keep trial balance balanced; reversal of any journal restores prior balances; concurrent approvals produce gap-free numbers; allocation removal restores `amount_due` exactly.
- Server tests need Postgres (see the repo notes on `FLUTTER_ROOT`); run `melos run test` and `melos run analyze` before finishing.

## Unverified and changing

Re-check each by the date shown.

- Nigeria NRS/MBS: tier dates, B2B clearance vs B2C 24-hour reporting, IRN/QR format, section numbers (NTA 2025 s.147/152/155, NTAA s.23/s.31) and any e-invoice archive period are secondary-sourced; the NRS site blocked fetches. Re-check before 1 January 2027 (medium-taxpayer enforcement).
- Germany e-invoicing: issuing duty from 1 January 2027 (prior-year turnover above EUR 800,000) and 1 January 2028 (all); totals-only leniency ends 31 December 2027. All from IHK/Haufe/Ecovis, not the BMF letters (15 October 2024, 15 October 2025, GoBD 14 July 2025). Re-check before 1 December 2026. One aggregator dates the second BMF letter 15 October 2026; treat as an error until confirmed.
- UK: MTD for Income Tax threshold falls to GBP 30,000 on 6 April 2027 and GBP 20,000 on 6 April 2028; quarterly update due 7 November 2026. UK VAT invoice issue deadline (30 days), credit-note content (Notice 700 s.18) and VAT bad-debt relief conditions were not read.
- Xero lock-date semantics, GoBD timing rules ("Festschreibung"), HMRC VAT-on-cash attribution, US invoice and sales-tax conventions, SKR03/SKR04 number lists, FRS 102/105 and HGB statement layouts: not read from primary sources.
- Retention: Nigeria 6 years (7 for e-invoices is disputed); Germany voucher period 8 years from 1 January 2025 and the 10-year UStG s.22 rule are secondary; sole-trader UK retention not sourced.
- Kleinunternehmer limits (EUR 25,000 prior year, EUR 100,000 current year) are secondary and reported unchanged for 2026 and 2027.

## References

- `references/ledger-model.md`: schema, posting invariants, corrections, lock dates, accrual/cash, control accounts, year-end, opening balances, reports.
- `references/chart-of-accounts.md`: system roles and starter charts for UK Ltd and sole trader, US LLC/S-corp, Nigeria, Germany with SKR03/SKR04 notes.
- `references/documents-and-invoicing.md`: invoice/bill lifecycle, credit notes, allocations, numbering, required contents per country, e-invoicing timelines.
- `references/banking-fx-assets.md`: bank reconciliation, multi-currency, fixed assets, prepayments and accruals.
- `references/retention-and-edge-cases.md`: retention per country, immutability checklist, cross-cutting edge cases.
- `references/openbudget-coexistence.md`: how the ledger sits beside envelopes, and the concrete gaps in the current data model.
- `references/test-vectors.md`: worked examples with expected outputs.
