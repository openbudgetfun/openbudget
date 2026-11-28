---
openbudget_app: user_fix
---

# Wallet balances no longer count week-old prices

A crypto holding now drops out of your net worth when no source has quoted it
for seven days, instead of keeping a stale value alive. Prices that come from
OpenBudget's cache are marked as cached rather than live, so confidence in a
wallet's total reflects how fresh its evidence is. The web app also loads its
files reliably after a preview or health check has asked for their headers
only.
