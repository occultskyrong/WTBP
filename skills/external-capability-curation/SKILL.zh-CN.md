---
name: external-capability-curation
description: 将用户提供的公开 GitHub 项目、外部 Skill、官方集成或参考实现收录为未安装、可搜索的 WTBP 外部最佳实践卡。当用户说出 `wtbp，收集 公开 URL`，或发送仓库或 Skill URL 并要求收集、登记、记忆、分类或让它在后续方案搜索中可被发现但不安装时使用。
---

# 外部能力收录

一次收集证据，后续安全复用。本 Skill 写入受治理的发现元数据，绝不安装第三方内容。

## 输入契约

- 必需：公开仓库、Skill 或官方来源 URL，以及用户希望收录而不只是讨论它的明确意图。`wtbp，收集 <公开 URL>` 是创建新收录记录的明确授权；新记录写入前不得再次索要确认。
- 可选：已知使用场景、目标技术或终端、期望采用边界和固定修订。
- URL 缺失、私有、不可访问，或用户未要求留存时，只返回草案分析，不写入登记文件。

## 工作流

1. 在当前会话打开用户提供的来源。记录规范 URL、发布方、来源类型、许可证、可见修订或 Release、访问日期与可见的维护/社区证据。不得从仓库名称或模型记忆推断事实。
2. 阅读相关来源文件（存在时包含 `SKILL.md`）。识别实际解决的问题、输入、输出、支持的技术/终端、副作用、权限、明确非目标和安装边界。
3. 读取 [card-contract.md](references/card-contract.md)。按规范 URL、发布方/仓库身份、固定修订和 Skill 路径查询 `knowledge/external-sources.yaml` 与 `knowledge/external-capabilities.yaml`。对既有记录，先展示差异；覆盖、替换修订或新增第二张卡前仍需明确授权。
4. 对新来源，自动创建一条来源记录和一张最佳实践能力卡。使用稳定的小写连字符 ID、简明中文面向人字段与规范标签。除非用户另行授权更严格审查，默认 `status: candidate`、`adoption: reference-only`、`availability: reference` 和 `installation_status: uninstalled`。
5. 填写检索契约：`solves`、`not_for`、`scenarios`、`cases`、`inputs`、`outputs`、`technologies`、`targets` 与 `keywords`。`scenarios` 说明适用情形；`cases` 至少给出两个后续应命中的中文任务请求。每个短语都必须描述后续可匹配的用户问题或约束，不能只用发布方名称作为检索信号。
6. 仅写入 `knowledge/external-sources.yaml` 与 `knowledge/external-capabilities.yaml`；不得创建安装路由。随后展示来源证据、去重结论、最佳实践场景/Case 与未来 `wtbp` 命中信号。
7. 运行来源与外部能力校验及聚焦的 `wtbp "<代表性请求>"` 查询。报告卡片 ID、未来命中证据、未解决事实，并明确未执行安装。

## 边界

- 仅读取公开来源。不得登录、绕过访问控制、克隆或执行不可信代码、安装包或 Skill、查看凭据或添加安装路由。
- 已收录能力卡只是发现元数据，不是背书、安全审查、运行验收或使用外部内容的授权。
- 未经用户明确确认和当前会话证据，不得覆盖已收录记录、升级状态或替换修订。最初的“收集”授权只覆盖新记录。
- 不得仅因 README 含相关关键词就声称项目能解决某问题。能力、许可证、修订或权限不清晰时，记录 `unverified` 并保持 `candidate`。
- 不得为了保存第三方 URL 新建本地 WTBP Skill。在线比较使用 `external-capability-discovery`，经用户确认的长期留存使用本 Skill。

## 输出契约

使用用户语言；本仓库默认中文。包含：

```text
来源身份和当前会话证据
收录结论：draft-only / collected / duplicate / update-required
能力解决与不解决的问题
未安装最佳实践卡：ID、场景、Case、检索字段、采用方式、状态、权限和安装边界
未来 wtbp 查询示例及预期命中信号
未核验元数据及其影响
校验结果；明确未执行安装
```

## 完成门禁

- 每个留存来源均有已打开的 HTTPS URL、发布方、访问日期、许可证、修订、Skill 路径、质量证据与来源到卡片的关联；未知事实必须说明为何为 `unverified`。
- 卡片的场景、Case、检索字段均非空，且 `installation_status` 明确为 `uninstalled`；它不是安装路由。
- 去重处理明确，任何未核验来源主张均保持 `candidate`。
- 写入后外部能力校验与代表性本地检索通过；否则只保留草案并报告首个阻断问题。
