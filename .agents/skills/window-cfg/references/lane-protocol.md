# Lane Protocol Reference

Use this reference for `/window-cfg` lane creation, recovery, update, handoff,
audit, and compaction. Do not read archived old Skills.

## Protocol Areas

- Lane id mapping and bootstrap
- Active registry update
- Recovery context
- Scoped lane state refresh
- Handoff replacement rules
- Audit and compaction behavior

## Lane Files

| Lane | File |
|---|---|
| A-producer | `production/session-state/windows/A-producer.md` |
| B-dev | `production/session-state/windows/B-dev.md` |
| C-art | `production/session-state/windows/C-art.md` |
| D-director | `production/session-state/windows/D-director.md` |
| Z-platform | `production/session-state/windows/Z-platform.md` |

Custom lane ids must be `[a-z0-9][a-z0-9-]{0,63}` and write to
`production/session-state/windows/[lane-id].md`.

Creating or renaming a lane must also prepare an update to
`production/session-state/active.md`. A lane file without registry discovery is
not recoverable by hooks or `/help`.

## Update Contract

Before overwriting a `## Handoff` section, migrate still-valid information to
stable lane sections such as Responsibility, Current Objective, Scope, Active
Files, Progress, Decisions, and Blockers. Never let a short handoff erase
long-term lane memory.

## Audit Checks

- Lane files exist for registered lanes.
- Registered lanes point to existing files.
- Active files are not claimed by conflicting lanes without an owner decision.
- Handoff dates are recent enough for active lanes.
- Z-platform owns Skill/hook/route/catalog changes.

Verdicts: `PASS`, `CONCERNS`, or `FAIL`.
