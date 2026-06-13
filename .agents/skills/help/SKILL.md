---
name: help
description: "分析已完成的工作和用户查询，并就下一步提供建议。当用户说接下来该做什么或现在该做什么或遇到困难或不知道该做什么时使用"
argument-hint: "[可选：你刚完成或卡住的内容，例如 '刚完成 D verdict' 或 '卡在工单拆分']"
user-invocable: true
allowed-tools: Read, Glob, Grep
context: |
  !echo "=== Live Project State ===" && echo "Stage: $(cat production/stage.txt 2>/dev/null | tr -d '[:space:]' || echo 'not set')" && echo "Work orders: $(ls production/work-orders/*.md 2>/dev/null | wc -l | tr -d ' ')" && echo "Session state: $(head -5 production/session-state/active.md 2>/dev/null || echo 'none')"
model: haiku
---

# Studio Help — 下一步做什么？

本 Skill 只读：只报告发现和建议，不写入任何文件。

`/help` 是 CFG 的轻量导航入口。它回答“现在在哪、下一步做什么、该进哪个窗口”，不做正式验收。阶段推进判断用 `/gate-check`；窗口恢复、审计、checkpoint 用 `/window-cfg`。

## Load Order

按顺序读取存在的文件：

1. `AGENTS.md`
2. `.codex/docs/workflow-catalog.yaml`
3. `.codex/docs/skill-route-index.yaml`
4. `.codex/docs/git-checkpoint-workflow.md`
5. `production/session-state/active.md`
6. `production/session-state/windows/*.md`
7. `production/work-orders/README.md`
8. `production/work-orders/*.md` 中与当前问题相关的文件

不要读取 `.agents/skills-archive/` 或 `.codex/agents/`。不要推荐 `.agents/skills/` 中不存在的 Skill。旧命令名只能通过 route index 的 alias 转译到当前核心入口。

## Phase Detection

阶段来源优先级：

1. `production/stage.txt` 存在且有内容时，它是权威阶段。
2. 否则按最靠后的证据推断：
   - `production/work-orders/*.md` 或 `src/` 有实质代码 -> `production`
   - `prototypes/` 有已验证原型 -> `pre-production`
   - `docs/architecture/architecture.md` 或 ADR 存在 -> `technical-setup`
   - `design/gdd/systems-index.md` 存在 -> `systems-design`
   - `design/gdd/game-concept.md` 存在 -> `concept`
   - 都没有 -> `concept`

## Window Registry

始终读取并展示：

- `production/session-state/active.md`
- `production/session-state/windows/*.md`

对每个 lane 提取：

- window id/name
- responsibility
- current objective
- active files
- handoff next step
- restart command

检查并报告：

- lane file 存在但未列入 `active.md`
- `active.md` 列出的 state file 不存在
- 多个 lane 同时声明同一个 Active File

窗口命令固定展示：

```text
Window commands / 窗口命令:
- 新建/恢复/接手: `/window-cfg <lane-id>`
- 审计窗口/文件占用: `/window-cfg audit`
- checkpoint 建议: `/window-cfg checkpoint <lane-id>`
```

## Production Navigation

生产阶段不使用 Epic/Story/Sprint 状态机。不要读取或推荐 `production/epics/`、`production/sprints/`、`production/sprint-status.yaml`。

生产阶段导航只看：

- `production/work-orders/*.md`
- `production/session-state/active.md`
- lane state files
- B/C/D/A 的交付报告或 handoff
- `production/project-canon.md`，仅当问题涉及 canon/player experience/visual verdict

工单状态判断：

- `queued` / `active` / `delivered` / `verdict` / `blocked` / `closed`
- 若文件没有显式状态，从标题、handoff、verdict、最近更新时间中保守推断，并标明“推断”。

## Parallel Routing

默认路由：

- 范围、优先级、队列、跨窗口冲突 -> `A-producer`
- 代码、测试、Godot runtime、dev evidence -> `B-dev`
- 美术、资源、截图/视频、visual evidence -> `C-art`
- 玩家体验、视觉质量、动作可读性、canon 一致性、跨线 verdict -> `D-director`
- Skill、Hook、route index、workflow docs、多窗口协议 -> `Z-platform`
- 系统设计、架构、UX 等长期专题 -> 推荐自定义 lane

如果发现文件占用冲突，优先建议 `/window-cfg audit`，不要继续并行写同一文件。

## Checkpoint Readiness

只读检查：

- `git status --short`
- `git diff --name-only`
- `git diff --cached --name-only`
- lane Active Files 与 handoff

建议 checkpoint 的信号：

- 一个 lane 的阶段性产物已完成。
- Skill/Hook/route/workflow/window 文档被修改。
- 工单、verdict、canon、交付证据形成可回滚单元。
- 用户准备切换窗口、压缩上下文或问“可以提交了吗”。

不要 stage、commit 或修改文件。

## Output Shape

保持简短。只给一个 primary next step。

```text
## Where You Are / 当前位置: [Phase]

In progress: [active task/work order/lane, if any]

Registered Windows / 已注册窗口:
- `[lane-id]` — [responsibility]
  Lane: `production/session-state/windows/[lane-id].md`
  Next: [handoff next step]

Window commands / 窗口命令:
- 新建/恢复/接手: `/window-cfg <lane-id>`
- 审计窗口/文件占用: `/window-cfg audit`
- checkpoint 建议: `/window-cfg checkpoint <lane-id>`

Parallel routing / 并行路由:
- 建议窗口: [lane id or `/window-cfg <lane-id>`]
- 原因: [why]

Checkpoint / 提交检查点:
- [only if recommended or unsafe]

Done / 已完成:
- [confirmed items]

Next up / 下一步:
Command: `/skill-or-window-command`
Why this one: [route-index or artifact reason]

Optional / 可选:
- [only directly relevant options]

Coming up / 后续:
- [one or two later required actions]
```

如果无法判断某个 manual 状态，问用户一个短问题。不要为了填满报告列很多泛泛选项。

Verdict: **HELP COMPLETE** — 已识别下一步。

