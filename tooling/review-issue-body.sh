#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf '用法：%s <GitHub 事件 JSON 文件>\n' "${0##*/}" >&2
  exit 2
}

event_path="${1:-${GITHUB_EVENT_PATH:-}}"
[[ -n "$event_path" && -f "$event_path" ]] || usage
command -v jq >/dev/null 2>&1 || {
  printf 'Issue 审查失败：缺少 jq。\n' >&2
  exit 2
}

title="$(jq -r '.issue.title // ""' "$event_path")"
body="$(jq -r '.issue.body // ""' "$event_path")"
failures=()

fail() {
  failures+=("$1")
}

section_text() {
  local heading="$1"
  printf '%s\n' "$body" | awk -v heading="$heading" '
    $0 == "### " heading { in_section = 1; next }
    in_section && /^### / { exit }
    in_section { print }
  '
}

clean_text() {
  sed -E '/^[[:space:]]*$/d; /^[[:space:]]*<!--.*-->[[:space:]]*$/d'
}

require_section() {
  local heading="$1"
  local value
  value="$(section_text "$heading" | clean_text)"
  [[ -n "$value" ]] || fail "章节“${heading}”不能为空"
}

require_section_match() {
  local heading="$1"
  local pattern="$2"
  local value
  value="$(section_text "$heading" | clean_text)"
  [[ "$value" =~ $pattern ]] || fail "章节“${heading}”缺少要求的信息"
}

require_checked() {
  local label="$1"
  printf '%s\n' "$body" | rg -q "^- \[[xX]\] ${label}$" || fail "必须确认：${label}"
}

case "$title" in
  '[实践]'*)
    template='实践提案'
    for heading in '问题与适用场景' '候选方案与取舍' '证据与参考实现' '建议的验证方法'; do
      require_section "$heading"
    done
    change_type="$(section_text '变更类型' | clean_text)"
    practice_id="$(section_text '建议的 Practice ID' | clean_text)"
    if [[ "$change_type" != '新增实践' && ! "$practice_id" =~ ^[a-z0-9-]+\.[a-z0-9-]+$ ]]; then
      fail '更新或废弃实践时，Practice ID 必须符合“领域.主题”格式'
    fi
    require_checked '我已说明该建议不应使用的条件。'
    require_checked '我已确认现有 Practice 是否已经覆盖该决策。'
    ;;
  '[证据]'*)
    template='证据修正'
    require_section '受影响的 Practice ID 或路径'
    require_section '证据与影响'
    require_section '建议的修正或验证方式'
    require_section_match '证据与影响' 'https?://|版本|访问日期|提交'
    ;;
  '[仓库]'*)
    template='仓库问题'
    for heading in '组件' '复现步骤' '预期行为' '实际行为与相关日志' '环境与复现信息'; do
      require_section "$heading"
    done
    ;;
  *)
    fail '标题必须保留 [实践]、[证据] 或 [仓库] 模板前缀，无法判断 Issue 类型'
    template='未知'
    ;;
esac

if [[ ${#failures[@]} -gt 0 ]]; then
  printf 'Issue 内容审查失败（模板：%s）：\n' "$template" >&2
  printf ' - %s\n' "${failures[@]}" >&2
  exit 1
fi

printf 'Issue 内容审查通过（模板：%s）。\n' "$template"
