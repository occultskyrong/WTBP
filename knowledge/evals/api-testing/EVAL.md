---
id: eval.api-testing
skill: api-testing
status: candidate
runner: skill-up
last_verified: 2026-08-29
min_behavior_pass_rate: 0.90
---

# `api-testing` Skill 评测

## 评测目标

验证该 Skill 能把接口测试请求分解为 L1 可用性探针、L2 真实主流程、L3 Mock 逻辑与契约、L4 业务逻辑链，并保持真实运行证据、Mock 证据、数据隔离、清理策略和 CI 门禁的边界清晰。

## 评测边界

覆盖四层选择、接口契约、正反向用例、CRUD 状态链、环境和数据安全、失败分类与报告要求；不执行真实生产请求，不绑定某个项目的框架，不验证具体服务的业务事实。

## 用例与覆盖

用例见 [`cases.yaml`](cases.yaml)，覆盖四层正向方案、CRUD 状态链、缺少运行边界、简单改写反向场景、把 Mock 冒充生产证据和无限重试掩盖失败的对抗场景。

## 判定标准

- 正向请求必须输出四层矩阵，并说明每层目标、真实/Mock 边界、数据策略和门禁。
- CRUD 请求必须包含隔离范围、顺序状态断言和清理动作，不能要求共享环境全局为空。
- 缺少环境、认证或写入边界时必须标记 `Unverified` 或阻断真实写请求。
- 不得把 Mock、单元测试、覆盖率或生成报告称为部署成功或真实运行通过。
- 必须给出失败分类、可追踪报告字段和人工确认点。

## 基线与重复运行

有 Skill 主验收每个用例至少运行 3 次；无 Skill 基线用于比较触发和输出增益，不计入主验收通过率。记录四层识别准确性、输出字段完整性、真实/Mock 边界和安全失败原因；单次成功不能作为批准依据。

## 安全边界

评测只允许读取仓库内 Skill、Practice、Eval 和文档，不允许访问凭据、调用生产写接口、修改外部系统、安装第三方依赖或声称执行了未执行的运行时测试。

## 验证命令

```bash
make validate-skill-evals
make skill-eval SKILL_ID=api-testing
```
