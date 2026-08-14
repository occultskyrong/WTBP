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

printf '%s\n' '提交执行清单：1/6 仓库结构校验（make validate）'
make validate
printf '%s\n' '提交执行清单：2/6 内容审查'
if [[ "$mode" == staged ]]; then make review-staged; else make review-range BASE_SHA="$base_ref" HEAD_SHA="$head_ref"; fi

printf '%s\n' '提交执行清单：3/6 敏感信息与高风险文件扫描'
if [[ "$mode" == staged ]]; then
  "$repo_root/tooling/scan-secrets.sh"
else
  "$repo_root/tooling/scan-secrets.sh" --range "$base_ref" "$head_ref"
fi

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

printf '%s\n' '提交执行清单：4/6 Skill-Up 质量审查（默认 dry-run）'
skill_eval_runs="${SKILL_EVAL_RUNS:-3}"
[[ "$skill_eval_runs" =~ ^[3-9][0-9]*$ ]] || fail 'Skill 评测重复运行次数不得少于 3 次'
if [[ ${#skill_ids[@]} -eq 0 ]]; then
  printf '%s\n' '  - 无 Skill 变更，跳过'
else
  while IFS= read -r skill_id; do
    [[ -n "$skill_id" ]] || continue
    eval_file="knowledge/evals/${skill_id}/EVAL.md"
    eval_runner="$(source_file "$eval_file" | awk -F': ' '$1 == "runner" { print $2; exit }')"
    [[ "$eval_runner" == "skill-up" ]] || fail "变更 Skill ${skill_id} 必须使用 skill-up Runner，当前为 ${eval_runner:-未声明}"
    minimum_pass_rate="$(source_file "$eval_file" | awk -F': ' '$1 == "min_behavior_pass_rate" { print $2; exit }')"
    awk -v value="$minimum_pass_rate" 'BEGIN { exit(value >= 0.90 ? 0 : 1) }' || fail "Skill ${skill_id} 的行为通过率门槛不得低于 0.90"
    printf '  - 评测 Skill：%s\n' "$skill_id"
    output_dir="${SKILL_EVAL_OUTPUT_DIR:-$repo_root/.wtbp-evals/commit-checklist/$skill_id}"
    SKILL_EVAL_DRY_RUN="${SKILL_EVAL_DRY_RUN:-true}" SKILL_EVAL_RUNS="$skill_eval_runs" SKILL_EVAL_OUTPUT_DIR="$output_dir" make ske SKILL_ID="$skill_id"
  done < <(printf '%s\n' "${skill_ids[@]}" | sort -u)
fi

printf '%s\n' '提交执行清单：5/6 质量门禁'
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

is_semantic_path() {
  case "$1" in
    knowledge/*|skills/*|tooling/*|.githooks/*|.github/*|docs/commit-conventions.md|docs/commit-checklist.md|docs/document-language-policy.md|docs/skill-evaluation.md|docs/skill-routing.md|docs/skill-catalog.md|docs/github-governance.md|docs/governance.md|Makefile|README.md|AGENTS.md|CLAUDE.md|CONTRIBUTING.md) return 0 ;;
    *) return 1 ;;
  esac
}

is_new_capability_path() {
  case "$1" in
    skills/*/SKILL.md|knowledge/practices/*/PRACTICE.md|knowledge/evals/*/EVAL.md) return 0 ;;
    *) return 1 ;;
  esac
}

semantic_change=0
new_capability=0
for file in "${changed_files[@]}"; do
  is_semantic_path "$file" && semantic_change=1
done
while IFS= read -r file; do
  is_new_capability_path "$file" && new_capability=1
done < <(diff_names A)

check_range_version_history() {
  [[ "$mode" == range ]] || return 0
  git rev-parse --verify "${base_ref}^{commit}" >/dev/null 2>&1 || return 0

  local commit
  local previous_version="$base_version"
  local next_version
  local commit_semantic
  local commit_new_capability
  local changed_version
  local file
  local previous_major
  local previous_minor
  local previous_patch
  local next_major
  local next_minor
  local next_patch

  while IFS= read -r commit; do
    [[ -n "$commit" ]] || continue
    next_version="$(git show "${commit}:VERSION" 2>/dev/null | tr -d '[:space:]' || true)"
    parse_version "$previous_version"
    previous_major="$major"; previous_minor="$minor"; previous_patch="$patch"
    parse_version "$next_version"
    next_major="$major"; next_minor="$minor"; next_patch="$patch"

    commit_semantic=0
    commit_new_capability=0
    while IFS= read -r file; do
      is_semantic_path "$file" && commit_semantic=1
    done < <(git diff-tree --root --no-commit-id --name-only -r "$commit")
    while IFS= read -r file; do
      is_new_capability_path "$file" && commit_new_capability=1
    done < <(git diff-tree --root --no-commit-id --diff-filter=A --name-only -r "$commit")
    changed_version="$(git diff-tree --root --no-commit-id --name-only -r "$commit" -- VERSION)"

    if [[ -n "$changed_version" && "$next_version" == "$previous_version" ]]; then
      fail "提交 ${commit} 修改了 VERSION 但版本值未变化"
    fi
    if [[ "$commit_semantic" -eq 1 && "$next_version" == "$previous_version" ]]; then
      fail "提交 ${commit} 包含规范或可复用内容变更但未升级 VERSION"
    fi
    if [[ "$commit_semantic" -eq 0 && "$next_version" != "$previous_version" ]]; then
      fail "提交 ${commit} 升级了 VERSION 但没有对应的规范或可复用内容变更"
    fi

    if [[ "$next_version" != "$previous_version" ]]; then
      if [[ "$next_major" -gt "$previous_major" ]]; then
        [[ "$next_major" -eq $((previous_major + 1)) && "$next_minor" -eq 0 && "$next_patch" -eq 0 ]] || fail "提交 ${commit} 的 MAJOR 版本跳跃或未归零"
      elif [[ "$next_minor" -gt "$previous_minor" ]]; then
        [[ "$next_major" -eq "$previous_major" && "$next_minor" -eq $((previous_minor + 1)) && "$next_patch" -eq 0 && "$commit_new_capability" -eq 1 ]] || fail "提交 ${commit} 的 MINOR 版本必须只递增一级并包含新增能力"
      else
        [[ "$next_major" -eq "$previous_major" && "$next_minor" -eq "$previous_minor" && "$next_patch" -eq $((previous_patch + 1)) ]] || fail "提交 ${commit} 的 PATCH 版本必须只递增一级"
      fi
    fi
    previous_version="$next_version"
  done < <(git rev-list --reverse --no-merges "$base_ref..$head_ref")

  [[ "$previous_version" == "$current_version" ]] || fail "范围最终 VERSION 与 HEAD 不一致"
}

check_commit_messages() {
  [[ "$mode" == range ]] || return 0
  git rev-parse --verify "${base_ref}^{commit}" >/dev/null 2>&1 || return 0

  local commit
  local subject
  local body
  local changed_version
  local parent_commit
  local parent_major
  local commit_major
  while IFS= read -r commit; do
    [[ -n "$commit" ]] || continue
    subject="$(git show -s --format=%s "$commit")"
    case "$subject" in
      Merge\ *|Revert\ *) continue ;;
    esac
    [[ "$(printf '%s' "$subject" | wc -m | tr -d ' ')" -le 72 ]] || fail "提交 ${commit} 标题超过 72 个字符"
    printf '%s\n' "$subject" | LC_ALL=C grep -Eq '^(feat|fix|docs|refactor|test|chore|ci|build|perf)(\([a-z0-9][a-z0-9._/-]*\))?!?: [^[:space:]].*$' || fail "提交 ${commit} 标题不符合 Conventional Commits：${subject}"
    changed_version="$(git diff-tree --no-commit-id --name-only -r "$commit" -- VERSION)"
    parent_commit="$(git rev-list --parents -n 1 "$commit" | awk '{ print $2 }')"
    parent_major="$base_major"
    if [[ -n "$parent_commit" ]]; then
      parse_version "$(git show "${parent_commit}:VERSION" 2>/dev/null | tr -d '[:space:]' || printf '0.0.0')"
      parent_major="$major"
    fi
    parse_version "$(git show "${commit}:VERSION" 2>/dev/null | tr -d '[:space:]' || printf '0.0.0')"
    commit_major="$major"
    if [[ -n "$changed_version" && "$commit_major" -gt "$parent_major" ]]; then
      body="$(git show -s --format=%b "$commit")"
      if ! printf '%s\n' "$subject" | rg -q '^[a-z]+(\([a-z0-9][a-z0-9._/-]*\))?!:' && ! printf '%s\n' "$body" | rg -q '^BREAKING CHANGE:'; then
        fail "提交 ${commit} 引入 MAJOR 版本升级时必须使用 ! 或声明 BREAKING CHANGE"
      fi
    fi
  done < <(git rev-list --no-merges "$base_ref..$head_ref")
}

printf '%s\n' '提交执行清单：6/6 版本、提交消息与范围一致性检查'
if [[ "$mode" == range ]] && git rev-parse --verify "${base_ref}^{commit}" >/dev/null 2>&1; then
  check_range_version_history
  printf '  - 范围版本历史：通过（%s -> %s）\n' "$base_version" "$current_version"
else
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
fi

check_commit_messages

printf '提交执行清单：通过（模式=%s，变更文件=%s）\n' "$mode" "${#changed_files[@]}"
