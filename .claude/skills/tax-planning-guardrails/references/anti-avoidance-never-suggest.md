# Anti-avoidance and the never-suggest list

Grades: **[P]** primary, **[S]** secondary, **[I]** design inference, **[B]** background not fetched. Almost nothing here was read in a primary source; treat the statutes as pointers for counsel, not as text to quote.

## Anti-abuse rules by country

| Country | Rules                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | Grade                                                                                                                                                                                                     |
| ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| UK      | General Anti-Abuse Rule (Finance Act 2013 Part 5, double reasonableness test, GAAR Advisory Panel); DOTAS (FA 2004 Part 7, hallmarks) and POTAS; IR35 and off-payroll rules (ITEPA Part 2 Chapter 10; small-company exemption); settlements legislation (ITTOIA 2005 Part 5 Chapter 5, ss.624 to 628; Jones v Garnett [2007] UKHL 35, the Arctic Systems case, holding not researched); failure to prevent facilitation of tax evasion (Criminal Finances Act 2017)                              | B                                                                                                                                                                                                         |
| US      | Economic substance (IRC §7701(o)); S-corporation reasonable compensation case law; wash sale rules; backdoor and DAF round-tripping scrutiny                                                                                                                                                                                                                                                                                                                                                     | B                                                                                                                                                                                                         |
| Germany | §42 AO (Gestaltungsmissbrauch; text not fetched); verdeckte Gewinnausschüttung for below- or above-market owner pay in a GmbH; §370 AO Steuerhinterziehung                                                                                                                                                                                                                                                                                                                                       | B                                                                                                                                                                                                         |
| Nigeria | NTAA 2025 s.46 (artificial transactions: the authority may disregard or adjust dispositions it considers artificial or fictitious; connected-party transactions off arm's length are deemed artificial) and s.47 (prohibited tax avoidance arrangement: any arrangement whose main purpose is a tax benefit or whose advantage is contrary to the object and purpose of the law); NTA 2025 s.191 or s.193 (the gazette numbering differs) headed "Artificial transactions" for connected persons | S, sections not read. https://tat.gov.ng/NIGERIA-TAX-ADMINISTRATION-ACT-2025.pdf , https://africacheck.org/sites/default/files/media/documents/2025-07/FINAL-COPY-NIGERIA-TAX-ADMINISTRATION-ACT-2025.pdf |

Germany §5 StBerG is a regulatory rule, covered in `regulatory-boundary.md`. https://www.gesetze-im-internet.de/stberg/__5.html (P)

## Never-suggest list

Design inference from the sources and standard anti-avoidance principles. Each item is a "main purpose is a tax advantage" or "lacks substance" pattern. The assistant must not propose, design, quantify as a plan, or encourage any of these. If the user raises one, say the app does not help design it and signpost a qualified adviser.

1. Any scheme promoted as an "HMRC-approved loophole", marketed contrived avoidance, loan-charge style remuneration trusts, anything notifiable under DOTAS or counteractable by the GAAR.
2. Income splitting to a spouse or family member through shares or a role without genuine work or capital (settlements risk).
3. Disguised employment through a personal service company; artificial intermediary structures (IR35 and off-payroll).
4. Paying a controlling owner a below-market salary in an S-corporation or GmbH (reasonable compensation; verdeckte Gewinnausschüttung).
5. Wash sales; round-tripping charitable gifts or donor-advised-fund arrangements that give back control; transactions without economic substance.
6. Concealment: undeclared foreign accounts, nominee structures, suppression of income, false residence claims (UK SRT, US citizenship), falsified rent receipts or home-office days (Nigeria, Germany).
7. Moving money, assets or residence for the primary purpose of a tax result without genuine change in the user's life.
8. Charging personal costs to a company, or recording private spending as business use, to reduce profit. (Applies to every pack's business-use percentage.)
9. Borrowing from a company repeatedly to avoid dividend tax, or repaying and redrawing a director's loan to dodge s455 (bed and breakfasting; see `uk-company-tax`).
10. Backdating documents, dividend minutes or vouchers.

## What is allowed

- Statutory reliefs applied to real expenses or contributions the user actually makes or genuinely plans to make.
- Timing shifts in genuine transactions (for example making a pension contribution before a tax year end, or realising a gain in a year with unused exempt amount).
- Choices the law itself offers (for example the trading allowance versus expenses, standard versus itemised deduction), with the arithmetic shown.

## Product rules that follow

- Surface only the allowed set; the code path for an opportunity must be a statutory relief with a source link.
- Documentation prompts for every evidence-based relief.
- Route owner-managed company structure, holdings, residence, trusts and anything in the never-suggest list's neighbourhood to a professional.
- Log which opportunity ids were shown to the user, with the rule version, so a later review can see exactly what was said.
