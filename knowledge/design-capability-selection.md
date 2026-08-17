# Design Capability Selection Record

Use this record before an official Figma capability check, project-contract work, Figma mutation, code implementation, or acceptance. It turns capability discovery into a small, reviewable decision; it is not a new execution Skill and it never replaces the project design contract (`PDC`) or any downstream gate.

## Required record

Create or refresh `DCS-YYYYMMDD-VNN` for each materially distinct design task. Record:

1. **Task boundary** — outcome, declared target/terminal, requested phase, Figma and repository scope, required read/write authority, and evidence required for completion.
2. **Local-first result** — the result of `wtbp "<task>"`, selected local Skill or Skills, rejected candidates, and the reason for `direct-use`, `adapt`, `compose`, `reference-only`, or `build-local`.
3. **Known external capability decision** — relevant external-card IDs, source/revision/status, allowed adoption mode, and what the capability may prove. An external card is not an installation or execution authorization.
4. **Conditional tracks** — whether visual direction, Icon design, motion design, Code Connect, or an explicitly authorized third-party audit is required, with the selected owner and handoff condition.
5. **Fallback and collection** — use `external-capability-discovery` only when neither a local Skill nor an already registered external card is a clear fit. When the user says `wtbp，收集 <public URL>`, use `external-capability-curation`; record the resulting uninstalled card and its scenarios/cases rather than treating collection as adoption.
6. **Authority boundary** — official Figma capability availability is recorded separately as `EX-01`. Do not install, authenticate, execute, or claim results for a third-party capability without the separate user authorization and the `EX-03`/`EX-04` boundary.

## Selection matrix

| Need | Default local owner | DCS decision |
|---|---|---|
| Create a new editable design from a requirement | `prd-to-figma` | Select the creation flow; require PDC before architecture and Figma write. |
| Change a bounded existing Figma design | `figma-evolve` | Select `patch` or explicitly authorized `regenerate`; retain the prior baseline. |
| Implement Figma into one product target | `figma-to-product` | Select exactly one target and map it to the project contract and page specification. |
| Compare Figma with a running target | `figma-verify` | Select a target/viewport/state matrix; do not accept from a screenshot alone. |
| Establish visual direction | `visual-direction` | Run before page styling and require human approval before any Figma write. |
| Create or extend a missing Icon family | `icon-design` | Run only for approved scope; feed `ICON` inventory, never a page-local substitute. |
| Define motion behaviour | `motion-design` | Run only when behavior needs motion evidence; it does not authorize Figma or code writes. |
| Map reusable Figma components to code | `figma:figma-code-connect` | Use after the project and component reuse boundary are known; record `EX-02`. |

## Fail-closed rules

- Do not enter a Figma workflow solely because a keyword matched. Record the local-first decision and task boundary first.
- A discovered candidate is temporary evidence. It cannot be installed, executed, or written into a registry by discovery alone.
- A collected URL becomes an uninstalled, searchable reference card by default. It is not a selected solution.
- If no clear capability fit exists, report `no_match` or `Unverified`, state the missing evidence, and stop before Figma or code mutation.
- DCS selects a process; `PDC`, `ARC`, `INV`, `PS`, `AGC`, `ICON`, `BF`, `G`, and acceptance gates still determine whether the artifact can proceed or complete.

## Minimum handoff

Every Figma-flow handoff includes the DCS ID, selected local owner, adoption mode, consulted external-card IDs (or `none`), conditional-track decisions, official-capability status, and any `Unverified` or blocked boundary. Link the DCS to the resulting PDC, design batch, implementation record, or acceptance record.
