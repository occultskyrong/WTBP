# 提交规范

## 分支

除紧急修复外，使用 `<type>/YYMMDD_short-description` 创建分支，例如 `feat/260808_issue-forms`。`master` 只接收通过审查和 CI 的变更。

## 提交消息

提交标题必须符合 Conventional Commits：

```text
<type>(<optional-scope>): <summary>
```

允许的 `type`：`feat`、`fix`、`docs`、`refactor`、`test`、`chore`、`ci`、`build`、`perf`。标题不超过 72 个字符；破坏性变更使用 `!`。

```text
feat(practice): add schema-design guidance
fix(search): reject deprecated practices by default
docs!: revise the contribution contract
ci: enforce commit message validation
```

一次提交只表达一个可审查的意图。若需要补充背景、取舍或风险，在正文说明；关联 Issue 时使用 `Closes #123`。

## 提交前

1. 精确暂存需要提交的文件，不使用 `git add .` 或 `git add -A`。
2. 运行 `make validate` 和 `make review-staged`。
3. 不使用 `--no-verify` 绕过 Hook。
4. 提交后通过 PR 审查和 CI，再合并到 `master`。
