---
name: sprint-plan
description: "Create or update sprint plans from the current milestone, completed work, and available capacity, pulling context from production docs and design backlog."
argument-hint: "[natural-language goal: epics | stories | sprint | status | scope | estimate | retro]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Task, AskUserQuestion
model: sonnet
context: |
  !ls production/sprints/ 2>/dev/null
---

## Absorbed Responsibilities

This is now the single planning entrypoint. It also covers the former
`create-epics`, `create-stories`, `estimate`, `sprint-status`, `scope-check`,
and `retrospective` routes.

Use the smallest planning action that fits:

- Need backlog structure: create epics/stories from approved GDD and architecture.
- Need execution plan: create or update the sprint.
- Need status: read current sprint state and summarize.
- Need scope/estimate/retro: run that checklist inside this Skill.

Preserved CCGS value:

- Epic output: `production/epics/[epic-slug]/EPIC.md`.
- Epic index output: `production/epics/index.md`.
- Story outputs: `production/epics/[epic-slug]/story-NNN-[slug].md`.
- Sprint output: `production/sprints/sprint-[N].md`.
- Sprint status output: `production/sprint-status.yaml`.
- Retrospective output: `production/retrospectives/retro-[sprint-or-milestone]-[date].md`.
- Story files must preserve: status, GDD/TR reference, governing ADR,
  acceptance criteria, story type, test evidence path, implementation notes,
  blockers, and done evidence.
- `production/sprint-status.yaml` is authoritative for active production state
  when present; keep it in sync with story status changes.
- Scope checks compare new or changed stories against original epic scope and
  mark additions as accepted, deferred, or removed.
- Estimates are advisory; include confidence and main risk drivers.
- Retrospectives read previous retrospectives and carry forward unresolved
  action items.

## Reference Loading Rules

Do not read `.agents/skills-archive/` during normal use. Old planning Skill
content has been extracted into `references/planning-epics-stories.md`.

Read that reference for epic creation, story generation, estimate, scope check,
sprint status, or retrospective behavior. Normal sprint plan creation can run
from this `SKILL.md` alone once GDD/ADR/control-manifest context exists.

## Phase -1: Classify Planning Task

Do not require the user to remember old command names or mode parameters.
Classify the request from natural language:

- **Epic creation**: translate approved GDD/architecture into
  `production/epics/[epic-slug]/EPIC.md`.
- **Story creation**: break an epic into developer-ready story files.
- **Sprint planning**: create or update `production/sprints/sprint-[N].md` and
  `production/sprint-status.yaml`.
- **Sprint status**: read current sprint/story state and report health.
- **Scope check**: compare proposed work against epic/milestone/sprint scope.
- **Estimate**: produce advisory S/M/L/XL or day-range estimates with confidence.
- **Retrospective**: write sprint or milestone retro with carry-over actions.

If the user used an absorbed legacy name (`create-epics`, `create-stories`,
`estimate`, `sprint-status`, `scope-check`, or `retrospective`), run the matching
internal path here and report the current command as `/sprint-plan`.

For epic/story/status/scope/estimate/retro work, load
`references/planning-epics-stories.md` before drafting. Normal sprint plan
creation can run from this `SKILL.md` alone once GDD/ADR/control-manifest
context exists.

## Phase 0: Parse Arguments

Extract the planning intent (`new`, `update`, `status`, or an absorbed planning
task). Do not parse review mode arguments and do not read or create
`production/review-mode.txt`. Sprint planning uses the fixed review standard:
internal feasibility checks here, phase-gate director review only in
`/gate-check`.

---

## Phase 1: Gather Context

1. **Read the current milestone** from `production/milestones/`.

2. **Read the previous sprint** (if any) from `production/sprints/` to
   understand velocity and carryover.

3. **Scan design documents** in `design/gdd/` for features tagged as ready
   for implementation.

4. **Check the risk register** at `production/risk-register/`.

---

## Phase 2: Generate Output

For `new`:

**Generate a sprint plan** following this format and present it to the user. Do NOT ask to write yet. The internal feasibility pass (Phase 4) runs first and may require revisions before the file is written.

```markdown
# Sprint [N] — [Start Date] to [End Date]

## Sprint Goal
[One sentence describing what this sprint achieves toward the milestone]

## Capacity
- Total days: [X]
- Buffer (20%): [Y days reserved for unplanned work]
- Available: [Z days]

## Tasks

### Must Have (Critical Path)
| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------------|-----------|-------------|-------------------|

### Should Have
| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------------|-----------|-------------|-------------------|

### Nice to Have
| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------------|-----------|-------------|-------------------|

## Carryover from Previous Sprint
| Task | Reason | New Estimate |
|------|--------|-------------|

## Risks
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|

## Dependencies on External Factors
- [List any external dependencies]

## Definition of Done for this Sprint
- [ ] All Must Have tasks completed
- [ ] All tasks pass acceptance criteria
- [ ] QA plan exists (`production/qa/smoke-check-sprint-[N].md`)
- [ ] All Logic/Integration stories have passing unit/integration tests
- [ ] Smoke check passed (`/smoke-check sprint`)
- [ ] QA sign-off report: APPROVED or APPROVED WITH CONDITIONS (`/smoke-check sprint`)
- [ ] No S1 or S2 bugs in delivered features
- [ ] Design documents updated for any deviations
- [ ] Code reviewed and merged
```

For `update`:

**Update an existing sprint plan**:

1. Read the most recent sprint plan from `production/sprints/`.
2. Present the current story list with their current statuses from `production/sprint-status.yaml`.
3. Ask the user what to change: stories to add, remove, reprioritize, or re-estimate. Use `AskUserQuestion` to gather changes.
4. Apply the changes and re-present the full revised plan for review.
5. Re-run the internal producer feasibility pass (Phase 4) on the revised plan.
6. Write the updated markdown plan and yaml together (same approval as `new` mode).

Note: `update` mode does not reset story statuses. Stories already marked `in-progress` or `done` keep their status. Only `backlog` and `ready-for-dev` stories can be removed or reprioritized freely.

For `status`:

**Generate a status report**:

```markdown
# Sprint [N] Status -- [Date]

## Progress: [X/Y tasks complete] ([Z%])

### Completed
| Task | Completed By | Notes |
|------|-------------|-------|

### In Progress
| Task | Owner | % Done | Blockers |
|------|-------|--------|----------|

### Not Started
| Task | Owner | At Risk? | Notes |
|------|-------|----------|-------|

### Blocked
| Task | Blocker | Owner of Blocker | ETA |
|------|---------|-----------------|-----|

## Burndown Assessment
[On track / Behind / Ahead]
[If behind: What is being cut or deferred]

## Emerging Risks
- [Any new risks identified this sprint]
```

---

## Phase 3: Prepare Sprint Status File

After generating a new sprint plan, also prepare the `production/sprint-status.yaml` content.
This is the machine-readable source of truth for story status — read by
`/sprint-plan`, `/story-done`, and `/help` without markdown parsing.

**Do not write the yaml yet** — hold it in context. The producer feasibility gate (Phase 4) may revise the story list. Both files will be written together after Phase 4 in a single write approval.

Format:

```yaml
# Auto-generated by /sprint-plan. Updated by /story-done and /dev-story.
# DO NOT edit manually — use /story-done to update story status.
#
# Status value mapping (yaml ↔ story file Status field):
#   backlog        ↔  Not Started
#   ready-for-dev  ↔  Ready
#   in-progress    ↔  In Progress
#   review         ↔  In Review
#   done           ↔  Complete
#   blocked        ↔  Blocked

sprint: [N]
goal: "[sprint goal]"
start: "[YYYY-MM-DD]"
end: "[YYYY-MM-DD]"
generated: "[YYYY-MM-DD]"
updated: "[YYYY-MM-DD]"

stories:
  - id: "[epic-story, e.g. 1-1]"
    name: "[story name]"
    file: "[production/stories/path.md]"
    priority: must-have        # must-have | should-have | nice-to-have
    status: ready-for-dev      # backlog | ready-for-dev | in-progress | review | done | blocked
    owner: ""
    estimate_days: 0
    blocker: ""
    completed: ""
```

Initialize each story from the sprint plan's task tables:
- Must Have tasks → `priority: must-have`, `status: ready-for-dev`
- Should Have tasks → `priority: should-have`, `status: backlog`
- Nice to Have tasks → `priority: nice-to-have`, `status: backlog`

For `update`: read the existing `sprint-status.yaml`, carry over statuses for
stories that haven't changed, add new stories, remove dropped ones.

---

## Phase 4: Producer Feasibility Check

`PR-SPRINT` is not invoked as a separate gate. Run an internal feasibility pass
before finalising the sprint plan:

- Check story count against available capacity.
- Check story dependency order.
- Flag hidden dependencies, underestimated stories, and milestone risk.
- If the plan looks unrealistic, revise the story selection or dates and
  re-present the updated plan before asking for write approval.

After the internal feasibility pass, ask: "May I write the sprint plan to `production/sprints/sprint-[N].md` and `production/sprint-status.yaml`?" If yes, write both files (creating directories as needed). Verdict: **COMPLETE** — sprint plan and status file created. If no: Verdict: **BLOCKED** — user declined write.

After writing, add:

> **Scope check:** If this sprint includes stories added beyond the original epic scope, run `/sprint-plan [epic]` to detect scope creep before implementation begins.

---

## Phase 5: QA Plan Gate

Before closing the sprint plan, check whether a QA plan exists for this sprint.

Use `Glob` to look for `production/qa/smoke-check-sprint-[N].md` or any file in `production/qa/` referencing this sprint number.

**If a QA plan is found**: note it in the sprint plan output — "QA Plan: `[path]`" — and proceed.

**If no QA plan exists**: do not silently proceed. Surface this explicitly:

> "This sprint has no QA plan. A sprint plan without a QA plan means test requirements are undefined — developers won't know what 'done' looks like from a QA perspective, and the sprint cannot pass the Production → Polish gate without one.
>
> Run `/smoke-check sprint` now, before starting any implementation. It takes one session and produces the test case requirements each story needs."

Use `AskUserQuestion`:
- Prompt: "No QA plan found for this sprint. How do you want to proceed?"
- Options:
  - `[A] Run /smoke-check sprint now — I'll do that before starting implementation (Recommended)`
  - `[B] Skip for now — I understand QA sign-off will be blocked at the Production → Polish gate`

If [A]: close with "Sprint plan written. Run `/smoke-check sprint` next — then begin implementation."
If [B]: add a warning block to the sprint plan document:

```markdown
> ⚠️ **No QA Plan**: This sprint was started without a QA plan. Run `/smoke-check sprint`
> before the last story is implemented. The Production → Polish gate requires a QA
> sign-off report, which requires a QA plan.
```

---

## Phase 6: Next Steps

After the sprint plan is written and QA plan status is resolved:

- `/smoke-check sprint` — **required before implementation begins** — defines test cases per story so developers implement against QA specs, not a blank slate
- `/dev-story [story-file]` — validate a story is ready before starting it
- `/dev-story [story-file]` — begin implementing the first story
- `/sprint-plan` — check progress mid-sprint
- `/sprint-plan [epic]` — verify no scope creep before implementation begins

**Review standard:** `/sprint-plan` does not spawn producer, QA, or code-review
director gates. It performs internal feasibility checks and hands phase
readiness to `/gate-check`.

