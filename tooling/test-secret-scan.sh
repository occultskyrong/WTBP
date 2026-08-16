#!/usr/bin/env bash
set -euo pipefail

repo_root="$(mktemp -d "${TMPDIR:-/tmp}/wtbp-secret-scan.XXXXXX")"
trap 'rm -rf "$repo_root"' EXIT
scanner="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scan-secrets.sh"

tmp_git() {
  env -u GIT_DIR -u GIT_WORK_TREE -u GIT_INDEX_FILE git -C "$repo_root" "$@"
}

tmp_scan() {
  env -u GIT_DIR -u GIT_WORK_TREE -u GIT_INDEX_FILE "$scanner" --repo-root "$repo_root"
}

tmp_git init -q
tmp_git config user.email test@example.invalid
tmp_git config user.name wtbp-test

printf '%s\n' 'safe example content' > "$repo_root/README.md"
tmp_git add README.md
tmp_scan

printf 'AKIA%016d\n' 1 > "$repo_root/credential.txt"
tmp_git add credential.txt
if tmp_scan >/dev/null 2>&1; then
  printf '敏感信息扫描测试失败：未拦截合成 AWS 访问密钥。\n' >&2
  exit 1
fi
printf '敏感信息扫描测试：正确拦截合成凭据\n'

tmp_git reset -q credential.txt
rm -f "$repo_root/credential.txt"
printf '%s\n' 'not a real credential' > "$repo_root/.env.local"
tmp_git add .env.local
if tmp_scan >/dev/null 2>&1; then
  printf '敏感信息扫描测试失败：未拦截高风险凭据文件名。\n' >&2
  exit 1
fi
printf '敏感信息扫描测试：正确拦截高风险凭据文件名\n'
tmp_git reset -q .env.local
rm -f "$repo_root/.env.local"
printf '%s\n' 'API_KEY=example_placeholder_value' > "$repo_root/.env.example"
tmp_git add .env.example
tmp_scan
printf '敏感信息扫描测试：通过\n'
