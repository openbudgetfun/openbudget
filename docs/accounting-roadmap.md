# Accounting and tax roadmap

OpenBudget is growing from an envelope budget into the owner's whole financial back
office: personal budgeting, the bookkeeping Xero does today, and the return preparation an
accountant does. This document fixes the scope decisions and the build order. The rules
themselves live in the domain skills under `.claude/skills/`; load the matching skill before
touching any of this work.

## Scope decisions

| Decision      | Choice                                                                                       |
| ------------- | -------------------------------------------------------------------------------------------- |
| Jurisdictions | UK, US (federal), Nigeria and Germany                                                        |
| Entities      | Individuals, sole traders and limited companies in each                                      |
| Xero jobs     | Bookkeeping, invoices and bills, VAT and sales tax returns, payroll                          |
| Filing        | **Prepare only.** The app produces the figures and a box-by-box checklist; the user submits. |
| Migration     | Import Xero CSV and report exports; no Xero API connection                                   |

## What "prepare only" leaves to the user

Some returns cannot be typed into a government portal by hand, so a prepare-only app cannot
complete them alone. The app must say so where it applies:

- **UK VAT**: HMRC closed its online VAT form in 2022. Submission needs MTD-compatible or
  bridging software.
- **UK MTD for Income Tax**: quarterly updates for those mandated from April 2026 need
  MTD-compatible software.
- **UK Corporation Tax and company accounts**: the CT600 needs iXBRL accounts and
  computations, and HMRC's free filing service closed on 31 March 2026. Companies House
  moves to software-only accounts filing from 1 April 2028.
- **UK RTI payroll**: FPS and EPS must be sent by HMRC-recognised payroll software.
- **Germany**: Mein ELSTER entry by hand works for the income tax, EÜR and UStVA checklists;
  GmbH returns are prepared as amounts only.

Direct filing (HMRC MTD APIs, ERiC for ELSTER) is a later, separate decision: it needs
government developer registration, fraud-prevention headers and credential handling.

Every figure is guidance for the user to check. A qualified professional should review the
first year of returns produced for each entity before the app replaces one.

## Build order

Each phase ships as its own stack of pull requests, with unit, widget and Patrol tests.

1. **Correct the existing tax packs.** Fix the audit findings below, with the skills' test
   vectors as regression tests.
2. **Ledger foundation** (`double-entry-ledger`). Business entities get an accounting mode:
   chart-of-accounts templates per country and entity, immutable balanced journals, period
   locks, statement-line bank reconciliation, transaction and functional currency with
   realised and unrealised FX, and ledger-derived trial balance, profit and loss, balance
   sheet and cash flow. Envelope budgets read from the ledger rather than duplicating it.
3. **Contacts, invoices and bills.** Customer and supplier records, sales invoices, bills,
   credit notes, payments and allocations, gap-free numbering, legally complete invoice
   PDFs per country (German e-invoice formats ahead of the 2027 and 2028 mandates), and aged
   receivables and payables.
4. **VAT and sales tax** (`uk-vat-payroll`, `germany-tax`, `nigeria-tax`). Tax codes on
   every document line, VAT control accounts, the UK nine-box return and its schemes, the
   German UStVA by Kennzahl, the Nigerian monthly VAT return, and exports for bridging
   software.
5. **Payroll** (`uk-vat-payroll`). A UK PAYE, NIC and student-loan engine accepted against
   HMRC's published payroll test data, pay runs, payslips, and RTI figures. Other
   countries' payroll follows the same contract later.
6. **Returns.** Box-by-box checklists from the ledger: UK SA100 and supplementary pages,
   the CT600 computation and FRS 105 accounts figures, US 1040 with Schedules C and SE and
   Form 1120-S, German ELSTER forms keyed by Kennzahl, and Nigerian personal and company
   returns.
7. **Xero import** (`xero-migration`). Capture real exports from a Xero demo company as
   fixtures first, then import in the skill's order with trial-balance, aged AR/AP and
   bank tie-outs as hard gates.
8. **Assistant guardrails** (`tax-planning-guardrails`). Per-country perimeter rules,
   wording rules and the never-suggest list in the system prompt and MCP instructions,
   disclaimers on every opportunity, and rule versions recorded on proposals.

## Audit findings in the current tax packs

Found while writing the skills on 5 November 2026. Source quality is in each skill.

### United Kingdom (`openbudget_core/lib/src/tax/gb/`)

- Company tax runs on the 6 April tax year instead of the company's accounting period and
  the 1 April financial year.
- Capital allowances are AIA only: no £1m cap, pools, writing-down allowances, full
  expensing, first-year allowances or balancing charges.
- No associated companies, short-period or straddle handling, director's loan account or
  s455 charge (35.75% for loans from 6 April 2026), or dividend-legality check.
- The personal allowance taper uses total income instead of adjusted net income.
- Student loan repayments are not rounded down to whole pounds, and the base ignores the
  £2,000 unearned-income rule. A person cannot hold an undergraduate plan and a
  postgraduate loan together.
- Payments on account are half the balance instead of the statutory rule (50% of last
  year's income tax and Class 4, with the £1,000 and 80% exemptions).
- SA103F box references are wrong where the trading allowance applies (boxes 73 and 76).
- Business-use apportionment is applied to sales VAT as well as input VAT.
- The director salary comparison skips the lower earnings limit and Employment Allowance,
  and some thresholds are inline numbers instead of rule data.
- The FY2027 assumption text is stale: the rates are already held at 19% and 25%.

### United States (`openbudget_core/lib/src/tax/us/`)

- Tax is computed by bracket formula; the IRS Tax Table applies below $100,000 taxable
  income.
- NIIT MAGI adds back tax-exempt interest; it should add back only the foreign earned
  income exclusion.
- QBI drops to zero above the threshold instead of phasing in the wage and property limits.
- The $1,500 home-office cap is applied to the regular method as well as the simplified one.
- Missing: qualifying surviving spouse, the Schedule 1-A deductions, the SALT cap, CTC and
  EITC, AMT, additional Medicare tax on wages, negative AGI, S corporations and payroll.

### Nigeria (`openbudget_core/lib/src/tax/ng/`)

- Only 2026 is supported; 2025 income still uses the old PITA and CITA regime.
- The minimum effective tax rate threshold is ₦50bn; section 57 says ₦20bn or a
  multinational group member.
- The small-company turnover ceiling is fixed at ₦50m. The gazetted Acts conflict
  (₦50m in the NTA, ₦100m in the NTAA), so it must be a configurable rule with a warning.
- Medical services are described as exempt; they are zero-rated. Land and buildings are
  exempt.
- Excess input VAT can be refunded on request, not only carried forward.
- Statute section citations for the small-company definitions are unverified.

### Germany (`openbudget_core/lib/src/tax/de/`)

- Filing deadlines ignore the §108 AO weekend roll-forward (for example 28 February 2027
  falls on a Sunday).
- Kirchensteuer is a fixed 9%; Bavaria and Baden-Württemberg levy 8%, so it is a profile
  input.
- The Arbeitnehmer-Pauschbetrag and the Basisrente cap are not applied per spouse on joint
  assessment, and the Basisrente headroom ignores statutory pension contributions.
- Children are not modelled, so Soli and Kirchensteuer overstate for parents.
- Every sole trader is treated as a Gewerbebetrieb; Freiberufler owe no Gewerbesteuer and
  file Anlage S.
- The Kleinunternehmer test checks the current year only; it needs the prior-year and
  current-year limits.
- Company lines cite KSt 1 instead of Anlage GK and ZVE, and no category carries its
  ELSTER Kennzahl.

### Assistant (`openbudget_server/lib/src/agent/`)

- The system prompt has no per-country perimeter rules, wording rules or never-suggest
  list, and "building wealth" sits on the investment-advice line.
- The MCP path bypasses the system prompt and returns opportunities without disclaimers.
- Opportunity titles are imperatives ("Use your pension annual allowance", "Harvest
  capital losses") and are hard-coded rather than localised.
- Proposals do not record the rule version they were made under.
