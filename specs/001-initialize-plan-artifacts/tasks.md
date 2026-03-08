# Tasks: Initialize plan artifacts and regenerate agent context

**Input**: Design documents from `/specs/001-initialize-plan-artifacts/`
**Prerequisites**: `plan.md`, `spec.md`

## Phase 1: Setup

- [x] T001 Create feature-plan artifacts in `specs/001-initialize-plan-artifacts/`.
- [x] T002 Add shared `AGENTS.md` and include role guidance with a `designer` role.
- [x] T003 Update `docs/how-to-use-openbudget-plan-and-priorities.md` with maintainer plan/context workflow.

## Phase 2: Core implementation

- [x] T004 Update `.specify/scripts/bash/update-agent-context.sh` to dedupe repeated `Recent Changes` entries.
- [x] T005 Update `.specify/scripts/bash/update-agent-context.sh` to dedupe `Active Technologies` by exact bullet line.
- [x] T006 Ensure update-all mode processes each target file once even when multiple aliases map to the same file.
- [x] T007 Filter stale placeholder entries (for example `[if applicable, ...]`) from generated context sections.

## Phase 3: Validation

- [x] T008 Run `bash -n .specify/scripts/bash/update-agent-context.sh`.
- [x] T009 Run `.specify/scripts/bash/update-agent-context.sh` (update-all mode) from the feature branch.
- [x] T010 Run `dprint check` for updated markdown files.

## Notes

- This task file reflects work completed while continuing “next steps in the plan” on branch `001-initialize-plan-artifacts`.
