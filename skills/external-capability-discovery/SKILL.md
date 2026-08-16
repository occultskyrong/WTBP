---
name: external-capability-discovery
description: Discover and rank public external Skills, official integrations, GitHub implementations, and reusable solutions for a concrete task. Use when no registered local WTBP Skill or external capability clearly fits, or when the user asks to search GitHub, skills.sh, or the public web for an existing Skill or solution and needs a source-backed percentage ranking before adoption or installation.
---

# External Capability Discovery

Discover before building. This Skill is the online fallback after local WTBP capability discovery; it does not replace a clearly applicable local Skill.

## Input Contract

- Required: the task goal, desired result, target domain or stack, and constraints that affect adoption.
- Optional: target platform, license preference, security boundary, installation permission, time range, and minimum score.
- First confirm the local decision with `wtbp "<request>"`. If one registered local Skill clearly meets the request, return that selection and do not begin online discovery.
- If goal, target artifact, or constraints are missing, ask only for the smallest missing information needed to compare candidates.

## Workflow

1. Record the local result: selected local capability, candidates rejected as insufficient, or `no_match`. A keyword hit alone is not a local match.
2. Define up to five source-specific search queries from the goal, stack, target platform, and required outcome. State the search scope and check date.
3. Search progressively, opening each source before using it as evidence:
   - use `find-skills` / skills.sh for installable Agent Skills, checking its leaderboard before a narrower search;
   - search GitHub for a `SKILL.md`, official integration, maintained repository, or reference implementation;
   - search first-party documentation and primary material before secondary listings;
   - use `systematic-cognition` source rules for public-web evidence, citations, conflicts, and inaccessible pages.
4. Create one temporary candidate card per relevant result. Collect only facts verified in the current session: source URL, publisher, type, supported task, installation count when applicable, GitHub stars/forks, observable active contributors, commits in the preceding 180 days, last commit or release date, license, fixed revision availability, Skill path, permissions, and side effects.
5. Read [scoring-model.md](references/scoring-model.md). Score every candidate from 0 to 100, retain its five component scores and raw metrics, calculate evidence confidence separately, then rank candidates by total score. Never invent missing metrics or present an unavailable metric as zero without saying why.
6. Make one adoption recommendation per candidate: `direct-use`, `adapt`, `compose`, `reference-only`, `reject`, or `build-local`. Explain why the highest-scoring candidate fits better than the next candidate and where human confirmation is still required.
7. Stop before installation, registry writes, code execution, credential access, or project modification. Only a user-approved, separately reviewed candidate may later be registered or installed through WTBP governance.

## Boundaries

- Read public sources only. Do not log in, bypass access controls, read private repositories, download executables, install packages, run unknown code, or access credentials.
- Treat skills.sh as one discovery source, not proof of quality. `find-skills` does not replace GitHub, license, maintenance, or security checks.
- Do not claim exhaustive GitHub or web coverage. A search result, repository title, star count, or model memory is not sufficient evidence of fitness.
- Keep discovered candidates temporary. Do not add them to `knowledge/external-sources.yaml`, `knowledge/external-capabilities.yaml`, or `knowledge/skill-routes.yaml` without explicit user approval and the normal review gates.
- A score ranks current evidence; it is not a safety approval, behavior evaluation, or installation authorization.

## Output Contract

Respond in the user's language; use Chinese by default. Include:

```text
Local-first decision and search scope
Ranked candidate table: rank, total score / 100, evidence confidence, adoption recommendation
For every candidate: component scores, source links, source type, raw adoption and maintenance metrics, license, revision/path, permissions, and check date
Why the ranking differs between the first two candidates
Unverified or unavailable metrics and their scoring effect
Recommended next authorization; no installation was performed
```

## Completion Gate

- A local capability was selected, rejected with evidence, or explicitly marked `no_match` before online discovery.
- Every ranked candidate has a current-session-opened source and a transparent 100-point total; unavailable metrics are disclosed.
- The response distinguishes total score from evidence confidence, ranks only comparable candidates, and includes no fabricated metrics, citations, permissions, or versions.
- No external content was installed, executed, persisted, or granted access. Otherwise report the discovery as incomplete.
