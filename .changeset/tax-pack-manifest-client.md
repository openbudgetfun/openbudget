---
openbudget_client: feat
---

# Carry the tax rule version and coverage in the client protocol

`TaxReportView` gains `rulesVersion`, `maturity` and `coverage`, matching the server view, so the app can show a pack's review state without recomputing it.
