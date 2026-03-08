# Plan And Priorities Flow (iOS)

Use this flow to budget your month and focus on high-impact categories.

## 1. Start on the Plan screen

The Plan screen is your budgeting command center. It shows ready-to-assign
money, monthly totals, and quick actions.

![OpenBudget iOS plan screen](https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-24-ios-guide/plan-screen.png)

## 2. Complete onboarding prompts

If onboarding cards are visible, finish them early so your workspace stays
focused on monthly budgeting tasks.

![OpenBudget iOS onboarding on plan screen](https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-24-ios-guide/plan-screen-onboarding-dismissed.png)

## 3. Switch to Spotlight for focus mode

Use Spotlight to surface top priorities for the month and keep your plan tight.

![OpenBudget iOS spotlight tab](https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-24-ios-guide/spotlight-screen.png)

## 4. Use the Plan actions menu

Use the overflow menu (`...`) for quick controls such as visibility toggles,
undo actions, and fast navigation into recent moves.

![OpenBudget iOS plan actions menu](https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-24-ios-guide/plan-menu.png)

## Maintainer workflow: planning next steps with agent context

When continuing implementation work from a feature plan, use the current
SpecKit command flow and always refresh shared agent context before generating
tasks.

1. Start from a feature branch/spec context, then run
   `.claude/commands/speckit.plan.md` workflow (`/speckit.plan`).
2. During Phase 1 design, run
   `.specify/scripts/bash/update-agent-context.sh claude`.
3. Confirm the regeneration updated shared guidance artifacts:
   - `AGENTS.md` (shared role guidance for codex/opencode/amp/q/bob flows)
   - `.agent/rules/specify-rules.md`
   - `.cursor/rules/specify-rules.mdc`
   - `.windsurf/rules/specify-rules.md`
   - `.kilocode/rules/specify-rules.md`
   - `.augment/rules/specify-rules.md`
   - `.roo/rules/specify-rules.md`
4. Continue with `.claude/commands/speckit.tasks.md` (`/speckit.tasks`) to
   generate dependency-ordered implementation tasks from the updated plan
   artifacts.

This keeps “next steps in the plan” aligned with the latest rules and
multi-agent context.

<!-- {=iosGuideCompanionWorkflows} -->

## Continue with another guide flow

- [Guide home](./how-to-use-openbudget.md)
- [Plan and priorities flow](./how-to-use-openbudget-plan-and-priorities.md)
- [Transaction review flow](./how-to-use-openbudget-transaction-review.md)
- [Recent moves and envelope details flow](./how-to-use-openbudget-recent-moves-and-envelopes.md)

<!-- {/iosGuideCompanionWorkflows} -->
