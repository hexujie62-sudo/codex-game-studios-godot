# CCGS Codex 单生态架构文档

生成日期：2026-06-04

这份文档是当前 CCGS Codex 单生态体系的总索引。它的目的不是宣传项目，而是让你能随时判断：这个体系有几条动线、每个阶段靠什么连接、每个 SKILL/HOOK 文件具体负责什么、哪些把关机制不能合并、后续新增 Skill 应该怎样接入。

## 当前规模

- Agent：49 个，位置：`.codex/agents/*.toml`
- Skill：76 个，位置：`.agents/skills/*/SKILL.md`
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
| Skill Route Index | `.codex/docs/skill-route-index.yaml` | Skill 推荐的解释层：core/support/explicit-only、项目稳定约束、可变设计事实 |
| Docs/Templates | `.codex/docs/` | 标准、模板、Gate 定义、Hook/Skill/Agent 参考 |
| Codex Hooks | `.codex/hooks/*.sh` 和 `.codex/hooks.json` | 会话上下文、轻量提醒、危险命令软拦截 |
| Git Hooks | `.githooks/` | 本地 commit/push 前检查 |
| Rules | `.codex/rules/*.md` | 路径级代码/设计规范 |
| Skill 测试 | `CCGS Skill Testing Framework/` | Skill/Agent 的行为规范、分类和回归测试索引 |

旧的 Anthropic 命名层已经从底层迁出；目录级说明现在统一使用 `AGENTS.md`。

## 原始动线设计

CCGS 的原始动线不是“76 个命令让人手选”，而是一个七阶段工作流：

`概念形成 -> 系统设计 -> 技术设置 -> 预生产 -> 生产 -> 打磨 -> 发布`

每个阶段都有三种连接方式：

| 连接方式 | 代表文件/技能 | 作用 |
|---|---|---|
| 路由连接 | `/help`、`workflow-catalog.yaml` | 判断当前阶段、缺失工件和下一步推荐 |
| 工件连接 | GDD、ADR、Control Manifest、Epic、Story、Test Evidence | 把前一阶段产物变成后一阶段输入 |
| 把关连接 | `/design-review`、`/architecture-review`、`/story-readiness`、`/story-done`、`/gate-check` | 防止写作、实现和验收混在一起 |

最重要的主线是：

1. `/start` 或 `/help` 确定位置。
2. `/brainstorm`、`/setup-engine`、`/art-bible`、`/map-systems` 建立概念和系统边界。
3. `/design-system` 逐系统写 GDD，`/design-review` 和 `/review-all-gdds` 把关。
4. `/create-architecture`、`/architecture-decision`、`/architecture-review` 建立技术蓝图和 ADR 追踪。
5. `/create-control-manifest`、`/create-epics`、`/create-stories` 把设计转成可执行工作。
6. `/story-readiness` 确认故事可开工，`/dev-story` 实现，`/code-review` 审查，`/story-done` 验收。
7. `/qa-plan`、`/smoke-check`、`/regression-suite`、`/test-evidence-review`、`/gate-check` 决定是否进入下一阶段。

这就是它拆得很细的核心原因：不是为了让人选 76 个命令，而是为了让 AI 在不同证据面上不能自说自话。

## 项目适配层

当前体系新增 `.codex/docs/skill-route-index.yaml`，用来解决“AI 到底为什么推荐这个 Skill”的问题。它把项目事实分成两层：

| 层级 | 当前处理方式 | 能否作为常驻规则 |
|---|---|---|
| 稳定约束 | Codex-only、Godot 引擎族、AI 全链路开发方式、用户不手选 76 个命令 | 可以 |
| 可变设计事实 | 2D/3D、美术风格、视角、题材、核心循环、输入方式、平台、资源规格 | 不可以，必须从当前工件读取 |

因此，`/help` 可以稳定地偏向 Godot/Codex/AI 全链路的路线，但不能因为某次文档里写过 2D、某种美术风格或某种输入方式，就把它们写死到整个 Skill 体系里。那些内容只能作为“当前工件显示”的推荐依据。

## 控制不变量

- 写作和审查必须分开：写 GDD 的 Skill 不能同时负责批准 GDD。
- 阶段推进必须是建议性判定：`/gate-check` 给 PASS/CONCERNS/FAIL，但最终由用户决定。
- 故事动线必须分开：`/story-readiness -> /dev-story -> /code-review -> /story-done`，实现者不能自证完成。
- 追踪链必须完整：GDD 需求 -> TR-ID -> ADR/Control Manifest -> Story -> Test Evidence。
- Review mode 只改变审查强度，不改变必要工件：`full`、`lean`、`solo` 不能让必需产物消失。
- 文件写入仍遵守协作协议：提问 -> 选项 -> 决策 -> 草稿 -> 批准 -> 写入。

## Hook 矩阵

Hook 的 Codex 化不是简单改路径。完整去留、迁移和可靠性审查见：`docs/ccgs-codex-hook-adaptation-plan.md`。当前默认启用的是 5 个 Codex-native Hook；旧 CCGS Hook 已移入 `.codex/hooks/legacy/`，强制性检查迁到 `.githooks/` 和 CI。

| Hook 文件 | 当前接入状态 | 具体作用 | 把关强度 |
|---|---|---|---|
| `session-start.sh` | SessionStart | 输出 JSON `additionalContext`，提供分支、阶段、恢复文件、Hook 提醒和工作树概况。 | 建议型，不应阻塞。 |
| `detect-gaps-lite.sh` | SessionStart | 只检查明显路线缺口：引擎、概念、系统索引、Skill catalog。 | 建议型，不应阻塞。 |
| `dangerous-command-policy.sh` | PreToolUse，matcher=Bash\|apply_patch | 阻止 force push、hard reset、checkout 丢弃、核心目录递归删除。 | 阻塞明显危险操作。 |
| `skill-change-reminder.sh` | PostToolUse，matcher=Write\|Edit\|apply_patch | 解析 file_path 或 patch，发现 Skill 修改后提醒 `/skill-test`，并写入 hook-reminders。 | 建议型，不应阻塞。 |
| `post-compact-restore.sh` | PostCompact | 输出 JSON `systemMessage`，提醒压缩后读取 `active.md`。 | 建议型，不应阻塞。 |
| `.githooks/pre-commit` | git commit | 阻止无效 JSON；提醒 GDD 章节、硬编码数值、TODO owner、资源命名和 Skill 测试。 | JSON 阻塞，其余提醒。 |
| `.githooks/pre-push` | git push | 阻止直接推送 `main`、`master`、`develop`。 | 本地阻塞；最终应配合远端分支保护。 |

注意：Codex hooks 不是完整安全边界。强制性质量门应由 Git hooks 和 CI 承担；Codex hooks 只负责会话内上下文和轻量护栏。

## Skill 矩阵

| Skill | 类别 | 优先级 | 所属阶段 | 必需 | 可重复 | 行数 | 测试 Spec | 用途 | 边界差异 |
|---|---|---|---|---|---:|---:|---|---|---|
| `/adopt` | 工具(utility) | 低(low) | 支持/显式调用 | 不适用 | 不适用 | 444 | CCGS Skill Testing Framework/skills/utility/adopt.md | 现有项目接入 — 审计现有项目工件是否符合模板格式（不仅是存在性），按影响分类缺失内容，并生成编号的迁移计划。在加入进行中的项目或从旧版本模板升级时运行。与 /project… | 负责导航、设置、发布、辅助或例外流程；很多应保持显式调用。 |
| `/architecture-decision` | 写作(authoring) | 高(high) | 技术设置 | 是 | 是 | 457 | CCGS Skill Testing Framework/skills/authoring/architecture-decision.md | 创建架构决策记录（ADR），记录重要技术决策及其上下文、考虑的替代方案和后果。每个主要技术选择都应有 ADR。 | 负责产出文档或规范；必须保留草稿、确认、写入的协作闭环。 |
| `/architecture-review` | 审查(review) | 关键(critical) | 技术设置 | 是 | 否 | 666 | CCGS Skill Testing Framework/skills/review/architecture-review.md | 根据所有 GDD 验证项目架构的完整性和一致性。构建可追溯性矩阵，将每个 GDD 技术需求映射到 ADR，识别覆盖缺口，检测跨 ADR 冲突，验证所有决策的引擎兼容性一致性，… | 负责独立审查；不能和写作技能合并，否则会削弱把关。 |
| `/art-bible` | 写作(authoring) | 低(low) | 概念形成 | 是 | 否 | 250 | CCGS Skill Testing Framework/skills/authoring/art-bible.md | 引导式、逐章节的美术圣经编写。创建视觉识别规范，控制所有资源生产。在 /brainstorm 获批后、在 /map-systems 或任何 GDD 编写开始之前运行。 | 负责产出文档或规范；必须保留草稿、确认、写入的协作闭环。 |
| `/asset-audit` | 分析(analysis) | 低(low) | 打磨 | 否 | 否 | 96 | CCGS Skill Testing Framework/skills/analysis/asset-audit.md | 审计游戏资源是否符合命名约定、文件大小预算、格式标准和流程要求。识别孤立资源、缺失引用和标准违规。 | 负责风险扫描和报告；通常不直接改动工件，供 Gate 或用户决策使用。 |
| `/asset-spec` | 工具(utility) | 低(low) | 预生产 | 否 | 是 | 353 | CCGS Skill Testing Framework/skills/utility/asset-spec.md | 从 GDD、关卡文档或角色档案生成每个资源的视觉规范和 AI 生成提示。生成结构化规范文件并更新主资源清单。在美术圣经和 GDD/关卡设计获批后、生产开始之前运行。 | 负责导航、设置、发布、辅助或例外流程；很多应保持显式调用。 |
| `/balance-check` | 分析(analysis) | 低(low) | 打磨 | 否 | 否 | 124 | CCGS Skill Testing Framework/skills/analysis/balance-check.md | 分析游戏平衡数据文件、公式和配置，以识别异常值、损坏的进度、退化的策略和经济失衡。在修改任何与平衡相关的数据或设计后使用。当用户说'平衡报告'、'检查游戏平衡'、'运行平衡检… | 负责风险扫描和报告；通常不直接改动工件，供 Gate 或用户决策使用。 |
| `/brainstorm` | 工具(utility) | 低(low) | 概念形成 | 否/是 | 否 | 360 | CCGS Skill Testing Framework/skills/utility/brainstorm.md | 引导式游戏概念构思 — 从零想法到结构化的游戏概念文档。使用专业工作室构思技巧、玩家心理框架和结构化创意探索。 | 负责导航、设置、发布、辅助或例外流程；很多应保持显式调用。 |
| `/bug-report` | 工具(utility) | 低(low) | 生产 | 否 | 是 | 165 | CCGS Skill Testing Framework/skills/utility/bug-report.md | 根据描述创建结构化错误报告，或分析代码以识别潜在错误。确保每个错误报告都有完整的复现步骤、严重性评估和上下文。 | 负责导航、设置、发布、辅助或例外流程；很多应保持显式调用。 |
| `/bug-triage` | 工具(utility) | 低(low) | 支持/显式调用 | 不适用 | 不适用 | 245 | CCGS Skill Testing Framework/skills/utility/bug-triage.md | 读取 production/qa/bugs/ 中的所有未解决错误，重新评估优先级与严重性，分配到冲刺，显示系统趋势，并生成分类报告。在冲刺开始时或错误数量增长到需要重新确定优… | 负责导航、设置、发布、辅助或例外流程；很多应保持显式调用。 |
| `/changelog` | 冲刺(sprint) | 低(low) | 发布 | 否 | 否 | 178 | CCGS Skill Testing Framework/skills/sprint/changelog.md | 从 git 提交、冲刺数据和设计文档自动生成变更日志。生成内部和面向玩家的两个版本。 | 负责生产节奏、状态和对外/对内记录。 |
| `/code-review` | 分析(analysis) | 低(low) | 生产 | 否 | 是 | 186 | CCGS Skill Testing Framework/skills/analysis/code-review.md | 对指定文件或文件集执行架构和质量的代码审查。检查编码标准合规性、架构模式遵守情况、SOLID 原则、可测试性和性能问题。 | 负责风险扫描和报告；通常不直接改动工件，供 Gate 或用户决策使用。 |
| `/consistency-check` | 分析(analysis) | 高(high) | 系统设计 | 否 | 是 | 309 | CCGS Skill Testing Framework/skills/analysis/consistency-check.md | 根据实体注册表扫描所有 GDD 以检测跨文档的不一致性：具有不同属性的相同实体、具有不同值的相同项目、具有不同变量的相同公式。Grep 优先方法——读取注册表然后仅针对冲突的… | 负责风险扫描和报告；通常不直接改动工件，供 Gate 或用户决策使用。 |
| `/content-audit` | 分析(analysis) | 低(low) | 支持/显式调用 | 不适用 | 不适用 | 206 | CCGS Skill Testing Framework/skills/analysis/content-audit.md | 根据实施内容审计 GDD 指定的内容数量。识别已计划与已构建的内容。 | 负责风险扫描和报告；通常不直接改动工件，供 Gate 或用户决策使用。 |
| `/create-architecture` | 写作(authoring) | 低(low) | 技术设置 | 是 | 否 | 469 | CCGS Skill Testing Framework/skills/authoring/create-architecture.md | 引导式、逐章节编写游戏的主架构文档。读取所有 GDD、系统索引、现有 ADR 和引擎参考库，在编写任何代码之前生成完整的架构蓝图。支持引擎版本感知：标记知识缺口并根据固定引擎… | 负责产出文档或规范；必须保留草稿、确认、写入的协作闭环。 |
| `/create-control-manifest` | 流水线(pipeline) | 高(high) | 技术设置 | 是 | 否 | 289 | CCGS Skill Testing Framework/skills/pipeline/create-control-manifest.md | 架构完成后，为程序员生成一个可操作的规则清单——必须做什么、绝不能做什么，按系统和按层级。从所有已接受的 ADR、技术偏好和引擎参考文档中提取。比 ADR 更可操作（ADR … | 负责把上游工件转成下游可执行工作，例如系统图、史诗、故事、实现。 |
| `/create-epics` | 流水线(pipeline) | 高(high) | 预生产 | 是 | 是 | 246 | CCGS Skill Testing Framework/skills/pipeline/create-epics.md | 将已批准的 GDD 和架构转化为史诗——每个架构模块一个史诗。定义范围、管辖 ADR、引擎风险和未跟踪的需求。不分解为故事——在每个史诗创建后运行 /create-stori… | 负责把上游工件转成下游可执行工作，例如系统图、史诗、故事、实现。 |
| `/create-stories` | 流水线(pipeline) | 高(high) | 预生产 | 是 | 是 | 334 | CCGS Skill Testing Framework/skills/pipeline/create-stories.md | 将单个史诗分解为可实施的故事文件。读取史诗、其 GDD、管辖 ADR 和控制清单。每个故事嵌入其 GDD 需求 TR-ID、ADR 指导、验收标准、故事类型和测试证据路径。在… | 负责把上游工件转成下游可执行工作，例如系统图、史诗、故事、实现。 |
| `/day-one-patch` | 工具(utility) | 低(low) | 支持/显式调用 | 不适用 | 不适用 | 227 | CCGS Skill Testing Framework/skills/utility/day-one-patch.md | 为游戏发布准备首日补丁。确定范围、确定优先级、实施并通过 QA 关卡一个专注的补丁，解决在黄金母版之后但在公开发布之前或之后立即发现的已知问题。将补丁视为一个具有自己的 QA… | 负责导航、设置、发布、辅助或例外流程；很多应保持显式调用。 |
| `/design-review` | 审查(review) | 关键(critical) | 概念形成、系统设计 | 否/是 | 是 | 269 | CCGS Skill Testing Framework/skills/review/design-review.md | 审查游戏设计文档的完整性、内部一致性、可实现性和项目设计标准的遵守情况。在将设计文档交给程序员之前运行。 | 负责独立审查；不能和写作技能合并，否则会削弱把关。 |
| `/design-system` | 写作(authoring) | 高(high) | 系统设计 | 是 | 是 | 872 | CCGS Skill Testing Framework/skills/authoring/design-system.md | 针对单个游戏系统的引导式、逐章节 GDD 编写。从现有文档收集上下文，协作式遍历每个必需章节，交叉引用依赖关系，并增量写入文件。 | 负责产出文档或规范；必须保留草稿、确认、写入的协作闭环。 |
| `/dev-story` | 流水线(pipeline) | 高(high) | 生产 | 是 | 是 | 326 | CCGS Skill Testing Framework/skills/pipeline/dev-story.md | 读取故事文件并实现它。加载完整上下文（故事、GDD 需求、ADR 指导原则、控制清单），路由到适合系统和引擎的程序员代理，实现代码和测试，并确认每个验收标准。核心实现技能 —… | 负责把上游工件转成下游可执行工作，例如系统图、史诗、故事、实现。 |
| `/estimate` | 分析(analysis) | 低(low) | 支持/显式调用 | 不适用 | 不适用 | 133 | CCGS Skill Testing Framework/skills/analysis/estimate.md | 通过分析复杂性、依赖关系、历史速度和风险因素来估算任务工作量。生成带有置信度水平的结构化估算。 | 负责风险扫描和报告；通常不直接改动工件，供 Gate 或用户决策使用。 |
| `/gate-check` | 关卡(gate) | 关键(critical) | 支持/显式调用 | 不适用 | 不适用 | 543 | CCGS Skill Testing Framework/skills/gate/gate-check.md | 验证在开发阶段之间推进的就绪状态。生成带有具体阻碍和必需工件的通过/关注/失败的判定。当用户说'我们是否准备好进入 X'、'我们可以进入生产阶段吗'、'检查我们是否可以开始下… | 负责阶段通行判定；是体系控制点，不能和 authoring 技能合并。 |
| `/help` | 工具(utility) | 低(low) | 支持/显式调用 | 不适用 | 不适用 | 229 | CCGS Skill Testing Framework/skills/utility/help.md | 分析已完成的工作和用户查询，并就下一步提供建议。当用户说接下来该做什么或现在该做什么或遇到困难或不知道该做什么时使用 | 负责导航、设置、发布、辅助或例外流程；很多应保持显式调用。 |
| `/hotfix` | 工具(utility) | 低(low) | 支持/显式调用 | 不适用 | 不适用 | 181 | CCGS Skill Testing Framework/skills/utility/hotfix.md | 绕过正常冲刺流程的紧急修复工作流程，具有完整的审计跟踪。创建热修复分支，跟踪批准，并确保修复正确地反向移植。 | 负责导航、设置、发布、辅助或例外流程；很多应保持显式调用。 |
| `/launch-checklist` | 工具(utility) | 低(low) | 发布 | 是 | 否 | 241 | CCGS Skill Testing Framework/skills/utility/launch-checklist.md | 完整的发布就绪性验证，涵盖每个部门：代码、内容、商店、营销、社区、基础设施、法律以及进行/不进行的签署。 | 负责导航、设置、发布、辅助或例外流程；很多应保持显式调用。 |
| `/localize` | 工具(utility) | 低(low) | 支持/显式调用 | 不适用 | 不适用 | 442 | CCGS Skill Testing Framework/skills/utility/localize.md | 完整的本地化流程：扫描硬编码字符串、提取和管理字符串表、验证翻译、生成译者简报、运行文化/敏感性审查、管理语音本地化、测试 RTL/平台要求、强制字符串冻结并报告覆盖率。 | 负责导航、设置、发布、辅助或例外流程；很多应保持显式调用。 |
| `/map-systems` | 流水线(pipeline) | 高(high) | 概念形成 | 是 | 否 | 365 | CCGS Skill Testing Framework/skills/pipeline/map-systems.md | 将游戏概念分解为单独的系统，映射依赖关系，确定设计优先级，并创建系统索引。 | 负责把上游工件转成下游可执行工作，例如系统图、史诗、故事、实现。 |
| `/milestone-review` | 冲刺(sprint) | 低(low) | 支持/显式调用 | 不适用 | 不适用 | 157 | CCGS Skill Testing Framework/skills/sprint/milestone-review.md | 生成全面的里程碑进度审查，包括功能完整性、质量指标、风险评估和进行/不进行的建议。在里程碑检查点或评估里程碑截止日期的就绪性时使用。 | 负责生产节奏、状态和对外/对内记录。 |
| `/onboard` | 工具(utility) | 低(low) | 支持/显式调用 | 不适用 | 不适用 | 97 | CCGS Skill Testing Framework/skills/utility/onboard.md | 为加入项目的新贡献者或代理生成上下文感知的入职文档。总结与指定角色或领域相关的项目状态、架构、约定和当前优先级。 | 负责导航、设置、发布、辅助或例外流程；很多应保持显式调用。 |
| `/patch-notes` | 冲刺(sprint) | 低(low) | 发布 | 否 | 否 | 187 | CCGS Skill Testing Framework/skills/sprint/patch-notes.md | 从 git 历史、冲刺数据和内部变更日志生成面向玩家的补丁说明。将开发者语言转化为清晰、引人入胜的玩家沟通内容。 | 负责生产节奏、状态和对外/对内记录。 |
| `/perf-profile` | 分析(analysis) | 低(low) | 打磨 | 否 | 否 | 127 | CCGS Skill Testing Framework/skills/analysis/perf-profile.md | 结构化性能分析工作流程。识别瓶颈、根据预算进行测量并生成带有优先级排名的优化建议。 | 负责风险扫描和报告；通常不直接改动工件，供 Gate 或用户决策使用。 |
| `/playtest-report` | 工具(utility) | 低(low) | 打磨 | 是 | 否 | 148 | CCGS Skill Testing Framework/skills/utility/playtest-report.md | 生成结构化的游戏测试报告模板或将现有游戏测试笔记分析为结构化格式。使用此功能来标准化游戏测试反馈的收集和分析。 | 负责导航、设置、发布、辅助或例外流程；很多应保持显式调用。 |
| `/project-stage-detect` | 工具(utility) | 低(low) | 支持/显式调用 | 不适用 | 不适用 | 196 | CCGS Skill Testing Framework/skills/utility/project-stage-detect.md | 自动分析项目状态、检测阶段、识别缺口，并根据现有工件推荐下一步。当用户询问'我们在开发中的什么位置'、'我们处于什么阶段'、'完整项目审计'时使用。 | 负责导航、设置、发布、辅助或例外流程；很多应保持显式调用。 |
| `/propagate-design-change` | 流水线(pipeline) | 高(high) | 支持/显式调用 | 不适用 | 不适用 | 240 | CCGS Skill Testing Framework/skills/pipeline/propagate-design-change.md | 当 GDD 被修订时，扫描所有 ADR 和可追溯性索引以识别哪些架构决策现在可能已过时。生成变更影响报告并指导用户完成解决方案。 | 负责把上游工件转成下游可执行工作，例如系统图、史诗、故事、实现。 |
| `/prototype` | 工具(utility) | 低(low) | 预生产 | 否 | 否 | 580 | CCGS Skill Testing Framework/skills/utility/prototype.md | 概念原型 — 在编写 GDD 之前验证核心想法是否值得设计。在 /brainstorm 和 /setup-engine 之后立即运行。根据游戏类型路由到 HTML、引擎或纸面… | 负责导航、设置、发布、辅助或例外流程；很多应保持显式调用。 |
| `/qa-plan` | 工具(utility) | 低(low) | 生产 | 否 | 是 | 279 | CCGS Skill Testing Framework/skills/utility/qa-plan.md | 为冲刺或功能生成 QA 测试计划。读取 GDD 和故事文件，按测试类型（逻辑/集成/视觉/UI）分类故事，并生成结构化测试计划，包括所需的自动化测试、手动测试用例、冒烟测试范… | 负责导航、设置、发布、辅助或例外流程；很多应保持显式调用。 |
| `/quick-design` | 写作(authoring) | 低(low) | 支持/显式调用 | 不适用 | 不适用 | 296 | CCGS Skill Testing Framework/skills/authoring/quick-design.md | 针对小更改的轻量级设计规范——调优调整、次要机制、平衡微调。当系统 GDD 已存在或更改太小而不需要完整 GDD 时，跳过完整的 GDD 编写。生成直接嵌入到故事文件中的快速… | 负责产出文档或规范；必须保留草稿、确认、写入的协作闭环。 |
| `/regression-suite` | 工具(utility) | 低(low) | 支持/显式调用 | 不适用 | 不适用 | 257 | CCGS Skill Testing Framework/skills/utility/regression-suite.md | 将测试覆盖率映射到 GDD 关键路径，识别没有回归测试的已修复错误，标记新功能导致的覆盖率漂移，并维护 tests/regression-suite.md。在实施错误修复后或… | 负责导航、设置、发布、辅助或例外流程；很多应保持显式调用。 |
| `/release-checklist` | 工具(utility) | 低(low) | 发布 | 是 | 否 | 183 | CCGS Skill Testing Framework/skills/utility/release-checklist.md | 生成全面的前发布验证清单，涵盖构建验证、认证要求、商店元数据和发布就绪性。 | 负责导航、设置、发布、辅助或例外流程；很多应保持显式调用。 |
| `/retrospective` | 冲刺(sprint) | 低(low) | 生产 | 否 | 是 | 222 | CCGS Skill Testing Framework/skills/sprint/retrospective.md | 通过分析已完成的工作、速度、阻碍和模式，生成冲刺或里程碑回顾。为下一次迭代生成可操作的见解。 | 负责生产节奏、状态和对外/对内记录。 |
| `/reverse-document` | 工具(utility) | 低(low) | 支持/显式调用 | 不适用 | 不适用 | 264 | CCGS Skill Testing Framework/skills/utility/reverse-document.md | 从现有实现生成设计或架构文档。从代码/原型反向工作以创建缺失的规划文档。 | 负责导航、设置、发布、辅助或例外流程；很多应保持显式调用。 |
| `/review-all-gdds` | 审查(review) | 关键(critical) | 系统设计 | 是 | 否 | 640 | CCGS Skill Testing Framework/skills/review/review-all-gdds.md | 全面的跨 GDD 一致性和游戏设计审查。同时读取所有系统 GDD 并检查它们之间的矛盾、过时的引用、所有权冲突、公式不兼容和游戏设计理论违规（主导策略、经济失衡、认知过载、支… | 负责独立审查；不能和写作技能合并，否则会削弱把关。 |
| `/scope-check` | 分析(analysis) | 低(low) | 生产 | 否 | 是 | 129 | CCGS Skill Testing Framework/skills/analysis/scope-check.md | 通过将当前范围与原始计划进行比较，分析功能或冲刺的范围蔓延。标记添加内容，量化膨胀，并建议削减。当用户说'是否有范围蔓延'、'范围审查'、'我们是否保持在范围内'时使用。 | 负责风险扫描和报告；通常不直接改动工件，供 Gate 或用户决策使用。 |
| `/security-audit` | 分析(analysis) | 低(low) | 支持/显式调用 | 不适用 | 不适用 | 246 | CCGS Skill Testing Framework/skills/analysis/security-audit.md | 审计游戏的安全漏洞：存档篡改、作弊向量、网络漏洞、数据暴露和输入验证缺口。生成带有修复指导的优先级安全报告。在任何公开发布或多人游戏启动之前运行。 | 负责风险扫描和报告；通常不直接改动工件，供 Gate 或用户决策使用。 |
| `/setup-engine` | 工具(utility) | 低(low) | 概念形成 | 是 | 否 | 717 | CCGS Skill Testing Framework/skills/utility/setup-engine.md | 配置项目的游戏引擎和版本。在 AGENTS.md 中固定引擎版本，检测知识缺口，并在版本超出 LLM 训练数据时通过 WebSearch 填充引擎参考文档。 | 负责导航、设置、发布、辅助或例外流程；很多应保持显式调用。 |
| `/skill-create-ccgs` | 工具(utility) | 中(medium) | 支持/显式调用 | 不适用 | 不适用 | 220 | CCGS Skill Testing Framework/skills/utility/skill-create-ccgs.md | 为这个 Codex-only CCGS 魔改体系创建、接入、登记、测试和治理项目 Skill，或判断应修改现有 Skill、添加 references、更新路由而不是新增命令。 | 负责 Skill 的新增/修改/接入；必须同步 spec、catalog、route index，并通过 `/skill-test` 审计。 |
| `/skill-improve` | 工具(utility) | 低(low) | 支持/显式调用 | 不适用 | 不适用 | 146 | CCGS Skill Testing Framework/skills/utility/skill-improve.md | 使用测试-修复-重新测试循环来改进技能。运行静态检查，提出有针对性的修复，重写技能，重新测试，并根据分数变化保留或恢复。 | 负责导航、设置、发布、辅助或例外流程；很多应保持显式调用。 |
| `/skill-test` | 工具(utility) | 中(medium) | 支持/显式调用 | 不适用 | 不适用 | 388 | CCGS Skill Testing Framework/skills/utility/skill-test.md | 验证技能文件的结构合规性和行为正确性。四种模式：静态（linter）、规范（行为）、分类（rubric）、审计（覆盖率报告）。 | 负责导航、设置、发布、辅助或例外流程；很多应保持显式调用。 |
| `/smoke-check` | 工具(utility) | 低(low) | 支持/显式调用 | 不适用 | 不适用 | 423 | CCGS Skill Testing Framework/skills/utility/smoke-check.md | 在 QA 交付前运行关键路径冒烟测试关卡。执行自动化测试套件，验证核心功能，并生成通过/失败报告。在冲刺的故事实施后和手动 QA 开始前运行。失败的冒烟测试意味着构建尚未准备… | 负责导航、设置、发布、辅助或例外流程；很多应保持显式调用。 |
| `/soak-test` | 工具(utility) | 低(low) | 支持/显式调用 | 不适用 | 不适用 | 285 | CCGS Skill Testing Framework/skills/utility/soak-test.md | 为扩展的游戏测试会话生成浸泡测试协议。定义在长时间游戏测试期间要观察、测量和记录的内容，以揭示缓慢泄漏、疲劳效应和仅在持续游戏后才出现的边缘情况。主要用于打磨和发布阶段。 | 负责导航、设置、发布、辅助或例外流程；很多应保持显式调用。 |
| `/sprint-plan` | 冲刺(sprint) | 中(medium) | 预生产、生产 | 是 | 是 | 282 | CCGS Skill Testing Framework/skills/sprint/sprint-plan.md | 根据当前里程碑、已完成的工作和可用容量生成新的冲刺计划或更新现有计划。从生产文档和设计待办事项中提取上下文。 | 负责生产节奏、状态和对外/对内记录。 |
| `/sprint-status` | 冲刺(sprint) | 中(medium) | 生产 | 否 | 否 | 209 | CCGS Skill Testing Framework/skills/sprint/sprint-status.md | 快速冲刺状态检查。读取当前冲刺计划，扫描故事文件的状态，并生成带有燃尽评估和新兴风险的简明进度快照。在冲刺期间的任何时候运行以快速了解情况。当用户询问'冲刺进展如何'、'冲刺… | 负责生产节奏、状态和对外/对内记录。 |
| `/start` | 工具(utility) | 低(low) | 支持/显式调用 | 不适用 | 不适用 | 246 | CCGS Skill Testing Framework/skills/utility/start.md | 首次引导 — 询问您当前所处阶段，然后引导您到正确的工作流程。不做任何假设。 | 负责导航、设置、发布、辅助或例外流程；很多应保持显式调用。 |
| `/story-done` | 准入(readiness) | 关键(critical) | 生产 | 是 | 是 | 460 | CCGS Skill Testing Framework/skills/readiness/story-done.md | 故事完成后的完成度审查。读取故事文件，根据实现验证每个验收标准，检查 GDD/ADR 偏差，提示代码审查，将故事状态更新为完成，并从冲刺中显示下一个就绪的故事。 | 负责开工前/完成后的准入判断；和实现技能分开，避免自证完成。 |
| `/story-readiness` | 准入(readiness) | 关键(critical) | 生产 | 否 | 否 | 356 | CCGS Skill Testing Framework/skills/readiness/story-readiness.md | 验证故事文件是否已准备好实施。检查嵌入的 GDD 需求、ADR 引用、引擎说明、清晰的验收标准以及未解决的设计问题。生成就绪/需要工作/受阻的判定及具体缺口。当用户说'这个故… | 负责开工前/完成后的准入判断；和实现技能分开，避免自证完成。 |
| `/team-audio` | 团队(team) | 中(medium) | 支持/显式调用 | 不适用 | 不适用 | 146 | CCGS Skill Testing Framework/skills/team/team-audio.md | 协调音频团队：音频总监 + 音效设计师 + 技术美术师 + 游戏玩法程序员，完成从指导到实施的完整音频流程。 | 负责跨域编排；只在一个任务天然需要多个专业角色时使用。 |
| `/team-combat` | 团队(team) | 中(medium) | 支持/显式调用 | 不适用 | 不适用 | 144 | CCGS Skill Testing Framework/skills/team/team-combat.md | 协调战斗团队：协调游戏设计师、游戏玩法程序员、AI 程序员、技术美术师、音效设计师和 QA 测试人员，端到端地设计、实施和验证战斗功能。 | 负责跨域编排；只在一个任务天然需要多个专业角色时使用。 |
| `/team-level` | 团队(team) | 中(medium) | 支持/显式调用 | 不适用 | 不适用 | 195 | CCGS Skill Testing Framework/skills/team/team-level.md | 协调关卡设计团队：关卡设计师 + 叙事总监 + 世界构建者 + 美术总监 + 系统设计师 + QA 测试人员，用于完整的区域/关卡创建。 | 负责跨域编排；只在一个任务天然需要多个专业角色时使用。 |
| `/team-live-ops` | 团队(team) | 中(medium) | 支持/显式调用 | 不适用 | 不适用 | 160 | CCGS Skill Testing Framework/skills/team/team-live-ops.md | 协调现场运营团队进行发布后内容规划：协调现场运营设计师、经济设计师、分析工程师、社区经理、作家和叙事总监，设计和规划赛季、活动或现场内容更新。 | 负责跨域编排；只在一个任务天然需要多个专业角色时使用。 |
| `/team-narrative` | 团队(team) | 中(medium) | 支持/显式调用 | 不适用 | 不适用 | 127 | CCGS Skill Testing Framework/skills/team/team-narrative.md | 协调叙事团队：协调叙事总监、作家、世界构建者和关卡设计师，创建连贯的故事内容、世界传说和叙事驱动的关卡设计。 | 负责跨域编排；只在一个任务天然需要多个专业角色时使用。 |
| `/team-polish` | 团队(team) | 中(medium) | 打磨 | 是 | 否 | 141 | CCGS Skill Testing Framework/skills/team/team-polish.md | 协调打磨团队：协调性能分析师、技术美术师、音效设计师和 QA 测试人员，以优化、打磨和硬化功能或区域，达到发布质量。 | 负责跨域编排；只在一个任务天然需要多个专业角色时使用。 |
| `/team-qa` | 团队(team) | 中(medium) | 支持/显式调用 | 不适用 | 不适用 | 245 | CCGS Skill Testing Framework/skills/team/team-qa.md | 协调 QA 团队通过完整的测试周期。协调 qa-lead（策略 + 测试计划）和 qa-tester（测试用例编写 + 错误报告），为冲刺或功能生成完整的 QA 包。涵盖：测… | 负责跨域编排；只在一个任务天然需要多个专业角色时使用。 |
| `/team-release` | 团队(team) | 中(medium) | 支持/显式调用 | 不适用 | 不适用 | 169 | CCGS Skill Testing Framework/skills/team/team-release.md | 协调发布团队：协调发布经理、QA 负责人、DevOps 工程师和制作人，执行从候选版本到部署的发布。 | 负责跨域编排；只在一个任务天然需要多个专业角色时使用。 |
| `/team-ui` | 团队(team) | 中(medium) | 支持/显式调用 | 不适用 | 不适用 | 187 | CCGS Skill Testing Framework/skills/team/team-ui.md | 协调 UI 团队通过完整的 UX 流程：从 UX 规范编写到视觉设计、实施、审查和打磨。与 /ux-design、/ux-review 和工作室 UX 模板集成。 | 负责跨域编排；只在一个任务天然需要多个专业角色时使用。 |
| `/tech-debt` | 分析(analysis) | 低(low) | 支持/显式调用 | 不适用 | 不适用 | 141 | CCGS Skill Testing Framework/skills/analysis/tech-debt.md | 跟踪、分类和确定整个代码库的技术债务优先级。扫描债务指标，维护债务登记册，并建议偿还计划。 | 负责风险扫描和报告；通常不直接改动工件，供 Gate 或用户决策使用。 |
| `/test-evidence-review` | 分析(analysis) | 低(low) | 支持/显式调用 | 不适用 | 不适用 | 252 | CCGS Skill Testing Framework/skills/analysis/test-evidence-review.md | 对测试文件和手动证据文档进行质量审查。超越存在性检查——评估断言覆盖率、边缘情况处理、命名约定和证据完整性。为每个故事生成充分/不完整/缺失的判定。在 QA 签署之前或按需运… | 负责风险扫描和报告；通常不直接改动工件，供 Gate 或用户决策使用。 |
| `/test-flakiness` | 分析(analysis) | 低(low) | 支持/显式调用 | 不适用 | 不适用 | 212 | CCGS Skill Testing Framework/skills/analysis/test-flakiness.md | 通过读取 CI 运行日志或测试结果历史来检测非确定性（不稳定）测试。聚合每个测试的通过率，识别间歇性故障，建议隔离或修复，并维护不稳定测试注册表。最好在打磨阶段或多次 CI … | 负责风险扫描和报告；通常不直接改动工件，供 Gate 或用户决策使用。 |
| `/test-helpers` | 工具(utility) | 低(low) | 支持/显式调用 | 不适用 | 不适用 | 396 | CCGS Skill Testing Framework/skills/utility/test-helpers.md | 为项目的测试套件生成引擎特定的测试辅助库。读取现有测试模式并生成 tests/helpers/，其中包含针对项目系统定制的断言实用程序、工厂函数和模拟对象。减少新测试文件中的… | 负责导航、设置、发布、辅助或例外流程；很多应保持显式调用。 |
| `/test-setup` | 工具(utility) | 低(low) | 预生产 | 否 | 否 | 427 | CCGS Skill Testing Framework/skills/utility/test-setup.md | 为项目引擎搭建测试框架和 CI/CD 流水线。创建 tests/ 目录结构、引擎特定的测试运行器配置和 GitHub Actions 工作流程。在技术设置阶段运行一次，在第一… | 负责导航、设置、发布、辅助或例外流程；很多应保持显式调用。 |
| `/ux-design` | 写作(authoring) | 低(low) | 预生产 | 是 | 是 | 990 | CCGS Skill Testing Framework/skills/authoring/ux-design.md | 针对屏幕、流程或 HUD 的引导式、逐章节 UX 规范编写。读取游戏概念、玩家旅程和相关 GDD 以提供上下文感知的设计指导。使用工作室模板生成 ux-spec.md（每个屏… | 负责产出文档或规范；必须保留草稿、确认、写入的协作闭环。 |
| `/ux-review` | 写作(authoring) | 低(low) | 预生产 | 是 | 否 | 264 | CCGS Skill Testing Framework/skills/authoring/ux-review.md | 验证 UX 规范、HUD 设计或交互模式库的完整性、无障碍合规性、GDD 一致性和实施就绪性。生成已批准/需要修订/需要重大修订的判定及具体缺口。 | 负责产出文档或规范；必须保留草稿、确认、写入的协作闭环。 |
| `/vertical-slice` | 工具(utility) | 低(low) | 预生产 | 否 | 否 | 360 | CCGS Skill Testing Framework/skills/utility/vertical-slice.md | 预生产验证 — 构建一个生产质量的端到端构建，以在承诺进入生产阶段之前确认完整的游戏循环是可实现的。在 GDD、架构和 UX 规范完成后运行。生成继续/调整/终止的判定，控制… | 负责导航、设置、发布、辅助或例外流程；很多应保持显式调用。 |
| `/window-handoff-ccgs` | 工具(utility) | 中(medium) | 支持/显式调用 | 不适用 | 不适用 | 183 | CCGS Skill Testing Framework/skills/utility/window-handoff-ccgs.md | 更新、审计或压缩 CCGS 多窗口 lane 状态文件，用于阶段性完成、关闭窗口、上下文过长、跨窗口交接和 lane 过长归档。 | 负责多窗口持续落盘和恢复可靠性；不改变原阶段动线。 |
| `/window-start-ccgs` | 工具(utility) | 中(medium) | 支持/显式调用 | 不适用 | 不适用 | 124 | CCGS Skill Testing Framework/skills/utility/window-start-ccgs.md | 用短命令启动或恢复 CCGS 多窗口工作流 lane，支持 A/B/C/D/Z，自动读取多窗口协议、active.md 和对应 lane 文件。 | 负责多窗口恢复入口；减少复制长启动提示，不改变阶段动线或窗口 owner 规则。 |

## 为什么原体系分这么细

| 拆分点 | 拆分意义 | 如果合并的风险 |
|---|---|---|
| `/help`、`/project-stage-detect`、`/gate-check` | 分别负责轻量导航、完整审计、阶段判定。 | AI 可能把“下一步建议”包装成“阶段已通过”。 |
| `/design-system`、`/design-review`、`/review-all-gdds` | 分别负责写单个 GDD、审单个 GDD、跨 GDD 一致性。 | 单文档看似完整，但跨系统互相矛盾。 |
| `/create-architecture`、`/architecture-decision`、`/architecture-review` | 分别负责整体蓝图、单项技术决策、覆盖率/冲突审查。 | ADR 变成孤立意见，不能证明覆盖了 GDD 需求。 |
| `/create-epics`、`/create-stories` | Epic 对齐架构模块，Story 对齐可实现切片。 | Story 可能跳过层级顺序，丢失 ADR/TR-ID 追踪。 |
| `/story-readiness`、`/dev-story`、`/story-done` | 分别对应开工前、实现中、完成后。 | 实现者可能把不清楚的验收标准直接标成完成。 |
| `/qa-plan`、`/smoke-check`、`/team-qa` | 分别负责测试设计、构建稳定性、完整 QA 签署。 | QA 会退化成泛泛清单，没有阶段证据。 |
| `team-*` 和原子 Skill | team Skill 只在跨域任务中编排多个角色。 | 简单任务过重，复杂任务又失去专业覆盖。 |

## 优化的必要性

即使不考虑新增 Skill，优化仍然有必要，原因不是“文件太多所以删”，而是现在的控制层对人不够透明：

1. 你实际不会手动选择 76 个命令，你会问 AI “现在用什么”。所以真正的压力不在命令数量，而在 AI 路由是否可解释。
2. 如果 `/help` 只给结论，不说明为什么选这个 Skill、为什么没选另一个 Skill，你就无法判断它是在遵循体系，还是在用 LLM 直觉猜。
3. Hook 脚本数量和默认接入状态以前没有讲清楚，会让人误以为所有 Hook 都在自动把关。
4. Skill 过长本身不是问题；1000 行以内可以接受。真正的问题是触发、路由、证据边界或审查责任被埋掉，导致 AI 无法解释为什么选这个 Skill。
5. Claude/Codex 双生态会制造维护漂移，同一个规则可能有两个入口，长期一定会出现一份新、一份旧。

所以优化目标不是削弱把关，而是把“路由层”和“证据层”分开：人看到的是更轻的入口，底层保留必要的审查面。

## 优化方案

### 1. 先不直接删除 76 个 Skill，先减少暴露入口

第一步不要删 Skill。当前真正的问题是“路由可见性”，而不是文件数量。保留专业 Skill 作为证据面，让 `/help` 只展示更少的路线组：

- `start`：入场、阶段检测、现有项目接入
- `design`：概念、系统、GDD、美术、UX
- `architecture`：架构、ADR、Control Manifest
- `production`：Epic、Story、Sprint、实现
- `qa`：QA 计划、冒烟、回归、证据审查
- `polish-release`：打磨、发布、热修、首日补丁
- `maintain`：Skill 测试、Skill 改进、一致性、技术债

### 2. 把 Skill 分成 core/support/explicit-only

- Core：`/help` 可以作为主推荐给出。
- Support：只在发现具体阻塞后作为辅助建议出现。
- Explicit-only：只有用户点名，或报告/Gate 明确指向时才运行，例如 `/hotfix`、`/day-one-patch`、`/team-live-ops`。

### 3. 按证据边界优化，而不是按行数优化

现在不再把 300-500 行当成硬目标。1000 行以内只要触发清楚、阶段清楚、读写边界清楚、判定词清楚，就可以保留。只有当检查表、示例、章节模板反复遮挡核心流程，或 `/skill-test` 证明行为不稳定时，才把稳定不变的内容下沉到 `references/`。

### 4. 增加路线索引，而不是删除护栏

已新增 `.codex/docs/skill-route-index.yaml`，记录每个 Skill 的路线组、阶段、core/support/explicit-only、推荐理由和不适用场景。`/help` 读取它后，必须解释“为什么推荐这个 Skill”，并区分稳定约束和当前工件事实。

### 5. 合并 Skill 必须有证据

只有三个条件同时满足，才考虑合并：输入工件相同、输出工件相同、判定词汇相同。只要有一个不同，就不应该合并。最可能合并的是窄范围状态/报告类，不是写作、审查、准入、关卡类。

## 新 Skill 加入方案

每个新 Skill 必须先接入体系，再算被接受。默认先运行 `/skill-create-ccgs`，让它判断是新增、修改、references-only、route-only 还是不建议接入：

1. 定义职责类型：authoring、review、readiness、pipeline、analysis、team、sprint、utility 或 gate。
2. 在 frontmatter description 写清楚触发语言、适用场景和不适用场景。
3. 定义读取哪些上游工件、写入哪些下游工件。
4. 决定它是 core、support 还是 explicit-only。
5. 新增文件：`.agents/skills/<name>/SKILL.md`。
6. 如果影响导航，更新 `.codex/docs/workflow-catalog.yaml` 或 `.codex/docs/skill-route-index.yaml`。
7. 新增行为 spec：`CCGS Skill Testing Framework/skills/<category>/<name>.md`。
8. 在 `CCGS Skill Testing Framework/catalog.yaml` 登记 category 和 priority。
9. 更新本架构文档的 Skill 矩阵。
10. 运行 `/skill-test static <name>` 和 `/skill-test category <name>`；有 spec 后再运行 `/skill-test spec <name>`。

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
- 用 `/skill-test audit` 校验：每个 `.agents/skills/*/SKILL.md` 都必须有 catalog entry、spec path 和 route entry。
- 决定 `team-*` 是否默认从 `/help` 隐藏，只在跨域故事或用户显式点名时出现。
- 继续把公开文档里的旧版本历史说明压缩成 Codex-only 维护说明，避免重新引入双生态。
