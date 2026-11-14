---
openbudget_app: feat
---

# Render Money guide citations, disclaimers and the conversations-left estimate (G11)

The assistant feature now presents itself as the Money guide (`docs/money-guide.md`, section 3). The `assistant*` ARB keys keep their names; their values and the Plus copy say "Money guide", and a widget test scans every assistant screen for a visible "assistant" label.

- Replies keep the server's `AgentEvent.citations` and `touchesTaxOrInvestment`, and stored messages read `citationsJson`, as `AssistantSource` values on `AssistantTimelineItem.assistant`.
- `parseCitedReply` numbers `[^key]` markers in order of first appearance, reuses a key's number, drops markers with no source and lists uncited sources last.
- Marks render as `TextSpan`s on a spot-ink wash, padded with no-break spaces so they wrap with their word, with a tap recognizer, a "Source N: title" semantics label and a 44-point near-miss target. Tapping one, or the "N sources" button, opens `AssistantSourcesSheet`.
- `SourceGradeChip`, `SourceLinkText` and `openSourceLink` move out of `universal_tax_panel.dart` into `tax/widgets/source_widgets.dart`, so the tax panel and the sources sheet share one badge and link style.
- Flagged replies show `assistantDisclaimer` under the message; the usage meter shows `assistantConversationsLeft` when `AgentUsageView.conversationsLeft` is set.
