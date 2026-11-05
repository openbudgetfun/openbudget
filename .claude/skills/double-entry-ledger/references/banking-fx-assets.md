# Bank reconciliation, multi-currency, fixed assets, prepayments and accruals

Tags: **P**, **S** secondary, **I** inferred (engineering recommendation), **K** general knowledge.

## 1. Bank reconciliation

Xero: reconciliation confirms bank transactions are recorded by matching statement lines on the Reconcile tab; period reconciliation takes a date range with opening and closing balances; bulk reconcile with cash coding for lines without a document; refunds and overpayments created during reconciliation must also be reconciled. [S] https://central.xero.com/0/article/Bank-reconciliation-in-Xero , https://central.xero.com/0/article/Reconcile-a-period , https://central.xero.com/0/article/Reconcile-using-cash-coding-US

Model [I]:

- `bank_statement_line(id, bank_account_id, date, amount_minor, currency, description, reference, external_id UNIQUE, running_balance NULL)`: immutable, deduplicated by `external_id`.
- `reconciliation(id, statement_line_id, status, rule_id NULL, reconciled_by, reconciled_at)`.
- `reconciliation_match(reconciliation_id, ledger_line_id OR payment_id, amount_minor)`: many-to-many, so one line can match several items and several lines one item.
- `bank_rule(id, conditions_json, action {code_to, party, tax_code, transfer_to}, priority)`.

Matching order [I]:

1. Exact: same amount, date within N days, reference or invoice number matches.
2. Group: several open documents of one party sum to the line.
3. Rule: description pattern leads to an account and tax code.
4. Transfer: an opposite-sign line of the same amount in another own account within a few days.
5. Manual or suggested.

Rules [I]:

- A transfer between own accounts is one journal (Dr Bank B, Cr Bank A) matched to both lines. If dates differ, route through `bank_clearing`.
- Unreconciled report: ledger bank lines without a statement line (outstanding payments and deposits) and statement lines without a ledger line. Formula: statement closing balance + outstanding deposits - outstanding payments = ledger balance at that date.
- A reconciled ledger bank line cannot be voided or edited until un-reconciled (audited).
- Feeds and file imports are idempotent through `external_id`. Details of formats and providers are in the `xero-migration` skill.

## 2. Multi-currency

Xero behaviour: unrealised gains and losses on unpaid foreign-currency documents are computed at today's rate and shown in a report, not posted; realised gains and losses are journalled at payment; a Historical Adjustment account takes unrealised differences on pre-conversion transactions; conversion balances start in base currency. [S] https://central.xero.com/0/article/Foreign-Currency-Gains-and-Losses-report , https://central.xero.com/0/article/Realised-gains-and-losses-report , https://central.xero.com/0/article/Work-with-the-Historical-Adjustment-account

Xero's own API convention is foreign per base, 6 decimals and 10 significant figures; amounts to 2 dp. [S] https://developer.xero.com/documentation/best-practices/data-integrity/multicurrency/

Rules [I]:

- Post each line in transaction currency and functional currency at the transaction-date rate.
- Convention: `rate` = functional currency per 1 unit of transaction currency, 8 or more decimals, with `rate_source` and `rate_date`. Never mix quote directions (1 GBP = 1.25 USD is 0.80 GBP per USD). Name the field explicitly. The T6 vectors below state their direction; the worked numbers are direction-independent once converted.
- A document locks its rate at approval; the user may override at approval only.
- Round each line to the functional minor unit; put residue on the largest line (or the control line). `rounding` account is last resort.
- Realised FX at settlement = functional amount at the payment rate minus the carried functional amount of the settled part. A part payment releases carrying value proportionally.
- Period-end revaluation of monetary items only (AR, AP, foreign bank, loans) at the closing rate. Post an unrealised journal and auto-reverse on day 1, or compute only in reports as Xero does. Do not revalue fixed assets, prepayments or equity.
- Foreign-currency bank accounts revalue the same way. Transfers between a USD and a GBP account take the rate from the actual statement amounts.
- UK VAT: total VAT chargeable on the invoice is in sterling; that figure posts to the VAT account (vector T4.2). The HMRC-acceptable rate sources were not retrieved. [P] https://www.gov.uk/guidance/record-keeping-for-vat-notice-70021
- No source was read on IAS 21 or FRS 102 s.30, CBN rate rules, or German conversion rules.
- Existing code note: `fx_rates` stores `double` rates from a third-party provider as snapshots. Ledger rates need exact decimals, a per-document locked rate, and an auditable source; the snapshot can seed a suggested rate only.

## 3. Fixed assets and depreciation [I]

- `fixed_asset(id, name, class, purchase_date, cost_minor, residual_minor, method {straight_line, reducing_balance}, life_months or rate_bp, in_service_date, disposed_date NULL, disposal_proceeds_minor NULL)`.
- `depreciation_run(asset_id, period, amount_minor, journal_id)` unique on `(asset_id, period)` so reruns are idempotent. The final period absorbs rounding so accumulated depreciation equals cost minus residual exactly.
- Disposal journal: Dr Bank (proceeds), Dr Accumulated depreciation, Cr Asset cost, difference to Gain or loss on disposal.
- Keep book depreciation separate from tax allowances (UK capital allowances, US MACRS, German AfA, Nigerian capital allowances). No rate tables are given; no HMRC, IRS, BMF or NRS source on them was read. Tax allowance rates belong in the tax rule packs.
- The fixed-asset module has its own start date in Xero. [S] https://central.xero.com/0/article/Change-the-fixed-asset-start-date-US
- US property records are kept until the limitation period for the disposal year expires. [P] https://www.irs.gov/businesses/small-businesses-self-employed/how-long-should-i-keep-records
- FRS 102 s.17, FRS 105 and IAS 16 wording was not read.

## 4. Prepayments, accruals, deferred income [I]

Implement as `scheduled_journal` templates with an `auto_reverse` flag.

- Prepayment: Dr Prepayments, Cr Bank (or AP); release monthly Dr Expense, Cr Prepayments over the service period.
- Accrual: cost incurred, no bill. Dr Expense, Cr Accruals at period end; auto-reverse on day 1 of the next period; the real bill posts normally.
- Deferred income: the sales equivalent (Dr Deferred income, Cr Sales over the service period).
- Scheduled journals respect lock dates: a run that falls in a locked period posts in the first open period with a reason.

## 5. Gaps

- Xero matching heuristics (score, rule syntax) not read.
- Open Banking provider specifics not researched here (see `xero-migration`).
