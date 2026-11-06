---
"openbudget_core": fix
"openbudget_server": fix
---

# Tax profiles keep every field the core profile defines

The server filtered profile JSON through its own per-country key list before handing it to `TaxProfile.fromJson`, on save and on every read. Fields added to the core profiles since (UK accounting period end, associated companies and postgraduate loan; Nigeria's small-company ceiling and multinational-group flag; Germany's church-tax Land, Einkunftsart, children, pension, prior-year turnover and commute) were silently dropped. The list is gone: `TaxProfile.fromJson` is now the single definition of a profile's fields and parses strictly, throwing a `FormatException` that names the field for a wrong type, an unknown enum value, a negative count or an impossible year-end date. The server turns that into a `ValidationException`, and `toJson` still drops unknown keys.
