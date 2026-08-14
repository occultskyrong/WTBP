---
id: eval.example-skill
skill: example-skill
status: draft
runner: skill-up
last_verified: 2026-08-09
min_behavior_pass_rate: 0.90
---

# Skill 评测

## 评测目标

说明要验证的关键行为，以及该 Skill 应该改善什么结果。

## 评测边界

说明评测覆盖的场景、未覆盖的场景、依赖的 Practice ID 和前置条件。

## 用例与覆盖

用例保存在同目录的 `cases.yaml`。至少覆盖正向触发、反向不触发和缺少上下文的边界场景。
涉及工具、文件或权限时，再增加对抗或安全用例。

当 `runner` 为 `skill-up` 时，在同目录创建 `skill-up/eval.yaml` 和 `skill-up/cases/`，保持
Runner 配置与本规范的用例覆盖一致；模型和凭据不得写入配置文件。

## 判定标准

说明确定性断言、模型判断、输出契约和失败条件。不能只使用“看起来合理”作为唯一标准。

## 基线与重复运行

默认使用有 Skill / 无 Skill 基线，并至少重复运行 3 次。记录成功率、主要失败原因和成本边界。

## 安全边界

说明允许访问的文件、工具和数据，禁止的命令、路径、密钥和外部副作用。

## 验证命令

```bash
make validate-skill-evals
make skill-eval SKILL_ID=example-skill
```

行为评测依赖的 Agent、模型和密钥不写入仓库；CI 中通过环境变量或受控 Secret 提供。
