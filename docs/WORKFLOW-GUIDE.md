# CFG Workflow Guide

This guide describes the current Codex-first, Godot-focused CFG workflow. CFG is
a deep-modified CCGS descendant, but old story/sprint production is not the
active operating model.

The machine-readable route layer lives in `.codex/docs/workflow-catalog.yaml`
and `.codex/docs/skill-route-index.yaml`. Use `/help` when you want Codex to
inspect the project and recommend the next step.

For quick framework recovery or routing decisions, read
`.codex/docs/cfg-operating-checklist.md` before exploring the broader docs.

## Core Commands

| Area | Commands |
|---|---|
| Navigation | `/start`, `/help`, `/window-cfg`, `/skill-create-cfg` |
| Design | `/brainstorm`, `/design-system`, `/art-bible` |
| Technical setup | `/setup-engine`, `/create-architecture` |
| Production review | `/code-review`, `/bug-report`, `/gate-check`, `/release-checklist` |

## Multi-Window Lanes

| Lane | Responsibility |
|---|---|
| `A-producer` | Scope, priorities, active project state, work-order queue, cross-window coordination |
| `B-dev` | Godot code, scenes, runtime checks, integration evidence, implementation reports |
| `C-art` | Art direction execution, assets, screenshots, compare grids, visual evidence |
| `D-director` | Player-facing verdicts, visual/experience/canon consistency, work orders, canon |
| `Z-platform` | CFG Skills, Hooks, route index, workflow docs, tooling guardrails |

Lane state lives in `production/session-state/windows/`. Long-lived recovery
state belongs in lane files, not chat.

Use:

```text
/window-cfg A
/window-cfg B
/window-cfg C
/window-cfg D
/window-cfg Z
```

## Production Flow

CFG production is work-order driven.

1. A-producer maintains the active queue in `production/session-state/active.md`.
2. D-director writes work orders under `production/work-orders/`.
3. D-director writes executable blocker/request notes into target A/B/C lane files.
4. The target lane executes only its assigned section and only inside owner paths.
5. B-dev/C-art produce domain evidence in reports, tests, captures, or handoffs.
6. D-director reads evidence and records `PASS`, `PARTIAL PASS`, `FAIL`, or `INVALID`.
7. Canon changes go through `production/project-canon.md`.

Do not create Epic, Story, Sprint, or `production/sprint-status.yaml` as active
production state. Deleted story/sprint commands are not fallback routes.

## Work Order Fields

Each active work order should include:

- `代号 / Code`
- `目标窗口 / Target lane`
- `背景 / Context`
- `授权范围 / Scope`
- `非范围 / Non-scope`
- `交付规格 / Delivery Spec`
- `通过门 / Pass gates`
- `失败旋钮 / Allowed failure knobs`
- `停止条件 / Stop Conditions`
- `回流方式 / Return path`

Scope changes stop in the execution lane and route back to A-producer or
D-director. Execution lanes do not widen scope on their own.

## Skill Governance

Use:

```text
/skill-create-cfg
```

for Skill creation, updates, deletion, renaming, route changes, test spec
updates, and workflow insertion.

The governance flow must decide whether a capability should be a new Skill,
modify an existing Skill, become references-only/route-only, or be deleted. Any
Skill that writes files must define owner, consumer, lifetime, update trigger,
stale condition, directory, enforcer, and conflict risk before it is accepted.
The durable artifact matrix lives in `.codex/docs/generated-artifact-governance.md`.

`/create-architecture` follows the same rule: architecture docs, ADRs,
traceability, and control manifests are written only when they have a named
consumer such as B-dev, code-review, gate-check, or a work order.

## Checkpoints

Checkpoint plans live under `/window-cfg checkpoint <lane-id>`. They must stage
only named files and include:

```text
Lane:
Scope:
Verification:
Rollback:
```

Do not use `git add .`.

## Practical Rules

- Use `/help` instead of guessing when the next workflow step is unclear.
- Use `/window-cfg audit` before multi-lane checkpoints.
- Keep lane files short recovery indexes; put full evidence in reports or work orders.
- Ask before destructive changes, publishing, branch strategy changes, or high-risk architecture/design decisions.
