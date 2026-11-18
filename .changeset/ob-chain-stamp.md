---
openbudget_ui: feat
---

# Add `ObChainStamp` for wallet chains

`ObChainStamp` letters a chain's name on a perforated postage stamp, beside `ObCurrencyStamp`. Each `ChainFamily` prints in one fixed spot ink (Bitcoin tangerine, EVM lilac, Solana teal, Tron pink, XRP Ledger sky, and the later families spread over the six inks), follows the day and night print runs, and is drawn with the Skribble pen, with no chain logos. A stamp is `inked` or an outline, with an optional detail line ("zpub", "+ 6") and a value line in tabular figures. `ObChainStampToggle` is the pickable variant: it inks while selected, has a 48 point touch target, and announces the chain and whether it is selected. State words for screen readers come from `ObChainStampWords`, so the app can localise them.
