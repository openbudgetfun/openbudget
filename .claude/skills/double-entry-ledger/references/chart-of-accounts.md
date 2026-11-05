# Chart of accounts

Tags: **P**, **P-snip**, **S**, **I** (inferred), **K** (general knowledge, not in the research notes, verify before use).

## Design

One internal account model. Every account may carry a stable `system_role`; per-jurisdiction template charts map to those roles. Do not key on account codes (users renumber; Xero codes vary by region). [I]

## Required `system_role` set [I]

Exactly one active account per role per ledger, not deletable, no direct manual postings:

`accounts_receivable`, `accounts_payable`, `vat_output` (US: `sales_tax_payable`), `vat_input`, `vat_control`, `payroll_liabilities`, `directors_loan`, `retained_earnings`, `current_year_earnings` (virtual), `realised_fx`, `unrealised_fx`, `rounding`, `suspense`, `opening_balance_equity`, `bank_clearing`, `prepayments`, `accruals`, `depreciation_expense`, `accumulated_depreciation`, `bad_debt_expense`, `bad_debt_provision`.

Also useful: `customer_credit` (overpayments and prepayments received), `supplier_credit`, `historical_adjustment` (migration only).

Reference behaviour: Xero ships locked system accounts that cannot be deleted or change type (Accounts Receivable, Accounts Payable, VAT, Retained Earnings, realised and unrealised currency gains), and keeps foreign-currency accounts in the chart with a currency attached. [S] https://central.xero.com/0/article/Locked-and-system-accounts-in-your-chart-of-accounts-GL , https://central.xero.com/0/article/Foreign-currency-accounts-in-the-chart-of-accounts-GL

## Control-account rules [I]

- Manual journals to AR or AP are blocked, or need a party and a document reference. Otherwise the sub-ledger and the control balance drift.
- Foreign-currency AR and AP are controlled through the document flow.
- Each account also carries `cash_flow_section` and an optional `tax_category_code` that feeds the tax engine (`gb.se.office_costs` style codes from `openbudget_core/lib/src/tax/`).

## Starter charts [I]

Names are short and codes illustrative. Ship these as data with effective dates, not as code.

### UK limited company (FRS 102 1A or FRS 105 micro-entity layout; accrual)

- Assets: bank accounts, trade debtors (AR), other debtors, prepayments, stock, VAT recoverable, fixed assets by class (computer equipment, plant, fixtures, motor vehicles), accumulated depreciation per class, directors' loan (if overdrawn).
- Liabilities: trade creditors (AP), accruals, VAT liability, PAYE and NIC liability, corporation tax liability, pension liability, directors' loan (if credit), bank loans, credit cards.
- Equity: share capital, retained earnings, dividends declared.
- Income: sales, other income, interest received.
- Expenses: cost of sales, wages and salaries, employer NIC, pension costs, rent, utilities, insurance, software, professional fees, bank charges, depreciation, FX gains and losses, bad debts, corporation tax charge, rounding.

### UK sole trader

- Same shape. Equity is owner's capital, capital introduced and owner's drawings in place of share capital, retained earnings and dividends.
- No corporation tax or director's loan accounts.
- The owner's income tax and NIC are not business expenses; drawings absorb them. Personal-use adjustments are separate from ordinary expenses.

### US LLC (single or multi-member, disregarded or partnership) and S-corp

- LLC: member's equity or capital, contributions, distributions.
- S-corp: common stock, additional paid-in capital, retained earnings, shareholder distributions, officer compensation (separate from distributions).
- Both: sales tax payable by state, payroll liabilities (federal and state withholding, FICA), AR, AP, undeposited funds or clearing, credit cards.
- A Schedule C or Form 1120-S line tag on each account is useful. US chart guidance (AICPA or IRS mapping) was not researched.

### Nigerian company

- The same five types plus: VAT payable and input VAT recoverable (7.5% VAT cited by secondary sources), withholding tax receivable (deducted by customers) and withholding tax payable (deducted from suppliers), company income tax liability, PAYE liability, pension (PenCom) and NSITF payables, USD and other foreign-currency bank accounts with FX gains and losses. [S] https://taxstreem.com/resources/articles/the-ultimate-value-added-tax-guide-for-nigeria
- No statutory chart requirement was found.

### German GmbH and Einzelunternehmen

- Internal simplified chart with `skr03_code` and `skr04_code` mapping columns.
- VAT: Vorsteuer 19%, Vorsteuer 7%, Umsatzsteuer 19%, Umsatzsteuer 7%, Kleinunternehmer income (no VAT), steuerfreie Umsätze (§4 UStG), innergemeinschaftliche Lieferungen, reverse-charge accounts.
- Einzelunternehmen: Privatentnahmen and Privateinlagen replace equity accounts.
- GmbH: Stammkapital, Gewinnvortrag or Verlustvortrag, Jahresüberschuss.

## SKR03 and SKR04

- SKR03 and SKR04 are the two common DATEV standard charts. They differ in ordering, not content. SKR03 follows the business process (Prozessgliederungsprinzip); SKR04 follows the balance-sheet and P&L layout (Abschlussgliederungsprinzip). Both reach the same statements. The law prescribes no chart. SKR04 is often recommended for new set-ups. [S] https://www.steuerschroeder.de/Steuerrechner/Kontenrahmen.html , https://www.finban.io/skr03-vs-skr04 , https://onlinebilanz.de/kontenrahmen-skr-04-aufbau-abschlussgliederungsprinzip/
- SKR04 classes: 0 to 3 balance sheet, 4 income, 5 to 7 expenses. [S] https://www.finban.io/skr03-vs-skr04
- Bank: 1200 (SKR03), 1800 (SKR04). [S] same sources.
- Is a simplified mapping acceptable? The law requires proper bookkeeping, not a chart. Many small firms use SKR only because their Steuerberater works in DATEV. Recommendation [I]: use the internal chart, store a mapping to both SKRs for every default account, and offer a DATEV Buchungsstapel export later. The DATEV chart is published under licence terms; build the mapping from the licensed list or a verified list.

Unverified number list from general knowledge [K]. Verify against the DATEV chart before shipping; do not treat as settled:

| Meaning                   | SKR03 | SKR04 |
| ------------------------- | ----- | ----- |
| Trade receivables         | 1400  | 1200  |
| Trade payables            | 1600  | 3300  |
| Input VAT 19%             | 1576  | 1406  |
| Input VAT 7%              | 1571  | 1401  |
| Output VAT 19%            | 1776  | 3806  |
| Output VAT 7%             | 1771  | 3801  |
| Revenue 19%               | 8400  | 4400  |
| Revenue 7%                | 8300  | 4300  |
| Subscribed capital (GmbH) | 0800  | 2900  |

## Gaps

- No primary list of SKR03 or SKR04 numbers was read.
- Nigerian statutory chart requirements, if any, not found.
- US chart guidance not researched.
