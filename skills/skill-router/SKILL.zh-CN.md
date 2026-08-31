---
name: skill-router
description: 为用户请求发现并路由到最小适用的 WTBP Skill。当用户询问该使用哪个 Skill、输入 `wtbp`、希望通过一个入口使用多个 Skill、需要复用或安装 Skill，或任务可能命中多个 Skill 时使用。
---

# Skill 路由

先路由，不要把全部 Skill 合并到本 Skill，也不要加载所有 `SKILL.md`。

## 输入契约

- 用户任务、目标、约束、所需证据，以及任何安装或副作用请求。
- 语义意图、目标领域或验收边界缺失时返回 `clarify`，不能猜测。

## 工作流

1. 识别用户目标、约束、所需证据，以及请求是否需要先发现 Skill 而不是直接执行。
2. 先运行 `wtbp root`，把输出记为 `<wtbp-root>`。即使当前工作区是使用方产品仓库，它也会定位到 WTBP 仓库；不得相对当前工作区解析 WTBP 路径。
3. 已知领域时运行 `wtbp list --domain <领域>` 浏览本地 Skill，运行 `wtbp external --domain <领域>` 浏览外部能力卡；已知名称时运行 `wtbp show <id>` 查看任一类能力卡；需要推荐时运行 `wtbp "<用户请求>"` 获取本地与外部候选及命中依据。`wtbp` 不会启动第二个 LLM 会话。
4. 本地 Skill 卡读取 `<wtbp-root>/knowledge/skill-index.yaml`，外部能力卡读取 `<wtbp-root>/knowledge/external-capabilities.yaml`。由当前 Agent/Claude 会话比较意图、输入、输出、阶段、副作用、权威性、权限和可用证据。
5. 可能涉及外部能力、参考实现或新建本地 Skill 时，加载 `references/external-capability-selection.md`。除 `select`、`clarify` 或 `no_match` 外，还必须给出一个采用决策：`direct-use`、`adapt`、`compose`、`reference-only` 或 `build-local`。
6. 如果只有一个明确命中的活跃本地路由，只读取 `<wtbp-root>` 下该路由对应的 `SKILL.md` 并遵循其流程。`local-adapter` 外部能力不能替代所选本地 Skill 的契约。
7. 如果命中多个路由或能力卡，展示边界与推荐顺序；运行高影响流程前要求用户选择。
8. 如果唯一命中活跃且另行登记为 `auto_install: true` 的外部安装路由，先确认语义匹配和安装边界，再显式运行 `wtbp install <skill-id>`。能力卡发现本身绝不安装；`manual-optional` 卡必须先获得明确授权，并单独核对来源、固定版本、许可证、权限、凭据和执行环境。
9. 当用户说出 `wtbp，收集 <公开 URL>` 时，将其视为创建一条新的未安装最佳实践记录的明确授权。立即加载 `external-capability-curation`：它读取公开来源、去重、抽取场景和至少两个 Case，再写入来源记录与能力卡；绝不创建安装路由。既有记录的覆盖或修订替换仍需单独授权。
10. 若语义比较后没有任何已登记的本地或外部能力明确适配，在提出 `build-local` 前先选择 `external-capability-discovery`。它先记录本地 `no_match`，再通过 `find-skills`/skills.sh、GitHub 和一手公开来源对临时候选排名；其中主张级公开网络证据使用 `systematic-cognition` 的来源规则。已有本地 Skill 明确足够时，不得启动在线发现。
11. 只有外部发现已评估既有来源、任务重复稳定，并且能编写正向、反向、边界和必要对抗 Eval 时，才建议 `build-local`。

## 边界

- 路由器绝不执行选中的 Skill。候选发现绝不安装；只有当前会话确认唯一命中的、另行登记的、活跃的、GitHub HTTPS 来源、固定 40 位提交、明确标记 `auto_install: true` 且通过 `wtbp security-check <本地候选目录>`、没有阻断或待复核发现的外部路由后，才可显式运行 `wtbp install <skill-id>`。不走该安装器的项目解决方案，在导入、安装依赖或执行前也必须经过同一安全校验门禁。
- 不自动安装任意 URL、未固定版本、`candidate`、`stale` 或 `deprecated` 路由，也不覆盖非 WTBP 管理的 Skill 链接。
- 不要因为请求含有泛化关键词，就把简单翻译、改写或一次性编辑路由为 Skill。
- 不默认选择 `stale` 或 `deprecated` 路由。
- 路由必须可解释：说明命中的关键词和缺少的上下文。
- `skill-index.yaml` 是本地 Skill 标签和能力卡的唯一来源，`external-capabilities.yaml` 是外部能力卡的唯一来源；不要从路由关键词手工重建任何一类能力。
- 不得因没有关键词命中就推荐新建本地 Skill。可能新增能力时，先检索/复用证据并加载 `references/external-capability-selection.md`。
- 不得把路由器的关键词计数当作语义契合度。只有当前会话排除明确本地选择后，才可加载 `external-capability-discovery`；路由器本身绝不进行网络搜索。
- 当前会话的语义判断在加载并确认目标 Skill 范围前都只是建议。路由阶段绝不能安装、执行、写入 Figma 或扩大权限；唯一的留存元数据例外是新的 `wtbp，收集 <公开 URL>` 记录，其写入边界由 `external-capability-curation` 定义。

## 输出契约

按用户语言输出；本仓库默认使用中文。包含：

```text
用户目标与场景
使用的能力视图：list / show / recommend
命中的本地 Skill、外部能力候选及关键词
推荐路由、采用决策与边界
本地优先结论，以及在线发现是暂缓还是已选择
下一步需要读取的内容或命令
安装或授权要求（如有）
未命中原因或缺失上下文
```

## 完成门禁

- 结果必须是 `select`、`clarify` 或 `no_match`，并包含匹配证据、一个采用决策、边界和下一步读取/命令。
- 关键词匹配不能当作语义执行；发现阶段不能安装或运行 Skill，外部能力卡也不能当作安装指令。
- 在线外部发现只能在本地优先语义判断后选择，且只返回排名候选；不得安装、执行或登记外部内容。
- 只有明确授权且来源、固定版本、权限和验证均通过后，才能报告安装完成。
