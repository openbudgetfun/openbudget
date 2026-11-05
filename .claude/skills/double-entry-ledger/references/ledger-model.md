# Ledger model: accounts, journals, immutability, locks, close, reports

Source tags: **P** primary read; **P-snip** official page seen only via a search summary; **S** secondary; **I** inferred (engineering recommendation, needs accountant review); **K** general knowledge not in the research notes.

## 1. Why append-only

- German law: entries must be made individually, completely, correctly, on time and in order (`einzeln, vollständig, richtig, zeitgerecht und geordnet`); cash movements daily. An entry may not be changed so the original content is unrecognisable, and changes must show whether they were made originally or later. Electronic books are allowed if they follow GoB; data must stay available and readable without delay; the tax authority has data access (§147 Abs. 6 AO). [P] https://www.gesetze-im-internet.de/ao_1977/__146.html
- GoBD summaries: once processed, vouchers and postings cannot be changed or deleted; corrections must be recognisable. [S] https://www.steuerschroeder.de/GoB.html , https://www.datext.de/blog/artikel/gobd-im-handwerksbetrieb-was-seit-juli-2025-zusaetzlich-gilt . The GoBD primary text was not fetched.
- UK Companies Act 2006 s.386: records must show and explain transactions and disclose the financial position with reasonable accuracy at any time; include day-to-day money in and out, and assets and liabilities. [P-snip] https://www.legislation.gov.uk/ukpga/2006/46/section/386
- UK e-invoice guidance (VAT Notice 700/63): guarantee authenticity and integrity; recreate invoice data as sent or received; keep history files; show control over completeness, accuracy, timeliness, corruption and duplicate processing; keep an audit trail. [P] https://www.gov.uk/guidance/electronic-invoicing-notice-70063
- Xero: only Draft and Awaiting Approval invoices can be deleted; Awaiting Payment is voided; a paid bill needs its payment removed before voiding. [S, vendor docs seen via search] https://central.xero.com/0/article/Delete-or-void-a-sales-invoice , https://central.xero.com/0/article/Delete-or-void-bills
- UK MTD for Income Tax started 6 April 2026 (qualifying income over GBP 50,000); GBP 30,000 from 6 April 2027; GBP 20,000 from 6 April 2028. Digital records hold amount, date and category per transaction. Quarterly updates 7 Aug 2026, 7 Nov 2026, 7 Feb 2027, 7 May 2027. [P-snip] https://www.gov.uk/government/collections/making-tax-digital-for-income-tax
- UK MTD for VAT: records in functional compatible software; data between software via digital links, not copy and paste. [P] https://www.gov.uk/guidance/record-keeping-for-vat-notice-70021

## 2. Account types

| Type      | Normal balance | Increases with |
| --------- | -------------- | -------------- |
| Asset     | Debit          | Debit          |
| Expense   | Debit          | Debit          |
| Liability | Credit         | Credit         |
| Equity    | Credit         | Credit         |
| Income    | Credit         | Credit         |

Contra accounts (accumulated depreciation, sales returns, owner drawings) carry the opposite of their parent's normal balance. [I]

Store a journal line as `(debit_minor, credit_minor)` with a check that exactly one is non-zero, or as signed integers with debit positive. Never floats. [I]

## 3. Minimal schema [I]

Each table is scoped to a ledger organisation, which maps one-to-one to a `Budget` (see `openbudget-coexistence.md`).

- `ledger_account(id, budget_id, code, name, type, subtype, system_role NULL, currency NULL, is_control, is_system, default_tax_code, tax_category_code NULL, cash_flow_section, archived_at)`. `currency` is set only for foreign-currency bank or control accounts. System accounts cannot be deleted or change type.
- `journal(id, budget_id, number, date, source_type, source_id, source_version, status {posted, reversed}, reverses_journal_id NULL, reason, created_by, posted_at, hash_prev, hash)`. Insert-only. Unique `(budget_id, source_type, source_id, source_version)` for idempotent posting.
- `journal_line(id, journal_id, ledger_account_id, party_id NULL, currency, amount_minor_txn, fx_rate, amount_minor_functional, side, tax_code NULL, tax_amount_minor NULL, tracking_1 NULL, tracking_2 NULL, document_id NULL)`.
- `audit_event(id, actor, action, entity, before_json, after_json, ts)`: draft edits, approvals, voids, settings and lock-date changes, un-reconciliation.
- `period_lock(budget_id, scope {org, adviser}, locked_through, set_by, set_at)`: itself append-only; the effective lock is the latest row per scope.
- Optional hash chain over journals (`hash = H(hash_prev || canonical journal)`) makes tampering evident, supporting the German unchangeable-or-traceable test. [I]

Serverpod note: `.spy.yaml` does not express triggers. Append-only enforcement needs SQL in the migration or a restricted database role; check what `serverpod create-migration` allows before committing to the design (open question).

## 4. Posting invariants (enforce in the database) [I]

1. At least two lines.
2. Sum of functional debits equals sum of functional credits. Also balanced per transaction currency, so a rate cannot hide an imbalance.
3. No zero-amount line; no line with both debit and credit.
4. Posting date is after the effective lock date unless an audited override applies (`assert_open`).
5. Source documents post idempotently via the unique key above.
6. Manual journals to control accounts require `party_id` and `document_id`.
7. `posted_at` is server time. Never trust client dates for it.

## 5. Corrections

Never edit a posted journal. Post a reversal (swap debit and credit, set `reverses_journal_id`), then post the correct journal. If the original date is locked, post both in the first open period and record the reason. Voiding a document is a reversal plus status `voided`, keeping its number and PDF. [I]

## 6. Lock dates

- Xero shows a padlock on transactions in a locked or closed period; an administrator must remove the lock to edit; exchange rates on locked dates cannot be edited. [S] https://central.xero.com/0/article/Edit-the-exchange-rate-for-a-date-or-date-range-US . The split between a period lock for everyone and an adviser-only lock was not confirmed.
- Keep two dates: an organisation lock and an optional adviser-only lock. All attempts go through `assert_open(date, actor)`. [I]
- After filing a tax return (for example a UK VAT return), lock that period. Corrections post as adjustments in the current period, as in HMRC error-correction method 2 (Notice 700/21 section 7.11 reference; text not read). [I]
- Opening a locked period needs an audited permission and writes an `audit_event`.

## 7. Accrual and cash from one ledger [I]

- The ledger is always accrual.
- Cash-basis reports use only journals that touch bank or cash accounts and attribute each movement back to income or expense lines through the settled document, in proportion to the amount paid.
- Store `settled_percentage` on each allocation so VAT on cash accounting and cash-basis P&L can be computed without rewriting the ledger. HMRC's attribution rules were not read.

## 8. Control accounts and checks [I]

- AR control = sum of open invoice balances less unallocated credits, per currency. AP likewise.
- VAT control: the net of VAT accounts equals the VAT return boxes (UK) or the Umsatzsteuer-Voranmeldung lines (DE) for the period.
- A nightly job runs these checks. A mismatch raises an alert and blocks period close.

## 9. Year-end close [I]

- Engine default: virtual close. Leave income and expense balances in place, show "current year earnings" as net P&L since the fiscal-year start, and fold prior years into retained earnings in reports only. This allows reopening a period without unwinding closing journals.
- Offer an explicit "close year" action that sets the lock date and writes an immutable snapshot of the statements.
- Physical close (a journal moving each P&L balance to retained earnings) is the alternative; see vector T7.7.
- Prior-year P&L accounts still report their own year when queried by date range.

## 10. Opening balances [I]

- One journal dated the day before the start date, balanced against `opening_balance_equity`. Investigate and clear any residual to retained earnings or a visible historical-adjustment account.
- Load AR and AP as open documents with original dates and amounts, not lump sums, so aged reports work.
- Load bank accounts at the statement balance plus unreconciled items at the cut-off date.
- Xero's equivalent: conversion balances; unpaid invoices and bills before the conversion date must be entered; non-base-currency balances cannot be imported directly. [S] https://central.xero.com/0/article/Enter-conversion-balances . Details in the `xero-migration` skill.

## 11. Financial statements [I unless noted]

All statements are queries over journal lines through one `ledger_balance` function.

- **Trial balance:** debit and credit columns with a total check; hard error on imbalance.
- **Balance sheet:** assets = liabilities + equity including current-year earnings, in every period and every currency view.
- **P&L:** grouped by account type and subtype (income, cost of sales, gross profit, other income, operating expenses, net profit), with comparison columns.
- **Cash flow (indirect):** net profit, add back non-cash items (depreciation), adjust for working-capital changes (AR, AP, prepayments, accruals, tax liabilities), then investing and financing. The closing figure equals the movement in bank and cash accounts. Tag accounts with `cash_flow_section`; do not guess.
- **Aged AR and AP:** open items only (document less allocations), bucketed Current, 1-30, 31-60, 61-90, 90+ by due date with configurable edges. Totals equal the control account at the report date. Credits and overpayments appear as negative rows.
- **Reports as at a past date** do not change when later entries are posted dated earlier inside a locked period. A "reported as at" feature reproduces from `posted_at`.
- Xero provides separate Foreign Currency Gains and Losses and Realised Gains and Losses reports. [S] https://central.xero.com/0/article/Foreign-Currency-Gains-and-Losses-report
- Statutory layouts (Companies Act formats, FRS 105 micro-entity, HGB §266/§275) were not researched. Do not claim statutory format compliance.
