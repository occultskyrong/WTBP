---
name: skill-router
description: 为用户请求发现并路由到最小适用的 WTBP Skill。当用户询问该使用哪个 Skill、输入 `wtbp`、希望通过一个入口使用多个 Skill、需要复用或安装 Skill，或任务可能命中多个 Skill 时使用。
---

# Skill 路由

先路由，不要把全部 Skill 合并到本 Skill，也不要加载所有 `SKILL.md`。

## 工作流

1. 识别用户目标、约束、所需证据，以及请求是否需要先发现 Skill 而不是直接执行。
2. 已知领域时运行 `wtbp list --domain <领域>` 浏览，已知 Skill 名称时运行 `wtbp show <skill-id>` 查看能力卡；需要推荐时运行 `wtbp "<用户请求>"`。
3. 比较能力、输入输出或副作用前读取 `knowledge/skill-index.yaml`；只在解释任务匹配时读取 `knowledge/skill-routes.yaml`。
4. 如果只有一个明确命中的活跃本地路由，只读取该路由对应的 `SKILL.md` 并遵循其流程。
5. 如果命中多个路由，展示候选、边界和推荐项；运行高影响流程前要求用户选择。
6. 如果唯一命中活跃的外部路由，且其登记了 `auto_install: true`，运行 `wtbp install <skill-id>`；否则只展示其来源、版本、固定提交、权限、安装范围和验证方式，不安装。
7. 如果没有路由命中，说明原因。只有任务会重复出现、流程稳定，且能编写正向、反向、边界和必要对抗 Eval 时，才建议新建 Skill。

## 边界

- 路由器绝不执行选中的 Skill。它只可安装唯一命中的、活跃的、GitHub HTTPS 来源、固定 40 位提交且明确标记 `auto_install: true` 的外部路由。
- 不自动安装任意 URL、未固定版本、`candidate`、`stale` 或 `deprecated` 路由，也不覆盖非 WTBP 管理的 Skill 链接。
- 不要因为请求含有泛化关键词，就把简单翻译、改写或一次性编辑路由为 Skill。
- 不默认选择 `stale` 或 `deprecated` 路由。
- 路由必须可解释：说明命中的关键词和缺少的上下文。
- `skill-index.yaml` 是能力标签和能力卡的唯一来源；不要从路由关键词手工推断能力。

## 输出契约

按用户语言输出；本仓库默认使用中文。包含：

```text
用户目标与场景
使用的能力视图：list / show / recommend
命中的 Skill 候选及关键词
推荐路由与边界
下一步需要读取的内容或命令
安装或授权要求（如有）
未命中原因或缺失上下文
```
