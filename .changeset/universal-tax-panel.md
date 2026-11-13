---
openbudget_app: feat
---

# Universal tax panel and summary export (U11)

`TaxOverviewScreen` now shows `UniversalTaxPanel` for any entity whose country has no tax rule pack, replacing the "no tax rules" dead end. The panel reads the tax year and indirect-tax rates straight from `Countries.byCode` (rates formatted from the integer `ratePerMillion`, graded by their source, with the secondary-source badge), links to the authority, and shows the `tax.getSummary` totals. `TaxExportCard` calls `tax.createExportLink` through the new `TaxExport` notifier and opens the signed URL with `url_launcher` behind the `TaxUrlLauncher` seam, on pack and non-pack entities alike. `TaxRepository` gains `getSummary` and `createExportLink`; the year switcher, caveat card and disclaimer bar move to shared widgets. No server, migration or native changes.
