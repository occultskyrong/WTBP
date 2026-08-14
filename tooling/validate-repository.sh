#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
required_paths=(
  "README.md"
  "VERSION"
  "AGENTS.md"
  "AGENTS.zh-CN.md"
  "CLAUDE.md"
  "CLAUDE.zh-CN.md"
  "CONTRIBUTING.md"
  ".editorconfig"
  ".gitattributes"
  ".githooks/commit-msg"
  ".github/ISSUE_TEMPLATE/config.yml"
  ".github/ISSUE_TEMPLATE/practice-proposal.yml"
  ".github/ISSUE_TEMPLATE/evidence-correction.yml"
  ".github/ISSUE_TEMPLATE/repository-bug.yml"
  ".github/PULL_REQUEST_TEMPLATE.md"
  ".github/workflows/issue-content-review.yml"
  ".github/dependabot.yml"
  "docs/commit-conventions.md"
  "docs/commit-checklist.md"
  "docs/document-language-policy.md"
  "docs/skill-routing.md"
  "docs/skill-catalog.md"
  "docs/github-governance.md"
  "docs/governance.md"
  "knowledge/schemas/taxonomy.yaml"
  "knowledge/schemas/context-schema.yaml"
  "knowledge/schemas/practice-schema.yaml"
  "knowledge/schemas/relationship-schema.yaml"
  "knowledge/schemas/eval-schema.yaml"
  "knowledge/schemas/skill-index-schema.yaml"
  "knowledge/skill-routes.yaml"
  "knowledge/skill-index.yaml"
  "knowledge/catalog.yaml"
  "knowledge/relationships.yaml"
  "knowledge/external-sources.yaml"
  "knowledge/templates/practice-template.md"
  "knowledge/templates/skill-template/SKILL.md"
  "knowledge/templates/skill-template/SKILL.zh-CN.md"
  "knowledge/templates/eval-template/EVAL.md"
  "knowledge/templates/eval-template/cases.yaml"
  "skills/practice-search/SKILL.md"
  "skills/skill-router/SKILL.md"
  "tooling/wtbp"
  "skills/skill-evaluation/SKILL.md"
  "tooling/install-git-hooks.sh"
  "tooling/install-wtbp.sh"
  "tooling/install-skill.sh"
  "tooling/review-staged.sh"
  "tooling/review-issue-body.sh"
  "tooling/validate-repository.sh"
  "tooling/validate-skill-evals.sh"
  "tooling/validate-skill-routes.sh"
  "tooling/validate-skill-index.sh"
  "tooling/generate-skill-catalog.sh"
  "tooling/run-skill-eval.sh"
  "tooling/commit-checklist.sh"
)

for path in "${required_paths[@]}"; do
  if [[ ! -f "$repo_root/$path" ]]; then
    printf '缺少必需文件：%s\n' "$path" >&2
    exit 1
  fi
done

bash -n "$repo_root/.githooks/pre-commit"
bash -n "$repo_root/.githooks/commit-msg"
bash -n "$repo_root/tooling/review-staged.sh"
bash -n "$repo_root/tooling/review-issue-body.sh"
bash -n "$repo_root/tooling/validate-repository.sh"
bash -n "$repo_root/tooling/validate-skill-evals.sh"
bash -n "$repo_root/tooling/validate-skill-routes.sh"
bash -n "$repo_root/tooling/validate-skill-index.sh"
bash -n "$repo_root/tooling/generate-skill-catalog.sh"
bash -n "$repo_root/tooling/wtbp"
bash -n "$repo_root/tooling/install-wtbp.sh"
bash -n "$repo_root/tooling/install-skill.sh"
bash -n "$repo_root/tooling/run-skill-eval.sh"
bash -n "$repo_root/tooling/commit-checklist.sh"

if ! rg -q '^[0-9]+\.[0-9]+\.[0-9]+$' "$repo_root/VERSION"; then
  printf 'VERSION 必须符合 MAJOR.MINOR.PATCH 三段式格式。\n' >&2
  exit 1
fi

for issue_form in "$repo_root"/.github/ISSUE_TEMPLATE/*.yml; do
  [[ "${issue_form##*/}" == "config.yml" ]] && continue
  if ! rg -q '^name: .+' "$issue_form" || ! rg -q '^description: .+' "$issue_form" || ! rg -q '^body:' "$issue_form"; then
    printf 'Issue 表单无效：%s\n' "${issue_form#$repo_root/}" >&2
    exit 1
  fi
done

if ! rg -q '^blank_issues_enabled: false$' "$repo_root/.github/ISSUE_TEMPLATE/config.yml"; then
  printf 'Issue 选择器必须禁用空白 Issue。\n' >&2
  exit 1
fi

if ! rg -q '^  - package-ecosystem: github-actions$' "$repo_root/.github/dependabot.yml"; then
  printf 'Dependabot 必须监控 GitHub Actions。\n' >&2
  exit 1
fi

if ! rg -U -q '^permissions:\n  contents: read$' "$repo_root/.github/workflows/repository-check.yml"; then
  printf '仓库工作流必须使用只读的 contents 权限。\n' >&2
  exit 1
fi

while IFS= read -r skill_file; do
  if ! rg -q '^---$' "$skill_file" || ! rg -q '^name: [a-z0-9-]+$' "$skill_file" || ! rg -q '^description: .+' "$skill_file"; then
    printf 'Skill 元数据无效：%s\n' "${skill_file#$repo_root/}" >&2
    exit 1
  fi
done < <(rg --files "$repo_root/skills" -g 'SKILL.md')

while IFS= read -r ai_file; do
  companion_file="${ai_file%.md}.zh-CN.md"
  if [[ ! -f "$companion_file" ]]; then
    printf 'AI 文档缺少中文对照：%s（应为 %s）\n' "${ai_file#$repo_root/}" "${companion_file#$repo_root/}" >&2
    exit 1
  fi
done < <(printf '%s\n' \
  "$repo_root/AGENTS.md" \
  "$repo_root/CLAUDE.md" \
  "$repo_root/knowledge/templates/skill-template/SKILL.md" \
  && rg --files "$repo_root/skills" -g 'SKILL.md')

while IFS= read -r reference_file; do
  [[ -n "$reference_file" ]] || continue
  companion_file="${reference_file%.md}.zh-CN.md"
  if [[ ! -f "$companion_file" ]]; then
    printf 'AI 参考资料缺少中文对照：%s（应为 %s）\n' "${reference_file#$repo_root/}" "${companion_file#$repo_root/}" >&2
    exit 1
  fi
done < <(rg --files "$repo_root/skills" -g '*.md' | rg '/references/[^/]+\.md$' | rg -v '\.zh-CN\.md$' || true)

"$repo_root/tooling/validate-skill-evals.sh"
"$repo_root/tooling/validate-skill-routes.sh"
"$repo_root/tooling/validate-skill-index.sh"
"$repo_root/tooling/generate-skill-catalog.sh" --check

if [[ -d "$repo_root/knowledge/practices" ]]; then
  while IFS= read -r practice_file; do
    for field in id title domain status maturity last_verified tags; do
      if ! rg -q "^${field}:" "$practice_file"; then
        printf '%s 缺少字段：%s\n' "${practice_file#$repo_root/}" "$field" >&2
        exit 1
      fi
    done
  done < <(rg --files "$repo_root/knowledge/practices" -g 'PRACTICE.md')
fi

printf 'WTBP 仓库结构校验：通过\n'
