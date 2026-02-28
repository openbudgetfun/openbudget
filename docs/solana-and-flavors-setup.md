# Solana Wallet + Flavor Setup

This document describes how to run OpenBudget with the new Solana wallet integration and environment-specific app flavors.

## 1) Secrets and Provider Config

Do not commit API keys.

Use Serverpod passwords (preferred) or process environment variables:

- `heliusApiKey` in `openbudget_server/config/passwords.yaml` (local only, gitignored)
- `HELIUS_API_KEY` environment variable as fallback

Example local `passwords.yaml` entry:

```yaml
heliusApiKey: "<your-helius-key>"
```

## 2) Running the Server

```bash
devenv up
```

or manually:

```bash
server:start
```

## 3) App Flavors

Entrypoints:

- `lib/main_dev.dart`: staging/dev API defaults (`https://api-staging.openbudget.app/`)
- `lib/main_prod.dart`: production API defaults (`https://api.openbudget.app/`)

Default flavor:

- `openbudget_app/pubspec.yaml` sets `flutter.default-flavor: dev`.
- This allows tooling that calls `flutter run` without `--flavor` to still build/install the dev variant.

Optional override for any build:

```bash
--dart-define=API_URL=https://your-api-host
```

## 4) Run Commands

### macOS / Web

```bash
# dev
flutter:app run -t lib/main_dev.dart -d macos
flutter:app run -t lib/main_dev.dart -d chrome

# prod
flutter:app run -t lib/main_prod.dart -d macos
flutter:app run -t lib/main_prod.dart -d chrome
```

### Android

```bash
# dev flavor (explicit)
flutter:app run --flavor dev -t lib/main_dev.dart -d android

# dev flavor (implicit via default-flavor)
flutter:app run -t lib/main_dev.dart -d android

# prod flavor
flutter:app run --flavor prod -t lib/main_prod.dart -d android
```

### iOS

Shared schemes and flavor-specific build configurations are now wired:

- `dev`
- `prod`
- `Debug-dev` / `Release-dev` / `Profile-dev`
- `Debug-prod` / `Release-prod` / `Profile-prod`

Bundle IDs / display names:

- Dev: `com.openbudget.app.dev` (`OpenBudget Dev`)
- Prod: `com.openbudget.app` (`OpenBudget`)

Use:

```bash
flutter:app run --flavor dev -t lib/main_dev.dart -d ios
flutter:app run --flavor prod -t lib/main_prod.dart -d ios
```

Build checks used during validation:

```bash
flutter:app run --flavor dev -t lib/main_dev.dart -d 63886201-1983-42F2-8DEA-51FBF6C0191C --no-resident
flutter:app run --flavor prod -t lib/main_prod.dart -d 63886201-1983-42F2-8DEA-51FBF6C0191C --no-resident
xcrun simctl listapps 63886201-1983-42F2-8DEA-51FBF6C0191C | rg "com.openbudget.app(\\.dev)?"
```

## 5) Solana Wallet Flow (Current)

1. Add account -> choose `Solana Wallet`.
2. Enter wallet address.
3. App creates account, attaches wallet, and runs initial sync.
4. Open account detail to:
   - view holdings,
   - view transaction history,
   - edit tx metadata (category/tags/memo),
   - trigger manual sync.

## 6) Mobile MCP Validation

For Dart/Flutter MCP launch tooling:

- Use `target: lib/main_dev.dart` for default mobile-MCP runs.
- Android launch now succeeds without explicit flavor args because `default-flavor: dev` is configured.
- Current MCP launcher does not expose `--flavor`, so production variant validation should still be done via CLI:

```bash
flutter:app run --flavor prod -t lib/main_prod.dart -d android
```

## 7) Mobile MCP Screenshot Workflow

To support screenshot capture in Mobile MCP, use the driver-enabled target:

```bash
flutter:app run -t test_driver/main_driver.dart -d android
```

Then use Mobile MCP `flutter_driver` screenshot command.

Current screenshot artifacts used in PR reviews are stored at:

- `docs/research/screenshots/2026-02-28/login-screen.png`
- `docs/research/screenshots/2026-02-28/login-email-focus.png`
- `docs/research/screenshots/2026-02-28/login-email-filled.png`

## 8) Known Gaps

- Valuation currently relies primarily on provider-returned price fields; fallback pricing adapters are tracked in backlog.
- Tax lot / deterministic realized P&L engine is tracked in backlog.
