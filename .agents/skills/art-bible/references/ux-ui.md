# UX And UI Reference

Use this reference when `/art-bible` is handling UX specs, HUD specs,
interaction patterns, UX review, UI visual specs, or UI implementation handoff.
Do not read archived old Skills.

## UX Modes And Output Paths

| Request | Output |
|---|---|
| screen or flow UX spec | `design/ux/[screen-or-flow].md` |
| HUD design | `design/ux/hud.md` |
| interaction patterns | `design/ux/interaction-patterns.md` |
| accessibility requirements | `design/accessibility-requirements.md` |

## Required Reads

Read only what exists and is relevant:

- `design/gdd/game-concept.md`
- `design/player-journey.md`
- `design/gdd/*.md` sections mentioning UI Requirements, UX, HUD, controls, or
  accessibility
- existing `design/ux/*.md`
- `design/ux/interaction-patterns.md`
- `design/art/art-bible.md`
- `design/accessibility-requirements.md`
- `.codex/docs/technical-preferences.md`

If `design/ux/interaction-patterns.md` does not exist, surface the gap. Do not
invent patterns silently; either create the library first or note that new
patterns introduced by this spec must be documented.

## UX Spec Skeleton

Create a skeleton before section authoring when writing a full UX spec:

```markdown
# UX Spec: [Screen Or Flow]

## Purpose & Player Need
## Player Context On Arrival
## Navigation Position
## Entry & Exit Points
## Layout Specification
### Information Hierarchy
### Layout Zones
### Component Inventory
### ASCII Wireframe
## States & Variants
## Interaction Map
## Events Fired
## Transitions & Animations
## Data Requirements
## Accessibility
## Localization Considerations
## Acceptance Criteria
## Open Questions
```

Ask before creating the skeleton:

```text
May I create the skeleton file at `design/ux/[screen-or-flow].md`?
```

Then author section by section. Before each section write:

```text
May I write the [section name] section to `[filepath]`?
```

## HUD Skeleton

Use for `design/ux/hud.md`:

```markdown
# HUD Design

## HUD Philosophy
## Information Architecture
### Full Information Inventory
### Categorization
## Layout Zones
## HUD Elements
## Dynamic Behaviors
## Platform & Input Variants
## Accessibility
## Open Questions
```

HUD-specific checks:

- What information is always visible, contextual, delayed, or hidden?
- Which screen regions are reserved?
- Which elements can animate, pulse, fade, or stack?
- Does each element fit the visual budget and avoid UI clutter?
- Does every critical state have a non-color cue?

## Interaction Pattern Library

Use for `design/ux/interaction-patterns.md`:

```markdown
# Interaction Pattern Library

## Overview
## Pattern Catalog
## Patterns
### [Pattern Name]
- Purpose:
- Used by:
- Inputs:
- States:
- Accessibility:
- Godot implementation notes:
## Gaps & Patterns Needed
## Open Questions
```

When cataloging patterns, read existing UX specs and extract reusable components,
navigation patterns, selection patterns, confirmation flows, error states, and
input handling rules.

## Section Guidance

Purpose & Player Need:

- State why the screen exists for the player, not just for the system.
- Identify the player decision or emotion this screen supports.

Player Context:

- Where did the player come from?
- What pressure are they under?
- What do they need to know immediately?

Layout:

- Define information hierarchy before visual composition.
- Include layout zones and component inventory.
- Use ASCII wireframes when useful; keep them schematic, not decorative.

States & Variants:

- Empty, loading, normal, error, disabled, selected, focused, warning, success.
- Multiplayer/localization/platform variants when relevant.

Interaction Map:

- Inputs, focus order, navigation loops, cancel/back behavior, confirmation and
  destructive action safeguards.
- For Godot, note Control focus behavior, input actions, and gamepad/keyboard
  parity.

Events Fired:

- Name events/signals the UI emits.
- Do not implement them here; hand off to `/dev-story`.

Accessibility:

- Color is never the only state indicator.
- Include scalable text, minimum touch targets, focus visibility, readable
  contrast, motion sensitivity, and audio/visual fallback where relevant.
- Cross-reference `design/accessibility-requirements.md` if it exists.

Acceptance Criteria:

- Include at least one layout/readability criterion.
- Include at least one input/focus criterion.
- Include at least one accessibility criterion.
- Criteria must be testable without reading the design discussion.

## UX Review

Use these verdicts:

- `APPROVED` — spec is complete, consistent, and implementation-ready.
- `NEEDS REVISION` — specific fixable gaps exist.
- `MAJOR REVISION NEEDED` — fundamental player-need, flow, scope, or
  accessibility issues make the spec unsuitable for implementation.

Review checklist:

- Purpose and player need are explicit.
- Entry/exit paths are complete.
- Layout hierarchy and component inventory are clear.
- States and variants cover likely runtime conditions.
- Interaction map covers keyboard, mouse, gamepad, and/or touch as relevant.
- Godot UI constraints are noted: Control hierarchy, CanvasLayer if needed,
  Theme resources, focus, input actions, scalable text.
- Accessibility tier is met or gaps are listed.
- Localization concerns are addressed for text expansion and RTL if relevant.
- Acceptance criteria are testable.
- Visual direction aligns with `design/art/art-bible.md`.

If review fails, present findings before asking whether to revise. Do not modify
the reviewed document without approval.

## UI Team Handoff

`/art-bible` owns UX and visual specs. It does not implement UI code.

When implementation is needed, hand off to `/dev-story` with:

- UX spec path.
- Art bible path.
- Interaction pattern library path.
- Accessibility requirements path.
- Godot UI notes: Control hierarchy, Theme resource expectations, focus order,
  input actions, and CanvasLayer usage if needed.

If implementation introduces a new interaction pattern, require the implementation
story to update `design/ux/interaction-patterns.md`.

Verdict: `COMPLETE` when the UX spec/review/handoff is complete, `BLOCKED` when
required upstream design context is missing and the user declines to provide it.
