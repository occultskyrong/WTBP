# External Capability Selection

Load this reference when a request may be solved by an official integration, an external Skill, a reference implementation,
or a new local Skill.

## Rule

Search and evaluate existing trustworthy capability before proposing a local Skill. Do not treat a search result, GitHub URL,
or a keyword match as an executable capability.

Read `knowledge/external-capabilities.yaml` for external capability cards and `knowledge/external-sources.yaml` for their
traceable sources. `knowledge/skill-index.yaml` remains the canonical card registry for local WTBP Skills only.

## Per-task decision

Return one adoption decision in addition to the routing result:

| Decision | Use it when | Required boundary |
|---|---|---|
| `direct-use` | An already available official/client-provided capability covers the task without a project-specific recurring workflow. | Verify availability and permission in the current context. |
| `adapt` | An external capability is useful, but a local WTBP Skill must impose project contracts, gates, or evidence. | Load the local Skill; external capability does not replace its contract. |
| `compose` | Two or more local/external capabilities have distinct stages and no single one owns the full task. | State the order, owner, boundary, and evidence for each stage. |
| `reference-only` | A source is useful for comparison or structure but cannot safely execute the task. | Do not treat it as project fact, install it, or claim its result. |
| `build-local` | No suitable capability covers a repeated stable project-specific workflow. | First record search evidence; require full local Skill contract, registry graph, and Eval. |

`manual-optional` external cards never become `direct-use` merely because their keywords match. They require explicit user
authorization and a separate check of source, fixed version, license, permissions, credentials, and execution environment.
Do not run `wtbp install` for a capability card; that command is reserved for a separately registered managed-install route.

## Decision checks

Before recommending direct use, adaptation, composition, or local build, compare:

1. Scenario fit: goal, inputs, expected output, and non-goals.
2. Authority: publisher, source URL, pin/version, license, maintenance status, and trust boundary.
3. Side effects: files, network, Figma, commands, credentials, and installation scope.
4. Evidence: what the capability can prove, what still needs project/runtime/visual acceptance, and what remains unverified.
5. Reuse threshold: whether a project-specific workflow is repeated and stable enough to deserve a local Skill and Eval.

If any required decision input is unavailable, return `clarify` or `no_match`; never compensate by silently installing,
inventing a route, or creating a new Skill.
