# Design Principles and Layered Framework

This is the upstream contract for every WTBP Figma and visual-design Skill. A design artifact must be derived through
the layers below; a prompt, screenshot, generated page, or local visual preference cannot skip a layer.

## Non-negotiable principles

1. **Evidence before invention** — requirements, current product evidence, contracts, and approved decisions outrank
   model preference. Unknowns remain `Unverified`.
2. **Outcome before surface** — establish the user outcome, actor, product, target, entry, journey, scope, and
   exclusions before choosing a page, component, or visual treatment.
3. **Architecture before decoration** — define information architecture, modules, routes, page/state coverage, and
   acceptance conditions before styling individual screens.
4. **Foundations before composition** — tokens, typography, assets, components, variants, and layout conventions are
   selected or extended before page-specific styling.
5. **Constraints before coordinates** — use Auto Layout, normal flow, responsive constraints, and named overlay
   parents. Coordinates and absolute positioning are exceptions that require evidence and a recorded reason.
6. **One contract across surfaces** — the approved inventory, Figma nodes, component mappings, implementation target,
   and acceptance matrix share stable feature IDs, states, targets, and provenance.
7. **Small, versioned, reversible change** — patch only the approved scope; regenerate into a new version when
   hierarchy or behavior changes; preserve the previous baseline and record shared-component impact.
8. **Evidence closes the loop** — completion requires structural, rendered, runtime, provenance, and human-review
   evidence. Instructions, node creation, static checks, or a single screenshot are never sufficient.
9. **Terminal fidelity and content isolation** — render the declared product inside its real target shell at the
   approved dimensions, and keep design/project descriptions in the sibling review annotation rather than in the
   product UI. High fidelity means the shell, safe areas, navigation chrome, content geometry, and states agree.
10. **Base frame before surface styling** — construct every approved page/state as the same validated structural
   skeleton before adding page-specific visual treatment. The base-frame batch must pass its blocking gate before
   components, content styling, state decoration, or polish are layered on top.
11. **Recursive geometry and contract-bound distribution** — validate every descendant component against its direct
   parent and ancestor chain, not only the page root. Navigation bars, tabs, and other equal-weight regions must use
   an explicit distribution rule and measurable partition/center evidence rather than hand-placed coordinates.
12. **Project contract before architecture** — inspect the actual consuming project before choosing an information
   architecture or visual direction. Record what already exists, what can be reused, what must be extended, and what
   is unknown; a PRD or screenshot alone cannot define the project's design contract.
13. **Asset system before instances** — extract every Icon used by the approved scope into a versioned semantic
    inventory before page styling. Reuse approved project assets first; missing Icons are independently designed as
    family-consistent components, never improvised inside a page.
14. **Boundary ownership before visual proof** — distinguish canvas, editor selection, terminal shell, product root,
    Section, and annotation ownership. Structural shell geometry (`BF-02S`/`G-05S`) and unselected four-edge visual
    evidence (`BF-02V`/`G-05V`) are separate required gates; a structural pass alone is never completion.

## Layered design framework

| Layer | Question | Required output | Blocking gate |
|---|---|---|---|
| L0 Evidence and intent | What problem, for whom, on which target, and why? | Cognition record, source authority, outcome, actor, target, product, entry, scope, exclusions, project design contract | Missing or conflicting material facts are `Unverified`/blocking |
| L1 Information architecture | How does the user move through the product? | Project-contract-backed modules, routes/entries, primary journey, page/state/transition matrix, recovery paths | `PDC-01`–`PDC-06` pass before architecture; no page or action is designed without its containing journey, state coverage, and transition outcome |
| L2 Product contract | What is in scope and how will it be judged? | Versioned inventory, stable feature IDs, status, rules, permissions, acceptance conditions, decisions | Explicit user approval and no unresolved blocking decision |
| L3 Foundations | Which reusable rules and building blocks express the contract? | Tokens, typography, versioned Icon asset inventory, coupled-asset readiness, components, variants, action-group contracts, layout conventions, source mappings | `IA-01`–`IA-07` and `AGC-01`–`AGC-06` pass before page-specific styling; reuse/extension decision and consumer impact recorded |
| L4 Page composition | How is each approved feature represented? | All approved page/state base frames first, then layered page composition, target shell/root ownership, Auto Layout hierarchy, right-side annotation, classified copy | `BF-01`–`BF-06` including `BF-02S`/`BF-02V` pass before styling; then `G-01`–`G-06` including `G-05S`/`G-05V` pass for all product pages/states |
| L5 Implementation mapping | How does the artifact become one declared target? | Figma node → component/style/data/state mapping, target constraints, changed files | No coordinate-only translation or unscoped target work |
| L6 Verification | Does the target preserve the contract across conditions? | Target × viewport/device × state/transition matrix, baseline/expected/post-fix captures, geometry and runtime evidence | Structural, rendered, interaction, accessibility, and human review pass |
| L7 Handoff and evolution | Can another person reproduce, change, or roll back it? | Artifact/version links, provenance, exceptions, impact list, rerun result, next Skill | Baseline and acceptance record are complete |

## Ordering and change propagation

- Work proceeds from L0 to L7. A later layer may not silently decide an earlier-layer question.
- Before information architecture, inspect the consuming project and produce the project design contract. Run
  `PDC-01`–`PDC-06`; do not design a new route, page family, component system, or visual foundation while the contract
  is missing, stale, or materially conflicting.
- After architecture, create and obtain approval for `INV-YYYYMMDD-VNN`; only then build
  `AGC-YYYYMMDD-VNN`, then `ICON-YYYYMMDD-VNN`, and pass `AGC-01`–`AGC-06` and `IA-01`–`IA-07`. The approved
  inventory is the sole page/state scope for action-group and Icon contracts. Do not create page-local Icon
  substitutes, text glyphs, emoji, unapproved external assets, or ad hoc page CSS for a registered action group.
- Within visual composition, use this fixed order: (1) define the shared shell and layout foundations, (2) approve the
  versioned scope inventory, (3) approve action-group contracts, (4) build the approved Icon asset inventory and
  coupled-asset mappings, (5) construct every approved page/state base frame in one scaffold pass, (6) run
  `BF-01`–`BF-06`, (7) layer reusable components, product content, states, and visual styling, and (8) rerun
  `G-01`–`G-06` after each write batch and at handoff.
- A failed or incomplete base-frame gate blocks all upper-layer styling. Do not polish one page while another page's
  root layout, shell, regions, or state skeleton is still unresolved.
- A change to outcome, actor/target, journey, scope, permission/data scope, state, component contract, token, or
  authoritative copy re-opens the earliest affected layer and all downstream gates.
- A pure visual refinement may stay within L4 only when it changes no approved behavior, scope, state, target,
  permission/data scope, or component/token contract; it still requires the post-write structural and rendered audit.
- Shared component, token, Icon asset, coupled asset, or typography changes always include a consumer-impact list and rerun the affected
  page/state matrix.
- The current approved inventory and design baseline are immutable references. New work uses a new inventory revision
  or design batch; it never overwrites evidence to make a mismatch disappear.

## Minimum handoff contract

Every handoff must identify the project design contract revision and `PDC-01`–`PDC-06` results, the derived architecture revision (`ARC-YYYYMMDD-VNN`), the action-group contract revision and `AGC-01`–`AGC-06` results, the Icon inventory revision and `IA-01`–`IA-07` results, the approved inventory and design batch, feature IDs, target and platform, page/state
coverage, target shell and dimensions, shell/root ownership, visual-boundary recipe, unselected fixed capture and four-edge results, foundation mappings, Figma node IDs, changed files/nodes, `BF-01`–`BF-06` and `G-01`–`G-06` results including `BF-02S`/`BF-02V` and `G-05S`/`G-05V`, target matrix, evidence
links, approved exceptions, unresolved `Unverified` items, and the next Skill. If any required evidence is unavailable,
report the artifact as incomplete or blocked rather than complete.
