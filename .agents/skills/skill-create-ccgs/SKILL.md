---
name: skill-create-ccgs
description: "CCGS Skill 唯一治理入口。用户只用自然语言提出新增、修改、合并、删除、测试或优化 Skill 的需求；本 Skill 内部完成现有体系审查、动线接入判断、写入方案、复查和必要修复。不要再让用户选择额外测试/修复入口或参数模式。"
argument-hint: "[自然语言需求]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit
model: sonnet
---

# CCGS Skill Governance

这是 CCGS Codex 魔改体系的唯一用户入口，用来处理所有 Skill 新增、修改、
合并、删除、路由、测试和优化请求。

用户不需要知道 `static`、`spec`、`category`、`audit`、`improve` 这些内部概念。
这些是本 Skill 的内部步骤，不是用户命令。

核心目标：**减少可见入口，防止 Skill 堆膨胀，同时确保任何 Skill 变化都真的融入
原有 CCGS 动线。**

---

## Reference Loading Rules

Do not read `.agents/skills-archive/` during normal use. Old `/skill-test`,
`/skill-improve`, and generic `skill-creator` behavior is absorbed into this
Skill's internal phases. Use `references/absorption-map.md` only for governance
audits of what was absorbed.

---

## Phase 1: Understand The User Request

读取用户的自然语言需求。不要要求用户选择模式或记参数。

先把需求归类为一个或多个内部意图：

- 新增 Skill。
- 修改已有 Skill。
- 合并多个 Skill。
- 删除或隐藏冗余 Skill。
- 只改 route index。
- 只补 references、模板、检查表或测试 spec。
- 修复某个 Skill 的触发、输出、动线接入或测试失败。
- 审计某个 Skill 是否真的进入体系。

如果信息不足，最多问 3 个短问题：

1. 这个能力要解决哪个重复问题？
2. 它应该读哪些上游工件、写哪些下游工件？
3. 它会接到哪个用户动线里，例如 `/start`、`/help`、阶段 workflow、窗口 lane、Hook 或发布流程？

不要把问题改写成参数说明。用户给一句自然语言也可以继续。

---

## Phase 2: Load Existing System

在提出任何新增或修改方案前，读取足够上下文。优先读取索引和 frontmatter，
只在需要时读取完整 Skill。

必须检查：

- `AGENTS.md`
- `.agents/skills/*/SKILL.md` 的 frontmatter
- `.codex/docs/skill-route-index.yaml`
- `.codex/docs/workflow-catalog.yaml`
- `.codex/docs/multi-window-workflow.md`
- `.codex/docs/context-management.md`
- `CCGS Skill Testing Framework/catalog.yaml`
- `CCGS Skill Testing Framework/quality-rubric.md`
- `CCGS Skill Testing Framework/templates/skill-test-spec.md`

按需求选择性读取：

- 相关已有 Skill 的完整 `SKILL.md`
- 相关测试 spec
- `.codex/hooks/`、`.githooks/`
- README、architecture docs、publishing docs
- `production/session-state/active.md`
- `production/session-state/windows/*.md`

稳定约束：

- Codex-only。
- Godot-focused。
- 用户是高度 AI 全链路开发者。
- 用户不会手动管理大量命令；路由必须由 AI 解释和执行。

可变设计事实：

- 2D/3D、美术风格、视角、题材、输入方式、平台、当前玩法目标。
- 这些只能从当前项目工件读取，不能写死进平台级 Skill。

---

## Phase 3: Decide The Smallest Correct Change

先判定是否真的需要新增 Skill。默认倾向于复用、合并或修改现有入口。

### 3.0 Value Preservation Filter

合并或删除旧 Skill 时，不是按“旧文档有多长”决定保留价值，而是按它是否提供
LLM 靠常识无法稳定复现的体系信息。

必须吸收：

- CCGS/Godot 特有的产物路径、文件命名、状态字段或 registry 更新。
- 明确的 PASS / CONCERNS / FAIL / BLOCKED / READY 判定边界。
- 会影响阶段推进、窗口交接、Story 状态、测试证据或发布风险的检查点。
- 防止自证完成的职责边界，例如 authoring、implementation、review、gate 的分离规则。
- Godot 版本、GDScript、场景/资源/测试运行方式相关的稳定约束。

可以删掉或不迁移：

- 普通 LLM 仅凭自然语言也能完成的泛用解释。
- Claude Code、Unity、Unreal 或多引擎选择逻辑，除非当前 Godot 项目明确需要迁移对照。
- 只是在重复“读取上下文、总结、给建议”的段落。
- 已由核心 Skill 更短规则覆盖的 team orchestration 包装层。
- 让用户学习参数或额外入口的说明。

如果不确定某段是否要迁移，先问：

> 不看这个旧 Skill，仅靠核心 Skill + 当前项目文件，能否 100% 稳定地产生同样
> 的路径、判定和状态更新？

如果答案不是明确“能”，迁移成短规则；如果答案是“能”，不要迁移。

| Decision | When | Action |
|---|---|---|
| Modify existing Skill | 触发、上游、下游和证据边界与现有 Skill 接近 | 修改现有 Skill 和对应 route/spec |
| Merge Skills | 多个用户入口只是同一治理链路的内部步骤 | 保留一个入口，删除或隐藏冗余入口 |
| Route-only | 行为没变，只是 `/help` 或动线推荐不准 | 只改 route index 或对应路由 Skill |
| References-only | 缺的是稳定资料、模板或检查表 | 加 references，不新增用户命令 |
| Workflow integration | Skill 已存在但没有接入 `/start`、`/help`、workflow、lane 或 Hook | 修改接入点，不新建重复 Skill |
| New Skill | 有独立触发、独立工件边界、独立质量门且无法被现有 Skill 覆盖 | 新建并全量接入 |
| Delete / Hide | 用户可见入口只暴露内部维护动作，增加认知负担 | 删除 Skill 或从 route/catalog 中移除 |
| Reject / Defer | 一次性需求、职责不清、会绕过审查链 | 输出 `CONCERNS` 或 `BLOCKED` |

保护边界：

- authoring 不能自审。
- readiness 不能实现。
- implementation 不能自证完成。
- gate 只能建议 PASS/CONCERNS/FAIL，不能替用户推进阶段。
- team Skill 只编排跨域协作，不能替代原子 Skill 的证据链。
- 内部测试和修复可以并入本 Skill，但不能把审查职责和产出职责混成一个游戏开发 Skill。

---

## Phase 4: Mandatory Workflow Insertion Review

这是防止“造了 Skill 但没融入体系”的硬性步骤。任何新增、修改、合并或删除
Skill，都必须先回答下面的问题。

不要只说“已创建 `.agents/skills/<name>/SKILL.md`”。那不算接入完成。

### 4.1 User Entry Surface

这个能力会从哪里被用户遇到？

- `/start`
- `/help`
- 阶段 workflow catalog
- 某个现有 Skill 的下一步
- 多窗口 lane：`A/B/C/D/Z` 或自定义 lane
- Hook 提醒
- README / quick start / docs
- 用户点名才使用

如果答案是“用户点名才使用”，必须说明为什么它不应该出现在常规路由里。

### 4.2 Stage And Lane Fit

说明它属于哪个阶段和哪个 lane：

- Concept、Systems Design、Technical Setup、Pre-Production、Production、Polish、Release、Support
- A-producer、B-dev、C-art、D-qa、Z-platform 或自定义 lane

如果它影响窗口体系、上下文恢复、Skill、Hook、route index 或发布脚本，
默认属于 `Z-platform`。

### 4.3 Upstream And Downstream Artifacts

列出：

- 读取哪些上游工件。
- 写入哪些下游工件。
- 哪些工件只读。
- 哪些文件 owner 需要 A-producer 或 Z-platform 裁决。

### 4.4 Route And Catalog Effects

检查是否需要改：

- `.codex/docs/skill-route-index.yaml`
- `.codex/docs/workflow-catalog.yaml`
- `CCGS Skill Testing Framework/catalog.yaml`
- `CCGS Skill Testing Framework/skills/<category>/<name>.md`
- `docs/ccgs-codex-architecture.md`
- `.codex/docs/multi-window-workflow.md`
- `.codex/docs/context-management.md`
- `.agents/skills/help/SKILL.md`
- `.agents/skills/start/SKILL.md`
- Hooks 或 Git hooks
- README / public release docs

如果某项不改，必须说明“不改的理由”。例如 route index 已经覆盖、workflow 不进入主线、README 不需要用户入口。

### 4.5 Regression Question

明确回答：

```text
这个变化会不会让原 CCGS 动线断掉？
会不会让 /start、/help、阶段推进、窗口路由或 Hook 提醒产生冲突？
如果不会，证据是什么？
```

没有这个回答，不允许进入写入阶段。

---

## Phase 5: Draft Changeset

输出一个简短 changeset 草案，按文件列出将改什么。

常见文件：

- `.agents/skills/<name>/SKILL.md`
- `.codex/docs/skill-route-index.yaml`
- `.codex/docs/workflow-catalog.yaml`
- `.agents/skills/help/SKILL.md`
- `.agents/skills/start/SKILL.md`
- `.codex/docs/multi-window-workflow.md`
- `CCGS Skill Testing Framework/catalog.yaml`
- `CCGS Skill Testing Framework/skills/<category>/<name>.md`
- README / docs
- Hooks / Git hooks

写入前必须请求批准：

`May I write this CCGS Skill governance changeset to [file list]?`

如果用户已经明确说“开始修改”“执行”“改掉”，可把该消息视为当前 changeset 的写入授权，
但仍要在回复中说明会改哪些文件。

---

## Phase 6: Write

按 changeset 写入。保持修改范围最小。

写作规则：

- 用户入口尽量少。内部维护动作不要暴露成多个 Skill。
- 不要求用户记参数或测试模式。
- `description` 必须能让 Codex 正确发现 Skill。
- `SKILL.md` 1000 行以内可接受；不要为了短而破坏证据边界。
- 长资料放 references。
- 有写入能力时必须包含 ask-before-write 协作语言。
- 末尾必须包含下一步或 handoff。
- 必须有清晰 verdict 词：`READY`、`COMPLETE`、`CONCERNS`、`BLOCKED`、`PASS`、`FAIL`。

---

## Phase 7: Internal Verification

写入后，本 Skill 自己执行内部验证职责。不要要求用户再调用另一个 Skill。

### 7.1 Static Check

对改动后的 Skill 检查：

- frontmatter 必填字段。
- 至少两个 Phase。
- verdict 词。
- 写入权限对应 ask-before-write。
- 有下一步 handoff。
- argument-hint 不把用户逼进参数模式。
- description 包含触发场景。

### 7.2 Spec Check

如果有对应测试 spec：

- Skill 行为是否满足 spec 的 happy path、blocked path、integration path、mutability path、protocol path。
- 如果 spec 已过期，更新 spec，而不是让过期 spec 反向约束正确设计。

### 7.3 Category Check

读取 `quality-rubric.md` 中对应 category，检查是否破坏 authoring、review、
readiness、pipeline、gate、team、utility 等边界。

### 7.4 Route And Catalog Audit

检查：

- 每个存在的 `.agents/skills/*/SKILL.md` 都有正确 catalog entry 和 route entry，除非明确作为系统外实验文件并记录原因。
- route entry 不指向不存在的 Skill。
- catalog 不引用不存在的 spec。
- workflow catalog 只包含阶段主线 Skill。
- `stable_constraints` 没有写入可变设计事实。
- `/help` 能解释推荐原因。

### 7.5 Workflow Insertion Audit

针对本次变更重新检查 Phase 4：

- 入口面是否正确。
- 阶段/lane 是否正确。
- `/start`、`/help`、workflow、multi-window、Hook、README 是否需要同步。
- 如果是上下文、窗口或入口类 Skill，必须确认 `/start` 或 `/help` 是否需要改。

---

## Phase 8: Internal Repair Loop

如果 Phase 7 发现失败或警告，本 Skill 自己执行内部修复职责：

1. 说明失败点。
2. 提出最小修复。
3. 请求写入授权，除非用户已明确授权本轮修复。
4. 写入修复。
5. 重新执行 Phase 7。

最多进行两轮内部修复。两轮后仍失败，输出 `FAIL` 并列出剩余问题，不继续盲改。

不要让用户切换到别的修复入口。

---

## Phase 9: Report

输出必须短而可审计：

```text
Decision: Modify / New / Merge / Delete / Route-only / References-only / Blocked
Why: ...
Workflow insertion:
- Entry: ...
- Stage/Lane: ...
- Updated surfaces: ...
- Not updated: ... because ...
Files changed:
- ...
Verification:
- static: PASS/FAIL
- spec: PASS/FAIL/not applicable
- category: PASS/FAIL/not applicable
- route/catalog: PASS/FAIL
- workflow insertion: PASS/FAIL
Verdict: COMPLETE / CONCERNS / FAIL / BLOCKED
```

不要自动提交。除非用户明确要求，不运行 git commit。

