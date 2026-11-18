---
openbudget_server: feat
---

# Record the tax rule version on reports and tax proposals

`TaxReportView` carries `rulesVersion`, `maturity` and the per-section `coverage` the pack declares. Tax proposals created through the assistant's registry store the `rulesVersion` of the entity's current tax year in `AgentProposal.rulesVersion`, so an applied change can be traced to the figures it was made under.
