# Skill Test Spec: /start

## Skill Summary

`/start` 是 Codex Game Studios 的首次引导入口。它不直接假设用户的
game concept、engine 偏好或当前阶段，而是先读取项目工件，再把用户路由到
合适的下一步。

本 fork 使用多窗口 lane 保存长期状态，所以 `/start` 必须先检查窗口状态：
如果项目还没有任何 `production/session-state/windows/*.md`，`/start` 应在内部
引导创建最小 `A-producer` 总控 lane，然后继续原本 onboarding。它不应要求用户
先退出 `/start` 再运行另一个窗口命令。

`/start` 可以写入 `production/stage.txt`。stage 写入只能发生在用户完成起点选择
之后。`/start` 不再创建、读取或标准化 `production/review-mode.txt`；审查标准固定
为 Lean 口径，不再要求用户选择 full/lean/solo。

---

## Static Assertions

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has at least two phase headings
- [ ] Contains `Phase 0: Window Lane Bootstrap`
- [ ] Can bootstrap `A-producer` lane before onboarding phases
- [ ] Contains a `single-window` override path
- [ ] Contains verdict keywords: `COMPLETE` and `BLOCKED`
- [ ] Contains the project-state detection inputs: technical preferences, game concept, source code, prototypes, design docs, production artifacts
- [ ] Ends with a handoff instead of auto-running the next Skill

---

## Test Cases

### Case 1: Fresh Project With No Lane State

**Fixture:**

- No `production/session-state/windows/*.md`
- No `production/session-state/active.md`
- No `design/gdd/game-concept.md`

**Input:** `/start`

**Expected behavior:**

1. Skill checks lane state before asking about game concept.
2. Skill explains that it will create a minimal `A-producer` lane before continuing.
3. Skill asks permission to write `production/session-state/windows/A-producer.md`.
4. If approved, Skill writes the lane and continues into Phase 1 project-state detection.
5. Skill does not write `production/stage.txt` until the user makes the corresponding onboarding choice.
6. Skill does not create or normalize `production/review-mode.txt`.

**Assertions:**

- [ ] `/start` remains the first user entry.
- [ ] No `BLOCKED` verdict is used merely because lane state is missing.
- [ ] Lane creation is gated behind "May I write".
- [ ] After lane setup, normal onboarding can continue.

### Case 2: User Explicitly Chooses Single-Window

**Fixture:**

- No lane files exist.

**Input:** `/start single-window`

**Expected behavior:**

1. Skill skips the lane bootstrap because the user explicitly opted out.
2. Skill warns that recovery and parallel coordination will not be written to a lane.
3. Skill proceeds to normal onboarding.

**Assertions:**

- [ ] Warning mentions `/window-ccgs A` can be run later.
- [ ] The skill still follows normal write approval rules.
- [ ] No lane file is created by `/start`.

### Case 3: Existing Lane State

**Fixture:**

- `production/session-state/windows/A-producer.md` exists.
- `production/session-state/active.md` may or may not exist.

**Input:** `/start`

**Expected behavior:**

1. Skill recognizes that the project has entered the lane system.
2. Skill continues to project-state detection.
3. Skill asks where the user's game idea currently is.

**Assertions:**

- [ ] The lane bootstrap does not block.
- [ ] The onboarding options A/B/C/D are shown.
- [ ] No duplicate lane creation is suggested as the primary action.

### Case 4: Custom Lane Exists But No Producer Lane

**Fixture:**

- `production/session-state/windows/systems-design.md` exists.
- `production/session-state/windows/A-producer.md` does not exist.

**Input:** `/start`

**Expected behavior:**

1. Skill treats the project as lane-enabled.
2. Skill continues onboarding.
3. Skill reminds the user that long-running projects should also have a control lane such as `/window-ccgs A`.

**Assertions:**

- [ ] Custom lane is accepted as valid lane state.
- [ ] `/window-ccgs A` appears as a reminder, not as a blocker.

### Case 5: Returning Project

**Fixture:**

- Engine is configured in `.codex/docs/technical-preferences.md`.
- `design/gdd/game-concept.md` exists.
- At least one lane file exists.

**Input:** `/start`

**Expected behavior:**

1. Skill detects that basic setup already exists.
2. Skill does not restart onboarding by default.
3. Skill summarizes current engine, concept file, and Lean review policy.
4. Skill suggests continuing with an appropriate next command such as `/help`, `/design-system`, or the current required step.

**Assertions:**

- [ ] Existing configuration is not overwritten.
- [ ] The user is not asked to recreate already existing concept work.
- [ ] Verdict is `COMPLETE` or a clear handoff is provided.

### Case 6: Stage Write And Fixed Lean Review Policy

**Fixture:**

- Lane state exists.
- `production/stage.txt` is missing.
- `production/review-mode.txt` is missing.

**Input:** `/start`

**Expected behavior:**

1. Skill only writes `production/stage.txt` after the user chooses an onboarding path.
2. Skill does not create, read, or normalize `production/review-mode.txt`.
3. Skill states the fixed Lean review policy as conversation guidance only.
4. The stage value maps to the documented stage mapping.

**Assertions:**

- [ ] Stage write happens after path selection, not before.
- [ ] No full/lean/solo review-mode prompt appears.
- [ ] Review mode file is not created.
- [ ] No unrelated files are modified.

---

## Protocol Compliance

- [ ] `/start` may create the initial `A-producer` lane during first onboarding.
- [ ] `/start` does not auto-run the next Skill.
- [ ] If no lane exists, `/start` bootstraps lane state instead of blocking.
- [ ] If the user explicitly opts into single-window mode, `/start` can proceed but warns about the tradeoff.
- [ ] File writes are limited to documented startup state files; `production/review-mode.txt` is not created or normalized.

---

## Coverage Notes

- This spec intentionally treats multi-window lane setup as a first-class entry
  concern because this fork is Codex-first and file-backed.
- The exact content of game concept questions is tested by authoring Skills, not
  by this utility spec.
- `/help` is responsible for ongoing route recommendations after startup.
