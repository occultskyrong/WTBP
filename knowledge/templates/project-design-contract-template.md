# Project Design Contract

Use this contract before designing the overall information architecture or changing Figma/HTML for an existing
product. It records the actual consuming project's facts, constraints, reuse boundary, and evidence so that
architecture is derived from the project rather than from a screenshot or prompt alone.

## Contract metadata

```text
contract_id: PDC-YYYYMMDD-VNN
status: Draft | Approved | Blocked
project:
repository:
worktree:
branch_or_commit:
figma_baseline:
product:
platform:
declared_terminals:
runtime_or_preview_entry:
evidence_date:
owner:
next_reviewer:
```

## PDC-01 — Project identity and target

- Repository/worktree:
- Branch, commit, or Figma baseline:
- Product and platform:
- Declared terminals and shell dimensions:
- Runtime/preview entry:
- Evidence date and scope:

## PDC-02 — Surface inventory

| Surface ID | Route/entry | Page family | States | Navigation/shell | Viewport/device | Owning feature/module | Evidence |
|---|---|---|---|---|---|---|---|
| S-01 |  |  |  |  |  |  |  |

## PDC-03 — Foundations

| Foundation ID | Type (component/token/type/icon/layout) | Existing usage or node | Reuse/modify boundary | Source locator | Confidence |
|---|---|---|---|---|---|
| FND-01 |  |  |  |  | Existing / Unverified |

## PDC-04 — Behavior and constraints

- Permissions and roles:
- Data/API boundaries:
- Actions, transitions, and recovery paths:
- Responsive rules and viewport limits:
- Accessibility requirements:
- Terminal shell and safe-area constraints:
- Platform or runtime restrictions:
- Known conflicts or missing evidence:

## PDC-05 — Reuse and change boundary

| Area | Classification (`Existing — reuse` / `Existing — modify` / `New` / `Conflict` / `Unverified`) | Must reuse | May extend | Consumer impact | Must not rebuild/change | Evidence |
|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  |

## PDC-06 — Evidence and decisions

### Source and runtime evidence

- Repository paths/symbols:
- API, dictionary, permission, or configuration keys:
- Figma file/node links:
- Runtime URLs and capture conditions:
- Screenshots or other evidence:

### Conflict and decision log

| ID | Conflict or decision | Options and trade-offs | Approved resolution | Approver/date | Follow-up |
|---|---|---|---|---|---|
| DEC-01 |  |  |  |  |  |

### Unverified boundary

- Unverified facts:
- Why evidence is unavailable or stale:
- What downstream work is blocked:
- Explicit user acceptance of the boundary (if any):

## Architecture handoff

- Approved contract revision:
- Derived architecture revision (`ARC-YYYYMMDD-VNN`):
- Architecture derived from this contract:
- Inventory revision:
- Base-frame batch and BF-01–BF-06 result:
- Verification matrix and G-01–G-06 result:
- Remaining risks and next review:
