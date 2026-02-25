# OpenBudget Migration Progress

Last updated: 2026-02-25

This checklist tracks progress for migrating and polishing app flows using the `ynab-ui` reference set while enforcing OpenBudget branding.

## Completion Snapshot

- Core flow migration: 100% complete
- Critical Patrol coverage: 100% complete
- Ongoing parity polish: in progress

## Flow Checklist

- [x] Auth and onboarding flow parity
- [x] Plan screen (Categories/Spotlight) parity
- [x] Settings root, plan settings, currency, display options parity
- [x] App icon switching and dark-mode parity
- [x] Accounts list/detail/loan/reconcile/edit flow parity
- [x] Add Accounts staged loading and search flow parity
- [x] Add Accounts desktop/tablet search layout parity
- [x] Add Accounts search submit behavior regression fix
- [x] Add Accounts desktop unlinked-account form/success parity coverage
- [x] Add Accounts unlinked flow stability hardening (isolated step scroll state + keyed form controls)
- [x] Add Accounts desktop screenshot capture hardening (targeted boundary capture for unlinked-account form artifacts)
- [x] Transaction review + action sheet flow parity
- [x] Recent Moves tabs, coach dialog, and drilldown parity
- [x] Recent Moves desktop tab-switch regression coverage
- [x] Reflect dashboard + Spending Breakdown + Net Worth parity
- [x] Spending Breakdown preset range recalculation regression coverage
- [x] Spending Breakdown desktop preset-range parity regression coverage

## Testing and CI Checklist

- [x] Patrol integration suite enabled for critical flows
- [x] Patrol runner hardened with hidden-failure marker detection and per-file failure accounting
- [x] Patrol runner optimized with shared dependency resolution and `--no-pub`
- [x] Formatting, lint, and secrets git hooks configured in `devenv.nix`
- [x] Branding guard test prevents shipping `YNAB` strings in app UI sources

## Screenshot Artifacts

- [x] Each migration/parity PR includes runtime screenshots uploaded to Backblaze `openbudget` bucket
- [x] `docs/openbudget-screenflows.md` updated as screenshots are added

## Next Backlog (Polish)

- [x] Add wider desktop Patrol coverage for additional account-management states (edit account, reconcile prompt)
- [x] Add explicit guardrail tests for account-link loading overlays on large viewports
- [x] Stabilize Add Accounts Patrol interactions with visibility-safe helpers and keyed account-type selection
- [x] Re-run full Patrol suite end-to-end via `tools/run_patrol_integration_tests.sh` and keep CI parity (`14/14` files green)
- [ ] Continue tightening copy and spacing parity for any newly identified visual drift
