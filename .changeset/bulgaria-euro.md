---
openbudget_core: fix
---

# Bulgaria defaults to the euro

New Bulgarian entities silently fell back to US dollars: `BG.json` still listed the lev (BGN) from the CLDR release-46 currency map, but `CurrencyCode` is generated from the ISO 4217 List One published by SIX on 2026-09-17, which no longer carries BGN, so the code could not parse and entity creation picked USD instead. Bulgaria replaced the lev with the euro on 1 January 2026 at the fixed rate BGN 1.95583 = EUR 1 (European Central Bank); the country file now lists EUR, with the source and a caveat recorded, and historical BGN amounts stay out of scope for the `currencies` field.

A regression test in `openbudget_core/test/countries/` now fails CI when any servable country's first currency is not a `CurrencyCode`, so the next stale code cannot ship.
