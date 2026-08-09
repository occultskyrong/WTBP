# WTBP 的 Claude 协作指引

本文件是 Claude Code 的执行路由，和 [`AGENTS.md`](AGENTS.md) 共同构成自动化入口。
`AGENTS.md` 的常驻边界优先；本文件只补充 Claude 的渐进读取、执行和交付方式。
所有说明使用中文；机器标识、路径、YAML 字段、Practice/Skill ID、Conventional Commit
的 `type` 与 GitHub 关键字保留原样。

## 第 0 层：开始任何任务

按以下顺序完成最小上下文建立：

1. 读取 `AGENTS.md`，接受其授权边界和输出契约。
2. 运行 `git status --short --branch`，确认分支、未提交改动和上游关系。
3. 阅读 `README.md` 的“仓库导航”和“AI 最小读取顺序”。
4. 根据任务类型选择下一层内容；不要默认读取整个 `knowledge/` 或全部 Skill 引用。

## 第 1 层：任务路由

| 任务信号 | 必读入口 | 目标输出 |
|---|---|---|
| 需要比较方案、存在技术/成本/安全/合规取舍 | `skills/practice-search/SKILL.md` | 场景化建议与证据边界 |
| 要新增或修改知识条目 | `CONTRIBUTING.md` | Practice/Skill/Eval 贡献或审查结果 |
| 要调整目录、规则或自动化 | `README.md`、相关 `docs/` | 结构决策、影响面和验证结果 |
| 要提交、推送或创建 PR | `docs/commit-conventions.md` | 符合规范的提交或 PR 交付 |
| 要排查校验、Hook 或 CI | `Makefile`、相关 `tooling/` | 可复现的问题定位和修复验证 |

高影响决策再从 `knowledge/catalog.yaml` 开始，按目录条目加载目标 Practice、关联证据、
参考实现或 Skill；优先使用 `approved` 且较新的内容，不把 `stale` 或 `deprecated` 当作默认建议。

## 第 2 层：渐进执行流程

### 发现

先确认事实、调用方、约束、风险和未决变量。仓库存在 `.codegraph/` 时，代码或结构探索
优先使用 `codegraph files`、`codegraph explore`、`codegraph node`；文档问题再使用 `rg` 和定向阅读。

### 聚焦

只加载与当前任务直接相关的文件。Practice 任务通常是“目录条目 → Practice → 证据/参考实现”；
Skill 任务通常是“Skill → 关联 Practice → 按需 references/scripts/assets”。

### 输出

决策类输出必须包含：场景、缺失变量、Practice ID、候选方案及取舍、建议、证据、剩余风险和验证方法。
改动类输出必须额外包含：改动范围、验证命令及结果、未验证项和下一步授权。

### 交付

修改、暂存、提交、推送、创建 PR 和合并是独立动作。只执行用户明确授权的阶段；
发现无关脏改动、未知提交或远端分歧时先报告，不自动恢复、覆盖、rebase、stash 或强制推送。

## 第 3 层：提交与 PR 细节

需要进入 Git 交付时才读取 [`docs/commit-conventions.md`](docs/commit-conventions.md) 和
[`docs/github-governance.md`](docs/github-governance.md)，并遵守以下摘要：

1. 不直接在 `master` 提交，使用 `<type>/YYMMDD_short-description` 分支。
2. 精确暂存文件，运行 `make validate`、`make review-staged` 和适用的专项验证。
3. 使用 `<type>(<optional-scope>): 中文说明`，标题不超过 72 个字符；禁止 `git add .`、
   `git add -A`、`--no-verify`、强制推送和无范围 tag 推送。
4. PR 以 `master` 为目标，填写中文模板；只有当前 PR 的
   `WTBP 仓库检查 / 仓库验证` 成功后才可称为可合并。

## 第 4 层：完成检查

结束前形成证据摘要：工作区和分支、实际改动、验证命令及结果、未验证边界、是否提交/推送/创建 PR，
以及仍需用户授权的下一步。不要把本地验证、CI 通过、PR 合并或远端运行状态相互替代。
