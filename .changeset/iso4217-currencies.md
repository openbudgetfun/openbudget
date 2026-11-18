---
"openbudget_core": feat
"openbudget_server": feat
---

# Every ISO 4217 currency can be a base currency

`CurrencyCode` is generated from `openbudget_core/data/iso4217.json`, the ISO 4217 List One published by SIX on 2026-09-17, and grows from 27 members to 166. Every active code with a published minor unit is included with its published exponent, including the two funds (CLF, UYW) the standard gives four decimal places. The 26 ISO codes and BTC that shipped before keep their names, symbols and exponents exactly.

The 13 codes ISO 4217 publishes without a minor unit are recorded in the data file and rejected: precious metals, units of account, the testing code and the no-currency code cannot hold an amount, so `XXX` is still not a currency. `dart run tool/generate_currencies.dart --check` runs in CI's lint job, beside the generated icon check.

The FX service no longer sends a currency filter to currencyapi.com: the provider rejects a filter naming a code it does not list, and it prices 155 of the 166 codes. It now answers with every currency it prices, and the parser keeps the supported ones. The 11 unpriced codes still work as a base currency, and a cross-currency write falls back to the existing manual-rate path.
