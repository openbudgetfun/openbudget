# openbudget_app

Flutter client for OpenBudget.

## Flavors

OpenBudget uses environment entrypoints:

- `lib/main_dev.dart` -> staging/dev API cluster
- `lib/main_prod.dart` (and `lib/main.dart`) -> production API cluster
- `pubspec.yaml` sets `flutter.default-flavor: dev` for tooling that runs
  without explicit `--flavor`

## Run Commands

Run from repo root with devenv scripts:

```bash
# Dev
flutter:app run -t lib/main_dev.dart -d macos
flutter:app run -t lib/main_dev.dart -d android
flutter:app run --flavor dev -t lib/main_dev.dart -d android
flutter:app run --flavor dev -t lib/main_dev.dart -d ios

# Prod
flutter:app run -t lib/main_prod.dart -d macos
flutter:app run --flavor prod -t lib/main_prod.dart -d android
flutter:app run --flavor prod -t lib/main_prod.dart -d ios
```

API override for any build:

```bash
flutter:app run -t lib/main_dev.dart --dart-define=API_URL=https://localhost:8080
```
