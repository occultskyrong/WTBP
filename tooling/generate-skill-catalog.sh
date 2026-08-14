#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
index_file="$repo_root/knowledge/skill-index.yaml"
output_file="$repo_root/docs/skill-catalog.md"

generate() {
  cat <<'EOF'
# Skill 能力总览

本页由 `knowledge/skill-index.yaml` 生成。它帮助人快速浏览能力；执行时仍应通过 `wtbp` 路由并按需读取目标 `SKILL.md`。

| Skill | 状态 | 领域 | 阶段 | 核心能力 | 简介 |
|---|---|---|---|---|---|
EOF
  awk -F': ' '
    function clean(value) { sub(/^\[/, "", value); sub(/\]$/, "", value); gsub(/, /, "、", value); return value }
    function emit() { if (id != "") print "| `" id "` | " status " | " clean(domains) " | " clean(stages) " | " clean(capabilities) " | " summary " |" }
    /^  - id: / { emit(); id = $2; summary = domains = capabilities = stages = status = ""; next }
    /^    summary: / { summary = $2 }
    /^    domains: / { domains = $2 }
    /^    capabilities: / { capabilities = $2 }
    /^    stages: / { stages = $2 }
    /^    status: / { status = $2 }
    END { emit() }
  ' "$index_file"

  cat <<'EOF'

## 如何选择

- 已知要解决什么问题：运行 `wtbp "<问题>"`，获取候选 Skill 和匹配依据。
- 想按领域浏览：运行 `wtbp list --domain <domain>`，例如 `design`、`research` 或 `quality`。
- 已知 Skill 名称：运行 `wtbp show <skill-id>`，查看输入、输出、副作用、别名、路由和安装方式。
- 只在选中后读取对应的英文 `SKILL.md`；不要一次性加载全部 Skill。
EOF
}

case "${1:---check}" in
  --write)
    generate > "$output_file"
    ;;
  --check)
    diff -u "$output_file" <(generate)
    ;;
  *)
    printf '用法：generate-skill-catalog.sh [--check|--write]\n' >&2
    exit 2
    ;;
esac
