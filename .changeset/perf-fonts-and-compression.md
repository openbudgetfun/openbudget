---
openbudget_ui: perf
openbudget_app: perf
openbudget_server: perf
openbudget_site: chore
---

# Ship only the Skribble faces in use, gzip API responses, and measure it

- `openbudget_ui` no longer depends on `skribble_font_recursive`, whose pubspec registers all 129 Skribble faces (60 MB). It ships the 14 faces the theme letters with, trimmed of unused stylistic alternates by `tool/subset_fonts.sh` (2.9 MB, every character kept). Families now resolve as `packages/openbudget_ui/<family>`. Flutter web downloads every registered face before its first frame, so the web app's first load drops from 29.3 MB to 5.4 MB and its first frame on a slow 4G connection from 140 s to 26 s.
- `CompressionMiddleware` gzips endpoint results and web-server files for clients that accept it. Plan and transaction-list bodies shrink about tenfold.
- `appleid.auth.js` is deferred in `web/index.html`, and the app starts Apple sign-in and PostHog setup together instead of one after the other.
- `tools/perf/web_load.mjs` and `openbudget_server/test/benchmark/` measure load size, timings, statements and payloads; `docs/performance.md` records the numbers.
- `openbudget_site/tool/render_images.dart` reads the Gentle faces from the pub cache now that the workspace no longer resolves the full font package.
