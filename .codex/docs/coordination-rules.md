# CFG Coordination Rules

CFG coordinates work through lanes, Skills, work orders, canon, and lightweight
hooks. The inherited 49-agent hierarchy is archived outside this repository and
is not part of the active architecture.

## Core Rules

1. **Lane Ownership**: Each long-running workstream owns a lane file under
   `production/session-state/windows/`.
2. **Artifact Ownership**: Lanes edit only their owner domains unless a work
   order or explicit handoff says otherwise.
3. **D-director Verdicts**: Player experience, visual quality, motion
   readability, cross-line presentation, and canon consistency go to
   `D-director`.
4. **A-producer Coordination**: `A-producer` coordinates scope, sequencing,
   active project state, and lane routing. It does not replace D-director as the
   experience verdict point.
5. **Execution Evidence**: `B-dev` and `C-art` run their own implementation or
   visual smoke checks and record evidence. They do not self-certify final
   player-facing acceptance.
6. **Work Orders**: D-director assigns cross-line or verdict-driven work through
   `production/work-orders/`, then references the work order path in the target
   lane's blocker/request section.
7. **Canon Updates**: Current project facts live in `production/project-canon.md`
   and are maintained by D-director.

## Active Lanes

- `A-producer` - scope, sequencing, active state, lane coordination.
- `B-dev` - implementation, runtime smoke, integration evidence.
- `C-art` - visual execution, screenshots, compare grids, visual smoke.
- `D-director` - verdicts, work orders, canon.
- `Z-platform` - CFG framework, Skills, hooks, route/index, docs, tooling.

No separate QA lane is created by default at this stage. If formal independent
QA becomes necessary later, create a dedicated lane then.

## Optional Specialist Perspectives

Specialist perspectives may be added back only for concrete needs:

- Stable method or repeatable workflow -> create or update a Skill.
- One-off professional lens -> add a narrow agent or use a temporary subtask.
- Mutable project fact -> write canon, not a Skill.
- Execution task -> write a work order for the owner lane.

## Parallel Work

Use parallel work only when inputs are independent and file ownership does not
overlap. If two lanes need the same artifact, use one of:

- handoff;
- request;
- split into separate artifacts;
- D-director verdict if it is an experience/canon conflict;
- A-producer sequencing if it is a scope or scheduling conflict.

