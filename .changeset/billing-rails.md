---
openbudget_client: feat
openbudget_server: feat
---

# Add Stripe, RevenueCat and Solana payment rails

Add hosted Stripe Checkout and billing portal sessions, signed Stripe webhooks, and RevenueCat App Store and Play Store webhooks that record entitlements. Add the Solana Subscriptions Delegation Program rail: plan terms, a wallet ownership challenge, on-chain subscription verification, and an hourly collector future call that charges 10 USDC per 30-day period and advances, past-dues or expires the entitlement. New models: `StripeCustomer`, `SolanaBillingChallenge`, and `SolanaPlanView`.
