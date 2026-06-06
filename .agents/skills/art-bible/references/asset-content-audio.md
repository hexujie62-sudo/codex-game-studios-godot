# Asset, Content, Audit, And Audio Reference

Use this reference when `/art-bible` is handling asset specs, asset manifests,
asset audits, content audits, or audio design. Do not read archived old Skills.

## Entity And Screen Inventory

Create `design/assets/entity-inventory.md` when the project needs a master list
of visual/audio/UI production targets.

Read:

- `design/gdd/systems-index.md`
- all relevant `design/gdd/*.md`
- `design/art/art-bible.md`
- optional `design/narrative/**`

Extract named entities, enemies, characters, buildings, items, environments,
VFX events, UI screens, HUD elements, and audio needs. Present a proposed
inventory before writing.

Write only after approval:

```text
May I write the entity inventory to `design/assets/entity-inventory.md`?
```

Inventory sections:

- Entities
- Environments
- UI Screens
- HUD Elements
- VFX
- Audio
- Open Questions

## Asset Specs

Use asset specs when a system, level, entity, character, UI screen, VFX event, or
audio need requires production-ready direction.

Required reads:

- `design/art/art-bible.md`; if missing, stop and ask the user to run `/art-bible`
  for visual direction first.
- Source document by target:
  - system: `design/gdd/[target-name].md`
  - level: `design/levels/[target-name].md`
  - entity/character: `design/assets/entity-inventory.md` and optional
    `design/narrative/**`
  - UI/screen: `design/ux/[screen-or-flow].md`
- `design/assets/asset-manifest.md` if it exists, to avoid duplicate IDs.

Output file:

```text
design/assets/specs/[target-name]-assets.md
```

For each asset, include:

- Asset ID, assigned globally as `ASSET-001`, `ASSET-002`, etc.
- Name and category.
- Source requirement and referenced GDD/art/UX section.
- Purpose in gameplay, UI, or presentation.
- 2-3 sentence visual or sonic description.
- Art bible rules that govern the asset.
- AI generation prompt when relevant.
- Negative prompt or explicit avoid-list when relevant.
- Godot constraints: import type, expected resolution, texture/audio format,
  material/shader considerations, and performance budget notes.
- Status: Needed / In Progress / Delivered / Deprecated.

After approval, ask:

```text
May I write the spec to `design/assets/specs/[target-name]-assets.md`?
```

Then update `design/assets/asset-manifest.md` after separate approval:

```text
May I update `design/assets/asset-manifest.md`?
```

Manifest minimum structure:

```markdown
# Asset Manifest

## Progress Summary

| Category | Needed | Specced | Delivered | Notes |
|---|---:|---:|---:|---|

## Assets by Context

### [Target Type]: [Target Name]

| Asset ID | Name | Category | Status | Spec Path | Referenced By |
|---|---|---|---|---|---|
```

Shared asset protocol:

- Before assigning a new ID, search existing manifest/specs for reusable assets.
- If an asset can be shared, reuse the existing `ASSET-ID` and update
  `Referenced By`.
- Do not create duplicate assets for the same visual or audio role.

## Asset Audit

Use for delivered assets under:

- `assets/art/**/*`
- `assets/audio/**/*`
- `assets/vfx/**/*`
- `assets/shaders/**/*`
- `assets/data/**/*`

Read standards from `design/art/art-bible.md`, `design/assets/asset-manifest.md`,
and `AGENTS.md`.

Checks:

- lowercase/snake_case filenames unless a toolchain requires otherwise.
- source files and generated/imported files are distinguishable.
- Godot-compatible formats and import expectations.
- file size and resolution against budget.
- broken references: code or scenes reference assets that do not exist.
- orphaned assets: files with no known reference.
- missing manifest entries for delivered files.

Report format:

```markdown
# Asset Audit — [date]

## Summary

- Total assets scanned: [N]
- Naming violations: [N]
- Size violations: [N]
- Format violations: [N]
- Orphaned assets: [N]
- Missing assets: [N]

## Findings

| Severity | Path | Issue | Recommended action |
|---|---|---|---|

## Verdict

[COMPLIANT / WARNINGS / NON-COMPLIANT]
```

Only write the report after approval.

## Content Audit

Use when the question is whether specified content exists, not whether individual
files are formatted correctly.

Read:

- `design/gdd/systems-index.md`
- GDDs that mention explicit counts or content types
- `design/assets/entity-inventory.md`
- `design/assets/asset-manifest.md`

For Godot projects, scan:

- scenes: `**/*.tscn`
- resources: `**/*.tres`, `**/*.res`
- data: `assets/data/**/*.json`, `assets/data/**/*.yaml`, `assets/data/**/*.csv`
- dialogue/narrative data if present
- audio/art/vfx folders when content counts include them

Compare specified counts against found content. If a GDD has no auditable count,
do not invent one; report it as "unspecified".

Output:

```markdown
# Content Audit — [date]

## Summary

- Scope: [Full audit | System: name]
- Complete content groups: [N]
- Partial content groups: [N]
- Missing content groups: [N]
- Unspecified content groups: [N]

## Gap Table

| System | Content type | Specified | Found | Status | Evidence |
|---|---|---:|---:|---|---|

## High Priority Gaps

## Unspecified Content Counts

## Recommendation
```

Verdict: `COMPLETE` after presenting the audit. Use `CONCERNS` if high-priority
gaps exist.

## Audio Design

Use when the user asks for audio direction/specs, not audio implementation.

Read:

- relevant `design/gdd/*.md`
- `design/audio/sound-bible.md` if it exists
- existing `assets/audio/**`
- `design/art/art-bible.md` for mood and feedback alignment

Output:

```text
design/audio/audio-[feature].md
```

Minimum sections:

- Audio role and player feedback goal.
- Event list with trigger, priority, and gameplay meaning.
- Sonic direction: texture, rhythm, intensity, reference language.
- Accessibility: sudden loud sounds, high-frequency alerts, visual fallback for
  important audio cues.
- Godot implementation notes: AudioStreamPlayer usage, bus/mixer strategy,
  preload vs stream, loop points, and memory budget.
- Asset list and status.
- Open questions and implementation handoff.

If gameplay code, mixer setup, or runtime integration is requested, hand off to
`/dev-story`. `/art-bible` owns specs and evidence, not implementation.

Verdict: `COMPLETE` when the design document is produced, `BLOCKED` when required
GDD/art context is missing and the user declines to provide it.
