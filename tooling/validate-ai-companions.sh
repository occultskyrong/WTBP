#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  printf 'AI 文档对照校验失败：%s\n' "$1" >&2
  exit 1
}

gate_markers() {
  rg -o '[A-Z][A-Z0-9]{0,15}-(?:[0-9]{2}|YYYYMMDD-VNN)' "$1" 2>/dev/null | sort -u || true
}

validate_pair() {
  local canonical="$1"
  local companion="${canonical%.md}.zh-CN.md"

  [[ -f "$companion" ]] || fail "缺少中文对照：${canonical#$repo_root/}"
  if ! diff -u <(gate_markers "$canonical") <(gate_markers "$companion") >/dev/null; then
    fail "规则标识不一致：${canonical#$repo_root/} 与 ${companion#$repo_root/}"
  fi
}

ai_files=(
  "$repo_root/AGENTS.md"
  "$repo_root/CLAUDE.md"
  "$repo_root/knowledge/design-principles.md"
  "$repo_root/knowledge/design-workflow.md"
  "$repo_root/knowledge/skill-framework.md"
  "$repo_root/knowledge/templates/project-design-contract-template.md"
  "$repo_root/knowledge/templates/icon-asset-inventory-template.md"
  "$repo_root/knowledge/templates/action-group-contract-template.md"
  "$repo_root/knowledge/templates/skill-template/SKILL.md"
)

while IFS= read -r file; do
  [[ -n "$file" ]] && ai_files+=("$file")
done < <(rg --files "$repo_root/skills" -g 'SKILL.md')

while IFS= read -r file; do
  [[ -n "$file" ]] && ai_files+=("$file")
done < <(rg --files "$repo_root/skills" -g '*.md' | rg '/references/[^/]+\.md$' | rg -v '\.zh-CN\.md$' || true)

for file in "${ai_files[@]}"; do
  validate_pair "$file"
done

printf 'AI 文档对照校验：通过（%s 份规范源）\n' "${#ai_files[@]}"
