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
- Modify, stage, commit, push, create a PR, and merge a PR remain separate action boundaries. In this repository,
  an explicit user instruction to “commit” authorizes the complete commit-delivery workflow below: run the checklist,
  commit only after it passes, and push the branch. Creating or merging a PR always requires a separate explicit
  authorization.
- Protect unrelated changes, unknown commits, and remote divergence. Do not force-push, auto-rebase, auto-stash,
  use `git reset --hard`, or use `--no-verify`.
- Use one task branch per independent task. Continue the same branch for incremental commits within that task; never
  append a new task to a branch whose scope is unclear. Create a new branch from a clean default branch with
  `tooling/new-task-branch.sh` before staging new-task changes.
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
| Use, install, add, or change a Skill | `wtbp "<request>"`, `knowledge/skill-index.yaml`, `knowledge/external-capabilities.yaml` | Capability comparison, reuse decision, target Skill, installation boundary, and contribution guidance |
| Commit or push | `docs/commit-conventions.md` | Compliant Git delivery |
| Create or merge a PR | `docs/commit-conventions.md` | GitHub governance and PR template |
| Validation, hook, or CI issue | `Makefile` | Validation scripts and repository workflow |

Use the catalog, local Skill index, external capability register, or route index before expanding files. The local
Skill index is the only source for local Skill tags and cards; the external capability register is the only source for
external capability cards; routes only match tasks and separately managed installations. Do not load all templates,
evidence, or Skill references merely because their directories exist.

Before installing, importing, copying, adding dependencies for, or executing any external Skill or project solution,
run `wtbp security-check <fixed-local-source-directory>`. A missing report, non-zero result, or review finding is a
fail-closed stop; only a clean result permits the separately authorized installation or adoption step.

Apply [knowledge/skill-framework.md](knowledge/skill-framework.md) to every Skill change or execution. It defines
the five layers, minimum Skill contract, registry graph, G0–G6 gates, lifecycle statuses, and fail-closed rules.

## Exploration and implementation

- When `.codegraph/` exists, use `codegraph files`, `codegraph explore`, or `codegraph node` before text search for
  code or repository-structure questions. Use `rg` for documentation-only questions or when no index exists.
- For non-trivial coding, refactoring, debugging, or review, apply `karpathy-guidelines`: state assumptions, make the
  smallest change that solves the task, and verify concrete success criteria.
- Before delivery, report the scope, validation results, unverified boundaries, and the next authorization required.

## Commit gate

Before staging and committing, run `make sync-default-branch`; it refreshes `origin/<default>` and fast-forwards the local default-branch ref when no other worktree owns it. Before a commit, run `make commit-checklist`. It reuses that synchronized base and verifies mergeability, then runs repository
validation, staged-content review, sensitive-information scanning, `skill-up` contract review for changed Skills or registered
Eval assets, quality gates, and the paired `VERSION`/`CHANGELOG.md` check. See
[docs/commit-checklist.md](docs/commit-checklist.md).

## Commit delivery workflow

When the user says “commit” (or an equivalent Chinese instruction such as “提交”), execute these steps in order:

1. Inspect the worktree, staged scope, current branch, task scope, remote divergence, and the intended Conventional Commit message.
2. If the current branch is the default branch or its task scope is unclear, stop before staging/committing and create a clean task branch with `tooling/new-task-branch.sh`. Never auto-stash or migrate existing changes.
3. Run `make sync-default-branch` before staging and committing. It refreshes the remote default branch and fast-forwards the local default-branch ref without switching away from a task branch. If another worktree owns the default branch, it reports the owner and does not mutate that worktree; the refreshed remote ref remains the mergeability baseline.
4. Run `make commit-checklist`. It reuses the refreshed default branch and checks mergeability without modifying the worktree. If any
   check fails, stop; do not create a commit or push.
5. Create the commit with the validated scope and a Chinese Conventional Commit summary.
6. Push the current task branch to its configured remote without force-push or history rewriting. The `pre-push` hook repeats
   the mergeability preflight after refreshing the default branch.
7. After a successful push, run `make return-to-default`. It first refreshes the default branch, then switches this clean, fully pushed worktree to it and fast-forwards it (`pull --ff-only` equivalent). If another worktree owns the default branch, it must report the owner as a safe skip; never force a switch or mutate that other worktree. This is branch hygiene, not a substitute for the mergeability preflight.
8. Verify the remote branch and branch-return result, then report the commit and push results separately. Creating a PR is not
   part of this workflow and occurs only on a separate explicit instruction. After a version-changing update is merged to
   `master`, the successful repository-check workflow creates and pushes the immutable `vX.Y.Z` tag; do not create a release
   tag from a task branch.

If commit or push fails because of conflicts, permissions, missing credentials, or remote divergence, stop at that step and
report the exact blocker and the next user-authorized action. Never bypass a failed gate, use `--no-verify`, force-push, or
auto-rebase. An instruction to “run the commit checklist” alone authorizes validation only; it does not authorize a commit
or push.
