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
3. Use `wtbp list --domain <domain>` to browse local Skills, `wtbp external --domain <domain>` to browse external capability cards, `wtbp show <id>` to inspect either card type, and `wtbp "<user request>"` to obtain local and external candidates with matching evidence. `wtbp` never starts another LLM session.
4. Read `<wtbp-root>/knowledge/skill-index.yaml` for local Skill cards and `<wtbp-root>/knowledge/external-capabilities.yaml` for external capability cards. Let the current Agent/Claude session compare intent, inputs, outputs, stage, side effects, authority, permissions, and available evidence.
5. When an external capability, a reference implementation, or a new local Skill may be relevant, load `references/external-capability-selection.md`. Return `select`, `clarify`, or `no_match`, plus one adoption decision: `direct-use`, `adapt`, `compose`, `reference-only`, or `build-local`.
6. If exactly one active local route clearly matches, read only that route's `SKILL.md` from `<wtbp-root>` and follow it. A `local-adapter` external capability is never a replacement for the selected local Skill's contract.
7. If several routes or capability cards match, present their boundaries and the recommended ordering. Ask for a choice before running a high-impact workflow.
8. If exactly one active external installation route matches and it is separately registered with `auto_install: true`, confirm the semantic match and installation boundary, then explicitly run `wtbp install <skill-id>`. Capability-card discovery itself never installs; `manual-optional` cards always require an explicit authorization and separate source, pin, license, permission, credential, and environment review.
9. When the user says `wtbp, collect <public URL>`, treat it as explicit authorization for one new, uninstalled best-practice record. Load `external-capability-curation` immediately: it reads the public source, deduplicates it, extracts scenarios and at least two cases, then writes the source record and capability card. It never creates an install route. Existing-record overwrite or revision replacement still needs separate approval.
10. If no registered local or external capability clearly fits after semantic comparison, select `external-capability-discovery` before proposing `build-local`. It first records the local `no_match`, then uses `find-skills`/skills.sh, GitHub, and primary public sources to rank temporary candidates. Use `systematic-cognition` for claim-level public-web evidence within that discovery. Do not invoke online discovery when a local Skill is clearly sufficient.
11. Propose `build-local` only after external discovery assessed existing sources, the task is repeated and stable, and positive, negative, boundary, and necessary adversarial Eval cases can be written.

## Boundaries

- The router never executes a selected Skill. Candidate discovery never installs. Installation requires an explicit `wtbp install <skill-id>` after the current session confirms a single separately registered external GitHub HTTPS route that is active, pinned to a 40-character commit, explicitly marked `auto_install: true`, and passed `wtbp security-check <local-candidate-directory>` with no blocking or review findings. Project solutions outside this installer have the same mandatory security-check gate before import, dependency installation, or execution.
- Never install arbitrary URLs, unpinned revisions, `candidate`, `stale`, or `deprecated` routes automatically. Do not overwrite non-WTBP Skill links.
- Do not route simple translation, rewriting, or one-off editing tasks merely because they contain a generic keyword.
- Do not select `stale` or `deprecated` routes by default.
- Keep route matching explainable: state the matched keywords and any missing context.
- Treat `skill-index.yaml` as the only source for local Skill tags and cards, and `external-capabilities.yaml` as the only source for external capability cards. Do not manually reconstruct either from route keywords.
- Do not recommend a local Skill merely because no keyword matched. For a possible new capability, search/reuse evidence first and load `references/external-capability-selection.md`.
- Do not treat the router's keyword count as semantic fit. Only after the current session rules out a clear local selection may it load `external-capability-discovery`; the router itself never performs network search.
- The current session's semantic decision is only a recommendation until the selected Skill is loaded and its scope is confirmed. Never let the routing step install, execute, write to Figma, or expand permissions. The only retained-metadata exception is a new `wtbp, collect <public URL>` record, whose write boundary is defined by `external-capability-curation`.

## Output Contract

Respond in the user's language; use Chinese by default for this repository. Include:

```text
User goal and context
Capability view used: list / show / recommend
Matched local Skill and external capability candidates with matched keywords
Recommended route, adoption decision, and boundary
Whether online discovery is deferred or selected after the local-first decision
Required next read or command
Installation or authorization requirement, if any
Unmatched or missing context
```

## Completion Gate

- The result is `select`, `clarify`, or `no_match` with matched evidence, one adoption decision, boundaries, and the next read/command.
- No keyword match is treated as semantic execution; no Skill is installed or run during discovery, and no external capability card is treated as an installation instruction.
- Online external discovery is selected only after the local-first semantic decision and returns ranked candidates only; it does not install, execute, or register external content.
- Installation is only reported after explicit authorization and the registered source, pin, permissions, and verification pass.
