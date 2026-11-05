# Test vectors

All figures are the author's own arithmetic from the research notes (checked again while writing this file); none are from an official source. They test internal consistency, not tax law. Amounts are shown in major units for readability; encode as integer minor units. Rounding: half up on the absolute value to the minor unit.

## T1 Posting invariants

- Journal with one line: rejected. Two lines Dr 100.00 / Cr 99.99: rejected. Line with debit and credit both non-zero: rejected. Zero line: rejected.
- Multi-currency journal balanced in GBP but not per transaction currency (USD lines 100.00 Dr and 99.00 Cr, rates chosen to balance in GBP): rejected.
- Same `(source_type, source_id, source_version)` posted twice: the second returns the first journal, no new rows.
- Post dated on or before the lock date by a normal user: rejected. By a user with override: accepted, an `audit_event` exists.
- Reversal of any journal: balances of all accounts return to the pre-journal values; the reversal references the original.

## T3.1 UK invoice, part payment, credit note, write-off (GBP, VAT 20%)

1. Invoice net 1,200.00, VAT 240.00, gross 1,440.00: Dr AR 1,440.00 / Cr Sales 1,200.00 / Cr VAT output 240.00.
2. Part payment 500.00: Dr Bank 500.00 / Cr AR 500.00. `amount_due` 940.00.
3. Credit note net 120.00, VAT 24.00, gross 144.00: Dr Sales returns 120.00 / Dr VAT output 24.00 / Cr AR 144.00. Allocate 144.00; `amount_due` 796.00.
4. Write-off of the remainder (assuming relief applies): net 796.00 / 1.2 = 663.33, VAT 132.67, sum 796.00. Dr Bad debt 663.33 / Dr VAT output 132.67 / Cr AR 796.00. `amount_due` 0.00.
5. Assertions: AR control 0.00. VAT output net 240.00 - 24.00 - 132.67 = 83.33 Cr, which equals the VAT inside the 500.00 received (500/1.2 = 416.67 net, VAT 83.33). Sales net 1,200.00 - 120.00 = 1,080.00 = bad debt 663.33 + cash net 416.67.

## T3.2 Overpayment

Invoice gross 100.00, payment 130.00: Dr Bank 130.00 / Cr AR 100.00 / Cr Customer credit 30.00. Party balance is 30.00 credit. A new invoice of 80.00 takes 30.00 from the credit, leaving 50.00 due.

## T3.3 Numbering concurrency

Two approvals racing on one series produce `INV-0001` and `INV-0002`, no duplicate, no gap. If one transaction rolls back, its number is not consumed and the next approval takes it.

## T4.1 UK simplified-invoice threshold

Gross 250.00: simplified allowed. 250.01: full required. Customer asks for a full invoice at 100.00: full.

## T4.2 UK foreign-currency VAT

EUR 1,000.00 net, 20% VAT 200.00, gross 1,200.00, rate 1 GBP = 1.16 EUR: sterling VAT 200 / 1.16 = 172.4137 = 172.41. That figure posts to VAT output.

## T4.3 German Kleinunternehmer limits (secondary-sourced limits)

Prior-year net 24,999 and current-year projected 90,000: Kleinunternehmer, no VAT shown. At current-year actual 100,000.01 the crossing supply is taxable at 19% or 7% and needs VAT on its invoice.

## T4.4 German rate split

Lines 100.00 net at 19% and 50.00 net at 7%: VAT 19.00 and 3.50, gross 172.50. Invoice shows both net bases and both tax amounts.

## T4.5 German e-invoice routing (calendar test, secondary-sourced dates)

- 2026-12-31, prior-year turnover 1,000,000: PDF allowed.
- 2027-01-01, same issuer: structured EN 16931 invoice required for domestic B2B.
- 2027-06-01, prior-year turnover 500,000: PDF still allowed.
- 2028-01-01: required for all.
- Boundary: prior-year turnover exactly 800,000 is treated as "at or below" in the sources reading "above EUR 800,000"; one source says "at least EUR 800,000". This conflict is open; the test must follow whatever the configured rule data says.

## T5 Bank reconciliation

- T5.1 Split match: line -1,000.00 settles Bill A 600.00 and Bill B 400.00; one payment journal, two allocations; both bills paid.
- T5.2 Partial: line +500.00 against open invoice 800.00: allocate 500.00, 300.00 due.
- T5.3 Bank fee: line -12.50 with no document and a rule: Dr Bank charges 12.50 / Cr Bank 12.50.
- T5.4 Transfer: account A -500.00 on 5 Nov, account B +500.00 on 6 Nov: one transfer journal (via `bank_clearing` for the in-transit day), both lines reconciled, no income or expense effect.
- T5.5 Report: statement closing 10,000.00, ledger 9,700.00, outstanding payments 500.00, outstanding deposits 200.00: 10,000 + 200 - 500 = 9,700, difference 0.00.

## T6 Multi-currency (functional GBP; rate = USD per 1 GBP)

- T6.1 Realised loss: day 1 invoice USD 1,000.00 at 1.25 = GBP 800.00 (Dr AR 800.00 / Cr Sales 800.00). Day 20 paid USD 1,000.00 at 1.30 = 769.23. Dr Bank 769.23 / Dr Realised FX loss 30.77 / Cr AR 800.00.
- T6.2 Part payment: USD 400.00 at 1.30 = 307.69. AR released 800.00 x 400/1,000 = 320.00. Loss 12.31. Remaining AR 480.00 (USD 600.00).
- T6.3 Unrealised: open USD 500.00 booked at 1.25 = 400.00. Closing rate 1.28: 500/1.28 = 390.625 = 390.63. Unrealised loss 9.37 (Dr Unrealised FX loss / Cr AR), reversed next period. Paid later at 1.30 = 384.62: realised loss 400.00 - 384.62 = 15.38.
- T6.4 Rounding: three lines USD 33.33 at 1.25 = 26.664 -> 26.66 each = 79.98. Document total USD 99.99 / 1.25 = 79.992 -> 79.99. Residue 0.01 goes to the largest line so lines sum to the total.

## T7 Fixed assets, prepayments, close, opening balances

- T7.1 Straight line: cost 12,000, residual 0, 5 years: 2,400 per year, 200 per month. After 18 months accumulated 3,600, NBV 8,400.
- T7.2 Residual and rounding: cost 10,000, residual 1,000, 36 months: 250.00 per month exactly. Cost 1,000 over 7 months: 142.857...; months 1 to 6 post 142.86 (857.16), month 7 posts 142.84; total exactly 1,000.00.
- T7.3 Reducing balance 25%: cost 12,000. Year 1 3,000.00 (NBV 9,000.00); year 2 2,250.00 (6,750.00); year 3 1,687.50 (5,062.50).
- T7.4 Disposal: cost 12,000, accumulated 7,200, proceeds 5,500. NBV 4,800, gain 700. Dr Bank 5,500 / Dr Accumulated depreciation 7,200 / Cr Asset cost 12,000 / Cr Gain 700. Debits 12,700 = credits 12,700.
- T7.5 Prepayment: annual insurance 1,200 paid 1 Oct, year-end 31 Dec: Dr Prepayments 1,200 / Cr Bank 1,200; release 100.00 per month; at 31 Dec expense 300.00, prepayment 900.00.
- T7.6 Accrual with reversal: utilities 450 for October to December, bill in January. 31 Dec: Dr Utilities 450 / Cr Accruals 450. 1 Jan reversal: Dr Accruals 450 / Cr Utilities 450. January bill: Dr Utilities 450 / Cr AP 450. Net January effect 0; year-end expense in the right year.
- T7.7 Year-end close: income 100,000, expenses 70,000, profit 30,000. Physical close: Dr income accounts 100,000 / Cr expense accounts 70,000 / Cr Retained earnings 30,000; all P&L accounts 0 afterwards. Virtual close: current-year earnings 30,000; next year's balance sheet retained earnings include 30,000.
- T7.8 Opening balances: Cash 5,000 Dr, AR 2,000 Dr, AP 1,500 Cr, Share capital 100 Cr, Retained earnings 5,400 Cr. Debits 7,000 = credits 7,000.

## T8 Statements

- T8.1 Trial balance after T3.1: Bank 500.00 Dr; AR 0; Sales 1,200.00 Cr; Sales returns 120.00 Dr; VAT output 83.33 Cr; Bad debt 663.33 Dr. Debits 500.00 + 120.00 + 663.33 = 1,283.33; credits 1,200.00 + 83.33 = 1,283.33.
- T8.2 Balance-sheet identity: opening T7.8 plus a cash sale of 1,000 gross: assets 8,000, liabilities 1,500, equity 100 + 5,400 + current-year earnings 1,000 = 6,500; 8,000 = 1,500 + 6,500.
- T8.3 Indirect cash flow: net profit 30,000; depreciation +2,400; AR increase -3,000; AP increase +1,000; operating 30,400. Asset purchase -12,000; loan received +10,000. Net change in cash 28,400, equal to the bank-account movement.
- T8.4 Aged AR on 5 November: A 100.00 due 4 Nov (1 day), B 200.00 due 20 Oct (16 days), C 300.00 due 1 Aug (96 days), unallocated credit note -50.00. Buckets: 1 to 30 = 300.00; 90+ = 300.00; credits -50.00; total 550.00 = AR control.

## T9 VAT rounding method

Three lines of 0.10 at 5%: per-line method total VAT 0.03; per-invoice method 0.02. The stored method decides; a reprint never changes the figure.

## T10 Retention

- German voucher created 2026-03-15: `retain_until` 2034-12-31 under the 8-year rule counted from the end of the creation calendar year. Book or annual accounts: 2036-12-31.
- UK VAT record for an accounting period ending 2026-03-31: 2032-03-31 (sixth anniversary).
- A purge run lists the record only after its date and never when a legal hold is set.
