# Skill Test Spec: /sprint-plan

> **Category**: sprint
> **Priority**: high
> **Spec written**: 2026-06-06

## Skill Summary

`/sprint-plan` is the planning core Skill. It creates epics, creates stories,
plans or updates sprints, reports sprint status, checks scope, estimates work,
and writes retrospectives. It absorbs the former `create-epics`,
`create-stories`, `estimate`, `sprint-status`, `scope-check`, and
`retrospective` routes; those names are aliases only, not separate active Skill
specs.

---

## Static Assertions

- [ ] Frontmatter has all required fields (`name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`)
- [ ] 2+ phase headings found
- [ ] Verdict keywords present (`COMPLETE`, `BLOCKED`, `CONCERNS`, `ON SCOPE`, `SCOPE CREEP DETECTED`, `AT RISK`)
- [ ] `"May I write"` language present for epics, stories, sprint files, status files, and retrospectives
- [ ] Next-step handoff section present
- [ ] Argument hint accepts natural-language goals instead of forcing command parameters
- [ ] Reference loading rules use direct `references/planning-epics-stories.md`, not `.agents/skills-archive/`
- [ ] Fixed Lean policy present: no `--review full|lean|solo`, no `production/review-mode.txt`

---

## Director Gate Checks

- **Phase gates**: Only `/gate-check` should spawn phase-gate directors.
- **Inline gates**: `PR-SPRINT`, `PR-EPIC`, and `QL-STORY-READY` are not spawned
  by `/sprint-plan`; internal feasibility/readiness checks are used instead.
- **Absorbed legacy behavior**: old route names may map to internal task scopes,
  but output should recommend `/sprint-plan`, not the old commands.

---

## Test Cases

### Case 1: Happy Path — Create sprint plan and status file

**Fixture**:
- Active milestone exists in `production/milestones/`
- Previous sprint exists or no sprint exists yet
- Backlog stories exist under `production/epics/**/story-*.md`
- Control manifest and accepted ADR references exist for selected stories

**Input**: `/sprint-plan next sprint`

**Expected behavior**:
1. Skill reads milestone, previous sprint, sprint status, epics, stories, risks, and QA context.
2. Skill selects stories by dependency order, layer, priority, and capacity.
3. Skill runs an internal feasibility pass for capacity, hidden dependencies, underestimated work, and milestone risk.
4. Skill drafts `production/sprints/sprint-[N].md` and `production/sprint-status.yaml`.
5. Skill checks whether a sprint QA plan exists and warns if missing.
6. Skill asks before writing sprint markdown and status yaml together.

**Assertions**:
- [ ] Draft is shown before write approval
- [ ] `production/sprint-status.yaml` is the machine-readable status file
- [ ] Existing story statuses are preserved during update mode
- [ ] No `production/review-mode.txt` is read, created, or normalized
- [ ] No producer gate is spawned
- [ ] Verdict is `COMPLETE` after approved write or `BLOCKED` if required data is missing

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 2: Absorbed Epic Path — Create epics from GDD and architecture

**Fixture**:
- `design/gdd/systems-index.md` lists approved systems
- Relevant GDD files exist
- Architecture and accepted ADRs exist for the systems

**Input**: `/sprint-plan create epics for approved systems`

**Expected behavior**:
1. Skill classifies the request as epic creation.
2. Skill loads `references/planning-epics-stories.md`.
3. Skill reads GDDs, architecture, ADRs, TR registry, and control manifest.
4. Skill drafts epics in Foundation -> Core -> Feature -> Presentation order.
5. Skill asks `May I write` per epic, not once for all epics.
6. Skill updates `production/epics/index.md` after approved epic writes.

**Assertions**:
- [ ] Each EPIC.md includes layer, source GDD, TR/GDD requirements, governing ADRs, scope, dependencies, risks, and Definition of Done
- [ ] Existing epic files are not silently overwritten
- [ ] User sees each epic draft before approval
- [ ] Next step recommends `/sprint-plan create stories for [epic]`

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 3: Absorbed Story Path — Create stories with ADR/blocker handling

**Fixture**:
- `production/epics/[epic-slug]/EPIC.md` exists
- Source GDD exists
- TR registry and control manifest exist
- One governing ADR is Accepted and one is Proposed

**Input**: `/sprint-plan create stories for [epic-slug]`

**Expected behavior**:
1. Skill classifies the request as story creation.
2. Skill reads EPIC, GDD, governing ADRs, TR registry, and control manifest.
3. Skill drafts story files using `story-NNN-[slug].md`.
4. Story covered by Accepted ADR is `Ready`.
5. Story covered by Proposed ADR is `Blocked` and names the ADR.
6. Skill asks `May I write` per story.

**Assertions**:
- [ ] Story frontmatter includes title, epic, layer, priority, status, story type, TR-ID, ADR references, acceptance criteria, DoD, blockers, and test evidence path
- [ ] Blocked story recommends `/create-architecture ADR: [title]`, not old `/architecture-decision`
- [ ] Blocked stories may be written only as visibly blocked
- [ ] Skill does not start implementation

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 4: Absorbed Read-Only Paths — Estimate, status, and scope

**Fixture**:
- A current sprint or story exists
- Active milestone or parent epic exists
- Sprint history may or may not exist

**Input**: `/sprint-plan estimate and scope check this sprint`

**Expected behavior**:
1. Skill classifies the requested read-only planning checks.
2. Estimate output uses S/M/L/XL or day-range with confidence and uncertainty drivers.
3. Scope check maps stories to milestone or epic scope.
4. Sprint status reports completed/in-progress/not-started/blocked counts, blockers, stale work, and health.
5. Skill does not write files unless user explicitly asks to persist updates.

**Assertions**:
- [ ] Estimates include confidence (`High`, `Medium`, `Low`) and risk drivers
- [ ] Scope verdict is one of `ON SCOPE`, `CONCERNS`, `SCOPE CREEP DETECTED`
- [ ] Sprint health is one of `ON TRACK`, `AT RISK`, `BLOCKED`
- [ ] Missing sprint history uses conservative defaults, not failure
- [ ] No director gate is spawned

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 5: Absorbed Retrospective Path — Carry-over actions

**Fixture**:
- Sprint or milestone data exists
- A previous retrospective exists with unchecked action items
- Target retrospective does not exist yet, or exists and requires append/replace choice

**Input**: `/sprint-plan retrospective for sprint 005`

**Expected behavior**:
1. Skill classifies the request as retrospective.
2. Skill reads sprint/milestone data and prior retrospective.
3. Skill carries unresolved action items forward.
4. Skill drafts what worked, what did not, carry-over actions, new actions, owners, and due dates.
5. Skill asks before creating, appending, or replacing the retrospective file.

**Assertions**:
- [ ] Existing retro is not silently overwritten
- [ ] Prior unresolved action items appear in a carry-over section
- [ ] Action items are concrete and have owner/due date
- [ ] Verdict is `COMPLETE` after approved write

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 6: Policy Regression — Legacy planning commands are aliases

**Fixture**:
- Route index maps old planning names to `sprint-plan`
- Old planning specs/archive dirs have been removed after absorption

**Input**: User asks for old `/create-stories`

**Expected behavior**:
1. `/help` or route index maps the request to `/sprint-plan`.
2. `/sprint-plan` runs the internal story creation path.
3. Output does not ask the user to switch to the old command.
4. No active spec exists for the old command.

**Assertions**:
- [ ] Route aliases exist for absorbed planning names
- [ ] Old specs are not active coverage targets
- [ ] Active Skill does not depend on `.agents/skills-archive/`
- [ ] Fixed Lean policy remains intact

**Case Verdict**: PASS / FAIL / PARTIAL

---

## Protocol Compliance

- [ ] Presents findings or draft before requesting approval
- [ ] Uses `"May I write"` before any file write
- [ ] Keeps epics, stories, sprint planning, status, scope, estimate, and retro inside `/sprint-plan`
- [ ] Does not auto-advance stage or commit changes
- [ ] Ends with next step, blocker, or handoff

---

## Coverage Notes

- The exact wording of sprint/epic/story/retro documents is validated through
  behavior and required-field assertions rather than fixture-locked prose.
- Old standalone planning specs are intentionally deleted once their durable
  behavior is covered here and in `references/planning-epics-stories.md`.
