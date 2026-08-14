#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
router="$repo_root/tooling/wtbp"
query='重新调用wtbp技能，重新设计整个 Lingbox 的设计稿'
temporary_dir="$(mktemp -d)"
trap 'rm -rf "$temporary_dir"' EXIT

fail() {
  printf 'WTBP 路由测试失败：%s\n' "$1" >&2
  exit 1
}

assert_contains() {
  local output="$1"
  local expected="$2"
  [[ "$output" == *"$expected"* ]] || fail "输出缺少：$expected"
}

resolve_source="$(sed -n '/^resolve_routes()/,/^case /p' "$router")"
[[ "$resolve_source" != *'install-skill.sh'* ]] || fail '候选查询不应直接安装外部 Skill'
help_output="$($router --help)"
assert_contains "$help_output" '候选查询不会自动安装或执行 Skill'

fallback_output="$($router "$query")"
assert_contains "$fallback_output" 'figma-evolve'
assert_contains "$fallback_output" '命中关键词：重新设计'
assert_contains "$fallback_output" '该命令不会替你执行 Skill'

case_insensitive_output="$($router 'Which SKILL should route this task?')"
assert_contains "$case_insensitive_output" 'skill-router'

printf 'WTBP 路由测试：通过（前缀归一化、本地候选、当前会话语义边界）\n'
