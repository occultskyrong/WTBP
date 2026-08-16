---
name: external-capability-curation
description: Curate a user-provided public GitHub project, external Skill, official integration, or reference implementation into an uninstalled, searchable WTBP external best-practice card. Use when a user says `wtbp, collect public URL` or sends a repository or Skill URL and asks to collect, register, remember, classify, or make it discoverable for future solution searches without installing it.
---

# External Capability Curation

Collect evidence once; reuse it safely later. This Skill writes governed discovery metadata, never installs third-party content.

## Input Contract

- Required: a public repository, Skill, or official source URL and the user's intent to collect it rather than merely discuss it. `wtbp, collect <public URL>` is explicit authorization to create a new collected record; do not ask again before the new-record write.
- Optional: known use case, target technology or terminal, desired adoption boundary, and a fixed revision.
- If the URL is missing, private, inaccessible, or the user has not asked to retain it, return a draft-only analysis and do not write registry files.

## Workflow

1. Open the user-provided source in the current session. Record canonical URL, publisher, source type, license, visible revision or release, access date, and visible maintenance/community evidence. Do not infer repository facts from its name or model memory.
2. Read the relevant source files, including `SKILL.md` when present. Identify the actual problem solved, inputs, outputs, supported technology/targets, side effects, permissions, explicit non-goals, and installation boundary.
3. Load [card-contract.md](references/card-contract.md). Search `knowledge/external-sources.yaml` and `knowledge/external-capabilities.yaml` by canonical URL, publisher/repository identity, fixed revision, and Skill path. For an existing record, present the difference and require explicit approval before overwrite, revision replacement, or a second card.
4. For a new source, create one source record and one best-practice capability card automatically. Use a stable lowercase-hyphen ID, concise Chinese human-facing fields, and normalized tags. Default to `status: candidate`, `adoption: reference-only`, `availability: reference`, and `installation_status: uninstalled` unless the user separately authorizes a stricter review.
5. Fill the retrieval contract: `solves`, `not_for`, `scenarios`, `cases`, `inputs`, `outputs`, `technologies`, `targets`, and `keywords`. `scenarios` states when the capability is appropriate; `cases` gives at least two representative Chinese task requests that should match later. Do not use publisher names as the only retrieval signal.
6. Persist only `knowledge/external-sources.yaml` and `knowledge/external-capabilities.yaml`; do not create an installation route. Then show the source evidence, duplicate result, best-practice scenarios/cases, and future `wtbp` match signals.
7. Run source and external-capability validation plus a focused `wtbp "<representative request>"` query. Report the card ID, future match evidence, unresolved facts, and that no installation occurred.

## Boundaries

- Read only public sources. Never log in, bypass access control, clone or execute untrusted code, install a package or Skill, inspect credentials, or add an install route.
- A collected card is discovery metadata, not an endorsement, security review, runtime acceptance, or authorization to use the external content.
- Do not overwrite a collected record, upgrade its status, or replace its revision without explicit user approval and current-session evidence. The original `collect` authorization covers a new record only.
- Never claim a project solves a problem merely because its README uses related keywords. If capabilities, license, revision, or permissions are unclear, record `unverified` and keep the card `candidate`.
- Do not create a local WTBP Skill merely to store a third-party URL. Use `external-capability-discovery` for online comparison and this Skill for user-approved retention.

## Output Contract

Respond in the user's language; use Chinese by default. Include:

```text
Source identity and current-session evidence
Collection decision: draft-only / collected / duplicate / update-required
What the capability solves and does not solve
Uninstalled best-practice card: ID, scenarios, cases, retrieval fields, adoption, status, permission and install boundary
Future wtbp query examples and expected match signals
Unverified metadata and its impact
Validation result; explicit statement that no installation occurred
```

## Completion Gate

- Every retained source has an opened HTTPS URL, publisher, access date, license, revision, Skill path, quality evidence, and source-to-card link; unknown facts state why they are `unverified`.
- The card has non-empty scenarios, cases, retrieval fields, and an explicit `uninstalled` installation status; it is not an installation route.
- Duplicate handling is explicit, and any unverified source claim remains `candidate`.
- Validation and representative local retrieval pass after a write; otherwise leave only a draft and report the first blocking issue.
