---
openbudget_server: fix
openbudget_client: fix
---

# Keep journal lines in entry order

Journal lines used to come back in whatever order their UUID ids sorted in.
Ids are UUIDv7, so lines saved within the same millisecond sorted randomly
after the timestamp — a journal's lines could read back in a different order
than they were entered, and CI's ledger test flaked on it. `journal_line`
now carries a `lineNumber` (0-based, unique per journal) that every write
path assigns in caller order and every read orders by. The migration
backfills existing lines 0..n-1 per journal with no data loss.
