---
openbudget_app: feat
---

# Show bundled release notes after an update

Add a release-notes pipeline for the app. `monochange` already writes `openbudget_app/assets/release_notes/<version>.json`; the app now reads it, tracks the last seen version in shared preferences, and opens a bottom sheet once after the signed-in shell builds.

- Freezed models and a tolerant parser for the notes shape, with malformed files surfaced as an error state instead of a crash.
- `WhatsNewRepository` over an injectable `AssetBundle` and a `package_info_plus` app version behind an overridable provider.
- A hand-drawn sheet with section headers, entry summaries, and a small renderer for paragraphs, bullets, and bold text.
- A What's new row in Settings that opens the current version's notes on demand, plus an empty state when no file is bundled.
- Unit, widget, and Patrol coverage for parsing, loading, seen tracking, rendering, and the update flow.
- Settings shows the installed version from `package_info_plus` instead of a hard-coded `1.0.0 (1)` string.
