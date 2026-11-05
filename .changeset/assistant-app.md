---
openbudget_app: feat
---

# Add the financial assistant screens

Add the assistant feature to the app:

- `AssistantScreen` (`/budgets/:id/assistant`) streams a turn through `client.agent.chat`, draws tool calls as chips, proposals as inline cards, and shows the included usage meter or the user's own provider.
- `AssistantProposalsScreen` (`assistantProposals`) lists pending proposals and a collapsed history, with apply and dismiss calling the server and refreshing both the list and any inline card.
- `AssistantProviderScreen` (`assistantProvider`) saves an HTTPS OpenAI-compatible base URL, model and API key, shows the stored key hint, and removes the provider.
- `AssistantApi` wraps the generated agent endpoint behind an interface, `AssistantChat` and `AssistantProposals` hold Freezed state through Riverpod notifiers, and `assistantFailureFrom` maps entitlement, allowance, provider, validation and network exceptions to specific UI.
- Entry points in More and Settings, routes and route names, English strings, widget tests with `pumpApp`, provider tests with a fake API and chat stream, and a Patrol flow in `integration_test/assistant_flow_test.dart`.
