# Feature Specification: Initialize plan artifacts and regenerate agent context

**Feature Branch**: `001-initialize-plan-artifacts`\
**Created**: 2026-03-08\
**Status**: Draft\
**Input**: User description: "continue with the next steps in the plan make sure you have a designer and all rules are up to date in the agents file"

## User Scenarios & Testing _(mandatory)_

### User Story 1 - Regenerate agent context from a valid feature plan (Priority: P1)

As a maintainer, I can run the plan workflow and refresh shared agent context files from the active feature plan so agent rules and roles stay synchronized.

**Why this priority**: This is required to keep operational guidance accurate before generating implementation tasks.

**Independent Test**: Run `.specify/scripts/bash/update-agent-context.sh` from the feature branch and verify `CLAUDE.md` and `AGENTS.md` contain up-to-date context.

**Acceptance Scenarios**:

1. **Given** a feature branch with `specs/<feature>/plan.md`, **When** the update script runs, **Then** agent context files are updated successfully.
2. **Given** missing plan context, **When** the update script runs, **Then** it fails with a clear actionable error.

---

### User Story 2 - Keep agent updates idempotent (Priority: P2)

As a maintainer, I can rerun context generation without creating duplicate Recent Changes or Active Technologies entries.

**Why this priority**: Repeated runs are common during planning and should not degrade context quality.

**Independent Test**: Run the update script multiple times and confirm no duplicate entries are added.

**Acceptance Scenarios**:

1. **Given** an agent file that already contains the current branch change line, **When** the script reruns, **Then** no duplicate line is added.
2. **Given** stale placeholder entries from older runs, **When** the script updates the file, **Then** placeholder rows are not retained.

---

### User Story 3 - Support shared target files across agent aliases (Priority: P3)

As a maintainer, I can update all existing agent files in one command without processing the same physical file multiple times.

**Why this priority**: Several agent aliases map to `AGENTS.md`; duplicate processing causes repeated writes and noisy history.

**Independent Test**: Run update with no agent argument and verify each target file is updated once.

**Acceptance Scenarios**:

1. **Given** multiple aliases map to one target file, **When** update-all runs, **Then** duplicate targets are skipped with an informational log.

## Edge Cases

- Plan metadata contains `N/A` variants (for example `N/A (...)`) for storage.
- Existing context files include placeholder bullets (for example `[if applicable, ...]`).
- Agent aliases map to identical paths (`codex`, `opencode`, `amp`, `q`, `bob`).

## Requirements _(mandatory)_

### Functional Requirements

- **FR-001**: System MUST require a valid feature branch/plan context before updating agent files.
- **FR-002**: System MUST parse implementation plan metadata (language, dependencies, storage, project type).
- **FR-003**: System MUST update existing agent files without duplicating current-branch Recent Changes lines.
- **FR-004**: System MUST update Active Technologies using exact line-level dedupe to avoid false positives from substring matches.
- **FR-005**: System MUST skip stale placeholder/N/A entries when refreshing context sections.
- **FR-006**: System MUST ensure the shared `AGENTS.md` includes a `designer` role definition.
- **FR-007**: System MUST avoid updating the same target file multiple times during update-all mode.
- **FR-008**: Documentation MUST define the maintainer workflow for running plan + context refresh before task generation.

### Key Entities _(include if feature involves data)_

- **Feature Plan Metadata**: Extracted fields from `plan.md` (`Language/Version`, `Primary Dependencies`, `Storage`, `Project Type`).
- **Agent Context File**: Markdown instructions file containing roles, recent changes, and active technologies.
- **Agent Target Mapping**: Mapping from logical agent type (`claude`, `codex`, `q`, etc.) to physical file path.

## Success Criteria _(mandatory)_

### Measurable Outcomes

- **SC-001**: Running `.specify/scripts/bash/update-agent-context.sh` on the feature branch exits successfully and updates context files.
- **SC-002**: Running the same command twice in succession produces no additional duplicate entries in `Recent Changes`.
- **SC-003**: `AGENTS.md` contains a `designer` role and no placeholder `[if applicable, ...]` change entries.
- **SC-004**: Update-all mode logs duplicate-target skips for aliases that resolve to the same path and writes each target once.
