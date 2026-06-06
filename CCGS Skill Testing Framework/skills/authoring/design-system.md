# Skill Test Spec: /design-system

## Skill Summary

`/design-system` is the single systems design and GDD entrypoint. It creates or
updates `design/gdd/systems-index.md`, authors full system GDDs, writes quick
design patches, reviews GDDs, runs cross-GDD consistency/balance checks, and
reports design-change impact when architecture or stories may be stale.

The main `SKILL.md` owns GDD authoring and routing. Detailed behavior from the
absorbed old routes lives in direct references:

- `references/system-index-patch-impact.md`
- `references/review-consistency-balance.md`
- `references/absorption-map.md`

Review policy is fixed Lean. `CD-GDD-ALIGN` is not a phase gate. The skill uses
internal alignment checks and fresh-session review boundaries instead of old
full/lean/solo gate branching.

---

## Static Assertions

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`,
  `user-invocable`, `allowed-tools`
- [ ] Has at least two phase headings
- [ ] Contains verdict keywords such as `APPROVED`, `NEEDS REVISION`,
  `MAJOR REVISION NEEDED`, `COMPLETE`, `CONCERNS`, or `BLOCKED`
- [ ] Contains "May I write" language for skeletons, sections, indexes, logs,
  reports, and registry updates
- [ ] Documents fixed Lean policy and states `CD-GDD-ALIGN` is not a phase gate
- [ ] Links all three direct references
- [ ] Does not require reading `.agents/skills-archive/` during normal use
- [ ] Documents retrofit mode for existing GDD files

---

## Test Cases

### Case 1: Missing Systems Index

**Fixture:**

- `design/gdd/game-concept.md` exists.
- `design/gdd/systems-index.md` does not exist.

**Input:** `/design-system`

**Expected behavior:**

1. Skill loads `references/system-index-patch-impact.md`.
2. Skill extracts explicit and implicit systems from the concept.
3. Skill maps dependencies, detects circular dependencies, assigns priority and
   design order.
4. Skill asks before writing `design/gdd/systems-index.md`.
5. Skill offers the first system from the design order.

**Assertions:**

- [ ] Does not tell the user to run the old map-systems slash command.
- [ ] Preserves systems-index status values.
- [ ] Does not write the index without approval.

---

### Case 2: Full GDD Authoring

**Fixture:**

- `design/gdd/game-concept.md` exists.
- `design/gdd/systems-index.md` exists and includes `[system-name]`.
- No `design/gdd/[system-name].md` exists.

**Input:** `/design-system [system-name]`

**Expected behavior:**

1. Skill reads concept, systems index, dependencies, registry, relevant GDDs,
   and engine context.
2. Skill creates a skeleton only after approval.
3. Skill authors required GDD sections one by one.
4. Each section is drafted, approved, then written.
5. Skill runs internal alignment checks, not `CD-GDD-ALIGN` gate.
6. Skill updates registry/session/systems-index only after separate approval.

**Assertions:**

- [ ] Does not spawn `CD-GDD-ALIGN`.
- [ ] Does not self-approve a GDD authored in the same session.
- [ ] Existing dependency facts are not silently contradicted.
- [ ] Acceptance criteria are testable.

---

### Case 3: Retrofit Existing GDD

**Fixture:**

- `design/gdd/[system-name].md` exists with some complete sections and some
  placeholders.

**Input:** `/design-system retrofit design/gdd/[system-name].md`

**Expected behavior:**

1. Skill reads the existing file.
2. Skill reports complete versus missing/placeholder sections.
3. Skill edits only incomplete sections.
4. Skill preserves all approved existing content.

**Assertions:**

- [ ] No whole-file overwrite.
- [ ] Placeholder replacement uses unique section context.
- [ ] User approval is required per changed section.

---

### Case 4: Review, Consistency, Or Balance Request

**Fixture:**

- One or more system GDDs exist.
- Optional `design/registry/entities.yaml`, `assets/data/**`, or
  `design/balance/**` exists.

**Input:** `/design-system review design/gdd/[system].md`

**Expected behavior:**

1. Skill loads `references/review-consistency-balance.md`.
2. Skill runs the matching flow: single-GDD review, cross-GDD review,
   consistency registry check, or balance check.
3. Skill uses preserved verdicts and report paths.
4. Skill asks before writing review logs, cross-review reports, registry fixes,
   or balance reports.

**Assertions:**

- [ ] Does not invoke old `/design-review`, `/review-all-gdds`,
  `/consistency-check`, or `/balance-check`.
- [ ] Fresh-session review boundary is preserved.
- [ ] Registry entries are never deleted.
- [ ] Balance findings are based on actual data/formulas/config.

---

### Case 5: Quick Patch Or Change Impact

**Fixture:**

- A small design change or changed approved GDD exists.
- ADRs may exist under `docs/architecture/`.

**Input:** `/design-system quick [change]` or
`/design-system impact design/gdd/[system].md`

**Expected behavior:**

1. Skill loads `references/system-index-patch-impact.md`.
2. For quick patches, it writes
   `design/quick-specs/[name]-[date].md` after approval or redirects to full
   GDD authoring when scope is too large.
3. For impact checks, it compares changed GDD assumptions against ADRs and
   traceability.
4. Skill asks before updating ADR status, traceability, systems-index, or writing
   change-impact documents.

**Assertions:**

- [ ] Does not invoke old `/quick-design` or `/propagate-design-change`.
- [ ] Uses `Still Valid`, `Needs Review`, and `Likely Superseded`
  classifications for ADR impact.
- [ ] Never deletes ADR content.
- [ ] Returns `COMPLETE`, `REDIRECTED`, or `BLOCKED` as appropriate.

---

## Protocol Compliance

- [ ] Main SKILL routes to direct references by request area.
- [ ] Route aliases are compatibility labels only, not content dependencies.
- [ ] All writeable artifacts require explicit approval.
- [ ] Fixed Lean policy replaces old full/solo gate branching.
- [ ] Same-session authoring cannot self-approve the GDD.

---

## Coverage Notes

- This spec intentionally deletes the old standalone design route specs once
  their durable behavior is captured here and in direct references.
- Other non-design legacy specs may still exist until their own category is
  processed.
