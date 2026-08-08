# WTBP — What's The Best Practices

WTBP 是一个面向软件研发的最佳实践知识库与可复用技能（Skill）仓库。它不把“最佳实践”视为脱离场景的标准答案，而是把它沉淀为可追溯的决策知识：在什么约束下比较哪些方案、为何推荐某种方案、如何执行和验证。

## 核心对象

| 对象 | 作用 |
|---|---|
| 实践（Practice） | 场景、约束、方案对比、推荐规则与反模式 |
| 证据（Evidence） | 支撑判断的官方资料、测试、案例与验证日期 |
| 参考实现（Reference Implementation） | 带适用边界和验证方式的参考实现 |
| 技能（Skill） | 触发、检索、执行、输出与校验流程 |
| 决策记录（Decision Record） | 某次具体决策采用、调整或拒绝方案的理由 |
| 评测（Eval） | 证明知识或 Skill 在真实案例中有效的测试集 |

## 快速开始

1. 先在 [`ontology/context-schema.yaml`](ontology/context-schema.yaml) 中描述问题的关键场景变量。
2. 通过 [`registry/catalog.yaml`](registry/catalog.yaml) 找到候选实践条目（Practice），或调用 [`skills/practice-search`](skills/practice-search/SKILL.md)。
3. 阅读 Practice 的推荐规则、证据和参考实现，再形成项目自己的决策记录（Decision Record）。
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

## 中文协作与智能体入口

面向贡献者、评审者和使用者的文档、Issue、PR 描述与校验提示默认使用中文；文件路径、YAML 字段、Practice/Skill 标识、Conventional Commit 的 `type` 及 GitHub 自动关键字等机器可识别内容保持原样。

- [`AGENTS.md`](AGENTS.md)：所有智能体的仓库协作约定与改动边界。
- [`CLAUDE.md`](CLAUDE.md)：Claude Code 的专用入口，说明阅读顺序、验证和交付要求。
- [`CONTRIBUTING.md`](CONTRIBUTING.md)：人工与自动化贡献流程、中文约定和审查要求。

## 提交、推送与 PR

1. 从最新 `master` 创建主题分支，建议命名为 `<type>/YYMMDD_简短说明`；不要直接向 `master` 提交。
2. 仅暂存本次改动，依次运行 `make validate` 和 `make review-staged`，修复校验问题后再提交。
3. 使用 Conventional Commits：`<type>(可选范围): 中文说明`。例如：`docs: 补充 Claude 协作指引`。
4. 提交、推送、创建 PR 和合并是四个独立动作。推送后以 `master` 为目标分支创建 PR，按中文模板说明背景、改动、验证与风险；通过当前 PR 的 `WTBP 仓库检查 / 仓库验证` 后再进行人工评审和合并。

禁止使用 `--no-verify` 绕过本地检查，也不要使用 `git add .` 或 `git add -A` 将无关改动一并提交。完整约定见 [`docs/commit-conventions.md`](docs/commit-conventions.md) 与 [`docs/github-governance.md`](docs/github-governance.md)。

## 设计边界

- `AGENTS.md` 等项目规则只保存本地事实、约束和 WTBP 入口；不要复制整个知识库。
- Practice 负责“如何判断”，Skill 负责“如何稳定执行”，两者不重复维护同一份知识。
- 参考实现必须说明适用场景、版本和验证方式；代码片段本身不是证据。
- Registry 是唯一人工维护的索引来源；面向网站或不同 Agent 的索引应由工具生成。

延伸阅读：[概念与关系](docs/concepts.md)、[使用方式](docs/how-to-use.md)、[贡献指南](CONTRIBUTING.md)、[提交规范](docs/commit-conventions.md)、[治理说明](docs/governance.md)、[GitHub 治理](docs/github-governance.md)。
