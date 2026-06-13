# CFG Generated Artifact Governance

This file defines how CFG Skills may create or update durable files. It is not a
project fact source; it is a maintenance contract for generated artifacts.

## Rule

Any Skill that creates or updates a durable file must know:

- owner lane;
- consumer;
- lifetime;
- update trigger;
- stale condition;
- directory;
- enforcer;
- conflict risk.

If those answers are missing, the Skill must not create the file. It should
report the missing owner/consumer/trigger instead.

## Source Priority

Generated files do not override these authority sources:

| Authority | Source |
|---|---|
| Active production queue | `production/session-state/active.md` |
| Lane recovery state | `production/session-state/windows/*.md` |
| Work-order scope and verdict | `production/work-orders/*.md` |
| Canon/player-facing facts | `production/project-canon.md` |
| CFG routing and Skill ownership | `.codex/docs/skill-route-index.yaml` and `.agents/skills/` |

## Skill Artifact Matrix

| Skill | Lane / stage | Durable outputs | Lifetime | Consumer | Maintenance trigger | Enforcer |
|---|---|---|---|---|---|---|
| `/start` | A-producer / onboarding | initial `active.md`, initial A lane when absent | recovery-state | `/window-cfg`, `/help`, hooks | first session, project adoption, missing lane bootstrap | `/window-cfg audit`, session hooks |
| `/window-cfg` | Any lane / support | lane files, `active.md` registry, optional archive on compact | rolling recovery-state | all lanes, `/help`, hooks | lane takeover, handoff, compaction, audit concerns | `/window-cfg audit`, checkpoint policy |
| `/skill-create-cfg` | Z-platform / support | Skill files, references, route/workflow updates, test specs, governance docs | rolling framework source | `/help`, hooks, Skill test catalog, future sessions | any Skill add/modify/delete/rename/test/governance change | this document, quality rubric, route/catalog scan |
| `/setup-engine` | Z-platform + B-dev / concept | technical preferences, engine references, minimal test setup notes | rolling technical baseline | all implementation/review Skills | engine version/tooling/test foundation changes | setup Skill handoff, B-dev evidence |
| `/brainstorm` | A-producer / concept | game concept, validation scope, optional prototype plan | rolling design source | `/design-system`, `/art-bible`, `/create-architecture`, A-producer | concept approval or design pivot | A-producer, `/gate-check` |
| `/design-system` | A-producer / systems-design | systems index, GDDs, design patches/reviews | rolling design source | `/create-architecture`, `/art-bible`, work orders, D-director | system added/changed, D/A decision, work-order scope change | A-producer, `/gate-check` |
| `/art-bible` | C-art + A-producer / concept-pre-production | art bible, asset specs, asset manifest, UX specs | rolling art/UX source | C-art, B-dev, D-director, work orders | new visual entity, UI screen, asset need, D verdict | C-art evidence, D-director verdict |
| `/create-architecture` | A-appointed technical owner + B-dev / technical-setup | architecture doc, ADRs, control manifest, traceability only when consumed | rolling architecture source | B-dev, `/code-review`, `/gate-check`, named work orders | architecture boundary change, accepted ADR, work-order dependency, review finding | artifact contract, `/code-review`, `/gate-check` |
| `/code-review` | B-dev / production | read-only findings by default; report only when requested | evidence | B-dev, A-producer, D-director when player-facing | user asks for report or review evidence needed | review output rules |
| `/bug-report` | A-producer + owner lane / production | bug report or triage note | rolling backlog item / evidence | owner lane, A-producer, release | bug discovered, regression, hotfix need | work-order queue, owner lane handoff |
| `/gate-check` | A-producer + D-director / support | read-only verdict by default; report only when requested | evidence | user, A-producer, D-director | phase/milestone readiness check | gate-check verdict rules |
| `/release-checklist` | A-producer / release | release checklist, changelog, patch notes when requested | release evidence | user, release owner | release milestone, patch, store submission | release Skill handoff |

## Directory Rules

- `production/work-orders/` is the only work-order directory.
- `production/session-state/` is recovery state, not a report archive.
- `production/dev-tasks/` is B-dev evidence and implementation reports.
- `artifacts/` is capture/evidence output, normally owned by C-art unless a
  work order says otherwise.
- `docs/architecture/` is allowed only for architecture artifacts with named
  consumers and maintenance triggers.
- Do not create `production/epics/`, `production/sprints/`, or
  `production/sprint-status.yaml` as active CFG state.

## Review Checklist

Before accepting a generated artifact:

1. Is the owner lane named?
2. Is at least one real consumer named?
3. Is the file one-shot evidence, rolling source, source-of-truth, or recovery
   state?
4. What event makes it stale?
5. What Skill, hook, lane, or file rule will notice staleness?
6. Does it duplicate active queue, work order, canon, or lane state?

Verdict: `SAFE`, `REWRITE REQUIRED`, `DELETE`, or `BLOCKED`.

