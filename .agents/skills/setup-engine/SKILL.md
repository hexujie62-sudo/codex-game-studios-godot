---
name: setup-engine
description: "Godot-only technical setup entrypoint. Pin Godot version, GDScript, tool paths, engine reference, and minimal test foundation without low-value setup confirmations."
argument-hint: "[godot-version | refresh | upgrade]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, WebSearch, WebFetch, AskUserQuestion
model: sonnet
---

# Setup Engine

本 Skill 是 Godot-only。它吸收旧 `test-setup` 中“测试框架初始化”的引擎设置部分。
更深的 QA、回归和证据检查由 `/smoke-check` 处理。

如果用户要求配置 Unity、Unreal 或其他引擎，说明本 fork 的核心管线是
Godot-focused；不要把多引擎选择逻辑写回本 Skill。

---

## Reference Loading Rules

Do not read `.agents/skills-archive/` during normal use. Old `test-setup`
behavior has been extracted into `references/godot-test-foundation.md`.

Read that reference when the user asks for test setup, test helpers, Godot
runtime validation, CI/test command wiring, or when `/smoke-check` reports that
the test foundation is missing.

---

## Phase 1: Resolve Godot Version

读取：

1. `AGENTS.md`
2. `.codex/docs/technical-preferences.md`
3. `docs/engine-reference/godot/VERSION.md`
4. `project.godot`（如果存在）

版本来源优先级：

1. 用户参数中的版本，例如 `4.6.2`。
2. `AGENTS.md` 的 Engine / Local Tool Paths。
3. `.codex/docs/technical-preferences.md`。
4. `docs/engine-reference/godot/VERSION.md`。

如果仍无法确定版本，问一个短问题：

```text
Which Godot 4.x version should this project pin?
```

不要启动引擎选择问卷。

---

## Phase 2: Build Godot Setup Package

准备一个 Godot setup package，而不是对每个文件分别询问。package 至少包含：

- `.codex/docs/technical-preferences.md` update:
  - Engine: Godot `[version]`
  - Language: GDScript
  - Runtime target: Godot project with `project.godot`
  - Source paths: `src/`, `scenes/`, `scripts/`, `addons/` as applicable
  - Asset paths: `assets/`, `design/assets/`
  - Test paths: `tests/unit/`, `tests/integration/`, `tests/helpers/`
  - Godot command: local console executable if known, otherwise placeholder
  - Engine reference: `docs/engine-reference/godot/VERSION.md`
- `docs/engine-reference/godot/VERSION.md` create/update if missing or stale.
- Minimal `tests/` foundation if missing.
- Runtime check plan and whether it can run now.

### Routine Setup Execution Boundary

When the user invokes `/setup-engine`, treat that command as an explicit request
to complete the routine low-risk Godot setup scope. Do not ask a separate
package-approval question for normal setup bookkeeping.

Write the following directly when the needed facts are known or can be inferred:

- `.codex/docs/technical-preferences.md` updates.
- `docs/engine-reference/godot/VERSION.md` creation or refresh from local known
  facts.
- Minimal `tests/` directories and `tests/README.md`.
- Recording setup concerns such as missing `project.godot`, missing local Godot
  console path, or skipped runtime validation.
- Read-only local version checks when a Godot console path exists.

If a required fact is missing and materially affects the setup, ask one short
question for that fact. State that after the user answers, Codex will finish the
routine setup. When the user provides the missing fact, continue the setup
directly; do not ask again with "May I update..." or another write approval.

Ask again only before work outside routine setup, such as creating a new Godot
project file, installing tools, changing branch/release strategy, deleting or
overwriting existing project-specific configuration, or making broad
architecture choices.

---

## Phase 3: Engine Reference

如果 `docs/engine-reference/godot/VERSION.md` 缺失，纳入 Phase 2 setup package 并创建最小版本记录：

```markdown
# Godot Version Reference

Pinned version: [version]
Language: GDScript
Project file: project.godot
Reference status: local / refreshed
```

如果用户使用 `refresh`，只查 Godot 官方来源并更新 Godot reference，不查询 Unity
或 Unreal。

如果版本明显超出模型可靠知识范围，标记：

```text
Engine reference risk: verify APIs against official Godot docs before implementation.
```

---

## Phase 4: Godot Runtime Check

如果本机 Godot console path 已知且 `project.godot` 存在，运行一次轻量检查：

```text
[Godot console] --headless --path . --quit
```

这是只读验证，不需要额外批准。没有可执行路径或没有 `project.godot` 时，只把它记录为 setup concern。

检查并报告：

- `project.godot` 是否存在。
- `addons/` 是否存在且可能影响测试。
- `src/`、`scenes/`、`scripts/` 是否存在。
- `.godot/`、`.import/` 等生成目录不应作为设计事实来源。

---

## Phase 5: Minimal Godot Test Foundation

这一步只建立测试基础，不替代 `/smoke-check`。

如果 `tests/` 缺失，把最小结构纳入 Phase 2 setup package：

```text
tests/
  unit/
  integration/
  helpers/
  README.md
```

`tests/README.md` 应记录：

- pinned Godot version
- local/headless test command placeholder
- unit/integration/manual evidence boundaries
- where `/smoke-check` writes QA evidence

如果项目已有自己的测试框架，不覆盖；只记录 detected framework 和 gaps。

---

## Phase 6: Production Rejoin

After routine setup and validation, reconnect the user to the production
workflow instead of ending with a generic command menu.

Read `.codex/docs/workflow-catalog.yaml` and, if present, `production/stage.txt`.
Use the catalog only for next-step routing; do not duplicate `/help`'s full lane
and checkpoint report.

Determine the current phase:

1. If `production/stage.txt` exists, map its value to the matching workflow
   phase.
2. If no stage file exists, default to `concept` unless project artifacts clearly
   place the project later.

Within the current phase, scan steps in catalog order:

- A required step with an `artifact.glob` is complete when the glob has at least
  `min_count` matches and any `pattern` requirement matches at least one file.
- A required step with only an artifact `note` is `manual/unknown`; name the
  note instead of pretending it is complete.
- Optional steps can be listed only as secondary options; they must not displace
  the first missing required step.
- Treat the just-completed `engine-setup` / `test-setup` setup work as complete
  if the corresponding technical preferences, engine reference, or tests
  foundation was created or verified in this run.

Before choosing the catalog-required next step, check for explicit concept
prototype intent. Read `design/gdd/game-concept.md` if it exists. If the concept
document clearly declares a prototype or validation build as the first complete
scope, contains a `prototypes/...` path, or says the core feel/visual/technical
risk should be validated before full GDD work, then this project-specific
prototype is the immediate blocker after engine setup.

Prototype intent is considered unresolved when no matching
`prototypes/*/README.md` or `prototypes/*/REPORT.md` exists, or when the concept
names a specific prototype path and that path does not contain a README/REPORT.
In that case, choose `/brainstorm prototype` as the single primary next step,
even if later required Concept-stage documents such as the art bible or systems
index are missing. Explain that the old `/prototype` route is absorbed into
`/brainstorm`, and that the prototype validates the concept's first complete
scope before the document chain continues. Do not recommend prototype mode for a
generic concept that merely mentions future validation as a possible risk.

Choose exactly one primary next step:

- If explicit unresolved prototype intent exists, recommend `/brainstorm prototype`.
- First missing required step in the current phase.
- If all required steps in the current phase are complete, recommend
  `/gate-check [next-phase]` or the first required step of the next phase if a
  gate is not appropriate yet.
- If the next step has no command, explain the missing artifact and recommend
  `/help` only as a fallback navigator.

Special Concept-stage examples:

- Engine setup complete, `design/gdd/game-concept.md` missing → next
  `/brainstorm`.
- Engine setup complete, concept explicitly names a first-scope prototype or
  validation build and no prototype README/REPORT exists → next
  `/brainstorm prototype`.
- Engine setup complete, concept exists, `design/art/art-bible.md` missing →
  next `/art-bible`.
- Engine setup complete, concept and art bible exist, systems index missing →
  next `/design-system`.

If `project.godot` is missing, report it as a runtime validation concern, not a
reason to drop the user out of the design/art/architecture flow.

---

## Phase 7: Output

输出保持短：

```text
Godot setup
- Version: [version]
- Language: GDScript
- Project file: found / missing
- Technical preferences: updated / unchanged / blocked
- Engine reference: current / created / needs refresh
- Test foundation: present / created / concern
- Runtime validation: passed / skipped ([reason]) / failed

Production rejoin
- Where you are: [workflow phase label]
- Completed now: Engine Setup / Test Framework Setup
- Current blocker: [explicit prototype blocker, first missing required step, or "none in this phase"]
- Next: /[single recommended command]
- Why: [concept first-scope prototype reason, or catalog step description + artifact gap]

Verdict: COMPLETE / CONCERNS / BLOCKED
```

不要推荐旧测试命令或多引擎命令。不要输出一个无上下文的候选命令列表。
