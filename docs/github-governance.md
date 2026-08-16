# GitHub 治理基线

本文件记录需要在 GitHub 网页端配置的仓库治理规则。它们不能由 Git 中的
文件自行强制；每次仓库迁移、权限变更或新建镜像后均应复核。

## `master` 规则集（Ruleset）

创建一个处于 `Active` 状态、目标为 `master` 的分支规则集：

- 要求通过 Pull Request 合并。
- 要求 `WTBP 仓库检查 / 仓库验证` 成功。
- 要求解决评审讨论，禁止强制推送和删除分支。
- 单人维护时审批数为 `0`；有独立维护者后改为 `1`，并启用最新推送后重新审批。
- 启用前先以 `Evaluate` 模式验证；管理员绕过权限只应作为迁移期的恢复手段。

规则集启用后，任何常规变更都必须经由分支和 PR 进入 `master`。不得把本地
Hook 视为远端保护的替代品。

## 自动化与依赖

工作流仅授予所需的最小权限，并将第三方 Action 固定到完整提交 SHA。保留
Dependabot 对 GitHub Actions 的版本更新；更新 PR 必须通过同一套校验后才可合并。

`WTBP 仓库检查 / 发布版本 Tag` 是唯一的版本 Tag 发布者：它只在 `master` 的仓库验证成功后、且 `VERSION` 与前一提交
不同的时候，以 `contents: write` 创建并推送不可变注释 Tag `vX.Y.Z`。其他检查任务保持 `contents: read`。同名 Tag 若
已指向当前提交则幂等结束；若指向其他提交则失败，禁止覆盖。PR 使用分支三点比较；发布比较使用显式
`tags/v旧版...tags/v新版`，避免同名分支优先于 Tag 的歧义。

## Issue 内容审查

Issue 新建或编辑时，`WTBP Issue 内容审查 / Issue 内容验证` 会根据标题前缀识别模板，
检查必要章节、Practice ID、实践提案清单和仓库问题环境信息。审查失败只产生失败检查，
不会自动评论、加标签或修改 Issue。

本地可以使用事件 JSON 重放同一检查：

```bash
make review-issue ISSUE_EVENT_PATH=/path/to/event.json
```

## 安全与公开协作

在 `Settings → Advanced Security` 开启依赖关系图、Dependabot 告警和 Dependabot
安全更新。启用私密漏洞报告前，先确定真实的响应负责人、响应
时限与升级路径，再提交 `SECURITY.md`；不要以没有人维护的联系渠道替代安全流程。

本仓库的版本化文档是唯一规范来源。若不计划维护 GitHub Wiki，应在仓库设置中
关闭它，避免形成第二套未审查的规则。公开协作前同样应指定行为准则的处理人，
再添加 `CODE_OF_CONDUCT.md`。
