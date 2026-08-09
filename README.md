# WTBP — What's The Best Practices

WTBP 是面向软件研发的场景化最佳实践知识库与可复用 Skill 仓库。

它沉淀的不是脱离场景的标准答案，而是可追溯的决策知识：在什么约束下比较哪些方案、
为什么推荐某种方案、如何执行以及如何验证。

## 1. 如何使用

### 查找方案

1. 明确问题场景、约束、风险和需要验证的结果。
2. 从 [`knowledge/catalog.yaml`](knowledge/catalog.yaml) 查找候选 Practice，或调用 [`skills/practice-search`](skills/practice-search/SKILL.md)。
3. 阅读目标 Practice 的适用边界、推荐规则、证据和参考实现。
4. 将最终选择和取舍写入使用方项目的决策记录。

### 执行流程

Practice 负责“如何判断”，Skill 负责“如何执行”。只有稳定、可重复的流程才沉淀为 Skill；
Skill 应引用 Practice，不复制 Practice 的完整内容。

### 贡献内容

新增或修改 Practice、Skill、参考实现或评测前，先阅读 [`CONTRIBUTING.md`](CONTRIBUTING.md)。

## 2. AI 与智能体读取顺序

为快速建立全局认知，按以下顺序读取：

1. [`AGENTS.md`](AGENTS.md)、[`CLAUDE.md`](CLAUDE.md)：协作边界、输出契约和授权规则。
2. [`docs/how-to-use.md`](docs/how-to-use.md)：知识库的使用方式和对象关系。
3. [`knowledge/catalog.yaml`](knowledge/catalog.yaml)：可发现对象索引。
4. 只加载目录指向的目标 Practice、证据、参考实现或 Skill；不要一次性读取全部模式和模板。
5. 需要执行流程时，再读取目标 Skill 的 `SKILL.md` 及其按需引用的内容。

## 3. 项目结构

| 目录 | 用途 |
|---|---|
| `docs/` | 概念、使用方式和治理说明 |
| `knowledge/` | Practice、目录、模式和贡献模板 |
| `skills/` | 可执行的检索与工作流 |
| `tooling/` | 仓库校验、内容审查和 Git Hook |
| `.github/` | Issue、PR、CI 和 Dependabot 配置 |

## 4. 本地校验

```bash
make validate          # 校验仓库结构
make install-hooks     # 启用提交门禁（每个克隆仓库一次）
make review-staged     # 审查暂存内容
```

提交前必须通过 `make validate` 和 `make review-staged`。提交、PR 和 GitHub 治理细节见：

- [`docs/commit-conventions.md`](docs/commit-conventions.md)
- [`docs/github-governance.md`](docs/github-governance.md)
