---
name: brainstorm
description: "Guided game concept and landing package: use deep co-design interviews, professional design frameworks, and structured exploration to turn an idea or draft into a complete concept package, first complete scope, tool/resource plan, implementation plan, and acceptance criteria."
argument-hint: "[genre/theme hint or open]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, WebSearch, Task, AskUserQuestion
model: sonnet
---

When this skill is invoked:

## Absorbed Responsibilities

This Skill now also absorbs the concept-side of the former `prototype` route:
when an idea is risky or unclear, define the smallest prototype question,
success criteria, and throwaway validation path before moving into full design.

Preserved CCGS value:

- Concept output: `design/gdd/game-concept.md`.
- Prototype evidence, if needed: `prototypes/[name]-concept/README.md` and
  `prototypes/[name]-concept/REPORT.md`.
- Prototype verdicts: `PROCEED`, `PIVOT`, or `KILL` (`ADJUST` maps to
  `PIVOT`; `STOP` maps to `KILL` if old wording appears).
- A prototype should answer one risky question about the core loop, not become a
  parallel production branch.
- If a prototype changes the concept, update the concept/GDD facts before
  downstream design or architecture continues.

## Reference Loading Rules

Do not read `.agents/skills-archive/` during normal use. The old prototype Skill
content has been extracted into direct references:

- For concept prototype, spike, HTML/engine/paper path choice, prototype report,
  pivot, or kill decisions: read `references/prototype-validation.md`.
- For checking what was absorbed during future governance work: read
  `references/absorption-map.md`.

Full concept ideation can run from this SKILL.md alone unless the user asks for
prototype validation or the concept risk is high enough that a prototype question
must be defined before GDD work continues.

1. **Parse the argument** for an optional genre/theme hint (e.g., `roguelike`,
   `space survival`, `cozy farming`). If `open` or no argument, start from
   scratch. Do not parse review mode arguments and do not read or create
   `production/review-mode.txt`. Use the fixed review standard: internal checks
   here, phase-gate director review only in `/gate-check`.

   If the argument or user request is mainly `prototype`, `spike`, `validate`,
   `playtest`, `pivot`, or `kill`, read `references/prototype-validation.md`
   before proceeding.

2. **Check for existing concept work**:
   - Read `design/gdd/game-concept.md` if it exists (resume, don't restart)
   - Read `design/gdd/game-pillars.md` if it exists (build on established pillars)

3. **Run a deep guided design interview before the package.** Do NOT generate
   everything silently — the goal is collaborative exploration where Codex acts
   as a creative facilitator and production partner, not a replacement for the
   human's vision.

   The interview may be long when the concept needs it. Keep asking while the
   answers materially improve the design or landing plan. Each question should
   advance direction, feel, controls, camera, loop, pillars, anti-pillars,
   visual identity, production function coverage, first complete scope, tools,
   resources, risks, or acceptance criteria.

   If the user supplies a strong concept draft, do not force a generic personal
   taste interview unless it is useful, but still run a focused deep interview
   around the draft. Summarize what is already locked, then guide the unresolved
   design and landing decisions. Do not jump straight to final package writing.

   Ask conversationally, not as a checklist. `/brainstorm` should keep going as
   long as the answers are improving the concept, but each turn should do design
   work: write the creative analysis in conversation first, then use
   `AskUserQuestion` only to capture the next meaningful decision with concise
   labels.

   For a named or already-formed concept, do not open with a broad intake form
   covering emotion, controls, structure, visual identity, constraints, and dev
   experience all at once. Summarize the locked facts, pick the next unresolved
   design phase, propose concrete options with reasoning, capture the decision,
   then synthesize it before moving on.

   **Use `AskUserQuestion` selectively** at decision points:
   - Open-ended idea discovery when the user has no direction.
   - Choosing between genuinely different concept directions.
   - Capturing structured choices during the design interview.
   - Approving the complete concept-and-landing package before writes.
   - Deciding a major scope pivot.
   Do not use it for every pillar, visual phrase, speed knob, file path, or
   small section once the direction is clear.

   Professional studio brainstorming principles to follow:
   - Withhold judgment — no idea is bad during exploration
   - Encourage unusual ideas — outside-the-box thinking sparks better concepts
   - Build on each other — "yes, and..." responses, not "but..."
   - Use constraints as creative fuel — limitations often produce the best ideas
   - Time-box each phase — keep momentum, don't over-deliberate early

4. **Output shape: Concept And Landing Package.** Before writing files, present
   one package that includes:
   - game concept, core fantasy, pillars, anti-pillars, player promise;
   - first complete playable/validation scope, not a vague MVP drip-feed;
   - design details needed inside that scope: controls, loop, camera, feedback,
     progression, content beats, failure/success rules;
   - production functions Codex should cover, read from
     `.codex/docs/collaboration-profile.md` when present;
   - required Godot scenes/scripts/resources/tools, placeholder art direction,
     audio/music direction, text/narrative needs, tuning needs, QA checks;
   - risks, assumptions, acceptance criteria, and verification commands.

   Ask for one approval of this package. After approval, write all low-risk
   concept/prototype planning files in that scope without repeated per-file
   confirmations.

   **Anti-drip-feed scope rule**: the first scope is not a tiny placeholder that
   leaves key questions for later. It must be coherent enough to build end to
   end: requirements, tools, resources, acceptance criteria, and validation are
   all described before Codex starts implementation. Use throwaway prototypes
   only to answer a specific risk, then fold the result back into the package.

---

## Phase 1: Creative Discovery

Start by understanding the person, the target experience, and the production
context, not only the game mechanics.

If the user already supplied a concept draft, start from the draft instead of
pretending the project is blank. Still run a deep focused interview. The right
shape is:

1. "What is already locked" — core fantasy, platform, engine, scope, excluded
   mechanics, player promise, or constraints.
2. "What still needs human taste" — emotional anchors, reference games, genre
   likes/dislikes, desired player feeling, or developer constraints that are not
   already answered by the draft.
3. "What is worth exploring next" — the design topics whose answers will improve
   the package: rhythm, loop feel, controls, camera, visual anchor, pillars,
   anti-pillars, first complete scope, tools, assets, risks, or acceptance.
4. Codex recommendation for the current topic, with concise reasoning and
   trade-offs.
5. A user decision or free-form response prompt.
6. Repeat while the interview is still producing useful design decisions. Stop
   only when Codex can draft the complete package without guessing.

For strong drafts, skip generic blank-slate discovery only when those facts are
already answered. Continue through the normal phases by proposing concrete
concept-specific choices, explaining trade-offs, capturing the user's decision,
and synthesizing it into the draft before the next phase.

For open-ended ideation, ask these questions conversationally (not as a checklist):

**Emotional anchors**:
- What's a moment in a game that genuinely moved you, thrilled you, or made
  you lose track of time? What specifically created that feeling?
- Is there a fantasy or power trip you've always wanted in a game but never
  quite found?

**Taste profile**:
- What 3 games have you spent the most time with? What kept you coming back?
  *(Ask this as plain text — the user must be able to type specific game names freely.
  Do NOT put this in an AskUserQuestion with preset options.)*
- Are there genres you love? Genres you avoid? Why?
- Do you prefer games that challenge you, relax you, tell you stories,
  or let you express yourself? *(Use `AskUserQuestion` for this — constrained choice.)*

**Practical constraints** (shape the sandbox before brainstorming).
Bundle these into a single multi-tab `AskUserQuestion` with these exact tab labels:
- Tab "Experience" — "What kind of experience do you most want players to have?" (Challenge & Mastery / Story & Discovery / Expression & Creativity / Relaxation & Flow)
- Tab "Timeline" — "What's your realistic development timeline?" (Weeks / Months / 1-2 years / Multi-year)
- Tab "Dev level" — "Where are you in your dev journey?" (First game / Shipped before / Professional background)

Use exactly these tab names — do not rename or duplicate them.

**Synthesize** the answers into a **Creative Brief** — a 3-5 sentence
summary of the emotional goals, taste profile, production function coverage, and
constraints. If the brief is obvious from the user's draft, present it and move
directly into the package instead of asking for a separate confirmation.

---

## Phase 2: Concept Generation

Using the creative brief as a foundation, generate **3 distinct concepts**
that each take a different creative direction. Use these ideation techniques:

**Technique 1: Verb-First Design**
Start with the core player verb (build, fight, explore, solve, survive,
create, manage, discover) and build outward from there. The verb IS the game.

**Technique 2: Mashup Method**
Combine two unexpected elements: [Genre A] + [Theme B]. The tension between
the two creates the unique hook. (e.g., "farming sim + cosmic horror",
"roguelike + dating sim", "city builder + real-time combat")

**Technique 3: Experience-First Design (MDA Backward)**
Start from the desired player emotion (aesthetic goal from MDA framework:
sensation, fantasy, narrative, challenge, fellowship, discovery, expression,
submission) and work backward to the dynamics and mechanics that produce it.

For each concept, present:
- **Working Title**
- **Elevator Pitch** (1-2 sentences — must pass the "10-second test")
- **Core Verb** (the single most common player action)
- **Core Fantasy** (the emotional promise)
- **Unique Hook** (passes the "and also" test: "Like X, AND ALSO Y")
- **Primary MDA Aesthetic** (which emotion dominates?)
- **Estimated Scope** (small / medium / large)
- **Why It Could Work** (1 sentence on market/audience fit)
- **Biggest Risk** (1 sentence on the hardest unanswered question)

Present all three. Then use `AskUserQuestion` to capture the selection.

**CRITICAL**: This MUST be a plain list call — no tabs, no form fields. Use exactly this structure:

```
AskUserQuestion(
  prompt: "Which concept resonates with you? You can pick one, combine elements, or ask for fresh directions.",
  options: [
    "Concept 1 — [Title]",
    "Concept 2 — [Title]",
    "Concept 3 — [Title]",
    "Combine elements across concepts",
    "Generate fresh directions"
  ]
)
```

Do NOT use a `tabs` field here. The `tabs` form is for multi-field input only — using it here causes an "Invalid tool parameters" error. This is a plain `prompt` + `options` call.

Never pressure toward a choice — let them sit with it.

---

## Phase 3: Core Loop Design

For the chosen concept, build the core loop as part of the package. The core loop
is the beating heart of the game, but do not turn it into a long sequence of
small approvals.

**30-Second Loop** (moment-to-moment):

If the concept is unclear, ask one bundled question covering the most important
loop decisions. Derive the options from the concept, don't hardcode them:

1. **Core action feel** — prompt: "What's the primary feel of the core action?" Generate 3-4 options that fit the concept's genre and tone, plus a free-text escape (`I'll describe it`).

2. **Key design dimension** — identify the most important design variable for this specific concept (e.g., world reactivity, pacing, player agency) and ask about it. Generate options that match the concept. Always include a free-text escape.

After capturing answers, analyze: Is this action intrinsically satisfying? What
makes it feel good? Include audio feedback, visual feedback, timing satisfaction,
tactical depth, camera, tuning knobs, and verification criteria in the package.

**5-Minute Loop** (short-term goals):
- What structures the moment-to-moment play into cycles?
- Where does "one more turn" / "one more run" psychology kick in?
- What choices does the player make at this level?

**Session Loop** (30-120 minutes):
- What does a complete session look like?
- Where are the natural stopping points?
- What's the "hook" that makes them think about the game when not playing?

**Progression Loop** (days/weeks):
- How does the player grow? (Power? Knowledge? Options? Story?)
- What's the long-term goal? When is the game "done"?

**Player Motivation Analysis** (based on Self-Determination Theory):
- **Autonomy**: How much meaningful choice does the player have?
- **Competence**: How does the player feel their skill growing?
- **Relatedness**: How does the player feel connected (to characters,
  other players, or the world)?

---

## Phase 4: Pillars and Boundaries

Game pillars are used by real AAA studios (God of War, Hades, The Last of
Us) to keep hundreds of team members making decisions that all point the
same direction. Even for solo developers, pillars prevent scope creep and
keep the vision sharp.

Collaboratively define **3-5 pillars**:
- Each pillar has a **name** and **one-sentence definition**
- Each pillar has a **design test**: "If we're debating between X and Y,
  this pillar says we choose __"
- Pillars should feel like they create tension with each other — if all
  pillars point the same way, they're not doing enough work

Then define **3+ anti-pillars** (what this game is NOT):
- Anti-pillars prevent the most common form of scope creep: "wouldn't it
  be cool if..." features that don't serve the core vision
- Frame as: "We will NOT do [thing] because it would compromise [pillar]"

**Pillar handling**: Pillars, anti-pillars, and visual anchor are core interview
topics, not clerical approval steps. If they are not already locked, present a
proposed set with names, definitions, design tests, and why it fits the concept,
then let the user lock, rename, reframe, swap, combine, or describe their own
direction before drafting the final package. Do not ask for approval of each
individual pillar as a file section, and do not repeat file-write confirmation
after the complete package is approved.

`CD-PILLARS` and `AD-CONCEPT-VISUAL` are not invoked as separate gates. Do not
spawn director agents here; run the internal pillar/visual-anchor check below and
proceed to Phase 5.

Run an internal pillar/visual-anchor check:

- Every pillar has a design test.
- Anti-pillars block likely scope creep.
- Pillars create useful tension instead of restating one idea.
- The visual direction can be derived from the pillar set without contradicting
  platform or scope constraints.

If the internal check has concerns, surface them in the package before asking
for approval. The visual anchor is stored as the **Visual Identity Anchor** and
becomes the foundation of the art bible.

---

## Phase 5: Player Type Validation

Using the Bartle taxonomy and Quantic Foundry motivation model, validate
who this game is actually for:

- **Primary player type**: Who will LOVE this game? (Achievers, Explorers,
  Socializers, Competitors, Creators, Storytellers)
- **Secondary appeal**: Who else might enjoy it?
- **Who is this NOT for**: Being clear about who won't like this game is as
  important as knowing who will
- **Market validation**: Are there successful games that serve a similar
  player type? What can we learn from their audience size?

---

## Phase 6: Scope and Feasibility

Ground the concept in reality:

- **Target platform**: If already stated in the user's brief or existing docs,
  record it without asking. If missing, ask once because it affects Godot export
  risk, UI/input assumptions, and scope. Do not recommend another engine from
  this Skill. This fork is Godot-focused.

- **Godot fit**: note any Godot-specific implications from platform and scope:
  export target, input model, asset volume, UI scale, performance budget, and
  whether the concept needs a small prototype before full GDD work.
- **Art pipeline**: What's the art style and how labor-intensive is it?
- **Content scope**: Estimate level/area count, item count, gameplay hours
- **First complete playable/validation scope**: What coherent range can Codex
  define fully enough to build end to end, including design, tools, assets,
  tests, risks, and acceptance criteria?
- **Biggest risks**: Technical risks, design risks, market risks
- **Scope tiers**: What's the full vision vs. what ships if time runs out?

`TD-FEASIBILITY` is not invoked as a separate gate. Do not spawn a director agent
here; run the internal Godot feasibility check below before scope tier
definition.

Run an internal Godot feasibility check instead:

- Does the concept depend on networking, procedural generation, complex physics,
  heavy simulation, large content volume, or unusual platform requirements?
- Is the core loop feel-sensitive enough to need a concept prototype before GDDs?
- Are the target platform and scope realistic for the user's timeline?

If risk is HIGH, offer to revisit scope or define a prototype question using
`references/prototype-validation.md` before finalising.

`PR-SCOPE` is not invoked as a separate gate. Do not spawn a producer agent here;
run the internal scope check below before document generation.

Run an internal scope check: compare full vision, first complete scope,
timeline, team size, and content count. If the plan is unrealistic, offer to
adjust the first complete scope or document a scope risk before writing the
concept.

---

4. **Generate the game concept document** using the template at
   `.codex/docs/templates/game-concept.md`. Fill in ALL sections from the
   brainstorm conversation, including the MDA analysis, player motivation
   profile, and flow state design sections.

   **Include a Visual Identity Anchor section** in the game concept document with:
   - The selected visual direction name
   - The one-line visual rule
   - The 2-3 supporting visual principles with their design tests
   - The color philosophy summary

   This section is the seed of the art bible — it captures the "everything must
   move" decision before it can be forgotten between sessions.

5. Use one approval for the complete concept-and-landing package:
- Prompt: "Concept and landing package is ready. Approve this package and write the planned files?"
- Options: `[A] Yes — write package` / `[B] Revise package first`

If [B]: ask what to revise at package level. Offer concise options:
`Core direction` / `Scope` / `Controls or loop` / `Art/audio direction` /
`Implementation plan` / `Risks or acceptance criteria` / `Something else`.

After revising, show the changed package summary, then ask once:
`Ready to write the updated package?`
Options: `[A] Yes — write package` / `[B] Revise again`

If yes, generate the document using the template at
`.codex/docs/templates/game-concept.md`, fill in ALL sections from the package,
and write the file, creating directories as needed. If the approved package also
includes a prototype/validation plan, write the low-risk planning files named in
the package without asking again.

**Scope consistency rule**: The "Estimated Scope" field in the Core Identity table must match the full-vision timeline from the Scope Tiers section — not just say "Large (9+ months)". Write it as "Large (X–Y months, solo)" or "Large (X–Y months, team of N)" so the summary table is accurate.

6. **Suggest one next step**, not a long pipeline dump. Pick based on current
   gaps:
   - If engine/tooling is not pinned: `/setup-engine`.
   - If the approved package needs visual/audio asset direction before coding:
     `/art-bible`.
   - If systems need detailed GDDs: `/design-system`.
   - If the first playable scope is ready for technical planning:
     `/create-architecture`.
   - If a scoped Godot prototype plan is already approved and tooling is ready:
     `/sprint-plan` or `/dev-story` depending on existing production artifacts.

7. **Output a summary** with the chosen concept's elevator pitch, pillars,
   primary player type, engine recommendation, biggest risk, and file path.

Verdict: **COMPLETE** — game concept created and handed off for next steps.

---

## Context Window Awareness

This is a multi-phase skill. If context reaches or exceeds 70% during any phase,
append this notice to the current response before continuing:

> **Context is approaching the limit (≥70%).** The game concept document is saved
> to `design/gdd/game-concept.md`. Open a fresh Codex session to continue
> if needed — progress is not lost.

---

## Recommended Next Steps

After the game concept is written, follow the pre-production pipeline in order:
1. `/setup-engine` — configure the engine and populate version-aware reference docs
2. `/art-bible` — establish visual identity before writing any GDDs
3. `/design-system` — decompose the concept into individual systems with dependencies
4. `/design-system [first-system]` — author per-system GDDs in dependency order
5. `/create-architecture` — produce the master architecture blueprint
6. `/create-architecture` — bootstrap TR registry and Requirements Traceability Matrix
7. `/gate-check pre-production` — validate readiness before committing to production

