# Regulatory boundary for the in-app AI assistant

Grades: **[P]** primary, **[S]** secondary, **[I]** design inference, **[B]** background not fetched. The design rules are inference. They must be validated with counsel in each jurisdiction before launch. Disclaimers do not cure regulated behaviour.

## United Kingdom

Facts:

- Targeted support is a new regulated activity for suggestions to groups of customers with common characteristics, covering pensions and retail investments. FCA examples include suggesting a different sustainable withdrawal rate, or an ISA for someone holding excess cash. It carries its own conduct standards alongside Consumer Duty and needs a permission ("targeted support" specified activity, applied for through Connect). It is distinct from simplified advice (individual). [S: https://www.fca.org.uk/firms/advice-guidance-boundary-review ; page partly retrieved]
- Timeline: CP25/17 (June 2025); PS25/22 near-final rules published 11 December 2025; final rules confirmed 26 February 2026; applications opened 2 March 2026; in force 6 April 2026; rules in COBS 9B. (A query label "PS25/17" was wrong; the policy statement is PS25/22.) The FCA planned consolidated perimeter guidance on advice versus guidance versus targeted support and a consultation on simplifying advice rules; their status in November 2026 is unknown. [S: https://www.pwc.co.uk/industries/financial-services/understanding-regulatory-developments/fca-fires-the-starting-gun-on-targeted-support.html , https://www.burges-salmon.com/articles/102mohl/targeted-support-goes-live-on-6-april-2026-what-you-need-to-know/ , https://www.freshfields.com/en/our-thinking/blogs/risk-and-compliance/fca-finalises-targeted-support-rules-applications-now-open-102mmq0 , https://kpmg.com/xx/en/our-insights/regulatory-insights/targeted-support-final-rules.html ]
- Tax advice is not itself a regulated activity, but is subject to professional body standards (ICAEW, CIOT, AAT, Professional Conduct in Relation to Taxation) and HMRC Standards for Agents. [B]
- FG15/1 and PERG 8 were not retrieved. [B]

Design rules [I]:

1. Present generic information and illustrations: what the law allows, limits, a calculator showing outcomes for the user's own inputs.
2. Do not say "you should pay £X into pension Y", do not pick an ISA product, fund, provider, withdrawal rate or transfer.
3. Do not say "people like you often...". That is targeted support and needs FCA permission.
4. Tax-only illustrations ("this contribution would reduce your tax by £X") are not themselves regulated advice. An assistant picking investments, ISAs as products or pension withdrawals strays into the perimeter.
5. Include a scope statement, no personalisation of product choice, and a route to an adviser (a pension specialist, MoneyHelper, or a qualified accountant).
6. Show the rule source and effective date for every number.

## United States

Facts:

- Publisher's exclusion (Advisers Act §202(a)(11)(D)): excludes publishers of bona fide newspapers, news magazines or business or financial publications of general and regular circulation. Lowe v. SEC (1985): reliance holds even with specific buy, sell or hold recommendations provided the advice is not individualised to a client's portfolio or needs. Criteria: bona fide, general and impersonal, regular. Losing the exclusion brings fiduciary duty, registration and SEC oversight. [S: https://natlawreview.com/article/navigating-publishers-exclusion-under-advisers-act ]
- Circular 230 (§§10.34, 10.37), §7216 consent for tax return information, IRC §§6694 and 7407 preparer penalties, SEC robo-adviser guidance, Marketing Rule, Form ADV, state adviser laws, FTC and state UDAP, federal AI rules: research returned nothing relevant. [B]

Design rules [I]:

1. Output is impersonal in kind: educational, rule-based, identical for any user with the same inputs.
2. No specific securities, allocation or timing of trades. Tax-loss harvesting suggestions on specific securities risk crossing into investment advice. Describe the rule and the user's recorded net gains, not what to sell.
3. Frame as "calculators and education". Circular 230 applies to practitioners, not necessarily the software firm, but the standard disclaimer applies: output is not tax advice and not a written federal tax opinion.
4. Handle return information with care: §7216 consent before any use or disclosure beyond preparing the user's own output. [B]

## Germany

Facts:

- StBerG §5: persons not authorised may not provide commercial Hilfeleistung in Steuersachen. Tax authorities and chambers must report suspected violations to the RDG fine authority, the Chamber for competition-law review, and criminal and professional bodies; §30 AO secrecy does not block reports. [P] https://www.gesetze-im-internet.de/stberg/__5.html
- StBerG §6 exceptions: bookkeeping tasks (chart of accounts, routine postings, routine payroll, the wage-tax filing) if done by a person with a commercial qualification and at least 3 years of 16 hours a week bookkeeping experience; unpaid commercial assistance supervised by qualified persons. The summary did not mention a general "allgemeine Auskünfte" exception; its status is uncertain. [P, summary only] https://www.gesetze-im-internet.de/stberg/__6.html
- BGH 9 September 2021 (I ZR 113/20, Smartlaw): a contract generator is not a prohibited legal service under the RDG because software that asks case details but follows a schematic process is closer to a form handbook than a legal examination of an individual case (§2(1) RDG). It is an RDG case, not binding for StBerG; an IWW article extrapolates it to tax tech. [S: https://www.lto.de/recht/juristen/b/bgh-izr11320-vertragsgenerator-smartlaw-legal-tech-keine-unzulaessige-rechtsdienstleistung-rdg-rechtsberatung , https://der-betrieb.de/meldungen/das-smartlaw-urteil-des-bgh-siegeszug-der-legal-tech-anwendungen/ , https://www.iww.de/kp/kurz-informiert/tax-techlegal-tech-digitalisierung-machts-moeglich-do-it-yourself-statt-zum-steuerberater-n144657 ]
- BGH 27 November 2019 (VIII ZR 285/18, wenigermiete.de): a debt-collection-style legal service is permissible. [S: https://rickert.law/bundesgerichtshof-zur-zulaessigkeit-von-legal-tech-dienstleistungen/ ]
- BGH 28 March 2023 (II ZB 11/22): a "Tax Law Clinic" violated §5 StBerG. OLG Hamburg 29 September 2016 (4 U 81/16) concerns tax help via an automated... (title truncated, may concern software). Neither was read. [S: https://dejure.org/gesetze/StBerG/5.html ]
- Bundessteuerberaterkammer FAQ "KI im steuerberatenden Berufsstand" (27 January 2026): unread. [S: https://sofi-ai.de/news/vorbehaltsaufgaben-ki ]
- No ruling on AI chatbots or tax apps under §5 StBerG was found. §3 and §4 StBerG (who may advise; Lohnsteuerhilfevereine) were only seen in summaries. EU AI Act duties were not researched. [B]

Design rules [I]:

1. Safe zone: allgemeine Information about statutory rules, calculators, standardised workflows (Smartlaw-style logic helps but is not binding for StBerG), links to ELSTER, a Lohnsteuerhilfeverein or a Steuerberater.
2. Avoid "Handlungsempfehlung für Ihren Einzelfall". Do not tell a user what to do in their specific case.
3. GmbH, holding and Gehalt-versus-Ausschüttung comparisons: signpost-only.
4. German copy is written and reviewed in German, not machine-translated from English.

## Nigeria

No authoritative source on regulation of tax or investment advice was found: not the Chartered Institute of Taxation of Nigeria Act, not SEC Nigeria adviser rules, not NDPA data protection. [B] Follow the same generic design, apply the strictest of the three above, and add "consult a registered tax practitioner" (the research suggested an FIRS or NRS registered practitioner; confirm the current authority name, since the repo links nrs.gov.ng).

## Cross-cutting

Data protection for financial data (UK GDPR, EU GDPR, GLBA, NDPA) was not researched. Never auto-file, auto-execute or move real money. Log every recommendation shown with the rule version.
