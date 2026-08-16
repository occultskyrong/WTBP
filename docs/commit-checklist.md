# 提交执行清单

提交不是只执行 `git commit`。每次提交都必须经过同一份执行清单，保证结构、内容、敏感信息、Skill
评测、版本和提交消息规则一起被检查。清单入口是：

```bash
make commit-checklist
```

Git Hook 会自动调用该入口；CI 在检查提交范围时也使用同一套规则。清单失败时不得使用
`--no-verify` 绕过。

## 每次提交的固定检查

执行顺序如下：

1. `make validate`：检查仓库结构、目录登记、模式、模板和 Skill Eval 契约。
2. `make review-staged`：只审查本次暂存内容，检查对象字段、章节、目录关系、补充 Eval 和安全边界。
3. `tooling/scan-secrets.sh`：扫描新增内容中的私钥、云访问密钥、GitHub/Slack/Google Token、JWT、带凭据连接串、
   疑似密码/密钥赋值和高风险凭据文件名。扫描器只输出文件和命中类型，不输出敏感值；示例凭据必须使用明确的
   `example`、`sample`、`placeholder` 等占位词。二进制变更默认不能通过文本扫描，需改为可审查的文本或单独评估。
4. Skill/Eval 变更检查：发现新增或修改 `skills/*/SKILL.md`，或修改 `knowledge/evals/<skill-id>/` 下已登记的
   Eval、通用用例或 Skill-up 原生用例/配置时，必须对受影响 Skill 执行 `make ske SKILL_ID=<skill-id>`。Skill 变更
   仍必须同步修改对应 Eval；Eval 的 `runner` 必须为 `skill-up`，行为门槛不得低于 `0.90`。默认 dry-run 也必须由
   skill-up 加载 Runner 配置、Skill、用例和断言。
5. 质量门禁检查：Skill Eval 的契约覆盖率必须为 100%；用例至少 3 次运行，并包含正向、反向和边界，
   涉及副作用时还必须包含对抗用例。真实行为评测的默认通过率门槛为 90%。
6. 版本、提交消息和范围一致性检查：核对根目录 `VERSION` 是否符合三段式版本和本次变更级别；范围模式还会
   检查提交标题、长度和 MAJOR 变更说明。
7. 版本 Tag 发布计划：版本未变则不发布；版本变更时，清单记录预期 `vX.Y.Z`。Tag 不在本地 Hook、任务分支或 PR
   阶段创建；PR 合并到 `master` 且仓库验证通过后，由 GitHub Action 创建并推送不可变注释 Tag。

执行清单检查的是“命令确实执行并通过”，不依赖人工勾选。评测结果、凭据、缓存和报告仍保留在本机，
不得提交到仓库。

敏感信息扫描的独立回归测试为：

```bash
make test-secret-scan
```

## Skill 评测门禁

`ske` 是 `skill-evaluation` 的本地快捷名称。对新增或修改的 Skill，以及任何已登记 Eval 资产的变更，提交清单会强制使用 `skill-up` Runner，至少执行：

```bash
make ske SKILL_ID=<skill-id>
```

执行清单默认使用 `SKILL_EVAL_DRY_RUN=true`，因此不会调用外部模型；它证明 Skill-Up 契约可以加载，但不等同于
真实行为质量通过。具备认证并明确允许发送评测内容时，执行真实行为评测：

```bash
SKILL_EVAL_RUNS=3 \
SKILL_EVAL_OUTPUT_DIR="$PWD/.wtbp-evals/<skill-id>/commit" \
make ske SKILL_ID=<skill-id>
```

真实评测必须满足对应 `EVAL.md` 中不低于 `0.90` 的 `min_behavior_pass_rate`；安全断言失败时，即使总通过率达到
门槛也不能通过。需要把行为评测设为当前提交的硬门禁时，使用：

```bash
WTBP_REQUIRE_BEHAVIOR_EVAL=true \
SKILL_EVAL_DRY_RUN=false \
SKILL_EVAL_RUNS=3 \
make commit-checklist
```

这会要求每个受影响 Skill 生成本次评测报告并达到门槛。CI 和无外部模型的本地环境使用 dry-run，只能证明
契约门禁，不能宣称行为评测已通过。

## 三段式版本规则

当前版本记录在根目录 [`VERSION`](../VERSION)，格式固定为 `MAJOR.MINOR.PATCH`。版本只代表 WTBP
规范和可复用内容的对外认知，不代表每个 Git 提交都必须增加数字。

| 级别 | 适用变更 | 示例 | 版本动作 |
|---|---|---|---|
| MAJOR | 不兼容的规则、字段、目录、Skill 输出契约或治理流程变化 | 删除必填字段、改变评测判定含义 | 主版本加 1，次版本和补丁归零；提交标题使用 `!` 并说明 `BREAKING CHANGE` |
| MINOR | 向后兼容的新能力或新知识对象 | 新增 Practice、Skill、Eval、可选门禁或发布自动化 | 次版本加 1，补丁归零 |
| PATCH | 已有契约不变的修复和可复用内容修订 | 修正规则错误、补充证据、修复校验脚本 | 补丁加 1 |
| 不变 | 不改变规范、行为或可发现内容的微小修改 | 排版、错别字、注释、链接文字调整 | 不修改 `VERSION` |

“小变动不升版”只适用于最后一行；一旦修改 `knowledge/**`、`skills/**`、`tooling/**`、治理文件、
目录、Eval、Hook、CI 或本清单覆盖的规范，应按 PATCH、MINOR 或 MAJOR 判断，不能用“改动很小”规避版本检查。
一次提交只应选择一个最高变更级别；若同时包含多个级别，按最高级别升级，并在提交说明中写明取舍。

版本 Tag 是合并后的发布快照，不是 PR 进度标记。版本比较使用显式 `tags/v旧版...tags/v新版`；PR 比较仍使用
`master...任务分支`。同名 Tag 已存在且不指向当前 `master` 提交时，发布工作流必须失败，禁止移动、删除或重打 Tag。

范围模式（CI 的 Pull Request 检查）还会复核每个非合并提交的 Conventional Commit 标题和 72 字符限制；
引入 MAJOR 版本的提交必须使用 `!` 或在正文声明 `BREAKING CHANGE:`。

## 提交前人工确认

自动清单通过后，提交者仍需确认：

- 暂存区没有无关文件、密钥、令牌、缓存、报告或生成物。
- 敏感信息扫描没有发现高风险文件名或疑似凭据；新增二进制文件已单独确认用途和来源。
- 变更范围与 Issue、分支和提交标题表达的是同一个意图。
- 真实行为评测若未执行，PR 说明中明确写出“仅完成契约/dry-run，未完成外部模型评测”。
- 版本升级与上表级别一致；不变更版本时，确认确实没有改变对外规则或可发现内容。
