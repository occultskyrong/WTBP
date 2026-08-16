---
name: visual-direction
description: Define an evidence-backed visual direction for a product or Figma design before page styling. Use when a user asks for a more attractive, human-feeling, distinctive, or reference-led interface direction, while keeping external design Skills replaceable and WTBP governance stable.
---

# Visual Direction

Create a versioned visual direction that guides Figma and implementation without copying an external Skill into WTBP. Read [`../../knowledge/design-principles.md`](../../knowledge/design-principles.md) and [`../../knowledge/design-workflow.md`](../../knowledge/design-workflow.md) first.

## Hard safety and routing gate

- Every response produced by this Skill must include a `Status` section with these literal labels: `External Skill: not installed`, `Figma: not written`, and `Human review: not completed` unless the user has supplied explicit evidence for a different state. The Chinese status line `人工评审：未完成，不能进入 Figma 写入` is required for the normal draft state.
- For a normal draft, put this exact block before the visual thesis and do not omit or paraphrase it:

  ```text
  状态
  - 外部 Skill：未安装
  - Figma：未写入
  - 人工评审：未完成，不能进入 Figma 写入
  ```

- If the request is only copywriting, translation, summarization, or image generation, do not create a `VIS` direction; complete the narrower request directly.
- If the request asks to install, authenticate, update, or execute an external Skill, or to write to Figma without review, stop before the workflow and state exactly: `不安装、不认证、不写入 Figma；人工评审未完成，不能进入 Figma 写入。`
- Never promise a future unreviewed Figma write, even if a tool, token, plugin, or MCP connection later becomes available; human review remains a mandatory gate.
- Never call a write, edit, or file-creation tool in this Skill. Do not create or modify files in an unknown current directory. Return a draft in the response unless the user explicitly declares a local artifact path and authorizes filesystem output through a downstream workflow. A local draft is not Figma approval.

## Input Contract

- A product goal, actor, target terminal, and approved or explicitly provisional scope.
- The consuming project or a declared `figma-only` boundary, plus existing tokens, components, fonts, Icon assets, and brand constraints when available.
- A minimum brief: desired user feeling, primary task, content density, accessibility constraints, and references supplied by the user.
- Optional external research adapter: a fixed source revision or a read-only research capability such as Refero. Record the source, revision, access date, permissions, and whether live research was actually used.
- Ask one blocking clarification only when the goal, target, or scope would change the direction materially.
- Every reference row must include a directly traceable URL or the literal state `Unverified`; never turn a product name or remembered pattern into verified source evidence.

## Workflow

1. Establish the product and project boundary. Inspect existing foundations before proposing a new visual language; do not infer product facts from screenshots.
2. Form a concrete visual thesis: dominant mood as observable properties, hierarchy, density, contrast, typography, color roles, spacing, radius, elevation, imagery, Icon family, and motion personality. Replace adjectives such as “modern” or “premium” with testable choices.
3. Research references only when authorized. Prefer several strong references, record URLs and access dates, extract patterns rather than copying one reference, and label model judgment separately from source evidence.
4. Create `VIS-YYYYMMDD-VNN` with token roles, representative examples, anti-patterns, accessibility constraints, and decisions that remain open. Map the direction to `PS`, `AGC`, `ICON`, and `MOTION` work without creating page-local exceptions.
5. Obtain human review of the direction before any Figma write or page-specific styling. Hand off approved direction to `prd-to-figma` or `figma-evolve`; this Skill does not perform that write.

## Boundaries

- Do not write to Figma, code repositories, or external services.
- Do not write a draft to WTBP, a consuming repository, or an undeclared temporary directory; filesystem output requires an explicitly declared path and authorization.
- Do not install, authenticate, or silently update an external Skill. External capabilities are optional adapters and must remain versioned and permission-declared.
- Do not invent product rules, brand facts, user research, accessibility approval, or implementation parity.
- Do not call a direction “good-looking” or complete without explicit human review and the required evidence.
- Stop when the target, product goal, scope, or reference provenance is materially missing.

## Output Contract

The response must begin with the normal draft status block, followed by a reference table in which every row has a URL or `Unverified`, an access date or access boundary, and a separate model-judgment field. End with the exact human-review block:

```text
人工评审：未完成，不能进入 Figma 写入
```

Return:

```text
VIS revision and scope
Product/project boundary and target terminal
Visual thesis with observable properties
Token roles: color, typography, spacing, radius, elevation, density
Icon and motion personality constraints
Reference table: source, revision/access date, extracted decision, confidence, permission boundary
Representative examples and anti-patterns
Accessibility and content-density constraints
Mappings to PS, AGC, ICON, MOTION, and downstream Figma Skill
Human decisions, unresolved items, and unverified boundaries
```

The final response must include the exact status `人工评审：未完成，不能进入 Figma 写入` unless the user has supplied explicit human-review evidence.

## Completion Gate

- The product goal, target, scope, and evidence boundary are recorded.
- `VIS-YYYYMMDD-VNN` contains observable choices rather than untestable taste words.
- Every external reference has a traceable source and access boundary; no external Skill was copied or silently executed.
- Token roles, Icon style, motion personality, accessibility constraints, anti-patterns, and downstream mappings are complete.
- Human review is recorded before page-specific Figma writes; otherwise the result is `candidate` and blocked from styling.
