# Art Bible Absorption Map

This file records how old visible Skills were absorbed into `/art-bible`.
It is for governance/audit work, not normal art bible authoring.

| Old Skill | Kept In | Core Value Preserved | Removed As Redundant |
|---|---|---|---|
| `asset-spec` | `references/asset-content-audio.md` | entity inventory, asset spec output path, manifest update, global `ASSET-###` IDs, shared asset protocol, AI prompts, Godot constraints | old review mode branches, separate command usage, repeated context-reading prose |
| `asset-audit` | `references/asset-content-audio.md` | asset scan paths, naming/format/size/reference/orphan checks, COMPLIANT/WARNINGS/NON-COMPLIANT verdict | separate command entry and next-step links to old commands |
| `content-audit` | `references/asset-content-audio.md` | GDD count extraction, Godot-oriented implementation scan, gap table, unspecified-count handling | Unity/Unreal scan paths and standalone summary mode |
| `team-audio` | `references/asset-content-audio.md` | audio design output, event list, accessibility, memory/Godot audio notes, implementation handoff boundary | full team orchestration wrapper and non-Godot middleware examples |
| `ux-design` | `references/ux-ui.md` | UX/HUD/pattern output paths, skeletons, required reads, section-by-section writes, accessibility and acceptance criteria | long per-section teaching prose and old separate command usage |
| `ux-review` | `references/ux-ui.md` | APPROVED/NEEDS REVISION/MAJOR REVISION NEEDED verdicts, review checklist, no silent edits | standalone command entry and duplicate argument parsing |
| `team-ui` | `references/ux-ui.md` | UX spec -> review -> visual design -> implementation handoff, pattern library requirement, accessibility blockers, Godot UI notes | full team orchestration wrapper and implementation ownership inside art/UX skill |

Rules:

- Normal `/art-bible` use must never read `.agents/skills-archive/`.
- If a future audit finds a missing hard rule, add it to the relevant reference,
  not back into a legacy Skill.
- If a removed paragraph is just "read context, summarize, ask user", do not
  re-add it.
