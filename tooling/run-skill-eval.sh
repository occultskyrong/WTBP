#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_id="${1:?必须提供 Skill ID}"
eval_file="$repo_root/knowledge/evals/${skill_id}/EVAL.md"

"$repo_root/tooling/validate-skill-evals.sh"
[[ -f "$eval_file" ]] || { printf '不存在 Skill Eval：%s\n' "${eval_file#$repo_root/}" >&2; exit 1; }

runner="$(awk -F': ' '$1 == "runner" { print $2; exit }' "$eval_file")"
default_config="$repo_root/knowledge/evals/${skill_id}/skill-up/eval.yaml"
eval_config="${SKILL_EVAL_CONFIG:-$default_config}"

if [[ ! -f "$eval_config" ]]; then
  printf 'Skill %s 的评测契约已通过；尚未执行行为评测。\n' "$skill_id"
  printf '未找到 Runner 配置：%s\n' "$eval_config"
  printf '如需运行外部 Runner，请设置 SKILL_EVAL_CONFIG 指向其配置文件。\n'
  printf '当前声明的 Runner：%s\n' "$runner"
  exit 0
fi

case "$runner" in
  skill-up)
    skill_up_bin="${SKILL_UP_BIN:-}"
    if [[ -z "$skill_up_bin" ]]; then
      skill_up_bin="$(command -v skill-up || true)"
    fi
    [[ -n "$skill_up_bin" ]] || {
      printf '未找到 skill-up；请先安装 Runner，或改用受控的 SKILL_EVAL_CONFIG。\n' >&2
      exit 2
    }
    "$skill_up_bin" validate "$eval_config"
    if [[ "${SKILL_EVAL_DRY_RUN:-false}" == "true" ]]; then
      "$skill_up_bin" run "$eval_config" \
        --iteration "${SKILL_EVAL_RUNS:-3}" \
        --dry-run \
        -v
    else
      "$skill_up_bin" run "$eval_config" \
        --iteration "${SKILL_EVAL_RUNS:-3}" \
        --output-dir "${SKILL_EVAL_OUTPUT_DIR:-$repo_root/.wtbp-evals/$skill_id}" \
        --format junit
    fi
    ;;
  caliper)
    command -v caliper >/dev/null 2>&1 || {
      printf '未找到 caliper；请先安装 Runner，或改用受控的 SKILL_EVAL_CONFIG。\n' >&2
      exit 2
    }
    caliper run "$eval_config" --k "${SKILL_EVAL_RUNS:-3}" --baseline
    ;;
  *)
    printf '当前 Runner %s 没有内置执行适配器；请通过 SKILL_EVAL_CONFIG 提供受控命令。\n' "$runner" >&2
    exit 2
    ;;
esac
