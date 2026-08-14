#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bin_dir="${WTBP_BIN_DIR:-$HOME/.local/bin}"
command_target="$bin_dir/wtbp"
command_source="$repo_root/tooling/wtbp"
codex_skill_dir="${WTBP_CODEX_SKILL_DIR:-$HOME/.codex/skills}"
codex_skill_target="$codex_skill_dir/wtbp"
codex_skill_source="$repo_root/skills/skill-router"

fail() {
  printf 'WTBP 命令安装失败：%s\n' "$1" >&2
  exit 2
}

link_managed_entry() {
  local target="$1"
  local source="$2"
  local label="$3"

  mkdir -p "$(dirname "$target")"
  if [[ -e "$target" || -L "$target" ]]; then
    [[ -L "$target" ]] || fail "$label 目标已存在且不是符号链接：$target"
    [[ "$(readlink "$target")" == "$source" ]] || fail "$label 目标已指向其他位置：$target"
    printf '%s 已可用：%s\n' "$label" "$target"
    return
  fi

  ln -s "$source" "$target"
  printf '%s 安装完成：%s\n' "$label" "$target"
}

[[ -f "$command_source" ]] || fail "缺少 WTBP 命令：$command_source"
[[ -f "$codex_skill_source/SKILL.md" ]] || fail "缺少 WTBP Codex 入口 Skill：$codex_skill_source/SKILL.md"

link_managed_entry "$command_target" "$command_source" 'WTBP 命令'
link_managed_entry "$codex_skill_target" "$codex_skill_source" 'WTBP Codex 入口 Skill'
