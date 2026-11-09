---
openbudget_app: native
openbudget_ui: feat
openbudget_site: feat
openbudget_scripts: chore
---

# Reprint the identity and design system as a vivid Skribble zine

The brand and the shared design system move from warm paper and indigo to a two-colour print look: a cream page, white sheets, one deep violet ink and saturated spot inks (hot pink, teal, sunflower, cobalt, tangerine, lilac) printed slightly off-register. Every text pairing is checked against WCAG 2.2 AA in `ob_palette_test.dart`.

- `brand/` has a new mark (an open hot-pink envelope with a gold coin and a teal overprint) in paper, night (chalk halo), one-colour and small versions, plus lockups lettered in Skribble Black. `render_brand` regenerated every platform icon and splash screen on the cream tile, which is a native change.
- `openbudget_ui` rewrites `ObSwatch`, `ObPalette` (adds `onHighlighter`, `overprint`, `printShadow` and six `spots`) and `OpenBudgetTheme`: Skribble display and Skribble Linear Playful text faces, firm inked rough outlines, sticker buttons that press into a hard print shadow (`ObStickerBorder`), highlighter-swipe navigation indicators (`ObMarkerBorder`), and the expressive Skribble roughness.
- New flourishes, all silent to screen readers and still under reduced motion: `ObScribbleUnderline`, `ObPostmark`, `ObSeal`, `ObCurrencyStamp`, `ObInkBurst`, `ObSpotDoodle`, and `ObInkPageTransitionsBuilder` (an ink wipe on Android, web and desktop; the native slide with an inked edge on iOS and macOS). `useObFlourish` and `obMotionAllowed` gate them on `MediaQuery.disableAnimations`.
- Reworked components: `ObCard` (`raised` stickers), `ObAmount`, new `ObHeroAmount`, `ObHighlighter`, `ObSectionHeader`, `ObStatePanel`, `ObLoadingPanel`, `ObToneChip`, `ObEnvelopeGauge` (wax seal and ink burst when full, torn flap when overspent), new `ObListRow` and `ObIconBadge`, and `ObMark` on the new paths.
- New `ObFieldIcon`: a Skribble icon that centres itself in a text field's 48pt icon slot. A bare `SkribbleIcon` stretches to fill that slot but draws in its top-left corner, on the field's outline; `ObTextField` now centres any icon it is given.
- `openbudget_site` keeps its envelope desk and doodles, takes the same palette tokens, and adds orchestrated entrances, sticker buttons, spot-ink envelopes, seal bursts and an "All assigned" postmark, doodles that draw in, scroll-linked moments, and a hand-drawn GitHub mark beside every GitHub link. All motion respects `prefers-reduced-motion`.
