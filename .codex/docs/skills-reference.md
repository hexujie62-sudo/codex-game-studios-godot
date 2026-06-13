# Available Skills

CFG keeps a small set of real Skill entries. Deleted or renamed commands must
not remain as half-active workflow surfaces.

## Daily Navigation

| Command | Purpose |
|---|---|
| `/start` | New project, existing project adoption, or full re-orientation |
| `/help` | Read current project state and recommend one next step |
| `/window-cfg` | Start, recover, update, audit, or compact multi-window lanes |
| `/skill-create-cfg` | Create, modify, merge, delete, route, test, and audit Skills, including generated-artifact safety |

## Design And Architecture

| Command | Purpose |
|---|---|
| `/setup-engine` | Pin Godot version, language, tools, and engine references |
| `/brainstorm` | Shape game concept, pillars, loop, and prototype direction |
| `/design-system` | Write and revise system GDDs; includes system mapping, light design, design review, consistency, and balance checks |
| `/art-bible` | Visual identity, asset specs, asset audit, UX specs, and UX review |
| `/create-architecture` | CFG architecture baseline, ADRs, architecture review, and control manifest when architecture boundaries change |

## Production And Review

| Command | Purpose |
|---|---|
| `/code-review` | Review code quality, architecture drift, security, tech debt, and performance concerns |
| `/bug-report` | Bug report, triage, and hotfix routing |
| `/gate-check` | Phase gate, milestone, and vertical-slice readiness judgement |
| `/release-checklist` | Release checklist, launch checklist, changelog, patch notes, localization, day-one patch, and release team coordination |

Production execution is work-order driven:

- A-producer maintains the active work-order queue in `production/session-state/active.md`.
- D-director owns `production/work-orders/` and `production/project-canon.md`.
- B-dev and C-art execute assigned work-order sections in their owner paths and report evidence through lane handoffs.

## Removed Names

Do not route deleted or renamed commands to phantom replacements. The current
daily navigation commands are the commands listed above.
