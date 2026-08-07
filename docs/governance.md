# 治理与生命周期

Practice 的状态依次为 `draft`、`candidate`、`approved`、`stale`、`deprecated`。

- `draft`：尚未完成场景和证据。
- `candidate`：内容已完整，等待评审或验证。
- `approved`：已具备明确适用范围、可追溯证据和验证方法。
- `stale`：依赖的平台、版本或证据可能已过期，不应作为默认推荐。
- `deprecated`：被替代；通过 `supersedes` 关系指向继任内容。

涉及安全、成本、合规或不可逆架构决策的 Practice 必须有人类评审。证据和参考实现不能以模型生成内容作为唯一依据。
