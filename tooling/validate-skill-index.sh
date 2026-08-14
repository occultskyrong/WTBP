#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
index_file="$repo_root/knowledge/skill-index.yaml"
schema_file="$repo_root/knowledge/schemas/skill-index-schema.yaml"
separator=$'\034'

fail() {
  printf 'Skill 能力索引校验失败：%s\n' "$1" >&2
  exit 1
}

read_taxonomy() {
  local field="$1"
  awk -F': ' -v field="$field" '$0 ~ "^  " field ": " { print $2; exit }' "$index_file"
}

list_contains_only() {
  local value="$1"
  local allowed="$2"
  local field="$3"
  local skill_id="$4"
  local item

  [[ "$value" == \[*\] && "$value" != '[]' ]] || fail "$skill_id 的 $field 必须是非空单行列表"
  value="${value#[}"
  value="${value%]}"
  allowed="${allowed#[}"
  allowed="${allowed%]}"
  allowed="${allowed//[[:space:]]/}"
  IFS=',' read -r -a items <<< "$value"
  for item in "${items[@]}"; do
    item="${item//[[:space:]]/}"
    [[ ",$allowed," == *",$item,"* ]] || fail "$skill_id 的 $field 包含未定义值：$item"
  done
}

catalog_field() {
  local skill_id="$1"
  local field="$2"
  awk -v skill_id="$skill_id" -v field="$field" '
    $0 == "  - id: " skill_id { found = 1; next }
    found && $0 ~ "^    " field ": " { sub("^    " field ": ", ""); print; exit }
    found && /^  - id: / { exit }
  ' "$repo_root/knowledge/catalog.yaml"
}

[[ -f "$index_file" ]] || fail '缺少 knowledge/skill-index.yaml'
[[ -f "$schema_file" ]] || fail '缺少 knowledge/schemas/skill-index-schema.yaml'
rg -q '^version: 1$' "$index_file" || fail 'skill-index.yaml 必须声明 version: 1'
rg -q '^skills:$' "$index_file" || fail 'skill-index.yaml 缺少 skills'

domains="$(read_taxonomy domains)"
capabilities="$(read_taxonomy capabilities)"
stages="$(read_taxonomy stages)"
side_effects="$(read_taxonomy side_effects)"
for field in domains capabilities stages side_effects; do
  value="$(read_taxonomy "$field")"
  schema_value="$(awk -F': ' -v field="$field" '$1 == field { print $2; exit }' "$schema_file")"
  [[ "$value" == "$schema_value" ]] || fail "taxonomy.$field 必须与模式一致"
done

index_ids=()
while IFS="$separator" read -r skill_id title summary skill_domains skill_capabilities skill_stages inputs outputs skill_side_effects status install aliases route_ids; do
  [[ -n "$skill_id" ]] || continue
  index_ids+=("$skill_id")
  [[ "$skill_id" =~ ^[a-z0-9][a-z0-9-]*$ ]] || fail "Skill ID 无效：$skill_id"
  for value in "$title" "$summary" "$inputs" "$outputs"; do
    [[ -n "$value" ]] || fail "$skill_id 缺少能力说明字段"
  done
  list_contains_only "$skill_domains" "$domains" domains "$skill_id"
  list_contains_only "$skill_capabilities" "$capabilities" capabilities "$skill_id"
  list_contains_only "$skill_stages" "$stages" stages "$skill_id"
  list_contains_only "$skill_side_effects" "$side_effects" side_effects "$skill_id"
  [[ "$install" =~ ^(builtin|managed-external)$ ]] || fail "$skill_id 的 install 无效：$install"
  [[ "$status" =~ ^(active|candidate|stale|deprecated)$ ]] || fail "$skill_id 的 status 无效：$status"
  [[ "$aliases" == \[*\] ]] || fail "$skill_id 的 aliases 必须是单行列表"
  [[ "$route_ids" == \[*\] && "$route_ids" != '[]' ]] || fail "$skill_id 的 route_ids 必须是非空单行列表"

  catalog_path="$(catalog_field "$skill_id" path)"
  catalog_status="$(catalog_field "$skill_id" status)"
  [[ -n "$catalog_path" ]] || fail "$skill_id 未登记在 knowledge/catalog.yaml"
  [[ -f "$repo_root/$catalog_path/SKILL.md" ]] || fail "$skill_id 的 catalog 路径不存在 SKILL.md"
  [[ "$catalog_status" == "$status" ]] || fail "$skill_id 的 status 与 catalog 不一致"

  route_values="${route_ids#[}"
  route_values="${route_values%]}"
  IFS=',' read -r -a route_items <<< "$route_values"
  for route_id in "${route_items[@]}"; do
    route_id="${route_id//[[:space:]]/}"
    rg -q "^  - id: ${route_id}$" "$repo_root/knowledge/skill-routes.yaml" || fail "$skill_id 引用不存在的路由：$route_id"
  done
done < <(awk -F': ' -v sep="$separator" '
  function emit() { if (id != "") print id sep title sep summary sep domains sep capabilities sep stages sep inputs sep outputs sep side_effects sep status sep install sep aliases sep route_ids }
  /^  - id: / { emit(); id = $2; title = summary = domains = capabilities = stages = inputs = outputs = side_effects = status = install = aliases = route_ids = ""; next }
  /^    title: / { title = $2 }
  /^    summary: / { summary = $2 }
  /^    domains: / { domains = $2 }
  /^    capabilities: / { capabilities = $2 }
  /^    stages: / { stages = $2 }
  /^    inputs: / { inputs = $2 }
  /^    outputs: / { outputs = $2 }
  /^    side_effects: / { side_effects = $2 }
  /^    status: / { status = $2 }
  /^    install: / { install = $2 }
  /^    aliases: / { aliases = $2 }
  /^    route_ids: / { route_ids = $2 }
  END { emit() }
' "$index_file")

[[ ${#index_ids[@]} -gt 0 ]] || fail 'skill-index.yaml 至少需要一个 Skill'
duplicate_ids="$(printf '%s\n' "${index_ids[@]}" | sort | uniq -d)"
[[ -z "$duplicate_ids" ]] || fail "skill-index.yaml 存在重复 ID：$duplicate_ids"

while IFS= read -r skill_file; do
  skill_id="$(awk -F': ' '$1 == "name" { print $2; exit }' "$skill_file")"
  printf '%s\n' "${index_ids[@]}" | rg -qx "$skill_id" || fail "Skill $skill_id 未登记在 skill-index.yaml"
done < <(rg --files "$repo_root/skills" -g 'SKILL.md')

printf 'Skill 能力索引校验：通过（Skill %s 个）\n' "${#index_ids[@]}"
