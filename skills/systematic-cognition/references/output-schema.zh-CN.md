# 认知结果字段

标准结果至少包含以下字段：

| 字段 | 要求 |
|---|---|
| `topic` | 用户要了解的主题 |
| `question` | 重述后的研究问题 |
| `conclusion` | 一句话结论 |
| `core_claims` | 3–5 条核心命题 |
| `scope` | 地区、时间、版本和对象边界 |
| `evidence` | 结论与来源、直接支持内容的命题级对应关系 |
| `uncertainties` | 证据不足、冲突和未验证项 |
| `next_questions` | 最多 3 个可继续研究的问题 |

证据条目建议使用以下结构：

```json
{
  "claim_id": "C-01",
  "claim": "可验证的结论",
  "url": "https://example.com/source",
  "title": "来源标题",
  "source_level": "A",
  "published_at": "2026-08-09",
  "checked_at": "2026-08-09",
  "support": "来源直接支持的内容",
  "supporting_locator": "标题、章节、页码、段落或数据字段",
  "status": "confirmed"
}
```

`status` 只能表示 `confirmed`、`inferred`、`disputed` 或 `unverified`。`inferred` 必须在正文中明确写成推论，不能伪装成来源原话。

标记为 `confirmed` 时，`url`、`title`、`checked_at`、`support` 和 `supporting_locator` 都不可缺少。不得用一条泛泛的来源记录为多项实质不同的命题背书；页面无法访问或找不到所述支持内容时，必须把受影响命题标为 `unverified`，不能保留为已确认引用。
