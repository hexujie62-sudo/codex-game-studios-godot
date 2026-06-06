# Skill Test Spec: /create-architecture

> **Category**: authoring
> **Priority**: critical
> **Spec written**: 2026-06-06

## Skill Summary

`/create-architecture` is the Godot architecture core Skill. It authors or
updates the master architecture blueprint, creates and retrofits ADRs, reviews
architecture coverage/traceability, and generates the control manifest. It
absorbs the former `architecture-decision`, `architecture-review`, and
`create-control-manifest` routes; those names are aliases only, not separate
active Skill specs.

---

## Static Assertions

- [ ] Frontmatter has all required fields (`name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`)
- [ ] 2+ phase headings found
- [ ] Verdict keywords present (`PASS`, `FAIL`, `CONCERNS`, `BLOCKED`, `COMPLETE`, `READY`)
- [ ] `"May I write"` language present for architecture, ADR, registry, traceability, and manifest writes
- [ ] Next-step handoff section present
- [ ] Argument hint accepts natural-language goals instead of forcing `full|lean|solo`
- [ ] Reference loading rules use direct `references/adr-review-control.md`, not `.agents/skills-archive/`
- [ ] Fixed Lean policy present: no `--review full|lean|solo`, no `production/review-mode.txt`

---

## Director Gate Checks

- **Phase gates**: Only `/gate-check` should spawn phase-gate directors.
- **Inline gates**: Architecture self-review and feasibility checks are internal
  checks inside `/create-architecture`; legacy `TD-ADR`, `TD-ARCHITECTURE`,
  `TD-MANIFEST`, and `LP-FEASIBILITY` mode switches are not user-exposed.
- **Absorbed legacy behavior**: old route names may map to internal task scopes,
  but output should recommend `/create-architecture`, not the old commands.

---

## Test Cases

### Case 1: Happy Path — Master architecture blueprint, skeleton-first

**Fixture**:
- Godot engine reference exists under `docs/engine-reference/godot/`
- `.codex/docs/technical-preferences.md` pins Godot
- Approved GDD context exists in `design/gdd/`
- No existing `docs/architecture/architecture.md`

**Input**: `/create-architecture`

**Expected behavior**:
1. Skill loads engine, technical preferences, systems index, GDDs, and existing architecture files.
2. Skill extracts a Technical Requirements Baseline.
3. Skill creates or proposes a skeleton for `docs/architecture/architecture.md`.
4. Each architecture section is drafted and shown before write approval.
5. Skill asks `May I write this to docs/architecture/architecture.md?` or an equivalent section-specific approval before writing.
6. Handoff lists required ADRs, control-manifest readiness, and gate-check readiness.

**Assertions**:
- [ ] Skeleton-first behavior is documented
- [ ] Technical requirements baseline is produced before architecture decisions
- [ ] Godot version/API risk is checked against engine reference
- [ ] Per-section or grouped write approval is required before writing
- [ ] Handoff uses `/create-architecture` for next ADR/review tasks

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 2: Absorbed ADR Path — Create or retrofit ADR

**Fixture**:
- `docs/architecture/` exists
- Existing ADR files may or may not exist
- Relevant GDD and Godot engine reference files exist

**Input**: `/create-architecture ADR: event bus ownership`

**Expected behavior**:
1. Skill classifies the request as ADR authoring.
2. Skill loads `references/adr-review-control.md`.
3. Skill scans `docs/architecture/adr-*.md` to assign the next unused ADR number or detect a duplicate topic.
4. Skill drafts an ADR with status, date, Godot compatibility, dependencies, context, decision, alternatives, consequences, GDD requirements, performance impact, migration plan, validation criteria, and related decisions.
5. Skill asks before writing `docs/architecture/adr-NNNN-[slug].md`.
6. Skill asks separately before updating `docs/architecture/tr-registry.yaml`.

**Assertions**:
- [ ] ADR status values are `Proposed`, `Accepted`, `Superseded`, `Rejected`
- [ ] Duplicate ADR topics are not silently duplicated
- [ ] Godot compatibility section is required
- [ ] TR registry updates preserve stable IDs and require approval
- [ ] No `--review full|lean|solo` or `production/review-mode.txt` behavior is used

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 3: Absorbed Review Path — Coverage, conflicts, and RTM

**Fixture**:
- `design/gdd/systems-index.md` exists
- One or more GDDs exist
- `docs/architecture/adr-*.md` exists
- Optional stories/tests exist for RTM mode

**Input**: `/create-architecture review coverage and conflicts`

**Expected behavior**:
1. Skill classifies the request as architecture review.
2. Skill extracts or reuses stable TR IDs from `docs/architecture/tr-registry.yaml`.
3. Skill maps GDD technical requirements to ADR coverage.
4. Skill checks cross-ADR conflicts, dependency cycles, stale ADRs, and Godot deprecated/post-cutoff API assumptions.
5. Skill reports verdict `PASS`, `CONCERNS`, or `FAIL`.
6. Skill asks before writing review report, traceability index, RTM, or registry changes.

**Assertions**:
- [ ] Coverage statuses are `Covered`, `Partial`, and `Gap`
- [ ] Verdict semantics match the reference: critical Foundation/Core gaps or blocking conflicts produce `FAIL`
- [ ] Stable TR IDs are never renumbered
- [ ] RTM output links GDD -> ADR -> Story -> Test when stories/tests exist
- [ ] Review remains advisory and does not auto-advance project stage

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 4: Absorbed Control Manifest Path — Accepted ADRs only

**Fixture**:
- `docs/architecture/` contains a mix of Accepted and Proposed ADRs
- `.codex/docs/technical-preferences.md` exists
- Godot deprecated API reference exists

**Input**: `/create-architecture generate control manifest`

**Expected behavior**:
1. Skill classifies the request as control-manifest generation.
2. Skill reads all ADRs and filters to `Status: Accepted`.
3. Skill lists Proposed/Superseded/Rejected ADRs excluded from the manifest.
4. Skill drafts `docs/architecture/control-manifest.md` with control IDs, TR/GDD sources, governing ADRs, layer, required/forbidden patterns, owner/path, dependency order, readiness notes, test evidence expectation, and status.
5. Skill asks before writing or overwriting the manifest.

**Assertions**:
- [ ] Proposed ADRs are excluded and named
- [ ] Every control rule has a source ADR, technical preference, or Godot reference
- [ ] Existing manifest is read before regeneration
- [ ] Manifest is identified as `/dev-story` readiness input
- [ ] No director gate or review-mode file is required

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 5: Policy Regression — Legacy commands are aliases, not facts

**Fixture**:
- Route index maps `architecture-decision`, `architecture-review`, and
  `create-control-manifest` to `create-architecture`
- Old archive directories and old specs have been removed after absorption

**Input**: User asks for old `/architecture-review`

**Expected behavior**:
1. `/help` or route index maps the request to `/create-architecture`.
2. `/create-architecture` runs the internal architecture review path.
3. Output does not ask the user to switch to the old command.
4. No active spec exists for the old command.

**Assertions**:
- [ ] Route alias exists for old names
- [ ] Old specs are not active coverage targets
- [ ] Active Skill does not depend on `.agents/skills-archive/`
- [ ] Fixed Lean policy remains intact

**Case Verdict**: PASS / FAIL / PARTIAL

---

## Protocol Compliance

- [ ] Presents findings or draft before requesting approval
- [ ] Uses `"May I write"` before any file write
- [ ] Keeps ADR authoring, architecture review, and control-manifest writes inside `/create-architecture`
- [ ] Does not auto-advance stage or commit changes
- [ ] Ends with next step, blocker, or handoff

---

## Coverage Notes

- The exact section content of architecture documents and ADRs is validated by
  behavior and required-field assertions rather than by fixture-locking prose.
- Old standalone architecture specs are intentionally deleted once their durable
  behavior is covered here and in `references/adr-review-control.md`.
