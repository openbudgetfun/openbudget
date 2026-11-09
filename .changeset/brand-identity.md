---
openbudget_app: native
openbudget_ui: feat
openbudget_scripts: feat
---

# Replace the gradient logos with the three-envelope mark

The generic gradient "OB" monograms and their contact sheets are gone. The new identity lives as hand-authored SVGs in `brand/`: the mark (three cash envelopes, the middle one full and sealed) in paper, night and one-colour (`currentColor`) versions, a pixel-aligned small mark for 16 to 32 px that follows `prefers-color-scheme`, and the wordmark lockup in each colourway. `docs/branding.md` is now the brand guide: mark, clear space, minimum size, colours from `ObSwatch`, voice, and usage rules.

- `openbudget_ui` adds `ObMark`, a `HookWidget` that paints the mark from the same path data as `brand/mark.svg` (a test keeps them identical), follows the theme or takes an `ObMarkVariant` (`paper`, `night`, `ink`), and can draw the app-icon tile. It depends on `path_parsing` to read the path data.
- `openbudget_scripts` adds `render_brand`, which lays the mark out per platform, rasterises it with `resvg` (now in the devenv shell), and runs `flutter_launcher_icons` and `flutter_native_splash` from those renders. Run it from the repository root.
- `openbudget_app` regenerates every launcher icon (iOS with the iOS 18 dark and tinted variants, an Android adaptive icon with a themed monochrome layer, web, Windows, macOS) and the native and web splash screens on paper and night. The web app gains an SVG favicon and paper manifest colours. These are native resources, so they need a store release rather than a Shorebird patch.
- `AppIconStyle` now offers the mark's colourways (`primary` for paper, `night`, `ink`) instead of the five retired logo variants; a stored retired value falls back to `primary`. The login screen and the App Icon settings screen draw the mark with `ObMark`, and `assets/branding/logos/` is no longer bundled.
