---
name: create-architecture
description: "Godot 架构主入口。用于在架构边界、ADR、实现约束、Godot API 风险、代码/设计分歧或 work order 需要技术约束时，编写或审查有消费者的架构产物；不得生成无人维护的 architecture、traceability 或 control manifest 文件。"
argument-hint: "[自然语言目标：blueprint / ADR / review / control manifest / retrofit]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash, AskUserQuestion
model: sonnet
---

# Create Architecture

`/create-architecture` 是 CFG 的 Godot 架构入口。它把已批准的设计、技术偏好和当前生产目标翻译成可执行的架构约束。

它不再服务 Epic/Story/Sprint 动线。架构产物只有在被 work order、lane handoff、code review、gate check 或项目维护规则实际消费时才应该生成或更新。

Capability areas:

- architecture blueprint
- ADR authoring
- architecture review
- control manifest
- traceability review
- Godot API risk review

## CFG Specialist Policy

继承的 49 个 CCGS agent 不属于当前项目架构。不要读取 `.codex/agents/`，不要模拟旧专家团。架构、Godot 可行性、测试可达性和控制清单是本 Skill 在当前上下文内应用的专业视角。

跨线玩家体验、视觉质量、canon 冲突交给 `D-director`。实现可行性和 runtime evidence 由 `B-dev` 提供；必要时由 D 或 A 写入新的 work order。

## Reference Loading Rules

Do not read `.agents/skills-archive/` during normal use.

Read `references/adr-review-control.md` only when the request involves ADR authoring/review, control manifest, stale ADR checks, traceability review, or Godot-specific risk review.

Full blueprint authoring can run from this `SKILL.md` after loading project context.

## Artifact Governance

Read `.codex/docs/generated-artifact-governance.md` before writing any durable
architecture artifact.

Before creating or updating any architecture-generated file, state its lifecycle:

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

Rules:

- `docs/architecture/architecture.md` is rolling architecture context. Owner: architecture lane or A-appointed technical owner. Consumers: B-dev, code-review, gate-check.
- ADRs are source-of-truth decisions. Owner: architecture lane/A-appointed owner. Consumers: B-dev, code-review, gate-check.
- `docs/architecture/control-manifest.md` is an implementation constraint index. Generate it only if B-dev or work orders will actually consume it. It must list update triggers.
- Traceability files are rolling indexes. Do not create them as decorative completeness artifacts. If generated, they must name the source GDDs/ADRs and the next maintenance trigger.
- Do not require a fixed minimum ADR count. ADRs exist only for real architecture decisions.
- Do not create architecture review reports, RTM, TR registry, or traceability
  indexes unless the requester needs a durable report or a downstream consumer
  is named.

If a generated file would not be maintained or consumed, do not generate it.
Report the gap instead and return `CONCERNS` or `BLOCKED`.

## Phase 1: Classify The Request

Classify natural language into one path:

- **Blueprint**: create/update `docs/architecture/architecture.md`.
- **ADR**: create/update `docs/architecture/adr-NNNN-[slug].md`.
- **Review**: audit existing architecture/ADRs for coverage, conflicts, staleness, or Godot risk.
- **Control manifest**: create/update `docs/architecture/control-manifest.md` from accepted decisions.
- **Retrofit**: align existing code/docs with current architecture expectations.
- **Risk review**: inspect one Godot API/domain risk against engine references.

If the task arrives through a route-index alias, run the corresponding path here
and report the current command as `/create-architecture`.

## Phase 2: Load Context

Read only what exists and is relevant:

- `AGENTS.md`
- `.codex/docs/generated-artifact-governance.md`
- `.codex/docs/technical-preferences.md`
- `docs/engine-reference/godot/VERSION.md`
- `project.godot`
- `design/gdd/game-concept.md`
- `design/gdd/systems-index.md`
- relevant `design/gdd/*.md`
- `design/art/art-bible.md` when art/UI/asset constraints affect architecture
- existing `docs/architecture/*.md`
- relevant `production/work-orders/*.md`
- `production/project-canon.md` only when canon/player-facing constraints affect the decision

If Godot version is unknown and the task needs engine-specific architecture, stop and route to `/setup-engine`.

## Phase 3: Draft The Architecture Package

For blueprint/control-manifest/traceability work, present one package before writes:

- scope of architecture being decided
- input documents read
- outputs to write/update
- artifact lifecycle contract for each output
- named consumer for each durable output
- key module ownership decisions
- Godot-specific risks and verification source
- open questions and deferred decisions
- impact on B-dev/C-art/D/A lanes

Ask once for approval of the package. After approval, write all low-risk files named in that package without repeated per-file confirmations.

For ADRs, show the ADR draft first, then ask once to write.

For reviews, stay read-only unless the user explicitly asks to write a report or
a downstream lane needs durable evidence.

## Blueprint Minimum Content

`docs/architecture/architecture.md` should contain only architecture that will guide work:

- document status and owner
- engine/version assumptions
- systems covered
- module ownership
- scene/node/resource boundaries
- data/event/signal flow
- save/load and persistence boundaries if relevant
- public interfaces or invariants B-dev must honor
- accepted ADR links
- open questions with owner and resolution path
- maintenance triggers

Do not fill template sections that are not relevant to the current project.

## ADR Minimum Content

Each ADR must include:

- status: Proposed / Accepted / Superseded / Rejected
- context
- decision
- consequences
- alternatives considered
- Godot/version compatibility
- GDD/work-order requirements addressed
- maintenance trigger

Accepted ADRs can block implementation. Proposed ADRs are planning evidence, not final law.

## Control Manifest Minimum Content

Only create/update `docs/architecture/control-manifest.md` when it will be consumed by B-dev, code-review, gate-check, or a named work order.

Minimum sections:

- source ADRs and architecture docs
- implementation rules B-dev must follow
- forbidden patterns
- owner lane for each rule
- update trigger
- consuming work orders or review paths

## Review Checklist

When reviewing architecture, check:

- Godot version/tooling is consistent.
- module ownership is clear enough for implementation.
- ADRs do not conflict.
- accepted decisions still match GDD/canon/work-order scope.
- generated indexes are being maintained by a named owner.
- generated artifacts match `.codex/docs/generated-artifact-governance.md`.
- no old Epic/Story/Sprint artifact is treated as active state.
- B-dev can implement without inventing architecture mid-task.
- D-director verdict is required when architecture changes player-facing feel, visual language, or canon.

## Handoff

Close with:

```text
Architecture result:
- Written/updated: [paths]
- Owner: [lane]
- Consumers: [lanes/skills]
- Maintenance trigger: [trigger]
- B-dev impact: [summary]
- C-art impact: [summary]
- D/A decision needed: [yes/no + why]
- Next: [one command or lane handoff]

Verdict: COMPLETE / CONCERNS / BLOCKED
```

Recommended next steps must use active CFG routes: `/window-cfg`, `/code-review`, `/gate-check`, `/design-system`, `/art-bible`, or another existing Skill. Do not recommend removed sprint/story/smoke commands.

