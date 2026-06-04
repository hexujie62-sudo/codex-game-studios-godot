# CCGS Hook Codex 化方案与可靠性审查

生成日期：2026-06-04

这份文档只处理一个问题：原 CCGS 的 Hook 体系迁到 Codex 后，哪些应该保留、哪些应该改造、哪些应该迁出 Hook、哪些应该删除。结论先放前面：**不要把 12 个旧 Hook 原样迁入 Codex。应该把“规则价值”和“执行机制”拆开处理。**

## 当前实施状态

已实施：

- `.codex/hooks.json` 已缩减为 5 个 Codex-native 默认 Hook。
- 新增 `session-start.sh`、`detect-gaps-lite.sh`、`dangerous-command-policy.sh`、`skill-change-reminder.sh`、`post-compact-restore.sh`。
- 原 11 个旧脚本已移入 `.codex/hooks/legacy/`，不再默认接入。
- 新增 `.githooks/pre-commit` 和 `.githooks/pre-push`。
- 新增 `.github/workflows/ccgs-integrity.yml` 做 JSON、Hook 语法和 Skill catalog/spec 覆盖检查。

仍需要项目使用者执行：

- 在本地启用 Git hooks：`git config core.hooksPath .githooks`。
- 在 Codex 里通过 `/hooks` 审查并信任项目 hooks。
- 在远端仓库配置分支保护；本地 `pre-push` 不能替代远端保护。

本轮验证记录：

- `codex features list` 确认 `hooks stable true`。
- `.codex/hooks.json` 可被 JSON parser 解析。
- 全仓 `.json` 文件可解析。
- `.codex/hooks/*.sh`、`.codex/hooks/lib/*.sh`、`.codex/hooks/legacy/*.sh`、`.githooks/pre-commit`、`.githooks/pre-push` 均通过 `bash -n`。
- `session-start.sh` 输出可解析 JSON，且包含 `SessionStart` additionalContext。
- `post-compact-restore.sh` 输出可解析 JSON，且包含 `active.md` 恢复提醒。
- `dangerous-command-policy.sh` 对 `git reset --hard` 返回 exit 2 和 `decision:block`。
- `skill-change-reminder.sh` 能从 `apply_patch` 输入中识别 `.agents/skills/help/SKILL.md`。
- `.githooks/pre-commit` dry run 正常退出。
- `.githooks/pre-push` 对 `refs/heads/main` 返回阻止。
- Skill catalog 覆盖检查通过：73 个 Skill，对应 catalog 73 项，无缺失。

## 判断依据

本方案基于当前仓库状态和 Codex 官方 hooks 语义：

- Codex 会从 `~/.codex/hooks.json`、`~/.codex/config.toml`、`<repo>/.codex/hooks.json`、`<repo>/.codex/config.toml` 等位置发现 hooks。
- 项目本地 hooks 只有在项目 `.codex/` layer 被 trust 后才会加载；非 managed hook 还需要 `/hooks` 审查和信任。
- repo-local hook 命令不应依赖相对路径；Codex 可能从子目录启动，官方建议用 git root 定位脚本。
- `PreToolUse` / `PostToolUse` 能处理 `Bash`、`apply_patch` 和 MCP 工具，但不是完整强制边界，也不能覆盖所有 shell/tool 路径。
- `apply_patch` 可以匹配 `Edit|Write`，但输入仍是 `tool_name: "apply_patch"`，文件变化需要从 `tool_input.command` 解析。
- `PreCompact` / `PostCompact` 的纯文本 stdout 会被忽略，只能用 JSON 输出控制行为或提示。
- `Stop` 和 `SubagentStop` 在 exit 0 时需要 JSON stdout；纯文本 stdout 对这些事件是无效输出。

官方参考：[OpenAI Codex Hooks](https://developers.openai.com/codex/hooks)

## 总体原则

1. **Codex Hook 只做 Codex 生命周期内的上下文和轻量护栏。**
   它不承担最终质量门。

2. **真正需要强制性的规则迁到 Git/CI。**
   例如 JSON 有效性、提交前检查、推送保护、资源格式检查。

3. **Skill 体系相关规则迁到 `/skill-test`。**
   例如 Skill 修改后必须有 catalog、spec、静态检查、类别检查。

4. **不适配且没有独立价值的 Hook 删除。**
   不为了“看起来完整”保留旧脚本。

5. **保留旧规则时必须换执行位置。**
   不保留 CC 语义，不保留伪适配。

## 最终目标架构

| 层级 | 负责什么 | 典型入口 | 可靠性 |
|---|---|---|---|
| Codex hooks | 会话上下文、轻量提醒、危险操作软拦截 | `.codex/hooks.json` | 中等：依赖 trust、事件覆盖和 tool path |
| Git hooks | commit/push 前本地强制检查 | `.githooks/` 或 repo git config | 高：真实拦截 git 操作 |
| CI | 跨环境最终质量门 | GitHub Actions 或其他 CI | 最高：不依赖 Codex |
| Skills | 工作流审查和人机协作把关 | `/help`、`/skill-test`、`/asset-audit` | 中高：依赖显式调用和体系路由 |
| AGENTS/rules | 模型执行前的常驻规范 | `AGENTS.md`、`.codex/rules/` | 中：影响模型行为，但不是硬门 |

## 12 个 Hook 的去留方案

| 当前 Hook | 当前问题 | 处理决定 | 新归属 | 可靠性目标 |
|---|---|---|---|---|
| `session-start.sh` | 可用，但 stdout 信息太散；相对路径脆弱。 | 保留并 Codex 化。 | Codex `SessionStart` | 会话开始提供阶段、恢复文件、关键缺口。 |
| `detect-gaps.sh` | 与 `/help`、`/project-stage-detect` 重叠；扫描偏重。 | 保留轻量版，复杂审计交给 `/help`。 | Codex `SessionStart` + `/help` | 只提示明显缺口，不做完整审计。 |
| `validate-commit.sh` | Codex `PreToolUse` 只能拦截部分 Bash；不能保证所有 commit。 | 迁出 Codex 主责。 | Git pre-commit + CI；Codex 中可留提醒版。 | Git/CI 负责强制，Codex 只提醒。 |
| `validate-push.sh` | 与分支保护、pre-push 重叠；Codex 不能覆盖所有 push。 | 从 Codex 默认 hook 删除。 | Git pre-push / 远端 branch protection | 不依赖 Codex。 |
| `validate-assets.sh` | 当前按 `file_path` 解析，Codex `apply_patch` 下不可靠；PostToolUse 不能撤销副作用。 | 迁到 `/asset-audit` + CI；Codex 可留 advisory parser。 | Skill + CI | 最终检查由 CI/显式审计负责。 |
| `validate-skill-change.sh` | 当前按 `file_path` 解析，Codex `apply_patch` 下不可靠。 | 改成解析 patch diff，提醒 `/skill-test audit`。 | Codex `PostToolUse` + `/skill-test` | 能发现大部分 Codex 文件改动，但不当硬门。 |
| `pre-compact.sh` | 依赖纯文本 stdout 注入上下文；Codex 会忽略 PreCompact 纯文本。 | 重写，不再吐长文本。 | Codex `PreCompact` | 只写入 session-state 文件，必要时 JSON `systemMessage`。 |
| `post-compact.sh` | 依赖纯文本 stdout；Codex 会忽略 PostCompact 纯文本。 | 重写为 JSON 输出。 | Codex `PostCompact` | 用 JSON 提醒读取 `active.md`。 |
| `session-stop.sh` | Codex `Stop` 是 turn scope，不是“会话关闭”；exit 0 纯文本 stdout 无效。 | 改名并重写。 | Codex `Stop` 或移出 | 只做 turn-end continuation/提醒，不做 session-end 语义。 |
| `notify.sh` | Codex 当前 hooks 事件没有 `Notification`。 | 删除默认入口，移入 optional。 | optional script | 不作为体系护栏。 |
| `log-agent.sh` | 当前未接入；SubagentStart 纯文本可加上下文，但审计日志价值有限。 | 默认删除或 optional。 | optional / transcript | 如果需要审计，再接入 `SubagentStart`。 |
| `log-agent-stop.sh` | SubagentStop exit 0 需要 JSON；当前纯文本/日志脚本语义不完整。 | 默认删除或重写后 optional。 | optional / transcript | 如果需要审计，再接入 `SubagentStop`。 |

## 推荐的 Codex hooks 最小集

Codex 默认只保留 5 类 hook：

| 事件 | Hook | 目的 |
|---|---|---|
| `SessionStart` | `session-start.sh` | 给 Codex 注入阶段、恢复点、当前工作树概况。 |
| `SessionStart` | `detect-gaps-lite.sh` | 只提示新项目、缺引擎、缺概念、缺系统索引等明显缺口。 |
| `PostToolUse` | `skill-change-reminder.sh` | 解析 `apply_patch`，发现 `.agents/skills/*/SKILL.md` 改动后提醒 `/skill-test audit`。 |
| `PostCompact` | `post-compact-restore.sh` | JSON 提醒读取 `production/session-state/active.md`。 |
| `PreToolUse` | `dangerous-command-policy.sh` | 阻止明显危险命令，例如强推、递归删除、删除 `.codex`/`.agents`。 |

不再默认接入：

- `validate-push.sh`
- `validate-assets.sh`
- `notify.sh`
- `log-agent.sh`
- `log-agent-stop.sh`
- 原版 `pre-compact.sh`
- 原版 `session-stop.sh`

## Git/CI 迁移方案

### Git pre-commit

迁移规则：

- staged JSON 文件必须有效。
- `design/gdd/*.md` 的必需章节检查。
- `src/gameplay/**` 的硬编码数值提醒。
- TODO/FIXME 负责人格式提醒。
- `.agents/skills/*/SKILL.md` 修改时提示运行 `/skill-test audit`。

位置建议：

- `.githooks/pre-commit`
- 文档中要求执行：`git config core.hooksPath .githooks`

### Git pre-push / 远端保护

迁移规则：

- 不允许直接 push 到 `main` / `develop`，除非用户明确绕过本地 hook。
- 真正可靠的保护应放在 GitHub branch protection。

位置建议：

- `.githooks/pre-push`
- GitHub protected branches

### CI

CI 应负责最终质量门：

- JSON 校验。
- Skill catalog/spec 覆盖率。
- Hook 脚本 shellcheck 或最小语法检查。
- GDD 必需章节检查。
- 资源命名和资源 JSON schema。

## Skill 迁移方案

这些规则不应该放在 Codex Hook 里强制：

| 规则 | 迁移到 |
|---|---|
| Skill 修改后必须有 catalog entry | `/skill-test audit` |
| Skill 修改后必须有 spec | `/skill-test audit` |
| Skill frontmatter 结构 | `/skill-test static <skill>` |
| Skill 行为是否符合用途 | `/skill-test spec <skill>` |
| 资源命名、孤立资源、引用缺失 | `/asset-audit` |
| 项目阶段缺口 | `/help` + `/project-stage-detect` |

Hook 只负责“提醒运行这些 Skill”，不负责替代这些 Skill。

## Codex 化改造要求

所有保留在 `.codex/hooks.json` 的 hook 必须满足：

1. command 使用 git root 定位：
   - 推荐：`bash "$(git rev-parse --show-toplevel)/.codex/hooks/<name>.sh"`
   - Windows 需要 `commandWindows` 覆盖，避免 PATH 中没有 `bash`。

2. 支持 Codex 当前输入：
   - Bash：读取 `tool_input.command`
   - apply_patch：读取 `tool_input.command`
   - SessionStart：读取 `source`
   - Pre/PostCompact：读取 `trigger`
   - Stop/SubagentStop：读取 `last_assistant_message`、`agent_type` 等字段

3. stdout 必须符合事件语义：
   - `SessionStart`：可以纯文本，也可以 JSON `additionalContext`
   - `PreToolUse`：纯文本 stdout 忽略；要阻止必须 exit 2 或 JSON deny
   - `PostToolUse`：纯文本 stdout 忽略；要反馈必须 JSON 或 exit 2
   - `PreCompact/PostCompact`：纯文本 stdout 忽略，必须 JSON
   - `Stop/SubagentStop`：exit 0 时必须 JSON，纯文本无效

4. Hook 不能假装是硬门：
   - 能拦的拦。
   - 拦不到的必须迁到 Git/CI/Skill。

## 可靠性审查

### 审查结论

方案可靠性：**中高**。

原因：

- 高可靠部分由 Git/CI 承担，不依赖 Codex。
- Codex hook 只保留适合 Codex 生命周期的轻量职责。
- 删除了没有当前事件支持或和 Codex/系统功能高度重叠的脚本。
- 不再把 PostToolUse 当成可撤销副作用的安全门。

不能评为“高”的原因：

- Codex hooks 仍依赖 trust 状态。
- `PreToolUse/PostToolUse` 当前不覆盖所有 shell/tool 路径。
- 用户可以绕过本地 Git hooks。
- CI 需要实际接入后才算最终闭环。

### 逐项风险

| 风险 | 影响 | 方案控制 |
|---|---|---|
| 项目 hooks 未 trust | Codex hooks 不运行 | 文档要求用 `/hooks` 审查；CI/Git 不依赖 Codex。 |
| Codex 从子目录启动 | 相对路径失效 | hook command 改成 git root 定位。 |
| apply_patch 输入不是 `file_path` | 文件变更 Hook 检测不到 | 改为解析 patch command。 |
| PostToolUse 无法撤销副作用 | 资源错误已经写入 | 资源质量门迁到 `/asset-audit` + CI。 |
| Stop 被误解成 session end | 日志和恢复语义错误 | 改名为 turn-stop 或删除。 |
| Subagent audit 重叠 | 多一套低价值日志 | 默认删除，必要时用 transcript 或 optional hook。 |

### 验收标准

完成改造后，需要通过这些验收：

1. `codex features list` 显示 `hooks stable true`。
2. `.codex/hooks.json` 可被 JSON parser 解析。
3. 从 repo 根目录和子目录启动时，hook 命令都能定位脚本。
4. 模拟 `SessionStart` 输入时，`session-start.sh` 输出可被 Codex 作为上下文接收。
5. 模拟 `apply_patch` 修改 `.agents/skills/help/SKILL.md` 时，`skill-change-reminder.sh` 能识别 skill 名。
6. 模拟 `PostCompact` 时，hook 输出合法 JSON。
7. 模拟 `Stop` 时，不输出纯文本；要么不接入，要么输出合法 JSON。
8. Git pre-commit 能拦截无效 JSON。
9. CI 能独立运行 Skill catalog/spec 覆盖检查。
10. 架构文档和 hook reference 不再声称 12 个旧 Hook 都是 Codex 默认安全网。

## 实施顺序

1. 先更新文档和 Hook 矩阵，明确旧 Hook 不再全部默认有效。
2. 新增 `.githooks/pre-commit` 和 `.githooks/pre-push`。
3. 重写 `.codex/hooks.json`，只保留 Codex-native 最小集。
4. 重写保留的 Codex hook 脚本。
5. 把 optional/legacy 脚本移到 `.codex/hooks/optional/` 或删除。
6. 新增 `/skill-test audit` 或增强现有 `/skill-test`，覆盖 catalog/spec。
7. 增加 CI 检查。
8. 跑验收标准。

## 最终判断

这套方案不是“把旧 Hook 修到能跑”，而是把 CCGS 的安全职责重新分配：

- Codex hooks：负责会话内提醒和轻量上下文。
- Git hooks：负责本地提交/推送前检查。
- CI：负责不可绕过的最终质量门。
- Skills：负责工作流级审查和人工决策。

这样改完后，体系会比原来更轻，也更可靠。关键是：**不再把 Codex Hook 误当成完整安全网。**
