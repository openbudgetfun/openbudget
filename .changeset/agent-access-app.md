---
openbudget_app: feat
---

# Add the Agent access settings screen

Add `/agent-access` with token creation, a one-time secret dialog with copy, a
token list showing each prefix, creation and last-used dates plus revoked state,
and revoke confirmation. `AgentTokenApi` wraps `EndpointAgentToken` so tests
inject a fake, and `agentAccessTokensProvider` refreshes the list after every
mutation.
