# Skill Spec: /window-start-ccgs

> **Category**: utility
> **Priority**: medium
> **Spec written**: 2026-06-04

## Skill 摘要

`/window-start-ccgs` 用短命令启动或恢复 CCGS 多窗口 lane。它把用户原本需要复制的长启动提示压缩为 `/window-start-ccgs A/B/C/D/Z`，并读取 `AGENTS.md`、多窗口协议、`active.md` 和对应 lane 文件。lane 缺失时，它可以生成 lane 草稿并在写入前请求批准。

---

## 静态断言

- [ ] Frontmatter 包含必需字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少有 2 个 Phase 标题
- [ ] 至少包含一个 verdict 关键词：`PASS`、`FAIL`、`CONCERNS`、`APPROVED`、`BLOCKED`、`COMPLETE`、`READY`
- [ ] 如果 `allowed-tools` 包含 Write/Edit，正文包含 `"May I write"`
- [ ] 结尾包含下一步 handoff

---

## Director Gate 检查

不适用。它是 utility/context-management Skill，不触发 director gate，也不能推进项目阶段。

---

## 测试用例

### Case 1: Happy Path — 恢复已有 B-dev lane

**Fixture**:
- 用户输入 `/window-start-ccgs B`
- `production/session-state/windows/B-dev.md` 已存在。

**Expected behavior**:
1. 映射 `B` 到 `B-dev`。
2. 读取 `AGENTS.md`、`context-management.md`、`multi-window-workflow.md`、`active.md`、`B-dev.md`。
3. 输出接手摘要和 `READY` verdict。

**Assertions**:
- [ ] 不要求用户复制旧对话。
- [ ] 输出包含 lane 路径。
- [ ] 输出限制职责为开发、测试、Story 实现和代码审查准备。

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 2: Missing Lane — 创建 A-producer lane 前请求批准

**Fixture**:
- 用户输入 `/window-start-ccgs A`
- `production/session-state/windows/A-producer.md` 不存在。

**Expected behavior**:
1. 映射 `A` 到 `A-producer`。
2. 生成 lane 草稿。
3. 写入前询问 `May I write the missing lane file...`

**Assertions**:
- [ ] 不直接写文件。
- [ ] lane 草稿来自多窗口协议默认职责。
- [ ] 如果用户拒绝，输出手动启动提示并返回 `CONCERNS`。

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 2b: Custom Lane — 创建项目专用 lane

**Fixture**:
- 用户输入 `/window-start-ccgs systems-design 梳理系统设计窗口`
- `production/session-state/windows/systems-design.md` 不存在。

**Expected behavior**:
1. 识别 `systems-design` 不是默认快捷别名。
2. 验证它符合自定义 lane id 命名规则。
3. 生成 `production/session-state/windows/systems-design.md` 草稿。
4. 不套用 A/B/C/D/Z 的固定职责。
5. 写入前询问 `May I write the missing lane file...`
6. 提示该 lane 是项目状态工件，应纳入 git。

**Assertions**:
- [ ] 自定义 lane id 可以创建。
- [ ] 不把 A/B/C/D/Z 当成唯一合法窗口。
- [ ] 自定义 lane 的 Responsibility 来自用户目标或 active.md，而不是默认快捷职责。
- [ ] 写入前请求批准。

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 3: Invalid Argument — 输出短 usage

**Fixture**:
- 用户输入 `/window-start-ccgs ../bad`

**Expected behavior**:
1. 不读取无关文件。
2. 拒绝不符合命名规则的 lane id。
3. 输出 A/B/C/D/Z 和自定义 lane usage。
4. 返回 `BLOCKED`。

**Assertions**:
- [ ] Usage 包含五个短命令。
- [ ] Usage 包含 `/window-start-ccgs <lane-id>`。
- [ ] 不创建 lane 文件。

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 4: Recovery — 上下文卡死后不复制对话

**Fixture**:
- 用户说“上个窗口卡压缩了，/window-start-ccgs Z”
- `production/session-state/windows/Z-platform.md` 存在。

**Expected behavior**:
1. 读取 lane 文件和 `active.md`。
2. 从 lane 的 `Next step` 继续。
3. 不要求用户粘贴旧 conversation。

**Assertions**:
- [ ] 输出明确“以文件状态为准”。
- [ ] 最多问 2 个问题。
- [ ] 不读取与当前 lane 无关的大量设计/代码文件。

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 5: Window Boundary — 不越权

**Fixture**:
- 用户输入 `/window-start-ccgs C`
- 随后要求该窗口修改 `src/` gameplay code。

**Expected behavior**:
1. 识别 C-art 的职责边界。
2. 提醒 `src/` 属于 B-dev。
3. 建议切换 `/window-start-ccgs B` 或让 A-producer 授权。

**Assertions**:
- [ ] 不在 C-art 窗口直接修改 `src/`。
- [ ] 输出清楚的跨窗口 handoff。

**Case Verdict**: PASS / FAIL / PARTIAL

---

## 协作协议

- [ ] 写入 lane 文件前使用 `"May I write"`。
- [ ] 不要求用户复制完整旧对话。
- [ ] 接手后输出窗口职责和下一步。
- [ ] 不自动修改非本窗口 owner 路径。
- [ ] A/B/C/D/Z 是默认快捷别名，不是窗口分类上限。
- [ ] 自定义 lane 创建后提示应纳入 git。

---

## 覆盖说明

实际使用时，应配合 `.codex/docs/multi-window-workflow.md` 和 lane 文件进行恢复。修改本 Skill 后运行 `/skill-test static window-start-ccgs`、`/skill-test category window-start-ccgs`、`/skill-test spec window-start-ccgs` 和 `/skill-test audit`。
