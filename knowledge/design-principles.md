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

## Layered design framework

| Layer | Question | Required output | Blocking gate |
|---|---|---|---|
| L0 Evidence and intent | What problem, for whom, on which target, and why? | Cognition record, source authority, outcome, actor, target, product, entry, scope, exclusions, project design contract | Missing or conflicting material facts are `Unverified`/blocking |
| L1 Information architecture | How does the user move through the product? | Project-contract-backed modules, routes/entries, primary journey, page/state/transition matrix, recovery paths | `PDC-01`–`PDC-06` pass before architecture; no page or action is designed without its containing journey, state coverage, and transition outcome |
| L2 Product contract | What is in scope and how will it be judged? | Versioned inventory, stable feature IDs, status, rules, permissions, acceptance conditions, decisions | Explicit user approval and no unresolved blocking decision |
| L3 Foundations | Which reusable rules and building blocks express the contract? | Tokens, typography, assets, components, variants, layout conventions, source mappings | Reuse/extension decision and consumer impact recorded |
| L4 Page composition | How is each approved feature represented? | All approved page/state base frames first, then layered page composition, target shell, Auto Layout hierarchy, right-side annotation, classified copy | `BF-01`–`BF-06` pass before styling; then `G-01`–`G-06` pass for all product pages/states |
| L5 Implementation mapping | How does the artifact become one declared target? | Figma node → component/style/data/state mapping, target constraints, changed files | No coordinate-only translation or unscoped target work |
| L6 Verification | Does the target preserve the contract across conditions? | Target × viewport/device × state/transition matrix, baseline/expected/post-fix captures, geometry and runtime evidence | Structural, rendered, interaction, accessibility, and human review pass |
| L7 Handoff and evolution | Can another person reproduce, change, or roll back it? | Artifact/version links, provenance, exceptions, impact list, rerun result, next Skill | Baseline and acceptance record are complete |

## Ordering and change propagation

- Work proceeds from L0 to L7. A later layer may not silently decide an earlier-layer question.
- Before information architecture, inspect the consuming project and produce the project design contract. Run
  `PDC-01`–`PDC-06`; do not design a new route, page family, component system, or visual foundation while the contract
  is missing, stale, or materially conflicting.
- Within visual composition, use this fixed order: (1) define the shared shell and layout foundations, (2) construct
  every approved page/state base frame in one scaffold pass, (3) run `BF-01`–`BF-06`, (4) layer reusable components,
  product content, states, and visual styling, and (5) rerun `G-01`–`G-06` after each write batch and at handoff.
- A failed or incomplete base-frame gate blocks all upper-layer styling. Do not polish one page while another page's
  root layout, shell, regions, or state skeleton is still unresolved.
- A change to outcome, actor/target, journey, scope, permission/data scope, state, component contract, token, or
  authoritative copy re-opens the earliest affected layer and all downstream gates.
- A pure visual refinement may stay within L4 only when it changes no approved behavior, scope, state, target,
  permission/data scope, or component/token contract; it still requires the post-write structural and rendered audit.
- Shared component, token, asset, or typography changes always include a consumer-impact list and rerun the affected
  page/state matrix.
- The current approved inventory and design baseline are immutable references. New work uses a new inventory revision
  or design batch; it never overwrites evidence to make a mismatch disappear.

## Minimum handoff contract

Every handoff must identify the project design contract revision and `PDC-01`–`PDC-06` results, the derived architecture revision (`ARC-YYYYMMDD-VNN`), the approved inventory and design batch, feature IDs, target and platform, page/state
coverage, target shell and dimensions, foundation mappings, Figma node IDs, changed files/nodes, `BF-01`–`BF-06` and `G-01`–`G-06` results, target matrix, evidence
links, approved exceptions, unresolved `Unverified` items, and the next Skill. If any required evidence is unavailable,
report the artifact as incomplete or blocked rather than complete.
