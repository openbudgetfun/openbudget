---
openbudget_app: fix
---

# Map load errors to localized messages

Add `loadProblemMessage` (`openbudget_app/lib/src/utils/load_problem_message.dart`), which maps network, auth, not-found and unknown failures to four new `loadProblem*` strings. Every `ObStatePanel.problem` that printed `error.toString()` now uses it, and the budget detail, edit plan, category detail and transfer error panels gain a Retry action that invalidates the root provider. The budget header month title and transaction cards carry `onLongPressHint` semantics, and main-flow copy uses US spelling ("Uncategorized", "recognizes") to match the rest of the app.
