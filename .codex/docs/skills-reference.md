# Available Skills

Codex Game Studios Godot keeps a small set of real slash commands. Older CCGS micro-skills were folded into these core entries so the `/` menu stays readable.

## Daily Navigation

| Command | Purpose |
|---|---|
| `/start` | New project, existing project adoption, or full re-orientation |
| `/help` | Read current project state and recommend one next step |
| `/window-ccgs` | Start, recover, update, audit, or compact multi-window lanes |
| `/skill-create-ccgs` | Create, merge, modify, delete, route, and test CCGS Skills |

## Design And Architecture

| Command | Purpose |
|---|---|
| `/setup-engine` | Pin Godot version, language, tools, and engine references |
| `/brainstorm` | Shape game concept, pillars, loop, and prototype direction |
| `/design-system` | Write and revise system GDDs; includes system mapping, light design, design review, consistency, and balance checks |
| `/art-bible` | Visual identity, asset specs, asset audit, UX specs, and UX review |
| `/create-architecture` | Architecture document, ADRs, architecture review, and control manifest |

## Production

| Command | Purpose |
|---|---|
| `/sprint-plan` | Epics, stories, estimates, sprint plans, scope, status, and retrospectives |
| `/dev-story` | Implement a ready story, including a small readiness preflight |
| `/story-done` | Verify acceptance criteria, deviations, and test evidence |
| `/code-review` | Review code quality, architecture drift, security, tech debt, and performance concerns |

## QA And Release

| Command | Purpose |
|---|---|
| `/smoke-check` | QA plan, smoke tests, regression, test helpers, flaky tests, playtest and soak evidence |
| `/bug-report` | Bug report, triage, and hotfix routing |
| `/gate-check` | Phase gate, milestone, and vertical-slice readiness judgement |
| `/release-checklist` | Release checklist, launch checklist, changelog, patch notes, localization, day-one patch, and release team coordination |

## Legacy Names

If a user mentions an old command such as `/patch-notes`, `/story-readiness`, `/asset-spec`, or `/window-start-ccgs`, route it through `.codex/docs/skill-route-index.yaml` to the corresponding core command. Do not ask the user to learn the old command set.
