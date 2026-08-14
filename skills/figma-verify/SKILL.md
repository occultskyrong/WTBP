---
name: figma-verify
description: Verify a Figma node against a running implementation for only the user-declared targets, diagnose layout drift to its responsible ancestor, and report evidence or apply explicitly requested scoped fixes. Use for Figma-to-product acceptance, visual regression, or CSS/layout offset investigation.
---

# Figma Verify

Validate actual implementation evidence against current Figma design evidence. This Skill does not assume every delivery includes Web and Mini Program; verify only declared targets.

## Required Inputs

- Concrete Figma node links for the page, state, or component under review.
- At least one declared target and its runnable product, preview, or repository.
- Acceptance matrix: viewport/device and material states. Use PRD values when provided; otherwise request only the missing acceptance dimension.
- Mode: `report` by default; `fix` only when the user explicitly authorizes scoped implementation changes.

## Evidence and Matrix Gate

1. Load the appropriate Figma inspection Skill and capture current Figma screenshots, hierarchy, tokens, constraints, components, and target node IDs.
2. Build a target matrix. A target is valid only with applicable device/viewport, states, and runtime evidence. `figma-only` checks Figma completeness without implementation parity.
3. Stabilize each implementation capture: correct viewport/device, loaded fonts and assets, deterministic data where possible, and no transient animation state.
4. Compare structure, layout, and visual result. A page screenshot is necessary but not sufficient.

## Layout Diagnosis Gate

For every meaningful offset, report the first divergent layout owner rather than proposing a child-level cosmetic patch.

Trace the rendered target element and Figma counterpart through their ancestor chains. Compare dimensions, padding, margin, gap, flex/grid direction and rules, position/containing block, overflow, transforms, box sizing, fonts/line-height, variables, and responsive rules.

Classify the cause as one of:

```text
structure | layout-owner | positioning | typography/assets | cascade | environment | unresolved
```

Do not mark acceptance as passed solely because a diff threshold is small, static checks pass, or one screenshot looks plausible. Human judgment remains required for intentional visual differences and interaction quality.

## Fix Mode

When `mode=fix`, change only the first proven cause, rerun the affected matrix entries, and report the before/after evidence. Do not add compensating child margins, transforms, or absolute positioning to conceal a parent-level error.

## TDD-Style Fidelity Cases

For each applicable case, first capture a reproducible failing state, then prove a scoped root-cause fix with the same target, viewport/device, state, Figma node, fonts, assets, and data. Do not replace a failing baseline while investigating.

| ID | Reproducible failure | Required diagnosis | Passing proof |
|---|---|---|---|
| V-01 Absolute misuse | Normal card content shifts when text or image height changes. | Classify normal flow versus overlay and inspect the containing block. | Dynamic-content capture matches Figma intent without coordinate compensation. |
| V-02 Parent-chain omission | A whole section is offset by a constant amount. | Compare ancestors to find the first divergent padding/gap/dimension/layout rule. | The owner is corrected and child compensation is absent. |
| V-03 Cascade/geometry leak | Correct local styles lose to a global selector, transform, overflow, or box model rule. | Record the winning computed rule and its source. | Scoped correction fixes the target without regression in the declared matrix. |
| V-04 Font/asset instability | Text wraps differently or media changes layout after load. | Verify loaded font, line-height, intrinsic image size, and crop behavior before visual diff. | Stable repeated captures show the intended geometry. |
| V-05 Responsive drift | A page matches at one width but breaks at another. | Compare each declared viewport/device against Figma constraints. | Every declared viewport/state has an independent result. |
| V-06 State omission | Default state looks right but loading/error/disabled differs. | Compare the Figma Variant or state Frame and runtime state. | Every declared state is passed, failed, or explicitly blocked. |
| V-07 Target leakage | A request names only one platform but the report claims cross-platform acceptance. | Check the PRD/design contract target list. | Report contains only declared targets; unlisted targets are `not requested`. |

Use these case IDs in the target matrix. A case is **passed** only after the failing baseline, first-cause diagnosis, repair evidence when authorized, and post-fix capture are all present.

## Real-Fixture Contract

For a claim that a case is solved, store or return this minimum evidence for that one case:

```text
case_id, Figma file/node URL, target, repository/preview
viewport or device, state, deterministic data and capture conditions
baseline screenshot, expected Figma screenshot, post-fix screenshot
first divergent layout owner and computed-style/geometry evidence
changed files or Figma nodes, rerun result, human-review result
```

Prompt-level cases prove that the agent follows the workflow. They do **not** prove a particular CSS implementation is fixed. Promote a case to solved only with this real-fixture evidence.

## Output Contract

Return:

```text
Figma nodes, targets, matrix, and mode
Screenshots and deterministic capture conditions
Pass/fail by target, viewport/device, and state
Mismatch classification and first divergent layout owner
Expected versus actual geometry/style evidence
Fixes made only in fix mode
Human-review items, unresolved evidence, and next action
```
