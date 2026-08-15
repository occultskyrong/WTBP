# Action Group Contract

Create this contract from the approved `INV-YYYYMMDD-VNN`, after the project design contract and architecture are
approved and before Icon extraction, base-frame construction, page-specific styling, or implementation. It records
the reusable interaction primitive rather than allowing each page to invent its own button geometry or CSS.

## Contract metadata

```text
action_group_contract_id: AGC-YYYYMMDD-VNN
status: Draft | Approved | Blocked
project_design_contract: PDC-YYYYMMDD-VNN
architecture_revision: ARC-YYYYMMDD-VNN
approved_inventory: INV-YYYYMMDD-VNN
terminal_and_shell:
component_library_or_repository:
owner:
inspection_date:
next_reviewer:
```

## Action-group registry

| Group ID | Feature/page/state IDs | Classification | User outcome | Children and order | Width/slot policy | Registered component | Status |
|---|---|---|---|---|---|---|---|
| AG-01 |  | `single-action` / `action-group` / `symmetric-navigation` / `segmented-selection` |  |  | `content` / `equal` / `full-span` and `natural` / `equal-slot` / `equal-partition` |  | Draft |

`single-action` has one action and one complete target. `action-group` contains two or three related actions.
`symmetric-navigation` has previous/current-or-reset/next semantics and requires equal edge slots.
`segmented-selection` changes one mutually exclusive selection; do not use it for unrelated actions.

## Component and token mapping

| Group ID | Child ID | Semantic action | Component/variant | Visible label or Icon ID | Target size | Visual size | Spacing/radius/state tokens | Figma node | Code mapping |
|---|---|---|---|---|---|---|---|---|---|
| AG-01 | AG-01-01 |  | `IconButton` / `TextButton` / approved component |  |  |  |  |  |  |

Use the approved project component and token library first. The visible Icon and its hit target are separate values:
the visual Icon is normally 16/20/24/32 by role, while target size follows the declared target platform. For custom
pointer targets, use at least 24 by 24 CSS px unless the recorded spacing exception applies; use 44 by 44 CSS px or
platform-equivalent for frequent mobile actions. See [W3C target size](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum),
[W3C enhanced target size](https://www.w3.org/WAI/WCAG22/Understanding/target-size-enhanced), and
[Apple button guidance](https://developer.apple.com/design/human-interface-guidelines/buttons).

## Layout and semantic policy

For every group, record:

- parent role and visual role: `button`, `group`, `toolbar`, or `segmented control`;
- whether the parent is a background/toolbar or itself one action; a multi-action parent must never visually or
  semantically impersonate one large button;
- width policy: `content` by default, `equal` only for equal-priority regular text-button groups, and `full-span`
  only when the declared container/context requires it;
- slot policy and layout owner: Flex/Grid/Auto Layout, columns/basis/constraints, parent padding, gap, and responsive
  behavior;
- state policy: default, hover, pressed, focus-visible, selected, disabled, loading, and unavailable explanation
  only when applicable;
- accessible names and keyboard behavior for every icon-only or stateful action.

For `symmetric-navigation`, use `equal-slot`: left and right children use the same component and target size; the
middle child is centered relative to the parent, not merely between unequal siblings. Use a three-slot Grid or
equivalent Auto Layout constraint. Do not use hand-placed coordinates or `space-between` as proof of exact centering.
When an edge action is unavailable, keep an equal non-action spacer or an explicit layout rule so that the middle
does not drift.

## Action-group gate

1. **Classification and scope (`AGC-01`)** — every approved interactive region is classified, mapped to feature/page/state IDs, and has no unrelated action mixed into its group.
2. **Component reuse (`AGC-02`)** — each child uses an approved component/variant or a recorded minimal extension; no page-local clone, one-off vector, or ad hoc CSS substitutes a registered control.
3. **Target and density (`AGC-03`)** — target size, visual Icon/text size, padding, gap, and full-span exception are token-mapped and appropriate to the terminal; large empty outlined areas cannot misrepresent small separate actions.
4. **Distribution and centering (`AGC-04`)** — declared width/slot policy is encoded in Auto Layout/Flex/Grid. For `equal-slot`, record equal edge dimensions and the middle-center tolerance; for `equal`, record common width/basis and gaps.
5. **State and accessibility (`AGC-05`)** — interactive states, contrast, focus, disabled behavior, keyboard behavior, and accessible names are recorded; icon-only buttons state their action, not their glyph.
6. **Implementation and evidence (`AGC-06`)** — map Figma component/token to target component/CSS and define the Figma/DOM geometry, declared viewport/state, screenshot, and human-review checks required for acceptance.

Any missing classification, unapproved full-span behavior, unequal `symmetric-navigation` slot, missing target-size
evidence, or page-local workaround blocks page-specific styling, implementation handoff, and acceptance. Record
`pass`, `blocked`, or a named approved exception for every applicable item.

## Verification record

| Group ID | Viewport/state | Left/right target geometry | Center or partition geometry | Figma/DOM layout owner | Screenshot/evidence | Result | Exception |
|---|---|---|---|---|---|---|---|
| AG-01 |  |  |  |  |  | pass / blocked |  |
