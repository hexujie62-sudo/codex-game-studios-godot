---
name: window-start-ccgs
description: "用短命令启动或恢复 CCGS 多窗口工作流 lane。支持默认快捷 A/B/C/D/Z，也支持自定义 lane id；自动读取 AGENTS、multi-window-workflow、active.md 和对应 lane 文件，缺失时引导创建 lane。用于新开窗口、上下文卡死后恢复、切换窗口职责或创建项目专用 workstream 时。"
argument-hint: "[A|B|C|D|Z|registered-lane-id|custom-lane-id] [optional objective]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write
model: haiku
---

# CCGS Window Start

用一个短命令启动或恢复 CCGS 多窗口 lane。目标是替代手动输入长启动提示。

---

## Phase 1: Parse Window Id

读取第一个参数并解析 lane id。

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

如果没有参数，输出：

```text
Usage:
/window-start-ccgs A   # 总控/案子
/window-start-ccgs B   # 开发
/window-start-ccgs C   # 美术/资源
/window-start-ccgs D   # QA
/window-start-ccgs Z   # CCGS 底层
/window-start-ccgs <lane-id>   # 自定义窗口，例如 systems-design
```

然后停止。Verdict: `BLOCKED`。

---

## Phase 2: Read Shared Context

按顺序读取：

1. `AGENTS.md`
2. `.codex/docs/context-management.md`
3. `.codex/docs/multi-window-workflow.md`
4. `production/session-state/active.md`
5. 对应 lane 文件

如果 lane 文件存在，只读取它并进入 Phase 4。

如果 lane 文件不存在，进入 Phase 3。

---

## Phase 3: Create Missing Lane

如果 `production/session-state/windows/` 不存在，计划创建目录。

根据窗口生成 lane 草稿：

- 默认快捷 lane 的 `Responsibility`、`Scope`、`Avoids` 使用 `.codex/docs/multi-window-workflow.md` 的默认窗口职责。
- 自定义 lane 的 `Responsibility` 必须来自用户第二个参数、active.md 中已登记的说明，或用户当前请求。信息不足时最多问 2 个问题，不要擅自套用 A/B/C/D/Z 职责。
- `Current Objective` 使用用户第二个参数；如果没有，写成“等待 A-producer 或用户分配目标”。
- `Active Files` 初始为空。
- `Progress` 初始为“读取项目状态并确认下一步”。
- `Handoff` 包含可复制的短恢复命令，例如 `/window-start-ccgs B` 或 `/window-start-ccgs systems-design`。

lane 文件是项目状态工件。创建草稿时必须提示：

- 该 lane 应纳入 git 版本管理。
- 如果新 lane 还没有被 track，后续 `/help` 和 pre-commit hook 会把它标为 registry/tracking concern。

写入前必须询问：

`May I write the missing lane file to production/session-state/windows/<window>.md?`

如果用户拒绝，输出手动启动提示并停止。Verdict: `CONCERNS`。

---

## Phase 4: Adopt Window Responsibility

输出简短接手摘要：

```text
Window: [window]
Role: [one-line responsibility]
Lane: [path]
Current objective: [from lane]
Next step: [from Handoff]
Avoid touching: [top 3 avoid paths]
Verdict: READY
```

然后按窗口职责继续：

- `A-producer`：只维护总控、范围、阶段、跨窗口协调。
- `B-dev`：只处理开发、测试、Story 实现和代码审查准备。
- `C-art`：只处理美术、资源规格、资产清单和资源审计。
- `D-qa`：只处理 QA、缺陷、测试证据、冒烟和回归。
- `Z-platform`：只处理 CCGS 底层、Skill、Hook、路由、测试框架和体系文档。
- 自定义 lane：按 lane 文件的 `Responsibility` 和 `Scope` 执行；不要套用默认快捷 lane 的职责。

不要依赖旧对话。以文件状态为准。

---

## Phase 5: Recovery Rules

如果用户是因为上下文压缩、卡死或新开窗口而运行本 Skill：

1. 不要求用户粘贴旧对话。
2. 只读取 `active.md` 和 lane 文件。
3. 从 lane 文件的 `Next step` 继续。
4. 如果 lane 文件信息不足，向用户问最多 2 个问题，不要要求复制整段聊天。

---

## Phase 6: Next Step Handoff

如果接手成功：

- 普通下一步：继续 lane 文件中的 `Next step`。
- 正式开始工作前：运行 `/window-handoff-ccgs update [A|B|C|D|Z]` 记录本窗口已接手。
- 正式开始自定义 lane 前：运行 `/window-handoff-ccgs update <lane-id>` 记录本窗口已接手。
- 需要更新窗口状态：在完成当前小阶段后运行 `/window-handoff-ccgs update <lane-id>`。
- 需要结束窗口：把当前状态写回 lane 文件，再开新窗口运行同一个短命令。

Verdict: `READY` 或 `BLOCKED`。
