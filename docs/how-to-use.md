# 使用方式

## 作为人类知识库

从目录中找到与问题最接近的实践条目（Practice），先核对适用场景和不适用场景，再比较候选方案。将最终选择写入项目自己的决策记录（Decision Record）。

## 作为智能体上下文

项目规则文件只应链接到 WTBP 和项目事实。智能体先读取 [`knowledge/skill-index.yaml`](../knowledge/skill-index.yaml) 了解
能力、输入输出和副作用，再读取 [`knowledge/skill-routes.yaml`](../knowledge/skill-routes.yaml) 将问题路由到已有 Skill，
然后按需加载目标 `SKILL.md`。遇到高影响、缺少内部模式或需要比较替代方案的问题时，
调用 `practice-search`；需要全网搜索和来源核验时，调用 `systematic-cognition`。不要因为问题不同就自动新建 Skill。

## 作为自动化能力

只有流程稳定且可重复的部分才沉淀为 Skill。Skill 应先收集上下文，再引用 Practice，最后输出建议和验证结果。
如果已有 Skill 能覆盖问题，优先复用；外部 Skill 只有在来源、版本、权限、安装范围和验证方式都登记后才允许安装。

## 作为跨模型适配基线

规范源集中在 `knowledge/`、`skills/`、`knowledge/skill-index.yaml` 和 `knowledge/catalog.yaml`；不同 Agent 的规则文件只
保留项目事实、硬约束和 WTBP 入口，不手工复制知识。需要适配时，应由工具根据规范源生成
对应的 `AGENTS.md`、Skill 入口或其他工具专有规则。

## 作为评测基线

所有新建或修改的 Skill 都必须有 `knowledge/evals/<skill-id>/EVAL.md` 和 `cases.yaml`。
至少覆盖正向触发、反向不触发和缺少场景变量的边界案例；涉及工具、权限或副作用时增加
对抗用例。跨模型评测比较场景识别、Practice 引用、证据边界和可执行验证，不要求模型使用
完全一致的措辞。完整规范见 [`docs/skill-evaluation.md`](skill-evaluation.md)。
