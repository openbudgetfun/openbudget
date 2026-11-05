# Connect an external agent over MCP

OpenBudget exposes a [Model Context Protocol](https://modelcontextprotocol.io)
server at `POST /mcp`. Claude Code, Codex and any other MCP client can read your
budgets and tax reports through the same tools the in-app assistant uses.

Agents never change financial data directly. A tool that suggests a change
creates a pending proposal, and you apply or dismiss it in OpenBudget.

> The agent's answers are guidance, not regulated financial or tax advice.

## Create a personal access token

1. Open OpenBudget and go to the assistant's **External agents** settings.
2. Create a token, give it a name such as `Claude Code`, and choose whether it
   may propose changes.
3. Copy the token immediately. It is shown once and cannot be recovered; the
   server stores only its SHA-256 hash.

Token creation and revocation go through `AgentTokenEndpoint`, which the app
calls with your signed-in session. When the External agents screen is not in
your build, the same call is available from any signed-in `Client`:

```dart
final created = await client.agentToken.createAccessToken(
  'Claude Code',
  true, // allow propose tools; false makes the token read-only
);
print(created.token);

final tokens = await client.agentToken.listAccessTokens();
await client.agentToken.revokeAccessToken(created.view.id);
```

A user may hold ten unrevoked tokens at once. Revoking is immediate and
idempotent; a revoked token is rejected on its next request. The token list
shows each token's name, its first 12 characters, when it was created, when it
was last used, and whether it was revoked. It never shows the token or its
hash.

## Connect a client

Claude Code:

```sh
claude mcp add --transport http openbudget https://your-openbudget-server.example/mcp \
  --header "Authorization: Bearer obk_your_token"
```

Other clients that accept a streamable HTTP server with headers:

```json
{
  "mcpServers": {
    "openbudget": {
      "type": "http",
      "url": "https://your-openbudget-server.example/mcp",
      "headers": {
        "Authorization": "Bearer obk_your_token"
      }
    }
  }
}
```

The server answers with JSON, not an SSE stream. It requires `POST`; `GET` and
`DELETE` return `405 Method Not Allowed`. A missing, invalid or revoked token
gets `401 Unauthorized` with a `WWW-Authenticate: Bearer` challenge.

### Browser origins

Command-line clients send no `Origin` header and are always allowed. A browser
client must send an `Origin` that appears in the comma-separated
`mcpAllowedOrigins` server password:

```yaml
mcpAllowedOrigins: https://app.example.com,https://staging-app.example.com
```

If no origins are configured, every request that carries an `Origin` is
rejected with `403 Forbidden`.

## Tools

A token created with proposal access sees all eight tools. A read-only token
sees only the five read tools; calling a propose tool returns a tool error.

| Tool                               | Access  | What it does                                                                     |
| ---------------------------------- | ------- | -------------------------------------------------------------------------------- |
| `list_budgets`                     | read    | Lists the budgets you own, with their currencies.                                |
| `list_envelopes`                   | read    | Lists one budget's envelopes with this month's assigned, activity and available. |
| `search_transactions`              | read    | Searches one budget's transactions by text, date range or both.                  |
| `get_tax_report`                   | read    | Computes a budget's tax report for a tax year, with sources and assumptions.     |
| `list_tax_categories`              | read    | Lists the tax category codes available to one budget.                            |
| `propose_move_money`               | propose | Proposes moving money between two envelopes in one month.                        |
| `propose_transaction_tax_category` | propose | Proposes changing one transaction's tax category.                                |
| `propose_envelope_tax_category`    | propose | Proposes setting one envelope's default tax category.                            |

Every tool checks ownership from the token owner's user id, so a token can only
reach its owner's data. Tool results and credentials are never logged.

## Apply proposals in the app

A propose tool returns a proposal id, a one-sentence summary and the status
`pending`. The change is not made until you act on it in OpenBudget, where the
proposal appears alongside ones from the in-app assistant:

- **Apply** runs the normal budget or tax service and marks the proposal
  applied.
- **Dismiss** closes it without touching any data.

Applying is also available through `AgentEndpoint.applyProposal` and
dismissing through `AgentEndpoint.dismissProposal`.

## Limits

Each token may make 120 requests per minute; the server answers `429 Too Many
Requests` beyond that. The limit is per server process and resets when the
server restarts.
