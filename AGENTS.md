# WTBP Agent Guide

Chinese companion: [AGENTS.zh-CN.md](AGENTS.zh-CN.md). This English file is the canonical AI-readable source.

WTBP stores reusable software and product decision knowledge bound to real scenarios. It is not a collection of
generic answers or prompt fragments. This file contains the minimum standing rules; load detailed workflows only
when the task requires them.

## Language policy

- Human-facing documentation is Chinese by default: `README.md`, `docs/`, contribution guidance, Issue and PR text.
- AI entrypoints, executable instructions, and their loaded references are English: `AGENTS.md`, `CLAUDE.md`,
  `skills/**/SKILL.md`, and `skills/**/references/*.md`.
- Every AI-readable document has a Chinese companion named `<name>.zh-CN.md`; update both in the same change.
- Paths, IDs, YAML keys, commands, and user-facing test prompts keep their required language and format.
- Read [docs/document-language-policy.md](docs/document-language-policy.md) before adding a document or translation.

## Always follow

- Establish the scenario, goal, constraints, and required evidence first. Never treat generated text as the only evidence.
- Keep project-specific facts in the consuming project. Contribute only reusable knowledge with scope, counterexamples,
  traceable evidence, and verification methods.
- Do not use `stale` or `deprecated` content as a default recommendation.
- Modify, stage, commit, push, create a PR, and merge a PR are separate authorizations.
- Protect unrelated changes, unknown commits, and remote divergence. Do not force-push, auto-rebase, auto-stash,
  use `git reset --hard`, or use `--no-verify`.
- Never commit secrets, tokens, generated reports, caches, or unrelated files.

## Remote access hard boundary

Never run SSH or SSH-based remote access on the user's behalf, including `ssh`, `scp`, `sftp`, `rsync`, `mosh`,
`autossh`, `sshpass`, `ssh-keyscan`, Git SSH remotes, Docker SSH contexts, or wrappers. This includes read-only
inspection and diagnostics. Provide commands for the user to run and continue only from sanitized output they return.

## Task routing

| Task | Read first | Load only if needed |
|---|---|---|
| Understand the repository | `README.md` | `docs/how-to-use.md`, `docs/concepts.md` |
| High-impact technical or product decision | `skills/practice-search/SKILL.md` | `knowledge/catalog.yaml`, context schema, target Practice and evidence |
| Add or change a Practice | `CONTRIBUTING.md` | Practice template, catalog, relationships |
| Use, install, add, or change a Skill | `knowledge/skill-routes.yaml`, `docs/skill-routing.md` | Target Skill, Practice, Eval, contribution guidance |
| Commit, push, or create a PR | `docs/commit-conventions.md` | GitHub governance and PR template |
| Validation, hook, or CI issue | `Makefile` | Validation scripts and repository workflow |

Use the catalog or route index before expanding files. Do not load all templates, evidence, or Skill references merely
because their directories exist.

## Exploration and implementation

- When `.codegraph/` exists, use `codegraph files`, `codegraph explore`, or `codegraph node` before text search for
  code or repository-structure questions. Use `rg` for documentation-only questions or when no index exists.
- For non-trivial coding, refactoring, debugging, or review, apply `karpathy-guidelines`: state assumptions, make the
  smallest change that solves the task, and verify concrete success criteria.
- Before delivery, report the scope, validation results, unverified boundaries, and the next authorization required.

## Commit gate

Before a commit, run `make commit-checklist`. It runs `make validate`, staged-content review, `ske` contract evaluation
for changed Skills, quality gates, and the `VERSION` check. See [docs/commit-checklist.md](docs/commit-checklist.md).
