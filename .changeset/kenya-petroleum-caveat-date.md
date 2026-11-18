---
openbudget_core: fix
---

# Correct the Kenya petroleum band end date in its caveat

The Kenya country file said the 8% petroleum VAT band was deleted "from 1 July 2027". The rate row and its source say 1 July 2023, so the caveat now says the same, and `country_data.g.dart` is regenerated.
