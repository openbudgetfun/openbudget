---
openbudget_client: feat
openbudget_server: feat
---

# Add the financial assistant

Add `AgentEndpoint`, a server-side assistant every OpenBudget Plus subscriber can chat with. It runs on OpenCode Zen through an OpenAI-compatible Chat Completions client, or on the user's own OpenAI-compatible provider, and answers from the user's own budgets, transactions, envelopes and tax reports through a tool registry. Tool calls check budget ownership from the stored owner column, so the same registry can back an MCP server later.

The assistant never changes data. Its propose tools insert a pending `AgentProposal` — a money move or a transaction/envelope tax category — that the user applies or dismisses. Applying runs the existing monthly allocation and tax services inside the caller's session.

Zen calls are metered from token usage at the published prices and stop once the $1 included in each period is spent. BYO calls skip the entitlement and are recorded at zero cost. A BYO API key is stored with AES-256-GCM, and only its last four characters ever reach the client. Conversations, messages, usage records, proposals and provider settings get their own tables in one migration.
