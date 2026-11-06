# What's new in OpenBudget

The changes you will notice in the app, newest first. Developer notes live in
[CHANGELOG.md](CHANGELOG.md).

## [1.0.0](https://github.com/openbudgetfun/openbudget/releases/tag/v1.0.0) (2026-11-06)

Grouped release for `openbudget`.

### New

#### Welcome to OpenBudget

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #220](https://github.com/openbudgetfun/openbudget/pull/220)

Give every unit of money a job, see where it went, keep every account in one place, and know what you owe in tax, with an assistant that works through it with you.

- **Plan month by month.** Assign money to envelopes, jump between months, copy last month's plan, start from a template, or let quick budget and auto-assign fill envelopes for you. Search, reorder, and add notes to envelopes.
- **Know what needs attention.** Envelopes show spending progress, carryover, and clear overspent and underfunded labels. Set goals, move money in a couple of taps, and track the age of your money.
- **All your accounts.** Add, edit, transfer between, reconcile, and close accounts, pay off credit cards, link accounts from banks in your region, and see Solana wallet balances alongside your budget.
- **Transactions that stay tidy.** Split, edit, delete and undo, search, filter, sort, bulk edit, catch duplicates, import from CSV, and export your data.
- **Recurring bills on autopilot.** See them on a calendar, skip one, and have due transactions posted for you.
- **Every currency, honestly.** Choose a display currency with up-to-date exchange rates. Amounts in a currency the app does not support show their own code instead of pretending to be dollars.
- **Know what you owe.** Set up a tax profile for the UK, the US, Nigeria or Germany, as an individual, sole trader or company, and tag envelopes and transactions with tax categories. Your report shows the balance due or refund, the bands behind each tax, and the legal savings your own figures point to, with the sources and assumptions behind every number.
- **Talk to your budget.** Ask the assistant how much tax you may owe, where you could cut spending, or whether you are on track. It shows what it looked at, and every change it suggests waits for you to apply or dismiss it. Guidance only, not financial or tax advice.
- **Bring your own agent.** Connect your own OpenAI-compatible provider, or create an access token in Settings so Claude Code, Codex or any MCP client can work with your finances.
- **OpenBudget Plus.** $10 a month for tax reports and the built-in assistant with $1 of usage included every month. Subscribe from the App Store or Google Play, by card in a browser, or with USDC from a Solana wallet.
- **A hand-drawn look.** Every screen has a fresh sketched style in light and dark, and after each update a short note shows what changed. You can open it again from Settings.

#### Keep the books for your business

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #250](https://github.com/openbudgetfun/openbudget/pull/250)

Budgets set up as a sole trader or limited company can now turn on double-entry books. Open More, tap "Enable double-entry books" — OpenBudget sets up your chart of accounts once (this can't be undone) — and your Books are ready. Record money in and money out as journals that always balance, see everything you owe and own grouped in your chart of accounts, and check the trial balance for any date you like; OpenBudget tells you at a glance whether your books balance. Posted entries are locked for your records, so mistakes are corrected with a reversal instead of an edit, and you can set a lock date to freeze the periods you've already closed.

Journals now show their lines, so you can see exactly what went in and out of each account. Drafts can be reopened and finished later: OpenBudget fills the entry back in and saves over the same draft instead of making a second one. Your books' lock date is remembered, and the Books screen shows it at a glance.

### Fixed

- **German tax reports now show the right numbers.** Your German tax reports got a set of corrections: filing deadlines no longer land on weekends, church tax follows your federal state (8% in Bavaria and Baden-Württemberg, 9% everywhere else), couples each get their own worker's allowance, children are credited with whichever is better for you — child benefit or the child allowance — freelancers are no longer charged trade tax, and the commuter and home-office allowances follow the 2025 and 2026 rules. The tax profile asks a few new questions, like your federal state, your children and your commute, so the numbers fit your situation.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #246](https://github.com/openbudgetfun/openbudget/pull/246)
- **UK tax figures are more accurate.** Your UK tax estimates now follow HMRC's rules more closely. Your personal allowance no longer shrinks when pension contributions or Gift Aid bring your income down, student loan repayments match the amounts HMRC collects (and you can tell us about a postgraduate loan on top of your plan), and the 31 January bill shows the real two instalments towards next year instead of a guess. Limited companies pick their actual year end and say how many companies they're connected to, so Corporation Tax lands on the right rates, and big equipment purchases stop above the annual investment allowance until the spending can be claimed. Company owners comparing salary with dividends now see the year's real thresholds, including whether the Employment Allowance applies. The UK tax profile screen asks the new questions under Company and Student loan settings.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #245](https://github.com/openbudgetfun/openbudget/pull/245)
- **Amounts you type are saved exactly.** When you type an amount like 12.34, it is now saved as exactly 12.34 instead of passing through a floating-point conversion. If you type more decimal places than the currency uses, the field tells you and asks for a correct amount rather than quietly rounding it. The same applies to accounts, transfers, recurring transactions, split expenses, reconciliation and imported transactions.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #252](https://github.com/openbudgetfun/openbudget/pull/252)

#### Nigeria tax figures corrected, and 2025 returns added

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #244](https://github.com/openbudgetfun/openbudget/pull/244)

- Nigerian tax profiles can now prepare 2025 returns under the rules that applied that year, alongside the 2026 rules.
- The small-company turnover limit now lets you choose between the two conflicting official figures (N50,000,000 as gazetted and N100,000,000 as intended), and the report clearly warns you whenever your turnover falls between the two.
- Medical services are no longer wrongly described as VAT-exempt — they are zero-rated, so their input VAT stays recoverable. Land and buildings are exempt.
- Extra VAT you have paid can now be shown as refundable on request, not only carried forward.
- Foreign dividends, interest, rent and royalties you bring home through approved channels are treated as exempt from Nigerian income tax.
- Companies in a multinational group are now asked, so the report can flag the 15% minimum effective tax rate that applies to them.

- **Tax profile answers are saved in full.** Some tax profile answers were lost when you saved: a UK company's year end and associated companies, a postgraduate loan, a Nigerian company's turnover-limit choice and multinational-group answer, and the new German questions (church-tax state, type of self-employment, children, pension, last year's turnover and commute). They are now kept, so your tax estimates use them. A profile with an impossible value, such as a 31 September year end, is now refused with a message instead of being stored.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #249](https://github.com/openbudgetfun/openbudget/pull/249)

#### US tax reports now match your filed return

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #247](https://github.com/openbudgetfun/openbudget/pull/247)

Your US federal tax report has been corrected to match what the IRS
actually computes:

- For taxable income under $100,000, the report now uses the same IRS tax
  table the paper return uses, so the numbers line up with what you file.
- Investment income tax and the state-and-local-tax deduction now use the
  right income measure, so they stop triggering when they shouldn't.
- The business income deduction now phases down gradually at higher
  incomes instead of disappearing, and pays attention to your business's
  payroll and equipment.
- State and local taxes are correctly capped, and the new 2025 deductions
  for tips, overtime, car loan interest, and seniors are included.
- The child tax credit is applied when you add your dependents, and
  qualifying surviving spouse is now a filing status choice.
- The US tax profile asks a few more questions (dependents, age, Social
  Security numbers, home office method), so the report can use them.
