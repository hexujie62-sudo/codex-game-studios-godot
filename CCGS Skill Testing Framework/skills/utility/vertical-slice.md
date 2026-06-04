# /vertical-slice Skill Spec

## Purpose

Verify that `/vertical-slice` runs as the Pre-Production validation workflow for a production-quality, end-to-end slice before the project commits to full Production.

## Source Skill

`.agents/skills/vertical-slice/SKILL.md`

## Test Cases

### Case 1: Scope Definition Before Build

**Fixture:** Project has approved GDDs, architecture, UX specs, and a user asks to run `/vertical-slice`.

**Expected assertions:**
- [ ] Skill explains that the slice answers whether the full loop works at representative quality.
- [ ] Skill defines a validation question and 3-5 minute playable scope before implementation.
- [ ] Skill asks the user to confirm scope before creating prototype files.

### Case 2: Concept Prototype Distinction

**Fixture:** User asks to validate whether a raw idea is worth designing.

**Expected assertions:**
- [ ] Skill distinguishes vertical slice from `/prototype`.
- [ ] Skill redirects early concept validation to `/prototype` instead of building a vertical slice.
- [ ] Skill does not treat throwaway concept prototype code as production input.

### Case 3: Report and Index Output

**Fixture:** Slice has been built and playtested.

**Expected assertions:**
- [ ] Skill produces `prototypes/[concept-name]-vertical-slice/REPORT.md`.
- [ ] Skill updates `prototypes/index.md` only after user approval.
- [ ] Report includes verdict, validation evidence, lessons learned, and recommended next steps.

### Case 4: PIVOT or KILL Handling

**Fixture:** Slice shows the full loop does not work or repeated slice attempts fail.

**Expected assertions:**
- [ ] Skill can produce a PIVOT note that identifies which GDDs, ADRs, UX specs, or scope assumptions need revision.
- [ ] Skill can document killed concepts in `prototypes/GRAVEYARD.md`.
- [ ] Skill routes revised direction back through design/architecture updates before another slice.

### Case 5: Production Boundary

**Fixture:** Slice succeeds and the user wants to continue.

**Expected assertions:**
- [ ] Skill states vertical slice code is reference only and must not be imported into production.
- [ ] Skill recommends `/gate-check production` or `/sprint-plan` after a successful slice.
- [ ] Skill treats missing skipped slice as advisory risk, but a broken slice as blocking evidence.

## Protocol Compliance

- [ ] Uses review mode (`full`, `lean`, `solo`) consistently when director gates are involved.
- [ ] Asks before writing slice directories, reports, pivot notes, or graveyard entries.
- [ ] Presents findings and verdict before asking to update persistent project files.
