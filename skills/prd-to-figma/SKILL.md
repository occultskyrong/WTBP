---
name: prd-to-figma
description: Create or update an editable Figma design from a PRD supplied as text, file, or accessible link. Use for first-time product design, PRD-to-Figma delivery, or creating a new Figma destination when no file link is supplied.
---

# PRD to Figma

Turn a PRD into an editable Figma artifact. The PRD is the only business-fact source. Do not retrieve a knowledge base, require Lark CLI, or add unsupported product rules.

Read [`../../knowledge/design-principles.md`](../../knowledge/design-principles.md) and then [`../../knowledge/design-workflow.md`](../../knowledge/design-workflow.md) before work. The former defines the layered design contract; the latter supplies the operational minimum-brief, conflict, inventory-approval, frame/annotation, text-classification, and artifact-acceptance gates.

## Input Contract

- PRD text, file, or an accessible link.
- A Figma destination: an existing file link, or an explicit request to create a new file.
- The consuming project repository/worktree and preview entry when the design will serve an existing project; for a
  genuinely new or `figma-only` artifact, state that boundary explicitly.
- Target terminals from the PRD when stated (`web`, `miniapp`, `app-*`); `figma-only` is valid.
- A terminal shell contract: shell type, exact viewport/device dimensions, safe areas, navigation/status surfaces, and a visible boundary around the complete page. For `miniapp`, the contract must explicitly require the applicable mini-program shell; for `web`, an approved browser shell or visibly bounded viewport container; for `app-*`, the declared device and safe-area chrome. Do not invent a generic device frame or deliver a bare canvas.
- The current project Icon library/source when one exists; otherwise an explicit boundary that the required Icons are design candidates pending project adoption.
- A minimum brief: outcome, actor/terminal, product/platform, entry/primary journey, scope/exclusions, and visual intent.

Ask for the one missing item only when it would change the page structure, business behavior, or delivery destination. Never invent a terminal, role, permission, workflow, or unavailable state.

## Workflow

1. Preflight the callable official Figma integration with read-only identity/permission proof and record `EX-01`. Use `figma-use` for the declared Figma scope; do not install or substitute a third-party tool when the capability is unavailable.
2. Read the PRD and return a compact cognition record and design contract: outcome, actors, terminal, entry and journey, in-scope pages, material states, targets, exclusions, and open/conflicting rules. Offer distinct resolutions and stop on a material conflict.
3. Inspect the consuming project before designing architecture. Produce `PDC-YYYYMMDD-VNN` and pass `PDC-01`–`PDC-06`: project identity/target, routes and page families, foundations, behavior/platform constraints, reuse/change boundaries, and evidence/decisions. If the project is unavailable, record `figma-only`/new-project scope and mark implementation-dependent fields `Unverified`.
4. Resolve project-contract conflicts and obtain approval of the project design contract before choosing new modules, routes, page families, or visual foundations. Then derive `ARC-YYYYMMDD-VNN` from the approved PDC, mapping modules, routes, shells, reuse boundaries, states/transitions, and the complete base-frame batch; architecture must not introduce an unrecorded contract fact.
5. Create `INV-YYYYMMDD-VNN` with stable feature IDs, `Existing — reuse/modify`, `New`, `Conflict`, or `Unverified` status, expected pages/states, evidence locators, and a visible conflict/decision section. Obtain explicit approval of this inventory before Figma mutation, action-group contracting, or Icon extraction; it is the only approved page/state scope for `AGC-YYYYMMDD-VNN` and `ICON-YYYYMMDD-VNN`.
6. Create and approve `PS-YYYYMMDD-VNN` for every approved page/state before extracting page foundations or creating frames. Record `PS-01`–`PS-05`: page explanation, complete element hierarchy, per-element reuse decision and shared component/token/Icon mapping, L0–L3 Figma/code layer plan, and design-to-code/acceptance mapping. A missing mapping is `Unverified`, not a reason to create a page-local substitute.
7. Build and approve `AGC-YYYYMMDD-VNN` from the approved PDC, ARC, inventory, and page specifications. Classify every interactive region, map it to the shared component/token library, and pass `AGC-01`–`AGC-06` before page styling. For `symmetric-navigation`, use equal edge slots and a parent-centered middle child; do not make several small actions look like one large outlined button.
8. Build `ICON-YYYYMMDD-VNN` from the approved PDC, ARC, inventory, page specifications, and action-group contract, extracting every Icon required by the approved page/state scope. Pass `IA-01`–`IA-07`: reuse the approved project library first, map semantic name/size/style/state/source, and independently design every missing Icon as a reusable family-consistent component before any page uses it.
9. Load `figma:figma-use` before Figma reads or writes. Use `figma:figma-create-new-file` when the user asked for a new destination; otherwise verify the supplied destination before changing it.
10. Create or reuse L1 foundations before page frames: variables/tokens, semantic text styles, approved action-group and Icon components, other components, variants, and real assets. Load `figma:figma-generate-library` only when the requested file lacks the needed foundations; preserve any verified Code Connect/project mapping as the component source of truth (`EX-02`), and never create a page-local control or Icon substitute.
11. Assign a `YYYY-MM-DD-VNN` design batch, then create the complete L0 base-frame batch for every approved page/state inside the declared terminal shell and dimensions. The selected shell or viewport boundary must visibly surround the complete page: use the mini-program shell for `miniapp`, declared device/safe-area chrome for `app-*`, and an approved browser shell or bounded viewport container for `web`. Use neutral placeholders, Auto Layout, and constraints for ordinary content; reserve absolute positioning for proven overlays, badges, or fixed controls.
12. Run and record the blocking base-frame checkpoint (`BF-01`–`BF-06`) across the entire batch: page coverage, shell contract, root geometry, flow hierarchy, state skeleton, and review separation. Do not add L1–L3 work until every result passes or has a named approved exception.
13. Use `figma:figma-generate-design` only after the project contract, page specifications, action-group contract, Icon inventory, foundations, and base-frame checkpoint pass. Implement the approved L1 shared components, L2 page composition/copy/states, and L3 scoped visual styling in separate write batches. Refine generated output with `figma:figma-use`; do not leave a generated reference capture as the final editable design.
14. Add a standalone right-side annotation block for every affected frame, keep design/project/technical descriptions out of the product frame, classify every in-frame text node, capture full-shell screenshots, inspect node geometry and wrapped annotation bounds, and record the acceptance result. After each write, run the shared post-write structural gate (`G-01`–`G-06`) across every product page/state frame, including unchanged frames. Return concrete file, page, frame, component, and state node links.

## Figma Delivery Rules

- Treat tokens, components, variants, Auto Layout, constraints, assets, annotations, and prototype links as design evidence; a screenshot alone is insufficient.
- Every affected feature must be shown inside its complete containing page and applicable platform shell; do not deliver a cropped component.
- Select the shell from the actual target contract and show its visible outer boundary before page styling; a bare canvas or a generic phone frame for Web or Mini Program is a `BF-02`/`G-05` failure.
- Construct and validate all approved page/state base frames before layering page-specific components or visual styles; a failed `BF-01`–`BF-06` checkpoint blocks upper-layer work.
- Before any frame or page-specific styling, approve a page specification with `PS-01`–`PS-05`: explanation/boundary, complete element hierarchy, public component and asset reuse matrix, L0–L3 plan, and design-to-code mapping.
- Build and approve the project design contract (`PDC-01`–`PDC-06`) from the actual consuming project before designing the overall architecture; a PRD or screenshot alone is insufficient.
- Before page-specific styling, use approved `AGC-YYYYMMDD-VNN` and `ICON-YYYYMMDD-VNN` entries only. Action groups must use their declared component, width/slot policy, target size, and state tokens; the page may not compensate with local CSS. Use 16px for dense/inline Icon affordances, 20px for standard controls, 24px for primary navigation or TabBar, and 32px for feature or empty-state emphasis; 48px and above is illustration/empty-state artwork, not a normal Icon variant. Design missing Icons independently in the same family and map every instance to its semantic ID, size, style, state, and source.
- The complete page must show the declared target shell at the approved dimensions. A miniapp design must show the applicable mini-program viewport, device/status/navigation/tab-bar shell, and safe-area behavior.
- Annotation blocks must document identity, user/outcome, scope, fields/filters, rules/provenance, actions/states, exceptions, proposed copy, decisions, and acceptance evidence when applicable.
- Re-open the inventory gate when feedback changes scope, behavior, terminal, permissions/data scope, conflict resolution, or a blocking decision.
- Keep product UI free of delivery commentary. Put review notes outside frames or in Figma annotations.
- Product frames must contain only user-facing product UI and verified/proposed product copy. Page descriptions, project explanations, technical notes, acceptance rules, and review commentary belong only in the standalone right-side annotation sibling.
- Do not overwrite an existing page outside the agreed scope. For an overall redesign, hand off to `figma-evolve` in `regenerate` mode.
- Do not claim implementation, visual parity, or target-platform verification; those belong to later Skills.
- Do not call the artifact complete from prompt output, node-creation success, static checks, or one plausible screenshot; use the shared structural/rendered acceptance contract.
- Do not call the artifact complete until every page has recorded G-01 through G-06: layout owner, one-to-one annotation, text containment, instance/master scale, target shell fidelity, and product-content isolation, or an approved exception.
- A third-party design lint, token, or accessibility audit is optional only. Do not install it, request a PAT, or claim its result without explicit user authorization and `EX-03`–`EX-04` evidence.

## Failure-Driven Design Scenarios

Select applicable scenarios before creating frames and include their IDs in the design contract:

| ID | Given | Required Figma outcome | Later proof |
|---|---|---|---|
| D-01 | A card contains title, dynamic copy, image, and CTA in normal reading order. | Use nested Auto Layout, spacing variables, and content-driven height; do not encode child `x/y` as normal-layout intent. | `figma-to-product` must use normal flow and test dynamic copy. |
| D-02 | A close icon, badge, or floating control overlays a bounded card. | Make the containing Frame and anchor explicit; describe the overlay behavior in an annotation. | `figma-to-product` may use absolute positioning only with that parent and anchor. |
| D-03 | A component has default, loading, disabled, empty, or error behavior. | Create a Variant or state Frame for every material state named by the PRD. | `figma-verify` must include each declared state in its matrix. |
| D-04 | The PRD names only `miniapp`, `web`, or one App target. | Record only those targets in the design contract. | No unlisted target may be implemented or accepted by default. |
| D-05 | A page contains equal-weight navigation, a TabBar, tabs, or a segmented control. | Encode the declared distribution in Auto Layout/constraints and record item weights, partition centers, and tolerance; never place items by hand-written coordinates. | `figma-to-product` and `figma-verify` must prove the distribution at each declared viewport. |
| D-06 | A page contains nested cards, buttons, text, media, or shared component instances. | Preserve the parent/child geometry contract for every descendant and record any intentional overlay or overflow exception. | Verification recursively checks all descendants; a page-only overflow check cannot pass. |
| D-07 | A page contains previous/current-or-reset/next actions, such as month navigation. | Register `symmetric-navigation`; use equal edge target slots, a parent-centered middle action, and compact child controls. | Later proof records `AGC-01`–`AGC-06`, edge target equality, center tolerance, and target sizes at every declared viewport/state. |

These are executable hypotheses, not completion evidence. The later implementation and verification cases must fail before a root-cause fix and pass with screenshot/runtime evidence afterward.

## Output Contract

Return:

```text
PRD source and scope
Design contract and unresolved items
Project design contract revision, `PDC-01`–`PDC-06` results, derived architecture revision (`ARC-YYYYMMDD-VNN`), and evidence boundary
Icon inventory revision, semantic mappings, coupled-asset readiness, and `IA-01`–`IA-07` results
Action-group contract revision, component/token mappings, and `AGC-01`–`AGC-06` results
Inventory version, feature IDs, approval, and conflict result
Page specification IDs, `PS-01`–`PS-05` results, element/reuse matrix, and L0–L3 plan
Design batch, module/frame organization, and annotation IDs
Figma file link
Created or updated page/frame/component/state node links
Tokens and component decisions
Screenshots inspected
Geometry, text classification, accessibility, and acceptance record
Target shell contract and dimensions
Base-frame IDs, neutral screenshots, and `BF-01`–`BF-06` checkpoint results
All-page post-write gate results for `G-01`–`G-06` and approved exceptions
Page/state/transition matrix and unresolved interaction decisions
Targets eligible for implementation
Unverified boundaries and next Skill
```

## Completion Gate

- The PRD, design contract, inventory approval, destination, targets, and material states are recorded.
- The consuming project was inspected and `PDC-01` through `PDC-06` are approved, or the new-project/`figma-only` boundary and `Unverified` fields are explicit.
- The overall architecture is recorded as an `ARC-YYYYMMDD-VNN` derived from the approved project design contract, with no unrecorded route, page family, foundation, terminal, state, or behavior.
- Every approved page/state has an approved `PS-YYYYMMDD-VNN` with `PS-01`–`PS-05`; L0–L3 work and downstream code mapping remain within that specification or a named approved exception.
- The action-group contract is recorded as `AGC-YYYYMMDD-VNN`; `AGC-01` through `AGC-06` pass before page-specific styling, and every approved multi-action region has a component and layout policy.
- The Icon inventory is recorded as `ICON-YYYYMMDD-VNN`, `IA-01` through `IA-07` pass, and every page Icon maps to an approved semantic family, size, style, state, and source.
- Every approved page/state has passed `BF-01` through `BF-06` before styling, and every product page/state frame has G-01 through G-06 results, full-shell screenshots, text/accessibility evidence, and transition decisions.
- Missing integration proof, approval, geometry evidence, or an unresolved conflict blocks the artifact from being called complete.
