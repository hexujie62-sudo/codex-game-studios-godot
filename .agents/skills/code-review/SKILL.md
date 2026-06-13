---
name: code-review
description: "对指定文件或文件集执行架构和质量的代码审查。检查编码标准合规性、架构模式遵守情况、可测试性、性能和安全风险。"
argument-hint: "[path-to-file-or-directory] [optional work-order-or-ADR path]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, AskUserQuestion
model: sonnet
---

# Code Review

`/code-review` 是 CFG 的代码质量入口。它是只读审查，不修改文件。

It also covers former technical-debt, perf-profile, and security-audit concerns when the concern is tied to code or architecture changes.

For broad release readiness, route to `/release-checklist`. For runtime evidence failures, route to `B-dev` through the active work order and lane state. Do not route to removed sprint/story/smoke commands.

## Required Context

Read:

- target files in full
- `AGENTS.md`
- `.codex/docs/technical-preferences.md`
- relevant `docs/architecture/*.md`
- relevant `production/work-orders/*.md` if the user provided one or the touched paths clearly belong to one
- relevant B-dev evidence/report if present

If a work order path is supplied, read it first to extract:

- scope and non-scope
- delivery spec
- stop conditions
- evidence requirements
- ADR/canon references

If no work order or ADR is found, say so and continue with a code-only review.

## CFG Specialist Policy

The inherited 49 CCGS agent files are not active. Do not read `.codex/agents/`. Apply engine, shader, UI, architecture, security, performance, and testability lenses directly in-session.

## Review Checklist

### Work Order Compliance

- implementation stays inside Scope and Non-scope
- delivery spec is satisfied or gaps are named
- stop conditions were not ignored
- evidence hooks or validation paths exist

### ADR And Architecture Compliance

- referenced ADRs are followed
- implementation does not contradict accepted architecture
- Godot node/resource/autoload ownership is clear
- signals/events do not create hidden circular dependencies
- save/load, input, physics, and scene lifecycle obey project rules

### Standards

- methods/classes have appropriate names and comments where useful
- complexity is reasonable
- dependencies are explicit
- configuration values are data/config driven when appropriate
- generated/imported assets are not treated as source logic

### Testability And Evidence

- B-dev can validate the change with an available command, scene, test, capture, or manual step
- important behavior has an observable runtime path
- acceptance criteria from the work order are testable
- no new edge case is introduced without evidence or follow-up owner

### Performance And Safety

- no avoidable allocations in hot paths
- frame-rate and physics timing are handled correctly
- file IO, save data, networking, and external data are validated
- error states fail clearly rather than silently corrupting state

## Output

Findings first, ordered by severity. Use file/line references.

```text
## Code Review: [target]

Findings:
- [P0/P1/P2/P3] [file:line] [issue, impact, required fix]

Open Questions:
- [only if needed]

Work Order / ADR Compliance:
- [COMPLIANT / DRIFT / VIOLATION / NOT PROVIDED]

Testability:
- [TESTABLE / GAPS / BLOCKING / N/A]

Summary:
- [short change/context summary]

Verdict: APPROVED / APPROVED WITH CONCERNS / CHANGES REQUIRED
```

If no issues are found, say that clearly and mention residual risk or unrun tests.

## Next Step

After the review:

- If approved and tied to an active work order, hand back to the owning lane for delivery/verdict.
- If changes are required, route to `B-dev` for code fixes.
- If architecture is wrong or missing, route to `/create-architecture`.
- If the issue affects player-facing feel, visual quality, or canon, request `D-director` verdict.

Do not ask the user to run removed story/sprint completion commands.
