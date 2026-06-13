# Window: <lane-id>

## Responsibility

<lane-responsibility>

## Current Objective

<current-objective>

## Scope

- Owns:
  - `production/session-state/windows/<lane-id>.md`
  - <owned-paths>
- Reads:
  - `AGENTS.md`
  - `.codex/docs/`
  - `production/session-state/active.md`
  - <reference-paths>
- Avoids:
  - Files owned by other active lanes unless there is an owner handoff
  - Broad unrelated refactors
  - Publishing, destructive changes, commits, or branch changes without explicit authorization

## Active Files

- `production/session-state/windows/<lane-id>.md` - current lane state.

## Progress

- [x] <lane-id> lane created.
- [ ] Read the assigned objective and define owner boundaries.

## Decisions

- <YYYY-MM-DD>: <lane-id> created for <lane-title>.

## Blockers / Needs From Other Windows

- None.

## Handoff

Last updated: <YYYY-MM-DD>

Completed:
- Created <lane-id> lane state.

Changed files:
- `production/session-state/windows/<lane-id>.md`

Tests:
- Not run; lane bootstrap only.

Open blockers:
- None.

Next step:
- Continue the assigned objective within this lane's scope.

Restart prompt:
You are taking over the <lane-id> lane. Read `production/session-state/active.md`, `production/session-state/windows/<lane-id>.md`, and the assigned task files before editing.
