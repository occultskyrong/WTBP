#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
route_file="$repo_root/knowledge/skill-routes.yaml"
skill_id="${1:-}"
separator=$'\034'

fail() {
  printf 'Skill 安装失败：%s\n' "$1" >&2
  exit 2
}

[[ -n "$skill_id" ]] || fail '必须提供已登记的 Skill ID'
[[ "$skill_id" =~ ^[a-z0-9][a-z0-9-]*$ ]] || fail "Skill ID 无效：$skill_id"
[[ -f "$route_file" ]] || fail '缺少 knowledge/skill-routes.yaml'

route="$(awk -v target="$skill_id" -v sep="$separator" '
  function emit() {
    if (registered_skill_id == target) print source sep status sep source_url sep version sep commit sep skill_path sep permissions sep verify sep auto_install
  }
  /^  - id: / { emit(); route_id = $3; registered_skill_id = source = status = source_url = version = commit = skill_path = permissions = verify = auto_install = ""; next }
  /^    skill_id: / { registered_skill_id = $2 }
  /^    source: / { source = $2 }
  /^    status: / { status = $2 }
  /^    source_url: / { source_url = $2 }
  /^    version: / { version = $2 }
  /^    commit: / { commit = $2 }
  /^    skill_path: / { skill_path = $2 }
  /^    permissions: / { permissions = $2 }
  /^    verify: / { verify = $2 }
  /^    auto_install: / { auto_install = $2 }
  END { emit() }
' "$route_file")"

[[ -n "$route" ]] || fail "未找到路由：$skill_id"
IFS="$separator" read -r source status source_url version commit skill_path permissions verify auto_install <<< "$route"

[[ "$source" == external ]] || fail "$skill_id 是本地 Skill，无需安装"
[[ "$status" == active ]] || fail "$skill_id 当前状态不允许安装：$status"
[[ "$source_url" =~ ^https://github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+(\.git)?$ ]] || fail '只允许登记 GitHub HTTPS 仓库地址'
[[ "$commit" =~ ^[0-9a-f]{40}$ ]] || fail '外部 Skill 必须登记固定的 40 位提交哈希'
[[ "$skill_path" =~ ^[A-Za-z0-9._/-]+$ && "$skill_path" != /* && "$skill_path" != *..* ]] || fail 'skill_path 必须是仓库内相对路径'
[[ -n "$version" && -n "$permissions" && -n "$verify" ]] || fail '外部 Skill 缺少版本、权限或验证声明'

store_root="${WTBP_SKILL_STORE:-$HOME/.local/share/wtbp/skills}"
install_root="$store_root/$skill_id/$commit"
skill_root="$install_root/$skill_path"

run_security_gate() {
  local candidate_root="$1"
  local security_report

  if ! security_report="$(bash "$repo_root/tooling/security-check.sh" "$candidate_root" --format json)"; then
    printf '安全校验报告（已脱敏）：\n%s\n' "$security_report" >&2
    fail '安全校验未通过，拒绝安装；阻断或人工复核项必须先处理'
  fi
  printf '安全校验通过：%s\n' "$candidate_root"
}

if [[ ! -d "$install_root" ]]; then
  mkdir -p "$(dirname "$install_root")"
  temporary_root="$(mktemp -d "$(dirname "$install_root")/.${skill_id}.${commit}.XXXXXX")"
  trap 'rm -rf "$temporary_root"' EXIT
  git clone --no-checkout "$source_url" "$temporary_root/repository"
  git -C "$temporary_root/repository" fetch --depth 1 origin "$commit"
  git -C "$temporary_root/repository" checkout --detach "$commit"
  [[ "$(git -C "$temporary_root/repository" rev-parse HEAD)" == "$commit" ]] || fail '下载内容与登记提交不一致'
  [[ -f "$temporary_root/repository/$skill_path/SKILL.md" ]] || fail '登记的 skill_path 不包含 SKILL.md'
  run_security_gate "$temporary_root/repository"
  mv "$temporary_root/repository" "$install_root"
  trap - EXIT
else
  [[ "$(git -C "$install_root" rev-parse HEAD 2>/dev/null)" == "$commit" ]] || fail '已安装内容与登记提交不一致'
  run_security_gate "$install_root"
fi

[[ -f "$skill_root/SKILL.md" ]] || fail '已安装内容不包含 SKILL.md'
rg -q '^---$' "$skill_root/SKILL.md" || fail 'SKILL.md 缺少 frontmatter'
rg -q '^name: [a-z0-9-]+$' "$skill_root/SKILL.md" || fail 'SKILL.md 缺少有效 name'

link_skill() {
  local link_path="$1"
  local link_dir
  local temporary_link

  link_dir="$(dirname "$link_path")"
  mkdir -p "$link_dir"
  if [[ -e "$link_path" || -L "$link_path" ]]; then
    [[ -L "$link_path" ]] || fail "目标已存在且不是受控链接：$link_path"
    current_target="$(readlink "$link_path")"
    if [[ "$current_target" == "$skill_root" ]]; then
      return
    fi
    [[ "$current_target" == "$store_root"/* ]] || fail "目标已指向非 WTBP 内容：$link_path"
  fi
  temporary_link="$link_path.wtbp-new"
  rm -f "$temporary_link"
  ln -s "$skill_root" "$temporary_link"
  mv -f "$temporary_link" "$link_path"
}

link_skill "$HOME/.codex/skills/$skill_id"
link_skill "$HOME/.claude/skills/$skill_id"

printf 'Skill 安装完成：%s %s（%s）\n' "$skill_id" "$version" "$commit"
printf '安装路径：%s\n' "$skill_root"
printf '验证要求：%s\n' "$verify"
