# Godot Test Foundation Reference

Use this reference when `/setup-engine` needs to scaffold or verify the minimal
Godot test foundation. Do not read archived old Skills.

## Absorption Map

| Old Skill | Core value preserved |
|---|---|
| `test-setup` | Godot test paths, runner expectations, helper folder, CI/test command wiring |

## Required Foundation

Minimum paths:

- `tests/`
- `tests/unit/`
- `tests/integration/`
- `tests/helpers/`
- optional `tests/gdunit4_runner.gd`
- `tests/README.md`

Record test paths and Godot command in `.codex/docs/technical-preferences.md`.

## Godot Runtime Check

Use the pinned console executable from `AGENTS.md` or
`.codex/docs/technical-preferences.md`.

If Godot is missing or cannot run, report `CONCERNS` and route QA execution to
manual verification until setup is fixed.

## Helper Boundary

Test helpers belong under `tests/helpers/`. They may create scenes/resources for
tests but must not become production dependencies. Ask before creating or
updating test files.

Verdict: `COMPLETE` when Godot version, technical preferences, reference file,
and minimal test paths are ready; `BLOCKED` when version/tool path cannot be
resolved and the user declines to provide it.
