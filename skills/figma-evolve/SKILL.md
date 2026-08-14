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
- A target shell contract with terminal, exact viewport/device dimensions, safe areas, and navigation/status surfaces. For `miniapp`, explicitly identify the mini-program shell; do not invent a generic device frame.
- The current `ICON-YYYYMMDD-VNN` inventory or project evidence sufficient to confirm whether the affected Icon mapping and asset family remain valid.

If no scope node is given, inspect the file and ask for the smallest scope that can safely change. Do not choose an authoritative version or invent a business-rule resolution.

## Workflow

1. Preflight the callable Figma integration with read-only identity/permission proof. Read the target node, parent context, components, variables, constraints, annotations, and current screenshot before mutation.
2. Restate the intended change and inspect the consuming project. Create or refresh `PDC-YYYYMMDD-VNN` and pass `PDC-01`–`PDC-06` for project identity, surfaces, foundations, behavior/constraints, reuse/change boundaries, and evidence. For Figma-only work, record the explicit implementation boundary and `Unverified` fields.
3. Resolve project-contract conflicts. For a structural change or `regenerate`, derive or refresh `ARC-YYYYMMDD-VNN` from the approved PDC, then create or refresh and obtain approval for `INV-YYYYMMDD-VNN` before building or refreshing `ICON-YYYYMMDD-VNN` and passing `IA-01`–`IA-07`. A narrow patch may reuse the current architecture only when its contract is unchanged, and may reuse the Icon inventory only when the approved scope and affected Icon semantic mapping/family are unchanged. Record modules, routes, shells, reuse boundaries, states/transitions, affected base-frame batch, and Icon impact. Obtain approval before mutation unless an already-approved inventory explicitly covers the change.
4. Assign a `YYYY-MM-DD-VNN` design batch. If the request or current evidence creates a material conflict, stop, offer distinct resolutions, and re-open the inventory gate.
5. In `patch` mode, mutate only the target nodes and necessary shared components, including approved Icon components when required. Preserve valid Auto Layout, constraints, variants, and asset links.
6. In `regenerate` mode, create a new versioned page or Frame such as `V2`; preserve the prior page/frame and return both links. Never replace a whole file by default.
7. Ensure every affected feature is shown in its complete containing page and declared terminal shell with a standalone right-side annotation block. When a new page/state or structural redesign is in scope, first construct or revalidate the base-frame batch for all approved pages/states using neutral placeholders. Keep design/project/technical descriptions out of the product frame. Classify in-frame text and record provenance, proposed copy, actions, states, and exceptions.
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
- A write is blocked from completion when any page lacks a recorded `layoutMode`/layout owner, one-to-one annotation, text-containment result, or instance/master scale result. An approved exception must name the affected frame and rationale.
- A write is blocked when the target shell/dimensions are absent, the full shell is not visible, or descriptive/technical/review text appears inside the product frame. These are G-05/G-06 failures and require a named approved exception.

## Failure-Driven Change Scenarios

| ID | Given | Required action | Pass condition |
|---|---|---|---|
| E-01 | A local spacing change is requested for one Frame. | Use `patch`; inspect its parent Auto Layout and shared-token consumers first. | Only scoped nodes change and affected targets are listed. |
| E-02 | A redesign changes component hierarchy or layout behavior. | Use `regenerate` and create `V2` rather than overwriting the baseline. | Both version links exist and downstream implementation impact is explicit. |
| E-03 | A requested visual fix would change ordinary children to absolute positioning. | Reject that mutation until overlay intent and containing parent are evidenced. | No coordinate-only workaround is introduced. |
| E-04 | A change touches equal-weight navigation or a nested component boundary. | Revalidate distribution/parent-chain geometry for the affected base batch before styling. | No hand-placed navigation or unexplained child overflow remains. |

## Output Contract

Return:

```text
Figma source and selected mode
Requested change and business-rule conflicts
Project design contract revision, `PDC-01`–`PDC-06` results, derived architecture revision (`ARC-YYYYMMDD-VNN`), and evidence boundary
Icon inventory revision, affected semantic mappings, and `IA-01`–`IA-07` results when Icons or structure change
Inventory version, feature IDs, approval, and design batch
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
- Structural or Icon-affecting changes have a current `ICON-YYYYMMDD-VNN`; `IA-01` through `IA-07` pass before page-specific styling, or the unchanged mapping/family reuse is recorded.
- Every affected and unchanged product page/state frame has G-01 through G-06 results or a named approved exception, and every new/structurally changed base batch has passed BF-01 through BF-06 first.
- Full-shell before/after links, screenshots, interaction matrix, and downstream handoff are present; otherwise stop as incomplete.
