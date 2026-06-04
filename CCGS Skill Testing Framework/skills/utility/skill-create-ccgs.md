# Skill Spec: /skill-create-ccgs

> **Category**: utility
> **Priority**: medium
> **Spec written**: 2026-06-04

## Skill 摘要

`/skill-create-ccgs` 用于创建、接入、登记、测试和治理 CCGS 项目 Skill。它必须先判断用户需求应该
新增 Skill、修改现有 Skill、只补 references、只改 route，还是应该阻止/延后。
它的重点是体系接入：同步 Skill 文件、测试 spec、catalog、route index、必要时的
workflow catalog 和架构文档。

---

## 静态断言

- [ ] Frontmatter 包含必需字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少有 2 个 Phase 标题
- [ ] 至少包含一个 verdict 关键词：`PASS`、`FAIL`、`CONCERNS`、`APPROVED`、`BLOCKED`、`COMPLETE`、`READY`
- [ ] 如果 `allowed-tools` 包含 Write/Edit，正文包含 `"May I write"`
- [ ] 结尾包含下一步 handoff

---

## Director Gate 检查

不适用。它是 utility/system-maintenance Skill，不触发 creative、technical、
producer 或 art director gate，也不能自动推进任何项目阶段。

---

## 测试用例

### Case 1: Happy Path — 新 Skill 完整接入

**Fixture**:
- 用户提出一个重复使用的新工作流，并且有独立工件边界。
- 没有现有 `.agents/skills/<name>/SKILL.md` 覆盖相同触发。
- `CCGS Skill Testing Framework/catalog.yaml` 和 `.codex/docs/skill-route-index.yaml` 存在。

**Expected behavior**:
1. 判定为 `New Skill`。
2. 提出 changeset：`SKILL.md`、spec、catalog entry、route entry，以及必要的 workflow/docs 更新。
3. 询问 `May I write this CCGS Skill changeset to [file list]?`

**Assertions**:
- [ ] 判定说明为什么现有 Skill 不足。
- [ ] route entry 包含 `stage`、`group`、`visibility`、`fit_basis`、`why`、`avoid_when`。
- [ ] catalog entry 包含 `name`、`spec`、`priority`、`category`。
- [ ] 测试计划包含 `/skill-test static`、`/skill-test category`、`/skill-test spec`、`/skill-test audit`。

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 2: Modify Instead of New — 现有 Skill 拥有边界

**Fixture**:
- 用户提出的能力与现有 Skill 的触发和输出重叠。
- 现有 Skill 读取/写入相同上游和下游工件。

**Expected behavior**:
1. 判定为 `Modify existing Skill`。
2. 指出现有 owner Skill，以及需要更新的关联文件。
3. 不创建重复 Slash command。

**Assertions**:
- [ ] 判定中命名现有 Skill。
- [ ] 如果行为变化，计划更新对应 spec 和 route entry。
- [ ] 不提出新的 `.agents/skills/<new-name>/` 目录。

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 3: References-Only — 上下文不变成命令

**Fixture**:
- 用户想给现有 Skill 增加长检查表、稳定资料或示例。
- 该资料没有新的触发、工件边界或质量门。

**Expected behavior**:
1. 判定为 `Add references`。
2. 提出 `references/` 文件和 `SKILL.md` 中的短指针。
3. 在 spec 里增加 reference 读取行为断言。

**Assertions**:
- [ ] 不新增 Skill command。
- [ ] reference 内容不重复塞进 `SKILL.md`。
- [ ] 除非有明确理由，owner Skill 仍符合 1000 行以内的指导。

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 4: Mutable Design Facts — 可变设计事实不进入稳定路由

**Fixture**:
- 用户要求的新 Skill 提到了当前项目事实，例如 2D/3D、美术风格、视角、输入方式或平台。
- `.codex/docs/technical-preferences.md` 包含当前设计事实。

**Expected behavior**:
1. 这些内容只作为当前工件事实使用。
2. 不把它们加入 `.codex/docs/skill-route-index.yaml` 的 `stable_constraints`。
3. 如需使用，只在 `why` 中标注为当前工件依据。

**Assertions**:
- [ ] stable route constraints 仍只包含 Codex/Godot/AI 全链路/系统层事实。
- [ ] 可变事实从项目工件读取，不被写死为永久 Skill 行为。
- [ ] spec 包含保护这一点的断言。

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 5: Blocked Path — 需求会破坏证据链

**Fixture**:
- 用户要求把 authoring 和 review 合并，或要求实现 Skill 自动关闭 Story。

**Expected behavior**:
1. 返回 `BLOCKED` 或 `CONCERNS`。
2. 说明会削弱哪条 CCGS 边界。
3. 提供更安全替代方案，例如 route-only、references addition 或拆成独立 Skill。

**Assertions**:
- [ ] 在风险解决前不提出写文件。
- [ ] 报告命名具体不变量：authoring/review、readiness/implementation、implementation/story-done 或 gate/user decision。
- [ ] 替代方案保留 `/skill-test` 和 route index 的审计能力。

**Case Verdict**: PASS / FAIL / PARTIAL

---

## 协作协议

- [ ] 写入任何文件前使用 `"May I write"`。
- [ ] 请求批准前先展示判定和 changeset。
- [ ] 结尾给出下一步或 follow-up action。
- [ ] 不在没有用户批准的情况下自动创建文件。

---

## 覆盖说明

这个 spec 验证 CCGS 接入行为。实际生成的 Skill 仍需要继续运行：
`/skill-test static <name>`、`/skill-test category <name>`、
`/skill-test spec <name>` 和 `/skill-test audit`。
