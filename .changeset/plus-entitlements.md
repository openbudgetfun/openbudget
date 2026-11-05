---
openbudget_client: feat
openbudget_server: feat
---

# Record OpenBudget Plus subscriptions per payment rail

Add the `entitlement` table, `EntitlementService`, and `BillingEndpoint.getEntitlement`. Each payment rail (Stripe, RevenueCat, Solana) records its own subscription row keyed by the rail's id; access holds through `currentPeriodEnd` for active, past-due and cancelled subscriptions, and the period ending last wins. `BillingPlan` fixes the $10 monthly price and the $1 of built-in agent usage included each period.
