#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
git -C "$repo_root" rev-parse --show-toplevel >/dev/null
cd "$repo_root"

fail() {
  printf '审查失败：%s\n' "$1" >&2
  exit 1
}

usage() {
  cat >&2 <<'EOF'
用法：
  review-staged.sh
  review-staged.sh --range <base-tree-or-commit> <head-commit>
EOF
  exit 2
}

mode="staged"
base_ref=""
head_ref=""

if [[ $# -eq 0 ]]; then
  :
elif [[ $# -eq 3 && "$1" == "--range" ]]; then
  mode="range"
  base_ref="$2"
  head_ref="$3"
  git rev-parse --verify "${base_ref}^{tree}" >/dev/null
  git rev-parse --verify "${head_ref}^{commit}" >/dev/null
else
  usage
fi

source_spec() {
  local file="$1"
  if [[ "$mode" == "staged" ]]; then
    printf ':%s\n' "$file"
  else
    printf '%s:%s\n' "$head_ref" "$file"
  fi
}

source_file() {
  git show "$(source_spec "$1")"
}

source_exists() {
  git cat-file -e "$(source_spec "$1")" 2>/dev/null
}

source_files() {
  if [[ "$mode" == "staged" ]]; then
    git ls-files
  else
    git ls-tree -r --name-only "$head_ref"
  fi
}

changed_file_names() {
  if [[ "$mode" == "staged" ]]; then
    if git rev-parse --verify 'HEAD^{commit}' >/dev/null 2>&1; then
      git diff --cached --name-only --diff-filter=ACMRD
    else
      empty_tree="$(git hash-object -t tree /dev/null)"
      git diff --cached "$empty_tree" --name-only --diff-filter=ACMRD
    fi
  else
    git diff --name-only --diff-filter=ACMRD "$base_ref" "$head_ref"
  fi
}

check_patch_format() {
  if [[ "$mode" == "staged" ]]; then
    if git rev-parse --verify 'HEAD^{commit}' >/dev/null 2>&1; then
      git diff --cached --check
    else
      empty_tree="$(git hash-object -t tree /dev/null)"
      git diff --cached "$empty_tree" --check
    fi
  else
    git diff --check "$base_ref" "$head_ref"
  fi
}

require_source_field() {
  local file="$1"
  local field="$2"
  source_file "$file" | rg -q "^${field}: .+" || fail "$file 缺少 frontmatter 字段: $field"
}

require_source_section() {
  local file="$1"
  local section="$2"
  source_file "$file" | rg -q "^## ${section}$" || fail "$file 缺少章节: $section"
}

require_nonempty_source_section() {
  local file="$1"
  local section="$2"
  source_file "$file" | awk -v heading="## ${section}" '
    $0 == heading { in_section = 1; next }
    in_section && /^## / { exit }
    in_section && $0 !~ /^[[:space:]]*$/ { found = 1 }
    END { exit(found ? 0 : 1) }
  ' || fail "$file 的章节“${section}”不能为空"
}

source_field_value() {
  local file="$1"
  local field="$2"
  source_file "$file" | awk -F': ' -v field="$field" '$1 == field { print $2; exit }'
}

catalog_contains() {
  local id="$1"
  local path="$2"
  source_file knowledge/catalog.yaml | awk -v id="$id" -v path="$path" '
    $0 == "  - id: " id { candidate = 1; next }
    candidate && $0 == "    path: " path { found = 1 }
    candidate && /^  - id: / { candidate = 0 }
    END { exit(found ? 0 : 1) }
  '
}

practice_id_from_file() {
  source_field_value "$1" id
}

skill_name_from_file() {
  source_field_value "$1" name
}

eval_id_from_file() {
  source_field_value "$1" id
}

eval_skill_from_file() {
  source_field_value "$1" skill
}

implementation_root() {
  printf '%s\n' "$1" | awk -F/ 'NF >= 4 { print $1 "/" $2 "/" $3 }'
}

taxonomy_contains_domain() {
  local domain="$1"
  source_file knowledge/schemas/taxonomy.yaml | rg -q "^  - id: ${domain}$"
}

practice_schema_contains() {
  local field="$1"
  local value="$2"
  source_file knowledge/schemas/practice-schema.yaml | awk -v field="$field" '$1 == field ":" { print; exit }' | rg -Fq "$value"
}

check_practice() {
  local file="$1"
  local domain
  local practice_id
  local status
  local maturity
  local field

  for field in id title domain status maturity last_verified tags; do
    require_source_field "$file" "$field"
  done
  for field in 问题定义 适用场景 不适用场景 决策变量 候选方案 场景化推荐规则 反模式 验证方法 证据与来源; do
    require_source_section "$file" "$field"
  done
  source_file "$file" | rg -q 'TODO|TBD|待补充|待确认' && fail "$file 不能包含未完成占位符"

  domain="$(source_field_value "$file" domain)"
  practice_id="$(practice_id_from_file "$file")"
  status="$(source_field_value "$file" status)"
  maturity="$(source_field_value "$file" maturity)"
  [[ "$practice_id" == "${domain}."* ]] || fail "$file 的 id 必须以领域 ${domain}. 开头"
  taxonomy_contains_domain "$domain" || fail "$file 的 domain 未在 knowledge/schemas/taxonomy.yaml 中定义: $domain"
  practice_schema_contains status_values "$status" || fail "$file 的 status 未被 Practice 模式允许: $status"
  practice_schema_contains maturity_values "$maturity" || fail "$file 的 maturity 未被 Practice 模式允许: $maturity"
  catalog_contains "$practice_id" "${file%/PRACTICE.md}" || fail "$file 未在 knowledge/catalog.yaml 中登记正确路径"

  if [[ "$status" == "approved" ]]; then
    require_nonempty_source_section "$file" '证据与来源'
    require_nonempty_source_section "$file" '验证方法'
    source_file "$file" | rg -q '^last_verified: [0-9]{4}-[0-9]{2}-[0-9]{2}$' || fail "$file 的 approved 状态需要有效 last_verified 日期"
  fi
}

check_skill() {
  local file="$1"
  local skill_name
  local skill_dir

  require_source_field "$file" name
  require_source_field "$file" description
  source_file "$file" | rg -q '^---$' || fail "$file 缺少 YAML frontmatter 分隔符"
  source_file "$file" | rg -q 'TODO|TBD|待补充|待确认' && fail "$file 不能包含未完成占位符"

  skill_name="$(skill_name_from_file "$file")"
  skill_dir="${file%/SKILL.md}"
  [[ "${skill_dir##*/}" == "$skill_name" ]] || fail "$file 的目录名必须与 name 一致"
  catalog_contains "$skill_name" "$skill_dir" || fail "$file 未在 knowledge/catalog.yaml 中登记正确路径"
  for required_heading in 'Input Contract' 'Workflow' 'Output Contract' 'Completion Gate'; do
    source_file "$file" | rg -q "^## ${required_heading}$" || fail "$file 缺少统一契约章节: ## ${required_heading}"
  done
  source_file "$file" | rg -q '^## (Boundaries|Operating Boundaries|Change Rules|Design Evidence Gate|Evidence and Matrix Gate|Decision Rules|Figma Delivery Rules|Layout Provenance Gate)$' || fail "$file 缺少边界或门禁章节"
}

count_source_indented_field() {
  local file="$1"
  local field="$2"
  source_file "$file" | awk -v field="$field" 'index($0, "    " field ":") == 1 { count++ } END { print count + 0 }'
}

check_eval_cases() {
  local file="$1"
  local skill_name="$2"
  local case_count
  local field_count
  local category
  local duplicate_ids

  source_exists "$file" || fail "缺少评测用例文件: $file"
  source_file "$file" | rg -q '^version: 1$' || fail "$file 必须声明 version: 1"
  source_file "$file" | rg -q "^skill_id: ${skill_name}$" || fail "$file 的 skill_id 必须为 ${skill_name}"
  source_file "$file" | rg -q '^baseline: (true|false)$' || fail "$file 必须声明 baseline"
  source_file "$file" | rg -q '^runs: [3-9][0-9]*$' || fail "$file 的 runs 至少为 3"

  case_count="$(source_file "$file" | awk '/^  - id: / { count++ } END { print count + 0 }')"
  [[ "$case_count" -ge 3 ]] || fail "$file 至少需要 3 个评测用例"
  for category in positive negative boundary; do
    source_file "$file" | rg -q "^    category: ${category}$" || fail "$file 缺少 ${category} 用例"
  done
  for field in category prompt expect_skill assertions; do
    field_count="$(count_source_indented_field "$file" "$field")"
    [[ "$field_count" -ge "$case_count" ]] || fail "$file 每个用例都必须包含 ${field}"
  done
  if source_file "$file" | awk '/^    expect_skill:/ { if ($2 != "true" && $2 != "false") bad = 1 } END { exit(bad ? 0 : 1) }'; then
    fail "$file 的 expect_skill 只能是 true 或 false"
  fi
  duplicate_ids="$(source_file "$file" | awk '/^  - id: / { print $3 }' | sort | uniq -d)"
  [[ -z "$duplicate_ids" ]] || fail "$file 存在重复用例 ID: $duplicate_ids"
}

check_eval() {
  local file="$1"
  local eval_dir="${file%/EVAL.md}"
  local eval_id
  local skill_name
  local status
  local runner
  local last_verified
  local field

  for field in id skill status runner last_verified min_behavior_pass_rate; do
    require_source_field "$file" "$field"
  done
  source_file "$file" | rg -q '^---$' || fail "$file 缺少 YAML frontmatter 分隔符"
  eval_id="$(eval_id_from_file "$file")"
  skill_name="$(eval_skill_from_file "$file")"
  status="$(source_field_value "$file" status)"
  runner="$(source_field_value "$file" runner)"
  last_verified="$(source_field_value "$file" last_verified)"
  [[ "$eval_id" == "eval.${skill_name}" ]] || fail "$file 的 id 必须为 eval.${skill_name}"
  [[ "$eval_dir" == "knowledge/evals/${skill_name}" ]] || fail "$file 路径必须与 skill 对应"
  source_exists "skills/${skill_name}/SKILL.md" || fail "$file 指向不存在的 Skill: ${skill_name}"
  [[ "$status" =~ ^(draft|candidate|approved|stale|deprecated)$ ]] || fail "$file 的 status 无效: $status"
  [[ "$runner" =~ ^(skill-up|caliper|aws-skill-eval|internal|manual)$ ]] || fail "$file 的 runner 无效: $runner"
  [[ "$last_verified" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || fail "$file 的 last_verified 必须为日期"
  minimum_pass_rate="$(source_field_value "$file" min_behavior_pass_rate)"
  awk -v value="$minimum_pass_rate" 'BEGIN { exit(value >= 0 && value <= 1 ? 0 : 1) }' || fail "$file 的 min_behavior_pass_rate 必须在 0 到 1 之间"
  if [[ "$runner" == "skill-up" ]]; then
    source_exists "${eval_dir}/skill-up/eval.yaml" || fail "$file 声明 skill-up，但缺少 ${eval_dir}/skill-up/eval.yaml"
  fi
  for field in 评测目标 评测边界 用例与覆盖 判定标准 基线与重复运行 安全边界 验证命令; do
    require_source_section "$file" "$field"
  done
  source_file "$file" | rg -q 'TODO|TBD|待补充|待确认' && fail "$file 不能包含未完成占位符"
  catalog_contains "$eval_id" "$eval_dir" || fail "$file 未在 knowledge/catalog.yaml 中登记正确路径"
  check_eval_cases "${eval_dir}/cases.yaml" "$skill_name"
}

check_implementation() {
  local root="$1"
  local manifest="${root}/IMPLEMENTATION.md"
  local field

  source_exists "$manifest" || fail "$root 的参考实现必须包含 IMPLEMENTATION.md"
  for field in id practice status language_or_stack last_verified; do
    require_source_field "$manifest" "$field"
  done
  for field in 对应场景 前置条件 实现位置 验证方式 已知边界 关联证据; do
    require_source_section "$manifest" "$field"
  done
}

catalog_entries() {
  source_file knowledge/catalog.yaml | awk '
    /^(practices|skills|implementations|evals):/ { section = substr($1, 1, length($1) - 1); id = ""; next }
    /^  - id: / { id = $3; next }
    /^    path: / && section != "" && id != "" { print section "\t" id "\t" $2 }
  '
}

check_catalog_entry_targets() {
  local section
  local id
  local path
  local expected_file

  while IFS=$'\t' read -r section id path; do
    [[ -n "$section" && -n "$id" && -n "$path" ]] || fail 'knowledge/catalog.yaml 中的对象必须具有 id 和 path'
    case "$section" in
      practices) expected_file="${path}/PRACTICE.md" ;;
      skills) expected_file="${path}/SKILL.md" ;;
      implementations) expected_file="${path}/IMPLEMENTATION.md" ;;
      evals) expected_file="${path}/EVAL.md" ;;
      *) fail "knowledge/catalog.yaml 包含未知对象分类: $section" ;;
    esac
    source_exists "$expected_file" || fail "knowledge/catalog.yaml 指向不存在的对象: $expected_file"
  done < <(catalog_entries)
}

check_all_artifacts_cataloged() {
  local file
  local id

  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    id="$(practice_id_from_file "$file")"
    catalog_contains "$id" "${file%/PRACTICE.md}" || fail "$file 未在 knowledge/catalog.yaml 中登记正确路径"
  done < <(source_files | rg '^knowledge/practices/.+/PRACTICE\.md$' || true)

  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    id="$(skill_name_from_file "$file")"
    catalog_contains "$id" "${file%/SKILL.md}" || fail "$file 未在 knowledge/catalog.yaml 中登记正确路径"
  done < <(source_files | rg '^skills/.+/SKILL\.md$' || true)

  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    id="$(source_field_value "$file" id)"
    catalog_contains "$id" "${file%/IMPLEMENTATION.md}" || fail "$file 未在 knowledge/catalog.yaml 中登记正确路径"
  done < <(source_files | rg '^knowledge/implementations/.+/IMPLEMENTATION\.md$' || true)

  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    eval_id="$(eval_id_from_file "$file")"
    catalog_contains "$eval_id" "${file%/EVAL.md}" || fail "$file 未在 knowledge/catalog.yaml 中登记正确路径"
  done < <(source_files | rg '^knowledge/evals/[^/]+/EVAL\.md$' || true)
}

check_registry_and_contracts() {
  source_exists knowledge/catalog.yaml || fail '缺少 knowledge/catalog.yaml'
  source_file knowledge/catalog.yaml | rg -q 'TODO|TBD|待补充|待确认' && fail 'knowledge/catalog.yaml 不能包含未完成占位符'

  local duplicates
  duplicates="$(source_file knowledge/catalog.yaml | awk -F': ' '/^  - id: / { print $2 }' | sort | uniq -d)"
  [[ -z "$duplicates" ]] || fail "knowledge/catalog.yaml 存在重复 ID: $duplicates"

  local field
  for field in id title domain status maturity last_verified tags; do
    source_file knowledge/templates/practice-template.md | rg -q "^${field}:" || fail "Practice 模板缺少字段：$field"
  done
  for field in 问题定义 适用场景 不适用场景 决策变量 候选方案 场景化推荐规则 反模式 验证方法 证据与来源; do
    source_file knowledge/templates/practice-template.md | rg -q "^## ${field}$" || fail "Practice 模板缺少章节: $field"
  done

  check_catalog_entry_targets
  check_all_artifacts_cataloged
}

check_changed_skill_eval_pairs() {
  local file
  local skill_name
  local eval_file
  local eval_changed
  local changed

  for file in "${changed_files[@]}"; do
    case "$file" in
      skills/*/SKILL.md)
        source_exists "$file" || continue
        skill_name="$(skill_name_from_file "$file")"
        eval_file="knowledge/evals/${skill_name}/EVAL.md"
        source_exists "$eval_file" || fail "$file 必须配套 $eval_file"
        eval_changed=0
        for changed in "${changed_files[@]}"; do
          if [[ "$changed" == "knowledge/evals/${skill_name}"/* ]]; then
            eval_changed=1
            break
          fi
        done
        [[ "$eval_changed" -eq 1 ]] || fail "$file 修改时必须同步修改其 Eval"
        ;;
    esac
  done
}

changed_file_exists() {
  local expected="$1"
  local file

  for file in "${changed_files[@]}"; do
    [[ "$file" == "$expected" ]] && return 0
  done
  return 1
}

check_changed_ai_document_pairs() {
  local file
  local companion_file
  local canonical_file

  for file in "${changed_files[@]}"; do
    case "$file" in
      AGENTS.md|CLAUDE.md|knowledge/templates/skill-template/SKILL.md|skills/*/SKILL.md|skills/*/references/*.md)
        [[ "$file" == *.zh-CN.md ]] && continue
        companion_file="${file%.md}.zh-CN.md"
        changed_file_exists "$companion_file" || fail "$file 修改时必须同步修改中文对照：$companion_file"
        if source_exists "$file"; then
          source_exists "$companion_file" || fail "$file 的中文对照不存在：$companion_file"
        fi
        ;;
      AGENTS.zh-CN.md|CLAUDE.zh-CN.md|knowledge/templates/skill-template/SKILL.zh-CN.md|skills/*/SKILL.zh-CN.md|skills/*/references/*.zh-CN.md)
        canonical_file="${file%.zh-CN.md}.md"
        changed_file_exists "$canonical_file" || fail "$file 修改时必须同步修改英文规范源：$canonical_file"
        if source_exists "$file"; then
          source_exists "$canonical_file" || fail "$file 的英文规范源不存在：$canonical_file"
        fi
        ;;
    esac
  done
}

check_patch_format

changed_files=()
while IFS= read -r file; do
  [[ -n "$file" ]] && changed_files+=("$file")
done < <(changed_file_names)

if [[ ${#changed_files[@]} -eq 0 ]]; then
  printf 'WTBP 审查：跳过（没有变更文件）\n'
  exit 0
fi

for file in "${changed_files[@]}"; do
  case "$file" in
    .DS_Store|reports/*|coverage/*)
      fail "不允许提交生成产物: $file"
      ;;
    knowledge/practices/*/*/PRACTICE.md)
      source_exists "$file" && check_practice "$file"
      ;;
    skills/*/SKILL.md)
      source_exists "$file" && check_skill "$file"
      ;;
    knowledge/evals/*/EVAL.md)
      source_exists "$file" && check_eval "$file"
      ;;
    knowledge/evals/*/skill-up/eval.yaml)
      eval_file="${file%/skill-up/eval.yaml}/EVAL.md"
      source_exists "$eval_file" || fail "$file 必须配套 $eval_file"
      check_eval "$eval_file"
      ;;
  esac
done

implementation_roots=()
for file in "${changed_files[@]}"; do
  case "$file" in
    knowledge/implementations/*/*/*)
      root="$(implementation_root "$file")"
      [[ -n "$root" ]] && implementation_roots+=("$root")
      ;;
  esac
done

if [[ ${#implementation_roots[@]} -gt 0 ]]; then
  while IFS= read -r root; do
    [[ -n "$root" ]] && source_exists "$root" && check_implementation "$root"
  done < <(printf '%s\n' "${implementation_roots[@]}" | sort -u)
fi

check_registry_and_contracts
check_changed_skill_eval_pairs
check_changed_ai_document_pairs
printf 'WTBP 审查：通过（已审查 %s 个文件，模式=%s）\n' "${#changed_files[@]}" "$mode"
