# CFG Operating Checklist

Purpose: a short runtime checklist for Codex windows and Z-platform maintenance.
Read this before exploring the full framework when the task is about CFG
architecture, window routing, Skill governance, work orders, hooks, checkpoints,
or generated artifacts.

This file is an index and checklist. It is not the source of project canon,
work-order scope, or lane handoff content.

## Read Order

For framework or lane-flow questions, read in this order:

1. `AGENTS.md`
2. `.codex/docs/cfg-operating-checklist.md`
3. `production/session-state/active.md`
4. relevant `production/session-state/windows/<lane>.md`
5. only then read the specific authority file listed below

Do not start by searching the whole repo unless the checklist fails to identify
the owner or source.

## Authority Map

| Question | Read / Update |
|---|---|
| What framework is active? | `AGENTS.md`, `docs/ccgs-codex-architecture.md` |
| Which command should be used? | `.codex/docs/skill-route-index.yaml` |
| What phase / workflow step applies? | `.codex/docs/workflow-catalog.yaml` |
| How do windows recover and route work? | `.codex/docs/multi-window-workflow.md` |
| What is the active queue / current focus? | `production/session-state/active.md` |
| What does this lane own next? | `production/session-state/windows/<lane>.md` |
| What is the work-order scope/verdict? | `production/work-orders/<code>.md` |
| What is canon/player-facing truth? | `production/project-canon.md` |
| How are generated files governed? | `.codex/docs/generated-artifact-governance.md` |
| How are commits/checkpoints scoped? | `.codex/docs/git-checkpoint-workflow.md` |
| What hooks exist and what do they guard? | `.codex/docs/hooks-reference.md`, `.codex/hooks/`, `.githooks/` |

## Current Command Surface

Core user-facing Skills:

- `/start`
- `/help`
- `/window-cfg`
- `/skill-create-cfg`
- `/setup-engine`
- `/brainstorm`
- `/design-system`
- `/art-bible`
- `/create-architecture`
- `/code-review`
- `/bug-report`
- `/gate-check`
- `/release-checklist`

Support/optional Skills:

- `/director-review`
- `/visual-dev-methodology`

No active CFG command should route to removed sprint/story/smoke Skills.

## Runtime Loops

### New Session / Recovery

1. Read `AGENTS.md`.
2. Read `active.md`.
3. Recover the lane with `/window-cfg <lane>`.
4. Read referenced work order or verdict only if the lane handoff/blocker points
   to one.
5. Continue from the lane `Next step`; do not reconstruct from chat.

### Work Order Execution

1. A-producer maintains the active queue in `active.md`.
2. D-director writes work orders in `production/work-orders/`.
3. Target lane reads its assigned section only.
4. Target lane executes inside owner paths only.
5. Target lane writes evidence/report/handoff.
6. D-director reads evidence and records `PASS`, `PARTIAL PASS`, `FAIL`, or
   `INVALID`.

### Queue And Scope Control

Active queue fields live in `active.md`:

```text
ID:
Owner lane:
Status: queued / active / delivered / verdict / blocked / closed / deferred
Priority:
Blocked by:
Next decision:
```

This replaces old sprint/story status for active CFG production.

### B/C Domain Evidence

- B-dev owns runtime/program evidence, smoke checks, integration tests, and
  implementation reports.
- C-art owns visual/capture evidence, screenshots, compare grids, visual smoke,
  and art reports.
- D-director judges player-facing quality/canon. D does not create missing B/C
  evidence except for isolated reading experiments used only to support a
  verdict.

### Skill Change

1. Use `/skill-create-cfg`.
2. Decide `KEEP`, `MODIFY`, `REWRITE`, `MERGE`, `DELETE`, `ROUTE-ONLY`,
   `REFERENCES-ONLY`, `NEW`, or `BLOCKED`.
3. Update all touched surfaces: Skill body, route index, workflow catalog, hook
   reminders, test spec/catalog, generated artifact governance, and lane state
   when relevant.
4. Do not leave renamed/deleted commands as active compatibility entries.

### Generated Artifact

Before any Skill creates or updates a durable file, answer:

```text
Artifact:
Owner:
Consumer:
Lifetime:
Update trigger:
Stale condition:
Directory:
Enforcer:
Conflict risk:
Verdict:
```

If no owner, consumer, or update trigger exists, do not generate the file.

### Architecture Artifact

`/create-architecture` writes architecture docs, ADRs, traceability, and control
manifests only when a named consumer exists: B-dev, `/code-review`,
`/gate-check`, or a named work order.

Existing files under `docs/architecture/` are prototype snapshot context unless
`docs/architecture/README.md` and the active work order say they are current.

### Checkpoint

1. Run `/window-cfg checkpoint <lane-id>` or manually follow
   `.codex/docs/git-checkpoint-workflow.md`.
2. Stage only named files.
3. Keep rollback unit to one lane/domain unless A-producer approves a cross-lane
   checkpoint.
4. Commit body must include `Lane`, `Scope`, `Verification`, and `Rollback`.
5. Never use `git add .`.

## Stop Conditions

Stop and route before continuing when:

- work crosses owner paths;
- scope expands beyond a work order;
- player-facing acceptance/canon is being changed without D-director;
- a generated file lacks owner/consumer/maintenance trigger;
- a lane file becomes a long report instead of recovery state;
- a command or hook points to removed CFG routes;
- a commit would mix unrelated B/C/D/Z changes.

## Maintenance

Owner: Z-platform.

Update this file whenever:

- a core Skill is added, removed, renamed, or reclassified;
- a hook is added or deleted;
- work-order flow changes;
- queue/status fields change;
- generated artifact governance changes;
- architecture artifact lifecycle changes;
- default lane responsibilities change.


