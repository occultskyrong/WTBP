#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
capability_file="$repo_root/knowledge/external-capabilities.yaml"
schema_file="$repo_root/knowledge/schemas/external-capability-schema.yaml"
source_file="$repo_root/knowledge/external-sources.yaml"
separator=$'\034'

fail() {
  printf '外部能力登记校验失败：%s\n' "$1" >&2
  exit 1
}

schema_value() {
  local field="$1"
  awk -F': ' -v field="$field" '$1 == field { print $2; exit }' "$schema_file"
}

list_contains_only() {
  local value="$1"
  local allowed="$2"
  local field="$3"
  local capability_id="$4"
  local item

  [[ "$value" == \[*\] && "$value" != '[]' ]] || fail "$capability_id 的 $field 必须是非空单行列表"
  value="${value#[}"
  value="${value%]}"
  allowed="${allowed#[}"
  allowed="${allowed%]}"
  allowed="${allowed//[[:space:]]/}"
  IFS=',' read -r -a items <<< "$value"
  for item in "${items[@]}"; do
    item="${item//[[:space:]]/}"
    [[ ",$allowed," == *",$item,"* ]] || fail "$capability_id 的 $field 包含未定义值：$item"
  done
}

enum_contains() {
  local value="$1"
  local allowed="$2"

  allowed="${allowed#[}"
  allowed="${allowed%]}"
  allowed="${allowed//[[:space:]]/}"
  [[ ",$allowed," == *",$value,"* ]]
}

source_exists() {
  local source_id="$1"
  rg -q "^  - id: ${source_id}$" "$source_file"
}

[[ -f "$capability_file" ]] || fail '缺少 knowledge/external-capabilities.yaml'
[[ -f "$schema_file" ]] || fail '缺少 knowledge/schemas/external-capability-schema.yaml'
[[ -f "$source_file" ]] || fail '缺少 knowledge/external-sources.yaml'
rg -q '^version: 1$' "$capability_file" || fail 'external-capabilities.yaml 必须声明 version: 1'
rg -q '^capabilities:$' "$capability_file" || fail 'external-capabilities.yaml 缺少 capabilities'

domains="$(schema_value domains)"
capabilities="$(schema_value capabilities)"
stages="$(schema_value stages)"
kinds="$(schema_value kinds)"
adoptions="$(schema_value adoption_values)"
availability_values="$(schema_value availability_values)"
statuses="$(schema_value status_values)"

ids=()
while IFS="$separator" read -r capability_id title summary source_id kind card_domains card_capabilities card_stages adoption availability permissions verify status keywords; do
  [[ -n "$capability_id" ]] || continue
  ids+=("$capability_id")
  [[ "$capability_id" =~ ^[a-z0-9][a-z0-9-]*$ ]] || fail "外部能力 ID 无效：$capability_id"
  for value in "$title" "$summary" "$source_id" "$permissions" "$verify"; do
    [[ -n "$value" ]] || fail "$capability_id 缺少必填说明字段"
  done
  source_exists "$source_id" || fail "$capability_id 引用了不存在的来源：$source_id"
  enum_contains "$kind" "$kinds" || fail "$capability_id 的 kind 无效：$kind"
  enum_contains "$adoption" "$adoptions" || fail "$capability_id 的 adoption 无效：$adoption"
  enum_contains "$availability" "$availability_values" || fail "$capability_id 的 availability 无效：$availability"
  enum_contains "$status" "$statuses" || fail "$capability_id 的 status 无效：$status"
  list_contains_only "$card_domains" "$domains" domains "$capability_id"
  list_contains_only "$card_capabilities" "$capabilities" capabilities "$capability_id"
  list_contains_only "$card_stages" "$stages" stages "$capability_id"
  [[ "$keywords" == \[*\] && "$keywords" != '[]' ]] || fail "$capability_id 的 keywords 必须是非空单行列表"
  [[ "$adoption" != direct-use || "$availability" == client-provided ]] || fail "$capability_id 的 direct-use 必须是 client-provided"
  [[ "$adoption" != manual-optional || "$availability" == manual-install ]] || fail "$capability_id 的 manual-optional 必须是 manual-install"
  [[ "$adoption" != reference-only || "$availability" == reference ]] || fail "$capability_id 的 reference-only 必须是 reference"
done < <(awk -F': ' -v sep="$separator" '
  function emit() { if (id != "") print id sep title sep summary sep source_id sep kind sep domains sep capabilities sep stages sep adoption sep availability sep permissions sep verify sep status sep keywords }
  /^  - id: / { emit(); id = $2; title = summary = source_id = kind = domains = capabilities = stages = adoption = availability = permissions = verify = status = keywords = ""; next }
  /^    title: / { title = $2 }
  /^    summary: / { summary = $2 }
  /^    source_id: / { source_id = $2 }
  /^    kind: / { kind = $2 }
  /^    domains: / { domains = $2 }
  /^    capabilities: / { capabilities = $2 }
  /^    stages: / { stages = $2 }
  /^    adoption: / { adoption = $2 }
  /^    availability: / { availability = $2 }
  /^    permissions: / { permissions = $2 }
  /^    verify: / { verify = $2 }
  /^    status: / { status = $2 }
  /^    keywords: / { keywords = $2 }
  END { emit() }
' "$capability_file")

[[ ${#ids[@]} -gt 0 ]] || fail 'external-capabilities.yaml 至少需要一项能力'
duplicates="$(printf '%s\n' "${ids[@]}" | sort | uniq -d)"
[[ -z "$duplicates" ]] || fail "external-capabilities.yaml 存在重复 ID：$duplicates"
printf '外部能力登记校验：通过（能力 %s 项）\n' "${#ids[@]}"
