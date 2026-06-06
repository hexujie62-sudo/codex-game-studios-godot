# Skill Test Spec: /brainstorm

## Skill Summary

`/brainstorm` is the concept-and-landing-package entrypoint. It produces
`design/gdd/game-concept.md` and a complete package covering pillars,
anti-pillars, core loop, player motivation, scope tiers, Godot fit, Visual
Identity Anchor, first complete playable/validation scope,
implementation/tool/resource plan, risks, and acceptance criteria.

It also absorbs the concept-side value of the old `prototype` route. Prototype
details live in `references/prototype-validation.md` and are loaded only when the
user asks for validation, spike, pivot, kill, or when concept risk is high enough
that a prototype question should be defined before GDD work.

Review policy is fixed Lean. `CD-PILLARS`, `AD-CONCEPT-VISUAL`,
`TD-FEASIBILITY`, and `PR-SCOPE` are not phase gates. The skill uses internal
checks and package-level user approval before writing.

---

## Static Assertions

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`,
  `user-invocable`, `allowed-tools`
- [ ] Has at least two phase headings
- [ ] Contains verdict keyword `COMPLETE`
- [ ] Contains package-level approval language for the concept-and-landing package
- [ ] Requires deep guided design interview before direct package drafting when
  major direction, rhythm, pillars, visual anchor, production coverage, tools,
  risks, acceptance criteria, or first complete scope are unresolved
- [ ] Describes first complete scope / validation build instead of defaulting to
  drip-feed MVP language
- [ ] Documents fixed Lean policy and does not ask the user to choose full,
  lean, or solo mode
- [ ] Links `references/prototype-validation.md` and
  `references/absorption-map.md`
- [ ] Does not require reading `.agents/skills-archive/` during normal use
- [ ] Ends with next-step handoff to current core Skills such as
  `/setup-engine`, `/art-bible`, `/design-system`, `/create-architecture`, or
  `/gate-check`

---

## Test Cases

### Case 1: Guided Concept Creation

**Fixture:**

- No existing `design/gdd/game-concept.md`

**Input:** `/brainstorm`

**Expected behavior:**

1. Skill asks only the package-level discovery questions needed for the user's
   current clarity.
2. Skill presents three distinct concept options.
3. User selects or combines a concept.
4. Skill runs a deep guided design interview for the topics that materially
   change the package, such as rhythm, loop feel, pillars, visual identity,
   production coverage, tools, risks, acceptance criteria, or first complete
   scope. The interview is not artificially capped by question count.
5. Skill develops core loop, pillars, anti-pillars, player type, scope, and
   Godot fit.
6. Skill runs internal pillar, visual-anchor, feasibility, and scope checks.
7. Skill presents the complete concept-and-landing package before writing.
8. Skill asks once before writing package files.
9. Skill returns `COMPLETE` and recommends one current core next step.

**Assertions:**

- [ ] Does not spawn old inline director gates.
- [ ] Does not parse `--review full|lean|solo`.
- [ ] Visual Identity Anchor is included.
- [ ] Scope table uses a concrete timeline/team-size estimate.
- [ ] File is not written without package approval.
- [ ] Does not jump from a strong user draft directly to final package writing
      while useful design interview topics remain unresolved.

---

### Case 2: High-Risk Concept Needs Prototype Question

**Fixture:**

- User selects an action, physics, networking, procedural, or unusual-platform
  concept with unclear feasibility.

**Input:** `/brainstorm action roguelike prototype`

**Expected behavior:**

1. Skill loads `references/prototype-validation.md`.
2. Skill defines one falsifiable prototype hypothesis.
3. Skill chooses a path based on the risk: Godot engine for feel/physics,
   HTML/paper for logic, paper/spreadsheet for economy/rules.
4. Skill includes `prototypes/[concept-name]-concept/` in the approved package
   before creating it.
5. Skill preserves verdict vocabulary `PROCEED`, `PIVOT`, or `KILL`.

**Assertions:**

- [ ] Does not invoke or read a separate `prototype` Skill.
- [ ] Does not use HTML to validate timing-sensitive feel.
- [ ] Prototype code remains isolated under `prototypes/`.
- [ ] Prototype result must update concept facts before downstream design.

---

### Case 3: Existing Concept Resume

**Fixture:**

- `design/gdd/game-concept.md` exists.

**Input:** `/brainstorm`

**Expected behavior:**

1. Skill reads the existing concept.
2. Skill resumes or asks which concept section to revise.
3. Skill preserves approved content unless the user asks to change it.
4. Skill asks for package/change approval before rewriting the concept file.

**Assertions:**

- [ ] Does not restart from scratch silently.
- [ ] Shows existing concept facts before changing them.
- [ ] Revised content is written only after approval.

---

### Case 4: Missing Write Approval

**Fixture:**

- Concept draft is ready, but user does not approve writing.

**Input:** `/brainstorm`

**Expected behavior:**

1. Skill presents the draft.
2. Skill asks whether to approve package, revise package, or stop.
3. If approval is declined, no file is written.
4. Skill returns `BLOCKED` or a clear stopped state.

**Assertions:**

- [ ] No file write without package approval.
- [ ] User can revise the package before writing.
- [ ] Stop state preserves what remains unresolved.

---

## Protocol Compliance

- [ ] Uses Goal -> Scope -> Deep Design Interview -> Complete Package -> Approval -> Write.
- [ ] Uses `AskUserQuestion` selectively for constrained decisions, while free-form
  interview can continue in normal conversation.
- [ ] Preserves long guided co-design while removing repeated micro-approval.
- [ ] Keeps prototype details in direct references and loads them conditionally.
- [ ] Route aliases are compatibility labels only, not content dependencies.
- [ ] Fixed Lean policy replaces old full/solo branching.

---

## Coverage Notes

- This spec intentionally removes old full/solo director-gate cases.
- If future prototype behavior is missing, add it to
  `references/prototype-validation.md`, not to a restored visible Skill.
