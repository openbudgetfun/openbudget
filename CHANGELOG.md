# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0](https://github.com/openbudgetfun/openbudget/releases/tag/v1.0.0) (2026-11-14)

Grouped release for `openbudget`.

### Store release required

#### Replace the gradient logos with the three-envelope mark

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #255](https://github.com/openbudgetfun/openbudget/pull/255)

The generic gradient "OB" monograms and their contact sheets are gone. The new identity lives as hand-authored SVGs in `brand/`: the mark (three cash envelopes, the middle one full and sealed) in paper, night and one-colour (`currentColor`) versions, a pixel-aligned small mark for 16 to 32 px that follows `prefers-color-scheme`, and the wordmark lockup in each colourway. `docs/branding.md` is now the brand guide: mark, clear space, minimum size, colours from `ObSwatch`, voice, and usage rules.

- `openbudget_ui` adds `ObMark`, a `HookWidget` that paints the mark from the same path data as `brand/mark.svg` (a test keeps them identical), follows the theme or takes an `ObMarkVariant` (`paper`, `night`, `ink`), and can draw the app-icon tile. It depends on `path_parsing` to read the path data.
- `openbudget_scripts` adds `render_brand`, which lays the mark out per platform, rasterises it with `resvg` (now in the devenv shell), and runs `flutter_launcher_icons` and `flutter_native_splash` from those renders. Run it from the repository root.
- `openbudget_app` regenerates every launcher icon (iOS with the iOS 18 dark and tinted variants, an Android adaptive icon with a themed monochrome layer, web, Windows, macOS) and the native and web splash screens on paper and night. The web app gains an SVG favicon and paper manifest colours. These are native resources, so they need a store release rather than a Shorebird patch.
- `AppIconStyle` now offers the mark's colourways (`primary` for paper, `night`, `ink`) instead of the five retired logo variants; a stored retired value falls back to `primary`. The login screen and the App Icon settings screen draw the mark with `ObMark`, and `assets/branding/logos/` is no longer bundled.

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

- `entitlement` table, `EntitlementService` and `BillingEndpoint.getEntitlement`. Each rail records its own subscription row; access holds through `currentPeriodEnd` and the period ending last wins. `BillingPlan` fixes $20 a month with $5 of built-in agent usage.
- Stripe Checkout and billing portal sessions with signed webhooks, RevenueCat App Store and Play Store webhooks, and the Solana Subscriptions Delegation Program rail with a wallet ownership challenge, on-chain verification and an hourly collector that charges 20 USDC per 30-day period. Confirming a Solana subscription never charges twice, and a failed first payment grants nothing.
- The app's `/plus` screen offers RevenueCat on mobile, Stripe on web and desktop, and Solana USDC on web.

##### Agent

- `AgentEndpoint` runs a tool-calling assistant on OpenCode Zen (`deepseek-v4.1-flash`) or the user's own OpenAI-compatible provider, metered at published prices against the included allowance. Bring-your-own keys are stored with AES-256-GCM, and provider URLs that resolve to internal addresses are refused.
- The assistant never writes data: propose tools record pending `AgentProposal`s that the user applies or dismisses, claimed atomically so a proposal applies once.
- A Streamable HTTP MCP server at `POST /mcp` exposes the same tools to external agents through revocable personal access tokens (`AgentTokenEndpoint`), stored as SHA-256 hashes and rate limited per token. The app adds an Agent access screen to create, copy once and revoke them.
- The app adds the assistant chat, proposals and provider screens.

##### Errors and release notes

- Every server exception is a Serverpod serializable exception declared in `openbudget_server/lib/src/exceptions/*.spy.yaml`, so clients match on types such as `ValidationException(message:)` and `EntitlementRequiredException` instead of a generic 500.
- The app reads the bundled release notes, shows them once after an update, and keeps them available from Settings.

#### Build iOS with a CocoaPods-resolvable RevenueCat SDK

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #260](https://github.com/openbudgetfun/openbudget/pull/260)

`purchases_flutter` moves from 11.0.0 to 10.19.0. Version 11 needs
`PurchasesHybridCommon` 20.0.0, which has never been published to the
CocoaPods trunk CDN, so a clean `pod install` could not resolve the iOS
workspace. 10.19.0 is the newest release whose `PurchasesHybridCommon`
dependency (19.17.0) is on trunk, and its Dart API matches every call the
OpenBudget Plus flow makes, so billing behaviour is unchanged.

The iOS project now builds the `Pods-Runner` aggregate target as part of the
shared schemes, so Xcode compiles the plugin frameworks before
`GeneratedPluginRegistrant.m` imports them. The Podfile no longer excludes the
`x86_64` simulator slice, which lets the pods build for the same architectures
as the Runner app.

`ios/Podfile.lock` and `pubspec.lock` are refreshed, which also records the
`package_info_plus` and `solana_kit_mobile_wallet_adapter` pods that were
missing from the stale iOS lockfile.

#### Wire native iOS Google and Apple sign-in

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #254](https://github.com/openbudgetfun/openbudget/pull/254)

- The iOS Runner target now ships a `Runner.entitlements` file with the Sign in with Apple capability, applied to every build configuration.
- The Google reversed-client-id URL scheme is read from `ios/Flutter/Secrets.xcconfig` (gitignored, with a committed example) so no client id is committed, and the URL schemes in `Info.plist` expand it.
- The login screen decides social availability through a pure `socialSignInAvailability` function: iOS shows Apple from the native entitlement alone and Google when both Google client ids were supplied, while web and Android keep requiring the Apple service id and redirect URI.
- `config/dart_defines.local.json` (gitignored, example committed) carries the client ids, and the devenv `flutter:app` command passes it to `flutter run`, `build`, `test` and `drive` when it exists.
- Native Google sign-in on iOS and Android only shows when `GOOGLE_SERVER_CLIENT_ID` is also supplied, so the ID token is addressed to the web client that Serverpod's Google provider verifies.
- `server.dart` reads the social provider passwords through tested helpers, and `config/passwords.example.yaml` documents every key.
- The Runner target excludes `x86_64` on the simulator, matching the pod targets' existing `EXCLUDED_ARCHS`, so the simulator build links the arm64-only pod frameworks.

#### Reprint the identity and design system as a vivid Skribble zine

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #261](https://github.com/openbudgetfun/openbudget/pull/261)

The brand and the shared design system move from warm paper and indigo to a two-colour print look: a cream page, white sheets, one deep violet ink and saturated spot inks (hot pink, teal, sunflower, cobalt, tangerine, lilac) printed slightly off-register. Every text pairing is checked against WCAG 2.2 AA in `ob_palette_test.dart`.

- `brand/` has a new mark (an open hot-pink envelope with a gold coin and a teal overprint) in paper, night (chalk halo), one-colour and small versions, plus lockups lettered in Skribble Black. `render_brand` regenerated every platform icon and splash screen on the cream tile, which is a native change.
- `openbudget_ui` rewrites `ObSwatch`, `ObPalette` (adds `onHighlighter`, `overprint`, `printShadow` and six `spots`) and `OpenBudgetTheme`: Skribble display and Skribble Linear Playful text faces, firm inked rough outlines, sticker buttons that press into a hard print shadow (`ObStickerBorder`), highlighter-swipe navigation indicators (`ObMarkerBorder`), and the expressive Skribble roughness.
- New flourishes, all silent to screen readers and still under reduced motion: `ObScribbleUnderline`, `ObPostmark`, `ObSeal`, `ObCurrencyStamp`, `ObInkBurst`, `ObSpotDoodle`, and `ObInkPageTransitionsBuilder` (an ink wipe on Android, web and desktop; the native slide with an inked edge on iOS and macOS). `useObFlourish` and `obMotionAllowed` gate them on `MediaQuery.disableAnimations`.
- Reworked components: `ObCard` (`raised` stickers), `ObAmount`, new `ObHeroAmount`, `ObHighlighter`, `ObSectionHeader`, `ObStatePanel`, `ObLoadingPanel`, `ObToneChip`, `ObEnvelopeGauge` (wax seal and ink burst when full, torn flap when overspent), new `ObListRow` and `ObIconBadge`, and `ObMark` on the new paths.
- New `ObFieldIcon`: a Skribble icon that centres itself in a text field's 48pt icon slot. A bare `SkribbleIcon` stretches to fill that slot but draws in its top-left corner, on the field's outline; `ObTextField` now centres any icon it is given.
- `openbudget_site` keeps its envelope desk and doodles, takes the same palette tokens, and adds orchestrated entrances, sticker buttons, spot-ink envelopes, seal bursts and an "All assigned" postmark, doodles that draw in, scroll-linked moments, and a hand-drawn GitHub mark beside every GitHub link. All motion respects `prefers-reduced-motion`.

### Breaking changes

#### Port the app to the entity schema

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #267](https://github.com/openbudgetfun/openbudget/pull/267)

The app now talks to the entity-based protocol end to end. Routes take `:entityId`, every amount is an integer in the currency's minor units, and months are `yyyymm` ints. Realtime refreshes come from `entityStream.watch` and invalidate providers by `ChangeScope`. The plan reads one `budget.getMonth` view, home reads `entity.listSummaries`, and the reports read `report.spending`, `report.monthSummaries` and `report.ageOfMoney`. The app never converts currencies itself: every converted figure comes from the server with its rate, rate date and source.

#### Reset the schema to the entity model

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #267](https://github.com/openbudgetfun/openbudget/pull/267)

Replace budget-owned records with entity-owned accounts, transaction lines and exact minor-unit amounts. Reset local databases before applying the single replacement migration; regenerate clients for the breaking protocol changes.

### Features

#### Create an entity in any country

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #288](https://github.com/openbudgetfun/openbudget/pull/288)

`CreateEntityScreen` replaces its four-country list with a searchable picker over every servable country in `Countries.all`, and a searchable picker over every ISO 4217 currency. Both, and the time zone choice, are one reusable `showObPickerSheet` in `openbudget_ui`: search by name, code or keyword ignoring case and accents, an exact code ranked first, Enter to take the top result, the down arrow into the list, a live result count, and the highlighter, a check and a spoken state on the chosen row. The library carries no strings, so callers pass theirs from `app_en.arb`.

Choosing a country fills the currency (its first bookable one, or USD when none is), time zone and, for a person or sole trader, a read-only tax year row; a company keeps its editable year end. `defaultFiscalYearEnd` now ends an individual's year the day before the country's Gregorian `individualTaxYear` starts, so GB, US, NG and DE are unchanged and Australia ends 30 June; countries with no tax year in the dataset, or a non-Gregorian one, still end 31 December. `CountryInfo.displayName` and `searchAliases` (in `country_display_name.dart`) turn the terse IANA names ("Britain (UK)", "St Lucia") into what people write and find. The year-end row also fixes its swapped day and month.

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

#### Render Money guide citations, disclaimers and the conversations-left estimate (G11)

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #321](https://github.com/openbudgetfun/openbudget/pull/321)

The assistant feature now presents itself as the Money guide (`docs/money-guide.md`, section 3). The `assistant*` ARB keys keep their names; their values and the Plus copy say "Money guide", and a widget test scans every assistant screen for a visible "assistant" label.

- Replies keep the server's `AgentEvent.citations` and `touchesTaxOrInvestment`, and stored messages read `citationsJson`, as `AssistantSource` values on `AssistantTimelineItem.assistant`.
- `parseCitedReply` numbers `[^key]` markers in order of first appearance, reuses a key's number, drops markers with no source and lists uncited sources last.
- Marks render as `TextSpan`s on a spot-ink wash, padded with no-break spaces so they wrap with their word, with a tap recognizer, a "Source N: title" semantics label and a 44-point near-miss target. Tapping one, or the "N sources" button, opens `AssistantSourcesSheet`.
- `SourceGradeChip`, `SourceLinkText` and `openSourceLink` move out of `universal_tax_panel.dart` into `tax/widgets/source_widgets.dart`, so the tax panel and the sources sheet share one badge and link style.
- Flagged replies show `assistantDisclaimer` under the message; the usage meter shows `assistantConversationsLeft` when `AgentUsageView.conversationsLeft` is set.

- **Add ObReadableWidth and polish the multi-currency screens.** `openbudget_ui` adds `ObReadableWidth`, which widens a scroll view's padding so its content stays in a readable column on wide windows while the scroll view still spans the window. In `openbudget_app`, dates on the multi-currency screens go through `DateLabels` (`intl` with the active locale) instead of hand-built strings, `FxRateLine` localises the rate source and takes an optional action, and the integration screenshot helper captures the painted surface at its real device pixel ratio (the old capture left a white margin on desktop) and gains `useScreenshotSurface`. A new Patrol tour, `multi_currency_screens_flow_test.dart`, captures every multi-currency screen at phone and desktop size.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #271](https://github.com/openbudgetfun/openbudget/pull/271)
- **Show a preview banner on the tax overview.** While a country pack is `preview`, the tax overview leads with a notice that the figures have not yet been checked by a tax professional. A `reviewed` pack hides it. The copy is localised.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #277](https://github.com/openbudgetfun/openbudget/pull/277)
- **Universal tax categories (task U6).** The country-neutral tax category catalogue of `docs/tax-jurisdictions.md` section 8.6 now lives in `openbudget_core/lib/src/tax/universal/`: 44 codes prefixed `universal.` across income (gains and digital-asset disposals split into proceeds and cost), 17 business expenses, 7 reliefs, 4 tax-paid kinds and 4 out-of-scope kinds, each with an ARB label key. `TaxRulePack` grows `mapUniversalCategory`, implemented for GB, US, NG and DE with per-kind tables that map each universal code onto the pack's own code or leave it deliberately unmapped (kinds must match, so a relief never lands on an expense line — the contract test enforces this). The server accepts universal codes on every entity regardless of country, `tax.listCategories` for an entity whose country has no rule pack returns the universal catalogue without requiring a tax profile, and `tax.getReport` maps universal codes through the pack before computing: unmapped universal entries count as uncategorised and the report carries a caveat naming the count. Includes a Kenyan end-to-end server test (create, tag lines and envelopes, list categories) and a GB sole-trader test proving `universal.expense.software` lands on SA103F box 23. App-localisation labels are generated; the in-app universal panel is task U11 and the full country picker U10, so no screen changes yet.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #285](https://github.com/openbudgetfun/openbudget/pull/285)

#### Universal tax panel and summary export (U11)

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #301](https://github.com/openbudgetfun/openbudget/pull/301)

`TaxOverviewScreen` now shows `UniversalTaxPanel` for any entity whose country has no tax rule pack, replacing the "no tax rules" dead end. The panel reads the tax year and indirect-tax rates straight from `Countries.byCode` (rates formatted from the integer `ratePerMillion`, graded by their source, with the secondary-source badge), links to the authority, and shows the `tax.getSummary` totals. `TaxExportCard` calls `tax.createExportLink` through the new `TaxExport` notifier and opens the signed URL with `url_launcher` behind the `TaxUrlLauncher` seam, on pack and non-pack entities alike. `TaxRepository` gains `getSummary` and `createExportLink`; the year switcher, caveat card and disclaimer bar move to shared widgets. No server, migration or native changes.

#### Add a crypto wallet (W6.2)

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #309](https://github.com/openbudgetfun/openbudget/pull/309)

The add-account screen's Solana-only "Connect wallet" step becomes
`AddWalletStep` (`features/accounts/widgets/add_wallet_step.dart`): one paste
field that runs the core `WalletAddressParser` as the person types and shows
the detected chain as an `ObChainStamp`. An EVM address is looked ahead at
through `wallet.preview` and offered as a picker of chain stamps, with the
networks that hold priced assets pre-selected; the home network (Ethereum) is
always read, because the server requires it. A `zpub`, `ypub` or `xpub` connects
as a Bitcoin HD wallet. A private key, `0x` plus 64 hex digits or recovery phrase
(including three or more words in a row) empties the field on the device, shows
the refusal in an `ObStatePanel.problem`, and sends nothing. The refused text is
never put in a provider state.

`AddWalletFlow` (Riverpod, `features/accounts/providers/add_wallet_provider.dart`)
holds the preview, the picked networks and the connect, with Freezed states in
`models/add_wallet_state.dart`. While the server reads the new wallet the screen
shows "Reading Ethereum, Base and Arbitrum One…"; a wallet whose every network
failed gets a retry through `wallet.sync`. The app passes a localised
`accountName` ("Ethereum wallet (0x5a…eAed)", "Bitcoin wallet, zpub"), and
success stamps an `ObPostmark`. `WalletActions.connect` now takes
`scanNetworks` and refreshes the account list, and `supportedWalletNetworks`
reads `wallet.supportedNetworks` so an unavailable chain is said so up front.
The unused Solana-only wallet strings are removed.

#### Wallet holdings grouped by chain (W6.3)

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #305](https://github.com/openbudgetfun/openbudget/pull/305)

`WalletHoldingsSection` replaces the private `_WalletHoldingsSection` and
`_HoldingRow` in `account_detail_screen.dart`. It is a `HookConsumerWidget`
under `features/accounts/widgets/`, fed by `buildWalletHoldingsView` (Freezed
`WalletHoldingsView`, `WalletNetworkSection`, `WalletAssetGroup` and
`HiddenHolding` in `features/accounts/models/`). It draws one section per
network with an `ObChainStamp`, the counted subtotal and "Read 2 hours ago"
from `wallet.listNetworkStates`, groups staked and unclaimed positions under
their asset with `ObToneChip`s, marks `cached` prices, shows a failed network's
note and `lastError`, and folds `suspected`, `hiddenByUser` and `unpriced`
holdings into a collapsed Hidden group.

`walletNetworkStatesProvider` and `WalletActions.setHoldingVerdicts` (which
calls `wallet.setHoldingVerdict` per holding and refreshes the holdings) are
new. `WalletActions` is now `keepAlive`: as an auto-disposed notifier it was
already unmounted when its post-await `ref.invalidate` calls ran, so neither
`sync` nor the new verdict calls refreshed anything.

A holding counts only when `priceQuality` is not `unpriced`, it has a
`valueMinor`, and its verdict is `clean` or `allowedByUser`, the same rule the
server's valuation uses.

#### Wallet settings on account detail

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #310](https://github.com/openbudgetfun/openbudget/pull/310)

A wallet account gets a "Wallet settings" sheet (`WalletSettingsSheet`) that renames the account, edits the networks an EVM wallet reads, and disconnects it. The chain editor reuses the add-wallet picker's `ObChainStampToggle` stamps (inked when read, outline when not) with each chain's value from the holdings; dropping a chain that holds value asks in the page what leaves net worth before it calls `wallet.setScanNetworks`. "Look for assets on other chains" runs `wallet.preview` again through `WalletLookAhead`, picks the chains it finds, and says so when nothing new turns up.

Account detail now shows the settings button and the holdings for wallet accounts that track by value, which is every account the server creates for a wallet; before, only the transaction branch drew them. `AccountActions` is kept alive so its invalidations land, and renaming refreshes `accountDetailProvider`. The add-wallet refusal card uses a lock for secrets, and `addAccountSuccessAddAnother` reads "Add another".

#### Guardrail data in core and neutral tax opportunities (G1)

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #297](https://github.com/openbudgetfun/openbudget/pull/297)

`openbudget_core` now carries the Money guide's guardrail data: per-country
regulatory perimeters, the never-suggest list, signpost triggers and
disclaimer keys for GB, US, DE and NG. `TaxOpportunity` and
`TaxOpportunityView` gain `grade`, `announced`, `signpostOnly`,
`needsEvidence`, `ruleYear` and `assumptions`, and opportunity titles are
neutral noun phrases. Opportunities built on secondary or inferred figures,
or on announced rules, carry no computed saving.

#### Every ISO 4217 currency can be a base currency

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #272](https://github.com/openbudgetfun/openbudget/pull/272)

`CurrencyCode` is generated from `openbudget_core/data/iso4217.json`, the ISO 4217 List One published by SIX on 2026-09-17, and grows from 27 members to 166. Every active code with a published minor unit is included with its published exponent, including the two funds (CLF, UYW) the standard gives four decimal places. The 26 ISO codes and BTC that shipped before keep their names, symbols and exponents exactly.

The 13 codes ISO 4217 publishes without a minor unit are recorded in the data file and rejected: precious metals, units of account, the testing code and the no-currency code cannot hold an amount, so `XXX` is still not a currency. `dart run tool/generate_currencies.dart --check` runs in CI's lint job, beside the generated icon check.

The FX service no longer sends a currency filter to currencyapi.com: the provider rejects a filter naming a code it does not list, and it prices 155 of the 166 codes. It now answers with every currency it prices, and the parser keeps the supported ones. The 11 unpriced codes still work as a base currency, and a cross-currency write falls back to the existing manual-rate path.

#### Double-entry ledger foundation: core model, posting service and trial balance

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #248](https://github.com/openbudgetfun/openbudget/pull/248)

`openbudget_core` gains a pure-Dart ledger module: the five account types with their normal balances, the stable system-role set (bank, AR/AP, VAT control, payroll liabilities, directors' loan, retained earnings, opening-balance equity, suspense, rounding, realised/unrealised FX, owner drawings), draft-journal validation (at least two one-sided positive lines, exact-decimal FX conversion with the per-currency exponent, balance in the functional currency and per transaction currency for single-foreign-currency journals), trial-balance computation with a hard error on imbalance, and starter charts of accounts for GB/US/NG/DE companies and sole traders (SKR04-style German numbers marked unverified).

`openbudget_server` adds the `ledger_account`, `journal`, `journal_line`, `ledger_period_lock` and `ledger_audit_event` tables, an `accountingMode` field on `Budget`, and a `LedgerEndpoint` with ownership checks on every call: `enableLedger` (validates the budget's tax-profile entity kind is soleTrader or company and seeds the chart from the jurisdiction template), account listing/creation/archival, draft save/edit/delete, posting, reversal (posted journals are immutable — corrections are reversal journals), journal listing with date filters, `setLockDate` (posting or reversing on or before the lock is rejected) and `trialBalance(asOf)`. Every post, reversal, lock change and mode switch writes an audit event row. One Serverpod migration ships with this change; generated client protocol is committed.

#### Ledger reads and integer-only amount parsing

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #250](https://github.com/openbudgetfun/openbudget/pull/250)

`openbudget_server` adds two ledger reads, `listJournalLines(journalId)` and `getLockDate(budgetId)`. Both check ownership and require a ledger budget, and need no migration. `openbudget_core` adds `parseMinorUnits` and `formatMinorUnits`, which parse and render plain amounts with integers only and refuse input with more decimals than the currency has. The tax screens' `double`-based helpers are replaced by them, so a tax form now rejects `12.345` for a two-decimal currency instead of rounding it. `LedgerValidationIssue` gains `lineIndex`, the zero-based line an issue refers to.

#### Resolve and store Money guide citations (G9)

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #317](https://github.com/openbudgetfun/openbudget/pull/317)

`AgentService` resolves every `[^key]` in an assistant reply against the tool results stored in the conversation: a `search_knowledge` card's `citeAs`, or a tax tool result's `citeAs`. A pure `CitationCatalogue` in `money_guide/citation_resolver.dart` strips keys it cannot resolve, including a real card id the model never retrieved, before the reply is stored or sent. The reply arrives whole, so the stored text, the streamed `textDelta` and the history the model sees next are the same string and no key can be split across chunks.

`agent_message` gains `citationsJson` and `touchesTaxOrInvestment` (one migration, `money-guide-citations`), and the `textDelta` `AgentEvent` carries `citations` and `touchesTaxOrInvestment`. A reply touches tax or investment when it cites a card whose perimeter is not `general`, or a tax report or summary.

`get_tax_report` now returns `citeAs` as `report-<startYear>`, and `get_tax_summary` returns `citeAs` as `summary-<startYear>` with the pack's authority pages in `sources`. A universal-layer summary carries neither, so it cannot be cited.

#### Keep Money guide calls under the context ceiling (G10)

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #319](https://github.com/openbudgetfun/openbudget/pull/319)

`ContextBudget` in `money_guide/context_budget.dart` builds the history of every model call. When the history passes 32,000 estimated tokens it replaces the bodies of tool results older than the last two turns with `{"elided": true, "tool": "...", "citeAs": "..."}`, once per crossing, so the provider's prompt cache breaks once and not on every call. The stored rows are never rewritten and the compaction is replayed from them on each call, so no migration is needed and the citation catalogue still resolves every key an elided result carried.

No call carries more than 40,000 estimated tokens. A user message longer than 4,000 estimated tokens is refused before any call. If a call is still over the ceiling after compaction, tool results are elided oldest first for that call only, and if it cannot fit even then the turn stops with a "conversation too long" error and no call is made.

`AgentUsageView.conversationsLeft` is the remaining allowance divided by the median cost of the user's newest 20 metered conversations, rounded down. It is null below three conversations, for bring-your-own providers, and when the typical conversation costs nothing. `AgentUsageService.view` takes an optional `now` so tests can pin the subscription period.

- **The Money guide knowledge base: card format, generator and index.** Knowledge cards now have their format and tooling (`openbudget_server/knowledge/`, docs/money-guide.md sections 4.1 and 4.2). `dart run tool/generate_knowledge.dart` parses the Markdown front matter, validates every card — sources, the 300-word limit, the guardrails wording lint, and that every `{{figure:id}}` placeholder exists in the country pack for each listed tax year — and writes the cards as Dart constants under `lib/src/money_guide/knowledge/`; `--check` fails when the committed constants drift, and CI runs it in the lint job. A pure-Dart BM25 index ranks cards with the title/keyword/body weights of section 5.2 and filters by country, tax year and entity kind. Five sourced sample universal cards ship with it.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #296](https://github.com/openbudgetfun/openbudget/pull/296)
- **Add the Money guide prompt.** `MoneyGuidePrompt` replaces `AgentPrompt` in `openbudget_server/lib/src/money_guide/money_guide_prompt.dart`. Every model call now opens with two system messages: the static rules of `docs/money-guide.md` section 7.2, identical for every entity so provider prompt caching is shared, and a generated entity brief. The rules cover guidance-not-advice framing, sourced-facts-only with `[^key]` citations, jurisdiction states, the never-suggest list, wording, signposting and propose-only changes. The brief carries the country, entity kind, base currency, tax year, the state of each tax section (`full`, `preview` or `universal`) from the pack manifest, the rules version, the guidance perimeter and professional, the recorded residence and US-person answers, the indirect-tax rates of a country without a pack, and the ids and titles of the knowledge cards the model may read. It never carries the entity name or any identifier. Golden snapshots pin the brief for GB, US, DE, NG and Kenya.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #316](https://github.com/openbudgetfun/openbudget/pull/316)
- **Add Money guide read tools (G7).** `get_spending_summary`, `get_tax_calendar` and `get_tax_summary` are registered in `AgentToolRegistry` and exposed over MCP. `get_spending_summary` aggregates up to 12 months of income and spending per envelope and category group with totals, monthly averages and a spending trend. `get_tax_calendar` returns the next pack deadlines (capped at 10) or the universal tax-year end. `get_tax_summary` returns the U8 tax-ready summary totals for any country with `citeAs`. All three carry the `guidance` block and enforce ownership. `get_crypto_tax_summary` is left out pending C9.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #311](https://github.com/openbudgetfun/openbudget/pull/311)
- **Add search_knowledge and the guidance block (G6).** The Money guide now has a `search_knowledge` tool backed by the G2 BM25 index, registered in `AgentToolRegistry` and exposed over MCP. Results carry `citeAs`, resolved card bodies and a `guidance` block. Entities in a country without a pack get a universal hint from `get_tax_report` instead of an error, and the MCP `instructions` carry the short guardrail rules. Every tax and knowledge tool result now carries a `guidance` block with the disclaimer key, scope statement, jurisdiction state, rules version and signpost targets.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #308](https://github.com/openbudgetfun/openbudget/pull/308)

#### Crypto breakdown report for net worth (W6.4)

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #306](https://github.com/openbudgetfun/openbudget/pull/306)

`report.cryptoBreakdown(entityId, grouping, {currencyCode})` returns a
`CryptoBreakdownView` of `CryptoBreakdownRow`s: what an entity's wallets are
worth today, by chain (`byChain`, one row per network) or by asset (`byAsset`).
Only counted holdings are summed: priced, with a spam verdict of `clean` or
`allowedByUser`. Each wallet's value in one currency is converted once with
the daily FX the net worth report uses and shared over its holdings by largest
remainder, so the rows, the total and net worth's figure for the same wallets
agree to the minor unit and no double touches a sum. By asset, natives and the
catalogue's canonical tokens merge across networks (all USDC is one row);
every other token is one row per network and asset, with the top eight listed
and the rest as "Other". A currency with no rate is reported in
`missingCurrencyCodes` and left out, never guessed. A foreign entity is
`Forbidden`. No migration: the views are not tables.

#### Add combined and historical net worth reports

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #267](https://github.com/openbudgetfun/openbudget/pull/267)

`NetWorthService` now returns one coherent current view and a chart-ready
history for the caller's entities. Every account is converted exactly once and
the same converted atoms feed the asset, liability, entity and currency
breakdowns, so rounding never makes the totals disagree. A missing quote leaves
the currency out of the totals and lists it instead of pretending a 1:1 rate.

History rebuilds balances from live transactions and valuations at up to 400
day, week or month points, with one batched fact query per source and one FX
query for the whole range. `ReportEndpoint` also serves spending, month summaries and age of money,
and `entity.listSummaries` gives the home screen every entity in one call.

#### Caveats and named figures as data

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #293](https://github.com/openbudgetfun/openbudget/pull/293)

Every `TaxRuleSet` now carries `TaxRuleCaveat` rows (id, grade P/S/I, plain-language text, the sections or rule keys it touches, `recheckBy`) and a `figures` map of `TaxFigure` (id, value with unit, source, grade, `verifiedOn`) — the headline numbers knowledge cards will quote (personal allowance, basic-rate band, VAT registration threshold, standard deduction, Grundfreibetrag, rent relief cap and more). The "Unverified and changing" lists of the uk-personal-tax, uk-company-tax, uk-vat-payroll, us-federal-tax, nigeria-tax and germany-tax skills are ported onto the GB, US, NG and DE packs; no figure value changed, each is only named and given its source and grade. Reports carry only the caveats they touched (`TaxReport.caveats`, plus `TaxReportLine.figureId` on lines presenting a named figure), which flow through `TaxReportView` as `TaxRuleCaveatView` and `TaxFigureView`. `dart run openbudget_core:tax_freshness` now reports overdue caveats alongside countries through the existing re-check seam. No migration: the new fields are view-only.

- **Build the signed tax summary export download.** `tax.createExportLink(entityId, startYear)` returns an absolute URL to a new Relic route, `GET /tax/export/<token>.zip`, which serves the tax-ready summary as a ZIP of `summary.csv`, `lines.csv` and `README.txt`. The link is an HMAC-SHA256 token over the owner's user id, the entity id, the year and an expiry — ten minutes, no table, and no name, email or entity name in the URL — with the signing key derived from the existing Serverpod service secret (`openbudget.tax-export.v1` context) and signatures compared in constant time. The download re-verifies the signature, expiry and the entity's stored owner, then rebuilds the summary through `TaxSummaryService` (now via `buildForExport`, which keeps the per-line provenance and accepts a `SystemEntityOwner` for the web session). Amounts are decimal strings at the currency's exponent, and every refusal answers a bare 404 with the reason only in the server log. `TaxSummaryService.defaultStartYear` resolves a link without a year through the same period rule as `getSummary`, and the shared tax-line query gained the payee and envelope names for the lines.csv columns. The `archive` package is a new direct dependency of `openbudget_server`.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #294](https://github.com/openbudgetfun/openbudget/pull/294)

#### Add the filing calendar (C5)

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #307](https://github.com/openbudgetfun/openbudget/pull/307)

`TaxRulePack.deadlines(period, profile)` derives the filing and payment dates a tax year creates, as `TaxDeadline` values with a stable rule id, a neutral title, the period covered, a source and citation, an evidence grade, a profile-dependence flag and, when a weekend or holiday moved it, the date before. GB, US, NG and DE take their dates from the four country skills: the US pack moves a date to the next business day under § 7503 (federal holidays plus DC Emancipation Day), the DE pack reuses its § 149 and § 108 AO logic, and the GB and NG packs move nothing. Dates the profile or the books do not hold stay out, and the contract test lists each one with its reason.

`tax.listDeadlines(entityId)` returns the entity's deadlines from today to a year ahead, with days left. It enforces ownership, gives an empty list for a country without a pack and uses the entity's own facts and the pack's defaults when no profile is saved. The tax overview shows the next dates in an Upcoming list (`TaxUpcomingSection`, behind `taxDeadlinesProvider`). The generated protocol and client carry the new `TaxDeadlineView`. The US and NG manifests now report the filing calendar as partial.

- **Record the tax rule version on reports and tax proposals.** `TaxReportView` carries `rulesVersion`, `maturity` and the per-section `coverage` the pack declares. Tax proposals created through the assistant's registry store the `rulesVersion` of the entity's current tax year in `AgentProposal.rulesVersion`, so an applied change can be traced to the figures it was made under.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #277](https://github.com/openbudgetfun/openbudget/pull/277)

#### Build tax-ready summaries for every country

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #291](https://github.com/openbudgetfun/openbudget/pull/291)

`tax.getSummary(entityId, startYear)` now returns a `TaxSummaryView` for any entity and year, from `TaxSummaryService.build` (docs/tax-jurisdictions.md, section 8.7). A pack country uses its pack's tax year and reports totals under the pack's own category codes; any other country uses the universal tax year, and a company uses its own financial year. The view carries a header (period, base currency, rules version or verified-on date, disclaimer key), income, expense, relief and tax-paid totals by category after business-use share, VAT/GST collected and paid by rate and by quarter from the lines' sales-tax fields, wallet disposals with their stored FIFO estimates, method and caveats, FX notes with the exact rate facts each converted line used, and the count of uncategorised lines. No table or migration is added. Wallet figures keep their stored P&L currency and are never converted.

- **Add an Esplora Bitcoin provider for single addresses.** `EsploraClient` reads single Bitcoin addresses from mempool.space with Blockstream as fallback, throttling to five requests a second per host, honouring `Retry-After` on 429 and failing over between hosts. `BitcoinWalletProvider` maps confirmed plus mempool balance (`chain_stats` and `mempool_stats`, funded minus spent txo sums) to one satoshi quantity with eight decimals, and is registered for the Bitcoin family without a secret. Extended keys (`xpub`/`zpub`) are reported as not yet supported.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #295](https://github.com/openbudgetfun/openbudget/pull/295)
- **Sync wallets per network and add the preview and network endpoints.** A wallet sync now commits per network: holdings are replaced only for the networks the provider read, a failed network keeps its stored quantities and is re-priced from cache, and `wallet_network_state` records when each network was last read and why the last read failed — in plain words, with no URL, key or address. The sync is `synced` when at least one network read and `failed` (last facts kept) when none did, and `WalletSyncResult` reports `readNetworks` and `failedNetworks`. `connect` validates addresses through the shared core parser (refusing private keys, recovery phrases and testnet forms before anything is stored) and takes `scanNetworks` for EVM wallets. New endpoint methods: `wallet.preview` (rate limited to 20 reads an hour per user), `wallet.supportedNetworks`, `wallet.setScanNetworks` and `wallet.listNetworkStates`.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #292](https://github.com/openbudgetfun/openbudget/pull/292)

#### Take the wallet schema multichain

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #279](https://github.com/openbudgetfun/openbudget/pull/279)

Wallets, holdings and on-chain transactions now carry their `WalletNetwork`, holdings carry a `position` (available, staked, unclaimed rewards) and a `spamVerdict`, and the new `wallet_network_state` table keeps per-network read state and history cursors for the multi-network sync. EVM wallets get `scanNetworks`, and HD wallets get a sealed descriptor slot. Existing Solana wallets, holdings and transactions are backfilled with their wallet's network by the migration — no data is dropped — and `PriceSource` adds `coingecko` and `defillama` for the next price work.

#### Share the `WalletNetwork` model with the chain catalogue

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #275](https://github.com/openbudgetfun/openbudget/pull/275)

Moves `WalletNetwork` from the server to `openbudget_core` with every launch value from `docs/multichain-wallets.md` section 7.1 (Bitcoin, seven EVM networks, Tron, the XRP Ledger, Hyperliquid, Dogecoin, Litecoin, Cardano, TON, Sui and Aptos beside Solana), so the server, the client and the app share one definition. Values are stored by name, so no database migration is needed; existing Solana rows and serialisation are unchanged.

Core gains `ChainFamily` (one integration per family, Hyperliquid kept its own family per the plan's validation table), the `WalletNetworkRules` extension (family, testnet flag, native symbol and decimals, display name, EVM chain id, catalogue entry) and a `ChainCatalog` of canonical assets per network — the native coin plus USDT, USDC, DAI, WETH and WBTC where a citable canonical deployment exists. Every token contract is cited from its issuer's or chain's own documentation; price ids are deliberately left for W2.1. `wallet.connect` now rejects networks that have no reader yet instead of silently accepting any future value.

- **CoinGecko and DefiLlama price service (W2.1).** Adds CoinGecko `/simple/price` and `/simple/token_price/{platform}` clients (chunked at 515, pro host with `x-cg-pro-api-key` when `coingeckoProApiKey` is set, otherwise demo host with `x-cg-demo-api-key`) and a DefiLlama `prices/current` client (no key). `PriceService` resolves `(network, assetId)` pairs through the `asset_price` cache (15-minute expiry), then CoinGecko, then DefiLlama, writing the cache. CoinGecko native and platform ids are pinned into the core chain catalogue (marked unverified until the manual `--check` tool confirms them). `PriceSource` already carries `coingecko` and `defillama`. Both CoinGecko keys are documented in `passwords.example.yaml` with environment fallbacks.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #299](https://github.com/openbudgetfun/openbudget/pull/299)
- **Resolve wallet providers through a per-family registry.** `WalletProvider` now takes one `WalletReadRequest` — the wallet's home network, the networks to read, the address and, for HD wallets later, the sealed descriptor — and returns per-network results: holdings carry their `network` and `position`, and the snapshot reports which networks it read, which failed with a plain-words reason, and which history cursors it reached. A new `WalletProviderRegistry` maps each `ChainFamily` to its provider factory and reports a family as unsupported while its secret is missing, following the password-plus-environment fallback pattern. Solana's provider is the first registration and behaves exactly as before, and a regression test pins that no provider call happens inside the sync's database transaction.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #289](https://github.com/openbudgetfun/openbudget/pull/289)
- **Add the hourly wallet refresh future call.** `WalletRefreshFutureCall` registers as `wallet-refresh-hourly` beside `fx-refresh-hourly`. Each run reads due wallets by plan (free every 24 hours, Plus every 6 hours, oldest due first, capped per run) and revalues every other wallet from cached prices with no provider call. Manual syncs are throttled to one per 5 minutes per wallet using the wallet row's timestamp, consistent across server instances, and the in-memory preview rate limiter keeps its clock seam.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #314](https://github.com/openbudgetfun/openbudget/pull/314)

#### Reading a wallet again when its networks change

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #310](https://github.com/openbudgetfun/openbudget/pull/310)

`wallet.setScanNetworks` now reads the wallet at once when the set of networks changed: an added network shows its holdings, a removed one loses its holdings, and the account valuation follows, before the call answers. A read that fails on every network is recorded per network and does not undo the change. The commit also deletes the `wallet_network_state` row of a network that left the scan set, so it no longer shows as a stale section. No migration. The generated client carries the updated documentation.

#### Wallet spam classifier, verdicts and valuation rules (W2.2)

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #302](https://github.com/openbudgetfun/openbudget/pull/302)

`WalletSpamClassifier` runs on every wallet read for every chain family and
marks bait-named, impersonating and unlisted outlier tokens `suspected`. User
verdicts (`hiddenByUser`, `allowedByUser`) survive every sync; only the
classifier moves a holding between `clean` and `suspected`. A wallet's
valuation sums priced holdings whose verdict is `clean` or `allowedByUser`,
and cached prices older than seven days leave the holding `unpriced` and
uncounted. `wallet.setHoldingVerdict` lets a user hide, allow or clear an
override, handing control back to the classifier.

The client protocol gains `SpamVerdict` on wallet holdings; core gains nothing
new beyond the shared enum already present.

- **XRP Ledger provider.**
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #300](https://github.com/openbudgetfun/openbudget/pull/300)
- **Add citations to the generated agent protocol.** The generated Serverpod client gains the `AgentCitation` model, `AgentEvent.citations` and `AgentEvent.touchesTaxOrInvestment`, and `AgentMessage.citationsJson` and `AgentMessage.touchesTaxOrInvestment`, for the Money guide's server-checked citations.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #317](https://github.com/openbudgetfun/openbudget/pull/317)
- **Add conversationsLeft to the generated usage view.** The generated Serverpod client gains `AgentUsageView.conversationsLeft`, an estimate of how many typical Money guide conversations the remaining allowance covers, for the conversations-left line of the app.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #319](https://github.com/openbudgetfun/openbudget/pull/319)
- **Carry the tax rule version and coverage in the client protocol.** `TaxReportView` gains `rulesVersion`, `maturity` and `coverage`, matching the server view, so the app can show a pack's review state without recomputing it.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #277](https://github.com/openbudgetfun/openbudget/pull/277)
- **Add the ISO 3166 country dataset.** Every ISO 3166-1 country now carries reference facts in `openbudget_core/data/countries/<CC>.json` — English name, current currencies, IANA time zones and a `servable` flag — built from IANA tzdata 2026f and CLDR by `tool/bootstrap_country_data.dart`, and inlined as constants by `tool/generate_country_data.dart` (`--check` runs in CI). `Countries.byCode` exposes the dataset; `defaultTimeZone`, `timeZoneChoices` and `defaultFiscalYearEnd` read it. Results are unchanged for GB, US, NG and DE; other countries now default to their own zone and currency instead of `UTC`, and five placeholder sanctions targets (BY, CU, IR, KP, RU) are flagged `servable: false` pending counsel's answer to Q1. Tax-year and indirect-tax fields stay null until the U3–U5 research tasks fill them.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #273](https://github.com/openbudgetfun/openbudget/pull/273)
- **Fill tax years and indirect tax for Africa, the Middle East and Central Asia.** The 98 servable countries of Africa (including the Indian Ocean and Atlantic territories), the Middle East and Gulf, Central Asia, the Caucasus and the European countries outside the EU/EEA/OECD now carry their individual tax year, default company year end, VAT/GST/sales-tax rates (effective-dated), tax authority, graded sources, `verifiedOn`, `recheckBy` and caveats — task U5 of the tax jurisdictions plan, completing the U3/U4/U5 research pass: every servable ISO 3166-1 country now has research data. Non-Gregorian tax years are modelled with a `calendar` field and caveats: Ethiopia (1 Hamle–30 Sene, 8 July–7 July), Afghanistan (solar year, 21 March–20 March) and Saudi Arabia's Hijri zakat year. Rate changes since 2022 are effective-dated rows, never overwritten: Bahrain 5%→10%, Saudi 5%→15%, Botswana's temporary 12% cut, Kazakhstan 12%→16%, Uzbekistan 15%→12%, Tajikistan 15%→14% (→13% pre-recorded for 2027), Chad 18%→17.5%, Zimbabwe 15%→15.5%, Malawi 16.5%→17.5%, Liberia 10%→12%→13%, Ghana's levy restructuring and Montenegro's 2025 band. Countries with no VAT/GST (the Gulf non-adopters, Iraq, Syria, Libya, Afghanistan, Guernsey, Gibraltar, Greenland, Mayotte, St Helena, Eritrea, the Vatican and the uninhabited territories) use the schema's `none` kind with a source.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #281](https://github.com/openbudgetfun/openbudget/pull/281)
- **Fill tax years and indirect tax for the Americas and Asia-Pacific.** The 101 servable countries of the Americas and Asia-Pacific that task U3 did not cover now carry their individual tax year, default company year end, indirect-tax system, tax authority, graded sources, `verifiedOn`, `recheckBy` and caveats — task U4 of the tax jurisdictions plan, including the non-Gregorian tax years (Nepal's Bikram Sambat, Afghanistan's Solar Hijri) and every rate change since 2022 (Singapore's two GST steps, Indonesia's effective-11% 12%, Malaysia's 8% service tax, India's September 2025 slab reform, Pakistan, Sri Lanka, Laos, Vietnam's alternating 8%/10% windows, Fiji's rise-and-cut, Ecuador, Antigua, the Bahamas, Suriname's new VAT and more). The United States now carries all 51 state base sales-tax rates (with the New Mexico, South Dakota and Louisiana changes dated from primary sources) and Canada all 13 provincial GST/HST/PST/QST rates, including Nova Scotia's April 2025 HST cut. Twenty-nine territories with no broad consumption tax of their own record `kind: none` with caveats; the effective-dates test now covers subdivision rows per ISO 3166-2 code. Africa, the Middle East and Central Asia stay null until U5.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #280](https://github.com/openbudgetfun/openbudget/pull/280)
- **Fill tax years and indirect tax for EU, EEA and OECD countries.** The 44 EU, EEA and OECD members in `openbudget_core/data/countries/` now carry their individual tax year, default company year end, VAT/GST rates (standard, reduced and special tiers, effective-dated), tax authority, graded sources, `verifiedOn`, `recheckBy` and caveats — task U3 of the tax jurisdictions plan. EU rates are primary from the Commission's "VAT rates applied in EU member countries" table; national statutes or authority pages back GB, DE, FI, CH, CA, IS and NZ; the eleven authorities that block automated fetches carry secondary-graded rates and a caveat. Company year-end defaults now come from the data for these countries, so AU, NZ and JP default to 30 June / 31 March / 31 March instead of 31 December; GB keeps its existing 31 March default. Everything else stays null until U4 and U5.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #276](https://github.com/openbudgetfun/openbudget/pull/276)
- **Generic chart of accounts for countries without a tax pack.** `LedgerChartTemplate.forBooks` now falls back to a country-neutral, IFRS-style starter chart for sole-trader and company books in any country without a chart of its own, instead of returning nothing, so ledger mode works everywhere the later country batches add. The generic charts carry every system role the ledger machinery needs (including `bankClearing`) with no country-specific tax accounts beyond a generic indirect-tax control account, and the existing GB, US, NG and DE charts are byte-for-byte unchanged, pinned by snapshot tests.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #284](https://github.com/openbudgetfun/openbudget/pull/284)
- **Tax freshness tool and weekly re-check workflow.** `dart run openbudget_core:tax_freshness` lists every country whose tax reference data has reached its `recheckBy` date, with the verified-on date and the overdue day count (`--as-of YYYY-MM-DD` overrides the day; `--json` feeds automation; the exit code is 0 either way — overdue data is a work queue, not a build failure). A new scheduled workflow (`tax-freshness.yml`) runs the tool weekly, opens or updates one labelled GitHub issue per overdue country, and closes issues whose country is no longer overdue. It never runs on pull requests and is never a required check. Task C2 extends the report to rule-set caveats.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #287](https://github.com/openbudgetfun/openbudget/pull/287)

#### Add the tax pack manifest and rule-set contract

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #277](https://github.com/openbudgetfun/openbudget/pull/277)

`TaxRulePack` now declares a `TaxPackManifest` (maturity plus a coverage value for every `TaxSection`) and a per-year `TaxRuleSet` carrying the revision, sources and `verifiedOn` date. `TaxRuleSet.versionFor` produces the `gb-2026-r1` style version recorded on reports. The GB, US, NG and DE packs each ship a manifest, all `preview`, and reports carry `rulesVersion`, `maturity` and `coverage`.

The new `tax_pack_contract_test.dart` iterates every `TaxJurisdiction` and checks the manifest sections, the rule-set metadata, unique versions and the report fields for every supported year and entity kind.

#### Parse wallet addresses across every launch chain

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #274](https://github.com/openbudgetfun/openbudget/pull/274)

`openbudget_core` gains `WalletAddressParser.parse`, a pure-Dart parser that never throws and never touches the network. It covers Solana, Bitcoin (including `xpub`, `ypub` and `zpub` recognition from SLIP-132 version bytes only), EVM with EIP-55 checksums, Tron in Base58Check and 42-digit hex forms, and XRP Ledger classic and X-address forms.

The result is a Freezed sealed type: a match with one or more candidates, a refusal with a user-facing reason, or an invalid hint such as a checksum failure. A candidate carries the shared `ChainFamily` and the `WalletNetwork` values it can be read on, derived from `WalletNetworkRules`, so the parser adds no chain type of its own. Inputs are refused before anything leaves the device: recovery phrases, WIF and extended private keys, raw 64-byte keys, `0x` plus 64 hex digits, testnet Bitcoin, TON and X-address forms, multisig `Ypub` and `Zpub`, and X-addresses carrying a destination tag. `crypto` and `pointycastle` join the core dependencies.

- **Add `ObChainStamp` for wallet chains.** `ObChainStamp` letters a chain's name on a perforated postage stamp, beside `ObCurrencyStamp`. Each `ChainFamily` prints in one fixed spot ink (Bitcoin tangerine, EVM lilac, Solana teal, Tron pink, XRP Ledger sky, and the later families spread over the six inks), follows the day and night print runs, and is drawn with the Skribble pen, with no chain logos. A stamp is `inked` or an outline, with an optional detail line ("zpub", "+ 6") and a value line in tabular figures. `ObChainStampToggle` is the pickable variant: it inks while selected, has a 48 point touch target, and announces the chain and whether it is selected. State words for screen readers come from `ObChainStampWords`, so the app can localise them.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #304](https://github.com/openbudgetfun/openbudget/pull/304)

#### Make the Seeker dev runner safe to start and stop

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #266](https://github.com/openbudgetfun/openbudget/pull/266)

`devenv shell dev:seeker` now discovers the attached Android device (or uses `SEEKER_DEVICE_ID` when several are ready), starts the local stack, and probes the API port from the phone before choosing Tailscale, LAN, or USB forwarding. The runner lives in `openbudget_scripts`, so its address selection, device selection, endpoint fallback, stale-state cleanup, PID ownership checks, and early launch failures are unit tested.

- An explicit `OPENBUDGET_API_URL` is preserved and must be reachable from the device.
- Stale PID files, stale FIFOs, and stale flags are cleared before a new launch, and a failed Flutter launch prints the tail of its log before cleaning up.
- `dev:seeker` serializes concurrent start, stop, and restart per checkout, while status and reload stay available.
- `dev:seeker:stop` stops only the Flutter runner and FIFO holder this checkout can verify, removes only the `adb reverse` mappings it created on the recorded device, reuses preexisting mappings instead of overwriting them, and leaves shared Postgres, Redis, and Serverpod processes alone.
- Hot reload and hot restart write through a timeout-guarded control pipe, so a FIFO with no reader reports an error instead of hanging.

#### Add the landing page as `openbudget_site`

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #256](https://github.com/openbudgetfun/openbudget/pull/256)

A new workspace package renders the openbudget.app landing page with Jaspr in static mode. The page is set in the app's Skribble faces on the paper and night colourways from the brand guide. Its envelope desk is a small working budget: visitors drag or tap envelopes to fill them, watch full ones seal, and switch currencies to see the headline change. The desk runs on `web/site.js` (9 KB, no dependencies) and reads as a picture without JavaScript.

- `lib/site_config.dart` holds every outbound link. A download without a URL renders as a "Coming soon" stamp; giving it a URL makes the stamp a link on the next build.
- `dart run tool/build.dart` runs `jaspr build` with the sitemap domain from the config. It removes the `packages/`, `.dart_tool/` and `.build.manifest` files build_runner leaves beside the pages, and fails unless `index.html`, `404.html` and `sitemap.xml` exist. The output is about 250 KB.
- `dart run tool/render_images.dart` draws the favicon, the social card and the home-screen icon from `brand/`.
- The package README documents development, the build, and a Cloudflare Workers static-assets deploy with the `cf` CLI. Nothing deploys automatically.
- CI runs the site's `jaspr_test` suite alongside `openbudget_core`'s Dart tests.

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

#### Port the app screens onto the Skribble components

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #262](https://github.com/openbudgetfun/openbudget/pull/262)

Screens keep their providers, routes and data flow; only widgets, colours and layout change.

- The Add tab in the budget shell is a hot-pink sticker (`_AddSticker`) with a hard print shadow, and the Patrol page object finds it by its icon.
- The net worth summary, the budget header and the net worth hero are raised `ObCard` stickers with the teal overprint shadow.
- Chart series read `ObPalette.spots`, so charts use the same six spot inks as the badges and the landing page.
- Text on the highlighter takes `ObPalette.onHighlighter` on the login headline, the Plus price and the home "ready to assign" figure; before, they were chalk or a tone hue on sunflower in dark mode, which failed WCAG AA.
- Transaction rows move the cleared status chip into the row's chip strip beside "Unassigned", so neither chip truncates at 390pt and the amount stands alone like a ledger column.
- `ObToneChip` is tighter (7/9pt sides, a 7pt dot) so a dotted chip is no wider than the old bare chip.
- Every Skribble icon in a text field's `prefixIcon` or `suffixIcon` slot (47 across 23 files) is an `ObFieldIcon`, so the glyph sits centred inside the outline instead of on its top-left corner. A login test asserts both field icons sit inside the outline's inner rect.

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

#### Keep journal lines in entry order

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #286](https://github.com/openbudgetfun/openbudget/pull/286)

Journal lines used to come back in whatever order their UUID ids sorted in.
Ids are UUIDv7, so lines saved within the same millisecond sorted randomly
after the timestamp — a journal's lines could read back in a different order
than they were entered, and CI's ledger test flaked on it. `journal_line`
now carries a `lineNumber` (0-based, unique per journal) that every write
path assigns in caller order and every read orders by. The migration
backfills existing lines 0..n-1 per journal with no data loss.

#### Resolve IANA time-zone aliases such as Africa/Kampala

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #312](https://github.com/openbudgetfun/openbudget/pull/312)

`EntityClock` now loads the `timezone` package's `latest_all` database, which
retains IANA backward links, instead of the trimmed `latest` database that
dropped them. Every time zone listed in the generated country data resolves.

#### Build the server image from the workspace and apply migrations on start

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #242](https://github.com/openbudgetfun/openbudget/pull/242)

The server `Dockerfile` now narrows the root workspace to `openbudget_core`, `openbudget_lints` and `openbudget_server` before `dart pub get`, so the Dart-only build image no longer fails on the Flutter workspace members, and the committed `pubspec.lock` still pins every package. `.dockerignore` keeps `openbudget_lints` (a path dev dependency) and drops local `.dart_tool/` and `build/` output. The entrypoint passes `--apply-migrations`, so a new image never serves requests against an older schema.

- **Tax profiles keep every field the core profile defines.** The server filtered profile JSON through its own per-country key list before handing it to `TaxProfile.fromJson`, on save and on every read. Fields added to the core profiles since (UK accounting period end, associated companies and postgraduate loan; Nigeria's small-company ceiling and multinational-group flag; Germany's church-tax Land, Einkunftsart, children, pension, prior-year turnover and commute) were silently dropped. The list is gone: `TaxProfile.fromJson` is now the single definition of a profile's fields and parses strictly, throwing a `FormatException` that names the field for a wrong type, an unknown enum value, a negative count or an impossible year-end date. The server turns that into a `ValidationException`, and `toJson` still drops unknown keys.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #249](https://github.com/openbudgetfun/openbudget/pull/249)
- **Let `serverpod generate` run again.** `WalletRefreshFutureCall` exposed a public `run` method that returned a report, and Serverpod requires every future-call method to return `Future<void>`, so code generation failed. The refresh pass now lives in `WalletRefreshRunner`, and the future call keeps only `refresh`.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #318](https://github.com/openbudgetfun/openbudget/pull/318)

#### Bulgaria defaults to the euro

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #290](https://github.com/openbudgetfun/openbudget/pull/290)

New Bulgarian entities silently fell back to US dollars: `BG.json` still listed the lev (BGN) from the CLDR release-46 currency map, but `CurrencyCode` is generated from the ISO 4217 List One published by SIX on 2026-09-17, which no longer carries BGN, so the code could not parse and entity creation picked USD instead. Bulgaria replaced the lev with the euro on 1 January 2026 at the fixed rate BGN 1.95583 = EUR 1 (European Central Bank); the country file now lists EUR, with the source and a caveat recorded, and historical BGN amounts stay out of scope for the `currencies` field.

A regression test in `openbudget_core/test/countries/` now fails CI when any servable country's first currency is not a `CurrencyCode`, so the next stale code cannot ship.

#### Store country tax rates exactly and reject duplicate sources

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #283](https://github.com/openbudgetfun/openbudget/pull/283)

The country dataset's `IndirectTaxRate` now stores `ratePerMillion` (an exact integer in millionths of the taxed amount: 1% is `10 000`) instead of `basisPoints`, whose whole-hundredths-of-a-percent grid silently rounded fractional rates. Québec's 9.975% QST, Minnesota's 6.875%, Missouri's 4.225%, New Jersey's 6.625% and New Mexico's 5.125%/4.875% are exact again, and the caveats that apologised for the rounding are gone.

44 country files listed the same source more than once (112 duplicate entries, all identical in grade and retrieval date); each now keeps one entry, with the rate rows' `source` indices remapped. `CountryInfo.fromJson` rejects a repeated caveat or a repeated source and rejects unknown tax-year calendars, naming the country in each error — so the generator, CI's `--check` and the tests all fail loudly on the next duplicate.

`individualTaxYear.calendar` is now the `TaxYearCalendar` enum instead of a free string. Its JSON names are CLDR calendar identifiers (`gregorian`, `persian`, `ethiopic`, `islamic`, `islamic-umalqura`, …) plus `bikram-sambat` for Nepal, whose calendar has no CLDR identifier; `docs/tax-jurisdictions.md` section 8 documents the field and the schema.

- **Correct the Kenya petroleum band end date in its caveat.** The Kenya country file said the 8% petroleum VAT band was deleted "from 1 July 2027". The rate row and its source say 1 July 2023, so the caveat now says the same, and `country_data.g.dart` is regenerated.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #301](https://github.com/openbudgetfun/openbudget/pull/301)

### Refactoring

- **One tax profile form for every country.** The tax profile screen now renders the questions the entity's rule pack declares (`profileQuestions`) and no longer branches on a country: there is no `is GbTaxProfile`-style check left in the app, so a new country's pack gets its form without editing the screen. Labels, help text and choice options come from ARB through `taxQuestionLabel`, a resolver generated by `dart run tool/generate_tax_question_labels.dart` into `tax_question_labels.g.dart`; the tool fails when a pack names a key the ARB file lacks, `--check` runs in CI's lint job, and a contract test finds every declared key. The form keeps today's fields, grouping, save behaviour and stored JSON, shows a count or amount that does not parse as an inline error under its field with one shared message, and reads wide windows in a readable column. The old per-country strings the screen used are removed from `app_en.arb`. Widget tests fill every question of each pack and assert the saved profile JSON byte for byte, and a test fails if code under `lib/` checks for a country's profile class.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #303](https://github.com/openbudgetfun/openbudget/pull/303)
- **Profiles read and take answers, for the generic tax profile form.** `TaxProfile` gains `toAnswers()` and `withAnswers(answers)` so a form that knows only a pack's questions can edit any profile. By default the answers are the stored JSON and applying them decodes through the pack's `profileFromJson`, so the result is validated like any stored profile. Two profiles differ from their JSON: `UsTaxProfile` reads its `dependents` list as the three dependents questions (the counts under and over 17 and one SSN answer) and composes the list back from them, leaving the stored list untouched when those answers did not change so dependents with mixed SSN answers are not flattened by an unrelated save; `GbTaxProfile` includes the accounting period end it omits from JSON at the default. Stored JSON is unchanged.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #303](https://github.com/openbudgetfun/openbudget/pull/303)
- **Move the tax profiles into their rule packs.** `TaxProfile` is no longer sealed: each pack now owns its profile class, decoder and questions in `openbudget_core/lib/src/tax/<cc>/<cc>_profile.dart`, and `TaxRulePack` gains `profileFromJson` (which `TaxProfile.fromJson` delegates to, so the pack is the single definition of its stored fields) and `profileQuestions` (the questions the app asks to build a profile, as data). `TaxProfile` itself keeps the shared fields, the strict field readers and the question types. Stored JSON keeps today's shape: every fixture captured from the current serialisation round-trips byte-identically, and the two new tax-planning-guardrail questions (tax residence and US person) are stored only when answered, so profiles saved before them keep their exact bytes. The shared strict readers that were private to `tax_profile.dart` are now public (`taxProfileField` and friends), which is a breaking change for out-of-workspace code that reached into the file; nothing in the workspace did. The app still renders the hand-built per-country form until the generic form lands.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #298](https://github.com/openbudgetfun/openbudget/pull/298)

### Security

- **Privacy and cost guards for wallet providers.** Wallet provider failure paths no longer leak addresses, API keys, descriptors or request URLs in logs or error messages, and tests pin every outbound vendor request to the address, network and key. Each wallet sync and each hourly refresh run now logs one `wallet.vendor.requests vendor=<vendor> count=<n>` line per vendor, counted per operation, for the Bitcoin scale threshold. `docs/multichain-wallets.md` lists every vendor that receives wallet data, for the privacy notice.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #315](https://github.com/openbudgetfun/openbudget/pull/315)

### Testing

- **Keep More-screen Patrol flows off the live client.** The More screen's books entry reads the budget and tax profile, so the assistant and More-screen flows now answer those providers with local fixtures and assert the production Serverpod client is never created. A late connection attempt to the API can no longer fail a test after it passes.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #258](https://github.com/openbudgetfun/openbudget/pull/258)
- **Keep every test off the live API.** All `openbudget_app` widget and Patrol integration tests now install an HTTP guard from `openbudget_test_utils`: the moment a request tries to leave the test (including to `api.openbudget.app`) it throws a `StateError` naming the Serverpod endpoint inside the test that caused it. Un-guarded, such a request hung until the harness cancelled it and failed the run after completion (`SocketException: Connection attempt cancelled`), which flaked the `integration-test` CI job. The flows that still reached un-faked providers now answer them with local fixtures: the Plaid link fake covers `createLinkToken` on mobile targets, and the reporting-currency, cross-currency-transfer, net-worth-fx, settings and reports flows fake `userSettingsProvider`, `entityListProvider`, `netWorthForEntitiesProvider`, `netWorthHistoryProvider`, `institutionCatalogProvider` and `budgetMonthGroupsProvider`.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #282](https://github.com/openbudgetfun/openbudget/pull/282)
- **Add the Money guide eval harness.** `openbudget_server/test/money_guide/` gains the golden-file schema, a strict validator over `golden/*.yaml`, and a deterministic grader (tools called, citations resolved, no stripped citations, required facts, forbidden and never-suggest wording, and the refuse, signpost and qualify behaviours). The offline eval replays recorded model turns through the real `AgentService`, prompt, tools and citation resolver over a mock transport, so it runs in CI with no network. A `live_eval`-tagged test asks each golden question three times of the real model, grades each run, and writes a cost and pass-rate report to a gitignored path. `dart_test.yaml` skips the tag unless it is asked for by name. The provider key comes only from the environment (filled by Monosecret), and neither the key nor any message content is logged or written to the report.
  _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #320](https://github.com/openbudgetfun/openbudget/pull/320)

### Maintenance

#### Make git hooks work across linked worktrees

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #278](https://github.com/openbudgetfun/openbudget/pull/278)

`devenv` now installs the prek hook shims with a config path relative to the
repository toplevel instead of an absolute path into whichever worktree
entered the shell last. Commits in any worktree run that worktree's own
`.pre-commit-config.yaml` and hook tools, and deleting one worktree no longer
breaks the hooks of the others. The commit-time analyze gate now runs the
exact command CI's `analyze` job uses.
