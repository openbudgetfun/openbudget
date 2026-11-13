---
openbudget_ui: feat
openbudget_app: refactor
---

# Add ObReadableWidth and polish the multi-currency screens

`openbudget_ui` adds `ObReadableWidth`, which widens a scroll view's padding so its content stays in a readable column on wide windows while the scroll view still spans the window. In `openbudget_app`, dates on the multi-currency screens go through `DateLabels` (`intl` with the active locale) instead of hand-built strings, `FxRateLine` localises the rate source and takes an optional action, and the integration screenshot helper captures the painted surface at its real device pixel ratio (the old capture left a white margin on desktop) and gains `useScreenshotSurface`. A new Patrol tour, `multi_currency_screens_flow_test.dart`, captures every multi-currency screen at phone and desktop size.
