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

覆盖单 target 实现、普通改写不触发、target/仓库缺失、I-01 至 I-10 的布局、导航分布、动作组几何与递归边界，以及写入后全页面结构门禁；不验证真实项目构建、Figma MCP 连通性或跨终端共享代码。

## 用例与覆盖

用例见 [`cases.yaml`](cases.yaml)。每个布局用例以“先失败、再定位首个责任层、后通过”为目标，覆盖正常流、锚定浮层、祖先 padding、层叠/包含块、字体/资源、响应式和 target 隔离。`skill-up` 用例保持同样覆盖。

## 判定标准

- 正向请求必须声明恰好一个 target，并先收集已审批清单/feature ID、Figma 节点、父级、布局、Tokens、组件和资源证据。
- 在组件映射和实现架构前，必须先检查实际目标仓库并建立或确认 `PDC-YYYYMMDD-VNN`，完成 `PDC-01`–`PDC-06`；契约冲突或关键字段未确认时必须阻断，不得从截图直接猜测项目结构。
- 必须在实现前生成或确认由 PDC 推导的 `ARC-YYYYMMDD-VNN`，并用它约束模块、路由、组件映射、状态/转移和底层窗体批次。
- 编辑代码前必须为每个页面/状态建立或确认 `PS-YYYYMMDD-VNN`，核对 `PS-01`–`PS-05` 的页面说明、完整元素层级、公共组件/Token/Icon/资产复用矩阵、L0–L3 实现顺序及设计到代码映射；页面规格缺失、过期或与实现冲突时必须阻断。
- 页面样式前必须确认 `AGC-YYYYMMDD-VNN` 和 `AGC-01`–`AGC-06`，让每个动作组具有可验证的语义、共享组件、宽度/插槽策略、可见尺寸与触达目标尺寸。对称导航必须左右目标等大、中部操作相对父级居中；不得用一个大外框、手工坐标或 `space-between` 伪造居中。
- 页面样式前必须确认 `ICON-YYYYMMDD-VNN` 和 `IA-01`–`IA-07`，让每个 Figma Icon 实例映射到批准的语义组件、尺寸、风格、状态、精确来源/导出和目标实现；优先复用项目库，缺失 Icon 独立设计为同一家族组件，不得手绘页面局部替代图标。
- 必须优先复用代码仓库中的组件和 Tokens，不能把截图直接翻译为静态坐标。
- 关键偏移必须输出首个布局责任层；不得用子元素 margin、transform 或 absolute 补偿。
- 必须实现完整页面和已声明物料状态，保留失败布局证据，分类实现文案，并输出 viewport/状态矩阵、几何和可访问性检查。
- 缺失 target 或仓库时不得开始实现，也不得顺带实现未声明的其他终端。
- 通过必须提供真实夹具：Figma 节点、目标预览、基线/预期/修复后截图、首因、改动文件和复跑结果；dry-run 不算实现验收。
- 交接必须附上所有声明页面/状态的 `G-01`–`G-06` 结果；源 Figma 与 DOM 的布局责任层、annotation、文字边界、实例/Master 比例、目标终端外框高保真或产品内容隔离缺失时，门禁不通过。小程序必须验证适用的小程序外框，App 必须验证声明的设备/安全区外框，Web 必须验证批准的浏览器外框或边界可见的视口容器；通用手机框或裸画布不通过。页面描述和技术说明不得进入产品 UI。
- 实现必须先为所有声明页面/状态构造并验证结构底层批次，记录 `BF-01`–`BF-06`，通过后才能叠加组件、内容和视觉样式；底层批次不完整时不得交接。
- 等权导航必须使用可验证的 Flex/Grid/Auto Layout 分布，递归组件边界必须覆盖所有后代节点、直接父级和祖先链；手工坐标、页面级单点溢出检查或 `overflow:hidden` 掩盖都不通过。对称导航必须记录左右目标的宽高和中部相对父级的中心偏差。

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
