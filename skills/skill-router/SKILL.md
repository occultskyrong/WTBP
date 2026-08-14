---
name: skill-router
description: Discover and route a user request to the smallest applicable WTBP Skill. Use when the user asks which Skill to use, writes `wtbp`, wants one entry point for many Skills, needs to reuse or install a Skill, or has an unclear task that may match several Skills.
---

# Skill Router

Route first; do not merge every Skill into this Skill or load every `SKILL.md`.

## Input Contract

- A user task with its goal, constraints, expected evidence, and any requested installation or side effect.
- If semantic intent, target domain, or acceptance boundary is missing, return `clarify` instead of guessing.

## Workflow

1. Identify the user's goal, constraints, expected evidence, and whether the request needs discovery rather than direct execution.
2. First run `wtbp root` and retain the returned `<wtbp-root>`. This resolves the WTBP repository even when the current workspace is a consuming product repository. Never resolve WTBP paths relative to the current workspace.
3. Use `wtbp list --domain <domain>` to browse a known domain, `wtbp show <skill-id>` to inspect one capability card, and `wtbp "<user request>"` to obtain local candidates and matching evidence. `wtbp` never starts another LLM session.
4. Read `<wtbp-root>/knowledge/skill-index.yaml` and let the current Agent/Claude session compare candidate cards by intent, inputs, outputs, stage, and side effects. Return one of `select`, `clarify`, or `no_match`, with a short reason and missing context.
5. If exactly one active local route clearly matches, read only that route's `SKILL.md` from `<wtbp-root>` and follow it.
6. If several routes match, present the candidates, their boundaries, and the recommended route. Ask for a choice before running a high-impact workflow.
7. If exactly one active external route matches and it is registered with `auto_install: true`, confirm the semantic match and installation boundary, then explicitly run `wtbp install <skill-id>`. Candidate discovery itself never installs. Otherwise show its source, version, pinned commit, permissions, installation scope, and verification method without installing it.
8. If no route matches, explain why. Propose a new Skill only when the task is repeated, stable, and can have positive, negative, boundary, and necessary adversarial Eval cases.

## Boundaries

- The router never executes a selected Skill. Candidate discovery never installs. Installation requires an explicit `wtbp install <skill-id>` after the current session confirms a single registered external GitHub HTTPS route that is active, pinned to a 40-character commit, and explicitly marked `auto_install: true`.
- Never install arbitrary URLs, unpinned revisions, `candidate`, `stale`, or `deprecated` routes automatically. Do not overwrite non-WTBP Skill links.
- Do not route simple translation, rewriting, or one-off editing tasks merely because they contain a generic keyword.
- Do not select `stale` or `deprecated` routes by default.
- Keep route matching explainable: state the matched keywords and any missing context.
- Treat `skill-index.yaml` as the only source for capability tags and cards. Do not manually reconstruct capabilities from route keywords.
- The current session's semantic decision is only a recommendation until the selected Skill is loaded and its scope is confirmed. Never let the routing step install, execute, write to Figma, or expand permissions.

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

## Completion Gate

- The result is `select`, `clarify`, or `no_match` with matched evidence, boundaries, and the next read/command.
- No keyword match is treated as semantic execution; no Skill is installed or run during discovery.
- Installation is only reported after explicit authorization and the registered source, pin, permissions, and verification pass.
