# CFG Director Gates

This document replaces the legacy CCGS multi-director panel. The old panel and
49-agent roster are archived outside this repository.

## Authority

`D-director` is the primary cross-line verdict lane for this project. It裁决
player experience, visual quality, motion readability, cross-line presentation,
and canon consistency.

Professional lenses such as art, technical, QA, design, or narrative may be
reintroduced later only when there is a concrete need. They are not default
agents and are not required for routine CFG work.

## Review Model

CFG review uses evidence, not routine human sign-off:

1. The execution lane performs owner self-checks and domain evidence appropriate
   to its lane: B-dev runtime/program evidence, C-art visual/capture evidence.
2. The execution lane records evidence in its handoff or report.
3. D-director reads `production/project-canon.md`, the active work order, and the
   delivered evidence.
4. D-director returns one of: `PASS`, `PARTIAL PASS`, `FAIL`, or `INVALID`.
5. If canon facts change, D-director updates `production/project-canon.md`.

D must not directly edit execution artifacts. If work is needed, D writes a
narrow work order under `production/work-orders/` and routes it to A/B/C through
lane blocker/request notes.

## Gate Outcomes

| Verdict | Meaning | Action |
|---|---|---|
| `PASS` | Evidence and player-facing target are acceptable. | Freeze the work order or move to the next scoped step. |
| `PARTIAL PASS` | Direction is valid but targeted fixes remain. | Write a narrow follow-up work order. |
| `FAIL` | Main target failed or a structural issue appeared. | Reject the delivery and write a corrected work order. |
| `INVALID` | Required evidence is missing or causality is unreadable. | Return to the execution lane for missing evidence; do not裁决观感. |

## Escalation To Human

D-director stops and reports to the human producer when:

- a frozen decision must be overturned;
- the same issue fails to converge after two narrow repair rounds;
- a new failure mode is outside `director-review` guidance;
- a core gameplay/canon decision must be changed;
- execution evidence suggests systematic unreported drift or self-certification.

Human input should focus on requirements and player experience, not routine
transport of work between lanes.

## Relationship To `/gate-check`

`/gate-check` no longer spawns a fixed four-director panel. It should:

- read the relevant lane state and evidence;
- verify required artifacts exist;
- surface missing evidence as `CONCERNS` or `FAIL`;
- request or reference D-director verdict when the gate depends on player
  experience, visual quality, cross-line presentation, or canon consistency.

Execution lanes cannot self-certify final player-facing acceptance. They can
provide runtime smoke results, test evidence, screenshots, compare grids, and
self-checks as lane-owned domain evidence.

