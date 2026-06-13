---
name: gate-check
description: "验证在开发阶段之间推进的就绪状态。生成带有具体阻碍和必需工件的通过/关注/失败的判定。当用户说'我们是否准备好进入 X'、'我们可以进入生产阶段吗'、'检查我们是否可以开始下一阶段'、'通过关卡'时使用。"
argument-hint: "[target-phase: systems-design | technical-setup | pre-production | production | polish | release]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, AskUserQuestion
model: opus
---

# Phase Gate Validation

`/gate-check` 是 CFG 的正式阶段门检查。它只给 readiness verdict，不替用户推进阶段，不制造缺失文件来让 gate 通过。

Verdicts:

- `PASS` — 关键工件与质量条件满足。
- `CONCERNS` — 可以前进，但风险必须被记录并由用户接受。
- `FAIL` — 有阻塞项，建议先处理。

Gate report 可以在用户批准后写入 `production/gate-checks/`。当 gate 涉及玩家体验、视觉质量、动作可读性、canon 一致性或跨线质量冲突时，必须读取或要求 `D-director` verdict。

## CFG State Policy

生产阶段不使用 Epic/Story/Sprint 状态机。不要要求、读取或推荐：

- `production/epics/`
- `production/sprints/`
- `production/sprint-status.yaml`
- `/sprint-plan`
- `/dev-story`
- `/story-done`
- `/smoke-check`

生产阶段只认：

- `production/work-orders/*.md`
- `production/session-state/active.md`
- `production/session-state/windows/*.md`
- B-dev / C-art / A-producer delivery or evidence files
- D-director verdict files
- `production/project-canon.md` when canon/player-facing quality is relevant

## Parse Arguments

Target phase is the first argument. If no argument is provided, detect current stage from `production/stage.txt` or visible artifacts, then ask the user to confirm the transition before running.

Stage order:

1. Concept
2. Systems Design
3. Technical Setup
4. Pre-Production
5. Production
6. Polish
7. Release

When a `PASS` gate is complete and the user explicitly confirms advancement, update `production/stage.txt` to the new stage.

## Gate Definitions

### Concept -> Systems Design

Required:

- `design/gdd/game-concept.md`
- core fantasy, player promise, pillars/anti-pillars
- Visual Identity Anchor or equivalent visual direction seed

Quality:

- core loop described clearly enough to decompose into systems
- first complete playable/validation scope is named
- major unanswered concept risks are listed

Recommended:

- concept prototype/report if the core loop is unproven

### Systems Design -> Technical Setup

Required:

- `design/gdd/systems-index.md`
- MVP/core system GDDs needed for first playable scope
- cross-GDD consistency review or explicit accepted gaps
- `design/art/art-bible.md` at least visual identity foundation if art direction affects architecture

Quality:

- system dependencies are mapped
- acceptance criteria are testable
- design docs do not contradict canon or art direction

### Technical Setup -> Pre-Production

Required:

- Godot version/tooling pinned in `AGENTS.md` or `.codex/docs/technical-preferences.md`
- `project.godot` or explicit Godot project creation plan
- `docs/engine-reference/godot/VERSION.md`
- `docs/architecture/architecture.md` or accepted architecture plan sufficient for the next prototype/work order
- ADRs for foundation/core decisions that block implementation
- minimal test/runtime check path recorded

Quality:

- Godot API risks are noted for the pinned version
- architecture has clear module ownership and handoff boundaries
- B-dev can execute without inventing architecture mid-task

### Pre-Production -> Production

Required:

- first production queue exists in `production/session-state/active.md` or a named A-producer handoff
- work-order template/protocol is present at `production/work-orders/README.md`
- at least one ready production work order exists in `production/work-orders/`
- D-director method is available when the work touches player-facing quality
- required B/C evidence format is clear for the first work order

Quality:

- work orders include Scope, Non-scope, Delivery Spec, Stop Conditions, owner lane, and evidence requirements
- first playable/prototype risks are either validated or explicitly accepted
- A-producer owns priority/queue decisions
- D-director owns canon/player-facing verdicts

### Production -> Polish

Required:

- core gameplay path is playable end-to-end or the remaining gap is explicitly scoped
- active production work orders for core loop are closed or have accepted D/A verdicts
- B-dev evidence covers runtime/config/test claims
- C-art evidence covers visual/readability/capture claims
- critical blockers are recorded with owner lane and next action

Quality:

- tests/runtime checks pass or failures are documented as accepted risks
- player-facing quality has D-director verdict when relevant
- no unresolved cross-lane ownership conflict blocks polish

### Polish -> Release

Required:

- release candidate build path or export plan
- critical/high bugs triaged
- release checklist or equivalent launch readiness document
- store/platform/legal/localization needs identified when applicable
- final D/A decision for player-facing readiness

Quality:

- performance and stability evidence exists for target platform
- known risks are acceptable for release
- rollback/patch path is recorded

## Run The Gate

For each required item:

- use `Glob`, `Read`, and `Grep` to verify existence and meaningful content
- mark unverified subjective items as `MANUAL CHECK NEEDED`
- ask the user only for checks that cannot be verified from files
- never infer PASS from absence of evidence

For production gates, read relevant work orders and lane state before judging readiness. If the gate closes a specific directed effort, read the D verdict and B/C evidence for that effort.

## D-director Assessment

If the gate depends on player experience, visual quality, motion readability, cross-line presentation, or canon consistency, read:

- `production/project-canon.md`
- `production/session-state/windows/D-director.md`
- relevant `production/work-orders/*.md`
- delivered evidence from B-dev/C-art/A-producer

Output:

```text
D-director Assessment:
- Verdict: PASS / PARTIAL PASS / FAIL / INVALID / MISSING
- Evidence: [paths]
- Effect on gate: [eligible / minimum CONCERNS / minimum FAIL]
```

Rules:

- D `PASS` -> eligible for PASS if other checks pass.
- D `PARTIAL PASS` -> minimum `CONCERNS`.
- D `FAIL` or `INVALID` -> minimum `FAIL`.
- Missing required D verdict -> minimum `CONCERNS`, or `FAIL` if it blocks phase safety.

## Output

```text
## Gate Check: [Current Phase] -> [Target Phase]

Date: [date]
Checked by: gate-check skill

Required Artifacts: [X/Y present]
- [x] [path] — [evidence]
- [ ] [path] — MISSING / INCOMPLETE
- [?] [item] — MANUAL CHECK NEEDED

Quality Checks: [X/Y passing]
- [x] [check]
- [ ] [check]
- [?] [check]

D-director Assessment:
- [include when relevant]

Blockers:
1. [blocking item and owner lane]

Recommendations:
- [priority action]
- [optional risk reduction]

Chain-of-Verification:
- [N] challenge questions checked; verdict [unchanged/revised]

Verdict: PASS / CONCERNS / FAIL
```

## Chain-of-Verification

Before finalizing, ask five challenge questions designed to disprove the draft verdict. At least two must be answered by re-reading a specific file or re-running a specific grep/check. Revise the verdict if the challenge reveals missed blockers or overstated failures.

## Update Stage On PASS

If verdict is `PASS`, ask:

```text
Gate passed. May I update `production/stage.txt` to `[Target Stage]`?
```

Only write after the user confirms.

## Closing Next Step

Close with 2-3 practical options tailored to the result:

- missing design/art/architecture -> relevant Skill
- production queue/scope issue -> `A-producer` via `/window-cfg A`
- player-facing verdict issue -> `D-director` via `/window-cfg D`
- code/runtime evidence issue -> `B-dev`
- art/capture/readability evidence issue -> `C-art`
- framework/routing issue -> `Z-platform`

Verdict is advisory. The user decides whether to proceed despite concerns.

