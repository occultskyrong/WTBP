# 外部设计能力采用说明

WTBP 不把所有外部设计仓库复制为本地 Skill。它负责项目契约、动作组、底层窗体、结构门禁和真实验收；外部能力只在其擅长的环节补强。

## 采用分级

| 能力来源 | 采用级别 | 在 WTBP 中的职责 | 不做什么 |
|---|---|---|---|
| [Figma MCP Server Guide](https://github.com/figma/mcp-server-guide) | 默认能力源 | 提供当前客户端已暴露的 Figma 读取/写入、设计上下文、实现、组件库等官方能力 | 不替代 PDC、AGC、BF、G 或真实夹具验收 |
| [Figma Code Connect](https://github.com/figma/code-connect) | 优先映射 | 将 Figma 组件映射到真实代码组件和属性；优先于生成近似实现 | 映射缺失时不能假称已精确复用组件 |
| [Figma Console MCP Skills](https://github.com/southleft/figma-console-mcp-skills) | 可选审计 | 在明确授权后补充 Token、WCAG、目标尺寸、组件树和 lint 审计 | 不自动安装，不读取 PAT，不替代 WTBP 门禁 |
| [Figma SDS](https://github.com/figma/sds) | 参考实现 | 参考 Variables、Components、Code Connect 和代码仓库的组织方式 | 不直接复制到消费项目 |
| [Design Lint](https://github.com/destefanis/design-lint) | 参考实现 | 参考可配置 Figma 节点规则的实现方式 | 不覆盖父子几何、对称导航或运行时验收 |
| [UI UX Pro Max Skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | 参考能力 | 辅助探索视觉方向和 UX 模式 | 不作为业务事实、设计契约或强制门禁 |

完整来源元数据见 [`knowledge/external-sources.yaml`](../knowledge/external-sources.yaml)，可检索的能力卡与采用决策见
[`knowledge/external-capabilities.yaml`](../knowledge/external-capabilities.yaml) 和
[`docs/network-first-capability-governance.md`](network-first-capability-governance.md)。

## 运行顺序

```text
DCS 本地优先能力选择与外部参考边界
  → 官方 Figma 能力可用性（EX-01）
  → Code Connect / 项目组件映射（EX-02）
  → WTBP 的 PDC、INV、AGC、ICON、BF、G 门禁
  → 可选的第三方审计（EX-03）
  → 真实 Figma / 运行产品验收
```

外部能力的候选、收录和采用必须先记录在 `DCS-YYYYMMDD-VNN` 中。在线发现只在本地 Skill 和已收录外部能力均无明确适配时发生；`wtbp，收集 <公开 URL>` 只会生成未安装、可搜索的参考卡。它们都不替代第三方安装、凭据或执行的单独授权。

第三方审计永远位于 WTBP 门禁之后：它能发现问题，但不能把未验证的设计或截图变成已验收交付。

## 安装与凭据边界

只有当前客户端已提供的官方 Figma 能力属于默认工作流。第三方能力必须同时满足以下条件才可使用：

1. 用户明确授权安装与执行范围；
2. 已审查来源、版本、许可证和所需权限；
3. 使用方提供自己的凭据注入方式；WTBP 不读取、保存或回显 PAT；
4. 记录审计输入、版本、结果和未覆盖范围；
5. 即使审计通过，仍完成 AGC、BF、G 和真实夹具验收。

未满足任一条件时，报告“可选能力未启用”，继续执行不依赖该能力的 WTBP 流程。
