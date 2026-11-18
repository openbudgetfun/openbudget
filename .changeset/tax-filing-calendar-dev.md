---
openbudget_client: feat
openbudget_core: feat
openbudget_server: feat
---

# Add the filing calendar (C5)

`TaxRulePack.deadlines(period, profile)` derives the filing and payment dates a tax year creates, as `TaxDeadline` values with a stable rule id, a neutral title, the period covered, a source and citation, an evidence grade, a profile-dependence flag and, when a weekend or holiday moved it, the date before. GB, US, NG and DE take their dates from the four country skills: the US pack moves a date to the next business day under § 7503 (federal holidays plus DC Emancipation Day), the DE pack reuses its § 149 and § 108 AO logic, and the GB and NG packs move nothing. Dates the profile or the books do not hold stay out, and the contract test lists each one with its reason.

`tax.listDeadlines(entityId)` returns the entity's deadlines from today to a year ahead, with days left. It enforces ownership, gives an empty list for a country without a pack and uses the entity's own facts and the pack's defaults when no profile is saved. The tax overview shows the next dates in an Upcoming list (`TaxUpcomingSection`, behind `taxDeadlinesProvider`). The generated protocol and client carry the new `TaxDeadlineView`. The US and NG manifests now report the filing calendar as partial.
