#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

fail() { printf '版本 Tag 发布失败：%s\n' "$1" >&2; exit 1; }

commit_ref="${1:-HEAD}"
git rev-parse --verify "${commit_ref}^{commit}" >/dev/null || fail "无法解析提交：${commit_ref}"
commit_sha="$(git rev-parse "${commit_ref}^{commit}")"
current_version="$(git show "${commit_sha}:VERSION" 2>/dev/null | tr -d '[:space:]' || true)"
[[ "$current_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "提交 ${commit_sha} 的 VERSION 不是三段式版本：${current_version:-<empty>}"

if git rev-parse --verify "${commit_sha}^" >/dev/null 2>&1; then
  previous_version="$(git show "${commit_sha}^:VERSION" 2>/dev/null | tr -d '[:space:]' || true)"
else
  previous_version='0.0.0'
fi

if [[ "$current_version" == "$previous_version" ]]; then
  printf 'VERSION 未变化（%s），跳过 Tag 发布。\n' "$current_version"
  exit 0
fi

tag="v${current_version}"
remote='origin'
remote_refs="$(git ls-remote --tags "$remote" "refs/tags/${tag}" "refs/tags/${tag}^{}")"
existing_commit="$(printf '%s\n' "$remote_refs" | awk -v peeled="refs/tags/${tag}^{}" '$2 == peeled { print $1; exit }')"
if [[ -z "$existing_commit" ]]; then
  existing_commit="$(printf '%s\n' "$remote_refs" | awk -v direct="refs/tags/${tag}" '$2 == direct { print $1; exit }')"
fi

if [[ -n "$existing_commit" ]]; then
  [[ "$existing_commit" == "$commit_sha" ]] || fail "远端 Tag ${tag} 已指向 ${existing_commit}，不能移动或重打"
  printf '远端 Tag %s 已指向当前提交 %s，幂等通过。\n' "$tag" "$commit_sha"
  exit 0
fi

git show-ref --verify --quiet "refs/tags/${tag}" && fail "本地已存在 Tag ${tag}；请先核对其来源，禁止覆盖"
git config user.name 'github-actions[bot]'
git config user.email '41898282+github-actions[bot]@users.noreply.github.com'
git tag -a "$tag" "$commit_sha" -m "发布 ${tag}"
git push "$remote" "refs/tags/${tag}"
printf '已发布不可变 Tag %s -> %s（VERSION %s -> %s）。\n' "$tag" "$commit_sha" "$previous_version" "$current_version"
