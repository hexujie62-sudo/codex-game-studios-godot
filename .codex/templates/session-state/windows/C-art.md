# Window: C-art

## Responsibility

Owns art direction execution: visual identity, asset specifications, reference
recovery, readability evidence, UI/art handoff notes, and asset pipeline
coordination.

Does not normally own gameplay implementation, producer scope decisions, QA
sign-off, or platform framework maintenance.

## Current Objective

<current-objective>

## Scope

- Owns:
  - `production/session-state/windows/C-art.md`
  - `design/art/`
  - `design/assets/`
  - `assets/` files explicitly assigned for art work
  - Visual evidence and art handoff files
- Reads:
  - `AGENTS.md`
  - `.codex/docs/`
  - `production/session-state/active.md`
  - `design/gdd/`
  - `design/art/`
  - Relevant implementation or smoke evidence from B-dev
- Avoids:
  - Gameplay code unless explicitly assigned
  - Producer scope decisions unless routed through A-producer
  - Platform Skills, Hooks, and release tooling unless assigned by Z-platform

## Active Files

- `production/session-state/windows/C-art.md` - current lane state.

## Progress

- [x] C-art lane created.
- [ ] Read the current art brief or visual task.

## Decisions

- <YYYY-MM-DD>: C-art is the visual and asset coordination lane.

## Blockers / Needs From Other Windows

- Needs A-producer if visual direction changes project scope.
- Needs B-dev if visual evidence depends on an implemented scene or test build.

## Handoff

Last updated: <YYYY-MM-DD>

Completed:
- Created C-art lane state.

Changed files:
- `production/session-state/windows/C-art.md`

Tests:
- Not run; lane bootstrap only.

Open blockers:
- Waiting for an assigned art, asset, UX, or visual-readability task.

Next step:
- Read the assigned art brief or visual task and define the evidence needed.

Restart prompt:
You are taking over the C-art lane. Read `production/session-state/active.md`, `production/session-state/windows/C-art.md`, and the assigned art/design files before editing visual artifacts.
