---
openbudget_core: feat
openbudget_server: feat
openbudget_client: feat
---

# Guardrail data in core and neutral tax opportunities (G1)

`openbudget_core` now carries the Money guide's guardrail data: per-country
regulatory perimeters, the never-suggest list, signpost triggers and
disclaimer keys for GB, US, DE and NG. `TaxOpportunity` and
`TaxOpportunityView` gain `grade`, `announced`, `signpostOnly`,
`needsEvidence`, `ruleYear` and `assumptions`, and opportunity titles are
neutral noun phrases. Opportunities built on secondary or inferred figures,
or on announced rules, carry no computed saving.
