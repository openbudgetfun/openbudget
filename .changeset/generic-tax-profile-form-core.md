---
openbudget_core: refactor
---

# Profiles read and take answers, for the generic tax profile form

`TaxProfile` gains `toAnswers()` and `withAnswers(answers)` so a form that knows only a pack's questions can edit any profile. By default the answers are the stored JSON and applying them decodes through the pack's `profileFromJson`, so the result is validated like any stored profile. Two profiles differ from their JSON: `UsTaxProfile` reads its `dependents` list as the three dependents questions (the counts under and over 17 and one SSN answer) and composes the list back from them, leaving the stored list untouched when those answers did not change so dependents with mixed SSN answers are not flattened by an unrelated save; `GbTaxProfile` includes the accounting period end it omits from JSON at the default. Stored JSON is unchanged.
