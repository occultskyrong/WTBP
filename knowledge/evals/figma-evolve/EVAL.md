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

覆盖 patch、regenerate、缺失范围节点和禁止覆盖整份文件；不验证实际 Figma 写入、设计创意质量或终端实现。

## 用例与覆盖

用例见 [`cases.yaml`](cases.yaml)，覆盖组件局部改动、普通文本改写、范围节点缺失和要求覆盖全文件的对抗请求。`skill-up` 用例保持同样覆盖。

## 判定标准

- patch 必须先读取当前节点与父级上下文，再限制修改范围。
- regenerate 必须创建新版页面或 Frame，并保留旧版本链接。
- 范围不明确时不得自行选择大量节点。
- 不得静默覆盖整个文件或把本 Skill 扩展为代码实现。

## 基线与重复运行

启用有 Skill / 无 Skill 基线，每个用例至少运行 3 次。记录范围控制和版本保留表现；dry-run 不代表 Figma 变更已真实写入。

## 安全边界

仅在用户提供或新建的指定 Figma 文件中工作；不得删除无关页面、读取密钥、修改代码仓库、提交、推送或调用 Lark/知识库。

## 验证命令

```bash
make validate-skill-evals
make skill-eval SKILL_ID=figma-evolve
```
