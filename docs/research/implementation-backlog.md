# OpenBudget Deep Research: Implementation Backlog

Date: 2026-02-27

This backlog turns strategy into implementable epics with explicit acceptance criteria.

## Priority Legend

- P0 = correctness/safety blockers
- P1 = core strategic unlocks
- P2 = ecosystem and optimization

## Epic P0.1 - Currency Safety Invariants (Server)

Problem:

- Transfer currency checks currently rely on UI behavior.

Work:

- Add server-side transfer validation:
  - source and destination accounts must share currency.
  - transfer transaction `currencyCode` must match account currency.
- Add account-currency guardrails in reconcile paths.
- Add explicit validation errors with actionable messages.

Acceptance Criteria:

- Cross-currency transfer request fails server-side with deterministic error.
- Integration tests cover valid + invalid transfer combinations.

## Epic P0.2 - Unknown Currency Handling

Problem:

- Unknown currency fallback defaults to USD in app parsing.

Work:

- Replace silent fallback with explicit unknown-currency handling.
- Add unsupported-currency UI treatment (error chip, fallback label, telemetry).
- Add server-side allowlist strategy:
  - short term: strict enum/allowlist,
  - long term: dynamic currency registry.

Acceptance Criteria:

- Unknown currency values are surfaced, not silently remapped.
- Parsing behavior is covered by unit tests.

## Epic P0.3 - Account Balance Semantics

Problem:

- Account balances are treated as stored values while many transaction flows do not attach account IDs.

Work:

- Decide canonical model:
  - Option A: ledger-derived balances,
  - Option B: opening-balance + adjustments + derived movement.
- Update account detail/list and transaction create flows to align.
- If using derived balances, add server query for computed account balance timeline.

Acceptance Criteria:

- Product spec documents single source-of-truth balance policy.
- Account list and account detail agree for same account/time window.
- Tests validate consistency.

## Epic P0.4 - Runtime API Configuration Alignment

Problem:

- App client provider hardcodes localhost API URL.

Work:

- Use runtime config loading path for app startup.
- Keep test overrides easy and deterministic.
- Ensure web/mobile/desktop startup paths share config policy.

Acceptance Criteria:

- Production app can run without code changes to client URL.
- Integration tests validate config resolution path.

## Epic P1.1 - FX Rate and Valuation Core

Goal:

- Base-currency valuation from native-currency records.

Schema:

- `fx_rate(id, base_currency, quote_currency, rate, source, as_of, confidence)`
- unique index `(base_currency, quote_currency, as_of, source)`

Service APIs:

- `valuation.getRate(base, quote, asOf)`
- `valuation.convert(amountMinor, from, to, asOf)`
- `valuation.netWorth(budgetId, asOf, baseCurrency)`
- `valuation.netWorthSeries(budgetId, range, baseCurrency)`

UI:

- Base-currency selector in settings.
- Valuation-as-of labels on totals.
- Driver attribution (spending vs FX movement).

Acceptance Criteria:

- Historical net worth changes when FX changes, without editing transaction amounts.
- Conversion reproducibility for historical timestamps.

## Epic P1.2 - Currency Registry Expansion

Goal:

- Expand currency support beyond static enum constraints.

Work:

- Introduce server-backed currency registry endpoint.
- Keep app enum only for built-in defaults; support dynamic additions.
- Preserve decimal precision behavior per currency.

Acceptance Criteria:

- New fiat currency can be introduced without shipping app binary updates.
- Decimal rounding rules are deterministic and tested.

## Epic P1.3 - Solana Wallet Ingestion (Read-Only)

Goal:

- Track wallet holdings and valuation.

Schema:

- `wallet(id, owner_id, chain, address, label, created_at)`
- `asset(id, chain, asset_id, symbol, decimals, metadata_json)`
- `asset_holding(id, wallet_id, asset_id, quantity_base_units, last_synced_at)`
- `asset_tx(id, wallet_id, chain, tx_hash, event_index, asset_id, direction, quantity_base_units, fee_base_units, occurred_at, raw_json)`
- unique `(chain, tx_hash, event_index)`

Worker:

- cursor-based sync job per wallet.
- idempotent upserts.

Acceptance Criteria:

- Wallet can be added and synced repeatedly without duplicates.
- Holdings view reflects on-chain changes after sync.

## Epic P1.4 - Asset Price Service

Goal:

- Price digital assets in selected valuation currency.

Schema:

- `asset_price(asset_id, quote_currency, price, source, as_of, confidence)`

Service APIs:

- `assetValuation.holdingsValue(walletId, asOf, quoteCurrency)`
- `assetValuation.portfolioValue(budgetId, asOf, quoteCurrency)`

Acceptance Criteria:

- Unified net worth includes fiat accounts + crypto holdings.
- Missing price behavior is explicit and user-visible.

## Epic P1.5 - Unified Valuation Dashboard

Goal:

- Make valuation understandable.

Work:

- Breakdown tiles:
  - by asset class (cash, debt, crypto),
  - by currency exposure,
  - by 24h/7d/30d change attribution.

Acceptance Criteria:

- User can explain total movement without raw spreadsheet work.

## Epic P2.1 - Tax Lot Engine (FIFO First)

Goal:

- Deterministic realized PnL and tax-year calculations.

Schema:

- `tax_profile(owner_id, jurisdiction, tax_year_start_month, lot_method)`
- `tax_lot(id, asset_tx_id, asset_id, acquired_at, quantity_open, unit_cost_minor, currency)`
- `disposal_event(id, asset_tx_id, disposed_at, quantity_disposed, proceeds_minor, currency)`
- `lot_match(id, disposal_event_id, tax_lot_id, quantity_matched, cost_basis_minor, proceeds_minor, gain_loss_minor)`

Engine:

- deterministic lot matching with versioned rule metadata.

Acceptance Criteria:

- Recomputing the same period yields identical results.
- Disposal drilldown explains lot-level gain/loss.

## Epic P2.2 - Tax Reporting

Goal:

- Usable tax outputs for users and accountants.

Work:

- tax-year summaries,
- realized/unrealized splits,
- export package (CSV + JSON + evidence links).

Acceptance Criteria:

- User can export traceable tax report per year.

## Epic P2.3 - AI Analyst (Read-Only)

Goal:

- Explainable financial insights.

Work:

- assistant endpoint over curated financial context.
- retrieval from valuations, lots, disposals, spending trends.
- response format with citations and confidence.

Acceptance Criteria:

- Each recommendation contains references to source records.
- Assistant outputs are auditable and non-destructive.

## Epic P2.4 - Connector and Plugin Surface

Goal:

- Enable ecosystem contributions.

Work:

- connector contract for wallet/rate importers.
- plugin registry concept for jurisdiction tax modules.

Acceptance Criteria:

- Third-party connector can be integrated without core refactor.

## Cross-Cutting Engineering Requirements

1. Observability

- Metrics for ingestion lag, valuation freshness, tax run duration, AI query latency.

2. Data Quality

- Confidence/freshness fields for all external rates/prices.

3. Testing

- Property tests for currency math and lot matching.
- Replay fixtures for known edge-case wallets/periods.

4. Migration Safety

- Backfill jobs with dry-run modes.
- Explicit migration docs per schema change.

## Suggested Sequencing (Lean)

1. P0.1, P0.2, P0.3, P0.4
2. P1.1, P1.2
3. P1.3, P1.4, P1.5
4. P2.1, P2.2
5. P2.3, P2.4

## Initial RFC Set To Create

1. RFC-001 Currency and Valuation Core
2. RFC-002 Account Balance Canonical Semantics
3. RFC-003 Solana Wallet Ingestion and Data Model
4. RFC-004 Tax Lot Engine (FIFO) and Auditability
5. RFC-005 AI Assistant Contracts and Guardrails
