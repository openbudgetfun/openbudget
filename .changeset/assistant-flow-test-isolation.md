---
openbudget_app: test
---

# Keep More-screen Patrol flows off the live client

The More screen's books entry reads the budget and tax profile, so the assistant and More-screen flows now answer those providers with local fixtures and assert the production Serverpod client is never created. A late connection attempt to the API can no longer fail a test after it passes.
