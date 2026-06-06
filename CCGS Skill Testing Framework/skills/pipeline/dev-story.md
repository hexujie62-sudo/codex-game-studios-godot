# Skill Test Spec: /dev-story

## Skill Summary

`/dev-story` reads a story file, loads all required context (referenced ADR,
TR-ID from the registry, control manifest, engine preferences), runs the
readiness preflight, implements the story, and writes required tests. The skill
routes implementation to the correct specialist agent based on the engine and
file type — it does not write source code directly.

Review policy is fixed Lean. `/dev-story` does not run LP-CODE-REVIEW and does
not mark the story Complete. It leaves closure to `/code-review` followed by
`/story-done`.

---

## Static Assertions (Structural)

Verified automatically by `/skill-create-ccgs` internal static check — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 phase headings
- [ ] Contains verdict keywords: COMPLETE, BLOCKED, IN PROGRESS, NEEDS CHANGES
- [ ] Contains "May I write" collaborative protocol language (story status + code files)
- [ ] Has a next-step handoff at the end (`/code-review` then `/story-done`)
- [ ] Documents fixed Lean policy: no `--review full|lean|solo`, no `production/review-mode.txt`, no LP-CODE-REVIEW gate
- [ ] Notes that implementation is delegated to specialist agents (not done directly)

---

## Review Handoff

LP-CODE-REVIEW is not a `/dev-story` phase gate. The skill implements the story,
collects changed files and test evidence, updates session state, and recommends:

```text
/code-review [files]
/story-done [story-path]
```

It must not read, create, or normalize `production/review-mode.txt`.

---

## Test Cases

### Case 1: Happy Path — Story implemented with fixed Lean handoff

**Fixture:**
- A story file exists at `production/epics/[layer]/story-[name].md` with:
- `Status: Ready`
  - A TR-ID referencing a registered requirement
  - At least 2 Given-When-Then acceptance criteria
  - A test evidence path
- Referenced ADR has `Status: Accepted`
- `docs/architecture/control-manifest.md` exists
- `.codex/docs/technical-preferences.md` has engine and language configured

**Input:** `/dev-story production/epics/[layer]/story-[name].md`

**Expected behavior:**
1. Skill reads the story file and all referenced context
2. Skill verifies the ADR is Accepted (no block)
3. Skill routes implementation to the correct specialist agent
4. Required implementation files and tests are created or updated
5. Skill summarizes acceptance criteria coverage and any deferred manual evidence
6. Skill updates session state with changed files and next steps
7. Skill recommends `/code-review [files]` then `/story-done [story-path]`

**Assertions:**
- [ ] Skill reads story before spawning any agent
- [ ] ADR status is checked before implementation begins
- [ ] Implementation is delegated to a specialist agent (not done inline)
- [ ] LP-CODE-REVIEW is not spawned
- [ ] Story status is not marked Complete by `/dev-story`
- [ ] Test file is written as part of implementation (not deferred)
- [ ] Output recommends `/code-review` and `/story-done`

---

### Case 2: Failure Path — Referenced ADR is Proposed

**Fixture:**
- A story file exists with `Status: Ready`
- The story's TR-ID points to a requirement covered by an ADR with `Status: Proposed`

**Input:** `/dev-story production/epics/[layer]/story-[name].md`

**Expected behavior:**
1. Skill reads the story file
2. Skill resolves the TR-ID and reads the governing ADR
3. ADR status is Proposed — skill outputs a BLOCKED message
4. Skill names the specific ADR blocking the story
5. Skill recommends running `/create-architecture ADR: [title]` to advance the ADR
6. Implementation does NOT begin

**Assertions:**
- [ ] Skill does NOT begin implementation with a Proposed ADR
- [ ] BLOCKED message names the specific ADR number and title
- [ ] Skill recommends `/create-architecture ADR: [title]` as the next action
- [ ] Story status remains unchanged (not set to In Progress or Complete)

---

### Case 3: Ambiguous Acceptance Criteria — Skill asks for clarification

**Fixture:**
- A story file exists with `Status: Ready`
- Referenced ADR is Accepted
- One acceptance criterion is ambiguous (not Given-When-Then; uses subjective language like "feels responsive")

**Input:** `/dev-story production/epics/[layer]/story-[name].md`

**Expected behavior:**
1. Skill reads the story and identifies the ambiguous criterion
2. Before routing to the specialist, skill asks the user to clarify the criterion
3. User provides a concrete, testable restatement
4. Skill proceeds with implementation using the clarified criterion
5. Skill does NOT guess at the intended behavior

**Assertions:**
- [ ] Skill surfaces the ambiguous criterion before implementation starts
- [ ] Skill asks for user clarification (not auto-interpretation)
- [ ] Implementation begins only after clarification is provided
- [ ] Clarified criterion is used in the test (not the original vague version)

---

### Case 4: Edge Case — No argument; reads from session state

**Fixture:**
- No argument is provided
- `production/session-state/active.md` references an active story file
- That story file exists with `Status: In Progress`

**Input:** `/dev-story` (no argument)

**Expected behavior:**
1. Skill detects no argument is provided
2. Skill reads `production/session-state/active.md`
3. Skill finds the active story reference
4. Skill confirms with user: "Continuing work on [story title] — is that correct?"
5. After confirmation, skill proceeds with that story

**Assertions:**
- [ ] Skill reads session state when no argument is provided
- [ ] Skill confirms the active story with the user before proceeding
- [ ] Skill does NOT silently assume the active story without confirmation
- [ ] If session state has no active story, skill asks which story to implement

---

### Case 5: Code Review Handoff — no gate automation

**Fixture:**
- Story implementation completes with changed source files and a test file
- No `production/review-mode.txt` or `production/session-state/review-mode.txt`
  exists

**Expected behavior:**
1. Implementation completes.
2. No LP-CODE-REVIEW gate is spawned.
3. Output lists the exact files that should be reviewed.
4. Output recommends `/code-review [files]` before `/story-done [story-path]`.
5. Story remains ready for closure by `/story-done`, not auto-completed here.

**Assertions:**
- [ ] No review-mode file is read or required.
- [ ] LP-CODE-REVIEW is not spawned, skipped, or treated as a gate.
- [ ] Story status is not marked Complete by `/dev-story`.
- [ ] Code review is presented as the next recommended command.

---

## Protocol Compliance

- [ ] Does NOT write source code directly — delegates to specialist agents
- [ ] Reads all context (story, TR-ID, ADR, manifest, engine prefs) before implementation
- [ ] "May I write" asked before updating story status and before writing code files
- [ ] Does not read, create, or normalize review-mode state
- [ ] Updates `production/session-state/active.md` after story completion
- [ ] Ends with next-step handoff: `/code-review` then `/story-done`

---

## Coverage Notes

- Engine routing logic (Godot vs Unity vs Unreal) is not tested per engine —
  the routing pattern is consistent; engine selection is a config fact.
- Visual/Feel and UI story types (no automated test required) have different
  evidence requirements and are not covered in these cases.
- Integration story type follows the same pattern as Logic but with a different
  evidence path — not independently fixture-tested.

