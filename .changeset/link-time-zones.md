---
openbudget_server: fix
---

# Resolve IANA time-zone aliases such as Africa/Kampala

`EntityClock` now loads the `timezone` package's `latest_all` database, which
retains IANA backward links, instead of the trimmed `latest` database that
dropped them. Every time zone listed in the generated country data resolves.
