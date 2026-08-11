#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
route_file="$repo_root/knowledge/skill-routes.yaml"

fail() {
  printf 'Skill 路由校验失败：%s\n' "$1" >&2
  exit 1
}

[[ -f "$route_file" ]] || fail '缺少 knowledge/skill-routes.yaml'
rg -q '^version: 1$' "$route_file" || fail 'skill-routes.yaml 必须声明 version: 1'
rg -q '^routes:$' "$route_file" || fail 'skill-routes.yaml 缺少 routes'

catalog_has_skill() {
  local skill_id="$1"
  awk -v skill_id="$skill_id" '
    $0 == "  - id: " skill_id { found = 1; next }
    found && /^  - id: / { exit }
    END { exit(found ? 0 : 1) }
  ' "$repo_root/knowledge/catalog.yaml"
}

route_count=0
route_ids=()
while IFS=$'\t' read -r route_id skill_id source path status last_verified install source_url version permissions verify; do
  [[ -n "$route_id" ]] || continue
  route_count=$((route_count + 1))
  route_ids+=("$route_id")
  [[ "$route_id" =~ ^route\.[a-z0-9][a-z0-9.-]*$ ]] || fail "路由 ID 无效：$route_id"
  [[ "$skill_id" =~ ^[a-z0-9][a-z0-9-]*$ ]] || fail "路由 $route_id 的 skill_id 无效：$skill_id"
  [[ "$source" =~ ^(local|external)$ ]] || fail "路由 $route_id 的 source 必须是 local 或 external"
  [[ "$status" =~ ^(active|candidate|stale|deprecated)$ ]] || fail "路由 $route_id 的 status 无效：$status"
  [[ "$last_verified" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || fail "路由 $route_id 的 last_verified 无效"
  [[ -n "$install" ]] || fail "路由 $route_id 缺少 install"

  if [[ "$source" == local ]]; then
    [[ -n "$path" ]] || fail "本地路由 $route_id 缺少 path"
    [[ -f "$repo_root/$path/SKILL.md" ]] || fail "路由 $route_id 指向不存在的本地 Skill：$path"
    catalog_has_skill "$skill_id" || fail "路由 $route_id 的 Skill 未登记在 knowledge/catalog.yaml：$skill_id"
  else
    [[ -n "$source_url" ]] || fail "外部路由 $route_id 缺少 source_url"
    [[ -n "$version" ]] || fail "外部路由 $route_id 缺少 version"
    [[ -n "$permissions" ]] || fail "外部路由 $route_id 缺少 permissions"
    [[ -n "$verify" ]] || fail "外部路由 $route_id 缺少 verify"
  fi

done < <(awk -F': ' '
  /^  - id: / { if (id != "") print id "\t" skill "\t" source "\t" path "\t" status "\t" last_verified "\t" install "\t" source_url "\t" version "\t" permissions "\t" verify; id = $2; skill = source = path = status = last_verified = install = source_url = version = permissions = verify = ""; next }
  /^    skill_id: / { skill = $2 }
  /^    source: / { source = $2 }
  /^    path: / { path = $2 }
  /^    status: / { status = $2 }
  /^    last_verified: / { last_verified = $2 }
  /^    install: / { install = $2 }
  /^    source_url: / { source_url = $2 }
  /^    version: / { version = $2 }
  /^    permissions: / { permissions = $2 }
  /^    verify: / { verify = $2 }
  END { if (id != "") print id "\t" skill "\t" source "\t" path "\t" status "\t" last_verified "\t" install "\t" source_url "\t" version "\t" permissions "\t" verify }
' "$route_file")

[[ "$route_count" -gt 0 ]] || fail 'skill-routes.yaml 至少需要一条路由'
duplicate_ids="$(printf '%s\n' "${route_ids[@]}" | sort | uniq -d)"
[[ -z "$duplicate_ids" ]] || fail "存在重复路由 ID：$duplicate_ids"
printf 'Skill 路由校验：通过（%s 条路由）\n' "$route_count"
