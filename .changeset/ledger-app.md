---
openbudget_app: feat
---

# Double-entry books in the app

Business budgets can now keep double-entry books. The More screen shows a Books entry for sole-trader and company budgets: envelope budgets get a one-way "enable books" confirmation that seeds the chart of accounts, and ledger budgets open the Books screen. Books has three tabs — journals (newest first with draft/posted/reversed status chips), the chart of accounts grouped by account type with archived marks, and a trial balance with an as-of date picker, per-account debit/credit totals and a balanced indicator. The journal editor validates live against the shared core rules while typing (debit total, credit total, difference), saves drafts, posts behind a "posted journals are permanent" confirmation and deletes drafts; posted journals open read-only with a reversal action that asks for a reversal date. A lock-date setting on the Books screen calls `setLockDate` to freeze closed periods. Amounts travel as integer minor units and render with the app's currency formatting.
