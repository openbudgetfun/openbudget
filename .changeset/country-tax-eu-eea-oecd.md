---
openbudget_core: feat
---

# Fill tax years and indirect tax for EU, EEA and OECD countries

The 44 EU, EEA and OECD members in `openbudget_core/data/countries/` now carry their individual tax year, default company year end, VAT/GST rates (standard, reduced and special tiers, effective-dated), tax authority, graded sources, `verifiedOn`, `recheckBy` and caveats — task U3 of the tax jurisdictions plan. EU rates are primary from the Commission's "VAT rates applied in EU member countries" table; national statutes or authority pages back GB, DE, FI, CH, CA, IS and NZ; the eleven authorities that block automated fetches carry secondary-graded rates and a caveat. Company year-end defaults now come from the data for these countries, so AU, NZ and JP default to 30 June / 31 March / 31 March instead of 31 December; GB keeps its existing 31 March default. Everything else stays null until U4 and U5.
