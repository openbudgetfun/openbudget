<!--
=== Sync Impact Report ===
Version change: N/A → 1.0.0 (initial ratification)

Modified principles: N/A (initial constitution)

Added sections:
  - Core Principles (10 principles)
  - Technology Stack & Constraints
  - Development Workflow & Monetization Strategy
  - Governance

Removed sections: N/A

Templates requiring updates:
  - .specify/templates/plan-template.md — ✅ no updates needed
    (Constitution Check section already references constitution file)
  - .specify/templates/spec-template.md — ✅ no updates needed
    (Spec template is technology-agnostic by design)
  - .specify/templates/tasks-template.md — ✅ no updates needed
    (Task phases and structure are generic)
  - .specify/templates/checklist-template.md — ✅ no updates needed
  - .specify/templates/agent-file-template.md — ✅ no updates needed

Follow-up TODOs: None
=== End Sync Impact Report ===
-->

# OpenBudget Constitution

## Core Principles

### I. Cross-Platform Flutter First

All user-facing applications MUST target iOS, Android, Web, and
Desktop (macOS, Windows, Linux) via a single Flutter codebase.
Platform-specific code MUST be isolated behind abstractions so
that no feature is exclusive to a single platform unless a
hardware dependency makes it impossible (e.g., NFC on web).
The latest stable Flutter release MUST be tracked within one
minor version.

**Rationale**: A unified codebase reduces maintenance cost and
ensures feature parity across every surface users expect.

### II. Envelope Budgeting Core

The budgeting model MUST implement zero-sum (envelope) budgeting:
every unit of income MUST be assigned to a category, leaving no
money unallocated. Categories act as virtual envelopes. Users
MUST be able to reallocate funds between categories at any time.
Both fixed and variable expenses MUST be covered by the budget
plan. The system draws from the principles documented at
https://actualbudget.org/docs/ but is NOT local-first.

**Rationale**: Envelope budgeting is a proven, intuitive method
that gives every dollar a job and promotes intentional spending.

### III. Cloud-First Architecture

All persistent data MUST live on a Serverpod-powered backend.
There is no offline-first or local-first data layer. The client
communicates with the server via Serverpod's generated protocol.
Database migrations MUST be managed through Serverpod's migration
tooling. The API contract MUST be the single source of truth for
data shapes shared between client and server.

**Rationale**: A cloud-first model simplifies conflict resolution,
enables real-time multi-device sync, and centralises business
logic for AI-driven features that require server-side compute.

### IV. AI-First Financial Intelligence

AI capabilities MUST be treated as core product features, not
add-ons. The system MUST provide tools for: cross-border tax
calculation, investment strategy suggestions, and cryptocurrency
portfolio management. AI features MUST surface actionable
insights within the normal budgeting workflow rather than in
isolated screens. All AI-generated advice MUST include
appropriate disclaimers and MUST NOT constitute regulated
financial advice unless properly licensed.

**Rationale**: AI transforms budgeting from passive record-keeping
into proactive financial guidance, which is the primary
differentiator of OpenBudget.

### V. Multi-Currency Native

Multi-currency support MUST be a first-class concern in every
data model, UI component, and calculation. The system MUST
support budgeting, reporting, and transaction tracking across
an arbitrary number of currencies simultaneously. Exchange rates
MUST be sourced from reliable external providers and cached with
clear staleness indicators. Currency conversion MUST never
silently lose precision.

**Rationale**: Users managing finances across borders or in crypto
need accurate multi-currency handling from day one, not as a
retrofit.

### VI. Test-Driven Quality (NON-NEGOTIABLE)

Every feature MUST have unit tests covering core logic and
integration tests covering cross-boundary interactions. Test
coverage MUST be maintained or improved with every pull request.
Tests MUST be written before or alongside implementation—never
deferred to a later ticket. Widget tests MUST cover critical UI
flows. Every major feature MUST have Patrol E2E tests covering the
primary user flow. Integration tests live in `integration_test/`
and use the page object pattern. Server-side endpoints MUST have
contract tests validating request/response shapes. Flaky tests
MUST be fixed or quarantined within 48 hours of detection.

**Rationale**: Rigorous testing is the only reliable way to
maintain velocity as the codebase grows and to prevent regressions
in financial calculations where correctness is critical.

### VII. Hooks & Riverpod State Management

All client-side state MUST be managed through Riverpod providers.
Flutter Hooks MUST be used for lifecycle-bound state in widgets.
Direct `setState` usage is prohibited outside of trivial,
leaf-level widgets with no shared state. Provider architecture
MUST follow the pattern: repository → service → provider → UI.
State MUST be immutable; mutations MUST produce new state objects.

**Rationale**: A single, consistent state management approach
eliminates ambiguity, simplifies debugging, and makes the
codebase accessible to new contributors.

### VIII. Ecosystem Package Design

Reusable functionality MUST be extracted into packages within the
OpenBudget monorepo that can be consumed independently. Each
package MUST have its own pubspec.yaml, README, and test suite.
Packages MUST NOT depend on application-level code. Inter-package
dependencies MUST form a directed acyclic graph—circular
dependencies are prohibited. Public API surfaces MUST be
explicitly exported and documented.

**Rationale**: Well-scoped packages enable code reuse across
OpenBudget applications and allow the community to adopt
individual components without importing the entire system.

### IX. Continuous Delivery

Shorebird MUST be used for over-the-air code push on iOS and
Android to deliver patches without app store review cycles.
The CI/CD pipeline MUST produce verifiable, reproducible builds.
Devenv MUST be the standard tool for managing project scripts,
dependencies, and development environment setup so that every
contributor has an identical local environment. All deployable
artifacts MUST be tagged with a semantic version.

**Rationale**: Rapid, reliable delivery reduces the feedback loop
between development and users, and Shorebird enables critical
fixes to reach users in minutes rather than days.

### X. Strict Code Quality

The project MUST enforce strict lint rules derived from Flutter
best practices (flutter_lints or stricter). All warnings MUST
be treated as errors in CI. The latest stable versions of
dependencies MUST be tracked; dependency updates MUST occur at
least monthly. Code MUST follow Effective Dart guidelines.
Generated code (Serverpod, Riverpod, Freezed) MUST be committed
and kept in sync with source definitions.

**Rationale**: Strict linting catches bugs early, enforces
consistency, and keeps the codebase welcoming to contributors
who expect idiomatic Dart/Flutter patterns.

## Technology Stack & Constraints

- **Framework**: Flutter (latest stable) targeting iOS, Android,
  Web, macOS, Windows, Linux
- **Backend**: Serverpod (latest stable) with PostgreSQL
- **State Management**: Riverpod + Flutter Hooks
- **Code Push**: Shorebird (iOS and Android)
- **Dev Environment**: Devenv for reproducible toolchains and
  scripts
- **Language**: Dart (latest stable via Flutter SDK)
- **Testing**: `flutter_test`, `integration_test`, Serverpod
  test utilities
- **Linting**: `flutter_lints` (strict mode) or equivalent with
  all warnings as errors
- **Code Generation**: Serverpod protocol generation, Riverpod
  code generation, Freezed for immutable models
- **CI/CD**: Automated build, test, lint, and deploy pipeline
  (provider TBD)
- **Minimum Supported Platforms**: iOS 16+, Android API 26+,
  Chrome/Edge/Firefox latest two versions, macOS 13+,
  Windows 10+, Ubuntu 22.04+

## Development Workflow & Monetization Strategy

### Development Workflow

1. **Branch Strategy**: Feature branches from `main`; pull
   requests require passing CI and at least one review.
2. **Commit Discipline**: Conventional Commits format.
   Generated code changes MUST be in dedicated commits.
3. **Testing Gate**: CI MUST run unit, widget, and integration
   tests. PRs with failing tests MUST NOT merge.
4. **Lint Gate**: CI MUST run lint checks. PRs with lint
   violations MUST NOT merge.
5. **Code Review**: Every PR MUST be reviewed for adherence to
   this constitution's principles before merge.

### Monetization Strategy

The core budgeting experience MUST remain free. Revenue is
generated through optional premium subscriptions:

- **Finance Techniques Library**: Curated, AI-enhanced budgeting
  strategies, debt payoff plans, and savings methodologies
  delivered as subscribable content.
- **Investment Strategy Packs**: AI-driven portfolio suggestions,
  rebalancing alerts, and cross-border tax optimisation tools.
- **Crypto Intelligence**: Advanced crypto portfolio tracking,
  DeFi yield analysis, and tax-lot accounting.
- **Multi-Currency Pro**: Enhanced exchange rate providers,
  historical rate access, and automated conversion rules.
- **Enterprise / Family Plans**: Shared budgets with role-based
  access, consolidated reporting, and priority support.

Additional revenue ideas to explore:

- Affiliate partnerships with financial service providers
  (brokerages, banks, crypto exchanges) with transparent
  disclosure.
- Anonymised, aggregated spending insights sold to research
  firms (opt-in only, GDPR/CCPA compliant).
- White-label API access for fintech partners wanting to embed
  OpenBudget's budgeting engine.

## Governance

This constitution is the highest-authority document for the
OpenBudget project. All pull requests, code reviews, and
architectural decisions MUST comply with the principles defined
above.

### Amendment Procedure

1. Propose an amendment via a pull request modifying this file.
2. The PR description MUST state: the principle(s) affected,
   the rationale for the change, and the version bump category
   (MAJOR / MINOR / PATCH).
3. At least two maintainers MUST approve the amendment PR.
4. Upon merge, `LAST_AMENDED_DATE` MUST be updated to the merge
   date and `CONSTITUTION_VERSION` incremented per semver rules.

### Versioning Policy

- **MAJOR**: Removal or backward-incompatible redefinition of an
  existing principle.
- **MINOR**: Addition of a new principle or material expansion of
  existing guidance.
- **PATCH**: Clarifications, typo fixes, non-semantic rewording.

### Compliance Review

- Every feature spec MUST include a constitution compliance
  check before implementation begins.
- Quarterly reviews SHOULD audit active features against the
  current constitution version.
- Violations discovered post-merge MUST be filed as bugs with
  `constitution-violation` label and resolved within the next
  sprint.

**Version**: 1.0.0 | **Ratified**: 2026-02-14 | **Last Amended**: 2026-02-14
