# Skill Spec: /window-handoff-ccgs

> **Category**: utility
> **Priority**: medium
> **Spec written**: 2026-06-04

## Skill 摘要

`/window-handoff-ccgs` 用于更新、审计和压缩 CCGS 多窗口 lane 状态文件。它负责把窗口里的关键上下文写回 `production/session-state/windows/<window>.md`，并防止 lane 文件无限增长。它是 `/window-start-ccgs` 的配套恢复机制。

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

### Case 1: Update — 阶段性工作后写回 lane

**Fixture**:
- 用户输入 `/window-handoff-ccgs update B`
- `production/session-state/windows/B-dev.md` 存在。
- 本轮有代码或测试相关改动。

**Expected behavior**:
1. 映射 `B` 到 `B-dev`。
2. 读取 lane、active.md 和多窗口协议。
3. 先生成更新范围说明，标出 Lane 主体、Handoff 和不改区块。
4. 生成 Lane 主体变更草稿和 Handoff 替换草稿。
5. 写入前询问 `May I update production/session-state/windows/B-dev.md with this handoff?`

**Assertions**:
- [ ] 草稿先声明 `本次更新范围`。
- [ ] 草稿明确列出 Lane 主体会更新、追加或保持不变的区块。
- [ ] 草稿明确说明 Handoff 会被替换，或说明为什么保持不变。
- [ ] 草稿区分 `Lane 主体变更` 和 `Handoff 替换内容`。
- [ ] Handoff 包含 Last updated、Completed、Changed files、Tests、Open blockers、Next step、Restart command。
- [ ] 不把完整聊天记录写入 lane。
- [ ] 不把巨大 diff 写入 lane。
- [ ] 写入前请求用户批准。

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 2: Audit — 发现过期或缺字段 lane

**Fixture**:
- 用户输入 `/window-handoff-ccgs audit`
- `A-producer.md` 缺少 Handoff。
- `Z-platform.md` 完整。
- `systems-design.md` 是自定义 lane 且完整。

**Expected behavior**:
1. 读取所有 lane 文件。
2. 标记 A-producer 为 `CONCERNS` 或 `FAIL`。
3. 标记 Z-platform 为 `READY`。
4. 标记 systems-design 为 `READY`，不因为它不是 A/B/C/D/Z 而忽略。

**Assertions**:
- [ ] audit 模式只读，不写文件。
- [ ] 输出每个窗口状态。
- [ ] audit 基于 `production/session-state/windows/*.md`，不是固定 A/B/C/D/Z 枚举。
- [ ] 缺失 Last updated 或 Next step 会被标记。

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 3: Compact — lane 超长后归档

**Fixture**:
- 用户输入 `/window-handoff-ccgs compact Z`
- `Z-platform.md` 超过 500 行。

**Expected behavior**:
1. 生成 archive 路径。
2. 准备把旧 lane 完整写入 archive。
3. 准备重写 lane 为短摘要。
4. 写入前询问 `May I archive and compact...`

**Assertions**:
- [ ] 归档保留完整旧内容。
- [ ] 新 lane 保留 Responsibility、Current Objective、Scope、Active Files、最近 Decisions、Blockers、Handoff、Archive links。
- [ ] 不在未批准时写 archive 或重写 lane。

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 4: Missing Lane — 引导先 start

**Fixture**:
- 用户输入 `/window-handoff-ccgs update systems-design`
- `production/session-state/windows/systems-design.md` 不存在。

**Expected behavior**:
1. 停止更新。
2. 提示先运行 `/window-start-ccgs systems-design`。
3. 返回 `BLOCKED`。

**Assertions**:
- [ ] 不创建不完整 lane。
- [ ] 不要求用户复制旧聊天。
- [ ] 自定义 lane 缺失时使用同一个 lane id 给出 start 命令。

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 5: Key Information Protection — 防止丢失关键决策

**Fixture**:
- 用户在窗口中做了一个尚未写入正式文档的关键决定。
- 旧 `Handoff` 中包含一个仍然有效的 blocker 和一个仍然有效的 next step。
- 用户运行 `/window-handoff-ccgs update A`。

**Expected behavior**:
1. 要求把该决定写入 `Decisions`。
2. 如果决定影响其他窗口，写入 `Blockers / Needs From Other Windows`。
3. 如果决定已经写入正式文档，只引用文件路径，不重复长正文。
4. 覆盖旧 `Handoff` 前先检查旧内容。
5. 仍然有效的 blocker、文件状态或 next step 被迁移到 Lane 主体或新 `Handoff`。

**Assertions**:
- [ ] 未落盘的关键决定不会只留在聊天中。
- [ ] 已落盘的长内容用路径引用。
- [ ] 旧 Handoff 中仍有效的信息不会因为新 Handoff 覆盖而丢失。
- [ ] 已过期的旧 Handoff 信息可以丢弃，但草稿必须说明原因。
- [ ] Handoff 包含下一步和恢复命令。

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 6: Lane Body vs Handoff — 防止只更新最近摘要

**Fixture**:
- 用户输入 `/window-handoff-ccgs update Z`。
- 本轮新增了一个长期流程决定：update 草稿必须声明更新范围。
- 本轮也产生了一个最近恢复点：下一步运行 audit。

**Expected behavior**:
1. 把长期流程决定追加到 `Decisions`。
2. 把流程测试完成状态写入 `Progress`。
3. 用最近恢复点替换 `Handoff`。
4. 草稿中标出 `Responsibility` 和 `Scope` 不变。

**Assertions**:
- [ ] 不能只替换 `Handoff` 而不更新需要长期保存的 Lane 主体信息。
- [ ] `Decisions` 只追加，不覆盖旧决定。
- [ ] `Progress` 保留仍然有效的旧条目。
- [ ] `Handoff` 只保存最近恢复摘要，不累加成长日志。

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 7: Tracking Concern — lane 存在但未纳入 git

**Fixture**:
- 用户输入 `/window-handoff-ccgs update Z`
- `production/session-state/windows/Z-platform.md` 存在。
- `git ls-files -- production/session-state/windows/Z-platform.md` 没有输出。

**Expected behavior**:
1. 正常生成 update 草稿。
2. 在 `Open blockers` 或审计结果中标记 tracking concern。
3. 提醒 lane 是项目状态工件，应纳入 git。
4. 不自动运行 `git add`。

**Assertions**:
- [ ] 未跟踪 lane 不会被悄悄忽略。
- [ ] 不自动 stage 文件。
- [ ] 输出给出明确修复方向。

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 8: File Conflict — 多个 lane 占用同一文件

**Fixture**:
- 用户输入 `/window-handoff-ccgs audit`
- `systems-design.md` 的 `Active Files` 包含 `` `design/gdd/combat.md` ``。
- `B-dev.md` 的 `Active Files` 也包含 `` `design/gdd/combat.md` ``。

**Expected behavior**:
1. audit 扫描所有 lane 的 `## Active Files` 区块。
2. 从反引号中提取 active file 路径。
3. 发现同一路径出现在多个 lane。
4. 输出 `FILE CONFLICT`，列出冲突文件和相关 lane。
5. 不自动修改 lane，不自动解决冲突。

**Assertions**:
- [ ] 同一 active file 被多个 lane 引用时会被标记。
- [ ] 输出建议 handoff/request/split。
- [ ] audit 模式仍然只读。

**Case Verdict**: PASS / FAIL / PARTIAL

---

## 协作协议

- [ ] 更新 lane 前使用 `"May I update"`。
- [ ] compact 前使用 `"May I archive and compact"`。
- [ ] audit 模式不写文件。
- [ ] 不要求用户复制完整旧对话。
- [ ] update 草稿必须声明更新范围，让用户知道将修改 Lane 主体还是只替换 Handoff。
- [ ] A/B/C/D/Z 是默认快捷别名，不是窗口分类上限。
- [ ] 支持自定义 lane id，并扫描所有 lane 文件。
- [ ] audit 检查 `Active Files` 重复占用并报告 file conflict。

---

## 覆盖说明

实际使用时，`/window-start-ccgs` 负责启动/恢复窗口，`/window-handoff-ccgs` 负责中途更新、结束交接、审计和压缩。修改本 Skill 后运行 `/skill-test static window-handoff-ccgs`、`/skill-test category window-handoff-ccgs`、`/skill-test spec window-handoff-ccgs` 和 `/skill-test audit`。
