---
openbudget_server: feat
---

# Resolve and store Money guide citations (G9)

`AgentService` resolves every `[^key]` in an assistant reply against the tool results stored in the conversation: a `search_knowledge` card's `citeAs`, or a tax tool result's `citeAs`. A pure `CitationCatalogue` in `money_guide/citation_resolver.dart` strips keys it cannot resolve, including a real card id the model never retrieved, before the reply is stored or sent. The reply arrives whole, so the stored text, the streamed `textDelta` and the history the model sees next are the same string and no key can be split across chunks.

`agent_message` gains `citationsJson` and `touchesTaxOrInvestment` (one migration, `money-guide-citations`), and the `textDelta` `AgentEvent` carries `citations` and `touchesTaxOrInvestment`. A reply touches tax or investment when it cites a card whose perimeter is not `general`, or a tax report or summary.

`get_tax_report` now returns `citeAs` as `report-<startYear>`, and `get_tax_summary` returns `citeAs` as `summary-<startYear>` with the pack's authority pages in `sources`. A universal-layer summary carries neither, so it cannot be cited.
