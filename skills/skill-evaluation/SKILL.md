---
name: skill-evaluation
description: Evaluate an Agent Skill's structure, trigger boundaries, behavioral effectiveness, stability, and safety risk, then produce a reviewable conclusion from its registered Eval. Use for Skill review, acceptance, regression, or comparison.
---

# Skill Evaluation

This Skill organizes evaluation. It neither replaces the target Skill's function nor treats a single successful run as proof of quality.
Its local shortcut is `ske`; the shortcut does not change the canonical name `skill-evaluation` or the evaluation directory.

## Workflow

1. Confirm the target Skill, version or commit, related Practice, evaluation scope, and available runner. List missing inputs before proceeding.
2. Locate the target Skill in `knowledge/catalog.yaml` and its `knowledge/evals/<skill-id>/EVAL.md`; load cases and references only as needed.
3. Run `make validate-skill-evals` before evaluation to check structure, registry, fields, case coverage, and safety boundaries.
4. Execute positive, negative, boundary, and adversarial cases from the Eval. When feasible, run with-Skill and without-Skill baselines and repeat at least three times.
5. Separate deterministic assertions, model judgment, and human judgment. For failures, record the case, actual result, expected result, and whether the evaluation itself is defective.
6. Report the conclusion. Do not automatically modify the target Skill, commit, push, create a PR, or merge.

## Output Contract

Respond in the user's language; use Chinese by default for this repository.

```text
Target Skill and version
Evaluation scope and related Practice
Structure and safety checks
Trigger results: positive / negative / boundary / adversarial
Behavioral results: with Skill / without Skill / repeated runs / main failure causes
Boundary between deterministic evidence and model judgment
Conclusion: approved / candidate / improve / stale / deprecated
Residual risks, unverified items, and next step
```

## Decision Rules

- Without the corresponding `EVAL.md` or `cases.yaml`, report only `improve`; do not approve.
- A structural or safety hard-gate failure cannot be offset by a high functional score.
- Missing positive, negative, or boundary coverage makes the evaluation incomplete. Check adversarial scenarios whenever tools, permissions, or side effects are involved.
- Do not treat `stale` or `deprecated` Practices, outdated evidence, or model guesses as default evidence.
- The execution environment must provide the behavioral runner, model credentials, and external services. Never write secrets into prompts, cases, or reports.

## Entry Points

```bash
make validate-skill-evals
make skill-eval SKILL_ID=<skill-id>
```

When a native runner configuration exists, execute that runner by default. `SKILL_EVAL_CONFIG` may select another configuration. Without runner configuration, complete contract validation only and clearly report that behavioral evaluation was not run.
