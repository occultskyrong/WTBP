#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
remote_name="${1:-origin}"

fail() {
  printf '可合并性预检失败：%s\n' "$1" >&2
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
[[ -n "$current_branch" ]] || fail '当前不在可提交的本地分支上'
if [[ "$current_branch" == "$base_branch" ]]; then
  printf '可合并性预检：跳过（当前为默认分支 %s）\n' "$base_branch"
  exit 0
fi

repo_git fetch --quiet "$remote_name" "$base_branch" || fail "无法刷新 ${remote_name}/${base_branch}；请检查网络和凭据后重试"
base_ref="${remote_name}/${base_branch}"
repo_git rev-parse --verify "${base_ref}^{commit}" >/dev/null 2>&1 || fail "无法解析默认分支基线：$base_ref"

set +e
merge_output="$(repo_git merge-tree --write-tree "$base_ref" HEAD 2>&1)"
merge_status=$?
set -e
case "$merge_status" in
  0)
    printf '可合并性预检：通过（%s 可与最新 %s 合并）\n' "$current_branch" "$base_ref"
    ;;
  1)
    fail "任务分支与最新 ${base_ref} 存在冲突；请先合并并解决冲突后再提交或推送"
    ;;
  *)
    fail "无法检查 ${base_ref} 的合并性：${merge_output}"
    ;;
esac
