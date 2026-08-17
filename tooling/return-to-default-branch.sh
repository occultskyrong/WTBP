#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
remote_name="${1:-origin}"

fail() {
  printf '返回默认分支失败：%s\n' "$1" >&2
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

current_branch="$(repo_git branch --show-current)"
[[ -n "$current_branch" ]] || fail '当前不在本地分支上'

if [[ -n "$(repo_git status --porcelain)" ]]; then
  fail '工作区或暂存区存在未提交内容；不得自动切换分支'
fi

"$repo_root/tooling/sync-default-branch.sh" "$remote_name" || fail '无法刷新并同步默认分支'
base_ref="${remote_name}/${base_branch}"
repo_git rev-parse --verify "${base_ref}^{commit}" >/dev/null 2>&1 || fail "无法解析默认分支基线：$base_ref"

if [[ "$current_branch" == "$base_branch" ]]; then
  repo_git merge --ff-only "$base_ref" || fail "本地 ${base_branch} 无法快进到 ${base_ref}"
  printf '已位于并同步默认分支：%s\n' "$base_branch"
  exit 0
fi

remote_task_ref="refs/remotes/${remote_name}/${current_branch}"
repo_git rev-parse --verify "${remote_task_ref}^{commit}" >/dev/null 2>&1 || fail "任务分支尚未推送到 ${remote_name}/${current_branch}；保留当前分支"
local_head="$(repo_git rev-parse HEAD)"
remote_head="$(repo_git rev-parse "${remote_task_ref}^{commit}")"
[[ "$local_head" == "$remote_head" ]] || fail "任务分支 HEAD 尚未完整推送到 ${remote_name}/${current_branch}；保留当前分支"

base_worktree="$(repo_git worktree list --porcelain | awk -v target="refs/heads/${base_branch}" '
  /^worktree / { path = substr($0, 10) }
  $0 == "branch " target { print path; exit }
')"
if [[ -n "$base_worktree" ]]; then
  printf '未切换当前工作树：默认分支 %s 正由 %s 使用；请在该工作树继续同步默认分支。\n' "$base_branch" "$base_worktree"
  exit 0
fi

if repo_git show-ref --verify --quiet "refs/heads/${base_branch}"; then
  repo_git switch "$base_branch" || fail "无法切换到默认分支：$base_branch"
else
  repo_git switch --track -c "$base_branch" "$base_ref" || fail "无法创建并切换默认分支：$base_branch"
fi
repo_git merge --ff-only "$base_ref" || fail "本地 ${base_branch} 无法快进到 ${base_ref}"
printf '已在推送后切换并同步默认分支：%s\n' "$base_branch"
