# Systems Index, Quick Patch, And Change Impact Reference

Use this reference when `/design-system` is creating the systems index, handling
a small design patch, or checking downstream impact after a GDD change. Do not
read archived old Skills.

## Systems Index Flow

Use when `design/gdd/systems-index.md` is missing, the user asks to map systems,
or the user asks for the next system.

Read:

- `design/gdd/game-concept.md`; if missing, stop and ask the user to run
  `/brainstorm`.
- Existing `design/gdd/systems-index.md` if present, to resume.
- Existing `design/gdd/*.md` to avoid duplicating systems already designed.

Produce `design/gdd/systems-index.md` with:

- System name.
- Category.
- Layer: Core / Support / Meta / Content / UI / Audio / Technical.
- Priority.
- Dependencies and dependents.
- Design order.
- Status: `Not Started`, `Designed`, `In Review`, `Approved`, or
  `Needs Revision`.
- Design doc path.
- Visual/UX/Audio flags where art bible or UX specs will be required.

Flow:

1. Extract explicit systems from the concept.
2. Identify implicit systems needed by the core loop, UI, progression, content,
   save/load, input, audio, and feedback.
3. Present the proposed system list to the user before writing.
4. Map dependencies and detect circular dependencies.
5. Assign priorities from MVP relevance, pillar importance, dependency position,
   and risk.
6. Ask:

```text
May I write the systems index to `design/gdd/systems-index.md`?
```

Verdict: `COMPLETE` when written, `BLOCKED` if the user declines the write.

## Quick Design Patch Flow

Use for changes too small for a full GDD but too important to leave as chat.

Output:

```text
design/quick-specs/[kebab-case-title]-[YYYY-MM-DD].md
```

Classify the change:

- Tuning change.
- Rule tweak.
- Small addition.
- UI/UX copy or flow adjustment.
- Asset/audio feedback note.
- New small system.
- Too large: redirect to full `/design-system [system-name]`.

Required reads:

- `design/gdd/systems-index.md` if it exists.
- Relevant `design/gdd/*.md`.
- Existing `design/quick-specs/` touching the same system.

Minimum sections:

- Change summary.
- Motivation.
- Design delta or new rules/values.
- Affected systems.
- Acceptance criteria.
- GDD update required? yes/no with reason.

Ask before writing:

```text
May I write this Quick Design Spec to `design/quick-specs/[name]-[date].md`?
```

If the patch changes a tracked system, ask separately before updating
`design/gdd/systems-index.md`.

Verdicts: `COMPLETE`, `REDIRECTED`, or `BLOCKED`.

## Design Change Impact Flow

Use when an approved GDD changed and architecture or stories may now be stale.

Input: changed GDD path, usually `design/gdd/[system].md`.

Read:

- The changed GDD.
- Previous version from git history when available.
- All `docs/architecture/adr-*.md`.
- `docs/architecture/architecture-traceability.md` if present.
- Relevant stories if the project has generated implementation stories.

Analyze changed sections:

- New rule.
- Removed rule.
- Formula modified.
- Dependency changed.
- Acceptance criteria changed.
- Visual/UX/audio requirement changed.

Classify affected ADRs:

| Status | Meaning |
|---|---|
| Still Valid | GDD change does not affect the ADR decision |
| Needs Review | Human judgment needed; ADR may need revision |
| Likely Superseded | GDD now contradicts the ADR assumption |

Output:

```text
docs/architecture/change-impact-[date]-[system-slug].md
```

Include:

- Change summary.
- ADRs loaded.
- Not affected.
- Needs review.
- Likely superseded.
- Traceability updates needed.
- Follow-up actions for `/create-architecture`.

Ask before each write:

- Update ADR status to `Superseded by ADR-[next] (pending ...)`.
- Update traceability index.
- Write the change impact document.

Never delete ADR content. Non-destructive status notes only.

Verdict: `COMPLETE` when the report is saved, `BLOCKED` if the user declines
required writes.
