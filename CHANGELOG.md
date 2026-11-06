# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0](https://github.com/openbudgetfun/openbudget/releases/tag/v1.0.0) (2026-11-06)

Grouped release for `openbudget`.

### Store release required

#### Ship the first OpenBudget release

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #220](https://github.com/openbudgetfun/openbudget/pull/220)

The first release of the OpenBudget workspace: a Flutter app on Serverpod 4.1 with Riverpod, Hooks, Freezed and GoRouter, released together as the `openbudget` group. It is a `native` release because it adds RevenueCat, `url_launcher`, `package_info_plus` and the Solana Kit wallet packages, so it ships through the stores rather than as a Shorebird patch.

##### Platform

- Flutter 3.47.7, Dart 3.13 and Serverpod 4.1.0, with the protocol and providers regenerated and the module schema migration applied.
- `monochange` replaces knope for changeset-only releases, with a developer stream (`CHANGELOG.md`, GitHub release body) and a user stream (`WHATS_NEW.md` and `openbudget_app/assets/release_notes/<version>.json`).
- The infrastructure-as-code and spec-driven tooling are gone; CI checks analyze, tests, formatting, Patrol flows, the widget ban, pinned dependencies, secrets and the generated icon catalog.
- `avoid_stateful_widgets` in `openbudget_lints` now rejects `StatelessWidget` as well as the stateful widget types, so every widget is a `HookWidget` or `HookConsumerWidget`.

##### Budgeting

- Endpoints and models for budgets, categories, envelopes, monthly allocations, goals, transactions (splits, transfers, reconciliation, bulk edits, duplicate detection, CSV import), recurring transactions with auto-posting, payees, transaction rules, reports, FX rates with backend snapshots, institutions with multi-region catalog seeding, Plaid connections, and Solana wallet interpretation and valuation.
- Real-time budget stream updates, email authentication through `serverpod_auth_idp`, and auth-aware routing.
- Every budgeting currency the server writes is validated against `CurrencyCode` (`ValidationException` for unsupported codes, normalized codes stored). The app formats unknown codes as the raw code plus a plain amount and keys aggregations by code, so nothing is silently shown as USD. Wallet asset symbols and Plaid currencies are left untouched.

##### Design

- `openbudget_ui` is rebuilt on the Skribble hand-drawn design system: palette roles resolve through the Skribble theme, a generated `OpenBudgetIcons` catalog of `SkribbleIcon` artwork, and `Ob*` cards, panels and buttons. Every screen is restyled with readable text and every existing action kept.

##### Tax

- `openbudget_core` gains a tax engine contract and rule packs for the United Kingdom (including Scottish rates and student loans), the United States federal system, Nigeria and Germany, for individuals, sole traders and limited companies.
- The server stores tax profiles and categorisation, converts amounts between currency minor units, and builds country reports with bands, return references, opportunities and rule-source metadata.
- The app adds the tax overview, profile form and category sheet, with provider, widget and Patrol coverage.

##### OpenBudget Plus

- `entitlement` table, `EntitlementService` and `BillingEndpoint.getEntitlement`. Each rail records its own subscription row; access holds through `currentPeriodEnd` and the period ending last wins. `BillingPlan` fixes $10 a month with $1 of built-in agent usage.
- Stripe Checkout and billing portal sessions with signed webhooks, RevenueCat App Store and Play Store webhooks, and the Solana Subscriptions Delegation Program rail with a wallet ownership challenge, on-chain verification and an hourly collector that charges 10 USDC per 30-day period. Confirming a Solana subscription never charges twice, and a failed first payment grants nothing.
- The app's `/plus` screen offers RevenueCat on mobile, Stripe on web and desktop, and Solana USDC on web.

##### Agent

- `AgentEndpoint` runs a tool-calling assistant on OpenCode Zen (`deepseek-v4.1-flash`) or the user's own OpenAI-compatible provider, metered at published prices against the included allowance. Bring-your-own keys are stored with AES-256-GCM, and provider URLs that resolve to internal addresses are refused.
- The assistant never writes data: propose tools record pending `AgentProposal`s that the user applies or dismisses, claimed atomically so a proposal applies once.
- A Streamable HTTP MCP server at `POST /mcp` exposes the same tools to external agents through revocable personal access tokens (`AgentTokenEndpoint`), stored as SHA-256 hashes and rate limited per token. The app adds an Agent access screen to create, copy once and revoke them.
- The app adds the assistant chat, proposals and provider screens.

##### Errors and release notes

- Every server exception is a Serverpod serializable exception declared in `openbudget_server/lib/src/exceptions/*.spy.yaml`, so clients match on types such as `ValidationException(message:)` and `EntitlementRequiredException` instead of a generic 500.
- The app reads the bundled release notes, shows them once after an update, and keeps them available from Settings.

### Features

#### Parse typed money amounts in integer minor units

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #252](https://github.com/openbudgetfun/openbudget/pull/252)

Typed amounts were converted with `double.tryParse` and `(value * factor).round()`, so every entry round-tripped through binary floating point before it reached the ledger.

- A new `parseMoneyInput` / `moneyInputError` pair in `openbudget_app/lib/src/utils/money_input.dart` wraps core's integer-only `parseMinorUnits`, with an explicit `allowNegative` flag that accepts a single leading `-`.
- All typed-amount sites in the app now use it: expense and income, split expense, edit transaction, transfers, recurring create/edit, add/edit account, the reconcile and loan-target dialogs, and CSV import. Invalid or over-precise text shows the field's validation error (`amountInvalidFormat`) instead of silently becoming 0 or a rounded figure.
- Reverse conversions that put minor units back into an editable field use `formatMinorUnits`, replacing the `/ factor` + `toStringAsFixed` copies of `_pow10` in the transaction dialog, account dialog, recurring dialog, loan-target dialog, budget amount keypad hint and goal dialog.
- CSV import still skips rows whose amount cannot be represented exactly, and still accepts negative bank amounts. Fields that only ever accepted positive amounts (expense, income, transfer, split, recurring, edit account, loan target) continue to refuse negatives; account balances, the reconcile statement balance and imported rows still accept them.
- `ObTextField` gained an optional `errorText` so amount fields can surface the new validation message.

#### Double-entry books in the app

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #250](https://github.com/openbudgetfun/openbudget/pull/250)

Business budgets can now keep double-entry books. The More screen shows a Books entry for sole-trader and company budgets: envelope budgets get a one-way "enable books" confirmation that seeds the chart of accounts, and ledger budgets open the Books screen. Books has three tabs — journals (newest first with draft/posted/reversed status chips), the chart of accounts grouped by account type with archived marks, and a trial balance with an as-of date picker, per-account debit/credit totals and a balanced indicator. The journal editor validates live against the shared core rules while typing (debit total, credit total, difference), saves drafts, posts behind a "posted journals are permanent" confirmation and deletes drafts; posted journals open read-only with a reversal action that asks for a reversal date. A lock-date setting on the Books screen calls `setLockDate` to freeze closed periods. Amounts travel as integer minor units and render with the app's currency formatting.

Draft journals now reopen with their stored lines: the editor loads them through the new `listJournalLines` read, prefills account, side and amount per line and re-saves the same draft via `journalId` instead of creating a second one, with loading and retry states while they load. The journal detail screen lists every journal's lines — posted, reversed and drafts opened read-only — with account, debit/credit per line and totals, so drafts no longer show the "lines can't be shown here yet" note. The Books screen reads the persisted lock date back through the new `getLockDate` read (or "No lock date set") instead of keeping it only for the current session, and saving a lock date refreshes it.

#### Double-entry ledger foundation: core model, posting service and trial balance

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #248](https://github.com/openbudgetfun/openbudget/pull/248)

`openbudget_core` gains a pure-Dart ledger module: the five account types with their normal balances, the stable system-role set (bank, AR/AP, VAT control, payroll liabilities, directors' loan, retained earnings, opening-balance equity, suspense, rounding, realised/unrealised FX, owner drawings), draft-journal validation (at least two one-sided positive lines, exact-decimal FX conversion with the per-currency exponent, balance in the functional currency and per transaction currency for single-foreign-currency journals), trial-balance computation with a hard error on imbalance, and starter charts of accounts for GB/US/NG/DE companies and sole traders (SKR04-style German numbers marked unverified).

`openbudget_server` adds the `ledger_account`, `journal`, `journal_line`, `ledger_period_lock` and `ledger_audit_event` tables, an `accountingMode` field on `Budget`, and a `LedgerEndpoint` with ownership checks on every call: `enableLedger` (validates the budget's tax-profile entity kind is soleTrader or company and seeds the chart from the jurisdiction template), account listing/creation/archival, draft save/edit/delete, posting, reversal (posted journals are immutable — corrections are reversal journals), journal listing with date filters, `setLockDate` (posting or reversing on or before the lock is rejected) and `trialBalance(asOf)`. Every post, reversal, lock change and mode switch writes an audit event row. One Serverpod migration ships with this change; generated client protocol is committed.

#### Ledger reads and integer-only amount parsing

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #250](https://github.com/openbudgetfun/openbudget/pull/250)

`openbudget_server` adds two ledger reads, `listJournalLines(journalId)` and `getLockDate(budgetId)`. Both check ownership and require a ledger budget, and need no migration. `openbudget_core` adds `parseMinorUnits` and `formatMinorUnits`, which parse and render plain amounts with integers only and refuse input with more decimals than the currency has. The tax screens' `double`-based helpers are replaced by them, so a tax form now rejects `12.345` for a two-decimal currency instead of rounding it. `LedgerValidationIssue` gains `lineIndex`, the zero-based line an issue refers to.

### Fixes

#### Fix the German tax rule pack

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #246](https://github.com/openbudgetfun/openbudget/pull/246)

- Filing deadlines roll forward to the next working day under § 108 Abs. 3 AO (VZ 2025 advised: 1 Mar 2027; VZ 2026 self-filers: 2 Aug 2027) and the Art. 97 § 36 Abs. 3 EGAO transition deadlines are honoured.
- Kirchensteuer takes the Bundesland from the tax profile (8 % in Bayern and Baden-Württemberg, 9 % elsewhere); profiles saved with only the old flag keep the 9 % assumption.
- Joint assessment gives each employed spouse their own Arbeitnehmer-Pauschbetrag and their own Anlage N, doubles the Basisrente Höchstbetrag, and subtracts statutory pension contributions from the Basisrente headroom.
- Children add Kinderfreibeträge with the Kindergeld Günstigerprüfung, and Solidaritätszuschlag and Kirchensteuer are computed on the tax recalculated with Kinderfreibeträge (§ 3 Abs. 2 SolzG, § 51a Abs. 1 EStG).
- Sole traders declare Freiberufler (Anlage S, no Gewerbesteuer, no § 35 credit) or Gewerbetreibender (Anlage G, Gewerbesteuer with the § 35 credit) in the profile.
- The Kleinunternehmer test now checks prior-year turnover of at most €25,000 and current-year turnover of at most €100,000 (§ 19 UStG from 2025), instead of the current year against €25,000.
- Homeoffice claims are capped at €6 per day and €1,260 per year in whole days, a separate Arbeitszimmer category exists, and the two claims exclude each other because they may not overlap in time.
- Company report lines reference Anlage GK and Anlage ZVE instead of KSt 1, the Homeoffice line cites Anlage N Z58/Z59 (Kz 335/336) versus Arbeitszimmer Z57 (Kz 325), and German categories carry their ELSTER Kennzahlen keyed by (form, year, section, Kz).
- The Entfernungspauschale is an Anlage N profile input computed from the year's schedule (2025 tiered 0.30 to km 20 then 0.38, 2026 flat 0.38 from km 1, capped at €4,500).

All tax arithmetic stays in integer cents; every new figure is versioned per year with a source comment.

#### Fix the UK tax rule pack

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #245](https://github.com/openbudgetfun/openbudget/pull/245)

Corrects the defects found while auditing the GB pack against the domain skills, with each fix backed by the skills' test vectors.

##### Personal tax

- The personal allowance taper now uses adjusted net income: gross relief-at-source pension contributions and gross Gift Aid donations recorded on the books reduce the taper base instead of only total income.
- Student loan repayments round down to whole pounds (SA110 boxes 3 and 3.1), the repayment base follows the SA110 working sheet (savings and dividends count only above £2,000, gross pension contributions reduce it), and a profile can now hold an undergraduate plan and a postgraduate loan at the same time. Profiles that stored the postgraduate loan in `studentLoanPlan` still parse.
- Payments on account are now the statutory rule: two instalments of 50% of the year's Income Tax plus Class 4, net of tax collected at source, excluding Capital Gains Tax, student loans and the High Income Child Benefit Charge, skipped under £1,000 or when more than 80% was collected at source. The thresholds and instalment share are rule data, and the instalments fall due with the return (31 January and 31 July two years after the year starts), not on half the balance.
- SA103F references where the trading allowance applies: the allowance deducts at box 73 and the taxable profit is box 76, the figure that flows to the SA100 (was box 16.1 and box 64).

##### VAT

- Business-use apportionment applies to input tax only. Output VAT is owed on the whole sale, so sales entries with a private-use percentage no longer reduce the VAT charged.

##### Company tax

- Corporation Tax runs on the company's accounting period, not the 6 April tax year. `GbTaxProfile` gains an accounting-period end date (default 31 March), and profits are apportioned by day across the 1 April financial years the period straddles, each part charged with its own year's rates. The FY2027 hold at 19%/25% is stated instead of the stale assumption text.
- The profile also carries an associated-companies count, and each one divides the £50,000/£250,000 limits; short periods pro-rate the limits by days (CTM03930/CTM03935).
- Capital allowances: the Annual Investment Allowance is capped at £1,000,000 and pro-rated by whole months for a short period, cars never reach it, and the pure module now also models company full expensing (100% of new main-rate plant) and the 50% special-rate first-year allowance. Pools and writing-down allowances are still not modelled: spend above the cap or in cars is shown as unrelieved.
- The director salary comparison compares the year's Class 1 thresholds from rule data including the lower earnings limit, credits the Employment Allowance when the books show wages above the secondary threshold beyond the director's pay (s2(4A): a sole director who is the only employee above the threshold cannot claim it), and is labelled guidance, never "optimal".

##### Rule data

New per-year figures with sources: Class 1 lower earnings limit (6,500 / 6,708), Employment Allowance (10,500), payments-on-account minimum (1,000), collected-at-source share (80) and instalment share (50), student-loan unearned-income threshold (2,000), pension relief-at-source basic rate (20%), AIA cap (£1,000,000), full-expensing (100%) and special-rate FYA (50%) rates. All arithmetic stays in integer minor units.

##### App

- The GB tax profile form asks the new questions: postgraduate loan, and for companies the accounting period end and associated companies. New localised strings and widget tests.

##### Not covered here

- The server's profile sanitizer (`openbudget_server/lib/src/tax/tax_service.dart`) still whitelists the old GB profile keys, so `postgraduateLoan`, `accountingPeriodEnd*` and `associatedCompanies` are dropped at the endpoint until the server is updated; a local report computes with the defaults.
- Pools, writing-down allowances, balancing charges, exempt distributions and the s455 charge remain unmodelled (stated in report assumptions).

#### Correct the Nigeria tax rule pack and add the 2025 old-regime year

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #244](https://github.com/openbudgetfun/openbudget/pull/244)

- Add the 2025 year of assessment under the repealed PITA and CITA regime: the PITA progressive bands (7% to 24%) after the consolidated relief allowance, the 1% minimum tax where it exceeds the progressive tax, CITA turnover tiers of 0%, 20% and 30% with the 3% tertiary education tax, and the old N25,000,000 VAT registration threshold. The regime follows the year of assessment, and every 2025 figure is marked secondary-sourced in the report assumptions because the repealed Act texts were not read.
- Apply the 15% minimum effective tax rate trigger correctly (NTA s.57): aggregate turnover of N20bn or more, or membership of a multinational group, not the previous N50bn / EUR 750m wording.
- Make the small-company turnover ceiling a profile choice between the conflicting statutory figures (N50m in the Nigeria Tax Act gazette, N100m in the Administration Act) and always explain the conflict in the company report whenever turnover falls between the two.
- Correct the VAT category descriptions: medical services are zero-rated (s.187), land and buildings are exempt (s.186); excess input VAT is carried forward as a credit or refundable on request (s.156(1)-(2)).
- Treat foreign dividend, interest, rent and royalty brought in through approved channels as exempt (s.163(1)(s)) with dedicated out-of-scope categories.
- Remove an unverifiable claim that a Presidential Order can cut the 30% companies income tax rate; the gazette shows only 0% and 30%.
- Align statute citations with the gazette research and mark unverified section numbers as unverified instead of citing them.
- `NgTaxProfile` gains `smallCompanyCeiling` and `mneGroupMember` (JSON round-tripped with defaults for stored profiles); the tax profile form asks both questions with new localised strings.

#### Fix the US federal tax rule pack

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #247](https://github.com/openbudgetfun/openbudget/pull/247)

The US rule pack in `openbudget_core` now reproduces the filed figures:

- Taxable income below $100,000 is taxed with the IRS Tax Table (the
  bracket formula on the midpoint of the row containing the taxable
  income, rounded to whole dollars); $100,000 and above keep the Tax
  Computation Worksheet formula. The Qualified Dividends and Capital Gain
  Tax Worksheet comparison uses the same $100,000 rule.
- Net investment income MAGI adds back only the foreign earned income
  exclusion (new profile field); tax-exempt interest is no longer added.
- The qualified business income deduction no longer drops to zero above
  the threshold: the section 199A phase-in range, the W-2 wage / UBIA
  limitation, and the specified-service phase-out are applied (Form
  8995-A mechanics, combined businesses). The 2026 $400 minimum deduction
  stays.
- The $1,500 home office cap applies to the simplified Schedule C method
  only; the profile selects the method, and the regular Form 8829 method
  is uncapped.
- `UsFilingStatus` gains `qualifyingSurvivingSpouse`, which uses the MFJ
  brackets, standard deduction, and thresholds; stored profile JSON still
  parses.
- Additional Medicare tax now covers wages plus self-employment income
  together (Form 8959) and is reported separately from Schedule SE.
  Adjusted gross income may be negative; taxable income still floors at
  zero.
- Itemizers get the SALT cap ($40,000 for 2025, $40,400 for 2026) with
  the 30% phase-down to the $10,000 floor, and the Schedule 1-A
  deductions (tips, overtime, passenger-vehicle loan interest, senior)
  with their caps, phase-outs, SSN flags, and the married-filing-
  separately exclusions.
- The child tax credit and credit for other dependents are computed from
  the new dependents profile fields, with the $50-per-$1,000 phase-out
  (flagged as unverified) and nonrefundable application.
- New US categories: state and local taxes (Schedule A line 5d), the
  three Schedule 1-A amounts, and the unadjusted basis of qualified
  property for the QBI wage limitation.
- `openbudget_app` adds the matching questions to the US tax profile
  form (filing status option, dependents, age and SSN switches, foreign
  earned income exclusion, home office method, specified service flag)
  with localized strings and widget tests.
- `openbudget_server` whitelists the new US profile fields (and the
  surviving-spouse filing status) so they persist through saveProfile.
- Every new figure is versioned per tax year in `UsTaxYearTable` with a
  source note; `usRulesVerifiedOn` is 5 November 2026.

#### Build the server image from the workspace and apply migrations on start

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #242](https://github.com/openbudgetfun/openbudget/pull/242)

The server `Dockerfile` now narrows the root workspace to `openbudget_core`, `openbudget_lints` and `openbudget_server` before `dart pub get`, so the Dart-only build image no longer fails on the Flutter workspace members, and the committed `pubspec.lock` still pins every package. `.dockerignore` keeps `openbudget_lints` (a path dev dependency) and drops local `.dart_tool/` and `build/` output. The entrypoint passes `--apply-migrations`, so a new image never serves requests against an older schema.

- **Tax profiles keep every field the core profile defines.** The server filtered profile JSON through its own per-country key list before handing it to `TaxProfile.fromJson`, on save and on every read. Fields added to the core profiles since (UK accounting period end, associated companies and postgraduate loan; Nigeria's small-company ceiling and multinational-group flag; Germany's church-tax Land, Einkunftsart, children, pension, prior-year turnover and commute) were silently dropped. The list is gone: `TaxProfile.fromJson` is now the single definition of a profile's fields and parses strictly, throwing a `FormatException` that names the field for a wrong type, an unknown enum value, a negative count or an impossible year-end date. The server turns that into a `ValidationException`, and `toJson` still drops unknown keys.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #249](https://github.com/openbudgetfun/openbudget/pull/249)
