# WTBP Skill Framework

This is the governing framework for every Skill stored or routed by WTBP. A Skill is a bounded,
repeatable capability with registered inputs, side effects, outputs, evidence, and lifecycle status. It is
not a prompt fragment and it is not complete merely because a model produced plausible text.

## Five-layer architecture

The layers are ordered. A later layer may not silently invent a missing decision from an earlier layer.

1. **Intent and scope** — capture the goal, scenario, constraints, non-goals, required evidence, and the
   decision or artifact that will be accepted.
2. **Capability and routing** — use `knowledge/skill-index.yaml` as the source for local Skill cards,
   `knowledge/external-capabilities.yaml` as the source for external capability cards, and
   `knowledge/skill-routes.yaml` only for task matching and separately managed installation routes. The current
   session makes the semantic `select`, `clarify`, or `no_match` decision plus an adoption decision; keyword
   matching never executes, installs, or creates a Skill.
3. **Bounded execution** — load the smallest selected Skill, verify its input contract, follow its workflow,
   and request only the side effects declared in the capability card. Stop when a required input, permission,
   or external dependency is missing.
4. **Evidence and verification** — produce the declared output contract, attach deterministic evidence where
   possible, separate model judgment from human judgment, and run the Skill's completion gates. A dry-run,
   screenshot, or generated report is evidence of that check only; it is not proof of an unperformed runtime,
   visual, or external-model acceptance.
5. **Governance and lifecycle** — keep the Skill, Chinese companion, catalog, index, route, Eval, and
   `validated_by` relationship synchronized. Use `candidate` until the required evidence and gates support a
   stronger status; record version, verification date, deprecation reason, and replacement when applicable.

## Minimum Skill contract

Every `skills/<skill-id>/SKILL.md` must contain these contract sections. Execution-specific evidence gates may sit
between workflow phases, but they must not replace the contract or make its completion condition implicit:

1. `Input Contract` — required inputs, assumptions, optional inputs, and the one clarification that blocks
   safe progress.
2. `Workflow` — ordered steps from intake to handoff; each step names its evidence or decision boundary.
3. `Boundaries` or an equivalent explicit section — non-goals, side-effect limits, and fail-closed conditions.
4. `Output Contract` — stable fields, artifact locations or IDs, unresolved items, and language rules.
5. `Completion Gate` — deterministic checks, required human or external checks, and the exact stop condition.

The frontmatter `name` must equal the directory name. The English file is the AI source of truth and must have
the sibling `<name>.zh-CN.md` companion with the same rules. References are loaded progressively, not as a
bulk context dump.

## Registry and evidence graph

The minimum graph for a local Skill is:

```text
SKILL.md
  ├─ capability card  -> knowledge/skill-index.yaml
  ├─ route             -> knowledge/skill-routes.yaml
  ├─ catalog object    -> knowledge/catalog.yaml
  ├─ evaluation        -> knowledge/evals/<skill-id>/EVAL.md + cases.yaml
  └─ validation link   -> knowledge/relationships.yaml (validated_by)
```

All edges must point to the same `skill-id`. A missing edge, stale verification date, or contradictory status
is a registry failure, not a reason to guess. The catalog describes discoverable objects; it does not override
the capability index, route, or Skill contract.

The minimum graph for an external capability is:

```text
external capability card -> knowledge/external-capabilities.yaml
  └─ traceable source    -> knowledge/external-sources.yaml
      └─ adoption, availability, permissions, and verification boundary
```

An external capability is not a local Skill and therefore does not inherit a local catalog object, route, Eval,
or installation authority. A local adapter or managed-install route that uses it must still satisfy its own local
registry graph and gates.

## Gate model

| Gate | Question | Fail-closed action |
|---|---|---|
| G0 Registry | Are path, ID, catalog, route, companion, Eval, and relationship consistent? | Do not route or commit the Skill. |
| G1 Intake | Are goal, scope, constraints, inputs, and acceptance evidence complete? | Ask for the smallest missing clarification. |
| G2 Boundary | Are non-goals, side effects, permissions, external dependencies, and install authority explicit? | Do not execute, install, or expand scope. |
| G3 Execution | Did the ordered workflow run and preserve its intermediate evidence? | Report the first failed step; do not claim completion. |
| G4 Output | Does the result satisfy the declared output contract and identify unresolved items? | Mark incomplete and return for correction. |
| G5 Evaluation | Does the registered Eval cover positive, negative, boundary, and required adversarial cases and meet its threshold? | Keep status `candidate` or `improve`; never approve by intuition. |
| G6 Lifecycle | Is the version, status, verification date, deprecation/replacement, and change level coherent? | Block delivery until metadata and version are corrected. |

## Lifecycle and progressive disclosure

`discover -> analyze -> design/evolve/implement -> verify -> evaluate -> maintain` is the default lifecycle.
Discovery loads local and external cards, then routes; execution loads one Skill; references and Evals are loaded
only when the selected step needs them. Before proposing a new Skill, assess existing official capabilities,
external Skills, and reference implementations. Choose direct use, local adaptation, composition, or reference-only
when they meet the scenario with declared boundaries. New Skills require a repeated stable task, a distinct
project-specific boundary, recorded reuse/search evidence, and the minimum Eval matrix.

`active` is selectable, `candidate` is selectable only after the current session confirms scope, `stale` is not
a default recommendation, and `deprecated` is not selectable except for migration or audit. External capability
cards never authorize installation. A separately managed external Skill must remain pinned, allowlisted,
permission-declared, and explicitly authorized before installation.

## Review checklist

Before declaring a Skill change complete, verify:

- the five layers and all six gates have an owner and evidence;
- the English Skill, Chinese companion, index, route, catalog, Eval, and relationship agree; external capability
  cards instead agree with their source, adoption, availability, permissions, and verification boundary;
- no step relies on a keyword match as semantic execution or on a dry-run as runtime proof;
- side effects and installation authority are narrower than or equal to the registered capability card;
- the next handoff, unresolved risk, and verification command are explicit.
