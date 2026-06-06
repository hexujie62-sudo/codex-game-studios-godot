---
name: help
description: "分析已完成的工作和用户查询，并就下一步提供建议。当用户说接下来该做什么或现在该做什么或遇到困难或不知道该做什么时使用"
argument-hint: "[可选：你刚完成或卡住的内容，例如 '刚完成 design-review' 或 '卡在 ADRs']"
user-invocable: true
allowed-tools: Read, Glob, Grep
context: |
  !echo "=== Live Project State ===" && echo "Stage: $(cat production/stage.txt 2>/dev/null | tr -d '[:space:]' || echo 'not set')" && echo "Latest sprint: $(ls -t production/sprints/*.md 2>/dev/null | head -1 || echo 'none')" && echo "Session state: $(head -5 production/session-state/active.md 2>/dev/null || echo 'none')"
model: haiku
---

# Studio Help — 下一步做什么？

本 Skill 只读：只报告发现和建议，不写入任何文件。

本 Skill 用来快速判断项目现在处在游戏开发流程的哪一步，并告诉用户下一步应该做什么。它是轻量导航，不是完整审计。阶段推进判断使用 `/gate-check`；旧项目重新定位从 `/start` 进入。

---

## Reference Loading Rules

Do not read `.agents/skills-archive/` during normal use. Old onboarding and
stage-detection behavior has been extracted into
`references/navigation-stage.md`.

Read that reference only when the user asks "where am I?", "what did I finish?",
"what should I do next?", or when route/catalog state conflicts with visible
project artifacts.

---

## Step 1: 读取 Catalog

读取 `.codex/docs/workflow-catalog.yaml`。这是阶段、步骤顺序、required/optional 标记，以及完成条件 artifact glob 的权威来源。

---

## Step 1a: 读取 Skill Route Index

如果 `.codex/docs/skill-route-index.yaml` 存在，必须读取。它是已安装 Skills 的权威路由层：

- `stable_constraints` 可以影响每一次推荐。
- `mutable_design_fields` 不是永久假设。只有读取当前项目工件后才能使用，并在输出中说明“当前工件显示...”。
- `core_skills` 是当前真实保留的核心入口，可以成为主推荐。
- `alias_routes` 是旧 Skill 名到核心 Skill 的转译表；用户提到旧命令时，推荐对应核心入口，不展示旧命令。
- 不推荐 `.agents/skills/` 中不存在的 Skill，即使 workflow 或旧文档曾经提到它。

如果 `.codex/docs/git-checkpoint-workflow.md` 存在，也读取它的 checkpoint readiness
规则。`/help` 只建议 checkpoint，不 stage、不 commit。

必要时读取这些当前项目事实来源：

- `AGENTS.md`
- `.codex/docs/collaboration-profile.md`
- `.codex/docs/technical-preferences.md`
- `design/gdd/game-concept.md`
- `design/gdd/systems-index.md`
- `design/art/art-bible.md`
- `design/ux/*.md`

不要把当前设计事实写成永久路由假设，例如 2D/3D、美术风格、camera、genre、core loop、input method、platform、Codex 职能覆盖。它们只能解释本次推荐。

推荐命令时，给出 route index 中的简短理由：

```text
Command: `/skill-name`
Why this one: [route-index why] ([stable constraint] 或 [current artifact])
```

---

## Step 1b: 查找未进入 Catalog 的 Skills

读取 catalog 后，使用 Glob 扫描 `.agents/skills/*/SKILL.md`，获取完整已安装 Skill 列表。对每个文件，提取 frontmatter 中的 `name:`。

将这些 name 与 catalog 中的 `command:` 对比。任何没有出现在 catalog command 中的 Skill 都是 uncataloged skill：它仍可使用，但不属于 phase-gated workflow。

如果 route index 存在，也要查询 uncataloged skill 是否在 `core_skills` 中。只有真实存在且属于核心入口的 Skill 才展示。旧 Skill 名只通过 `alias_routes` 转译，不进入 footer。

在 Step 7 输出中，可把这些 Skill 放到 footer：

```text
### Also installed (not in workflow)
- `/skill-name` — [SKILL.md frontmatter description]
- `/skill-name` — [description]
```

只有至少存在一个相关 uncataloged skill 时才展示该区块。最多展示 10 个，并按当前阶段相关性排序。

---

## Step 2: 判断当前 Phase

按顺序判断当前阶段：

1. **读取 `production/stage.txt`**：如果存在且有内容，它就是权威阶段名。映射到 catalog phase key：
   - `Concept` -> `concept`
   - `Systems Design` -> `systems-design`
   - `Technical Setup` -> `technical-setup`
   - `Pre-Production` -> `pre-production`
   - `Production` -> `production`
   - `Polish` -> `polish`
   - `Release` -> `release`

2. **如果 `stage.txt` 缺失**，从工件推断阶段，使用最靠后的匹配：
   - `src/` 有 10 个以上 source files -> `production`
   - `production/stories/*.md` 存在 -> `pre-production`
   - `docs/architecture/adr-*.md` 存在 -> `technical-setup`
   - `design/gdd/systems-index.md` 存在 -> `systems-design`
   - `design/gdd/game-concept.md` 存在 -> `concept`
   - 什么都没有 -> `concept`

---

## Step 3: 读取 Session Context

如果 `production/session-state/active.md` 存在，读取并提取：

- 最近在做什么。
- in-progress tasks 或 open questions。
- STATUS block 中的当前 epic/feature/task。

这些信息用于个性化输出，判断用户刚完成什么或卡在哪里。

---

## Step 3a: 读取 Registered Windows

输出前必须读取 multi-window registry：

- `production/session-state/active.md`：人类可读的 registry 总览。
- `production/session-state/windows/*.md`：现有 lane files 的权威列表。

Registered windows 是动态的。`A/B/C/D/Z` 只是默认快捷方式，不是合法窗口全集。任何位于 `production/session-state/windows/` 下的合法 lane file 都是 registered lane。

对每个 lane file 提取：

- `# Window: ...` 中的 window name；如果缺失，则使用文件名。
- `Responsibility` 第一段。
- `Current Objective`。
- `Active Files` 中反引号包裹的路径。
- `Handoff` 中的 `Next step`。
- `Restart command`，如果存在。

同时对比 `active.md` 和 lane files：

- lane file 存在但未列入 `active.md` -> 放入 `Registry concerns`。
- `active.md` 列出的 state file 不存在 -> 放入 `Registry concerns`。
- 同一路径出现在多个 lane 的 `Active Files` -> 放入 `File conflicts`。

输出中必须始终包含 window command block，即使当前没有 lane files：

```text
Window commands / 窗口命令:
- 新建/恢复/接手: `/window-ccgs <lane-id>`
- 状态登记: Codex 在接手、完成阶段性产物或准备切换窗口时自行刷新 lane state
```

`/help` 是只读 Skill，不创建、更新或删除 lane files。

---

## Step 4: 检查当前 Phase 的 Step 完成度

对当前阶段中的每个步骤执行完成度检查。

### Artifact-based checks

如果步骤有 `artifact.glob`：

- 使用 Glob 检查是否存在匹配文件。
- 如果有 `min_count`，确认匹配数量达到要求。
- 如果有 `artifact.pattern`，使用 Grep 检查匹配文件中是否包含该 pattern。
- **Complete** = artifact 条件满足。
- **Incomplete** = artifact 缺失或 pattern 未找到。

如果步骤有 `artifact.note` 但没有 glob：

- 标记为 **MANUAL**，表示无法自动判断，需要询问用户。

如果步骤没有 `artifact`：

- 标记为 **UNKNOWN**，表示无法跟踪完成度，例如 repeatable implementation work。

### Special case: production phase — read `sprint-status.yaml`

当当前阶段是 `production` 时，先检查 `production/sprint-status.yaml`。如果存在，直接读取：

- `status: in-progress` 的 stories -> 显示为 currently active。
- `status: ready-for-dev` 的 stories -> 显示为 next up。
- `status: done` 的 stories -> 计为 complete。
- `status: blocked` 的 stories -> 用 `blocker` 字段显示 blocker。

这比扫描 markdown 更精确。此时跳过 `implement` 和 `story-done` 的 glob artifact check，以 YAML 为准。

### Special case: `repeatable: true`

非 production 阶段的 repeatable steps，例如 System GDDs，artifact check 只能说明“已经开始”，不能说明“全部完成”。输出时要标注可能仍在持续进行。

---

## Step 5: 定位当前位置并识别下一步

根据完成度数据判断：

1. **Last confirmed complete step**：最靠后的已完成 required step。
2. **Current blocker**：第一个未完成 required step，也就是当前必须处理的下一步。
3. **Optional opportunities**：当前 blocker 前后可并行处理的 optional steps。
4. **Upcoming required steps**：当前 blocker 后面的 required steps，用于预告。

如果用户提供了参数，例如 `刚完成 design-review`，即使 artifact check 有歧义，也可以据此把该步骤视为刚完成并向后推进。

然后应用 route index：

- 只保留一个 primary recommendation，通常是第一个未完成 required step，并且对应 Skill 为 `visibility: core`。
- 如果 workflow catalog 的 command 已经被 alias_routes 吸收，显示吸收后的核心 Skill。
- optional opportunities 只展示与当前 blocker 直接相关的核心 Skill，不展示已归档的旧 Skill。
- Godot 相关工作应依据当前项目工件中的 Godot 信息。不要假设 2D/3D、美术风格、view、input method、platform，除非当前工件明确显示。

---

## Step 6: Parallel Routing

在给出下一步 Skill 后，判断这个工作应该在哪个 lane 中推进。不要把 A/B/C/D/Z 当成唯一分类；它们只是默认快捷 lane。可以推荐自定义 lane。

默认路由：

- 项目阶段、范围、优先级、跨窗口冲突、gate 决策 -> `A-producer` 或 `case-main`
- 代码实现、tests、Story、code review 准备 -> `B-dev`
- 美术、资源规格、asset manifest、assets -> `C-art`
- QA、bug、smoke、regression、test evidence -> `D-qa`
- CCGS 底层、Skill、Hook、route index、workflow docs、multi-window 协议 -> `Z-platform`
- 系统设计、GDD、UX、architecture 等长期专题 -> 推荐自定义 lane，例如 `systems-design`、`ux-design`、`architecture`

输出规则：

- 如果推荐 lane 已注册，显示：`建议窗口: [lane-id]`。
- 如果推荐 lane 未注册，显示：`建议新建窗口: /window-ccgs <lane-id>`。
- 如果当前窗口职责不匹配，提醒不要在当前窗口直接改对应文件。
- 如果任务跨多个 lane，先推荐 `A-producer` 做拆分和 owner 裁决。
- 如果发现 File conflicts，优先提示 `/window-ccgs audit`，不要继续并行写同一文件。

---

## Step 7: Checkpoint Readiness

检查是否应该建议用户做 checkpoint。只读检查：

- `git status --short`
- `git diff --name-only`
- `git diff --cached --name-only`
- registered lane 的 `Active Files`、`Handoff` 和最近完成项

建议 checkpoint 的信号：

- 当前 worktree 有可归属到单一 lane 的阶段性改动。
- 用户刚完成或报告完成了一个阶段性产物。
- Skill、Hook、route、workflow、test spec、architecture docs 被修改。
- Story/review/test evidence/bug triage 单元完成。
- 用户准备切换 lane、压缩上下文、开始 research，或问“可以提交了吗”。

不要因为一个很小的 typo 或无明确 rollback 单元的零散改动就强推 checkpoint。

输出 checkpoint block 的条件：

- 如果建议 checkpoint，显示：

```text
Checkpoint / 提交检查点:
- 建议: `/window-ccgs checkpoint <lane-id>`
- 原因: [why this is a rollback-sized unit]
- 注意: 只会生成 stage/commit 建议；真正提交需要明确授权或 lane policy。
```

- 如果 worktree 很脏且跨多个 lane，显示：

```text
Checkpoint / 提交检查点:
- 当前不建议直接提交；先运行 `/window-ccgs audit`，再由 A-producer 拆 scope。
```

---

## Step 8: 检查 In-Progress Work

如果 `active.md` 显示有 active task 或 epic：

- 在输出顶部突出显示。
- 建议继续它，或询问是否已经完成。

---

## Step 9: 输出结果

保持简短直接。它是快速导航，不是报告。

```text
## Where You Are / 当前位置: [Phase Label]

**In progress:** [from active.md, if any]

### Registered Windows / 已注册窗口
- `[window-id]` — [one-line responsibility]
  Lane: `production/session-state/windows/[window-id].md`
  Next: [Handoff next step or "not recorded"]

Window commands / 窗口命令:
- 新建/恢复/接手: `/window-ccgs <lane-id>`
- 状态登记: Codex 自动刷新当前 lane state；用户不需要手动运行 update/handoff

Registry concerns / 注册表问题:
- [only if active.md and lane files disagree]

File conflicts / 文件占用冲突:
- [only if the same active file appears in multiple lanes]

Parallel routing / 并行路由:
- 建议窗口: [registered lane id] 或 建议新建窗口: `/window-ccgs <lane-id>`
- 原因: [why this lane fits the task]

Checkpoint / 提交检查点:
- [only if checkpoint is recommended or unsafe]
- 建议: `/window-ccgs checkpoint <lane-id>` 或 先 `/window-ccgs audit`
- 原因: [why]

### ✓ Done / 已完成
- [completed step name]
- [completed step name]

### → Next up (REQUIRED) / 下一步
**[Step name]** — [description]
Command: `[/command]`
Why this one: [route-index why; mention stable constraint or current artifact source]

### ~ Also available (OPTIONAL) / 可选
- **[Step name]** — [description] -> `/command` — [short why]
- **[Step name]** — [description] -> `/command`

### Coming up after that / 后续
- [Next required step name] (`/command`)
- [Next required step name] (`/command`)

---
接近 **[next phase]** gate 时，准备好后运行 `/gate-check`。
```

格式规则：

- `✓` 表示确认完成。
- `→` 表示当前 required next step，只能有一个。
- `~` 表示当前可做的 optional steps。
- 必须始终展示 `Registered Windows` 和 `Window commands / 窗口命令`。
- 必须展示 `Parallel routing / 并行路由`，说明建议在哪个 lane 推进。
- 如果达到 checkpoint readiness，展示 `Checkpoint / 提交检查点`。
- 如果发现 File conflicts，必须提示先运行 `/window-ccgs audit`，不要继续并行改同一文件。
- command 使用 backtick code。
- 如果某个 step 没有 command，例如 Implement Stories，解释该做什么，不要硬造 slash command。
- 对 MANUAL steps，询问用户：`I can't tell if [step] is done — has it been completed?`

Verdict: **HELP COMPLETE** — 已识别下一步。

---

## Step 10: Gate 提醒

检查用户是否接近阶段 gate：

- 如果当前阶段 required steps 全部或几乎全部完成，提示：`你已经接近 [Current] -> [Next] gate。准备好后运行 /gate-check。`
- 如果还剩多个 required steps，不展示 gate warning。

---

## Step 11: 深入检查路径

如果用户显得卡住或困惑，额外展示：

```text
---
需要更详细的检查？
- `/gate-check` — 正式 readiness check，判断能否进入下一阶段。
- `/start` — 从头重新定位或接入旧项目。
```

只有用户输入暗示困惑时才展示，例如“不知道”“卡住了”“lost”“not sure”。普通“what's next?” 不展示。

---

## Collaborative Protocol

- **Never auto-run the next skill.** 推荐下一步，但让用户自己调用。
- **Ask about MANUAL steps**，不要假设完成或未完成。
- **Match the user's tone**。如果用户很焦虑，只给一个行动，不要列六个。
- **One primary recommendation**。用户离开时应明确知道下一件事是什么。Optional 和 coming up 都是辅助信息。


