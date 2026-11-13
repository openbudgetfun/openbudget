---
openbudget_core: fix
---

# Store country tax rates exactly and reject duplicate sources

The country dataset's `IndirectTaxRate` now stores `ratePerMillion` (an exact integer in millionths of the taxed amount: 1% is `10 000`) instead of `basisPoints`, whose whole-hundredths-of-a-percent grid silently rounded fractional rates. Québec's 9.975% QST, Minnesota's 6.875%, Missouri's 4.225%, New Jersey's 6.625% and New Mexico's 5.125%/4.875% are exact again, and the caveats that apologised for the rounding are gone.

44 country files listed the same source more than once (112 duplicate entries, all identical in grade and retrieval date); each now keeps one entry, with the rate rows' `source` indices remapped. `CountryInfo.fromJson` rejects a repeated caveat or a repeated source and rejects unknown tax-year calendars, naming the country in each error — so the generator, CI's `--check` and the tests all fail loudly on the next duplicate.

`individualTaxYear.calendar` is now the `TaxYearCalendar` enum instead of a free string. Its JSON names are CLDR calendar identifiers (`gregorian`, `persian`, `ethiopic`, `islamic`, `islamic-umalqura`, …) plus `bikram-sambat` for Nepal, whose calendar has no CLDR identifier; `docs/tax-jurisdictions.md` section 8 documents the field and the schema.
