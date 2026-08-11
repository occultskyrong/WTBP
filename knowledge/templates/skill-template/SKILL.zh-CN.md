---
name: example-skill
description: 描述可重复执行的任务，以及智能体必须使用该技能的具体场景。
---

# 示例技能

1. 收集执行任务所需的场景变量。
2. 读取关联 Practice 及其证据，而不是复制其中的知识。
3. 按输出契约给出可验证的结果。
4. 执行或说明验证方法，并报告尚未验证的风险。

## 配套评测

在 `knowledge/evals/<skill-name>/` 创建 `EVAL.md` 和 `cases.yaml`，并在
`knowledge/catalog.yaml` 的 `evals` 中登记。至少覆盖正向触发、反向不触发和边界场景；
涉及工具、权限或外部副作用时增加对抗用例。提交前运行 `make validate`、
`make validate-skill-evals` 和 `make review-staged`。
