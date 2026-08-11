# Skill 评测规范

Skill 是可执行流程，Eval 是证明该流程有效、可重复和边界清晰的契约。新增或修改 Skill
必须同步维护对应 Eval；没有评测的 Skill 只能保持 `draft`，不得标记为 `approved`。

## 评测目录

每个 Skill 的评测位于 `knowledge/evals/<skill-id>/`：

- `EVAL.md`：评测目标、边界、判定标准、安全边界和验证命令。
- `cases.yaml`：正向、反向、边界用例；涉及工具或权限时增加对抗用例。
- `skill-up/eval.yaml` 与 `skill-up/cases/`：当 Runner 选择 `skill-up` 时使用的原生执行配置。

评测必须在 `knowledge/catalog.yaml` 的 `evals` 中登记，并通过目录、Skill 和 Eval 的关系
保持可追溯。评测结果、模型凭据、缓存和生成报告不提交到仓库。

## 最小覆盖

每份 `cases.yaml` 至少有 3 个用例，并包含：

1. `positive`：应该使用 Skill 的任务。
2. `negative`：不应该使用 Skill 的任务。
3. `boundary`：缺少上下文、权限或其他关键条件的任务。

涉及写文件、执行命令、外部服务、敏感数据或不可逆操作时，还必须覆盖 `adversarial` 或
等价的安全场景。

每个用例都必须写明 `prompt`、`expect_skill` 和至少一个断言。断言应优先使用可重复的文件、
结构、命令或字段检查；模型评审只能作为补充，不能替代确定性断言。

## 评测维度

- 结构：Frontmatter、目录、引用和渐进式披露符合 Skill 规范。
- 触发：正向请求能触发，负向请求不误触发。
- 效果：有 Skill 的结果优于无 Skill 基线，或明确证明其在格式、风险或成本上的价值。
- 稳定：同一用例至少重复运行 3 次，并记录失败原因。
- 安全：没有密钥泄露、越权访问、危险命令或未声明副作用。

默认不采用单一总分。必须先通过安全和结构硬门禁，再结合触发率、任务通过率、基线增益和
重复运行结果决定 `candidate`、`approved` 或 `improve`。高影响、安全、合规或不可逆流程
必须有人类审查。

## 执行入口

```bash
make validate-skill-evals
make skill-eval SKILL_ID=<skill-id>
```

`make validate` 会包含评测契约校验；`make review-staged` 会阻止新增或修改 Skill 时缺少
对应 Eval。如果评测目录包含 Runner 原生配置，`make skill-eval` 会默认使用它；没有配置时只校验
契约并明确提示尚未运行行为评测。也可以通过 `SKILL_EVAL_CONFIG` 指定其他配置，例如：

```bash
SKILL_EVAL_CONFIG=/path/to/eval.yaml \
SKILL_EVAL_RUNS=3 \
make skill-eval SKILL_ID=practice-search
```

只检查 Runner 配置、不调用模型时使用 `SKILL_EVAL_DRY_RUN=true`。

行为评测使用可插拔 Runner：默认可接入 `skill-up`，也可使用 Caliper 或受控的内部 Runner。
安装了 `skill-up` 时，`make validate-skill-evals` 还会自动执行其离线配置校验；也可以通过
`SKILL_UP_BIN=/path/to/skill-up` 指定 Runner。Runner、模型和密钥只在执行环境提供，不写入
`EVAL.md` 或用例。

### 安装 `skill-up`

`skill-up` 是可选的行为评测 Runner。安装只影响本机，不会把 Runner、模型凭据、缓存或评测报告写入
仓库。建议使用官方安装脚本，并在安装后记录实际版本；不要把安装脚本下载的二进制文件提交到 Git。

```bash
mkdir -p /tmp/wtbp-skill-up-bin
INSTALL_DIR=/tmp/wtbp-skill-up-bin \
  bash -c 'curl -fsSL https://raw.githubusercontent.com/alibaba/skill-up/main/install.sh | INSTALL_DIR=/tmp/wtbp-skill-up-bin bash'
/tmp/wtbp-skill-up-bin/skill-up --version
```

如果系统已有 `skill-up`，可以跳过安装，或通过 `SKILL_UP_BIN` 显式指定路径。安装完成后先做不调用模型的
离线检查：

```bash
SKILL_UP_BIN=/tmp/wtbp-skill-up-bin/skill-up make validate-skill-evals
```

运行行为评测时，`skill-up` 会根据 `knowledge/evals/<skill-id>/skill-up/eval.yaml` 加载 Skill 和用例，
并把提示词与上下文交给配置的 Agent Engine。只有在执行环境已完成认证、且明确允许向外部模型服务发送这些
评测内容时，才运行真实评测；否则使用 dry-run 检查命令和用例是否可发现：

```bash
SKILL_UP_BIN=/tmp/wtbp-skill-up-bin/skill-up \
SKILL_EVAL_DRY_RUN=true \
SKILL_EVAL_RUNS=1 \
make skill-eval SKILL_ID=practice-search
```

获得授权并准备好认证后，再按目标 Eval 的要求重复至少 3 次：

```bash
SKILL_UP_BIN=/tmp/wtbp-skill-up-bin/skill-up \
SKILL_EVAL_RUNS=3 \
make skill-eval SKILL_ID=practice-search
```

更多 Runner 用法参见 [skill-up CLI 文档](https://alibaba.github.io/skill-up/guide/cli-reference) 和
[评测编写指南](https://alibaba.github.io/skill-up/guide/writing-evals)。

### 本地别名 `ske`

`skill-evaluation` 的本地快捷别名是 `ske`。别名只改变调用方式，不改变 Skill 的规范名称、目录或
`knowledge/catalog.yaml` 中的登记。完成本机链接后，在 Claude 或 Codex 中输入“使用 `ske` 评估这个 Skill”
即可加载同一份 `skills/skill-evaluation/SKILL.md`。

仓库内还提供同名 Make 入口。默认评测 `skill-evaluation` 自身，也可以指定需要评测的 Skill：

```bash
make ske
make ske SKILL_ID=practice-search
```

如需在另一台机器重新建立 Agent 别名，可执行：

```bash
ln -s /Users/jiachenclaw/code/WTBP/skills/skill-evaluation ~/.claude/skills/ske
ln -s /Users/jiachenclaw/code/WTBP/skills/skill-evaluation ~/.codex/skills/ske
```

目标路径已经存在时不要覆盖；先确认它是否是指向本仓库 Skill 的符号链接。

## 生命周期

Skill 修改了触发词、工作流、输出契约、工具权限或关联 Practice 时，必须更新 Eval 并重新
运行受影响用例。Practice 状态、证据或参考实现变化时，也要复核关联 Eval；评测过期时将其
标记为 `stale`，不得继续作为批准依据。
