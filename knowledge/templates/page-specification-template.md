# Page Design and Implementation Specification

Create one `PS-YYYYMMDD-VNN` specification for every approved page/state before creating its Figma base frame or
implementing its target code. This is the page-level bridge between the approved project design contract, architecture,
inventory, shared component contracts, and layered delivery. It is a review document or right-side annotation source;
its explanatory content must not be placed inside product UI.

## Metadata

```text
specification_id: PS-YYYYMMDD-VNN
status: Draft | Approved | Blocked
PDC_revision:
ARC_revision:
inventory_revision:
feature_id:
page_state_id:
terminal_and_shell:
figma_frame_or_target_path:
owner:
reviewer:
evidence_date:
```

## Terminal shell selection (part of `PS-01`)

| Declared target | Selected shell representation | Visible page boundary | Dimensions | Chrome, safe area, and navigation surfaces | Evidence | Decision |
|---|---|---|---|---|---|---|
| web / miniapp / app-* | browser shell / bounded viewport / mini-program shell / declared device | required around the full page |  |  |  |  |

Use the target's actual terminal evidence. A Figma page may not be a bare canvas: `web` uses an approved browser shell
or visibly bounded viewport container; `miniapp` uses the applicable mini-program shell; `app-*` uses the declared
device and safe-area chrome. A generic phone frame cannot substitute for another terminal. Browser chrome may be
omitted only when it is outside the product contract; the viewport boundary still remains visible.

### Boundary ownership and visual proof (required)

| Shell node | Product root Frame | System chrome owner / safe-area relationship | Product TabBar owner | Section ownership rule | Annotation sibling | Visual-boundary recipe | Fixed unselected capture | Four-edge result |
|---|---|---|---|---|---|---|---|---|
| | | | | `Section` is a descendant of the product root; it never substitutes for root or shell. | Right-side sibling, outside product root. | Fill/surface; stroke or `N/A` reason; radius or `N/A`; shadow/chrome; canvas contrast. | Target, state, data, viewport/scale, shell/root IDs and bounds; selection hidden. | Top / right / bottom / left, each with visible canvas margin. |

`Canvas` is workspace backdrop only. A Figma selection outline, handles, rulers, a Section edge, or a cropped screenshot is never boundary evidence. The shell contains the product root and declared system chrome. Product content and product TabBar remain inside the root. `BF-02S`/`G-05S` prove hierarchy and geometry; `BF-02V`/`G-05V` prove the unselected visual boundary. Both sub-results are required.

## 1. Page explanation and boundary (`PS-01`)

- User, outcome, entry, primary task, and exit/recovery:
- In-scope content, actions, material states, and transitions:
- Explicit exclusions and unresolved facts:
- Requirement/project/Figma evidence locators:
- Right-side annotation sections required for this page:

## 2. Element inventory and hierarchy (`PS-02`)

| Element ID | Parent/region | Semantic role | Content/data source | States | Layout role | Figma node | Target code owner | Evidence |
|---|---|---|---|---|---|---|---|---|
| EL-01 |  |  |  |  | normal-flow / overlay / fixed |  |  |  |

Every visible or interactive element must appear once. Record overlays with their containing parent, anchor, and reason;
ordinary content must have a normal-flow/Auto Layout owner.

### Section boundary rule

| Section ID | Child/column inputs | Fixed padding | Recomputed content bounds | Fixed width/height exception | Evidence |
|---|---|---|---|---|---|
| SEC-01 |  |  |  |  |  |

When nodes move, a page is added or removed, or a Section's column count changes, recalculate the affected Section from
its actual content bounds plus its declared fixed padding. Do not retain a former fixed width or height; any fixed-size
exception must name the product rule and approval.

## 3. Shared foundation and component reuse matrix (`PS-03`)

| Element ID | Reuse decision (`reuse` / `extend` / `new` / `Unverified`) | Component/variant | Token/type/icon/asset | Code Connect or project mapping | Allowed extension | Evidence |
|---|---|---|---|---|---|---|
| EL-01 |  |  |  |  |  |  |

- Action-group entries and width/slot/target policy (`AGC-YYYYMMDD-VNN`):
- Icon semantic IDs and size/style/state/source (`ICON-YYYYMMDD-VNN`):
- Missing component/Icon decision, owner, and approval boundary:

## 4. Layered Figma and implementation plan (`PS-04`)

| Layer | Figma construction | Target implementation | Required proof before advancing |
|---|---|---|---|
| L0 Structural base | Terminal shell, page root, regions, normal-flow/Auto Layout parents, state slots, annotation sibling | Route/entry, shell, page root, layout owners, state slots | BF-01–BF-06, `BF-02S`/`BF-02V`, and page shell evidence |
| L1 Shared foundations | Approved components, variants, tokens, action groups, Icons, assets | Existing/project components, tokens, Code Connect mappings | PS-03 mappings and AGC/ICON gates |
| L2 Page composition | Element hierarchy, verified/proposed product copy, data and material states | Page composition, data/state wiring, normal-flow layout | EL coverage and declared states present |
| L3 Scoped finish | Page-specific visual styling, approved overlays, interaction details | Scoped styles, assets, responsive behavior, interaction details | No local component clone or compensating geometry |

Do not start a later layer while the preceding layer is missing, failed, or `Unverified` without an explicit approved exception.

## 5. Design-to-code mapping and acceptance (`PS-05`)

| Element ID | Figma component/node | Target component/file | Layout owner | Viewport/state | Acceptance evidence | Status |
|---|---|---|---|---|---|---|
| EL-01 |  |  |  |  |  |  |

- Target/viewport/state matrix entries:
- First divergent layout owner when implementation differs:
- Required full-shell screenshots and annotation evidence:
- Shell/root ownership, visual recipe, fixed unselected capture, and top/right/bottom/left edge outcomes:
- Handoff to `figma-to-product` / `figma-verify`:

A page is ready only when both structural (`BF-02S`/`G-05S`) and visual (`BF-02V`/`G-05V`) boundary evidence pass.

## Approval record

- Approved specification revision and approver/date:
- Approved exceptions:
- Blocking items and next decision:
