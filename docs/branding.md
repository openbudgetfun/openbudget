# OpenBudget Brand Guide

OpenBudget looks like a kitchen-table envelope budget: warm paper, indigo-black ink, pencil hatching and a highlighter for the one number to act on. The brand is that same world, drawn small.

## The Mark

Three cash envelopes stand together, each filled to its own level. The middle one is full, so its flap is folded down and sealed with wax. It is a budget drawn as a bar chart, except the bars are envelopes: money split into jobs, with one job finished.

The mark reuses the app's own rules. `ObEnvelopeGauge` fills an envelope with pencil as money goes in and seals it when it is full; the mark is three of those gauges at rest.

| File                     | Use                                                                                                   |
| ------------------------ | ----------------------------------------------------------------------------------------------------- |
| `brand/mark.svg`         | The mark on light grounds (paper colourway).                                                          |
| `brand/mark-night.svg`   | The mark on dark grounds (night colourway).                                                           |
| `brand/mark-mono.svg`    | One colour (`currentColor`) with the paper knocked out: embossing, tinted and themed icons, print.    |
| `brand/mark-small.svg`   | The mark redrawn for 16 to 32 px: no tilt or hatching, pixel-aligned, follows `prefers-color-scheme`. |
| `brand/lockup.svg`       | Mark and wordmark side by side, light grounds.                                                        |
| `brand/lockup-night.svg` | The lockup on dark grounds.                                                                           |
| `brand/lockup-mono.svg`  | The lockup in one colour.                                                                             |

The wordmark is "OpenBudget" set in SkribbleGentle ExtraBold, the app's display face, converted to outlines with the face's own kerning. Never retype it in another font.

In Flutter, draw the mark with `ObMark` from `openbudget_ui`. It paints the same path data as `brand/mark.svg` (a test keeps them identical), follows the theme, and draws the app-icon tile when asked.

## Clear Space and Size

- **Clear space:** keep at least half an envelope's width clear on every side, about a sixth of the mark's height. The lockup takes the same margin around its whole box.
- **Minimum size:** the full mark from 40 px up. From 16 to 40 px use `mark-small.svg`. The lockup needs at least 140 px of width; below that, use the mark alone.
- **App icons:** the mark spans 64% of the tile on iOS, web, Windows and macOS, and 52% of the Android adaptive canvas, so it stays inside every platform's safe zone.

## Colour

Every colour comes from `ObSwatch` in `openbudget_ui/lib/src/theme/ob_palette.dart`. Never add a colour for the brand alone.

| Role                       | Paper                   | Night                   |
| -------------------------- | ----------------------- | ----------------------- |
| Ground and envelope paper  | `paper` `#FCF8EF`       | `night` `#1D2131`       |
| Outlines and wordmark      | `ink` `#262C44`         | `nightInk` `#F4EFE3`    |
| Funded share               | `indigo` `#3E4CC9`      | `nightIndigo` `#A3ACFF` |
| Wax seal (both colourways) | `highlighter` `#FFEC8A` | `highlighter` `#FFEC8A` |

Pencil hatching over the funded share is the envelope paper colour at 28% opacity. The one-colour mark uses `ink` on light grounds and `nightInk` or `paper` on dark ones.

## Platform Assets

The SVGs are the source. `dart run openbudget_scripts:render_brand`, run from the repository root inside `devenv shell`, lays the mark out for every platform, rasterises it with `resvg`, then runs `flutter_launcher_icons` and `flutter_native_splash`. It produces the iOS icons (with the iOS 18 dark and tinted variants), the Android adaptive icon (with the themed monochrome layer), web, Windows and macOS icons, the splash screens, and the web favicon. Never edit a generated icon by hand.

## Voice

OpenBudget talks like a friend who keeps a tidy ledger: plain, warm and specific about money.

- Say what happened and what to do next: "Groceries is £12 over. Move money from Eating Out?"
- Name real amounts, real envelopes and real dates rather than abstractions.
- Calm, never alarmed; encouraging, never cute. No exclamation marks about money.
- AI suggestions are guidance, not regulated advice, and say so.

## Do and Don't

- **Do** put the mark on paper, night, or a photo calm enough to keep its outlines readable.
- **Do** use the one-colour mark wherever only one ink is available.
- **Do** keep the three envelopes, their fill levels and the seal exactly as drawn.
- **Don't** recolour the envelopes, add gradients, shadows or outlines, or swap the yellow seal for another colour.
- **Don't** rotate, stretch, or redraw the mark, or set the wordmark in another typeface.
- **Don't** use the full mark below 40 px; switch to `mark-small.svg`.
- **Don't** place the paper colourway on dark grounds or the night colourway on light ones.

## Naming Rule

OpenBudget is the only product name allowed in active code, UI text, docs, comments, design files, assets, and examples.

### Required Naming

- Use `OpenBudget` for product display text.
- Use `OpenBudget` as the root for new symbols and file names when naming is product-related.
- Prefer neutral wording such as `budgeting app`, `app`, or `product` when product naming is not needed.

### Disallowed Naming

- `YNAB`
- `Ynab`
- `ynab`
- `You Need A Budget`

### Historical Exception

Historical release notes in `.changeset/` may contain legacy naming that should remain unchanged for history tracking. Do not reuse those terms in new implementation work.
