---
name: start
description: "首次引导 — 询问您当前所处阶段，然后引导您到正确的工作流程。不做任何假设。"
argument-hint: "[无参数]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, AskUserQuestion
model: sonnet
---

# Guided Onboarding

本 Skill 不再创建或维护 review-mode 文件。审查标准固定：普通 Skill 使用内部检查；
只有 `/gate-check` 运行阶段门 director panel。

本 Skill 是新用户入口。它不假设用户已经有游戏概念、engine 偏好或开发经验。它先询问，再把用户路由到合适的 workflow。

它也吸收旧的 `adopt`、`project-stage-detect` 和部分 `reverse-document`
入口：旧项目接入、阶段重新定位、缺失工件识别，都先从 `/start` 或 `/help`
进入，不再暴露额外命令。

Preserved CCGS value:

- New project entry should create or propose the initial `A-producer` lane before
  normal onboarding.
- Existing project entry should distinguish existence gaps from format gaps.
- Adoption plan output, if needed: `docs/adoption-plan-[date].md`.
- Stage report output, if needed: `production/project-stage-report.md`.
- Brownfield checks should inspect `design/`, `docs/architecture/`,
  `production/`, `tests/`, `project.godot`, and source folders before deciding
  the stage.
- If code/prototypes exist without design docs, route to `/design-system` or
  `/create-architecture` retrofit behavior instead of inventing a new command.
- Do not ask the user to choose review modes. The review standard is fixed:
  inline director checks are internal, and `/gate-check` owns phase-gate review.

## Reference Loading Rules

Do not read `.agents/skills-archive/` during normal use. Old onboarding and
brownfield content has been extracted into `references/brownfield-intake.md`.

Read that reference only when the user is adopting an existing project, asking
for stage detection, or trying to reverse-document code/prototypes into design
or architecture artifacts. Fresh greenfield onboarding can run from this
`SKILL.md` alone.

---

## Phase 0: Window Lane Bootstrap

在任何 onboarding 问题之前，先检查多窗口状态：

- `production/session-state/windows/*.md`
- `production/session-state/active.md`

如果没有任何 lane 文件，说明这个项目还没有进入 Codex Game Studios 的文件化窗口体系。此时不要阻断 `/start`，也不要要求用户先切到 `/window-ccgs A`。`/start` 是首次入口，必须在内部完成最小 lane 接入，然后继续原 onboarding。

先说明：

```text
这个 fork 使用多窗口 lane 保存长期状态。我会先为本项目建立一个最小的 A-producer 总控 lane，用来记录阶段、范围和后续窗口分流；然后继续 /start 的原本引导。
```

准备写入：

- `production/session-state/windows/A-producer.md`
- 如果 `production/session-state/active.md` 不存在，也创建最小 registry。

写入前询问：

```text
May I write the initial A-producer lane state to production/session-state/windows/A-producer.md and continue /start?
```

如果用户同意，写入最小 lane，然后继续 Phase 1。不要输出 `BLOCKED`。

如果用户拒绝，继续 Phase 1，但提醒：`单窗口可以继续，但恢复和并行协作不会写入 lane；之后可随时运行 /window-ccgs A 接入。`

如果用户本次输入明确包含 `single-window`、`单窗口`、`不创建窗口` 或等价表达，可以跳过写入询问，继续 Phase 1，并给同样提醒。

如果已经存在至少一个 lane 文件，则继续 Phase 1。不要强制要求一定是 `A-producer`；自定义 lane 也算已进入窗口体系。但如果没有 `A-producer` 或等价总控 lane，后续推荐路径里应提醒：长期项目建议补一个总控 lane，例如 `/window-ccgs A`。

---

## Phase 1: Detect Project State

在提问前，先静默收集上下文，用来定制后续建议。不要主动展示这些检测结果；它们只用于判断，不作为开场报告。

检查：

- **Engine configured?** 读取 `.codex/docs/technical-preferences.md`。如果 Engine 字段包含 `[TO BE CONFIGURED]`，说明 engine 尚未配置。
- **Game concept exists?** 检查 `design/gdd/game-concept.md`。
- **Source code exists?** 在 `src/` 中 Glob source files：`*.gd`、`*.cs`、`*.cpp`、`*.h`、`*.rs`、`*.py`、`*.js`、`*.ts`。
- **Prototypes exist?** 检查 `prototypes/` 下是否有子目录。
- **Design docs exist?** 统计 `design/gdd/` 中的 markdown 文件。
- **Production artifacts?** 检查 `production/sprints/` 或 `production/milestones/` 中是否有文件。

把这些结果保存在内部，用来校验用户的自我判断，并调整推荐路径。

---

## Phase 2: Ask Where the User Is

这是用户第一眼看到的内容。使用 `AskUserQuestion`，并给出这些可点击选项：

- **Prompt**: `欢迎来到 Codex Game Studios。在我建议下一步之前，我想先了解你的起点：你现在的游戏想法处于什么状态？`
- **Options**:
  - `A) 还没有想法` — 我完全没有 game concept，想先探索和想清楚要做什么。
  - `B) 有模糊想法` — 我有大概的主题、感觉或 genre，例如“太空”“cozy farming game”，但还不具体。
  - `C) 概念比较清楚` — 我知道核心想法、genre、基本 mechanics，可能有一句 pitch，但还没正式写成文档。
  - `D) 已有工作成果` — 我已经有 design docs、prototypes、code 或明显的 planning，想整理或继续推进。

等待用户选择。用户回应前不要继续。

---

## Phase 3: Route Based on Answer

#### If A: 还没有想法

用户需要先做创意探索。

1. 说明从零开始完全没问题。
2. 简要解释 `/brainstorm`：它会用 MDA、player psychology、verb-first design 等专业框架做引导式构思。说明两种模式：`/brainstorm open` 用于完全开放探索；`/brainstorm [hint]` 用于已有模糊主题时，例如 `space`、`cozy`、`horror`。
3. 推荐下一步运行 `/brainstorm open`，也可以让用户带一个 hint。
4. 展示推荐路径：

**Concept phase:**

- `/brainstorm open` — 探索 game concept。
- `/setup-engine` — 配置 engine，brainstorm 会给建议。
- `/brainstorm` — 一次性 concept build，用 1 到 3 天验证核心想法是否有趣。
- `/art-bible` — 定义 visual identity，使用 brainstorm 产出的 Visual Identity Anchor。
- `/design-system` — 拆解系统。
- `/design-system` — 为每个 MVP system 编写 GDD。
- `/design-system` — 跨系统一致性检查。
- `/gate-check` — 进入 architecture work 前检查 readiness。

**Architecture phase:**

- `/create-architecture` — 产出 master architecture blueprint 和 Required ADR list。
- `/create-architecture (xN)` — 按 Required ADR list 记录关键技术决策。
- `/create-architecture` — 把决策编译成可执行规则清单。
- `/create-architecture` — 验证 architecture coverage。

**Pre-Production phase:**

- `/art-bible` — 为关键 screens 编写 UX specs，例如 main menu、HUD、core interactions。
- `/sprint-plan` — 做 production-quality end-to-end build，验证完整 game loop。
- `/smoke-check (x1+)` — 记录每次 vertical slice playtest session。
- `/sprint-plan` — 把 systems 映射为 epics。
- `/sprint-plan` — 把 epics 拆成 implementable stories。
- `/sprint-plan` — 规划第一个 sprint。

**Production phase:** 使用 `/dev-story` 接 story 开发。

#### If B: 有模糊想法

1. 让用户分享模糊想法，几个词也可以。
2. 确认这个想法可以作为起点，不评价、不强行改方向。
3. 推荐运行 `/brainstorm [用户的 hint]` 来发展它。
4. 展示推荐路径：

**Concept phase:**

- `/brainstorm [hint]` — 把模糊想法发展成完整 concept。
- `/setup-engine` — 配置 engine。
- `/brainstorm` — 一次性 concept build，用 1 到 3 天验证核心想法是否有趣。
- `/art-bible` — 定义 visual identity，使用 brainstorm 产出的 Visual Identity Anchor。
- `/design-system` — 拆解系统。
- `/design-system` — 为每个 MVP system 编写 GDD。
- `/design-system` — 跨系统一致性检查。
- `/gate-check` — 进入 architecture work 前检查 readiness。

**Architecture phase:**

- `/create-architecture` — 产出 master architecture blueprint 和 Required ADR list。
- `/create-architecture (xN)` — 按 Required ADR list 记录关键技术决策。
- `/create-architecture` — 把决策编译成可执行规则清单。
- `/create-architecture` — 验证 architecture coverage。

**Pre-Production phase:**

- `/art-bible` — 为关键 screens 编写 UX specs，例如 main menu、HUD、core interactions。
- `/sprint-plan` — 做 production-quality end-to-end build，验证完整 game loop。
- `/smoke-check (x1+)` — 记录每次 vertical slice playtest session。
- `/sprint-plan` — 把 systems 映射为 epics。
- `/sprint-plan` — 把 epics 拆成 implementable stories。
- `/sprint-plan` — 规划第一个 sprint。

**Production phase:** 使用 `/dev-story` 接 story 开发。

#### If C: 概念比较清楚

1. 让用户用一句话描述 concept，包括 genre 和 core mechanic。这里使用普通文本，不使用 `AskUserQuestion`，因为这是开放回答。
2. 确认 concept 后，用 `AskUserQuestion` 提供两个路径：
   - **Prompt**: `你想怎么继续？`
   - **Options**:
     - `先正式整理` — 运行 `/brainstorm [concept]`，把它结构化为正式 game concept document。
     - `直接进入配置` — 先进入 `/setup-engine`，之后再手动补 GDD。
3. 展示推荐路径：

**Concept phase:**

- `/brainstorm` 或 `/setup-engine` — 取决于用户在上一步的选择。
- `/brainstorm` — 一次性 concept build，用 1 到 3 天验证核心想法是否有趣。
- `/art-bible` — 定义 visual identity。若跑过 brainstorm，则在 brainstorm 后；否则在 concept doc 存在后。
- `/design-system` — 审查 concept doc。
- `/design-system` — 拆解 individual systems。
- `/design-system` — 为每个 MVP system 编写 GDD。
- `/design-system` — 跨系统一致性检查。
- `/gate-check` — 进入 architecture work 前检查 readiness。

**Architecture phase:**

- `/create-architecture` — 产出 master architecture blueprint 和 Required ADR list。
- `/create-architecture (xN)` — 按 Required ADR list 记录关键技术决策。
- `/create-architecture` — 把决策编译成可执行规则清单。
- `/create-architecture` — 验证 architecture coverage。

**Pre-Production phase:**

- `/art-bible` — 为关键 screens 编写 UX specs，例如 main menu、HUD、core interactions。
- `/sprint-plan` — 做 production-quality end-to-end build，验证完整 game loop。
- `/smoke-check (x1+)` — 记录每次 vertical slice playtest session。
- `/sprint-plan` — 把 systems 映射为 epics。
- `/sprint-plan` — 把 epics 拆成 implementable stories。
- `/sprint-plan` — 规划第一个 sprint。

**Production phase:** 使用 `/dev-story` 接 story 开发。

#### If D: 已有工作成果

1. 分享 Phase 1 检测到的内容：
   - `我看到你已经有 [X source files / Y design docs / Z prototypes]...`
   - `当前 engine 是 [configured as X / not yet configured]...`

2. **Sub-case D1 — Early stage**，例如 engine 未配置，或只有 game concept：
   - 如果 engine 未配置，先推荐 `/setup-engine`。
   - 然后推荐 `/help` 做 gap inventory。

3. **Sub-case D2 — 已有 GDDs、ADRs 或 stories：**
   - 解释：有文件不等于模板里的 Skills 能直接使用这些文件。GDDs 可能缺少必需章节，`/start` 专门检查这个问题。
   - 推荐：
     1. `/help` — 判断当前阶段和缺失工件。
     2. `/start` — 审计现有工件是否符合内部格式。

4. 展示 D2 推荐路径：
   - `/help` — phase detection + existence gaps。
   - `/start` — format compliance audit + migration plan。
   - `/setup-engine` — 如果 engine 未配置。
   - `/design-system retrofit [path]` — 补齐缺失 GDD sections。
   - `/create-architecture retrofit [path]` — 补齐缺失 ADR sections。
   - `/create-architecture` — 启动 TR requirement registry。
   - `/gate-check` — 验证是否可以进入下一阶段。

---

## Phase 3c: Write Initial Stage File

确认起始路径后，准备写入初始阶段到 `production/stage.txt`。如果 `production/` 不存在，先创建目录。

Stage mapping:

- **Path A、B 或 C，从零开始**：写入 `Concept`。
- **Path D，已有项目但 engine 未配置或只有 game concept**：写入 `Concept`。
- **Path D，已有 GDDs 但没有 architecture documents**：写入 `Systems Design`。
- **Path D，已有完整 architecture，例如 ADRs 和 architecture doc**：写入 `Technical Setup`。

写入前询问：

```text
May I write the initial stage to `production/stage.txt`?
```

然后说明：`我已将 production/stage.txt 设置为 [stage]。这会固定 status line 和 stage detection 的阶段来源。`

---

## Phase 3b: Review Standard

不要读取、创建或标准化 `production/review-mode.txt`。该文件是旧模式兼容物，
不再驱动 active Skills。

只用一句话说明：
`当前使用固定审查标准：普通 Skill 做内部检查，阶段推进由 /gate-check 集中审查。`

---

## Phase 4: Confirm Before Proceeding

展示推荐路径后，使用 `AskUserQuestion` 询问用户想从哪一步开始。不要自动运行下一个 Skill。

- **Prompt**: `你想从 [recommended first step] 开始吗？`
- **Options**:
  - `是，从 [recommended first step] 开始`
  - `我想先做别的`

---

## Phase 5: Hand Off

当用户确认下一步后，只回复一句短句：`输入 [skill command] 开始。` 不要重新解释该 Skill，也不要追加鼓励语。`/start` 的任务到此结束。

Verdict: **COMPLETE** — 已完成定位并交接到下一步。

---

## Edge Cases

- **User picks D but project is empty**：温和纠正：`看起来这是一个还没有工件的新模板。Path A 或 Path B 会不会更合适？`
- **User picks A but project has code**：指出发现：`我注意到 src/ 里已经有代码。你是不是想选 D，也就是已有工作成果？`
- **User is returning**，例如 engine configured 且 concept exists：跳过 onboarding，说明：`看起来你已经完成基础设置。当前 engine 是 [X]，并且已有 game concept：design/gdd/game-concept.md。当前使用固定审查标准。想从上次的位置继续吗？可以试试 /sprint-plan，或直接告诉我你想做什么。`
- **User doesn't fit any option**：让用户用自己的话描述情况，然后适配。

---

## Collaborative Protocol

1. **Ask first** — 不假设用户状态或意图。
2. **Present options** — 给清晰路径，不下命令。
3. **User decides** — 用户选择方向。
4. **No auto-execution** — 推荐下一步 Skill，但未经确认不运行。
5. **Adapt** — 如果用户情况不符合模板，认真听并调整。

