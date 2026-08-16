#!/usr/bin/env bash
set -euo pipefail

# Git hooks export repository-local variables such as GIT_INDEX_FILE.  This
# test creates its own repository, so inherited values would make its `git add`
# commands mutate the caller's staging area instead of the temporary index.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_COMMON_DIR GIT_PREFIX

repo_root="$(mktemp -d "${TMPDIR:-/tmp}/wtbp-secret-scan.XXXXXX")"
trap 'rm -rf "$repo_root"' EXIT
scanner="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scan-secrets.sh"

git -C "$repo_root" init -q
git -C "$repo_root" config user.email test@example.invalid
git -C "$repo_root" config user.name wtbp-test

printf '%s\n' 'safe example content' > "$repo_root/README.md"
git -C "$repo_root" add README.md
"$scanner" --repo-root "$repo_root"

printf 'AKIA%016d\n' 1 > "$repo_root/credential.txt"
git -C "$repo_root" add credential.txt
if "$scanner" --repo-root "$repo_root" >/dev/null 2>&1; then
  printf '敏感信息扫描测试失败：未拦截合成 AWS 访问密钥。\n' >&2
  exit 1
fi
printf '敏感信息扫描测试：正确拦截合成凭据\n'

git -C "$repo_root" reset -q credential.txt
rm -f "$repo_root/credential.txt"
printf '%s\n' 'not a real credential' > "$repo_root/.env.local"
git -C "$repo_root" add .env.local
if "$scanner" --repo-root "$repo_root" >/dev/null 2>&1; then
  printf '敏感信息扫描测试失败：未拦截高风险凭据文件名。\n' >&2
  exit 1
fi
printf '敏感信息扫描测试：正确拦截高风险凭据文件名\n'
git -C "$repo_root" reset -q .env.local
rm -f "$repo_root/.env.local"
printf '%s\n' 'API_KEY=example_placeholder_value' > "$repo_root/.env.example"
git -C "$repo_root" add .env.example
"$scanner" --repo-root "$repo_root"
printf '敏感信息扫描测试：通过\n'
