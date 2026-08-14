#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"
fail() { printf '提交执行清单失败：%s\n' "$1" >&2; exit 1; }

mode=staged
base_ref=''
head_ref=''
if [[ $# -eq 3 && "$1" == --range ]]; then
  mode=range
  base_ref="$2"
  head_ref="$3"
  git rev-parse --verify "${base_ref}^{tree}" >/dev/null || fail "无法解析基线：$base_ref"
  git rev-parse --verify "${head_ref}^{commit}" >/dev/null || fail "无法解析提交：$head_ref"
elif [[ $# -ne 0 ]]; then
  printf '用法：commit-checklist.sh [--range <base-tree-or-commit> <head-commit>]\n' >&2
  exit 2
fi

source_spec() { if [[ "$mode" == staged ]]; then printf ':%s\n' "$1"; else printf '%s:%s\n' "$head_ref" "$1"; fi; }
source_exists() { git cat-file -e "$(source_spec "$1")" 2>/dev/null; }
source_file() { git show "$(source_spec "$1")"; }

diff_names() {
  local filter="$1"
  if [[ "$mode" == range ]]; then
    git diff --name-only --diff-filter="$filter" "$base_ref" "$head_ref"
  elif git rev-parse --verify 'HEAD^{commit}' >/dev/null 2>&1; then
    git diff --cached --name-only --diff-filter="$filter"
  else
    empty_tree="$(git hash-object -t tree /dev/null)"
    git diff --cached "$empty_tree" --name-only --diff-filter="$filter"
  fi
}

changed_files=()
while IFS= read -r file; do
  [[ -n "$file" ]] && changed_files+=("$file")
done < <(diff_names ACMRD)
[[ ${#changed_files[@]} -gt 0 ]] || { printf '提交执行清单：跳过（没有变更）\n'; exit 0; }

printf '%s\n' '提交执行清单：1/5 仓库结构校验（make validate）'
make validate
printf '%s\n' '提交执行清单：2/5 内容审查'
if [[ "$mode" == staged ]]; then make review-staged; else make review-range BASE_SHA="$base_ref" HEAD_SHA="$head_ref"; fi

skill_ids=()
for file in "${changed_files[@]}"; do
  case "$file" in
    skills/*/SKILL.md)
      source_exists "$file" || continue
      skill_id="$(source_file "$file" | awk -F': ' '$1 == "name" { print $2; exit }')"
      [[ -n "$skill_id" ]] || fail "$file 无法读取 Skill name"
      skill_ids+=("$skill_id")
      ;;
  esac
done

printf '%s\n' '提交执行清单：3/5 Skill SKE 契约评测（默认 dry-run）'
skill_eval_runs="${SKILL_EVAL_RUNS:-3}"
[[ "$skill_eval_runs" =~ ^[3-9][0-9]*$ ]] || fail 'Skill 评测重复运行次数不得少于 3 次'
if [[ ${#skill_ids[@]} -eq 0 ]]; then
  printf '%s\n' '  - 无 Skill 变更，跳过'
else
  while IFS= read -r skill_id; do
    [[ -n "$skill_id" ]] || continue
    printf '  - 评测 Skill：%s\n' "$skill_id"
    output_dir="${SKILL_EVAL_OUTPUT_DIR:-$repo_root/.wtbp-evals/commit-checklist/$skill_id}"
    SKILL_EVAL_DRY_RUN="${SKILL_EVAL_DRY_RUN:-true}" SKILL_EVAL_RUNS="$skill_eval_runs" SKILL_EVAL_OUTPUT_DIR="$output_dir" make ske SKILL_ID="$skill_id"
  done < <(printf '%s\n' "${skill_ids[@]}" | sort -u)
fi

printf '%s\n' '提交执行清单：4/5 质量门禁'
if [[ ${#skill_ids[@]} -gt 0 ]]; then
  printf '  - 契约覆盖率：100%%；最少重复运行：%s 次\n' "$skill_eval_runs"
  if [[ "${WTBP_REQUIRE_BEHAVIOR_EVAL:-false}" == true || "${SKILL_EVAL_DRY_RUN:-true}" == false ]]; then
    printf '%s\n' '  - 行为评测：要求本次 report.xml 达到 EVAL.md 门槛'
    while IFS= read -r skill_id; do
      [[ -n "$skill_id" ]] || continue
      output_dir="${SKILL_EVAL_OUTPUT_DIR:-$repo_root/.wtbp-evals/commit-checklist/$skill_id}"
      report="$(rg --files "$output_dir" 2>/dev/null | rg '/report\.xml$' | sort | tail -1 || true)"
      [[ -n "$report" ]] || fail "Skill $skill_id 未找到本次行为评测 report.xml"
      total="$(rg -o 'tests="[0-9]+"' "$report" | sed -E 's/[^0-9]//g' | awk '{ n += $1 } END { print n + 0 }')"
      failures="$(rg -o 'failures="[0-9]+"' "$report" | sed -E 's/[^0-9]//g' | awk '{ n += $1 } END { print n + 0 }')"
      errors="$(rg -o 'errors="[0-9]+"' "$report" | sed -E 's/[^0-9]//g' | awk '{ n += $1 } END { print n + 0 }')"
      [[ "$total" -gt 0 ]] || fail "$report 没有可统计的测试用例"
      passed=$((total - failures - errors))
      rate="$(awk -v passed="$passed" -v total="$total" 'BEGIN { printf "%.4f", passed / total }')"
      minimum="$(source_file "knowledge/evals/${skill_id}/EVAL.md" | awk -F': ' '$1 == "min_behavior_pass_rate" { print $2; exit }')"
      [[ -n "$minimum" ]] || minimum=0.90
      if awk '
        /<testcase / { name = $0; sub(/^.*name="/, "", name); sub(/".*$/, "", name); bad = 0 }
        /<failure / && name ~ /(adversarial|security)/ { bad = 1 }
        /<\/testcase>/ { if (bad) exit 1; name = "" }
        END { exit(bad ? 1 : 0) }
      ' "$report"; then
        :
      else
        fail "Skill $skill_id 的对抗或安全用例失败，不能被总通过率抵消"
      fi
      awk -v rate="$rate" -v minimum="$minimum" 'BEGIN { exit(rate + 0.0000001 >= minimum ? 0 : 1) }' || fail "Skill $skill_id 行为通过率 ${rate} 未达到门槛 ${minimum}"
      printf '  - %s：通过率 %s（门槛 %s）\n' "$skill_id" "$rate" "$minimum"
    done < <(printf '%s\n' "${skill_ids[@]}" | sort -u)
  else
    printf '%s\n' '  - 行为通过率：未启用外部模型，仅完成契约 dry-run'
  fi
else
  printf '%s\n' '  - 无 Skill 变更，不执行行为门禁'
fi

read_version() { source_exists "$1" && source_file "$1" | tr -d '[:space:]'; }
parse_version() {
  [[ "$1" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]] || fail "版本不是三段式 MAJOR.MINOR.PATCH：$1"
  major="${BASH_REMATCH[1]}"; minor="${BASH_REMATCH[2]}"; patch="${BASH_REMATCH[3]}"
}
current_version="$(read_version VERSION)"
[[ -n "$current_version" ]] || fail '提交范围缺少 VERSION；请先暂存它'
if [[ "$mode" == range ]]; then
  base_version="$(git show "${base_ref}:VERSION" 2>/dev/null | tr -d '[:space:]' || printf '0.0.0')"
elif git rev-parse --verify 'HEAD^{commit}' >/dev/null 2>&1; then
  base_version="$(git show 'HEAD:VERSION' 2>/dev/null | tr -d '[:space:]' || printf '0.0.0')"
else
  base_version=0.0.0
fi
parse_version "$current_version"; current_major="$major"; current_minor="$minor"; current_patch="$patch"
parse_version "$base_version"; base_major="$major"; base_minor="$minor"; base_patch="$patch"

semantic_change=0
new_capability=0
for file in "${changed_files[@]}"; do
  case "$file" in
    skills/*/SKILL.md|knowledge/practices/*/PRACTICE.md|knowledge/evals/*/EVAL.md|knowledge/schemas/*|knowledge/catalog.yaml|knowledge/skill-index.yaml|knowledge/skill-routes.yaml|knowledge/relationships.yaml|knowledge/templates/*|tooling/*|.githooks/*|.github/*|Makefile|AGENTS.md|CLAUDE.md|CONTRIBUTING.md|docs/commit-conventions.md|docs/commit-checklist.md|docs/skill-evaluation.md|docs/skill-routing.md|docs/skill-catalog.md|docs/github-governance.md|docs/governance.md) semantic_change=1 ;;
  esac
done
while IFS= read -r file; do
  case "$file" in
    skills/*/SKILL.md|knowledge/practices/*/PRACTICE.md|knowledge/evals/*/EVAL.md) new_capability=1 ;;
  esac
done < <(diff_names A)

printf '%s\n' '提交执行清单：5/5 三段式版本检查'
if [[ "$base_version" == 0.0.0 && "$current_version" == 0.1.0 ]]; then
  printf '  - 初次建立 VERSION：%s\n' "$current_version"
elif [[ "$current_version" == "$base_version" ]]; then
  [[ "$semantic_change" -eq 0 ]] || fail '检测到对外规则或可复用内容变更，但 VERSION 未升级'
  printf '  - 仅微小变更，版本保持 %s\n' "$current_version"
else
    [[ "$semantic_change" -eq 1 ]] || fail "仅有微小变更时不得升级 VERSION（${base_version} -> ${current_version}）"
  if [[ "$current_major" -gt "$base_major" ]]; then
    [[ "$current_major" -eq $((base_major + 1)) && "$current_minor" -eq 0 && "$current_patch" -eq 0 ]] || fail 'MAJOR 版本必须只递增一级并归零 MINOR/PATCH'
    printf '  - MAJOR：%s -> %s（提交标题和正文必须说明不兼容变更）\n' "$base_version" "$current_version"
  elif [[ "$current_minor" -gt "$base_minor" ]]; then
    [[ "$current_major" -eq "$base_major" && "$current_minor" -eq $((base_minor + 1)) && "$current_patch" -eq 0 ]] || fail 'MINOR 版本必须只递增一级并归零 PATCH'
    [[ "$new_capability" -eq 1 ]] || fail 'MINOR 升级必须包含新增 Practice、Skill 或 Eval 等能力'
    printf '  - MINOR：%s -> %s\n' "$base_version" "$current_version"
  else
    [[ "$current_major" -eq "$base_major" && "$current_minor" -eq "$base_minor" && "$current_patch" -eq $((base_patch + 1)) ]] || fail 'PATCH 版本必须只递增一级'
    printf '  - PATCH：%s -> %s\n' "$base_version" "$current_version"
  fi
fi

printf '提交执行清单：通过（模式=%s，变更文件=%s）\n' "$mode" "${#changed_files[@]}"
