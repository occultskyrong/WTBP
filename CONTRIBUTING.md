# 贡献指南

## 新增 Practice

1. 在 `practices/<domain>/<topic>/` 从 [`templates/practice-template.md`](templates/practice-template.md) 创建 `PRACTICE.md`。
2. 补全场景、约束、方案对比、推荐规则、反模式和验证方法；没有证据或适用范围的内容不进入 `approved` 状态。
3. 在 `registry/catalog.yaml` 登记 Practice，并在 `registry/relationships.yaml` 关联证据、Skill 和参考实现。
4. 运行 `make validate`。

## 新增 Skill

1. 使用 Agent Skills 兼容结构：`SKILL.md` 加按需加载的 `references/`、`scripts/` 或 `assets/`。
2. Skill 必须引用其使用的 Practice ID，不复制整篇 Practice。
3. 为关键行为提供正向、反向或边界 Eval。
4. 在 `registry/catalog.yaml` 登记后运行校验。

## 评审原则

- 评审推荐规则的适用条件和反例，而非只评审文字是否通顺。
- 证据过期、参考实现不可验证或方案边界不清晰时，降低成熟度或标记为 `stale`。
- 替代旧结论时保留旧条目，并用 `supersedes` 关系记录替代链。
