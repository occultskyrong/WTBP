---
name: prd-to-figma
description: Create or update an editable Figma design from a PRD supplied as text, file, or accessible link. Use for first-time product design, PRD-to-Figma delivery, or creating a new Figma destination when no file link is supplied.
---

# PRD to Figma

Turn a PRD into an editable Figma artifact. The PRD is the only business-fact source. Do not retrieve a knowledge base, require Lark CLI, or add unsupported product rules.

## Required Inputs

- PRD text, file, or an accessible link.
- A Figma destination: an existing file link, or an explicit request to create a new file.
- Target terminals from the PRD when stated (`web`, `miniapp`, `app-*`); `figma-only` is valid.

Ask for the one missing item only when it would change the page structure, business behavior, or delivery destination. Never invent a terminal, role, permission, workflow, or unavailable state.

## Workflow

1. Read the PRD and return a compact design contract: outcome, actors, entry and journey, in-scope pages, material states, targets, exclusions, and open or conflicting rules. Stop on a material conflict instead of encoding both alternatives.
2. Load `figma:figma-use` before Figma reads or writes. Use `figma:figma-create-new-file` when the user asked for a new destination; otherwise verify the supplied destination before changing it.
3. Create or reuse foundations before page frames: variables/tokens, semantic text styles, components, variants, and real assets. Load `figma:figma-generate-library` only when the requested file lacks the needed foundations.
4. Create complete page frames and all material states. Use Auto Layout and constraints for ordinary content. Reserve absolute positioning for proven overlays, badges, or fixed controls.
5. Use `figma:figma-generate-design` for screen generation only after the contract and destination are known. Refine generated output with `figma:figma-use`; do not leave a generated reference capture as the final editable design.
6. Capture a screenshot and return concrete file, page, frame, component, and state node links. Record the design contract in the response or a Figma annotation page; it is task-local evidence, not a knowledge base.

## Figma Delivery Rules

- Treat tokens, components, variants, Auto Layout, constraints, assets, annotations, and prototype links as design evidence; a screenshot alone is insufficient.
- Keep product UI free of delivery commentary. Put review notes outside frames or in Figma annotations.
- Do not overwrite an existing page outside the agreed scope. For an overall redesign, hand off to `figma-evolve` in `regenerate` mode.
- Do not claim implementation, visual parity, or target-platform verification; those belong to later Skills.

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
Figma file link
Created or updated page/frame/component/state node links
Tokens and component decisions
Screenshots inspected
Targets eligible for implementation
Unverified boundaries and next Skill
```
