---
id: eval.prd-to-figma
skill: prd-to-figma
status: candidate
runner: skill-up
last_verified: 2026-08-14
min_behavior_pass_rate: 0.90
---

# `prd-to-figma` Skill 评测

## 评测目标

验证 Skill 能把 PRD 作为唯一业务事实来源，创建或更新可编辑 Figma 交付物，并返回可追溯的文件和节点链接。

## 评测边界

覆盖新建 Figma、已有文件写入、缺少落点与拒绝 Lark/知识库依赖；不验证真实 Figma MCP 的可用性、品牌创意质量或任何终端代码实现。

## 用例与覆盖

用例见 [`cases.yaml`](cases.yaml)，包括首次 PRD 到 Figma、普通改写、缺少 Figma 落点和要求引入 Lark/知识库的对抗请求。`skill-up` 用例保持同样覆盖。

## 判定标准

- 正向请求必须先形成最小设计简报、需求冲突门禁和带稳定 feature ID 的版本化设计清单，在审批范围内形成设计契约，并返回 Figma 文件和关键节点链接的输出契约。
- 设计交付必须覆盖完整容器页面和物料状态；可见文案要标注已验证来源、`Copy for review` 或画布外设计说明，不得把提案静默当作产品事实。
- 普通改写不得触发本 Skill。
- 未指定新建或已有 Figma 落点时必须指出缺失项。
- 不得把 Lark CLI、知识库或未提供的业务规则当作前置条件或事实来源。
- 通过标准必须包含 Figma 读权限证据、目标节点/Frame、页面组织、截图和节点链接；提示词、节点创建或一次截图不算视觉验收。

## 基线与重复运行

启用有 Skill / 无 Skill 基线，每个用例至少运行 3 次。记录契约完整性、边界拒绝与错误触发；dry-run 不能说明真实 Figma 写入已通过。

## 安全边界

只允许读取用户提供的 PRD 和必要的 Figma 上下文；仅在用户明确要求创建/更新时写入指定或新建 Figma 文件。不得访问 Lark、知识库、密钥、无关文件或执行代码仓库变更。

## 验证命令

```bash
make validate-skill-evals
make skill-eval SKILL_ID=prd-to-figma
```
