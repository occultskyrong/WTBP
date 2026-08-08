# GitHub 治理基线

本文件记录需要在 GitHub 网页端配置的仓库治理规则。它们不能由 Git 中的
文件自行强制；每次仓库迁移、权限变更或新建镜像后均应复核。

## `master` Ruleset

创建一个处于 `Active` 状态、目标为 `master` 的 branch ruleset：

- 要求通过 Pull Request 合并。
- 要求 `WTBP Repository Check / validate` 成功。
- 要求解决评审讨论，禁止 force push 和删除分支。
- 单人维护时审批数为 `0`；有独立维护者后改为 `1`，并启用最新推送后重新审批。
- 启用前先以 `Evaluate` 模式验证；管理员 bypass 只应作为迁移期的恢复手段。

Ruleset 启用后，任何常规变更都必须经由分支和 PR 进入 `master`。不得把本地
Hook 视为远端保护的替代品。

## Actions 与依赖

工作流仅授予所需的最小权限，并将第三方 Action 固定到完整提交 SHA。保留
Dependabot 对 GitHub Actions 的版本更新；更新 PR 必须通过同一套校验后才可合并。

## 安全与公开协作

在 `Settings → Advanced Security` 开启 Dependency graph、Dependabot alerts 和
Dependabot security updates。启用私密漏洞报告前，先确定真实的响应负责人、响应
时限与升级路径，再提交 `SECURITY.md`；不要以没有人维护的联系渠道替代安全流程。

本仓库的版本化文档是唯一规范来源。若不计划维护 GitHub Wiki，应在仓库设置中
关闭它，避免形成第二套未审查的规则。公开协作前同样应指定行为准则的处理人，
再添加 `CODE_OF_CONDUCT.md`。
