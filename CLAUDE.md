# WTBP 的 Claude 协作指引

本文件供 Claude Code 在本仓库工作时使用。所有说明以中文呈现；机器标识、文件路径、
YAML 字段、Practice/Skill ID、Conventional Commit 的 `type` 与 GitHub 关键字保留原样。

## 仓库定位

WTBP 是场景化最佳实践知识库。任何推荐都必须基于明确场景、Practice、证据、参考实现
和验证方法，而非将模型生成的结论视为唯一依据。

开始高影响决策前，读取 `skills/practice-search/SKILL.md` 与 `registry/catalog.yaml`；只
按需加载相关对象。输出应说明场景、缺失变量、使用的 Practice ID、方案取舍、建议、
证据、风险和验证方法。

## 工作前检查

1. 阅读本文件、`AGENTS.md`、`CONTRIBUTING.md` 与任务关联的 Practice/Skill。
2. 运行 `git status --short --branch`，确认当前分支、未提交改动和上游关系。
3. 保护无关改动：不恢复、不删除、不覆盖、不暂存无关文件；分歧或目标不明确时先报告。

## 提交规范

提交、推送、创建 PR 与合并 PR 必须视为独立授权。用户未明确要求时，只完成其已授权
阶段，不隐式提交、推送、创建或合并 PR。

1. 不直接在 `master` 提交。使用 `<type>/YYMMDD_short-description` 分支，例如
   `docs/260809_chinese-templates`。
2. 使用精确文件列表暂存；禁止 `git add .`、`git add -A` 与 `--no-verify`。
3. 提交前运行 `make validate` 和 `make review-staged`；按变更风险补充 YAML、Shell、
   范围审查或业务验证。
4. 提交标题使用 `<type>(<optional-scope>): 中文说明`，例如：

   ```text
   docs: 统一中文贡献模板
   ci: 补齐 PR 审查历史
   feat(practice): 增加数据库建模实践
   ```

   允许的 `type` 是 `feat`、`fix`、`docs`、`refactor`、`test`、`chore`、`ci`、
   `build`、`perf`；标题不超过 72 个字符。

## 推送与 Pull Request

1. 推送前再次确认远端、分支和工作区；只推送用户授权的单一分支，不使用 `--all` 或
   无范围的 tag 推送。
2. PR 的目标分支为 `master`。标题、摘要、变更影响和验证说明使用中文，并完整填写
   `.github/PULL_REQUEST_TEMPLATE.md`。
3. PR 只有在当前提交的 `WTBP 仓库检查 / 仓库验证` 成功时才可合并。不得把其他分支、
   旧提交或单独 push 的成功误认为当前 PR 已通过。
4. 不自动合并。合并方式、解决冲突、关闭 PR、重新触发 Dependabot 或变更保护规则，都
   需要用户再次明确授权。

## 质量与安全边界

- Practice、Skill、参考实现和目录必须保持一致；对新增、修改或删除的对象运行仓库门禁。
- 面向贡献者的文档、PR、Issue、模板和校验提示使用中文；保留机器兼容字段。
- 不提交密钥、访问令牌、生成报告、缓存或无关文件。
- 本地验证、CI 通过、PR 合并和远端运行状态是不同证据，不得互相替代。
