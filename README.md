# Codex Game Studios for Godot

> Unofficial Codex-first, Godot-focused workflow kit adapted from Claude Code Game Studios.

[中文说明](#中文说明)

Codex Game Studios for Godot is an AI-assisted game development workflow kit for **Codex + Godot**.

It is not a game template. It is a project operating system for long-running AI-assisted game development: Skills, lightweight Hooks, route indexes, multi-window coordination, file-backed session state, release hygiene, and Skill governance.

This project is a modified derivative of `Claude Code Game Studios`, released under the MIT License.

<p>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License"></a>
  <a href=".codex/agents"><img src="https://img.shields.io/badge/agents-49-blueviolet" alt="49 Agents"></a>
  <a href=".agents/skills"><img src="https://img.shields.io/badge/skills-17%20core-green" alt="17 Core Skills"></a>
  <a href=".codex/hooks"><img src="https://img.shields.io/badge/codex%20hooks-5-orange" alt="5 Codex Hooks"></a>
  <a href="https://godotengine.org/"><img src="https://img.shields.io/badge/Godot-4.x-478cbf" alt="Godot 4.x"></a>
</p>

## What This Fork Changes

The original CCGS is strong because it splits game development into many specialized Agents and Skills. Its default operating model, however, is closer to a single long Claude Code session. That becomes fragile during long Codex projects: design rationale, implementation context, QA evidence, and handoff notes can get buried inside one growing conversation.

This fork keeps the studio-style structure, but moves the long-lived project memory into files that Codex can read, update, audit, and recover from.

- **Codex-first**: docs, Hooks, Skill routing, and context recovery are organized around Codex usage.
- **Godot-focused**: the default technical stack is Godot 4.x and GDScript.
- **Recoverable multi-window lanes**: production, development, art, QA, and platform maintenance can run in separate Codex windows.
- **File-backed state**: `production/session-state/` stores lane state so new windows do not need a copied chat transcript.
- **Checkpoint-aware Git workflow**: `/window-ccgs checkpoint` recommends scoped, rollback-friendly commits instead of broad `git add .` commits.
- **Research isolation**: uncertain or experimental work can run in a separate research worktree and merge back only after clean preflight.
- **Governed Skills**: route index, test specs, catalog entries, and `/skill-create-ccgs` keep Skills from becoming an unmanaged command pile.

## Compared With Original CCGS

| Area | Original CCGS | This Fork |
|---|---|---|
| Primary ecosystem | Claude Code | Codex |
| Work style | Single-window serial flow first | Multi-window lane workflow |
| Context recovery | More dependent on the current conversation | File-backed session state |
| Skill management | Many slash commands | Small core command set + route index + CCGS-specific creation flow |
| Hook model | Claude/CC-oriented semantics | Codex-oriented lightweight reminders |
| Engine stance | Multi-engine template | Godot-first |
| Best fit | General AI game studio framework | Long-running AI-first Godot development |

## Quick Start

```powershell
git clone https://github.com/<your-name>/codex-game-studios-godot.git my-game-studio
cd my-game-studio
codex
```

First session:

```text
/start
```

`/start` bootstraps the producer lane when lane state is missing, then continues the guided onboarding flow. Use `/window-ccgs` later when opening additional windows, updating handoffs, auditing lanes, or recovering an existing lane.

When you do not know what to do next:

```text
/help
```

Start or resume another work lane:

```text
/window-ccgs A
```

Update the lane before closing a window, switching tasks, or hitting long-context pressure:

```text
/window-ccgs update A
```

Ask whether the current lane is ready for a recoverable checkpoint:

```text
/window-ccgs checkpoint A
```

Start isolated research without switching the shared worktree branch:

```text
/window-ccgs research Z skill-experiment
```

Create or change a Skill through the CCGS governance flow:

```text
/skill-create-ccgs
```

## Multi-Window Lanes

The multi-window system is not just "open more chats". A lane is a recoverable responsibility track with a state file. A Codex window reads its lane on start, works within that responsibility, and writes back a handoff when the work reaches a useful checkpoint.

Why this is better for long-running projects:

- **Less context weight**: the dev window does not need the full art discussion; the QA window does not need every platform-maintenance decision.
- **More reliable handoff**: important decisions live in lane files, not only in chat history.
- **Clearer parallel work**: production, development, art, QA, and platform maintenance have separate ownership.
- **Easier conflict handling**: when two lanes need the same files, the producer lane decides ownership before edits collide.

Default shortcut lanes:

| Lane | Suggested Responsibility |
|---|---|
| `A` | Producer control: scope, phase, priorities, cross-window coordination |
| `B` | Godot development: implementation, story work, tests |
| `C` | Art and assets: visual direction, asset specs, production notes |
| `D` | QA: bugs, smoke checks, test evidence, release readiness |
| `Z` | Platform maintenance: Skills, Hooks, route index, test framework, system docs |

Recommended flow:

1. Start the producer lane first.

```text
/window-ccgs A
```

2. Start focused lanes as needed.

```text
/window-ccgs B
/window-ccgs C
/window-ccgs D
/window-ccgs Z
```

3. Update the lane before closing, switching tasks, long context compression, or cross-window handoff.

```text
/window-ccgs update B
```

4. Resume the same responsibility from the lane file.

```text
/window-ccgs B
```

Shortcut lanes are not hard-coded roles. You can create custom lanes too:

```text
/window-ccgs ui-polish
/window-ccgs update ui-polish
```

Lane state lives under:

```text
production/session-state/
```

Core rule: long-lived state belongs in the lane body; the latest handoff is only the most recent recovery point. Do not copy a whole old conversation into a new window.

## Git Checkpoints And Research Worktrees

Commits are treated as recovery checkpoints. They should be small enough to explain, tied to one lane when possible, and easy to roll back with `git revert`.

Use:

```text
/window-ccgs checkpoint <lane-id>
```

The checkpoint flow produces:

- files to stage;
- files to leave unstaged;
- a Conventional Commit subject;
- `Lane:`, `Scope:`, `Verification:`, and `Rollback:` body fields.

It must not use `git add .`. Automatic checkpoint commits are allowed only when a lane explicitly records `auto_checkpoint: true`, the file list is explicit, and `/window-ccgs audit` reports no conflicts.

For uncertain platform work or research directions, use:

```text
/window-ccgs research <lane-id> <slug>
/window-ccgs merge <lane-id>
```

Research work uses `codex/research/...` branches in separate worktrees so one window does not switch the branch under another window. Clean-only auto-merge is allowed only when the lane records that policy and the merge preflight passes.

## Skill Governance With `/skill-create-ccgs`

`/skill-create-ccgs` is the CCGS-specific entry point for adding or changing Skills. It is different from a generic skill creator: it first decides how the requested capability should enter the existing system.

It can decide that the right action is:

- create a new Skill;
- modify an existing Skill;
- add references only;
- update route index only;
- merge into an existing Skill;
- defer the change because the responsibility, trigger, or evidence boundary is unclear.

A proper Skill integration usually considers:

- `.agents/skills/<skill-name>/SKILL.md`
- `CCGS Skill Testing Framework/skills/...`
- `CCGS Skill Testing Framework/catalog.yaml`
- `.codex/docs/skill-route-index.yaml`
- related architecture or workflow docs

The point is to answer three questions before writing a command:

- **Should this exist as a Skill?** Avoid turning temporary game taste, art style, input scheme, or project-specific assumptions into permanent commands.
- **Where should it connect?** If routing is the issue, update the route index. If context is missing, add references. If an existing Skill owns the job, modify or merge instead.
- **How do we prove it works?** Add or update test specs and catalog entries so `/help`, route routing, and Skill tests can see the new capability.

Example:

```text
/skill-create-ccgs
I want a Godot UI generation Skill that turns a UX spec into Control node structure and GDScript bindings.
```

If that capability already belongs under `/art-bible`, `/design-system`, or `/dev-story`, `/skill-create-ccgs` should recommend modifying the existing route or Skill instead of blindly creating another command.

## What's Included

| Category | Count | Notes |
|---|---:|---|
| Agents | 49 | Production, design, programming, art, audio, narrative, QA, release, and platform roles |
| Skills | 17 core | Older CCGS micro-skills are folded into core Skills and routed through `.codex/docs/skill-route-index.yaml` |
| Codex Hooks | 5 | Session start, context recovery, dangerous command reminders, Skill-change reminders, and related lightweight checks |
| Git Hooks | 2+ | Local pre-commit checks, checkpoint reminders, owner-domain warnings, and lane-state sanity checks |
| Docs | Many | Architecture, collaboration protocol, checkpoint workflow, multi-window workflow, Hook adaptation, context management, and release docs |

## Godot Boundary

This fork is Godot-first. The default assumptions are Godot 4.x and GDScript.

It does not permanently lock your game to a genre, art style, camera style, input mode, or platform. Those are project-level design facts and should stay out of permanent Skills unless a specific project deliberately creates a project-local Skill for them.

Future Godot-focused Skills may cover areas such as UI generation, frame animation workflows, automated Godot tests, import settings, and editor-side validation.

## Public Release Boundary

If you publish this project to GitHub, publish the CCGS/Codex/Godot workflow base, not your private game project.

Do not publish the current working repository with `git add .`. A working repo may contain game design drafts, prototypes, production state, local paths, private context, or credentials.

Generate a clean public release directory instead:

```powershell
pwsh -File scripts/build-public-release.ps1
```

Default output:

```text
..\codex-game-studios-godot-public
```

The release builder uses a whitelist. It is meant to include the platform layer:

- `.agents/skills/`
- `.codex/agents/`
- `.codex/docs/`
- `.codex/hooks.json`
- `.codex/hooks/`
- `.codex/rules/`
- `.githooks/`
- `CCGS Skill Testing Framework/`
- public `docs/`
- `AGENTS.md`
- `LICENSE`
- `NOTICE.md`
- release scripts

It should not include:

- private game design drafts;
- private session state;
- unreleased prototype code or assets;
- API keys, accounts, SDK secrets, or local machine paths;
- unverified AI asset sources.

More publishing details:

```text
docs/GITHUB-PUBLISHING.md
```

GitHub listing copy and release notes:

```text
docs/GITHUB-LISTING-COPY.md
```

Machine-local publishing helper:

```powershell
pwsh -File scripts/setup-github-auth.ps1
pwsh -File scripts/publish-to-github.ps1
```

## License And Attribution

This project is a modified derivative of `Claude Code Game Studios`, which is released under the MIT License.

The original copyright notice must remain:

```text
Copyright (c) 2026 Donchitos
```

See [LICENSE](LICENSE) and [NOTICE.md](NOTICE.md).

## Brand Notice

This is an unofficial project.

It is not affiliated with, endorsed by, sponsored by, or officially maintained by OpenAI, Anthropic, Claude, Codex, Godot, or the original CCGS author.

Names such as `OpenAI`, `Codex`, `Claude`, `Anthropic`, and `Godot` belong to their respective owners and are used only to describe compatibility, origin, and intended usage.

## Contributing

Contributions are welcome, especially around:

- Codex workflow stability;
- Godot-first development experience;
- Skill routing and test coverage;
- multi-window context recovery;
- lightweight Hook and Git hook governance;
- documentation clarity.

Please avoid baking temporary game themes, fixed art styles, or one project's short-term assumptions into permanent platform Skills.

## 中文说明

这个仓库的公开 README 采用英文优先，是为了让 GitHub 上的国际用户更容易理解和搜索；中文说明保留在这里，方便中文使用者快速掌握核心用法。

### 项目定位

这个 fork 的目标不是增加更多命令，而是把原本偏单窗口、偏 Claude Code 的 CCGS 工作流，改造成更适合 Codex 长期使用的体系。

- **Codex-first**：文档、Hooks、Skill 路由、上下文恢复围绕 Codex 整理。
- **Godot-focused**：默认面向 Godot 4.x 和 GDScript。
- **多窗口可恢复**：把制作、开发、美术、QA、底层维护拆到不同 lane。
- **状态文件化**：通过 `production/session-state/` 保存 lane 状态，减少长上下文压缩或换窗口时的信息丢失。
- **Skill 可治理**：通过 route index、测试框架和 `/skill-create-ccgs` 管理新增、修改、合并和审计。

### 多窗口怎么用

第一次进入项目时运行：

```text
/start
```

`/start` 会在缺少 lane 状态时先引导创建最小 `A-producer` 总控 lane，然后继续原本的概念、引擎和阶段引导。这样窗口化会融入原 CCGS 动线，而不是替代 `/start`。

之后按需要开开发、美术、QA 或底层维护窗口：

```text
/window-ccgs B
/window-ccgs C
/window-ccgs D
/window-ccgs Z
```

窗口完成阶段性工作、准备关闭、切换任务、上下文过长或需要交接时：

```text
/window-ccgs update B
```

长期状态写在 lane 主体，最近恢复点写在 handoff。不要把整段旧对话复制到新窗口。

### `/skill-create-ccgs` 怎么用

新增或改造 Skill 时先运行：

```text
/skill-create-ccgs
```

它会先判断应该新增 Skill、修改现有 Skill、补 references、更新 route index、合并到已有 Skill，还是因为职责不清暂缓。

它的重点是让 Skill 融入当前 CCGS 体系，而不是无条件多加一个命令。

## License

MIT License. See [LICENSE](LICENSE) and [NOTICE.md](NOTICE.md).
