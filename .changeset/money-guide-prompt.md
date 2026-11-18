---
openbudget_server: feat
---

# Add the Money guide prompt

`MoneyGuidePrompt` replaces `AgentPrompt` in `openbudget_server/lib/src/money_guide/money_guide_prompt.dart`. Every model call now opens with two system messages: the static rules of `docs/money-guide.md` section 7.2, identical for every entity so provider prompt caching is shared, and a generated entity brief. The rules cover guidance-not-advice framing, sourced-facts-only with `[^key]` citations, jurisdiction states, the never-suggest list, wording, signposting and propose-only changes. The brief carries the country, entity kind, base currency, tax year, the state of each tax section (`full`, `preview` or `universal`) from the pack manifest, the rules version, the guidance perimeter and professional, the recorded residence and US-person answers, the indirect-tax rates of a country without a pack, and the ids and titles of the knowledge cards the model may read. It never carries the entity name or any identifier. Golden snapshots pin the brief for GB, US, DE, NG and Kenya.
