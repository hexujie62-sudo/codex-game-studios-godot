# Skill Test Spec: /setup-engine

## Skill Summary

`/setup-engine` is the Godot-only technical setup entrypoint. It resolves the
pinned Godot version, GDScript baseline, local console executable, engine
reference, runtime check status, and minimal test foundation. It produces one
routine Godot setup scope. Invoking `/setup-engine` is treated as the user's
request to complete normal low-risk setup, so the Skill writes routine setup
files directly and asks again only for missing required facts or work outside
routine setup.

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
- [ ] Has a next-step handoff such as `/brainstorm`, `/design-system`,
  `/create-architecture`, or `/smoke-check`

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

**Assertions:**

- [ ] Engine field is set to Godot 4.x or a pinned Godot version.
- [ ] Language field is GDScript.
- [ ] Godot command is recorded if known.
- [ ] `tests/unit/`, `tests/integration/`, `tests/helpers/`, and `tests/README.md`
  are included when missing.
- [ ] No low-value setup confirmation is requested after `/setup-engine`.
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

**Assertions:**

- [ ] Runtime check is not falsely reported as passing.
- [ ] `project.godot` missing is named explicitly.
- [ ] Verdict is `CONCERNS`.

---

### Case 3: Missing Console Path Is Asked Once Then Setup Continues

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

### Case 4: Multi-Engine Request

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
- [ ] Ends with a concise setup summary and next step.
