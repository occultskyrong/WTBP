# 贡献指南

提交分支、提交消息和提交前检查见 [`docs/commit-conventions.md`](docs/commit-conventions.md)；完整执行清单见
[`docs/commit-checklist.md`](docs/commit-checklist.md)。

## 语言

面向贡献者、使用者和评审者的文档、Issue、PR 说明、模板与校验提示默认使用中文。
AI 读取的规范入口（`AGENTS.md`、`CLAUDE.md`、`skills/**/SKILL.md` 和其 `references/`）以英文
作为规范源，并在同目录提供同名 `.zh-CN.md` 中文对照；两份文件必须同步修改。完整命名和例外规则见
[`docs/document-language-policy.md`](docs/document-language-policy.md)。

为保持工具兼容性，文件路径、YAML 字段、Practice/Skill ID、Conventional Commit 的
`type` 和 GitHub 自动识别关键字（如 `Closes #123`）保留原格式；提交标题的说明文字
应使用简明中文。

## 新增 Practice

1. 在 `knowledge/practices/<domain>/<topic>/` 从 [`knowledge/templates/practice-template.md`](knowledge/templates/practice-template.md) 创建 `PRACTICE.md`。
2. 补全场景、约束、方案对比、推荐规则、反模式和验证方法；没有证据或适用范围的内容不进入 `approved` 状态。
3. 在 `knowledge/catalog.yaml` 登记 Practice，并在 `knowledge/relationships.yaml` 关联证据、Skill 和参考实现。
4. 运行 `make validate`；提交前由 `make commit-checklist` 统一执行校验和审查。

## 新增 Skill

1. 先阅读 [`docs/skill-routing.md`](docs/skill-routing.md)，确认现有 Skill 无法覆盖；不要为已有能力重复建 Skill。
2. 使用 Agent Skills 兼容结构：`SKILL.md` 加按需加载的 `references/`、`scripts/` 或 `assets/`。
3. Skill 必须引用其使用的 Practice ID，不复制整篇 Practice。
4. 在 `knowledge/evals/<skill-id>/` 创建 `EVAL.md` 和 `cases.yaml`，至少覆盖正向触发、反向
   不触发和缺少上下文的边界场景；涉及工具或权限时增加对抗用例。
5. 在 `knowledge/catalog.yaml` 同时登记 Skill 和 Eval，保持 `skill`、路径和状态一致；在
   `knowledge/skill-routes.yaml` 增加问题场景到新 Skill 的路由。
6. 运行 `make validate`、`make validate-skill-evals`；提交前由 `make commit-checklist` 自动执行
   `ske` 契约评测、门禁和版本检查。行为评测还要记录有 Skill / 无 Skill 基线、重复运行次数和主要失败原因。

## Skill 评测

评测规范见 [`docs/skill-evaluation.md`](docs/skill-evaluation.md) 和
[`knowledge/schemas/eval-schema.yaml`](knowledge/schemas/eval-schema.yaml)。没有 Eval 的新建
或修改 Skill 会被提交前审查拒绝；评测结果、模型凭据和生成报告不得提交到仓库。

## 评审原则

- 评审推荐规则的适用条件和反例，而非只评审文字是否通顺。
- 证据过期、参考实现不可验证或方案边界不清晰时，降低成熟度或标记为 `stale`。
- 替代旧结论时保留旧条目，并用 `supersedes` 关系记录替代链。
- 不绕过提交 Hook；远端 CI 会复跑相同的架构和内容审查。
