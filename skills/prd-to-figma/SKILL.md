---
name: prd-to-figma
description: Create or update an editable Figma design from a PRD supplied as text, file, or accessible link. Use for first-time product design, PRD-to-Figma delivery, or creating a new Figma destination when no file link is supplied.
---

# PRD to Figma

Turn a PRD into an editable Figma artifact. The PRD is the only business-fact source. Do not retrieve a knowledge base, require Lark CLI, or add unsupported product rules.

Read [`../../knowledge/design-workflow.md`](../../knowledge/design-workflow.md) before work. It supplies the shared minimum-brief, conflict, inventory-approval, frame/annotation, text-classification, and artifact-acceptance gates.

## Required Inputs

- PRD text, file, or an accessible link.
- A Figma destination: an existing file link, or an explicit request to create a new file.
- Target terminals from the PRD when stated (`web`, `miniapp`, `app-*`); `figma-only` is valid.
- A minimum brief: outcome, actor/terminal, product/platform, entry/primary journey, scope/exclusions, and visual intent.

Ask for the one missing item only when it would change the page structure, business behavior, or delivery destination. Never invent a terminal, role, permission, workflow, or unavailable state.

## Workflow

1. Preflight the callable Figma integration with read-only identity/permission proof. If the required integration is unavailable, stop; do not silently substitute another artifact type.
2. Read the PRD and return a compact cognition record and design contract: outcome, actors, terminal, entry and journey, in-scope pages, material states, targets, exclusions, and open/conflicting rules. Offer distinct resolutions and stop on a material conflict.
3. Create `INV-YYYYMMDD-VNN` with stable feature IDs, `Existing — reuse/modify`, `New`, `Conflict`, or `Unverified` status, expected pages/states, evidence locators, and a visible conflict/decision section. Obtain explicit approval of this inventory before Figma mutation.
4. Load `figma:figma-use` before Figma reads or writes. Use `figma:figma-create-new-file` when the user asked for a new destination; otherwise verify the supplied destination before changing it.
5. Create or reuse foundations before page frames: variables/tokens, semantic text styles, components, variants, and real assets. Load `figma:figma-generate-library` only when the requested file lacks the needed foundations.
6. Assign a `YYYY-MM-DD-VNN` design batch, then create complete page frames and all material states. Use Auto Layout and constraints for ordinary content. Reserve absolute positioning for proven overlays, badges, or fixed controls.
7. Use `figma:figma-generate-design` for screen generation only after the contract, approved inventory, destination, and foundations are known. Refine generated output with `figma:figma-use`; do not leave a generated reference capture as the final editable design.
8. Add a standalone right-side annotation block for every affected frame, classify every in-frame text node, capture screenshots, inspect node geometry and wrapped annotation bounds, and record the acceptance result. Return concrete file, page, frame, component, and state node links.

## Figma Delivery Rules

- Treat tokens, components, variants, Auto Layout, constraints, assets, annotations, and prototype links as design evidence; a screenshot alone is insufficient.
- Every affected feature must be shown inside its complete containing page and applicable platform shell; do not deliver a cropped component.
- Annotation blocks must document identity, user/outcome, scope, fields/filters, rules/provenance, actions/states, exceptions, proposed copy, decisions, and acceptance evidence when applicable.
- Re-open the inventory gate when feedback changes scope, behavior, terminal, permissions/data scope, conflict resolution, or a blocking decision.
- Keep product UI free of delivery commentary. Put review notes outside frames or in Figma annotations.
- Do not overwrite an existing page outside the agreed scope. For an overall redesign, hand off to `figma-evolve` in `regenerate` mode.
- Do not claim implementation, visual parity, or target-platform verification; those belong to later Skills.
- Do not call the artifact complete from prompt output, node-creation success, static checks, or one plausible screenshot; use the shared structural/rendered acceptance contract.

## Failure-Driven Design Scenarios

Select applicable scenarios before creating frames and include their IDs in the design contract:

| ID | Given | Required Figma outcome | Later proof |
|---|---|---|---|
| D-01 | A card contains title, dynamic copy, image, and CTA in normal reading order. | Use nested Auto Layout, spacing variables, and content-driven height; do not encode child `x/y` as normal-layout intent. | `figma-to-product` must use normal flow and test dynamic copy. |
| D-02 | A close icon, badge, or floating control overlays a bounded card. | Make the containing Frame and anchor explicit; describe the overlay behavior in an annotation. | `figma-to-product` may use absolute positioning only with that parent and anchor. |
| D-03 | A component has default, loading, disabled, empty, or error behavior. | Create a Variant or state Frame for every material state named by the PRD. | `figma-verify` must include each declared state in its matrix. |
| D-04 | The PRD names only `miniapp`, `web`, or one App target. | Record only those targets in the design contract. | No unlisted target may be implemented or accepted by default. |

These are executable hypotheses, not completion evidence. The later implementation and verification cases must fail before a root-cause fix and pass with screenshot/runtime evidence afterward.

## Output Contract

Return:

```text
PRD source and scope
Design contract and unresolved items
Inventory version, feature IDs, approval, and conflict result
Design batch, module/frame organization, and annotation IDs
Figma file link
Created or updated page/frame/component/state node links
Tokens and component decisions
Screenshots inspected
Geometry, text classification, accessibility, and acceptance record
Targets eligible for implementation
Unverified boundaries and next Skill
```
