---
name: setup-engine
description: "Godot-only 技术设置入口。固定 Godot 版本、GDScript、工具路径、engine reference 和最小测试基础；不再提供 Unity/Unreal 多引擎选择。"
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

## Phase 2: Write Technical Preferences

准备 `.codex/docs/technical-preferences.md` 更新草稿，至少包含：

- Engine: Godot `[version]`
- Language: GDScript
- Runtime target: Godot project with `project.godot`
- Source paths: `src/`, `scenes/`, `scripts/`, `addons/` as applicable
- Asset paths: `assets/`, `design/assets/`
- Test paths: `tests/unit/`, `tests/integration/`, `tests/helpers/`
- Godot command: local console executable if known, otherwise placeholder
- Engine reference: `docs/engine-reference/godot/VERSION.md`

写入前询问：

```text
May I update .codex/docs/technical-preferences.md with this Godot setup?
```

---

## Phase 3: Engine Reference

如果 `docs/engine-reference/godot/VERSION.md` 缺失，创建最小版本记录：

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

如果本机 Godot console path 已知，建议一次轻量检查：

```text
[Godot console] --headless --path . --quit
```

不要强制运行。没有可执行路径时，只把它记录为 setup concern。

检查并报告：

- `project.godot` 是否存在。
- `addons/` 是否存在且可能影响测试。
- `src/`、`scenes/`、`scripts/` 是否存在。
- `.godot/`、`.import/` 等生成目录不应作为设计事实来源。

---

## Phase 5: Minimal Godot Test Foundation

这一步只建立测试基础，不替代 `/smoke-check`。

如果 `tests/` 缺失，准备最小结构：

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

写入前询问：

```text
May I create the minimal Godot test foundation under tests/?
```

如果项目已有自己的测试框架，不覆盖；只记录 detected framework 和 gaps。

---

## Phase 6: Output

输出保持短：

```text
Godot setup
- Version: [version]
- Language: GDScript
- Project file: found / missing
- Technical preferences: updated / unchanged / blocked
- Engine reference: current / created / needs refresh
- Test foundation: present / created / concern
- Next: /brainstorm, /design-system, /create-architecture, or /smoke-check

Verdict: COMPLETE / CONCERNS / BLOCKED
```

不要推荐旧测试命令或多引擎命令。
