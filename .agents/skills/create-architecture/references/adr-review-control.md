# ADR, Architecture Review, And Control Manifest Reference

Use this reference for `/create-architecture` ADR authoring, architecture review,
traceability review, stale-ADR checks, RTM output, and control-manifest
generation. Do not read archived old Skills.

## Capability Areas

| Area | Core value |
|---|---|
| ADR authoring | ADR numbering, status values, duplicate/supersede handling, Godot compatibility checks, TR registry updates |
| Architecture review | TR coverage, RTM, conflicting/stale ADR detection, dependency ordering, PASS/CONCERNS/FAIL verdict |
| Control manifest | flat implementation control list, accepted-ADR filtering, work-order/B-dev implementation input, forbidden/required patterns |

Report `/create-architecture` as the active entry.

## Shared Inputs

Read the smallest set needed for the requested architecture task:

- `docs/engine-reference/godot/VERSION.md`
- `docs/engine-reference/godot/breaking-changes.md`
- `docs/engine-reference/godot/deprecated-apis.md`
- relevant `docs/engine-reference/godot/modules/*.md`
- `.codex/docs/technical-preferences.md`
- `design/gdd/systems-index.md`
- relevant `design/gdd/*.md`
- `docs/architecture/architecture.md`
- `docs/architecture/adr-*.md`
- `docs/architecture/tr-registry.yaml`
- `docs/architecture/architecture-traceability.md`
- `docs/architecture/control-manifest.md`
- `.codex/docs/generated-artifact-governance.md`

Stable constraints:

- Godot-only; do not reintroduce Unity/Unreal choice logic.
- Use the pinned Godot version from engine reference before making API claims.
- Do not parse `--review full|lean|solo` and do not read or create
  `production/review-mode.txt`.
- Use internal checks here; phase-gate director review belongs to `/gate-check`.
- Show drafts or summaries before any write approval.

## ADR Authoring

Output:

```text
docs/architecture/adr-NNNN-[slug].md
```

Before assigning `NNNN`, scan existing `docs/architecture/adr-*.md` and choose
the next unused number. If an ADR already covers the topic, offer update or
supersede; never silently create a duplicate.

Status values:

- `Proposed`: default for new ADRs until accepted by user/process.
- `Accepted`: implementation may depend on this decision.
- `Superseded`: replaced by a later ADR; name the successor.
- `Rejected`: considered but not adopted.

Required ADR sections:

- Title and status.
- Date.
- Godot engine compatibility: engine version, domain, knowledge risk, references
  consulted, post-cutoff API assumptions, verification required.
- ADR dependencies: depends on, enables, blocks, ordering note.
- Context and problem statement.
- Decision.
- Alternatives considered and rejection reasons.
- Consequences, including risks.
- GDD requirements addressed.
- Performance implications.
- Migration plan, if changing existing code.
- Validation criteria.
- Related decisions.

ADR retrofit path:

1. Read the existing ADR.
2. Detect missing sections without modifying existing content.
3. Treat missing `Status`, `ADR Dependencies`, `Engine Compatibility`, and
   `GDD Requirements Addressed` as high-risk gaps.
4. Draft only the missing sections.
5. Ask before appending or updating the ADR.

TR registry impact:

- If an ADR introduces or covers technical requirements, update
  `docs/architecture/tr-registry.yaml` only after explicit approval.
- Never renumber existing TR IDs.
- Append new IDs using `TR-[system]-NNN`.
- If wording changed but intent is the same, keep the ID and record a revised
  date instead of creating a new ID.
- If a requirement disappeared, mark it deprecated only after user confirmation.

## Architecture Review

Review modes are internal task scopes, not user-facing commands:

- `coverage`: GDD technical requirements to ADR coverage.
- `consistency`: cross-ADR contradictions and dependency cycles.
- `engine`: Godot version/API compatibility.
- `single-gdd`: narrow review for one GDD.
- `rtm`: requirements traceability matrix including work-order and test/evidence links when those consumers exist.
- `full`: all applicable checks above.

Extract technical requirements from GDDs into stable TR IDs. A technical
requirement is any design statement implying architecture support:

- data structure or ownership
- performance constraint
- engine capability
- cross-system communication
- state persistence
- timing/threading requirement
- platform/input requirement

Coverage statuses:

- `Covered`: ADR explicitly or clearly covers the TR.
- `Partial`: ADR partially covers the TR or coverage is ambiguous.
- `Gap`: no ADR covers the TR.

Conflict checks:

- data/state ownership conflict
- interface contract mismatch
- performance budget conflict
- dependency cycle
- conflicting architecture patterns
- stale ADR after GDD or engine-version change
- deprecated or post-cutoff Godot API assumption

Verdict:

- `PASS`: all Foundation/Core TRs covered, no blocking ADR conflicts, Godot
  assumptions verified.
- `CONCERNS`: gaps or partial coverage exist, but implementation can proceed
  with visible risk.
- `FAIL`: critical Foundation/Core gaps, dependency cycles, blocking ADR
  conflicts, or unverified high-risk Godot assumptions.

Review outputs may include:

- `docs/architecture/architecture-review-[date].md`
- `docs/architecture/architecture-traceability.md`
- `docs/architecture/requirements-traceability.md`
- `docs/architecture/tr-registry.yaml`

Ask before writing any review report, traceability index, RTM, TR registry
change, GDD revision flag, or session-state summary. Only write these durable
indexes when a named consumer and maintenance trigger exist.

## Control Manifest

Output:

```text
docs/architecture/control-manifest.md
```

Generate it from Accepted ADRs only. Proposed ADRs must be excluded and listed
for the user before write approval. If no Accepted ADRs exist, stop with
`BLOCKED` and recommend creating/accepting ADRs through `/create-architecture`.

Minimum fields:

- control id
- source GDD requirement / TR ID
- governing ADR
- architecture layer
- required pattern
- forbidden pattern, if any
- implementation owner/path
- dependency order
- implementation/work-order readiness notes
- test evidence expectation
- status

Also include global rules from `.codex/docs/technical-preferences.md` and
Godot deprecated API entries from engine reference when relevant. Every rule
must trace to an ADR, technical preference, or engine reference; do not invent
rules by taste.

If `control-manifest.md` already exists:

1. Read its version/date.
2. Summarize what changed since the last manifest.
3. Draft the regenerated manifest.
4. Ask before overwriting.

Use the manifest as an implementation constraint input for B-dev, code-review,
gate-check, or named work orders. Implementers should not have to read all ADRs
to learn required and forbidden implementation patterns.

Do not create a manifest for completeness. If no named consumer exists, return
`CONCERNS` and describe which lane or work order would need it.

## Handoff

After any architecture write, report:

- changed files
- accepted/proposed ADRs affected
- TR IDs added or revised
- manifest or traceability files updated
- checks run
- open blockers
- next `/create-architecture` task or `/gate-check` readiness note
