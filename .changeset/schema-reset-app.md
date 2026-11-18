---
openbudget_app: breaking
---

# Port the app to the entity schema

The app now talks to the entity-based protocol end to end. Routes take `:entityId`, every amount is an integer in the currency's minor units, and months are `yyyymm` ints. Realtime refreshes come from `entityStream.watch` and invalidate providers by `ChangeScope`. The plan reads one `budget.getMonth` view, home reads `entity.listSummaries`, and the reports read `report.spending`, `report.monthSummaries` and `report.ageOfMoney`. The app never converts currencies itself: every converted figure comes from the server with its rate, rate date and source.
