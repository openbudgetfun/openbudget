# OpenBudget

[![CI](https://github.com/openbudgetfun/openbudget/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/openbudget/actions/workflows/ci.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Serverpod](https://img.shields.io/badge/Serverpod-3.3-blue)](https://serverpod.dev)
[![Pulumi](https://img.shields.io/badge/Pulumi-IaC-8A3391?logo=pulumi)](https://www.pulumi.com)
[![License](https://img.shields.io/github/license/openbudgetfun/openbudget)](LICENSE)

Cross-platform envelope budgeting app with AI-driven financial intelligence.

## Platforms

- iOS 16+
- Android API 26+
- Web (Chrome, Edge, Firefox — latest two versions)
- macOS 13+
- Windows 10+
- Linux (Ubuntu 22.04+)

## Prerequisites

- [Devenv](https://devenv.sh/) — manages development environment, services, and scripts
- [FVM](https://fvm.app/) — Flutter version management

## Getting Started

```bash
# 1. Clone and enter the repo
git clone https://github.com/openbudget/openbudget.git
cd openbudget

# 2. Start the devenv shell (installs all tools automatically)
devenv shell

# 3. Install dependencies
dart pub get

# 4. Run code generation
runner:build
runner:serverpod

# 5. Start everything (Postgres + Redis + server)
devenv up

# 6. In another terminal, follow local service logs
tail -f ./.tmp/log.txt

# 7. In a separate terminal, run the app (dev flavor)
flutter:app run -t lib/main_dev.dart -d macos
```

That's it. `devenv up` starts Postgres, Redis, and the backend server in one command. The server waits for the databases to be healthy before starting.

## Project Structure

```
openbudget/
├── openbudget_app/           # Flutter application
├── openbudget_server/        # Serverpod backend
├── openbudget_client/        # Generated client protocol
├── openbudget_core/          # Shared Dart models & utilities
├── openbudget_ui/            # Shared widgets & theme
├── openbudget_lints/         # Centralized lint rules
├── openbudget_test_utils/    # Shared test helpers
├── infra/                    # Pulumi infrastructure (AWS + GCP)
├── pubspec.yaml              # Workspace root
└── devenv.nix                # Development environment config
```

## Branding

Branding rules and naming constraints are documented in `docs/branding.md`.

Solana wallet + flavor setup instructions are in `docs/solana-and-flavors-setup.md`.

## Commands

All commands run from the repo root. No need to `cd` into subdirectories.

### Running the App

```bash
# Dev flavor (staging/dev cluster)
flutter:app run -t lib/main_dev.dart -d macos
flutter:app run -t lib/main_dev.dart -d chrome
flutter:app run -t lib/main_dev.dart -d android
flutter:app run --flavor dev -t lib/main_dev.dart -d ios
flutter:app run --flavor dev -t lib/main_dev.dart -d android

# Prod flavor (production cluster)
flutter:app run -t lib/main_prod.dart -d macos
flutter:app run -t lib/main_prod.dart -d chrome
flutter:app run --flavor prod -t lib/main_prod.dart -d ios
flutter:app run --flavor prod -t lib/main_prod.dart -d android

# Build web
flutter:app build web
```

Environment routing defaults:

- `main_dev.dart` -> `https://api-staging.openbudget.app/`
- `main_prod.dart` / `main.dart` -> `https://api.openbudget.app/`
- iOS `dev` flavor bundle id: `com.openbudget.app.dev` (`OpenBudget Dev`)
- iOS `prod` flavor bundle id: `com.openbudget.app` (`OpenBudget`)
- `openbudget_app/pubspec.yaml` sets `default-flavor: dev` for tooling that
  cannot pass `--flavor`
- Override for any build: `--dart-define=API_URL=https://your-api-host`

Legacy local override support is also available with
`--dart-define=OPENBUDGET_API_URL=http://192.168.1.10:8080`.

### Services

```bash
devenv up                      # Start Postgres + Redis + server (all-in-one)
server:start                   # Start the server manually (without devenv)
tail -f ./.tmp/log.txt         # Follow process-compose logs while developing
```

### Testing

```bash
test:all                       # Run tests in all packages
test:flutter                   # Run Flutter tests only
test:integration               # Run Patrol integration tests
flutter:app test               # Run app tests only
```

### Analysis and Formatting

```bash
lint:analyze                   # Lint all packages
lint:all                       # Run all linting (format check + analyze)
format:all                     # Format all code (Dart + JSON/YAML/Markdown)
format:check                   # Check non-Dart formatting without fixing
docs:workflows:update          # Sync reusable markdown workflow template blocks
docs:workflows:check           # Verify workflow docs are synced to templates
```

### Code Generation

```bash
runner:build                   # Generate code (Freezed, Riverpod, etc.)
runner:serverpod               # Generate server protocol and client
runner:watch                   # Generate code in watch mode
```

### Utilities

```bash
clean:all                      # Clean all packages
update:deps                    # Update all dependencies
```

## Logging

When developing locally with `devenv up`, `process-compose` writes service logs
to a shared file.

### Log File

The log file is:

```
./.tmp/log.txt
```

This file is gitignored. To follow logs in real time:

```bash
tail -f ./.tmp/log.txt
```

Check this file first whenever local development issues appear (startup,
database connectivity, server errors, etc.).

### PostHog Analytics (Production Only)

In release builds, [PostHog](https://posthog.com) handles product analytics. It is completely disabled in debug mode. Pass the API key at build time:

```bash
flutter:app run --dart-define=POSTHOG_API_KEY=phc_xxx
```

## Architecture

- **Envelope budgeting** — zero-sum model where every unit of income is assigned to a category
- **Cloud-first** — all data stored on the backend with PostgreSQL
- **Riverpod + Hooks** — state management following repository > service > provider > UI pattern
- **Multi-currency native** — first-class support for multiple currencies including crypto
- **AI-first** — financial intelligence features integrated into the budgeting workflow
