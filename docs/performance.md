# Performance

The numbers OpenBudget is held to, how to measure them again, and what each change did to them. Every performance pull request adds a row to the history below with its before and after, measured the way this page describes. Lower is better everywhere.

## Current numbers

Measured on 2026-11-25 in a cloud session (4 vCPU, headless Chromium, PostgreSQL 16).

### Web app (`openbudget_app`, release build)

First load of `/` with an empty cache, until Flutter's `flutter-first-frame` event. "Slow 4G" is Lighthouse's mobile preset: 150 ms round trip, 1.6 Mbps down.

| Metric                         | Value                          |
| ------------------------------ | ------------------------------ |
| Bytes on the wire (brotli)     | 4.75 MB                        |
| Bytes after decoding           | 14.0 MB                        |
| Requests                       | 25                             |
| JavaScript on the wire         | 1.38 MB                        |
| Fonts downloaded               | 17 faces, 1.51 MB on the wire  |
| `main.dart.js`                 | 4.33 MB, 1.25 MB gzipped       |
| Deferred parts (after sign-in) | 69 files, 2.01 MB, 645 KB gzip |
| CanvasKit (`chromium` variant) | 5.43 MB, 1.85 MB on the wire   |
| First frame, unthrottled       | 702 ms (median of 3)           |
| First frame, slow 4G           | 22.5 s (median of 3)           |
| Splash painted, slow 4G        | 352 ms                         |
| Font assets in the bundle      | 17 files, 3.16 MB (all builds) |

### Website (`openbudget_site`, `build/jaspr`)

| Metric                       | Value   |
| ---------------------------- | ------- |
| Home page bytes on the wire  | 92.5 KB |
| Home page requests           | 11      |
| First contentful paint, 4G   | 644 ms  |
| Largest contentful paint, 4G | 884 ms  |
| Whole build, uncompressed    | 481 KB  |

### API reads (`openbudget_server`)

The reads the app makes when it opens a book, against a household book of 4 accounts, 40 envelopes and 3,600 transactions over 24 months. Time is the endpoint method (database and logic, not the network), median and 95th percentile of 25 calls after 3 warm-ups. Statements are the SQL statements one call sends. Wire bytes are the JSON body gzipped, which is what `CompressionMiddleware` now sends.

| Call                            | p50     | p95      | Statements | JSON    | On the wire |
| ------------------------------- | ------- | -------- | ---------- | ------- | ----------- |
| `entity.listSummaries`          | 31.5 ms | 35.1 ms  | 10         | 658 B   | 658 B       |
| `entity.list`                   | 1.4 ms  | 1.6 ms   | 1          | 426 B   | 426 B       |
| `budget.getMonth`               | 29.9 ms | 136.1 ms | 9          | 21.5 KB | 2.2 KB      |
| `transaction.list` (first page) | 13.5 ms | 15.3 ms  | 6          | 42.5 KB | 4.1 KB      |
| `account.list`                  | 2.5 ms  | 3.5 ms   | 2          | 1.4 KB  | 374 B       |
| `category.list`                 | 2.5 ms  | 2.8 ms   | 2          | 2.1 KB  | 425 B       |
| `envelope.list`                 | 4.5 ms  | 6.3 ms   | 3          | 12.5 KB | 1.4 KB      |
| `report.ageOfMoney`             | 15.3 ms | 17.8 ms  | 4          | 2 B     | 2 B         |

Bodies under 1 KB are sent as they are, since the gzip framing would eat most of the gain.

## How to measure

### Web app and website

`tools/perf/web_load.mjs` serves a build directory the way a CDN does (brotli or gzip when the browser accepts it), loads it in headless Chromium with an emulated network and prints one JSON object: timings, requests, wire and decoded bytes, split by kind. Requests to other hosts (Apple and Google sign-in scripts) are blocked and listed, because a sandbox cannot reach them and they are outside what the build controls.

```sh
# Web app: build with CanvasKit served from the build, not gstatic.com.
cd openbudget_app
flutter build web --release -t lib/main_prod.dart --no-web-resources-cdn
cd ..
node tools/perf/web_load.mjs openbudget_app/build/web --flutter --network none --runs 3
node tools/perf/web_load.mjs openbudget_app/build/web --flutter --network 4g --runs 3

# Website
(cd openbudget_site && dart run tool/build.dart)
node tools/perf/web_load.mjs openbudget_site/build/jaspr --network 4g --runs 3
```

To see what fills `main.dart.js`, build with `--source-maps` and attribute its bytes to packages (add `--files` for single files, or `--bundle main.dart.js_1.part.js` for a deferred part):

```sh
flutter build web --release -t lib/main_prod.dart --no-web-resources-cdn --source-maps
node tools/perf/js_size_by_package.mjs openbudget_app/build/web --top 30
```

Playwright and Chromium come preinstalled in cloud sessions; elsewhere install Playwright first (`npm i -g playwright && npx playwright install chromium`).

### API reads

```sh
cd openbudget_server
dart test --run-skipped -t benchmark test/benchmark/
```

The benchmark starts its own PostgreSQL cluster with `pg_stat_statements` loaded (set `OPENBUDGET_TEST_POSTGRES_BIN` when `initdb` is not on the `PATH`), seeds the household book and prints the table above as JSON. Set `OPENBUDGET_BENCH_OUT=results.json` to also write it to a file. It is tagged `benchmark` and skipped in normal runs.

## History

### 2026-11-25: load screens after sign-in on demand, English-only built-in localizations

| Metric                                | Before  | After   | Change |
| ------------------------------------- | ------- | ------- | ------ |
| `main.dart.js`                        | 6.81 MB | 4.33 MB | −36%   |
| `main.dart.js` gzipped                | 1.94 MB | 1.25 MB | −36%   |
| JavaScript on the wire, first load    | 2.02 MB | 1.38 MB | −31%   |
| Web app bytes on the wire, first load | 5.38 MB | 4.75 MB | −12%   |
| Web app bytes after decoding          | 16.5 MB | 14.0 MB | −15%   |
| Web app first frame, slow 4G          | 25.5 s  | 22.5 s  | −12%   |
| Web app first frame, unthrottled      | 852 ms  | 702 ms  | −18%   |

What changed:

- **Deferred screens.** 42 screens reached after sign-in (accounts, reports, settings and the rest of More, tax, books, the assistant, Plus, entry forms and the plan editors) now sit behind nine deferred libraries in `lib/src/routing/deferred/`. The router builds them through `DeferredScreen`, which shows a loading panel on a first visit and a problem panel with Retry if the download fails. dart2js puts each library in its own `main.dart.js_N.part.js`, so the login screen no longer waits for Solana, PointyCastle, the charts or the tax engine. Once the budget shell has drawn its first frame it preloads all nine in the background, so screens open at once in practice. Native builds load deferred libraries straight away and behave as before.
- **Localizations.** The app shipped `GlobalMaterialLocalizations` and friends, which carry strings and date formats for every language Flutter supports, while the app is English-only. It now uses Flutter's built-in English delegates. Adding a language means adding its ARB file and switching back to the global delegates.
- **Tooling.** `tools/perf/js_size_by_package.mjs` attributes a dart2js bundle to packages from its source map, which is how the split was chosen.

### 2026-11-25: ship only the fonts in use, gzip responses, defer the Apple script

| Metric                                   | Before   | After   | Change |
| ---------------------------------------- | -------- | ------- | ------ |
| Web app bytes on the wire, first load    | 29.25 MB | 5.38 MB | −82%   |
| Web app bytes after decoding             | 73.2 MB  | 16.5 MB | −77%   |
| Web app requests                         | 140      | 25      | −82%   |
| Web app first frame, slow 4G             | 140.4 s  | 25.5 s  | −82%   |
| Web app first frame, unthrottled         | 1,611 ms | 852 ms  | −47%   |
| Font assets in every build (web, mobile) | 59.6 MB  | 3.16 MB | −95%   |
| `budget.getMonth` body on the wire       | 21.5 KB  | 2.2 KB  | −90%   |
| `transaction.list` body on the wire      | 42.5 KB  | 4.1 KB  | −90%   |
| `envelope.list` body on the wire         | 12.5 KB  | 1.4 KB  | −89%   |

What changed:

- **Fonts.** `openbudget_ui` depended on `skribble_font_recursive`, whose pubspec registers all 129 Skribble faces. Flutter bundles every face a dependency registers into every build, and Flutter web fetches every one of them before it draws a frame: 132 font requests and 25 MB on the wire before the login screen appeared. `openbudget_ui` now ships the 14 faces the theme letters with (Skribble 700 to 900, Skribble Linear Playful 400 to 900 plus two italics, Skribble Mono Playful 700 to 900). `tool/subset_fonts.sh` copies them from the upstream release and drops the stylistic alternates the app never asks for, keeping every character, which halves each face (379 KB to 213 KB). A test keeps the registered families equal to the theme's and the total under 4 MB.
- **Compression.** Serverpod sends endpoint results and files uncompressed. `CompressionMiddleware` gzips bodies over 1 KB for clients that accept it, on the API server and the web server; streamed files are compressed once per ETag and cached. Both the browser and `dart:io`'s client (the native apps) ask for gzip and unpack it themselves.
- **Startup.** `appleid.auth.js` loaded as a render-blocking script from a third-party host in `web/index.html`; it is now deferred. The app starts Apple sign-in preparation and PostHog setup together before `runApp` rather than one after the other.

## Where the time goes next

The biggest remaining costs, largest first, are the candidates for the next pull requests:

1. **CanvasKit is 1.85 MB on the wire.** A WebAssembly build (`--wasm`, skwasm) renders faster in browsers that support it. `FlutterRoute` already sends the cross-origin isolation headers it needs, but they also block the Apple and Google sign-in scripts, so that needs care.
2. **17 font faces still load before the first frame (1.51 MB).** Dropping weights the screens barely use, or a Latin-only subset, would save up to another megabyte.
3. **`main.dart.js` is still 4.33 MB.** Flutter itself and the web engine are 1.46 MB of it; the login flow's SVG stack (`flutter_svg`, `vector_graphics_compiler`, `xml`) is about 80 KB.
4. **`entity.listSummaries` takes 31 ms and 10 statements** for one book. **`budget.getMonth` has a slow tail** (p95 136 ms).
5. **The website** spends two round trips before first paint on `styles.css` and the font preloads; inlining the critical CSS would bring first paint forward.
