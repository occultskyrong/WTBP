# 动作组契约

在项目设计契约、整体架构和 `INV-YYYYMMDD-VNN` 已批准后，且在 Icon 抽取、底层窗体、页面特定样式或实现之前建立本契约。它记录可复用的交互原语，避免每个页面自行发明按钮几何或 CSS。

## 契约元数据

```text
action_group_contract_id: AGC-YYYYMMDD-VNN
status: Draft | Approved | Blocked
project_design_contract: PDC-YYYYMMDD-VNN
architecture_revision: ARC-YYYYMMDD-VNN
approved_inventory: INV-YYYYMMDD-VNN
terminal_and_shell:
component_library_or_repository:
owner:
inspection_date:
next_reviewer:
```

## 动作组登记表

| 动作组 ID | 功能/页面/状态 ID | 分类 | 用户结果 | 子项及顺序 | 宽度/槽位策略 | 已登记组件 | 状态 |
|---|---|---|---|---|---|---|---|
| AG-01 |  | `single-action` / `action-group` / `symmetric-navigation` / `segmented-selection` |  |  | `content` / `equal` / `full-span` 和 `natural` / `equal-slot` / `equal-partition` |  | Draft |

`single-action` 只有一个动作和一个完整热区。`action-group` 包含两个或三个相关动作。
`symmetric-navigation` 表达上一项/当前或回到当前项/下一项，必须使用等尺寸边缘槽位。
`segmented-selection` 改变一个互斥选择；不能用于不相关动作。

## 组件与 Token 映射

| 动作组 ID | 子项 ID | 语义动作 | 组件/Variant | 可见文案或 Icon ID | 热区尺寸 | 视觉尺寸 | 间距/圆角/状态 Token | Figma 节点 | 代码映射 |
|---|---|---|---|---|---|---|---|---|---|
| AG-01 | AG-01-01 |  | `IconButton` / `TextButton` / 已批准组件 |  |  |  |  |  |  |

优先使用已经批准的项目组件和 Token 库。可见 Icon 与点击热区是两个独立值：视觉 Icon 按角色通常为 16/20/24/32，热区尺寸按声明终端确定。自定义指针热区通常不得小于 24×24 CSS px，除非记录了间距例外；高频移动端动作使用 44×44 CSS px 或终端等效尺寸。参考 [W3C 点击目标](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum)、[W3C 增强点击目标](https://www.w3.org/WAI/WCAG22/Understanding/target-size-enhanced) 和 [Apple 按钮指南](https://developer.apple.com/design/human-interface-guidelines/buttons)。

## 布局与语义策略

每个动作组必须记录：

- 父级语义和视觉角色：`button`、`group`、`toolbar` 或 `segmented control`；
- 父级是背景/工具栏，还是一个动作本身；多动作父级不得在视觉或语义上伪装成一个大按钮；
- 宽度策略：默认 `content`，只有等优先级常规文本按钮组使用 `equal`，只有声明的容器/场景需要时使用 `full-span`；
- 槽位策略和布局责任层：Flex/Grid/Auto Layout、列或 basis/约束、父级内边距、gap 和响应式行为；
- 状态策略：默认、hover、pressed、focus-visible、selected、disabled、loading，以及仅在需要时记录的不可用原因；
- 每个纯图标或状态型动作的可访问名称和键盘行为。

`symmetric-navigation` 必须使用 `equal-slot`：左、右子项使用同一组件和热区尺寸；中间子项相对父级居中，而非只位于两个不等宽兄弟之间。使用三槽位 Grid 或等效 Auto Layout 约束。不得用手工坐标或 `space-between` 作为严格居中的证明。边缘动作不可用时，保留等尺寸的非动作占位槽，或记录明确布局规则，防止中间项漂移。

## 动作组门禁

1. **分类与范围（`AGC-01`）**：每个获批交互区域均已分类、映射到功能/页面/状态 ID，且组内没有混入不相关动作。
2. **组件复用（`AGC-02`）**：每个子项使用已批准组件/Variant 或记录最小扩展；页面局部克隆、一次性矢量或临时 CSS 不得替代已登记控件。
3. **热区与密度（`AGC-03`）**：热区、Icon/文字视觉尺寸、内边距、gap 和 full-span 例外都已映射 Token 并适配终端；大面积空白描边不得把多个小动作伪装成一个按钮。
4. **分布与居中（`AGC-04`）**：声明的宽度/槽位策略已经由 Auto Layout/Flex/Grid 编码。`equal-slot` 记录左右等尺寸和中间居中容差；`equal` 记录统一宽度/basis 和 gap。
5. **状态与可访问性（`AGC-05`）**：交互状态、对比度、焦点、禁用行为、键盘行为和可访问名称均已记录；纯图标按钮表达动作，不能只表达字形。
6. **实现与证据（`AGC-06`）**：Figma 组件/Token 已映射到目标组件/CSS，并定义验收所需的 Figma/DOM 几何、声明视口/状态、截图和人工复核。

缺少分类、未经批准的 full-span、`symmetric-navigation` 槽位不等、缺少热区证据，或存在页面局部补偿方案时，必须阻断页面特定样式、实现交接和验收。每一项记录 `pass`、`blocked` 或具名的已批准例外。

## 验证记录

| 动作组 ID | 视口/状态 | 左右热区几何 | 中间或分区几何 | Figma/DOM 布局责任层 | 截图/证据 | 结果 | 例外 |
|---|---|---|---|---|---|---|---|
| AG-01 |  |  |  |  |  | pass / blocked |  |
