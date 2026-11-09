# openbudget_site

The OpenBudget landing page at [openbudget.app](https://openbudget.app). It is a static site: [Jaspr](https://jaspr.site) renders Dart components to HTML at build time, and a small script (`web/site.js`, 9 KB, no dependencies) brings the envelope desk to life in the browser. Without JavaScript the page still reads in full; the desk shows as a picture.

## Layout

| Path                       | What it holds                                                                                                           |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `lib/site_config.dart`     | Every link the site renders: the web app, the source, and the downloads.                                                |
| `lib/main.server.dart`     | The entry point `jaspr build` renders.                                                                                  |
| `lib/src/site.dart`        | The document: metadata, social cards, structured data, and which page to show.                                          |
| `lib/src/sections/`        | The page's sections: masthead, hero, differences, pricing, questions, footer, and the envelope desk.                    |
| `lib/src/components/`      | Shared pieces: the hand-drawn doodles, the download stamps, and the brand artwork read from `../brand/`.                |
| `lib/src/demo_budget.dart` | The desk's envelopes, currencies and messages. `web/site.js` reads the same data from the page, so the two never drift. |
| `web/`                     | Copied into the build as it is: `styles.css`, `site.js`, fonts, images, `robots.txt` and `_headers`.                    |
| `tool/build.dart`          | Builds the deployable site.                                                                                             |
| `tool/render_images.dart`  | Draws `favicon.svg`, `og.png` and `apple-touch-icon.png` from `brand/`.                                                 |

## Prerequisites

Run everything from `openbudget_site/` inside the repository's devenv shell, which provides Dart through the Flutter SDK. Install the Jaspr CLI once:

```sh
dart pub global activate jaspr_cli 0.23.5
```

`jaspr` runs build_runner and the renderer with the first `dart` on your `PATH`. The workspace includes Flutter packages, so that must be the Flutter SDK's `dart` (for example `.fvm/flutter_sdk/bin` first on the `PATH`), not a standalone Dart SDK. If pub reports that `openbudget_test_utils requires the Flutter SDK`, the SDK's `bin/cache/flutter.version.json` is missing; `flutter --version` writes it again.

## Develop

```sh
jaspr serve
```

This serves the site at http://localhost:8080 and re-renders when a Dart file changes. Edits to `web/styles.css` and `web/site.js` show on reload.

`jaspr` warns that `jaspr_builder` is missing and, in an interactive terminal, offers to add it. Answer no. The site has no client components or generated styles, so it does not need the builder, and the builder does not resolve against the workspace's `analyzer`. It also notes that no `.client.dart` file exists, which is expected for the same reason.

## Build

```sh
dart run tool/build.dart
```

This runs `jaspr build` with the sitemap domain taken from `siteConfig`, then removes what build_runner leaves next to the pages:

- `packages/`: the assets of every dependency.
- `.dart_tool/`: a package config holding the build machine's absolute paths.
- `.build.manifest`.

None of these belong on a public host. The script fails unless `index.html`, `404.html` and `sitemap.xml` were all written, and then lists the output with sizes. A plain `jaspr build` also works, but it leaves those files in place.

The output in `build/jaspr/` is about 250 KB uncompressed:

| File                                            | Notes                                                                         |
| ----------------------------------------------- | ----------------------------------------------------------------------------- |
| `index.html`                                    | The landing page. About 21 KB gzipped; the doodles and lockup are inline SVG. |
| `404.html`                                      | The not-found page, marked `noindex` and left out of the sitemap.             |
| `sitemap.xml`, `robots.txt`                     | For search engines.                                                           |
| `styles.css`, `site.js`                         | The only stylesheet and script.                                               |
| `fonts/*.woff2`, `fonts/OFL.txt`                | Four Skribble faces subset to Latin, about 16 KB each, and their licence.     |
| `favicon.svg`, `apple-touch-icon.png`, `og.png` | Icons and the social card.                                                    |
| `_headers`                                      | Security headers, and long-lived caching for the fonts.                       |

## Change a link or put a download live

Every outbound link comes from `siteConfig` in `lib/site_config.dart`. A download without a URL renders as a cancelled "Coming soon" stamp that goes nowhere. To put one live, give it a URL and rebuild:

```dart
final siteConfig = SiteConfig(
  siteUrl: Uri.parse('https://openbudget.app/'),
  webAppUrl: Uri.parse('https://app.openbudget.app'),
  sourceUrl: Uri.parse('https://github.com/openbudgetfun/openbudget'),
  appStoreUrl: Uri.parse('https://apps.apple.com/app/<listing>'),
);
```

The stamp becomes a link. Once every download has a URL, the "on their way" label becomes "Get the app" and the question about when the apps are coming disappears.

## Images and fonts

`favicon.svg`, `og.png` and `apple-touch-icon.png` are drawn from the SVGs in `brand/` and set in the app's own Skribble fonts. Redraw them after the mark or the headline changes:

```sh
dart run tool/render_images.dart
```

It needs `resvg` and `oxipng`, which the devenv shell provides. A test checks that `web/favicon.svg` still matches `brand/mark-small.svg`.

The fonts are the Skribble faces from `skribble_font_recursive`, a version of [Recursive](https://github.com/arrowtype/recursive) under the SIL Open Font License (`web/fonts/OFL.txt`). They are subset to Basic Latin plus the punctuation, currency signs and arrows the page uses. To subset them again, then rename the `.woff2` files to match `web/fonts/`:

```sh
fonts="$(find ~/.pub-cache/hosted/pub.dev -maxdepth 1 -name 'skribble_font_recursive-*' | sort | tail -1)/assets/fonts"
nix shell nixpkgs#python3Packages.fonttools nixpkgs#woff2 -c sh -c '
  for face in SkribbleGentle-ExtraBold SkribbleLinearGentle-Regular \
    SkribbleLinearGentle-SemiBold SkribbleMonoGentle-SemiBold; do
    pyftsubset "$0/$face.ttf" --output-file="$face.ttf" \
      --layout-features="kern,liga,calt,tnum,lnum,case" \
      --unicodes="U+0020-007E,U+00A0,U+00A3,U+00A9,U+00B7,U+00D7,U+2013,U+2014,U+2018,U+2019,U+201C,U+201D,U+2022,U+2026,U+20A6,U+20AC,U+2190-2193,U+2713"
    woff2_compress "$face.ttf" && rm "$face.ttf"
  done' "$fonts"
```

## Test

```sh
dart test
```

The tests render the site with `jaspr_test` and check:

- The download stamps follow `siteConfig`: live, coming soon, and the copy once every app has shipped.
- Every web app link points at the configured app.
- The metadata, social card and structured data.
- The not-found page stays out of search results.
- The desk's starting budget.

## Deploy to Cloudflare

The site deploys as a [Workers static assets](https://developers.cloudflare.com/workers/static-assets/) project with the `cf` CLI. Nothing here deploys automatically. The steps below were checked with `cf deploy --dry-run` (cf 1.0.0-beta.28, wrangler 4.159.0) against this build, and nothing was uploaded.

`cf` deploys static folders through Wrangler, so set up the deploy tooling once in this directory. Create a `package.json` holding only `{ "private": true, "type": "module" }`, then install the two tools. None of these files hold secrets:

```sh
npm install --save-dev cf wrangler
```

Then create `cloudflare.config.ts`:

```ts
import { defineConfig } from "cf/config";

export default defineConfig({
  worker: {
    name: "openbudget-site",
    compatibilityDate: "2026-11-04",
    assets: {
      htmlHandling: "auto-trailing-slash",
      // Serve build/jaspr/404.html, with a 404 status, for unknown paths.
      notFoundHandling: "404-page",
    },
    domains: ["openbudget.app"],
  },
});
```

And `wrangler.config.ts`, which tells `cf` where the built site is:

```ts
import { defineWranglerConfig } from "wrangler/experimental-config";

export default defineWranglerConfig({
  assetsDirectory: "build/jaspr",
});
```

Add `node_modules/` and `.cloudflare/` to `.gitignore` if you commit the configuration. To ship:

```sh
dart run tool/build.dart
cf deploy --dry-run   # builds and validates; needs no credentials
cf auth login         # or set CLOUDFLARE_API_TOKEN in CI
cf deploy
```

Workers static assets apply `web/_headers` as it is. The domain must be a zone on the same Cloudflare account. `cf previews deploy <name>` uploads a preview without touching production.
