---
openbudget_app: feat
openbudget_client: feat
openbudget_server: feat
openbudget_ui: feat
---

# Ship the envelope budgeting platform

The first release of the OpenBudget workspace: a Flutter app on Serverpod with Riverpod, Hooks, and GoRouter.

- Server endpoints and models for budgets, categories, envelopes, monthly allocations, goals, transactions (splits, transfers, reconciliation, bulk edits, duplicate detection, CSV import), recurring transactions with auto-posting, payees, transaction rules, reports, FX rates with backend snapshots, institutions with multi-region catalog seeding, Plaid connections, and Solana wallet interpretation and valuation.
- Real-time budget stream updates, email authentication through `serverpod_auth_idp`, and auth-aware routing with redirects.
- Localization enforced through `AppLocalizations` with a hardcoded-text check, theme palette and pinned-dependency lint rules in `openbudget_lints`, and widget-ban enforcement.
- Widget tests for every screen and Patrol end-to-end flows using the page object pattern.
