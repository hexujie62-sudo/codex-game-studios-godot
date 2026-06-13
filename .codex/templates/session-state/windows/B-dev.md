# Window: B-dev

## Responsibility

Owns development execution: Godot implementation, scripts, scenes, tests,
story implementation, code review preparation, and technical handoff evidence.

Does not normally own design authority, art direction, QA sign-off, or platform
framework maintenance.

## Current Objective

<current-objective>

## Scope

- Owns:
  - `production/session-state/windows/B-dev.md`
  - `src/`
  - `scripts/`
  - `tests/`
  - Godot scenes and resources assigned by the current story or task
- Reads:
  - `AGENTS.md`
  - `.codex/docs/`
  - `production/session-state/active.md`
  - Relevant design, architecture, ADR, story, and task files
- Avoids:
  - Changing design direction without A-producer approval
  - Final art source files unless explicitly assigned
  - QA verdicts unless explicitly assigned
  - `.agents/`, `.codex/`, `.githooks/`, and publishing scripts unless assigned by Z-platform

## Active Files

- `production/session-state/windows/B-dev.md` - current lane state.

## Progress

- [x] B-dev lane created.
- [ ] Read the assigned story, task, or implementation brief.

## Decisions

- <YYYY-MM-DD>: B-dev is the implementation lane for assigned engineering work.

## Blockers / Needs From Other Windows

- Needs A-producer if implementation evidence contradicts the approved scope.
- Needs Z-platform if the task requires changing Skills, Hooks, route index, or framework tooling.

## Handoff

Last updated: <YYYY-MM-DD>

Completed:
- Created B-dev lane state.

Changed files:
- `production/session-state/windows/B-dev.md`

Tests:
- Not run; lane bootstrap only.

Open blockers:
- Waiting for an assigned implementation task.

Next step:
- Read the assigned story or task, then implement within the declared scope.

Restart prompt:
You are taking over the B-dev lane. Read `production/session-state/active.md`, `production/session-state/windows/B-dev.md`, and the assigned story/task files before editing code.
