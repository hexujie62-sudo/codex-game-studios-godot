---
name: window-handoff-ccgs
description: "更新、审计或压缩 CCGS 多窗口 lane 状态文件。用于窗口完成阶段性工作、准备关闭、上下文超过 60-70%、切换任务、跨窗口交接、检查窗口是否持续更新、或 lane Markdown 过长需要归档时。支持 update/audit/compact 模式、默认快捷 A/B/C/D/Z 和自定义 lane id。"
argument-hint: "[update|audit|compact] [A|B|C|D|Z|registered-lane-id|custom-lane-id] [optional summary]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash
model: haiku
---

# CCGS Window Handoff

更新、审计或压缩 CCGS 多窗口 lane 文件。它解决多窗口方案的可靠性问题：
窗口必须把重要状态写回文件，恢复时只读文件，不复制旧对话。

---

## Phase 1: Parse Mode and Window

第一个参数是模式：

- `update`：更新一个窗口 lane 文件。
- `audit`：检查所有 lane 是否存在、是否过期、是否缺关键字段。
- `compact`：当 lane 文件过长时，归档历史并保留短摘要。

如果第一个参数不是模式，把它当作 lane id，并默认 `update`。

默认快捷别名：

| 输入 | Window | Lane file |
|---|---|---|
| `A`、`producer`、`A-producer` | `A-producer` | `production/session-state/windows/A-producer.md` |
| `B`、`dev`、`B-dev` | `B-dev` | `production/session-state/windows/B-dev.md` |
| `C`、`art`、`C-art` | `C-art` | `production/session-state/windows/C-art.md` |
| `D`、`qa`、`D-qa` | `D-qa` | `production/session-state/windows/D-qa.md` |
| `Z`、`platform`、`Z-platform` | `Z-platform` | `production/session-state/windows/Z-platform.md` |

这些只是默认快捷方式，不是窗口分类上限。

如果输入不是默认别名：

1. 把它视为自定义 lane id。
2. 只允许小写字母、数字和连字符：`[a-z0-9][a-z0-9-]{0,63}`。
3. 对应文件为 `production/session-state/windows/<lane-id>.md`。
4. 如果不符合命名规则，输出错误和 usage。Verdict: `BLOCKED`。

如果模式是 `update` 或 `compact` 但没有 lane id，输出 usage 并停止。Verdict: `BLOCKED`。

---

## Phase 2: Load State

读取：

- `AGENTS.md`
- `.codex/docs/multi-window-workflow.md`
- `production/session-state/active.md`
- 目标 lane 文件，或所有 `production/session-state/windows/*.md` lane 文件（audit 模式）

如果目标 lane 不存在，提示先运行 `/window-start-ccgs <lane-id>`。Verdict: `BLOCKED`。

如果目标 lane 存在但未被 git track，不能悄悄忽略。把它写进草稿的
`Open blockers` 或 audit 输出中：

```text
Tracking concern: lane exists but is untracked. It should be added to git as a project state artifact.
```

---

## Phase 3: Update Mode

在这些时机运行 `update`：

- 窗口刚完成一个阶段性产物。
- 准备关闭窗口。
- 上下文超过约 60-70%。
- 修改了本窗口 owner 路径中的文件。
- 发现需要另一个窗口输入。
- 用户说“记录一下”“交接一下”“更新窗口状态”。

收集本轮状态：

- Current objective
- Completed
- Active files
- Changed files
- Tests / checks run
- Decisions made
- Blockers / needs from other windows
- Next step
- Restart command

可用 `git status --short` 辅助识别 changed files，但不要把巨大 diff 写进 lane。

生成 lane 更新草稿时，必须先声明本次更新范围：

```text
本次更新范围：
- Lane 主体：更新 / 追加 / 保持不变 [Current Objective, Active Files, Progress, Decisions, Blockers]
- Handoff：替换为最新恢复点 / 保持不变
- 不改：[Responsibility, Scope, ...]
- 旧 Handoff 处理：[已迁移到 Lane 主体 / 继续保留在新 Handoff / 已过期可丢弃]
```

Lane 主体和 Handoff 的职责不同：

- Lane 主体保存长期状态：职责、范围、当前目标、活跃文件、累计进度、关键决定、跨窗口 blocker。
- Handoff 保存最近恢复点：刚完成什么、改了哪些文件、跑了哪些检查、下一步怎么恢复。
- `Handoff` 可以覆盖；lane 文件不能粗暴覆盖。
- 覆盖旧 `Handoff` 前，必须先检查旧内容。仍然有效的决定、阻塞、文件状态或下一步，要迁移到 `Decisions`、`Progress`、`Blockers / Needs From Other Windows`、`Active Files` 或新 `Handoff`。
- 如果旧 `Handoff` 内容已过期，可以丢弃，但草稿里要说明它为什么不再需要。

更新策略：

- 默认保留 `Responsibility` 和 `Scope`，除非用户明确要求改窗口职责或路径 owner。
- `Current Objective`、`Active Files`、`Progress`、`Blockers` 可以按当前状态更新，但不得删除仍然有效的旧信息。
- `Decisions` 只追加本轮新决定，不能覆盖旧决定。
- `Handoff` 替换为最新恢复摘要，必须包含 `Last updated`、`Completed`、`Changed files`、`Tests`、`Open blockers`、`Next step`、`Restart command`。

草稿必须分成两部分：

1. `Lane 主体变更`：列出会修改或追加的主体区块。
2. `Handoff 替换内容`：列出新的 `## Handoff` 区块。

写入前询问（等同于 `May I write` 协作协议）：

`May I update production/session-state/windows/<window>.md with this handoff?`

如果用户同意，写入 lane。Verdict: `COMPLETE`。

---

## Phase 4: Audit Mode

检查 `production/session-state/windows/*.md`，不要硬编码只检查 A/B/C/D/Z。

对每个 lane 检查：

- 文件是否存在。
- 是否包含 `Responsibility`、`Current Objective`、`Scope`、`Active Files`、`Progress`、`Decisions`、`Blockers / Needs From Other Windows`、`Handoff`。
- `Handoff` 是否包含 `Last updated` 和 `Next step`。
- `Last updated` 是否明显过期。无法计算时间时，至少标记为 `UNKNOWN`，让用户确认。
- 是否有 `Open blockers`。
- 是否引用了不存在的 active files。
- 是否存在 file conflict：同一路径同时出现在多个 lane 的 `Active Files`。

file conflict 检查保持简单：

1. 只扫描每个 lane 的 `## Active Files` 区块。
2. 从反引号中提取路径，例如 `` `design/gdd/combat.md` ``。
3. 同一路径被两个或更多 lane 引用时，输出 `FILE CONFLICT`。
4. 不尝试自动解决，不自动改文件。

冲突输出示例：

```text
File conflicts:
- design/gdd/combat.md
  owners: systems-design, B-dev
  action: pause edits and let A-producer decide handoff/request/split
```

输出所有发现的 lane 文件：

```text
Window Handoff Audit
[lane-id]: MISSING / STALE / READY / TRACKING CONCERN
File conflicts: none / FOUND

Verdict: PASS / CONCERNS / FAIL
```

audit 模式只读，不写文件。

---

## Phase 5: Compact Mode

当 lane 文件过长时运行 `compact`。默认阈值：

- 软阈值：300 行，建议压缩。
- 硬阈值：500 行，应压缩。

压缩方法：

1. 读取目标 lane。
2. 创建归档路径：`production/session-state/windows/archive/<window>-YYYYMMDD-HHMM.md`。
3. 把旧 lane 完整内容写入归档。
4. 重写 lane，只保留：
   - Responsibility
   - Current Objective
   - Scope
   - Active Files
   - 最近 5 条 Decisions
   - 当前 Blockers
   - 当前 Handoff
   - Archive links

写入前询问：

`May I archive and compact production/session-state/windows/<window>.md?`

Verdict: `COMPLETE` 或 `CONCERNS`。

---

## Phase 6: Integrity Rules

不要把这些内容写进 lane：

- 整段聊天记录。
- 大段代码 diff。
- 已经落盘在真实产物里的长设计正文。
- 和该窗口职责无关的文件细节。

必须写进 lane：

- 本窗口现在负责什么。
- 改了哪些文件。
- 本次 update 会修改 lane 主体哪些区块，Handoff 是否会被替换。
- 哪些决定只存在于对话中，尚未进入正式文档。
- 谁被阻塞，需要哪个窗口接力。
- 新窗口恢复时下一步是什么。

如果信息不足，问最多 3 个问题，不要求用户复制完整旧对话。

---

## Phase 7: Next Step

完成后提示：

- 继续当前窗口：按 `Next step` 做。
- 换窗口：运行 `/window-start-ccgs <lane-id>`。
- 检查所有窗口：运行 `/window-handoff-ccgs audit`。

Verdict: `COMPLETE`、`CONCERNS`、`FAIL` 或 `BLOCKED`。
