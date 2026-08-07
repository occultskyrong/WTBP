#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
required_paths=(
  "README.md"
  "CONTRIBUTING.md"
  "ontology/taxonomy.yaml"
  "ontology/context-schema.yaml"
  "ontology/practice-schema.yaml"
  "ontology/relationship-schema.yaml"
  "registry/catalog.yaml"
  "registry/relationships.yaml"
  "registry/external-sources.yaml"
  "templates/practice-template.md"
  "templates/skill-template/SKILL.md"
  "skills/practice-search/SKILL.md"
)

for path in "${required_paths[@]}"; do
  if [[ ! -f "$repo_root/$path" ]]; then
    printf 'Missing required file: %s\n' "$path" >&2
    exit 1
  fi
done

while IFS= read -r skill_file; do
  if ! rg -q '^---$' "$skill_file" || ! rg -q '^name: [a-z0-9-]+$' "$skill_file" || ! rg -q '^description: .+' "$skill_file"; then
    printf 'Invalid Skill metadata: %s\n' "${skill_file#$repo_root/}" >&2
    exit 1
  fi
done < <(rg --files "$repo_root/skills" -g 'SKILL.md')

while IFS= read -r practice_file; do
  for field in id title domain status maturity last_verified tags; do
    if ! rg -q "^${field}:" "$practice_file"; then
      printf 'Missing %s in %s\n' "$field" "${practice_file#$repo_root/}" >&2
      exit 1
    fi
  done
done < <(rg --files "$repo_root/practices" -g 'PRACTICE.md')

printf 'WTBP repository structure: PASS\n'
