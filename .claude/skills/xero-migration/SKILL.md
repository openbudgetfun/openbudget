---
name: xero-migration
description: Importing a Xero organisation into OpenBudget's ledger from its CSV, Excel and report exports (chart of accounts, contacts, trial balance, general ledger, invoices and bills, aged receivables and payables, conversion balances), plus post-migration bank feeds and statement files (OFX, QIF, CSV, CAMT.053, MT940) and receipt or e-invoice capture per country. Load before writing any Xero parser, importer, conversion-balance or migration-validation code, or any bank-statement or receipt ingestion code.
---

# Xero migration and ongoing data capture

Goal: a user leaves Xero and brings their books into OpenBudget's double-entry ledger with proof that nothing was lost, then keeps data flowing from banks, receipts and e-invoices. The importer reads files the user exports from their own Xero; the ledger rules it must satisfy are in the `double-entry-ledger` skill.

Today is 5 November 2026.

## Read this first: the Xero headers are unverified

The research could not read Xero Central or Xero developer article bodies. The column lists in `references/xero-exports.md` come from search snippets, third-party migration vendors and import-template samples. **Native Xero export headers are unverified.** Before any parser is finalised:

1. Capture real exports from a Xero **Demo Company** (fake data, safe to commit) for every export type in the list, in the UK, US and (if reachable) AU regional settings, in both Excel and CSV where offered.
2. Commit them as fixtures under `openbudget_core/test/fixtures/xero/<export>/<region>/` with the header row, plus a fixture-manifest recording the Xero release date seen, region, and how it was exported.
3. Write parsers against those fixtures. Never commit a real customer's export.

Until step 1 is done every parser is a draft and must say so in its doc comment.

## When to use

- Building or changing the Xero importer, its parsers, mapping tables or validation gates.
- Building the conversion (opening-balance) flow, Historical Adjustment handling, or migration progress UI.
- Building bank-feed adapters or statement-file import (OFX, QIF, CSV, CAMT.053, MT940).
- Building receipt, bill or e-invoice capture (XRechnung, ZUGFeRD, Peppol, OCR) for UK, US, Nigeria or Germany.

## Source-of-truth rules

- Every fact about a Xero file carries a quality tag in the references: P (official text read), S (secondary: vendor or adviser), I (inferred). Almost everything here is S or I. Do not promote any of it to settled without a fixture.
- **Map headers by name, never by position.** Normalise (strip a UTF-8 BOM, trim, strip a leading `*`, case-fold), match against an alias table per export, and **fail loudly** on an unknown layout: a missing required column or an unrecognised column set raises a typed error that lists the found headers. No silent skipping, no positional fallback.
- Treat account codes as strings. Excel strips leading zeros from exported chart codes.
- Amounts are integer minor units using the currency's exponent; Xero amounts are decimals in files, parse them as exact decimals, never `double`. Keep stated per-line tax amounts as given.
- Xero stores FX as foreign per base (6 decimals). Keep the source rate and its direction verbatim and treat the source base-currency amount as authoritative. Do not invert and re-round (see vector V5).
- The ledger must not be altered by a failed import: parse, map and validate in a staging area; post only after all hard gates pass or the user explicitly overrides a named gate.
- Do not hard-code Xero account codes. Identify system accounts by the `SystemAccount` attribute or type plus name, with a manual-confirm step. Codes vary by region and by organisation.
- Tax-rate names are free text per organisation. Map by an explicit mapping table (Xero name to local tax code), never by guessing from a percentage.
- **Xero developer terms prohibit using Xero API data to train or fine-tune AI or machine-learning models** (secondary source; bespoke single-client integrations reportedly exempt; verify in Xero's current terms before launch). OpenBudget has an AI agent: process Xero payloads only to import the user's own data. Do not log them into prompts, evaluations or training sets. File exports the user uploads are the user's data, but apply the same caution until the terms are read.
- Privacy: imported books contain personal data of the user's customers and suppliers. Do not send them to third-party services (OCR, analytics) without explicit confirmation; do not log row contents.

## Core rules

1. **Order matters.** Follow the import order in `references/import-order-and-validation.md`: settings, currencies, tax rates, tracking, chart, contacts, banks, one opening journal, open AR/AP documents, history, manual journals, attachments last.
2. **The trial balance is the anchor.** Use Xero's standard as-at Trial Balance, not "by date range" (it omits brought-forward balances). Post it as one journal dated the day before the conversion date.
3. **Never silence an imbalance.** Any difference goes to a visible Historical Adjustment account; the gate fails until a human reviews it.
4. **Invoices alone cannot rebuild the ledger.** The invoice export is line-level and its payment allocation is unconfirmed. The GL is the ledger source; invoices and bills supply documents and the AR/AP sub-ledger.
5. **Open items, not contact balances.** Import open invoices and bills from the Aged Detail so the sub-ledger ties to the control account.
6. **Hard gates:** journal balance, trial-balance match per account, AR and AP tie-out, bank balance tie-out, P&L and balance-sheet match for the last full period. Failure blocks posting unless overridden by name.
7. **After posting,** lock the ledger through the day before the conversion date and keep the import report (files, hashes, row counts, gate results) as an immutable artefact.
8. Ongoing statement import is idempotent: dedupe by bank transaction ID where one exists, otherwise by a hash that includes an occurrence index, and anchor to statement balances.
9. A received e-invoice's structured XML is kept as the original; capture never replaces it with an OCR reading.

## Where it lives in OpenBudget

- Pure parsers, alias tables, normalisation and validators: `openbudget_core/lib/src/ledger/import/xero/` (no Flutter, no server types). Statement-format parsers (OFX, QIF, CSV, CAMT.053, MT940) in `openbudget_core/lib/src/ledger/import/statements/`. Fixtures under `openbudget_core/test/fixtures/`.
- Staging models, import endpoint, posting orchestration: `openbudget_server/lib/src/ledger/import/` (`.spy.yaml` plus service), after the ledger core schema exists. One migration per PR.
- Bank-feed adapters behind a provider-agnostic `BankFeed` interface in the server; the file-import adapter is the baseline that works everywhere. Existing `plaid/` and `solana_wallets/` sync account data into `Account` directly; for ledger budgets they must write immutable statement lines instead (see the coexistence reference in `double-entry-ledger`).
- UI: `HookConsumerWidget`, `@riverpod` providers, `AppLocalizations` strings, Patrol E2E with the page-object pattern for the full import flow using fixture files.
- Keep fixture-derived expected values next to the fixtures, not inline in the parser.

## Testing

- Parser tests run against the committed Demo Company fixtures; add a fixture test per export type and per region. A test fails if a fixture's header row changes, so a Xero format change shows up in CI.
- Encode `references/test-vectors.md` (constructed examples, not Xero output). Tolerance is zero: every gate compares integer minor units. A documented rounding line is the only permitted difference.
- Negative tests: unknown header, missing required column, BOM, Excel-mangled dates and codes, mixed inclusive and exclusive amounts, an unbalanced trial balance, an unmatched aged total.
- Run `melos run test` and `melos run analyze`.

## Unverified and changing

Re-check each against a real Xero Demo Company export before the parser is finalised, and again before launch.

- All native export headers: Contacts export, Invoice and Bill export (and whether it shows currency, rate, payments, status), Credit note export, General Ledger Detail, Journal Report, Account Transactions, Aged Receivables and Payables Detail, Manual Journals, Fixed Asset register, Inventory, Tracking categories.
- Sign conventions, how voided and deleted documents appear, whether credit notes share the invoice export, and the GL representation of foreign-currency amounts.
- Date formats by region (assume the organisation's regional setting; take an explicit parameter).
- Default US chart system-account codes; the UK Historical Adjustment 840, Retained Earnings 960, Rounding 860 and Unrealised Currency Gains 498 codes are only partly verified.
- Whether report CSV export exists natively (sources conflict; Excel is confirmed).
- Xero developer plans, prices and limits (AUD, as of the sources: Starter free with 5 connections; Journals endpoint gated to Advanced; five-tier model effective 2 March 2026 per secondary sources). Check the live pricing page. Re-check the AI-training clause in the current developer terms.
- Supported statement formats for Xero's own import (OFX, QFX, QIF, PDF, CSV reported; MT940 and CAMT.053 not confirmed).
- Bank-feed providers: GoCardless Bank Account Data is closed to new sign-ups; Enable Banking, TrueLayer, Yapily, Tink, finAPI, Plaid and Mono terms, coverage and pricing were not read from primary sources. Mono's acquisition by Flutterwave was unconfirmed. Re-check before choosing a provider, and before 1 January 2027.
- E-invoice formats: EN 16931, ZUGFeRD, XRechnung and Peppol specifications were not fetched directly; Nigeria NRS clearance payloads were not read; UK and US capture requirements were not researched.

## References

- `references/xero-exports.md`: each export, known columns and quirks, system accounts, API alternative and its limits.
- `references/import-order-and-validation.md`: the import order, conversion balances, and the validation gates.
- `references/bank-feeds-and-statement-formats.md`: provider landscape, file formats, dedupe and anchoring.
- `references/receipt-and-einvoice-capture.md`: capture pipeline and per-country e-invoice inputs.
- `references/test-vectors.md`: constructed worked examples with expected outputs.
