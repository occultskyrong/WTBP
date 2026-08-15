# Shared Design Workflow and Acceptance Contract

This is the shared process for WTBP design Skills. Read [the upstream design principles and layered framework](design-principles.md) first, then read this operational contract before creating, evolving, implementing, or accepting a visual artifact. The workflow is fail-closed: a prompt, `start`, or an explicit request to skip questions never replaces a missing brief, unresolved material conflict, inventory approval, or artifact evidence.

## 1. Scope and outcome

Design work produces two distinct outcomes in order:

1. an evidence-based overview and change inventory for user approval;
2. an annotated visual artifact or an implementation/acceptance result after the required gate is passed.

Do not implement product code, change runtime configuration, estimate delivery, or call a visual proposal an implemented contract unless the selected Skill explicitly owns that work. Keep design inventories at feature level; do not turn them into API, database, class, or engineering-task plans.

## 2. Minimum brief and terminal

Before visual mutation, establish:

- intended outcome;
- actor and target terminal;
- product and platform;
- entry point and primary journey;
- in-scope and excluded scope;
- whether a visual artifact is actually requested.

Use the terminal and actor labels defined by the target product or project. If a shared taxonomy is needed, record the explicit mapping in the cognition record before using it; never import roles from another project, example, or repository name. Determine ownership from routes, authentication, permissions, callers, and product copy; do not infer a terminal from the fact that a screen is mobile.

Before composition, define the terminal shell contract from the declared target and evidence: shell type, viewport/frame dimensions, device chrome, safe areas, navigation bars, status areas, and any embedded browser or host constraints. Do not invent a generic phone frame. For `miniapp`, explicitly show the mini-program viewport and its applicable device/status/navigation/tab-bar shell; for `app-ios` or `app-android`, show the declared device and safe-area chrome; for `web`, show the approved browser/viewport or responsive canvas without adding browser chrome unless it is part of the product contract. Record the source and dimensions in the inventory and acceptance matrix.

For overlapping designs, also require source design timestamps and the user-selected authoritative baseline. If either is missing, record `Unverified` and stop composition until the collision can be resolved.

## 3. Requirement and evidence gates

When a requirement document, file, link, or complete requirement content is supplied, create a compact cognition record before design:

- source, title, version/date, and authority;
- outcome, actors, terminal, product, entry, and journey;
- in-scope and excluded capabilities;
- business rules, permissions, states, actions/transitions, recovery paths, exceptions, acceptance conditions, and open questions.

Run a conflict pass across the document, current evidence, and approved history. A conflict affecting outcome, actor/terminal, journey, scope, permission/data scope, authoritative rule, destructive consequence, page structure, or available states is material. State both sides, offer 2–3 distinct resolutions with trade-offs, recommend only when evidence supports it, and stop until the user selects a resolution.

Use this evidence precedence without hiding real conflicts: approved user decision, authoritative supplied requirement, current owning API/dictionary/permission contract, verified current UI, then implementation inference. Record a compact locator for every material rule or value: source type and section, repository/branch/commit and file/symbol, API/dictionary key, or approved decision/date. If evidence is inaccessible or stale, use `Unverified / 待确认`, never `Existing` or `New` by guesswork.

## 4. Project design contract gate

Before designing the overall information architecture or mutating Figma/HTML, inspect the actual consuming project
when one exists. Use repository/runtime evidence, not a screenshot or prompt, and create a versioned contract
`PDC-YYYYMMDD-VNN`. For a genuinely new or `figma-only` project with no consuming repository, record that boundary
explicitly and mark implementation-dependent fields `Unverified` rather than inventing them.

The contract must record:

1. **Project identity and target (`PDC-01`)** — repository/worktree, branch/commit or Figma baseline, product,
   platform, declared terminal, runtime/preview entry, and the inspected evidence date.
2. **Surface inventory (`PDC-02`)** — existing routes/entries, page families, states, navigation shells, viewport/device
   targets, and the owning feature or module for each surface.
3. **Foundations (`PDC-03`)** — reusable components/variants, tokens/variables, typography, assets, icons, layout
   conventions, and their source paths or Figma node IDs. Record the existing Icon library/source, semantic naming,
   supported sizes/styles/states, ownership/license, and any unknown or conflicting family before reuse.
4. **Behavior and constraints (`PDC-04`)** — permissions, data/API boundaries, actions/transitions, responsive rules,
   accessibility requirements, shell/safe-area limits, and known platform restrictions.
5. **Reuse and change boundary (`PDC-05`)** — what is `Existing — reuse`, `Existing — modify`, `New`, `Conflict`, or
   `Unverified`; what must be reused, what may be extended, consumer impact, and what must not be rebuilt or changed.
6. **Evidence and decisions (`PDC-06`)** — source locators, screenshots/runtime captures, conflicts, approved decisions,
   contract revision, unresolved `Unverified` items, and the next review owner.

Start from the [project design contract template](templates/project-design-contract-template.md), then attach the
repository and runtime locators that support each field. The template is a recording aid, not a substitute for
actual project inspection.

Run a project-contract conflict pass before architecture. A mismatch in route ownership, component/token contract,
terminal, state, permission/data scope, or layout constraint is blocking. Do not design a new page family or visual
foundation until the user approves the contract or explicitly accepts the named `Unverified` boundary.

The project design contract is the source for the architecture, inventory, foundations, base-frame batch, implementation
mapping, and verification matrix. A stale contract must be re-read and versioned before downstream work continues.

### Architecture derivation gate

After the project design contract is approved, derive the overall architecture as `ARC-YYYYMMDD-VNN` before creating
or mutating the inventory or visual artifact. The architecture record must map the contract to:

- module, route/entry, page-family, and navigation relationships;
- surface ownership, target shells, viewport/device dimensions, and safe-area boundaries;
- reuse, extension, and genuinely new component/foundation decisions;
- state, transition, permission/data, and recovery-path responsibilities;
- the complete page/state base-frame batch and its downstream implementation/verification targets; and
- rejected alternatives, material trade-offs, and the PDC locators that support each decision.

Architecture is blocked when it introduces a route, page family, component foundation, terminal, state, or behavior
not present in PDC-01–PDC-06 without a new contract revision and conflict decision. Use the [project design contract
template](templates/project-design-contract-template.md) for the evidence handoff, then record the `ARC` revision in
the inventory and design batch.

## 5. Inventory approval gate

Before creating or mutating Figma/HTML, return an inventory version `INV-YYYYMMDD-VNN` using the actual inventory date and the next unused revision for that date. Use stable feature IDs such as `F-01`; keep an ID stable while its user-visible outcome is stable.

Each inventory row includes feature name, status, terminal/user, expected pages, material states, entry/action/transition expectations, and a one-sentence change. Use only:

- `Existing — reuse`: verified capability remains or is composed into the journey;
- `Existing — modify`: verified capability changes in behavior, scope, copy, state, or presentation;
- `New`: targeted entry/routes, callers, and owning contract/dictionary/permission surfaces were inspected and no scoped user-visible outcome exists;
- `Conflict`: the item contradicts evidence, an approved decision, terminal authority, platform limits, or another scoped item;
- `Unverified`: current evidence cannot establish the state.

Always include a visible conflict/decision section, even when it says no material conflict was found. Ask the user to approve the named inventory version. Approval covers only that version and its rows; separately listed unresolved blocking decisions remain unresolved. Any scope, row, conflict resolution, or blocking-decision change creates a new inventory revision. Do not mutate a visual artifact until the current inventory is approved and all blocking decisions are resolved.

### Action-group contract gate

Only after the current inventory is approved, create `AGC-YYYYMMDD-VNN` from actual project/Figma component evidence.
Use the [action-group contract template](templates/action-group-contract-template.md). This is a reusable interaction
record, not page-specific CSS: classify every approved interactive region as `single-action`, `action-group`,
`symmetric-navigation`, or `segmented-selection`, then map its semantic actions, components, tokens, width/slot policy,
states, and verification evidence.

The blocking action-group gate is:

1. **Classification and scope (`AGC-01`)** — map every interactive region to approved feature/page/state IDs and keep
   unrelated actions out of the same group.
2. **Component reuse (`AGC-02`)** — reuse an approved component/variant or record a minimal extension; page-local
   button clones, vectors, and CSS workarounds are not a component contract.
3. **Target and density (`AGC-03`)** — map target size, visual Icon/text size, padding, gap, and any full-span
   exception to tokens and terminal evidence. A broad outlined surface must not misrepresent several small actions as
   one button.
4. **Distribution and centering (`AGC-04`)** — encode `content`, `equal`, or `full-span` width and `natural`,
   `equal-slot`, or `equal-partition` distribution in Auto Layout/Flex/Grid. `symmetric-navigation` requires same-size
   edge targets and a middle child centered to the parent; `space-between` or hand-written coordinates do not prove it.
5. **State and accessibility (`AGC-05`)** — record default, hover, pressed, focus-visible, selected, disabled, and
   loading states when applicable, plus contrast, keyboard behavior, and accessible names for icon-only actions.
6. **Implementation and evidence (`AGC-06`)** — map Figma component/token to target component/CSS, then define the
   Figma/DOM geometry, viewport/state, screenshot, and human-review checks required for acceptance.

Missing classification, an unapproved full-span control, unequal symmetric-navigation edge slots, missing target-size
evidence, or a page-local compensating rule blocks page-specific styling, implementation handoff, and acceptance.

### Visual asset and Icon gate

Only after the current inventory is approved, build `ICON-YYYYMMDD-VNN` from actual project/Figma evidence. Use the
[Icon and visual asset inventory template](templates/icon-asset-inventory-template.md). It is a reusable asset record,
not a page annotation: every Icon used by the inventory's approved pages/states must be extracted into its own semantic
ID and mapped to a reusable component or approved source.

The blocking Icon asset gate is:

1. **Source and ownership (`IA-01`)** — inspect project/Figma Icon libraries, source paths/nodes, license/permission,
   and freshness; never infer ownership from a screenshot.
2. **Semantic extraction (`IA-02`)** — map every page Icon to a semantic `ICON-*` ID; page-local vectors, emoji,
   text glyphs, screenshots, and unapproved third-party sets are not reusable Icon assets.
3. **Size and family (`IA-03`)** — define only the required 16/20/24/32 variants by terminal role. Keep a vector
   master, grid/pixel alignment, outline/filled rule, stroke/cap/join/corner rule, and optical-boundary rule. Use
   `48px+` for illustration/empty-state artwork rather than normal UI Icons. When direct scaling changes optical
   balance, create a separately corrected variant instead of stretching one source.
4. **State and token mapping (`IA-04`)** — record default, selected/active, disabled, destructive, inverse, and
   loading variants only when applicable, with color tokens and dark/inverse behavior; do not hard-code colors.
5. **Missing-Icon design (`IA-05`)** — design every missing Icon as an independent reusable component before page
   use. Compare it with the approved family at every required size and record reviewer decision and component/node.
6. **Implementation mapping (`IA-06`)** — map each Figma and target-product instance to the same Icon ID, component,
   size, state, and exact asset/export; a visually similar substitute does not pass.
7. **Rendered fidelity (`IA-07`)** — inspect required sizes/states in the declared shell for pixel alignment, optical
   balance, contrast, touch-target separation, clipping, and fallback behavior.

Also record coupled asset readiness for fonts (license/weights/fallback/loading), logo/brand marks (approved variants
and no-redraw rule), image/illustration (source/rights/crop/density), and material motion (trigger/reduced-motion or
static fallback). These are `N/A` only when they are not used by the approved scope.

Missing source, unapproved family, unverified visual asset, or unmapped page Icon blocks page-specific styling,
implementation handoff, and acceptance. For genuinely new or `figma-only` work, record the absent project library as
`Unverified`; new Icons remain reviewable candidates until the Icon inventory is approved.

### External design capability gate

WTBP orchestrates project-specific evidence and gates; it does not duplicate an external design tool's implementation.
Use the current client's official Figma capabilities as the default source: `figma-use` for Figma reads/writes,
`figma-generate-library` only when an approved foundation is missing, `figma-code-connect` for durable code/component
mappings, and Figma design-context/implementation capabilities for scoped inspection and handoff. Record which
capability was available and used; an unavailable capability is `Unverified`, not a license to fabricate its result.

The external capability gate is:

1. **Official capability and authority (`EX-01`)** — prove that the current client exposes the required official Figma
   capability and that the user authorized its declared Figma read/write scope before use.
2. **Component/code source of truth (`EX-02`)** — prefer a verified Code Connect or project component mapping over a
   generated approximation. Record missing mappings as a PDC/AGC/ICON decision rather than creating a page-local clone.
3. **Optional audit boundary (`EX-03`)** — a third-party design-lint, token, or accessibility audit may run only after
   explicit user authorization, source/version review, and confirmation of its Figma credential and command-execution
   requirements. Its output supplements, but never replaces, AGC, BF, G, or real-fixture acceptance evidence.
4. **No implicit installation or credentials (`EX-04`)** — never install a third-party Skill/plugin, request a personal
   access token, read an environment secret, or transmit Figma nodes merely because an audit could be useful. Report
   the missing dependency and the next authorization instead.

Only the official default capabilities are part of the normal Figma workflow. Third-party sources remain optional and
reference-only until a consuming project explicitly approves installation and permissions; see the human-facing
external capability register for source and adoption details.

## 6. Artifact organization and review unit

After approval, assign a design batch `YYYY-MM-DD-VNN` using the actual creation/revision date and the next unused revision. Organize:

`dated batch → business module → platform subsection → independent page/state frame`

Every scoped feature appears in its complete containing page. A page includes the declared terminal shell at its approved dimensions, task context, content, actions, and relevant list/form/state structure. An overlay is shown over the complete underlying page. Never deliver an isolated control, cropped component, shared-edge mega-frame, or connector-line flow.

For each product frame, create one standalone review annotation block as a sibling on the right. Default review geometry is a `48px` gap, top alignment within `4px`, `400px` annotation width, `24px` padding, and content-driven height. The block may be shorter or taller than the page; never clip, hide overflow, force equal height, or allow wrapped text to cross its bounds. The product frame contains only user-facing product UI; design explanations, project descriptions, technical notes, acceptance rules, and review commentary belong in this sibling block and must not be placed inside the product frame.

The annotation follows this order and omits genuinely inapplicable sections: `Identity`, `User and outcome`, `Entry and scope`, `Fields and filters`, `Rules and provenance`, `Actions and states`, `Exceptions`, `Copy for review`, `Decision/rationale`, and `Acceptance record`.

### Base-frame-first construction checkpoint

Before adding page-specific components, content styling, state decoration, or visual polish, construct the **base frame batch** for every approved page/state in the inventory. Each base frame must contain only the shared structural skeleton: the declared terminal shell, page root, navigation/status surfaces, safe-area behavior, content regions, Auto Layout/normal-flow parents, named overlay parents where needed, state slots, and the right-side annotation sibling. Use neutral placeholders; do not hide unresolved geometry behind decorative styles or final copy.

Run the following blocking checkpoint across the complete base-frame batch:

1. **Page coverage (`BF-01`)** — every approved page/state ID has exactly one base frame, and no unapproved frame is introduced.
2. **Shell contract (`BF-02`)** — every base frame uses the declared terminal shell, viewport/device dimensions, safe areas, and navigation/status surfaces.
3. **Root geometry (`BF-03`)** — page roots, content regions, and primary gaps have explicit dimensions/constraints and a recorded layout owner; no unexplained coordinates or overflow exist.
4. **Flow hierarchy (`BF-04`)** — ordinary regions use Auto Layout/normal flow, and every intentional overlay has a named containing parent, anchor, and reason.
5. **State skeleton (`BF-05`)** — all material states and transition slots in the approved matrix are represented without inventing behavior or polishing only one page.
6. **Review separation (`BF-06`)** — every base frame already has its standalone right-side annotation sibling, and the product frame contains no design/project/technical/acceptance commentary.

Record the base-frame IDs, shell dimensions, layout-owner evidence, neutral screenshots, and all `BF-01`–`BF-06` results. A failed, partial, or unverified checkpoint blocks upper-layer styling. Once it passes, layer approved shared components, approved action-group entries, approved Icon inventory entries, verified/proposed product copy, state visuals, and page-specific styling in separate write batches; rerun the applicable base and shared gates after structural changes.

After every visual write batch, run the post-write structural gate across **all** product page/state frames in the target artifact, not only the frames that were edited. Do not perform another write or report completion until the gate passes or an approved exception is recorded:

1. **Layout owner and distribution (`G-01`)** — inspect and record each page/frame's Figma `layoutMode` (or the equivalent DOM layout owner). Ordinary content must remain in Auto Layout/normal flow. `NONE` is allowed only when the frame is an intentional overlay, canvas, or fixed-control container and the reason is recorded; ordinary children must not be converted to absolute positioning for alignment. Re-run the applicable `AGC-01`–`AGC-06` geometry: equal-weight navigation, TabBar, tabs, or segmented controls record distribution, item weights/basis, partition centers, and tolerance; `symmetric-navigation` records equal edge target dimensions and the middle-to-parent-center tolerance. Hand-placed coordinates, `space-between` used as centering proof, or a visibly non-equal partition fail this gate unless an approved product rule explains it.
2. **Annotation pairing (`G-02`)** — enumerate every product page/state frame and prove a one-to-one mapping to a standalone annotation sibling. The annotation must be outside the product UI, on the right, top-aligned, and use the default `48px` gap unless an approved exception states the alternative.
3. **Recursive text and component containment (`G-03`)** — traverse every descendant text node, component instance, asset, and nested container under each product page/state, including descendants inside shared instances. Compare each node with its direct parent and trace material overflow through the ancestor chain after fonts/assets load. Record node, parent, ancestor, and geometry; no child may cross a required parent/ancestor boundary or be hidden by clipping/overflow to conceal a failure. A page-level bounding-box check alone never passes this gate.
4. **Instance/master scale (`G-04`)** — for every shared component instance, inspect its master/component geometry and record `instance width / master width` and `instance height / master height`. Ratios must remain `1.0` unless a documented responsive, variant, or constraint rule and its approval explain the deviation; unexplained distortion blocks acceptance.
5. **Terminal shell and fidelity (`G-05`)** — record the declared target, shell type, dimensions, device/browser chrome, safe areas, and navigation surfaces. The full shell and product page must be visible in the capture; miniapp frames must show the applicable mini-program shell, and any deviation from the target contract blocks acceptance.
6. **Product-content isolation (`G-06`)** — inspect every visible text node in the product frame. Only verified or explicitly marked proposed product copy may remain; design/project descriptions and technical or acceptance commentary must be absent from the product frame and present, when needed, in the right-side annotation sibling.

The gate record must include the artifact revision, inspected page/frame IDs, target shell contract, base-frame IDs and `BF-01`–`BF-06` results, `AGC-01`–`AGC-06` results, `G-01`–`G-06` results, geometry sources, screenshots, exceptions, and the rerun result. A node-write success, static check, or single screenshot cannot satisfy this gate.

## 7. Text and state rules

Classify every text node inside the product frame as:

- verified product copy with a traceable requirement/UI/contract/decision source;
- proposed product copy, kept only when needed for an approved function and marked `Copy for review / 待确认文案` in the annotation;
- design commentary, moved outside the product frame;
- unsupported copy, removed.

Descriptions of the page, project, implementation, or acceptance are never product copy. Keep them only in the standalone right-side annotation block; a product frame containing such commentary fails `G-06`.

Create separate frames for states that materially change available actions, permission/data scope, primary content structure, completion outcome, or recovery path, including applicable empty, populated, loading, disabled, success, validation failure, error, and no-permission states. Do not manufacture irrelevant states.

## 8. Acceptance evidence

Acceptance requires structural, rendered, and provenance evidence for the actual artifact:

1. enumerate all product page/state frames and inspect Figma node geometry or HTML DOM bounding boxes;
2. confirm the `BF-01`–`BF-06` base-frame checkpoint passed before evaluating upper-layer styling;
3. run and record `G-01` for every page/frame's `layoutMode` or equivalent layout owner;
4. run and record `G-02` for one-to-one annotation pairing, right-side placement, top alignment, and the default `48px` gap;
5. run and record `G-03` by recursively traversing every descendant text/component/container and checking direct-parent and ancestor containment after fonts/assets load; a page-only overflow check is insufficient;
6. run and record `G-04` for every shared component instance/master width and height ratio, including approved deviations;
7. run and record `G-05` for the target shell, exact dimensions, device/browser chrome, safe areas, and full-frame capture;
8. run and record `G-06` for product-content isolation and the absence of descriptive/technical/review text in the product frame;
9. run and record `AGC-01`–`AGC-06` for every approved interactive group, including target geometry and declared slot/partition behavior;
10. run and record `IA-01`–`IA-07` for every Icon and coupled visual asset used by the approved scope;
11. confirm complete page context and the correct platform shell;
12. verify fields, filters, enumerations, permissions, actions, state transitions, recovery paths, sorting/pagination, exceptions, and provenance; mark unknowns `Unverified`;
13. record every in-page text classification and matching proposed-copy review entry;
14. capture rendered screenshots at stated scales and inspect overlap, clipping, collisions, hierarchy, states, and primary actions;
15. check accessibility evidence where applicable: normal text contrast at least `4.5:1`, large text and essential non-text UI at least `3:1`, status not conveyed by color alone, and visible focus/keyboard order for HTML;
16. verify prototype links or runtime action transitions against the approved page/state/transition matrix;
17. rerun the complete audit after every visual fix.

A prompt response, generated code, node-creation success, static check, one plausible screenshot, or Skill-Up dry-run is not artifact acceptance evidence. For a solved implementation/visual case, retain the Figma/preview link, target, viewport/device, state, deterministic data/capture conditions, baseline screenshot, expected reference, post-fix screenshot, first divergent layout owner, changed files/nodes, rerun result, and human-review result.

## 9. Handoff and completion

Re-open the inventory gate when feedback changes scope, behavior, terminal, permission/data scope, conflict resolution, or a blocking business decision. Pure visual refinement within the approved scope may use a new design batch revision without a new inventory.

Final reports state the artifact location, batch, modules, independent frames, inventory version and feature IDs, terminals, targets, annotations, states, evidence sources, conflict result, approval, unverified items, and next Skill. Never call an artifact complete when a required integration, baseline, approval, or acceptance evidence is unavailable.
