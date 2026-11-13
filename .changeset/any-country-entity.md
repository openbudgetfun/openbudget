---
openbudget_app: feat
openbudget_core: feat
openbudget_ui: feat
---

# Create an entity in any country

`CreateEntityScreen` replaces its four-country list with a searchable picker over every servable country in `Countries.all`, and a searchable picker over every ISO 4217 currency. Both, and the time zone choice, are one reusable `showObPickerSheet` in `openbudget_ui`: search by name, code or keyword ignoring case and accents, an exact code ranked first, Enter to take the top result, the down arrow into the list, a live result count, and the highlighter, a check and a spoken state on the chosen row. The library carries no strings, so callers pass theirs from `app_en.arb`.

Choosing a country fills the currency (its first bookable one, or USD when none is), time zone and, for a person or sole trader, a read-only tax year row; a company keeps its editable year end. `defaultFiscalYearEnd` now ends an individual's year the day before the country's Gregorian `individualTaxYear` starts, so GB, US, NG and DE are unchanged and Australia ends 30 June; countries with no tax year in the dataset, or a non-Gregorian one, still end 31 December. `CountryInfo.displayName` and `searchAliases` (in `country_display_name.dart`) turn the terse IANA names ("Britain (UK)", "St Lucia") into what people write and find. The year-end row also fixes its swapped day and month.
