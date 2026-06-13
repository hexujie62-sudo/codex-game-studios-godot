# Navigation And Stage Reference

Use this reference when `/help` is explaining current stage, route aliases, or
"what next?" decisions. Do not read archived old Skills.

## Absorption Map

| Old Skill | Core value preserved |
|---|---|
| `onboard` | role/task onboarding summary path and concise next-step guidance |
| `project-stage-detect` | artifact-based stage inference and confidence reporting |

## Stage Signals

Prefer explicit state, then artifact evidence:

1. `production/stage.txt`
2. `production/session-state/active.md`
3. `production/session-state/windows/*.md`
4. `design/gdd/game-concept.md`
5. `design/gdd/systems-index.md`
6. `design/gdd/*.md`
7. `.codex/docs/technical-preferences.md`
8. `docs/architecture/architecture.md`
9. `docs/architecture/control-manifest.md`
10. `production/work-orders/**`
11. `production/dev-tasks/**`
12. `production/design-sync/**`
13. `production/releases/**`

If explicit state conflicts with artifacts, report the conflict and recommend
`/start` for brownfield/stage reconciliation or `/gate-check` for formal phase
readiness. `/help` stays read-only.

## Optional Onboarding Note

When the user asks for a concise handoff for a role or lane, summarize current
stage, objective, active files, safest next command, and blockers.

Optional output if the user explicitly wants a saved note:

```text
production/onboarding/onboard-[role]-[date].md
```

In normal `/help`, do not write it. If the handoff belongs in lane state,
recommend `/window-cfg <lane>` so Codex can take over that lane and refresh its
state automatically.
