---
openbudget_site: feat
---

# Add the landing page as `openbudget_site`

A new workspace package renders the openbudget.app landing page with Jaspr in static mode. The page is set in the app's Skribble faces on the paper and night colourways from the brand guide. Its envelope desk is a small working budget: visitors drag or tap envelopes to fill them, watch full ones seal, and switch currencies to see the headline change. The desk runs on `web/site.js` (9 KB, no dependencies) and reads as a picture without JavaScript.

- `lib/site_config.dart` holds every outbound link. A download without a URL renders as a "Coming soon" stamp; giving it a URL makes the stamp a link on the next build.
- `dart run tool/build.dart` runs `jaspr build` with the sitemap domain from the config. It removes the `packages/`, `.dart_tool/` and `.build.manifest` files build_runner leaves beside the pages, and fails unless `index.html`, `404.html` and `sitemap.xml` exist. The output is about 250 KB.
- `dart run tool/render_images.dart` draws the favicon, the social card and the home-screen icon from `brand/`.
- The package README documents development, the build, and a Cloudflare Workers static-assets deploy with the `cf` CLI. Nothing deploys automatically.
- CI runs the site's `jaspr_test` suite alongside `openbudget_core`'s Dart tests.
