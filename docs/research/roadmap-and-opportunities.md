# OpenBudget Deep Research: Roadmap and Opportunity Map

Date: 2026-02-27

## 1) Product North Star

Build the open-source budgeting platform where:

- People can budget in native currencies and view accurate base-currency valuations over time.
- Digital assets are treated as first-class financial accounts, starting with Solana.
- Tax impact becomes explainable, auditable, and eventually AI-assisted.

## 2) Strategic Positioning

OpenBudget can differentiate by combining:

- Envelope-first behavioral budgeting.
- Transparent multi-currency valuation.
- Open and inspectable digital-asset accounting.
- Explainable (not black-box) AI assistance.

Most tools do one of these well. Few do all four in one open stack.

## 3) Principles For Next Stage

1. Ledger truth first, UI convenience second.
2. Historical reproducibility over "latest only" metrics.
3. Server-enforced invariants for money movement and currency safety.
4. Explainability as a product feature (especially for tax and AI outputs).
5. Incremental release slices with measurable user value each phase.

## 4) Proposed Capability Roadmap

## Phase 0: Correctness Hardening (near-term)

Goal: remove known correctness gaps before adding new domains.

- Enforce transfer currency parity on server side.
- Remove silent USD fallback behavior for unknown currency codes.
- Clarify account/transaction semantics:
  - either make account balances ledger-derived,
  - or explicitly represent opening balance + adjustments + computed live balance.
- Align reconciliation adjustment currency with account currency.
- Replace hardcoded app API URL resolution with config-driven initialization.

Expected impact:

- Fewer hidden valuation/accounting errors.
- Better trust foundation for future crypto/tax features.

## Phase 1: True Multi-Currency Valuation Engine

Goal: convert from "currency tagging" to "valuation intelligence."

### Data model additions

- `fx_rate`
  - `baseCurrency`, `quoteCurrency`, `rate`, `source`, `asOf`, `confidence`
- `valuation_snapshot`
  - per budget/account valuation in base currency at timestamp
- `user_or_budget_preferences`
  - `primaryValuationCurrency`

### Service/API additions

- `valuation.getBudgetValueAt(budgetId, timestamp, baseCurrency)`
- `valuation.getNetWorthSeries(budgetId, range, baseCurrency)`
- `valuation.getExposureBreakdown(budgetId)` (currency concentration)

### UX additions

- Toggle between native amounts and base valuation.
- Show valuation delta due to FX changes vs spending behavior.
- "Valuation as-of" label everywhere totals are shown.

Expected impact:

- Delivers your core painkiller: native input with automatic revaluation.

## Phase 2: Digital Assets (Solana First)

Goal: represent wallets/tokens as first-class financial objects.

### Data model additions

- `wallet`
  - chain, address, ownership, label
- `asset`
  - chain, mint/token id, symbol, decimals
- `asset_holding`
  - wallet, asset, quantity, lastSyncedAt
- `asset_transaction`
  - tx hash, timestamp, direction, quantity, fees, counter-asset/value
- `asset_price`
  - asset quote history by timestamp and source

### Ingestion architecture

- Worker pipeline for Solana wallet sync.
- Deterministic ingestion cursor per wallet.
- Idempotent upsert by `(chain, txHash, eventIndex)`.

### UX additions

- Add wallet flow: "This wallet belongs to me."
- Holdings + PnL + allocation views.
- Unified net worth across fiat + crypto.

Expected impact:

- Opens product to crypto-native and globally distributed users.

## Phase 3: Tax-Lot and PnL Engine

Goal: build auditable tax intelligence foundation.

### Data model additions

- `tax_lot`
  - acquisition date, quantity, cost basis, source tx
- `disposal_event`
  - disposal date, proceeds, fees, linked lots
- `realized_pnl`
  - gain/loss per disposal and per tax year
- `tax_profile`
  - jurisdiction, method defaults (FIFO/HIFO/Specific-ID), tax year boundaries

### Tax computation versions

- Deterministic computation runs with versioned rulesets.
- Re-runnable for amended data or updated policy logic.

### UX additions

- Tax-year dashboard.
- "Explain this gain/loss" drilldown to lot-level matching.
- Exportable tax evidence package.

Expected impact:

- Bridges portfolio tracking and compliance, which is rare in open budgeting tools.

## Phase 4: AI Financial Analyst (Explainable)

Goal: AI assistant over validated valuation + tax primitives.

### AI scope (initial)

- Read-only analysis and recommendations.
- No automated writes by default.

### Candidate assistant tasks

- Identify currency concentration risk.
- Estimate likely tax liabilities under current holdings.
- Suggest disposal/harvesting strategies based on configured tax rules.
- Explain month-over-month net worth changes by driver:
  - spending,
  - FX,
  - asset price movement,
  - transfers.

### Guardrails

- Every conclusion must cite underlying records/transactions/lots.
- Confidence and assumptions shown to user.
- "Not tax advice" boundary with jurisdiction constraints.

Expected impact:

- Delivers meaningful AI value beyond chat novelty.

## 5) Opportunities Useful To Broader Users

## 5.1 Global and Multi-Country Households

- Multi-income households paid in different currencies.
- Expat and immigrant budgeting with transparent conversion effects.
- Students and contractors with cross-border cashflow.

## 5.2 Freelancers and Creators

- Revenue in one currency, expenses in another.
- Separate project wallets/accounts with tax-year summaries.

## 5.3 Open-Source and DAO Treasuries

- Public treasury transparency dashboards.
- Reproducible valuation snapshots and movement timelines.

## 5.4 Developers and Ecosystem Builders

- Open API for importers/connectors.
- Community-built indexers for chains/exchanges.
- Optional plugin surface for jurisdiction-specific tax rules.

## 6) Open-Source Leverage Opportunities

1. Public schema docs and generated API reference.
2. "Connector SDK" for third-party wallet/import adapters.
3. Curated community packages:

- wallet sync providers,
- FX source adapters,
- tax rule packs.

4. Public benchmark datasets for valuation/tax correctness testing.
5. Reproducible scenario fixtures for bug reports.

## 7) Architectural Evolution Recommendations

## 7.1 App Architecture

- Introduce repository/use-case layer between providers and client transport.
- Keep Riverpod for orchestration and state.
- Centralize domain transforms (currency, valuation, tax projections).

## 7.2 Server Architecture

- Keep current service modules; add explicit bounded contexts:
  - `valuation/`
  - `digital_assets/`
  - `tax/`
  - `ai_assistant/`
- Add async worker subsystem for chain sync and periodic rate ingestion.

## 7.3 Data and Compute

- Store canonical monetary values in integer minor units.
- Store all derived valuation/tax outputs as reproducible snapshots.
- Add source metadata for all external price/rate inputs.

## 7.4 Reliability and Correctness

- Property-based tests for currency conversion and lot matching invariants.
- Golden tests for known tax scenarios.
- Idempotency guarantees on ingestion endpoints/jobs.

## 8) Suggested MVP Milestones

Milestone A: "Multi-Currency Truth" release

- Base valuation currency setting.
- Daily FX ingestion + historical series.
- Net worth in native + base currency with attribution.

Milestone B: "Solana Wallets" release

- Read-only wallet sync + holdings + valuation.
- Transaction timeline with token-level details.

Milestone C: "Tax Preview" release

- FIFO realized PnL by tax year.
- Exportable evidence report.

Milestone D: "AI Analyst Beta" release

- Explainable insights over valuation + tax data.
- Scenario analysis and optimization prompts.

## 9) KPI Framework

Product and trust metrics:

- Percentage of users with >1 active currency.
- Percentage of users with primary valuation currency configured.
- Valuation freshness SLA (e.g., rates < 24h old).
- Wallet sync success and lag metrics.
- Tax computation reproducibility pass rate.
- AI explanation acceptance rate (user marks as helpful/accurate).

## 10) Risk Register (Top)

1. Incorrect valuation due to stale/bad rates.

- Mitigation: source metadata, freshness checks, confidence fields.

2. Tax logic ambiguity across jurisdictions.

- Mitigation: explicit rulesets + jurisdiction profiles + versioned calculations.

3. Ledger inconsistency between account balances and transactions.

- Mitigation: define canonical balance policy and enforce at server level.

4. Premature AI layer without reliable accounting primitives.

- Mitigation: ship AI only after valuation/tax correctness baseline.

## 11) Contributor Lane Proposals

Good lanes for community contributions:

- FX source adapters.
- Solana indexer connectors.
- CSV import format packs and parsers.
- Jurisdiction-specific tax rule modules.
- Explainability UI components (diff, attribution, lot trace views).
- Test fixtures for reproducible accounting/tax edge cases.

## 12) Recommended Next Concrete Steps

1. Write RFC: "Currency and Valuation Core" (schema + API + UI integration).
2. Implement Phase 0 hardening items before domain expansion.
3. Stand up `valuation` bounded context with rate ingestion and snapshot endpoints.
4. Draft Solana wallet ingestion RFC with idempotency and replay model.
5. Define tax-lot data model and FIFO engine test fixtures.
