---
openbudget_server: feat
---

# Add search_knowledge and the guidance block (G6)

The Money guide now has a `search_knowledge` tool backed by the G2 BM25 index, registered in `AgentToolRegistry` and exposed over MCP. Results carry `citeAs`, resolved card bodies and a `guidance` block. Entities in a country without a pack get a universal hint from `get_tax_report` instead of an error, and the MCP `instructions` carry the short guardrail rules. Every tax and knowledge tool result now carries a `guidance` block with the disclaimer key, scope statement, jurisdiction state, rules version and signpost targets.
