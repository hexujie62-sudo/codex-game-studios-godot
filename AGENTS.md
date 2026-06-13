# CFG Runtime Charter

CFG is this project's active Codex operating framework. It is a deep-modified
version of CCGS. `/window-cfg` is the current multi-window entry, and
`/skill-create-cfg` is the current Skill governance entry. `docs/ccgs-*` are
historical document paths that still host active CFG documentation.

This file is the stable runtime entrypoint for Codex in this repository. It
defines durable operating rules and links to authoritative sub-systems. It does
not contain mutable project canon, current work orders, lane handoffs, or
director verdict methods.

The inherited 49 CCGS studio agents have been removed from the project layer and
archived outside the repository. CFG does not simulate a 49-person studio by
default. Future specialist perspectives must be added back only when there is a
real need, as a Skill, a narrow agent, or another explicit tool.

## Technology Stack

- **Engine**: Godot 4.6.2
- **Language**: GDScript
- **Version Control**: Git with trunk-based development
- **Build System**: SCons (engine), Godot Export Templates
- **Asset Pipeline**: Godot Import System + custom resource pipeline

## Local Tool Paths

- Set your local Godot executable path in AGENTS.local.md or update this section after cloning.
- For command-line export and headless tasks, use your local Godot console executable.

## Shell Tooling

- Use PowerShell 7+ (`pwsh`); avoid WindowsApps/MSIX launch targets when they cause shell issues.
- For complex PowerShell with `$`, `$_`, regex, or backticks, avoid nested double-quoted `-Command "..."`; use single-quoted `-Command '...'`, simpler commands, or a script file.

> **Note**: Engine-specialist agents exist for Godot, Unity, and Unreal with
> dedicated sub-specialists. Use the set matching your engine.

## Project Structure

@.codex/docs/directory-structure.md

## Engine Version Reference

@docs/engine-reference/godot/VERSION.md

## Technical Preferences

@.codex/docs/technical-preferences.md

## Coordination Rules

@.codex/docs/coordination-rules.md

## CFG Authority Map

- Project canon: `production/project-canon.md`
- Director verdict method: `.agents/skills/director-review/SKILL.md`
- Work orders: `production/work-orders/`
- CFG operating checklist: `.codex/docs/cfg-operating-checklist.md`
- Multi-window protocol: `.codex/docs/multi-window-workflow.md`
- Skill routing: `.codex/docs/skill-route-index.yaml`
- Generated artifact governance: `.codex/docs/generated-artifact-governance.md`
- Checkpoint policy: `.codex/docs/git-checkpoint-workflow.md`

`D-director` is the cross-line verdict lane for player experience, visual
quality, motion readability, and canon consistency. `A-producer` coordinates
scope, sequence, and records. `B-dev` owns runtime/program evidence, including
current smoke checks; `C-art` owns visual evidence, including screenshots,
compare grids, and visual smoke checks. No separate QA lane is created by
default at this stage.

## User Language Contract / 用户语言契约

任何需要用户/制作人理解、确认或审计的产出,必须使用当前用户语言。范围包括工单、verdict、blocker/request 留言、canon 更新说明、lane handoff 摘要和最终回报。工单虽然由执行窗口读取,但它也是制作人可审计的指令文件,所以同样受此规则约束。代码标识符、参数名、文件路径、shader uniform、引擎 API、commit 技术标识符保留原文拼写。

## Collaboration Protocol

**User-driven collaboration, not micro-approval.**
Every substantial task follows: **Goal -> Scope -> Guided Design Interview -> Detailed Plan/Doc -> Approval -> Execute -> Verify**.

- Agents MUST clarify the user's goal and the production functions Codex should cover for this task, such as engineering, design, art direction, audio, writing, tuning, level design, tools, QA, or operations.
- For design-heavy tasks, Agents MUST preserve deep guided co-design. Run as much interview as the design needs, explain trade-offs and recommendations, and make each question advance direction, landing, tools, risk, or acceptance criteria before drafting the final package.
- Agents MUST turn the agreed scope into a detailed plan or document before execution when the task changes design, architecture, production content, or multiple files.
- Agents SHOULD avoid drip-feed MVP thinking. Define the first complete playable or validation scope with its needed design, tools, assets, tests, risks, and acceptance criteria before building.
- Once the user approves the plan or changeset, Agents SHOULD execute all low-risk writes inside that approved scope without asking again for each small file, directory, or section.
- Agents MUST ask again before going outside the approved scope, making irreversible/destructive changes, publishing, deleting, broad staging, changing branch strategy, or making high-risk architecture/design decisions.
- Multi-file changes require one explicit approval for the full changeset, not repeated per-file approvals.
- Ownership handoff does not remove professional dissent. If another lane or
  agent owns an artifact, development/Z-platform should still raise concerns
  when a requested change risks framework correctness, user experience,
  release safety, privacy, rollback ability, or long-term maintainability.
- No commits without user instruction or an explicit lane checkpoint policy
  recorded in the relevant lane. Checkpoint commits must stage only named files
  and include lane, scope, verification, and rollback information.

See `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md` for full protocol and examples.

> **First session?** Run `/start`. If the project has no lane state yet, `/start`
> bootstraps the initial `A-producer` lane and then continues the guided
> onboarding flow. Use `/window-cfg` for later window recovery, updates,
> audits, compaction, or additional lanes.

## Coding Standards

@.codex/docs/coding-standards.md

## Context Management

@.codex/docs/context-management.md
