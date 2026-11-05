---
openbudget_client: fix
openbudget_server: fix
---

# Send typed server errors to the client

Every server exception (`ValidationException`, `NotFoundException`, `TaxRulesUnavailableException`, `EntitlementRequiredException`, the billing and agent errors, and the rest) is now a Serverpod serializable exception declared in `openbudget_server/lib/src/exceptions/*.spy.yaml`. Clients receive the exception type and its `message` instead of a generic internal-server-error, so the app can show the specific problem. Constructors take named fields (`ValidationException(message: '...')`, `BillingProviderException(provider:, details:)`).
