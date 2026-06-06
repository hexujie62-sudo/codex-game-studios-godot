# Brownfield Intake Reference

Use this reference when `/start` is adopting an existing project, detecting the
current stage, or reverse-documenting existing code/prototypes. Do not read
archived old Skills.

## Absorption Map

| Old Skill | Core value preserved |
|---|---|
| `adopt` | adoption plan path, existing-project scans, gap classification, safe stage recommendation |
| `project-stage-detect` | stage artifact scan, stage report path, confidence levels |
| `reverse-document` | turning code/prototypes into concept/GDD/architecture artifacts without pretending they were pre-approved |

## Adoption Plan

Read existing project evidence before recommending a path:

- `AGENTS.md`
- `.codex/docs/technical-preferences.md`
- `project.godot`
- `design/**`
- `docs/architecture/**`
- `production/**`
- `tests/**`
- `src/**`, `scripts/**`, `scenes/**`, `addons/**`
- `prototypes/**`

Classify gaps:

- existence gap: artifact missing.
- format gap: artifact exists but does not match CCGS schema.
- traceability gap: code/design exists but no GDD/ADR/control-manifest link.
- stage mismatch: `production/stage.txt` says one thing while artifacts show another.

Optional output:

```text
docs/adoption-plan-[date].md
```

Ask before writing:

```text
May I write the adoption plan to `docs/adoption-plan-[date].md`?
```

Verdict: `COMPLETE` when the user has a recommended next core Skill,
`CONCERNS` when stage confidence is mixed, `BLOCKED` when required project files
cannot be read.

## Stage Report

Optional output:

```text
production/project-stage-report.md
```

Include detected stage, confidence, evidence found, missing required artifacts,
recommended next core command, and risks if proceeding without missing artifacts.

Ask before writing or updating `production/stage.txt`.

## Reverse Documentation

Use only to document what exists, not to invent missing design intent.

Routes:

- prototype -> concept notes or concept update.
- implemented system -> `design/gdd/[system-name].md` retrofit.
- architecture from code -> `/create-architecture` review/ADR path.

When implementation contradicts design, surface the conflict and ask whether the
source of truth is the code, the design, or an intentional change. Do not
silently rewrite design to match code.
