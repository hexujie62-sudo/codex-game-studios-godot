# Docs Directory

When authoring or editing files in this directory, follow these standards.

## Architecture Decision Records (`docs/architecture/`)

Use the ADR template: `.codex/docs/templates/architecture-decision-record.md`

**Required sections:** Title, Status, Context, Decision, Consequences,
ADR Dependencies, Engine Compatibility, GDD Requirements Addressed

**Status lifecycle:** `Proposed` → `Accepted` → `Superseded`
- Work orders may cite `Proposed` ADRs only as risk context; implementation
  constraints must come from `Accepted` ADRs or explicit work-order decisions.
- Use `/create-architecture ADR` to create ADRs through the guided flow.

**TR Registry:** `docs/architecture/tr-registry.yaml`
- Stable requirement IDs (e.g. `TR-MOV-001`) that link GDD requirements to ADRs,
  work orders, and evidence when a consumer exists.
- Never renumber existing IDs — only append new ones
- Updated by `/create-architecture review` only when a durable traceability
  consumer exists.

**Control Manifest:** `docs/architecture/control-manifest.md`
- Flat programmer rules sheet: Required / Forbidden / Guardrails per layer
- Date-stamped `Manifest Version:` in header
- Named work orders or B-dev reports cite this version when it is consumed;
  `/create-architecture`, `/code-review`, or `/gate-check` checks staleness.

**Validation:** Run `/create-architecture review` after completing a set of ADRs.

## Engine Reference (`docs/engine-reference/`)

Version-pinned engine API snapshots. **Always check here before using any
engine API** — the LLM's training data predates the pinned engine version.

Current engine: see `docs/engine-reference/godot/VERSION.md`
