# Design System Absorption Map

This file records how old visible Skills were absorbed into `/design-system`.
It is for governance/audit work, not normal GDD authoring.

| Old Skill | Kept In | Core Value Preserved | Removed As Redundant |
|---|---|---|---|
| `map-systems` | `references/system-index-patch-impact.md` | systems index path, dependency mapping, circular dependency check, priority/design order, status values, write approval | separate command usage and repeated context-reading prose |
| `quick-design` | `references/system-index-patch-impact.md` | quick spec path, change classification, redirect boundary, affected systems, acceptance criteria, systems-index update ask | old standalone command and broad examples |
| `propagate-design-change` | `references/system-index-patch-impact.md` | changed-GDD diff, ADR impact classifications, traceability update, change-impact output, non-destructive ADR status rule | old command framing and architecture gate |
| `design-review` | `references/review-consistency-balance.md` | single-GDD review checklist, review log path, systems-index status update, verdicts | full/solo gate branches and standalone command |
| `review-all-gdds` | `references/review-consistency-balance.md` | cross-GDD report path, PASS/CONCERNS/FAIL, dependency/formula/economy/pillar/scenario checks | separate holistic command and Opus-tier framing |
| `consistency-check` | `references/review-consistency-balance.md` | registry path, grep-first scan, conflict/stale/unverifiable findings, reflexion log, no-delete registry rule | old standalone command and repeated next-step prose |
| `balance-check` | `references/review-consistency-balance.md` | data-first balance check, output path, health labels, degenerate strategy/progression analysis, change-impact reminder | taste-based judging risk and standalone command |

Rules:

- Normal `/design-system` use must never read `.agents/skills-archive/`.
- If a future audit finds a missing hard rule, add it to one of the direct
  references, not back into a legacy Skill.
- Do not re-add generic "read context and summarize" text unless it changes an
  artifact path, verdict, status, write boundary, or handoff.
