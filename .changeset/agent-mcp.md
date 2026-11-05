---
openbudget_client: feat
openbudget_server: feat
---

# Connect external agents over MCP

Add a Streamable HTTP MCP server at `POST /mcp` so Claude Code, Codex and any other MCP client can read a user's budgets and tax reports through the same tool registry as the in-app assistant. Tools check ownership from the token's user id, record pending proposals the user applies in the app, and never write financial data directly.

Access is authorised by personal access tokens with `AgentTokenEndpoint.createAccessToken`, `listAccessTokens` and `revokeAccessToken`. A token is `obk_` plus 32 random bytes, shown once and stored only as a SHA-256 hash; revocation is immediate, users may hold ten unrevoked tokens, and `lastUsedAt` is recorded at most once a minute. Tokens can be read-only or allow the propose tools.

The route rejects non-POST methods, unauthorised tokens and disallowed browser origins, negotiates MCP protocol versions, and rate limits each token to 120 requests a minute. It answers JSON rather than SSE. Tokens, headers and tool results are never logged. `agent_access_token` gets its own table in one migration.
