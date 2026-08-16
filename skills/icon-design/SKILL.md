---
name: icon-design
description: Define, create, and validate a cohesive Icon asset family for an approved product scope or Figma design. Use when a required Icon is missing, a set needs independent design, or visual and implementation consistency must be proven without coupling WTBP to an external generator.
---

# Icon Design

Treat Icon work as an asset contract, not page decoration. Read [`../../knowledge/design-workflow.md`](../../knowledge/design-workflow.md), [`../../knowledge/templates/icon-asset-inventory-template.md`](../../knowledge/templates/icon-asset-inventory-template.md), and the project Icon source before creating anything.

## Hard safety and routing gate

- For a contract-only response with no declared artifact path, begin with this exact status block and do not claim that files or assets were created:

  ```text
  Status
  - External Skill: not installed
  - Figma: not written
  - Human review: not completed; final asset delivery is blocked
  ```

- If the request only selects or places an existing project Icon, do not create an `ICON` asset contract; complete the narrower request directly.
- If the request asks to install, authenticate, update, or execute an external Icon Skill, read credentials, or write to Figma without review, stop and state: `不安装、不认证、不读取凭据、不写入 Figma；人工评审未完成，不能交付最终资产。`
- Do not call a write, edit, or file-creation tool in this Skill. Return the asset contract in the response unless an explicit downstream workflow declares and authorizes an artifact path.

## Input Contract

- An approved `INV`, `AGC`, or `ICON-YYYYMMDD-VNN` scope; for a standalone asset, an explicit asset brief is required.
- The target terminal, semantic meaning, states, sizes, family style, palette, source/ownership constraints, and destination.
- The existing project Icon library or an explicit `Unverified` boundary when no library exists.
- Optional external adapter such as a generator or SVG-processing Skill. Record source URL, fixed revision, license, dependencies, permissions, and whether it was actually used.
- Ask one blocking clarification only when the subject, style anchor, format, or destination would materially change the asset.
- When any required input is missing, do not invent defaults or start authoring. Explicitly list every missing gate before asking for clarification: semantic meaning, target size, family/style anchor, source/ownership or license, format, destination, and project-library boundary.
- For a missing-input response, use the heading `Missing asset gates` and include a line naming all absent gates, including `source/ownership/license`; do not offer a default family, size, source, format, or output path as if it were approved.

## Workflow

1. Reuse an approved project Icon first. If unavailable, create `ICON-YYYYMMDD-VNN` and pass `IA-01` source/ownership, `IA-02` semantic extraction, and `IA-04` state/token mapping before authoring.
2. Write the asset contract: semantic name, family/style anchor, optical size, coordinate system, stroke/fill rules, padding, states, palette roles, export format, and implementation target.
3. Choose one branch per asset: native vector, traced vector, or transparent raster. For three or more Icons, make one representative pilot and review silhouette, padding, optical weight, and smallest-size legibility before expanding the family.
4. Generate or edit through the selected local or external adapter. Keep source, intermediate, preview, and validation artifacts. Never treat an external generator's output as approved by default.
5. Validate `IA-03` size/family/optical rules, `IA-05` independent missing-asset design, `IA-06` implementation mapping, and `IA-07` rendered fidelity. Prefer importing authoritative SVG source into Figma; do not rebuild an Icon from rotated primitives when a source SVG exists.
6. Hand off only validated reusable components/assets to the Figma library and downstream implementation. Record human review and unresolved deviations.

## Boundaries

- Do not use emoji, text glyphs, page-local vectors, arbitrary screenshots, or unlicensed sources as final product Icons.
- Do not write to Figma, code repositories, or external services without an explicit downstream authorization.
- Do not write drafts to WTBP, a consuming repository, or an undeclared temporary directory; local output requires an explicitly declared path and authorization.
- Do not install, authenticate, or silently update an external Icon Skill; it is a replaceable adapter.
- Do not claim family consistency, small-size legibility, licensing, or rendered fidelity without the corresponding evidence and human review.
- Stop when semantic meaning, target size, family anchor, source ownership, or destination is materially missing.

## Output Contract

When a required gate is missing, return this blocking shape before any optional suggestion:

```text
Missing asset gates
- semantic meaning: missing
- target size: missing
- family/style anchor: missing
- source/ownership/license: missing
- format: missing
- destination: missing
- project Icon library boundary: missing
Final asset delivery: blocked pending the missing inputs and human review.
```

Return:

```text
ICON revision and approved scope
Asset contract per Icon: semantic ID, family, size, style, state, source, format, destination
IA-01 through IA-07 results
Pilot and family consistency evidence
Source/revision/license/permission record for every external adapter or source
Validation artifacts and intended display-size review
Figma component/export and code mapping
Human review, deliberate deviations, and unresolved items
```

Unless explicit human-review evidence is supplied, include the exact status `人工评审：未完成，不能交付最终资产`.

## Completion Gate

- The scope is approved or explicitly marked `Unverified`; every Icon has a stable semantic ID.
- Source ownership, family rules, optical size, state/token mapping, implementation mapping, and rendered fidelity are recorded.
- A representative pilot was reviewed before a multi-Icon set was expanded.
- Every final asset passes deterministic structural checks and human visual review at the smallest intended size.
- Only validated reusable assets are handed off; no external Skill was copied, installed, or treated as the WTBP source of truth.
