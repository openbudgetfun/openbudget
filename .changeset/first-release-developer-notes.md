---
openbudget_app:
  type: native
  version: "1.0.0"
openbudget_client: feat
openbudget_core: feat
openbudget_server: feat
openbudget_ui: feat
---

# Ship the first OpenBudget release

The first release of the OpenBudget workspace: a Flutter app on Serverpod 4.1 with Riverpod, Hooks, Freezed and GoRouter, released together as the `openbudget` group. It is a `native` release because it adds RevenueCat, `url_launcher`, `package_info_plus` and the Solana Kit wallet packages, so it ships through the stores rather than as a Shorebird patch.

## Platform

- Flutter 3.47.7, Dart 3.13 and Serverpod 4.1.0, with the protocol and providers regenerated and the module schema migration applied.
- `monochange` replaces knope for changeset-only releases, with a developer stream (`CHANGELOG.md`, GitHub release body) and a user stream (`WHATS_NEW.md` and `openbudget_app/assets/release_notes/<version>.json`).
- The infrastructure-as-code and spec-driven tooling are gone; CI checks analyze, tests, formatting, Patrol flows, the widget ban, pinned dependencies, secrets and the generated icon catalog.
- `avoid_stateful_widgets` in `openbudget_lints` now rejects `StatelessWidget` as well as the stateful widget types, so every widget is a `HookWidget` or `HookConsumerWidget`.

## Budgeting

- Endpoints and models for budgets, categories, envelopes, monthly allocations, goals, transactions (splits, transfers, reconciliation, bulk edits, duplicate detection, CSV import), recurring transactions with auto-posting, payees, transaction rules, reports, FX rates with backend snapshots, institutions with multi-region catalog seeding, Plaid connections, and Solana wallet interpretation and valuation.
- Real-time budget stream updates, email authentication through `serverpod_auth_idp`, and auth-aware routing.
- Every budgeting currency the server writes is validated against `CurrencyCode` (`ValidationException` for unsupported codes, normalized codes stored). The app formats unknown codes as the raw code plus a plain amount and keys aggregations by code, so nothing is silently shown as USD. Wallet asset symbols and Plaid currencies are left untouched.

## Design

- `openbudget_ui` is rebuilt on the Skribble hand-drawn design system: palette roles resolve through the Skribble theme, a generated `OpenBudgetIcons` catalog of `SkribbleIcon` artwork, and `Ob*` cards, panels and buttons. Every screen is restyled with readable text and every existing action kept.

## Tax

- `openbudget_core` gains a tax engine contract and rule packs for the United Kingdom (including Scottish rates and student loans), the United States federal system, Nigeria and Germany, for individuals, sole traders and limited companies.
- The server stores tax profiles and categorisation, converts amounts between currency minor units, and builds country reports with bands, return references, opportunities and rule-source metadata.
- The app adds the tax overview, profile form and category sheet, with provider, widget and Patrol coverage.

## OpenBudget Plus

- `entitlement` table, `EntitlementService` and `BillingEndpoint.getEntitlement`. Each rail records its own subscription row; access holds through `currentPeriodEnd` and the period ending last wins. `BillingPlan` fixes $10 a month with $1 of built-in agent usage.
- Stripe Checkout and billing portal sessions with signed webhooks, RevenueCat App Store and Play Store webhooks, and the Solana Subscriptions Delegation Program rail with a wallet ownership challenge, on-chain verification and an hourly collector that charges 10 USDC per 30-day period. Confirming a Solana subscription never charges twice, and a failed first payment grants nothing.
- The app's `/plus` screen offers RevenueCat on mobile, Stripe on web and desktop, and Solana USDC on web.

## Agent

- `AgentEndpoint` runs a tool-calling assistant on OpenCode Zen (`deepseek-v4.1-flash`) or the user's own OpenAI-compatible provider, metered at published prices against the included allowance. Bring-your-own keys are stored with AES-256-GCM, and provider URLs that resolve to internal addresses are refused.
- The assistant never writes data: propose tools record pending `AgentProposal`s that the user applies or dismisses, claimed atomically so a proposal applies once.
- A Streamable HTTP MCP server at `POST /mcp` exposes the same tools to external agents through revocable personal access tokens (`AgentTokenEndpoint`), stored as SHA-256 hashes and rate limited per token. The app adds an Agent access screen to create, copy once and revoke them.
- The app adds the assistant chat, proposals and provider screens.

## Errors and release notes

- Every server exception is a Serverpod serializable exception declared in `openbudget_server/lib/src/exceptions/*.spy.yaml`, so clients match on types such as `ValidationException(message:)` and `EntitlementRequiredException` instead of a generic 500.
- The app reads the bundled release notes, shows them once after an update, and keeps them available from Settings.
