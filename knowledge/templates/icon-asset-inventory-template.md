# Icon and Visual Asset Inventory

Create this inventory after the project design contract and architecture are approved, before page-specific styling.
It separates reusable Icon assets from page composition and records the coupled assets that can otherwise create
visual drift.

## Inventory metadata

```text
icon_inventory_id: ICON-YYYYMMDD-VNN
status: Draft | Approved | Blocked
project_design_contract: PDC-YYYYMMDD-VNN
architecture_revision: ARC-YYYYMMDD-VNN
terminal_and_shell:
source_library_or_repository:
inspection_date:
owner:
next_reviewer:
```

## Icon source and semantic map

| Icon ID | Semantic name | Existing source/component/node | Surfaces and states | Classification | Permission/license | Decision |
|---|---|---|---|---|---|---|
| ICON-01 | `navigation/back` |  |  | Existing — reuse / New / Unverified |  |  |

Do not use page-local vectors, emoji, text glyphs, screenshots, or an unapproved third-party set as an Icon source.
Every product Icon instance must map to one semantic Icon ID and one reusable source/component.

## Size, style, and state contract

Use vector masters and create only the sizes that the declared terminal and real usage require. The default role map is:

| Size | Typical role | Required check |
|---|---|---|
| 16 | Dense table/list or inline action | Pixel alignment and readable optical weight |
| 20 | Standard control or input adornment | Optical centering and touch-target separation |
| 24 | Primary action, navigation, TabBar, or mobile control | Shell/navigation alignment and selected state |
| 32 | Feature callout or empty-state symbol | Visual weight remains in the same family |

`48px+` belongs to illustration/empty-state artwork, not the normal Icon system. Do not export every size by default:
record only used variants, and design an independently corrected variant when scaling would change stroke, detail,
or optical balance.

- Master grid and pixel alignment:
- Outline/filled family and permitted mixing rule:
- Stroke weight, cap, join, corner, and optical-boundary rule:
- Color tokens and inverse/dark-mode rule:
- Required states: default, selected/active, disabled, destructive, inverse, loading (only when applicable):
- Figma component naming: `Icon/<semantic>/<size>/<style>/<state>`:
- Code/component mapping and export format:

## Missing Icon design queue

| Icon ID | Missing need and semantic intent | Required sizes/states | Family references | Design decision | Reviewer | Resulting component/node |
|---|---|---|---|---|---|---|
| ICON-NEW-01 |  |  |  | New independent Icon component |  |  |

Design each missing Icon as a standalone, reusable component before it appears in a page. Compare it with the
approved family at each required size; never create a one-off page-specific substitute.

## Coupled asset checks

| Asset class | Existing source and ownership | Required variants | Mapping/constraint | Status |
|---|---|---|---|---|
| Font |  | weights, fallback, license | loading and line-height evidence |  |
| Logo/brand mark |  | light/dark, compact/full | clear-space and no-redraw rule |  |
| Image/illustration |  | crop, density, empty state | source/rights and responsive behavior |  |
| Motion/animated asset |  | reduced-motion/static fallback | trigger, duration, loading impact | N/A unless material |

## Icon asset gate

1. **Source and ownership (`IA-01`)** — inspect the actual project/Figma library and record source, ownership,
   license/permission, and stale or unavailable evidence.
2. **Semantic extraction (`IA-02`)** — extract every Icon used by approved pages/states into semantic IDs, with no
   duplicate meaning or page-local substitute.
3. **Size and family (`IA-03`)** — define the required 16/20/24/32 variants by real role, master grid, stroke/fill,
   optical alignment, and terminal-specific exceptions.
4. **State and token mapping (`IA-04`)** — map color tokens and required state variants; no hard-coded color or
   unverified mixed library is allowed.
5. **Missing-Icon design (`IA-05`)** — each missing Icon has an independent reusable component, family comparison,
   reviewer decision, and source/node mapping before page use.
6. **Implementation mapping (`IA-06`)** — every Figma and product instance maps to the same Icon ID, component, size,
   state, and exact asset/export.
7. **Rendered fidelity (`IA-07`)** — inspect required sizes/states in the declared terminal shell for pixel alignment,
   optical balance, contrast, touch-target separation, clipping, and fallback behavior.

Record `pass`, `blocked`, or an explicitly approved exception for every item. Missing source, unapproved Icon family,
or an unmapped page Icon blocks page-specific styling, implementation handoff, and acceptance.
