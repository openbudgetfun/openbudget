---
name: tax-planning-guardrails
description: Legal tax-planning levers (UK, US, Nigeria, Germany), the computation behind each saving, cross-border residence and treaty basics, anti-avoidance rules, a never-suggest list, and the regulatory boundary for the in-app AI assistant. MUST be loaded by anyone touching `openbudget_server/lib/src/agent/` or `money_guide/` (Money guide prompt, tool registry, MCP handler, proposals), any `*_opportunities.dart`, `opportunities()` in a rule pack, `TaxOpportunity` or `TaxOpportunityView`, or any user-facing wording that suggests a tax or investment action.
---

# Tax planning guardrails

OpenBudget shows users legal ways to owe less and lets an AI assistant discuss them. It is guidance software, not an adviser. This skill lists the levers worth surfacing, how to quantify each one, what must never be suggested, where the UK, US, German and Nigerian regulatory lines sit, and the product rules that keep the assistant on the guidance side of them.

Research date: 5 November 2026. Tax years: UK 2025/26 and 2026/27; US, DE, NG calendar 2025 and 2026. Most of the research behind this skill was secondary (advisers, news, calculators); grades are shown on every figure. The regulatory sections are design inference and must be validated with counsel in each jurisdiction before launch.

## When to use

Load this before you:

- edit `openbudget_server/lib/src/agent/` and `openbudget_server/lib/src/money_guide/` (`money_guide_prompt.dart`, `agent_tool_registry.dart`, `agent_tax_reports.dart`, `agent_proposal_service.dart`, `mcp/agent_mcp_handler.dart`);
- add or change an opportunity in `openbudget_core/lib/src/tax/{gb,us,ng,de}/` (`gb_tax_rules.dart` `_individualOpportunities` and `_directorSplitOpportunity`, `us_tax_rules.dart`, `ng/ng_opportunities.dart`, `de/de_opportunities.dart`);
- change `TaxOpportunity`, `TaxOpportunityView`, or how reports reach the assistant or an MCP client;
- write copy, disclaimers, empty states or notifications that say "you could save".

Also load the matching country skill for the underlying rules (`uk-company-tax` for company and director figures).

## Source-of-truth rules

- Every limit, rate and threshold in an opportunity comes from per-year rule data in `openbudget_core` with source URL and verified-on date. No numbers in explanation strings other than values interpolated from rule data. The current code inlines some (for example salary candidates and the 80% payments-on-account test in `gb_tax_rules.dart`); move them to the rate tables when touched.
- A saving is `taxWith(baseline) - taxWith(lever applied)`, recomputed by the same pure functions that built the report, using the user's own entered figures. If the saving depends on a fact the books do not hold, leave `estimatedSavingMinor` empty and say what is missing. Never guess.
- Mark each rule **primary**, **secondary** or **inferred**. A lever whose key figure is secondary or inferred must carry that grade and must not produce a numeric saving until verified. Announced-not-enacted rules carry an `announced` flag and never feed a liability or saving.
- Money is integer minor units. Percentages are basis points.

## Core rules

1. **A lever is a statutory relief applied to something the user really did or genuinely will do**, or a timing shift in a genuine transaction. The app does not design structures, choose products or tell users what to do with their money.
2. **Show the arithmetic.** Each opportunity states: the rule and year, the figures used, the saving and how it was computed, what it assumes, the deadline, the source link, and what would change the answer.
3. **Wording.** Describe what the law allows and what the user's figures show. Use "the allowance is", "your figures show", "would reduce the estimate by". Do not use "you should", "you must", "best", "optimal", "we recommend". Titles are neutral noun phrases ("Pension annual allowance", not "Use your pension annual allowance"). Templates are in `references/product-rules.md`.
4. **Never suggest** anything on the never-suggest list (`references/anti-avoidance-never-suggest.md`): contrived schemes, income splitting without genuine work or capital, disguised employment, below-market owner pay, wash sales, concealment, falsified evidence, and any arrangement whose main purpose is a tax advantage. If the user proposes one, decline to design it and signpost a professional.
5. **Regulatory perimeter.**
   - **UK:** tax illustrations are not themselves regulated, but personal recommendations on investments and pensions are. The FCA targeted support regime (COBS 9B, in force 6 April 2026) covers suggestions to groups of customers with common characteristics. Do not pick ISA products, funds, pension providers or withdrawal rates, and do not say "people like you usually...".
   - **US:** keep output impersonal in kind: same inputs, same output, rule-based. No security selection, allocation or trade timing. Tax-loss harvesting on named securities is investment advice territory.
   - **Germany:** general information, calculators and standard workflows are the safe zone; Einzelfall tax advice (Steuerberatung) is reserved under StBerG §5. GmbH, holding and Gehalt-versus-Ausschüttung comparisons are signpost-only until counsel clears them.
   - **Nigeria:** no regulatory source was found; apply the strictest of the above and signpost a registered tax practitioner.
6. **Disclaimer is necessary and never sufficient.** A disclaimer does not cure behaviour that is advice. Include it where an action is suggested and also make the behaviour conform.
7. **Signpost a professional** (triggers in `references/product-rules.md`) for non-doms or recent arrivals, US persons abroad, owner-managed company structures, holdings, anything over a stated size, anything touching an investigation or penalty, residence disputes, and any "should I" question about a specific investment.
8. **User approval, always.** The assistant has read tools and propose tools only. A proposal is a pending row the user applies or dismisses. It never files, pays, moves real money, sets elections, or executes an opportunity. Never claim a change was made before the user applies it. Proposals record the rule version, tax year and `rulesVerifiedOn` that justified them.
9. **Guardrails must travel with the data.** The MCP surface and any third-party client bypass `MoneyGuidePrompt`. Disclaimers, assumptions, rule year, grade and `announced` flags belong in the tool result payload, not only in the system prompt.
10. **Residence and citizenship first.** Ask where the user is tax resident and whether they are a US person before showing country-specific levers. A US citizen or green-card holder living abroad needs US analysis everywhere. Wrong-country levers are worse than none.
11. **Documentation prompts.** For any relief that needs evidence (Nigerian rent relief, German home office days, charitable receipts, pension statements) ask for the evidence, not only the number.
12. **Privacy.** Send the model only what a tool result needs. Nothing in the prompt identifies the user. Do not add personal data to provider requests (the current prompt comment states this; keep it true).

## Where it lives in OpenBudget

- Contract: `openbudget_core/lib/src/tax/tax_model.dart` (`TaxOpportunity`: id, title, explanation, source, `estimatedSavingMinor`, `deadline`) and `tax_rule_pack.dart` (`opportunities(input, report)`).
- Packs: `gb/gb_tax_rules.dart`, `us/us_tax_rules.dart`, `ng/ng_opportunities.dart`, `de/de_opportunities.dart`. Rates in `*_rates.dart` or `*_tables.dart`.
- Assistant: `openbudget_server/lib/src/money_guide/money_guide_prompt.dart` (static rules and entity brief), `agent_tool_registry.dart` (tools, propose tools), `agent_tax_reports.dart` (maps opportunities into `TaxOpportunityView`), `agent_proposal_service.dart` (apply and dismiss), `mcp/agent_mcp_handler.dart` (`instructions`), `agent_proposal*.spy.yaml` (proposal model).
- New guardrail code goes in `openbudget_core` as pure data and functions (opportunity grade, `announced` flag, perimeter class, disclaimer keys) so the server, app and MCP surface share one source. User-visible disclaimer strings go through `AppLocalizations`, with German text reviewed by a German speaker.

## Testing

- Encode every vector in `references/test-vectors.md`. Savings are exact integers; tolerance 0 minor units except where noted.
- Add a wording lint test over every opportunity string in every pack and language: reject "you should", "you must", "we recommend", "best option", "guaranteed", "loophole", and imperative titles.
- Add agent eval cases (list in `references/test-vectors.md`): refusals, signposts, no claim of applied changes, no product picking, announced rules flagged.
- Assert tool results include the guardrail fields (rule year, assumptions, grade, disclaimer key), not only the system prompt.
- Assert propose tools never apply anything and that the proposal row stores the rule version.

## Unverified and changing

Re-check by **1 December 2026**, and again after each Budget or Finance Act.

- All "announced" UK items: Budget 2026 (28 October 2026, secondary sources only): cash ISA limit cut to £12,000 for under-65s from April 2027 reportedly **scrapped**, Lifetime ISA to be replaced by a First-Time Buyer ISA, savings and property income rates up again from April 2027 (sources disagree on size), trading allowance £1,000 to £3,000, mandatory payrolling of benefits from April 2027, MTD for Income Tax threshold £30,000, BADR lifetime limit halved to £500,000 from April 2027 (one calculator site only). No GOV.UK or HM Treasury page confirmed any of these.
- UK pension annual allowance £60,000, taper, MPAA £10,000, carry forward, NIC rates, Employment Allowance £10,500, trivial benefits, marriage allowance, HICBC thresholds, Gift Aid mechanics, settlements legislation: background knowledge, not fetched.
- US: SEP and solo 401(k) limit $72,000, Roth catch-up rule, wash-sale text, capital loss limit, QBI thresholds, Social Security wage base, reasonable compensation case law, backdoor Roth pro rata: background. OBBBA 35% cap mechanics (IRC §68) not read. FEIE amounts for 2025 and 2026 not retrieved.
- Nigeria: voluntary pension deductibility conflict between sources; small-company turnover threshold (₦100m in most sources, ₦50m in one 27 October 2026 article and in the current repo code); capital allowance rules; the NTAA ss.46 and 47 text; NTA s.191 versus s.193 cross-reference.
- Germany: no primary amounts fetched except StBerG §§5 and 6. Riester, Investitionsabzugsbetrag, GWG, Arbeitszimmer, Ehegattensplitting, Steuerklassen, GmbH, Teileinkünfteverfahren: background.
- Regulatory: FCA perimeter guidance status, PERG text, US Circular 230 §§10.34 and 10.37, §7216 consent, SEC robo-adviser guidance, state adviser law, EU AI Act, GDPR and NDPA duties, German AI-chatbot case law, BStBK FAQ on AI (27 January 2026, unread), OLG Hamburg 4 U 81/16 (unread), Nigerian professional regulation: none retrieved.
- Treaty texts (UK-US, UK-Germany, UK-Nigeria, Germany-Nigeria status, US-Nigeria none per the IRS list): not read.

## References

- `references/levers-uk.md`: UK levers, figures, sources, computations.
- `references/levers-us.md`: US levers, 2025 and 2026 limits, computations.
- `references/levers-nigeria.md`: Nigeria Tax Act 2025 levers and the disputed thresholds.
- `references/levers-germany.md`: German levers and what is signpost-only.
- `references/cross-border.md`: UK SRT, FIG regime, US treaty list, FEIE, US persons, what to ask first.
- `references/anti-avoidance-never-suggest.md`: anti-avoidance rules per country and the never-suggest list.
- `references/regulatory-boundary.md`: FCA, SEC and Circular 230, German StBerG, Nigeria; design rules per perimeter.
- `references/product-rules.md`: wording templates, disclaimers, signpost triggers, proposal flow, prompt and tool checklist.
- `references/test-vectors.md`: computed savings, wording lint cases, agent eval cases.
