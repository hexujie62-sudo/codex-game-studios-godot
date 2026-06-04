---
name: start
description: "首次引导 — 询问您当前所处阶段，然后引导您到正确的工作流程。不做任何假设。"
argument-hint: "[无参数]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, AskUserQuestion
model: sonnet
---

# Guided Onboarding

本 Skill 会写入一个文件：`production/review-mode.txt`。review mode 配置在 Phase 3b 中设置。

本 Skill 是新用户入口。它不假设用户已经有游戏概念、engine 偏好或开发经验。它先询问，再把用户路由到合适的 workflow。

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
- `/prototype` — 一次性 concept build，用 1 到 3 天验证核心想法是否有趣。
- `/art-bible` — 定义 visual identity，使用 brainstorm 产出的 Visual Identity Anchor。
- `/map-systems` — 拆解系统。
- `/design-system` — 为每个 MVP system 编写 GDD。
- `/review-all-gdds` — 跨系统一致性检查。
- `/gate-check` — 进入 architecture work 前检查 readiness。

**Architecture phase:**

- `/create-architecture` — 产出 master architecture blueprint 和 Required ADR list。
- `/architecture-decision (xN)` — 按 Required ADR list 记录关键技术决策。
- `/create-control-manifest` — 把决策编译成可执行规则清单。
- `/architecture-review` — 验证 architecture coverage。

**Pre-Production phase:**

- `/ux-design` — 为关键 screens 编写 UX specs，例如 main menu、HUD、core interactions。
- `/vertical-slice` — 做 production-quality end-to-end build，验证完整 game loop。
- `/playtest-report (x1+)` — 记录每次 vertical slice playtest session。
- `/create-epics` — 把 systems 映射为 epics。
- `/create-stories` — 把 epics 拆成 implementable stories。
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
- `/prototype` — 一次性 concept build，用 1 到 3 天验证核心想法是否有趣。
- `/art-bible` — 定义 visual identity，使用 brainstorm 产出的 Visual Identity Anchor。
- `/map-systems` — 拆解系统。
- `/design-system` — 为每个 MVP system 编写 GDD。
- `/review-all-gdds` — 跨系统一致性检查。
- `/gate-check` — 进入 architecture work 前检查 readiness。

**Architecture phase:**

- `/create-architecture` — 产出 master architecture blueprint 和 Required ADR list。
- `/architecture-decision (xN)` — 按 Required ADR list 记录关键技术决策。
- `/create-control-manifest` — 把决策编译成可执行规则清单。
- `/architecture-review` — 验证 architecture coverage。

**Pre-Production phase:**

- `/ux-design` — 为关键 screens 编写 UX specs，例如 main menu、HUD、core interactions。
- `/vertical-slice` — 做 production-quality end-to-end build，验证完整 game loop。
- `/playtest-report (x1+)` — 记录每次 vertical slice playtest session。
- `/create-epics` — 把 systems 映射为 epics。
- `/create-stories` — 把 epics 拆成 implementable stories。
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
- `/prototype` — 一次性 concept build，用 1 到 3 天验证核心想法是否有趣。
- `/art-bible` — 定义 visual identity。若跑过 brainstorm，则在 brainstorm 后；否则在 concept doc 存在后。
- `/design-review` — 审查 concept doc。
- `/map-systems` — 拆解 individual systems。
- `/design-system` — 为每个 MVP system 编写 GDD。
- `/review-all-gdds` — 跨系统一致性检查。
- `/gate-check` — 进入 architecture work 前检查 readiness。

**Architecture phase:**

- `/create-architecture` — 产出 master architecture blueprint 和 Required ADR list。
- `/architecture-decision (xN)` — 按 Required ADR list 记录关键技术决策。
- `/create-control-manifest` — 把决策编译成可执行规则清单。
- `/architecture-review` — 验证 architecture coverage。

**Pre-Production phase:**

- `/ux-design` — 为关键 screens 编写 UX specs，例如 main menu、HUD、core interactions。
- `/vertical-slice` — 做 production-quality end-to-end build，验证完整 game loop。
- `/playtest-report (x1+)` — 记录每次 vertical slice playtest session。
- `/create-epics` — 把 systems 映射为 epics。
- `/create-stories` — 把 epics 拆成 implementable stories。
- `/sprint-plan` — 规划第一个 sprint。

**Production phase:** 使用 `/dev-story` 接 story 开发。

#### If D: 已有工作成果

1. 分享 Phase 1 检测到的内容：
   - `我看到你已经有 [X source files / Y design docs / Z prototypes]...`
   - `当前 engine 是 [configured as X / not yet configured]...`

2. **Sub-case D1 — Early stage**，例如 engine 未配置，或只有 game concept：
   - 如果 engine 未配置，先推荐 `/setup-engine`。
   - 然后推荐 `/project-stage-detect` 做 gap inventory。

3. **Sub-case D2 — 已有 GDDs、ADRs 或 stories：**
   - 解释：有文件不等于模板里的 Skills 能直接使用这些文件。GDDs 可能缺少必需章节，`/adopt` 专门检查这个问题。
   - 推荐：
     1. `/project-stage-detect` — 判断当前阶段和缺失工件。
     2. `/adopt` — 审计现有工件是否符合内部格式。

4. 展示 D2 推荐路径：
   - `/project-stage-detect` — phase detection + existence gaps。
   - `/adopt` — format compliance audit + migration plan。
   - `/setup-engine` — 如果 engine 未配置。
   - `/design-system retrofit [path]` — 补齐缺失 GDD sections。
   - `/architecture-decision retrofit [path]` — 补齐缺失 ADR sections。
   - `/architecture-review` — 启动 TR requirement registry。
   - `/gate-check` — 验证是否可以进入下一阶段。

---

## Phase 3c: Write Initial Stage File

确认起始路径后，在询问 review mode 前，写入初始阶段到 `production/stage.txt`。如果 `production/` 不存在，先创建目录。

Stage mapping:

- **Path A、B 或 C，从零开始**：写入 `Concept`。
- **Path D，已有项目但 engine 未配置或只有 game concept**：写入 `Concept`。
- **Path D，已有 GDDs 但没有 architecture documents**：写入 `Systems Design`。
- **Path D，已有完整 architecture，例如 ADRs 和 architecture doc**：写入 `Technical Setup`。

静默执行，不需要为这个单行文件额外询问 `May I write?`。

然后说明：`我已将 production/stage.txt 设置为 [stage]。这会固定 status line 和 stage detection 的阶段来源。`

---

## Phase 3b: Set Review Mode

检查 `production/review-mode.txt` 是否已存在。

**如果存在**：读取并显示当前模式：`Review mode 当前是 [current]。` 然后进入 Phase 4，不再询问。

**如果不存在**：使用 `AskUserQuestion`：

- **Prompt**: `一个设置问题：你希望 workflow 中的 design review 有多严格？`
- **Options**:
  - `Full` — Director specialists 在每个关键 workflow step 审查。适合团队、学习 workflow，或希望每个决策都有充分反馈的情况。
  - `Lean (recommended)` — Directors 只在 phase gate transitions，例如 `/gate-check`，进行审查。跳过 per-skill reviews。适合 solo dev 和小团队。
  - `Solo` — 不做 director reviews，速度最快。适合 game jams、prototypes，或 review 负担太重的情况。

用户选择后立即写入 `production/review-mode.txt`。这不需要额外询问 `May I write?`，因为写入是选择的直接结果：

- `Full` -> 写入 `full`
- `Lean (recommended)` -> 写入 `lean`
- `Solo` -> 写入 `solo`

如果 `production/` 不存在，先创建目录。

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
- **User is returning**，例如 engine configured 且 concept exists：跳过 onboarding，说明：`看起来你已经完成基础设置。当前 engine 是 [X]，并且已有 game concept：design/gdd/game-concept.md。Review mode: [read from production/review-mode.txt, or lean (default) if missing]。想从上次的位置继续吗？可以试试 /sprint-plan，或直接告诉我你想做什么。`
- **User doesn't fit any option**：让用户用自己的话描述情况，然后适配。

---

## Collaborative Protocol

1. **Ask first** — 不假设用户状态或意图。
2. **Present options** — 给清晰路径，不下命令。
3. **User decides** — 用户选择方向。
4. **No auto-execution** — 推荐下一步 Skill，但未经确认不运行。
5. **Adapt** — 如果用户情况不符合模板，认真听并调整。
