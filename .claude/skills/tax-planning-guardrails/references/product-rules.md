# Product rules for opportunities and the assistant

These are design rules derived from the research in this skill (grades in the other references). They must be reviewed by counsel per jurisdiction before launch.

## 1. Wording

Principle: say what the law allows and what the user's own figures show; never tell the user what to do or what is best.

| Do                                                                                                                  | Do not                                          |
| ------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------- |
| "The pension annual allowance is £60,000 this year. Your figures show £0 recorded."                                 | "Use your pension allowance."                   |
| "A gross contribution of £5,000 would reduce the estimate by about £2,000, based on your entered income."           | "You should pay £5,000 into a pension."         |
| "The standard deduction is $X more than your itemised total. This report uses the standard deduction."              | "Take the standard deduction."                  |
| "Losses realised by 31 December offset gains realised in the year. Your report shows net gains of $X."              | "Harvest capital losses."                       |
| "The rent relief is 20% of rent paid, up to ₦500,000. Add your rent and keep the receipts."                         | "Claim rent relief." (when no rent is recorded) |
| "Taking £12,570 salary and the rest as dividends shows the lowest total in the comparison. All options are listed." | "Take £12,570 salary."                          |
| "Depending on your situation, an accountant can confirm whether this applies."                                      | "This will save you £X."                        |

Title rules: neutral noun phrases. Banned in titles and bodies: imperative verbs addressed to the user as advice, "should", "must", "we recommend", "best", "optimal", "guaranteed", "loophole", "risk-free", "beat the taxman". Allowed: "is estimated to", "the rule is", "your figures show", "would reduce the estimate by", "if you choose to".

Every opportunity states: rule and tax year; figures used; the computed saving and what it compares; assumptions; deadline; source URL; the grade (primary, secondary, inferred) when not primary; the `announced` flag when applicable; what would change the answer.

An opportunity with an unverified key figure shows no saving. An `announced` rule is labelled "announced, not yet law" and never changes a liability.

German copy: "nach den erfassten Zahlen", "die gesetzliche Grenze beträgt", "wäre nach dieser Schätzung", never "Sie sollten", "wir empfehlen", "Handlungsempfehlung". Written by a German speaker.

## 2. Disclaimers

Use short, specific disclaimers keyed by `disclaimerKey` and localised through `AppLocalizations`. Place them on every opportunity card, every assistant message that suggests a tax or investment action, and every export.

- Standard (English): "Information only, based on the figures you entered and the rules we checked on {date}. This is not tax, legal or investment advice and does not know your full circumstances. Rules change. A qualified professional should confirm anything you act on."
- UK addition: "This does not recommend any investment, pension or ISA product."
- US addition: "General educational calculation. Not a written federal tax opinion and not investment advice."
- DE addition: "Allgemeine Information, keine Steuerberatung im Einzelfall. Für Ihren Fall wenden Sie sich an einen Steuerberater oder Lohnsteuerhilfeverein."
- NG addition: "Confirm with a registered tax practitioner and the tax authority before relying on this."

Rules: a disclaimer is never the only guardrail. A disclaimer attached to wording that is advice does not fix it. State the scope plainly ("I can show what the rules allow and what your figures show; I cannot choose products or decide for you").

## 3. When to signpost a professional

The assistant and the opportunity code must route to a qualified professional (accountant, tax adviser, Steuerberater, registered practitioner, or for UK pensions and investments an authorised adviser or MoneyHelper) and say why, when any of these hold:

- Residence or domicile is unclear, the user arrived in or left a country this year, or the user is a UK arrival after ten or more years abroad (FIG).
- The user is a US person living abroad, or has income in more than one country.
- Owner-managed company structure questions: shares, holdings, GmbH, entity election, group structures, associated companies, share issues, loans above £10,000 to or from the company, dividend legality doubts.
- Any "should I" or "which one" question about a specific investment, fund, ISA, pension provider, withdrawal, property or crypto position.
- Estimated saving above a configured threshold per jurisdiction (set in rule data).
- HMRC, IRS, BZSt, state IRS or NRS letters, penalties, investigations, amended returns, late filings, or anything that sounds like evasion.
- Trusts, inheritance, large gifts, divorce, bankruptcy.
- The relief needs facts the books do not hold (qualifying conditions, evidence).
- A rule is secondary, inferred or announced and the user wants to act before it is confirmed.

Wording: "This is a point where a qualified adviser can look at your whole situation. I can prepare the figures and questions to bring."

## 4. Assistant behaviour contract

- Tools only for facts. Never guess an amount.
- Cite `rulesVerifiedOn`, assumptions and sources from the tool result. Say when figures are incomplete (uncategorised or converted transactions).
- Never claim a change was made; changes are proposals the user applies.
- No product picking, no named securities, no allocation, no withdrawal rates, no "people like you".
- Decline to design anything on the never-suggest list and say why, once, plainly.
- Ask residence and citizenship before country-specific levers.
- Ask for evidence for evidence-based reliefs.
- Do not infer a user's tax position from other users or from "typical" cases.
- If the question is outside scope (legal advice, filing on the user's behalf, investment selection), say so and point to the right kind of professional.

## 5. Proposals stay user-approved

- Propose tools create a pending proposal. Apply and dismiss happen only through the user-facing endpoint.
- Allowed proposal kinds today: move money between envelopes, set a transaction tax category, set an envelope default tax category. A new kind needs a design review against this skill. **Never** add a kind that files, pays, transfers real money, sets an election, applies for a relief, changes residence or entity status, or places an order.
- A tax-category proposal is a bookkeeping suggestion with a reason. It must not imply a tax saving unless the saving is computed from rule data and shown.
- Store with each proposal: the rule version or `rulesVerifiedOn` and tax year the reason relied on, the opportunity id if any, and the model and tool outputs reference. The current `AgentProposal` stores only kind, payload, summary and status.
- Validate again at apply time (category code valid for the budget's jurisdiction and entity kind, entity still owned by the user), not only at propose time.
- Show the user what will change and what it affects before apply (a tax category change alters the report).

## 6. Prompt and tool-result checklist

System prompt (`MoneyGuidePrompt.staticRules` plus the generated entity brief) must say, in this order of importance:

1. Scope: guidance only; no regulated tax, legal or investment advice; no product, security or allocation choices.
2. Perimeter rules per the user's jurisdiction (injected from the tax profile, not hard-coded to one country).
3. The never-suggest list in short form, with an instruction to decline and signpost.
4. Wording rules (no "should"; show the arithmetic; show grade and `announced` status).
5. Signpost triggers.
6. Proposals only; never claim changes were made.
7. Residence and citizenship first; evidence prompts.
8. Privacy: do not repeat personal identifiers unnecessarily.

Tool results (`get_tax_report`, MCP `tools/call`) must carry a `guidance` block: disclaimer key, scope statement, rule year, `rulesVerifiedOn`, grade and `announced` for each opportunity, and a perimeter class per opportunity (`taxIllustration`, `signpostOnly`). An MCP client or BYO provider does not see the system prompt, so the payload is the guardrail.

Opportunity rows carry: `grade`, `announced`, `signpostOnly`, `assumptions`, `needsEvidence`, `ruleYear`. Rows that are `signpostOnly` carry no saving.

## 7. State of the code on 5 November 2026 (dated; re-audit before relying)

- `AgentPrompt.system` (since replaced by `MoneyGuidePrompt`, which carries these rules) stated scope, tool grounding, no-change-claims, and a one-line "guidance, not regulated advice" instruction. It lacks perimeter rules per country, the never-suggest list, wording rules, signpost triggers, residence prompts, and anything about grade or `announced` status. It frames the assistant as helping "building wealth".
- `AgentMcpHandler.instructions` has a one-sentence disclaimer only. Tool results carry no disclaimer, grade or perimeter fields.
- `TaxOpportunity` has `id`, `title`, `explanation`, `source`, `estimatedSavingMinor`, `deadline`. No grade, `announced`, `signpostOnly`, evidence, or rule-year field.
- Several opportunity titles are imperatives ("Use your pension annual allowance", "Shelter savings and dividends in an ISA", "Harvest capital losses", "Itemize deductions", "Claim rent relief", "Pay quarterly estimated tax", "Basisrente bis zum Höchstbetrag einzahlen", "Homeoffice-Pauschale ausschöpfen").
- `gb.director_salary_vs_dividend` and `de.geschaeftsfuehrer_vergleich` name a specific pay split; the UK one is a total-cost comparison but outputs only the cheapest, the German one is signpost-only territory.
- Propose tools exist for budgeting and tax category only; none files, pays or transfers. Good. Proposals do not record rule version.
