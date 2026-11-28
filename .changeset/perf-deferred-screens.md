---
openbudget_app: perf
---

# Load screens after sign-in on demand on the web

- 42 screens reached after sign-in now live in nine deferred libraries under `lib/src/routing/deferred/`, built through the new `DeferredScreen`, which shows a loading panel on a first visit and a problem panel with Retry if the download fails. The budget shell preloads every library after its first frame with `preloadDeferredScreens()`. Native builds load deferred libraries at once.
- Both `MaterialApp`s use `appLocalizationsDelegates`: the app's own strings plus Flutter's built-in English delegates, in place of the global delegates that carry every language.
- `main.dart.js` drops from 6.81 MB to 4.33 MB (1.94 MB to 1.25 MB gzipped), and the web app's first frame on slow 4G from 25.5 s to 22.5 s. `tools/perf/js_size_by_package.mjs` attributes a dart2js bundle to packages from its source map.
