---
name: figma-to-product
description: Implement selected Figma nodes in exactly one declared product target such as Web, Mini Program, iOS, or Android. Use when a user has an existing Figma design and wants a high-fidelity, maintainable implementation in a specified code repository.
---

# Figma to Product

Implement one target from current Figma design evidence. Do not restart from the PRD, infer missing business features, or treat a screenshot as the complete design contract.

Read [`../../knowledge/design-principles.md`](../../knowledge/design-principles.md) and then [`../../knowledge/design-workflow.md`](../../knowledge/design-workflow.md) before implementation. They define the layered design contract, brief/inventory gate, evidence provenance, complete-page requirement, text classification, and real-fixture acceptance contract.

## Input Contract

- Concrete Figma page, frame, component, or state node links.
- One target: `web`, `miniapp`, `app-ios`, `app-android`, or another explicitly named target.
- The target shell contract: exact viewport/device dimensions, device/browser chrome, safe areas, and navigation/status surfaces. For `miniapp`, the applicable mini-program shell is mandatory.
- Target repository or writable implementation location.
- The approved design inventory/contract and its feature IDs, or enough evidence to identify the approved scope.
- An approved project design contract `PDC-YYYYMMDD-VNN`, or permission/evidence sufficient to build one from the
  target repository before architecture or implementation decisions.
- The approved `ICON-YYYYMMDD-VNN` inventory, or evidence sufficient to rebuild its semantic Icon mapping before implementation.

Ask for a missing target, repository, or project-contract evidence. If a Figma design contradicts a supplied PRD or
the project design contract, report the conflict and route it to `figma-evolve`; do not silently choose in code.

## Design Evidence Gate

1. Load `figma:figma-design-to-code` before `get_design_context`; load `figma:figma-use` for Figma inspection when needed.
2. For each scoped node, collect node and parent IDs, hierarchy, screenshot, Auto Layout, constraints, variables/tokens, components/variants, annotations/prototype behavior, and exact assets/fonts.
3. Inspect the target repository's actual routes, page families, components, theme/tokens, CSS or platform styles, assets, runtime entry, and target-specific constraints. Build or refresh `PDC-YYYYMMDD-VNN` and record `PDC-01`–`PDC-06` before choosing architecture or implementation mappings. Prefer Code Connect mappings, then existing project components/tokens, then Figma variables; create the smallest missing component only last.
4. Use `figma:figma-code-connect` when reusable Figma components need durable code mappings.
5. Derive or confirm `ARC-YYYYMMDD-VNN` from the approved project design contract before editing. Map modules, routes, shells, reuse boundaries, states/transitions, and the complete base-frame batch; then confirm inventory feature IDs, terminal, permissions/data scope, material states, proposed-copy markers, and evidence provenance. If the requested implementation changes scope, behavior, component contract, or target constraint, return to the earliest affected contract gate and do not infer the change.
6. Before implementation styling, build or confirm `ICON-YYYYMMDD-VNN` and `IA-01`–`IA-07`. Map every Figma Icon instance to its semantic component, size, style, state, exact source/export, and target implementation. Reuse the project library first; independently design a missing Icon in the approved family before use, never as a page-local substitute.
7. Before styling any page, implement the structural base-frame batch for every declared page/state: target shell, page root, content regions, normal-flow/Auto Layout parents, state slots, and right-side annotation sibling. Use neutral content and keep page-specific decoration out of this pass.
8. Run and record the blocking base-frame checkpoint (`BF-01`–`BF-06`) across the complete batch. A failed or partial base pass blocks component styling and content polish.
9. After each implementation write, run the shared structural gate (`G-01`–`G-06`) across every declared page/state: record source Figma `layoutMode` or DOM layout owner, navigation distribution, one-to-one right-side annotation, recursive descendant containment, shared component instance/master width and height ratios, target shell fidelity, and product-content isolation. A missing result blocks handoff to `figma-verify`.

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
| I-08 Equal navigation distribution | A TabBar, tabs, or segmented control requires equal-weight items or named partitioning. | Use Auto Layout/Flex/Grid or an equivalent distribution rule. Assert item weights/basis and center points against the declared partitions; do not position items by hand-written `x/y` or `left/top`. |
| I-09 Recursive component containment | A page contains nested cards, buttons, text, media, or shared component instances. | Traverse every descendant and its direct parent/ancestor chain. Assert no child crosses a required boundary and no `overflow:hidden` conceals it; a page-level bounding-box check is insufficient. |

For I-03 through I-06 and I-08 through I-09, hand off the failing and passing captures to `figma-verify`; a code diff alone does not close the case.

## Workflow

1. Inspect the target project and create or confirm `PDC-YYYYMMDD-VNN`; do not infer routes, components, tokens, behavior, or constraints from Figma alone.
2. Derive or confirm `ARC-YYYYMMDD-VNN`, then map Figma components and states to the project-contract-backed target components before editing.
3. Confirm the `ICON-YYYYMMDD-VNN` inventory and pass `IA-01`–`IA-07` before styling. Map every instance to semantic ID, component, size, style, state, exact source/export, and target implementation; design missing Icons as independent family-consistent components.
4. Select all applicable I-01–I-09 cases and record target, node, expected layout owner, viewport, state, and required failing evidence before editing.
5. Implement the complete structural base-frame batch for every declared page/state in the existing target conventions. Preserve unrelated code and do not commit, push, or change another target.
6. Run and record `BF-01`–`BF-06`; do not add component or visual styling until the base batch passes.
7. Layer reusable components, product content, material states, and visual styling incrementally. Render complete containing pages and material states inside the declared target shell, not cropped components. Classify any new product copy and keep page descriptions, project/technical notes, and design commentary outside the product UI in the right-side annotation sibling.
8. Use exact Figma assets and the approved Icon mappings; do not draw page-local substitute icons, change an Icon's approved size/style/state, or silently fall back to system fonts.
9. Run target checks and capture deterministic runtime evidence for each declared viewport/state. A code diff or one screenshot is not acceptance; hand off the complete fixture to `figma-verify`.
10. Include the project design contract and PDC results, Icon inventory/IA results, target shell contract, base-frame evidence and BF results, full-shell screenshots, all-page G-01–G-06 record, action/transition results, and any approved exceptions in the handoff; do not report implementation acceptance from only the changed component.

## Output Contract

Return:

```text
Figma nodes and target/repository
Project design contract revision, `PDC-01`–`PDC-06` results, derived architecture revision (`ARC-YYYYMMDD-VNN`), and evidence boundary
Icon inventory revision, per-instance semantic mapping, and `IA-01`–`IA-07` results
Target shell contract and dimensions
Base-frame batch, neutral captures, and `BF-01`–`BF-06` results
Approved inventory and feature IDs
Design evidence and component/token mapping
Changed implementation files
Layout owners and approved absolute-position cases
Checks and screenshots completed
Runtime matrix, text classifications, accessibility evidence, and fixture record
Known visual/behavior gaps
Node-to-code links for figma-verify
```

## Completion Gate

- The target, repository, project design contract (`PDC-01`–`PDC-06`), derived architecture (`ARC-YYYYMMDD-VNN`), Icon inventory (`ICON-YYYYMMDD-VNN` with `IA-01`–`IA-07`), inventory, and applicable I-01–I-09 cases are explicit.
- Every declared page/state passes `BF-01` through `BF-06` before styling; runtime evidence covers every declared viewport/state inside the target shell, and the post-write G-01 through G-06 record is complete.
- No unlisted target or unproven coordinate compensation is claimed; missing evidence blocks handoff.
