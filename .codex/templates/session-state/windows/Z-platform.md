# Window: Z-platform

## Responsibility

Owns the project's platform and tooling layer: engine configuration, build/export
pipeline, CI/CD, project-specific tooling, and adaptation of the CFG framework
base (Skills, Hooks, route index, workflow docs, guardrails) to fit this
project's engine, conventions, and pipeline.

Z adapts the framework to the project — it does not maintain the upstream CFG
framework itself. When a Skill, Hook, route, or workflow doc must change to
serve this project, Z owns that change.

Does not normally own game design conclusions, gameplay implementation, art
production, or QA sign-off.

## Current Objective

<current-objective>

## Scope

- Owns:
  - `production/session-state/windows/Z-platform.md`
  - Project platform assets: engine config, build/export pipeline, CI config,
    and project-specific tooling scripts
  - CFG framework base, customized for this project:
    - `.agents/skills/`
    - `.codex/docs/`
    - `.codex/hooks/`
    - `.codex/hooks.json`
    - `.codex/rules/`
    - `.githooks/`
- Reads:
  - `AGENTS.md`
  - `production/session-state/active.md`
  - `production/session-state/windows/*.md`
  - `.codex/docs/skill-route-index.yaml`
  - `.codex/docs/workflow-catalog.yaml`
- Avoids:
  - Gameplay implementation unless explicitly assigned
  - Art and production assets unless explicitly assigned
  - QA verdicts unless explicitly assigned
  - Project design conclusions unless routed through the owning lane

## Active Files

- `production/session-state/windows/Z-platform.md` - current lane state.

## Progress

- [x] Z-platform lane created.
- [ ] Confirm this project's engine, build/export pipeline, and which framework
  customizations it needs.

## Decisions

- <YYYY-MM-DD>: Z-platform is the project platform and framework-adaptation lane.

## Blockers / Needs From Other Windows

- Needs A-producer when a framework change affects production workflow scope.
- Needs the owning lane when a framework change changes how that lane writes state or evidence.

## Handoff

Last updated: <YYYY-MM-DD>

Completed:
- Created Z-platform lane state.

Changed files:
- `production/session-state/windows/Z-platform.md`

Tests:
- Not run; lane bootstrap only.

Open blockers:
- Waiting for an assigned platform, tooling, or framework-adaptation task.

Next step:
- Read the assigned task and check route/workflow impact before editing the
  framework base or platform config.

Restart prompt:
You are taking over the Z-platform lane. Read `AGENTS.md`, `.codex/docs/context-management.md`, `.codex/docs/multi-window-workflow.md`, `production/session-state/active.md`, and `production/session-state/windows/Z-platform.md`, then continue from the lane handoff.
