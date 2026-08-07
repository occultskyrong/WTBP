#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
git -C "$repo_root" rev-parse --show-toplevel >/dev/null
cd "$repo_root"

fail() {
  printf 'REVIEW FAILED: %s\n' "$1" >&2
  exit 1
}

staged_file() {
  git show ":$1"
}

staged_exists() {
  git cat-file -e ":$1" 2>/dev/null
}

require_staged_field() {
  local file="$1"
  local field="$2"
  staged_file "$file" | rg -q "^${field}: .+" || fail "$file 缺少 frontmatter 字段: $field"
}

require_staged_section() {
  local file="$1"
  local section="$2"
  staged_file "$file" | rg -q "^## ${section}$" || fail "$file 缺少章节: $section"
}

require_nonempty_staged_section() {
  local file="$1"
  local section="$2"
  staged_file "$file" | awk -v heading="## ${section}" '
    $0 == heading { in_section = 1; next }
    in_section && /^## / { exit }
    in_section && $0 !~ /^[[:space:]]*$/ { found = 1 }
    END { exit(found ? 0 : 1) }
  ' || fail "$file 的章节“${section}”不能为空"
}

catalog_contains() {
  local id="$1"
  local path="$2"
  staged_file registry/catalog.yaml | awk -v id="$id" -v path="$path" '
    $0 == "  - id: " id { candidate = 1; next }
    candidate && $0 == "    path: " path { found = 1 }
    candidate && /^  - id: / { candidate = 0 }
    END { exit(found ? 0 : 1) }
  '
}

practice_id_from_file() {
  staged_file "$1" | awk -F': ' '/^id: / { print $2; exit }'
}

skill_name_from_file() {
  staged_file "$1" | awk -F': ' '/^name: / { print $2; exit }'
}

implementation_root() {
  printf '%s\n' "$1" | awk -F/ 'NF >= 4 { print $1 "/" $2 "/" $3 }'
}

check_practice() {
  local file="$1"
  local domain
  local practice_id
  local field

  for field in id title domain status maturity last_verified tags; do
    require_staged_field "$file" "$field"
  done
  for field in 问题定义 适用场景 决策变量 候选方案 场景化推荐规则 反模式 验证方法 证据与来源; do
    require_staged_section "$file" "$field"
  done
  staged_file "$file" | rg -q 'TODO|TBD|待补充|待确认' && fail "$file 不能包含未完成占位符"

  domain="$(printf '%s\n' "$file" | awk -F/ '{ print $2 }')"
  practice_id="$(practice_id_from_file "$file")"
  [[ "$practice_id" == "${domain}."* ]] || fail "$file 的 id 必须以领域 ${domain}. 开头"
  catalog_contains "$practice_id" "${file%/PRACTICE.md}" || fail "$file 未在 registry/catalog.yaml 中登记正确路径"

  if staged_file "$file" | rg -q '^status: approved$'; then
    require_nonempty_staged_section "$file" '证据与来源'
    require_nonempty_staged_section "$file" '验证方法'
    staged_file "$file" | rg -q '^last_verified: [0-9]{4}-[0-9]{2}-[0-9]{2}$' || fail "$file 的 approved 状态需要有效 last_verified 日期"
  fi
}

check_skill() {
  local file="$1"
  local skill_name
  local skill_dir

  require_staged_field "$file" name
  require_staged_field "$file" description
  staged_file "$file" | rg -q '^---$' || fail "$file 缺少 YAML frontmatter 分隔符"
  staged_file "$file" | rg -q 'TODO|TBD|待补充|待确认' && fail "$file 不能包含未完成占位符"

  skill_name="$(skill_name_from_file "$file")"
  skill_dir="${file%/SKILL.md}"
  [[ "${skill_dir##*/}" == "$skill_name" ]] || fail "$file 的目录名必须与 name 一致"
  catalog_contains "$skill_name" "$skill_dir" || fail "$file 未在 registry/catalog.yaml 中登记正确路径"
}

check_implementation() {
  local root="$1"
  local manifest="${root}/IMPLEMENTATION.md"
  local field

  staged_exists "$manifest" || fail "$root 的参考实现必须包含 IMPLEMENTATION.md"
  for field in id practice status language_or_stack last_verified; do
    require_staged_field "$manifest" "$field"
  done
  for field in 对应场景 前置条件 实现位置 验证方式 已知边界 关联证据; do
    require_staged_section "$manifest" "$field"
  done
}

check_registry_and_contracts() {
  staged_exists registry/catalog.yaml || fail '缺少 registry/catalog.yaml'
  staged_file registry/catalog.yaml | rg -q 'TODO|TBD|待补充|待确认' && fail 'registry/catalog.yaml 不能包含未完成占位符'

  local duplicates
  duplicates="$(staged_file registry/catalog.yaml | awk -F': ' '/^  - id: / { print $2 }' | sort | uniq -d)"
  [[ -z "$duplicates" ]] || fail "registry/catalog.yaml 存在重复 ID: $duplicates"

  local field
  for field in id title domain status maturity last_verified tags; do
    staged_file templates/practice-template.md | rg -q "^${field}:" || fail "Practice 模板缺少字段: $field"
  done
  for field in 问题定义 适用场景 决策变量 候选方案 场景化推荐规则 反模式 验证方法 证据与来源; do
    staged_file templates/practice-template.md | rg -q "^## ${field}$" || fail "Practice 模板缺少章节: $field"
  done
}

if git rev-parse --verify 'HEAD^{commit}' >/dev/null 2>&1; then
  diff_base=(--cached)
else
  empty_tree="$(git hash-object -t tree /dev/null)"
  diff_base=(--cached "$empty_tree")
fi

git diff "${diff_base[@]}" --check || fail '暂存内容包含空白或补丁格式问题'

changed_files=()
while IFS= read -r file; do
  [[ -n "$file" ]] && changed_files+=("$file")
done < <(git diff "${diff_base[@]}" --name-only --diff-filter=ACMR)

if [[ ${#changed_files[@]} -eq 0 ]]; then
  printf 'WTBP staged review: SKIPPED (no staged files)\n'
  exit 0
fi

for file in "${changed_files[@]}"; do
  case "$file" in
    .DS_Store|reports/*|coverage/*)
      fail "不允许提交生成产物: $file"
      ;;
    practices/*/PRACTICE.md)
      check_practice "$file"
      ;;
    skills/*/SKILL.md)
      check_skill "$file"
      ;;
  esac
done

implementation_roots=()
for file in "${changed_files[@]}"; do
  case "$file" in
    implementations/*/*/*)
      root="$(implementation_root "$file")"
      [[ -n "$root" ]] && implementation_roots+=("$root")
      ;;
  esac
done

if [[ ${#implementation_roots[@]} -gt 0 ]]; then
  while IFS= read -r root; do
    [[ -n "$root" ]] && check_implementation "$root"
  done < <(printf '%s\n' "${implementation_roots[@]}" | sort -u)
fi

check_registry_and_contracts
printf 'WTBP staged review: PASS (%s files reviewed)\n' "${#changed_files[@]}"
