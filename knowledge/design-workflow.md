# Shared Design Workflow and Acceptance Contract

This is the shared process for WTBP design Skills. Read it before creating, evolving, implementing, or accepting a visual artifact. The workflow is fail-closed: a prompt, `start`, or an explicit request to skip questions never replaces a missing brief, unresolved material conflict, inventory approval, or artifact evidence.

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

Use the canonical terminal labels `Admin`, `Business`, `Parent`, and `Supplier`. Determine ownership from routes, authentication, permissions, callers, and product copy; do not infer a terminal from a repository name or from the fact that a screen is mobile.

For overlapping designs, also require source design timestamps and the user-selected authoritative baseline. If either is missing, record `Unverified` and stop composition until the collision can be resolved.

## 3. Requirement and evidence gates

When a requirement document, file, link, or complete requirement content is supplied, create a compact cognition record before design:

- source, title, version/date, and authority;
- outcome, actors, terminal, product, entry, and journey;
- in-scope and excluded capabilities;
- business rules, permissions, states, exceptions, acceptance conditions, and open questions.

Run a conflict pass across the document, current evidence, and approved history. A conflict affecting outcome, actor/terminal, journey, scope, permission/data scope, authoritative rule, destructive consequence, page structure, or available states is material. State both sides, offer 2–3 distinct resolutions with trade-offs, recommend only when evidence supports it, and stop until the user selects a resolution.

Use this evidence precedence without hiding real conflicts: approved user decision, authoritative supplied requirement, current owning API/dictionary/permission contract, verified current UI, then implementation inference. Record a compact locator for every material rule or value: source type and section, repository/branch/commit and file/symbol, API/dictionary key, or approved decision/date. If evidence is inaccessible or stale, use `Unverified / 待确认`, never `Existing` or `New` by guesswork.

## 4. Inventory approval gate

Before creating or mutating Figma/HTML, return an inventory version `INV-YYYYMMDD-VNN` using the actual inventory date and the next unused revision for that date. Use stable feature IDs such as `F-01`; keep an ID stable while its user-visible outcome is stable.

Each inventory row includes feature name, status, terminal/user, expected pages and material states, and a one-sentence change. Use only:

- `Existing — reuse`: verified capability remains or is composed into the journey;
- `Existing — modify`: verified capability changes in behavior, scope, copy, state, or presentation;
- `New`: targeted entry/routes, callers, and owning contract/dictionary/permission surfaces were inspected and no scoped user-visible outcome exists;
- `Conflict`: the item contradicts evidence, an approved decision, terminal authority, platform limits, or another scoped item;
- `Unverified`: current evidence cannot establish the state.

Always include a visible conflict/decision section, even when it says no material conflict was found. Ask the user to approve the named inventory version. Approval covers only that version and its rows; separately listed unresolved blocking decisions remain unresolved. Any scope, row, conflict resolution, or blocking-decision change creates a new inventory revision. Do not mutate a visual artifact until the current inventory is approved and all blocking decisions are resolved.

## 5. Artifact organization and review unit

After approval, assign a design batch `YYYY-MM-DD-VNN` using the actual creation/revision date and the next unused revision. Organize:

`dated batch → business module → platform subsection → independent page/state frame`

Every scoped feature appears in its complete containing page. A page includes the applicable platform shell, task context, content, actions, and relevant list/form/state structure. An overlay is shown over the complete underlying page. Never deliver an isolated control, cropped component, shared-edge mega-frame, or connector-line flow.

For each product frame, create one standalone review annotation block as a sibling on the right. Default review geometry is a `48px` gap, top alignment within `4px`, `400px` annotation width, `24px` padding, and content-driven height. The block may be shorter or taller than the page; never clip, hide overflow, force equal height, or allow wrapped text to cross its bounds.

The annotation follows this order and omits genuinely inapplicable sections: `Identity`, `User and outcome`, `Entry and scope`, `Fields and filters`, `Rules and provenance`, `Actions and states`, `Exceptions`, `Copy for review`, `Decision/rationale`, and `Acceptance record`.

## 6. Text and state rules

Classify every text node inside the product frame as:

- verified product copy with a traceable requirement/UI/contract/decision source;
- proposed product copy, kept only when needed for an approved function and marked `Copy for review / 待确认文案` in the annotation;
- design commentary, moved outside the product frame;
- unsupported copy, removed.

Create separate frames for states that materially change available actions, permission/data scope, primary content structure, completion outcome, or recovery path, including applicable empty, populated, loading, disabled, success, validation failure, error, and no-permission states. Do not manufacture irrelevant states.

## 7. Acceptance evidence

Acceptance requires structural, rendered, and provenance evidence for the actual artifact:

1. inspect Figma node geometry or HTML DOM bounding boxes and record product-frame and annotation IDs;
2. confirm complete page context and the correct platform shell;
3. confirm the annotation is a distinct right-side sibling with the required gap, alignment, and unclipped wrapped text;
4. verify fields, filters, enumerations, permissions, actions, states, sorting/pagination, exceptions, and provenance; mark unknowns `Unverified`;
5. record every in-page text classification and matching proposed-copy review entry;
6. capture a rendered screenshot at a stated scale and inspect overlap, clipping, collisions, hierarchy, states, and primary actions;
7. check accessibility evidence where applicable: normal text contrast at least `4.5:1`, large text and essential non-text UI at least `3:1`, status not conveyed by color alone, and visible focus/keyboard order for HTML;
8. rerun the audit after every visual fix.

A prompt response, generated code, node-creation success, static check, one plausible screenshot, or Skill-Up dry-run is not artifact acceptance evidence. For a solved implementation/visual case, retain the Figma/preview link, target, viewport/device, state, deterministic data/capture conditions, baseline screenshot, expected reference, post-fix screenshot, first divergent layout owner, changed files/nodes, rerun result, and human-review result.

## 8. Handoff and completion

Re-open the inventory gate when feedback changes scope, behavior, terminal, permission/data scope, conflict resolution, or a blocking business decision. Pure visual refinement within the approved scope may use a new design batch revision without a new inventory.

Final reports state the artifact location, batch, modules, independent frames, inventory version and feature IDs, terminals, targets, annotations, states, evidence sources, conflict result, approval, unverified items, and next Skill. Never call an artifact complete when a required integration, baseline, approval, or acceptance evidence is unavailable.
