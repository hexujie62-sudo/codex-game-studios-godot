# CCGS Skill Testing Framework — Codex Instructions

This folder is the quality assurance reference layer for Codex Game Studios
Skills and Agents. It is self-contained and separate from any game project.

Use this folder through `/skill-create-ccgs`. Do not expose separate testing or
improvement commands to the user.

## Key Files

| File | Purpose |
|---|---|
| `catalog.yaml` | Master registry for Skills and Agents. Contains category, spec path, and last-check tracking fields. |
| `quality-rubric.md` | Category-specific pass/fail metrics. Read the matching `###` section during internal verification. |
| `skills/[category]/[name].md` | Behavioral spec for a Skill. |
| `agents/[tier]/[name].md` | Behavioral spec for an Agent. |
| `templates/skill-test-spec.md` | Template for writing new Skill spec files. |
| `templates/agent-test-spec.md` | Template for writing new Agent spec files. |
| `results/` | Optional saved verification output. Gitignored. |

## Path Conventions

- Skill specs: `CCGS Skill Testing Framework/skills/[category]/[name].md`
- Agent specs: `CCGS Skill Testing Framework/agents/[tier]/[name].md`
- Catalog: `CCGS Skill Testing Framework/catalog.yaml`
- Rubric: `CCGS Skill Testing Framework/quality-rubric.md`

The `spec:` field in `catalog.yaml` is the authoritative path for each Skill or
Agent spec. Always read it rather than guessing.

## Internal Verification Workflow

When `/skill-create-ccgs` changes a Skill:

1. Read `catalog.yaml` to get the Skill's `spec:` path and `category:`.
2. Read the Skill at `.agents/skills/[name]/SKILL.md`.
3. Read the spec at the `spec:` path.
4. Evaluate static structure, behavioral cases, category rubric, route index,
   catalog coverage, and workflow insertion.
5. If verification fails, propose a minimal repair and rerun verification.

The user should not be asked to switch to another Skill to test or improve a
Skill change.

## Spec Validity Note

Specs describe current expected behavior, but they may encode old assumptions.
When a Skill misbehaves in practice, correct the Skill and update the spec so
the framework reflects the fixed behavior.

## Deletability

This folder is optional QA evidence for the platform. Removing it from a game
project does not remove the Skills themselves, but public platform releases
should keep it because `/skill-create-ccgs` uses it for governance.

