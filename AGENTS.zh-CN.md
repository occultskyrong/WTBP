# WTBP Agent 使用指引

英文规范源：[AGENTS.md](AGENTS.md)。本文件是面向人类阅读的中文同步译文，不作为默认机器入口。

WTBP 沉淀的是与场景绑定的软件与产品决策知识，不是通用答案或提示词片段的集合。本文件是所有智能体的
常驻最小规则；详细流程仅在任务需要时按需加载。

## 语言规范

- 面向人类的文档默认使用中文：`README.md`、`docs/`、贡献指南、Issue 和 PR 文本。
- AI 入口、可执行指令及其按需加载的参考资料使用英文：`AGENTS.md`、`CLAUDE.md`、
  `skills/**/SKILL.md` 和 `skills/**/references/*.md`。
- 每份 AI 文档必须有同目录的 `<name>.zh-CN.md` 中文译文，并在同一次变更中同步更新。
- 路径、ID、YAML 字段、命令和面向用户的测试提示保持其所需语言与既定格式。
- 新增文档或译文前先阅读 [docs/document-language-policy.md](docs/document-language-policy.md)。

## 始终遵守

- 先确认任务场景、目标、约束和所需证据；不要把模型生成内容当作唯一依据。
- 项目专有事实留在使用方项目；只有具备适用范围、反例、可追溯证据和验证方法的知识才贡献到 WTBP。
- `stale` 或 `deprecated` 内容不得作为默认建议。
- 修改、暂存、提交、推送、创建 PR、合并 PR 是独立授权动作。
- 保护无关改动、未知提交和远端分歧；不使用强制推送、自动 rebase、自动 stash、`git reset --hard` 或 `--no-verify`。
- 不提交密钥、令牌、生成报告、缓存或无关文件。

## 远程访问硬边界

不得代用户执行任何 SSH 或基于 SSH 的远程访问，包括 `ssh`、`scp`、`sftp`、`rsync`、`mosh`、
`autossh`、`sshpass`、`ssh-keyscan`、Git SSH 远端、Docker SSH context 或任何包装方式；只读检查和诊断
同样禁止。需要远程信息时，提供用户可执行的命令，并仅基于用户返回的脱敏输出继续。

## 任务路由

| 任务 | 先读 | 再按需加载 |
|---|---|---|
| 了解仓库 | `README.md` | `docs/how-to-use.md`、`docs/concepts.md` |
| 高影响技术或产品决策 | `skills/practice-search/SKILL.md` | `knowledge/catalog.yaml`、上下文模式、目标 Practice 和证据 |
| 新增或修改 Practice | `CONTRIBUTING.md` | Practice 模板、目录、关系 |
| 使用、安装、新增或修改 Skill | `knowledge/skill-routes.yaml`、`docs/skill-routing.md` | 目标 Skill、Practice、Eval、贡献指南 |
| 提交、推送或创建 PR | `docs/commit-conventions.md` | GitHub 治理和 PR 模板 |
| 校验、Hook 或 CI 问题 | `Makefile` | 校验脚本和仓库工作流 |

先使用目录或路由索引确定目标；不要因为看到目录就读取全部模板、证据或 Skill 引用。

## 探索与实施

- 存在 `.codegraph/` 时，代码或结构问题优先使用 `codegraph files`、`codegraph explore`、`codegraph node`；
  文档问题或无索引时再使用 `rg`。
- 非简单的编码、重构、调试或审查任务遵循 `karpathy-guidelines`：明确假设、采用最小改动并验证具体成功标准。
- 交付时说明改动范围、验证结果、未验证边界和下一步所需授权。

## 提交门禁

提交前运行 `make commit-checklist`。它会执行 `make validate`、暂存内容审查、变更 Skill 的 `ske` 契约评测、
质量门禁和 `VERSION` 检查。详见 [docs/commit-checklist.md](docs/commit-checklist.md)。
