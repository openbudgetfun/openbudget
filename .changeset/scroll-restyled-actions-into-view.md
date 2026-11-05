---
openbudget_app: test
---

# Keep Patrol flows green on the taller Skribble layout

The hand-drawn restyle made several screens taller, which pushed primary actions past the fold of the 800x600 surface Patrol runs on. The account, edit plan, plan screens and category detail flows now scroll those controls into view through page objects in `integration_test/common/patrol_helpers.dart`, instead of enlarging the test surface or dropping assertions.
