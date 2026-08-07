# WTBP 检索约定

1. 从仓库根目录的 `registry/catalog.yaml` 发现 Practice、Skill、参考实现和 Eval。
2. 用 `ontology/context-schema.yaml` 补齐问题的关键场景变量。
3. 先读取 Practice 的 frontmatter、适用场景和推荐规则；只有需要时再读取证据或参考实现。
4. 优先选择 `approved` 且 `last_verified` 较新的内容；`stale` 和 `deprecated` 只能作为历史或反例使用。
5. 返回的建议必须列出使用的 Practice ID、缺失变量、采用或拒绝的原因及验证方法。
