# OpenBudget

[![CI](https://github.com/openbudgetfun/openbudget/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/openbudget/actions/workflows/ci.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?logo=flutter)](https://flutter.dev)
[![Serverpod](https://img.shields.io/badge/Serverpod-4.1-blue)](https://serverpod.dev)
[![License](https://img.shields.io/github/license/openbudgetfun/openbudget)](LICENSE)

Envelope budgeting for people whose money lives in more than one currency. Give every dollar, pound, euro or naira a job, see your net worth across currencies, keep household and business books, and know what you owe in tax.

[Website](https://openbudget.app) · [Web app](https://app.openbudget.app) · [How to use OpenBudget](docs/how-to-use-openbudget.md) · [Support](https://openbudget.app/support) · [Privacy](https://openbudget.app/privacy)

## What it does

- **Envelope budgeting.** Assign income to envelopes month by month, move money between them, set goals, and see what is overspent or underfunded at a glance.
- **Every currency, honestly.** Each account keeps its own currency. Net worth converts into the one you choose and shows the rate, its source and its age.
- **All your accounts.** Bank, cash, card and loan accounts, reconciliation, linked banks through Plaid, CSV import, and Bitcoin, Solana and XRP Ledger wallets by public address.
- **Tidy transactions.** Splits, search, bulk edits, duplicate detection, payee rules, and recurring bills that post themselves.
- **Books for a business.** Separate books for a person, a household, a sole trade or a company, with optional double-entry journals, a chart of accounts and a trial balance.
- **Tax reports.** Full reports for the UK, the US, Nigeria and Germany with sources for every figure, and tax-year facts and an accountant export for every other country.
- **The Money guide.** An assistant that answers questions about your budget and tax, cites its sources, and only ever proposes changes for you to apply. You can also connect your own OpenAI-compatible provider, or any MCP client through a revocable access token ([docs/agent-mcp.md](docs/agent-mcp.md)).

Budgeting, accounts, wallets, net worth and books are free. OpenBudget Plus adds tax reports and the Money guide for $20 a month. Tax reports and the Money guide are guidance, not regulated financial or tax advice.

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
git clone https://github.com/openbudgetfun/openbudget.git
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
├── openbudget_scripts/       # Repository tooling (brand rendering, checks)
├── openbudget_site/          # The openbudget.app landing and policy pages
├── brand/                    # Logo sources
├── docs/                     # Guides, design notes and research
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

# Seeker on USB, plus Postgres, Redis, and Serverpod.
# Prefers this machine's Tailscale address, then the LAN address,
# then USB port forwarding when the phone cannot route there.
devenv shell dev:seeker
devenv shell dev:seeker:status
devenv shell dev:seeker:reload
devenv shell dev:seeker:hot-restart
devenv shell dev:seeker:stop
```

`dev:seeker` discovers the attached Android device. Set
`SEEKER_DEVICE_ID=<serial>` only when more than one device is ready, and keep
`adb` (Android platform tools) on `PATH`. The runner probes the API port from
the phone and picks Tailscale, then LAN, then `adb reverse`. `OPENBUDGET_API_URL`
set in the environment wins and is never rewritten; otherwise `.tmp/flutter.env`
records the chosen URL. Start, stop, and restart serialize per checkout, while
status and reload stay available. The runner records the chosen device serial
and each reverse mapping it creates, so stop only signals the process this
checkout started and removes only those mappings on that device. Preexisting
`adb reverse` rules are reused, never overwritten, and another attached phone
is never touched. Postgres, Redis, and Serverpod keep running for the next run.

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
lint:l10n                      # Fail on hardcoded UI text in app source
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

## Releases and store listings

Versions and release notes come from changesets with [monochange](https://github.com/monochange/monochange). Every pull request that changes a package adds a file under `.changeset/`: a developer type lands in `CHANGELOG.md`, and a `user_*` type lands in `WHATS_NEW.md` and the in-app "What's new" sheet.

```bash
monochange run change --package openbudget_app --type user_feat --reason "..."
monochange check               # Validate changesets and manifests
monochange preview             # Dry-run the next release
```

The App Store and Google Play listing text lives in [`openbudget_app/fastlane/`](openbudget_app/fastlane/README.md): name, tagline, description, keywords and release notes, plus the answers for the stores' privacy forms in [`store-privacy.md`](openbudget_app/fastlane/store-privacy.md). The listings link to the privacy policy, terms, support and account deletion pages in `openbudget_site`.

## Privacy

OpenBudget stores what you enter on its server so your budget is the same on every device. It does not sell data, show ads, or track you across apps. The [privacy policy](https://openbudget.app/privacy) lists everything the code collects and every outside service that receives any of it, and [`store-privacy.md`](openbudget_app/fastlane/store-privacy.md) maps each item to the code behind it.

## Architecture

- **Envelope budgeting** — zero-sum model where every unit of income is assigned to a category
- **Cloud-first** — all data stored on the backend with PostgreSQL
- **Riverpod + Hooks** — state management following repository > service > provider > UI pattern
- **Multi-currency native** — first-class support for multiple currencies including crypto
- **AI-first** — financial intelligence features integrated into the budgeting workflow

## License

OpenBudget is licensed under the [Apache License 2.0](LICENSE).
