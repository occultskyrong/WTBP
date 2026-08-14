---
name: example-skill
description: 描述可重复执行的任务，以及智能体必须使用该技能的具体场景。
---

# 示例技能

## 输入契约

- 必需输入、假设、可选输入和最小阻断澄清。

## 工作流

1. 收集执行任务所需的场景变量。
2. 读取关联 Practice 及其证据，而不是复制其中的知识。
3. 按输出契约给出可验证的结果。

## 边界

- 声明非目标、副作用、权限、外部依赖和失败即停止条件。

## 输出契约

- 稳定结果字段、产物或 ID、未解决项和响应语言。

## 完成门禁

- 写明确定性检查、人工或外部检查，以及阻断完成的明确条件。

## 配套评测

在 `knowledge/evals/<skill-name>/` 创建 `EVAL.md` 和 `cases.yaml`，并在
`knowledge/catalog.yaml` 的 `evals` 中登记。至少覆盖正向触发、反向不触发和边界场景；
涉及工具、权限或外部副作用时增加对抗用例。提交前运行 `make validate`、
`make validate-skill-evals` 和 `make review-staged`。
