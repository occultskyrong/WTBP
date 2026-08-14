---
id: eval.figma-to-product
skill: figma-to-product
status: candidate
runner: skill-up
last_verified: 2026-08-14
min_behavior_pass_rate: 0.90
---

# `figma-to-product` Skill 评测

## 评测目标

验证 Skill 能以结构化 Figma 证据实现一个明确 target，并通过布局溯源避免由 absolute 定位或遗漏父级 CSS 导致的偏移。

## 评测边界

覆盖单 target 实现、普通改写不触发、target/仓库缺失，以及 I-01 至 I-07 的布局与终端边界场景；不验证真实项目构建、Figma MCP 连通性或跨终端共享代码。

## 用例与覆盖

用例见 [`cases.yaml`](cases.yaml)。每个布局用例以“先失败、再定位首个责任层、后通过”为目标，覆盖正常流、锚定浮层、祖先 padding、层叠/包含块、字体/资源、响应式和 target 隔离。`skill-up` 用例保持同样覆盖。

## 判定标准

- 正向请求必须声明恰好一个 target，并先收集已审批清单/feature ID、Figma 节点、父级、布局、Tokens、组件和资源证据。
- 必须优先复用代码仓库中的组件和 Tokens，不能把截图直接翻译为静态坐标。
- 关键偏移必须输出首个布局责任层；不得用子元素 margin、transform 或 absolute 补偿。
- 必须实现完整页面和已声明物料状态，保留失败布局证据，分类实现文案，并输出 viewport/状态矩阵、几何和可访问性检查。
- 缺失 target 或仓库时不得开始实现，也不得顺带实现未声明的其他终端。
- 通过必须提供真实夹具：Figma 节点、目标预览、基线/预期/修复后截图、首因、改动文件和复跑结果；dry-run 不算实现验收。

## 证据基础

- Figma 建议使用组件、Variables、语义名称和 Auto Layout；Auto Layout 能表达布局意图并减少 absolute 定位。[Figma：Structure your Figma file for better code](https://developers.figma.com/docs/figma-mcp-server/structure-figma-file/)
- Figma 的推荐实现流程要求先取得精确节点的结构和截图，再使用项目组件/Tokens 并回到 Figma 验证；MCP 返回内容是设计表示，不是最终代码样式。[Figma：Add custom rules and instructions](https://developers.figma.com/docs/figma-mcp-server/add-custom-rules/)
- Code Connect 能把真实组件用法、属性映射和源路径送入 MCP 上下文，减少模型对实现方式的猜测。[Figma：Code Connect integration](https://developers.figma.com/docs/figma-mcp-server/code-connect-integration/)

## 基线与重复运行

启用有 Skill / 无 Skill 基线，每个用例至少运行 3 次。记录证据门禁、target 边界和布局诊断完整性；dry-run 不代表代码或视觉验收已通过。真实夹具必须先保留故障截图，再修复首个责任层，并在同一 target、状态和 viewport 下复跑。

## 安全边界

只允许访问用户指定的 Figma 节点和目标仓库。不得读取密钥、改动未声明 target、提交、推送、部署，或为解决布局问题覆盖全局无关样式。

## 验证命令

```bash
make validate-skill-evals
make skill-eval SKILL_ID=figma-to-product
```
