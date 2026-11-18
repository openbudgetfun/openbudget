# Tax jurisdictions: from four countries to the world

Status: design, 13 November 2026.
Audience: the owner, and the implementation agents working through the build plan in [section 9](#9-build-plan).
Companion: [`money-guide.md`](money-guide.md), which designs the assistant that explains these rules.

OpenBudget computes full returns for the United Kingdom, the United States (federal), Nigeria and Germany. Each pack was built from a researched skill in `.claude/skills/`, and each lives in `openbudget_core/lib/src/tax/{gb,us,ng,de}/`. The owner asked for "all known tax jurisdictions". This document turns that into two tiers. There are full return calculations for the 20 largest economies OpenBudget can serve, and a universal layer for every other country. It fixes which countries are in, the contract every pack implements, the evidence a pack needs before it ships, what the universal layer stores and exports, and the order of the work.

Contents:

1. [Decisions at a glance](#1-decisions-at-a-glance)
2. [Two tiers](#2-two-tiers)
3. [The 20 countries](#3-the-20-countries)
4. [The country-pack contract](#4-the-country-pack-contract)
5. [The evidence bar](#5-the-evidence-bar)
6. [The pipeline for a new country](#6-the-pipeline-for-a-new-country)
7. [Keeping packs current](#7-keeping-packs-current)
8. [The universal layer](#8-the-universal-layer)
9. [Build plan](#9-build-plan)
10. [Risks and open questions](#10-risks-and-open-questions)

## 1. Decisions at a glance

1. **Two tiers.** Twenty countries get a full pack: computed returns, box-by-box checklists, opportunities and a filing calendar. Every other servable country gets the universal layer: entity defaults, VAT/GST/sales-tax rates, tax-tagged categories and an exportable tax-ready summary. Nigeria keeps its full pack as a 21st, maintained country.
2. **The 20** are the IMF's top 20 economies by nominal GDP. Russia is out because it is sanctioned, and China because it is very hard to serve. Poland and Taiwan, the next two, take their places. The UK, US and Germany are already built, which leaves 17 new packs.
3. **US state income tax is out.** The federal pack keeps detecting when a state return is likely and saying so. A sub-national tax is in when it is computed on the national return, and out when it is a separate return under its own law ([section 3.4](#34-sub-national-taxes)).
4. **One contract.** `TaxRulePack` grows to carry a manifest of what it covers, a versioned rule set with caveats, profile questions as data, a filing calendar, digital-asset rules and a map from universal categories. The four existing packs move onto it before any new country starts.
5. **Evidence before code.** Every pack starts as research that produces a skill: primary sources, test vectors, and an unverified list. Primary figures may compute anything. A secondary figure may compute a liability, but only with a visible caveat. Inferred, background and announced figures never compute. The unverified list is data that the app and the Money guide show.
6. **Maturity is visible.** A pack ships as `preview`. It becomes `reviewed` only after a qualified professional checks a year of its output. The four existing packs are `preview` today.
7. **The universal layer is generated core constants**, built from one checked-in JSON file per country. It is not a database table. It works offline at entity creation, it is reviewed in pull requests, and rate changes ship by Shorebird code push.
8. **The export is a ZIP of CSVs** behind a short-lived signed download link that the app opens with `url_launcher`. It adds no native dependency, so it needs no store release.
9. **Prepare only, as before.** No pack files anything. Direct filing stays a separate decision ([`accounting-roadmap.md`](accounting-roadmap.md)).

## 2. Two tiers

| Capability                                  | Full-pack country                                             | Universal-layer country                                                                                                                                    |
| ------------------------------------------- | ------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Entity defaults (currency, time zone, year) | Yes                                                           | Yes                                                                                                                                                        |
| Tax categories on lines and envelopes       | The pack's catalogue, each mapped to a return box             | The universal catalogue ([section 8.6](#86-universal-tax-categories))                                                                                      |
| VAT, GST or sales tax                       | Computed return by box, with schemes and thresholds           | Rates for reference, collected and paid totals by rate and quarter                                                                                         |
| Income and company tax                      | Computed liability, bands, credits, already-paid, balance due | Not computed                                                                                                                                               |
| Opportunities                               | Yes, under `tax-planning-guardrails`                          | None                                                                                                                                                       |
| Filing calendar                             | Computed deadlines with weekend and holiday roll-forward      | Tax-year start and end only                                                                                                                                |
| Crypto and capital gains                    | Gains under the country's own matching rules and exemptions   | Proceeds, cost and gain under a stated default method, with a caveat that local rules may differ                                                           |
| Tax-ready summary export                    | Yes                                                           | Yes                                                                                                                                                        |
| Money guide                                 | Rules, the user's figures and opportunities, cited            | Budgeting, the user's totals and universal facts. It declines country tax figures ([`money-guide.md`](money-guide.md#73-jurisdiction-states-and-refusals)) |

A country can also be **unserved**: comprehensively sanctioned, or blocked by counsel. It appears in no picker ([section 8.8](#88-countries-we-do-not-serve)).

## 3. The 20 countries

### 3.1 Method

Start from the IMF World Economic Outlook, October 2026 edition: 2025 nominal GDP in US dollars ([IMF DataMapper, NGDPD](https://www.imf.org/external/datamapper/NGDPD@WEO); ranked table read from [Worldometer's copy of that edition](https://www.worldometers.info/gdp/gdp-by-country/imf-2025-nominal-worldwide/) on 13 November 2026). Then apply three tests:

1. **Legal.** No comprehensive or sectoral sanctions that stop us serving residents or taking their payments.
2. **Practical.** The app stores list OpenBudget there, at least one payment rail works (store billing, Stripe or Solana USDC), we can lawfully hold residents' financial data on our servers, and an AI feature needs no prior licence.
3. **Meaningful.** Residents or small businesses file returns that our entity kinds (`individual`, `soleTrader`, `company`) map onto.

A country that fails test 1 or 2 is replaced by the next country in the ranking that passes all three.

### 3.2 The ranking and the verdicts

| Rank | Country        | 2025 GDP (US$) | Verdict                                                                |
| ---- | -------------- | -------------- | ---------------------------------------------------------------------- |
| 1    | United States  | 30.86tn        | **In**, built (federal)                                                |
| 2    | China          | 19.63tn        | **Out**, very hard ([section 3.3](#33-exclusions-and-hard-cases))      |
| 3    | Germany        | 5.12tn         | **In**, built                                                          |
| 4    | Japan          | 4.45tn         | **In**                                                                 |
| 5    | United Kingdom | 4.01tn         | **In**, built                                                          |
| 6    | India          | 3.91tn         | **In**                                                                 |
| 7    | France         | 3.38tn         | **In**                                                                 |
| 8    | Russia         | 2.57tn         | **Out**, sanctioned                                                    |
| 9    | Italy          | 2.55tn         | **In**                                                                 |
| 10   | Canada         | 2.32tn         | **In**, with provinces except Quebec's own return at first             |
| 11   | Brazil         | 2.28tn         | **In**                                                                 |
| 12   | Spain          | 1.91tn         | **In**, with the autonomous-community scales                           |
| 13   | South Korea    | 1.88tn         | **In**                                                                 |
| 14   | Australia      | 1.84tn         | **In**                                                                 |
| 15   | Mexico         | 1.84tn         | **In**                                                                 |
| 16   | Türkiye        | 1.60tn         | **In**                                                                 |
| 17   | Indonesia      | 1.45tn         | **In**                                                                 |
| 18   | Netherlands    | 1.32tn         | **In**                                                                 |
| 19   | Saudi Arabia   | 1.27tn         | **In**, business-led ([section 3.3](#33-exclusions-and-hard-cases))    |
| 20   | Switzerland    | 1.06tn         | **In**, with cantons ([section 3.3](#33-exclusions-and-hard-cases))    |
| 21   | Poland         | 1.04tn         | **In**, replaces China                                                 |
| 22   | Taiwan         | 0.92tn         | **In**, replaces Russia                                                |
| 23   | Belgium        | 0.73tn         | First alternate                                                        |
| 24   | Argentina      | 0.68tn         | Second alternate                                                       |
| 25   | Ireland        | 0.68tn         | Third alternate, the obvious pick if the owner prefers English sources |

Ranks 20 and 21 swap between editions: the October 2025 edition put Poland 20th and Switzerland 21st. Both are in, so the set does not depend on the edition. Nigeria (not in the top 25) keeps its pack and its maintenance, outside the 20.

### 3.3 Exclusions and hard cases

The facts below come from background knowledge and press. Each country's research task (T1) must confirm them from primary sources before any code depends on them.

- **Russia: out.** UK, EU and US sanctions, and none of our payment rails (Apple and Google billing, Stripe) work for Russian residents. Universal-layer data exists, with `servable: false` until counsel decides ([section 8.8](#88-countries-we-do-not-serve)).
- **China: out, very hard.** Personal financial information is sensitive personal information under PIPL, so holding it outside China needs a security assessment, a standard contract or certification. Apps in the China storefront need an MIIT filing. Public generative-AI services need a CAC filing. Google Play and Plaid are absent. Revisit only with a local partner. China stays in the universal layer, so someone keeping Chinese books from outside China can still use it, but the app is not distributed in the China storefront.
- **Saudi Arabia: in, business-led.** Individuals pay no personal income tax on employment income, so the personal-return section is `notApplicable`, with a short explainer card. The pack's weight is in business taxes: zakat for Saudi- and GCC-owned shares, corporate income tax for foreign-owned shares, VAT and withholding tax. Research must settle how zakat is computed on a Gregorian financial year against the Hijri year.
- **Switzerland: in, with cantons.** The return is cantonal: each of the 26 cantons assesses its own tax and the federal direct tax together, and about 2,100 communes apply their own multiplier. The pack ships the federal tax plus the six most populous cantons (Zurich, Bern, Vaud, Aargau, St. Gallen, Geneva), which hold more than half of residents. The commune multiplier is a profile input. Each further canton is one table task. In an unsupported canton, the personal and company sections fall back to the universal layer, and VAT stays full.
- **Taiwan: in.** It is listed as "Taiwan" in the country picker, as the app stores list it. The primary sources are in Traditional Chinese.
- **Türkiye: in.** High inflation brings yearly bracket revaluation and inflation-adjusted company accounts. Research must check how often figures change during a year.
- **Netherlands: in.** The Box 3 regime for savings and investments has been in transition since the Supreme Court rulings. Box 3 ships `partial`, with caveats, until a stable system is enacted.
- **South Korea: in.** Virtual-asset income tax has been deferred more than once. Research records its status as an `announced` caveat, and it never computes until enacted.
- **India: in.** Research must confirm whether the Income-tax Act 2025 replaces the 1961 Act for years starting 1 April 2026. If it does, the pack carries both regimes keyed by year, the way the Nigeria pack handles its 2026 change.
- **Brazil: in.** The consumption-tax reform (CBS and IBS replacing PIS, COFINS, ICMS and ISS) phases in over several years, and personal income tax changed for 2026. It is the highest-churn pack, so it is built last in its batch.

### 3.4 Sub-national taxes

**Rule:** a sub-national tax is in when the national return computes it, or when the return most residents file cannot be completed without it. A sub-national tax with its own return under its own law is out.

| Country       | Sub-national tax                                                    | Decision                                                                                |
| ------------- | ------------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| United States | 41 states and DC with wage income tax, plus local taxes             | **Out.** Detection only, as the `us-federal-tax` skill already says.                    |
| Canada        | Provincial and territorial tax on the T1; Quebec files its own TP-1 | **In** for the provinces on the T1. Quebec's TP-1 is a separate task in the same batch. |
| Spain         | Autonomous-community half of the IRPF scale                         | **In.** The Basque Country and Navarre (foral regimes) are `signpostOnly`.              |
| Italy         | Regional and municipal surcharges                                   | **In.** Regional rates are tables; the municipal rate is a profile input.               |
| Switzerland   | Cantonal and communal tax on the cantonal return                    | **In** for six cantons first ([section 3.3](#33-exclusions-and-hard-cases)).            |
| Japan         | Resident tax computed from the national return figures              | **In.**                                                                                 |
| South Korea   | Local income tax as a share of the national tax                     | **In.**                                                                                 |

US state income tax stays out for four reasons:

- 42 separate regimes, each with its own conformity to federal changes.
- Local taxes in New York City, Ohio municipalities and Pennsylvania.
- About forty more packs to keep current every year.
- Nine states have no wage income tax at all.

State sales-tax base rates are in the universal layer as subdivision data. Revisit after batch B2 with usage data. If it comes back, California and New York go first.

### 3.5 Build order

| Batch  | Countries, in order                              | Why this batch, and this place in the order                                                                                                                                                                                                           |
| ------ | ------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **B1** | Australia, Canada, India                         | English primary sources and common-law shapes the GB and US packs already use: withholding plus self-assessment, and a GST that looks like VAT. Australia is the simplest. India has the most crypto users and the most complexity.                   |
| **B2** | France, Italy, Spain, Poland, Netherlands        | One shared EU VAT layer (reverse charge, intra-community supplies, OSS) serves all five and Germany. The Netherlands goes last because Box 3 is still moving.                                                                                         |
| **B3** | Japan, South Korea, Taiwan, Switzerland          | Sources outside the Latin script, and stricter reservations of tax advice to licensed professionals (research to confirm; see [`money-guide.md`](money-guide.md#74-reusing-tax-planning-guardrails)). Switzerland's cantons are the largest data job. |
| **B4** | Mexico, Brazil, Indonesia, Türkiye, Saudi Arabia | The most regulatory churn: Brazil's reform, Türkiye's inflation and Saudi zakat. Mexico goes first because it reuses B2's Spanish-language review.                                                                                                    |

Research for batch N+1 runs while batch N is coded ([section 9.1](#91-milestones)).

## 4. The country-pack contract

### 4.1 What a pack is

A pack is pure Dart in `openbudget_core/lib/src/tax/<cc>/`, with no Flutter or server dependency. The same input always gives the same report. The server, the app and the Money guide all compute with it, so a figure never differs between a report and an answer. New packs use this file layout; the four existing packs keep theirs until a task touches them.

```text
openbudget_core/lib/src/tax/<cc>/
  <cc>_tax_rules.dart        the pack: implements TaxRulePack and wires the sections
  <cc>_tables.dart           one TaxRuleSet and one typed table per supported year
  <cc>_profile.dart          the profile class, its JSON and its questions
  <cc>_categories.dart       categories with return references and the universal map
  <cc>_personal.dart         personal return
  <cc>_self_employment.dart  self-employment profit and contributions
  <cc>_company.dart          company return
  <cc>_indirect.dart         VAT, GST or sales tax return
  <cc>_gains.dart            capital gains and digital assets
  <cc>_calendar.dart         filing and payment deadlines
  <cc>_opportunities.dart    opportunities under tax-planning-guardrails
openbudget_core/test/tax/<cc>/  one test file per section, named after the skill's vector ids
```

### 4.2 The interface

`TaxRulePack` keeps its current members and gains the ones marked new. The sketch below is the contract; names may be adjusted to match surrounding code when the task lands.

```dart
abstract interface class TaxRulePack {
  TaxJurisdiction get jurisdiction;

  /// New. What this pack covers, per section, and how mature it is.
  TaxPackManifest get manifest;

  Set<int> get supportedStartYears;
  TaxYear taxYearFor(DateTime date);
  TaxYear taxYear(int startYear);

  /// New. Version, sources, verified-on date, caveats and named figures for
  /// one year. Throws UnsupportedTaxYearException like taxYear.
  TaxRuleSet ruleSet(int startYear);

  /// New. Decodes this pack's profile; TaxProfile.fromJson delegates here.
  TaxProfile profileFromJson(Map<String, Object?> json, EntityKind kind);

  /// New. The questions the app asks to build the profile, as data.
  List<TaxProfileQuestion> profileQuestions(EntityKind kind);

  List<TaxCategory> categoriesFor(EntityKind kind);
  TaxCategory? category(String code);

  /// New. Universal category code to this pack's code, per entity kind.
  String? mapUniversalCategory(String universalCode, EntityKind kind);

  TaxReport report(TaxInput input);
  List<TaxOpportunity> opportunities(TaxInput input, TaxReport report);

  /// New. Filing and payment deadlines for one year and profile.
  List<TaxDeadline> deadlines(TaxYear year, TaxProfile profile);

  /// New. How disposals and income from digital assets are treated.
  DigitalAssetRules digitalAssetRules(int startYear, EntityKind kind);
}

enum TaxSection {
  personalReturn,
  selfEmployment,
  companyReturn,
  indirectTax,
  capitalGains,
  digitalAssets,
  filingCalendar,
  payroll,
}

enum TaxSectionCoverage { full, partial, signpostOnly, notApplicable, notBuilt }

enum TaxPackMaturity { preview, reviewed }

@immutable
final class TaxPackManifest {
  const TaxPackManifest({
    required this.maturity,
    required this.sections,
    this.regimes = const [],
  });

  final TaxPackMaturity maturity;
  final Map<TaxSection, TaxSectionCoverage> sections;

  /// Country-specific regimes an entity kind can elect, such as France's
  /// micro-entrepreneur regime or Italy's regime forfettario.
  final List<TaxRegime> regimes;
}

@immutable
final class TaxRuleSet {
  const TaxRuleSet({
    required this.startYear,
    required this.revision,
    required this.verifiedOn,
    required this.sources,
    this.caveats = const [],
    this.figures = const {},
    this.provisional = false,
  });

  final int startYear;

  /// Bumped whenever any figure in the year changes.
  final int revision;
  final DateTime verifiedOn;
  final List<TaxSource> sources;
  final List<TaxRuleCaveat> caveats;

  /// Named figures that knowledge cards quote, such as
  /// `personalAllowance`. One source for both a report and an answer.
  final Map<String, TaxFigure> figures;

  /// True when the year reuses the previous year's figures because the
  /// authority has not published new ones yet (section 7).
  final bool provisional;

  /// Recorded on reports, exports and proposals: `gb-2026-r3`.
  String versionFor(TaxJurisdiction jurisdiction) =>
      '${jurisdiction.countryCode.toLowerCase()}-$startYear-r$revision';
}
```

`TaxJurisdiction` stays an enum and gains one value per pack. Exhaustive switches in `TaxRules.forJurisdiction` and in chart-template selection then fail to compile until a pack is fully wired, which is the check we want. `TaxReport` and `TaxReportView` gain `rulesVersion`, `maturity`, `coverage` and `caveats`. `TaxReportLine` gains `section`, so the app can group lines by return section.

### 4.3 Sections

| Section          | A `full` section must produce                                                                                                                                                   |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `personalReturn` | Taxable income by source, allowances, bands, credits, sub-national tax where [section 3.4](#34-sub-national-taxes) puts it in, tax already paid, balance due, return references |
| `selfEmployment` | Profit under the country's basis (cash or accruals), allowances, social contributions on self-employment, and the figures the personal return takes                             |
| `companyReturn`  | Taxable profit for an accounting period, rate periods and straddles, reliefs, the corporate tax and its payment dates                                                           |
| `indirectTax`    | Return boxes per period, registration threshold check, the schemes the pack supports, and output and input tax from line data                                                   |
| `capitalGains`   | Gains under the country's matching rules, exemptions, allowances, loss rules and rates                                                                                          |
| `digitalAssets`  | `DigitalAssetRules` ([section 4.8](#48-digital-assets-and-capital-gains)) and their effect on the report                                                                        |
| `filingCalendar` | Every return and payment deadline for each entity kind, rolled forward by the country's rule                                                                                    |
| `payroll`        | Out of scope for this program; `notBuilt` everywhere except where the accounting roadmap builds it                                                                              |

`partial` means the section computes, but the manifest names what it leaves out, and a caveat says so in the report. `signpostOnly` means the pack explains and points to a professional, and computes nothing. `notApplicable` means the tax does not exist for that entity kind there (Saudi personal income tax). The manifest is what the app shows on the tax overview, and what the Money guide reads to decide what it may answer.

### 4.4 Entity kinds and regimes

| `EntityKind` | Sections computed                                                          | Notes                                                                                                                         |
| ------------ | -------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `individual` | `personalReturn`, `capitalGains`, `digitalAssets`                          | Linked sole trades feed in through `TaxInput.linked`, as today.                                                               |
| `soleTrader` | `selfEmployment`, `indirectTax`                                            | Its profit lands on the linked individual's personal return. Its own report shows the business schedule and the indirect tax. |
| `company`    | `companyReturn`, `indirectTax`, company `capitalGains` and `digitalAssets` | It is assessed on accounting periods from the entity's financial year end, never on the personal tax year.                    |

The three kinds stay. Country legal forms and regimes are a `regime` choice on the profile, declared by the pack as `TaxRegime` data. Examples: France's micro-entrepreneur versus réel, Italy's forfettario versus ordinario, India's presumptive schemes, Japan's blue versus white return, Brazil's MEI and Simples Nacional, Germany's Freiberufler versus Gewerbe (today's `einkunftsArt`), and a US S corporation election. Partnerships and trusts are out of scope. A pack marks them `signpostOnly` in its explainer.

Every pack's profile also asks two common questions that the guardrails require before any lever: whether the person is tax resident in the country, and whether they are a US person.

### 4.5 Tax years, accounting periods and versions

- **Individual tax year:** fixed per pack (`taxYear(startYear)`), with the authority's label (`2026/27`, `2026`, `FY2027`). `startYear` remains the key of every table.
- **Company periods:** the entity's financial year end defines the accounting period. The pack splits a period across rate years where rates changed, as the GB pack must do for the 1 April financial year.
- **Versions:** a `TaxRuleSet` per year carries `revision`. Any change to a figure of a published year bumps it, with a developer changeset saying what changed. Reports, exports and proposals record `rulesVersion` (`AgentProposal.rulesVersion` already exists). A closed year is never edited silently.
- **Unsupported years** throw `UnsupportedTaxYearException`, as today. The app shows "rules for 2027 are not in yet", and the universal summary still works.

### 4.6 Profiles as data

The current `tax_profile_screen.dart` is about 1,000 lines of hand-built per-country branches, and that does not scale to 21 countries. Packs declare questions instead, and the app renders one generic form.

```dart
sealed class TaxProfileQuestion {
  const TaxProfileQuestion({
    required this.key,
    required this.labelKey,
    this.helpKey,
    this.appliesTo = const {
      EntityKind.individual,
      EntityKind.soleTrader,
      EntityKind.company,
    },
    this.visibleWhen,
  });

  /// The JSON field the answer is stored under.
  final String key;

  /// ARB keys, named `taxQ<Cc><Field>` (for example `taxQGbScottishTaxpayer`).
  final String labelKey;
  final String? helpKey;
  final Set<EntityKind> appliesTo;

  /// Shown only when another answer has a given value.
  final TaxProfileCondition? visibleWhen;
}

final class TaxBoolQuestion extends TaxProfileQuestion { ... }
final class TaxChoiceQuestion extends TaxProfileQuestion { ... } // options with ARB keys
final class TaxMoneyQuestion extends TaxProfileQuestion { ... }  // minor units, pack currency
final class TaxCountQuestion extends TaxProfileQuestion { ... }
final class TaxMonthDayQuestion extends TaxProfileQuestion { ... }
```

All user-visible strings come from `AppLocalizations`. Because gen-l10n has no lookup by key, the app gets a small generated resolver (`tax_question_labels.g.dart`) built from every ARB key that starts with `taxQ`. A contract test asserts that every key a pack declares exists in `app_en.arb`. Stored profile JSON keeps its current shape, so existing profiles still parse. Narrative text the pack computes (assumptions, caveats, opportunity explanations) stays core English text for now, as it is today. That gap is already recorded as an audit finding in the accounting roadmap.

`TaxProfile` stops being `sealed`. Each profile class lives in its pack folder, and `TaxProfile.fromJson` delegates to `TaxRules.forJurisdiction(...).profileFromJson`. The contract test round-trips every pack's profile JSON.

### 4.7 Categories and the universal map

Pack categories stay as they are: codes prefixed by country (`fr.se.frais_de_deplacement`), labels in the authority's own language, and a `reportReference` box. Each pack also maps the universal catalogue onto its own codes, so a line tagged before the pack existed (or in another entity) lands in the right box. When a line carries a universal code, the report uses the mapped code. The server accepts universal codes on every entity ([section 8.6](#86-universal-tax-categories)).

### 4.8 Digital assets and capital gains

Crypto is where OpenBudget's wallets meet tax law, so this section is part of the contract, not an add-on.

```dart
@immutable
final class DigitalAssetRules {
  const DigitalAssetRules({
    required this.disposalTreatment, // capital, income or exemptAfterHolding
    required this.costBasis,          // fifo, averageCost, ukShareMatching, specificIdentification
    this.exemptAfterDays,             // a holding-period exemption
    this.annualExemptAmountMinor,
    this.freigrenzeMinor,             // an exemption that is lost once exceeded
    this.lossesRingFenced = false,    // losses offset only digital-asset gains
    this.flatRateBasisPoints,
    required this.staking,            // incomeOnReceipt, capitalOnDisposal or signpost
    required this.airdrops,
    required this.mining,
    this.caveats = const [],
  });
  ...
}
```

A pure lot engine in `openbudget_core/lib/src/tax/assets/` matches disposals to acquisitions by each method. It keeps quantities as `BigInt` base units and money as integer minor units in the entity's base currency. The server feeds it from `wallet_transaction` rows and crypto account transactions. Each pack turns the engine's matched disposals into report lines under its own rules. Where data is missing (an unpriced token, an unknown cost, a transfer between the user's own wallets that looks like a disposal), the report carries a caveat and counts the affected rows. It never guesses.

### 4.9 What does not change

`TaxInput`, `TaxEntry`, integer minor units, basis-point rates, round-down slices, `TaxOpportunity` (with the guardrail fields [`money-guide.md`](money-guide.md#74-reusing-tax-planning-guardrails) adds), the server's `TaxService` flow, and prepare-only filing.

## 5. The evidence bar

### 5.1 Grades

Every figure, rule and deadline in a skill and in a table carries the grade the existing skills already use:

- **[P] primary:** statute, official gazette, the authority's own page, form or instructions, or the authority's published calculator or worked example.
- **[S] secondary:** a Big Four or law-firm summary, a reputable tax publisher, or an intergovernmental compilation (OECD, EU) for figures it does not itself enact.
- **[I] inferred:** derived by the researcher from P or S material, or a design inference.
- **[B] background:** known but not fetched in this research.
- **announced:** published as policy and not yet law. It is a flag that sits on top of a grade.

### 5.2 What each grade may do

| Grade     | Computes a liability     | Computes an opportunity saving | Shown to the user                               |
| --------- | ------------------------ | ------------------------------ | ----------------------------------------------- |
| P         | Yes                      | Yes                            | Source link and verified-on date                |
| S         | Yes, with a caveat       | No                             | "From a secondary source" badge on the line     |
| I or B    | No; marks "needs review" | No                             | The caveat, and the line shows no figure        |
| announced | Never                    | Never                          | "Announced, not yet law" with the expected date |

A pack reaches `reviewed` only when every figure its `full` sections use is P.

### 5.3 Test vectors

Each skill's `references/test-vectors.md` carries numbered vectors, and the tests encode every one with zero tolerance unless the vector states one. For each section and each supported year, the minimum is:

- a zero or below-threshold case;
- both sides of every band edge, threshold and taper, to one minor unit;
- a typical case and a high-income case;
- one case per regime the pack supports;
- at least one **official** vector where the authority publishes a calculator or worked example (HMRC, BMF, ATO and CRA all do). Its source and the date it was run go in the vector.

Vectors are computed twice by the researcher, once by hand from the formula and once with independent integer arithmetic, before any pack code exists. That is the method the German skill used. The cross-pack contract test (`openbudget_core/test/tax/tax_pack_contract_test.dart`) checks that:

- every `TaxJurisdiction` has a pack and every pack's sections match its manifest;
- category codes carry the country prefix and are unique;
- every universal code maps or is declared unmapped;
- every `TaxRuleSet` has sources, a `verifiedOn` date and unique caveat ids, and every caveat has a `recheckBy` date;
- profile JSON round-trips and every question's ARB key exists;
- reports are deterministic;
- deadlines never fall on a rest day the pack knows.

### 5.4 The unverified list in the product

The skill's "Unverified and changing" section is the researcher's reasoning. The pack's `TaxRuleCaveat` rows are what the product shows:

```dart
@immutable
final class TaxRuleCaveat {
  const TaxRuleCaveat({
    required this.id,          // `nl.box3.2026-regime`
    required this.text,        // one plain sentence
    required this.grade,
    required this.affects,     // sections and figure ids
    required this.recheckBy,
    this.announced = false,
  });
  ...
}
```

- The report screen gets a "What we could not verify" section listing the caveats that touch the sections and figures the report used. Lines computed from S figures carry a badge.
- A `preview` pack shows a banner: "Preview: these figures have not yet been checked by a tax professional."
- Tool results and MCP payloads carry the caveats, so an external agent sees them too.
- The Money guide must mention any caveat that touches a figure it quotes ([`money-guide.md`](money-guide.md#73-jurisdiction-states-and-refusals)).

### 5.5 Maturity

`preview` is the shipping state for every new pack. `reviewed` needs a qualified professional in the country to check one year of output for each entity kind the pack covers, against real or realistic books. The owner records it, not an agent, by setting the manifest's maturity in a reviewed pull request that names the reviewer's qualification (never the person). The four existing packs move to `preview` in task C1. This is the honest reading of the roadmap's "a qualified professional should review the first year".

## 6. The pipeline for a new country

Every country goes through the same five steps. Each step is a task in [section 9.5](#95-the-country-task-template).

1. **Research → skill.** A research agent writes `.claude/skills/<country>-tax/`. It holds a `SKILL.md` with the core rules, a "Where it lives" section and an "Unverified and changing" section, and references for:
   - rates and allowances per year;
   - the return form map;
   - self-employment;
   - company tax;
   - indirect tax;
   - capital gains and crypto;
   - the filing calendar;
   - the advice perimeter (who may give tax advice there);
   - test vectors.

   Figures come from primary sources first and carry grades, and the research date is stated. No pack code is written in this step.
2. **Tables, profile, categories, calendar.** The pack skeleton: `TaxRuleSet` and typed tables for the current and previous year, the profile and its questions, categories with return references and the universal map, the chart-of-accounts template, deadlines, and a `preview` manifest.
3. **Computation.** One task per section group, each encoding the skill's vectors as tests.
4. **Money guide.** Knowledge cards from the skill, a perimeter card, and at least 20 golden questions that pass the eval ([`money-guide.md`](money-guide.md#8-evaluation)).
5. **Professional review** (owner): `preview` → `reviewed`.

Load the new skill before touching that country's code, as the root `CLAUDE.md` requires for the existing ones.

## 7. Keeping packs current

- **Every year table must exist before its year starts**, or as soon as the authority publishes the figures. Each skill records its country's annual cycle and when next year's figures appear (for example: IRS inflation adjustments each autumn, the UK Budget each autumn, India's Union Budget on 1 February, Australia's Budget in May). One "add `<cc>` `<year>` tables" task per country per year is a standing, well-scoped task: research the delta, add the table, add vectors, then bump revisions where needed.
- **Provisional years.** When a year starts before its figures are published, a pack may add a `provisional` rule set that repeats the previous year's figures. It is labelled "provisional: uses 2026 figures" on every screen, export and Money guide answer, and is replaced as soon as figures exist. It is never silent.
- **Mid-year changes** (an emergency budget, a court ruling) get a revision bump and a caveat while they settle.
- **`recheckBy` dates drive the work.** A scheduled GitHub workflow runs weekly. It runs `dart run openbudget_core:tax_freshness`, which reads every `recheckBy` in the country data and in every rule set, and opens or updates one issue per country listing what is overdue. It is not a PR check: a test that fails on the calendar would break unrelated pull requests.
- **In the app**, a report whose `verifiedOn` is more than 12 months old shows "rules last checked on …" in amber.
- **Cost:** about 21 tasks a year for the year tables, plus re-checks. They suit the cheapest implementation rung once the researcher has written the delta into the skill.

## 8. The universal layer

### 8.1 What it holds

For every ISO 3166-1 country:

- English name, `servable` flag, currencies (the first is the default), time zones (the first is the default);
- the individual tax year (start month and day, and the calendar it follows) and the default company year end;
- indirect tax: kind (`vat`, `gst`, `salesTax`, `consumptionTax`, `none`), local name, exact rates with labels and effective dates, the registration threshold when known, the default return frequency, and optional subdivision rates;
- the tax authority's name and URL;
- sources, grades, `verifiedOn`, `recheckBy` and caveats.

### 8.2 Storage: generated core constants, not a table

| Option                                       | For                                                                                                                                | Against                                                                                                   |
| -------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| **Generated constants in `openbudget_core`** | Works offline at entity creation; core logic (`defaultFiscalYearEnd`) reads it; reviewed in PRs; deterministic tests; no migration | A rate change needs a release, but Dart-only changes ship by Shorebird code push and server deploy        |
| Postgres reference table                     | Hot updates                                                                                                                        | A migration, admin tooling, an app fetch before entity creation, and two sources of truth with core logic |

**Decision: generated constants.** Effective dates let a known future rate change land ahead of time, so a release is rarely urgent.

Layout:

```text
openbudget_core/data/countries/<CC>.json      one file per country, the source of truth
openbudget_core/data/iso4217.json             ISO 4217 list (SIX), for CurrencyCode
openbudget_core/tool/generate_country_data.dart
openbudget_core/lib/src/countries/country_info.dart       CountryInfo, IndirectTaxInfo, Countries.byCode
openbudget_core/lib/src/countries/country_data.g.dart     generated, committed
```

One file per country keeps diffs small, lets research tasks run in parallel without merge conflicts, and gives each country one obvious place to fix. The generator has a `--check` mode, run by CI, that fails when the generated Dart is out of date. `defaultTimeZone`, `timeZoneChoices` and `defaultFiscalYearEnd` become lookups into this data, with unchanged results for GB, US, NG and DE.

### 8.3 Country file format

Illustrative values, not research:

```json
{
  "code": "XX",
  "name": "Example Republic",
  "servable": true,
  "currencies": ["XXC"],
  "timeZones": ["Region/City"],
  "individualTaxYear": {
    "startMonth": 1,
    "startDay": 1,
    "calendar": "gregorian"
  },
  "companyYearEndDefault": { "month": 12, "day": 31 },
  "indirectTax": {
    "kind": "vat",
    "localName": "Value Added Tax",
    "rates": [
      {
        "label": "standard",
        "ratePerMillion": 160000,
        "from": "2020-01-01",
        "source": 0
      },
      {
        "label": "reduced",
        "ratePerMillion": 80000,
        "from": "2020-01-01",
        "appliesTo": "food and medicines",
        "source": 0
      }
    ],
    "registrationThreshold": {
      "amountMinor": 500000000,
      "currency": "XXC",
      "period": "rolling12Months",
      "source": 1
    },
    "returnFrequency": "monthly",
    "subdivisions": []
  },
  "authority": {
    "name": "Example Revenue Authority",
    "url": "https://revenue.example"
  },
  "sources": [
    {
      "title": "VAT Act, section 5",
      "url": "https://revenue.example/vat-act",
      "grade": "primary",
      "retrievedOn": "2026-11-20"
    },
    {
      "title": "Registration guide",
      "url": "https://revenue.example/register",
      "grade": "primary",
      "retrievedOn": "2026-11-20"
    }
  ],
  "verifiedOn": "2026-11-20",
  "recheckBy": "2027-07-01",
  "caveats": []
}
```

- `calendar` is a CLDR calendar identifier (`gregorian` for almost every country; `persian`, `ethiopic`, `islamic`, `islamic-umalqura`, and so on), and the schema rejects unknown values. Nepal's Bikram Sambat has no CLDR identifier, so it is spelled `bikram-sambat`. Some countries' tax years follow another calendar (Iran, Nepal, Ethiopia, Afghanistan). For those the entity's Gregorian `fiscalYearEnd` is the nearest approximation, with a caveat on screen. None of the 20 needs this.
- `ratePerMillion` is the exact rate as an integer in millionths of the taxed amount: 1% is `10000`, so fractional rates such as Québec's 9.975% QST (`99750`) or Minnesota's 6.875% sales tax (`68750`) are never rounded. A source and grade back every rate, and a source appears in `sources` once only — the parser rejects a repeated caveat or source and fails the generator and CI.
- `subdivisions` carries ISO 3166-2 codes with their own rates: US state sales-tax base rates, Canadian provincial GST/HST/PST, Indian state codes where they matter. Local rates (US counties and cities) are out: the user enters the rate on the receipt.
- `CurrencyCode` grows from 27 values to every active ISO 4217 currency, generated from `iso4217.json`. BTC stays. The FX provider (currencyapi.com) prices most of them. A currency it does not price works as a base currency, and cross-currency writes ask for a manual rate through the existing `FxRateUnavailableException` path.

### 8.4 Sources

| Field                    | Source, in order of preference                                                                                                        |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------- |
| Country list and names   | ISO 3166-1 via the IANA tz `iso3166.tab` [P]                                                                                          |
| Currencies and exponents | ISO 4217 list published by SIX, the maintenance agency [P]                                                                            |
| Time zones               | IANA tz database `zone.tab` [P], plus a short hand-kept list of defaults for countries with several zones                             |
| Tax years                | The tax authority [P]; otherwise a secondary compilation [S]                                                                          |
| EU VAT rates             | The European Commission's published table of VAT rates in the member states [P]; where it and a national VAT act differ, the act wins |
| OECD members' rates      | OECD Consumption Tax Trends tables [S], confirmed against the authority [P] where reachable                                           |
| Everyone else            | The tax authority [P]; a Big Four indirect-tax guide or the PwC Worldwide Tax Summaries as [S] when the authority is unreachable      |

Take facts only, cite them, and copy no prose. Every S field carries a caveat, and the app shows "from a secondary source" next to it.

### 8.5 Freshness

- Each country has a `recheckBy` date: at most 12 months away, and earlier when a known change is coming. The weekly freshness workflow ([section 7](#7-keeping-packs-current)) reports overdue countries by region.
- A standing task per region per half-year re-verifies the rates of the countries that are overdue. It suits a cheap research agent, with a diff of what changed in the PR body.
- Rates are effective-dated, never overwritten. A change adds a row with `from`, and the old row gains `to`. Exports of past years therefore use the rates that applied then.

### 8.6 Universal tax categories

A country-neutral catalogue in `openbudget_core/lib/src/tax/universal/`, with codes prefixed `universal.`:

- **Income:** employment, self-employment turnover, interest, dividends, rent, pensions, capital gains, digital-asset disposals, digital-asset income (staking, mining, airdrops), other.
- **Business expenses:** cost of goods, office, rent, utilities, phone and internet, software, travel, vehicle, meals, professional fees, insurance, equipment, wages, bank fees, marketing, training, other.
- **Reliefs and contributions:** pension, charitable gifts, medical, education, childcare, mortgage interest, social contributions.
- **Tax paid:** income tax withheld, tax instalments, VAT/GST paid on purchases, VAT/GST collected on sales.
- **Out of scope:** transfers, loans, gifts received, owner capital and drawings.

The server accepts universal codes on every entity. Entities in a country with no pack use only these. Each pack maps them to its own codes ([section 4.7](#47-categories-and-the-universal-map)). Labels are ARB keys.

### 8.7 Tax-ready summary export

`TaxSummaryService` builds one `TaxSummaryView` for any entity and year. A pack country uses the pack's tax year; any other country uses the universal tax year, or the entity's financial year for companies. It holds:

- a header: entity kind, country, base currency, period, generated-at time, `rulesVersion` (pack countries) or `verifiedOn` (universal), and the disclaimer key;
- totals by category for income, expenses (after business-use share), reliefs and tax paid;
- VAT/GST collected and paid, by rate and by quarter, from `salesTaxMinor` on lines;
- digital assets per wallet: proceeds, cost, gain, the matching method used, and the caveats;
- FX notes: lines converted from another currency, the rate sources used, and manual rates;
- the count of uncategorised lines.

**Export:** `tax.createExportLink(entityId, startYear)` returns a URL with a signed token. The token is an HMAC over user, entity, year and expiry, valid for 10 minutes, and needs no table. A Relic web route serves a ZIP containing:

- `summary.csv`: the view above;
- `lines.csv`: every transaction line in the period, with date, payee, description, amount and currency, base amount, FX rate, rate date and rate source, category code and label, business-use share, sales tax, and envelope;
- `README.txt`: what each column means, the FX method, the rules version and the disclaimer.

Amounts are decimal strings at the currency's exponent, never floats. A test asserts that `lines.csv` sums to `summary.csv`. The app opens the link with `url_launcher`, which it already depends on, so the feature needs no native change and no store release. A PDF summary for accountants is a later task.

### 8.8 Countries we do not serve

The `servable` flag hides a country from every picker and blocks entity creation there. Which countries are blocked is a legal decision for counsel ([section 10](#10-risks-and-open-questions), Q1). Until counsel answers, the default list is the jurisdictions under comprehensive UK, EU or US sanctions on the day we ship, plus Russia and Belarus, which are under broad sectoral sanctions.

## 9. Build plan

### 9.1 Milestones

| Milestone | Scope                                                             | Tasks   | Research tasks | Depends on                                          | Specs                                                                    |
| --------- | ----------------------------------------------------------------- | ------- | -------------- | --------------------------------------------------- | ------------------------------------------------------------------------ |
| **M1**    | Universal layer                                                   | 12      | 3              | none                                                | [section 9.3](#93-m1-universal-layer)                                    |
| **M2**    | Pack contract v2 on GB, US, NG, DE                                | 9       | 1              | none; runs in parallel with M1                      | [section 9.4](#94-m2-pack-contract-v2)                                   |
| **M3**    | Money guide v1 on GB, US, NG, DE and the universal layer          | 13      | 4              | Starts after C1 and C2; G7 also needs U8, C5 and C9 | [`money-guide.md` section 10](money-guide.md#10-build-plan-milestone-m3) |
| **M4**    | Batch B1: Australia, Canada, India                                | 21      | 4              | M2 complete; each T6 needs M3                       | [section 9.6](#96-m4-to-m7-the-country-batches)                          |
| **M5**    | Batch B2: EU VAT layer, France, Italy, Spain, Poland, Netherlands | 33      | 7              | M2; each T6 needs M3                                | [section 9.6](#96-m4-to-m7-the-country-batches)                          |
| **M6**    | Batch B3: Japan, South Korea, Taiwan, Switzerland                 | 27      | 6              | M2; each T6 needs M3                                | [section 9.6](#96-m4-to-m7-the-country-batches)                          |
| **M7**    | Batch B4: Mexico, Brazil, Indonesia, Türkiye, Saudi Arabia        | 32      | 6              | M2; each T6 needs M3                                | [section 9.6](#96-m4-to-m7-the-country-batches)                          |
|           | **Total**                                                         | **147** | **31**         |                                                     |                                                                          |

Order and parallelism:

- M1 and M2 run side by side. M3 starts once C1 and C2 land.
- Within a batch, the countries are independent, so their tasks may run in parallel. Their only shared files are the `TaxJurisdiction` enum, the `TaxRules` registry and `app_en.arb`, which make small, mechanical merges.
- A batch's T1 research tasks may start while the batch before it is being coded.

### 9.2 How every task runs

- One task is one pull request on a `feat/`, `fix/`, `docs/` or `test/` branch. It carries a developer changeset, and a user changeset too when people will notice the change ([root `CLAUDE.md`](../CLAUDE.md)).
- Load the country skill and `tax-planning-guardrails` before any tax or assistant code, as the root `CLAUDE.md` requires.
- **[R] research tasks** produce a skill or data files with sources and grades, and no product code. Their acceptance criteria: every figure graded, every claim sourced, an "Unverified and changing" list with re-check dates, and test vectors computed twice. A research agent keeps personal data out of every search query.
- Every code task ends green on its listed test command, plus `melos run analyze` and `dprint check`. App-facing tasks also pass their widget tests and the named Patrol flow. Server tests need Postgres (`devenv up`).
- At most one Serverpod migration per task, and only where the task says so.

### 9.3 M1: universal layer

**U1. Every ISO 4217 currency.**

- Goal: generate `CurrencyCode` from the ISO 4217 list, with exponents and symbols, and keep the existing 27 names and BTC unchanged.
- Files: `openbudget_core/data/iso4217.json`, `openbudget_core/tool/generate_currencies.dart`, `openbudget_core/lib/src/constants/currencies.dart` (generated), `openbudget_core/test/constants/currencies_test.dart`.
- Acceptance:
  - every active ISO 4217 code parses, with the published exponent (0, 2 or 3);
  - the existing codes are unchanged;
  - the generator's `--check` mode passes in CI;
  - a test lists the currencies currencyapi.com does not price, and none of them blocks entity creation.
- Test: `cd openbudget_core && dart test test/constants/`.

**U2. Country dataset, schema and generator.**

- Goal: one JSON file per ISO 3166-1 country with the mechanical fields (name, currencies, time zones from `zone.tab`, `servable` from a placeholder list pending Q1), a generator, and `Countries.byCode`. Rewire `defaultTimeZone`, `timeZoneChoices` and `defaultFiscalYearEnd` to read it.
- Files: `openbudget_core/data/countries/*.json`, `openbudget_core/tool/generate_country_data.dart`, `openbudget_core/lib/src/countries/`, `openbudget_core/lib/src/time/default_time_zone.dart`, `openbudget_core/lib/src/tax/fiscal_year.dart`, tests.
- Acceptance:
  - every code in `iso3166.tab` has a file that passes the schema test;
  - multi-zone countries default to the hand-kept list;
  - GB, US, NG and DE give exactly today's defaults;
  - tax-year and indirect-tax fields may be null until U3 to U5 fill them;
  - `--check` runs in CI.
- Test: `cd openbudget_core && dart test test/countries/ test/tax/`.

**U3 [R]. Tax years and indirect tax: EU, EEA, OECD.**

- Goal: fill `individualTaxYear`, `companyYearEndDefault`, `indirectTax`, `authority`, `sources`, `verifiedOn`, `recheckBy` and `caveats` for every EU, EEA and OECD member.
- Files: `openbudget_core/data/countries/<CC>.json` for those countries.
- Acceptance:
  - every field is sourced and graded, and EU rates are P from the Commission's table;
  - the PR body lists each S or I field;
  - the schema test passes.
- Test: `cd openbudget_core && dart test test/countries/`.

**U4 [R]. Tax years and indirect tax: the Americas and Asia-Pacific (not already covered).**

- As U3, for those countries, including US state and Canadian provincial subdivision rates.

**U5 [R]. Tax years and indirect tax: Africa, the Middle East and Central Asia.**

- As U3, for those countries, including the non-Gregorian tax years with their caveats.

**U6. Universal tax categories.**

- Goal: the universal catalogue, server validation that accepts universal codes on every entity, the category list for entities without a pack, and pack mapping of universal codes in reports (the `mapUniversalCategory` member of [section 4.2](#42-the-interface), added for GB, US, NG and DE).
- Files: `openbudget_core/lib/src/tax/universal/`, `openbudget_core/lib/src/tax/tax_rule_pack.dart`, the four packs' category files, `openbudget_server/lib/src/tax/tax_catalogue_validation.dart`, `openbudget_server/lib/src/tax/tax_service.dart`, `app_en.arb` (category labels).
- Acceptance:
  - a Kenyan individual can tag lines and envelopes;
  - a GB sole trader's line tagged `universal.expense.software` lands in the GB report under its mapped code;
  - unmapped universal codes count as uncategorised, with a caveat.
- Test: `cd openbudget_core && dart test test/tax/` and `cd openbudget_server && dart test test/tax/`.

**U7. Generic chart-of-accounts template.**

- Goal: a country-neutral ledger chart for sole traders and companies in countries without a pack, so ledger mode works anywhere.
- Files: `openbudget_core/lib/src/ledger/chart_of_accounts.dart`, tests.
- Acceptance: `LedgerChartTemplate.forBooks` returns the generic template for any country without a pack; every `LedgerSystemRole` is present, including `bankClearing`.
- Test: `cd openbudget_core && dart test test/ledger/`.

**U8. Tax-ready summary service.**

- Goal: `TaxSummaryService.build` and the `tax.getSummary(entityId, startYear)` endpoint, as in [section 8.7](#87-tax-ready-summary-export). It adds no table and no migration.
- Files: `openbudget_server/lib/src/tax/tax_summary_service.dart`, `tax_summary_view.spy.yaml` and its nested views, `tax_endpoint.dart`, `openbudget_server/test/tax/tax_summary_test.dart`.
- Acceptance:
  - correct totals for a seeded Kenyan individual and a GB sole trader with foreign-currency and VAT lines;
  - business-use share applied;
  - wallet disposals shown with their method and caveat;
  - ownership enforced.
- Test: `cd openbudget_server && dart test test/tax/tax_summary_test.dart`.

**U9. Export download.**

- Goal: `tax.createExportLink`, the signed-token Relic route and the ZIP of `summary.csv`, `lines.csv` and `README.txt`.
- Files: `openbudget_server/lib/src/tax/export/`, server route registration, the `archive` package on the server, tests.
- Acceptance:
  - the token expires after 10 minutes and is bound to user and entity;
  - another user's token is rejected;
  - `lines.csv` sums to `summary.csv`;
  - amounts are decimal strings at the currency exponent;
  - the URL carries no personal data.
- Test: `cd openbudget_server && dart test test/tax/export/`.

**U10. Create an entity in any country.**

- Goal: a searchable country picker over servable countries and a searchable currency picker, with defaults from the data.
- Files: `openbudget_app/lib/src/features/home/screens/create_entity_screen.dart`, a picker sheet in `openbudget_ui`, `app_en.arb`, widget tests, `openbudget_app/integration_test/create_entity_any_country_flow_test.dart` (page objects in `common/patrol_helpers.dart`).
- Acceptance:
  - creating a Kenyan individual fills KES, `Africa/Nairobi` and the Kenyan tax year;
  - an unservable country is absent;
  - the Patrol flow passes.
- Test: `cd openbudget_app && flutter test test/features/home/` and `PATROL_TEST_GLOB=integration_test/create_entity_any_country_flow_test.dart ./tools/run_patrol_integration_tests.sh`.

**U11. Universal tax panel and export button.**

- Goal: the tax overview for an entity without a pack shows the tax year, the indirect-tax rates with source and grade badges, a link to the authority, the summary totals (U8), and "Export tax summary" (U9). This replaces today's "no tax rules" error.
- Files: `openbudget_app/lib/src/features/tax/`, `app_en.arb`, widget tests, Patrol flow `tax_export_flow_test.dart`.
- Acceptance:
  - a Kenyan entity shows the panel;
  - the export opens the signed URL;
  - S-graded rates show the badge;
  - a GB entity's screen is unchanged apart from the new export button.
- Test: `cd openbudget_app && flutter test test/features/tax/` and the Patrol flow.
- User changeset: yes.

**U12. Freshness workflow.**

- Goal: `dart run openbudget_core:tax_freshness` lists overdue `recheckBy` dates, and a scheduled weekly workflow opens or updates one issue per country. C2 extends it to rule-set caveats.
- Files: `openbudget_core/bin/tax_freshness.dart`, `.github/workflows/tax-freshness.yml`, tests for the date logic.
- Acceptance: a dry run on a fixture with past dates reports them; the workflow only reads and writes issues, never blocks PRs.
- Test: `cd openbudget_core && dart test test/tools/tax_freshness_test.dart`.

### 9.4 M2: pack contract v2

**C1. Manifest, maturity and rules version.**

- Goal: `TaxPackManifest`, `TaxSection`, `TaxSectionCoverage`, `TaxPackMaturity` and `TaxRuleSet` (version, sources, `verifiedOn`); a manifest for each of the four packs, all `preview`; `rulesVersion`, `maturity` and `coverage` on `TaxReport` and `TaxReportView`; and `AgentProposal.rulesVersion` set on tax proposals.
- Files: `openbudget_core/lib/src/tax/{tax_rule_pack,tax_model}.dart`, the four packs, `openbudget_server/lib/src/tax/tax_report_view.spy.yaml`, `tax_service.dart`, `openbudget_server/lib/src/agent/agent_proposal_service.dart`, `openbudget_core/test/tax/tax_pack_contract_test.dart`, and a preview banner on the app's tax overview.
- Acceptance:
  - the contract test covers every `TaxJurisdiction`;
  - every report carries `gb-2026-r1` style versions;
  - tax proposals store it;
  - the app shows the preview banner.
- Test: `cd openbudget_core && dart test test/tax/`, `cd openbudget_server && dart test test/tax/ test/agent/` and `cd openbudget_app && flutter test test/features/tax/`.

**C2. Caveats and named figures as data.**

- Goal: `TaxRuleCaveat` and `TaxFigure` in each `TaxRuleSet`. Port the "Unverified and changing" lists of `uk-personal-tax`, `uk-company-tax`, `uk-vat-payroll`, `us-federal-tax`, `nigeria-tax` and `germany-tax` into caveats, and name the figures that knowledge cards will quote. The report carries the caveats it touched, the app gains a "What we could not verify" section, and the freshness tool reads caveats.
- Files: the four packs' table files, `tax_model.dart`, `tax_report_view.spy.yaml`, app tax widgets, `openbudget_core/bin/tax_freshness.dart`.
- Acceptance:
  - every caveat has an id, a grade and a `recheckBy` date;
  - a GB report that uses the student-loan rules lists the student-loan caveats and no German ones;
  - S-graded lines show a badge.
- Test: as C1.

**C3. Profiles through the pack.**

- Goal: `profileFromJson` and `profileQuestions` on every pack; profile classes move into their pack folders; `TaxProfile` stops being `sealed`; the common residence and US-person questions are added. JSON stays byte-compatible.
- Files: `openbudget_core/lib/src/tax/tax_profile.dart`, `<cc>/<cc>_profile.dart` for each pack, tests with stored JSON fixtures from today's shape.
- Acceptance: every fixture round-trips unchanged; questions cover every field the current screen edits.
- Test: `cd openbudget_core && dart test test/tax/`.

**C4. Generic tax profile form.**

- Goal: the app renders `profileQuestions` and stops branching per country. It uses a generated `taxQ*` label resolver.
- Files: `openbudget_app/lib/src/features/tax/screens/tax_profile_screen.dart`, a generator under `openbudget_app/tool/`, `tax_question_labels.g.dart`, `app_en.arb`, widget tests per pack, and `openbudget_app/integration_test/tax_flow_test.dart`.
- Acceptance:
  - each of the four countries edits and saves every field it does today;
  - no `is GbTaxProfile` style checks remain in the app;
  - the contract test finds every declared ARB key.
- Test: `cd openbudget_app && flutter test test/features/tax/` and `PATROL_TEST_GLOB=integration_test/tax_flow_test.dart ./tools/run_patrol_integration_tests.sh`.

**C5. Filing calendar.**

- Goal: `TaxDeadline` and `deadlines()` for the four packs, taken from their skills (DE already has the §149 and §108 AO logic), a `tax.listDeadlines(entityId)` endpoint, and an "Upcoming" list on the tax overview.
- Files: `openbudget_core/lib/src/tax/{tax_model,<cc>/<cc>_calendar}.dart`, `tax_endpoint.dart`, app tax widgets, tests.
- Acceptance: every deadline named in the four skills appears with its source; the DE roll-forward vectors pass; `tax_flow_test.dart` checks the "Upcoming" list.
- Test: `cd openbudget_core && dart test test/tax/`, `cd openbudget_app && flutter test test/features/tax/` and `PATROL_TEST_GLOB=integration_test/tax_flow_test.dart ./tools/run_patrol_integration_tests.sh`.

**C6 [R]. Crypto tax research for GB, US, DE and NG.**

- Goal: a new `crypto-tax` skill with one reference per country. It covers:
  - disposal events;
  - cost-basis method;
  - holding periods and exemptions;
  - allowances;
  - losses;
  - staking, mining, airdrops, DeFi and NFTs;
  - record-keeping;
  - reporting regimes;
  - lot-matching test vectors.
- Files: `.claude/skills/crypto-tax/`.
- Acceptance: the general research bar ([section 9.2](#92-how-every-task-runs)); each country has at least 8 lot-matching vectors, including UK same-day and 30-day matching and the German holding-period exemption edge.

**C7. Lot engine.**

- Goal: a pure matching engine (`fifo`, `averageCost`, `ukShareMatching`, `specificIdentification`) with holding-period tracking.
- Files: `openbudget_core/lib/src/tax/assets/`, `openbudget_core/test/tax/assets/`.
- Acceptance: every C6 vector passes with zero tolerance; quantities stay `BigInt`; money stays integer minor units.
- Test: `cd openbudget_core && dart test test/tax/assets/`.

**C8. Digital-asset rules in the four packs.**

- Goal: `DigitalAssetRules` per pack and year, and gains and income lines in reports from the engine's output.
- Files: the four packs' `_gains.dart`, tests.
- Acceptance: the C6 country vectors pass end to end through `report()`; staking income lands in the right section; ring-fenced losses do not offset other gains (NG).
- Test: `cd openbudget_core && dart test test/tax/`.

**C9. Wallets into tax.**

- Goal: build acquisitions and disposals from `wallet_transaction` rows and crypto account transactions, run the pack's method, and compute `WalletTaxYearSummary` through the engine. Add caveats for unpriced, unknown-cost or self-transfer rows.
- Files: `openbudget_server/lib/src/wallets/`, `openbudget_server/lib/src/tax/tax_service.dart`, tests.
- Acceptance:
  - a seeded Solana wallet with a swap, a stake reward and a transfer to the user's own second wallet gives the vector's gain;
  - the self-transfer is not a disposal;
  - an unpriced token is counted and named.
- Test: `cd openbudget_server && dart test test/wallets/ test/tax/`.

### 9.5 The country task template

Every country in M4 to M7 runs these tasks in order. `<cc>` is the lower-case ISO code; `<country>-tax` is the skill name (`australia-tax`, `japan-tax`).

**T1 [R]. Research → skill.**

- Goal: `.claude/skills/<country>-tax/`, with the contents in [section 6](#6-the-pipeline-for-a-new-country), for the current and previous tax year.
- Acceptance:
  - the research bar ([section 9.2](#92-how-every-task-runs));
  - test vectors that meet [section 5.3](#53-test-vectors), with at least one official vector per computed section where the authority publishes one;
  - a perimeter reference saying whether tax advice is reserved to licensed professionals there, graded and dated;
  - a recommended section coverage for the manifest.
- Split into T1a (personal, self-employment, gains and crypto) and T1b (company, indirect, calendar, perimeter) where this plan says so.

**T2. Pack skeleton.**

- Goal:
  - the `TaxJurisdiction` value and registry wiring;
  - `TaxRuleSet` and typed tables for both years;
  - tax years and labels;
  - the profile, its questions and their ARB labels;
  - categories with return references and the universal map;
  - the chart-of-accounts template;
  - the `preview` manifest;
  - the deadlines.
- Files: `openbudget_core/lib/src/tax/<cc>/`, `tax_model.dart`, `tax_rules.dart`, `chart_of_accounts.dart`, `app_en.arb`, `openbudget_core/test/tax/<cc>/`.
- Acceptance: the contract test passes for the country; the calendar vectors pass; a profile can be saved in the app through the generic form.
- Test: `cd openbudget_core && dart test test/tax/` and `cd openbudget_app && flutter test test/features/tax/`.

**T3. Personal return and self-employment.**

- Goal: `personalReturn` and `selfEmployment`, including the linked sole-trade flow, the regimes, the sub-national tax this plan puts in, and opportunities with guardrail fields and neutral wording.
- Acceptance: every personal and self-employment vector passes; the wording lint passes; caveated figures behave as [section 5.2](#52-what-each-grade-may-do) says.
- Test: `cd openbudget_core && dart test test/tax/<cc>/`.

**T4. Company return and indirect tax.**

- Goal: `companyReturn` on accounting periods, and `indirectTax` return boxes per period with threshold checks.
- Acceptance: every company and indirect-tax vector passes; straddle periods are tested.
- Test: `cd openbudget_core && dart test test/tax/<cc>/`.

**T5. Capital gains and digital assets.**

- Goal: `capitalGains` and `DigitalAssetRules` for the country on the C7 engine.
- Acceptance: every gains and crypto vector passes through `report()`.
- Test: `cd openbudget_core && dart test test/tax/<cc>/`.

**T6. Money guide for the country.**

- Goal: knowledge cards from the skill (figures as placeholders into the pack's named figures), a perimeter card, the country's never-suggest additions, and at least 20 golden questions; then run the eval until it passes ([`money-guide.md`](money-guide.md#8-evaluation)).
- Files: `openbudget_server/knowledge/<cc>/`, `openbudget_server/test/money_guide/golden/<cc>.yaml`, and the country's entry in the core guidance perimeter data.
- Acceptance: the eval thresholds are met, and the eval report (pass rate and cost) is in the PR body.
- Test: `cd openbudget_server && dart test test/money_guide/` (offline) and the live eval command in `money-guide.md`.

**Owner step, not an agent task:** professional review, then `preview` → `reviewed`.

### 9.6 M4 to M7: the country batches

| Milestone   | Tasks, in order                                                        | Count | Extras beyond the six-task template                                                                                                                                                                                                                                                                      |
| ----------- | ---------------------------------------------------------------------- | ----- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **M4 (B1)** | AU T1–T6; CA T1–T6, CA T3b; IN T1a, T1b, T2–T6, IN T3b                 | 21    | **CA T3b:** Quebec's TP-1 as its own return for Quebec residents. **IN T1b:** the research split. **IN T3b:** the old and new regimes side by side, and the Act transition if research confirms it.                                                                                                      |
| **M5 (B2)** | E1; FR T1a, T1b, T2–T6; IT T1–T6; ES T1–T6, ES T3b; PL T1–T6; NL T1–T6 | 33    | **E1 [R+code]:** the EU VAT layer in `openbudget_core/lib/src/tax/eu/` (reverse charge, intra-community supplies and acquisitions, OSS, rates read from universal data); DE's VAT moves onto it. **FR T1b:** the research split. **ES T3b:** the 15 common-regime autonomous-community scales as tables. |
| **M6 (B3)** | JP T1a, T1b, T2–T6; KR T1–T6; TW T1–T6; CH T1a, T1b, T2–T6, CH T3b     | 27    | **JP T1b** and **CH T1b:** the research splits. **CH T3b:** cantonal tables for Zurich, Bern, Vaud, Aargau, St. Gallen and Geneva, with the commune multiplier as a profile input.                                                                                                                       |
| **M7 (B4)** | MX T1–T6; BR T1a, T1b, T2–T6, BR T4b; ID T1–T6; TR T1–T6; SA T1–T6     | 32    | **BR T1b:** the research split. **BR T4b:** the consumption-tax reform's transition years. SA's T3 is small: individuals are `notApplicable`, and sole proprietors get zakat.                                                                                                                            |

Research tasks per milestone, as counted in [section 9.1](#91-milestones):

- **M4: 4.** AU T1, CA T1, IN T1a and IN T1b.
- **M5: 7.** E1, FR T1a, FR T1b, and T1 for IT, ES, PL and NL.
- **M6: 6.** JP T1a, JP T1b, KR T1, TW T1, CH T1a and CH T1b.
- **M7: 6.** MX T1, BR T1a, BR T1b, and T1 for ID, TR and SA.

## 10. Risks and open questions

### Risks

1. **Maintenance outgrows the build.** Twenty-one packs need about 21 year-table tasks a year, plus mid-year changes, plus Money guide cards. If the freshness workflow's issues go unworked, packs drift silently. Mitigation: the `recheckBy` issues, amber "last checked" labels, and provisional years that say so. Budget a standing slice of each month for upkeep before starting the next batch.
2. **Advice-perimeter law.** Germany reserves individual tax advice (StBerG §5), and research is expected to find similar reservations elsewhere, Japan and France among them. A strong Money guide on the wrong side of such a law is a legal risk, not a bug. Mitigation: a perimeter card per country, `signpostOnly` sections where law requires, and counsel review before each country's guide goes live.
3. **Professional review is the bottleneck.** `reviewed` needs a qualified person per country. Without one, a country stays `preview` indefinitely. That is honest, but it caps what we can claim.

### Open questions for the owner

| #  | Question                                                                                                            | Default if not answered                                                                   |
| -- | ------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| Q1 | Which jurisdictions does OpenBudget block outright? It depends on where the company is incorporated and on counsel. | Comprehensive UK, EU or US sanctions targets on the day we ship, plus Russia and Belarus. |
| Q2 | Is Taiwan acceptable as the 20th, or should Ireland (English sources, euro, many expats) take its place?            | Taiwan, by the ranking rule.                                                              |
| Q3 | Who reviews each pack professionally, and is a paid review per country in budget?                                   | Packs ship as `preview` until a review happens.                                           |
| Q4 | Should US state income tax return once the batches are done, starting with California and New York?                 | No; revisit after B2 with usage data.                                                     |
