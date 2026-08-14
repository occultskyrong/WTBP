---
id: eval.figma-verify
skill: figma-verify
status: candidate
runner: skill-up
last_verified: 2026-08-14
min_behavior_pass_rate: 0.90
---

# `figma-verify` Skill 评测

## 评测目标

验证 Skill 能只针对用户声明的 targets 建立验收矩阵，并以结构、布局和视觉证据定位 Figma 与实现之间的偏差。

## 评测边界

覆盖单 target 验收、普通摘要不触发、缺失验收 target，以及 V-01 至 V-07 的保真诊断场景；不验证真实浏览器、开发者工具、设备农场或像素阈值。

## 用例与覆盖

用例见 [`cases.yaml`](cases.yaml)。每个保真用例要求保留失败基线、定位首个原因、在明确授权时修复、并以同一矩阵复验，覆盖 absolute、父级链、层叠、字体/资源、响应式、状态和 target 范围。`skill-up` 用例保持同样覆盖。

## 判定标准

- 只验证声明 targets，不默认增加 Web、小程序或 App。
- 每个 target 必须有适用 viewport/设备、状态和运行证据。
- 有意义偏移必须分类并输出第一个布局责任层及预期/实际证据。
- 截图差异、静态检查或一次看似合理的截图均不能单独证明验收通过。

## 证据基础

- Figma 将结构、组件、Variables、Auto Layout 和注释作为向 AI 表达设计意图的关键信息；仅有截图不足以表达布局和行为。[Figma：Structure your Figma file for better code](https://developers.figma.com/docs/figma-mcp-server/structure-figma-file/)
- Figma 推荐先获取精确节点的结构和截图，随后用项目约定实现，再回到 Figma 验证外观与行为。[Figma：Add custom rules and instructions](https://developers.figma.com/docs/figma-mcp-server/add-custom-rules/)
- Playwright 的视觉比较依赖基准图；浏览器、操作系统、字体和环境会影响截图，因此基准与复验必须在同一环境运行。[Playwright：Visual comparisons](https://playwright.dev/docs/test-snapshots)

## 基线与重复运行

启用有 Skill / 无 Skill 基线，每个用例至少运行 3 次。记录矩阵完整性、差异诊断和人审边界；dry-run 不代表真实终端验收已通过。要证明问题解决，真实夹具必须有同一节点、target、状态、viewport/设备和数据条件下的失败基线、首因诊断、修复后截图及人工复核。

## 安全边界

报告模式只读取指定 Figma 节点和用户提供的运行证据。修复模式必须有明确授权，且只修复首个已证实原因；不得读取密钥、部署、提交、推送或改动未声明 target。

## 验证命令

```bash
make validate-skill-evals
make skill-eval SKILL_ID=figma-verify
```
