# Planning, Epics, Stories, Status, Scope, And Retro Reference

Use this reference when `/sprint-plan` creates epics/stories, estimates work,
checks scope, reports sprint status, or writes retrospectives. Do not read
archived old Skills.

## Absorption Map

| Old Skill | Core value preserved |
|---|---|
| `create-epics` | EPIC path/index, layer ordering, GDD/ADR traceability, per-epic approval |
| `create-stories` | story filename/frontmatter, story type, blocked ADR handling, per-story approval |
| `estimate` | S/M/L/XL or day-range estimate, confidence, uncertainty drivers, spike recommendation |
| `sprint-status` | read-only sprint health report, status counts, blocker/stale-work detection |
| `scope-check` | milestone/epic/sprint scope mapping and ON SCOPE / CONCERNS / SCOPE CREEP DETECTED verdict |
| `retrospective` | retro outputs, prior-action carry-over, concrete owner/due-date actions |

Legacy names are route aliases only. Do not tell the user to run the old command
as the next step; report `/sprint-plan` as the active entry.

## Shared Inputs

Read the smallest set needed for the requested planning task:

- `production/milestones/*.md`
- `production/sprints/*.md`
- `production/sprint-status.yaml`
- `production/epics/**/EPIC.md`
- `production/epics/**/story-*.md`
- `production/epics/index.md`
- `production/retrospectives/*.md`
- `production/session-state/active.md`
- `design/gdd/systems-index.md`
- relevant `design/gdd/*.md`
- `docs/architecture/architecture.md`
- `docs/architecture/adr-*.md`
- `docs/architecture/tr-registry.yaml`
- `docs/architecture/control-manifest.md`

Stable constraints:

- Do not parse `--review full|lean|solo`.
- Do not read, create, or normalize `production/review-mode.txt`.
- Producer/QA/director review is not spawned here; use internal feasibility
  checks and hand phase readiness to `/gate-check`.
- Show drafts or summaries before any write approval.
- Ask before writing every epic, story, sprint plan, status file, or retro.

## Epic Creation

Outputs:

```text
production/epics/[epic-slug]/EPIC.md
production/epics/index.md
```

Read approved GDDs, architecture, Accepted ADRs, TR registry, and control
manifest before drafting. Process epics in layer order:

1. Foundation
2. Core
3. Feature
4. Presentation

Within a layer, order by priority and dependency. Each EPIC.md should include:

- epic title and slug
- layer
- source GDD path
- GDD/TR requirements covered
- governing ADRs and control-manifest references
- scope in / out
- dependencies
- engine or architecture risk notes
- Definition of Done
- suggested first stories

If an epic already exists, offer update or skip; never silently overwrite.
Ask `May I write` per epic, not once for a whole batch. Update
`production/epics/index.md` only after approved epic writes.

## Story Creation

Output:

```text
production/epics/[epic-slug]/story-NNN-[slug].md
```

Read EPIC.md, source GDD, governing ADRs, TR registry, and control manifest.
Each story must preserve:

- title
- epic
- layer
- priority
- status
- story type: `Logic`, `Integration`, `Visual/Feel`, `UI`, or `Config/Data`
- TR-ID / source GDD requirement
- ADR references and control IDs
- acceptance criteria
- Definition of Done
- implementation notes
- dependencies/blockers
- test evidence path or reason no automated test is required

Story status rules:

- Governing ADR Accepted -> `Ready`.
- Governing ADR Proposed -> `Blocked`, with a blocking note naming the ADR and
  recommending `/create-architecture ADR: [title]`.
- Missing TR or missing control manifest -> `Blocked` or `Needs Work`, depending
  on whether the missing artifact is required for implementation.

Ask `May I write` per story. Blocked stories may still be written if the user
approves, but they must stay visibly blocked and must not be implemented by
`/dev-story` until unblocked.

## Sprint Planning And Status File

Sprint output:

```text
production/sprints/sprint-[N].md
production/sprint-status.yaml
```

`production/sprint-status.yaml` is the machine-readable source of truth for
active story state when present. Preserve status values when updating a sprint.

Status mapping:

```text
Not Started -> backlog
Ready -> ready-for-dev
In Progress -> in-progress
In Review -> review
Complete -> done
Blocked -> blocked
```

Planning checks:

- Read previous sprint for carry-over.
- Read active milestone for capacity and goal fit.
- Select stories by dependency order, layer, and priority.
- Include 20% buffer for unplanned work unless current project rules say otherwise.
- Run internal feasibility: capacity, dependency order, hidden blockers,
  underestimated stories, milestone risk.
- If overloaded, revise the story selection or dates before asking to write.
- Check for a sprint QA plan and warn if missing; recommend `/smoke-check sprint`.

Ask once before writing the sprint plan and status file together.

## Estimation

Estimates are advisory and normally read-only. Use:

- size labels: `S`, `M`, `L`, `XL`
- optional day ranges
- confidence labels: `High`, `Medium`, `Low`
- uncertainty drivers: vague acceptance criteria, missing ADR, unfamiliar system,
  no prior code, no sprint history, external dependency

If confidence is low or the story depends on an unproven mechanic, recommend a
time-boxed prototype/spike through `/brainstorm` or a technical spike story.

No file write is required unless the user explicitly asks to insert estimates
into a sprint/story file; ask before any such write.

## Scope Check

Scope checks are advisory and normally read-only.

Verdicts:

- `ON SCOPE`: all checked work maps to active milestone or parent epic scope.
- `CONCERNS`: scope cannot be validated or partial overlap is risky.
- `SCOPE CREEP DETECTED`: work introduces systems, features, platforms, or
  obligations outside the approved milestone/epic/sprint scope.

For a sprint, map each story to milestone goals. For a single story, map the
story to parent epic scope. Name every out-of-scope item explicitly. Do not
remove, defer, or rewrite scope without approval.

## Sprint Status

Read-only report unless the user asks to update state.

Report:

- completed / in-progress / not-started / blocked counts
- specific blockers and owner of blocker
- stale in-progress work
- burndown assessment: `ON TRACK`, `AT RISK`, or `BLOCKED`
- emerging risks
- next action

If no active sprint exists, do not emit a false verdict; explain that no active
sprint was found and recommend `/sprint-plan`.

## Retrospective

Outputs:

```text
production/retrospectives/retro-sprint-[N]-[date].md
production/retrospectives/retro-[milestone-name]-[date].md
```

Read the sprint/milestone, session state, and the most recent prior
retrospective. If prior retro action items are unchecked, carry them into a
`Carry-over` section. If sprint data is missing, ask for manual input rather than
writing an empty retro.

Retros must include:

- what worked
- what did not work
- carry-over action items
- new action items
- owner
- due date
- concrete process change

Avoid generic morale summaries. Ask before creating, appending to, or replacing
a retro file.

## Handoff

After any planning write, report:

- changed files
- epics/stories/sprint/retro affected
- estimates or scope verdicts
- QA plan status
- blockers
- next `/sprint-plan`, `/dev-story`, `/smoke-check`, or `/gate-check` step
