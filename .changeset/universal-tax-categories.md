---
openbudget_core: feat
openbudget_server: feat
openbudget_app: feat
---

# Universal tax categories (task U6)

The country-neutral tax category catalogue of `docs/tax-jurisdictions.md` section 8.6 now lives in `openbudget_core/lib/src/tax/universal/`: 44 codes prefixed `universal.` across income (gains and digital-asset disposals split into proceeds and cost), 17 business expenses, 7 reliefs, 4 tax-paid kinds and 4 out-of-scope kinds, each with an ARB label key. `TaxRulePack` grows `mapUniversalCategory`, implemented for GB, US, NG and DE with per-kind tables that map each universal code onto the pack's own code or leave it deliberately unmapped (kinds must match, so a relief never lands on an expense line — the contract test enforces this). The server accepts universal codes on every entity regardless of country, `tax.listCategories` for an entity whose country has no rule pack returns the universal catalogue without requiring a tax profile, and `tax.getReport` maps universal codes through the pack before computing: unmapped universal entries count as uncategorised and the report carries a caveat naming the count. Includes a Kenyan end-to-end server test (create, tag lines and envelopes, list categories) and a GB sole-trader test proving `universal.expense.software` lands on SA103F box 23. App-localisation labels are generated; the in-app universal panel is task U11 and the full country picker U10, so no screen changes yet.
