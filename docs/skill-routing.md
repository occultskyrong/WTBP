# Skill 路由与复用

不是每个问题都需要新建 Skill。处理需求时，先从问题场景路由到已有 Skill；只有现有 Skill
无法覆盖、任务会重复出现，并且流程已经稳定可复用时，才考虑新增 Skill。

## 路由入口

机器可读的路由登记在 [`knowledge/skill-routes.yaml`](../knowledge/skill-routes.yaml)。每条路由至少说明：

- 要解决的问题场景和触发条件。
- 使用哪个 `skill_id`，以及 Skill 的仓库路径。
- 来源是仓库内 `local` Skill 还是外部 Skill。
- 是否需要安装；外部 Skill 还必须记录来源、版本、安装范围、权限和验证方式。
- 不适用场景、状态和最近核验日期。

当前可直接复用的 Skill：

| 问题类型 | Skill | 路径 | 安装 | 快捷方式 |
|---|---|---|---|---|
| 高影响技术/产品决策、最佳实践比较 | `practice-search` | `skills/practice-search` | 无需安装 | — |
| 全网搜索、当前主题认知、来源核验 | `systematic-cognition` | `skills/systematic-cognition` | 无需安装 | — |
| Skill 结构、行为、安全和门禁评测 | `skill-evaluation` | `skills/skill-evaluation` | 无需安装 | `ske` |

## 使用顺序

1. 先描述问题目标、范围、约束和所需证据。
2. 读取 `knowledge/skill-routes.yaml`，按触发条件筛选已有 Skill。
3. 命中本地 Skill 时，直接读取对应路径的 `SKILL.md`；不要复制一份新的 Skill。
4. 命中外部 Skill 时，先核对来源、版本、安装范围、权限、许可证和 Eval；未登记或无法验证的安装命令不得直接执行。
5. 只有没有合适路由，或已有 Skill 明确不适用，且任务具备稳定重复流程时，才提出新建 Skill。

## 外部 Skill 登记要求

外部 Skill 不复制进 `skills/`，除非项目明确决定将其纳入 WTBP 维护范围。路由登记必须补充：

```yaml
- id: route.example-external
  title: 要解决的问题
  skill_id: example-skill
  source: external
  source_url: https://example.com/skill
  version: 1.2.3
  install: 受控安装命令或安装文档
  permissions: 需要的文件、网络和工具权限
  verify: 安装后的版本、路径和最小验证命令
  status: candidate
  last_verified: 2026-08-11
```

不要只登记一个名称或一条未经核验的安装命令。外部 Skill 的版本、来源或权限发生变化时，必须更新
`last_verified`，并重新检查是否仍适合作为默认路由。

## 何时新建 Skill

满足以下条件再新建：

- 现有路由都不适用，或已有 Skill 的边界明确排除了该场景。
- 任务会重复发生，且输入、步骤、工具权限和输出契约可以稳定描述。
- 能为新 Skill 编写正向、反向、边界和必要的对抗 Eval。
- 能说明它与已有 Skill 的差异、复用关系和维护边界。

新建后仍需遵循 [`CONTRIBUTING.md`](../CONTRIBUTING.md)、[`docs/skill-evaluation.md`](skill-evaluation.md)
和提交执行清单；路由登记不能替代 Skill 本身的 Eval。
