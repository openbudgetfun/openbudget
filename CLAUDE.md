# OpenBudget — AI Assistant Context

## Project Overview

OpenBudget is a cross-platform envelope budgeting app built with Flutter and Serverpod. It targets iOS, Android, Web, macOS, Windows, and Linux from a single codebase. The app is cloud-first (no offline/local-first) with AI-driven financial intelligence features.

## Repository Structure

| Package                 | Type             | Description                                                 |
| ----------------------- | ---------------- | ----------------------------------------------------------- |
| `openbudget_app`        | Flutter app      | Main application entry point                                |
| `openbudget_server`     | Serverpod server | Backend API and business logic                              |
| `openbudget_client`     | Dart package     | Generated Serverpod client protocol                         |
| `openbudget_core`       | Dart package     | Shared models, constants, utilities (no Flutter dependency) |
| `openbudget_ui`         | Flutter package  | Shared widgets, theme, design tokens                        |
| `openbudget_lints`      | Dart package     | Centralized lint rules (all packages depend on this)        |
| `openbudget_test_utils` | Flutter package  | Shared test helpers (`pumpApp`, etc.)                       |

## Dependency Graph

```
openbudget_app → openbudget_ui → openbudget_core
               → openbudget_client
               → openbudget_server (via Serverpod protocol)

openbudget_test_utils → openbudget_ui → openbudget_core

All packages → openbudget_lints (dev dependency)
```

## Key Commands

```bash
# Development environment (requires devenv)
devenv up                    # Start postgres + redis

# Package management
dart pub get                 # Resolve workspace dependencies
melos run analyze             # Alias: melos analyze

# Code quality
melos run analyze             # Run dart analyze across all packages
melos run test               # Flutter and pure Dart tests (server tests need Postgres; run them in openbudget_server)
melos run format             # Format all Dart code
dprint check                 # Check non-Dart formatting (JSON, YAML, MD, TOML)
dprint fmt                   # Fix non-Dart formatting

# Code generation
melos run generate           # Run build_runner in all packages
melos run generate:watch     # Run build_runner in watch mode
melos run serverpod:generate # Run Serverpod code generation

# Server
server:start                 # Start Serverpod dev server (devenv script)

# Releases (monochange)
monochange run change --package openbudget_app --type user_feat --reason "..."  # Create a changeset
monochange check             # Validate changesets and manifests
monochange preview           # Dry-run the next release (also catches mixed-stream changesets)
monochange run notes         # Render the developer and user release notes
```

## Architecture Decisions

- **State management**: Riverpod + Flutter Hooks. No `setState` outside trivial leaf widgets.
- **Provider pattern**: repository → service → provider → UI
- **Immutability**: State is immutable; mutations produce new state objects via Freezed.
- **Code generation**: Serverpod, Riverpod, Freezed. Generated code (`*.g.dart`, `*.freezed.dart`) MUST be committed.
- **Multi-currency**: First-class concern in every data model and UI component.
- **Cloud-first**: All data lives on Serverpod backend. No offline-first layer.
- **Code push**: Shorebird for OTA updates on iOS/Android.

## Coding Conventions

### Hooks-First Composition — No StatefulWidget, No StatelessWidget

**Absolutely no `StatefulWidget` or `StatelessWidget` anywhere in the codebase.** This rule has zero exceptions.

- Widgets that need Riverpod: use `HookConsumerWidget`
- Widgets that don't need Riverpod: use `HookWidget`
- All reusable stateful logic MUST be extracted into custom hooks (`use*` functions)
- Use `useTextEditingController`, `useState`, `useEffect`, `useAnimationController`, `useMemoized`, etc.
- CI enforces this through the `avoid_stateful_widgets` rule in `openbudget_lints`: `dart analyze --fatal-infos` fails on any widget that extends `StatelessWidget`, `StatefulWidget`, or their Riverpod stateful variants

### Provider Pattern

All providers MUST use `riverpod_annotation` (`@riverpod`). No manual `StateNotifierProvider` or `ChangeNotifierProvider`. The generated provider name follows the pattern: class `FooNotifier` → `fooProvider`, function `bar` → `barProvider`.

### Freezed Models

All state objects and DTOs MUST use `@freezed`. Use sealed class union types for states (e.g., `AuthState.authenticated`, `AuthState.unauthenticated`, `AuthState.loading`).

### Localization (i18n)

All user-visible strings MUST come from `AppLocalizations`. No hardcoded strings in widgets. ARB files live in `openbudget_app/lib/l10n/`. Generated code outputs to `openbudget_app/lib/l10n/generated/`.

### Testing Discipline

The project follows a full testing pyramid:

- **Unit tests**: Every provider and utility function. Located in `test/` mirroring `lib/` structure.
- **Widget tests**: Every screen. Located in `test/`, uses `pumpApp` from `openbudget_test_utils` for consistent wrapping.
- **E2E / Integration tests**: Every major feature flow. Located in `integration_test/`, uses Patrol with the page object pattern.

**No feature is considered complete without Patrol E2E tests** covering the primary user flow. All E2E tests MUST use the page object pattern (selectors centralized in `integration_test/common/patrol_helpers.dart`). Test data lives in `integration_test/common/test_data.dart`.

**AI agents MUST test everything they create.** When implementing a feature or fix — whether frontend UI, backend endpoints, providers, or utilities — the agent MUST also write and run the corresponding tests (unit, widget, and/or integration) before considering the work complete. No code should be committed without verifying it passes `melos run test` and `melos run analyze`. Both frontend and backend changes require test coverage.

### Debugging with MCP Tools

When investigating a bug or verifying a feature, **always use the appropriate MCP tool to visually confirm behavior** rather than relying solely on test output.

- **`mobile-mcp`**: Use when debugging visual behavior on iOS Simulator or Android Emulator. Launch the app, take screenshots, tap elements, inspect accessibility snapshots. Preferred for verifying UI rendering, navigation flows, and platform-specific behavior.
- **`dart-mcp`**: Use when debugging the Flutter widget tree, inspecting widget properties, provider state, and render objects at runtime. Preferred for diagnosing layout issues, state mismatches, and widget hierarchy problems.
- **`playwright` (already available)**: Use when debugging Flutter web behavior. Navigate, screenshot, click, inspect DOM.
- **`peekaboo` (already available)**: Use when debugging macOS desktop builds. Screenshot, click, type, interact with the running desktop app.

### Navigation

Use `GoRouter` for all navigation. Routes are defined in `app_router.dart` with `@riverpod`. Route constants live in `route_names.dart`. Auth redirects are handled in the router's `redirect` callback.

### Accounting and Tax Domain Skills

Bookkeeping, invoicing, payroll and tax-return work follows the researched rules in `.claude/skills/` (also linked at `.agents/skills/`), not memory. Load the matching skill before changing that code: `double-entry-ledger`, `xero-migration`, `uk-personal-tax`, `uk-company-tax`, `uk-vat-payroll`, `us-federal-tax`, `nigeria-tax`, `germany-tax`, and `tax-planning-guardrails` for anything the assistant suggests. Each skill lists the figures it could not verify and when to re-check them. The scope and build order are in `docs/accounting-roadmap.md`. The plan for 20 countries and the universal layer is in `docs/tax-jurisdictions.md`, and the assistant (the Money guide) is designed in `docs/money-guide.md`.

## Version Management & Releases

### Changesets and Audience Streams (monochange)

The project uses [monochange](https://github.com/monochange/monochange) for **changeset-only** version management (`monochange.toml`). Conventional commits do **not** trigger version bumps; only `.changeset/*.md` files do. Every workspace package releases together as the `openbudget` group under one version.

Each changeset targets exactly one audience, chosen by its type:

| Stream                        | Types                                                                                              | Lands in                                                                                                |
| ----------------------------- | -------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| `default` (developers)        | `breaking`, `native`, `feat`, `fix`, `perf`, `refactor`, `security`, `chore`, `ci`, `docs`, `test` | `CHANGELOG.md` and the GitHub release body                                                              |
| `user` (people using the app) | `user_feat`, `user_improve`, `user_fix`                                                            | `WHATS_NEW.md` and `openbudget_app/assets/release_notes/<version>.json` (the in-app "What's new" sheet) |

- Every PR that changes a package **must** include a changeset; CI enforces it with `monochange check` and `monochange preview`.
- Write user changesets in product language: the outcome someone notices, never the implementation. Keep developer detail in a developer changeset.
- When one change matters to both audiences, write **two** changesets (one per stream). A single file whose types cross streams fails `monochange preview`.
- On push to `main`, `.github/workflows/release.yml` runs `monochange run release-pr`, which opens or refreshes the release PR on `chore/release/*`. Merging it lands a release commit, which the next run tags and publishes with `monochange run publish-release`.
- All packages are `publish_to: none`; nothing is published to pub.dev.

### App Versioning Rules (`openbudget_app`)

- **Major** bump = full app store release (native dependency changes — iOS Podfile, Android Gradle, etc.)
- **Minor/Patch** bump = Shorebird code push (Dart-only changes)
- CI runs a `native-change-check` job on PRs that warns when native files changed, signaling a major bump is needed

### Pinned App Dependencies

`openbudget_app/pubspec.yaml` must use **exact versions** for all external dependencies (no `^`, `>=`, or `~` ranges). Exceptions: `intl: any` (Flutter SDK peer), path deps, and SDK deps. CI enforces this via the `pinned-deps` job.

## Commit Conventions

### Conventional Commits (Mandatory)

- Format: `<type>: <description>`
- Types: `feat`, `fix`, `chore`, `docs`, `ci`, `test`, `refactor`
- Code/file references wrapped in backticks (e.g., \`openbudget_core\`)
- Emoji optional, encouraged for significant commits
- Generated code changes go in dedicated commits
- All warnings treated as errors in CI

### Feature Branch Workflow

All work MUST go through feature branches and pull requests. No direct commits to `main`. Branch naming: `feat/short-description`, `fix/short-description`, `chore/short-description`.

### No Secrets (Hard Rule)

- `**/config/passwords.yaml` gitignored for Serverpod secrets
- `.env` gitignored for Docker Compose credentials
- CI runs Gitleaks secrets scan on every push and PR
- If a secret is accidentally committed, rotate immediately

### CI Requirements

All PRs must pass the CI jobs: `analyze` (`dart analyze --fatal-infos` with the widget, palette and pinned-dependency rules), `format` (dprint), `Ban StatefulWidget and StatelessWidget`, `Secrets Detection` (Gitleaks), `lint` (Swift, workflow docs, localization and the generated icon catalog), `test`, `changesets`, `server-test`, `integration-test`, `Release config guard`, and `Detect native dependency changes`. The `main` ruleset requires `analyze`, `test`, `format`, `integration-test`, the widget ban and `Secrets Detection` by name.

### Database Migrations (Minimize)

- Each PR/feature MUST produce at most **one** Serverpod migration.
- If you modify multiple models in the same PR, run `serverpod create-migration` once after all model changes are complete.
- Never create incremental migrations for iterative tweaks within the same branch — squash into a single migration before opening the PR.
- Migration files (`openbudget_server/migrations/`) are committed alongside the code they support.

## Product Principles

- **Envelope budgeting is zero-sum.** Every unit of income is assigned to a category, and money can move between categories at any time.
- **Multi-currency is native.** Every model, calculation, and screen carries a currency. Conversions show their rate source and staleness and never silently round away value.
- **Cloud-first.** All persistent data lives on the Serverpod backend; the API contract is the single source of truth.
- **AI advice is guidance, not regulated advice.** Surface actionable insights in context and include an appropriate disclaimer.
- **Packages form a DAG.** Shared code lives in workspace packages that never depend on app code.

## Tech Stack

- **Flutter** (latest stable) — all platforms
- **Serverpod** 3.3.1 — backend with PostgreSQL
- **Riverpod** + **Flutter Hooks** — state management
- **Freezed** — immutable models
- **Shorebird** — code push (iOS/Android)
- **Devenv** — reproducible dev environment
- **GoRouter** — declarative routing with auth redirects
- **Melos** 7.x — monorepo tooling (config in root `pubspec.yaml`, no `melos.yaml`)
- **Patrol** — E2E integration testing
- **dprint** — non-Dart formatting
- **monochange** — changeset-based versioning with developer and user release-note streams
