# WTBP Agent 使用指引

WTBP 沉淀的是与场景绑定的软件与产品决策知识，不是通用答案或提示词片段的集合。
本文件是所有智能体的常驻最小规则；详细流程按任务路由按需加载。

## 第一层：始终遵守

- 先确认任务场景、目标、约束和所需证据；不要把模型生成内容当作唯一依据。
- 项目专有事实留在使用方项目；只有具备适用范围、反例、可追溯证据和验证方法的知识才贡献到 WTBP。
- `stale` 或 `deprecated` 内容不得作为默认建议。
- 修改、暂存、提交、推送、创建 PR、合并 PR 是独立授权动作；未获明确授权时停在当前阶段。
- 保护无关改动、未知提交和远端分歧；不使用强制推送、自动 rebase、自动 stash、`git reset --hard` 或 `--no-verify`。
- 不提交密钥、令牌、生成报告、缓存或无关文件。

## 第二层：按任务路由读取

| 任务 | 先读 | 再按需加载 |
|---|---|---|
| 了解仓库 | `README.md` | `docs/how-to-use.md`、`docs/concepts.md` |
| 高影响技术或产品决策 | `skills/practice-search/SKILL.md` | `knowledge/catalog.yaml`、`knowledge/schemas/context-schema.yaml`、目标 Practice 及关联证据 |
| 新增或修改 Practice | `CONTRIBUTING.md` | `knowledge/templates/practice-template.md`、`knowledge/catalog.yaml`、`knowledge/relationships.yaml` |
| 新增或修改 Skill | `CONTRIBUTING.md` | `knowledge/templates/skill-template/SKILL.md`、关联 Practice、Eval |
| 提交、推送或 PR | `docs/commit-conventions.md` | `docs/github-governance.md`、`.github/PULL_REQUEST_TEMPLATE.md` |
| 校验、Hook 或 CI 问题 | `Makefile` | `tooling/validate-repository.sh`、`tooling/review-staged.sh`、`.github/workflows/repository-check.yml` |

不要因为看到目录就一次性读取全部模式、模板、证据或 Skill 引用；先用目录索引确定目标，再展开最小相关范围。

## 第三层：工具与探索顺序

仓库存在 `.codegraph/` 时，探索代码或结构优先使用 `codegraph files`、`codegraph explore`、
`codegraph node`；没有索引或问题仅涉及文档时，再使用 `rg` 和定向文件阅读。

## 输出契约

涉及决策时必须说明：当前场景、缺失变量、Practice ID、候选方案及取舍、建议、证据、
剩余风险和验证方法。涉及改动时还要说明：改动范围、验证结果、未验证项和下一步授权。

## 执行顺序

1. `git status --short --branch`，确认工作区和分支。
2. 按上表选择最小读取集合，明确不在本次范围内的内容。
3. 先设计和验证，再实施；验证命令与变更风险匹配。
4. 只执行用户明确授权的交付动作；完成后留下可复核的证据摘要。

详细贡献、提交和 GitHub 规则分别见 [`CONTRIBUTING.md`](CONTRIBUTING.md)、
[`docs/commit-conventions.md`](docs/commit-conventions.md) 和 [`docs/github-governance.md`](docs/github-governance.md)。
