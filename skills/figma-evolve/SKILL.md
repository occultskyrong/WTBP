---
name: figma-evolve
description: Evolve an existing Figma design through a scoped patch or a version-preserving regeneration. Use when users provide a Figma file or node link and ask to change details, add a page or state, replace a component, or redesign a defined area.
---

# Figma Evolve

Modify current Figma design evidence without restarting from a PRD or silently destroying prior work. The Figma node is the current design source; a supplied PRD change remains the business source.

Read [`../../knowledge/design-principles.md`](../../knowledge/design-principles.md) and then [`../../knowledge/design-workflow.md`](../../knowledge/design-workflow.md) before work. They define the layered design contract, evidence precedence, inventory approval, batch/frame organization, annotation, text classification, and rendered acceptance contract.

## Input Contract

- A Figma file or concrete node link.
- A change request; optionally the relevant PRD delta.
- Mode: `patch` by default, or explicit `regenerate` for a bounded redesign.
- An approved inventory or enough information to reconstruct `INV-YYYYMMDD-VNN`; overlapping designs also require source timestamps and an authoritative baseline.
- The consuming project repository/worktree and preview entry when the Figma change serves an existing product; for a
  Figma-only change, state that no implementation project is in scope.
- A target shell contract with terminal, exact viewport/device dimensions, safe areas, navigation/status surfaces, and a visible boundary around the complete page. For `miniapp`, explicitly identify the mini-program shell; for `web`, use an approved browser shell or visibly bounded viewport container; for `app-*`, use the declared device/safe-area chrome. Do not invent a generic device frame or deliver a bare canvas.
- The current `AGC-YYYYMMDD-VNN` action-group contract or project evidence sufficient to confirm the affected component, width/slot policy, and target-size mapping remain valid.
- The current `ICON-YYYYMMDD-VNN` inventory or project evidence sufficient to confirm whether the affected Icon mapping and asset family remain valid.
- The current `PS-YYYYMMDD-VNN` page specification for the affected page/state, or evidence sufficient to revise its explanation, element hierarchy, reuse matrix, L0–L3 plan, and design-to-code boundary before mutation.

If no scope node is given, inspect the file and ask for the smallest scope that can safely change. Do not choose an authoritative version or invent a business-rule resolution.

## Workflow

1. Preflight the callable official Figma integration with read-only identity/permission proof and record `EX-01`. Read the target node, parent context, components, variables, constraints, annotations, and current screenshot before mutation; do not install a third-party tool when the capability is unavailable.
2. Restate the intended change and inspect the consuming project. Create or refresh `PDC-YYYYMMDD-VNN` and pass `PDC-01`–`PDC-06` for project identity, surfaces, foundations, behavior/constraints, reuse/change boundaries, and evidence. For Figma-only work, record the explicit implementation boundary and `Unverified` fields.
3. Resolve project-contract conflicts. For a structural change or `regenerate`, derive or refresh `ARC-YYYYMMDD-VNN` from the approved PDC, then create or refresh and obtain approval for `INV-YYYYMMDD-VNN`, followed by each affected `PS-YYYYMMDD-VNN` and `PS-01`–`PS-05`, before building or refreshing `AGC-YYYYMMDD-VNN` and passing `AGC-01`–`AGC-06`, then `ICON-YYYYMMDD-VNN` and `IA-01`–`IA-07`. A narrow patch may reuse a page specification only when its page outcome, element hierarchy, component mapping, and L0–L3 plan are unchanged. Record modules, routes, shells, reuse boundaries, states/transitions, affected base-frame batch, action-group impact, Icon impact, and page-specification impact. Obtain approval before mutation unless an already-approved inventory and page specification explicitly cover the change.
4. Assign a `YYYY-MM-DD-VNN` design batch. If the request or current evidence creates a material conflict, stop, offer distinct resolutions, and re-open the inventory gate.
5. In `patch` mode, mutate only the target nodes and necessary shared components, including approved action-group and Icon components when required. Preserve valid Auto Layout, constraints, variants, and asset links.
6. In `regenerate` mode, create a new versioned page or Frame such as `V2`; preserve the prior page/frame and return both links. Never replace a whole file by default.
7. Ensure every affected feature is shown in its complete containing page and declared terminal shell with a visible outer boundary and a standalone right-side annotation block. The shell must match the actual target rather than a generic phone frame: mini-program shell for `miniapp`, declared device/safe-area chrome for `app-*`, and approved browser shell or bounded viewport container for `web`. When a new page/state or structural redesign is in scope, confirm the page specification and first construct or revalidate the L0 base-frame batch for all approved pages/states using neutral placeholders; then implement L1 shared foundations, L2 composition/states, and L3 scoped finish only in the approved order. Keep design/project/technical descriptions out of the product frame. Classify in-frame text and record provenance, proposed copy, actions, states, and exceptions.
8. Run and record the blocking base-frame checkpoint (`BF-01`–`BF-06`) before adding or changing page-specific styling. A patch may reuse an already approved base only when its structural contract is unchanged; otherwise the checkpoint must cover the full affected batch.
9. Re-read changed nodes, run the shared post-write structural gate (`G-01`–`G-06`) across every product page/state frame, inspect shell and annotation geometry, take full-shell screenshots, and record the acceptance result. Identify downstream targets that need `figma-to-product` or `figma-verify` again.

## Change Rules

- Do not turn ordinary content into absolute-positioned children merely to match a screenshot.
- Change shared tokens or components only when the requested scope truly includes their consumers; report those consumers.
- Keep an explanation of the changed design outside the product UI.
- Do not implement Web, Mini Program, or App code in this Skill.
- Do not call a visual change complete from node mutation or one screenshot; complete the shared geometry, text, state, accessibility, and rendered acceptance audit.
- Do not layer page-specific styling onto a new or structurally changed page until all approved base frames pass `BF-01`–`BF-06`; a partial base batch blocks the change.
- Do not choose a new module, page family, component foundation, or visual direction until the consuming project contract passes `PDC-01`–`PDC-06` or the Figma-only boundary is explicit.
- Do not use a page-local Vector, emoji, text glyph, screenshot crop, or unapproved third-party set as a reusable Icon. Reuse the approved semantic Icon family; independently design a missing Icon before placing an instance.
- Do not create a page-local action-group clone, compensate a registered control with local CSS, or use `space-between` as proof that a symmetric navigation action is centered. Reuse the approved action-group component and its width/slot policy.
- When review identifies node migration, page addition/removal, or a Section column-count change, recompute every affected Section from actual content bounds plus its declared fixed padding. Do not preserve an earlier fixed width or height; record the trigger, child/column inputs, padding, recomputed geometry, and any approved fixed-size exception.
- A write is blocked from completion when any page lacks a recorded `layoutMode`/layout owner, one-to-one annotation, text-containment result, or instance/master scale result. An approved exception must name the affected frame and rationale.
- A write is blocked when the target shell/dimensions are absent, the full shell is not visible, or descriptive/technical/review text appears inside the product frame. These are G-05/G-06 failures and require a named approved exception.
- A third-party design lint, token, or accessibility audit is optional only. It requires explicit user authorization and `EX-03`–`EX-04`; its result cannot replace the required Figma geometry evidence.

## Failure-Driven Change Scenarios

| ID | Given | Required action | Pass condition |
|---|---|---|---|
| E-01 | A local spacing change is requested for one Frame. | Use `patch`; inspect its parent Auto Layout and shared-token consumers first. | Only scoped nodes change and affected targets are listed. |
| E-02 | A redesign changes component hierarchy or layout behavior. | Use `regenerate` and create `V2` rather than overwriting the baseline. | Both version links exist and downstream implementation impact is explicit. |
| E-03 | A requested visual fix would change ordinary children to absolute positioning. | Reject that mutation until overlay intent and containing parent are evidenced. | No coordinate-only workaround is introduced. |
| E-04 | A change touches equal-weight navigation or a nested component boundary. | Revalidate distribution/parent-chain geometry for the affected base batch before styling. | No hand-placed navigation or unexplained child overflow remains. |
| E-05 | A change touches previous/current-or-reset/next actions. | Revalidate the `symmetric-navigation` contract, equal edge targets, parent-centered middle child, and target-size evidence before styling. | `AGC-01`–`AGC-06` pass; no large outlined pseudo-button or compensating coordinates remain. |
| E-06 | Review moves nodes, adds/removes a page, or changes a Section's column count. | Recompute every affected Section from actual child bounds plus its declared fixed padding; update the page specification and inspect all affected pages/states. | No old fixed Section width/height remains unless a product rule and approval explicitly justify it. |

## Output Contract

Return:

```text
Figma source and selected mode
Requested change and business-rule conflicts
Project design contract revision, `PDC-01`–`PDC-06` results, derived architecture revision (`ARC-YYYYMMDD-VNN`), and evidence boundary
Action-group contract revision, affected component/token/slot mappings, and `AGC-01`–`AGC-06` results when interaction structure changes
Icon inventory revision, affected semantic mappings, and `IA-01`–`IA-07` results when Icons or structure change
Inventory version, feature IDs, approval, and design batch
Affected page specification IDs, `PS-01`–`PS-05` results, element/reuse matrix, and L0–L3 impact
Before and after node links
Changed pages/components/states and affected targets
Base-frame IDs and `BF-01`–`BF-06` checkpoint results when structure changed
Screenshots inspected
Annotation IDs, text classifications, geometry and acceptance record
Target shell contract and dimensions
Post-write gate results for `G-01`–`G-06` across all product page/state frames
Page/state/transition matrix and changed interaction decisions
Preserved version link when regenerated
Unverified items and required next Skill
```

## Completion Gate

- The input scope, inventory approval, design batch, and conflict decisions are recorded.
- The consuming project was inspected and `PDC-01` through `PDC-06` are approved, or the Figma-only boundary and `Unverified` fields are explicit.
- Structural changes have a derived `ARC-YYYYMMDD-VNN` based on the approved project design contract, with no unrecorded route, page family, foundation, terminal, state, or behavior.
- Every affected page/state has a current `PS-YYYYMMDD-VNN` with `PS-01`–`PS-05`; a reused page specification explicitly proves its outcome, element hierarchy, mapping, and layer plan are unchanged.
- Structural or action-group-affecting changes have a current `AGC-YYYYMMDD-VNN`; `AGC-01` through `AGC-06` pass before page-specific styling, or the unchanged semantic/component/slot reuse is recorded.
- Structural or Icon-affecting changes have a current `ICON-YYYYMMDD-VNN`; `IA-01` through `IA-07` pass before page-specific styling, or the unchanged mapping/family reuse is recorded.
- Every affected and unchanged product page/state frame has G-01 through G-06 results or a named approved exception, and every new/structurally changed base batch has passed BF-01 through BF-06 first.
- Full-shell before/after links, screenshots, interaction matrix, and downstream handoff are present; otherwise stop as incomplete.
