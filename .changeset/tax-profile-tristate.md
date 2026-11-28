---
openbudget_core: fix
openbudget_server: fix
openbudget_app: fix
---

# A tax profile can record a deliberate no

`TaxProfile.taxResident` and `TaxProfile.usPerson` are now `bool?`, with null meaning the question has not been answered. `baseJson()` still omits null, so every stored profile fixture keeps its exact bytes, while an explicit `false` now serializes as `"taxResident": false` / `"usPerson": false` and reads back as an answer. `TaxBoolQuestion` gains `nullable`, set on the two common guardrail questions, and `TaxQuestionField` renders those with a Not answered / Yes / No selector instead of a switch that could not express silence.

The Money guide brief now renders `true` as "yes", `false` as "no" and null as "not recorded", and `AgentService` forwards the stored answers as `bool?` instead of collapsing false to silence. The account deletion service checks for a renewing subscription inside the delete transaction, deletes transactions and journals before the entity cascade so envelope and ledger lines cannot block it, and collects the Plaid access tokens before the rows go, sending `/item/remove` only after the commit, so a refused or rolled-back deletion cannot break a bank link. The G10 compaction timing test asserts the structural invariants (two or three crossings, each at least four requests apart) instead of two hardcoded request indexes.
