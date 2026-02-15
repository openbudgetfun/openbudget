# OpenBudget

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
- Docker — for Serverpod database services (optional, devenv provides postgres/redis natively)

## Setup

```bash
# 1. Enter the development environment
devenv shell

# 2. Resolve workspace dependencies
dart pub get

# 3. Start database services
devenv up

# 4. Apply database migrations and start the server
server:start
```

## Project Structure

```
openbudget/
├── openbudget_app/           # Flutter application
├── openbudget_server/        # Serverpod backend
├── openbudget_client/        # Generated Serverpod client
├── openbudget_core/          # Shared Dart models & utilities
├── openbudget_ui/            # Shared widgets & theme
├── openbudget_lints/         # Centralized lint rules
├── openbudget_test_utils/    # Shared test helpers
├── docker-compose.yaml       # Docker services for CI/prod
├── pubspec.yaml              # Workspace root with melos config
└── devenv.nix                # Development environment config
```

## Development Commands

```bash
# Analysis & testing
melos run analyze              # Lint all packages
melos run test                # Run all tests
melos run test:flutter        # Run Flutter tests only

# Formatting
melos run format              # Format Dart code
dprint fmt                    # Format JSON, YAML, Markdown, TOML

# Code generation
melos run generate            # Run build_runner
melos run serverpod:generate  # Run Serverpod code generation

# Utilities
melos run clean               # Clean all Flutter packages
melos run upgrade              # Upgrade dependencies
```

## Architecture

- **Envelope budgeting** — zero-sum model where every unit of income is assigned to a category
- **Cloud-first** — all data stored on Serverpod backend with PostgreSQL
- **Riverpod + Hooks** — state management following repository → service → provider → UI pattern
- **Multi-currency native** — first-class support for multiple currencies including crypto
- **AI-first** — financial intelligence features integrated into the budgeting workflow
