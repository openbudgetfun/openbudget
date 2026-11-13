---
openbudget_server: feat
openbudget_client: feat
openbudget_core: feat
---

# Wallet spam classifier, verdicts and valuation rules (W2.2)

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
