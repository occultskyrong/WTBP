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
- 修改、暂存、提交、推送、创建 PR、合并 PR 仍是不同的动作边界。但在本仓库中，用户明确说“提交”时，
  即授权执行下面的完整提交交付流程：先执行提交清单，清单通过后提交并推送当前分支。创建或合并 PR
  始终需要单独、明确的授权。
- 保护无关改动、未知提交和远端分歧；不使用强制推送、自动 rebase、自动 stash、`git reset --hard` 或 `--no-verify`。
- 每个独立任务使用一个任务分支；同一任务的增量提交继续使用该分支，不得把新任务追加到范围不明确的旧分支。
  新任务开始前，必须从干净的默认分支运行 `tooling/new-task-branch.sh` 创建任务分支。
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
| 使用、安装、新增或修改 Skill | `wtbp "<请求>"`、`knowledge/skill-index.yaml`、`knowledge/external-capabilities.yaml` | 能力比较、复用决策、目标 Skill、安装边界和贡献指南 |
| 提交或推送 | `docs/commit-conventions.md` | 符合规范的 Git 交付 |
| 创建或合并 PR | `docs/commit-conventions.md` | GitHub 治理和 PR 模板 |
| 校验、Hook 或 CI 问题 | `Makefile` | 校验脚本和仓库工作流 |

先使用目录、本地 Skill 索引、外部能力登记或路由索引确定目标；本地 Skill 索引是本地 Skill 标签和能力卡的唯一来源，外部能力登记是外部能力卡的唯一来源，路由表只负责任务匹配和另行受管的安装；不要因为看到目录就读取全部模板、证据或 Skill 引用。

安装、导入、复制、添加依赖或执行任何外部 Skill 或项目解决方案前，必须先对固定到本地的来源目录运行
`wtbp security-check <固定的本地来源目录>`。缺少报告、返回非零结果或存在待复核发现时，必须失败即停止；只有干净结果才允许继续执行另行授权的安装或采用步骤。

所有 Skill 的变更和执行都必须遵循 [knowledge/skill-framework.zh-CN.md](knowledge/skill-framework.zh-CN.md)。它定义五层架构、
Skill 最小契约、登记关系图、G0–G6 门禁、生命周期状态和失败即停止规则。

## 探索与实施

- 存在 `.codegraph/` 时，代码或结构问题优先使用 `codegraph files`、`codegraph explore`、`codegraph node`；
  文档问题或无索引时再使用 `rg`。
- 非简单的编码、重构、调试或审查任务遵循 `karpathy-guidelines`：明确假设、采用最小改动并验证具体成功标准。
- 交付时说明改动范围、验证结果、未验证边界和下一步所需授权。

## 提交门禁

暂存和提交前运行 `make sync-default-branch`：它会刷新 `origin/<默认分支>`，并在没有其他工作树占用时快进本地默认分支引用。提交前再运行 `make commit-checklist`；它复用该同步基线并检查可合并性，再执行仓库结构校验、暂存内容审查、敏感信息扫描、
变更 Skill 或已登记 Eval 资产的 `skill-up` 契约审查、质量门禁和 `VERSION` 检查。详见
[docs/commit-checklist.md](docs/commit-checklist.md)。

## 提交交付流程

当用户说“提交”（或同义的中文指令）时，按以下顺序执行：

1. 检查工作区、暂存范围、当前分支、任务归属、远端分歧和拟使用的 Conventional Commit 提交消息。
2. 如果当前是默认分支，或无法确认当前分支的任务归属，必须在暂存/提交前停止，使用 `tooling/new-task-branch.sh`
   从干净默认分支创建任务分支；不得自动 stash 或迁移既有改动。
3. 暂存和提交前执行 `make sync-default-branch`。它刷新远端默认分支，并在不离开任务分支的情况下快进本地默认分支引用；若默认分支被另一工作树占用，必须报告该工作树且不得改动它，仍以已刷新的远端引用作为可合并性基线。
4. 执行 `make commit-checklist`。它复用已刷新默认分支，并在不修改工作区的前提下检查可合并性，以及 `VERSION`/`CHANGELOG.md` 是否成对变更；任一检查失败都必须停止，
   不得创建提交或推送。
5. 使用已校验的范围创建提交，提交标题使用中文说明的 Conventional Commit 格式。
6. 将当前任务分支推送到已配置的远端；不得强推或改写历史。`pre-push` Hook 会在刷新默认分支后再次执行可合并性预检。
7. 推送成功后执行 `make return-to-default`。它先刷新默认分支，再把干净且已完整推送的当前工作树切换到默认分支并快进同步（等价于 `pull --ff-only`）。默认分支被另一工作树占用时，必须报告占用路径并安全跳过；不得强制切换或改动另一工作树。该步骤用于分支卫生，不能替代可合并性预检。
8. 核验远端分支和分支归位结果，分别报告提交和推送结果。创建 PR 不属于此流程，只有用户另行明确要求时才执行。版本变更后的内容
   合并到 `master` 时，成功的仓库检查工作流会创建并推送不可变的 `vX.Y.Z` Tag；任务分支不得创建发布 Tag。

如果提交或推送因冲突、权限、凭据缺失或远端分歧失败，必须停在失败步骤，报告准确阻塞原因和下一步需要用户授权
的动作。不得绕过失败门禁、使用 `--no-verify`、强制推送或自动 rebase。用户只说“执行提交清单”时，仅授权校验，
不授权提交或推送。
