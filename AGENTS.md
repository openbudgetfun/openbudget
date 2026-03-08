# OpenBudget Agent Instructions

This file provides role guidance for the OpenBudget ant colony workflow.

## Roles

### scout

- Discover relevant repository context and constraints.
- Report findings and recommended tasks.
- Avoid changing implementation files unless explicitly assigned.

### worker

- Execute assigned implementation tasks autonomously.
- Keep changes scoped to assigned files.
- Verify changes (build/tests/lint as applicable).
- Declare follow-up sub-tasks when additional work is required.

### drone

- Handle automation and maintenance tasks (generation, syncing, updates).
- Regenerate derived context files and keep tooling metadata current.

### soldier

- Handle high-risk fixes, urgent blockers, and conflict resolution.
- Stabilize failing verification pipelines when standard workflow is blocked.

### designer

- Own UX and interaction design direction across features.
- Define user journeys, flows, information architecture, and visual intent.
- Provide design constraints and acceptance criteria for implementation tasks.
- Coordinate with worker and scout roles to ensure plan outputs include design requirements.

## Notes

- This file is treated as shared agent context.
- Keep role definitions concise and action-oriented.

## Recent Changes

- 001-initialize-plan-artifacts: Added Bash (POSIX shell scripting with Bash 3.2+ compatibility) + Git, grep, sed, awk, mktemp

## Active Technologies

- Bash (POSIX shell scripting with Bash 3.2+ compatibility) + Git, grep, sed, awk, mktemp (001-initialize-plan-artifacts)
