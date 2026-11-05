# Statutory accounts and Companies House duties

Grades: **[P]** primary, **[S]** secondary, **[I]** inferred. Research date 5 November 2026.

## Size thresholds

For financial years beginning on or after 6 April 2025 (Companies (Accounts and Reports) (Amendment and Transitional Provision) Regulations 2024, SI 2024/1303). A company qualifies by meeting at least two of three. [P]
https://www.gov.uk/annual-accounts/microentities-small-and-dormant-companies and https://www.legislation.gov.uk/uksi/2024/1303/pdfs/uksiem_20241303_en_001.pdf

| Size         | Turnover | Balance sheet total | Employees | Earlier limits                                                                                                                                            |
| ------------ | -------- | ------------------- | --------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Micro-entity | £1m      | £500,000            | 10        | £632,000 / £316,000 (S, ICAEW https://www.icaew.com/insights/viewpoints-on-the-news/2024/dec-2024/uk-company-size-thresholds-to-increase-from-april-2025) |
| Small        | £15m     | £7.5m               | 50        | £10.2m / £5.1m (S)                                                                                                                                        |
| Medium       | £54m     | £27m                |           | £36m / £18m (S)                                                                                                                                           |

Validation rule [I]: `qualifiesMicro = count(turnover <= 1_000_000_00, balanceSheet <= 500_000_00, employees <= 10) >= 2` (pence). Use the old limits for years starting before 6 April 2025. Changing size status normally needs two consecutive years meeting the test (not researched).

## What goes where

- Micro-entity (FRS 105): balance sheet in a specified format with footnotes, P&L in the specified format, auditor's report unless audit exemption claimed, notes (guarantees, advances and credits to directors required). Balance sheet states it was prepared under the micro-entity provisions and delivered under the small companies regime. Comparatives required. [P] https://www.gov.uk/government/publications/life-of-a-company-annual-requirements/life-of-a-company-part-1-accounts and https://ewf.companieshouse.gov.uk/help/en/stdwf/microAccountsHelp.html
- Micro-entities may send only a balance sheet to Companies House. Small companies may send abridged accounts only if all members agree. Both must still send full statutory accounts to members and to HMRC with the CT return. Small companies may choose whether to file a directors' report and P&L at Companies House. [P] https://www.gov.uk/annual-accounts/microentities-small-and-dormant-companies
- Directors' report: the SI 2024/1303 explanatory memorandum says micro-entities are exempt from producing one; GOV.UK describes it as not having to _file_ one. The sources conflict ("produce" versus "file"). Offer both and default conservatively: produce for small, optional for micro. [I]
- Not retrieved: full FRS 105 and FRS 102 Section 1A formats, notes lists and disclosure checklists (FRC pages); audit exemption conditions beyond the 2028 statement change; the accounts deadline (9 months after the accounting reference date, 21 months for first accounts) is user-stated and unverified.

## The 23 October 2026 pause and the 2028 changes

- 23 October 2026 notice: the government has paused requiring small companies and micro-entities to file profit and loss accounts from April 2028, will explore streamlining Companies House and HMRC filing, and companies can keep filing abridged accounts and can still remove (fillet) P&L information from accounts filed after 1 April 2028. [P] https://www.gov.uk/government/news/companies-house-update-to-accounts-filing-from-april-2028
- **Do not model a mandatory P&L filing at Companies House for 2026 or 2028.** Model P&L filing as a user choice. Older material (including a third-party site stating 1 April 2027) is stale. The move from April 2027 to April 2028 was announced on 28 January 2026 (S, search summary of https://www.gov.uk/government/news/companies-house-to-bring-in-changes-to-accounts-filing-from-april-2028).
- From 1 April 2028 all UK companies must file accounts through commercial software as iXBRL; web and paper accounts filing close (web filing remains for confirmation statements and other filings). Other 2028 changes: a stronger audit-exemption eligibility statement on the balance sheet, all component parts of accounts filed together, a limit on shortening the accounting reference period (business reason needed to shorten more than once in five years). Minimum at Companies House for micro-entities: balance sheet, auditor's report unless exempt, notes. [P] same notice and https://changestoukcompanylaw.campaign.gov.uk/changes-to-accounts/
- Companies House late filing penalties for private companies: up to 1 month £150; 1 to 3 months £375; 3 to 6 months £750; over 6 months £1,500; non-filing risks strike-off. [P] https://www.gov.uk/annual-accounts/penalties-for-late-filing. Doubling for repeat lateness: not retrieved.

## Confirmation statement and registers

- Fee £50 online, £110 paper, payable with the first confirmation statement in each 12-month payment period. The review period ends 12 months after incorporation or the previous statement date; file within 14 days after it ends. Late filing can bring a fine up to £5,000 and strike-off. File even if nothing changed. [P] https://www.gov.uk/guidance/filing-your-companys-confirmation-statement. A search summary mentioned older fees on outdated pages; re-check the fee.
- Report before confirming: directors and secretary, PSCs, registered office, registered email (mandatory if not given). Optional in the statement: SIC code, statement of capital, trading status of shares, PSC exemption, shareholder information. The company confirms its intended future activities are lawful. [P] same page.
- PSC register must not be empty. PSC changes are notified within 14 days of being confirmed (offence if not). [P] https://assets.publishing.service.gov.uk/media/691c9c97e39a085bda43ef2b/register-of-people-with-significant-control-guidance-for-registered-unregistered-companies.pdf and https://www.gov.uk/guidance/provide-psc-verification (14-day verification window via search summary, S).
- Not read: PSC thresholds (more than 25% shares or votes, right to appoint a majority of the board, significant influence), registered office and "appropriate address" rules.
- Model `confirmationStatementDate` and `filingDeadline = reviewPeriodEnd + 14 days`; remind 60 days before. [I]

## Identity verification (ECCTA)

- Legal requirement from 18 November 2025 with a 12-month transition. The date is not a deadline. New directors and PSCs must verify to be appointed. Existing directors confirm verification (personal code) when filing their next confirmation statement during the transition; the company cannot file until all directors are verified. Existing PSCs verify within a 14-day window tied to an appointed day within the 12 months. Verification is through GOV.UK One Login or an authorised corporate service provider. Non-compliance is an offence, with financial penalties and filing and company-formation restrictions. Verification for people who file for companies (agents) starts no earlier than November 2027 with at least six months' notice. [P] https://changestoukcompanylaw.campaign.gov.uk/identity-verification/ , https://www.gov.uk/guidance/filing-your-companys-confirmation-statement , https://www.gov.uk/government/news/companies-house-confirms-identity-verification-rollout-from-18-november-2025 , https://www.legislation.gov.uk/uksi/2025/1118/regulation/4/made/data.xht
- The transition ends on or around 18 November 2026 (inferred: 12 months; the page gives no exact day). A 5 November 2026 user is likely to hit this when filing. Build a "verified / personal code held" checklist per director and PSC. Never store or ask for the personal code in the app.

## Dormancy

See `rates-and-computation.md`. A dormant company still files a confirmation statement and accounts; dormant accounts are free if on time. Registered dormant with HMRC means no CT return unless HMRC issues a notice.
