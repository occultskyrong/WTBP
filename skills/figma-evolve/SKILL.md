---
name: figma-evolve
description: Evolve an existing Figma design through a scoped patch or a version-preserving regeneration. Use when users provide a Figma file or node link and ask to change details, add a page or state, replace a component, or redesign a defined area.
---

# Figma Evolve

Modify current Figma design evidence without restarting from a PRD or silently destroying prior work. The Figma node is the current design source; a supplied PRD change remains the business source.

Read [`../../knowledge/design-workflow.md`](../../knowledge/design-workflow.md) before work. It defines the shared evidence precedence, inventory approval, batch/frame organization, annotation, text classification, and rendered acceptance contract.

## Required Inputs

- A Figma file or concrete node link.
- A change request; optionally the relevant PRD delta.
- Mode: `patch` by default, or explicit `regenerate` for a bounded redesign.
- An approved inventory or enough information to reconstruct `INV-YYYYMMDD-VNN`; overlapping designs also require source timestamps and an authoritative baseline.

If no scope node is given, inspect the file and ask for the smallest scope that can safely change. Do not choose an authoritative version or invent a business-rule resolution.

## Workflow

1. Preflight the callable Figma integration with read-only identity/permission proof. Read the target node, parent context, components, variables, constraints, annotations, and current screenshot before mutation.
2. Restate the intended change and create or confirm `INV-YYYYMMDD-VNN` with stable feature IDs, status, evidence locators, affected pages/states/targets, and conflict decisions. Obtain approval before mutation unless an already-approved inventory explicitly covers the change.
3. Assign a `YYYY-MM-DD-VNN` design batch. If the request or current evidence creates a material conflict, stop, offer distinct resolutions, and re-open the inventory gate.
4. In `patch` mode, mutate only the target nodes and necessary shared components. Preserve valid Auto Layout, constraints, variants, and asset links.
5. In `regenerate` mode, create a new versioned page or Frame such as `V2`; preserve the prior page/frame and return both links. Never replace a whole file by default.
6. Ensure every affected feature is shown in its complete containing page with a standalone right-side annotation block. Classify in-frame text and record provenance, proposed copy, actions, states, and exceptions.
7. Re-read changed nodes, inspect annotation geometry, take screenshots, and record the acceptance result. Identify downstream targets that need `figma-to-product` or `figma-verify` again.

## Change Rules

- Do not turn ordinary content into absolute-positioned children merely to match a screenshot.
- Change shared tokens or components only when the requested scope truly includes their consumers; report those consumers.
- Keep an explanation of the changed design outside the product UI.
- Do not implement Web, Mini Program, or App code in this Skill.
- Do not call a visual change complete from node mutation or one screenshot; complete the shared geometry, text, state, accessibility, and rendered acceptance audit.

## Failure-Driven Change Scenarios

| ID | Given | Required action | Pass condition |
|---|---|---|---|
| E-01 | A local spacing change is requested for one Frame. | Use `patch`; inspect its parent Auto Layout and shared-token consumers first. | Only scoped nodes change and affected targets are listed. |
| E-02 | A redesign changes component hierarchy or layout behavior. | Use `regenerate` and create `V2` rather than overwriting the baseline. | Both version links exist and downstream implementation impact is explicit. |
| E-03 | A requested visual fix would change ordinary children to absolute positioning. | Reject that mutation until overlay intent and containing parent are evidenced. | No coordinate-only workaround is introduced. |

## Output Contract

Return:

```text
Figma source and selected mode
Requested change and business-rule conflicts
Inventory version, feature IDs, approval, and design batch
Before and after node links
Changed pages/components/states and affected targets
Screenshots inspected
Annotation IDs, text classifications, geometry and acceptance record
Preserved version link when regenerated
Unverified items and required next Skill
```
