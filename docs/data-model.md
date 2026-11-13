# OpenBudget data model

Status: design for the schema reset (branch `refactor/schema-reset`), 9 November 2026.
Audience: the agent implementing the reset in one pass, and anyone changing a `.spy.yaml` file afterwards.

This document replaces the 78 current `*.spy.yaml` models and the 36 migrations in `openbudget_server/migrations/` with one schema and one fresh migration. Nothing is in production, so no data is migrated. Where this document and the `double-entry-ledger` skill disagree, section 2.3 says why and which one wins.

Contents:

1. [Decisions at a glance](#1-decisions-at-a-glance)
2. [Principles](#2-principles)
3. [What is wrong today](#3-what-is-wrong-today)
4. [Model inventory](#4-model-inventory)
5. [Models by domain](#5-models-by-domain)
6. [Server-side calculations](#6-server-side-calculations)
7. [Endpoint surface](#7-endpoint-surface)
8. [App impact, in working order](#8-app-impact-in-working-order)
9. [Migration plan](#9-migration-plan)
10. [Test plan](#10-test-plan)
11. [Follow-up migrations and extension points](#11-follow-up-migrations-and-extension-points)
12. [Open questions](#12-open-questions)

## 1. Decisions at a glance

1. **`Entity` replaces `Budget` as the root.** An entity is a person or household, a sole trader or a company. It has an owner, a kind, a country, a base currency, a time zone and a financial year end. It owns accounts, transactions, the envelope plan, the books, the tax profile, the assistant conversations, the Plaid connections and the wallets. "Budget" survives only as the name of the envelope plan feature.
2. **Money is `int` minor units named `*Minor`**, in the ISO 4217 exponent from `openbudget_core` (`CurrencyCode.decimals`). Values stay within ±(2^53 − 1) so Flutter web reads them exactly. Crypto quantities are `BigInt` base units (`quantityRaw`). No `double` holds money, a price or a rate anywhere.
3. **Exchange rates are exact decimal strings** (`fxRate`, `rate`, `unitPrice`). Every stored conversion carries `fxRate`, `fxRateDate` and `fxRateSource`.
4. **Every account has a currency and an `AccountKind`.** Assets and liabilities are told apart by the kind, through a rule in `openbudget_core`, never by the sign of the balance. Balances are signed: positive is owned, negative is owed.
5. **Two balance sources.** `transactions` accounts (cash, bank, cards, loans) sum their transactions. `valuations` accounts (property, vehicles, investments, crypto) take their latest `account_valuation`. `account.balanceMinor` caches either one and is changed only by `AccountBalanceService`, inside the same database transaction as the change that moved it.
6. **A transaction is a header plus one or more `transaction_line`s.** The header is the movement on the account. The lines allocate it to envelopes, ledger accounts and tax treatments. Split children are no longer rows in the same table, so nothing is counted twice.
7. **Every transaction stores both amounts:** `amountMinor` in the account currency and `baseAmountMinor` in the entity's base currency, at the rate of the transaction date. Envelopes, reports, tax and the books use base amounts. A cross-currency transfer stores what actually left and arrived, and takes its rate from those two amounts.
8. **The envelope plan stores only allocations** (`monthly_allocation.allocatedMinor`, keyed by `month` = yyyymm). Activity, carryover, available and Ready to Assign are derived on the server, with one aggregate query and a fold (section 6.4). `budget.getMonth` returns the whole Plan screen in one call.
9. **Net worth is computed on the server** for any set of the owner's entities, in a chosen reporting currency. It returns per-currency, per-entity and per-account breakdowns, and records the rate, rate date, source and staleness of every conversion. History is derived from transactions, valuations and daily FX rows, so it never goes stale and is cheap to chart. No snapshot table is needed.
10. **FX rates become one row per currency per day** (`fx_rate`, USD base) instead of a snapshot every ten minutes.
11. **Persisted enums replace free strings.** Enums that `openbudget_core` logic needs live in core as a Serverpod **shared package**: `EntityKind`, `AccountingMode`, `AccountKind`, `AccountBalanceSource`, `LedgerAccountType`, `LedgerSystemRole`, `JournalStatus`, `JournalSource`, `FxRateSource` and `RecurrenceFrequency`. Every other enum lives in the server.
12. **Every relation declares `onDelete`.** Deleting an entity removes everything under it. The three rows other records depend on are protected with `NoAction`: an envelope used by transaction lines, a category that still has envelopes, and a ledger account with lines.
13. **One wallet model.** `wallet_connection` and `solana_wallet` merge into `wallet`, with `wallet_holding`, `wallet_transaction` and `asset_price` below it.
14. **Bank transactions are the source documents of business books.** In ledger mode, each transaction revision posts one journal (`journal.sourceTransactionId` plus `sourceRevision`). The schema lands now; the posting service is a follow-up pull request (section 11).
15. **Invoices, bills, contacts, payments and VAT codes are deferred** to a later "documents" migration. The extension points are named in section 11.

## 2. Principles

### 2.1 Money

- Every money field is `int` (Postgres `bigint`). Its name ends in `Minor` and its doc comment says which currency it is in: the account currency, the base currency, or a named `*CurrencyCode` field on the same row.
- The minor-unit exponent comes from `CurrencyCode.decimals` in `openbudget_core`: 2 for GBP and USD, 0 for JPY and KRW, and 3 for KWD and BHD once they are added (section 12, Q12). Nothing assumes 2.
- Range: |value| ≤ 9,007,199,254,740,991 (2^53 − 1). The server rejects anything larger with `ValidationException`, because Dart `int` on Flutter web is a JavaScript number. That still allows about 90 trillion naira in kobo.
- Signs: transaction and line amounts are signed (+ in, − out). Account balances and valuations are signed (+ owned, − owed). Allocations may be negative. Goal amounts are positive.
- Rounding: round half up on the absolute value to the target minor unit, using `convertMinorUnits` in `openbudget_core/lib/src/ledger/exchange_rate.dart`. When one amount is split across lines, the rounding residue goes to the line with the largest absolute amount.
- Crypto quantities are `BigInt` base units (`quantityRaw`), stored by Serverpod as `text`. They are never summed in SQL. Fiat values of crypto are ordinary `*Minor` integers in a named currency.
- Micro-dollars stay as they are for agent metering (`costMicroUsd`), because that is a fixed internal unit.

### 2.2 Currency and FX

- Currency codes are `String` ISO 4217 codes, upper case, checked against `CurrencyCode.tryParse` by the existing `requireSupportedCurrency`. They stay strings rather than a Serverpod enum because the list is reference data owned by `openbudget_core`.
- **Base currency** is the entity's `baseCurrencyCode`. The ledger skill calls it the functional currency; this document says "base" everywhere, including in the ledger tables.
- **Rate direction is always "base (or target) units per one unit of the other currency"**: `baseAmount = round(amount × fxRate)` after shifting exponents. This matches the existing journal convention (functional per one transaction-currency unit).
- `fx_rate` stores provider rates as units of a currency per 1 USD. A cross rate from currency C to currency T is `rate(T) / rate(C)`, computed exactly with `ExactDecimal` and rounded half up to 12 significant digits. **The rounded rate is the one stored and used**, so every stored amount can be reproduced from its row.
- Every stored conversion keeps `fxRate`, `fxRateDate` (the date of the rate actually used, which may be earlier than the transaction date) and `fxRateSource` (`identity`, `market`, `implied` or `manual`).
- A conversion with no rate is never silently made at 1. Writes fail with `FxRateUnavailableException`, which the app answers by asking for a manual rate. Reads such as net worth mark the affected currency incomplete instead.

### 2.3 Where the ledger skill and this design differ

The skill's coexistence note (all tagged inferred) makes `Transaction` rows a _projection_ of posted journal lines for ledger budgets. This design reverses the direction. A `transaction` is the source document for a bank movement in every entity, and in ledger mode each revision posts an immutable journal, the way an invoice posts one. That gives one write path for bank movements in both modes: Plaid, CSV import, recurring transactions, wallets and the app all write transactions. It also means no projection table has to be kept in step. Journals stay append-only and remain the only input to trial balance, P&L and tax for ledger entities. Bank-linked ledger accounts accept lines only from journals sourced from a transaction, an opening balance or a revaluation, so the ledger balance of a bank account always equals the account's transaction balance. A nightly check compares the two. Update the skill's `openbudget-coexistence.md` when the posting service lands (section 11).

### 2.4 Dates, months and time zones

- **Instants** are `DateTime` in UTC, named `*At` (`createdAt`, `postedAt`, `fetchedAt`).
- **Calendar dates** are `DateTime` at 00:00:00.000 UTC, named `date` or `*Date` (`date`, `valuationDate`, `fxRateDate`, `lockDate`). They mean a day in the entity's time zone, not an instant. Add `CivilDate` helpers to `openbudget_core` (`civilDate(y, m, d)` and `isCivilDate(DateTime)`). The server rejects any date field that is not at UTC midnight. The app builds dates with `DateTime.utc(y, m, d)`.
- **Budget months** are `int` yyyymm (202611), named `month`. Add a `MonthKey` helper to core (`fromDate`, `toFirstDate`, `next`, `previous`, `validate`). An integer has no time-zone ambiguity and compares directly in SQL.
- "Today" for an entity is computed on the server from `entity.timeZone` (IANA), using `package:timezone`. Add it to `openbudget_server`. The UTC date is never used as a stand-in.

### 2.5 Identifiers

- Every table declares `id: UuidValue?, defaultPersist=random_v7`. That includes `audit_event`, which today falls back to a serial `int` id.
- UUIDv7 ids sort by creation time, so `(date, id)` is a stable keyset for paging.

### 2.6 Ownership, tenancy and access checks

- `entity.ownerId` references `serverpod_auth_core_user` with `onDelete=Restrict`. Every other user-scoped table (`userId`) references the same table with `onDelete=Cascade`.
- **Every row reachable directly by id from the client carries `entityId`**, even when a parent also implies it (`envelope`, `transaction`, `monthly_allocation`, `envelope_goal`). `entityId` never changes after insert, and services check `child.entityId == parent.entityId` on insert. It is an immutable tenancy key, not mutable duplicated state: access checks and hot queries become one indexed predicate, and the envelope → category → budget lookup chain goes away.
- One function guards access: `EntityAccess.requireOwned(session, entityId) → Entity` in `lib/src/entities/entity_access.dart`. Today it compares `ownerId`. Shared households later (section 11) change only this function.
- Rows that hang off a tenancy-keyed parent and are always reached through it (`transaction_line`, `journal_line`, `wallet_holding`, `account_valuation`, `budget_template_line`) do not repeat `entityId`.

### 2.7 Enums and reference data

- Persisted categorical values are Serverpod enums (`serialized: byName`, stored as `text`). Adding a value needs no migration; renaming one does.
- Enums used by `openbudget_core` logic are declared once, in core, as a Serverpod shared package (section 5.0). Enums only the server and app use are declared in the server.
- Values from external vocabularies stay `String` and say so in their doc comment: Helius `txType` and `source`, Plaid ids, tax category codes (validated against the core catalog) and IANA time zones.

### 2.8 Delete behaviour

- **Hard delete** is the default. There are no `deletedAt` columns.
- **Lifecycle states the user can see** are timestamps or booleans: `entity.archivedAt`, `account.closedAt`, `ledger_account.archivedAt`, and `isHidden` on categories and envelopes.
- **Cascade policy.** Cascades follow the ownership tree: entity → everything under it, account → its transactions, valuations and wallet, transaction → its lines. Protective references use `NoAction`, not `Restrict`. `NoAction` is checked at the end of the statement, so a whole-entity cascade succeeds while a direct delete of a referenced envelope, category or ledger account fails. `Restrict` would also break the entity cascade, because it is checked immediately.
- **The application layer still has to act on deletes.** A DB cascade does not maintain `account.balanceMinor`, so every delete of a transaction or valuation goes through its service. DB cascades only delete transactions together with their account or entity, where no cached balance survives to go stale.
- **Journals are never deleted** except by deleting the whole entity. The service warns and requires the confirmation text before deleting an entity in ledger mode.

### 2.9 Cached versus derived values

| Value                                                             | Stored or derived                                                | Kept correct by                                                                      |
| ----------------------------------------------------------------- | ---------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| `account.balanceMinor`                                            | **cached**                                                       | `AccountBalanceService` in the writing transaction; nightly verify job (section 6.2) |
| `transaction.baseAmountMinor`, line base amounts                  | **stored fact** (the rate is locked at the transaction date)     | `TransactionWriter` only                                                             |
| Envelope activity, carryover, available, Ready to Assign          | derived                                                          | one aggregate SQL query plus a fold (section 6.4)                                    |
| Cleared and uncleared balances                                    | derived                                                          | one `SUM ... GROUP BY status` per account                                            |
| Net worth, current and history                                    | derived                                                          | section 6.5 and 6.6                                                                  |
| Trial balance and statements                                      | derived                                                          | journal lines only                                                                   |
| Wallet holding `valueMinor`, `costBasisMinor`, `realizedPnlMinor` | **stored output of the last sync** (prices are not reproducible) | the wallet sync                                                                      |
| Unrealised P&L and percentages                                    | derived                                                          | `valueMinor − costBasisMinor`, computed when read                                    |

### 2.10 Audit and immutability

- `audit_event` (formerly `ledger_audit_event`) records every ledger action, every balance repair, and every edit or delete of a transaction in a ledger-mode entity, with a JSON payload of the before state. Rows are never updated.
- A posted journal is never updated or deleted. A correction is a reversal plus a new journal. These rules are enforced in `LedgerService` and `JournalPoster`, and covered by tests. Enforcement in the database is an open question (section 12, Q4). It cannot go into `migration.sql`, because Serverpod builds a fresh database from `definition.sql` alone and never runs a hand-edited `migration.sql` on it.

### 2.11 Naming

- Tables are snake_case singular. Fields are camelCase, which is also the column name.
- Foreign keys are `<thing>Id`. Booleans start with `is`, or are a plain adjective already in use (`onBudget`, `enabled`).
- Index names are `<table>_<columns>_idx`, plus `_unique_idx` when unique.
- Non-table response classes end in `View`, `Page`, `Result`, `Row` or `Summary`. Request classes end in `Input` or `Query`.

## 3. What is wrong today

Each of these was checked in the code on 9 November 2026. The section that fixes each one is given in brackets.

1. **Money in cents.** Every amount is a `*Cents` integer. The app's inline Plan keypad divides and multiplies by 100 (`budget_detail_screen.dart:240-251, 882-889`). Plaid balances are converted with `balance * 100` on a `double` (`plaid_service.dart:254`). Wallet values, prices and P&L figures are `double`, and so are FX rates. [2.1, 5.5, 5.7]
2. **No account on app-created transactions.** `TransactionEndpoint.create` has no `accountId` parameter, so expenses and income added in the app belong to no account. `Account.balanceCents` is a free number set by the user or by sync, and is never moved by transactions. `account_detail_screen.dart:336` treats it as an opening balance; the server docs call it the current balance. [5.3, 6.2]
3. **The stored spent amount is wrong.** After every expense, `addExpense` calls `envelope.update(spentAmountCents: amount)`, which overwrites the envelope's spent figure with the latest single expense (`transaction_actions_provider.dart:316-325`). The UI falls back to that figure whenever its monthly data is missing. [5.4, 6.4]
4. **Carryover is never computed.** `monthly_allocation.carryoverCents` is stored, but `copyMonth` drops it and `upsert` defaults it to 0, so "available" is wrong in any month after the first. [6.4]
5. **Splits count twice.** A split stores a parent and children in `transaction`, all on the same account. `reconcileWithBalance` and `ageOfMoney` sum every row, so a split is counted twice. The app hides the children by hand (`transaction_list_screen.dart:188-194`). [5.3]
6. **Currency is duplicated.** `transaction.currencyCode` is independent of its account's currency, and `envelope.currencyCode` is independent of the budget's. The app forces every account into the budget currency (`add_account_screen.dart:375`), and transfers reject mismatched currencies. [5.2, 5.3, 6.3]
7. **Net worth is wrong across currencies and kinds.** Only `creditCard` counts as a liability, while loans and mortgages are stored as `'other'` with negative balances and land in Assets. There is no total when currencies differ, and conversion runs in the app with `double` math. Three screens disagree: the home screen by currency, the account list by sign, and the net worth screen by type. [5.2, 6.5]
8. **Accounts are copied across budgets.** `listMine` and `addMineToBudget` copy one real account into several budgets, so the home screen's combined net worth counts it more than once. [5.1, 5.2]
9. **Budgets cannot be deleted.** 37 of the 41 non-module foreign keys are `ON DELETE NO ACTION`. Only the three agent tables and `journal_line → journal` cascade, so `BudgetService.delete` fails on any budget with data. [2.8]
10. **Plaid access tokens are stored in plain text**, in a model that is generated into `openbudget_client`. [5.7]
11. **Two parallel wallet systems.** `wallets/` (`wallet_connection`, `wallet_holding`, `asset_quote_cache`) and `solana_wallets/` (`solana_wallet` and its holdings and transactions) overlap. [5.7]
12. **FX grows without limit.** `fx_rate_snapshot` plus `fx_rate_entry` write about 170 rows every 10 minutes, roughly 24,000 a day. The rates are `double`, and `isLatest` is a flag maintained by hand. [5.6]
13. **Free strings where enums belong:** `accountType`, `sourceType`, `syncStatus` (on two tables, with different vocabularies), `flagColor`, `goalType`, `frequency`, `accountingMode`, `entityKind`, ledger `type`, `systemRole`, `status`, `source`, `rateSource`, audit `action`, and wallet `priceQuality` and `priceConfidence`. [5]
14. **Duplicated or orphaned facts.**
    - `tax_profile.jurisdiction` and `entityKind` repeat keys inside `profileJson`.
    - `linkedBudgetId` and both agent `conversationId` columns have no foreign key.
    - No `userId` column has a foreign key.
    - `budget_template.allocationData` is JSON keyed by envelope id, with no integrity.
    - `isHidden` is a nullable `bool`.
    - `envelope.reorder` takes `List<String>`.

    [5]
15. **N+1 calls from the app.**
    - `envelope.list` is keyed by category, so every all-envelopes view makes one call per category.
    - `budgetSummary` downloads every transaction ever recorded.
    - The home screen repeats this for every budget.
    - Reports fetch each month separately.
    - Auto-assign and cover-overspending upsert one allocation per call.

    [7, 8]
16. **Writes and indexes don't scale.**
    - `reconcileAccount` and `bulkCreate` write one row per statement.
    - The transaction date index is global rather than scoped to a budget.
    - `findDuplicates` matches by budget, not by account.

    [5.3, 6]
17. **The reconciliation adjustment is wrong.** `reconcileWithBalance` dates it `DateTime.now()` and puts it in the budget currency, not the account currency. [6.7]
18. **`ledger_audit_event` has a serial `int` id**, and its `entity` column means something else ("record kind") from the entity introduced here. [5.5]
19. **`convertMinorUnits` rounds negative amounts towards zero.** `_roundHalfUp` adds half the divisor and truncates, which is only half up for non-negative numerators. Checked: −3333 at `'0.8'` gives −2665, where half up on the absolute value gives −2666, and −5 at `'0.5'` gives −2, not −3. Journals pass only non-negative debits and credits, so nothing is wrong yet. Transactions convert signed amounts, so fix it first: round the absolute value and reapply the sign, and add negative vectors to `exchange_rate_test.dart`. [6.3]

## 4. Model inventory

Status is relative to today's models: **KEEP** (unchanged), **CHANGE**, **NEW**, **DROP**, or **MOVE** (same model declared in another package). Section 5 gives the full text of every model marked CHANGE, NEW or MOVE.

### 4.1 Tables

| Table                                                         | Status                                                       | Reason                                                                                  |
| ------------------------------------------------------------- | ------------------------------------------------------------ | --------------------------------------------------------------------------------------- |
| `entity`                                                      | NEW (replaces `budget`)                                      | explicit owner of everything, with kind, country, base currency, time zone and year end |
| `budget`                                                      | DROP                                                         | replaced by `entity`                                                                    |
| `user_settings`                                               | NEW                                                          | reporting currency for combined net worth, replacing per-budget `displayCurrencyCode`   |
| `tax_profile`                                                 | CHANGE                                                       | keyed by entity; jurisdiction and kind come from the entity                             |
| `account`                                                     | CHANGE                                                       | `AccountKind` enum, balance source, cached signed balance, typed connection keys        |
| `account_valuation`                                           | NEW                                                          | values for houses, cars and investments; net worth history                              |
| `transaction`                                                 | CHANGE                                                       | account required; base amount and rate; status and flag enums; external id              |
| `transaction_line`                                            | NEW                                                          | replaces split children and the envelope and tax columns on `transaction`               |
| `transfer`                                                    | NEW                                                          | the link between two legs, replacing `transferPairId` on both rows                      |
| `payee`                                                       | CHANGE                                                       | keyed by entity                                                                         |
| `transaction_rule`                                            | CHANGE                                                       | keyed by entity, with cascades                                                          |
| `recurring_transaction`                                       | CHANGE                                                       | account required; frequency enum; minor units                                           |
| `category`                                                    | CHANGE                                                       | keyed by entity; non-null `isHidden`                                                    |
| `envelope`                                                    | CHANGE                                                       | stored amounts and currency dropped; `entityId`; default ledger account                 |
| `monthly_allocation`                                          | CHANGE                                                       | `month` as yyyymm; carryover dropped                                                    |
| `envelope_goal`                                               | CHANGE                                                       | kind enum; one amount field                                                             |
| `budget_template`                                             | CHANGE                                                       | JSON payload dropped                                                                    |
| `budget_template_line`                                        | NEW                                                          | template amounts with foreign keys                                                      |
| `ledger_account`                                              | CHANGE                                                       | keyed by entity; enums; `archivedAt`                                                    |
| `journal`                                                     | CHANGE                                                       | keyed by entity; enums; transaction source key                                          |
| `journal_line`                                                | CHANGE                                                       | base naming; `fxRateSource` enum                                                        |
| `ledger_period_lock`                                          | CHANGE                                                       | keyed by entity                                                                         |
| `audit_event`                                                 | CHANGE (renamed from `ledger_audit_event`)                   | UUID id; action enum; covers all entities                                               |
| `fx_rate`                                                     | NEW                                                          | one exact row per currency per day                                                      |
| `fx_rate_snapshot`, `fx_rate_entry`                           | DROP                                                         | replaced by `fx_rate`                                                                   |
| `plaid_connection`                                            | CHANGE                                                       | encrypted token; sync cursor and status; keyed by entity                                |
| `wallet`                                                      | NEW (merges `solana_wallet` and `wallet_connection`)         | one wallet model                                                                        |
| `wallet_holding`                                              | CHANGE (merges `solana_wallet_holding` and `wallet_holding`) | `BigInt` quantity; minor-unit values; enums                                             |
| `wallet_transaction`                                          | CHANGE (renamed from `solana_wallet_transaction`)            | minor units; tags as a list; raw JSON server-only                                       |
| `asset_price`                                                 | CHANGE (renamed from `asset_quote_cache`)                    | exact price strings                                                                     |
| `solana_wallet`, `solana_wallet_holding`, `wallet_connection` | DROP                                                         | merged above                                                                            |
| `institution`                                                 | KEEP                                                         | catalog is sound                                                                        |
| `institution_location`                                        | CHANGE                                                       | `onDelete=Cascade` only                                                                 |
| `agent_conversation`                                          | CHANGE                                                       | keyed by entity; user foreign key                                                       |
| `agent_message`                                               | CHANGE                                                       | `onDelete` casing only                                                                  |
| `agent_proposal`                                              | CHANGE                                                       | keyed by entity; `conversationId` foreign key; `rulesVersion` (roadmap phase 8)         |
| `agent_usage_record`                                          | CHANGE                                                       | user and conversation foreign keys                                                      |
| `agent_provider_settings`                                     | CHANGE                                                       | `serverOnly`; user foreign key                                                          |
| `agent_access_token`                                          | CHANGE                                                       | `serverOnly`; user foreign key                                                          |
| `entitlement`                                                 | CHANGE                                                       | user foreign key                                                                        |
| `stripe_customer`                                             | CHANGE                                                       | `serverOnly`; user foreign key                                                          |
| `solana_billing_challenge`                                    | CHANGE                                                       | `serverOnly`; user foreign key                                                          |

Serverpod's own tables (`serverpod_*`) and the auth module tables (`serverpod_auth_core_*`, `serverpod_auth_idp_*`) are unchanged and come with the new migration automatically (section 9).

### 4.2 Enums

| Enum                                                                                                                                                                                                                                                                              | Status                                               | Lives in      |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------- | ------------- |
| `EntityKind`                                                                                                                                                                                                                                                                      | NEW (replaces the hand-written core `TaxEntityKind`) | core (shared) |
| `AccountingMode`, `LedgerAccountType`, `JournalStatus`                                                                                                                                                                                                                            | MOVE (hand-written core enums become shared models)  | core (shared) |
| `LedgerSystemRole`                                                                                                                                                                                                                                                                | MOVE + CHANGE (adds `bankClearing`)                  | core (shared) |
| `JournalSource`                                                                                                                                                                                                                                                                   | MOVE + CHANGE (adds `transaction`, `revaluation`)    | core (shared) |
| `AccountKind`, `AccountBalanceSource`, `FxRateSource`, `RecurrenceFrequency`                                                                                                                                                                                                      | NEW                                                  | core (shared) |
| `TransactionKind`, `TransactionStatus`, `TransactionFlag`, `ValuationSource`, `EnvelopeGoalKind`, `AuditAction`, `AuditSubject`, `SyncStatus`, `WalletNetwork`, `PriceSource`, `PriceQuality`, `Confidence`, `FxProvider`, `ChangeScope`, `ReportGrouping`, `NetWorthGranularity` | NEW                                                  | server        |
| `AgentEventKind`, `AgentMessageRole`, `AgentProposalKind`, `AgentProposalStatus`, `AgentProvider`, `EntitlementSource`, `EntitlementStatus`                                                                                                                                       | KEEP                                                 | server        |

### 4.3 Non-table classes and exceptions

| Class                                                                                                                                                                                               | Status                                       | Reason                                                  |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------- | ------------------------------------------------------- |
| `EntitySummaryView`, `EntityChangedEvent`                                                                                                                                                           | NEW                                          | home screen in one call; targeted realtime invalidation |
| `BudgetMonthView`, `EnvelopeMonthView`, `BudgetMonthSummary`, `AllocationInput`                                                                                                                     | NEW                                          | Plan screen and month reports in one call               |
| `TransactionInput`, `TransactionLineInput`, `TransferInput`, `TransactionQuery`, `TransactionPage`, `TransactionView`, `TransferPeerView`, `ImportResult`, `ReconcileResult`, `AccountBalancesView` | NEW                                          | one write shape; paged reads                            |
| `ImportRow`                                                                                                                                                                                         | CHANGE                                       | minor units; external id; payee name                    |
| `SplitItem`                                                                                                                                                                                         | DROP                                         | replaced by `TransactionLineInput`                      |
| `NetWorthView`, `NetWorthCurrencyRow`, `NetWorthEntityRow`, `NetWorthAccountRow`, `NetWorthHistoryView`, `NetWorthPoint`                                                                            | NEW                                          | server-side net worth                                   |
| `SpendingRow`                                                                                                                                                                                       | NEW                                          | reports in one aggregate                                |
| `FxLatestSnapshot`, `FxRateQuote`                                                                                                                                                                   | CHANGE                                       | exact rate strings; rate date                           |
| `FxQuoteView`                                                                                                                                                                                       | NEW                                          | shows the rate before a foreign transaction is saved    |
| `WalletSyncResult`, `WalletTaxYearSummary`                                                                                                                                                          | CHANGE (renamed from `SolanaWallet*`)        | minor units                                             |
| `WalletConnectResult`, `SolanaWalletSyncResult`, `SolanaWalletTaxYearSummary`                                                                                                                       | DROP                                         | merged or renamed                                       |
| `JournalLineInput`, `TrialBalanceView`, `TrialBalanceRowView`                                                                                                                                       | CHANGE                                       | entity key; base naming; enums                          |
| `TaxReportView`                                                                                                                                                                                     | CHANGE                                       | `entityKind` becomes `EntityKind`                       |
| `TaxBandSliceView`, `TaxCategoryView`, `TaxLiabilityView`, `TaxOpportunityView`, `TaxReportLineView`                                                                                                | KEEP                                         |                                                         |
| `AgentEvent`, `AgentProviderSettingsView`, `AgentUsageView`, `AgentAccessTokenCreated`, `AgentAccessTokenView`, `SolanaPlanView`                                                                    | KEEP                                         |                                                         |
| `FxRateUnavailableException`                                                                                                                                                                        | NEW (replaces `TaxRateUnavailableException`) | one exception for any missing rate                      |
| All other exceptions                                                                                                                                                                                | KEEP                                         |                                                         |

## 5. Models by domain

Every block below is the complete file content. Paste it as is. File paths are relative to the package named in each subsection. Remove the files listed as dropped.

### 5.0 Shared enums in `openbudget_core`

Serverpod 4.1 generates models declared in a **shared package** into that package, and both the server and the client use them. This lets the persisted enums that core logic needs (tax engine, chart templates, journal validation, account rules, recurrence) have one definition, with no name clashes.

Setup:

- `openbudget_server/config/generator.yaml` gains:

  ```yaml
  shared_packages:
    - ../openbudget_core
  ```

- `openbudget_core/pubspec.yaml` gains `serverpod_serialization: 4.1.0`, which is pure Dart. Core still has no Flutter dependency.
- The enum files go in `openbudget_core/lib/src/models/`. Generated code lands in `openbudget_core/lib/src/generated/`. Export `src/generated/protocol.dart` from `openbudget_core.dart`, and commit the generated files.
- Delete the hand-written `AccountingMode`, `JournalStatus` and `JournalSource` (`lib/src/ledger/journal_enums.dart`), `LedgerAccountType` (`ledger_account_type.dart`), `LedgerSystemRole` (`ledger_system_role.dart`) and `TaxEntityKind` (`tax/tax_model.dart`).
- Behaviour on those enums moves to extensions in the same files, for example `extension LedgerAccountTypeRules on LedgerAccountType { bool get hasDebitNormalBalance => ... }`.
- Replace `tryParse(name)` with `Enum.values.asNameMap()[name]`.
- Rename `TaxEntityKind` to `EntityKind` throughout core, server and app.
- Add `openbudget_core/lib/src/accounts/account_kind_rules.dart` with `isLiability`, `canBeOnBudget`, `defaultBalanceSource` and `allowedBalanceSources`, as in the table in section 5.2.

**Fallback:** if shared-package generation fails, declare these enums in the server instead. Keep core's logic enums under their current names and map between them with `byName`, with one parity test per enum, and import core with `hide` where both are in scope. Use the fallback only if the shared package cannot be made to generate; record which path was taken in the pull request.

`openbudget_core/lib/src/models/entity_kind.spy.yaml`:

```yaml
### What an entity is, for tax and for which features it may use.
enum: EntityKind
serialized: byName
values:
  ### A person or household. Envelope budgeting only.
  - individual
  ### A self-employed business whose profit is taxed on its owner's return.
  - soleTrader
  ### A limited company with its own return.
  - company
```

`openbudget_core/lib/src/models/accounting_mode.spy.yaml`:

```yaml
### How an entity keeps its records.
enum: AccountingMode
serialized: byName
values:
  ### Single-entry transactions with envelope budgeting. Every entity starts here.
  - envelope
  ### Each transaction revision also posts a double-entry journal. Sole
  ### traders and companies only; switching back is not supported.
  - ledger
```

`openbudget_core/lib/src/models/account_kind.spy.yaml`:

```yaml
### What an account holds or owes.
###
### Whether a kind is a liability, may be on budget, and which balance
### sources it allows are rules in `AccountKindRules`, never stored.
enum: AccountKind
serialized: byName
values:
  - cash
  - checking
  - savings
  - creditCard
  - loan
  - mortgage
  - investment
  - crypto
  - property
  - vehicle
  - otherAsset
  - otherLiability
```

`openbudget_core/lib/src/models/account_balance_source.spy.yaml`:

```yaml
### Where an account's balance comes from.
enum: AccountBalanceSource
serialized: byName
values:
  ### The sum of the account's transaction amounts.
  - transactions
  ### The latest account valuation, for things that are priced rather than
  ### transacted.
  - valuations
```

`openbudget_core/lib/src/models/fx_rate_source.spy.yaml`:

```yaml
### Where a stored exchange rate came from.
enum: FxRateSource
serialized: byName
values:
  ### Same currency; the rate is exactly 1.
  - identity
  ### The daily provider rate from `fx_rate`.
  - market
  ### Implied by the two amounts that actually moved in a transfer.
  - implied
  ### Entered by the user.
  - manual
```

`openbudget_core/lib/src/models/recurrence_frequency.spy.yaml`:

```yaml
### How often a recurring transaction repeats. Occurrence dates are expanded
### by `nextOccurrence` in `openbudget_core`, shared by the server's posting
### job and the app's calendar.
enum: RecurrenceFrequency
serialized: byName
values:
  - daily
  - weekly
  - biweekly
  - monthly
  - yearly
```

`openbudget_core/lib/src/models/ledger_account_type.spy.yaml`:

```yaml
### The five account types of a double-entry chart.
enum: LedgerAccountType
serialized: byName
values:
  - asset
  - liability
  - equity
  - income
  - expense
```

`openbudget_core/lib/src/models/ledger_system_role.spy.yaml`:

```yaml
### The stable internal role of a structural ledger account. At most one
### account per role per entity; system accounts cannot be archived.
enum: LedgerSystemRole
serialized: byName
values:
  - bank
  - accountsReceivable
  - accountsPayable
  - vatControl
  - payrollLiabilities
  - directorsLoan
  - retainedEarnings
  - openingBalanceEquity
  - suspense
  - rounding
  - realisedFx
  - unrealisedFx
  - ownerDrawings
  ### Clears the two legs of a transfer between the entity's own accounts.
  - bankClearing
```

`openbudget_core/lib/src/models/journal_status.spy.yaml`:

```yaml
### Where a journal is in its lifecycle.
enum: JournalStatus
serialized: byName
values:
  - draft
  - posted
  - reversed
```

`openbudget_core/lib/src/models/journal_source.spy.yaml`:

```yaml
### What produced a journal.
enum: JournalSource
serialized: byName
values:
  - manual
  - opening
  - import
  - reversal
  ### Posted from one revision of a bank transaction.
  - transaction
  ### Period-end or user-requested FX revaluation. Balanced in base currency
  ### only; lines may carry a zero transaction-currency amount.
  - revaluation
```

Add `bankClearing` to every chart template in `chart_of_accounts.dart` (an asset account, code chosen per template), and teach `JournalDraft` validation that `revaluation` journals balance in base currency only.

### 5.1 Entities and settings (`openbudget_server/lib/src/entities/`, `.../settings/`, `.../tax/`)

**`entity`: NEW.** The root that owns everything else. One entity is one set of books in one base currency.

Rules:

- `kind` is fixed after creation.
- `baseCurrencyCode` may change only while the entity has no transactions.
- `accountingMode` may become `ledger` only when `kind` is not `individual`, and never goes back.
- `fiscalYearEndMonth` and `fiscalYearEndDay` default from `defaultFiscalYearEnd(countryCode, kind)` in core:
  - GB individual and sole trader: 4/5.
  - GB company: 3/31 until the user sets their accounting reference date.
  - US, NG and DE: 12/31.
- `includeInNetWorth` defaults to false for companies and true otherwise (Q1).
- `linkedPersonalEntityId` must point at an `individual` entity with the same owner.

`entities/entity.spy.yaml`:

```yaml
### A person, household or business whose money OpenBudget keeps: the root
### that owns accounts, transactions, the envelope plan and the books.
###
### One entity is one set of books in one base currency.
class: Entity
table: entity
fields:
  id: UuidValue?, defaultPersist=random_v7
  ### The signed-in user who owns the entity.
  ownerId: UuidValue, relation(parent=serverpod_auth_core_user, onDelete=Restrict)
  name: String
  ### Fixed after creation.
  kind: EntityKind
  ### ISO 3166-1 alpha-2 country of residence or incorporation, upper case.
  ### Picks the tax rule pack and the chart-of-accounts template.
  countryCode: String
  ### ISO 4217 base (functional) currency. Envelopes, reports, tax and the
  ### books are kept in it. Fixed once the entity has a transaction.
  baseCurrencyCode: String
  ### IANA time zone, such as `Europe/London`. Defines "today" and which
  ### calendar date an instant belongs to.
  timeZone: String
  accountingMode: AccountingMode, default=envelope
  ### Month (1-12) the financial year ends in.
  fiscalYearEndMonth: int
  ### Day of fiscalYearEndMonth the financial year ends on.
  fiscalYearEndDay: int
  ### Whether the entity counts towards the owner's combined net worth.
  includeInNetWorth: bool, default=true
  ### For a sole trader or company: the owner's personal entity that the
  ### business's profit, drawings and dividends feed.
  linkedPersonalEntityId: UuidValue?, relation(parent=entity, onDelete=SetNull)
  sortOrder: int, default=0
  archivedAt: DateTime?
  createdAt: DateTime, default=now
  updatedAt: DateTime, default=now
indexes:
  entity_owner_idx:
    fields: ownerId, sortOrder
  entity_linked_personal_idx:
    fields: linkedPersonalEntityId
```

If the generator rejects `parent=serverpod_auth_core_user` (a module table), add `modules: { serverpod_auth_core: { nickname: auth } }` to `generator.yaml`, and declare `owner: module:auth:AuthUser?, relation(field=ownerId, onDelete=Restrict)` next to the plain `ownerId: UuidValue` field. Use the same fix for every `userId` relation below.

**`user_settings`: NEW.** It holds the reporting currency for combined net worth, replacing `Budget.displayCurrencyCode`. `UserSettingsService.get` creates the row lazily. The default currency is the base currency of the user's first entity, or USD.

`settings/user_settings.spy.yaml`:

```yaml
### Per-user preferences that span entities.
class: UserSettings
table: user_settings
fields:
  id: UuidValue?, defaultPersist=random_v7
  userId: UuidValue, relation(parent=serverpod_auth_core_user, onDelete=Cascade)
  ### ISO 4217 code that combined net worth and cross-entity totals use.
  reportingCurrencyCode: String
  updatedAt: DateTime, default=now
indexes:
  user_settings_user_unique_idx:
    fields: userId
    unique: true
```

**`tax_profile`: CHANGE.** It is keyed by entity, and the duplicated `jurisdiction`, `entityKind` and `linkedBudgetId` columns are dropped. On save and on read, `TaxService` overwrites these JSON keys from the entity before parsing:

- `jurisdiction` from `countryCode`
- `entityKind` from `kind`
- the GB `accountingPeriodEndMonth` and `accountingPeriodEndDay` from the fiscal year end

The entity is their single source of truth.

`tax/tax_profile.spy.yaml`:

```yaml
### The tax profile of one entity, stored as the tax engine's JSON.
class: TaxProfileRecord
table: tax_profile
fields:
  id: UuidValue?, defaultPersist=random_v7
  entityId: UuidValue, relation(parent=entity, onDelete=Cascade)
  ### `TaxProfile.toJson` payload. Its `jurisdiction`, `entityKind` and
  ### accounting-period keys are rewritten from the entity on every save and
  ### read; the entity is their source of truth.
  profileJson: String
  createdAt: DateTime, default=now
  updatedAt: DateTime, default=now
indexes:
  tax_profile_entity_unique_idx:
    fields: entityId
    unique: true
```

**Dropped:** `budgets/budget.spy.yaml`. Rename the `budgets/` directory to `entities/`, `BudgetService` to `EntityService`, `BudgetRealtimeNotifier` to `EntityRealtimeNotifier`, and `budget_stream.dart` to `entity_stream.dart`.

### 5.2 Accounts (`openbudget_server/lib/src/accounts/`, `.../institutions/`)

**Account kind rules** (`AccountKindRules` in core):

| Kind             | Liability | May be on budget | Default balance source | Allowed sources          |
| ---------------- | --------- | ---------------- | ---------------------- | ------------------------ |
| `cash`           | no        | yes              | transactions           | transactions             |
| `checking`       | no        | yes              | transactions           | transactions             |
| `savings`        | no        | yes              | transactions           | transactions             |
| `creditCard`     | yes       | yes              | transactions           | transactions             |
| `loan`           | yes       | no               | transactions           | transactions, valuations |
| `mortgage`       | yes       | no               | transactions           | transactions, valuations |
| `otherLiability` | yes       | no               | transactions           | transactions, valuations |
| `investment`     | no        | no               | valuations             | transactions, valuations |
| `otherAsset`     | no        | no               | valuations             | transactions, valuations |
| `crypto`         | no        | no               | valuations             | valuations               |
| `property`       | no        | no               | valuations             | valuations               |
| `vehicle`        | no        | no               | valuations             | valuations               |

**`account`: CHANGE.**

Changes from today:

- `accountType: String` becomes `kind: AccountKind`.
- `balanceCents` becomes `balanceMinor`, a signed cache.
- New: `balanceSource`.
- `isClosed` becomes `closedAt`.
- Dropped:
  - `creatorId`: the entity owner.
  - `sourceType`: derived from `plaidConnectionId` or a wallet row.
  - `connectionId`: replaced by typed foreign keys.
  - `syncStatus` and `lastSyncedAt`: moved to the connection or wallet.
  - `externalAccountId`: replaced by `plaidAccountId`, plus `wallet.address`.
- New: `reportedBalanceMinor` and `reportedBalanceAt` (what the bank says), `ledgerAccountId`, `reconciledThroughDate`, `note` and `updatedAt`.

Rules:

- `entityId`, `currencyCode` and `balanceSource` are fixed after creation.
- `onBudget` requires `canBeOnBudget(kind)` and `balanceSource == transactions`. It can change only while the account has no transactions other than its opening balance.
- `kind` may change only to another kind with the same `isLiability` and the same allowed source.
- `balanceMinor` is written only by `AccountBalanceService`.
- Writes to accounts are rejected while the owning entity is archived. A closed account rejects new transactions and valuation writes.
- Deleting an account removes both legs of every transfer that touches it, through `TransactionWriter`, so a surviving peer's cached balance is reversed. A reconciled or period-locked transfer leg rejects the whole delete.

`accounts/account.spy.yaml`:

```yaml
### Somewhere money or value is held or owed: a bank account, card, loan,
### wallet, house or car. Belongs to exactly one entity.
class: Account
table: account
fields:
  id: UuidValue?, defaultPersist=random_v7
  entityId: UuidValue, relation(parent=entity, onDelete=Cascade)
  name: String
  kind: AccountKind
  ### ISO 4217 code. Every transaction and valuation amount on the account is
  ### in this currency. Fixed after creation.
  currencyCode: String
  ### Fixed after creation.
  balanceSource: AccountBalanceSource
  ### Cached current balance in account-currency minor units, signed:
  ### positive is owned, negative is owed. Equals the sum of the account's
  ### transaction amounts, or its latest valuation. Written only by
  ### `AccountBalanceService`.
  balanceMinor: int, default=0
  ### Whether the account's money is in the envelope plan.
  onBudget: bool, default=false
  institutionId: UuidValue?, relation(parent=institution, onDelete=SetNull)
  plaidConnectionId: UuidValue?, relation(parent=plaid_connection, onDelete=SetNull)
  ### Plaid `account_id`, when linked through Plaid.
  plaidAccountId: String?
  ### Balance the institution last reported, in account minor units. Shown to
  ### prompt a reconciliation; never used for budgeting or net worth.
  reportedBalanceMinor: int?
  reportedBalanceAt: DateTime?
  ### The ledger account that mirrors this account in ledger-mode books.
  ledgerAccountId: UuidValue?, relation(parent=ledger_account, onDelete=NoAction)
  ### Statement date of the last completed reconciliation.
  reconciledThroughDate: DateTime?
  note: String?
  sortOrder: int, default=0
  closedAt: DateTime?
  createdAt: DateTime, default=now
  updatedAt: DateTime, default=now
indexes:
  account_entity_idx:
    fields: entityId, sortOrder
  account_plaid_unique_idx:
    fields: plaidConnectionId, plaidAccountId
    unique: true
  account_ledger_account_unique_idx:
    fields: ledgerAccountId
    unique: true
```

**`account_valuation`: NEW.** It stores the value over time of valuation-sourced accounts. Manual entries, Plaid investment and liability balances, and wallet syncs all write here: one row per account per day, upserted. Inserting, updating or deleting a row recomputes `account.balanceMinor` from the latest row, in the same transaction. `ValuationSource` is a new server enum.

`accounts/account_valuation.spy.yaml`:

```yaml
### The value of an account from a calendar date onwards, for accounts whose
### balance comes from valuations (a house, a car, a brokerage, a wallet).
class: AccountValuation
table: account_valuation
fields:
  id: UuidValue?, defaultPersist=random_v7
  accountId: UuidValue, relation(parent=account, onDelete=Cascade)
  ### Calendar date the value applies from.
  valuationDate: DateTime
  ### Value in account-currency minor units, signed like Account.balanceMinor.
  valueMinor: int
  source: ValuationSource
  note: String?
  createdAt: DateTime, default=now
  updatedAt: DateTime, default=now
indexes:
  account_valuation_account_date_unique_idx:
    fields: accountId, valuationDate
    unique: true
```

`accounts/valuation_source.spy.yaml`:

```yaml
### Who supplied an account valuation.
enum: ValuationSource
serialized: byName
values:
  - manual
  - plaid
  - wallet
  - import
```

**`institution`: KEEP.**

**`institution_location`: CHANGE** (onDelete only). `institutions/institution_location.spy.yaml`:

```yaml
### Geographic availability and popularity metadata for an institution.
class: InstitutionLocation
table: institution_location
fields:
  id: UuidValue?, defaultPersist=random_v7
  institutionId: UuidValue, relation(parent=institution, onDelete=Cascade)
  ### ISO 3166 country code (e.g. US, GB) or regional marker (e.g. EU).
  locationCode: String
  ### Whether this institution is shown in "Popular options" for the location.
  isPopular: bool, default=false
  ### Lower rank means higher priority in popular ordering.
  popularityRank: int?
  createdAt: DateTime, default=now
indexes:
  institution_location_institution_idx:
    fields: institutionId
  institution_location_code_idx:
    fields: locationCode, isPopular, popularityRank
  institution_location_unique_idx:
    fields: institutionId, locationCode
    unique: true
```

### 5.3 Transactions (`openbudget_server/lib/src/transactions/`, `.../payees/`, `.../transaction_rules/`, `.../recurring_transactions/`)

**`transaction`: CHANGE.**

Invariants, enforced by `TransactionWriter`, which is the only code that inserts, updates or deletes these rows:

1. `entityId == account.entityId`.
2. There is at least one line. `Σ line.amountMinor == amountMinor` and `Σ line.baseAmountMinor == baseAmountMinor`.
3. If the account currency equals the base currency, then `fxRate == '1'`, `fxRateSource == identity` and `baseAmountMinor == amountMinor`.
4. `date` and `fxRateDate` are calendar dates.
5. A `reconciled` transaction's `date`, `amountMinor`, `accountId` and lines cannot change until its status is set back to `cleared`.
6. In a ledger-mode entity, a change to the date, amount, account or lines increments `revision`. Dates on or before the period lock are rejected.

`kind == fxRevaluation` has `amountMinor == 0` and a non-zero `baseAmountMinor`.

Changes from today:

- Dropped:
  - `currencyCode`: the account's.
  - `envelopeId`, `taxCategoryCode`, `businessUsePercent`, `salesTaxCents` and `parentTransactionId`: moved to lines.
  - `transferPairId`: replaced by the `transfer` table.
  - `cleared` and `reconciled`: replaced by `status`.
- `flagColor` becomes `flag`.
- `transactionDate` becomes `date`.
- `amountCents` becomes `amountMinor`.
- New: `baseAmountMinor`, `fxRate`, `fxRateDate`, `fxRateSource`, `kind`, `externalId`, `recurringTransactionId`, `revision` and `updatedAt`.
- `accountId` is now required.
- `description` defaults to `''`.

`transactions/transaction.spy.yaml`:

```yaml
### Money moving into or out of one account on one calendar date.
###
### The header is the movement; its lines allocate it to envelopes, ledger
### accounts and tax treatments. Written only through TransactionWriter.
class: Transaction
table: transaction
fields:
  id: UuidValue?, defaultPersist=random_v7
  ### Always the account's entity; never changes.
  entityId: UuidValue, relation(parent=entity, onDelete=Cascade)
  accountId: UuidValue, relation(parent=account, onDelete=Cascade)
  ### Calendar date in the entity's time zone, at UTC midnight.
  date: DateTime
  ### Signed amount in account-currency minor units: positive in, negative out.
  amountMinor: int
  ### The same movement in the entity's base-currency minor units.
  baseAmountMinor: int
  ### Base currency per one unit of the account currency, exact decimal.
  fxRate: String, default='1'
  ### Calendar date of the rate actually used.
  fxRateDate: DateTime
  fxRateSource: FxRateSource, default=identity
  kind: TransactionKind, default=standard
  status: TransactionStatus, default=uncleared
  flag: TransactionFlag?
  payeeId: UuidValue?, relation(parent=payee, onDelete=SetNull)
  ### Statement text or a short title.
  description: String, default=''
  memo: String?
  ### Provider id for imported rows (Plaid transaction_id, `csv:<sha256>`),
  ### unique per account, so imports are idempotent.
  externalId: String?
  recurringTransactionId: UuidValue?, relation(parent=recurring_transaction, onDelete=SetNull)
  ### Increments whenever date, amount, account or lines change; ledger-mode
  ### books post one journal per revision.
  revision: int, default=0
  createdAt: DateTime, default=now
  updatedAt: DateTime, default=now
indexes:
  transaction_entity_date_idx:
    fields: entityId, date
  transaction_account_date_idx:
    fields: accountId, date
  transaction_payee_idx:
    fields: payeeId
  transaction_recurring_idx:
    fields: recurringTransactionId
  transaction_account_external_unique_idx:
    fields: accountId, externalId
    unique: true
```

`transactions/transaction_kind.spy.yaml`:

```yaml
### What a transaction represents, beyond an ordinary movement.
enum: TransactionKind
serialized: byName
values:
  - standard
  ### The balance an account started with.
  - openingBalance
  ### A difference found while reconciling against a statement.
  - balanceAdjustment
  ### Recognises the change in base-currency value of a foreign-currency
  ### account. amountMinor is 0; baseAmountMinor carries the difference.
  - fxRevaluation
```

`transactions/transaction_status.spy.yaml`:

```yaml
### How far a transaction has been checked against the bank.
enum: TransactionStatus
serialized: byName
values:
  - uncleared
  ### Seen on the bank statement or feed.
  - cleared
  ### Locked by a completed reconciliation.
  - reconciled
```

`transactions/transaction_flag.spy.yaml`:

```yaml
### A colour the user marks a transaction with.
enum: TransactionFlag
serialized: byName
values:
  - red
  - orange
  - yellow
  - green
  - blue
  - purple
```

**`transaction_line`: NEW.**

Rules:

- A line needs a non-zero `amountMinor` or a non-zero `baseAmountMinor`.
- `envelopeId` must belong to the transaction's entity, and must be null when the account is off budget.
- `ledgerAccountId` must belong to the entity, may be set only in ledger mode, and must not be the account's own `ledgerAccountId`.
- `businessUsePercent` is 0-100.
- `salesTaxMinor` has the same sign as `amountMinor`, and its absolute value is no larger.
- An inflow line on an on-budget account with no envelope is **Ready to Assign** income. An outflow line with no envelope is **uncategorised**, and also comes out of Ready to Assign.

`transactions/transaction_line.spy.yaml`:

```yaml
### One allocation of a transaction to an envelope, a ledger account and a
### tax treatment. A transaction has one or more lines that sum exactly to it.
class: TransactionLine
table: transaction_line
fields:
  id: UuidValue?, defaultPersist=random_v7
  transactionId: UuidValue, relation(parent=transaction, onDelete=Cascade)
  ### Part of the transaction amount, account-currency minor units, signed.
  amountMinor: int
  ### Part of the base amount, base-currency minor units, signed.
  baseAmountMinor: int
  ### Null on an on-budget account means Ready to Assign (inflow) or
  ### uncategorised (outflow). Always null on off-budget accounts.
  envelopeId: UuidValue?, relation(parent=envelope, onDelete=NoAction)
  ### Coding in ledger-mode books; null posts to the suspense account.
  ledgerAccountId: UuidValue?, relation(parent=ledger_account, onDelete=NoAction)
  ### Tax category code; overrides the envelope's default when set.
  taxCategoryCode: String?
  ### Share of the line used for business, 0-100.
  businessUsePercent: int?
  ### Sales tax included in amountMinor, account-currency minor units.
  salesTaxMinor: int?
  memo: String?
  sortOrder: int, default=0
indexes:
  transaction_line_transaction_idx:
    fields: transactionId
  transaction_line_envelope_idx:
    fields: envelopeId
  transaction_line_ledger_account_idx:
    fields: ledgerAccountId
```

**`transfer`: NEW.**

- It replaces `transferPairId`, which was stored on both legs. A link stored once cannot disagree with itself.
- Deleting either leg in the database deletes the link and leaves the other leg as an ordinary transaction, so its account balance stays correct.
- `TransactionService.delete` on a leg deletes **both** legs, which is what the user means.
- The legs may belong to different entities owned by the same user (owner's capital, drawings). Each leg is coded in its own books.

`transactions/transfer.spy.yaml`:

```yaml
### Links the two legs of a move between two accounts.
class: Transfer
table: transfer
fields:
  id: UuidValue?, defaultPersist=random_v7
  ### The outflow leg.
  fromTransactionId: UuidValue, relation(parent=transaction, onDelete=Cascade)
  ### The inflow leg.
  toTransactionId: UuidValue, relation(parent=transaction, onDelete=Cascade)
  createdAt: DateTime, default=now
indexes:
  transfer_from_unique_idx:
    fields: fromTransactionId
    unique: true
  transfer_to_unique_idx:
    fields: toTransactionId
    unique: true
```

**`payee`: CHANGE** (keyed by entity; `onDelete`). `payees/payee.spy.yaml`:

```yaml
### A merchant or person an entity pays or is paid by.
class: Payee
table: payee
fields:
  id: UuidValue?, defaultPersist=random_v7
  entityId: UuidValue, relation(parent=entity, onDelete=Cascade)
  name: String
  createdAt: DateTime, default=now
indexes:
  payee_entity_name_unique_idx:
    fields: entityId, name
    unique: true
```

**`transaction_rule`: CHANGE.** It is keyed by entity, `targetEnvelopeId` is renamed to `envelopeId`, and it cascades with its payee and envelope. A payee belongs to one entity, so the unique key is `payeeId`. `transaction_rules/transaction_rule.spy.yaml`:

```yaml
### Assigns an envelope automatically when a transaction uses a payee.
class: TransactionRule
table: transaction_rule
fields:
  id: UuidValue?, defaultPersist=random_v7
  entityId: UuidValue, relation(parent=entity, onDelete=Cascade)
  payeeId: UuidValue, relation(parent=payee, onDelete=Cascade)
  envelopeId: UuidValue, relation(parent=envelope, onDelete=Cascade)
  enabled: bool, default=true
  createdAt: DateTime, default=now
indexes:
  transaction_rule_entity_idx:
    fields: entityId
  transaction_rule_payee_unique_idx:
    fields: payeeId
    unique: true
```

**`recurring_transaction`: CHANGE.**

- `accountId` is required, and the amount is in the account currency.
- `currencyCode` is dropped.
- `frequency` becomes an enum.
- `nextOccurrence` becomes `nextDate`, a calendar date.
- `memo` is added.
- Posting goes through `TransactionWriter` with a single line, so the envelope rules apply.

`recurring_transactions/recurring_transaction.spy.yaml`:

```yaml
### A schedule that creates a transaction on each due date.
class: RecurringTransaction
table: recurring_transaction
fields:
  id: UuidValue?, defaultPersist=random_v7
  entityId: UuidValue, relation(parent=entity, onDelete=Cascade)
  accountId: UuidValue, relation(parent=account, onDelete=Cascade)
  payeeId: UuidValue?, relation(parent=payee, onDelete=SetNull)
  envelopeId: UuidValue?, relation(parent=envelope, onDelete=SetNull)
  description: String
  memo: String?
  ### Signed amount in account-currency minor units.
  amountMinor: int
  frequency: RecurrenceFrequency
  ### Calendar date of the next transaction to create.
  nextDate: DateTime
  ### Calendar date after which nothing more is created.
  endDate: DateTime?
  isActive: bool, default=true
  createdAt: DateTime, default=now
  updatedAt: DateTime, default=now
indexes:
  recurring_transaction_entity_idx:
    fields: entityId, isActive
  recurring_transaction_due_idx:
    fields: isActive, nextDate
```

**Dropped:** `transactions/split_item.spy.yaml`.

**`ImportRow`: CHANGE.** `transactions/import_row.spy.yaml`:

```yaml
### One row of a bulk import into one account.
class: ImportRow
fields:
  ### Calendar date.
  date: DateTime
  ### Signed amount in the account's minor units.
  amountMinor: int
  description: String
  payeeName: String?
  memo: String?
  ### Stable id from the source. When null the server derives
  ### `csv:<sha256(date|amountMinor|description|n)>`, where n counts identical
  ### rows earlier in the same file.
  externalId: String?
```

### 5.4 Envelope plan (`openbudget_server/lib/src/categories/`, `.../envelopes/`, `.../monthly_allocations/`, `.../envelope_goals/`, `.../budget_templates/`)

**`category`: CHANGE** (keyed by entity; non-null `isHidden`; `updatedAt`). `categories/category.spy.yaml`:

```yaml
### A group of envelopes in an entity's envelope plan.
class: Category
table: category
fields:
  id: UuidValue?, defaultPersist=random_v7
  entityId: UuidValue, relation(parent=entity, onDelete=Cascade)
  name: String
  sortOrder: int, default=0
  ### Hidden categories are left out of the default Plan view.
  isHidden: bool, default=false
  createdAt: DateTime, default=now
  updatedAt: DateTime, default=now
indexes:
  category_entity_idx:
    fields: entityId, sortOrder
```

**`envelope`: CHANGE.**

- Dropped:
  - `budgetedAmountCents`: replaced by allocations.
  - `spentAmountCents`: derived from lines.
  - `currencyCode`: always the base currency.
- Added: `entityId`, `defaultLedgerAccountId` and `updatedAt`.
- `isHidden` is non-null.
- A category cannot be deleted while it has envelopes (`NoAction`).
- An envelope used by any transaction line cannot be deleted. `EnvelopeService.delete(reassignToEnvelopeId:)` first moves its lines, allocations, goal, rules and recurring transactions, all in one transaction.

`envelopes/envelope.spy.yaml`:

```yaml
### A pot of money for one purpose in an entity's envelope plan. Its
### activity and available balance are derived, never stored.
class: Envelope
table: envelope
fields:
  id: UuidValue?, defaultPersist=random_v7
  entityId: UuidValue, relation(parent=entity, onDelete=Cascade)
  categoryId: UuidValue, relation(parent=category, onDelete=NoAction)
  name: String
  sortOrder: int, default=0
  note: String?
  ### Default tax category for lines assigned to this envelope.
  taxCategoryCode: String?
  ### Default ledger account for lines assigned to this envelope in
  ### ledger-mode books.
  defaultLedgerAccountId: UuidValue?, relation(parent=ledger_account, onDelete=SetNull)
  isHidden: bool, default=false
  createdAt: DateTime, default=now
  updatedAt: DateTime, default=now
indexes:
  envelope_entity_idx:
    fields: entityId
  envelope_category_idx:
    fields: categoryId, sortOrder
```

**`monthly_allocation`: CHANGE.**

- `year` and `month` become one `month` (yyyymm).
- `allocatedCents` becomes `allocatedMinor`, in base currency.
- `carryoverCents` is dropped (derived).
- `budgetId` becomes `entityId`.
- The table stays sparse: setting an allocation to 0 deletes the row.

`monthly_allocations/monthly_allocation.spy.yaml`:

```yaml
### Money assigned to an envelope for one month. The only stored figure of
### the envelope plan; activity, carryover and available are derived.
class: MonthlyAllocation
table: monthly_allocation
fields:
  id: UuidValue?, defaultPersist=random_v7
  entityId: UuidValue, relation(parent=entity, onDelete=Cascade)
  envelopeId: UuidValue, relation(parent=envelope, onDelete=Cascade)
  ### Budget month as yyyymm, such as 202611.
  month: int
  ### Assigned amount in base-currency minor units. Negative when more was
  ### moved out than was assigned this month. Never 0: a zero deletes the row.
  allocatedMinor: int
  createdAt: DateTime, default=now
  updatedAt: DateTime, default=now
indexes:
  monthly_allocation_envelope_month_unique_idx:
    fields: envelopeId, month
    unique: true
  monthly_allocation_entity_month_idx:
    fields: entityId, month
```

**`envelope_goal`: CHANGE.**

- `goalType: String` becomes `kind: EnvelopeGoalKind`.
- `targetAmountCents` and `monthlyFundingCents` collapse into one `amountMinor`, whose meaning depends on the kind.
- `entityId` is added.
- `targetDate` is required if and only if the kind is `targetByDate`.

`envelope_goals/envelope_goal.spy.yaml`:

```yaml
### A savings or funding target for one envelope.
class: EnvelopeGoal
table: envelope_goal
fields:
  id: UuidValue?, defaultPersist=random_v7
  entityId: UuidValue, relation(parent=entity, onDelete=Cascade)
  envelopeId: UuidValue, relation(parent=envelope, onDelete=Cascade)
  kind: EnvelopeGoalKind
  ### Base-currency minor units, positive. The target balance for
  ### targetBalance and targetByDate; the amount to assign each month for
  ### monthlyFunding.
  amountMinor: int
  ### Calendar date; required for targetByDate, null otherwise.
  targetDate: DateTime?
  createdAt: DateTime, default=now
  updatedAt: DateTime, default=now
indexes:
  envelope_goal_envelope_unique_idx:
    fields: envelopeId
    unique: true
```

`envelope_goals/envelope_goal_kind.spy.yaml`:

```yaml
### What an envelope goal asks for.
enum: EnvelopeGoalKind
serialized: byName
values:
  ### Keep the available balance at or above amountMinor.
  - targetBalance
  ### Assign amountMinor every month.
  - monthlyFunding
  ### Reach amountMinor available by targetDate.
  - targetByDate
```

Goal arithmetic (underfunded amount, progress) moves from the app's `budget_goals_provider.dart` into `openbudget_core/lib/src/budgeting/goal_math.dart`, so the server can fill `EnvelopeMonthView.goalUnderfundedMinor`.

**`budget_template`: CHANGE** (JSON payload dropped; keyed by entity). `budget_templates/budget_template.spy.yaml`:

```yaml
### A saved set of allocations that can be applied to any month.
class: BudgetTemplate
table: budget_template
fields:
  id: UuidValue?, defaultPersist=random_v7
  entityId: UuidValue, relation(parent=entity, onDelete=Cascade)
  ### User-chosen name, such as "Standard month".
  name: String
  createdAt: DateTime, default=now
  updatedAt: DateTime, default=now
indexes:
  budget_template_entity_idx:
    fields: entityId
```

**`budget_template_line`: NEW.** `budget_templates/budget_template_line.spy.yaml`:

```yaml
### One envelope's amount in a budget template.
class: BudgetTemplateLine
table: budget_template_line
fields:
  id: UuidValue?, defaultPersist=random_v7
  templateId: UuidValue, relation(parent=budget_template, onDelete=Cascade)
  envelopeId: UuidValue, relation(parent=envelope, onDelete=Cascade)
  ### Base-currency minor units.
  allocatedMinor: int
indexes:
  budget_template_line_unique_idx:
    fields: templateId, envelopeId
    unique: true
```

### 5.5 Ledger (`openbudget_server/lib/src/ledger/`)

The ledger's rules are unchanged: balanced posting, append-only journals, lock dates, the trial balance as a hard check. The changes are the entity key, enums instead of strings, "base" instead of "functional", and the transaction source key.

**`ledger_account`: CHANGE.**

- `budgetId` becomes `entityId`.
- `type` and `systemRole` become enums.
- `archived: bool` becomes `archivedAt`.
- New unique key on `(entityId, systemRole)`. Postgres treats NULLs as distinct, so any number of accounts without a role are allowed.

When an `account` is created in a ledger-mode entity, or when `enableLedger` runs, the service creates one ledger account per money account and links it through `account.ledgerAccountId`:

- `type` is `asset`, or `liability` when the account kind is a liability.
- `currencyCode` is the account's currency when it differs from the base currency.

`ledger/ledger_account.spy.yaml`:

```yaml
### One account in an entity's double-entry chart of accounts.
###
### Codes are user-visible labels; nothing keys on them. Accounts with a
### systemRole are structural: one per role, never archived.
class: LedgerAccount
table: ledger_account
fields:
  id: UuidValue?, defaultPersist=random_v7
  entityId: UuidValue, relation(parent=entity, onDelete=Cascade)
  ### Code from the template chart, unique per entity.
  code: String
  name: String
  type: LedgerAccountType
  systemRole: LedgerSystemRole?
  ### ISO 4217 code for foreign-currency bank and control accounts.
  currencyCode: String?
  ### Tax category feeding the tax engine.
  taxCategoryCode: String?
  ### Archived accounts keep their lines but accept no new postings.
  archivedAt: DateTime?
  createdAt: DateTime, default=now
indexes:
  ledger_account_entity_code_unique_idx:
    fields: entityId, code
    unique: true
  ledger_account_entity_role_unique_idx:
    fields: entityId, systemRole
    unique: true
```

**`journal`: CHANGE.**

- `budgetId` becomes `entityId`.
- `status` and `source` become enums.
- New: `sourceTransactionId` and `sourceRevision`, with a unique key so a transaction revision posts at most once.
- `reversalOfJournalId` gains a self foreign key.

`sourceTransactionId` deliberately has no foreign key: a posted journal outlives a deleted transaction, and its reversal records the delete.

`ledger/journal.spy.yaml`:

```yaml
### A journal in an entity's books: a dated, referenced bundle of lines.
###
### Drafts may be edited or deleted. Posted journals are immutable:
### corrections are journals with reversalOfJournalId pointing back, and the
### original flips to reversed. No update or delete path exists for posted
### rows.
class: Journal
table: journal
fields:
  id: UuidValue?, defaultPersist=random_v7
  entityId: UuidValue, relation(parent=entity, onDelete=Cascade)
  ### Calendar date in the entity's time zone.
  date: DateTime
  ### Human reference, such as `JB-2026-0001`.
  reference: String, default=''
  narration: String?
  status: JournalStatus, default=draft
  source: JournalSource, default=manual
  ### The transaction this journal posts, when source is `transaction`.
  ### No foreign key: posted journals outlive deleted transactions.
  sourceTransactionId: UuidValue?
  ### The transaction revision this journal posts.
  sourceRevision: int?
  ### Server time of posting. Never trusted from the client.
  postedAt: DateTime?
  postedBy: UuidValue?
  ### The posted journal this one reverses, when source is `reversal`.
  reversalOfJournalId: UuidValue?, relation(parent=journal, onDelete=NoAction)
  createdAt: DateTime, default=now
indexes:
  journal_entity_date_idx:
    fields: entityId, date
  journal_entity_status_idx:
    fields: entityId, status
  journal_source_transaction_unique_idx:
    fields: sourceTransactionId, sourceRevision
    unique: true
  journal_reversal_of_idx:
    fields: reversalOfJournalId
```

**`journal_line`: CHANGE.**

- `functionalDebitMinor` and `functionalCreditMinor` become `baseDebitMinor` and `baseCreditMinor`.
- `exchangeRate`, `rateDate` and `rateSource` become `fxRate`, `fxRateDate` (now required) and `fxRateSource` (now an enum).
- The index is renamed.

`ledger/journal_line.spy.yaml`:

```yaml
### One line of a journal: a one-sided amount on one ledger account.
###
### Each line carries the transaction-currency amount and the base amount
### with the exact rate that produced it. Exactly one of debitMinor and
### creditMinor is positive, and the base pair follows the same side.
class: JournalLine
table: journal_line
fields:
  id: UuidValue?, defaultPersist=random_v7
  journalId: UuidValue, relation(parent=journal, onDelete=Cascade)
  ledgerAccountId: UuidValue, relation(parent=ledger_account, onDelete=NoAction)
  description: String?
  ### Debit in transaction-currency minor units, or 0.
  debitMinor: int, default=0
  ### Credit in transaction-currency minor units, or 0.
  creditMinor: int, default=0
  ### ISO 4217 code of the transaction currency.
  currencyCode: String
  ### Debit in base-currency minor units, or 0.
  baseDebitMinor: int, default=0
  ### Credit in base-currency minor units, or 0.
  baseCreditMinor: int, default=0
  ### Base currency per one transaction-currency unit, exact decimal.
  fxRate: String, default='1'
  ### Calendar date of the rate.
  fxRateDate: DateTime
  fxRateSource: FxRateSource, default=identity
  ### Sales-tax code applied to this line.
  taxCode: String?
indexes:
  journal_line_journal_idx:
    fields: journalId
  journal_line_ledger_account_idx:
    fields: ledgerAccountId
```

**`ledger_period_lock`: CHANGE** (keyed by entity). `ledger/ledger_period_lock.spy.yaml`:

```yaml
### The per-entity period lock date.
###
### Posting, reversing or editing a transaction dated on or before lockDate
### is rejected. Every change writes an audit_event, so the lock's history
### lives in the audit trail.
class: LedgerPeriodLock
table: ledger_period_lock
fields:
  id: UuidValue?, defaultPersist=random_v7
  entityId: UuidValue, relation(parent=entity, onDelete=Cascade)
  ### Calendar dates on or before this one are locked.
  lockDate: DateTime
  setBy: UuidValue
  setAt: DateTime, default=now
indexes:
  ledger_period_lock_entity_unique_idx:
    fields: entityId
    unique: true
```

**`audit_event`: CHANGE** (renamed from `ledger_audit_event`).

- UUID id.
- `actor` becomes `actorId`.
- `action` becomes an enum.
- `entity` and `entityId` become `subjectType` (an enum) and `subjectId`, so "entity" means only the new root.

`audit/audit_event.spy.yaml` (move the file out of `ledger/`):

```yaml
### One audit trail entry for an entity. Never updated or deleted.
class: AuditEvent
table: audit_event
fields:
  id: UuidValue?, defaultPersist=random_v7
  entityId: UuidValue, relation(parent=entity, onDelete=Cascade)
  ### The acting user, or the nil UUID for system actions.
  actorId: UuidValue
  action: AuditAction
  subjectType: AuditSubject?
  subjectId: UuidValue?
  ### JSON object with the action's details, including the before state of
  ### edited or deleted rows.
  payloadJson: String, default='{}'
  createdAt: DateTime, default=now
indexes:
  audit_event_entity_created_idx:
    fields: entityId, createdAt
```

`audit/audit_action.spy.yaml`:

```yaml
### What an audit event records.
enum: AuditAction
serialized: byName
values:
  - ledgerEnabled
  - ledgerAccountCreated
  - ledgerAccountArchived
  - journalPosted
  - journalReversed
  - lockSet
  ### A transaction in a ledger-mode entity was edited after posting.
  - transactionEdited
  ### A transaction in a ledger-mode entity was deleted after posting.
  - transactionDeleted
  ### The nightly check found and repaired a cached balance.
  - balanceRepaired
```

`audit/audit_subject.spy.yaml`:

```yaml
### The kind of record an audit event is about.
enum: AuditSubject
serialized: byName
values:
  - entity
  - account
  - transaction
  - ledgerAccount
  - journal
  - periodLock
```

**`JournalLineInput`: CHANGE** (base naming). `ledger/journal_line_input.spy.yaml`:

```yaml
### One proposed journal line, as sent to `LedgerEndpoint.saveDraftJournal`.
class: JournalLineInput
fields:
  ledgerAccountId: UuidValue
  description: String?
  ### Debit in transaction-currency minor units, or 0.
  debitMinor: int, default=0
  ### Credit in transaction-currency minor units, or 0.
  creditMinor: int, default=0
  ### ISO 4217 code of the transaction currency.
  currencyCode: String
  ### Debit in base-currency minor units, or 0.
  baseDebitMinor: int, default=0
  ### Credit in base-currency minor units, or 0.
  baseCreditMinor: int, default=0
  ### Base currency per one transaction-currency unit, exact decimal.
  fxRate: String, default='1'
  ### Calendar date of the rate; the journal date when null.
  fxRateDate: DateTime?
  fxRateSource: FxRateSource, default=identity
  taxCode: String?
```

**`TrialBalanceRowView` and `TrialBalanceView`: CHANGE.** `ledger/trial_balance_row_view.spy.yaml`:

```yaml
### One row of a computed trial balance, in base-currency minor units.
class: TrialBalanceRowView
fields:
  ledgerAccountId: UuidValue
  accountCode: String
  accountName: String
  accountType: LedgerAccountType
  systemRole: LedgerSystemRole?
  debitMinor: int
  creditMinor: int
  ### Balance with debits positive.
  netMinor: int
```

`ledger/trial_balance_view.spy.yaml`:

```yaml
### The computed trial balance for one entity as of one date. An unbalanced
### result is a hard error, so the endpoint throws instead of returning one.
class: TrialBalanceView
fields:
  entityId: UuidValue
  ### ISO 4217 base currency code.
  currencyCode: String
  ### Inclusive calendar date the figures run through.
  asOf: DateTime
  rows: List<TrialBalanceRowView>
  totalDebitMinor: int
  totalCreditMinor: int
```

### 5.6 FX (`openbudget_server/lib/src/fx_rates/`)

**`fx_rate`: NEW. `fx_rate_snapshot` and `fx_rate_entry`: DROP.**

- One row per currency per UTC day, against USD. Store a USD row with rate `'1'` each day, so SQL joins need no special case.
- A refresh upserts today's rows and sets `fetchedAt`, so intraday refreshes overwrite instead of piling up. Refresh hourly instead of every 10 minutes; daily granularity is all any stored conversion uses.
- Convert the provider's JSON number to a plain decimal string without exponent notation (`1e-7` becomes `0.0000001`) before storing. `ExactDecimal.tryParse` must accept it.
- Historical rows are filled in by `FxBackfillFutureCall` for month ends and other dates that conversions ask for (section 6.3).

`fx_rates/fx_rate.spy.yaml`:

```yaml
### One currency's daily rate against USD, the provider's base.
class: FxRate
serverOnly: true
table: fx_rate
fields:
  id: UuidValue?, defaultPersist=random_v7
  ### Calendar date (UTC) the rate is for.
  rateDate: DateTime
  ### ISO 4217 code.
  currencyCode: String
  ### Units of currencyCode per 1 USD, exact decimal string.
  rate: String
  provider: FxProvider
  ### Last time the provider was asked for this day's rate.
  fetchedAt: DateTime
indexes:
  fx_rate_currency_date_unique_idx:
    fields: currencyCode, rateDate
    unique: true
  fx_rate_date_idx:
    fields: rateDate
```

`fx_rates/fx_provider.spy.yaml`:

```yaml
### Which upstream service supplied a rate.
enum: FxProvider
serialized: byName
values:
  - currencyapi
```

**`FxRateQuote`, `FxLatestSnapshot`: CHANGE. `FxQuoteView`: NEW.**

`fx_rates/fx_rate_quote.spy.yaml`:

```yaml
### One currency's rate against the snapshot base.
class: FxRateQuote
fields:
  currencyCode: String
  ### Units of currencyCode per one unit of the base, exact decimal string.
  rate: String
```

`fx_rates/fx_latest_snapshot.spy.yaml`:

```yaml
### The latest daily rates, for display only. Conversions that are stored
### happen on the server.
class: FxLatestSnapshot
fields:
  ### Always USD.
  baseCurrencyCode: String
  ### Calendar date of the rates.
  rateDate: DateTime
  fetchedAt: DateTime
  ### True when fetchedAt is more than 48 hours old.
  isStale: bool
  rates: List<FxRateQuote>
```

`fx_rates/fx_quote_view.spy.yaml`:

```yaml
### The rate the server would use to convert between two currencies on a date.
class: FxQuoteView
fields:
  fromCurrencyCode: String
  toCurrencyCode: String
  ### Units of toCurrencyCode per one fromCurrencyCode, exact decimal string.
  rate: String
  ### Calendar date of the rate actually used (on or before the asked date).
  rateDate: DateTime
  source: FxRateSource
  fetchedAt: DateTime?
  isStale: bool
```

### 5.7 Connections: Plaid and wallets (`openbudget_server/lib/src/plaid/`, `.../wallets/`)

**`plaid_connection`: CHANGE.**

- The access token is sealed with AES-256-GCM by the existing `AgentSecretBox` (rename it `SecretBox` and move it to `common/`). Both sealed fields are `scope=serverOnly`, so the client class carries no secret at all.
- `institutionId` (a Plaid id held in a string) becomes `plaidInstitutionId`.
- New: `transactionsCursor` (for `/transactions/sync`, used by a follow-up), `syncStatus` and `lastSyncError`.
- `plaidItemId` is unique on its own, because Plaid item ids are global.

`plaid/plaid_connection.spy.yaml`:

```yaml
### A Plaid item linked to an entity, for syncing its bank accounts.
class: PlaidConnection
table: plaid_connection
fields:
  id: UuidValue?, defaultPersist=random_v7
  entityId: UuidValue, relation(parent=entity, onDelete=Cascade)
  plaidItemId: String
  ### Base64 AES-256-GCM ciphertext of the access token, with its MAC tag.
  accessTokenCiphertext: String, scope=serverOnly
  ### Base64 nonce for accessTokenCiphertext.
  accessTokenNonce: String, scope=serverOnly
  plaidInstitutionId: String?
  institutionName: String?
  ### Cursor for Plaid /transactions/sync; null until the first sync.
  transactionsCursor: String?, scope=serverOnly
  syncStatus: SyncStatus, default=pending
  lastSyncedAt: DateTime?
  lastSyncError: String?
  createdAt: DateTime, default=now
  updatedAt: DateTime, default=now
indexes:
  plaid_connection_item_unique_idx:
    fields: plaidItemId
    unique: true
  plaid_connection_entity_idx:
    fields: entityId
```

`common/sync_status.spy.yaml`:

```yaml
### Where an external connection's last sync stands. Staleness is derived
### from lastSyncedAt, never stored.
enum: SyncStatus
serialized: byName
values:
  - pending
  - synced
  - failed
```

Plaid balances:

- Depository and credit accounts are `transactions` accounts. On link, their opening balance is a `kind: openingBalance` transaction for Plaid's current balance. Credit balances owed are negated.
- Every later sync writes `reportedBalanceMinor` and `reportedBalanceAt`.
- Investment, loan and mortgage accounts from Plaid are `valuations` accounts, and each sync upserts today's `account_valuation` (source `plaid`).
- Amounts are converted with `parseMinorUnits(value.toString(), decimals)`, never `* 100`.

**`wallet`: NEW** (merges `solana_wallet` and `wallet_connection`). A wallet always has a `crypto` account with `balanceSource: valuations`, created by `wallet.connect`. Its currency is the price currency, USD today (Q8). Each sync upserts today's valuation (source `wallet`) for the sum of the priced holdings' `valueMinor`. One wallet is one address, or one HD key, in one chain family: `network` is the wallet's home network, and an EVM wallet lists every network it reads in `scanNetworks`.

`wallets/wallet.spy.yaml`:

```yaml
### A read-only blockchain wallet whose holdings value one crypto account.
###
### One wallet is one address, or one HD key, in one chain family. An EVM
### wallet reads every network in scanNetworks; any other wallet reads its
### one network.
class: Wallet
table: wallet
fields:
  id: UuidValue?, defaultPersist=random_v7
  entityId: UuidValue, relation(parent=entity, onDelete=Cascade)
  ### The crypto account carrying the wallet's value into net worth.
  accountId: UuidValue, relation(parent=account, onDelete=Cascade)
  ### The wallet's home network, which fixes its chain family. Every EVM
  ### wallet uses ethereumMainnet here, so one EVM address is one wallet,
  ### and lists the networks it reads in scanNetworks.
  network: WalletNetwork
  ### The address in its family's canonical form (core WalletAddressParser).
  ### For an HD wallet, `hd:` and the first 40 hex digits of the SHA-256 of
  ### its canonical descriptor, so the key is never stored in clear.
  address: String
  ### EVM wallets: the networks each read covers, in display order. Null for
  ### every other family.
  scanNetworks: List<WalletNetwork>?
  ### HD wallets: the BIP 380 output descriptor, sealed with SecretBox.
  ### Written together with descriptorNonce or not at all.
  descriptorCiphertext: String?, scope=serverOnly
  descriptorNonce: String?, scope=serverOnly
  label: String?
  ### Solana only: the newest signature already processed. Other families
  ### keep history positions in wallet_network_state.
  lastSignature: String?
  syncStatus: SyncStatus, default=pending
  lastSyncedAt: DateTime?
  lastSyncError: String?
  createdAt: DateTime, default=now
  updatedAt: DateTime, default=now
indexes:
  wallet_account_unique_idx:
    fields: accountId
    unique: true
  wallet_entity_network_address_unique_idx:
    fields: entityId, network, address
    unique: true
  wallet_address_idx:
    fields: address
```

`openbudget_core/lib/src/models/wallet_network.spy.yaml` (shared with the server and the app; `ChainFamily`, the chain catalogue and the per-network rules are derived from it in core, never stored):

```yaml
### Which chain and network a wallet, holding, transaction or price is on.
### Stored by name: append values, never rename one.
enum: WalletNetwork
serialized: byName
values:
  - solanaMainnet
  - solanaDevnet
  - bitcoinMainnet
  - ethereumMainnet
  - baseMainnet
  - arbitrumOne
  - opMainnet
  - polygonPos
  - bnbSmartChain
  - avalancheCChain
  - tronMainnet
  - xrplMainnet
  - hyperliquid
  - dogecoinMainnet
  - litecoinMainnet
  - cardanoMainnet
  - tonMainnet
  - suiMainnet
  - aptosMainnet
```

**`wallet_holding`: CHANGE** (merges `solana_wallet_holding` with the old `wallet_holding`; multichain). Every holding carries its `network` and a `position` (spendable, staked or unclaimed), so one wallet can hold one asset on several networks and in several positions; `spamVerdict` decides whether it counts toward net worth.

- `balanceRaw: String` becomes `quantityRaw: BigInt`.
- `balanceUi` and `quantityDisplay` are dropped: they are derived from `quantityRaw` and `decimals`.
- `double` prices and values become `unitPrice` (an exact string) and `valueMinor`.
- Dropped as derived: unrealised P&L and its percentage, and `isPriceStale` (now `priceQuality == cached`). `pnlCurrency` is the same as `priceCurrencyCode`.
- `budgetId` is dropped; the holding is reached through its wallet.

`wallets/wallet_holding.spy.yaml`:

```yaml
### The current quantity and valuation of one asset in a wallet, on one
### network and in one position.
class: WalletHolding
table: wallet_holding
fields:
  id: UuidValue?, defaultPersist=random_v7
  walletId: UuidValue, relation(parent=wallet, onDelete=Cascade)
  ### The network the asset is on. A single-network wallet's holdings use the
  ### wallet's network.
  network: WalletNetwork
  ### The asset on that network: `native`, or the contract, mint, coin type,
  ### jetton master or policy-and-name unit (multichain-wallets.md 7.2).
  assetId: String
  ### Spendable, staked or unclaimed. Each position of an asset is its own
  ### holding.
  position: HoldingPosition, default=available
  symbol: String?
  name: String?
  ### The token standard or program: a Solana token program id, or erc20,
  ### trc20, trc10, xrplIou, jetton, cardanoNative, suiCoin or aptosFa.
  tokenProgram: String?
  decimals: int
  ### Quantity in the asset's base units (lamports, wei, satoshis, sun,
  ### drops).
  quantityRaw: BigInt
  isNft: bool, default=false
  ### Whether the holding counts toward net worth. The classifier sets clean
  ### or suspected; a user choice overrides it and survives syncs.
  spamVerdict: SpamVerdict, default=clean
  ### ISO 4217 code that unitPrice and every *Minor field here are in.
  priceCurrencyCode: String?
  ### Price of one whole token, exact decimal string.
  unitPrice: String?
  ### Quantity times unitPrice, in priceCurrencyCode minor units, half up.
  valueMinor: int?
  priceSource: PriceSource?
  priceQuality: PriceQuality, default=unpriced
  priceConfidence: Confidence?
  priceAsOf: DateTime?
  ### Estimated acquisition cost of the current quantity.
  costBasisMinor: int?
  ### Estimated realised gain or loss accumulated for this asset.
  realizedPnlMinor: int?
  pnlAsOf: DateTime?
  ### JSON subset of the asset's metadata.
  metadataJson: String?
  updatedAt: DateTime, default=now
indexes:
  wallet_holding_wallet_asset_unique_idx:
    fields: walletId, network, assetId, position
    unique: true
  wallet_holding_asset_idx:
    fields: network, assetId
```

`wallets/holding_position.spy.yaml`:

```yaml
### Whether a holding is spendable now, or staked or unclaimed. Every
### position counts toward net worth; the app shows them apart.
enum: HoldingPosition
serialized: byName
values:
  ### Spendable now.
  - available
  ### Staked, frozen or delegated: still owned, not spendable now.
  - staked
  ### Rewards earned but not yet claimed or withdrawn.
  - unclaimedRewards
```

`wallets/spam_verdict.spy.yaml`:

```yaml
### Whether a holding counts toward net worth.
enum: SpamVerdict
serialized: byName
values:
  ### Counted when priced.
  - clean
  ### Matched a spam rule; not counted until the user allows it.
  - suspected
  ### The user hid it; never counted.
  - hiddenByUser
  ### The user allowed it; counted when priced, whatever the rules say.
  - allowedByUser
```

**`wallet_network_state`: NEW.** One network's read state for one wallet: when its holdings were last read, why the last read failed, and where history sync stopped.

`wallets/wallet_network_state.spy.yaml`:

```yaml
### One network's read state for one wallet: when its holdings were last read,
### why the last read failed, and where history sync stopped.
class: WalletNetworkState
table: wallet_network_state
fields:
  id: UuidValue?, defaultPersist=random_v7
  walletId: UuidValue, relation(parent=wallet, onDelete=Cascade)
  network: WalletNetwork
  ### When holdings on this network were last read successfully.
  lastReadAt: DateTime?
  ### The last read's failure in plain words, cleared by the next success.
  lastError: String?
  ### Provider-defined history position (a block number, ledger index, page
  ### key or transaction id). Null until history sync covers this network.
  historyCursor: String?, scope=serverOnly
  updatedAt: DateTime, default=now
indexes:
  wallet_network_state_wallet_network_unique_idx:
    fields: walletId, network
    unique: true
```

`wallets/price_source.spy.yaml`:

```yaml
### Which pricing source valued a holding.
enum: PriceSource
serialized: byName
values:
  - helius
  - jupiter
  - magicEden
  ### Computed from a related asset or pool.
  - derived
  - coingecko
  - defillama
```

`wallets/price_quality.spy.yaml`:

```yaml
### How trustworthy a holding's price is right now.
enum: PriceQuality
serialized: byName
values:
  ### Fresh from a provider.
  - live
  ### Computed rather than quoted.
  - derived
  ### A cached price used because the provider failed.
  - cached
  ### No price; the holding is left out of the valuation.
  - unpriced
```

`common/confidence.spy.yaml`:

```yaml
### A three-level confidence tier.
enum: Confidence
serialized: byName
values:
  - high
  - medium
  - low
```

**`wallet_transaction`: CHANGE** (renamed from `solana_wallet_transaction`).

- `double` estimates become `*Minor` fields in `pnlCurrencyCode`.
- `interpretationConfidence` becomes the `Confidence` enum.
- `tagsCsv` becomes `tags: List<String>?`.
- `taxYear` is dropped: it is derived from `occurredAt` and the entity's fiscal year.
- `rawJson` becomes `scope=serverOnly`.
- `budgetId` is dropped.

`wallets/wallet_transaction.spy.yaml`:

```yaml
### A parsed on-chain transaction that touched a wallet.
class: WalletTransaction
table: wallet_transaction
fields:
  id: UuidValue?, defaultPersist=random_v7
  walletId: UuidValue, relation(parent=wallet, onDelete=Cascade)
  ### The network the transaction is on.
  network: WalletNetwork
  ### The transaction id: a Solana signature, an EVM or Tron hash, a Bitcoin
  ### txid or an XRP Ledger hash.
  signature: String
  ### Solana slot, block height or ledger index; orders transactions within
  ### one network.
  slot: int
  occurredAt: DateTime?
  description: String
  ### The provider's transaction type vocabulary, such as Helius `SWAP`.
  ### External vocabulary.
  txType: String
  ### The provider's source vocabulary, such as Helius `JUPITER`. External
  ### vocabulary.
  source: String
  interpretationConfidence: Confidence?
  ### JSON list of program ids the transaction invoked.
  programsJson: String?
  nativeTransfersJson: String?
  tokenTransfersJson: String?
  ### ISO 4217 code of the three estimates below.
  pnlCurrencyCode: String?
  costBasisMinor: int?
  proceedsMinor: int?
  realizedPnlMinor: int?
  ### User-managed classification.
  category: String?
  tags: List<String>?
  memo: String?
  ### Raw provider payload.
  rawJson: String?, scope=serverOnly
  createdAt: DateTime, default=now
  updatedAt: DateTime, default=now
indexes:
  wallet_transaction_wallet_signature_unique_idx:
    fields: walletId, network, signature
    unique: true
  wallet_transaction_wallet_time_idx:
    fields: walletId, occurredAt
```

**`asset_price`: CHANGE** (renamed from `asset_quote_cache`; exact price; network enum). `wallets/asset_price.spy.yaml`:

```yaml
### Cached price of one on-chain asset.
class: AssetPrice
serverOnly: true
table: asset_price
fields:
  id: UuidValue?, defaultPersist=random_v7
  network: WalletNetwork
  assetId: String
  symbol: String?
  ### ISO 4217 code of unitPrice (USD today).
  currencyCode: String
  ### Price of one whole token, exact decimal string.
  unitPrice: String
  source: PriceSource
  fetchedAt: DateTime
  expiresAt: DateTime
indexes:
  asset_price_network_asset_unique_idx:
    fields: network, assetId
    unique: true
  asset_price_expires_idx:
    fields: expiresAt
```

**`WalletSyncResult`, `WalletTaxYearSummary`: CHANGE** (renamed, minor units). `wallets/wallet_sync_result.spy.yaml`:

```yaml
### What one wallet sync did.
class: WalletSyncResult
fields:
  walletId: UuidValue
  insertedTransactions: int
  updatedTransactions: int
  holdingCount: int
  pricedHoldingCount: int
  cachedHoldingCount: int
  unpricedHoldingCount: int
  nftHoldingCount: int
  pricedNftHoldingCount: int
  cachedNftHoldingCount: int
  unpricedNftHoldingCount: int
  ### Share of holdings with a price, 0.0-1.0. Not money.
  valuationCoverageRatio: double?
  ### Sum of priced holdings, in valuationCurrencyCode minor units.
  totalValueMinor: int?
  valuationCurrencyCode: String?
  syncedAt: DateTime
  warnings: List<String>
```

`wallets/wallet_tax_year_summary.spy.yaml`:

```yaml
### Estimated realised wallet P&L for one tax year of the wallet's entity.
class: WalletTaxYearSummary
fields:
  walletId: UuidValue
  ### Calendar year the entity's tax year starts in.
  taxYear: int
  transactionCount: int
  pnlCurrencyCode: String
  realizedPnlMinor: int
  proceedsMinor: int
  costBasisMinor: int
```

**Dropped:**

- `solana_wallets/solana_wallet.spy.yaml`, `solana_wallet_holding.spy.yaml`, `solana_wallet_transaction.spy.yaml`, `solana_wallet_sync_result.spy.yaml` and `solana_wallet_tax_year_summary.spy.yaml`.
- `wallets/wallet_connection.spy.yaml`, `wallet_connect_result.spy.yaml` and `asset_quote_cache.spy.yaml`.

Merge `SolanaWalletService` (the richer sync) and `WalletService` into one `WalletService` under `wallets/`. The Helius, Jupiter and Magic Eden clients move with it.

### 5.8 Assistant (`openbudget_server/lib/src/agent/`)

`AgentEvent`, `AgentEventKind`, `AgentMessageRole`, `AgentProposalKind`, `AgentProposalStatus`, `AgentProvider`, `AgentProviderSettingsView`, `AgentUsageView`, `AgentAccessTokenCreated` and `AgentAccessTokenView` are **KEEP**.

Proposal payloads change shape:

- `moveMoney` becomes `{entityId, month, fromEnvelopeId?, toEnvelopeId?, amountMinor}`.
- `setTransactionTaxCategory` becomes `{transactionLineId, code}`.
- `setEnvelopeTaxCategory` is unchanged.

`agent/agent_conversation.spy.yaml`:

```yaml
### One chat between a user and the financial assistant about an entity.
class: AgentConversation
table: agent_conversation
fields:
  id: UuidValue?, defaultPersist=random_v7
  userId: UuidValue, relation(parent=serverpod_auth_core_user, onDelete=Cascade)
  entityId: UuidValue, relation(parent=entity, onDelete=Cascade)
  ### Short title, taken from the first message.
  title: String
  createdAt: DateTime, default=now
  updatedAt: DateTime, default=now
indexes:
  agent_conversation_entity_idx:
    fields: entityId, updatedAt
  agent_conversation_user_idx:
    fields: userId
```

`agent/agent_message.spy.yaml`:

```yaml
### One message in an agent conversation, including hidden tool traffic.
class: AgentMessage
table: agent_message
fields:
  id: UuidValue?, defaultPersist=random_v7
  conversationId: UuidValue, relation(parent=agent_conversation, onDelete=Cascade)
  role: AgentMessageRole
  ### The message text. Empty for an assistant turn that only calls tools.
  content: String
  ### JSON list of OpenAI tool calls the assistant requested, when any.
  toolCallsJson: String?
  ### The tool call this message answers, for role tool.
  toolCallId: String?
  createdAt: DateTime, default=now
indexes:
  agent_message_conversation_idx:
    fields: conversationId, createdAt
```

`agent/agent_proposal.spy.yaml`:

```yaml
### A change the assistant suggests but never makes itself.
class: AgentProposal
table: agent_proposal
fields:
  id: UuidValue?, defaultPersist=random_v7
  userId: UuidValue, relation(parent=serverpod_auth_core_user, onDelete=Cascade)
  entityId: UuidValue, relation(parent=entity, onDelete=Cascade)
  ### The conversation that produced it, when it came from chat.
  conversationId: UuidValue?, relation(parent=agent_conversation, onDelete=SetNull)
  kind: AgentProposalKind
  ### Kind-specific arguments, as a JSON object.
  payloadJson: String
  ### One sentence the user can decide on.
  summary: String
  status: AgentProposalStatus, default=pending
  ### Version of the tax rule pack and guardrails the proposal was made under.
  rulesVersion: String?
  createdAt: DateTime, default=now
  resolvedAt: DateTime?
indexes:
  agent_proposal_entity_status_idx:
    fields: entityId, status
  agent_proposal_user_idx:
    fields: userId, createdAt
```

`agent/agent_usage_record.spy.yaml`:

```yaml
### Token usage and cost of one model call.
class: AgentUsageRecord
table: agent_usage_record
fields:
  id: UuidValue?, defaultPersist=random_v7
  userId: UuidValue, relation(parent=serverpod_auth_core_user, onDelete=Cascade)
  conversationId: UuidValue?, relation(parent=agent_conversation, onDelete=SetNull)
  provider: AgentProvider
  model: String
  promptTokens: int
  ### Prompt tokens served from the provider's cache.
  cachedTokens: int
  completionTokens: int
  ### Cost in micro-dollars. BYO calls are recorded at zero.
  costMicroUsd: int
  createdAt: DateTime, default=now
indexes:
  agent_usage_user_idx:
    fields: userId, createdAt
  agent_usage_conversation_idx:
    fields: conversationId
```

`agent/agent_provider_settings.spy.yaml`:

```yaml
### A user's own OpenAI-compatible provider for the financial assistant.
###
### The API key is encrypted with AES-256-GCM before it reaches the database
### and is never returned to a client.
class: AgentProviderSettings
serverOnly: true
table: agent_provider_settings
fields:
  id: UuidValue?, defaultPersist=random_v7
  userId: UuidValue, relation(parent=serverpod_auth_core_user, onDelete=Cascade)
  ### HTTPS base URL of the provider's OpenAI-compatible API.
  baseUrl: String
  model: String
  ### Base64 AES-GCM ciphertext of the API key, including its MAC tag.
  encryptedApiKey: String
  ### Base64 nonce used for encryptedApiKey.
  nonce: String
  ### The last four characters of the key, for display only.
  keyHint: String
  updatedAt: DateTime, default=now
indexes:
  agent_provider_settings_user_unique_idx:
    fields: userId
    unique: true
```

`agent/mcp/agent_access_token.spy.yaml`:

```yaml
### A personal access token an external agent uses to reach the MCP server.
###
### Only the SHA-256 hash is stored, so a lost token can never be recovered,
### only revoked and replaced.
class: AgentAccessToken
serverOnly: true
table: agent_access_token
fields:
  id: UuidValue?, defaultPersist=random_v7
  userId: UuidValue, relation(parent=serverpod_auth_core_user, onDelete=Cascade)
  ### The user's label for the client, such as "Claude Code".
  name: String
  ### Lowercase hex SHA-256 of the full token.
  tokenHash: String
  ### The token's first 12 characters, for display only.
  tokenPrefix: String
  ### Whether the token may call the assistant's propose tools.
  canPropose: bool
  createdAt: DateTime, default=now
  ### Last time the token authenticated an MCP request.
  lastUsedAt: DateTime?
  ### When the user revoked it. Revoked tokens never authenticate again.
  revokedAt: DateTime?
indexes:
  agent_access_token_hash_unique_idx:
    fields: tokenHash
    unique: true
  agent_access_token_user_idx:
    fields: userId, createdAt
```

### 5.9 Billing (`openbudget_server/lib/src/billing/`)

`EntitlementSource`, `EntitlementStatus` and `SolanaPlanView` are **KEEP**. The three tables gain user foreign keys, and the two the client never receives become `serverOnly`.

`billing/entitlement.spy.yaml`:

```yaml
### A user's paid OpenBudget Plus subscription on one payment rail.
###
### Each rail writes its own row, keyed by the rail's subscription id, so a
### user who pays twice by mistake keeps two rows and the later period wins.
class: Entitlement
table: entitlement
fields:
  id: UuidValue?, defaultPersist=random_v7
  userId: UuidValue, relation(parent=serverpod_auth_core_user, onDelete=Cascade)
  source: EntitlementSource
  ### The rail's subscription id: a Stripe subscription, a RevenueCat
  ### original transaction, or a Solana subscription account address.
  externalId: String
  status: EntitlementStatus
  currentPeriodStart: DateTime
  currentPeriodEnd: DateTime
  createdAt: DateTime, default=now
  updatedAt: DateTime, default=now
indexes:
  entitlement_rail_unique_idx:
    fields: source, externalId
    unique: true
  entitlement_user_idx:
    fields: userId
```

`billing/stripe_customer.spy.yaml`:

```yaml
### Links an OpenBudget user to their Stripe customer for checkout and the
### billing portal.
class: StripeCustomer
serverOnly: true
table: stripe_customer
fields:
  id: UuidValue?, defaultPersist=random_v7
  userId: UuidValue, relation(parent=serverpod_auth_core_user, onDelete=Cascade)
  customerId: String
  createdAt: DateTime, default=now
indexes:
  stripe_customer_user_idx:
    fields: userId
    unique: true
  stripe_customer_customer_idx:
    fields: customerId
    unique: true
```

`billing/solana_billing_challenge.spy.yaml`:

```yaml
### A one-time wallet ownership challenge for a Solana subscription.
class: SolanaBillingChallenge
serverOnly: true
table: solana_billing_challenge
fields:
  id: UuidValue?, defaultPersist=random_v7
  userId: UuidValue, relation(parent=serverpod_auth_core_user, onDelete=Cascade)
  message: String
  expiresAt: DateTime
  usedAt: DateTime?
  createdAt: DateTime, default=now
indexes:
  solana_billing_challenge_user_idx:
    fields: userId
  solana_billing_challenge_message_idx:
    fields: message
    unique: true
```

### 5.10 Request, response and event classes

These classes have no table. Each file lives in the domain directory named in its heading.

#### Entities (`entities/`)

`entities/entity_summary_view.spy.yaml`:

```yaml
### One entity's headline figures for the home screen. `entity.listSummaries`
### returns one per entity, so the home screen loads with one call.
class: EntitySummaryView
fields:
  entity: Entity
  ### The current budget month (yyyymm) in the entity's time zone.
  month: int
  ### Ready to Assign this month in base minor units. Null when the entity
  ### has no on-budget account.
  readyToAssignMinor: int?
  overspentEnvelopeCount: int
  ### Assets plus liabilities in base minor units, at today's rates.
  netWorthMinor: int
  ### False when some account could not be converted; netWorthMinor then
  ### leaves it out.
  netWorthComplete: bool
  ### Transactions this month with an uncategorised outflow line on budget.
  uncategorizedCount: int
  pendingProposalCount: int
  dueRecurringCount: int
```

`entities/entity_changed_event.spy.yaml`:

```yaml
### Tells a subscribed client which part of an entity changed, so it reloads
### only the providers that depend on it.
class: EntityChangedEvent
fields:
  entityId: UuidValue
  scope: ChangeScope
  ### The budget month affected, when the change has one.
  month: int?
  ### The account affected, when the change has one.
  accountId: UuidValue?
```

`entities/change_scope.spy.yaml`:

```yaml
### Which part of an entity an EntityChangedEvent is about.
enum: ChangeScope
serialized: byName
values:
  ### The entity row itself, its settings or its tax profile.
  - entity
  ### Accounts, balances or valuations.
  - accounts
  ### Transactions, transfers or lines. Balances and the plan may also change.
  - transactions
  ### Categories, envelopes, allocations, goals or templates.
  - plan
  ### Ledger accounts, journals or the lock date.
  - ledger
  ### Assistant proposals.
  - proposals
```

#### Envelope plan (`budget/`, a new directory holding `BudgetEndpoint` and `BudgetMonthService`)

`budget/budget_month_view.spy.yaml`:

```yaml
### The whole Plan screen for one month: one call, computed by section 6.4.
class: BudgetMonthView
fields:
  entityId: UuidValue
  ### yyyymm.
  month: int
  ### ISO 4217 base currency every amount here is in.
  currencyCode: String
  summary: BudgetMonthSummary
  ### Every category, hidden ones included, in sortOrder.
  categories: List<Category>
  ### One row per envelope, hidden ones included, in category then envelope
  ### sortOrder.
  envelopes: List<EnvelopeMonthView>
```

`budget/envelope_month_view.spy.yaml`:

```yaml
### One envelope's figures for one month, in base minor units.
class: EnvelopeMonthView
fields:
  envelope: Envelope
  goal: EnvelopeGoal?
  ### Available at the end of last month, floored at 0.
  carryoverMinor: int
  ### Assigned this month.
  allocatedMinor: int
  ### Sum of this month's lines; negative is spending.
  activityMinor: int
  ### carryoverMinor + allocatedMinor + activityMinor. Negative means
  ### overspent.
  availableMinor: int
  ### What the goal still needs this month, from goal_math; 0 when met or
  ### when there is no goal.
  goalUnderfundedMinor: int
```

`budget/budget_month_summary.spy.yaml`:

```yaml
### The Ready to Assign breakdown for one month, in base minor units. Also
### one row of the month-range reports.
class: BudgetMonthSummary
fields:
  ### yyyymm.
  month: int
  ### Inflows this month with no envelope, positive.
  incomeMinor: int
  ### Outflows this month with no envelope, negative or 0.
  uncategorizedMinor: int
  ### FX revaluations this month, signed.
  fxDifferenceMinor: int
  ### Assigned this month.
  allocatedMinor: int
  ### Sum of envelope activity this month; negative is spending.
  activityMinor: int
  ### Overspending at the end of last month, positive. It comes out of this
  ### month's Ready to Assign.
  overspentLastMonthMinor: int
  ### Assigned in months after this one.
  assignedInFutureMinor: int
  ### Money not yet given a job. Negative means more was assigned than exists.
  readyToAssignMinor: int
  ### Sum of envelope availableMinor.
  availableMinor: int
```

`budget/allocation_input.spy.yaml`:

```yaml
### One envelope's new allocation in `budget.setAllocations`.
class: AllocationInput
fields:
  envelopeId: UuidValue
  ### The new total for the month in base minor units. 0 deletes the row.
  allocatedMinor: int
```

#### Transactions (`transactions/`)

`transactions/transaction_input.spy.yaml`:

```yaml
### Everything needed to create or replace a transaction. One shape for the
### app, imports, recurring posting and the assistant.
class: TransactionInput
fields:
  accountId: UuidValue
  ### Calendar date.
  date: DateTime
  ### Signed amount in account minor units.
  amountMinor: int
  ### A manual rate (base per one account-currency unit, exact decimal).
  ### Null uses the market rate for the date.
  fxRate: String?
  payeeId: UuidValue?
  ### Creates or reuses a payee by exact name when payeeId is null.
  payeeName: String?
  description: String, default=''
  memo: String?
  status: TransactionStatus, default=uncleared
  flag: TransactionFlag?
  ### Empty means one line for the whole amount with no envelope; the
  ### payee's rule may then fill the envelope.
  lines: List<TransactionLineInput>
```

`transactions/transaction_line_input.spy.yaml`:

```yaml
### One line of a TransactionInput. Base amounts are always computed on the
### server.
class: TransactionLineInput
fields:
  ### Signed account minor units; the lines must sum to the transaction.
  amountMinor: int
  envelopeId: UuidValue?
  ledgerAccountId: UuidValue?
  taxCategoryCode: String?
  businessUsePercent: int?
  salesTaxMinor: int?
  memo: String?
```

`transactions/transfer_input.spy.yaml`:

```yaml
### A move between two accounts the user owns, possibly in two currencies
### and two entities.
class: TransferInput
fields:
  fromAccountId: UuidValue
  toAccountId: UuidValue
  ### Calendar date of both legs.
  date: DateTime
  ### What left, positive, in the from-account's minor units.
  fromAmountMinor: int
  ### What arrived, positive, in the to-account's minor units. Required
  ### when the currencies differ unless useMarketRate is true; must be null
  ### or equal to fromAmountMinor when they match.
  toAmountMinor: int?
  ### Compute toAmountMinor at the market rate when it is null.
  useMarketRate: bool, default=false
  ### Envelope of the outflow leg. Allowed only when the money leaves the
  ### entity's envelope plan: the from-account is on budget and the
  ### to-account is off budget or in another entity.
  envelopeId: UuidValue?
  memo: String?
  status: TransactionStatus, default=uncleared
```

`transactions/transaction_query.spy.yaml`:

```yaml
### Filters and keyset cursor for `transaction.list`. Rows come newest first,
### ordered by (date desc, id desc).
class: TransactionQuery
fields:
  entityId: UuidValue
  accountId: UuidValue?
  envelopeId: UuidValue?
  payeeId: UuidValue?
  ### Inclusive calendar dates.
  fromDate: DateTime?
  toDate: DateTime?
  status: TransactionStatus?
  ### Only transactions with an uncategorised outflow line on budget.
  uncategorizedOnly: bool, default=false
  ### Case-insensitive match on description, memo and payee name.
  search: String?
  ### 1-200.
  limit: int, default=50
  ### The nextCursor of the previous page.
  cursor: String?
```

`transactions/transaction_page.spy.yaml`:

```yaml
### One page of transactions.
class: TransactionPage
fields:
  items: List<TransactionView>
  ### Opaque cursor for the next page; null on the last page.
  nextCursor: String?
```

`transactions/transaction_view.spy.yaml`:

```yaml
### A transaction with everything a list row or detail screen shows.
class: TransactionView
fields:
  transaction: Transaction
  lines: List<TransactionLine>
  ### ISO 4217 currency of the account.
  accountCurrencyCode: String
  accountName: String
  payeeName: String?
  ### The other leg, when this transaction is part of a transfer.
  transferPeer: TransferPeerView?
```

`transactions/transfer_peer_view.spy.yaml`:

```yaml
### The other leg of a transfer, as seen from one leg.
class: TransferPeerView
fields:
  transferId: UuidValue
  transactionId: UuidValue
  accountId: UuidValue
  accountName: String
  entityId: UuidValue
  ### Signed amount of the other leg in its own account's minor units.
  amountMinor: int
  currencyCode: String
```

`transactions/import_result.spy.yaml`:

```yaml
### What `transaction.importRows` did.
class: ImportResult
fields:
  insertedCount: int
  ### Rows whose externalId already existed on the account.
  skippedDuplicateCount: int
  ### Rows rejected, with their 0-based index and reason.
  errors: List<String>
```

`transactions/reconcile_result.spy.yaml`:

```yaml
### What `transaction.reconcile` found and did.
class: ReconcileResult
fields:
  ### Cleared and reconciled total up to the statement date, before any
  ### adjustment, in account minor units.
  clearedBalanceMinor: int
  ### statementBalanceMinor - clearedBalanceMinor.
  differenceMinor: int
  ### The balanceAdjustment created, when one was asked for and needed.
  adjustmentTransactionId: UuidValue?
  ### Transactions moved from cleared to reconciled. 0 when the difference
  ### was non-zero and no adjustment was asked for.
  reconciledCount: int
```

`accounts/account_balances_view.spy.yaml`:

```yaml
### The balances of one account, in account minor units.
class: AccountBalancesView
fields:
  accountId: UuidValue
  currencyCode: String
  ### account.balanceMinor.
  balanceMinor: int
  ### Cleared and reconciled transactions.
  clearedMinor: int
  unclearedMinor: int
  reportedBalanceMinor: int?
  reportedBalanceAt: DateTime?
  reconciledThroughDate: DateTime?
```

#### Net worth and reports (`reports/`, a new directory)

`reports/net_worth_view.spy.yaml`:

```yaml
### Net worth of a set of entities on one date in one reporting currency.
### Every total is a sum of the same per-account conversions (section 6.5),
### so the breakdowns always add up.
class: NetWorthView
fields:
  ### ISO 4217 reporting currency.
  currencyCode: String
  ### Calendar date the balances and rates are for.
  asOf: DateTime
  ### Non-liability accounts, converted.
  assetsMinor: int
  ### Liability accounts, converted; normally negative.
  liabilitiesMinor: int
  ### assetsMinor + liabilitiesMinor.
  netWorthMinor: int
  ### False when some currency had no rate; its accounts are left out of
  ### the totals and listed in missingCurrencyCodes.
  isComplete: bool
  missingCurrencyCodes: List<String>
  ### True when any rate used is stale.
  hasStaleRates: bool
  currencies: List<NetWorthCurrencyRow>
  entities: List<NetWorthEntityRow>
  accounts: List<NetWorthAccountRow>
```

`reports/net_worth_currency_row.spy.yaml`:

```yaml
### Accounts held in one currency, in that currency and converted.
class: NetWorthCurrencyRow
fields:
  ### ISO 4217 code the accounts are held in.
  currencyCode: String
  ### Sum of balances in this currency's minor units.
  nativeMinor: int
  ### Sum of the converted accounts in the reporting currency; null when
  ### no rate was available.
  convertedMinor: int?
  ### Reporting currency per one unit of this currency, exact decimal.
  fxRate: String?
  fxRateDate: DateTime?
  fxRateSource: FxRateSource?
  isStale: bool
  accountCount: int
```

`reports/net_worth_entity_row.spy.yaml`:

```yaml
### One entity's part of a net worth, in the reporting currency.
class: NetWorthEntityRow
fields:
  entityId: UuidValue
  name: String
  kind: EntityKind
  assetsMinor: int
  liabilitiesMinor: int
  netWorthMinor: int
  isComplete: bool
```

`reports/net_worth_account_row.spy.yaml`:

```yaml
### One account's part of a net worth.
class: NetWorthAccountRow
fields:
  accountId: UuidValue
  entityId: UuidValue
  name: String
  kind: AccountKind
  isLiability: bool
  currencyCode: String
  ### Balance on asOf in account minor units.
  balanceMinor: int
  ### The same in the reporting currency; null when no rate was available.
  convertedMinor: int?
  ### For valuation-sourced accounts: the date of the valuation used.
  valuationDate: DateTime?
```

`reports/net_worth_history_view.spy.yaml`:

```yaml
### Net worth at evenly spaced dates, for a chart.
class: NetWorthHistoryView
fields:
  currencyCode: String
  granularity: NetWorthGranularity
  points: List<NetWorthPoint>
```

`reports/net_worth_point.spy.yaml`:

```yaml
### Net worth on one date, in the reporting currency.
class: NetWorthPoint
fields:
  ### Calendar date: the last day of the period, or today for the last point.
  date: DateTime
  assetsMinor: int
  liabilitiesMinor: int
  netWorthMinor: int
  isComplete: bool
```

`reports/net_worth_granularity.spy.yaml`:

```yaml
### Spacing of net worth history points.
enum: NetWorthGranularity
serialized: byName
values:
  ### Ranges up to 92 days.
  - day
  ### Ranges up to 2 years. Weeks end on Sunday.
  - week
  ### Any range up to 400 months.
  - month
```

`reports/spending_row.spy.yaml`:

```yaml
### One group's spending and income over a month range, in base minor units.
class: SpendingRow
fields:
  ### Envelope, category or payee id; null for the "no envelope" or "no
  ### payee" group.
  groupId: UuidValue?
  name: String
  ### yyyymm, or null when the row covers the whole range.
  month: int?
  ### Sum of negative lines, as a negative number.
  outflowMinor: int
  ### Sum of positive lines.
  inflowMinor: int
  transactionCount: int
```

`reports/report_grouping.spy.yaml`:

```yaml
### How `report.spending` groups its rows.
enum: ReportGrouping
serialized: byName
values:
  - envelope
  - category
  - payee
```

#### Tax (`tax/`)

**`TaxReportView`: CHANGE.** Two fields change; every other field and its comment stays as it is today:

```yaml
### Replaces `entityKind: String`.
entityKind: EntityKind
### Lines converted from another currency at their transaction date. Since
### every line now stores its base amount, this counts lines whose account
### currency differs from the base currency.
convertedEntryCount: int
```

Update the class comment from "for one budget" to "for one entity". `TaxService` reads `transaction_line.baseAmountMinor` and no longer converts anything itself.

#### Exceptions (`exceptions/`)

**`FxRateUnavailableException`: NEW. `TaxRateUnavailableException`: DROP.** `exceptions/fx_rate_unavailable_exception.spy.yaml`:

```yaml
### Thrown when a write needs an exchange rate that the server does not have.
### The app answers by asking the user for a manual rate.
exception: FxRateUnavailableException
fields:
  message: String, default='Exchange rate not available'
  fromCurrencyCode: String
  toCurrencyCode: String
  ### Calendar date the rate was needed for.
  date: DateTime
```

## 6. Server-side calculations

All SQL below is Postgres, run through `session.db.unsafeQuery` or `unsafeExecute` with `QueryParameters.named`. Serverpod column names are camelCase, so they are quoted. `"transaction"` is always quoted. `@entityId` and the other `@` names are named parameters.

### 6.0 Helpers to add to `openbudget_core`

| Helper                                                                                                                                                       | File                               | Contract                                                                                                                                                                |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `convertMinorUnits` (fix)                                                                                                                                    | `ledger/exchange_rate.dart`        | Round half up on the absolute value, then reapply the sign (section 3, item 19).                                                                                        |
| `ExactDecimal.divide(ExactDecimal other, {int significantDigits = 12})`                                                                                      | `ledger/exchange_rate.dart`        | Exact quotient rounded half up to `significantDigits`, as a new `ExactDecimal` with a power-of-ten denominator, so its `toString()` is a plain decimal.                 |
| `ExactDecimal.fromDouble(double value)`                                                                                                                      | `ledger/exchange_rate.dart`        | Only for provider JSON numbers: `value.toStringAsPrecision(15)`, exponent expanded, trailing zeros trimmed. Returns null for zero, negative, NaN and infinity.          |
| `crossRate({required ExactDecimal fromPerUsd, required ExactDecimal toPerUsd})`                                                                              | `ledger/exchange_rate.dart`        | `toPerUsd.divide(fromPerUsd)`: target units per one source unit, 12 significant digits.                                                                                 |
| `impliedRate({required int fromMinor, required int toMinor, required int fromExponent, required int toExponent})`                                            | `ledger/exchange_rate.dart`        | `                                                                                                                                                                       |
| `splitBaseAmounts({required List<int> lineAmounts, required int baseTotal, required ExactDecimal rate, required int fromExponent, required int toExponent})` | `money/split.dart`                 | Converts each line, then adds `baseTotal − Σ converted` to the line with the largest absolute amount (the first one on a tie). Returns the base amounts in input order. |
| `MonthKey`                                                                                                                                                   | `budgeting/month_key.dart`         | `fromDate(DateTime)`, `toFirstDate(int)`, `toLastDate(int)`, `next`, `previous`, `isValid` (yyyy 1900-9999, mm 1-12).                                                   |
| `CivilDate`                                                                                                                                                  | `time/civil_date.dart`             | `civilDate(y, m, d)` builds `DateTime.utc(y, m, d)`; `isCivilDate` checks UTC midnight.                                                                                 |
| `AccountKindRules`                                                                                                                                           | `accounts/account_kind_rules.dart` | The table in section 5.2.                                                                                                                                               |
| `goal_math.dart`                                                                                                                                             | `budgeting/goal_math.dart`         | `underfundedMinor(goal, month, carryoverMinor, allocatedMinor, activityMinor)`, moved from the app's `budget_goals_provider.dart` unchanged in behaviour.               |
| `nextOccurrence(RecurrenceFrequency, DateTime anchor, DateTime after)`                                                                                       | `budgeting/recurrence.dart`        | Month-end safe: the 31st becomes the last day of shorter months, and the next month returns to the anchor day.                                                          |
| `defaultFiscalYearEnd(String countryCode, EntityKind kind)`                                                                                                  | `tax/fiscal_year.dart`             | The defaults in section 5.1.                                                                                                                                            |

### 6.1 The transaction write path

`TransactionWriter` (`lib/src/transactions/transaction_writer.dart`) is the only code that inserts, updates or deletes `transaction`, `transaction_line` and `transfer` rows. Plaid sync, imports, recurring posting, wallets, the assistant's applied proposals and the endpoints all call it. Every method runs inside `session.db.transaction`, or joins the caller's transaction when one is passed.

**`create(TransactionInput input) → TransactionView`:**

1. Load the account with `lockMode: LockMode.forUpdate`. Call `EntityAccess.requireOwned(account.entityId)`. A closed account rejects new transactions.
2. Check the date: it must be a civil date, no later than the entity's today plus one day (a margin for travel and time zones), and later than the lock date when the entity is in ledger mode.
3. Check `|amountMinor| ≤ 2^53 − 1`.
4. Resolve the rate (section 6.3):
   - If the account currency is the base currency, use `('1', date, identity)`.
   - If `input.fxRate` is set, use it with source `manual` and the transaction date.
   - Otherwise call `FxService.rateOn(accountCurrency, baseCurrency, date)`. If there is no rate, throw `FxRateUnavailableException`.
5. Compute `baseAmountMinor = convertMinorUnits(amountMinor, rate, accountExponent, baseExponent)`.
6. Build the lines:
   - Empty `lines` means one line for the whole amount.
   - If every line has a null envelope, the account is on budget, the amount is negative and the payee has an enabled `transaction_rule`, apply the rule's envelope to the single line.
   - Check that `Σ line.amountMinor == amountMinor` and apply the line rules in section 5.3.
   - Compute the base amounts with `splitBaseAmounts`.
7. Resolve the payee. When `payeeName` is set, upsert on `(entityId, name)` with `INSERT ... ON CONFLICT DO NOTHING`, then select.
8. Insert the transaction, then insert the lines in one `insert` call.
9. `AccountBalanceService.applyDelta(accountId, amountMinor)` (section 6.2).
10. After commit, post `EntityChangedEvent(transactions, month, accountId)`.

**`update(UuidValue id, TransactionInput input)`:**

1. Lock the old account and, if it changes, the new one, in UUID order.
2. A `reconciled` transaction rejects changes to the date, amount, account and lines, but may change status, flag, memo, description and payee.
3. The new account must be in the same entity. Moving a transaction between entities is a delete plus a create.
4. Re-resolve the rate only when the date, amount, account or manual rate changed. A manual rate is compared as an exact rational, so `0.8` and `0.80` are the same rate. Otherwise keep the stored `fxRate`, `fxRateDate` and `fxRateSource`, so editing a memo never re-prices history.
5. Replace the lines: delete them all, then insert the new set. A line-only edit keeps the stored `baseAmountMinor`, and `splitBaseAmounts` distributes that total across the replacement lines at the stored rate.
6. Apply the balance deltas: `−old.amountMinor` to the old account and `+new.amountMinor` to the new one. That is one delta of `new − old` when the account is unchanged. A net delta may be twice the single-amount bound; the resulting balance is what must stay within it.
7. In ledger mode, a change to the date, amount, account or lines increments `revision`, and writes an `audit_event` (`transactionEdited`) with the before state.
8. A transfer leg cannot change date, amount, account or lines through `update`. Use `updateTransfer`, which rewrites both legs.
9. After commit, post `EntityChangedEvent(transactions, month, accountId)` for the new month and account, and for the old month and account when either moved. A rolled-back write posts nothing.

**`delete(UuidValue id)`:**

1. A `reconciled` transaction must be set back to `cleared` first. If the transaction is a transfer leg, delete both legs.
2. Lock the affected accounts and apply `−amountMinor` to each.
3. In ledger mode, write `audit_event` (`transactionDeleted`) with the before state, including the lines.
4. Delete the transaction rows. Their lines and the transfer row cascade.

**`updateLines(UuidValue id, List<TransactionLineInput> lines)`** is `update` with the header unchanged. `tax.setLineTax` and the assistant's tax proposals use it.

**Bulk paths:**

- `importRows(accountId, List<ImportRow>)` runs the same per-row steps in one database transaction. It inserts with `INSERT ... ON CONFLICT ("accountId", "externalId") DO NOTHING RETURNING id`, then inserts lines for the returned rows only, and applies one balance delta for the sum of what was inserted.
  - The account is locked once and every row follows the `create` rules: ownership, a `transactions` balance source, an open account, an unarchived entity, the civil-date bound, the ledger period lock, safe non-zero amounts, payee rules and the ordinary market FX rate. Ownership, source, closed and archived failures reject the whole call; a row that fails the date, amount, external-id, rate or payee checks is skipped and reported in `errors` as `"<0-based index>: <reason>"`. The valid rows commit together. Empty `rows` is a no-op after the ownership check, and one call accepts at most 1000 rows.
  - A supplied `externalId` is trimmed, stored as given after trimming, and must be 1-255 printable characters. When null it is derived as `csv:<sha256(yyyy-mm-dd|amountMinor|description|n)>`, where n counts identical `(date, amount, description)` rows earlier in the same call. Re-importing a file derives the same ids, and several identical rows in one file stay distinct. Ids are unique per account; the unique index is the final race guard.
  - A row whose id already exists on the account, repeats an id already claimed in this call, or loses a concurrent insert is a duplicate: it skips payload validation and gets no lines, payee, balance movement or event. A rejected row does not claim its id, so a later row with the same id can still insert.
  - Imports are ordinary `uncleared` postings: never reconciled, transferred, or given server metadata. Payees and change events exist only for inserted rows; events publish after commit, one per distinct affected month.
- Plaid sync uses the same path. Pending Plaid transactions are skipped until they post, because pending ids change.

### 6.2 Account balance maintenance and verification

`AccountBalanceService` (`lib/src/accounts/account_balance_service.dart`) is the only writer of `account.balanceMinor`.

**Transactions-sourced accounts**, inside the caller's transaction:

```sql
UPDATE account
SET "balanceMinor" = "balanceMinor" + @delta, "updatedAt" = now() AT TIME ZONE 'UTC'
WHERE id = @accountId AND "balanceSource" = 'transactions'
RETURNING "balanceMinor";
```

If no row comes back, the account is valuation-sourced, which is a programming error: throw `StateError`. If the result exceeds ±(2^53 − 1), throw `ValidationException`, which rolls the transaction back. The increment is atomic, and because writers lock the account row first, two concurrent writers never lose an update.

**Valuation-sourced accounts.** After any insert, update or delete on `account_valuation`:

```sql
UPDATE account a
SET "balanceMinor" = COALESCE((
      SELECT v."valueMinor" FROM account_valuation v
      WHERE v."accountId" = a.id
      ORDER BY v."valuationDate" DESC
      LIMIT 1), 0),
    "updatedAt" = now() AT TIME ZONE 'UTC'
WHERE a.id = @accountId AND a."balanceSource" = 'valuations';
```

Valuation dates may not be later than the entity's today, so "latest" never means a future value.

**Nightly verification** (`BalanceVerifyFutureCall`, 03:00 UTC):

```sql
SELECT a.id, a."entityId", a."balanceMinor" AS cached, s.actual
FROM account a
JOIN LATERAL (
  SELECT CASE a."balanceSource"
    WHEN 'transactions' THEN
      (SELECT COALESCE(SUM(t."amountMinor"), 0) FROM "transaction" t WHERE t."accountId" = a.id)
    ELSE
      (SELECT COALESCE((SELECT v."valueMinor" FROM account_valuation v
                        WHERE v."accountId" = a.id
                        ORDER BY v."valuationDate" DESC LIMIT 1), 0))
  END AS actual
) s ON true
WHERE a."balanceMinor" <> s.actual;
```

For each row, the job sets `balanceMinor = actual` under a row lock, writes `audit_event` (`balanceRepaired`, payload `{cached, actual}`) and logs at error level. Any repair is a bug in a writer, so the test suite runs this query after every write test and expects no rows (section 10).

**Cleared balances**, for `account.getBalances`:

```sql
SELECT status, COALESCE(SUM("amountMinor"), 0) AS total
FROM "transaction" WHERE "accountId" = @accountId GROUP BY status;
```

### 6.3 FX rates, conversion and transfers

**Daily rates.** `FxRefreshFutureCall` runs hourly:

1. It fetches the provider's latest USD-based rates.
2. It upserts one row per supported currency for today's UTC date, plus `USD = '1'`:

   ```sql
   INSERT INTO fx_rate ("rateDate", "currencyCode", rate, provider, "fetchedAt")
   VALUES ... ON CONFLICT ("currencyCode", "rateDate")
   DO UPDATE SET rate = EXCLUDED.rate, "fetchedAt" = EXCLUDED."fetchedAt";
   ```

3. Rates convert with `ExactDecimal.fromDouble`. A currency whose rate fails to parse is skipped and logged; it never stores 0.

**Rate lookup.** `FxService.rateOn(from, to, date) → FxQuote?`:

1. If `from == to`, return `('1', date, identity)`.
2. Load the USD rate of `from` and of `to` on the latest `rateDate ≤ date`, looking back at most 7 days:

   ```sql
   SELECT DISTINCT ON ("currencyCode") "currencyCode", rate, "rateDate", "fetchedAt"
   FROM fx_rate
   WHERE "currencyCode" IN (@from, @to) AND "rateDate" <= @date AND "rateDate" > @date - interval '7 days'
   ORDER BY "currencyCode", "rateDate" DESC;
   ```

3. If either is missing, enqueue `FxBackfillFutureCall(date)`, which fetches the provider's historical endpoint for that date and upserts it. Then return null.
4. Return `crossRate(fromPerUsd, toPerUsd)`, with `rateDate` the earlier of the two rows' dates and source `market`.

`rateOn` caches results in Serverpod's local cache for 10 minutes, keyed by `from|to|date`.

**Staleness.** A rate is stale when its `rateDate` is more than 2 days before the date asked for, or, for today's rate, when its `fetchedAt` is more than 48 hours old.

**Converting a stored amount.** `baseAmountMinor = convertMinorUnits(amountMinor, rate, exponent(from), exponent(to))`, with the rounding fix from section 3, item 19. The stored `fxRate` is the 12-significant-digit rate actually used, so `convertMinorUnits` on the stored row reproduces the stored base amount for every source except `implied`.

**Transfers.** `TransactionWriter.createTransfer(TransferInput)`:

1. Lock both accounts in UUID order. Both must be owned by the caller and different. They may be in different entities.
2. Work out the amounts:
   - Same currency: `toAmount = fromAmount`. A different `toAmountMinor` is rejected.
   - Different currencies: `toAmount` is `toAmountMinor`, or the market conversion when `useMarketRate` is true. Otherwise the input is rejected with `ValidationException`.
3. Work out the base amounts, where `B` is the entity's base currency:
   - **Same entity, one leg in `B`:** that leg is `identity`. The other leg's base amount is the exact negation of it, with source `implied` and `fxRate = impliedRate(...)`.
   - **Same entity, neither leg in `B`:** the from leg converts at market (or fails with `FxRateUnavailableException`). The to leg's base is the negation of that, with source `implied`.
   - **Different entities:** each leg converts into its own entity's base independently, as in `create`.

   So a transfer inside one entity always nets to zero in base, and moving money between your own accounts never creates or destroys budget money.
4. Lines:
   - The to leg has one line with no envelope.
   - The from leg has one line with `envelopeId` from the input. An envelope is allowed only when the from account is on budget and the money leaves the envelope plan: the to account is off budget or in another entity.
   - When the from account is on budget and the to account is too, in the same entity, any envelope is rejected.
5. Insert both transactions and the `transfer` row, then apply both balance deltas.

An internal transfer is one whose two legs are in the same entity and both on budget. Section 6.4 leaves its lines out of the plan entirely.

### 6.4 Envelope month and Ready to Assign

`BudgetMonthService.month(entityId, month) → BudgetMonthView` runs three queries and a fold. It never reads all transactions.

**Query 1: envelope activity by month, up to and including `month`.**

```sql
SELECT l."envelopeId",
       (EXTRACT(YEAR FROM t."date")::int * 100 + EXTRACT(MONTH FROM t."date")::int) AS month,
       SUM(l."baseAmountMinor") AS activity
FROM "transaction" t
JOIN transaction_line l ON l."transactionId" = t.id
WHERE t."entityId" = @entityId
  AND t."date" < @firstDayOfNextMonth
  AND l."envelopeId" IS NOT NULL
GROUP BY 1, 2;
```

**Query 2: every allocation of the entity**, past and future, which is small because rows are sparse:

```sql
SELECT "envelopeId", "month", "allocatedMinor" FROM monthly_allocation WHERE "entityId" = @entityId;
```

**Query 3: money with no envelope on budget, by month and kind, excluding internal transfers.**

```sql
SELECT (EXTRACT(YEAR FROM t."date")::int * 100 + EXTRACT(MONTH FROM t."date")::int) AS month,
       t.kind,
       SUM(CASE WHEN l."baseAmountMinor" > 0 THEN l."baseAmountMinor" ELSE 0 END) AS inflow,
       SUM(CASE WHEN l."baseAmountMinor" < 0 THEN l."baseAmountMinor" ELSE 0 END) AS outflow
FROM "transaction" t
JOIN account a ON a.id = t."accountId" AND a."onBudget"
JOIN transaction_line l ON l."transactionId" = t.id AND l."envelopeId" IS NULL
LEFT JOIN transfer tf ON t.id IN (tf."fromTransactionId", tf."toTransactionId")
LEFT JOIN "transaction" peer
  ON peer.id = CASE WHEN tf."fromTransactionId" = t.id THEN tf."toTransactionId" ELSE tf."fromTransactionId" END
LEFT JOIN account pa ON pa.id = peer."accountId"
WHERE t."entityId" = @entityId
  AND t."date" < @firstDayOfNextMonth
  AND NOT COALESCE(pa."onBudget" AND peer."entityId" = t."entityId", false)
GROUP BY 1, 2;
```

`transaction_entity_date_idx` serves all three queries, together with the line and transfer indexes.

**The fold** (`openbudget_core/lib/src/budgeting/envelope_fold.dart`, pure Dart, so it is unit-tested without a database). Let `M0` be the earliest month in any query result, or `month` itself when there are none. For each envelope `e`, and each month `k` from `M0` to `month`:

```
carryover(e, M0) = 0
available(e, k)  = carryover(e, k) + allocated(e, k) + activity(e, k)
overspent(e, k)  = max(−available(e, k), 0)
carryover(e, k+1) = max(available(e, k), 0)
```

Cash overspending does not carry into the envelope. It comes out of the next month's Ready to Assign instead.

For the month `m` asked for:

```
flow(k)               = Σ inflow(k, kind) + Σ outflow(k, kind) over all kinds   (query 3)
allocatedThrough(m)   = Σ allocated(e, k) for k ≤ m
assignedInFuture(m)   = Σ allocated(e, k) for k > m
overspentBefore(m)    = Σ overspent(e, k) for k < m
readyToAssign(m)      = Σ flow(k) for k ≤ m − allocatedThrough(m) − overspentBefore(m) − assignedInFuture(m)
```

The summary fields for month `m`:

- `incomeMinor`: query 3 inflows at `m`, kinds other than `fxRevaluation`.
- `uncategorizedMinor`: query 3 outflows at `m`, kinds other than `fxRevaluation`.
- `fxDifferenceMinor`: query 3 at `m` for `fxRevaluation`, inflow plus outflow.
- `allocatedMinor`: `Σ allocated(e, m)`.
- `activityMinor`: `Σ activity(e, m)`.
- `overspentLastMonthMinor`: `Σ overspent(e, m − 1)`.
- `assignedInFutureMinor`: `assignedInFuture(m)`.
- `availableMinor`: `Σ available(e, m)`.

Hidden envelopes are included in every sum.

**Invariant**, asserted in tests after every write:

```
Σ_e available(e, m) + readyToAssign(m) + assignedInFuture(m)
  = Σ baseAmountMinor of lines on on-budget accounts of the entity dated before firstDayOfNextMonth(m),
    excluding internal transfers
```

The proof is direct: `Σ available(e, m) = allocatedThrough + Σ activity + overspentBefore`, because `carryover = available + overspent` at each step. Add `readyToAssign` and `assignedInFuture` and only `Σ activity + Σ flow` remains, which is the right-hand side. Internal transfers net to zero in base (section 6.3), so the right-hand side also equals the total book balance in base of the entity's on-budget accounts.

**Writing allocations.** `setAllocations(entityId, month, List<AllocationInput>)` runs in one transaction:

- `allocatedMinor == 0` runs `DELETE ... WHERE "envelopeId" = @e AND month = @m`.
- Any other value runs `INSERT ... ON CONFLICT ("envelopeId", month) DO UPDATE SET "allocatedMinor" = EXCLUDED."allocatedMinor", "updatedAt" = now()`.
- It returns the new `BudgetMonthView`.

Built on `setAllocations`:

- `moveMoney`: two inputs, from and to.
- `copyMonth`: copies the previous month's rows.
- `applyTemplate`: applies the template's lines.
- Auto-assign and cover-overspending: computed on the client from the month view, then sent as one `setAllocations` call.

**Caching.** None at first: three indexed aggregates over one entity stay well under 50 ms for ten years of a household's data. If profiling shows otherwise, add an `envelope_month_activity` cache keyed `(envelopeId, month)`, maintained by `TransactionWriter` (section 11). The schema does not need it now.

### 6.5 Net worth now

`NetWorthService.current(userId, entityIds?, currencyCode?, asOf?) → NetWorthView`:

1. **Scope.** If `entityIds` is null, use the user's entities with `includeInNetWorth` and no `archivedAt`. Otherwise use the listed ones, each checked with `requireOwned`.
2. **Reporting currency.** `R` is `currencyCode`, or `user_settings.reportingCurrencyCode`.
3. **As-of date.** `asOf` is null, or today in the first entity's time zone, for current net worth.
4. **Atoms.** Each atom is one account with a non-zero balance, closed accounts included only when they are non-zero. When `asOf` is today, the balance is the cached `account.balanceMinor`. For a past `asOf`, use the history method (section 6.6) with a single point.
5. **Rates.** Group the atoms by currency `C`. For each `C`, call `FxService.rateOn(C, R, asOf)` once. With no rate, the currency is missing.
6. **Convert each atom once.** `converted = convertMinorUnits(balanceMinor, rate(C), exponent(C), exponent(R))`. Atoms in a missing currency get `convertedMinor = null`.
7. **Aggregate.** Each total is a sum of the converted atoms, so they all agree exactly:
   - Assets: atoms where `!isLiability(kind)`.
   - Liabilities: atoms where `isLiability(kind)`.
   - Net worth: assets plus liabilities.
   - Entity rows: sums by entity.
   - Currency rows: `nativeMinor` is the sum of the raw balances, and `convertedMinor` is the sum of the converted atoms.

   An overpaid card is a liability account with a positive balance, which reduces liabilities. That is correct.
8. **Completeness.** `isComplete = missingCurrencyCodes.isEmpty`. `hasStaleRates` is true if any currency row is stale.

There are at most three queries: entities, accounts, and the latest valuation date for valuation accounts. Rates come from the cache, so no transactions are read.

`EntitySummaryView.netWorthMinor` is the same computation for a single entity in its base currency.

### 6.6 Net worth history

`NetWorthService.history(userId, entityIds?, currencyCode?, fromDate, toDate, granularity) → NetWorthHistoryView`:

1. **Points.** Each point is the last day of each day, week (Sunday) or month in `[fromDate, toDate]`, plus `toDate` itself when it is not on a period end. Ranges are limited to 92 days for `day`, 2 years for `week` and 400 months for `month`, and to at most 400 points. Anything larger is a `ValidationException`.
2. **Transactions-sourced balances.** The opening balance before `fromDate`, plus daily movements in the range:

   ```sql
   SELECT t."accountId", NULL::timestamp AS day, SUM(t."amountMinor") AS amount
   FROM "transaction" t
   WHERE t."accountId" = ANY(@accountIds) AND t."date" < @fromDate
   GROUP BY t."accountId"
   UNION ALL
   SELECT t."accountId", t."date", SUM(t."amountMinor")
   FROM "transaction" t
   WHERE t."accountId" = ANY(@accountIds) AND t."date" >= @fromDate AND t."date" <= @toDate
   GROUP BY t."accountId", t."date";
   ```

   Walk the points in date order, keeping a running balance per account. `transaction_account_date_idx` serves both halves.
3. **Valuation-sourced balances.** The last valuation before `fromDate`, plus all valuations in the range:

   ```sql
   SELECT DISTINCT ON ("accountId") "accountId", "valuationDate", "valueMinor"
   FROM account_valuation WHERE "accountId" = ANY(@valuationAccountIds) AND "valuationDate" < @fromDate
   ORDER BY "accountId", "valuationDate" DESC
   UNION ALL
   SELECT "accountId", "valuationDate", "valueMinor"
   FROM account_valuation WHERE "accountId" = ANY(@valuationAccountIds)
     AND "valuationDate" BETWEEN @fromDate AND @toDate;
   ```

   (Wrap the first half in parentheses so `ORDER BY` applies to it alone.) Each point takes the latest valuation on or before its date, or 0.
4. **Rates.** Read every `fx_rate` row for the needed currencies and `R` from `fromDate − 7 days` to `toDate`, in one query. For each point and currency, take the latest row on or before the point, then cross the rates as in section 6.3. A missing rate marks the point incomplete, leaves the currency out, and enqueues a backfill for that date.
5. **Aggregate.** Convert each account at each point, then sum, exactly as in section 6.5.

The cost is four queries for any range, and at most 400 points times the number of accounts in conversions. Nothing is snapshotted, so history follows edits, late imports and corrected valuations without a rebuild. History for an account starts at its first transaction or valuation.

### 6.7 Reconciliation

`TransactionWriter.reconcile(accountId, statementDate, statementBalanceMinor, createAdjustment) → ReconcileResult` runs in one database transaction:

1. Lock the account. It must be transactions-sourced, and `statementDate` must be a civil date no later than today.
2. Sum what has cleared:

   ```sql
   SELECT COALESCE(SUM("amountMinor"), 0) FROM "transaction"
   WHERE "accountId" = @accountId AND status IN ('cleared', 'reconciled') AND "date" <= @statementDate;
   ```

3. `difference = statementBalanceMinor − cleared`.
4. If `difference ≠ 0` and `createAdjustment` is false, return `(cleared, difference, null, 0)` and change nothing.
5. If `difference ≠ 0` and `createAdjustment` is true, call `create`:
   - kind `balanceAdjustment`, dated `statementDate`;
   - amount `difference` in the account currency, at the account's rate for that date;
   - status `cleared`, one line with no envelope.

   On a budget account the adjustment flows into Ready to Assign, so the user sees it and can assign it.
6. Mark the cleared transactions reconciled, in one statement:

   ```sql
   UPDATE "transaction" SET status = 'reconciled', "updatedAt" = now() AT TIME ZONE 'UTC'
   WHERE "accountId" = @accountId AND status = 'cleared' AND "date" <= @statementDate;
   ```

7. Set `account.reconciledThroughDate = statementDate`.

`account.reportedBalanceMinor`, when present, pre-fills the statement balance in the app. It is never applied automatically.

### 6.8 FX revaluation and ledger posting rules

**Book value against market value.** For a transactions-sourced account in currency `C ≠ B`:

- the book value is `book = Σ baseAmountMinor` of its transactions (dated on or before the as-of date);
- the market value is `market = convert(balance, rate(C → B, asOf))`.

The plan and the books use book values, and net worth uses market values.

`FxRevaluationService.revalue(entityId, asOf)`, for each such account where `market − book ≠ 0`:

- It creates one `fxRevaluation` transaction dated `asOf`, with `amountMinor = 0`, `baseAmountMinor = market − book`, `fxRate` the closing rate and source `market`.
- It has one line with no envelope.
- In ledger mode, the line's `ledgerAccountId` is the `realisedFx` account when the account's balance is 0, and the `unrealisedFx` account otherwise.
- It skips accounts with a revaluation already dated `asOf`, so it is idempotent.

Which accounts it covers:

- **Envelope mode:** on-budget foreign-currency accounts only. It runs automatically on the first day of each month for the previous month's last day (`FxRevaluationFutureCall`), so the plan never drifts more than a month from what the money is worth. The difference shows as `fxDifferenceMinor` in Ready to Assign (Q6).
- **Ledger mode:** every foreign-currency transactions-sourced account. It runs at each period end the user closes, and on demand.

**Deviation from the ledger skill.** The skill posts unrealised revaluations and auto-reverses them on day 1. This design does not reverse, because the revaluation moves the book value itself, so each period's P&L carries only that period's movement. Realised and unrealised differences are told apart by whether the account was emptied. Exact settlement-time realisation per document arrives with invoices and bills (section 11). Valuation-sourced accounts are never revalued, because their values are already market values.

**Posting rules for the follow-up `JournalPoster`.** Each transaction revision in a ledger-mode entity posts one journal with `source = transaction`, `sourceTransactionId` and `sourceRevision`, dated the transaction date. Before posting a new revision, the poster reverses the previous revision's journal. A delete reverses the last journal.

| Line of the journal             | Account                                                                                  | Amounts                                                                                                                                                                                                                           |
| ------------------------------- | ---------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Bank side                       | `account.ledgerAccountId`                                                                | One line for the whole transaction. A positive amount is a debit, a negative one a credit, in the account currency and in base.                                                                                                   |
| One per transaction line        | `line.ledgerAccountId`, else `envelope.defaultLedgerAccountId`, else the `suspense` role | The opposite side of the bank, with the line's `amountMinor` and `baseAmountMinor`. When a line has `salesTaxMinor`, split it: the net to the coded account, and the tax to `vatControl`, each converted with `splitBaseAmounts`. |
| Transfer legs inside one entity | the `bankClearing` role in place of the line account                                     | The two journals clear each other.                                                                                                                                                                                                |
| `fxRevaluation`                 | the bank account and `unrealisedFx` or `realisedFx`                                      | Base amounts only. The transaction-currency amounts are 0 (journal source `revaluation`).                                                                                                                                         |
| `openingBalance`                | the `openingBalanceEquity` role                                                          | As for a normal line.                                                                                                                                                                                                             |

### 6.9 Reports

`ReportService.spending(entityId, fromMonth, toMonth, grouping, byMonth) → List<SpendingRow>` is one aggregate over on-budget lines, excluding internal transfers. It uses the same joins as query 3 in section 6.4, without the `envelopeId IS NULL` filter, grouped by:

- `l."envelopeId"` for `envelope`;
- `e."categoryId"` (with a join to `envelope`) for `category`;
- `t."payeeId"` for `payee`;
- plus the month when `byMonth` is true.

The two sums are `SUM(CASE WHEN l."baseAmountMinor" < 0 THEN l."baseAmountMinor" ELSE 0 END)` and the same for `> 0`, plus `COUNT(DISTINCT t.id)`. Names come from a second lookup.

`ReportService.monthSummaries(entityId, fromMonth, toMonth) → List<BudgetMonthSummary>` runs the section 6.4 fold once, up to `toMonth`, and returns the summary of each month in the range. That is one call for the reports screen in place of one per month.

`ReportService.ageOfMoney(entityId) → int?` keeps today's FIFO definition: each outflow is matched to the oldest unspent inflow, and the result is the mean age in days of the last 10 outflows' money. It now runs on base amounts of on-budget lines, excluding internal transfers. Inflows are lines with no envelope and a positive amount. Outflows are lines with a negative amount and any envelope. It reads at most the last 365 days.

### 6.10 Indexes and payload rules

- Every query above is served by an index declared in section 5:
  - `transaction_entity_date_idx` for the plan, reports and lists;
  - `transaction_account_date_idx` for history, balances and reconciliation;
  - `transaction_line_transaction_idx` and `transaction_line_envelope_idx` for lines;
  - the transfer unique indexes;
  - `monthly_allocation_entity_month_idx` for allocations;
  - `fx_rate_currency_date_unique_idx` for rate lookups;
  - `account_valuation_account_date_unique_idx` for valuations.
- No endpoint returns an unbounded list of transactions. `transaction.list` pages by `(date, id)` keyset with a limit of at most 200. The cursor is `base64url("<yyyy-mm-dd>|<uuid>")`, and the next page's predicate is `("date", id) < (@date, @id)`.
- Per-entity lists that are naturally small (accounts, categories, envelopes, payees, rules, recurring transactions, ledger accounts) are returned whole.

## 7. Endpoint surface

General rules:

- Every `UuidValue budgetId` parameter becomes `UuidValue entityId`. A method not listed below changes only that, and its return type follows the renamed models.
- Every money parameter is `int ...Minor`. Every month parameter is `int month` (yyyymm). Every date parameter is a civil date.
- Each method that writes posts an `EntityChangedEvent` after its database transaction commits.
- All endpoints keep `requireLogin => true`, except the existing webhooks, which are web routes rather than endpoints.

### 7.1 New and changed endpoints

**`EntityEndpoint`** (`entity`, in `entities/`). It replaces `BudgetEndpoint`.

```dart
Future<Entity> create(Session session, String name, EntityKind kind, String countryCode,
    String baseCurrencyCode, String timeZone,
    {int? fiscalYearEndMonth, int? fiscalYearEndDay, UuidValue? linkedPersonalEntityId});
Future<List<Entity>> list(Session session, {bool? includeArchived});
Future<List<EntitySummaryView>> listSummaries(Session session);
Future<Entity> get(Session session, UuidValue entityId);
Future<Entity> update(Session session, UuidValue entityId,
    {String? name, String? baseCurrencyCode, String? timeZone, int? fiscalYearEndMonth,
     int? fiscalYearEndDay, bool? includeInNetWorth, UuidValue? linkedPersonalEntityId,
     bool? clearLinkedPersonalEntity, int? sortOrder});
Future<Entity> archive(Session session, UuidValue entityId);
Future<Entity> unarchive(Session session, UuidValue entityId);
/// Deletes the entity and everything under it. confirmName must equal the
/// entity's name exactly.
Future<void> delete(Session session, UuidValue entityId, String confirmName);
Future<String> exportData(Session session, UuidValue entityId);
```

`create` inserts the entity and, in the same transaction, creates the caller's `user_settings` row if it is missing. It seeds no categories, as today.

When `fiscalYearEnd*` is null, it uses `defaultFiscalYearEnd`. When `kind` is `company`, `includeInNetWorth` defaults to false.

**`EntityStreamEndpoint`** (`entityStream`). It replaces `BudgetStreamEndpoint`.

```dart
Stream<EntityChangedEvent> watch(Session session, UuidValue entityId);
```

It checks ownership, then returns `session.messages.createStream<EntityChangedEvent>('entity:$entityId')`. Writers call `session.messages.postMessage('entity:$id', event, global: true)`, so events reach clients connected to other server instances through Redis. `BudgetRealtimeNotifier`'s in-process `StreamController` is deleted.

**`SettingsEndpoint`** (`settings`, NEW, in `settings/`).

```dart
Future<UserSettings> get(Session session);
Future<UserSettings> setReportingCurrency(Session session, String currencyCode);
```

**`AccountEndpoint`** (`account`).

```dart
/// openingBalanceMinor becomes an openingBalance transaction (transactions
/// source) or the first valuation (valuations source), dated openingDate or
/// the entity's today.
Future<Account> create(Session session, UuidValue entityId, String name, AccountKind kind,
    String currencyCode,
    {AccountBalanceSource? balanceSource, bool? onBudget, int? openingBalanceMinor,
     DateTime? openingDate, UuidValue? institutionId, String? note});
Future<List<Account>> list(Session session, UuidValue entityId);
/// Every account in every entity the user owns, for pickers that cross entities.
Future<List<Account>> listAll(Session session);
Future<Account> get(Session session, UuidValue accountId);
Future<Account> update(Session session, UuidValue accountId,
    {String? name, AccountKind? kind, bool? onBudget, UuidValue? institutionId,
     bool? clearInstitution, String? note, int? sortOrder});
Future<List<Account>> reorder(Session session, UuidValue entityId, List<UuidValue> accountIds);
/// Requires balanceMinor == 0.
Future<Account> close(Session session, UuidValue accountId);
Future<Account> reopen(Session session, UuidValue accountId);
/// Deletes the account with its transactions and valuations. Rejected in
/// ledger mode once any journal line uses its ledger account.
Future<void> delete(Session session, UuidValue accountId);
Future<AccountBalancesView> getBalances(Session session, UuidValue accountId);
Future<List<AccountValuation>> listValuations(Session session, UuidValue accountId);
Future<AccountValuation> setValuation(Session session, UuidValue accountId,
    DateTime valuationDate, int valueMinor, {String? note});
Future<void> deleteValuation(Session session, UuidValue valuationId);
```

Removed: `listMine` and `addMineToBudget`. An account belongs to exactly one entity. Cross-entity views use `listAll` and `report.netWorth`.

A zero `openingBalanceMinor` writes no zero-amount transaction, because every transaction line must be non-zero, and leaves the cache at 0; its name, currency, date, amount and institution are still validated. A valuations-sourced zero opening stores one zero valuation. `delete` removes every transfer that touches the account through `TransactionWriter`, deleting both legs and reversing the surviving peer's balance, so a reconciled or period-locked leg rejects the whole delete. A ledger account with journal lines also rejects it.

**`TransactionEndpoint`** (`transaction`).

```dart
Future<TransactionView> create(Session session, TransactionInput input);
Future<TransactionView> get(Session session, UuidValue transactionId);
Future<TransactionPage> list(Session session, TransactionQuery query);
Future<TransactionView> update(Session session, UuidValue transactionId, TransactionInput input);
/// Deletes both legs when the transaction is part of a transfer.
Future<void> delete(Session session, UuidValue transactionId);
/// Bulk status change. `reconciled` cannot be set here, only by reconcile;
/// moving a reconciled transaction back to `cleared` unlocks it.
Future<int> setStatus(Session session, List<UuidValue> transactionIds, TransactionStatus status);
Future<int> setFlag(Session session, List<UuidValue> transactionIds, TransactionFlag? flag);
/// Returns [from leg, to leg].
Future<List<TransactionView>> createTransfer(Session session, TransferInput input);
Future<List<TransactionView>> updateTransfer(Session session, UuidValue transferId, TransferInput input);
Future<ReconcileResult> reconcile(Session session, UuidValue accountId, DateTime statementDate,
    int statementBalanceMinor, bool createAdjustment);
Future<ImportResult> importRows(Session session, UuidValue accountId, List<ImportRow> rows);
/// Same account, same amount, date within ±3 days.
Future<List<TransactionView>> findDuplicates(Session session, UuidValue accountId,
    DateTime date, int amountMinor);
```

Removed, with their replacements:

- `list(budgetId)`, `listByMonth` and `listByAccount`: replaced by `list(TransactionQuery)`.
- `toggleCleared`: replaced by `setStatus`.
- `reconcileAccount` and `reconcileWithBalance`: replaced by `reconcile`.
- `transfer`: replaced by `createTransfer`.
- `createSplit` and `listSplits`: replaced by `create` with several lines, and by `TransactionView.lines`.
- `bulkImport`: replaced by `importRows`.
- `ageOfMoney`: moved to `report.ageOfMoney`.

**`BudgetEndpoint`** (`budget`, NEW, in `budget/`). This is the envelope plan. The name is free once `BudgetEndpoint` becomes `EntityEndpoint`; the generated client gets a new `client.budget`.

```dart
Future<BudgetMonthView> getMonth(Session session, UuidValue entityId, int month);
Future<BudgetMonthView> setAllocations(Session session, UuidValue entityId, int month,
    List<AllocationInput> allocations);
/// A null envelope means Ready to Assign. amountMinor is positive.
Future<BudgetMonthView> moveMoney(Session session, UuidValue entityId, int month,
    UuidValue? fromEnvelopeId, UuidValue? toEnvelopeId, int amountMinor);
/// Replaces toMonth's allocations with fromMonth's.
Future<BudgetMonthView> copyMonth(Session session, UuidValue entityId, int fromMonth, int toMonth);
Future<BudgetTemplate> saveTemplate(Session session, UuidValue entityId, int month, String name);
Future<List<BudgetTemplate>> listTemplates(Session session, UuidValue entityId);
Future<List<BudgetTemplateLine>> getTemplateLines(Session session, UuidValue templateId);
Future<BudgetMonthView> applyTemplate(Session session, UuidValue templateId, int month);
Future<void> deleteTemplate(Session session, UuidValue templateId);
```

`moveMoney` is two allocation changes in one transaction:

- With both envelopes set: subtract from the from-envelope's allocation and add to the to-envelope's.
- With a null from-envelope: add to the to-envelope only, which takes the money from Ready to Assign.
- With a null to-envelope: subtract from the from-envelope only, which returns the money to Ready to Assign.

Removed: `MonthlyAllocationEndpoint` (`upsert`, `list`, `copyMonth`, `moveMoney`, `delete`) and `BudgetTemplateEndpoint` (`saveFromMonth`, `list`, `applyToMonth`, `delete`).

**`CategoryEndpoint`**: `create(entityId, name)`, `list(entityId)` and `get` change only their key.

```dart
Future<Category> update(Session session, UuidValue categoryId, {String? name, bool? isHidden});
Future<List<Category>> reorder(Session session, UuidValue entityId, List<UuidValue> categoryIds);
/// Throws ValidationException while the category has envelopes.
Future<void> delete(Session session, UuidValue categoryId);
```

**`EnvelopeEndpoint`**.

```dart
Future<Envelope> create(Session session, UuidValue categoryId, String name,
    {String? note, String? taxCategoryCode});
/// Every envelope of the entity, replacing the per-category list.
Future<List<Envelope>> list(Session session, UuidValue entityId);
Future<Envelope> get(Session session, UuidValue envelopeId);
Future<Envelope> update(Session session, UuidValue envelopeId,
    {String? name, UuidValue? categoryId, String? note, bool? isHidden, String? taxCategoryCode,
     bool? clearTaxCategoryCode, UuidValue? defaultLedgerAccountId, bool? clearDefaultLedgerAccount});
/// Was List<String>.
Future<List<Envelope>> reorder(Session session, UuidValue categoryId, List<UuidValue> envelopeIds);
/// Fails while lines use the envelope unless reassignToEnvelopeId is given.
Future<void> delete(Session session, UuidValue envelopeId, {UuidValue? reassignToEnvelopeId});
```

**`EnvelopeGoalEndpoint`**.

```dart
Future<EnvelopeGoal> upsert(Session session, UuidValue envelopeId, EnvelopeGoalKind kind,
    int amountMinor, {DateTime? targetDate});
Future<List<EnvelopeGoal>> list(Session session, UuidValue entityId);
Future<void> delete(Session session, UuidValue goalId);
```

Removed: `getForEnvelope` and `listForEnvelopes`. Goals come with `BudgetMonthView`.

**`TransactionRuleEndpoint`**: `targetEnvelopeId` becomes `envelopeId` in `create` and `update`.

**`RecurringTransactionEndpoint`**.

```dart
Future<RecurringTransaction> create(Session session, UuidValue accountId, String description,
    int amountMinor, RecurrenceFrequency frequency, DateTime nextDate,
    {UuidValue? payeeId, UuidValue? envelopeId, String? memo, DateTime? endDate});
Future<RecurringTransaction> update(Session session, UuidValue recurringTransactionId,
    {UuidValue? accountId, String? description, int? amountMinor, RecurrenceFrequency? frequency,
     DateTime? nextDate, UuidValue? payeeId, bool? clearPayee, UuidValue? envelopeId,
     bool? clearEnvelope, String? memo, DateTime? endDate, bool? clearEndDate, bool? isActive});
```

`list`, `get`, `delete`, `skipOccurrence`, `postDue` and `countDue` change only their key. `postDue` posts through `TransactionWriter` with `recurringTransactionId` set. A new `RecurringPostFutureCall` runs every hour and posts every due row for each entity whose local date has reached `nextDate`, so posting no longer depends on the app being open. The app's `recurring_auto_post_provider.dart` is deleted.

**`ReportEndpoint`** (`report`, NEW, in `reports/`).

```dart
Future<NetWorthView> netWorth(Session session,
    {List<UuidValue>? entityIds, String? currencyCode, DateTime? asOf});
Future<NetWorthHistoryView> netWorthHistory(Session session, DateTime fromDate, DateTime toDate,
    NetWorthGranularity granularity, {List<UuidValue>? entityIds, String? currencyCode});
Future<List<SpendingRow>> spending(Session session, UuidValue entityId, int fromMonth, int toMonth,
    ReportGrouping grouping, bool byMonth);
Future<List<BudgetMonthSummary>> monthSummaries(Session session, UuidValue entityId,
    int fromMonth, int toMonth);
Future<int?> ageOfMoney(Session session, UuidValue entityId);
```

**`FxRateEndpoint`** (`fxRate`).

```dart
Future<FxLatestSnapshot> latest(Session session);
Future<FxQuoteView> quote(Session session, String fromCurrencyCode, String toCurrencyCode, DateTime date);
```

Removed: `refresh`. The hourly job keeps rates current, and clients can no longer spend the provider quota. When `quote` has no rate, it throws `FxRateUnavailableException`.

**`LedgerEndpoint`**:

- `enableLedger(Session, UuidValue entityId) → Entity` creates the chart from the template, plus one ledger account per money account.
- `saveDraftJournal` takes `List<JournalLineInput>` with base naming.
- `trialBalance(Session, UuidValue entityId, DateTime asOf)`.
- `revalue(Session, UuidValue entityId, DateTime asOf) → int` is NEW. It runs section 6.8 and returns the number of revaluation transactions created.
- `listAuditEvents(Session, UuidValue entityId, {DateTime? before, int? limit}) → List<AuditEvent>` is NEW. It pages by `createdAt` and allows at most 200 rows.
- Every other method changes only its key.

**`TaxEndpoint`**:

- `getProfile`, `saveProfile`, `listCategories`, `setEnvelopeTaxCategory` and `getReport` change only their key.
- `setTransactionTax` becomes:

  ```dart
  Future<TransactionView> setLineTax(Session session, UuidValue transactionLineId,
      {String? taxCategoryCode, bool? clearTaxCategoryCode, int? businessUsePercent,
       int? salesTaxMinor});
  ```

  It goes through `TransactionWriter.updateLines`, so the ledger revision rules apply.

**`PlaidEndpoint`**:

- `createLinkToken(entityId)`, `exchangePublicToken(entityId, ...)`, `syncConnection(connectionId)` and `importSandboxAccounts(entityId, ...)` change only their key and behaviour (section 5.7).
- `listConnections(Session, UuidValue entityId) → List<PlaidConnection>` is NEW. It is safe to return, because the secret fields are server-only.
- `removeConnection(Session, UuidValue connectionId) → void` is NEW. It calls Plaid `/item/remove` and deletes the row. Accounts keep their history, and `plaidConnectionId` becomes null.

**`WalletEndpoint`** (`wallet`, merged).

```dart
/// Creates the wallet and its crypto account in one transaction, then syncs.
Future<Wallet> connect(Session session, UuidValue entityId, WalletNetwork network, String address,
    {String? label, String? accountName});
Future<List<Wallet>> list(Session session, UuidValue entityId);
Future<Wallet?> getForAccount(Session session, UuidValue accountId);
Future<WalletSyncResult> sync(Session session, UuidValue walletId);
Future<List<WalletHolding>> listHoldings(Session session, UuidValue walletId);
Future<List<WalletTransaction>> listTransactions(Session session, UuidValue walletId,
    {DateTime? before, int? limit});
Future<List<WalletTaxYearSummary>> listTaxYearSummaries(Session session, UuidValue walletId);
Future<WalletTransaction> updateTransactionMetadata(Session session, UuidValue walletTransactionId,
    {String? category, List<String>? tags, String? memo});
/// Deletes the wallet; deleteAccount also deletes its crypto account.
Future<void> disconnect(Session session, UuidValue walletId, {bool? deleteAccount});
```

Removed: `SolanaWalletEndpoint` (`attach`, `list`, `getForAccount`, `sync`, `listTransactions`, `listHoldings`, `listTaxYearSummaries` and `updateTransactionMetadata`, all moved to `wallet`), and `connectSolanaWallet`, `refreshSolanaWallet` and `listWalletHoldings`.

**`AgentEndpoint`**:

- `chat`, `listConversations` and `listProposals` take `entityId`.
- `applyProposal` runs `moveMoney` proposals through `BudgetEndpoint.moveMoney`'s service, and tax proposals through `setLineTax` and `setEnvelopeTaxCategory`'s services.
- The assistant's read tools switch to `BudgetMonthService`, `NetWorthService` and `ReportService`. So do the MCP tools in `agent/mcp/`, whose arguments rename `budgetId` to `entityId`.

**Unchanged:** `AgentTokenEndpoint`, `BillingEndpoint`, `InstitutionEndpoint`, `PayeeEndpoint` apart from its key, and the auth endpoints.

### 7.2 Removed endpoint classes

`BudgetStreamEndpoint`, `MonthlyAllocationEndpoint`, `BudgetTemplateEndpoint` and `SolanaWalletEndpoint`. The old `BudgetEndpoint` becomes `EntityEndpoint`, and the `budget` name is reused for the envelope plan.

## 8. App impact, in working order

Every phase leaves the app compiling, analysing cleanly and passing its tests. The renamed client (`client.entity`, the new `client.budget`) breaks every old call site at compile time, so the analyzer is the to-do list. Paths are relative to `openbudget_app/lib/src/`.

### Phase A: foundations

- Regenerate the client. Add the core helpers in section 6.0.
- `utils/currency_formatter.dart` and `utils/money_input.dart`:
  - Format with `formatMinorUnits(minor, CurrencyCode.decimals)`.
  - Parse with `parseMinorUnits(text, decimals)`.
  - Delete every `/ 100` and `* 100`, including the Plan keypad in `features/budget/screens/budget_detail_screen.dart:240-251, 882-889` and `features/budget/widgets/budget_amount_keypad.dart`.
  - A JPY field accepts no decimal point. A field for a 3-decimal currency accepts three digits after the point.
- Routing:
  - `routing/route_names.dart` and `app_router.dart`: change `:budgetId` to `:entityId` in every path, and every `String budgetId` parameter to `String entityId`.
  - Rename the selected-budget providers to selected-entity providers.
  - `selected_month_provider.dart` holds `int month` (yyyymm) through `MonthKey`.
- Rename `features/home/providers/budget_list_provider.dart` and `budget_actions_provider.dart` to `entity_list_provider.dart` and `entity_actions_provider.dart`.
- Replace `features/budget/providers/budget_realtime_provider.dart` with `entity_events_provider.dart`. It subscribes to `client.entityStream.watch(entityId)` and invalidates by `ChangeScope`:

  | Scope          | Invalidates                                                            |
  | -------------- | ---------------------------------------------------------------------- |
  | `transactions` | the transaction pages, the month views, the accounts and the summaries |
  | `plan`         | the month views                                                        |
  | `accounts`     | the accounts and net worth                                             |
  | `ledger`       | the ledger providers                                                   |
  | `proposals`    | the assistant proposals                                                |
  | `entity`       | the entity and its tax profile                                         |

### Phase B: entities, home and settings

- `features/budget/screens/create_budget_screen.dart` becomes `features/home/screens/create_entity_screen.dart`. It asks for:
  - name;
  - kind (personal, sole trader, company);
  - country (GB, US, NG, DE first);
  - base currency, defaulting from the country;
  - time zone, defaulting from the country through a core `defaultTimeZone(countryCode)` (Q7), with a picker for US zones.

  The financial year end is shown, pre-filled from `defaultFiscalYearEnd`, for sole traders and companies.
- `features/home/screens/home_screen.dart`:
  - It renders `entity.listSummaries()`: one card per entity, with Ready to Assign, overspent count, uncategorised count, due recurring transactions and pending proposals.
  - The combined net worth card calls `report.netWorth()` once.
  - The by-currency and by-sign totals computed in the app are deleted. The home screen, account list and net worth screen now show the same numbers, because they come from the same server function.
- Settings:
  - `features/settings/providers/display_currency_provider.dart` and `screens/currency_settings_screen.dart` set the user's reporting currency through `settings.setReportingCurrency`. The `budget.update(displayCurrencyCode:)` call and all FX math in the app are deleted.
  - `plan_settings_screen.dart` edits the entity: name, time zone, financial year end, and "Count in my net worth".
  - `budget_export_provider.dart` calls `entity.exportData`.
- Deleting an entity asks the user to type its name, and warns when the books are in ledger mode.

### Phase C: accounts, valuations, wallets and Plaid

- `features/accounts/screens/add_account_screen.dart`:
  - It shows a kind picker grouped into Cash and bank, Credit and loans, and Investments and property.
  - The currency can be any supported currency. The forced budget currency at line 375 is deleted.
  - The on-budget switch is shown only when `canBeOnBudget(kind)`.
  - For kinds that allow both sources, a "Track by transactions / Track by value" choice.
  - It takes an opening balance and date, which the server turns into an opening transaction or a first valuation.
- `account_list_screen.dart` groups accounts into Assets and Liabilities by `isLiability(kind)`, then by kind. Each row shows the native balance. A foreign-currency row adds a secondary line with the base equivalent at today's rate, from `NetWorthAccountRow.convertedMinor`, so the app does no conversion. Closed accounts are folded away.
- `account_detail_screen.dart`:
  - Transactions-sourced accounts show the balance, cleared and uncleared amounts from `account.getBalances`, a paged transaction list (`TransactionQuery.accountId`), the bank's reported balance with a "Reconcile" action, and the reconcile flow (section 6.7).
  - Valuation-sourced accounts show a value history list and chart from `listValuations`, and "Update value".
  - The line-336 reading of `balanceCents` as an opening balance is deleted.
- `edit_account_dialog.dart` allows a kind change only within the same liability class and balance source.
- Merge `solana_wallet_provider.dart` and `wallet_actions_provider.dart` into `wallet_provider.dart` on `client.wallet`. Holdings show `quantityRaw` formatted with `decimals`, and `valueMinor` formatted in `priceCurrencyCode`. Unrealised P&L is computed in the view model, from `valueMinor − costBasisMinor`.
- `plaid_account_link_provider.dart` takes `entityId`. A connections list appears under the accounts, with sync status, last error and Remove.
- Delete `listMine` and `addMineToBudget` usage.

### Phase D: transactions, transfers, imports and reconciliation

- `features/transactions/screens/add_expense_screen.dart`, `add_income_screen.dart` and `edit_transaction_dialog.dart`:
  - They build one `TransactionInput`. **An account is required**, defaulting to the last used on-budget account.
  - The amount field uses the account's currency and exponent.
  - When the account currency differs from the base, a live line under the amount shows the base equivalent, the rate, the rate date and the source, from `fxRate.quote`, for example "≈ £78.91 · 1 USD = 0.7891 GBP · 8 Nov · market". A "Set rate" action sends a manual `fxRate`.
  - `FxRateUnavailableException` opens the same rate sheet, with the message explaining why.
- Replace `split_expense_screen.dart` and `split_transaction_provider.dart` with a lines editor inside the same transaction form. It shows the remaining unallocated amount and saves only when the lines sum exactly. `SplitItem` is gone.
- `transaction_actions_provider.dart`:
  - Delete the `envelope.update(spentAmountCents: amount)` call at lines 316-325, which is bug 3 in section 3.
  - Every write calls `transaction.create`, `update` or `delete`, and relies on `EntityChangedEvent` for refreshes.
- `transaction_list_screen.dart` pages with `transaction.list(TransactionQuery)`, with search, account, envelope, status and "uncategorised" filters. The split-child hiding hack at lines 188-194 is deleted. A row shows the amount in the account currency, plus the base amount when they differ.
- `features/transfers/screens/create_transfer_screen.dart`:
  - "From" and "To" pickers list `account.listAll()`, so transfers can cross entities. The entity shows as a subtitle.
  - When the currencies differ, it has two amount fields, "Sent" and "Received". The implied rate is shown live, and "Use today's rate" fills Received from `fxRate.quote`.
  - An envelope picker appears only when the money leaves the plan (on budget to off budget, or to another entity).
- `import_transactions_screen.dart` and `import_transactions_provider.dart`:
  - They pick the target account first, parse amounts with `parseMinorUnits` and that account's decimals, and send `ImportRow`s with `externalId` when the file has one.
  - They show `ImportResult`'s inserted, duplicate and error counts.
- `duplicate_check_provider.dart` calls `findDuplicates(accountId, date, amountMinor)`.
- `features/budget/screens/review_transactions_sheet.dart` uses `TransactionQuery.uncategorizedOnly`.

### Phase E: the envelope plan

- `features/budget/providers/budget_detail_provider.dart`, `budget_provider.dart`, `budget_summary_provider.dart` and `monthly_allocation_provider.dart` collapse into one `budget_month_provider.dart` on `budget.getMonth(entityId, month)`. Every screen reads envelope figures from `EnvelopeMonthView`, never from `Envelope`.
- `budget_detail_screen.dart`, `widgets/budget_header.dart`, `widgets/category_group.dart` and `widgets/envelope_row.dart` render the month view.
  - The header shows Ready to Assign, with a breakdown sheet listing the `BudgetMonthSummary` fields. "Exchange-rate difference" is shown only when it is non-zero.
  - Overspent envelopes show red.
- Allocation edits, moves and templates go through `budget`:
  - `envelope_actions_provider.dart` and `move_money_dialog.dart` call `budget.setAllocations` or `budget.moveMoney`, each returning the new month view.
  - `auto_assign_provider.dart`, `auto_assign_dialog.dart` and `quick_budget_provider.dart` compute the amounts locally from the month view, then send one `setAllocations`.
  - `budget_template_provider.dart` and `budget_template_dialog.dart` call `budget.saveTemplate`, `listTemplates`, `applyTemplate` and `deleteTemplate`.
  - `recent_moves_provider.dart` and `recent_moves_screen.dart` keep their local history, now in minor units.
- Goals:
  - `budget_goals_provider.dart` keeps only presentation. The arithmetic moves to core `goal_math.dart`, and the underfunded amount comes from `EnvelopeMonthView.goalUnderfundedMinor`.
  - `envelope_goal_provider.dart` and `set_goal_dialog.dart` use `EnvelopeGoalKind` and one amount.
- `envelope_activity_sheet.dart` pages `transaction.list` with `envelopeId` and the month's dates.
- `age_of_money_provider.dart` calls `report.ageOfMoney`.
- `credit_card_provider.dart` and `widgets/credit_card_section.dart` show each card's month spending from `transaction.list` filtered by account and month, plus its balance. Payment envelopes are deferred (Q3).
- Category and envelope dialogs (`add_*`, `edit_*`) and `category_detail_screen.dart` use the new signatures. Deleting an envelope with history asks which envelope to move it to.

### Phase F: net worth and reports (the multi-currency UI)

- `features/reports/screens/net_worth_screen.dart` and `providers/net_worth_provider.dart` are rebuilt on `report.netWorth` and `report.netWorthHistory`:
  - **Headline:** net worth in the reporting currency, with a currency chip that changes the reporting currency in place. Assets and liabilities appear below it.
  - **Trust line:** "Rates from 8 Nov 2026". A "Stale" badge appears when `hasStaleRates`. When incomplete, a warning card lists the currencies left out, with "Not included: 2 accounts in NGN (no rate)".
  - **History chart** from `netWorthHistory`, with 3M (day), 1Y (week) and All (month) toggles. Incomplete points are drawn hollow.
  - **Breakdown tabs:**
    - By entity, with a chip filter to include or exclude entities. A changed `entityIds` set re-queries.
    - By currency: each row shows the native total, the converted total, and "1 USD = 0.7891 GBP · 8 Nov".
    - By account: grouped into assets and liabilities by kind. Valuation accounts show "Valued 1 Nov".
  - No conversion happens in the app.
- Reports:
  - `spending_report_provider.dart`, `spending_by_payee_provider.dart`, `category_trends_provider.dart`, `spending_trends_provider.dart` and `multi_month_comparison_provider.dart` call `report.spending` once per screen, with the right grouping and `byMonth`. They stop fetching months one by one.
  - Month-level figures come from `report.monthSummaries`.

### Phase G: books, tax, the assistant and Plus

- `features/ledger/*`: `entityId`; base naming in `ledger_formatting.dart` and the journal editor; enums replace string switches in `ledger_labels.dart`. Add an audit trail list and a "Revalue foreign accounts" action to `books_screen.dart`.
- `features/tax/*`: `entityId`. `tax_profile_screen.dart` no longer edits jurisdiction or entity kind, which come from the entity. `tax_category_sheet.dart` sets tax per line through `tax.setLineTax`.
- `features/assistant/*`: `entityId`. `assistant_proposal_card_view.dart` renders the new `moveMoney` payload (`amountMinor` formatted in base).
- `features/plus/*` and `features/agent_access/*`: no change beyond the regenerated client.

### Phase H: localisation, tests and clean-up

- Add ARB strings for every new label: account kinds, statuses, flags, change prompts, the FX lines, the net worth trust line and the entity kinds. Run the l10n generator.
- Update the widget tests for every screen touched. Update `integration_test/common/patrol_helpers.dart` and `test_data.dart`, and add the Patrol flows in section 10.
- Delete the dead providers and screens listed above, and every remaining reference to `Cents`. `rg -n 'Cents|cents|\* 100|/ 100' openbudget_app/lib` must come back empty apart from comments about currencies.

## 9. Migration plan

There is one migration, created by the tool and never edited by hand.

1. **Models first.** Make every model change in section 5 and add the core shared package (section 5.0). Delete the dropped `.spy.yaml` files.
2. **Delete the old migrations:**

   ```bash
   git rm -r openbudget_server/migrations
   ```

   This removes the 36 version directories and `migration_registry.txt`.
3. **Generate:**

   ```bash
   cd openbudget_server
   serverpod generate            # devenv script; or: dart run serverpod_cli generate
   ```

   Check that the shared-package enums land in `openbudget_core/lib/src/generated/` and that no class is generated twice. If they don't, apply the fallback in section 5.0.
4. **Create the single migration:**

   ```bash
   serverpod create-migration --tag schema-reset
   ```

   This writes `migrations/<timestamp>-schema-reset/` and a new `migration_registry.txt` with one entry. Its `definition.sql` contains:
   - Serverpod's own tables;
   - the auth module tables (`serverpod_auth_core_*` and `serverpod_auth_idp_*`) at the module versions in `pubspec.yaml`;
   - every table in section 4.1.

   It also contains the `serverpod_migrations` rows for each module. Do not edit any file in the directory. If the tool reports destructive changes, something is still pointing at the old registry: stop and check that step 2 removed everything.
5. **Inspect the result** before committing:

   ```bash
   grep -c 'CREATE TABLE' migrations/*-schema-reset/definition.sql
   grep -n 'ON DELETE' migrations/*-schema-reset/definition.sql
   ```

   Compare every foreign key action with section 5, and confirm that no `double precision` column remains in an OpenBudget table. The schema contract test in section 10 automates this.
6. **Reset the local databases.** Their `serverpod_migrations` rows name versions that no longer exist, so drop and recreate them:

   ```bash
   devenv up   # postgres on 8090, redis on 8091
   psql -h localhost -p 8090 -d postgres \
     -c 'DROP DATABASE IF EXISTS openbudget WITH (FORCE)' \
     -c 'CREATE DATABASE openbudget' \
     -c 'DROP DATABASE IF EXISTS openbudget_test WITH (FORCE)' \
     -c 'CREATE DATABASE openbudget_test'
   ```

   Then run `server:start`, which runs `dart bin/main.dart --apply-migrations`. On an empty database, Serverpod builds the schema from `definition.sql` alone. Check it:

   ```bash
   psql -h localhost -p 8090 -d openbudget -c 'SELECT module, version FROM serverpod_migrations ORDER BY module'
   ```

   It should list `openbudget` with the schema-reset version, plus `serverpod`, `serverpod_auth_core` and `serverpod_auth_idp`.
7. **Auth module tables** need no special handling. They are module tables, created from the same `definition.sql`, and the module versions are recorded as usual. The only consequence of the reset is that local sign-ins are lost, so developers register again. No staging or production database exists. If a shared staging database appears before this lands, it must be dropped the same way.
8. **CI.** The `server-test` job starts a fresh Postgres service each run, so it needs no change. `serverpod_test` applies the new migration on start.
9. **Generated code in its own commit.** Commit the hand-written models and services, then the output of `serverpod generate` and `melos run generate` (`*.g.dart`, `*.freezed.dart`, client protocol, core `generated/`) in a dedicated commit, as the project's conventions require.
10. **Changesets:**
    - A developer `breaking` changeset covering `openbudget_server`, `openbudget_client` and `openbudget_core`: "Reset the schema to the entity model."
    - A user `user_improve` changeset: "Accounts can now be in any currency, and net worth adds up across currencies, entities and account types."

    No native files change, so the app needs no major bump. The design adds no plugin (Q7).

## 10. Test plan

Every write-path test ends by running the verification query in section 6.2 and asserting that it returns no rows, through a shared `expectBalancesConsistent(session)` helper in `test/integration/helpers/`.

### 10.1 Core unit tests (`openbudget_core/test/`)

- `convertMinorUnits`:
  - positive and negative vectors at exponents 0, 2, 3 and 8;
  - half-up ties in both signs: −5 at `'0.5'` gives −3, and −3333 at `'0.8'` gives −2666;
  - the ±(2^53 − 1) bounds.
- `ExactDecimal.divide`: rounding to 12 significant digits, quotients below 1, repeating fractions. `fromDouble`: `1e-7`, `123456.789`, and a rejected 0.
- `crossRate` and `impliedRate`: GBP to JPY and JPY to GBP, round trips within one minor unit.
- `splitBaseAmounts`: the residue goes to the largest line, and to the first on a tie. The sum is always exact, including with mixed signs.
- `MonthKey` and `CivilDate`: the year boundary, invalid months, and a non-midnight date rejected.
- `AccountKindRules`: every `AccountKind` value has a row, enforced with an exhaustive switch.
- `envelope_fold.dart`:
  - The vectors: carryover; overspending reducing the next month's Ready to Assign without carrying into the envelope; future allocations; hidden envelopes; a month with no data.
  - A seeded **property test**: 1,000 random sequences of income, spending, allocations and moves. After each, the invariant in section 6.4 must hold for every month.
- `goal_math` (moved tests) and `nextOccurrence`: the 31st of the month, the 29th of February, biweekly.

### 10.2 Server integration tests (`openbudget_server/test/integration/`)

**`transaction_writer_test.dart`:**

- Create, update and delete move `balanceMinor` exactly.
- A changed account moves the balance between the two accounts.
- A memo-only update keeps the stored rate.
- Failures:
  - lines that do not sum: `ValidationException`;
  - an envelope from another entity: `ForbiddenException`;
  - an envelope on an off-budget account, a ledger account outside ledger mode, a non-civil date, or a date after today plus one day: `ValidationException`;
  - a date on or before the lock in ledger mode: `ValidationException`;
  - an amount, date or line edit on a `reconciled` transaction: `ValidationException`;
  - a missing rate: `FxRateUnavailableException` with its fields;
  - a balance overflow: rolled back.
- A manual rate is stored with `manual`.
- A payee rule fills the envelope only when no envelope is given.
- **Concurrency:** 20 parallel creates on one account leave the correct balance.

**`transfer_test.dart`:**

- A same-currency transfer.
- GBP to USD in a GBP entity: the two bases net to exactly zero, and the second leg's source is `implied`.
- EUR to USD in a GBP entity.
- A transfer across entities, converted independently.
- The envelope rules: allowed when the money leaves the plan; `ValidationException` between two on-budget accounts.
- Deleting one leg through the endpoint deletes both.
- Deleting one leg's account in the database leaves the other leg, with a consistent balance.

**`account_valuation_test.dart`:**

- The latest valuation wins.
- Deleting the latest one falls back to the previous valuation, or to 0.
- A future valuation date is rejected.
- A valuation on a transactions-sourced account is rejected.

**`budget_month_test.dart`:**

- Each vector from 10.1, through the database.
- Internal transfers leave Ready to Assign unchanged.
- A transfer from on budget to off budget with an envelope counts as activity.
- An income transfer from another entity counts as income.
- An `fxRevaluation` appears in `fxDifferenceMinor`.
- `setAllocations` with 0 deletes the row.
- `moveMoney` from and to Ready to Assign.
- The invariant is checked against the database's actual on-budget base totals after every test.

**`net_worth_test.dart`:**

- The atoms agree: the entity rows, the converted currency rows and the account rows all sum to the total.
- Liabilities are decided by kind, including a loan with a positive balance.
- `includeInNetWorth` and archived entities are respected.
- A missing rate makes the view incomplete, with `missingCurrencyCodes`, and leaves those accounts out of the totals.
- A stale rate sets `hasStaleRates`.
- Another user's `entityIds`: `ForbiddenException`.
- History:
  - the last point equals `current()`;
  - a backdated transaction changes earlier points;
  - a valuation step shows from its date;
  - more than 400 points: `ValidationException`.

**`fx_service_test.dart`:**

- The refresh upsert is idempotent.
- A cross rate is rounded to 12 significant digits.
- A 7-day lookback returns the latest row on or before the date.
- Past the lookback, it returns null and enqueues a backfill.
- USD has a `'1'` row every day.

**`reconcile_test.dart`:**

- A difference without an adjustment changes nothing.
- An adjustment is dated `statementDate`, in the account currency, and flows into Ready to Assign on a budget account.
- Only transactions that are cleared and dated on or before the statement date become reconciled.
- `reconciledThroughDate` is set.

**`delete_cascade_test.dart`:**

- Deleting an entity in ledger mode, with posted journals, removes every row in every table.
- An envelope with lines is rejected, and so is a category with envelopes.
- A ledger account with lines is rejected.
- `EnvelopeService.delete(reassignToEnvelopeId:)` moves the lines, allocations, goal, rules and recurring transactions.

**`access_test.dart`:** every endpoint method that takes an id rejects another user's id with `ForbiddenException` or `NotFoundException`. It is table-driven over the endpoint list.

**`plaid_connection_test.dart`:**

- The token is stored as ciphertext and round-trips through `SecretBox`.
- The generated client `PlaidConnection.fromJson` and `toJson` contain no ciphertext, nonce or cursor fields.

**`entity_events_test.dart`:**

- An event is posted after commit with the right scope.
- No event is posted when the transaction rolls back.

**`ledger_test.dart`** (the existing tests, re-keyed):

- `(sourceTransactionId, sourceRevision)` is unique.
- A posted journal cannot be edited.
- Edits and deletes in ledger mode write audit events.
- `revalue` is idempotent per date, and picks the realised or unrealised account by balance.

**`schema_contract_test.dart`:** queries `information_schema` and `pg_constraint` and asserts that:

- every foreign key's `ON DELETE` action matches a table copied from section 5;
- every `*Minor` column is `bigint`;
- no OpenBudget table has a `double precision` column;
- every OpenBudget table's `id` is `uuid`.

### 10.3 App tests

- **Widget tests**, using `pumpApp`:
  - money input for JPY, GBP and KWD;
  - the add expense FX line and the missing-rate sheet;
  - the transfer form's two amounts;
  - the lines editor's sum check;
  - the Plan header breakdown;
  - the net worth screen states: complete, incomplete and stale;
  - the create entity defaults.
- **Unit tests:** the scope-to-provider invalidation map in `entity_events_provider.dart`.
- **Patrol E2E**, using page objects in `patrol_helpers.dart`:
  1. Create a personal GBP entity. Add a USD checking account on budget. Add a USD expense to an envelope. The Plan shows the GBP activity, and the account shows the USD balance.
  2. Transfer USD to GBP with two amounts. Ready to Assign is unchanged.
  3. Add a property account by value. Net worth shows it under assets. Switching the reporting currency to USD updates every figure.
  4. Reconcile an account with a difference. The adjustment appears and the transactions lock.

### 10.4 Commands

```bash
melos run analyze
melos run test
cd openbudget_server && dart test        # needs Postgres; CI's server-test job maps it to 9090
dprint check
monochange check && monochange preview
```

## 11. Follow-up migrations and extension points

Each item is a separate pull request with at most one migration.

1. **`JournalPoster`**, with no migration. It posts each ledger-mode transaction revision under the rules in section 6.8, and adds the nightly check that bank-linked ledger balances equal account balances. Update `openbudget-coexistence.md` in the ledger skill to match section 2.3.
2. **Documents** (one migration): `contact`, `tax_code`, `invoice`, `invoice_line`, `bill`, `bill_line`, `payment` and `payment_allocation`, under the ledger skill's `documents-and-invoicing.md`. Extension points already in this schema:
   - `payee` gains `contactId: UuidValue?` (SetNull).
   - `transaction_line` gains `taxCodeId: UuidValue?` next to `taxCategoryCode`.
   - `payment` references the bank `transaction` that settled it.
   - `JournalSource` gains `invoice`, `bill` and `payment`.
   - Realised FX on settlement then follows the skill exactly.
3. **Shared households**: an `entity_member` table (`entityId`, `userId`, `role`) and a change to `EntityAccess.requireOwned` only (Q5).
4. **Plaid `/transactions/sync`** using `plaid_connection.transactionsCursor`, which is already in place.
5. **Credit card payment envelopes** (Q3), if users ask for them. They need a `paymentEnvelopeId` on `account`.
6. **Database enforcement of journal immutability** (Q4).
7. **`envelope_month_activity` cache**, only if `budget.getMonth` p95 exceeds 150 ms in production. It is keyed `(envelopeId, month)` and maintained by `TransactionWriter`.
8. **Security-level investments**: `holding` and `lot` tables under an investment account, which then derives its valuation from them.
9. **More wallet networks**: new `WalletNetwork` values, and a network-specific sync behind `WalletService`.
10. **User deletion**: when account deletion ships, the deletion service deletes the user's entities first, because `entity.ownerId` is `Restrict`, then the auth user, whose `userId` rows cascade.

## 12. Open questions

Each question has a recommended default, which the implementation should follow unless the owner decides otherwise.

| #   | Question                                                         | Default                                                                                                                                                                                                                        |
| --- | ---------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Q1  | Should companies count in the owner's combined net worth?        | **No by default** (`includeInNetWorth = false` for companies). A company's assets are not the owner's, and their stake is better shown as an investment valuation. Sole traders count, because their business money is theirs. |
| Q2  | Allow future-dated transactions?                                 | **No**, beyond the entity's today plus one day for time zones. Scheduled money is a recurring transaction, which keeps `balanceMinor` equal to the money that exists.                                                          |
| Q3  | Add credit card payment envelopes in the reset?                  | **No.** Card spending reduces its envelope, and paying the card is an internal transfer. The plan stays zero-sum (section 6.4). Add them later if users ask (section 11).                                                      |
| Q4  | Enforce journal immutability in the database with triggers?      | **Not in the reset.** Serverpod builds fresh databases from `definition.sql` only, so triggers there cannot be carried. Enforce in services and tests now. Revisit with an idempotent startup installer.                       |
| Q5  | Let several users share an entity?                               | **Not yet.** One owner per entity; `EntityAccess.requireOwned` is the only seam to change.                                                                                                                                     |
| Q6  | Revalue envelope-mode foreign accounts automatically each month? | **Yes, on-budget accounts only**, on the first of the month, shown as "Exchange-rate difference" in Ready to Assign. Without it, the plan drifts away from what foreign money is worth.                                        |
| Q7  | Detect the device time zone with a plugin?                       | **No.** Default from the country, with a picker. A plugin adds native code, which forces a major app release and a store review.                                                                                               |
| Q8  | What currency is a wallet's crypto account in?                   | **USD**, the price currency. It converts like any foreign account in net worth, and needs no revaluation, because it is valuation-sourced.                                                                                     |
| Q9  | Snapshot daily net worth for speed?                              | **No.** History is four queries for any range. Add a cache only if p95 exceeds 300 ms.                                                                                                                                         |
| Q10 | Allow deleting a posted transaction in a ledger-mode entity?     | **Yes**, unless it is dated within the lock or reconciled. The delete is audited, and the poster reverses its journal.                                                                                                         |
| Q11 | Import Plaid pending transactions?                               | **No.** Skip them until they post, because pending ids change on posting and would duplicate rows. The reported balance still shows what the bank says.                                                                        |
| Q12 | Add 3-decimal currencies (KWD, BHD) to `CurrencyCode` now?       | **Yes**, in the reset. It is two enum values plus tests, and it proves that nothing assumes 2 decimals.                                                                                                                        |

## Deviations

- Serverpod 4.1 rejects `import` as a reserved generated enum value. The shared `JournalSource` uses `imported`; all core and server callers use that name. Shared-package generation otherwise works, so the enum fallback is unnecessary.
- Pure core funding calculations accept a `FundingGoal` record containing the goal kind name, amount and target date. This avoids a dependency from core on the server's `EnvelopeGoal` model.
- The server's `ValuationSource` likewise uses `imported` because `import` is reserved by the generator.
- Serverpod 4.1 requires nullable fields for `scope=serverOnly`: Plaid's `accessTokenCiphertext` and `accessTokenNonce`, and wallet transaction `rawJson`, are nullable in the model. Secret-writing services must supply both token fields together.
- `FxRateEndpoint.refresh` stays in the reset even though section 7 removes it. This port keeps the authenticated endpoint so the hourly `fx-refresh-hourly` job can be validated against a forced refresh; remove it once the job is proven.
- `TransactionWriter` joins a caller transaction only through `TransactionWriter.inTransaction`. Serverpod 4.1's `session.db.transaction` has no after-commit callback, so a raw join could either lose the `EntityChangedEvent` or publish it before the caller commits. The wrapper owns the commit boundary, publishes queued events afterwards, and rejects a raw caller transaction. Its FX lookup joins the same transaction through `FxService.rateOn(..., transaction:)`.
