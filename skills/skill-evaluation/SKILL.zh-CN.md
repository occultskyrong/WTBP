---
name: skill-evaluation
description: 评估一个 Agent Skill 的结构、触发边界、行为效果、稳定性和安全风险，并根据已登记的 Eval 生成可复核的中文结论。需要审查、验收、回归或比较 Skill 时使用。
---

# Skill 评测

这个 Skill 负责组织评测，不替代目标 Skill 的功能，也不把一次成功运行当作质量证明。
本 Skill 的本地快捷别名为 `ske`；别名不改变规范名称 `skill-evaluation`，也不改变评测目录。

## 工作流

1. 确认目标 Skill、版本或提交、关联 Practice、评测范围和可用 Runner；缺少这些信息时先列出缺口。
2. 从 `knowledge/catalog.yaml` 找到目标 Skill 和对应 `knowledge/evals/<skill-id>/EVAL.md`，只按需读取用例和引用。
3. 运行 `make validate-skill-evals`，先完成结构、目录、字段、用例覆盖和安全边界检查。
4. 按 Eval 中的正向、反向、边界和对抗用例执行行为评测；有条件时运行有 Skill / 无 Skill 基线，至少重复 3 次。
5. 区分确定性断言、模型判断和人工判断；失败时记录用例、实际结果、期望结果和是否为评测缺陷。
6. 输出评测结论，不自动修改目标 Skill、提交、推送、创建 PR 或合并。

## 输出契约

```text
目标 Skill 与版本
评测范围和关联 Practice
结构与安全检查
触发结果：正向 / 反向 / 边界 / 对抗
行为结果：有 Skill / 无 Skill / 重复运行 / 主要失败原因
确定性证据与模型判断边界
结论：approved / candidate / improve / stale / deprecated
剩余风险、未验证项和下一步
```

## 判定规则

- 没有对应 `EVAL.md` 或 `cases.yaml` 时，只能报告为 `improve`，不得批准。
- 结构或安全硬门禁失败时，不得用高功能分数抵消。
- 正向、反向和边界覆盖缺失时，评测不完整；涉及工具、权限或副作用时必须检查对抗场景。
- 不把 `stale` 或 `deprecated` Practice、过期证据或模型猜测当作默认依据。
- 行为 Runner、模型凭据和外部服务必须由执行环境提供；禁止把密钥写入提示词、用例或报告。

## 入口

```bash
make validate-skill-evals
make skill-eval SKILL_ID=<skill-id>
```

评测目录存在 Runner 原生配置时，默认执行该 Runner；也可以通过 `SKILL_EVAL_CONFIG` 指定其他配置。
没有 Runner 配置时，只完成契约校验并明确报告未运行行为评测。
