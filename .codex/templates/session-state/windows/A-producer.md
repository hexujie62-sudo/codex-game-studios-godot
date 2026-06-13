# Window: A-producer

## Responsibility

Owns project control: scope, stage, priority, milestone direction,
cross-window coordination, owner decisions, and next-step routing.

Does not normally own implementation, art production, QA execution, or platform
framework maintenance.

## Current Objective

<current-objective>

## Scope

- Owns:
  - `production/session-state/active.md`
  - `production/session-state/windows/A-producer.md`
  - `production/sprints/`
  - `production/milestones/`
  - `production/gates/`
  - Cross-window owner decisions and phase recommendations
- Reads:
  - `AGENTS.md`
  - `.codex/docs/`
  - `design/gdd/`
  - `production/session-state/windows/*.md`
  - `.codex/docs/workflow-catalog.yaml`
- Avoids:
  - Gameplay implementation unless explicitly assigned
  - Source assets unless explicitly assigned
  - Platform Skills, Hooks, route index, or publishing scripts unless assigned by Z-platform

## Active Files

- `production/session-state/active.md` - project-level state and lane registry.
- `production/session-state/windows/A-producer.md` - current lane state.

## Progress

- [x] A-producer lane created.
- [ ] Define current project scope and next production step.

## Decisions

- <YYYY-MM-DD>: A-producer is the project control lane.

## Blockers / Needs From Other Windows

- None.

## Handoff

Last updated: <YYYY-MM-DD>

Completed:
- Created A-producer lane state.

Changed files:
- `production/session-state/active.md`
- `production/session-state/windows/A-producer.md`

Tests:
- Not run; lane bootstrap only.

Open blockers:
- None.

Next step:
- Continue `/start` onboarding or run `/help` to choose the next workflow step.

Restart prompt:
You are taking over the A-producer lane. Read `AGENTS.md`, `.codex/docs/context-management.md`, `.codex/docs/multi-window-workflow.md`, `production/session-state/active.md`, and `production/session-state/windows/A-producer.md`, then continue from the lane handoff.
