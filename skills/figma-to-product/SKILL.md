---
name: figma-to-product
description: Implement selected Figma nodes in exactly one declared product target such as Web, Mini Program, iOS, or Android. Use when a user has an existing Figma design and wants a high-fidelity, maintainable implementation in a specified code repository.
---

# Figma to Product

Implement one target from current Figma design evidence. Do not restart from the PRD, infer missing business features, or treat a screenshot as the complete design contract.

## Required Inputs

- Concrete Figma page, frame, component, or state node links.
- One target: `web`, `miniapp`, `app-ios`, `app-android`, or another explicitly named target.
- Target repository or writable implementation location.

Ask for a missing target or repository. If a Figma design contradicts a supplied PRD, report the conflict and route it to `figma-evolve`; do not silently choose in code.

## Design Evidence Gate

1. Load `figma:figma-design-to-code` before `get_design_context`; load `figma:figma-use` for Figma inspection when needed.
2. For each scoped node, collect node and parent IDs, hierarchy, screenshot, Auto Layout, constraints, variables/tokens, components/variants, annotations/prototype behavior, and exact assets/fonts.
3. Inspect the target repository's existing components, theme/tokens, CSS or platform styles, assets, and target-specific constraints. Prefer Code Connect mappings, then existing project components/tokens, then Figma variables; create the smallest missing component only last.
4. Use `figma:figma-code-connect` when reusable Figma components need durable code mappings.

## Layout Provenance Gate

Never translate Figma `x/y` coordinates directly into CSS `left/top` for ordinary content. Classify each key child as normal flow, constrained/stretching, overlay, or fixed/sticky.

For every key visual mismatch or absolute-positioned child, trace its ancestor chain to the page root and identify the layout owner. Inspect `display`, `position`, dimensions, padding, margin, gap, box sizing, flex/grid rules, overflow, transforms, inherited typography, variables, and responsive rules.

- Use Flex, Grid, Auto Layout intent, and normal flow for ordinary content.
- Permit `absolute` only for proven overlays, badges, or anchored controls; record its positioning parent, anchor, and verified viewport.
- Repair the first divergent layout owner. Do not hide a parent-level error with child `margin`, transform, or coordinate compensation.

## Failure-Driven Implementation Scenarios

Before editing, select every applicable scenario and state its ID, target, Figma node, expected layout owner, and required viewport/state in the implementation plan. Treat it as failed until the required evidence is captured.

| ID | Given | Required implementation and assertion |
|---|---|---|
| I-01 Normal-flow card | A card's title, variable-length copy, image, and CTA appear in reading order. | Map Figma Auto Layout to normal flow/Flex/Grid. Assert that changing copy length moves downstream content through parent layout, not child `top/left`. |
| I-02 Anchored overlay | A badge, close button, or menu overlays a card. | Permit absolute positioning only with the named containing parent, anchor, and viewport. Assert it stays anchored while normal content grows. |
| I-03 Ancestor padding drift | A card is uniformly 12–16px away from its Figma position. | Compare the complete ancestor chain. Repair the first wrong padding, gap, width, or layout direction; assert no compensating child margin/transform remains. |
| I-04 Cascade or containing-block drift | A global selector, `box-sizing`, `transform`, `overflow`, or positioned ancestor changes geometry. | Identify the computed-style source and containing block. Assert the scoped rule wins without weakening unrelated pages. |
| I-05 Typography and asset drift | Fallback font, line-height, unloaded image, or wrong `object-fit` changes content height. | Use exact assets/fonts and wait for them in runtime evidence. Assert text/image geometry before comparing spacing. |
| I-06 Responsive constraint drift | The Figma Frame behaves correctly at more than one width. | Implement the stated Flex/Grid/constraint rule and assert each declared viewport independently; never validate only the design-frame width. |
| I-07 Target isolation | The request declares one target only. | Implement only that target using its native conventions. Assert that no Web, Mini Program, or App work is claimed for an unlisted target. |

For I-03 through I-06, hand off the failing and passing captures to `figma-verify`; a code diff alone does not close the case.

## Implementation Workflow

1. Map Figma components and states to target components before editing.
2. Implement incrementally in the existing target conventions. Preserve unrelated code and do not commit, push, or change another target.
3. Use exact Figma assets; do not draw substitute icons or silently fall back to system fonts.
4. Run the target's relevant local checks and capture target-appropriate runtime evidence. Hand off visual acceptance to `figma-verify`.

## Output Contract

Return:

```text
Figma nodes and target/repository
Design evidence and component/token mapping
Changed implementation files
Layout owners and approved absolute-position cases
Checks and screenshots completed
Known visual/behavior gaps
Node-to-code links for figma-verify
```
