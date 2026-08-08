# WTBP — What's The Best Practices

WTBP 是一个面向软件研发的最佳实践知识库与可复用 Skill 仓库。它不把“最佳实践”视为脱离场景的标准答案，而是把它沉淀为可追溯的决策知识：在什么约束下比较哪些方案、为何推荐某种方案、如何执行和验证。

## 核心对象

| 对象 | 作用 |
|---|---|
| Practice | 场景、约束、方案对比、推荐规则与反模式 |
| Evidence | 支撑判断的官方资料、测试、案例与验证日期 |
| Reference Implementation | 带适用边界和验证方式的参考实现 |
| Skill | 触发、检索、执行、输出与校验流程 |
| Decision Record | 某次具体决策采用、调整或拒绝方案的理由 |
| Eval | 证明知识或 Skill 在真实案例中有效的测试集 |

## 快速开始

1. 先在 [`ontology/context-schema.yaml`](ontology/context-schema.yaml) 中描述问题的关键场景变量。
2. 通过 [`registry/catalog.yaml`](registry/catalog.yaml) 找到候选 Practice，或调用 [`skills/practice-search`](skills/practice-search/SKILL.md)。
3. 阅读 Practice 的推荐规则、证据和参考实现，再形成项目自己的 Decision Record。
4. 如需重复执行，再由关联 Skill 产出方案、代码或检查结果。

运行基础结构检查：

```bash
make validate
```

启用提交门禁（每个克隆仓库只需一次）：

```bash
make install-hooks
```

提交前 Hook 会对暂存内容按类型审查；CI 会在 PR 与推送时复跑同一检查。也可在提交前手动运行：

```bash
make review-staged
```

## 设计边界

- `AGENTS.md` 等项目规则只保存本地事实、约束和 WTBP 入口；不要复制整个知识库。
- Practice 负责“如何判断”，Skill 负责“如何稳定执行”，两者不重复维护同一份知识。
- 参考实现必须说明适用场景、版本和验证方式；代码片段本身不是证据。
- Registry 是唯一人工维护的索引来源；面向网站或不同 Agent 的索引应由工具生成。

详见 [`docs/concepts.md`](docs/concepts.md)、[`docs/how-to-use.md`](docs/how-to-use.md)、[`docs/governance.md`](docs/governance.md) 和 [`docs/github-governance.md`](docs/github-governance.md)。
