---
name: skill-router
description: Discover and route a user request to the smallest applicable WTBP Skill. Use when the user asks which Skill to use, writes `wtbp`, wants one entry point for many Skills, needs to reuse or install a Skill, or has an unclear task that may match several Skills.
---

# Skill Router

Route first; do not merge every Skill into this Skill or load every `SKILL.md`.

## Workflow

1. Identify the user's goal, constraints, expected evidence, and whether the request needs discovery rather than direct execution.
2. Use `wtbp list --domain <domain>` to browse a known domain, `wtbp show <skill-id>` to inspect one capability card, and `wtbp "<user request>"` to recommend a route.
3. Read `knowledge/skill-index.yaml` before comparing capabilities, inputs, outputs, or side effects. Read `knowledge/skill-routes.yaml` only to explain task matching.
4. If exactly one active local route clearly matches, read only that route's `SKILL.md` and follow it.
5. If several routes match, present the candidates, their boundaries, and the recommended route. Ask for a choice before running a high-impact workflow.
6. If exactly one active external route matches and it is registered with `auto_install: true`, run `wtbp install <skill-id>`. Otherwise show its source, version, pinned commit, permissions, installation scope, and verification method without installing it.
7. If no route matches, explain why. Propose a new Skill only when the task is repeated, stable, and can have positive, negative, boundary, and necessary adversarial Eval cases.

## Boundaries

- The router never executes a selected Skill. It may install only a single registered external GitHub HTTPS route that is active, pinned to a 40-character commit, and explicitly marked `auto_install: true`.
- Never install arbitrary URLs, unpinned revisions, `candidate`, `stale`, or `deprecated` routes automatically. Do not overwrite non-WTBP Skill links.
- Do not route simple translation, rewriting, or one-off editing tasks merely because they contain a generic keyword.
- Do not select `stale` or `deprecated` routes by default.
- Keep route matching explainable: state the matched keywords and any missing context.
- Treat `skill-index.yaml` as the only source for capability tags and cards. Do not manually reconstruct capabilities from route keywords.

## Output Contract

Respond in the user's language; use Chinese by default for this repository. Include:

```text
User goal and context
Capability view used: list / show / recommend
Matched Skill candidates and matched keywords
Recommended route and boundary
Required next read or command
Installation or authorization requirement, if any
Unmatched or missing context
```
