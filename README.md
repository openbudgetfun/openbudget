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

# 6. In a separate terminal, run the app
flutter:app run -d macos
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

## Commands

All commands run from the repo root. No need to `cd` into subdirectories.

### Running the App

```bash
flutter:app run -d macos       # Run on macOS
flutter:app run -d chrome       # Run on web
flutter:app run -d ios          # Run on iOS simulator
flutter:app run -d android      # Run on Android emulator
flutter:app build web          # Build for web
```

### Services

```bash
devenv up                      # Start Postgres + Redis + server (all-in-one)
server:start                   # Start the server manually (without devenv)
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

Both the Flutter app and backend server write structured logs to a single shared file during development. This makes it easy to follow what's happening across the entire stack from one place.

### Log File

In development, all logs are written to:

```
.temp/logs/openbudget-dev.log
```

This file is gitignored. To follow logs in real time:

```bash
tail -f .temp/logs/openbudget-dev.log
```

### Log Format

Each line is structured as:

```
[2026-02-17T10:30:00.000] [INFO   ] [server] [BudgetService] Created budget id=42
[2026-02-17T10:30:01.000] [INFO   ] [flutter:macos] [Navigation] Push /home
```

The fields are: `[timestamp] [level] [source] [logger] message`

- **source** identifies where the log came from:
  - `server` — backend
  - `flutter:macos` / `flutter:web` / `flutter:ios-simulator` / `flutter:android-emulator` — app (automatically detected per platform)
- **logger** is the component name (e.g. `BudgetService`, `Navigation`)

### Auto-Truncation

The log file auto-truncates when it exceeds 10 MB, keeping the most recent 2 MB. No manual cleanup needed.

### Frontend Log Relay

In debug mode, the Flutter app batches log entries and sends them to the server every 2 seconds. The server writes them to the same log file, so you see both frontend and backend activity together. In release mode, log relay is disabled.

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
