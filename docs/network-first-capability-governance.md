# 网络优先的能力治理

WTBP 的默认问题不是“要不要新建一个 Skill”，而是“现有的可信能力能否在明确边界内解决问题”。
因此，先检索和评估网络上的官方能力、外部 Skill、参考实现，再决定是否复用、适配、组合或自建。

这不是把所有 GitHub 仓库都变成 WTBP Skill。外部资源和本地 Skill 分别治理：本地 Skill 是 WTBP 维护的可执行契约，必须通过
G0–G6、Eval 和版本管理；外部能力只是可追溯的候选，必须明确来源、采用方式、权限和验证边界。

## 两类登记表

| 对象 | 规范源 | 用途 | 质量与安装边界 |
|---|---|---|---|
| 本地 Skill | [`knowledge/skill-index.yaml`](../knowledge/skill-index.yaml) | 稳定、可重复的 WTBP 流程 | 必须有 `SKILL.md`、中文对照、路由、目录、Eval 与关系；按 G0–G6 执行。 |
| 外部能力 | [`knowledge/external-capabilities.yaml`](../knowledge/external-capabilities.yaml) | 官方集成、外部 Skill 或参考实现 | 必须关联 [`knowledge/external-sources.yaml`](../knowledge/external-sources.yaml)，声明采用方式、可用性、权限和验证；不会自动安装。 |

`knowledge/skill-routes.yaml` 只把任务路由到本地 Skill 或已受控安装的外部 Skill。它不能替代外部能力登记，更不能把一条 URL
伪装成已经可执行的 Skill。

## 决策顺序

```text
问题、约束、验收证据
          │
          ▼
检索官方来源、外部 Skill 与参考实现
          │
          ▼
核验来源、许可、版本、权限、输入输出和证据边界
          │
          ├─ 已能满足且无项目专属流程 ─────► 直接使用（direct-use）
          ├─ 可作为底层能力但需 WTBP 门禁 ─► 本地适配（local-adapter）
          ├─ 多个能力分别解决不同阶段 ────► 组合（compose）
          ├─ 仅能借鉴结构或实现 ──────────► 参考（reference-only）
          └─ 无稳定匹配且会重复发生 ──────► 自建本地 Skill（build-local）
```

外部能力卡中的 `adoption` 描述单项能力的默认采用边界：

- `direct-use`：当前客户端或已配置环境提供的能力可直接使用，但仍先核对权限与可用性。
- `local-adapter`：能力是 WTBP 本地 Skill 的底层工具；必须遵循本地 Skill 的输入、项目契约、门禁与验收，不能绕过流程。
- `manual-optional`：第三方能力只有在用户明确授权后，才单独核对来源、固定版本、许可证、权限、凭据和执行环境；`wtbp` 不安装它。
- `reference-only`：只用于理解、比较或借鉴结构，不能当作项目事实、执行结果或强制规范。

`compose` 与 `build-local` 是当前会话针对一个任务的结论，不是外部能力卡的安装指令。

## 何时可以直接复用，何时必须自建

满足以下全部条件，优先直接复用或薄适配，而不是创建新 Skill：

- 能力来源可追溯，且版本、许可和权限边界与任务相容。
- 目标任务的输入、输出、风险和验收可由该能力或现有本地 Skill 覆盖。
- 没有跨项目反复出现、无法由现有契约表达的专属决策或执行门禁。
- 复用后仍可保留真实证据，不会把外部生成内容误称为项目验收。

只有同时满足以下条件，才提出 `build-local`：

- 外部能力和现有本地 Skill 均不能覆盖关键的项目专属边界。
- 场景会重复发生，流程、权限、副作用和输出可以稳定描述。
- 能写出正向、反向、边界与必要对抗 Eval，并有维护责任人。
- 能说明为何组合/适配不足，以及新 Skill 与现有能力的关系。

新增本地 Skill 前，先使用 `practice-search` 或 `systematic-cognition` 记录检索范围、候选来源和未采用理由；不要因一次任务
或一个临时提示词新建 Skill。

## 使用入口

```bash
wtbp "为 Figma 组件建立 Code Connect 映射"
wtbp external --domain design
wtbp show figma-code-connect
```

查询会分别列出“候选本地 Skill”和“可复用的外部能力候选”。当前 Agent/Claude 会话结合完整任务上下文做语义判断，输出
`select`、`clarify` 或 `no_match`，并给出本次任务采用 `direct-use`、`adapt`、`compose`、`reference-only` 或 `build-local`
的理由。查询不会启动第二个 LLM、安装 Skill、访问外部服务或读取凭据。若用户在当前 Agent/Claude 对话中明确输入
`wtbp，收集 <公开 URL>`，则该会话进入受控收录流程：仅读取该公开来源，自动生成未安装的外部最佳实践卡、适用场景与典型 Case；不会安装、执行或读取凭据。

## 本地优先后的在线发现

当已登记本地 Skill 和外部能力卡都不能明确覆盖任务时，选择 `external-capability-discovery`，而不是直接新建 Skill。
它以 `find-skills`/skills.sh、GitHub 和第一方公开来源发现临时候选，按场景契合、来源维护、社区采用、接入安全与证据完整度计算 100 分总分，并单独报告证据置信度。结果只用于本次决策；经用户确认、来源固定、许可证和权限审查后，才可进入外部能力登记或受控安装流程。

## 设计任务示例

Figma 官方 MCP 和 Code Connect 是典型的 `local-adapter`：它们可提供底层设计和组件映射能力，但在 WTBP 中仍须经
`prd-to-figma`、`figma-evolve`、`figma-to-product` 或 `figma-verify` 的项目设计契约、几何门禁和真实验收。第三方审计工具
则是 `manual-optional`，只能补充审计证据，不能替代 WTBP 的视觉或运行验证。具体来源和边界见
[`docs/external-design-capabilities.md`](external-design-capabilities.md)。

## 更新要求

新增或修改外部能力时：

1. 先登记和核验来源；来源必须具有 HTTPS URL、发布方、访问日期、许可证、修订、Skill 路径和质量证据。不清楚时标记 `unverified` 并说明原因，保持 `candidate` 或只登记为 `reference-only`。
2. 为每张外部最佳实践卡登记实际解决问题、反例、适用场景和至少两个典型 Case；不允许只用仓库名或 Star 推断能力。
3. 更新 `knowledge/external-sources.yaml`、`knowledge/external-capabilities.yaml` 及其 schema，运行 `make validate`。
4. 若它改变路由判断，更新 `skill-router` 的中英文说明和正向/边界/对抗 Eval。
5. 若决定把能力固化为本地 Skill，再完整走 [`knowledge/skill-framework.zh-CN.md`](../knowledge/skill-framework.zh-CN.md) 的 G0–G6；外部能力卡不能替代这些登记。
