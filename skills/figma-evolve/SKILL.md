---
name: figma-evolve
description: Evolve an existing Figma design through a scoped patch or a version-preserving regeneration. Use when users provide a Figma file or node link and ask to change details, add a page or state, replace a component, or redesign a defined area.
---

# Figma Evolve

Modify current Figma design evidence without restarting from a PRD or silently destroying prior work. The Figma node is the current design source; a supplied PRD change remains the business source.

## Required Inputs

- A Figma file or concrete node link.
- A change request; optionally the relevant PRD delta.
- Mode: `patch` by default, or explicit `regenerate` for a bounded redesign.

If no scope node is given, inspect the file and ask for the smallest scope that can safely change. Do not choose an authoritative version or invent a business-rule resolution.

## Workflow

1. Load `figma:figma-use`; read the target node, its parent context, components, variables, constraints, annotations, and a current screenshot before mutation.
2. Restate the intended change and list affected pages, components, states, and targets. If it conflicts with the supplied PRD, stop and describe the conflict.
3. In `patch` mode, mutate only the target nodes and necessary shared components. Preserve valid Auto Layout, constraints, variants, and asset links.
4. In `regenerate` mode, create a new versioned page or Frame such as `V2`; preserve the prior page/frame and return both links. Never replace a whole file by default.
5. Re-read changed nodes and take screenshots. Identify downstream targets that need `figma-to-product` or `figma-verify` again.

## Change Rules

- Do not turn ordinary content into absolute-positioned children merely to match a screenshot.
- Change shared tokens or components only when the requested scope truly includes their consumers; report those consumers.
- Keep an explanation of the changed design outside the product UI.
- Do not implement Web, Mini Program, or App code in this Skill.

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
Before and after node links
Changed pages/components/states and affected targets
Screenshots inspected
Preserved version link when regenerated
Unverified items and required next Skill
```
