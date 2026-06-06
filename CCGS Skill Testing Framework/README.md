# CCGS Skill Testing Framework

Quality assurance reference material for **Codex Game Studios** Skills and Agents.
It tests the framework itself, not any game built with it.

This folder is now an **internal reference library** used by `/skill-create-ccgs`.
Users do not need to run separate Skill testing commands.

The active catalog currently tracks **17 core Skill specs**. Absorbed legacy
specs are intentionally not kept as shadow coverage targets.

---

## What's In Here

```text
CCGS Skill Testing Framework/
├── README.md
├── AGENTS.md
├── catalog.yaml
├── quality-rubric.md
├── skills/
├── agents/
├── templates/
└── results/
```

Important files:

| File | Purpose |
|---|---|
| `catalog.yaml` | Registry for active core Skills, including category, spec path, and last-check fields |
| `quality-rubric.md` | Category-specific pass/fail metrics used by `/skill-create-ccgs` internal verification |
| `skills/[category]/[name].md` | Behavioral specs for active core Skills; absorbed legacy specs should be removed after their durable behavior is migrated |
| `agents/[tier]/[name].md` | Historical agent specs kept as reference material |
| `templates/skill-test-spec.md` | Template for new Skill specs |
| `templates/agent-test-spec.md` | Template for new Agent specs |
| `results/` | Optional saved verification output, gitignored |

---

## How It Is Used

When a Skill is created, modified, merged, deleted, tested, or repaired, use:

```text
/skill-create-ccgs
```

That Skill reads this framework internally and performs:

- static structure checks;
- behavioral spec checks;
- category rubric checks;
- route index and catalog coverage checks;
- workflow insertion checks;
- repair loops when verification fails.

The user should not need to remember separate testing or improve commands.

---

## Skill Categories

| Category | Examples | Key metrics |
|---|---|---|
| `gate` | gate-check | Fixed Lean policy, phase-gate director panel, no auto-advance |
| `review` | absorbed into design-system/create-architecture/code-review | Read-only analysis behavior when used internally |
| `authoring` | design-system, create-architecture, art-bible | Section-by-section or draft-first write approval, skeleton-first where appropriate |
| `readiness` | story-done | Blockers surfaced, evidence checked |
| `pipeline` | dev-story | Upstream dependency check, handoff path clear |
| `analysis` | code-review; design/balance checks inside design-system | Read-only report, verdict keyword, no writes unless approved |
| `team` | absorbed into dev-story, art-bible, smoke-check, release-checklist | Required agents coordinated internally when still needed |
| `sprint` | sprint-plan | Reads sprint data, status keywords present |
| `utility` | start, help, window-ccgs, skill-create-ccgs | Navigation, maintenance, setup, or QA behavior |

---

## Updating The Catalog

`catalog.yaml` tracks coverage for every active Skill that remains in
`.agents/skills/`. It no longer registers archived/absorbed legacy Skills or
historical agent specs. During migration, an old spec may exist briefly; once
its durable behavior is migrated into an active Skill spec or a direct
`references/` file, delete the redundant spec instead of leaving a shadow Skill
pile.

If a Skill is removed from `.agents/skills/`, remove its catalog entry and route
index entry too. If a legacy Skill is absorbed, route it through
`.codex/docs/skill-route-index.yaml` instead of keeping a catalog entry for it.

For new or modified Skills, `/skill-create-ccgs` should update:

- the Skill spec path;
- category;
- priority;
- last-check fields when results are saved.

---

## Writing A New Spec

1. Use `templates/skill-test-spec.md`.
2. Save the spec under `skills/[category]/[skill-name].md`.
3. Register it in `catalog.yaml`.
4. Let `/skill-create-ccgs` run its internal verification.

---

## Optional Folder

This folder is platform QA infrastructure. It can be removed from a lightweight
game project if the project does not need Skill/Agent governance evidence, but
public CCGS platform releases should keep it.

