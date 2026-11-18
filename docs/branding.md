# OpenBudget Brand Guide

OpenBudget is printed, not painted. It looks like a two-colour zine about money: a sunny cream page, white sheets, one deep violet ink, and saturated spot inks laid down flat and a few points off-register. Everything is drawn by hand with the Skribble pen. Envelopes fill with ink, full ones are sealed with wax, and the one number to act on gets a highlighter swipe.

## The Mark

A hot-pink cash envelope with its flap open and a gold coin dropping in. The pocket is printed a second time in teal, a few points down and to the right, the way cheap two-colour print lands off-register. The coin is the money; the open envelope is the act of budgeting it.

| File                     | Use                                                                                 |
| ------------------------ | ----------------------------------------------------------------------------------- |
| `brand/mark.svg`         | The mark on light grounds.                                                          |
| `brand/mark-night.svg`   | The same inks inside a chalk sticker halo, for dark grounds.                        |
| `brand/mark-mono.svg`    | One colour (`currentColor`) with the lining, rim and folds knocked out.             |
| `brand/mark-small.svg`   | Redrawn on a 32-unit pixel grid for 16 to 40 px; it adds its own halo in dark mode. |
| `brand/lockup.svg`       | The mark beside the wordmark, lettered in Skribble Black.                           |
| `brand/lockup-night.svg` | The night lockup: haloed mark and chalk wordmark.                                   |
| `brand/lockup-mono.svg`  | The one-colour lockup.                                                              |

`ObMark` in `openbudget_ui` draws the same paths, copied verbatim; `ob_mark_test.dart` fails if the widget and the SVGs drift apart.

### Why this mark

Three directions were explored. **Par Avion** was an airmail envelope in postmark navy, vermilion and cobalt. **Riso Overprint** was fluorescent pink and teal envelopes overprinted off-register, with a sunflower seal. **Night Marker** was dark-first blueprint ink with lime and coral marker. Riso Overprint won, because it is the one that feels printed and playful rather than corporate, and its colours are vivid on both light and dark grounds. It keeps two ideas from the others: the coin dropping in from Night Marker, and postmarks and stamps from Par Avion. The open envelope reads at 16 px and says "money goes in here" without words.

## Clear Space and Size

- **Clear space:** keep at least a quarter of the mark's height clear on every side. The lockup takes the same margin around its whole box.
- **Minimum size:** the full mark from 40 px up. From 16 to 40 px use `mark-small.svg`. The lockup needs at least 140 px of width; below that, use the mark alone.
- **App icons:** the mark spans 64% of the tile on iOS, web, Windows and macOS, and 52% of the Android adaptive canvas, so it stays inside every platform's safe zone.

## Colour

Every colour lives in `ObSwatch` (`openbudget_ui/lib/src/theme/ob_palette.dart`) and nowhere else. The landing page's CSS custom properties use the same values. Vivid inks are fills, washes and accents; words on them are always the deep ink. `ob_palette_test.dart` checks every text pairing against WCAG 2.2 AA in both print runs.

| Role                  | Day                           | Night     | Notes                                                |
| --------------------- | ----------------------------- | --------- | ---------------------------------------------------- |
| Page                  | `#FFF4DE`                     | `#140F26` | Sunny cream; deep violet stock at night.             |
| Sheet                 | `#FFFFFF`                     | `#1F1838` | Cards, fields and bars.                              |
| Ink                   | `#1A1233`                     | `#FFF6E5` | Every outline, figure and word.                      |
| Muted ink             | `#5B4F7A`                     | `#C0B6DD` | Secondary text, still AA on page and sheet.          |
| Hot pink (action)     | `#FF3D8B`                     | `#FF5C9E` | Primary stickers and the mark's pocket. Carries ink. |
| Pink text (brand)     | `#B8005A`                     | `#FF8DBA` | Pink that reads as text.                             |
| Teal (overprint)      | `#00C2A8`                     | `#1FE0C4` | The off-register second ink.                         |
| Sunflower             | `#FFC400`                     | `#FFC400` | Highlighter, coin and wax seals. Carries ink.        |
| Cobalt (review)       | `#2F45E0`                     | `#9FB2FF` | Review tone and focus rings.                         |
| Sky, tangerine, lilac | `#5C8DFF` `#FF7A1F` `#A77BFF` |           | Extra spot inks for charts and badges.               |
| Funded                | `#0A7040`                     | `#5FE3A0` | With wash `#C2F5D5` / `#10402B`.                     |
| Overspent             | `#BA1E15`                     | `#FF8C7A` | With wash `#FFD6CC` / `#4A1B17`.                     |
| Underfunded           | `#8A5000`                     | `#FFC94D` | With wash `#FFE58A` / `#43320A`.                     |

The six spot inks (pink, teal, sunflower, sky or cobalt, tangerine, lilac) are the chart and badge series, in that order; each carries the action label at AA.

## Type

All lettering is Skribble (`skribble_font_recursive`):

- **Skribble**, Black and ExtraBold, for display, page titles and hero figures.
- **Skribble Linear Playful** for row titles, body and labels, never below 12.5 pt.
- The same linear face with tabular figures for amounts in lists, so columns line up.
- **Skribble Mono Playful** for postmarks, stamps and currency codes.

## Flourishes

Flourishes are decoration on a screen that is already complete at rest. Every one is silent to screen readers, and with reduced motion it simply appears in its final state.

- **Scribble underline** under section titles, drawn on left to right.
- **Highlighter swipe** behind the one figure to act on: ready to assign.
- **Spot doodles**: a Skribble doodle that draws itself over a blot of spot ink, leading every empty state.
- **Wax seal** on a full envelope, and a **postmark** for anything finished.
- **Currency stamps**: each currency is a perforated postage stamp in its own spot ink.
- **Ink burst**: spot-ink confetti when money lands, never on page load.
- **Ink wipe** page transitions on Android, web and desktop; iOS and macOS keep the native slide (and swipe back) with an inked edge.
- **Sticker buttons** with a hard print shadow they press into.

## Platform Assets

The SVGs are the source. `dart run openbudget_scripts:render_brand`, run from the repository root inside `devenv shell`, lays the mark out for every platform, rasterises it with `resvg`, then runs `flutter_launcher_icons` and `flutter_native_splash`. It produces the iOS icons (with the iOS 18 dark and tinted variants), the Android adaptive icon (with the themed monochrome layer), web, Windows and macOS icons, the splash screens, and the web favicon. Never edit a generated icon by hand.

## Voice

OpenBudget talks like a friend who keeps a tidy ledger: plain, warm and specific about money.

- Say what happened and what to do next: "Groceries is £12 over. Move money from Eating Out?"
- Name real amounts, real envelopes and real dates rather than abstractions.
- Calm, never alarmed; encouraging, never cute. No exclamation marks about money.
- AI suggestions are guidance, not regulated advice, and say so.

## Do and Don't

- **Do** put the paper mark on cream or white, and the night mark (with its halo) on dark grounds.
- **Do** use the one-colour mark wherever only one ink is available.
- **Do** keep the teal print off-register exactly as drawn: down and to the right.
- **Do** let vivid inks fill shapes, and keep words in the deep ink on them.
- **Don't** recolour the envelope, coin or overprint, add gradients or soft shadows, or redraw the outline.
- **Don't** rotate, stretch, or set the wordmark in another typeface.
- **Don't** use the full mark below 40 px; switch to `mark-small.svg`.
- **Don't** set text in a spot ink on paper, except the pink text and tone colours made for it.

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
