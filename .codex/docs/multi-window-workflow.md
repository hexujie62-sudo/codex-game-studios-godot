# CCGS 多窗口并行工作流

这份文档定义多个 Codex 窗口如何同时推进同一个 CCGS 项目。目标不是让窗口共享聊天记录，而是让它们共享文件状态。

核心原则：**文件是记忆，不是对话。窗口可以并行，但权威状态必须落盘。**

## 为什么需要多窗口

Codex 长上下文可能在压缩时卡住。靠复制整段对话开新窗口，会带来三个问题：

1. 复制成本高，且容易漏掉关键决定。
2. 新窗口会继承太多无关上下文，反而更快再次卡住。
3. 多窗口同时工作时，如果没有文件边界，会互相覆盖工件。

多窗口方案把“聊天历史”拆成“可恢复的工件状态”：

- 总状态：`production/session-state/active.md`
- 窗口状态：`production/session-state/windows/<window-id>.md`
- 真实产物：GDD、ADR、Story、代码、资源规格、测试证据

## 复杂度原则

多窗口机制必须保持轻量。只添加能直接解决恢复、交接、冲突或审计问题的机制。

- 优先短命令、固定文件和人工可读状态，不优先自动化黑盒。
- Hook 只做提醒和明显危险操作拦截，不默认强制阻塞窗口工作。
- 新增 Skill 或 Hook 前，先确认现有 `/window-ccgs`、`active.md`、lane 文件是否已经足够。
- 如果一个机制让用户更难理解当前状态，就不加入，或先作为显式调用工具。

## 窗口 Registry 与默认快捷 lane

多窗口不是固定分类系统。实际注册窗口以文件为准：

```text
production/session-state/windows/*.md
```

`A/B/C/D/Z` 是默认快捷 lane，方便快速启动常见职责；它们不是窗口分类上限。
项目可以按当前工作流创建自定义 lane，例如 `systems-design`、`prototype-v3-dev`、
`ui-pass`、`case-main`。

`/help` 必须常驻展示当前已注册窗口，并常驻展示新建/恢复/接手窗口的命令：

```text
Window commands:
- Start/create/recover: `/window-ccgs <lane-id>`
- Lane state refresh: Codex handles this automatically when taking over,
  finishing a meaningful unit, or switching windows.
```

第一个窗口通常不需要用户手动创建。新项目第一次运行 `/start` 时，如果没有任何
lane，`/start` 会先引导创建最小 `A-producer`，再继续原本的 CCGS onboarding。
这保证窗口化进入原动线，而不是替代原动线。

默认快捷 lane：

| 窗口 | 职责 | 主要文件 | 默认 Skill |
|---|---|---|---|
| A-producer | 总控、案子、范围、阶段、优先级、跨窗口冲突 | `production/session-state/active.md`、sprint、milestone、gate 报告 | `/help`、`/sprint-plan`、`/gate-check` |
| B-dev | 开发、测试、代码实现、故事推进 | `src/`、`tests/`、`production/epics/**` | `/dev-story`、`/code-review`、`/story-done` |
| C-art | 美术、资源、视觉规格、资源审计 | `design/art/`、`design/assets/`、`assets/` | `/art-bible` |
| D-qa | QA、缺陷、回归、测试证据 | `production/qa/`、`tests/`、test evidence | `/smoke-check`、`/story-done` |
| Z-platform | 框架适配、Skill、Hook、路由、文档、工具链 | `.agents/skills/`、`.codex/`、`.githooks/`、`docs/ccgs-*` | `/window-ccgs Z`、`/skill-create-ccgs` |

当前这个 Codex 窗口默认登记为 `Z-platform`：负责把框架改得更好用、更符合当前用户、项目和团队习惯；不直接推进游戏设计、美术生产或玩法代码，除非用户明确切换职责。

## 与原 CCGS 动线的关系

多窗口不是替代七阶段动线，而是七阶段动线之上的并行执行层。

原动线仍然成立：

`概念形成 -> 系统设计 -> 技术设置 -> 预生产 -> 生产 -> 打磨 -> 发布`

多窗口只改变“谁在同一时间维护哪些工件”：

| 原动线连接 | 多窗口中的实现 |
|---|---|
| 路由连接：`/help`、workflow catalog | A-producer 维护总状态，其他窗口读取自己的 lane 文件 |
| 工件连接：GDD -> ADR -> Story -> Test Evidence | 每个窗口只写自己拥有的工件，交接时引用文件路径 |
| 把关连接：review/readiness/done/gate | D-qa 或 A-producer 做独立审查，B-dev 不能自证完成 |
| 变更传播：设计改动影响架构/故事/测试 | A-producer 记录变更，相关窗口更新自己的 lane |
| Skill/Hook 底层维护 | Z-platform 独立处理，避免污染游戏生产窗口上下文 |

因此，多窗口不会削弱把关机制。它反而让每个窗口的证据边界更清楚：开发窗口不负责总控，美术窗口不负责代码验收，底层窗口不负责玩法设计结论。

## 并行动线层

原 CCGS 是单窗口串行：

```text
/help -> 当前阶段 -> 当前 Skill -> 产物 -> review/gate -> 下一步
```

Codex 多窗口后，动线变成：

```text
/help -> 当前阶段 + 当前问题类型 + Registered Windows
      -> 推荐 Skill + 推荐 lane
      -> 产物
      -> Codex refreshes lane state
      -> /window-ccgs audit
      -> review/gate
```

新增的不是新阶段，而是“并行路由层”。它只决定工作在哪个 lane 中推进，
不改变 GDD -> ADR -> Story -> Test Evidence -> Gate 的证据链。

## 并行路由决策表

`/help` 应根据用户问题和当前工件，给出 Skill 推荐和 lane 推荐。

| 问题类型 | 推荐 lane | 说明 |
|---|---|---|
| 阶段、范围、优先级、跨窗口冲突、gate 是否进入 | `A-producer` 或 `case-main` | 负责总控和裁决，不直接替代下游实现 |
| 代码实现、tests、Story、code review 准备 | `B-dev` | 负责实现，但不能自证完成 |
| 美术、资源规格、asset manifest、assets | `C-art` | 负责资源工件和资源标准 |
| QA、bug、smoke、regression、test evidence | `D-qa` | 负责测试计划、证据和验收建议 |
| 框架适配、Skill、Hook、route index、workflow docs | `Z-platform` | 负责让底层体系更贴合项目需求，不接管玩法结论 |
| GDD、UX、architecture、长期专题设计 | 自定义 lane，例如 `systems-design`、`ux-design`、`architecture` | 根据当前 workstream 建 lane |
| 一个问题跨多个 lane | `A-producer` | 先拆分 owner、顺序和 handoff |
| 同一文件被多个 lane 占用 | 先 `/window-ccgs audit` | 解决 file conflict 后再继续写 |

`/help` 的输出必须同时包含：

- 下一步 Skill。
- 建议在哪个 lane 做。
- 如果 lane 不存在，给出 `/window-ccgs <lane-id>`。
- 如果 lane 已存在，给出 `/window-ccgs <lane-id>` 接手命令；状态更新由 Codex 在接手和阶段性完成时自行写回。

## 文件结构

```text
production/session-state/
├── active.md                  # 项目总状态，由 A-producer 维护
└── windows/
    ├── Z-platform.md          # CCGS 底层窗口状态
    ├── A-producer.md          # 默认快捷 lane，可选
    ├── B-dev.md               # 默认快捷 lane，可选
    ├── C-art.md               # 默认快捷 lane，可选
    ├── D-qa.md                # 默认快捷 lane，可选
    └── <custom-lane-id>.md    # 自定义 workstream lane
```

`active.md` 只记录项目层面摘要、当前阶段、全局 blocker 和窗口索引。各窗口详细进度写入自己的 lane 文件。

创建新 lane 时，`/window-ccgs` 必须同步准备 `active.md` 的 registry 更新：

- lane 文件保存详细恢复状态。
- `active.md` 保存已注册窗口索引，让 `/help`、SessionStart hook 和压缩恢复提醒能发现它。
- 如果 `active.md` 已存在，只追加或更新对应窗口 registry，不重写项目阶段、目标或历史决定。

## 窗口状态模板

每个窗口状态文件使用同一模板：

```markdown
# Window: [lane-id]

## Responsibility

[本窗口负责什么，不负责什么]

## Current Objective

[当前目标，一句话]

## Scope

- Owns: [本窗口可直接修改的路径]
- Reads: [本窗口需要读取的上下游路径]
- Avoids: [默认不碰的路径]

## Active Files

- `[path]` — [为什么在改]

## Progress

- [x] [已完成]
- [ ] [正在做]

## Decisions

- [日期] [决定] — [理由]

## Blockers / Needs From Other Windows

- [需要哪个窗口提供什么]

## Handoff

Last updated: [YYYY-MM-DD HH:mm]
Next step: [下一步]
Restart prompt: [新窗口接手时复制的一句话]
```

## 启动一个新窗口

新窗口不要复制旧聊天。推荐使用短命令：

```text
/window-ccgs A   # 总控/案子
/window-ccgs B   # 开发
/window-ccgs C   # 美术/资源
/window-ccgs D   # QA
/window-ccgs Z   # 框架适配/底层维护
/window-ccgs <lane-id>   # 自定义窗口
```

`/window-ccgs` 会读取 `AGENTS.md`、`context-management.md`、
`multi-window-workflow.md`、`active.md` 和对应 lane 文件。lane 文件不存在时，
它会生成 lane 草稿和 `active.md` registry 更新草稿，并在写入前请求批准。

自定义 lane id 只能使用小写字母、数字和连字符，例如 `systems-design`。
自定义 lane 的职责来自用户目标、`active.md` 登记或 lane 文件正文，不能自动套用
A/B/C/D/Z 的默认职责。

下面的长提示只作为备用方案，用于 Skill 不可用或需要手动接管时。

### A-producer

```text
你接手 A-producer 窗口。
先读取：
- AGENTS.md
- .codex/docs/context-management.md
- .codex/docs/multi-window-workflow.md
- production/session-state/active.md
- production/session-state/windows/A-producer.md

不要依赖旧对话。根据 A-producer.md 的 Next step 继续，只维护总控、范围、阶段和跨窗口协调。
```

### B-dev

```text
你接手 B-dev 窗口。
先读取：
- AGENTS.md
- .codex/docs/context-management.md
- .codex/docs/multi-window-workflow.md
- production/session-state/active.md
- production/session-state/windows/B-dev.md

不要依赖旧对话。根据 B-dev.md 的 Next step 继续，只处理开发、测试、Story 实现和代码审查准备。
```

### C-art

```text
你接手 C-art 窗口。
先读取：
- AGENTS.md
- .codex/docs/context-management.md
- .codex/docs/multi-window-workflow.md
- production/session-state/active.md
- production/session-state/windows/C-art.md

不要依赖旧对话。根据 C-art.md 的 Next step 继续，只处理美术、资源规格、资产清单和资源审计。
```

### D-qa

```text
你接手 D-qa 窗口。
先读取：
- AGENTS.md
- .codex/docs/context-management.md
- .codex/docs/multi-window-workflow.md
- production/session-state/active.md
- production/session-state/windows/D-qa.md

不要依赖旧对话。根据 D-qa.md 的 Next step 继续，只处理 QA、缺陷、测试证据、冒烟和回归。
```

### Z-platform

```text
你接手 Z-platform 窗口。
先读取：
- AGENTS.md
- .codex/docs/context-management.md
- .codex/docs/multi-window-workflow.md
- production/session-state/active.md
- production/session-state/windows/Z-platform.md

不要依赖旧对话。根据 Z-platform.md 的 Next step 继续，只处理框架适配、Skill、Hook、路由、测试框架和体系文档，让框架更符合当前用户、项目和团队习惯。
```

## 日常使用流程

1. A-producer 先确定本轮要并行的工作流。
2. 每个窗口读取 `active.md` 和自己的 lane 文件。
3. 每个窗口只修改自己拥有的路径。
4. 如果需要跨窗口输入，在自己的 lane 文件写入 `Blockers / Needs From Other Windows`。
5. A-producer 汇总 blocker，决定谁先处理。
6. 每个窗口完成一个小阶段后，Codex 自行刷新当前 lane state。
7. A-producer 定期把全局变化写回 `active.md`。

## 什么时候创建新窗口

不要为了“看起来专业”开窗口。窗口只在能降低上下文重量、减少文件冲突或明确分离职责时创建。

会被引导创建第一个窗口的时机：

- 新项目第一次运行 `/start`，且 `production/session-state/windows/*.md` 不存在。
- `/start` 会询问是否写入最小 `A-producer` lane；同意后继续原 onboarding。

会被引导创建新窗口的时机：

- `/help` 发现下一步任务属于未注册 lane，例如代码实现建议 `B-dev`，但没有 `B-dev.md`。
- A-producer 把一个跨域任务拆成独立工作流，例如 `systems-design`、`ux-design`、`prototype-v3-dev`。
- 当前窗口职责不匹配，例如 Z-platform 窗口里要写玩法代码，应转到 `/window-ccgs B`。
- 上下文已经很重、压缩不稳定，且当前任务可以通过 lane 文件恢复。
- 工作需要长期并行推进，并且主要修改不同 owner 路径。

不会因为下面情况自动创建新窗口：

- 只是一个小问题、单文件修正或一次性审查。
- 多个窗口会频繁改同一个文件；这种情况先 `/window-ccgs audit`，再 handoff/request/split。
- 只是为了固定 A/B/C/D/Z 分类；自定义 lane 应来自真实 workstream。

## 持续更新保证

不能假设窗口会“自觉一直记得更新”。本体系用三个机制降低风险：

1. **自动记录**：接手、阶段性完成、切换窗口和上下文接近上限时，Codex 自行刷新 lane state。
2. **固定时机**：在明确触发点必须更新。
3. **可审计**：A-producer 可以运行 `/window-ccgs audit` 检查哪些 lane 缺失、过期或字段不完整。

这不是魔法记忆。可靠性来自 Codex 在固定触发点写回 lane state，以及 A-producer 的审计。

必须更新 lane 的时机：

| 时机 | 命令 | 原因 |
|---|---|---|
| 刚启动并确认职责后 | Codex 自动刷新 lane state | 记录本窗口正式接手 |
| 完成一个阶段性产物 | Codex 自动刷新 lane state | 防止成果只留在聊天里 |
| 修改了本窗口 owner 路径 | Codex 自动刷新 lane state | 记录 active/changed files |
| 产生跨窗口 blocker | Codex 自动刷新 lane state | 让 A-producer 能协调 |
| 准备关窗口或开新窗口 | Codex 自动刷新 lane state | 生成恢复点 |
| 上下文达到约 60-70% | Codex 自动刷新 lane state | 避免压缩卡死后丢状态 |
| lane 文件超过 300 行 | `/window-ccgs compact <id>` | 控制 MD 长度 |
| A-producer 检查全局状态 | `/window-ccgs audit` | 查漏、查过期、查 blocker |

## 信息不丢失规则

lane 文件不是聊天记录，不保存所有过程。它只保存恢复所需的最小关键状态。

必须保存：

- 当前目标。
- 本轮完成了什么。
- 改过哪些文件。
- 跑过哪些测试或检查。
- 尚未写入正式文档的关键决定。
- 阻塞问题和需要哪个窗口接力。
- 下一步。
- 恢复命令。

不保存：

- 大段聊天原文。
- 大段 diff。
- 已经写进 GDD/ADR/Story/代码的正文。
- 与本窗口无关的细节。

判断标准：新窗口只读 `active.md` 和 lane 文件，能否继续下一步。如果不能，handoff 就不合格。

## 交接规则

任何窗口在以下时刻必须写 handoff：

- 准备关窗口
- 上下文超过约 60-70%
- 完成一个阶段性产物
- 改动会影响另一个窗口
- 遇到 blocker，需要别的窗口处理

### Lane 主体与 Handoff

刷新 lane state 不是把整份 lane 替换成一段最新摘要。

lane 文件分两层：

- **Lane 主体**：长期状态，包括 `Current Objective`、`Active Files`、`Progress`、`Decisions`、`Blockers / Needs From Other Windows`。
- **Handoff**：最近恢复点，只记录本轮完成内容、改动文件、检查结果、当前 blocker、下一步和恢复命令。

更新规则：

- `Handoff` 可以替换为最新恢复点。
- Lane 主体不能粗暴覆盖，仍然有效的旧信息必须保留。
- 覆盖旧 `Handoff` 前，必须检查旧内容。仍然有效的决定、阻塞、文件状态或下一步，要迁移到 Lane 主体或新 `Handoff`。
- 已经过期的旧 `Handoff` 信息可以丢弃，但更新草稿必须说明原因。
- `Decisions` 只追加，不覆盖旧决定。

因此，Codex 写回 lane state 时必须先在输出中声明：

```text
本次更新范围：
- Lane 主体：更新 / 追加 / 保持不变 [...]
- Handoff：替换为最新恢复点 / 保持不变
- 不改： [...]
- 旧 Handoff 处理： [...]
```

最短 handoff 必须包含：

```markdown
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
你接手 [window-id] 窗口。先读取 ... 然后继续 ...
```

推荐不用手写，直接运行：

```text
Codex 自动刷新 A/B/C/D/Z 或当前自定义 lane 的 lane state。
```

## 文件冲突规则

多窗口并行时最容易出事的是同一批文件被多个窗口同时改。默认路径归属如下：

| 路径 | Owner | 其他窗口规则 |
|---|---|---|
| `.agents/skills/` | Z-platform | 其他窗口只能提出需求，不直接改 |
| `.codex/` | Z-platform | 其他窗口只读，除非 A-producer 明确授权 |
| `.githooks/` | Z-platform | 其他窗口不改 |
| `docs/ccgs-*` | Z-platform | 其他窗口不改 |
| `design/gdd/` | A-producer 或设计窗口 | B-dev 只读，除非 story 明确要求 |
| `design/art/`、`design/assets/` | C-art | B-dev/D-qa 只读 |
| `assets/` | C-art | B-dev 只改导入引用，不改源资源规范 |
| `src/`、`tests/` | B-dev | C-art 不改代码，D-qa 可新增测试证据或测试用例 |
| `production/qa/` | D-qa | B-dev 可读并修复，但不改 QA 结论 |
| `production/session-state/active.md` | A-producer | 其他窗口只在紧急 handoff 时追加，不重写 |
| `production/session-state/windows/<id>.md` | 对应窗口 | 其他窗口不改，除非接手该窗口 |

如果两个窗口必须改同一文件，先让 A-producer 决定顺序。不要并行改同一文件。

## 文件占用协议

保持简单：不使用锁文件，不做复杂自动分配。同一文件同一时间只能有一个
`editing owner`。

每个 lane 在 `Active Files` 中声明自己正在改的文件：

```markdown
- `design/gdd/combat.md` — editing owner: systems-design；reason: 重写战斗系统规则
```

规则：

- 本窗口 owner 路径内的文件，可以声明为 `editing owner` 并直接修改。
- 非 owner 窗口需要该文件变化时，在自己的 `Blockers / Needs From Other Windows` 写 request，不直接改。
- 如果同一文件出现在多个 lane 的 `Active Files`，视为 file conflict。
- file conflict 解决前，不继续并行写该文件。

解决方式只保留三种：

1. **handoff**：当前 owner 更新 lane 后，把文件交给另一个 lane。
2. **request**：非 owner 只记录需求，由 owner 修改。
3. **split**：把工作拆到不同文件，例如一个改 GDD，一个改测试证据。

裁决规则：

- 普通路径冲突：默认路径 owner 优先。
- 跨域冲突：A-producer 裁决。
- `.agents/skills/`、`.codex/`、`.githooks/`、`docs/ccgs-*` 冲突：Z-platform 裁决。
- 不确定 owner 时，先停止写该文件，运行 `/window-ccgs audit`。

## Git Checkpoints

多窗口并行时，提交不是“把所有改动打包”，而是一个可恢复、可解释的
checkpoint。详细规则见 `.codex/docs/git-checkpoint-workflow.md`。

默认流程：

1. 窗口完成一个阶段性产物。
2. Codex 写回当前 lane state。
3. 运行 `/window-ccgs checkpoint <lane-id>` 生成提交建议。
4. 只 stage checkpoint plan 中列出的文件。
5. commit message 使用 Conventional Commits，并在正文写入 `Lane:`、`Scope:`、`Verification:`、`Rollback:`。

默认只建议提交，不自动提交。自动 checkpoint 只有在 lane 明确记录
`auto_checkpoint: true` 且 `/window-ccgs audit` 无冲突时允许。

### Checkpoint 推荐时机

| 时机 | 建议 |
|---|---|
| 写入或删除阶段产物 | 推荐 checkpoint |
| 刷新 lane handoff 后 | 如果本轮有实质改动，推荐 checkpoint |
| 修改 Skill、Hook、route、workflow、test spec | 推荐 checkpoint，并归属 Z-platform |
| 完成 Story 实施、review、test evidence、bug triage | 推荐 checkpoint，并归属对应 lane |
| 准备切换 lane、压缩上下文、开始 research | 先 checkpoint 或明确留下未提交原因 |

### Checkpoint 冲突规则

- 一个 checkpoint 默认对应一个 lane。
- staged files 跨多个 owner 域时，先让 A-producer 确认 scope。
- `git add .` 禁止用于 checkpoint。
- 如果同一文件出现在多个 lane 的 `Active Files`，pre-commit 会阻止提交。
- 如果存在未纳入 git 的 lane 文件，pre-commit 会阻止提交。
- 提交后必须向用户报告实际 SHA 和 `git revert <sha>` 回滚命令。

## Research Branches And Worktrees

研究方向、原型方向和不确定改造不应在共享 worktree 里直接切换分支。使用：

```text
/window-ccgs research <lane-id> <slug>
```

默认创建：

```text
Branch: codex/research/<normalized-lane-id>-<slug>-YYYYMMDD
Worktree: ../ccgs-worktrees/<normalized-lane-id>-<slug>
Base SHA: <current-head>
Merge target: <current-branch>
```

Research 创建前必须检查：

- 当前 worktree 没有与该 lane owner 路径重叠的未 checkpoint 改动。
- 目标 worktree 路径不存在，或为空且可安全使用。
- branch 名符合 `codex/research/` 前缀。
- lane 文件会记录 branch、worktree、base SHA、merge target 和 rollback/removal command。

研究完成后使用：

```text
/window-ccgs merge <lane-id>
```

自动合并只允许 `auto_merge: clean-only`，并且 merge preflight 无冲突、研究 worktree
无未提交改动、验证结果已记录。否则只输出 merge plan 和 blocker，不自动合并。

## 长上下文恢复方案

不要等 Codex 卡死再处理。每个窗口采用小循环：

1. 读取最少必要文件。
2. 完成一个小产物。
3. 写入产物文件。
4. Codex 刷新窗口 lane 文件。
5. 清理上下文或开新窗口继续。

当窗口卡住或压缩失败时：

1. 不复制全部对话。
2. 开新窗口。
3. 运行 `/window-ccgs [A|B|C|D|Z]`；如果 Skill 不可用，再使用对应 `Restart prompt`。
4. 读取 `active.md` 和 lane 文件。
5. 从 `Next step` 继续。

## Lane 文件过长处理

lane 文件只应该是恢复索引，不应该变成第二份长文档。

阈值：

- 300 行：建议压缩。
- 500 行：必须压缩。

压缩命令：

```text
/window-ccgs compact A
/window-ccgs compact B
/window-ccgs compact C
/window-ccgs compact D
/window-ccgs compact Z
```

压缩规则：

- 完整旧 lane 归档到 `production/session-state/windows/archive/`。
- 当前 lane 只保留当前目标、active files、最近决定、blocker、next step 和 archive link。
- 正式产物内容不复制到 lane，只保留路径引用。

## 什么时候用单窗口、子代理、多窗口

| 方式 | 适用场景 | 不适用场景 |
|---|---|---|
| 单窗口 | 一个小任务、一个文件、一次审查 | 会持续 30 分钟以上或读很多文件 |
| Subagent | 同一窗口内做独立搜索、审查、分析 | 需要长期持续推进的工作流 |
| 多窗口 | A/B/C/D/Z 各自长期推进不同工件 | 多个窗口必须频繁改同一文件 |

多窗口是“长期并行工作流”。Subagent 是“当前窗口的一次性分身”。不要混用概念。

## 推荐节奏

每天或每个工作块开始：

1. A-producer 读 `active.md` 和所有 lane 文件。
2. A-producer 给每个窗口分配一个明确目标。
3. B/C/D/Z 各自推进。
4. 每个窗口完成后由 Codex 写 handoff。
5. 每个窗口运行 `/window-ccgs checkpoint <lane-id>`，决定是否提交本轮 checkpoint。
6. A-producer 汇总全局状态。

每次进入阶段 gate 前：

1. 所有窗口停止写入。
2. D-qa 补测试和证据。
3. A-producer 运行 `/gate-check`。
4. Z-platform 只在底层工具或 Skill 被修改时通过 `/skill-create-ccgs` 做内部验证和动线接入审计。

## 何时更新本协议

以下情况由 Z-platform 更新本文：

- 新增窗口类型
- 改变路径 owner
- 新增专门的 workstream Skill
- Hook 或 session-state 格式变化
- 多窗口实践暴露出冲突或恢复问题
- Git checkpoint、research worktree 或 merge 策略变化


