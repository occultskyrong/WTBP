#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_file="$repo_root/knowledge/external-sources.yaml"
schema_file="$repo_root/knowledge/schemas/external-source-schema.yaml"
separator=$'\034'

fail() {
  printf '外部来源登记校验失败：%s\n' "$1" >&2
  exit 1
}

schema_value() {
  local field="$1"
  awk -F': ' -v field="$field" '$1 == field { print $2; exit }' "$schema_file"
}

enum_contains() {
  local value="$1"
  local allowed="$2"

  allowed="${allowed#[}"
  allowed="${allowed%]}"
  allowed="${allowed//[[:space:]]/}"
  [[ ",$allowed," == *",$value,"* ]]
}

require_unverified_reason() {
  local source_id="$1"
  local field="$2"
  local value="$3"

  [[ "$value" != unverified* || "$value" != unverified ]] || fail "$source_id 的 $field 为 unverified 时必须说明原因"
}

[[ -f "$source_file" ]] || fail '缺少 knowledge/external-sources.yaml'
[[ -f "$schema_file" ]] || fail '缺少 knowledge/schemas/external-source-schema.yaml'
rg -q '^version: 1$' "$source_file" || fail 'external-sources.yaml 必须声明 version: 1'
rg -q '^sources:$' "$source_file" || fail 'external-sources.yaml 缺少 sources'

trust_values="$(schema_value trust_values)"
adoption_values="$(schema_value adoption_values)"
ids=()
urls=()

while IFS="$separator" read -r source_id title kind url publisher trust accessed_on adoption scope credential_boundary license revision skill_path quality_evidence; do
  [[ -n "$source_id" ]] || continue
  ids+=("$source_id")
  urls+=("$url")
  [[ "$source_id" =~ ^source\.[a-z0-9][a-z0-9-]*$ ]] || fail "来源 ID 无效：$source_id"
  for value in "$title" "$kind" "$url" "$publisher" "$trust" "$accessed_on" "$adoption" "$scope" "$credential_boundary" "$license" "$revision" "$skill_path" "$quality_evidence"; do
    [[ -n "$value" ]] || fail "$source_id 缺少必填字段"
  done
  [[ "$url" =~ ^https://[^[:space:]?#]+$ && "$url" != */ ]] || fail "$source_id 的 URL 必须是无查询、片段或尾随斜杠的规范 HTTPS 地址"
  [[ "$publisher" =~ ^[a-z0-9][a-z0-9._-]*$ ]] || fail "$source_id 的 publisher 无效：$publisher"
  [[ "$accessed_on" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || fail "$source_id 的 accessed_on 必须是 YYYY-MM-DD"
  enum_contains "$trust" "$trust_values" || fail "$source_id 的 trust 无效：$trust"
  enum_contains "$adoption" "$adoption_values" || fail "$source_id 的 adoption 无效：$adoption"
  require_unverified_reason "$source_id" license "$license"
  require_unverified_reason "$source_id" revision "$revision"
  require_unverified_reason "$source_id" skill_path "$skill_path"
  require_unverified_reason "$source_id" quality_evidence "$quality_evidence"
done < <(awk -F': ' -v sep="$separator" '
  function emit() { if (id != "") print id sep title sep kind sep url sep publisher sep trust sep accessed_on sep adoption sep scope sep credential_boundary sep license sep revision sep skill_path sep quality_evidence }
  /^  - id: / { emit(); id = $2; title = kind = url = publisher = trust = accessed_on = adoption = scope = credential_boundary = license = revision = skill_path = quality_evidence = ""; next }
  /^    title: / { title = $2 }
  /^    kind: / { kind = $2 }
  /^    url: / { url = $2 }
  /^    publisher: / { publisher = $2 }
  /^    trust: / { trust = $2 }
  /^    accessed_on: / { accessed_on = $2 }
  /^    adoption: / { adoption = $2 }
  /^    scope: / { scope = $2 }
  /^    credential_boundary: / { credential_boundary = $2 }
  /^    license: / { license = $2 }
  /^    revision: / { revision = $2 }
  /^    skill_path: / { skill_path = $2 }
  /^    quality_evidence: / { quality_evidence = $2 }
  END { emit() }
' "$source_file")

[[ ${#ids[@]} -gt 0 ]] || fail 'external-sources.yaml 至少需要一项来源'
duplicate_ids="$(printf '%s\n' "${ids[@]}" | sort | uniq -d)"
duplicate_urls="$(printf '%s\n' "${urls[@]}" | sort | uniq -d)"
[[ -z "$duplicate_ids" ]] || fail "external-sources.yaml 存在重复 ID：$duplicate_ids"
[[ -z "$duplicate_urls" ]] || fail "external-sources.yaml 存在重复 URL：$duplicate_urls"
printf '外部来源登记校验：通过（来源 %s 项）\n' "${#ids[@]}"
