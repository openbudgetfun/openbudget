---
openbudget_core: feat
---

# Add the ISO 3166 country dataset

Every ISO 3166-1 country now carries reference facts in `openbudget_core/data/countries/<CC>.json` — English name, current currencies, IANA time zones and a `servable` flag — built from IANA tzdata 2026f and CLDR by `tool/bootstrap_country_data.dart`, and inlined as constants by `tool/generate_country_data.dart` (`--check` runs in CI). `Countries.byCode` exposes the dataset; `defaultTimeZone`, `timeZoneChoices` and `defaultFiscalYearEnd` read it. Results are unchanged for GB, US, NG and DE; other countries now default to their own zone and currency instead of `UTC`, and five placeholder sanctions targets (BY, CU, IR, KP, RU) are flagged `servable: false` pending counsel's answer to Q1. Tax-year and indirect-tax fields stay null until the U3–U5 research tasks fill them.
