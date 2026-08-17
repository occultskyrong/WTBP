#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

usage() {
  printf '用法：%s <type> <slug> [base-branch]\n' "${0##*/}" >&2
  printf '示例：%s docs branch-workflow\n' "${0##*/}" >&2
}

fail() {
  printf '创建任务分支失败：%s\n' "$1" >&2
  exit 1
}

[[ $# -ge 2 && $# -le 3 ]] || { usage; exit 2; }

branch_type="$1"
slug="$2"
base_branch="${3:-${WTBP_BASE_BRANCH:-master}}"

case "$branch_type" in
  feat|fix|docs|refactor|test|chore|ci|build|perf) ;;
  *) fail "type 不受支持：$branch_type" ;;
esac

[[ "$slug" =~ ^[a-z0-9][a-z0-9._-]*$ ]] || fail 'slug 只能包含小写字母、数字、点、下划线和连字符'
[[ "$base_branch" =~ ^[A-Za-z0-9._/-]+$ ]] || fail "base 分支名称无效：$base_branch"

git diff --quiet || fail '工作区存在未提交改动；请先处理当前任务，禁止自动 stash 或迁移改动'
git diff --cached --quiet || fail '暂存区存在未提交改动；请先处理当前任务，禁止自动 stash 或迁移改动'

current_branch="$(git branch --show-current)"
case "$current_branch" in
  master|main|"$base_branch") ;;
  *) fail "当前分支为 $current_branch；请先切换到默认分支 $base_branch，再创建新任务分支" ;;
esac

WTBP_BASE_BRANCH="$base_branch" "$repo_root/tooling/sync-default-branch.sh" origin || fail "无法同步默认分支 $base_branch"

base_ref="origin/$base_branch"
git rev-parse --verify "refs/remotes/$base_ref" >/dev/null 2>&1 || fail "找不到远端基线：$base_ref；请先同步远端分支"

date_code="$(date +%y%m%d)"
new_branch="${branch_type}/${date_code}_${slug}"
git show-ref --verify --quiet "refs/heads/$new_branch" && fail "本地分支已存在：$new_branch"
git show-ref --verify --quiet "refs/remotes/origin/$new_branch" && fail "远端分支已存在：origin/$new_branch"

git switch -c "$new_branch" "$base_ref"
printf '已创建任务分支：%s\n' "$new_branch"
printf '基线：%s\n' "$base_ref"
