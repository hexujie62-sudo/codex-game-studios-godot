# CFG Multi-Window Workflow

`/window-cfg` is the current CFG multi-window command.

Core principle:

```text
The lane file is recovery state.
The artifact file is source of truth.
The chat is disposable.
```

## What Changed From Legacy CCGS

- The inherited 49-agent studio hierarchy is not active.
- `D` means `D-director`.
- D-director裁决 cross-line player experience, visual quality, motion readability,
  and canon consistency.
- B-dev and C-art keep their current domain evidence duties: B owns
  runtime/program evidence, and C owns visual/capture evidence. No separate QA
  lane is created by default right now.
- Work orders are persisted under `production/work-orders/` and owned by
  D-director.
- Current project facts live in `production/project-canon.md` and are maintained
  by D-director.

## State Files

```text
production/session-state/
├── active.md
└── windows/
    ├── A-producer.md
    ├── B-dev.md
    ├── C-art.md
    ├── D-director.md
    ├── Z-platform.md
    └── <custom-lane-id>.md
```

`active.md` records project focus, last touched lane, registered windows, and
the active work-order queue when production work is running.
Lane-specific recovery state stays in the lane file.

## Default Lanes

| Lane | Responsibility | Default owner paths |
|---|---|---|
| `A-producer` | Scope, sequencing, active project state, lane coordination, design sync planning. | `production/session-state/active.md`, A lane, `production/design-sync/`, scope/gate coordination docs. |
| `B-dev` | Code, scenes/scripts, runtime/program evidence, smoke checks, integration evidence, implementation reports. | `scripts/`, `scenes/`, `tests/`, `production/dev-tasks/`, B lane. |
| `C-art` | Visual execution, assets, screenshots, compare grids, visual/capture evidence, visual smoke, art reports. | `design/art/`, `design/assets/`, `assets/`, visual scenes/scripts when assigned, artifacts, C lane. |
| `D-director` | Final verdicts on player experience/visual quality/cross-line presentation/canon, work orders, canon. | `production/project-canon.md`, `production/work-orders/`, D lane. |
| `Z-platform` | CFG framework, Skills, hooks, route/index, workflow docs, tooling guardrails. | `.agents/skills/`, `.codex/`, `.githooks/`, `docs/ccgs-*`, Z lane. |

Custom lanes are allowed when a real workstream benefits from separate recovery
state. They are not a substitute for D verdicts or owner rules.

## Starting Or Recovering A Lane

Use:

```text
/window-cfg A
/window-cfg B
/window-cfg C
/window-cfg D
/window-cfg Z
/window-cfg <custom-lane-id>
```

Explicit `/window-cfg <lane-id>` authorizes low-risk lane creation/recovery and
registry bookkeeping. Do not ask again for that bookkeeping. Ask again before
compaction, destructive changes, publishing, branch strategy changes, or
freeze-breaking design/architecture decisions.

`D`, `director`, and `D-director` recover the D-director lane. `qa` is not an
alias for D. If formal independent QA becomes necessary later, create a new lane
at that time.

## Lane State Template

```markdown
# Window: [lane-id]

## Responsibility
...

## Current Objective
...

## Scope
- Owns:
- Reads:
- Avoids:

## Active Files
- `[path]` - editing owner: [lane]; reason: ...

## Progress
- [x] ...

## Decisions
- [date] ...

## Blockers / Needs From Other Windows
- ...

## Handoff
Last updated: [YYYY-MM-DD HH:mm]
Completed:
- ...
Changed files:
- ...
Tests:
- ...
Open blockers:
- ...
Next step:
- ...
Restart prompt:
...
```

Lane files are recovery indexes, not full reports. Long evidence belongs in
work orders, implementation reports, art reports, smoke reports, or canon.

## Work Order Flow

Work orders are the D-director command and verdict loop.

1. A-producer records the active work-order queue in `production/session-state/active.md`.
   Queue items use work-order IDs only; CFG does not create Epic/Story/Sprint
   status files as a second production state source.
2. D-director writes `production/work-orders/<code>.md`.
3. 每份 D-issued work order 必须包含 `授权范围 / Scope`,`非范围 / Non-scope`,
   `交付规格 / Delivery Spec`, and `停止条件 / Stop Conditions`.
4. D-director 在目标 A/B/C lane 写入可执行 blocker/request,包含工单/verdict 路径、
   目标 lane,以及"完成后回报 D"的指令。这是 handoff,不是要求用户重贴工单。
5. The execution lane performs the work only in its owner paths and only inside the assigned scope.
6. 交付前,执行 lane 必须按 `交付规格 / Delivery Spec` 自检证据。
7. 执行 lane 在自己的 handoff/report 中记录证据,并给 D 留一条 blocker/request 表示工单已交付。
8. D-director 读取工单、证据和 `production/project-canon.md`,然后记录 `PASS`, `PARTIAL PASS`, `FAIL`, 或 `INVALID`。不符合
   `交付规格 / Delivery Spec` 的交付应判 `INVALID`;D 不替执行窗口重切、补做或加工交付物,除非只是核验证据来源,或做一次只服务于裁决阅读的隔离实验。
9. D-director updates canon only when a canon fact changed.

`production/work-orders/` is the only work-order root. A/B/C learn assigned work
from their lane blocker/request notes, which must point to that canonical path.
Do not create or preserve parallel work-order directories.

D-director does not edit execution artifacts under `scripts/`, `assets/`,
`design/`, or platform artifacts under `.codex/` / `.agents/`.

用户语言规则:任何需要用户/制作人理解、确认或审计的工单、verdict、blocker/request、canon 更新、handoff 摘要或回报,必须使用当前用户语言。技术标识符保留原文拼写。

执行窗口接活规则:当 A/B/C lane 的 blocker/request 指向 `production/work-orders/`
下的工单或 verdict,用户只需要说"继续"、"处理"、"按总监 verdict"等短指令。
除非用户明确说"只总结/先别执行",执行窗口应直接读取对应文件并执行本 lane 段落,
不得要求用户复制长工单。

## Queue And Scope Control

`sprint-plan`, Epic, Story, and `production/sprint-status.yaml` are not CFG's
active production state machine. Queue and scope control live here instead:

- A-producer owns the active queue in `active.md`.
- D-director owns work-order scope, non-scope, delivery spec, stop conditions,
  verdict, and canon updates.
- B-dev/C-art own execution evidence in their reports and lane handoffs.
- A/B/C lanes must stop and request A/D decision when work would cross scope,
  touch another owner path, or change player-facing acceptance criteria.

Recommended active queue fields:

```text
ID:
Owner lane:
Status: queued / active / delivered / verdict / blocked / closed
Priority:
Blocked by:
Next decision:
```

## File Ownership Rules

| Path | Owner | Other lane rule |
|---|---|---|
| `production/project-canon.md` | D-director | Others read or request updates through D. |
| `production/work-orders/` | D-director | Others read assigned work orders; do not rewrite D verdicts. |
| `.agents/skills/` | Z-platform | Others request changes; Z executes framework updates. |
| `.codex/` | Z-platform | Others read unless Z/A explicitly route a framework task. |
| `.githooks/` | Z-platform | Others do not edit. |
| `docs/ccgs-*` | Z-platform | Compatibility-named CFG framework docs. |
| `production/session-state/active.md` | A-producer | Others update only when owning lane takeover or handoff requires registry bookkeeping. |
| `production/session-state/windows/<id>.md` | Corresponding lane | Other lanes only add blocker/request notes when routing work. |
| `design/gdd/`, `design/V2/`, `production/design-sync/` | A-producer or assigned design lane | B/C/D/Z read unless routed. |
| `scripts/`, `scenes/`, `tests/`, `production/dev-tasks/` | B-dev | C/D/Z read unless routed; D writes work orders, not code. |
| `design/art/`, `design/assets/`, `assets/`, visual artifacts | C-art | B/D/Z read unless routed; D writes verdict/work order, not art assets. |
| `production/qa/` | Created when formal QA lane exists; otherwise B/C evidence by domain | Do not create a default QA lane until needed. |

## Active Files Protocol

Each lane declares active file ownership in its `## Active Files` section. If the
same path appears in more than one lane, that is a file conflict.

Resolution options:

- handoff;
- request;
- split;
- D-director verdict for experience/canon conflicts;
- A-producer sequencing for scope/schedule conflicts;
- Z-platform decision for framework paths.

## Review And Acceptance

Execution lanes produce domain evidence and self-checks. They cannot
self-certify final player-facing acceptance.

- B-dev owns runtime/program evidence, including automated smoke checks and
  integration test logs.
- C-art owns visual/capture evidence, including screenshots, compare grids, and
  visual smoke.
- D-director owns verdicts for player-facing presentation and canon.
- Human escalation is for requirements, player experience, freeze-breaking
  upgrades, or unresolved uncertainty.

## Checkpoints

Checkpoint policy lives in `.codex/docs/git-checkpoint-workflow.md`.

Single-lane checkpoint rule:

- Work order/canon/D lane changes -> D-director checkpoint.
- Execution artifact changes -> owner execution lane checkpoint.
- Framework/Skill/hook/route changes -> Z-platform checkpoint.
- Cross-lane commits require explicit A-producer scope decision.

Do not use `git add .`.

## Research Worktrees

Use `/window-cfg research <lane-id> <slug>` for isolated experiments. Research
worktrees must not switch the shared worktree branch out from under other lanes.

## Compaction

Lane files should stay short recovery indexes.

- Soft threshold: 220 lines.
- Hard threshold: 300 lines.

Use `/window-cfg compact <lane-id>` only with explicit user approval. Archive
the full old lane before rewriting the current lane.

## Daily Recovery Rhythm

1. Read `active.md`.
2. Recover the relevant lane with `/window-cfg <lane-id>`.
3. Read any assigned work order and required canon.
4. Execute within owner paths.
5. Write evidence to artifacts/reports.
6. Refresh lane handoff.
7. Route D verdict if needed.

