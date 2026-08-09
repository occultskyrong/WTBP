# WTBP Agent 使用指引

WTBP 沉淀的是与场景绑定的软件与产品决策知识，不是通用答案或提示词片段的集合。

本文件与 `CLAUDE.md` 的提交和 PR 规则必须保持一致；两者都是中文的自动化协作入口。

## 何时使用

面对技术、成本、安全、合规或可逆性取舍显著的决策时，先使用
`skills/practice-search/SKILL.md`，再给出建议。应从
`knowledge/catalog.yaml` 开始，只按需加载相关 Practice、证据和参考实现。

## 必须输出

说明当前场景、缺失的决策变量、使用的 Practice ID、候选方案及取舍、建议、证据、
剩余风险和验证方法。不得将 `stale` 或 `deprecated` 内容作为默认建议。

## 贡献边界

项目专有事实应保留在使用方项目的规则文件中。只有具备明确适用范围、反例、可追溯
证据和验证方法的可复用决策知识，才应贡献到这里。提交前遵循 `CONTRIBUTING.md`，并
运行 `make validate` 和 `make review-staged`。

## 自动化提交与 PR

### 授权边界

- 修改、暂存、提交、推送、创建 PR、合并 PR 是独立动作；只有用户明确要求某一步时，
  才执行该步骤。
- 不使用 `git reset --hard`、强制推送、自动 rebase、自动 stash 或 `--no-verify`。
- 发现与当前任务无关的未提交文件、未知提交或远端分歧时，停止并报告；不得将其带入
  当前提交。

### 提交

1. 在 `master` 外创建或使用 `<type>/YYMMDD_short-description` 分支。
2. 精确暂存本任务文件，不使用 `git add .` 或 `git add -A`。
3. 运行 `make validate`、`make review-staged` 与适用的专项验证。
4. 使用 `<type>(<optional-scope>): 中文说明` 创建 Conventional Commit；`type` 保持
   英文，说明文字使用中文，标题不超过 72 个字符。

### 推送与 PR

1. 推送前确认工作区干净、目标远端和分支名称正确；首次推送使用上游关联。
2. 创建 PR 时以 `master` 为目标分支，标题与说明使用中文，并完整填写 PR 模板中的
   影响和验证信息。
3. 仅当当前 PR 的 `WTBP 仓库检查 / 仓库验证` 成功后，才称为可合并；旧提交、其他
   分支或 push 事件的成功不能替代当前 PR 的检查。
4. 合并、关闭 PR、解决冲突或处理 Dependabot 更新都需要单独明确授权。遇到依赖更新
   与当前修复重复时，先比较内容；不得为了消除冲突而合并重复 PR。
