# Work Order Evidence Plan: [Work Order ID]

> **Date**: [date]
> **Scope**: [work order path and summary]
> **Owner lane**: [B-dev / C-art / other]
> **Engine**: [engine name and version]
> **Related work order**: `production/work-orders/[id].md`

---

## Evidence Summary

| Requirement | Owner | Evidence Type | Required Path |
|---|---|---|---|
| [runtime/config/test claim] | B-dev | test/report/capture | `production/dev-tasks/[id]-B-dev-report.md` |
| [visual/readability/player-facing claim] | C-art | screenshot/video/strip/report | `artifacts/runtime-captures/[scope]/...` |
| [canon/player experience verdict] | D-director | verdict | `production/work-orders/[id]-D-verdict.md` |

## Automated Or Runtime Checks

- [ ] [check command or Godot scene path]
- [ ] [expected observable result]
- [ ] [output/report path]

## Manual / Visual Checks

- [ ] [specific observable condition]
- [ ] [capture format: raw runtime screenshot / video timestamp / same-phase strip / etc.]
- [ ] [evidence path]

## Stop Conditions

- [ ] [condition from work order that requires stopping and reporting]
- [ ] [out-of-scope change that requires A/D decision]

## Done For This Work Order

- [ ] Scope completed without crossing Non-scope.
- [ ] Required evidence files exist.
- [ ] B-dev/C-art reports state limitations honestly.
- [ ] D-director verdict requested when required.
- [ ] A-producer queue updated if priority/scope changed.

*Template: `.codex/docs/templates/test-plan.md`*
