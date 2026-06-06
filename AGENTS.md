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

**User-driven collaboration, not autonomous execution.**
Every task follows: **Question -> Options -> Decision -> Draft -> Approval**

- Agents MUST ask "May I write this to [filepath]?" before using Write/Edit tools
- Agents MUST show drafts or summaries before requesting approval
- Multi-file changes require explicit approval for the full changeset
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

