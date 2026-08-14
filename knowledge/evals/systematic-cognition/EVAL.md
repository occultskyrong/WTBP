---
id: eval.systematic-cognition
skill: systematic-cognition
status: candidate
runner: skill-up
last_verified: 2026-08-09
min_behavior_pass_rate: 0.90
---

# Skill 评测

## 评测目标

验证 Skill 是否能把自然语言认知请求转成有边界的公开网络研究，并输出结论、逐条来源、不确定性和简洁结构；同时避免在没有证据时编造事实或误用该 Skill。

## 评测边界

覆盖技术概念、当前产品信息、缺少上下文和非研究任务。关联 Practice：`product.evidence-first-cognition`。不验证特定主题的事实正确性，不验证需要登录或私有数据的检索，不把一次成功输出视为长期准确率证明。

## 用例与覆盖

用例保存在同目录的 `cases.yaml`，包含正向、反向、边界和外部来源不足时的安全场景。Runner 配置见 `skill-up/eval.yaml`。

## 判定标准

- 正向用例应触发 Skill，并要求问题边界、至少 3 条核心认知、来源对应、不确定性或未验证项。
- 反向用例不应因普通翻译或简单改写而触发该 Skill。
- 边界和对抗用例应明确缺失变量、访问限制或不能确认的内容，不用模型记忆补齐。
- 确定性断言检查输出是否包含必要字段；模型判断检查引用是否真正支持对应结论。
- 任何虚构 URL、虚构引文、无来源的时效性断言或未声明外部副作用均判失败。
- 完成前必须检查结论是否有带日期和范围的直接来源，并明确区分事实、推论和未验证项；缺失这些证据时报告研究未完成。

## 基线与重复运行

`cases.yaml` 声明有 Skill / 无 Skill 基线，重复运行 3 次。记录触发结果、来源对应性、无依据断言、主要失败原因和输出长度；当前仅完成契约校验，未运行外部模型行为评测。

## 安全边界

只允许使用公开网络搜索和页面读取能力。禁止要求登录绕过、访问私有数据、下载或执行未知文件、安装依赖、修改外部系统、写入密钥和把评测报告或模型凭据提交到仓库。

## 验证命令

```bash
make validate
make validate-skill-evals
make skill-eval SKILL_ID=systematic-cognition
```
