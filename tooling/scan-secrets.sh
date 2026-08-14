#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
用法：
  scan-secrets.sh [--repo-root <path>]
  scan-secrets.sh --range <base-tree-or-commit> <head-commit> [--repo-root <path>]
EOF
  exit 2
}

repo_root=""
mode="staged"
base_ref=""
head_ref=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo-root)
      [[ $# -ge 2 ]] || usage
      repo_root="$2"
      shift 2
      ;;
    --range)
      [[ $# -ge 3 ]] || usage
      mode="range"
      base_ref="$2"
      head_ref="$3"
      shift 3
      ;;
    *) usage ;;
  esac
done

if [[ -z "$repo_root" ]]; then
  repo_root="$(git rev-parse --show-toplevel)"
else
  repo_root="$(cd "$repo_root" && pwd)"
fi

git -C "$repo_root" rev-parse --show-toplevel >/dev/null
if [[ "$mode" == "range" ]]; then
  git -C "$repo_root" rev-parse --verify "${base_ref}^{tree}" >/dev/null || {
    printf '敏感信息扫描失败：无法解析基线 %s\n' "$base_ref" >&2
    exit 1
  }
  git -C "$repo_root" rev-parse --verify "${head_ref}^{commit}" >/dev/null || {
    printf '敏感信息扫描失败：无法解析提交 %s\n' "$head_ref" >&2
    exit 1
  }
fi

changed_files() {
  if [[ "$mode" == "staged" ]]; then
    git -C "$repo_root" diff --cached --name-only --diff-filter=ACMR -z
  else
    git -C "$repo_root" diff --name-only --diff-filter=ACMR "$base_ref" "$head_ref" -z
  fi
}

file_diff() {
  local file="$1"
  if [[ "$mode" == "staged" ]]; then
    git -C "$repo_root" diff --cached --unified=0 --diff-filter=ACMR -- "$file"
  else
    git -C "$repo_root" diff --unified=0 --diff-filter=ACMR "$base_ref" "$head_ref" -- "$file"
  fi
}

is_example_path() {
  local basename_value="$1"
  case "$basename_value" in
    .env.example|.env.sample|.env.template|*.example|*.sample|*.template) return 0 ;;
    *) return 1 ;;
  esac
}

is_sensitive_path() {
  local file="$1"
  local basename_value
  basename_value="${file##*/}"
  basename_value="$(printf '%s' "$basename_value" | tr '[:upper:]' '[:lower:]')"

  if is_example_path "$basename_value"; then
    return 1
  fi
  case "$basename_value" in
    .env|.env.*|*.pem|*.key|*.p12|*.pfx|*.jks|*.keystore|id_rsa|id_rsa.*|id_ed25519|id_ed25519.*|credentials*.json|service-account*.json)
      return 0
      ;;
    *) return 1 ;;
  esac
}

placeholder_pattern='(?i)(example|sample|placeholder|dummy|fake|changeme|replace[-_ ]?me|your[-_ ]|<[^>]+>|\$\{|\{\{|\}\}|redacted|not[-_ ]?a[-_ ]?secret)'
generic_secret_pattern="(?i)(api[_-]?key|access[_-]?token|auth[_-]?token|client[_-]?secret|private[_-]?key|password|passwd|secret)[[:space:]]*[:=][[:space:]]*[\"'][A-Za-z0-9][A-Za-z0-9_./+=:-]{15,}[\"']?"

findings=()
while IFS= read -r -d '' file; do
  if is_sensitive_path "$file"; then
    findings+=("$file：文件名属于高风险凭据文件")
  fi

  diff_output="$(file_diff "$file")"
  if printf '%s\n' "$diff_output" | rg -q '^Binary files '; then
    findings+=("$file：二进制变更无法由文本扫描器验证")
    continue
  fi

  added_lines="$(printf '%s\n' "$diff_output" | awk '/^\+\+\+ / { next } /^\+/ { print substr($0, 2) }')"
  [[ -n "$added_lines" ]] || continue

  check_pattern() {
    local file_name="$1"
    local label="$2"
    local pattern="$3"
    if printf '%s\n' "$added_lines" | rg --pcre2 -n -- "$pattern" >/dev/null; then
      findings+=("${file_name}：新增内容命中${label}")
    fi
  }

  check_pattern "$file" 'PEM/私钥材料' '-----BEGIN [A-Z0-9 ]*PRIVATE KEY-----'
  check_pattern "$file" 'AWS 访问密钥' '\b(AKIA|ASIA)[0-9A-Z]{16}\b'
  check_pattern "$file" 'GitHub Token' '\b(gh[pousr]_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]{20,})\b'
  check_pattern "$file" 'Slack Token' '\bxox[baprs]-[0-9A-Za-z-]{20,}\b'
  check_pattern "$file" 'Google API Key' '\bAIza[0-9A-Za-z_-]{35}\b'
  check_pattern "$file" 'JWT' '\beyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\b'
  check_pattern "$file" '带凭据的连接串' '\bhttps?://[^[:space:]/:@]+:[^[:space:]/@]{8,}@'

  if printf '%s\n' "$added_lines" \
    | rg --pcre2 -n -- "$generic_secret_pattern" \
    | rg --pcre2 -v -- "$placeholder_pattern" >/dev/null; then
    findings+=("$file：新增内容命中疑似密钥/密码赋值")
  fi
done < <(changed_files)

if [[ ${#findings[@]} -gt 0 ]]; then
  printf '%s\n' '敏感信息扫描失败：发现可能提交的凭据或未验证的高风险文件。' >&2
  printf '  - %s\n' "${findings[@]}" >&2
  printf '%s\n' '请删除敏感内容、改用环境变量或将示例值明确标记为 example/sample 后重新暂存。' >&2
  exit 1
fi

printf '敏感信息扫描：通过（模式=%s）\n' "$mode"
