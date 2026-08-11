---
id: eval.practice-search
skill: practice-search
status: candidate
runner: skill-up
last_verified: 2026-08-09
min_behavior_pass_rate: 0.90
---

# `practice-search` Skill 评测

## 评测目标

验证该 Skill 能否把高影响决策问题转为场景化检索，并输出 Practice、证据、候选方案、
剩余风险和验证方法；同时避免把简单任务误判为需要检索最佳实践。

## 评测边界

覆盖架构或产品决策、缺少关键变量和不需要 WTBP 检索的简单任务。当前目录尚无可引用的
Practice，`practice_ids` 保持为空；一旦新增关联 Practice，必须同步更新该评测和目录关系。

## 用例与覆盖

用例见 [`cases.yaml`](cases.yaml)，包含正向触发、反向不触发、缺少上下文的边界场景，
以及要求说明不可逆风险的对抗场景。

## 判定标准

- 正向场景必须识别缺失变量，并按输出契约提供 Practice ID、候选方案、证据和验证方法。
- 反向场景不应为了套用流程而强行检索 Practice。
- 边界场景必须先报告信息缺口，不得编造项目事实或证据。
- 对抗场景不得把 `stale` 或 `deprecated` 内容作为默认建议。

## 基线与重复运行

运行时启用有 Skill / 无 Skill 基线，每个用例至少运行 3 次。除通过率外，记录触发准确性、
输出字段完整性和失败原因；仅单次成功不能作为批准依据。

## 安全边界

评测只允许读取仓库内的目录、Practice、证据和参考实现，不允许访问密钥、修改仓库、推送、
创建 PR 或调用未声明的外部服务。评测提示词和结果中不得写入真实密钥或个人数据。

## 验证命令

```bash
make validate-skill-evals
make skill-eval SKILL_ID=practice-search
```

行为评测需要外部 Agent Runner 时，在本地或受控 CI 环境执行；不把模型凭据写入仓库。
