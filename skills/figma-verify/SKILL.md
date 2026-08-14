---
name: figma-verify
description: Verify a Figma node against a running implementation for only the user-declared targets, diagnose layout drift to its responsible ancestor, and report evidence or apply explicitly requested scoped fixes. Use for Figma-to-product acceptance, visual regression, or CSS/layout offset investigation.
---

# Figma Verify

Validate actual implementation evidence against current Figma design evidence. This Skill does not assume every delivery includes Web and Mini Program; verify only declared targets.

Read `../../knowledge/design-principles.md` and then `../../knowledge/design-workflow.md` before verification. They are the shared contract for the layered scope, evidence precedence, inventory approval, complete-page coverage, annotation geometry, text classification, accessibility, and real-fixture acceptance.

## Input Contract

- Concrete Figma node links for the page, state, or component under review.
- At least one declared target and its runnable product, preview, or repository.
- Acceptance matrix: viewport/device and material states. Use PRD values when provided; otherwise request only the missing acceptance dimension.
- Target shell contract: shell type, exact dimensions, device/browser chrome, safe areas, and navigation/status surfaces. For `miniapp`, verify the mini-program shell rather than a generic mobile frame.
- The approved design inventory and stable feature IDs. If no approved inventory exists, reconstruct the smallest inventory from the authoritative requirement and record it as `Unverified` until approval; do not claim acceptance for unapproved scope.
- The approved project design contract `PDC-YYYYMMDD-VNN`, or repository evidence sufficient to reconstruct it before
  comparing implementation parity.
- The derived architecture record `ARC-YYYYMMDD-VNN` when the target includes a project architecture; if it is
  missing or stale, stop and route back to the contract/architecture gate.
- Mode: `report` by default; `fix` only when the user explicitly authorizes scoped implementation changes.

## Workflow

1. Confirm the input contract, current project design contract (`PDC-YYYYMMDD-VNN`), and mode, then build the
   target/viewport/state matrix before comparing anything.
2. Capture stable Figma and runtime evidence, run the structural and layout gates, and classify each mismatch.
3. In `fix` mode, change only the first proven cause, rerun the affected matrix, and preserve before/after evidence.
4. Produce the acceptance record and list unverified or human-review items.

## Evidence and Matrix Gate

1. Load the appropriate Figma inspection Skill and capture current Figma screenshots, hierarchy, tokens, constraints, components, and target node IDs.
2. Build a target matrix. A target is valid only with applicable device/viewport, states, and runtime evidence. `figma-only` checks Figma completeness without implementation parity.
3. Stabilize each implementation capture: correct viewport/device, loaded fonts and assets, deterministic data where possible, and no transient animation state.
4. Confirm the project design contract and derived architecture are current. Compare the implementation against
   `PDC-01`–`PDC-06` and `ARC-YYYYMMDD-VNN`: project target, routes/page families, foundations, behavior/constraints,
   reuse boundaries, architecture relationships, and evidence. A missing, stale, or materially conflicting contract
   or architecture blocks acceptance.
5. Confirm the approved inventory and feature IDs are covered. Verify the complete containing page and declared target shell at the approved dimensions, not only a cropped component; verify the standalone right-side annotation block and its geometry.
6. Confirm that the base-frame batch was constructed for every approved page/state before upper-layer styling. Inspect the `BF-01`–`BF-06` record and neutral captures; missing, partial, or failed base evidence blocks acceptance.
7. Classify every visible string as verified product copy, `Copy for review`, design commentary outside the artifact, or unsupported copy removed. Page descriptions, project/technical notes, and acceptance commentary inside the product frame are G-06 failures.
8. Compare structure, layout, and visual result. A page screenshot is necessary but not sufficient.
9. Run the shared post-write structural gate (`G-01`–`G-06`) across every product page/state frame, including unchanged frames: `layoutMode`/layout owner, navigation distribution, one-to-one right-side annotation, recursive descendant containment, shared instance/master width and height ratios, target shell fidelity, and product-content isolation. Record each result and approved exception.
10. Compare prototype links or runtime action transitions with the approved page/state/transition matrix; an untraced action, dead end, or recovery path is a verification failure, not a visual refinement.

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
| V-08 Navigation distribution drift | A TabBar or segmented navigation looks nearly, but not truly, equally divided. | Inspect Auto Layout/Flex/Grid distribution, item weights/basis, partition centers, and tolerance; reject hand-placed coordinates unless the product contract explains them. | All declared navigation items satisfy the distribution contract at every target viewport. |
| V-09 Recursive child overflow | The page bounding box passes but an inner card, button, text node, media asset, or shared instance clips or crosses its parent. | Recursively traverse every descendant and compare direct-parent and ancestor geometry; inspect overflow/clipping and record the first divergent owner. | Every descendant passes containment, or the exact approved overflow/overlay exception is recorded. |

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

## Acceptance Gate

An acceptance record is complete only when it includes the project design contract revision, derived architecture
revision (`ARC-YYYYMMDD-VNN`), and `PDC-01`–`PDC-06`/architecture comparison results, inventory/feature IDs, target
shell contract, base-frame IDs and `BF-01`–`BF-06` results, target matrix, complete-page and material-state full-shell
screenshots, expected-versus-actual geometry, annotation bounds when applicable, all-page `G-01`–`G-06` results, text
classifications and provenance, accessibility checks (contrast, non-color status, and keyboard/focus behavior for
HTML), the first divergent layout owner, and the rerun result after any authorized fix. A prompt, generated code,
node creation, static check, one screenshot, or Skill-Eval dry run is not acceptance evidence.

## Output Contract

Return:

```text
Figma nodes, targets, matrix, and mode
Project design contract revision, derived architecture revision (`ARC-YYYYMMDD-VNN`), `PDC-01`–`PDC-06`/architecture comparison results, and evidence boundary
Approved inventory version and covered feature IDs
Screenshots and deterministic capture conditions
Pass/fail by target, viewport/device, and state
Mismatch classification and first divergent layout owner
Expected versus actual geometry/style evidence
Annotation geometry, text classifications/provenance, and accessibility result
Target shell contract and dimensions
Base-frame batch, neutral captures, and `BF-01`–`BF-06` results
All-page post-write gate results for `G-01`–`G-06` and approved exceptions
Interaction transition results, real-fixture acceptance record, and rerun result
Fixes made only in fix mode
Human-review items, unresolved evidence, and next action
```

## Completion Gate

- Every declared target, viewport, state, page, and transition has an independent result.
- BF-01 through BF-06 passed before styling, and G-01 through G-06, accessibility, first-divergent-owner, and rerun evidence are recorded or explicitly blocked.
- A prompt, static check, one screenshot, or dry-run alone never closes acceptance; missing real-fixture evidence blocks completion.
