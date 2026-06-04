---
name: skill-create-ccgs
description: "为这个 Codex-only CCGS 魔改体系创建、接入、登记、测试和治理项目 Skill，或判断应修改现有 Skill、添加 references、更新路由而不是新增命令。用于用户提出新增 Skill、改造 Skill、接入工作流、补充测试 spec、更新 route/catalog/workflow/docs 时。"
argument-hint: "[new-skill-idea | existing-skill-name | change-request]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit
model: sonnet
---

# CCGS Skill Create

为这个项目创建、接入、登记、测试和治理 Skill。核心职责不是“生成一个
`SKILL.md` 文件”，而是判断新能力应该怎样进入 CCGS 体系，并同步它的
路由、测试、目录和文档。

---

## Phase 1: Parse Request

读取用户意图，先分类而不是直接创建文件：

- **新增 Skill**：用户提出一个现有 Skill 无法覆盖的新工作流、质量门或工件边界。
- **修改 Skill**：用户想改已有 Skill 的触发、步骤、输出、测试或项目适配。
- **补充 references**：需求只是给已有 Skill 增加稳定资料、模板、检查表或示例。
- **路由调整**：需求是改变 `/help` 如何推荐 Skill，而不是改变 Skill 行为。
- **测试补齐**：需求是补 catalog、spec、route entry 或 `/skill-test` 覆盖。
- **不建议接入**：需求太一次性、没有独立边界，或会削弱现有审查链。

如果用户没有给出足够信息，最多问 3 个问题：

1. 这个能力解决什么重复问题？
2. 它读取哪些上游工件，写入哪些下游工件？
3. 它应该是阶段主线、辅助工具，还是用户点名才出现？

---

## Phase 2: Load CCGS Context

读取以下文件，只读取判断需要的部分：

- `AGENTS.md`
- `.codex/docs/workflow-catalog.yaml`
- `.codex/docs/skill-route-index.yaml`
- `.codex/docs/technical-preferences.md`
- `CCGS Skill Testing Framework/catalog.yaml`
- `CCGS Skill Testing Framework/quality-rubric.md`
- `CCGS Skill Testing Framework/templates/skill-test-spec.md`
- `.agents/skills/*/SKILL.md` 的 frontmatter

必要时读取相似 Skill 的完整正文。不要把 2D/3D、美术风格、题材、视角、
输入方式或平台写成永久规则；这些只能作为当前工件事实。

---

## Phase 3: Decide New vs Modify

用这个矩阵做判定，并在输出里说明理由：

| Decision | Criteria | Result |
|---|---|---|
| Modify existing Skill | 触发语言相近、读取/写入工件相同、判定词相同 | 修改现有 `SKILL.md`、spec、route entry |
| Add references | 只是增加模板、示例、检查表、领域资料 | 给现有 Skill 增加 `references/`，不新增命令 |
| Route-only change | 行为不变，只影响 `/help` 推荐方式 | 修改 `.codex/docs/skill-route-index.yaml` |
| New Skill | 有独立触发、独立工件边界、独立质量门或可复用流程 | 创建 `.agents/skills/<name>/SKILL.md` 并全量接入 |
| Split Skill | 现有 Skill 超过 1000 行或测试证明边界混乱 | 拆 references 或拆新 Skill |
| Reject / defer | 一次性需求、无明确输出、会绕过审查链 | 输出 `BLOCKED` 或 `CONCERNS`，不写文件 |

合并或新增时保护这些边界：

- authoring 不能自审。
- readiness 不能实现。
- implementation 不能自证完成。
- gate 只能给建议性 PASS/CONCERNS/FAIL，不能替用户推进阶段。
- team Skill 只处理跨域编排，不能替代原子 Skill 的证据链。

---

## Phase 4: Plan Integration

为用户展示接入计划，列出将修改哪些文件：

### 新增 Skill 时

- `.agents/skills/<name>/SKILL.md`
- `CCGS Skill Testing Framework/skills/<category>/<name>.md`
- `CCGS Skill Testing Framework/catalog.yaml`
- `.codex/docs/skill-route-index.yaml`
- `.codex/docs/workflow-catalog.yaml`，仅当它进入阶段主线
- `docs/ccgs-codex-architecture.md`，仅当总矩阵或规模说明需要更新

### 修改 Skill 时

- `.agents/skills/<name>/SKILL.md`
- 对应 spec 文件
- `CCGS Skill Testing Framework/catalog.yaml`，如果 category/priority/spec 变化
- `.codex/docs/skill-route-index.yaml`，如果推荐方式、visibility、why 或 avoid_when 变化
- `.codex/docs/workflow-catalog.yaml`，如果阶段步骤变化

### references-only 时

- `.agents/skills/<name>/references/<file>.md`
- `.agents/skills/<name>/SKILL.md` 中加入何时读取 reference 的说明
- 对应 spec 增加 reference 行为断言

显示计划后必须问：

`May I write this CCGS Skill changeset to [file list]?`

没有用户批准前，不写任何文件。Verdict: `READY` 表示计划可写；
`CONCERNS` 表示有设计风险；`BLOCKED` 表示信息不足或会破坏体系边界。

---

## Phase 5: Draft the Skill

新 Skill 必须符合这个结构：

```markdown
---
name: <lowercase-hyphen-name>
description: "<做什么 + 何时使用 + 不适用场景的触发信息>"
argument-hint: "[expected arguments]"
user-invocable: true
allowed-tools: Read, Glob, Grep[, Write/Edit/Bash only if needed]
model: sonnet
---

# <Title>

<一句话职责>

## Phase 1: ...
```

写作规则：

- `description` 必须包含触发场景，因为这是 Skill 被发现的入口。
- `SKILL.md` 1000 行以内可接受；不要为了短而牺牲审查边界。
- 稳定、长篇、可复用资料放入 `references/`。
- 不把当前项目的可变设计事实写死为永久规则。
- 有写入能力时必须包含 `May I write` 协作语言。
- 末尾必须有 next-step handoff。
- 必须包含清晰 verdict 词：`PASS`、`FAIL`、`CONCERNS`、`BLOCKED`、`READY` 或 `COMPLETE`。

---

## Phase 6: Draft the Test Spec

为每个新增或重大修改的 Skill 创建/更新：

`CCGS Skill Testing Framework/skills/<category>/<name>.md`

使用 `CCGS Skill Testing Framework/templates/skill-test-spec.md`。至少包含：

- Happy path：正常创建/执行。
- Blocked path：缺少关键输入时停止。
- Integration path：catalog、route index、workflow catalog 是否正确更新。
- Mutability path：不把 2D/3D、美术风格、输入方式等写成稳定约束。
- Protocol path：写文件前出现 `May I write`，不会自动越过用户批准。

如果 Skill 是 gate/review/readiness/pipeline/team/category-specific，需要加入对应
`quality-rubric.md` 的断言。

---

## Phase 7: Update Registries

按判定结果更新关联内容：

- `CCGS Skill Testing Framework/catalog.yaml`
  - 新 Skill 必须有 `name`、`spec`、`priority`、`category`。
  - `category` 只能使用现有类别：gate、review、authoring、readiness、
    pipeline、analysis、team、sprint、utility。
- `.codex/docs/skill-route-index.yaml`
  - 新 Skill 必须有 `stage`、`group`、`visibility`、`fit_basis`、`why`、`avoid_when`。
  - `visibility` 只能是 `core`、`support`、`explicit-only`。
- `.codex/docs/workflow-catalog.yaml`
  - 只有当 Skill 是阶段主线步骤时才更新。
- `docs/ccgs-codex-architecture.md`
  - 当 Skill 总数、矩阵、加入方案或控制边界变化时更新。

---

## Phase 8: Test the Change

写入后执行或要求用户执行以下验证：

1. `/skill-test static <name>`
2. `/skill-test category <name>`
3. `/skill-test spec <name>`
4. `/skill-test audit`

同时做三方覆盖检查：

- `.agents/skills/*/SKILL.md`
- `CCGS Skill Testing Framework/catalog.yaml`
- `.codex/docs/skill-route-index.yaml`

三者数量和名称必须一致。若任何检查失败，输出 `FAIL`，列出具体修复文件。

---

## Phase 9: Report

输出必须短而可审计：

```text
Decision: New Skill / Modify / References-only / Route-only / Blocked
Why: ...
Files changed:
- ...
Tests:
- static: PASS/FAIL/not run
- category: PASS/FAIL/not run
- spec: PASS/FAIL/not run
- audit: PASS/FAIL/not run
Next step: /skill-test audit or /skill-improve <name>
```

不要自动提交。除非用户明确要求，不运行 git commit。
