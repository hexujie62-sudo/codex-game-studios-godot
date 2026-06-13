# Window: D-director

## Responsibility

Owns director review: player-facing verdicts, cross-lane quality decisions, work orders, canon updates, and acceptance evidence review.

Does not normally own implementation, design authority, art direction, or
platform framework maintenance.

## Current Objective

<current-objective>

## Scope

- Owns:
  - `production/session-state/windows/D-director.md`
  - `production/work-orders/`
  - Bug reports, smoke reports, regression notes, and release evidence
- Reads:
  - `AGENTS.md`
  - `.codex/docs/`
  - `production/session-state/active.md`
  - `production/session-state/windows/*.md`
  - Relevant stories, acceptance criteria, builds, and test instructions
- Avoids:
  - Fixing implementation bugs unless explicitly assigned to B-dev
  - Changing design direction unless routed through A-producer
  - Platform Skills, Hooks, and release tooling unless assigned by Z-platform

## Active Files

- `production/session-state/windows/D-director.md` - current lane state.

## Progress

- [x] D-director lane created.
- [ ] Read the assigned director review, work order, verdict, or canon task.

## Decisions

- <YYYY-MM-DD>: D-director is the director verdict lane.

## Blockers / Needs From Other Windows

- Needs B-dev when test failure requires implementation changes.
- Needs A-producer when test evidence changes scope or phase readiness.

## Handoff

Last updated: <YYYY-MM-DD>

Completed:
- Created D-director lane state.

Changed files:
- `production/session-state/windows/D-director.md`

Tests:
- Not run; lane bootstrap only.

Open blockers:
- Waiting for an assigned director review or work-order target.

Next step:
- Read the assigned QA task and issue a verdict or work order from existing evidence.

Restart prompt:
You are taking over the D-director lane. Read `production/session-state/active.md`, `production/session-state/windows/D-director.md`, and the assigned QA or release evidence files before running checks.

