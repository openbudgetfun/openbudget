---
openbudget_app: feat
openbudget_client: feat
openbudget_server: feat
---

# Account deletion and store review blockers

`settings.deleteAccount` deletes the caller's entities (cascading to accounts, plan, transactions, books, tax profiles, Plaid connections and wallets) and then the auth user (cascading to sign-in methods, sessions, settings, Money guide rows and billing rows) in one transaction, after asking Plaid to revoke each item through the new `PlaidService.revokeItems`. It throws `ValidationException` while an `active` or `pastDue` entitlement exists, so nobody keeps being charged for a deleted account; a `canceled` plan does not block. No migration: the entity owner foreign key stays `Restrict` and the service deletes entities explicitly.

In the app, `DeleteAccountScreen` replaces its "unavailable" stub with a confirmation flow backed by `accountDeletionProvider`, and `AuthNotifier.forgetDeletedAccount` clears the stored sign-in. Settings opens `LegalLinks.privacyPolicy` and `LegalLinks.termsOfService` through `legalLinkLauncherProvider` instead of a "coming soon" toast, and the two remaining stub rows are removed. The iOS and macOS `Info.plist` files declare `ITSAppUsesNonExemptEncryption` as false (the app only uses HTTPS), and macOS declares the finance category the Mac App Store requires.
