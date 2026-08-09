#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
required_paths=(
  "README.md"
  "AGENTS.md"
  "CLAUDE.md"
  "CONTRIBUTING.md"
  ".editorconfig"
  ".gitattributes"
  ".githooks/commit-msg"
  ".github/ISSUE_TEMPLATE/config.yml"
  ".github/ISSUE_TEMPLATE/practice-proposal.yml"
  ".github/ISSUE_TEMPLATE/evidence-correction.yml"
  ".github/ISSUE_TEMPLATE/repository-bug.yml"
  ".github/PULL_REQUEST_TEMPLATE.md"
  ".github/dependabot.yml"
  "docs/commit-conventions.md"
  "docs/github-governance.md"
  "docs/governance.md"
  "knowledge/schemas/taxonomy.yaml"
  "knowledge/schemas/context-schema.yaml"
  "knowledge/schemas/practice-schema.yaml"
  "knowledge/schemas/relationship-schema.yaml"
  "knowledge/catalog.yaml"
  "knowledge/relationships.yaml"
  "knowledge/external-sources.yaml"
  "knowledge/templates/practice-template.md"
  "knowledge/templates/skill-template/SKILL.md"
  "skills/practice-search/SKILL.md"
  "tooling/install-git-hooks.sh"
  "tooling/review-staged.sh"
  "tooling/validate-repository.sh"
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
bash -n "$repo_root/tooling/validate-repository.sh"

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
