# Skill Spec: /skill-create-ccgs

> **Category**: utility
> **Priority**: medium
> **Spec updated**: 2026-06-06

## Skill 摘要

`/skill-create-ccgs` 是 CCGS Skill 治理的唯一用户入口。用户只用自然语言提出
新增、修改、合并、删除、测试或优化 Skill 的需求；本 Skill 内部完成体系审查、
动线接入判断、写入方案、复查和必要修复。

它取代单独暴露的测试和修复用户入口。测试、审计和修复仍然存在，
但作为内部阶段执行。

---

## 静态断言

- [ ] Frontmatter 包含必需字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少有 2 个 Phase 标题
- [ ] 包含 `Mandatory Workflow Insertion Review`
- [ ] 包含内部验证阶段
- [ ] 包含内部修复循环
- [ ] 至少包含一个 verdict 关键词：`PASS`、`FAIL`、`CONCERNS`、`BLOCKED`、`COMPLETE`、`READY`
- [ ] 如果 `allowed-tools` 包含 Write/Edit，正文包含 `"May I write"`
- [ ] 不要求用户选择 `static/spec/category/audit/improve` 参数模式

---

## Director Gate 检查

不适用。它是 utility/system-maintenance Skill，不触发 creative、technical、
producer 或 art director gate，也不能自动推进任何游戏项目阶段。

---

## 测试用例

### Case 1: Natural Language Request

**Fixture**:

- 用户说：“我想加一个 Godot UI 生成 Skill。”

**Expected behavior**:

1. Skill 不要求用户选择参数或模式。
2. Skill 自己判断这是新增、修改、合并、references-only、route-only 还是 blocked。
3. Skill 读取现有 Skill、route index、workflow catalog 和 testing framework。

**Assertions**:

- [ ] 没有要求用户运行额外测试入口、额外修复入口或带参数重试。
- [ ] 输出用自然语言解释判定。
- [ ] 如果需要更多信息，最多问 3 个短问题。

### Case 2: Merge Redundant Skill Entrypoints

**Fixture**:

- 用户指出多个 Skill 只是同一治理流程的内部步骤。

**Expected behavior**:

1. 判定为 `Merge Skills` 或 `Delete / Hide`。
2. 保留一个用户入口。
3. 删除或隐藏冗余入口。
4. 将被删除入口的关键职责并入保留 Skill 的内部阶段。

**Assertions**:

- [ ] 冗余 Skill 不再出现在 `.agents/skills/*/SKILL.md`。
- [ ] catalog 不再引用已删除 Skill。
- [ ] route index 不再引用已删除 Skill。
- [ ] README、quick-start 或 docs 不再把已删除 Skill 当作用户命令。

### Case 3: Workflow Insertion Is Mandatory

**Fixture**:

- 用户要求新增或修改一个窗口/上下文/入口类 Skill。

**Expected behavior**:

1. Skill 不只创建 `SKILL.md`。
2. Skill 明确检查 `/start`、`/help`、workflow catalog、multi-window docs、context-management、Hooks 和 README 是否需要同步。
3. Skill 说明哪些文件改、哪些文件不改，以及理由。

**Assertions**:

- [ ] 输出包含 `Entry`、`Stage/Lane`、`Updated surfaces`、`Not updated`。
- [ ] 对入口类 Skill，必须判断 `/start` 是否受影响。
- [ ] 对路由类 Skill，必须判断 `/help` 和 route index 是否受影响。
- [ ] 对窗口类 Skill，必须判断 multi-window workflow 和 lane 更新规则是否受影响。

### Case 4: Modify Instead Of New

**Fixture**:

- 用户提出的能力与现有 Skill 的触发和输出重叠。

**Expected behavior**:

1. 判定为 `Modify existing Skill`。
2. 命名 owner Skill。
3. 不创建重复用户命令。

**Assertions**:

- [ ] 判定中说明为什么现有 Skill 拥有边界。
- [ ] 如果行为变化，计划更新对应 spec 和 route entry。
- [ ] 不提出新的 `.agents/skills/<new-name>/` 目录。

### Case 5: Mutable Design Facts Stay Out Of Stable Routing

**Fixture**:

- 用户要求的新能力提到当前项目事实，例如 2D/3D、美术风格、视角、输入方式或平台。

**Expected behavior**:

1. 这些内容只作为当前工件事实使用。
2. 不加入 route index 的 `stable_constraints`。
3. 如需使用，只在本次推荐中标注“当前工件显示”。

**Assertions**:

- [ ] stable constraints 仍只包含 Codex/Godot/AI 全链路/系统层事实。
- [ ] 可变事实从项目工件读取，不被写死为永久 Skill 行为。

### Case 6: Internal Verification And Repair

**Fixture**:

- 本 Skill 完成一次 Skill 修改后，发现 route index 或 catalog 有遗漏。

**Expected behavior**:

1. Skill 自己执行内部 static/spec/category/route/catalog/workflow insertion 检查。
2. 如果失败，提出最小修复。
3. 进行最多两轮内部修复。
4. 两轮后仍失败则输出 `FAIL`，不继续盲改。

**Assertions**:

- [ ] 不要求用户切换到另一个 Skill。
- [ ] 报告包含 static、spec、category、route/catalog、workflow insertion 的结果。
- [ ] 失败时列出具体文件和原因。

### Case 7: Blocked Path

**Fixture**:

- 用户要求把 authoring 和 review 合并，或要求实现 Skill 自动关闭 Story。

**Expected behavior**:

1. 返回 `BLOCKED` 或 `CONCERNS`。
2. 说明会削弱哪条 CCGS 边界。
3. 提供更安全替代方案，例如 route-only、references addition 或保留独立审查 Skill。

**Assertions**:

- [ ] 在风险解决前不提出写文件。
- [ ] 报告命名具体不变量：authoring/review、readiness/implementation、implementation/story-done 或 gate/user decision。

---

## 协作协议

- [ ] 写入任何文件前使用 `"May I write"`，除非用户当前消息已经明确授权本 changeset。
- [ ] 请求批准前先展示判定、动线接入审查和 changeset。
- [ ] 结尾给出可审计报告。
- [ ] 不在没有用户授权的情况下自动创建、删除或重写文件。

---

## 覆盖说明

此 spec 验证 Skill 治理入口本身。它不再要求用户运行单独测试或修复入口，
因为这些职责已经并入 `/skill-create-ccgs` 的内部验证和修复阶段。

