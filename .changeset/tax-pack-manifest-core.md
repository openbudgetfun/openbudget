---
openbudget_core: feat
---

# Add the tax pack manifest and rule-set contract

`TaxRulePack` now declares a `TaxPackManifest` (maturity plus a coverage value for every `TaxSection`) and a per-year `TaxRuleSet` carrying the revision, sources and `verifiedOn` date. `TaxRuleSet.versionFor` produces the `gb-2026-r1` style version recorded on reports. The GB, US, NG and DE packs each ship a manifest, all `preview`, and reports carry `rulesVersion`, `maturity` and `coverage`.

The new `tax_pack_contract_test.dart` iterates every `TaxJurisdiction` and checks the manifest sections, the rule-set metadata, unique versions and the report fields for every supported year and entity kind.
