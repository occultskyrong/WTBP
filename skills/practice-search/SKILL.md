---
name: practice-search
description: Find, compare, and apply WTBP best practices to a software or product decision. Use whenever an agent needs a reusable implementation pattern, must choose among technical approaches, lacks an internal precedent, or needs to ground a recommendation in documented evidence and reference implementations.
---

# Practice Search

用此 Skill 把模糊问题转为有边界的场景化建议。它不替代项目事实、架构设计或人工评审。

## 工作流

1. 提取问题、已有技术栈、规模、性能、安全合规、成本、团队能力和可逆性；缺少会影响选择的变量时先说明缺口。
2. 阅读 `registry/catalog.yaml`，按领域、标签和状态寻找候选 Practice。
3. 先读候选 Practice 的元数据、适用场景和场景化推荐规则；只在需要支撑判断时加载证据、参考实现或关联 Skill。
4. 比较候选方案与当前约束，明确采用、调整或拒绝的原因。不要把 `stale` 或 `deprecated` 内容作为默认建议。
5. 输出验证方法；如果建议进入不可逆、高成本、安全或合规决策，要求人工确认。

## 输出契约

按以下字段返回：

```text
问题与当前场景
缺失或尚未获得的关键变量
使用的 Practice ID
候选方案与权衡
建议：采用 / 调整 / 拒绝
证据与参考实现
反模式和剩余风险
验证方法与人工确认点
```

## 资源

- 读取 [catalog-contract.md](references/catalog-contract.md) 了解目录、状态和检索边界。
