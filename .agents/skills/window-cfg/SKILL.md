---
name: window-cfg
description: "CFG 多窗口唯一入口。用于启动、恢复、创建、登记 lane 状态、审计、压缩、生成 checkpoint 提交建议，以及创建/合并研究 worktree；支持默认 A/B/C/D/Z，也支持自定义 lane id。"
argument-hint: "[lane-id|audit|compact lane-id|checkpoint lane-id|research lane-id slug|merge lane-id] [optional summary/objective]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Edit
model: haiku
---

# CFG Window

这是 CFG 多窗口体系的唯一用户入口。它把 lane 启动、恢复、刷新、审计、压缩、checkpoint、research/merge 收进一个入口。

常用方式：

```text
/window-cfg A                 # 启动、恢复或接手 A lane
/window-cfg B                 # 启动、恢复或接手 B lane
/window-cfg Z                 # 启动、恢复或接手 Z lane
/window-cfg checkpoint B      # 生成 checkpoint 提交建议
/window-cfg research B ai-nav # 创建研究 worktree 草案/执行
/window-cfg merge B           # 研究分支合并 preflight
/window-cfg audit             # 检查所有 lane、注册表和文件占用冲突
/window-cfg compact Z         # 压缩过长的 Z lane
/window-cfg systems-design    # 启动、恢复或创建自定义 lane
```

用户也可以用自然语言，例如“接手 B 窗口”“检查窗口冲突”“压缩 Z”“给 Z 做一个 checkpoint”“开一个研究分支”。

---

## Reference Loading Rules

Do not read `.agents/skills-archive/` during normal use.

Read `references/lane-protocol.md` only for lane creation/recovery, lane state
refresh, audit, compact, or when checking registry consistency.

Also read `.codex/docs/git-checkpoint-workflow.md` for checkpoint, research, or
merge intents.

---

## Phase 1: Parse Intent And Lane

识别第一个参数：

- `audit`：只读检查所有 lane。
- `compact`：压缩指定 lane。
- `checkpoint`、`提交建议`、`可以提交`：生成当前 lane 的 checkpoint plan。
- `research`、`experiment`、`研究分支`：创建研究 branch/worktree。
- `merge`、`合并研究`：对研究 branch 做 merge preflight，必要时执行 clean-only merge。
- 其他内容：视为启动、恢复或创建 lane。

`update`、`handoff`、`记录`、`交接` 只作为自然语言意图处理：把它们视为
“接手/刷新指定 lane 状态”，不要把它们作为用户需要记住的独立命令暴露出去。

如果用户没有给参数，输出最小用法并停止：

```text
Usage:
/window-cfg A                 # 总控/案子
/window-cfg B                 # 开发
/window-cfg C                 # 美术/资源
/window-cfg D                 # 总监/裁决
/window-cfg Z                 # 框架适配/底层维护
/window-cfg <lane-id>         # 自定义窗口
/window-cfg checkpoint <lane-id> # 生成 checkpoint 提交建议
/window-cfg research <lane-id> <slug> # 创建研究 worktree
/window-cfg merge <lane-id>   # 合并研究 worktree
/window-cfg audit             # 审计所有窗口
/window-cfg compact <lane-id> # 压缩 lane
```

Verdict: `BLOCKED`。

默认快捷别名：

| 输入 | Lane id | Lane file |
|---|---|---|
| `A`、`producer`、`A-producer` | `A-producer` | `production/session-state/windows/A-producer.md` |
| `B`、`dev`、`B-dev` | `B-dev` | `production/session-state/windows/B-dev.md` |
| `C`、`art`、`C-art` | `C-art` | `production/session-state/windows/C-art.md` |
| `D`、`director`、`D-director` | `D-director` | `production/session-state/windows/D-director.md` |
| `Z`、`platform`、`Z-platform` | `Z-platform` | `production/session-state/windows/Z-platform.md` |

这些只是默认快捷方式，不是窗口分类上限。

自定义 lane id 只允许小写字母、数字和连字符：`[a-z0-9][a-z0-9-]{0,63}`。
不合法时输出错误和 usage。Verdict: `BLOCKED`。

---

## Phase 2: Load Shared Context

按需读取：

1. `AGENTS.md`
2. `.codex/docs/context-management.md`
3. `.codex/docs/multi-window-workflow.md`
4. `production/session-state/active.md`
5. `production/session-state/windows/*.md`
6. `.codex/docs/git-checkpoint-workflow.md`（仅 checkpoint/research/merge 时）

不要依赖旧对话。以 `active.md` 和 lane 文件为准。

Work-order path contract:

- The only work-order root is `production/work-orders/`.
- A/B/C receive work by reading their lane blocker/request notes and the
  `production/work-orders/<code>.md` path named there.
- Do not create, route, or preserve work orders outside `production/work-orders/`.
- 如果执行 lane 有 D-director blocker/request 指向工单或 verdict 路径,这条记录是
  可执行 handoff,不是让用户重贴工单的提示。用户说"继续"、"处理"、"按总监"、
  "看总监的回复"、"执行 verdict"等短指令时,lane 应读取引用文件并执行自己的
  target-lane 段落,除非用户明确说"只看"、"总结"或"先别执行"。
- During lane recovery, if a lane points at a work-order file outside
  `production/work-orders/`, treat it as stale state. If the same filename exists
  under `production/work-orders/`, refresh the lane reference to the canonical
  path; otherwise output `TRACKING CONCERN` and ask Z-platform/A-producer to
  reconcile the missing work order.

---

## Phase 3: Start / Recover / Create / Refresh Lane

当 intent 是 start/recover/create 时：

1. 读取对应 lane 文件。
2. 如果存在，输出接手摘要，并把当前窗口接手记录写回 lane/active state：

```text
Window: [lane-id]
Role: [one-line responsibility]
Lane: [path]
Current objective: [from lane]
Next step: [from Handoff]
Avoid touching: [top 3 avoid paths]
Registry: registered / registry concern
Verdict: READY
```

这是用户明确输入 `/window-cfg <lane-id>` 后的低风险恢复点 bookkeeping。
不要要求用户再运行 `/window-cfg update`，也不要询问 `May I update...`。

如果目标 lane 是 A/B/C 且 lane blocker/request 或 handoff 指向
`production/work-orders/<code>.md` 或 `production/work-orders/<code>-D-verdict.md`,
恢复后先判断这是否是给本 lane 的可执行任务:

- 用户只说"看一下/总结/解释"且没有"继续/处理/执行/按总监"语义时,可以只总结。
- 用户说"继续/处理/按总监/执行 verdict/开始"等自然语言时,直接读取引用文件,
  执行本 lane 对应段落,并在完成后更新本 lane handoff 与 D blocker/request。
- 不要要求用户复制工单正文、重写执行清单或手工转发 D 的裁决。

更新范围：

- `production/session-state/active.md`：登记或刷新该 lane 的 registry/status。
- lane 文件：刷新 `Handoff` 的 `Last updated`、`Next step`、`Restart prompt`，
  并记录用户本次传入的 objective/summary（如果有）。
- 如果旧 `Handoff` 里仍有效的 blocker、active files、决定或下一步会被覆盖，
  先迁移到 Lane 主体区块；不要粗暴丢失长期状态。
- 不覆盖 `Responsibility`、`Scope` 或旧 `Decisions`，除非用户明确要改职责。

3. 如果 lane 文件不存在，生成并直接写入 lane 和 registry。

默认 lane 职责：

- `A-producer`：总控、范围、阶段、跨窗口协调。
- `B-dev`：代码实现、测试、runtime evidence、代码审查准备。
- `C-art`：美术、资源规格、资产清单和资源审计。
- `D-director`：项目级总监/裁决 lane。负责 A/B/C 体验、表现力、跨线冲突和 canon 裁决，不直接编辑执行产物。
- `Z-platform`：框架适配和底层维护，让 Skill、Hook、路由、测试框架和体系文档更符合当前用户、项目和团队习惯。
- 自定义 lane：按用户目标或当前请求生成，不套用 A/B/C/D/Z。

新建 lane 时同步更新 `production/session-state/active.md` 的 registry。用户明确输入
`/window-cfg <lane-id>` 就是创建/接手该 lane 的授权；这是低风险、可逆的框架
bookkeeping，不需要额外确认。创建后输出 lane path、职责、当前目标和下一步。

---

## Phase 4: Lane State Refresh Contract

`update` / `handoff` 不再是推荐给用户的独立命令。Codex 在这些时机应自行刷新
当前 lane 状态：

- 窗口刚完成一个阶段性产物。
- 准备关闭窗口。
- 上下文超过约 60-70%。
- 修改了本窗口 owner 路径中的文件。
- 发现需要另一个窗口输入。
- 用户说“记录一下”“交接一下”“更新窗口状态”。

读取目标 lane 和 `active.md`。如果 lane 不存在，按 Phase 3 创建，不再要求用户先跑
另一个命令。

刷新时必须分清：

- Lane 主体：长期状态，包括职责、范围、当前目标、活跃文件、进度、关键决定、跨窗口 blocker。
- Handoff：最近恢复点，包括刚完成什么、改了哪些文件、跑了哪些检查、下一步怎么恢复。

规则：

- 不覆盖 `Responsibility` 和 `Scope`，除非用户明确要改窗口职责。
- `Decisions` 只追加，不覆盖。
- `Handoff` 可以替换，但替换前要检查旧内容；仍有效的信息迁移到主体区块。
- 不写整段聊天记录、大段 diff、或和该 lane 无关的细节。
- 直接写入低风险 lane state refresh；不要询问 `May I update...`。

输出时简要说明：

```text
本次更新范围：
- Lane 主体：更新 / 追加 / 保持不变 [...]
- Handoff：替换为最新恢复点 / 保持不变
- 不改：[Responsibility, Scope, ...]
- 旧 Handoff 处理：[迁移 / 保留 / 过期丢弃]
```

Verdict: `COMPLETE`。

---

## Phase 5: Audit Lanes

Audit 模式只读，不写文件。

检查 `production/session-state/windows/*.md`，不要硬编码只检查 A/B/C/D/Z。

对每个 lane 检查：

- 是否包含 `Responsibility`、`Current Objective`、`Scope`、`Active Files`、`Progress`、`Decisions`、`Blockers / Needs From Other Windows`、`Handoff`。
- `Handoff` 是否包含 `Last updated` 和 `Next step`。
- lane 文件是否存在但未在 `active.md` registry 中登记。
- `active.md` 是否登记了不存在的 lane file。
- `Active Files` 中同一路径是否被多个 lane 占用。
- 任何 work-order 引用是否都位于 `production/work-orders/`。
- 是否存在项目根部的非正典 work-order 存储目录；存在则输出 `TRACKING CONCERN`。

File conflict 检查保持简单：

1. 只扫描每个 lane 的 `## Active Files` 区块。
2. 从反引号中提取路径。
3. 同一路径出现在两个或更多 lane 时输出 `FILE CONFLICT`。
4. 不自动解决，不自动改文件。

输出：

```text
Window Audit
[lane-id]: MISSING / STALE / READY / TRACKING CONCERN
File conflicts: none / FOUND
Checkpoint concerns: none / FOUND
Verdict: PASS / CONCERNS / FAIL
```

---

## Phase 6: Compact Lane

当 lane 文件过长时运行 compact。

默认阈值：

- 软阈值：220 行，建议压缩。
- 硬阈值：300 行，应压缩。

压缩方法：

1. 读取目标 lane。
2. 创建归档路径：`production/session-state/windows/archive/<lane-id>-YYYYMMDD-HHMM.md`。
3. 把旧 lane 完整内容写入归档。
4. 重写 lane，只保留职责、当前目标、范围、活跃文件、最近 5 条决定、当前 blocker、当前 handoff 和归档链接。

写入前询问：

```text
May I archive and compact production/session-state/windows/<lane-id>.md?
```

Verdict: `COMPLETE` 或 `CONCERNS`。

---

## Phase 7: Checkpoint Plan

Checkpoint 模式只在用户明确要求 `/window-cfg checkpoint <lane-id>`、用户问“现在可以提交吗”、或 lane refresh 后需要建议时运行。默认只建议，不自动 commit。

必须读取：

- `.codex/docs/git-checkpoint-workflow.md`
- 目标 lane 文件
- `production/session-state/active.md`
- `git status --short`
- `git diff --name-only`
- `git diff --cached --name-only`

检查：

1. 目标 lane 是否存在并已注册。
2. `/window-cfg audit` 语义是否会发现 file conflict。
3. unstaged/untracked files 是否包含其他 lane owner 路径。
4. staged files 是否跨多个 owner domain。
5. 本次建议 stage 的文件是否能组成单一 rollback unit。
6. 是否存在 untracked lane 文件；存在时 Verdict: `BLOCKED`。

输出 checkpoint plan：

```text
Checkpoint candidate
Lane: [lane-id]
Reason: [why now]
Stage only:
- [file]
Leave unstaged:
- [file] — [reason]
Suggested commit:
  [type]: [subject]

Body:
  Lane: [lane-id]
  Scope: [scope]
  Verification: [checks]
  Rollback: git revert <sha-after-commit>
Verdict: READY / CONCERNS / BLOCKED
```

如果用户明确要求执行 commit，或 lane 明确记录 `auto_checkpoint: true`：

- 仍然只 stage plan 中列出的文件。
- 禁止 `git add .`。
- commit message 必须包含 `Lane:`、`Scope:`、`Verification:`、`Rollback:`。
- commit 成功后输出实际 SHA 和 `git revert <sha>`。
- 如果 commit 失败，不自动修复；输出失败原因和下一步。

---

## Phase 8: Research Worktree

Research 模式用于不确定方向、原型方向或需要隔离的底层改造。不要在共享 worktree
里直接切换分支。

输入：

```text
/window-cfg research <lane-id> <slug>
```

规则：

1. `<slug>` 只允许小写字母、数字和连字符。
2. 读取 `git status --short`、`git rev-parse --abbrev-ref HEAD`、`git rev-parse HEAD`。
3. 如果当前 worktree 有与该 lane owner 路径重叠的未 checkpoint 改动，Verdict: `BLOCKED`，建议先 `/window-cfg checkpoint <lane-id>`。
4. branch 名为 `codex/research/<normalized-lane-id>-<slug>-YYYYMMDD`，lane id 必须转成小写并把非 `[a-z0-9-]` 字符替换为连字符。
5. worktree 路径为 `../cfg-worktrees/<normalized-lane-id>-<slug>`。
6. 创建前输出 branch、worktree、base SHA、merge target 和 rollback/removal command。
7. 用户输入本命令可视为创建 branch/worktree 的授权；如果存在风险或路径冲突，必须再次询问。
8. 创建成功后，更新 lane 文件，记录 branch、worktree path、base SHA、merge target、auto_merge policy 和 removal command。

允许的 git 操作：

- `git status`
- `git rev-parse`
- `git branch --list`
- `git worktree list`
- `git worktree add -b <branch> <path> <base>`

禁止在 research 创建中 commit、push、force、reset、checkout 丢弃。

---

## Phase 9: Research Merge

Merge 模式用于研究 worktree 回流主线。

输入：

```text
/window-cfg merge <lane-id>
```

必须读取 lane 中记录的 branch/worktree/base/target。没有记录则 Verdict:
`BLOCKED`。

Preflight：

1. main/shared worktree 没有未 checkpoint 的重叠改动。
2. research worktree 存在。
3. research worktree `git status --short` 为空。
4. branch 存在。
5. `git merge-base <target> <branch>` 与记录 base 一致，或输出 drift concern。
6. 使用非破坏性 merge check（例如 `git merge-tree`）检查冲突。
7. 验证结果已记录；没有验证则 `CONCERNS`。

自动 merge 只允许在 lane 记录 `auto_merge: clean-only` 且所有 preflight 通过时执行。
否则输出 merge plan 并询问：

```text
May I merge research branch <branch> into <target> with this plan?
```

Merge 成功后输出 merge SHA、rollback command `git revert -m 1 <merge-sha>`，并更新 lane。

---

## Phase 10: Output Rules

保持短。窗口 Skill 是恢复和记录工具，不是长报告。

完成后提示：

- 继续当前窗口：按 `Next step` 做。
- 换窗口：运行 `/window-cfg <lane-id>`。
- 准备提交：运行 `/window-cfg checkpoint <lane-id>`。
- 开研究分支：运行 `/window-cfg research <lane-id> <slug>`。
- 检查所有窗口：运行 `/window-cfg audit`。
