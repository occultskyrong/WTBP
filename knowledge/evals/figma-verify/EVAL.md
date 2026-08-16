---
id: eval.figma-verify
skill: figma-verify
status: candidate
runner: skill-up
last_verified: 2026-08-14
min_behavior_pass_rate: 0.90
---

# `figma-verify` Skill 评测

## 评测目标

验证 Skill 能只针对用户声明的 targets 建立验收矩阵，并以结构、布局和视觉证据定位 Figma 与实现之间的偏差。

## 评测边界

覆盖单 target 验收、普通摘要不触发、缺失验收 target、V-01 至 V-12 的保真诊断场景，以及写入后全页面结构门禁；不验证真实浏览器、开发者工具、设备农场或像素阈值。

## 用例与覆盖

用例见 [`cases.yaml`](cases.yaml)。每个保真用例要求保留失败基线、定位首个原因、在明确授权时修复、并以同一矩阵复验，覆盖 absolute、父级链、层叠、字体/资源、响应式、状态和 target 范围。`skill-up` 用例保持同样覆盖。

## 判定标准

- 只验证声明 targets，不默认增加 Web、小程序或 App。
- 每个 target 必须有已审批清单/feature ID、适用 viewport/设备、状态和运行证据，并覆盖完整容器页面而非裁剪组件。
- 每个验收矩阵还必须引用当前项目设计契约 `PDC-YYYYMMDD-VNN`，逐项核对 `PDC-01`–`PDC-06` 与实现；契约缺失、过期或存在实质冲突时必须阻断验收。
- 验收还必须引用由契约推导的 `ARC-YYYYMMDD-VNN`，确认实际路由、页面族、外框、状态和组件映射没有偏离架构；架构缺失或过期时不得声称完成。
- 验收还必须逐页确认当前 `PS-YYYYMMDD-VNN`：核对 `PS-01`–`PS-05` 的页面说明、完整元素层级、公共组件/Token/Icon/资产复用矩阵、L0–L3 实现顺序及设计到代码/验收映射；页面规格缺失、过期、不完整或与实际实现冲突时不得通过。
- 验收必须确认当前 `AGC-YYYYMMDD-VNN` 和 `AGC-01`–`AGC-06`，逐个核对动作组的语义、共享组件、宽度/插槽策略、可见尺寸与触达目标尺寸。对称导航必须记录左右目标宽高相等和中部相对父级的中心偏差；一个空白过大的伪按钮、手工坐标或仅用 `space-between` 都不得通过。
- 验收必须确认当前 `ICON-YYYYMMDD-VNN` 和 `IA-01`–`IA-07`，逐个核对可见 Icon 的语义 ID、组件/家族、尺寸、风格、状态、来源/导出及目标映射；页面局部 Vector、emoji、文字图标、错误尺寸 Variant 或未经批准来源均不得通过。
- 有意义偏移必须分类并输出第一个布局责任层及预期/实际证据。
- 评审发现节点迁移、页面增删或 Section 列数变化时，验收必须重算所有受影响 Section 的实际内容边界加已声明固定内边距，并记录触发原因、子元素/列输入、内边距与重算前后几何；旧固定宽高或子元素补偿不能通过，除非有明确产品规则和批准记录。
- 必须检查适用的右侧标注几何、文案分类/来源和可访问性；截图差异、静态检查或一次看似合理的截图均不能单独证明验收通过。
- 通过必须提供真实夹具的基线/预期/修复后截图、几何证据、首因、复跑和人审记录；Skill-Eval dry-run 只能验证流程。
- 通过前必须逐页记录 `G-01`–`G-06`：layoutMode/布局责任层、独立右侧 annotation、文字容器边界、实例/Master 宽高比例、`G-05S` 外框/产品根/系统 Chrome/TabBar/Section 归属，以及 `G-05V` 的视觉配方、未选中固定完整截图、画布留白、上/右/下/左四边结果和产品内容隔离，并核对页面/状态/转移矩阵；小程序必须验证适用的小程序外框，App 必须验证声明的设备/安全区外框，Web 必须验证批准的浏览器外框或边界可见的视口容器。Figma 选中框、Section 边缘、画布或裁剪截图均不能作为边界证据，`G-05V` 失败即未完成；通用手机框或裸画布、页面描述和技术说明出现在产品 UI、只检查变更页面、遗漏操作转移或只提供一张截图都不通过。
- 验收还必须确认样式构建前所有批准页面/状态已完成底层窗体批次并通过 `BF-01`–`BF-06`，且存在中性底层截图；底层证据缺失时不得通过。
- 验收必须检查等权导航的分布/中心点，以及所有嵌套组件的递归父子和祖先边界；只检查页面级 bounding box、只检查变更页面或用裁剪隐藏溢出都不通过。动作组几何必须以同一 target/viewport 的可复核数据验证，不得只凭视觉印象。
- 官方 Figma MCP/Code Connect 能力必须记录可用性与映射边界（`EX-01`–`EX-02`）。第三方 Token、WCAG 或设计 lint 审计只有在用户明确授权、来源/版本已审查且凭据/命令范围明确后才能运行（`EX-03`–`EX-04`）；不得自动安装、读取 PAT 或用审计通过代替真实夹具验收。

## 证据基础

- Figma 将结构、组件、Variables、Auto Layout 和注释作为向 AI 表达设计意图的关键信息；仅有截图不足以表达布局和行为。[Figma：Structure your Figma file for better code](https://developers.figma.com/docs/figma-mcp-server/structure-figma-file/)
- Figma 推荐先获取精确节点的结构和截图，随后用项目约定实现，再回到 Figma 验证外观与行为。[Figma：Add custom rules and instructions](https://developers.figma.com/docs/figma-mcp-server/add-custom-rules/)
- Playwright 的视觉比较依赖基准图；浏览器、操作系统、字体和环境会影响截图，因此基准与复验必须在同一环境运行。[Playwright：Visual comparisons](https://playwright.dev/docs/test-snapshots)

## 基线与重复运行

启用有 Skill / 无 Skill 基线，每个用例至少运行 3 次。记录矩阵完整性、差异诊断和人审边界；dry-run 不代表真实终端验收已通过。要证明问题解决，真实夹具必须有同一节点、target、状态、viewport/设备和数据条件下的失败基线、首因诊断、修复后截图及人工复核。

## 安全边界

报告模式只读取指定 Figma 节点和用户提供的运行证据。修复模式必须有明确授权，且只修复首个已证实原因；不得读取密钥、部署、提交、推送或改动未声明 target。

## 验证命令

```bash
make validate-skill-evals
make skill-eval SKILL_ID=figma-verify
```
