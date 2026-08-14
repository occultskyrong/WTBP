---
name: figma-to-product
description: 将指定 Figma 节点落实到恰好一个已声明的产品终端，例如 Web、小程序、iOS 或 Android。已有 Figma 设计且需要在指定代码仓库中高保真、可维护地实现时使用。
---

# Figma 到产品实现

根据当前 Figma 设计证据实现一个 target。不得重新从 PRD 开始、补全缺失业务功能，或把截图视为完整设计契约。

## 必需输入

- 明确的 Figma 页面、Frame、组件或状态节点链接。
- 一个 target：`web`、`miniapp`、`app-ios`、`app-android`，或其他明确命名的 target。
- 目标仓库或可写实现位置。

target 或仓库缺失时询问。Figma 设计与提供的 PRD 冲突时，报告冲突并交给 `figma-evolve`，不得在代码中自行选择。

## 设计证据门禁

1. `get_design_context` 前加载 `figma:figma-design-to-code`；需要检查 Figma 时加载 `figma:figma-use`。
2. 对每个范围节点收集节点和父级 ID、层级、截图、Auto Layout、约束、变量/Tokens、组件/Variants、标注/原型行为及精确资源/字体。
3. 检查目标仓库既有组件、主题/Tokens、CSS 或平台样式、资源和终端约束。优先级为 Code Connect 映射、项目既有组件/Tokens、Figma Variables；最后才新建最小组件。
4. 可复用 Figma 组件需要持久代码映射时使用 `figma:figma-code-connect`。

## 布局溯源门禁

不得把 Figma `x/y` 坐标直接翻译为普通内容的 CSS `left/top`。将每个关键子元素分类为正常流、约束/拉伸、浮层或 fixed/sticky。

每个关键视觉差异或 absolute 子元素都要向上追踪至页面根，识别布局责任层。检查 `display`、`position`、尺寸、padding、margin、gap、box sizing、flex/grid 规则、overflow、transform、继承字体、变量及响应式规则。

- 普通内容使用 Flex、Grid、Auto Layout 意图和正常文档流。
- `absolute` 仅允许已证实的浮层、角标或锚定控件；记录定位父级、锚点和已验证 viewport。
- 修复第一个发生偏差的布局责任层；不得用子元素 margin、transform 或坐标补偿掩盖父级错误。

## 问题驱动的实现场景

编辑前选择全部适用场景，并在实现计划中写明 ID、target、Figma 节点、预期布局责任层和所需 viewport/状态。在捕获所需证据前，视为未通过。

| ID | 给定条件 | 必须实现与断言 |
|---|---|---|
| I-01 正常流卡片 | 卡片的标题、可变长度文案、图片和 CTA 按阅读顺序出现。 | 将 Figma Auto Layout 映射为正常流/Flex/Grid。断言改变文案长度后，下游内容由父级布局移动，而不是子元素 `top/left`。 |
| I-02 锚定浮层 | 角标、关闭按钮或菜单覆盖在卡片上。 | 只允许在已命名的包含父级、锚点和 viewport 下使用 absolute。断言普通内容增长时它仍保持锚定。 |
| I-03 祖先 padding 偏移 | 卡片整体比 Figma 偏离 12–16px。 | 对比完整祖先链，修复第一个错误的 padding、gap、宽度或布局方向；断言不存在补偿性子元素 margin/transform。 |
| I-04 层叠或包含块偏移 | 全局选择器、`box-sizing`、`transform`、`overflow` 或定位祖先改变几何关系。 | 定位计算样式来源和包含块。断言作用域规则获胜，且不削弱无关页面。 |
| I-05 字体与资源偏移 | 回退字体、line-height、未加载图片或错误 `object-fit` 改变内容高度。 | 使用精确资源/字体，并在运行证据中等待其就绪。断言文本/图片几何正确后再比较间距。 |
| I-06 响应式约束偏移 | Figma Frame 在多个宽度下都应正常工作。 | 实现声明的 Flex/Grid/约束规则，并分别断言各 viewport；不得只验证设计 Frame 宽度。 |
| I-07 Target 隔离 | 请求只声明一个 target。 | 只按该终端的原生约定实现。断言不得声称实现了未列出的 Web、小程序或 App。 |

I-03 至 I-06 必须把失败和通过的截图交给 `figma-verify`；代码 diff 本身不能关闭用例。

## 实现工作流

1. 编辑前先映射 Figma 组件/状态到目标组件。
2. 按目标项目既有约定增量实现，保护无关代码；不得提交、推送或修改其他 target。
3. 使用精确 Figma 资源；不得手绘替代图标或静默回退系统字体。
4. 运行目标的相关本地检查并记录符合终端的运行证据；视觉验收交给 `figma-verify`。

## 输出契约

返回：

```text
Figma 节点和 target/仓库
设计证据及组件/Token 映射
已修改实现文件
布局责任层和已批准的 absolute 定位案例
完成的检查和截图
已知视觉/行为缺口
供 figma-verify 使用的节点到代码链接
```
