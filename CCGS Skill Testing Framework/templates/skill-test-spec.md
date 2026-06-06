# Skill Spec: /[skill-name]

> **Category**: [gate | review | authoring | readiness | pipeline | analysis | team | sprint | utility]
> **Priority**: [critical | high | medium | low]
> **Spec written**: [YYYY-MM-DD]

## Skill Summary

[One paragraph describing what this skill does, what inputs it takes, and what outputs it produces.]

---

## Static Assertions

These should pass before any behavioral testing:

- [ ] Frontmatter has all required fields (`name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`)
- [ ] 2+ phase headings found
- [ ] At least one verdict keyword present (`PASS`, `FAIL`, `CONCERNS`, `APPROVED`, `BLOCKED`, `COMPLETE`, `READY`)
- [ ] If `allowed-tools` includes Write/Edit: `"May I write"` language present
- [ ] Next-step handoff section present at end

---

## Director Gate Checks

[Describe whether this skill references director gates under the fixed Lean policy.]

- **Phase gates**: [only `/gate-check` should spawn CD-PHASE-GATE, TD-PHASE-GATE, PR-PHASE-GATE, AD-PHASE-GATE]
- **Inline gates**: [skipped by default with "skipped — Lean policy", or replaced by internal checks]
- **N/A**: [if this skill never references gates, explain why]

---

## Test Cases

### Case 1: Happy Path — [brief name]

**Fixture** (assumed project state):
- [file/condition 1]
- [file/condition 2]

**Expected behavior**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Assertions**:
- [ ] [Assertion 1]
- [ ] [Assertion 2]
- [ ] [Assertion 3]

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 2: Failure / Blocked — [brief name]

**Fixture**:
- [missing or invalid condition]

**Expected behavior**:
1. [Skill detects the problem]
2. [Skill reports FAIL/BLOCKED]
3. [Skill does NOT proceed]

**Assertions**:
- [ ] Skill stops early and does not produce output
- [ ] Correct error/block message displayed
- [ ] No files written without user approval

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 3: Policy Variant — [brief name]

**Fixture**:
- [standard project state]
- [condition affected by fixed Lean policy]

**Expected behavior**:
1. [Behavior differs from happy path because of the policy condition]

**Assertions**:
- [ ] [Policy-specific assertion]
- [ ] [Output differs correctly from Case 1]

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 4: Edge Case — [brief name]

**Fixture**:
- [unusual or boundary condition]

**Expected behavior**:
1. [Skill handles gracefully]

**Assertions**:
- [ ] [Edge case handled without crash or silent failure]
- [ ] [Correct output or message]

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 5: Director Gate — [brief name]

**Fixture**:
- [project state that triggers a gate check]
- Fixed Lean policy is active

**Expected behavior**:
1. [Gate fires only if it is a phase gate inside `/gate-check`; otherwise it is skipped]
2. [Correct director agents spawned or skipped]

**Assertions**:
- [ ] `/gate-check` spawns all four phase-gate directors when applicable
- [ ] Non-phase gates are skipped by default with a Lean policy note
- [ ] Skill does not auto-advance past a CONCERNS or FAIL verdict

**Case Verdict**: PASS / FAIL / PARTIAL

---

## Protocol Compliance

- [ ] Uses `"May I write"` before any file writes (or is read-only and skips this)
- [ ] Presents findings/draft to user before requesting approval
- [ ] Ends with a recommended next step or follow-up action
- [ ] Does not auto-create files without user approval

---

## Coverage Notes

[Any gaps in coverage, known edge cases not tested, or conditions that would require
a live skill run to verify.]
