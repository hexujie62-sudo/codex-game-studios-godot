# Coding Standards

- All game code must include doc comments on public APIs when the API is not self-explanatory.
- Every durable system-level architecture decision should have a corresponding ADR or architecture note in `docs/architecture/` when B-dev/code-review/gate-check must consume it.
- Gameplay values must be data-driven when they are tuning knobs or production data; do not hardcode balance values into logic.
- Public methods should be testable through dependency injection, explicit scene setup, or a documented runtime validation path.
- Commits must reference the relevant design document, work order, task ID, or lane checkpoint.
- **Commit messages**: Use Conventional Commits format: `feat:`, `fix:`, `chore:`, `docs:`, `test:`, `refactor:`. Reference the work order, task ID, or lane in the body, for example `Work-Order: GA06-START` or `Lane: Z-platform`.
- **Checkpoint body**: For CFG framework or multi-window work, include `Lane:`, `Scope:`, `Verification:`, and `Rollback:` fields. See `.codex/docs/git-checkpoint-workflow.md`.
- **Verification-driven development**: Every implementation should have a way to prove it works: automated test, runtime check, capture, report, or explicit manual evidence.

# Design Document Standards

- All design docs use Markdown.
- Each mechanic or system should have a dedicated document in `design/gdd/` when it is durable enough to guide implementation.
- Design docs should include these sections when relevant:
  1. **Overview** -- one-paragraph summary
  2. **Player Fantasy** -- intended feeling and experience
  3. **Detailed Rules** -- unambiguous mechanics
  4. **Formulas** -- all math defined with variables
  5. **Edge Cases** -- unusual situations handled
  6. **Dependencies** -- other systems listed
  7. **Tuning Knobs** -- configurable values identified
  8. **Acceptance Criteria** -- testable success conditions
- Balance values must link to their source formula or rationale.

# Evidence Standards

## Evidence By Claim Type

Work orders define the required evidence. Use this table as the default when the work order does not specify a stricter format.

| Claim Type | Required Evidence | Default Owner | Location |
|---|---|---|---|
| **Logic** (formulas, AI, state machines) | Automated unit test or deterministic runtime check | B-dev | `tests/unit/` or `production/dev-tasks/` |
| **Integration** (multi-system) | Integration test, Godot runtime check, or report with reproduction steps | B-dev | `tests/integration/` or `production/dev-tasks/` |
| **Visual/Feel** (animation, VFX, feel) | Screenshot/video/strip plus interpretation notes | C-art, D-director if canon-level | `artifacts/runtime-captures/` and C-art report |
| **UI** (menus, HUD, screens) | Manual walkthrough, screenshot, or interaction test | C-art/B-dev by scope | `design/ux/`, `artifacts/`, or lane report |
| **Config/Data** (balance tuning) | Config diff plus runtime/state proof | B-dev | `production/dev-tasks/` |
| **Canon/player experience** | D-director verdict referencing B/C evidence | D-director | `production/work-orders/` |

## Automated Test Rules

- **Naming**: `[system]_[feature]_test.[ext]` for files; `test_[scenario]_[expected]` for functions.
- **Determinism**: Tests must produce the same result every run unless randomness is explicitly seeded and recorded.
- **Isolation**: Each test sets up and tears down its own state; tests must not depend on execution order.
- **No hardcoded data**: Test fixtures use constant files or factory functions, not inline magic numbers, except boundary value tests where the exact number is the point.
- **Independence**: Unit tests do not call external APIs, databases, or file I/O unless that dependency is the subject of the test.

## What Not To Automate

- Visual fidelity by headless assertion alone.
- "Feel" qualities such as perceived weight, timing, impact, or readability.
- Platform-specific rendering without target hardware/capture.
- Full gameplay sessions that require human play; record them as manual evidence.

## CI/CD Rules

- Automated test suite runs on every push to main and every PR when CI is configured.
- No merge if blocking tests fail.
- Never disable or skip failing tests to make CI pass; fix the underlying issue or document an accepted risk through A/D.
- Godot command should come from project tooling, usually the pinned console executable in `AGENTS.md`.
