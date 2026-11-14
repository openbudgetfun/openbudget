# What's new in OpenBudget

The changes you will notice in the app, newest first. Developer notes live in
[CHANGELOG.md](CHANGELOG.md).

## [1.0.0](https://github.com/openbudgetfun/openbudget/releases/tag/v1.0.0) (2026-11-14)

Grouped release for `openbudget`.

### New

- **Set up your books in any country.** Choose from more than 240 countries when you create your books, and search by name, code or what people call it ("UK", "Ivory Coast"). Your currency, time zone and tax year fill in for you, and you can still pick any currency in the world.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #288](https://github.com/openbudgetfun/openbudget/pull/288)

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
- **OpenBudget Plus.** $20 a month for tax reports and the built-in assistant with $5 of usage included every month. Subscribe from the App Store or Google Play, by card in a browser, or with USDC from a Solana wallet.
- **A hand-drawn look.** Every screen has a fresh sketched style in light and dark, and after each update a short note shows what changed. You can open it again from Settings.

- **Sign in with Google and Sign in with Apple on iPhone.** You can now create and access your OpenBudget account with the Google or Apple account already on your iPhone. Both buttons appear on the sign-in screen, and once you sign in the app keeps you signed in between launches.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #254](https://github.com/openbudgetfun/openbudget/pull/254)

#### Keep the books for your business

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #250](https://github.com/openbudgetfun/openbudget/pull/250)

Budgets set up as a sole trader or limited company can now turn on double-entry books. Open More, tap "Enable double-entry books" — OpenBudget sets up your chart of accounts once (this can't be undone) — and your Books are ready. Record money in and money out as journals that always balance, see everything you owe and own grouped in your chart of accounts, and check the trial balance for any date you like; OpenBudget tells you at a glance whether your books balance. Posted entries are locked for your records, so mistakes are corrected with a reversal instead of an edit, and you can set a lock date to freeze the periods you've already closed.

Journals now show their lines, so you can see exactly what went in and out of each account. Drafts can be reopened and finished later: OpenBudget fills the entry back in and saves over the same draft instead of making a second one. Your books' lock date is remembered, and the Books screen shows it at a glance.

- **Meet the Money guide.** The assistant is now the Money guide. Its answers carry small numbered marks: tap one to see where a rule or figure comes from, when it was last checked, and whether it comes from a secondary source or describes a rule that is announced but not yet law, then open the source itself. Answers about tax or investments say plainly that they are guidance, not regulated financial advice, and the usage header shows about how many conversations you have left this month.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #321](https://github.com/openbudgetfun/openbudget/pull/321)

#### See your crypto by chain or by asset in net worth

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #306](https://github.com/openbudgetfun/openbudget/pull/306)

Net worth now has a Crypto section whenever you've connected a wallet. One
printed bar shows how your crypto splits across chains, with each chain's value
and share beneath it, and a switch regroups it by asset, so all your USDC is one
line wherever it sits. Tokens that look like scams and tokens without a price
are left out, and everything is shown in your reporting currency.

#### Your money across currencies, people and businesses

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #267](https://github.com/openbudgetfun/openbudget/pull/267)

Keep separate books for yourself, a household, a sole trade or a company, each in its own currency, and see them together in one net worth.

- **Net worth across currencies.** Pick the currency you want to see everything in. Each converted figure shows the rate and date it used. When a rate is old it is marked stale, and when one is missing the screen says which accounts were left out instead of guessing.
- **Accounts in any currency.** Add bank accounts, cards, loans, property and wallets in the currency they really use. Track an account by its transactions or by its value.
- **Spend in a foreign currency.** When an account's currency differs from your books, the form shows what the amount is worth in your currency and the rate it used, and you can set your own rate.
- **Transfers between currencies and entities.** Enter what was sent and what arrived; the app shows the rate that implies.
- **Split a purchase exactly.** Break one payment across several envelopes; it only saves when the parts add up to the total.
- **Reports add up.** Spending with no category now has its own row, and age of money is back on the plan.

- **See your next tax dates.** The tax screen now has an Upcoming list with the next filing and payment dates for your books: what each one is for, the period it covers, how many days are left and the tax authority's page it comes from. When a weekend or holiday moves a date, the list shows the day it was moved from.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #307](https://github.com/openbudgetfun/openbudget/pull/307)
- **See your tax year and VAT or sales tax rates in any country.** Wherever you live, the Taxes screen now shows your tax year, the VAT, GST or sales tax rates with where each one comes from, a link to your tax authority, and a running summary of your income, expenses and tax already paid. Tap "Export tax summary" to download it for your accountant. UK, US, Nigerian and German books keep their full tax report and gain the same download button.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #301](https://github.com/openbudgetfun/openbudget/pull/301)
- **Add a wallet from any major chain.** Adding a crypto wallet is now one step: paste an address or an extended public key and OpenBudget works out the chain, from Bitcoin and Ethereum to Solana, Tron and the XRP Ledger. For an Ethereum-style address it checks which networks hold something and picks them for you, so you can add or drop a chain with a tap. While your wallet is read for the first time you see which chains are being read, and a successful add lands with an ADDED stamp. If you paste a private key or a recovery phrase, OpenBudget empties the field straight away, tells you never to share it, and sends nothing anywhere.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #309](https://github.com/openbudgetfun/openbudget/pull/309)
- **See your wallet's holdings chain by chain.** A wallet on several chains now lists its holdings in one section per chain, each with a stamp, its own total and when it was last read. Staked tokens and unclaimed rewards sit under their coin, a price that is a few days old says so, and a chain that couldn't be read tells you why while still showing its last amounts. Tokens without a price, suspected scams and anything you hide fold into one Hidden group at the bottom, where you can show or hide each one.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #305](https://github.com/openbudgetfun/openbudget/pull/305)
- **Choose which chains your wallet reads.** Open a crypto wallet and tap Wallet settings to rename it, pick the chains it looks at, or disconnect it. Not sure where your assets are? Tap "Look for assets on other chains" and OpenBudget checks and offers anything it finds. If you stop reading a chain that holds money, you're told what will leave your net worth before anything changes.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #310](https://github.com/openbudgetfun/openbudget/pull/310)

### Improved

- **Your tax profile asks where you are tax resident and whether you are a US person.** The tax profile now asks, in every country, whether you are a tax resident there and whether you are a US person, and keeps your answers when you save. Tax-saving ideas wait until you have answered. A count or amount that is not a number is now flagged right under its field, and the form stays in a comfortable column on wide screens.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #303](https://github.com/openbudgetfun/openbudget/pull/303)

#### Tax tips described neutrally and marked when based on unconfirmed figures

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #297](https://github.com/openbudgetfun/openbudget/pull/297)

Tax tips now read as descriptions of what the rules allow and what your
figures show, rather than instructions, and tips that rest on unconfirmed
figures are marked accordingly and show no estimated saving.

- **The Money guide speaks plainly about where it looks and what it is.** A Money guide reply about tax or investments now carries the disclaimer for your country, so it says what applies where you live instead of repeating the note under the screen. The small notes about what the guide looked at now say so in plain words, such as "Looked at your tax summary" or "Checked your tax deadlines". The message box now invites questions about money, tax or crypto.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #322](https://github.com/openbudgetfun/openbudget/pull/322)
- **Clearer money screens across currencies.** Net worth now leads with one big figure, says how old its exchange rates are, and points out any currency it can't convert yet instead of quietly leaving it out. Account pages show the balance, what's cleared and what the bank says at a glance, the reconcile sheet tells you plainly when you match your statement, and dates read like "Nov 8, 2026" everywhere. Foreign-currency accounts show what they're worth in your own currency right under the balance, the account-type list shows real names like Personal Loan and Solana Wallet, and the screens no longer cramp on small phones or stretch across wide windows.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #271](https://github.com/openbudgetfun/openbudget/pull/271)
- **Every screen in the new hand-drawn look.** Every screen now wears OpenBudget's new look: hand-drawn outlines, underlined section titles, sticker-style cards and a bright pink Add button. Highlighted figures, like the money ready to assign, are easier to read in dark mode, transaction labels such as "Unassigned" no longer get cut off on smaller phones, and the icons inside text fields, like the envelope beside Email, now sit neatly inside the box instead of on its corner.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #262](https://github.com/openbudgetfun/openbudget/pull/262)
- **A brighter, hand-drawn OpenBudget.** OpenBudget has a new look. The icon is now a hot-pink envelope with a gold coin dropping in, and the whole app is brighter: a sunny cream page, bold pink, teal and sunflower accents, and a deep violet ink that stays easy to read in light and dark mode. Outlines, lettering and underlines look drawn by hand. Full envelopes are sealed with wax, the money ready to assign is marked with a highlighter, and new pages slide in behind a stroke of ink. If you have Reduce Motion turned on, everything appears without the animation.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #261](https://github.com/openbudgetfun/openbudget/pull/261)
- **Tax figures say when they are still in preview.** The tax overview now tells you when a country's tax figures have not yet been checked by a tax professional, so you know to treat them as a guide.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #277](https://github.com/openbudgetfun/openbudget/pull/277)
- **See what we could not verify.** Your tax report now ends with a "What we could not verify" list: the honest gaps in our research for your country, each saying what needs a second look and none of it hidden in fine print. Figures that come from secondary sources rather than the tax authority itself carry a "From a secondary source" badge on their line, and changes a government has only announced — not yet made law — are labelled as exactly that.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #293](https://github.com/openbudgetfun/openbudget/pull/293)
- **Clearer country tax facts.** On a country without full tax rules, the Taxes screen now explains in plain words which figures come from secondary sources and which dates we assumed, shows the VAT or sales tax registration threshold, and labels each source by its website. The researchers' own notes stay one tap away under "Research notes".
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #301](https://github.com/openbudgetfun/openbudget/pull/301)

#### Net worth now leaves out suspected scam tokens and stale prices

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #302](https://github.com/openbudgetfun/openbudget/pull/302)

Wallets no longer count tokens that look like spam or scams, or prices older
than a week, toward net worth. You can still hide or allow any token yourself,
and your choice sticks across syncs.

- **Wallets stay fresh on their own.** Connected wallets now refresh automatically in the background, so balances and values stay up to date without pulling to refresh.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #314](https://github.com/openbudgetfun/openbudget/pull/314)

### Fixed

- **German tax reports now show the right numbers.** Your German tax reports got a set of corrections: filing deadlines no longer land on weekends, church tax follows your federal state (8% in Bavaria and Baden-Württemberg, 9% everywhere else), couples each get their own worker's allowance, children are credited with whichever is better for you — child benefit or the child allowance — freelancers are no longer charged trade tax, and the commuter and home-office allowances follow the 2025 and 2026 rules. The tax profile asks a few new questions, like your federal state, your children and your commute, so the numbers fit your situation.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #246](https://github.com/openbudgetfun/openbudget/pull/246)
- **UK tax figures are more accurate.** Your UK tax estimates now follow HMRC's rules more closely. Your personal allowance no longer shrinks when pension contributions or Gift Aid bring your income down, student loan repayments match the amounts HMRC collects (and you can tell us about a postgraduate loan on top of your plan), and the 31 January bill shows the real two instalments towards next year instead of a guess. Limited companies pick their actual year end and say how many companies they're connected to, so Corporation Tax lands on the right rates, and big equipment purchases stop above the annual investment allowance until the spending can be claimed. Company owners comparing salary with dividends now see the year's real thresholds, including whether the Employment Allowance applies. The UK tax profile screen asks the new questions under Company and Student loan settings.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #245](https://github.com/openbudgetfun/openbudget/pull/245)
- **Amounts you type are saved exactly.** When you type an amount like 12.34, it is now saved as exactly 12.34 instead of passing through a floating-point conversion. If you type more decimal places than the currency uses, the field tells you and asks for a correct amount rather than quietly rounding it. The same applies to accounts, transfers, recurring transactions, split expenses, reconciliation and imported transactions.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #252](https://github.com/openbudgetfun/openbudget/pull/252)
- **Record transactions in Uganda and more countries.** People whose time zone has another official name, such as Uganda's (Kampala), can now record transactions. Before, adding one failed.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #312](https://github.com/openbudgetfun/openbudget/pull/312)

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
