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

index_has_skill() {
  local skill_id="$1"
  awk -v skill_id="$skill_id" '
    $0 == "  - id: " skill_id { found = 1; next }
    found && /^  - id: / { exit }
    END { exit(found ? 0 : 1) }
  ' "$repo_root/knowledge/skill-index.yaml"
}

index_status() {
  local skill_id="$1"
  awk -v skill_id="$skill_id" '
    $0 == "  - id: " skill_id { found = 1; next }
    found && /^    status: / { print $2; exit }
    found && /^  - id: / { exit }
  ' "$repo_root/knowledge/skill-index.yaml"
}

catalog_status() {
  local skill_id="$1"
  awk -v skill_id="$skill_id" '
    $0 == "  - id: " skill_id { found = 1; next }
    found && /^    status: / { print $2; exit }
    found && /^  - id: / { exit }
  ' "$repo_root/knowledge/catalog.yaml"
}

catalog_path() {
  local skill_id="$1"
  awk -v skill_id="$skill_id" '
    $0 == "  - id: " skill_id { found = 1; next }
    found && /^    path: / { print $2; exit }
    found && /^  - id: / { exit }
  ' "$repo_root/knowledge/catalog.yaml"
}

index_lists_route() {
  local skill_id="$1"
  local route_id="$2"
  awk -v skill_id="$skill_id" -v route_id="$route_id" '
    function contains(value, needle) {
      sub(/^\[/, "", value)
      sub(/\]$/, "", value)
      gsub(/[[:space:]]/, "", value)
      return ("," value ",") ~ ("," needle ",")
    }
    /^  - id: / { current = $3; next }
    current == skill_id && /^    route_ids: / { found = contains($2, route_id); exit }
    END { exit(found ? 0 : 1) }
  ' "$repo_root/knowledge/skill-index.yaml"
}

route_count=0
route_ids=()
separator=$'\034'
while IFS="$separator" read -r route_id skill_id source path status last_verified install source_url version commit skill_path permissions verify auto_install; do
  [[ -n "$route_id" ]] || continue
  route_count=$((route_count + 1))
  route_ids+=("$route_id")
  [[ "$route_id" =~ ^route\.[a-z0-9][a-z0-9.-]*$ ]] || fail "路由 ID 无效：$route_id"
  [[ "$skill_id" =~ ^[a-z0-9][a-z0-9-]*$ ]] || fail "路由 $route_id 的 skill_id 无效：$skill_id"
  [[ "$source" =~ ^(local|external)$ ]] || fail "路由 $route_id 的 source 必须是 local 或 external"
  [[ "$status" =~ ^(active|candidate|stale|deprecated)$ ]] || fail "路由 $route_id 的 status 无效：$status"
  [[ "$last_verified" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || fail "路由 $route_id 的 last_verified 无效"
  [[ -n "$install" ]] || fail "路由 $route_id 缺少 install"
  index_has_skill "$skill_id" || fail "路由 $route_id 的 Skill 未登记在 knowledge/skill-index.yaml：$skill_id"
  index_lists_route "$skill_id" "$route_id" || fail "路由 $route_id 未被 skill-index.yaml 的 $skill_id 引用"
  [[ "$(index_status "$skill_id")" == "$status" ]] || fail "路由 $route_id 的 status 与 skill-index.yaml 不一致"

  if [[ "$source" == local ]]; then
    [[ -n "$path" ]] || fail "本地路由 $route_id 缺少 path"
    [[ -f "$repo_root/$path/SKILL.md" ]] || fail "路由 $route_id 指向不存在的本地 Skill：$path"
    catalog_has_skill "$skill_id" || fail "路由 $route_id 的 Skill 未登记在 knowledge/catalog.yaml：$skill_id"
    [[ "$(catalog_path "$skill_id")" == "$path" ]] || fail "路由 $route_id 的 path 与 catalog 不一致"
    [[ "$(catalog_status "$skill_id")" == "$status" ]] || fail "路由 $route_id 的 status 与 knowledge/catalog.yaml 不一致"
  else
    [[ -n "$source_url" ]] || fail "外部路由 $route_id 缺少 source_url"
    [[ -n "$version" ]] || fail "外部路由 $route_id 缺少 version"
    [[ "$commit" =~ ^[0-9a-f]{40}$ ]] || fail "外部路由 $route_id 必须登记固定 40 位 commit"
    [[ "$skill_path" =~ ^[A-Za-z0-9._/-]+$ && "$skill_path" != /* && "$skill_path" != *..* ]] || fail "外部路由 $route_id 的 skill_path 必须是仓库内相对路径"
    [[ -n "$permissions" ]] || fail "外部路由 $route_id 缺少 permissions"
    [[ -n "$verify" ]] || fail "外部路由 $route_id 缺少 verify"
    [[ "$auto_install" =~ ^(true|false)$ ]] || fail "外部路由 $route_id 的 auto_install 必须是 true 或 false"
    if [[ "$auto_install" == true ]]; then
      [[ "$status" == active ]] || fail "自动安装路由 $route_id 必须为 active"
      [[ "$source_url" =~ ^https://github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+(\.git)?$ ]] || fail "自动安装路由 $route_id 只允许 GitHub HTTPS 地址"
    fi
  fi

done < <(awk -F': ' '
  function emit() { if (id != "") print id sep skill sep source sep path sep status sep last_verified sep install sep source_url sep version sep commit sep skill_path sep permissions sep verify sep auto_install }
  /^  - id: / { emit(); id = $2; skill = source = path = status = last_verified = install = source_url = version = commit = skill_path = permissions = verify = auto_install = ""; next }
  /^    skill_id: / { skill = $2 }
  /^    source: / { source = $2 }
  /^    path: / { path = $2 }
  /^    status: / { status = $2 }
  /^    last_verified: / { last_verified = $2 }
  /^    install: / { install = $2 }
  /^    source_url: / { source_url = $2 }
  /^    version: / { version = $2 }
  /^    commit: / { commit = $2 }
  /^    skill_path: / { skill_path = $2 }
  /^    permissions: / { permissions = $2 }
  /^    verify: / { verify = $2 }
  /^    auto_install: / { auto_install = $2 }
  END { emit() }
' sep="$separator" "$route_file")

while IFS=$'\t' read -r route_id keywords; do
  [[ -n "$route_id" ]] || continue
  [[ "$keywords" == \[*\] && "$keywords" != '[]' ]] || fail "路由 $route_id 的 keywords 必须是非空单行列表"
done < <(awk -F': ' '
  /^  - id: / { if (id != "") print id "\t" keywords; id = $2; keywords = ""; next }
  /^    keywords: / { keywords = $2 }
  END { if (id != "") print id "\t" keywords }
' "$route_file")

[[ "$route_count" -gt 0 ]] || fail 'skill-routes.yaml 至少需要一条路由'
duplicate_ids="$(printf '%s\n' "${route_ids[@]}" | sort | uniq -d)"
[[ -z "$duplicate_ids" ]] || fail "存在重复路由 ID：$duplicate_ids"
printf 'Skill 路由校验：通过（%s 条路由）\n' "$route_count"
