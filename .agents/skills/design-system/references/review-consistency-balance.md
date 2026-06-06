# Review, Consistency, And Balance Reference

Use this reference when `/design-system` is reviewing GDDs, scanning cross-GDD
consistency, maintaining the entity registry, or checking balance. Do not read
archived old Skills.

## Single GDD Review

Use for a fresh-session review of one GDD. Never self-approve a GDD in the same
session that authored it.

Read:

- Target `design/gdd/[system].md`.
- `design/gdd/game-concept.md`.
- `design/gdd/systems-index.md`.
- Upstream/downstream dependency GDDs.
- Prior review log:
  `design/gdd/reviews/[doc-name]-review-log.md` if present.
- `.codex/docs/technical-preferences.md` for engine context.

Check:

- Required sections present: Overview, Player Fantasy, Detailed Design/Rules,
  Formulas, Edge Cases, Dependencies, Tuning Knobs, Acceptance Criteria.
- Section content is specific and testable.
- Dependencies are bidirectional.
- Formulas define variables, ranges, and edge cases.
- Acceptance criteria use measurable Given/When/Then style.
- UI/Visual/Audio requirements are routed to `/art-bible` where needed.
- Implementation details belong in `/create-architecture`, not the GDD.

Report:

```markdown
## Design Review: [Document Title]

### Completeness: [X/8 sections present]
### Dependency Graph
### Required Before Implementation
### Recommended Revisions
### Nice-to-Have
### Scope Signal
### Verdict: [APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED]
```

After approval, ask separately before updating:

- `design/gdd/systems-index.md` status.
- `design/gdd/reviews/[doc-name]-review-log.md`.

Review log entry:

```markdown
## Review — [YYYY-MM-DD] — Verdict: [APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED]

### Blocking Items
### Recommended Revisions
### Notes
```

## Cross-GDD Review

Use when two or more system GDDs exist and the user asks for holistic design
review, cross-review, or phase readiness support.

Read:

- `design/gdd/game-concept.md`
- `design/gdd/systems-index.md`
- all system GDDs excluding `game-concept.md`, `systems-index.md`, and
  `game-pillars.md`
- `design/registry/entities.yaml` if present

Check:

- Dependency bidirectionality.
- Rule contradictions.
- Stale references.
- Data/tuning ownership conflicts.
- Formula compatibility between upstream outputs and downstream inputs.
- Acceptance criteria across systems.
- Dominant progression loop.
- Attention budget and cognitive load.
- Dominant strategy risk.
- Economy/progression positive feedback.
- Difficulty curve consistency.
- Pillar alignment and player fantasy coherence.
- Cross-system scenario walkthroughs.

Output:

```text
design/gdd/gdd-cross-review-[date].md
```

Verdicts:

- `PASS`: no blocking issues; warnings do not block architecture.
- `CONCERNS`: warnings should be resolved but do not block.
- `FAIL`: blocking issues must be resolved before architecture begins.

Ask before writing the report and before marking flagged systems as
`Needs Revision` in `systems-index.md`.

## Consistency Registry Check

Use for focused consistency scans and registry maintenance.

Registry path:

```text
design/registry/entities.yaml
```

Registry maps:

- entities
- items
- formulas
- constants

Grep-first process:

1. Read the registry once.
2. Find GDDs that mention each registered name.
3. Compare values, variables, output ranges, constants, and ownership.
4. Deep-read only files with possible conflicts.

Findings:

- `CONFLICT`: same named fact has different values.
- `STALE REGISTRY`: source GDD changed but registry did not.
- `UNVERIFIABLE`: reference exists but cannot be checked.
- `CLEAN`: registry and GDD agree.

If stale entries or new facts are found, ask before updating
`design/registry/entities.yaml`. Never delete registry entries; set
`status: deprecated` when needed.

Append recurring conflicts to:

```text
docs/consistency-failures.md
```

Verdict: `PASS`, `CONFLICTS FOUND`, `COMPLETE`, or `BLOCKED`.

## Balance Check

Use only when actual balance data, formulas, or config exists. Do not invent
balance findings from taste.

Read:

- `assets/data/**`
- `design/balance/**`
- relevant `design/gdd/*.md`

Domains:

- combat
- economy
- progression
- loot
- UI feedback timing if data-driven

Report:

```markdown
# Balance Check: [System Name]

## Data Sources Analyzed
## Health Summary: [HEALTHY / CONCERNS / CRITICAL ISSUES]
## Outliers Detected
## Degenerate Strategies Found
## Progression Analysis
## Recommendations
## Values That Need Attention
```

Optional output:

```text
design/balance/balance-check-[system]-[date].md
```

If a proposed fix changes a GDD tuning knob or ADR assumption, run the Design
Change Impact Flow from `references/system-index-patch-impact.md` before treating
the change as settled.
