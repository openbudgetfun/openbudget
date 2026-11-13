---
openbudget_core: feat
---

# Tax freshness tool and weekly re-check workflow

`dart run openbudget_core:tax_freshness` lists every country whose tax reference data has reached its `recheckBy` date, with the verified-on date and the overdue day count (`--as-of YYYY-MM-DD` overrides the day; `--json` feeds automation; the exit code is 0 either way — overdue data is a work queue, not a build failure). A new scheduled workflow (`tax-freshness.yml`) runs the tool weekly, opens or updates one labelled GitHub issue per overdue country, and closes issues whose country is no longer overdue. It never runs on pull requests and is never a required check. Task C2 extends the report to rule-set caveats.
