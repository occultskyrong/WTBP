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

assert_not_contains() {
  local output="$1"
  local unexpected="$2"
  [[ "$output" != *"$unexpected"* ]] || fail "输出不应包含：$unexpected"
}

resolve_source="$(sed -n '/^resolve_routes()/,/^case /p' "$router")"
[[ "$resolve_source" != *'install-skill.sh'* ]] || fail '候选查询不应直接安装外部 Skill'
help_output="$($router --help)"
assert_contains "$help_output" '候选查询不会自动安装、执行 Skill 或访问外部服务'

fallback_output="$($router "$query")"
assert_contains "$fallback_output" 'figma-evolve'
assert_contains "$fallback_output" '命中关键词：重新设计'
assert_contains "$fallback_output" '该命令不会替你执行 Skill'

case_insensitive_output="$($router 'Which SKILL should route this task?')"
assert_contains "$case_insensitive_output" 'skill-router'

external_list_output="$($router external)"
assert_contains "$external_list_output" 'figma-official-mcp'
assert_contains "$external_list_output" 'local-adapter'

external_show_output="$($router show figma-code-connect)"
assert_contains "$external_show_output" '采用方式：local-adapter'
assert_contains "$external_show_output" '权限边界：'
assert_contains "$external_show_output" 'URL：https://github.com/figma/code-connect'
assert_contains "$external_show_output" '质量证据：'
assert_contains "$external_show_output" '适用场景：'
assert_contains "$external_show_output" '典型 Case：'

external_query_output="$($router '为 Figma 组件建立 Code Connect 映射并落地到代码组件')"
assert_contains "$external_query_output" '可复用的外部能力候选'
assert_contains "$external_query_output" 'figma-code-connect'
assert_contains "$external_query_output" '不得运行 wtbp install'

excluded_external_output="$($router 'Figma 自动生成完整产品')"
assert_not_contains "$excluded_external_output" 'figma-code-connect'

scenario_query_output="$($router '已有 Figma 组件且需映射真实代码组件')"
assert_contains "$scenario_query_output" 'figma-code-connect'
assert_contains "$scenario_query_output" 'scenarios（'

case_query_output="$($router '核验 Figma 变体与 React 属性一致')"
assert_contains "$case_query_output" 'figma-code-connect'
assert_contains "$case_query_output" 'cases（'

online_discovery_output="$($router '为 Playwright 找 GitHub 上可复用的 Skill 或开源解决方案，并按分数排序')"
assert_contains "$online_discovery_output" 'external-capability-discovery'
assert_contains "$online_discovery_output" '命中关键词：GitHub, 开源, 解决方案'
assert_contains "$online_discovery_output" '该命令不会替你执行 Skill'

curation_output="$($router 'wtbp，收集这个 GitHub 项目，后续搜索时命中但不要安装')"
assert_contains "$curation_output" 'external-capability-curation'
assert_contains "$curation_output" '命中关键词：收集, GitHub 项目'
assert_contains "$curation_output" '该命令不会替你执行 Skill'

printf 'WTBP 路由测试：通过（前缀归一化、本地与外部能力候选、在线发现候选与当前会话语义边界）\n'
