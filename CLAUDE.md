# WTBP Claude Guide

Chinese companion: [CLAUDE.zh-CN.md](CLAUDE.zh-CN.md). This English file is the canonical Claude-readable source.

`AGENTS.md` defines the standing boundaries. This file adds Claude-specific progressive reading and delivery rules.
Follow the language policy in [docs/document-language-policy.md](docs/document-language-policy.md).

## Start every task

1. Read `AGENTS.md` and follow its authorization, language, and remote-access boundaries.
2. Run `git status --short --branch` to establish the branch and unrelated changes.
3. Read the Chinese `README.md` for repository navigation; load only the route or document needed for the task.
4. Do not load all of `knowledge/` or all Skill references by default.

## Progressive routing

| Signal | Read first | Expected result |
|---|---|---|
| Compare technical, cost, safety, or compliance options | `skills/practice-search/SKILL.md` | Scenario-bound recommendation and evidence boundary |
| Use, install, add, or change a Skill | `wtbp "<request>"`, `knowledge/skill-index.yaml` | Capability comparison, reuse decision, installation boundary, or Skill/Eval contribution |
| Change repository rules or automation | Relevant Chinese `docs/` and source files | Scope, impact, and validation |
| Commit, push, or create a PR | `docs/commit-conventions.md` | Compliant Git delivery |
| Diagnose validation, hook, or CI | `Makefile` and relevant `tooling/` | Reproducible diagnosis and verification |

For a high-impact decision, start at `knowledge/catalog.yaml`, then load only the target Practice, evidence, reference
implementation, or Skill. For Skill discovery, inspect `knowledge/skill-index.yaml` before `knowledge/skill-routes.yaml`:
the former is the sole capability metadata source, while the latter only matches tasks. Prefer current `approved`
content and never use `stale` or `deprecated` material by default.

## Execution

- For code or structure exploration, use CodeGraph first when `.codegraph/` exists.
- Apply `karpathy-guidelines` to non-trivial implementation, refactoring, debugging, or review work.
- Keep changes surgical. Do not modify, stage, commit, push, create a PR, or merge without the corresponding user authorization.
- Do not use SSH-based remote access. Ask the user to run remote commands and return sanitized output when needed.

## Delivery

For decisions, report the scenario, missing variables, Practice ID, alternatives and tradeoffs, recommendation, evidence,
remaining risk, and verification method. For changes, also report scope, commands run and results, unverified items, and
the next authorization needed.

Before committing, run `make commit-checklist`. Use Chinese commit and PR descriptions while retaining English tool
identifiers, paths, IDs, and Conventional Commit types.
