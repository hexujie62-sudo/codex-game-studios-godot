---
name: skill-create-cfg
description: "CFG Skill 唯一治理入口。用于用户要求新增、修改、合并、删除、重命名、测试、优化或审计 Skill 时；必须判断应新增 Skill 还是修改/删除现有 Skill，确定所属 lane/阶段、上游/下游文件、route/workflow/hook/spec 接入，并审计该 Skill 生成文件的 owner、consumer、维护触发、目录归属和状态源风险，防止 Skill 产物变成无人维护或冲突的危险品。"
argument-hint: "[自然语言 Skill 需求]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit
model: sonnet
---

# CFG Skill Governance

本 Skill 是 CFG 的 Skill 治理入口。它的本质不是“多生成一个 Skill”，而是判断一个
能力是否应该以 Skill 形式存在、应该改哪个现有入口、如何接入 CFG 动线，以及它
写出的文件会不会污染状态源。

用户只需用自然语言提出需求。不要要求用户选择 `static`、`spec`、`category`、
`audit`、`improve` 等内部模式。

`/skill-create-cfg` 是唯一正式入口。旧治理命令不再保留活跃路由。

## Phase 1: Classify The Request

先把用户需求归类为一个或多个治理动作：

- `KEEP`: 保留现有 Skill，不需要改。
- `MODIFY`: 修改现有 Skill。
- `REWRITE`: 保留能力，但重写 Skill 结构或动线。
- `MERGE`: 把多个入口合并到一个现有 Skill。
- `DELETE`: 删除没有 CFG 价值或会制造冲突的 Skill。
- `ROUTE-ONLY`: 只改 route/help/workflow，不改 Skill 主体。
- `REFERENCES-ONLY`: 只补稳定资料、模板、检查表或测试 spec。
- `NEW`: 新增 Skill。
- `BLOCKED`: 缺少必要信息或会破坏职责边界。

判定标准必须硬，不写“也许有用”。如果一个 Skill 没有真实 CFG owner、没有当前
动线 consumer、生成物没有维护机制，或制造第二状态源，结论就是 `DELETE` 或
`REWRITE`，不是 optional。

## Phase 2: Load The Smallest Useful Context

必须读取：

- `AGENTS.md`
- `.codex/docs/skill-route-index.yaml`
- `.codex/docs/workflow-catalog.yaml`
- `.codex/docs/multi-window-workflow.md`
- `.codex/docs/context-management.md`
- `.codex/docs/generated-artifact-governance.md`
- 相关 `.agents/skills/<name>/SKILL.md`

按需读取：

- 相关测试 spec。
- `.codex/hooks/`、`.githooks/`。
- `production/session-state/active.md` 与相关 lane 文件。
- 相关 framework docs 或 README。

不要读取 `.agents/skills-archive/`，除非任务明确是遗产审计。

## Phase 3: Decide If A Skill Should Exist

新增 Skill 必须同时满足：

1. 有独立触发语言，且 frontmatter description 能让 Codex 自动识别。
2. 有明确上游和下游工件。
3. 有明确 lane/阶段归属。
4. 有独立质量边界，不能被现有 Skill + reference 覆盖。
5. 生成物通过 Phase 4 的 Artifact Safety 审计。

优先级：

1. 修改现有 Skill。
2. 加 reference 或 route。
3. 合并到现有动线。
4. 新增 Skill。
5. 删除旧 Skill。

部分价值不能成为保留旧 Skill 的理由。必须写清楚“有用规则”迁移到哪个 CFG 文件、
谁维护、原 Skill 是否删除。

## Phase 4: Artifact Safety

凡是 Skill 会创建或更新文件，必须先写出 `Artifact Contract`：

```text
Artifact:
Owner:
Consumer:
Lifetime: one-shot / rolling / source-of-truth / recovery-state / evidence
Update trigger:
Stale condition:
Directory:
Enforcer:
Conflict risk:
Verdict: SAFE / REWRITE REQUIRED / DELETE / BLOCKED
```

危险品判定：

- 生成第二状态源，例如抢 `production/session-state/active.md`、lane files、
  `production/work-orders/` 或 canon 的权威。
- 文件长期存在但没有 owner。
- 文件会被其他窗口读取，但没有维护触发。
- 目录归属不清，例如没有独立 QA lane 却默认写出 QA 权威状态。
- 绕过 D-director verdict、A-producer 排队、B/C 执行边界或 Z-platform
  framework owner。
- 让执行者自证最终验收。
- 一次性文件被后续 Skill 当长期权威读取。

命中危险品时，不能继续写入方案，必须给 `DELETE`、`REWRITE REQUIRED` 或
`BLOCKED`。

如果本次 Skill 变化新增、删除或改变持久生成物类型,同步更新
`.codex/docs/generated-artifact-governance.md` 的 Skill Artifact Matrix。不要
把 lifecycle 只写在聊天或单个 Skill 文件里。

## Phase 5: Workflow Insertion

任何 Skill 变化都必须回答：

- Entry: 用户会如何遇到它？`/help`、阶段 workflow、lane、hook，还是用户点名。
- Stage/Lane: 属于 A-producer、B-dev、C-art、D-director、Z-platform 或哪个阶段。
- Upstream: 读取哪些文件。
- Downstream: 写哪些文件。
- Owner: 谁维护下游文件。
- Route effects: 是否改 `.codex/docs/skill-route-index.yaml`。
- Workflow effects: 是否改 `.codex/docs/workflow-catalog.yaml`。
- Hook effects: 是否改 `.codex/hooks/` 或 `.githooks/`。
- Recovery effects: 是否改 `production/session-state/active.md` 或 lane 文件规则。

如果某项不改，说明“不改的理由”。只创建 `.agents/skills/<name>/SKILL.md`
不算接入完成。

## Phase 6: Write Changes

写入前给出 changeset。若用户已明确说“开始”“改吧”“执行”，视为本轮已授权；
仍需说明会改哪些文件。

写作规则：

- 保持入口少，不暴露内部维护模式。
- `description` 必须包含触发场景，而不是抽象职责名。
- Skill 正文只保留核心流程；稳定长资料放 `references/`。
- 有写入能力的 Skill 必须有包级批准或明确低风险授权规则。
- 删除旧 Skill 时同步 route/docs/hook 提示，不能留下半活入口。

## Phase 7: Verify

至少执行：

- Static: frontmatter、阶段、verdict、写入审批、handoff。
- Route: route 不指向不存在的 Skill。
- Workflow insertion: `/help` 和 workflow 不推荐已删除入口。
- Artifact safety: 所有新增/保留生成物都有 owner、consumer、维护触发和目录归属。

输出格式：

```text
Decision:
Why:
Artifact safety:
Workflow insertion:
Files changed:
Verification:
Verdict:
```

不要自动提交。除非用户明确要求，不运行 `git commit`。
