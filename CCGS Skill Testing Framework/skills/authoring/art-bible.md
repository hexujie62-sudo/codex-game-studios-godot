# Skill Test Spec: /art-bible

## Skill Summary

`/art-bible` is the single art, asset, audio, UX, and UI-spec entrypoint. The
main `SKILL.md` keeps the guided art bible workflow, preserved output paths,
review policy, collaboration protocol, and reference loading rules. Detailed
asset/content/audio and UX/UI behavior lives in one-level `references/` files
that are loaded only when the user's request needs them.

The skill must not depend on archived legacy Skills during normal use. Old
visible routes such as `asset-spec`, `asset-audit`, `content-audit`,
`ux-design`, `ux-review`, `team-ui`, and `team-audio` may remain route labels,
but their durable behavior must be present in `/art-bible` or its direct
references.

Review policy is fixed Lean. `AD-ART-BIBLE` is not a phase gate; section
drafting may still delegate to art/UX/technical agents where the live skill
requires it, but the old full/solo review-mode branching must not return.

---

## Static Assertions

Verified automatically by `/skill-create-ccgs` internal static check plus this
spec.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`,
  `user-invocable`, `allowed-tools`
- [ ] Has at least two phase headings
- [ ] Contains verdict keywords: `COMPLETE` and at least one concern/blocking
  verdict such as `CONCERNS` or `BLOCKED`
- [ ] Contains "May I write" language for authored artifacts
- [ ] Documents fixed Lean review policy and states that `AD-ART-BIBLE` is not a
  phase gate
- [ ] Has a next-step handoff to current core Skills such as `/design-system`,
  `/setup-engine`, `/create-architecture`, or `/dev-story`
- [ ] Directly links the three reference files:
  `references/asset-content-audio.md`, `references/ux-ui.md`, and
  `references/absorption-map.md`
- [ ] Normal-use instructions do not require reading `.agents/skills-archive/`

---

## Reference Split Checks

| Request area | Required source |
|---|---|
| art bible authoring | `SKILL.md` only unless the user also asks for assets, UX, audit, or audio |
| asset specs, manifests, asset audit, content audit, audio design | `references/asset-content-audio.md` |
| UX specs, HUD specs, interaction patterns, UX review, UI handoff | `references/ux-ui.md` |
| future governance audit of absorbed legacy behavior | `references/absorption-map.md` |

Checks:

- [ ] Reference files are one level below the skill folder.
- [ ] Reference files contain the old Skills' stable paths, verdicts, ID rules,
  and handoff boundaries.
- [ ] Reference files do not tell Codex to read archived old Skills for normal
  operation.
- [ ] Legacy command names appear only as route labels or absorption records, not
  as content dependencies.

---

## Test Cases

### Case 1: Core Art Bible Authoring

**Fixture:**

- No existing `design/art/art-bible.md`
- `design/gdd/game-concept.md` exists with title, pillars, pitch, and visual
  identity anchor
- `.codex/docs/technical-preferences.md` exists with Godot constraints

**Input:** `/art-bible`

**Expected behavior:**

1. Skill reads the game concept and technical preferences.
2. Skill asks scope and reference-art questions before authoring.
3. Skill authors the requested art bible sections through the collaborative
   protocol.
4. Skill asks before every section write to `design/art/art-bible.md`.
5. Skill notes `AD-ART-BIBLE skipped -- Lean policy` and runs the internal
   sign-off checklist instead of a director phase gate.
6. Skill records review status in the art bible header and returns `COMPLETE`
   when the requested sections are written.

**Assertions:**

- [ ] Does not ask the user to choose full/lean/solo mode.
- [ ] Does not run `AD-ART-BIBLE` as a phase gate.
- [ ] Existing section content is preserved in retrofit mode.
- [ ] Uses current core next-step options, not old visible commands.
- [ ] Does not read `.agents/skills-archive/`.

---

### Case 2: Asset Spec Or Manifest Request

**Fixture:**

- `design/art/art-bible.md` exists
- Relevant source GDD or entity inventory exists
- `design/assets/asset-manifest.md` may or may not exist

**Input:** `/art-bible assets for [target]`

**Expected behavior:**

1. Skill loads `references/asset-content-audio.md`.
2. Skill reads the art bible and target source document.
3. Skill assigns globally sequential `ASSET-###` IDs while checking for reusable
   existing assets.
4. Skill drafts `design/assets/specs/[target-name]-assets.md`.
5. Skill asks before writing the spec.
6. Skill asks separately before updating `design/assets/asset-manifest.md`.

**Assertions:**

- [ ] Does not invoke or read a separate `asset-spec` Skill.
- [ ] Preserves asset output paths and manifest structure.
- [ ] Preserves shared asset ID and reuse protocol.
- [ ] Includes Godot import/performance constraints.
- [ ] Returns `COMPLETE` or `BLOCKED` with the missing upstream artifact named.

---

### Case 3: UX, HUD, Or Interaction Pattern Request

**Fixture:**

- `design/gdd/game-concept.md` exists
- Relevant GDD or player journey exists
- `design/art/art-bible.md` exists

**Input:** `/art-bible ux hud`

**Expected behavior:**

1. Skill loads `references/ux-ui.md`.
2. Skill chooses the correct output path such as `design/ux/hud.md`,
   `design/ux/[screen-or-flow].md`, or
   `design/ux/interaction-patterns.md`.
3. Skill creates a skeleton only after approval.
4. Skill authors sections with purpose, layout, states, interactions,
   accessibility, and testable acceptance criteria.
5. Skill hands implementation to `/dev-story` instead of implementing UI code.

**Assertions:**

- [ ] Does not invoke or read separate `ux-design`, `ux-review`, or `team-ui`
  Skills.
- [ ] Preserves UX/HUD output paths and skeletons.
- [ ] Preserves UX review verdicts: `APPROVED`, `NEEDS REVISION`,
  `MAJOR REVISION NEEDED`.
- [ ] Includes Godot UI constraints such as Control hierarchy, Theme resources,
  focus, input actions, and scalable text.
- [ ] Does not modify reviewed UX documents without approval.

---

### Case 4: Asset Or Content Audit Request

**Fixture:**

- `design/art/art-bible.md` exists
- `design/assets/asset-manifest.md` exists
- Godot scenes/resources and asset folders exist

**Input:** `/art-bible audit assets`

**Expected behavior:**

1. Skill loads `references/asset-content-audio.md`.
2. Skill scans Godot-relevant asset, scene, resource, and data paths.
3. Skill reports naming, format, size, missing reference, orphan, and manifest
   issues.
4. Skill uses audit verdicts `COMPLIANT`, `WARNINGS`, or `NON-COMPLIANT`.
5. Skill asks before writing an audit report.

**Assertions:**

- [ ] Does not invoke or read separate `asset-audit` or `content-audit` Skills.
- [ ] Does not include Unity/Unreal scan paths in the preserved Godot-only audit.
- [ ] Reports unspecified content counts instead of inventing numbers.
- [ ] Returns a clear verdict and recommended action list.

---

### Case 5: Audio Design Request

**Fixture:**

- Relevant GDD exists
- `design/art/art-bible.md` exists
- Existing `design/audio/sound-bible.md` may or may not exist

**Input:** `/art-bible audio for combat feedback`

**Expected behavior:**

1. Skill loads `references/asset-content-audio.md`.
2. Skill reads the relevant GDD, existing sound bible if present, existing audio
   assets, and the art bible.
3. Skill drafts `design/audio/audio-[feature].md` with event list, sonic
   direction, accessibility, Godot implementation notes, asset list, open
   questions, and handoff.
4. Skill asks before writing the audio design file.
5. Skill hands runtime integration to `/dev-story`.

**Assertions:**

- [ ] Does not invoke or read a separate `team-audio` Skill.
- [ ] Preserves audio output path and design sections.
- [ ] Keeps implementation boundary out of `/art-bible`.
- [ ] Returns `COMPLETE` or `BLOCKED` with missing upstream context named.

---

## Protocol Compliance

- [ ] `SKILL.md` stays lean enough to load as the main workflow and puts detailed
  stable behavior in direct references.
- [ ] References are loaded conditionally by request area.
- [ ] Old archive directories are not used as normal references.
- [ ] Route aliases can translate old user wording to `/art-bible`, but aliases
  are not content sources.
- [ ] Every writeable artifact requires explicit approval before writing.
- [ ] Verdict is `COMPLETE` when requested artifacts/reviews are complete, or
  `CONCERNS`/`BLOCKED` when required context is missing or unresolved.

---

## Coverage Notes

- This spec intentionally does not preserve old full/solo review-mode cases.
  Fixed Lean is the current platform policy.
- This spec treats old command names as compatibility labels only. If a future
  audit finds a hard rule missing from `/art-bible`, it should be added to the
  relevant `references/` file, not restored as a visible Skill.
