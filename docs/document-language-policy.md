# 文档语言与命名规范

WTBP 同时服务于人类读者和 AI。语言和文件名必须直接表达受众，避免同一目录中出现无法判断用途的
中英文重复文档。

## 基本规则

| 内容 | 规范语言 | 命名 | 说明 |
|---|---|---|---|
| 面向人类的 README、`docs/`、贡献指南、Issue、PR、治理说明 | 中文 | `<name>.md` | 中文为默认和主阅读体验。 |
| AI 的规则入口与可执行指令 | 英文 | 固定入口名，如 `AGENTS.md`、`CLAUDE.md`、`SKILL.md` | 英文为机器加载的规范源。 |
| AI 文档的中文译文 | 中文 | `<name>.zh-CN.md` | 与英文规范源同目录、同层级，不作为默认机器入口。 |
| 机器可读数据、路径、ID、YAML 字段、命令 | 英文或既定格式 | 不追加语言后缀 | 保持工具兼容性。 |
| 面向中文用户的提示词、示例输入、UI 文案、评测用例 | 中文 | 保持原文件名 | 语言应与目标用户和被测输入一致。 |

## 规范源与同步

1. AI 文档以英文 `.md` 为规范源；中文 `.zh-CN.md` 是同内容译文，不得擅自增加或删减规则。
2. 修改 AI 文档时，必须在同一变更中同步更新中文译文；仅语言表达允许不同，规则、路径、命令和边界必须一致。
3. 面向人类的中文文档只有在确有外部英文读者需求时才建立 `.en.md` 译文；没有该需求时不制造双份文档。
4. `README.md` 保持中文的人类入口；它只链接 AI 英文规范源和相应中文译文，不复制完整规则。

## 当前 AI 文档

| 英文规范源 | 中文译文 | 用途 |
|---|---|---|
| `AGENTS.md` | `AGENTS.zh-CN.md` | 通用 Agent 规则与任务路由 |
| `CLAUDE.md` | `CLAUDE.zh-CN.md` | Claude 的渐进读取与交付规则 |
| `knowledge/templates/skill-template/SKILL.md` | `knowledge/templates/skill-template/SKILL.zh-CN.md` | 新建 Skill 时使用的 AI 指令模板 |
| `knowledge/skill-framework.md` | `knowledge/skill-framework.zh-CN.md` | 所有 Skill 的五层架构、最小契约和 G0–G6 门禁 |
| `skills/<skill-id>/SKILL.md` | `skills/<skill-id>/SKILL.zh-CN.md` | 可执行 Skill 指令 |
| `skills/<skill-id>/references/<name>.md` | `skills/<skill-id>/references/<name>.zh-CN.md` | 按需加载的 AI 参考材料 |

新增 AI 文档前先确认它是否真的需要被机器加载。若只是解释使用方式、贡献流程或治理背景，应放在
中文 `docs/` 中，而不是创建新的 Agent 入口。
