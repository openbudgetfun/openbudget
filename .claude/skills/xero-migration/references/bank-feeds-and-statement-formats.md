# Bank feeds and statement formats

Tags: **S** secondary (vendor, comparison blog, news), **I** inferred, **K** general knowledge not in the research notes (verify against the format specification). No provider pricing here was read from a primary source; check live pricing pages before choosing.

## 1. Provider landscape (as of November 2026, secondary sources)

- **GoCardless Bank Account Data** (formerly Nordigen): the official page says new sign-ups are disabled; a user relaying support reports only enterprise access in future (unconfirmed). Do not plan on it. [S] https://bankaccountdata.gocardless.com/new-signups-disabled , https://banksync.io/alternatives/gocardless-bank-account-data , https://github.com/invoiceninja/invoiceninja/discussions/11305
- **Enable Banking:** free "Restricted Production" tier (real data, only for accounts you link yourself), self-serve, claims 2,700+ ASPSPs in 30 countries (provider claim). **TrueLayer** and **Yapily:** free sandboxes and pay-as-you-go but production often needs sales; TrueLayer strongest for UK and Ireland. **Tink:** strongest in the Nordics and DACH. **Plaid:** UK and Ireland stronger than mainland EU; UK and EU pricing is custom. Tink, Yapily and TrueLayer typically need eIDAS QWAC certificates. [S] https://www.openbankingtracker.com/blog/best-open-banking-api-providers-developers-2026 , https://dev.to/johnfrandsen/comparing-european-open-banking-api-providers-in-2026-plaid-truelayer-tink-gocardless , https://dev.to/johnfrandsen/gocardless-bank-account-data-alternatives-what-to-use-when-signups-are-disabled-326d
- **Plaid (US):** pay-as-you-go with no minimum, rates shown only when applying for Production; Transactions billed monthly per connected Item; a Trial plan gives eligible new US and Canada teams free real data capped at 10 Production Items (teams created on or after 15 April 2026). Per-connection figures of 0.30 to 0.60 USD are third-party estimates. [S] https://www.vendr.com/marketplace/plaid , https://checkthat.ai/brands/plaid/pricing
- **Germany:** finAPI is BaFin-licensed (AIS and PIS), XS2A plus FinTS (reaches savings, credit-card and securities accounts XS2A often does not), powers DATEV; Tink is more developer-friendly; no public pricing (one blog estimates 0.10 to 0.50 EUR per account per month, enterprise deals from 2,000 to 5,000 EUR per month, unofficial). FinTS can be self-hosted via python-fints, which needs a registered FinTS product ID from the Deutsche Kreditwirtschaft, and returns MT940 or CAMT. [S] https://fynteq.com/insights/open-banking-providers-germany , https://www.finapi.io/en/products/open-banking/banking-api/ , https://github.com/OCA/l10n-germany/pull/269
- **Nigeria:** Okra shut down in May 2025; Mono is the surviving infrastructure operator; Flutterwave announced acquiring Mono in early 2026 (closing unverified); Nigeria's formal open-banking framework went live on 1 August 2025. Mono pricing and business-account coverage not found. [S] https://techeconomy.ng/okra-startup-closes-down/ , https://afridigest.substack.com/p/flutterwave-acquires-mono , https://allbusiness.africa/insights/african-open-banking-okra-collapse-2026

Design [I]: a provider-agnostic `BankFeed` interface with adapters for Plaid (US), Enable Banking or TrueLayer or Yapily (UK and EU including Germany), Mono (Nigeria), and a **file-import adapter** (CSV with column mapper, OFX/QFX, QIF, MT940, CAMT.053) as the baseline that works everywhere. Prefer CAMT.053 over MT940 or CSV for German accounts. Use FinTS or finAPI only if cost and licensing fit.

Selecting a provider sends the user's bank data to a third party. Ask the owner before adding any new provider, and never put credentials or tokens anywhere except the issuing provider.

## 2. Statement-file formats

Xero's own manual import reportedly accepts OFX, QFX, QIF, PDF and CSV (CSV capped at 100,000 rows); OFX recommended; the first CSV import maps columns to statement fields; MT940 and CAMT.053 not confirmed (converter apps turn them into OFX). [S] https://bankconv.com/guides/how-to-import-bank-statement-into-xero , https://www.receipt-bot.com/blog/xero-feature-deep-dive-how-to-import-bank-transactions-into-xero

CAMT.053 is the ISO 20022 XML replacement for MT940. MT940 compresses counterparty and remittance into a 390-character Tag 86 free text; CAMT.053 has discrete fields. Some banks charge for electronic statement delivery (for example EUR 10 per account per month at one Landesbank). [S] https://invoicedataextraction.com/blog/mt940-camt053-bank-statement-format-guide , https://www.scribd.com/document/895787770/Preis-Leistungsverzeichnis-En

Format notes from general knowledge (not from the research notes; confirm with real bank samples and the specs before relying on them) [K]:

| Format    | Shape                                                                          | Amount and sign                                   | Stable ID                                   | Pitfalls                                                                                                                       |
| --------- | ------------------------------------------------------------------------------ | ------------------------------------------------- | ------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| OFX / QFX | SGML-like v1 or XML v2                                                         | `TRNAMT` signed decimal                           | `FITID`, unique per account per institution | v1 SGML is not well-formed XML; some banks reuse `FITID`; time zone in `DTPOSTED`                                              |
| QIF       | line-based (`D` date, `T` amount, `P` payee, `N` number, `M` memo)             | `T` signed                                        | none                                        | no unique ID; date format varies (day-first vs month-first, 2-digit years); no balances                                        |
| CSV       | bank-specific                                                                  | signed, or separate debit and credit columns      | sometimes                                   | decimal comma in DE and NG-adjacent exports, thousands separators, BOM, encodings (Windows-1252), header text differs per bank |
| MT940     | SWIFT text blocks (`:60F:` opening, `:61:` line, `:86:` info, `:62F:` closing) | amounts use a decimal comma with `C` or `D` marks | bank reference in `:61:` where present      | Tag 86 structure differs per bank; multiple statements in one file                                                             |
| CAMT.053  | ISO 20022 XML                                                                  | `Amt` with `CdtDbtInd` `CRDT` or `DBIT`           | `AcctSvcrRef`, `EndToEndId` where present   | namespace versions (`camt.053.001.02`, `.08`), `Ntry` vs `TxDtls` nesting, entries with several details                        |

Parser rules [I]:

- Parse by tag or header name, not position. Reject files whose structure does not match; keep the original file as an immutable artefact with its SHA-256.
- Use exact decimals and the account currency's exponent. Never `double`.
- Dates are calendar dates; carry booking date and value date separately where both exist. CSV importers take an explicit date format and decimal separator per template.
- Treat statement lines as immutable. Corrections come from re-import of a newer file, not edits.

## 3. Dedupe and anchoring [I]

- Key: `(bank_account, bank_transaction_id)` when the source gives one (OFX `FITID`, CAMT `AcctSvcrRef` or `EndToEndId`, provider ID).
- Otherwise: hash of `(bank_account, booking_date, amount_minor, normalised remittance text, occurrence_index)`, where `occurrence_index` counts identical keys within one file, so two real identical purchases on the same day are both kept, while re-importing the same file adds nothing (vector V9).
- Anchor each import to statement balances: opening plus sum of lines must equal closing (vector V10). On mismatch refuse the file and report the difference.
- Carry the last-reconciled statement balance and date from the Xero migration forward as the first anchor.
- Link statement lines to ledger entries through reconciliation matches (see `double-entry-ledger`), never by mutating the line.
- Overlapping files from the same account (for example monthly statements plus a feed) must dedupe on the key above, then on a fuzzy match proposal shown to the user, never auto-deleted.

## 4. Gaps

- Official pricing and onboarding terms for TrueLayer, Yapily, Tink, finAPI, Enable Banking (paid) and Mono were not retrieved.
- Plaid UK and EU production access was not verified; Plaid docs were not fetched.
- Whether the Flutterwave and Mono deal closed, and Mono's business-account coverage, is unknown.
- Xero Central confirmation of supported statement formats is missing.
- The format table above rests on general knowledge, not on fetched specifications or bank samples.
