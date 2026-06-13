# Work Order Evidence: [Work Order ID]

> **Work order**: `production/work-orders/[id].md`
> **Owner lane**: [B-dev / C-art / other]
> **Date**: [date]
> **Tester / author**: [name or lane]
> **Build / Commit**: [version or git hash]

---

## What Was Tested

[Describe the requirement or claim validated. Reference the work order delivery
spec and acceptance/evidence requirement.]

## Results

| Requirement | Result | Evidence | Notes |
|---|---|---|---|
| [requirement] | PASS / FAIL / PARTIAL / INVALID | [path] | [notes] |

## Captures / Logs / Reports

| # | Path | What It Shows | Requirement |
|---|---|---|---|
| 1 | `[path]` | [description] | [requirement] |

For video, include timestamp ranges. For synthesized or composite evidence,
state that it is not raw runtime capture.

## Test Conditions

- **Game state at start**: [state]
- **Platform / hardware**: [platform]
- **Runtime mode**: [normal / validation / debug]
- **Special setup**: [setup]

## Observations

- [observation]

If nothing notable: *No significant observations.*

## Sign-Off / Return Path

| Role/Lane | Status | Notes |
|---|---|---|
| B-dev | Approved / Deferred / N/A | |
| C-art | Approved / Deferred / N/A | |
| D-director | Requested / PASS / PARTIAL PASS / FAIL / N/A | |
| A-producer | Queue updated / N/A | |

Deferred sign-offs must name the reason and owner.

*Template: `.codex/docs/templates/test-evidence.md`*
*Location: owner lane report or `production/work-orders/` evidence bundle*
