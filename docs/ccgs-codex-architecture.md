# CFG Codex Architecture

生成日期：2026-06-04  
最近更新：2026-06-13

CFG 是本仓库当前的 Codex 运行框架。它是 CCGS 的深度魔改版本；`/window-cfg`
是当前多窗口入口，`/skill-create-cfg` 是唯一 Skill 治理入口。`docs/ccgs-*`
只是历史文档路径，不代表仍在运行原版 CCGS。

## 当前规模

- Legacy Agent：not active by default; specialist roles must be restored through CFG governance when needed.`r`n- Core Skill：13 个。
- Support/optional Skill：2 个。
- Default Lane：A-producer、B-dev、C-art、D-director、Z-platform。
- Codex Hook：5 个。
- Git Hook：2 个。

## Source Of Truth

| 区域 | 权威位置 | 作用 |
|---|---|---|
| Runtime charter | `AGENTS.md` | 稳定协作规则、CFG 身份、权威地图 |
| Operating checklist | `.codex/docs/cfg-operating-checklist.md` | 快速判断动线、owner、入口和需要继续读取的文件 |
| Skill bodies | `.agents/skills/<skill>/SKILL.md` | Skill 触发、读写边界、执行步骤 |
| Route index | `.codex/docs/skill-route-index.yaml` | `/help` 与当前有效路由 |
| Workflow catalog | `.codex/docs/workflow-catalog.yaml` | 阶段与下一步推荐 |
| Multi-window protocol | `.codex/docs/multi-window-workflow.md` | A/B/C/D/Z lane、work order、队列和范围控制 |
| Generated artifact governance | `.codex/docs/generated-artifact-governance.md` | Skill 生成文件的 owner、consumer、生命周期和维护触发 |
| Work orders | `production/work-orders/` | D-director 落盘指令和 verdict |
| Active state | `production/session-state/active.md` | A-producer 项目焦点、注册窗口和活跃工单队列 |
| Lane state | `production/session-state/windows/*.md` | 各窗口恢复状态 |
| Canon | `production/project-canon.md` | D-director 维护的项目正典 |

## Active Production Model

CFG 当前生产模型不是 Epic / Story / Sprint。

```text
A-producer queue
  -> D-director work order
  -> A/B/C lane execution
  -> evidence in reports/captures/tests/handoff
  -> D-director verdict
  -> canon or next work order when needed
```

旧 `sprint-plan`、`dev-story`、`story-done`、`smoke-check` 已从核心动线移除。
不要创建 `production/epics/`、`production/sprints/` 或
`production/sprint-status.yaml` 作为生产状态源。

## Core Skills

| Skill | Group | Boundary |
|---|---|---|
| `/start` | orientation | 首次引导、旧项目接入、初始 A-producer lane |
| `/help` | orientation | 读取 route/workflow/window state 后推荐下一步 |
| `/window-cfg` | maintenance | lane 启动/恢复/审计/压缩/checkpoint/research worktree |
| `/skill-create-cfg` | maintenance | Skill 新增/修改/删除/路由/spec/生成物安全治理 |
| `/setup-engine` | architecture | Godot 版本、工具路径、技术偏好、最小测试基础 |
| `/brainstorm` | design | 概念、核心循环、原型方向 |
| `/design-system` | design | GDD、systems index、设计审查、一致性和平衡 |
| `/art-bible` | design/art | 美术圣经、资产规格、UX 规格、资产检查 |
| `/create-architecture` | architecture | 有消费者的架构基线、ADR、架构影响审计、control manifest |
| `/code-review` | implementation review | 代码质量、架构漂移、性能、安全、技术债 |
| `/bug-report` | production support | 缺陷记录、复现、分级和修复分流 |
| `/gate-check` | readiness | 阶段推进、里程碑和 vertical-slice readiness 判定 |
| `/release-checklist` | release | 发布、上线、补丁、changelog、localization |

Optional project Skills can be added through `/skill-create-cfg` when a reusable project-specific method becomes stable. Public CFG does not ship project-specific art recipes.

## Non-Negotiable Boundaries

- A-producer owns queue, sequencing, active project state.
- D-director owns work orders, verdicts, canon, player-facing acceptance.
- B-dev owns runtime/code/scenes/tests/implementation reports.
- C-art owns visual execution/assets/captures/visual reports.
- Z-platform owns Skills, hooks, route index, workflow docs, tooling guardrails.
- Execution lanes may produce evidence, but cannot self-certify final
  player-facing acceptance.
- Work orders must include Scope, Non-scope, Delivery Spec, Stop Conditions, and
  Return Path.
- Skill-generated files must have owner, consumer, lifetime, update trigger,
  stale condition, directory, enforcer, and conflict-risk judgment.
- Durable generated files must match `.codex/docs/generated-artifact-governance.md`.

## Skill Governance

Every Skill change goes through `/skill-create-cfg`.

Required decisions:

1. Is this `NEW`, `MODIFY`, `REWRITE`, `MERGE`, `DELETE`, `ROUTE-ONLY`,
   `REFERENCES-ONLY`, or `BLOCKED`?
2. Which lane/stage owns it?
3. Which upstream files does it read?
4. Which downstream files does it write?
5. Who consumes and maintains those files?
6. Does it create a second source of truth?
7. Which route/workflow/hook/spec/docs surfaces must change?

If these answers are unclear, the Skill does not enter CFG.

## Hooks

| Hook | Role |
|---|---|
| `session-start.sh` | Emits compact project context and dirty-worktree warning |
| `detect-gaps-lite.sh` | Reports obvious missing route artifacts |
| `dangerous-command-policy.sh` | Blocks obvious destructive commands |
| `skill-change-reminder.sh` | Reminds `/skill-create-cfg` after Skill edits |
| `post-compact-restore.sh` | Reminds recovery from `active.md` and lane files |
| `.githooks/pre-commit` | JSON blocking plus owner-domain/lane reminders |
| `.githooks/pre-push` | Blocks direct push to protected branches |

Hooks are guardrails, not the whole safety system. Durable correctness lives in
file ownership, work-order flow, and Skill governance.
