---
openbudget_server: feat
---

# Keep Money guide calls under the context ceiling (G10)

`ContextBudget` in `money_guide/context_budget.dart` builds the history of every model call. When the history passes 32,000 estimated tokens it replaces the bodies of tool results older than the last two turns with `{"elided": true, "tool": "...", "citeAs": "..."}`, once per crossing, so the provider's prompt cache breaks once and not on every call. The stored rows are never rewritten and the compaction is replayed from them on each call, so no migration is needed and the citation catalogue still resolves every key an elided result carried.

No call carries more than 40,000 estimated tokens. A user message longer than 4,000 estimated tokens is refused before any call. If a call is still over the ceiling after compaction, tool results are elided oldest first for that call only, and if it cannot fit even then the turn stops with a "conversation too long" error and no call is made.

`AgentUsageView.conversationsLeft` is the remaining allowance divided by the median cost of the user's newest 20 metered conversations, rounded down. It is null below three conversations, for bring-your-own providers, and when the typical conversation costs nothing. `AgentUsageService.view` takes an optional `now` so tests can pin the subscription period.
