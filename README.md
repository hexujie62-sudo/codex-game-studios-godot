# Codex Game Studios for Godot

> Multi-window parallel lanes for Codex + Godot 4.x — stop babysitting one AI window.

<p>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License"></a>
  <a href=".codex/agents"><img src="https://img.shields.io/badge/agents-49-blueviolet" alt="49 Agents"></a>
  <a href=".agents/skills"><img src="https://img.shields.io/badge/skills-17%20core-green" alt="17 Core Skills"></a>
  <a href=".codex/hooks"><img src="https://img.shields.io/badge/codex%20hooks-5-orange" alt="5 Codex Hooks"></a>
  <a href="https://godotengine.org/"><img src="https://img.shields.io/badge/Godot-4.x-478cbf" alt="Godot 4.x"></a>
</p>

[中文说明](#中文说明) · [Quick Start](#quick-start) · [Documentation](#documentation)

---

## Why This Fork?

If you've used Claude Code Game Studios for a real project, you've probably hit these walls:

| Pain | What happens | How this fork fixes it |
|------|-------------|----------------------|
| **One window, one bottleneck** | 49 agents sharing one context window. Confirmations pile up. Context overflows. | **Multi-window lanes** — production, dev, art, QA each get their own window and state file. |
| **Context dies on compaction** | Long sessions lose earlier decisions. Handoff between sessions is unreliable. | **File-backed state** — lanes persist to disk. Resume exactly where you left off. |
| **No Codex support** | CCGS is built for Claude Code. Codex users are left out. | **Codex-first** — docs, hooks, skill routing, and context recovery designed around Codex. |
| **Token burn on repeat reads** | Re-reading files on every session start wastes tokens. | **State in files, not chat history** — new windows read lane files, not old transcripts. |
| **Generic multi-engine template** | You're building in Godot, but the framework treats every engine the same. | **Godot 4.x + GDScript by default** — engine-specific assumptions built in, not bolted on. |

Adapted from [Claude Code Game Studios](https://github.com/anthropics/claude-code-game-studios), released under the MIT License.

---

## Quick Start

```bash
git clone https://github.com/hexujie62-sudo/codex-game-studios-godot.git my-game-studio
cd my-game-studio
codex
```

First session:

```text
/start
```

Open another work lane:

```text
/window-ccgs B
```

That's it. `/start` bootstraps your producer lane and walks you through onboarding. Use `/help` when you're not sure what to do next.

---

## Compared With Original CCGS

| Area | Original CCGS | This Fork |
|---|---|---|
| Primary ecosystem | Claude Code | **Codex** |
| Work style | Single-window serial flow | **Multi-window parallel lanes** |
| Context recovery | Depends on chat history | **File-backed session state** |
| Skill management | Many slash commands | **Route index + Skill tests + governance** |
| Hook model | Claude/CC-oriented | **Codex-oriented lightweight reminders** |
| Engine stance | Multi-engine template | **Godot 4.x first** |
| Best fit | General AI game studio | **Long-running AI Godot projects** |

---

## Documentation

### Multi-Window Lanes

The core idea: **each responsibility track runs in its own Codex window with a persistent state file.**

A lane is not just "another chat window." It's a recoverable responsibility track — a window reads its lane on start, works within that scope, and writes back a handoff at useful checkpoints.

**Why this matters for long projects:**

- **Less context weight** — the dev window doesn't carry the full art discussion.
- **Reliable handoff** — important decisions live in lane files, not only in chat history.
- **Clearer parallel work** — production, development, art, QA have separate ownership.
- **Easier conflict handling** — the producer lane decides ownership before edits collide.

<details>
<summary><strong>Default lanes</strong></summary>

| Lane | Responsibility |
|---|---|
| `A` | Producer — scope, priorities, cross-window coordination |
| `B` | Development — implementation, stories, tests |
| `C` | Art — visual direction, asset specs, production notes |
| `D` | QA — bugs, smoke checks, release readiness |
| `Z` | Platform — skills, hooks, route index, system docs |

Custom lanes work too:

```text
/window-ccgs ui-polish
```

Lane state lives under `production/session-state/`.

</details>

<details>
<summary><strong>Recommended workflow</strong></summary>

1. Start the producer lane first:

```text
/window-ccgs A
```

2. Start focused lanes as needed:

```text
/window-ccgs B
/window-ccgs C
/window-ccgs D
```

3. Update the lane before closing or switching:

```text
/window-ccgs update B
```

4. Resume from the lane file:

```text
/window-ccgs B
```

**Core rule:** long-lived state belongs in the lane body; the latest handoff is only the most recent recovery point. Do not copy a whole old conversation into a new window.

</details>

### Git Checkpoints

Commits are treated as recovery checkpoints — small, explainable, tied to one lane, easy to `git revert`.

```text
/window-ccgs checkpoint B
```

The checkpoint flow produces scoped file lists and conventional commit messages with `Lane:`, `Scope:`, `Verification:`, and `Rollback:` fields.

For experimental work, use research worktrees:

```text
/window-ccgs research Z skill-experiment
/window-ccgs merge Z
```

### Skill Governance

`/skill-create-ccgs` is the entry point for adding or modifying Skills. It decides whether to create, modify, merge, update the route index, or defer — instead of blindly adding another command.

<details>
<summary><strong>How Skill governance works</strong></summary>

A proper Skill integration considers:

- `.agents/skills/<skill-name>/SKILL.md`
- `CCGS Skill Testing Framework/skills/...`
- `CCGS Skill Testing Framework/catalog.yaml`
- `.codex/docs/skill-route-index.yaml`

Three questions before writing a command:

- **Should this exist as a Skill?** Avoid turning temporary game taste or project-specific assumptions into permanent commands.
- **Where should it connect?** If routing is the issue, update the route index. If an existing Skill owns the job, modify or merge instead.
- **How do we prove it works?** Add or update test specs and catalog entries.

Example:

```text
/skill-create-ccgs
I want a Godot UI generation Skill that turns a UX spec into Control node structure and GDScript bindings.
```

</details>

---

## What's Included

| Category | Count | Notes |
|---|---:|---|
| Agents | 49 | Production, design, programming, art, audio, narrative, QA, release, platform |
| Skills | 17 core | Routed through `skill-route-index.yaml` |
| Codex Hooks | 5 | Session start, context recovery, dangerous command reminders |
| Git Hooks | 2+ | Pre-commit checks, checkpoint reminders, lane-state sanity |
| Docs | Full set | Architecture, collaboration protocol, checkpoint workflow, multi-window guide |

---

## Godot Boundary

This fork is Godot-first. Default assumptions are Godot 4.x and GDScript.

It does not lock your game to a genre, art style, camera style, input mode, or platform. Those are project-level design decisions and should stay out of permanent Skills.

---

## Framework Boundary

This is the CCGS/Codex/Godot workflow base, not a private game project. It does not include game design drafts, session state, unreleased prototypes, API keys, or unverified AI assets.

---

## Contributing

Contributions welcome, especially around:
- Codex workflow stability
- Godot-first development experience
- Multi-window context recovery
- Skill routing and test coverage
- Documentation clarity

---

## License & Attribution

MIT License. This project is a modified derivative of [Claude Code Game Studios](https://github.com/anthropics/claude-code-game-studios).

Original copyright: `Copyright (c) 2026 Donchitos`

See [LICENSE](LICENSE) and [NOTICE.md](NOTICE.md).

## Brand Notice

Unofficial project. Not affiliated with, endorsed by, or sponsored by OpenAI, Anthropic, Claude, Codex, Godot, or the original CCGS author.

---

## 中文说明

### 为什么做这个 fork？

如果你用过 CCGS，可能遇到过这些问题：

- 所有 agent 挤在一个窗口里，上下文溢出，确认不停
- 会话太长后上下文压缩，之前的决策丢失
- 不支持 Codex，只能用 Claude Code
- 每次开新窗口要重新读一遍文件，浪费 token
- 多引擎模板，Godot 没有专门优化

这个 fork 针对这些问题做了改造：**多窗口并行 lane、文件持久化状态、Codex-first、Godot 4.x 专属优化**。

### 快速开始

```bash
git clone https://github.com/hexujie62-sudo/codex-game-studios-godot.git my-game-studio
cd my-game-studio
codex
```

第一次运行输入 `/start`，不知道做什么输入 `/help`。

### 多窗口怎么用

```text
/window-ccgs A          # 总控窗口（制作人）
/window-ccgs B          # 开发窗口
/window-ccgs C          # 美术窗口
/window-ccgs D          # QA 窗口
/window-ccgs Z          # 底层维护窗口
/window-ccgs update B   # 交接当前窗口状态
/window-ccgs ui-polish  # 自定义 lane
```

长期状态写在 lane 主体，最近恢复点写在 handoff。不要把整段旧对话复制到新窗口。

### Skill 治理

新增或改造 Skill 时先运行 `/skill-create-ccgs`，它会判断应该新增、修改、合并还是暂缓，而不是无条件多加一个命令。

---

MIT License. See [LICENSE](LICENSE) and [NOTICE.md](NOTICE.md).
