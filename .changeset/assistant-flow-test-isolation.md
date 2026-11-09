---
openbudget_app: test
---

# Isolate the assistant Patrol flow from the live client

The More screen's books entry reads the budget and tax profile, so the assistant flow now answers those providers with local fixtures and asserts the production Serverpod client is never created. A late connection attempt to the API can no longer fail the test after it passes.
