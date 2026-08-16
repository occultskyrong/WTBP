# WTBP 的 Claude 协作指引

英文规范源：[CLAUDE.md](CLAUDE.md)。本文件是面向人类阅读的中文同步译文，不作为默认 Claude 入口。

`AGENTS.md` 定义常驻边界；本文件补充 Claude 的渐进读取与交付规则。遵循
[docs/document-language-policy.md](docs/document-language-policy.md) 中的语言规范。

## 开始任何任务

1. 阅读 `AGENTS.md`，遵守其授权、语言和远程访问边界。
2. 运行 `git status --short --branch`，确认分支和无关改动。
3. 阅读中文 `README.md` 了解仓库导航，只加载本任务需要的路由或文档。
4. 不默认读取整个 `knowledge/` 或全部 Skill 引用。

## 渐进路由

| 任务信号 | 先读 | 目标结果 |
|---|---|---|
| 比较技术、成本、安全或合规方案 | `skills/practice-search/SKILL.md` | 有场景边界的建议与证据边界 |
| 使用、安装、新增或修改 Skill | `wtbp "<请求>"`、`knowledge/skill-index.yaml`、`knowledge/external-capabilities.yaml` | 能力比较、复用判断、安装边界或 Skill/Eval 贡献 |
| 调整仓库规则或自动化 | 相关中文 `docs/` 和源文件 | 改动范围、影响和验证 |
| 提交或推送 | `docs/commit-conventions.md` | 符合规范的 Git 交付 |
| 创建或合并 PR | `docs/commit-conventions.md` | GitHub 治理和 PR 模板 |
| 排查校验、Hook 或 CI | `Makefile` 和相关 `tooling/` | 可复现的定位与验证 |

高影响决策从 `knowledge/catalog.yaml` 开始，只加载目标 Practice、证据、参考实现或 Skill。发现 Skill 时先看
`knowledge/skill-index.yaml` 中的本地 Skill，再看 `knowledge/external-capabilities.yaml` 中的外部能力，最后看
`knowledge/skill-routes.yaml`：前两者分别是对应能力卡的唯一来源，路由只负责任务匹配和另行受管的安装。
优先使用当前的 `approved` 内容，不把 `stale` 或 `deprecated` 作为默认依据。
所有 Skill 相关工作都要遵循 `knowledge/skill-framework.zh-CN.md`：完成输入、边界、执行、输出和完成门禁后再声明结果，
并保持登记/Eval 关系图同步。

## 执行

- 存在 `.codegraph/` 时，代码或结构探索优先使用 CodeGraph。
- 非简单的实施、重构、调试或审查任务应用 `karpathy-guidelines`。
- 改动、暂存、提交、推送、创建 PR 和合并必须分别获得用户授权。
- 不执行任何基于 SSH 的远程访问；需要时由用户运行命令并返回脱敏输出。

## 交付

决策类任务说明场景、缺失变量、Practice ID、候选方案与取舍、建议、证据、剩余风险和验证方法。改动类任务还要
说明范围、实际执行的命令及结果、未验证项和下一步授权。

提交前运行 `make commit-checklist`。提交和 PR 的说明使用中文；工具标识、路径、ID 和 Conventional Commit
类型保持英文。
