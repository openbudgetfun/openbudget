---
openbudget_server: feat
---

# The Money guide knowledge base: card format, generator and index

Knowledge cards now have their format and tooling (`openbudget_server/knowledge/`, docs/money-guide.md sections 4.1 and 4.2). `dart run tool/generate_knowledge.dart` parses the Markdown front matter, validates every card — sources, the 300-word limit, the guardrails wording lint, and that every `{{figure:id}}` placeholder exists in the country pack for each listed tax year — and writes the cards as Dart constants under `lib/src/money_guide/knowledge/`; `--check` fails when the committed constants drift, and CI runs it in the lint job. A pure-Dart BM25 index ranks cards with the title/keyword/body weights of section 5.2 and filters by country, tax year and entity kind. Five sourced sample universal cards ship with it.
