#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bin_dir="${WTBP_BIN_DIR:-$HOME/.local/bin}"
target="$bin_dir/wtbp"
source="$repo_root/tooling/wtbp"

fail() {
  printf 'WTBP 命令安装失败：%s\n' "$1" >&2
  exit 2
}

mkdir -p "$bin_dir"
if [[ -e "$target" || -L "$target" ]]; then
  [[ -L "$target" ]] || fail "目标已存在且不是符号链接：$target"
  [[ "$(readlink "$target")" == "$source" ]] || fail "目标已指向其他命令：$target"
  printf 'WTBP 命令已可用：%s\n' "$target"
  exit 0
fi

ln -s "$source" "$target"
printf 'WTBP 命令安装完成：%s\n' "$target"
