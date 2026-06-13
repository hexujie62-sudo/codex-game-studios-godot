# Session State Templates

These templates seed file-backed lane state for new Codex Game Studios projects.

Runtime state belongs in:

```text
production/session-state/
```

Public releases must not include real `production/session-state/` files from a
working project. Those files can contain private project context, local paths,
handoffs, blockers, and publishing history.

Use these templates when bootstrapping a new project:

```text
.codex/templates/session-state/active.md
.codex/templates/session-state/windows/A-producer.md
.codex/templates/session-state/windows/B-dev.md
.codex/templates/session-state/windows/C-art.md
.codex/templates/session-state/windows/D-director.md
.codex/templates/session-state/windows/Z-platform.md
.codex/templates/session-state/windows/custom-lane.md
```

Replacement fields:

```text
<project-name>
<YYYY-MM-DD>
<lane-id>
<lane-title>
<lane-responsibility>
<current-objective>
```

`/start` should create `A-producer` plus `active.md` when no lane state exists.
`/window-cfg <lane-id>` should create additional lanes from the matching
template, or from `custom-lane.md` for custom lane ids.


