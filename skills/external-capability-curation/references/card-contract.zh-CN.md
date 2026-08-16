# 已收录外部能力卡契约

在留存用户确认的公开来源时使用本契约。来源记录保存可追溯性；能力卡让来源无需安装即可被发现。

## 来源记录

在 `knowledge/external-sources.yaml` 新增一条稳定的 `source.<publisher>-<repository>` ID 记录。记录 `url`、`publisher`、`trust`、`accessed_on`、`scope`、`credential_boundary`、`license`、`revision`、`skill_path` 与 `quality_evidence`。无法公开核验的事实设为 `unverified` 并附简短原因。`quality_evidence` 记录当次观察到的维护/社区信号，或无法核验的原因。

## 能力卡

在 `knowledge/external-capabilities.yaml` 新增一张通过 `source_id` 关联的卡。必需检索字段均为非空单行列表：

| 字段 | 含义 |
|---|---|
| `solves` | 来源直接支持的具体用户问题与可重复结果。 |
| `not_for` | 用于避免误命中的反例与责任边界。 |
| `scenarios` | 能力适用的具体前提和情形。 |
| `cases` | 至少两个后续应命中的中文任务请求。 |
| `inputs` | 能力可用前所需条件或产物。 |
| `outputs` | 它能够提供的产物、证据或决策。 |
| `technologies` | 命名的生态、协议、语言或框架。 |
| `targets` | 相关终端、环境或交付目标。 |
| `installation_status` | 收录时始终为 `uninstalled`。 |
| `keywords` | 简短词法别名，绝不能成为能力描述的唯一来源。 |

默认 `status` 为 `candidate`、`adoption` 为 `reference-only`、`availability` 为 `reference`。后续治理评审可以修改这些字段，但收录绝不创建外部路由或安装指令。

## 匹配与去重

- 新增卡片前按规范 URL、来源 ID、固定修订和 Skill 路径检索。
- 同一仓库有不同且已记录的 Skill 路径时，默认可能是独立能力卡，而非重复。
- 未知字段明确保留为 `unverified`，不得从 Star、描述或组织名推断。
- `wtbp` 匹配问题、场景、Case、技术、目标、输入、输出和 `keywords`；精确命中 `not_for` 时抑制错误候选，再由当前会话完成语义选择。
