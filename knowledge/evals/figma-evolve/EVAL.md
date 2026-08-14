---
id: eval.figma-evolve
skill: figma-evolve
status: candidate
runner: skill-up
last_verified: 2026-08-14
min_behavior_pass_rate: 0.90
---

# `figma-evolve` Skill 评测

## 评测目标

验证 Skill 能以已有 Figma 节点为当前设计证据进行局部修改，且在整体重做时保留原版本。

## 评测边界

覆盖 patch、regenerate、缺失范围节点、禁止覆盖整份文件和写入后全页面结构门禁；不验证实际 Figma 写入、设计创意质量或终端实现。

## 用例与覆盖

用例见 [`cases.yaml`](cases.yaml)，覆盖组件局部改动、带明确节点的整体重设计、普通文本改写、范围节点缺失和要求覆盖全文件的对抗请求。`skill-up` 用例保持同样覆盖。

## 判定标准

- patch 必须先读取当前节点与父级上下文，确认已审批的版本化清单与 feature ID，再限制修改范围。
- 面向已有消费项目时，必须先检查实际仓库/运行证据并建立或刷新 `PDC-YYYYMMDD-VNN`，完成 `PDC-01`–`PDC-06` 和冲突确认后才能选择新的页面族、组件基础或整体视觉方向；无消费项目时必须显式记录 `figma-only` 边界。
- 结构变更或 regenerate 必须提供由 PDC 推导的 `ARC-YYYYMMDD-VNN`；小范围 patch 只有在契约和架构均未变化时才能复用旧版本。
- 结构或 Icon 相关变更必须在页面样式前先创建并审批 `INV-YYYYMMDD-VNN`，再建立或确认 `ICON-YYYYMMDD-VNN` 并记录 `IA-01`–`IA-07`；小范围 patch 只有在批准范围、受影响 Icon 的语义映射和资产家族也未变化时才能复用。缺失 Icon 必须独立设计，不得用页面局部替代物。
- regenerate 必须创建新版页面或 Frame，并保留旧版本链接。
- 任何写入前都要明确设计批次、完整容器页面、物料状态和独立右侧标注块（如适用）；文案必须分类并保留来源。
- 范围不明确时不得自行选择大量节点。
- 不得静默覆盖整个文件或把本 Skill 扩展为代码实现。
- 通过必须有节点/Frame、几何与截图证据和人审记录；dry-run 或一次截图不算已验收。
- 每次写入后必须对所有产品页面/状态 Frame 记录 `G-01`–`G-06`：layoutMode/布局责任层、独立右侧 annotation、文字容器边界、实例/Master 宽高比例、目标终端外框高保真和产品内容隔离；未记录或未通过时不得完成。页面描述和技术说明只能出现在右侧独立 annotation 中。
- 新增页面/状态或结构重设计时，必须先完成所有批准页面/状态的底层窗体批次并通过 `BF-01`–`BF-06`，再添加页面级样式；局部 patch 只有在结构契约未变化且已有批准底层基线时才可复用。
- 变更涉及等权导航或嵌套组件时，必须重新验证分布规则、分区中心点和递归父子/祖先边界；不得只检查修改节点或页面外框。

## 基线与重复运行

启用有 Skill / 无 Skill 基线，每个用例至少运行 3 次。记录范围控制和版本保留表现；dry-run 不代表 Figma 变更已真实写入。

## 安全边界

仅在用户提供或新建的指定 Figma 文件中工作；不得删除无关页面、读取密钥、修改代码仓库、提交、推送或调用 Lark/知识库。

## 验证命令

```bash
make validate-skill-evals
make skill-eval SKILL_ID=figma-evolve
```
