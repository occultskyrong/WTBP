---
name: example-skill
description: Describe a repeatable task and the concrete situations in which an agent must use this Skill.
---

# Example Skill

1. Collect the context variables needed to perform the task.
2. Read the related Practice and its evidence instead of copying the knowledge into this Skill.
3. Provide verifiable results according to the output contract.
4. Execute or describe the verification method and report residual unverified risks.

## Paired Evaluation

Create `EVAL.md` and `cases.yaml` in `knowledge/evals/<skill-name>/`, then register them under `evals` in `knowledge/catalog.yaml`. Cover at least positive triggering, negative non-triggering, and boundary scenarios. Add adversarial cases when tools, permissions, or external side effects are involved. Before committing, run `make validate`, `make validate-skill-evals`, and `make review-staged`.
