# CCGS Codex 单生态架构文档

生成日期：2026-06-04  
最近更新：2026-06-06

这份文档是当前 CCGS Codex 单生态体系的总索引。它的目的不是宣传项目，而是让你能随时判断：这个体系有几条动线、每个阶段靠什么连接、每个 Skill/Hook 文件具体负责什么、哪些把关机制不能合并、后续新增 Skill 应该怎样接入。

## 当前规模

- Agent：49 个，位置：`.codex/agents/*.toml`
- Active Skill：17 个，位置：`.agents/skills/*/SKILL.md`
- Codex 默认 Hook：5 个，位置：`.codex/hooks/*.sh`
- Legacy Hook：11 个，位置：`.codex/hooks/legacy/*.sh`
- Git Hook：2 个，位置：`.githooks/`
- Rule：11 个，位置：`.codex/rules/*.md`
- Template：40 个，位置：`.codex/docs/templates/`

## 源头文件

| 区域 | 权威位置 | 作用 |
|---|---|---|
| 项目说明 | `AGENTS.md` 和各目录下的 `AGENTS.md` | Codex 读取的协作规则、目录约束、技术偏好入口 |
| Skills | `.agents/skills/<skill>/SKILL.md` | Slash command 的工作流、触发条件、读写边界和执行步骤 |
| Agents | `.codex/agents/*.toml` | 专业角色、负责人、总监和执行专家的职责边界 |
| Workflow Catalog | `.codex/docs/workflow-catalog.yaml` | 七阶段路线图，`/help` 用它判断下一步 |
| Skill Route Index | `.codex/docs/skill-route-index.yaml` | 旧说法到核心 Skill 的解释层：core/absorbed、项目稳定约束、可变设计事实 |
| Git Checkpoints | `.codex/docs/git-checkpoint-workflow.md` | 多窗口提交建议、rollback 说明、research worktree 和 clean-only merge 规则 |
| Docs/Templates | `.codex/docs/` | 标准、模板、Gate 定义、Hook/Skill/Agent 参考 |
| Codex Hooks | `.codex/hooks/*.sh` 和 `.codex/hooks.json` | 会话上下文、轻量提醒、危险命令软拦截 |
| Git Hooks | `.githooks/` | 本地 commit/push 前检查 |
| Rules | `.codex/rules/*.md` | 路径级代码/设计规范 |
| Skill 测试 | `CCGS Skill Testing Framework/` | 17 个核心 Skill 的行为规范、分类和回归测试索引 |

旧的 Anthropic 命名层已经从底层迁出；目录级说明现在统一使用 `AGENTS.md`。

## 当前动线设计

CCGS 的动线不是“大量命令让人手选”，而是一个七阶段工作流：

`概念形成 -> 系统设计 -> 技术设置 -> 预生产 -> 生产 -> 打磨 -> 发布`

每个阶段都有三种连接方式：

| 连接方式 | 代表文件/技能 | 作用 |
|---|---|---|
| 路由连接 | `/help`、`workflow-catalog.yaml`、`skill-route-index.yaml` | 判断当前阶段、缺失工件和下一步推荐 |
| 工件连接 | GDD、ADR、Control Manifest、Epic、Story、Test Evidence | 把前一阶段产物变成后一阶段输入 |
| 把关连接 | `/design-system`、`/create-architecture`、`/story-done`、`/smoke-check`、`/gate-check` | 防止写作、实现、验收和阶段推进混在一起 |

当前主线是：

1. `/start` 或 `/help` 确定位置。
2. `/brainstorm`、`/setup-engine`、`/art-bible` 建立概念、引擎和视觉边界。
3. `/design-system` 处理系统索引、系统 GDD、设计审查和跨 GDD 一致性。
4. `/create-architecture` 处理架构蓝图、ADR、架构审查、TR registry 和控制清单。
5. `/sprint-plan` 把设计与架构转成 Epic、Story、Sprint、估算、状态和复盘。
6. `/dev-story` 实施，`/code-review` 审查，`/story-done` 验收。
7. `/smoke-check`、`/bug-report`、`/gate-check`、`/release-checklist` 处理 QA、缺陷、阶段推进和发布收口。

这就是它保留职责边界的核心原因：不是为了让人手选大量命令，而是为了让 AI 在不同证据面上不能自说自话。

## 项目适配层

当前体系使用 `.codex/docs/skill-route-index.yaml` 解决“AI 到底为什么推荐这个 Skill”的问题。它把项目事实分成两层：

| 层级 | 当前处理方式 | 能否作为常驻规则 |
|---|---|---|
| 稳定约束 | Codex-only、Godot 引擎族、AI 全链路开发方式、用户不手选大量命令 | 可以 |
| 可变设计事实 | 2D/3D、美术风格、视角、题材、核心循环、输入方式、平台、资源规格 | 不可以，必须从当前工件读取 |

因此，`/help` 可以稳定地偏向 Godot/Codex/AI 全链路的路线，但不能因为某次文档里写过 2D、某种美术风格或某种输入方式，就把它们写死到整个 Skill 体系里。那些内容只能作为“当前工件显示”的推荐依据。

## 控制不变量

- 写作和审查必须分开：写 GDD 的流程不能直接把自己的设计批准为阶段通过。
- 阶段推进必须是建议性判定：`/gate-check` 给 PASS/CONCERNS/FAIL，但最终由用户决定。
- 故事动线必须分开：`/dev-story -> /code-review -> /story-done`，实现者不能自证完成。
- 追踪链必须完整：GDD 需求 -> TR-ID -> ADR/Control Manifest -> Story -> Test Evidence。
- 提交必须是可恢复 checkpoint：只 stage 明确文件，并说明 Lane、Scope、Verification、Rollback。
- 研究方向必须用短分支和独立 worktree 隔离；clean-only 才允许自动合并。
- Inline director gate 固定 Lean policy；阶段推进只通过 `/gate-check` 运行 phase gate。
- 文件写入仍遵守协作协议：提问 -> 选项 -> 决策 -> 草稿 -> 批准 -> 写入。

## Hook 矩阵

Hook 的 Codex 化不是简单改路径。完整去留、迁移和可靠性审查见：`docs/ccgs-codex-hook-adaptation-plan.md`。当前默认启用的是 5 个 Codex-native Hook；旧 CCGS Hook 已移入 `.codex/hooks/legacy/`，强制性检查迁到 `.githooks/` 和 CI。

| Hook 文件 | 当前接入状态 | 具体作用 | 把关强度 |
|---|---|---|---|
| `session-start.sh` | SessionStart | 输出 JSON `additionalContext`，提供分支、阶段、恢复文件、Hook 提醒、工作树概况和低频 checkpoint 提醒。 | 建议型，不应阻塞。 |
| `detect-gaps-lite.sh` | SessionStart | 只检查明显路线缺口：引擎、概念、系统索引、Skill catalog。 | 建议型，不应阻塞。 |
| `dangerous-command-policy.sh` | PreToolUse，matcher=Bash\|apply_patch | 阻止 force push、hard reset、checkout 丢弃、核心目录递归删除。 | 阻塞明显危险操作。 |
| `skill-change-reminder.sh` | PostToolUse，matcher=Write\|Edit\|apply_patch | 解析 file_path 或 patch，发现 Skill 修改后提醒使用 `/skill-create-ccgs` 做内部验证和动线接入审计，并写入 hook-reminders。 | 建议型，不应阻塞。 |
| `post-compact-restore.sh` | PostCompact | 输出 JSON `systemMessage`，提醒压缩后读取 `active.md`。 | 建议型，不应阻塞。 |
| `.githooks/pre-commit` | git commit | 阻止无效 JSON；提醒 GDD 章节、硬编码数值、TODO owner、资源命名和 Skill 测试。 | JSON 阻塞，其余提醒。 |
| `.githooks/pre-push` | git push | 阻止直接推送 `main`、`master`、`develop`。 | 本地阻塞；最终应配合远端分支保护。 |

注意：Codex hooks 不是完整安全边界。强制性质量门应由 Git hooks 和 CI 承担；Codex hooks 只负责会话内上下文和轻量护栏。

## Skill 矩阵

当前体系只登记 `.agents/skills/` 中真实存在的 17 个核心 Skill。旧入口只作为 route alias 和吸收职责存在，不再保留 shadow spec 或 archive 影子目录。

| Skill | 路线组 | 阶段 | 优先级 | 测试 Spec | 吸收职责 | 边界 |
|---|---|---|---|---|---|---|
| `/start` | orientation | support | high | `CCGS Skill Testing Framework/skills/utility/start.md` | adopt、project-stage-detect、reverse-document | 首次引导和旧项目接入；不替代阶段 Gate。 |
| `/help` | orientation | support | high | `CCGS Skill Testing Framework/skills/utility/help.md` | onboard、project-stage-detect | 日常导航；必须解释推荐理由，不直接推进阶段。 |
| `/window-ccgs` | maintenance | support | critical | `CCGS Skill Testing Framework/skills/utility/window-ccgs.md` | window-start-ccgs、window-handoff-ccgs | 多窗口恢复、更新、审计、压缩、checkpoint 建议和 research worktree；不改变各 lane owner。 |
| `/skill-create-ccgs` | maintenance | support | critical | `CCGS Skill Testing Framework/skills/utility/skill-create-ccgs.md` | skill-test、skill-improve、skill-creator | Skill 治理唯一入口；必须完成 route/catalog/spec/workflow/Hook 接入审计。 |
| `/setup-engine` | architecture | concept | high | `CCGS Skill Testing Framework/skills/utility/setup-engine.md` | test-setup | 固定 Godot、GDScript、工具路径和最小测试基础。 |
| `/brainstorm` | design | concept | high | `CCGS Skill Testing Framework/skills/utility/brainstorm.md` | prototype | 形成游戏概念和核心循环；写入前保留协作确认。 |
| `/design-system` | design | systems-design | critical | `CCGS Skill Testing Framework/skills/authoring/design-system.md` | map-systems、quick-design、design-review、review-all-gdds、consistency-check、balance-check、propagate-design-change | GDD 主入口；同时保留设计审查和跨 GDD 一致性边界。 |
| `/art-bible` | design | concept/pre-production | high | `CCGS Skill Testing Framework/skills/authoring/art-bible.md` | asset-spec、asset-audit、content-audit、ux-design、ux-review、team-ui、team-audio | 视觉、资产、UX 和音频规格入口；不写玩法结论。 |
| `/create-architecture` | architecture | technical-setup | critical | `CCGS Skill Testing Framework/skills/authoring/create-architecture.md` | architecture-decision、architecture-review、create-control-manifest | 架构蓝图、ADR、TR registry、审查和控制清单；不得绕过 Accepted ADR 状态。 |
| `/sprint-plan` | planning | pre-production/production | high | `CCGS Skill Testing Framework/skills/sprint/sprint-plan.md` | create-epics、create-stories、estimate、sprint-status、scope-check、retrospective | Epic、Story、Sprint、估算、范围、状态和复盘入口；`production/sprint-status.yaml` 是状态源。 |
| `/dev-story` | implementation | production | critical | `CCGS Skill Testing Framework/skills/pipeline/dev-story.md` | story-readiness、team-combat、team-level、team-narrative | 实施入口；开工前做 readiness preflight，但不能自证完成。 |
| `/story-done` | implementation | production | critical | `CCGS Skill Testing Framework/skills/readiness/story-done.md` | test-evidence-review | 完成度审查和状态收口；验证实现、证据、GDD/ADR 偏差。 |
| `/code-review` | implementation | production | high | `CCGS Skill Testing Framework/skills/analysis/code-review.md` | tech-debt、perf-profile、security-audit | 代码质量和架构风险审查；输出发现，不替用户改范围。 |
| `/smoke-check` | qa | production | high | `CCGS Skill Testing Framework/skills/utility/smoke-check.md` | qa-plan、regression-suite、test-helpers、test-flakiness、playtest-report、soak-test、team-qa、team-polish | QA 前冒烟和关键路径验证；失败时阻止进入手动 QA。 |
| `/bug-report` | qa | production | medium | `CCGS Skill Testing Framework/skills/utility/bug-report.md` | bug-triage、hotfix | 缺陷记录、复现、分级和修复分流。 |
| `/gate-check` | qa | support | critical | `CCGS Skill Testing Framework/skills/gate/gate-check.md` | milestone-review、vertical-slice | 阶段推进 PASS/CONCERNS/FAIL 判定；只建议，不替用户推进阶段。 |
| `/release-checklist` | release | release | medium | `CCGS Skill Testing Framework/skills/utility/release-checklist.md` | changelog、patch-notes、launch-checklist、day-one-patch、localize、team-release、team-live-ops | 发布就绪、商店材料、补丁和上线后收口。 |

## 为什么仍保留职责边界

| 边界 | 保留原因 | 如果继续压扁的风险 |
|---|---|---|
| `/help` 与 `/gate-check` | 导航建议和阶段判定必须分离。 | 下一步建议会被误读成阶段已通过。 |
| `/design-system` 与 `/create-architecture` | 玩法/系统规则和技术架构证据不同。 | 架构可能跳过 GDD 需求追踪，或设计文档写入技术假设。 |
| `/create-architecture` 与 `/sprint-plan` | ADR/TR registry/control manifest 是 Story 的上游。 | Story 可能缺少 ADR、TR-ID 或控制清单版本。 |
| `/dev-story` 与 `/story-done` | 实施和完成验证必须分开。 | 实现者容易把未验证的验收标准标成完成。 |
| `/smoke-check` 与 `/gate-check` | 构建冒烟和阶段通行是不同质量门。 | 冒烟通过会被误认为整阶段通过。 |
| `/skill-create-ccgs` 与普通业务 Skill | Skill 治理会修改 route、catalog、spec、Hook 和文档。 | 普通业务流程可能只改一个 Skill 文件，留下断裂动线。 |
| checkpoint 与普通提交 | checkpoint 是恢复点，必须能解释和回滚。 | 宽泛提交会把多个 lane 的变更混在一起，回滚时伤到无关工作。 |
| research worktree 与共享 worktree | 研究分支不能切走其他窗口正在使用的工作树。 | 多窗口会在同一分支上下文里互相踩状态。 |

## 优化的必要性

即使不考虑新增 Skill，优化仍然有必要，原因不是“文件太多所以删”，而是控制层必须对人透明：

1. 你实际不会手动选择大量命令，你会问 AI “现在用什么”。所以真正的压力不在命令数量，而在 AI 路由是否可解释。
2. 如果 `/help` 只给结论，不说明为什么选这个 Skill、为什么没选另一个 Skill，你就无法判断它是在遵循体系，还是在用 LLM 直觉猜。
3. Hook 脚本数量和默认接入状态必须讲清楚，避免误以为所有 Hook 都在自动把关。
4. Skill 过长本身不是问题；1000 行以内可以接受。真正的问题是触发、路由、证据边界或审查责任被埋掉。
5. 旧入口只能作为 alias 路由存在；真实行为必须进入核心 Skill 主体或 direct references。

所以优化目标不是削弱把关，而是把“路由层”和“证据层”分开：人看到的是更轻的入口，底层保留必要的审查面。

## 优化方案

### 1. 先减少暴露入口，再按证据删除或合并 Skill

第一步不是按数量粗暴删除，而是先减少用户可见入口。保留必要专业 Skill 作为证据面，让 `/help` 只展示更少的路线组：

- `orientation`：`/start`、`/help`
- `design`：`/brainstorm`、`/design-system`、`/art-bible`
- `architecture`：`/setup-engine`、`/create-architecture`
- `planning`：`/sprint-plan`
- `implementation`：`/dev-story`、`/code-review`、`/story-done`
- `qa`：`/smoke-check`、`/bug-report`、`/gate-check`
- `release`：`/release-checklist`
- `maintenance`：`/skill-create-ccgs`、`/window-ccgs`

### 2. 把旧入口变成 absorbed alias

Route index 保留旧说法到核心 Skill 的转译能力，但旧 Skill 内容不能作为运行时依赖。凡是会影响路径、判定、状态字段、写入边界、Godot 约束或测试证据的内容，都必须迁移进核心 Skill 或 direct `references/`。迁移完成后删除冗余 spec 和 archive 影子目录。

### 3. 按证据边界优化，而不是按行数优化

现在不再把 300-500 行当成硬目标。1000 行以内只要触发清楚、阶段清楚、读写边界清楚、判定词清楚，就可以保留。只有当检查表、示例、章节模板反复遮挡核心流程，或 `/skill-create-ccgs` 的内部验证证明行为不稳定时，才把稳定不变的内容下沉到 `references/`。

### 4. 增加路线索引，而不是删除护栏

`.codex/docs/skill-route-index.yaml` 记录每个核心 Skill 的路线组、阶段、推荐理由、吸收职责和不适用场景。`/help` 读取它后，必须解释“为什么推荐这个 Skill”，并区分稳定约束和当前工件事实。

### 5. 合并 Skill 必须有证据

只有三个条件同时满足，才考虑合并：输入工件相同、输出工件相同、判定词汇相同。只要有一个不同，就不应该合并。最可能合并的是窄范围状态/报告类，不是写作、审查、准入、关卡类。

## 新 Skill 加入方案

每个新 Skill 必须先接入体系，再算被接受。默认先运行 `/skill-create-ccgs`，让它判断是新增、修改、references-only、route-only 还是不建议接入：

1. 定义职责类型：authoring、review、readiness、pipeline、analysis、team、sprint、utility 或 gate。
2. 在 frontmatter description 写清楚触发语言、适用场景和不适用场景。
3. 定义读取哪些上游工件、写入哪些下游工件。
4. 决定它是核心入口、absorbed alias，还是只应进入 references。
5. 新增文件：`.agents/skills/<name>/SKILL.md`。
6. 如果影响导航，更新 `.codex/docs/workflow-catalog.yaml` 或 `.codex/docs/skill-route-index.yaml`。
7. 新增行为 spec：`CCGS Skill Testing Framework/skills/<category>/<name>.md`。
8. 在 `CCGS Skill Testing Framework/catalog.yaml` 登记 category 和 priority。
9. 更新本架构文档的 Skill 矩阵。
10. 由 `/skill-create-ccgs` 内部完成 static、category、spec、route/catalog、workflow insertion 和 Hook 影响验证。

新增 Skill 的判断标准：它必须有独立的工件边界或独立的质量门。如果只是给现有 Skill 补充上下文，优先加 `references/` 或 route-index，不要新建 Slash command。

## 新 Hook 加入方案

1. 脚本放在 `.codex/hooks/`，保持 POSIX 兼容，并兼容 Windows Git Bash。
2. 在 `.codex/hooks.json` 用相对路径接入，不写绝对机器路径。
3. Hook 不适用时必须快速 `exit 0`。
4. 阻塞型 Hook 只用于会破坏构建、破坏数据或危险操作的场景；建议型 Hook 只输出短提示。
5. 更新本文 Hook 矩阵和 `.codex/docs/hooks-reference.md`。

## 后续待办

- 持续维护 `skill-route-index.yaml`，让新增或修改的 Skill 都有 route entry、推荐理由和不适用场景。
- 只在超过 1000 行、触发不清、审查责任不清或测试失败时，再拆 Skill 的 references。
- 用 `/skill-create-ccgs` 内部审计校验：每个 `.agents/skills/*/SKILL.md` 都必须有 catalog entry、spec path 和 route entry。
- 继续按“核心 Skill + direct references + 删除旧目录/旧 spec”的标准，处理 implementation、QA、release、support 组。
- 继续把公开文档里的旧版本历史说明压缩成 Codex-only 维护说明，避免重新引入双生态。
