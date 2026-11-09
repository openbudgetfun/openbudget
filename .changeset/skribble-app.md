---
openbudget_app: refactor
openbudget_ui: fix
---

# Port the app screens onto the Skribble components

Screens keep their providers, routes and data flow; only widgets, colours and layout change.

- The Add tab in the budget shell is a hot-pink sticker (`_AddSticker`) with a hard print shadow, and the Patrol page object finds it by its icon.
- The net worth summary, the budget header and the net worth hero are raised `ObCard` stickers with the teal overprint shadow.
- Chart series read `ObPalette.spots`, so charts use the same six spot inks as the badges and the landing page.
- Text on the highlighter takes `ObPalette.onHighlighter` on the login headline, the Plus price and the home "ready to assign" figure; before, they were chalk or a tone hue on sunflower in dark mode, which failed WCAG AA.
- Transaction rows move the cleared status chip into the row's chip strip beside "Unassigned", so neither chip truncates at 390pt and the amount stands alone like a ledger column.
- `ObToneChip` is tighter (7/9pt sides, a 7pt dot) so a dotted chip is no wider than the old bare chip.
