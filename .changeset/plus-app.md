---
openbudget_app: native
---

# Add subscription management for OpenBudget Plus

Add the `/plus` screen and its payment rails: Stripe Checkout and billing
portal links on web and desktop, RevenueCat App Store and Play Store purchases
on mobile, and a Solana USDC wallet flow on web. `plusEntitlementProvider`
exposes the active subscription to other features, and RevenueCat is
identified with the signed-in user so webhooks record the right account.
Adds `purchases_flutter`, `url_launcher`, and the Solana Kit wallet packages,
which makes this a native release.
