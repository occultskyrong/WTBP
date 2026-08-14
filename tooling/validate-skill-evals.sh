#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  printf 'Skill 评测校验失败：%s\n' "$1" >&2
  exit 1
}

read_field() {
  local file="$1"
  local field="$2"
  awk -F': ' -v field="$field" '$1 == field { print $2; exit }' "$file"
}

catalog_has() {
  local id="$1"
  local path="$2"
  awk -v id="$id" -v path="$path" '
    $0 == "  - id: " id { found_id = 1; next }
    found_id && $0 == "    path: " path { found = 1; exit }
    found_id && /^  - id: / { exit }
    END { exit(found ? 0 : 1) }
  ' "$repo_root/knowledge/catalog.yaml"
}

count_indented_field() {
  local file="$1"
  local field="$2"
  awk -v field="$field" 'index($0, "    " field ":") == 1 { count++ } END { print count + 0 }' "$file"
}

validate_cases() {
  local file="$1"
  local skill_id="$2"
  [[ -f "$file" ]] || fail "缺少评测用例文件：${file#$repo_root/}"

  rg -q '^version: 1$' "$file" || fail "${file#$repo_root/} 必须声明 version: 1"
  rg -q "^skill_id: ${skill_id}$" "$file" || fail "${file#$repo_root/} 的 skill_id 必须为 ${skill_id}"
  rg -q '^baseline: (true|false)$' "$file" || fail "${file#$repo_root/} 必须声明 baseline"
  rg -q '^runs: [3-9][0-9]*$' "$file" || fail "${file#$repo_root/} 的 runs 至少为 3"

  local case_count
  case_count="$(awk '/^  - id: / { count++ } END { print count + 0 }' "$file")"
  [[ "$case_count" -ge 3 ]] || fail "${file#$repo_root/} 至少需要 3 个评测用例"

  local category
  for category in positive negative boundary; do
    rg -q "^    category: ${category}$" "$file" || fail "${file#$repo_root/} 缺少 ${category} 用例"
  done

  local field_count
  for field in category prompt expect_skill assertions; do
    field_count="$(count_indented_field "$file" "$field")"
    [[ "$field_count" -ge "$case_count" ]] || fail "${file#$repo_root/} 每个用例都必须包含 ${field}"
  done

  if awk '/^    expect_skill:/ { if ($2 != "true" && $2 != "false") bad = 1 } END { exit(bad ? 0 : 1) }' "$file"; then
    fail "${file#$repo_root/} 的 expect_skill 只能是 true 或 false"
  fi

  local duplicate_ids
  duplicate_ids="$(awk '/^  - id: / { print $3 }' "$file" | sort | uniq -d)"
  [[ -z "$duplicate_ids" ]] || fail "${file#$repo_root/} 存在重复用例 ID：${duplicate_ids}"
}

validate_eval() {
  local file="$1"
  local eval_dir="${file%/EVAL.md}"
  local eval_id
  local skill_id
  local status
  local runner
  local last_verified
  local field

  [[ -f "$file" ]] || fail "缺少 EVAL.md：${file#$repo_root/}"
  rg -q '^---$' "$file" || fail "${file#$repo_root/} 缺少 YAML frontmatter"
  for field in id skill status runner last_verified min_behavior_pass_rate; do
    rg -q "^${field}: .+" "$file" || fail "${file#$repo_root/} 缺少 frontmatter 字段：${field}"
  done

  eval_id="$(read_field "$file" id)"
  skill_id="$(read_field "$file" skill)"
  status="$(read_field "$file" status)"
  runner="$(read_field "$file" runner)"
  last_verified="$(read_field "$file" last_verified)"

  [[ "$eval_id" == "eval.${skill_id}" ]] || fail "${file#$repo_root/} 的 id 必须为 eval.${skill_id}"
  [[ "$eval_dir" == "$repo_root/knowledge/evals/${skill_id}" ]] || fail "${file#$repo_root/} 路径必须与 skill 对应"
  [[ -f "$repo_root/skills/${skill_id}/SKILL.md" ]] || fail "${file#$repo_root/} 指向不存在的 Skill：${skill_id}"
  [[ "$status" =~ ^(draft|candidate|approved|stale|deprecated)$ ]] || fail "${file#$repo_root/} 的 status 无效：${status}"
  [[ "$runner" =~ ^(skill-up|caliper|aws-skill-eval|internal|manual)$ ]] || fail "${file#$repo_root/} 的 runner 无效：${runner}"
  [[ "$last_verified" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || fail "${file#$repo_root/} 的 last_verified 必须为日期"
  minimum="$(read_field "$file" min_behavior_pass_rate)"
  awk -v value="$minimum" 'BEGIN { exit(value >= 0 && value <= 1 ? 0 : 1) }' || fail "${file#$repo_root/} 的 min_behavior_pass_rate 必须在 0 到 1 之间"
  if [[ "$runner" == "skill-up" ]]; then
    [[ -f "$eval_dir/skill-up/eval.yaml" ]] || fail "${file#$repo_root/} 声明 skill-up，但缺少 skill-up/eval.yaml"
    [[ -L "$repo_root/skills/${skill_id}/evals" ]] || fail "Skill ${skill_id} 缺少指向其原生 skill-up 评测配置的 evals 符号链接"
    [[ -f "$repo_root/skills/${skill_id}/evals/eval.yaml" ]] || fail "Skill ${skill_id} 的 evals/eval.yaml 不可用"
  fi

  for field in 评测目标 评测边界 用例与覆盖 判定标准 基线与重复运行 安全边界 验证命令; do
    rg -q "^## ${field}$" "$file" || fail "${file#$repo_root/} 缺少章节：${field}"
  done
  rg -q 'TODO|TBD|待补充|待确认' "$file" && fail "${file#$repo_root/} 不能包含未完成占位符"
  catalog_has "$eval_id" "knowledge/evals/${skill_id}" || fail "${file#$repo_root/} 未在 knowledge/catalog.yaml 登记"

  validate_cases "$eval_dir/cases.yaml" "$skill_id"
}

[[ -f "$repo_root/knowledge/catalog.yaml" ]] || fail '缺少 knowledge/catalog.yaml'
[[ -f "$repo_root/knowledge/schemas/eval-schema.yaml" ]] || fail '缺少 eval-schema.yaml'

skill_count=0
while IFS= read -r skill_file; do
  [[ -n "$skill_file" ]] || continue
  skill_count=$((skill_count + 1))
  skill_id="$(read_field "$skill_file" name)"
  [[ -n "$skill_id" ]] || fail "${skill_file#$repo_root/} 缺少 Skill name"
  eval_file="$repo_root/knowledge/evals/${skill_id}/EVAL.md"
  [[ -f "$eval_file" ]] || fail "Skill ${skill_id} 缺少对应 Eval：${eval_file#$repo_root/}"
done < <(rg --files "$repo_root/skills" -g 'SKILL.md' || true)

eval_count=0
while IFS= read -r eval_file; do
  [[ -n "$eval_file" ]] || continue
  eval_count=$((eval_count + 1))
  validate_eval "$eval_file"
done < <(rg --files "$repo_root/knowledge/evals" -g 'EVAL.md' || true)

printf 'Skill 评测契约校验：通过（Skill %s 个，Eval %s 个）\n' "$skill_count" "$eval_count"

skill_up_bin="${SKILL_UP_BIN:-}"
if [[ -z "$skill_up_bin" ]]; then
  skill_up_bin="$(command -v skill-up || true)"
fi
if [[ -n "$skill_up_bin" ]]; then
  while IFS= read -r config_file; do
    [[ -n "$config_file" ]] || continue
    skill_id="$(basename "$(dirname "$(dirname "$config_file")")")"
    "$skill_up_bin" validate "$repo_root/skills/${skill_id}/evals/eval.yaml"
  done < <(find "$repo_root/knowledge/evals" -path '*/skill-up/eval.yaml' -type f -print | sort)
fi
