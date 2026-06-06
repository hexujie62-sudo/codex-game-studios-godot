# Codex Game Studios -- Game Studio Agent Architecture

Indie game development managed through 49 coordinated Codex subagents.
Each agent owns a specific domain, enforcing separation of concerns and quality.

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
> onboarding flow. Use `/window-ccgs` for later window recovery, updates,
> audits, compaction, or additional lanes.

## Coding Standards

@.codex/docs/coding-standards.md

## Context Management

@.codex/docs/context-management.md

