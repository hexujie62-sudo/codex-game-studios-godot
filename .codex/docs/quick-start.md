# CFG Quick Start

CFG is the active framework for this project. It is a deep-modified CCGS-derived
workflow, but the inherited 49-agent studio model is no longer active.

## First Reads

1. `AGENTS.md` - runtime charter and tool rules.
2. `production/session-state/active.md` - current project focus and registered lanes.
3. `.codex/docs/multi-window-workflow.md` - lane recovery and ownership model.
4. `.codex/docs/skill-route-index.yaml` - Skill routing.
5. `production/project-canon.md` - current project facts.

## Main Loop

```text
/help or /window-cfg <lane>
-> read lane state
-> use the relevant Skill
-> write or execute within lane ownership
-> record evidence/handoff
-> D-director裁决 player-facing or cross-line outcomes when needed
```

## Default Lanes

| Lane | Role |
|---|---|
| `A-producer` | Scope, sequencing, active project state, lane coordination. |
| `B-dev` | Implementation, runtime smoke, integration evidence. |
| `C-art` | Visual execution, screenshots, compare grids, visual smoke. |
| `D-director` | Cross-line verdicts, work orders, canon. |
| `Z-platform` | CFG framework, Skills, hooks, route/index, docs, tooling. |

Use `/window-cfg D` for the D-director lane. D reads
`.agents/skills/director-review/SKILL.md` and `production/project-canon.md`
before裁决 deliveries.

The old CCGS agent roster can be restored from the parent legacy archive only if
a concrete future task needs a narrow specialist perspective.

