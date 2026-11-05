# Test vectors

These are constructed examples written for this skill. **They are not Xero output.** They test importer logic (header handling, gates, rounding, dedupe). Real Xero fixtures from a Demo Company replace or extend them once captured. Amounts are major units for readability; encode as integer minor units. Rounding: half up on the absolute value. All arithmetic was checked by the author.

## V1 Header normalisation and loud failure

Normalisation: strip a UTF-8 BOM, trim whitespace, strip a leading `*`, case-fold.

- Input headers `[BOM]*ContactName`, `*InvoiceNumber`, `invoicedate`, `*DueDate`, `*Description`, `*Quantity`, `*UnitAmount`, `*AccountCode`, `*TaxType` normalise to `contactname`, `invoicenumber`, `invoicedate`, `duedate`, `description`, `quantity`, `unitamount`, `accountcode`, `taxtype` and map to canonical fields by alias table. Column order shuffled: same result.
- Same set with `*AccountCode` removed: raises `MissingRequiredColumn(['accountcode'])` listing the headers found. No import.
- Same set plus an unrecognised `Foo` column: raises `UnknownColumns(['foo'])` unless `foo` is in the explicit ignore list for that export. No silent drop.
- Two columns that normalise to the same name: raises `AmbiguousHeader`.
- Tab-delimited GL file read with a comma delimiter, so a single header cell: raises `UnknownLayout`, listing the single cell.

## V2 Opening trial balance journal

As-at 31 March 2026, conversion date 1 April 2026, journal dated 31 March 2026.

| Account             | Debit    | Credit   |
| ------------------- | -------- | -------- |
| Bank                | 5,000.00 |          |
| Accounts Receivable | 2,000.00 |          |
| Accounts Payable    |          | 1,500.00 |
| Share capital       |          | 100.00   |
| Retained Earnings   |          | 5,400.00 |

Debits 7,000.00 = credits 7,000.00. Gate G1 passes, G2 passes, no Historical Adjustment line.

Imbalanced variant: Retained Earnings 5,300.00. Debits 7,000.00, credits 6,900.00. The importer posts a Historical Adjustment line of 100.00 credit to make the journal balance, G7 fails (residual not accepted), and the report names the 100.00. The user may accept the residual by name; the override is audited.

## V3 AR tie-out

Aged Receivables Detail rows: invoice 1,200.00, invoice 1,000.00, credit note -200.00. Sum 2,000.00. AR control from the Trial Balance 2,000.00. G3 passes.

Variant: control 2,100.00. G3 fails with a difference of 100.00; the report lists per-contact amounts from the aged file against the ledger.

Multi-currency variant: one USD invoice of 1,000.00 carried at base 800.00 (rate 1.25 USD per GBP) in the aged file; the base-currency column (not a recomputation at today's rate) is what ties to the control account.

## V4 Per-line tax and rounding (stated tax is kept)

Two lines of 45.45 at 10%, exclusive. Stated tax per line 4.55 (4.545 half up), total tax 9.10, gross 100.00. Recomputing on the sum would give 90.90 x 10% = 9.09. The importer stores the stated 9.10, notes a rounding delta of 0.01 against the recomputation, and posts nothing to alter the stated tax; the delta is shown, not corrected.

Inclusive: line total 14.78 at 10%: net 14.78 / 1.1 = 13.436... = 13.44; tax = 14.78 - 13.44 = 1.34.

Wrong upload mode: invoice net 100.00 at 20% VAT entered with the file read as inclusive gives net 83.33, tax 16.67, total 100.00 instead of net 100.00, tax 20.00, total 120.00. Where the file states a Total column and the computed total differs from it by exactly the tax amount the other mode would add (here 120.00 stated against 100.00 computed, a 20.00 gap equal to 20% of the net), the importer flags a probable inclusive/exclusive mismatch.

## V5 FX direction and re-rounding

Xero's convention: foreign per base. Rate 1.2345 USD per 1 GBP, six decimals.

- Invoice USD 1,234,567.89. Direct: 1,234,567.89 / 1.2345 = 1,000,054.9939... = **GBP 1,000,054.99**.
- If the importer inverts the rate and rounds it to 6 decimals (0.810045) and multiplies: 1,234,567.89 x 0.810045 = 1,000,055.5464... = GBP 1,000,055.55, wrong by 0.56.
- Rule: keep the source rate and direction verbatim; take the base amount from the file as authoritative; compute a rate only for display.
- Small case: USD 1,000.00 at 1.25 USD per GBP = GBP 800.00 either way.

## V6 Conversion date and lock

Xero locked through 31 March 2026. Default conversion date 1 April 2026. History before that date imports into locked periods; after posting, `period_lock` through 31 March 2026 exists. A later attempt to post a journal dated 15 March 2026 is rejected.

## V7 Contacts

`Acme Ltd` and `ACME Ltd.` in one file: both imported as separate contacts, a soft warning lists them as possible duplicates. They are not merged. A contact with an open balance column but no invoices: the balance is ignored and a soft warning is raised (balances come from documents).

## V8 Account codes as strings

Chart code `0840` exported through Excel as `840`: the importer reads the chart file's code as the string it finds. If the Trial Balance file refers to `0840` and the chart has `840`, G2 fails with an unmatched-account error naming both; it does not coerce numerically. Codes `0840` and `840` in one chart are distinct accounts.

## V9 Statement dedupe

File 1 holds two lines on 2026-10-30: `-3.50 COFFEE SHOP` and `-3.50 COFFEE SHOP`, no bank IDs. Keys: `(acct, 2026-10-30, -350, "coffee shop", 0)` and `(..., 1)`. Both stored. Re-importing file 1: zero new lines. A later file that overlaps and contains the same two lines plus one new line: one new line stored.

OFX line with `FITID` `A123` appears in two overlapping files: stored once.

## V10 Balance anchor

Opening balance 1,000.00; lines +250.00 and -75.50. Computed closing 1,174.50. File states closing 1,174.50: accepted. File states 1,174.00: refused with a difference of 0.50, no lines stored.

## V11 Amount parsing

- MT940-style `75,50` with debit mark: -7550 minor units in EUR. `1.234,56` in a German CSV with decimal comma: 123456. `1,234.56` in a UK CSV: 123456. The importer needs an explicit decimal separator and thousands separator per template; guessing fails.
- A zero-decimal currency (for example JPY) `1500`: 1500 minor units. A three-decimal currency (for example KWD) `1.500`: 1500 minor units. Exponent comes from the currency table.
- CAMT.053 `Amt` 100.00 with `CdtDbtInd` `DBIT`: -10000; with `CRDT`: +10000.

## V12 Gate matrix

For V2 and V3 inputs together with a bank file whose ledger balance equals the statement balance:

| Gate | Result                                  |
| ---- | --------------------------------------- |
| G1   | pass                                    |
| G2   | pass                                    |
| G3   | pass                                    |
| G4   | pass (AP has one open bill of 1,500.00) |
| G5   | pass                                    |
| G6   | pass                                    |
| G7   | pass (no Historical Adjustment)         |
| G8   | pass (every skipped row has a reason)   |

Breaking any single input flips exactly the gates the break touches and no others; assert that the report names which.
