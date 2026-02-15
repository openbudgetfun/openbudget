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
| `openbudget_wired`      | Flutter package  | Hand-drawn wired UI components (ported from verily_wired)   |
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
melos run test               # Run tests in all packages
melos run format             # Format all Dart code
dprint check                 # Check non-Dart formatting (JSON, YAML, MD, TOML)
dprint fmt                   # Fix non-Dart formatting

# Code generation
melos run generate           # Run build_runner in all packages
melos run generate:watch     # Run build_runner in watch mode
melos run serverpod:generate # Run Serverpod code generation

# Server
server:start                 # Start Serverpod dev server (devenv script)
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
- CI enforces this via a grep check that fails on any `extends StatefulWidget` or `extends StatelessWidget`

### Provider Pattern

All providers MUST use `riverpod_annotation` (`@riverpod`). No manual `StateNotifierProvider` or `ChangeNotifierProvider`. The generated provider name follows the pattern: class `FooNotifier` → `fooProvider`, function `bar` → `barProvider`.

### Freezed Models

All state objects and DTOs MUST use `@freezed`. Use sealed class union types for states (e.g., `AuthState.authenticated`, `AuthState.unauthenticated`, `AuthState.loading`).

### Wired UI

All user-facing components MUST use `openbudget_wired` widgets (`WiredButton`, `WiredInput`, `WiredCard`, `WiredCombo`, `WiredCheckbox`, `WiredToggle`, etc.). No raw Material buttons/inputs in feature screens. The wired components are re-exported via `openbudget_ui`.

### Localization (i18n)

All user-visible strings MUST come from `AppLocalizations`. No hardcoded strings in widgets. ARB files live in `openbudget_app/lib/l10n/`. Generated code outputs to `openbudget_app/lib/l10n/generated/`.

### Testing Discipline

The project follows a full testing pyramid:

- **Unit tests**: Every provider and utility function. Located in `test/` mirroring `lib/` structure.
- **Widget tests**: Every screen. Located in `test/`, uses `pumpApp` from `openbudget_test_utils` for consistent wrapping.
- **E2E / Integration tests**: Every major feature flow. Located in `integration_test/`, uses Patrol with the page object pattern.

**No feature is considered complete without Patrol E2E tests** covering the primary user flow. All E2E tests MUST use the page object pattern (selectors centralized in `integration_test/common/patrol_helpers.dart`). Test data lives in `integration_test/common/test_data.dart`.

### Debugging with MCP Tools

When investigating a bug or verifying a feature, **always use the appropriate MCP tool to visually confirm behavior** rather than relying solely on test output.

- **`mobile-mcp`**: Use when debugging visual behavior on iOS Simulator or Android Emulator. Launch the app, take screenshots, tap elements, inspect accessibility snapshots. Preferred for verifying UI rendering, navigation flows, and platform-specific behavior.
- **`dart-mcp`**: Use when debugging the Flutter widget tree, inspecting widget properties, provider state, and render objects at runtime. Preferred for diagnosing layout issues, state mismatches, and widget hierarchy problems.
- **`playwright` (already available)**: Use when debugging Flutter web behavior. Navigate, screenshot, click, inspect DOM.
- **`peekaboo` (already available)**: Use when debugging macOS desktop builds. Screenshot, click, type, interact with the running desktop app.

### Navigation

Use `GoRouter` for all navigation. Routes are defined in `app_router.dart` with `@riverpod`. Route constants live in `route_names.dart`. Auth redirects are handled in the router's `redirect` callback.

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

All PRs must pass: analyze, test, format, integration-test, widget-ban, secrets-scan.

## Constitution

See `.specify/memory/constitution.md` for the full project constitution (v1.0.0). All code must comply with its 10 core principles.

## Tech Stack

- **Flutter** (latest stable) — all platforms
- **Serverpod** 3.3.0 — backend with PostgreSQL
- **Riverpod** + **Flutter Hooks** — state management
- **Freezed** — immutable models
- **Shorebird** — code push (iOS/Android)
- **Devenv** — reproducible dev environment
- **GoRouter** — declarative routing with auth redirects
- **Melos** 7.x — monorepo tooling (config in root `pubspec.yaml`, no `melos.yaml`)
- **Patrol** — E2E integration testing
- **dprint** — non-Dart formatting
