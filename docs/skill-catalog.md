# Skill 能力总览

本页由 `knowledge/skill-index.yaml` 生成。它帮助人快速浏览能力；执行时仍应通过 `wtbp` 路由并按需读取目标 `SKILL.md`。

| Skill | 状态 | 领域 | 阶段 | 核心能力 | 简介 |
|---|---|---|---|---|---|
| `practice-search` | active | research、product | discover、analyze | practice-search、option-comparison、evidence-synthesis | 基于场景、约束、证据和参考实现比较技术或产品方案。 |
| `systematic-cognition` | active | research、product | discover、analyze | web-research、source-verification、evidence-synthesis | 检索公开资料，区分事实、推论和未验证项，并给出可追溯来源。 |
| `skill-evaluation` | active | governance、quality | evaluate | skill-evaluation、regression-evaluation | 审查 Skill 的触发边界、结构、安全、行为表现和质量门禁。 |
| `skill-router` | active | governance | discover | task-routing、managed-install | 浏览能力地图、查看 Skill 卡片，并将自然语言任务路由到最小适用的 Skill。 |
| `external-capability-discovery` | candidate | research、governance、product | discover、analyze、evaluate | web-research、source-verification、evidence-synthesis、task-routing | 在本地能力无明确适配项时，检索公开 Skill、GitHub 方案与官方集成，并按可追溯百分制评分排序。 |
| `external-capability-curation` | candidate | research、governance | discover、analyze、evaluate | source-verification、evidence-synthesis、task-routing | 将用户提供的公开项目或 Skill 自动转为可发现、未安装且含场景与 Case 的外部最佳实践卡。 |
| `prd-to-figma` | candidate | product、design | design | figma-create、figma-inspection | 从 PRD 创建首版可编辑 Figma 设计、页面、状态、组件和基础设计资产。 |
| `figma-evolve` | candidate | product、design | evolve | figma-evolve、figma-inspection | 在保留历史设计证据的前提下，对已有 Figma 节点进行补丁或版本化重做。 |
| `figma-to-product` | candidate | product、design、engineering | implement | figma-to-code、figma-inspection、layout-diagnosis | 将明确 Figma 节点以可维护布局还原到唯一指定的 Web、小程序或 App 终端。 |
| `figma-verify` | candidate | product、design、quality | verify | visual-verification、layout-diagnosis、figma-inspection | 对指定终端、视口和状态验证 Figma 与运行实现的差异，并定位首个布局责任层。 |

## 如何选择

- 已知要解决什么问题：运行 `wtbp "<问题>"`，获取候选 Skill 和匹配依据。
- 想按领域浏览：运行 `wtbp list --domain <domain>`，例如 `design`、`research` 或 `quality`。
- 已知 Skill 名称：运行 `wtbp show <skill-id>`，查看输入、输出、副作用、别名、路由和安装方式。
- 只在选中后读取对应的英文 `SKILL.md`；不要一次性加载全部 Skill。
