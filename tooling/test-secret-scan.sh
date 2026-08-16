#!/usr/bin/env bash
set -euo pipefail

repo_root="$(mktemp -d "${TMPDIR:-/tmp}/wtbp-secret-scan.XXXXXX")"
trap 'rm -rf "$repo_root"' EXIT
scanner="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scan-secrets.sh"

test_git() {
  env -u GIT_DIR -u GIT_WORK_TREE -u GIT_INDEX_FILE -u GIT_COMMON_DIR git -C "$repo_root" "$@"
}

test_scan() {
  env -u GIT_DIR -u GIT_WORK_TREE -u GIT_INDEX_FILE -u GIT_COMMON_DIR "$scanner" --repo-root "$repo_root"
}

test_git init -q
test_git config user.email test@example.invalid
test_git config user.name wtbp-test

printf '%s\n' 'safe example content' > "$repo_root/README.md"
test_git add README.md
test_scan

printf 'AKIA%016d\n' 1 > "$repo_root/credential.txt"
test_git add credential.txt
if test_scan >/dev/null 2>&1; then
  printf '敏感信息扫描测试失败：未拦截合成 AWS 访问密钥。\n' >&2
  exit 1
fi
printf '敏感信息扫描测试：正确拦截合成凭据\n'

test_git reset -q credential.txt
rm -f "$repo_root/credential.txt"
printf '%s\n' 'not a real credential' > "$repo_root/.env.local"
test_git add .env.local
if test_scan >/dev/null 2>&1; then
  printf '敏感信息扫描测试失败：未拦截高风险凭据文件名。\n' >&2
  exit 1
fi
printf '敏感信息扫描测试：正确拦截高风险凭据文件名\n'
test_git reset -q .env.local
rm -f "$repo_root/.env.local"
printf '%s\n' 'API_KEY=example_placeholder_value' > "$repo_root/.env.example"
test_git add .env.example
test_scan
printf '敏感信息扫描测试：通过\n'
