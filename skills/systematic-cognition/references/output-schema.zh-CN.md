# 认知结果字段

标准结果至少包含以下字段：

| 字段 | 要求 |
|---|---|
| `topic` | 用户要了解的主题 |
| `question` | 重述后的研究问题 |
| `conclusion` | 一句话结论 |
| `core_claims` | 3–5 条核心命题 |
| `scope` | 地区、时间、版本和对象边界 |
| `evidence` | 结论与来源的对应关系 |
| `uncertainties` | 证据不足、冲突和未验证项 |
| `next_questions` | 最多 3 个可继续研究的问题 |

证据条目建议使用以下结构：

```json
{
  "claim": "可验证的结论",
  "url": "https://example.com/source",
  "title": "来源标题",
  "source_level": "A",
  "published_at": "2026-08-09",
  "checked_at": "2026-08-09",
  "support": "来源直接支持的内容",
  "status": "confirmed"
}
```

`status` 只能表示 `confirmed`、`inferred`、`disputed` 或 `unverified`。`inferred` 必须在正文中明确写成推论，不能伪装成来源原话。
