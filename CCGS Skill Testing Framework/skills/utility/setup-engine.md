# Skill Test Spec: /setup-engine

## Skill Summary

`/setup-engine` is the Godot-only technical setup entrypoint. It resolves the
pinned Godot version, GDScript baseline, local console executable, engine
reference, runtime check status, and minimal test foundation. It produces one
routine Godot setup scope. Invoking `/setup-engine` is treated as the user's
request to complete normal low-risk setup, so the Skill writes routine setup
files directly and asks again only for missing required facts or work outside
routine setup. After setup, it reconnects to the production workflow by reading
the workflow catalog and recommending the first missing required step, not a
generic list of possible commands.

If the approved concept explicitly names a prototype or validation build as the
first complete scope, `/setup-engine` routes to `/brainstorm prototype` before
the document chain because the old `/prototype` route is absorbed into
`/brainstorm`.

The skill does not offer Unity or Unreal configuration in this fork.

---

## Static Assertions

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`,
  `user-invocable`, `allowed-tools`
- [ ] Has at least two phase headings
- [ ] Contains verdict keywords: `COMPLETE`, `CONCERNS`, and `BLOCKED`
- [ ] Defines the routine setup execution boundary
- [ ] Does not require a second write approval for normal setup files after the
  user invokes `/setup-engine`
- [ ] Describes Godot-only behavior and rejects multi-engine setup
- [ ] Reads `.codex/docs/workflow-catalog.yaml` for route-aware production
  rejoin
- [ ] Detects explicit unresolved concept prototype intent before routing to
  required design/art documents
- [ ] Has a single primary next-step handoff based on the first missing required
  workflow step or explicit project prototype blocker, not a generic command
  menu

---

## Test Cases

### Case 1: Godot Setup Executes Without Low-Value Reconfirmation

**Fixture:**

- `.codex/docs/technical-preferences.md` exists with placeholders
- `docs/engine-reference/godot/VERSION.md` exists or can be created
- `tests/` is missing
- User provides or project docs contain a Godot 4.x version

**Input:** `/setup-engine`

**Expected behavior:**

1. Skill resolves Godot version from argument, `AGENTS.md`, technical
   preferences, or engine reference.
2. Skill prepares the routine setup scope covering technical preferences, engine
   reference, test foundation, runtime check status, and concerns.
3. Skill writes low-risk setup files directly because the user invoked
   `/setup-engine`.
4. Skill does not ask `May I update...` or require a second write approval for
   routine setup files.
5. Skill returns `COMPLETE` or `CONCERNS` depending on whether `project.godot`
   and console validation are available.
6. Skill reads the workflow catalog, identifies the current phase, and reports
   the first missing required step as the production rejoin route.

**Assertions:**

- [ ] Engine field is set to Godot 4.x or a pinned Godot version.
- [ ] Language field is GDScript.
- [ ] Godot command is recorded if known.
- [ ] `tests/unit/`, `tests/integration/`, `tests/helpers/`, and `tests/README.md`
  are included when missing.
- [ ] No low-value setup confirmation is requested after `/setup-engine`.
- [ ] Output includes `Production rejoin` with `Where you are`,
  `Current blocker`, `Next`, and `Why`.
- [ ] Output does not end with a bare list such as
  `/brainstorm, /design-system, /create-architecture, or /smoke-check`.
- [ ] Verdict is `COMPLETE` or `CONCERNS`.

---

### Case 2: Missing Project File

**Fixture:**

- Godot console executable is known.
- `project.godot` is missing.

**Input:** `/setup-engine`

**Expected behavior:**

1. Skill records runtime check command and status.
2. Skill does not run `--headless --path . --quit` because no Godot project file
   exists.
3. Skill reports the missing project file as a setup concern.
4. Skill still reconnects to the next workflow step; missing `project.godot`
   does not by itself drop the user out of Concept, art, or design flow.

**Assertions:**

- [ ] Runtime check is not falsely reported as passing.
- [ ] `project.godot` missing is named explicitly.
- [ ] A single next workflow command is still recommended when setup can
  otherwise complete.
- [ ] Verdict is `CONCERNS`.

---

### Case 3: Concept Rejoin Chooses Art Bible

**Fixture:**

- Godot version is known.
- `.codex/docs/technical-preferences.md` is configured by this run.
- `design/gdd/game-concept.md` exists.
- The concept does not declare a prototype or validation build as the first
  complete scope.
- `design/art/art-bible.md` is missing.
- `design/gdd/systems-index.md` is missing.

**Input:** `/setup-engine`

**Expected behavior:**

1. Skill completes routine Godot setup.
2. Skill reads `.codex/docs/workflow-catalog.yaml`.
3. Skill identifies Concept as the current phase.
4. Skill treats Engine Setup and Game Concept Document as complete.
5. Skill selects Art Bible as the first missing required blocker and recommends
   `/art-bible`.

**Assertions:**

- [ ] `Next` is `/art-bible`.
- [ ] `Why` mentions the art bible artifact gap or the catalog's visual identity
  description.
- [ ] `/design-system` is shown only as coming later, if at all.

---

### Case 4: Concept Prototype Intent Routes To Brainstorm Prototype

**Fixture:**

- Godot version is known.
- `.codex/docs/technical-preferences.md` is configured by this run.
- `design/gdd/game-concept.md` exists.
- The concept declares a first complete scope or validation build such as a
  30-second visual/feel/technical prototype.
- The concept names a prototype path such as `prototypes/ci-jian-concept/`, or
  otherwise says prototype validation should happen before full GDD work.
- No matching `prototypes/*/README.md` or `prototypes/*/REPORT.md` exists.
- `design/art/art-bible.md` may be missing.
- `design/gdd/systems-index.md` may be missing.

**Input:** `/setup-engine`

**Expected behavior:**

1. Skill completes routine Godot setup.
2. Skill reads `design/gdd/game-concept.md` before selecting the catalog-required
   next step.
3. Skill recognizes the unresolved prototype/validation build as the immediate
   project blocker after engine setup.
4. Skill recommends `/brainstorm prototype` as the single primary next step.
5. Skill explains that the old `/prototype` route is absorbed into
   `/brainstorm`, and that the prototype validates the concept's first complete
   scope before the art/design document chain continues.

**Assertions:**

- [ ] `Next` is `/brainstorm prototype`.
- [ ] `Current blocker` names the unresolved concept prototype or validation
  build, not the missing art bible.
- [ ] `Why` mentions the concept's first complete scope, prototype path, or
  visual/feel/technical validation risk.
- [ ] `/art-bible` and `/design-system` are not the primary next step in this
  fixture.

---

### Case 5: Missing Console Path Is Asked Once Then Setup Continues

**Fixture:**

- Godot version is known.
- `project.godot` may be missing or present.
- Local Godot console executable is not discoverable from project docs.

**Input:** `/setup-engine`

**Expected behavior:**

1. Skill may ask one short question for the local Godot console path if it is
   needed for validation or accurate technical preferences.
2. The question states that after the user provides the path, Skill will finish
   routine setup.
3. When the user provides the path, Skill records it, writes the routine setup
   files, runs any safe read-only validation that can now run, and reports the
   result.
4. Skill does not ask a second `May I update...` confirmation after the path is
   provided.

**Assertions:**

- [ ] Missing required setup facts are gathered once, not via repeated approval
      loops.
- [ ] The user's path answer is treated as enough to continue routine setup.
- [ ] Runtime validation is skipped only when still blocked by `project.godot` or
      missing executable.

---

### Case 6: Multi-Engine Request

**Fixture:**

- User requests Unity, Unreal, or another engine.

**Input:** `/setup-engine unity`

**Expected behavior:**

1. Skill explains this fork is Godot-focused.
2. Skill does not write Unity/Unreal technical preferences.
3. Skill returns `BLOCKED` or a clear redirection.

**Assertions:**

- [ ] No Unity/Unreal routing table is written.
- [ ] Godot-only constraint is stated.
- [ ] No files are changed for the unsupported engine request.

---

## Protocol Compliance

- [ ] Treats `/setup-engine` invocation as execution intent for routine low-risk
  Godot setup.
- [ ] Asks again only for missing required facts or work outside routine setup.
- [ ] Runs read-only validation without extra approval when `project.godot` and
  Godot console are available.
- [ ] Does not recommend old multi-engine commands.
- [ ] Ends with a concise setup summary and route-aware production rejoin.
