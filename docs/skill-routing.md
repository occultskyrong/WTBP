# Skill 路由与复用

不是每个问题都需要新建 Skill。处理需求时，先从问题场景路由到已有 Skill；只有现有 Skill
无法覆盖、任务会重复出现，并且流程已经稳定可复用时，才考虑新增 Skill。

## 路由入口

机器可读的能力规范登记在 [`knowledge/skill-index.yaml`](../knowledge/skill-index.yaml)，路由登记在
[`knowledge/skill-routes.yaml`](../knowledge/skill-routes.yaml)。前者是标签、输入输出和副作用的唯一来源；后者只说明问题
如何命中 Skill。每条路由至少说明：

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
| 多 Skill 发现、比较和渐进加载 | `skill-router` | `skills/skill-router` | 安装本地命令 | `wtbp` |

完整能力地图见 [`docs/skill-catalog.md`](skill-catalog.md)。不要手工扩写上表来描述能力；更新时修改
`knowledge/skill-index.yaml` 并由校验确认总览同步。

## 统一入口

当不确定应该使用哪个 Skill 时，先运行统一入口，而不是加载全部 Skill：

```bash
wtbp
wtbp "比较两个架构方案的成本、安全和可逆性"
```

入口按受控关键词列出活跃或候选路由及其下一步读取路径；它不执行目标 Skill。命中唯一且明确的本地候选后，再读取
对应的英文 `SKILL.md`；多个候选或高影响流程必须先说明推荐和边界。唯一命中的外部候选只有同时满足已登记、`active`、
GitHub HTTPS 来源、固定 40 位提交、声明权限和 `auto_install: true` 时，才会由 `wtbp` 自动安装；其他外部候选必须
先获得明确安装授权。
首次使用时运行 `bash tooling/install-wtbp.sh`，它只在 `~/.local/bin/wtbp` 不存在时创建指向仓库脚本的符号链接；
若同名命令已经存在或指向其他位置，会停止而不会覆盖。

## 外部 Skill 自动安装

首次只安装 `wtbp` 命令；不会预装任何外部 Skill。后续用户通过 `wtbp "<请求>"` 命中唯一受控的外部路由时，命令会
调用 `tooling/install-skill.sh`，将固定版本下载到 `~/.local/share/wtbp/skills/`，再把同一份内容链接到
`~/.codex/skills/<skill-id>` 和 `~/.claude/skills/<skill-id>`。因此不会为两个 Agent 复制两份来源文件。

安装器只接受目录中登记的 GitHub HTTPS 仓库，拒绝任意 URL、浮动分支或标签、未登记权限、`candidate`、`stale`、
`deprecated` 以及非 WTBP 管理的既有链接。也可以在已登记的外部 Skill 上显式执行：

```bash
wtbp install <skill-id>
```

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
  commit: 0123456789abcdef0123456789abcdef01234567
  skill_path: skills/example-skill
  install: auto
  auto_install: true
  permissions: 需要的文件、网络和工具权限
  verify: 已安装的 SKILL.md、name 与目标路径
  status: active
  last_verified: 2026-08-11
```

`commit` 必须是完整的 40 位 Git 提交哈希，`skill_path` 必须指向仓库内包含 `SKILL.md` 的相对目录。不要只登记一个
名称或一条未经核验的安装命令。外部 Skill 的版本、来源、提交或权限发生变化时，必须更新 `last_verified`，重新核验，
并重新判断是否仍可自动安装。

## 何时新建 Skill

满足以下条件再新建：

- 现有路由都不适用，或已有 Skill 的边界明确排除了该场景。
- 任务会重复发生，且输入、步骤、工具权限和输出契约可以稳定描述。
- 能为新 Skill 编写正向、反向、边界和必要的对抗 Eval。
- 能说明它与已有 Skill 的差异、复用关系和维护边界。

新建后仍需遵循 [`CONTRIBUTING.md`](../CONTRIBUTING.md)、[`docs/skill-evaluation.md`](skill-evaluation.md)
和提交执行清单；路由登记不能替代 Skill 本身的 Eval。
