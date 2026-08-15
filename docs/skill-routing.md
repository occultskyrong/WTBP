# Skill 路由与复用

不是每个问题都需要新建 Skill。处理需求时，先从问题场景路由到已有 Skill；只有现有 Skill
无法覆盖、任务会重复出现，并且流程已经稳定可复用时，才考虑新增 Skill。

所有 Skill 先遵循 [`knowledge/skill-framework.md`](../knowledge/skill-framework.md) 的五层架构和 G0–G6
门禁，再进入具体路由。本文只说明发现和复用入口，不替代 Skill 的输入、输出、边界和完成契约。

## 路由入口

机器可读的本地 Skill 规范登记在 [`knowledge/skill-index.yaml`](../knowledge/skill-index.yaml)，外部能力登记在
[`knowledge/external-capabilities.yaml`](../knowledge/external-capabilities.yaml)，路由登记在
[`knowledge/skill-routes.yaml`](../knowledge/skill-routes.yaml)。本地索引是本地 Skill 的标签、输入输出和副作用的唯一来源；
外部登记表只记录可追溯的采用边界；路由只说明问题如何命中本地 Skill 或另行受控安装的外部 Skill。详细决策规则见
[`docs/network-first-capability-governance.md`](network-first-capability-governance.md)。每条路由至少说明：

- 要解决的问题场景和触发条件。
- 使用哪个 `skill_id`，以及 Skill 的仓库路径。
- 来源是仓库内 `local` Skill 还是外部 Skill。
- 是否需要安装；外部 Skill 还必须记录来源、版本、安装范围、权限和验证方式。
- 不适用场景、状态和最近核验日期。

当前已登记的常用 Skill（`candidate` 状态需要当前会话先确认边界）：

| 问题类型 | Skill | 状态 | 路径 | 安装 | 快捷方式 |
|---|---|---|---|---|---|
| 高影响技术/产品决策、最佳实践比较 | `practice-search` | active | `skills/practice-search` | 无需安装 | — |
| 全网搜索、当前主题认知、来源核验 | `systematic-cognition` | candidate | `skills/systematic-cognition` | 无需安装 | — |
| Skill 结构、行为、安全和门禁评测 | `skill-evaluation` | active | `skills/skill-evaluation` | 无需安装 | `ske` |
| 多 Skill 发现、比较和渐进加载 | `skill-router` | active | `skills/skill-router` | 安装本地命令 | `wtbp` |

完整能力地图见 [`docs/skill-catalog.md`](skill-catalog.md)。不要手工扩写上表来描述能力；更新时修改
`knowledge/skill-index.yaml` 并由校验确认总览同步。

设计类任务按责任边界分为 `prd-to-figma`（从需求形成设计产物）、`figma-evolve`（在既有 Figma 上有范围演进）、
`figma-to-product`（针对单一 target 实现）和 `figma-verify`（运行证据与视觉验收）。四个 Skill 共享同一套
简报、证据优先级、版本化清单审批、完整页面/状态、右侧注释、文案分类、几何与可访问性验收规则；规则详见
[`knowledge/design-workflow.zh-CN.md`](../knowledge/design-workflow.zh-CN.md)。不要把一次截图、节点创建或
Skill-Eval dry-run 当作真实视觉验收。

完整的阶段顺序、职责边界和候选成熟度见 [`docs/figma-skill-architecture.md`](figma-skill-architecture.md)。

## 统一入口

当不确定应该使用哪个 Skill 时，先运行统一入口，而不是加载全部 Skill：

```bash
wtbp
wtbp "比较两个架构方案的成本、安全和可逆性"
wtbp external --domain design
```

入口按受控关键词分别列出本地 Skill 和外部能力候选及其下一步读取路径；它不执行目标 Skill。当前会话先判断采用
`direct-use`、`adapt`、`compose`、`reference-only` 还是 `build-local`，再加载唯一明确的本地候选英文 `SKILL.md`。
`local-adapter` 外部能力必须保留本地 Skill 的项目契约与门禁；`manual-optional` 外部能力不会安装。只有唯一命中的外部
安装路由同时满足已登记、`active`、GitHub HTTPS 来源、固定 40 位提交、声明权限和 `auto_install: true` 时，当前会话确认后
才允许运行 `wtbp install <skill-id>`；查询命令本身不会自动安装。

## 当前会话完成语义路由

关键词匹配只是本地候选发现，不是能力认知的唯一方式。`wtbp` 不启动第二个 LLM，也不把任务转发给外部模型；调用
`wtbp` 的当前 Agent/Claude 会话负责完成一次语义判断。推荐按以下顺序渐进加载：

1. 运行 `wtbp root`，确认 WTBP 根目录。
2. 运行 `wtbp "<任务>"`，获取可解释的本地候选、外部能力候选和命中依据；需要浏览时运行 `wtbp external`。
3. 读取 `knowledge/skill-index.yaml` 中的本地 Skill 卡与 `knowledge/external-capabilities.yaml` 中的外部能力卡，比较场景、输入、输出、阶段、副作用、来源、权限和证据。
4. 由当前会话给出 `select`、`clarify` 或 `no_match`，以及本次采用决策；不得凭关键词直接执行、安装或新建。
5. 只有在选择明确后，才读取唯一目标本地 Skill 的英文 `SKILL.md`，并按其权限边界执行。

这种分层沿用 LLM Wiki 的“维护结构化知识、按需提供小范围上下文”原则：索引和命令负责提供上下文，当前会话负责
理解语义。它避免重复启动会话、丢失前文和额外模型费用；命令仍保持可测试、可解释和无外部模型依赖。
首次使用时运行 `bash tooling/install-wtbp.sh`。它只创建两个受控链接：

- `~/.local/bin/wtbp` 指向仓库内的路由命令；
- `~/.codex/skills/wtbp` 指向 `skills/skill-router`，让 Codex 通过一个名为 `wtbp` 的入口发现本仓库能力。

该入口是 `skill-router` 的别名，不会把每个本地 Skill 分别安装到 Codex。新增本地 Skill 仍只在 WTBP 内登记：
`knowledge/catalog.yaml` 负责对象发现，`knowledge/skill-index.yaml` 是本地能力卡和标签的唯一来源，
`knowledge/skill-routes.yaml` 只负责任务匹配。外部能力只登记到 `knowledge/external-capabilities.yaml`，不能因登记而获得安装或执行授权。若同名目标已经存在、不是符号链接或指向其他位置，安装会停止而不会覆盖。

## 外部 Skill 受控安装

首次只安装 WTBP 的命令和一个 Codex 路由入口；不会预装任何本地或外部业务 Skill。后续当前会话通过
`wtbp "<请求>"` 发现候选、完成语义确认并满足安装门禁后，显式运行 `wtbp install <skill-id>`。安装器会将固定版本下载到
`~/.local/share/wtbp/skills/`，再把同一份内容链接到
`~/.codex/skills/<skill-id>` 和 `~/.claude/skills/<skill-id>`。因此不会为两个 Agent 复制两份来源文件。

安装器只接受目录中登记的 GitHub HTTPS 仓库，拒绝任意 URL、浮动分支或标签、未登记权限、`candidate`、`stale`、
`deprecated` 以及非 WTBP 管理的既有链接。也可以在已登记的外部 Skill 上显式执行：

```bash
wtbp install <skill-id>
```

## 使用顺序

1. 先描述问题目标、范围、约束和所需证据。
2. 先检索 `knowledge/external-capabilities.yaml` 与可追溯来源，判断是否可以直接使用、适配、组合或仅作参考。
3. 再读取 `knowledge/skill-routes.yaml`，按触发条件筛选已有本地 Skill；命中时读取对应 `SKILL.md`，不要复制一份新的 Skill。
4. 只有受控外部安装路由才可在来源、版本、安装范围、权限、许可证和验证通过且明确授权后运行 `wtbp install <skill-id>`；外部能力卡不能触发安装。
5. 只有既有能力明确不适用、任务具备稳定重复流程且可编写 Eval 时，才提出新建 Skill。

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
并重新判断是否仍可受控安装。

## 何时新建 Skill

满足以下条件再新建：

- 现有路由都不适用，或已有 Skill 的边界明确排除了该场景。
- 任务会重复发生，且输入、步骤、工具权限和输出契约可以稳定描述。
- 能为新 Skill 编写正向、反向、边界和必要的对抗 Eval。
- 能说明它与已有 Skill 的差异、复用关系和维护边界。

新建后仍需遵循 [`CONTRIBUTING.md`](../CONTRIBUTING.md)、[`docs/skill-evaluation.md`](skill-evaluation.md)
和提交执行清单；路由登记不能替代 Skill 本身的 Eval。
