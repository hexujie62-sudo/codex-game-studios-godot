# Prototype Validation Reference

Use this reference when `/brainstorm` needs to validate a risky concept before
full GDD work, or when the user asks for a prototype, spike, pivot, or kill
decision. Do not read archived old Skills.

## When To Prototype

Prototype only one risky question:

- Does the core verb feel good?
- Are the rules interesting before content exists?
- Is the UI/control loop understandable?
- Can the technical approach work in Godot within the scope?

Do not let a prototype become a parallel production branch. Production code must
not import from `prototypes/`; if the concept proceeds, rebuild production code
cleanly from the documented lesson.

## Output Paths

Concept prototype:

```text
prototypes/[concept-name]-concept/
prototypes/[concept-name]-concept/README.md
prototypes/[concept-name]-concept/REPORT.md
```

Path-specific outputs:

- HTML: `prototypes/[concept-name]-concept/prototype.html`
- Engine/Godot: a minimal runnable Godot project under
  `prototypes/[concept-name]-concept/`
- Paper/rules: `rules.md` and `play-log.md`
- Pivot: `PIVOT-NOTE.md`
- Killed concepts: `prototypes/GRAVEYARD.md`
- Spike: `prototypes/[concept-name]-spike-[date]/SPIKE-NOTE.md`

Update `prototypes/index.md` after approval with concept name, date, path,
prototype path, verdict, and report link.

## Path Choice

| Question | Preferred path | Why |
|---|---|---|
| Moment-to-moment feel, action, platforming, racing, physics, atmosphere | Godot engine prototype | Browser timing can lie about feel |
| Turn-based logic, idle, simple puzzle, menu-heavy loop | HTML or paper | Fast to share and iterate |
| Card, economy, 4X, strategy, RPG rules | Paper or spreadsheet first | Validates rules before code |
| Narrative/dialogue | Paper, Twine, Ink, or Yarn-style script | Story pacing is the mechanic |

Rule of thumb:

- "Does this feel right?" -> Godot engine prototype.
- "Are these rules interesting?" -> Paper/spreadsheet.
- "Is this logic clear?" -> HTML or paper.

HTML prototypes are convenient to distribute, but do not use them to validate
action timing, physics, aiming, rhythm, or atmosphere.

## Prototype Plan

Before writing files, define:

- Hypothesis: one falsifiable sentence.
- Success criteria: what would prove `PROCEED`.
- Failure criteria: what would force `PIVOT` or `KILL`.
- Minimum playable surface: the smallest build/ruleset that tests the question.
- Hard cap: one day for a concept prototype unless the user explicitly approves
  a longer Godot path.

Ask before creating files:

```text
May I create the prototype directory at `prototypes/[concept-name]-concept/`?
```

## Debrief And Report

Capture:

- What was tested.
- What the user/player did.
- What felt good or confusing.
- What changed from the original concept.
- Evidence screenshots/logs/notes if available.
- Verdict: `PROCEED`, `PIVOT`, or `KILL`.

Ask before writing:

```text
May I write this report to `prototypes/[concept-name]-concept/REPORT.md`?
```

Verdict meanings:

- `PROCEED`: use the result to inform `/art-bible` and `/design-system`.
- `PIVOT`: write `PIVOT-NOTE.md` with what worked, what failed, and the next
  hypothesis. If the same concept pivots three times, force a kill discussion.
- `KILL`: append the concept to `prototypes/GRAVEYARD.md` after approval, with
  the reason and any reusable lessons.

Spike mode is smaller than a concept prototype. It writes only
`SPIKE-NOTE.md`, has no `PROCEED/PIVOT/KILL` verdict, and informs whether a
mechanic or technical approach should enter the backlog.

## Handoff

If `PROCEED`, update the concept/GDD facts before downstream design continues.
If `PIVOT`, return to `/brainstorm` with the pivot note. If `KILL`, stop or start
a fresh concept; do not keep polishing a failed prototype just because files
exist.
