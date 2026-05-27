---
all: patch
---

# Enforce localization usage and migrate hardcoded app text

Migrates user-visible strings to `AppLocalizations` across key app screens and adds a `lint:l10n` check to prevent new hardcoded UI text in `openbudget_app/lib/src`.
