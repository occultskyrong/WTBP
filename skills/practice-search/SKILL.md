---
name: practice-search
description: Search, compare, and apply WTBP practices for software or product decisions. Use when an implementation pattern must be reused, alternatives must be compared, internal precedent is missing, or recommendations need documented evidence and reference implementations.
---

# Practice Search

Use this Skill to turn an ambiguous request into a scoped, context-aware recommendation. It does not replace project facts, architecture design, or human review.

## Input Contract

- A decision question, current scenario, constraints, and the evidence or reversibility expected by the user.
- Identify the one missing variable that could materially change the recommendation; ask before comparing when it is absent.

## Workflow

1. Extract the question, current stack, scale, performance, security and compliance requirements, cost, team capability, and reversibility. State any missing variable that could change the decision.
2. Read `knowledge/catalog.yaml` and find candidate Practices by domain, tags, and status.
3. Read each candidate's metadata, applicable context, and context-specific recommendation rule first. Load evidence, reference implementations, or related Skills only when they are needed to support the decision.
4. Compare candidates against the current constraints, and explain why each is adopted, adapted, or rejected. Do not use `stale` or `deprecated` content as the default recommendation.
5. Provide a verification method. Require human confirmation before an irreversible, high-cost, security, or compliance decision.

## Boundaries

- This Skill compares reusable practices; it does not replace project-specific facts, architecture ownership, or human approval.
- Do not make an irreversible change, install a tool, or claim current evidence without the required verification.

## Output Contract

Respond in the user's language; use Chinese by default for this repository. Include the following fields:

```text
Question and current context
Missing or unavailable decision variables
Practice IDs used
Candidate options and trade-offs
Recommendation: adopt / adapt / reject
Evidence and reference implementations
Anti-patterns and residual risks
Verification method and human confirmation points
```

## Completion Gate

- Every recommendation is tied to a Practice ID, current context, evidence or an explicit evidence gap, and a verification method.
- Stale or deprecated material is not the default recommendation, and irreversible/high-impact choices have human confirmation points.
- Missing context or unsupported evidence is reported as unresolved; do not present a preference as an accepted decision.

## Resources

- Read [catalog-contract.md](references/catalog-contract.md) for catalog, status, and retrieval boundaries.
