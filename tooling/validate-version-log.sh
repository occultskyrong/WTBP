#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
version_file="$repo_root/VERSION"
log_file="$repo_root/CHANGELOG.md"

fail() {
  printf '版本日志校验失败：%s\n' "$1" >&2
  exit 1
}

[[ -f "$version_file" ]] || fail '缺少 VERSION'
[[ -f "$log_file" ]] || fail '缺少 CHANGELOG.md'

current_version="$(tr -d '[:space:]' < "$version_file")"
[[ "$current_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "VERSION 不是三段式：${current_version:-<empty>}"

rg -q '^# 版本日志$' "$log_file" || fail 'CHANGELOG.md 缺少“# 版本日志”标题'
rg -q '^## 当前任务分支（未提交）$' "$log_file" || fail 'CHANGELOG.md 缺少当前任务分支说明'
rg -q '^## 已合并主线（`master`；Tag 发布状态以 Tag 为准）$' "$log_file" || fail 'CHANGELOG.md 缺少已合并主线说明'
rg -q '^## 未合并任务线（不得作为其他任务分支的直接版本基线）$' "$log_file" || fail 'CHANGELOG.md 缺少未合并任务线说明'
rg -q "^### \[${current_version//./\\.}\] - " "$log_file" || fail "CHANGELOG.md 缺少当前 VERSION ${current_version} 的条目"

duplicate_versions="$(rg '^### \[[0-9]+\.[0-9]+\.[0-9]+\] - ' "$log_file" | sed -E 's/^### \[([^]]+)\].*/\1/' | sort | uniq -d)"
[[ -z "$duplicate_versions" ]] || fail "CHANGELOG.md 存在重复版本条目：${duplicate_versions}"

printf '版本日志校验：通过（当前版本 %s）\n' "$current_version"
