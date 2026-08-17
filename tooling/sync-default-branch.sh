#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
remote_name="${1:-origin}"

fail() {
  printf '同步默认分支失败：%s\n' "$1" >&2
  exit 1
}

repo_git() {
  env -u GIT_DIR -u GIT_WORK_TREE -u GIT_INDEX_FILE -u GIT_COMMON_DIR git -C "$repo_root" "$@"
}

repo_git remote get-url "$remote_name" >/dev/null 2>&1 || fail "找不到远端：$remote_name"
base_branch="${WTBP_BASE_BRANCH:-}"
if [[ -z "$base_branch" ]]; then
  base_branch="$(repo_git symbolic-ref --quiet --short "refs/remotes/${remote_name}/HEAD" 2>/dev/null | sed "s#^${remote_name}/##" || true)"
fi
[[ -n "$base_branch" ]] || fail "无法确定 ${remote_name} 的默认分支；请设置 WTBP_BASE_BRANCH"

repo_git fetch --quiet "$remote_name" "$base_branch" || fail "无法刷新 ${remote_name}/${base_branch}；请检查网络和凭据后重试"
base_ref="${remote_name}/${base_branch}"
base_head="$(repo_git rev-parse --verify "${base_ref}^{commit}" 2>/dev/null)" || fail "无法解析默认分支基线：$base_ref"
current_branch="$(repo_git branch --show-current)"
[[ -n "$current_branch" ]] || fail '当前不在本地分支上'

if [[ "$current_branch" == "$base_branch" ]]; then
  [[ -z "$(repo_git status --porcelain)" ]] || fail "当前默认分支 ${base_branch} 存在未提交内容；不得自动 pull"
  repo_git merge --ff-only "$base_ref" || fail "本地 ${base_branch} 无法快进到 ${base_ref}"
  printf '已拉取并同步默认分支：%s\n' "$base_branch"
  exit 0
fi

base_worktree="$(repo_git worktree list --porcelain | awk -v target="refs/heads/${base_branch}" '
  /^worktree / { path = substr($0, 10) }
  $0 == "branch " target { print path; exit }
')"
if [[ -n "$base_worktree" ]]; then
  printf '已刷新 %s；本地默认分支 %s 正由 %s 使用，未跨工作树执行 pull。\n' "$base_ref" "$base_branch" "$base_worktree"
  exit 0
fi

if repo_git show-ref --verify --quiet "refs/heads/${base_branch}"; then
  local_head="$(repo_git rev-parse "refs/heads/${base_branch}")"
  repo_git merge-base --is-ancestor "$local_head" "$base_head" || fail "本地 ${base_branch} 与 ${base_ref} 已分叉；请在默认分支工作树人工解决"
  repo_git update-ref "refs/heads/${base_branch}" "$base_head" "$local_head"
else
  repo_git branch --track "$base_branch" "$base_ref" >/dev/null
fi

printf '已刷新远端并安全快进本地默认分支引用：%s -> %s\n' "$base_branch" "$base_ref"
