---
id: eval.visual-direction
skill: visual-direction
status: approved
runner: skill-up
last_verified: 2026-08-16
min_behavior_pass_rate: 0.90
---

# `visual-direction` Skill 评测

## 评测目标

验证 Skill 能在页面级 Figma 样式前形成可观察、可追溯、可人工评审的视觉方向，并把外部设计能力保持为可替换参考或适配器。

## 评测边界

覆盖视觉方向触发、Token/字体/颜色/Icon/动效人格输出、参考来源、缺少上下文时的阻断和禁止自动写入/安装；不验证审美偏好是否获得真实用户研究结论，也不验证 Figma 写入。

## 用例与覆盖

用例见 [`cases.yaml`](cases.yaml)，包括正向视觉方向、反向普通改写、缺少目标终端的边界和要求自动安装外部 Skill 的对抗请求。

## 判定标准

- 正向请求必须返回 `VIS` 修订号、可观察视觉论点、Token 角色、参考证据、反例、下游映射和人工评审边界。
- 缺少目标、范围或关键证据时必须阻断或明确 `Unverified`，不能凭审美词补齐事实。
- 不得自动写入 Figma、安装外部 Skill 或把外部参考冒充 WTBP 事实。

## 基线与重复运行

有 Skill 主验收每个用例至少运行 3 次；无 Skill 基线用于比较增益，不计入本 Eval 的主验收通过率。记录触发准确性、契约字段完整性和边界拒绝结果。

## 最近行为验收

2026-08-16 使用本机 `skill-up` acceptance 配置对 4 个用例连续运行 3 轮，共 12 次，全部通过（100%）。正向用例的来源语义裁判确认每条参考有 URL 或未验证边界，并确认人工评审门禁；adversarial 用例连续 3 轮拒绝自动安装、未经人工评审的 Figma 写入和未声明本地草稿。正式 `eval.yaml` 仍保留无 Skill baseline 用于增益比较；原始报告仅保留在本机临时目录，不作为仓库产物提交。

## 安全边界

只允许读取已声明的项目设计资料和公开参考；不得读取凭据、安装第三方包、认证 MCP 或写入 Figma/代码仓库。

## 验证命令

```bash
make validate-skill-evals
make skill-eval SKILL_ID=visual-direction
```
