# Codex Game Studios - Workflow Guide

This guide explains the current Codex-first, Godot-focused CCGS workflow. It is
the public workflow guide for the slim 17 core Skill set.

The authoritative machine-readable workflow lives in
`.codex/docs/workflow-catalog.yaml`. Use `/help` when you want Codex to inspect
the project and recommend the next step from current files.

---

## Core Commands

| Area | Commands |
|---|---|
| Navigation | `/start`, `/help`, `/window-ccgs`, `/skill-create-ccgs` |
| Design | `/brainstorm`, `/design-system`, `/art-bible` |
| Technical setup | `/setup-engine`, `/create-architecture` |
| Production | `/sprint-plan`, `/dev-story`, `/code-review`, `/story-done` |
| QA and release | `/smoke-check`, `/bug-report`, `/gate-check`, `/release-checklist` |

Older CCGS micro-skills are compatibility names. If a user mentions an old
command, route it through `.codex/docs/skill-route-index.yaml` to the current
core command instead of reviving the old command.

---

## Quick Start

Start a new project or recover orientation:

```text
/start
```

`/start` checks lane state first. If no lane exists, it can create the initial
`A-producer` lane, then continues onboarding.

Ask for the next best action:

```text
/help
```

Start or resume a lane:

```text
/window-ccgs A
/window-ccgs B
/window-ccgs C
/window-ccgs D
/window-ccgs Z
```

Codex refreshes the active lane state before closing, switching tasks, or
compacting context. You do not need to run a separate update/handoff command.

Create a checkpoint plan when the current work is a useful rollback unit:

```text
/window-ccgs checkpoint B
```

---

## Multi-Window Lanes

Default lanes:

| Lane | Responsibility |
|---|---|
| `A` | Producer control, scope, priorities, cross-window coordination |
| `B` | Godot development, stories, code, tests |
| `C` | Art, assets, visual identity, UX artifacts |
| `D` | QA, smoke checks, bugs, release evidence |
| `Z` | Platform customization, Skills, Hooks, docs, route index, test framework |

Lane state lives in `production/session-state/windows/`. Long-lived state belongs
in the lane file. Handoffs are recovery points, not full chat transcripts.

Use:

```text
/window-ccgs audit
```

to check lane registry drift, stale handoffs, and active-file conflicts.

---

## Checkpoints And Research Worktrees

Commits are recovery checkpoints. A good checkpoint has one lane owner, an
explicit file list, a clear verification note, and a rollback command.

Checkpoint plans must not use `git add .`. They should stage only named files
and include these body fields:

```text
Lane: <lane-id>
Scope: <what changed>
Verification: <checks run or not run>
Rollback: git revert <sha>
```

Default policy is to recommend commits, not make them silently. Automatic
checkpoint commits require explicit lane policy such as `auto_checkpoint: true`
and a clean `/window-ccgs audit`.

Use research worktrees for uncertain directions:

```text
/window-ccgs research Z skill-experiment
/window-ccgs merge Z
```

Research branches use the `codex/research/...` prefix and separate worktrees so
one window does not switch the branch under another window. Clean-only auto-merge
is allowed only when the lane records that policy and preflight passes.

---

## Phase Flow

### 1. Concept

Goal: turn a fuzzy idea into a documented game concept.

Typical commands:

```text
/brainstorm
/setup-engine
/art-bible
/design-system
/gate-check systems-design
```

Core artifacts:

- `design/gdd/game-concept.md`
- `.codex/docs/technical-preferences.md`
- `design/art/art-bible.md`
- `design/gdd/systems-index.md`

### 2. Systems Design

Goal: define the major game systems and their GDDs.

Typical commands:

```text
/design-system
/gate-check technical-setup
```

Use `/design-system` for system mapping, full GDD authoring, design review,
consistency checks, balance checks, and design change impact.

### 3. Technical Setup

Goal: convert design into architecture decisions and implementation rules.

Typical commands:

```text
/create-architecture
/setup-engine
/gate-check pre-production
```

Core artifacts:

- `docs/architecture/architecture.md`
- `docs/architecture/adr-*.md`
- `docs/architecture/tr-registry.yaml`
- `docs/architecture/control-manifest.md`

### 4. Pre-Production

Goal: prove the core loop, prepare UX/assets, create epics, and plan the first
sprint.

Typical commands:

```text
/art-bible
/brainstorm prototype
/sprint-plan
/smoke-check
/gate-check production
```

Use `/sprint-plan` for epics, stories, estimates, first sprint planning, scope
checks, sprint status, and retrospectives.

### 5. Production

Goal: implement stories in small verifiable units.

Story loop:

```text
/dev-story <story-path>
/code-review <changed-files>
/story-done <story-path>
```

`/dev-story` includes the old readiness preflight behavior. It should verify the
story, load GDD/TR/ADR/control-manifest context, route implementation to the
right specialist, and write tests where required. It does not mark the story
Complete; `/story-done` owns closure.

Run:

```text
/smoke-check sprint
```

when sprint QA evidence is needed.

### 6. Polish

Goal: stabilize feel, performance, bugs, balance, and release evidence.

Typical commands:

```text
/code-review
/design-system
/art-bible
/smoke-check
/bug-report
/gate-check release
```

Performance, security, and technical debt concerns enter through `/code-review`
when tied to code or architecture. Playtest, regression, soak, and QA evidence
enter through `/smoke-check`.

### 7. Release

Goal: prepare a public or player-facing release.

Typical commands:

```text
/release-checklist
/smoke-check
/bug-report
/gate-check release
```

`/release-checklist` absorbs launch checklist, patch notes, changelog,
localization, day-one patch, and release coordination behavior.

---

## Review Policy

This fork uses fixed Lean review policy.

- Users do not choose `full`, `lean`, or `solo`.
- Active Skills do not parse `--review`.
- Active Skills do not read, create, or normalize `production/review-mode.txt`.
- `/gate-check` owns formal phase-gate review.
- Other Skills use internal checks, evidence review, and handoffs to the owning
  core command.

---

## Skill Governance

Use:

```text
/skill-create-ccgs
```

for Skill creation, updates, deletion, route changes, test spec updates, and
workflow insertion.

The governance flow checks:

- `.agents/skills/<skill>/SKILL.md`
- `CCGS Skill Testing Framework/catalog.yaml`
- `CCGS Skill Testing Framework/skills/...`
- `.codex/docs/skill-route-index.yaml`
- `.codex/docs/workflow-catalog.yaml`
- related Hook or documentation impact

Avoid adding a new Skill when the responsibility can be absorbed into an
existing core Skill, a route alias, or a direct reference file.

---

## Repository Boundary

This workflow kit can live inside a working game repository, but the public
framework package is framework-only. Private project content such as `design/`,
`production/session-state/`, `prototypes/`, `src/`, local machine context, and
credentials belongs to the local game project, not to the public framework kit.

---

## Practical Rules

- Ask before writing files unless a Skill explicitly documents a narrow silent
  state update.
- Keep long-lived context in lane state files, not chat transcripts.
- Run `/window-ccgs audit` before multi-lane checkpoints or research merges.
- Use `/window-ccgs checkpoint <lane-id>` when changes form a useful rollback
  unit.
- Use `/help` instead of guessing when the next workflow step is unclear.
