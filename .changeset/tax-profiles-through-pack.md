---
openbudget_core: refactor
---

# Move the tax profiles into their rule packs

`TaxProfile` is no longer sealed: each pack now owns its profile class, decoder and questions in `openbudget_core/lib/src/tax/<cc>/<cc>_profile.dart`, and `TaxRulePack` gains `profileFromJson` (which `TaxProfile.fromJson` delegates to, so the pack is the single definition of its stored fields) and `profileQuestions` (the questions the app asks to build a profile, as data). `TaxProfile` itself keeps the shared fields, the strict field readers and the question types. Stored JSON keeps today's shape: every fixture captured from the current serialisation round-trips byte-identically, and the two new tax-planning-guardrail questions (tax residence and US person) are stored only when answered, so profiles saved before them keep their exact bytes. The shared strict readers that were private to `tax_profile.dart` are now public (`taxProfileField` and friends), which is a breaking change for out-of-workspace code that reached into the file; nothing in the workspace did. The app still renders the hand-built per-country form until the generic form lands.
