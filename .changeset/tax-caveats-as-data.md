---
openbudget_core: feat
openbudget_server: feat
---

# Caveats and named figures as data

Every `TaxRuleSet` now carries `TaxRuleCaveat` rows (id, grade P/S/I, plain-language text, the sections or rule keys it touches, `recheckBy`) and a `figures` map of `TaxFigure` (id, value with unit, source, grade, `verifiedOn`) — the headline numbers knowledge cards will quote (personal allowance, basic-rate band, VAT registration threshold, standard deduction, Grundfreibetrag, rent relief cap and more). The "Unverified and changing" lists of the uk-personal-tax, uk-company-tax, uk-vat-payroll, us-federal-tax, nigeria-tax and germany-tax skills are ported onto the GB, US, NG and DE packs; no figure value changed, each is only named and given its source and grade. Reports carry only the caveats they touched (`TaxReport.caveats`, plus `TaxReportLine.figureId` on lines presenting a named figure), which flow through `TaxReportView` as `TaxRuleCaveatView` and `TaxFigureView`. `dart run openbudget_core:tax_freshness` now reports overdue caveats alongside countries through the existing re-check seam. No migration: the new fields are view-only.
