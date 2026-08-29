# 接口四层测试体系实施方案

## 1. 目标与边界

这套方案解决四个不同问题：后端是否部署成功、真实接口主流程是否可用、接口逻辑分支是否完整、多个接口串联后业务是否闭环。四类证据必须分开记录，不能用 Mock 全绿替代真实环境验证，也不能用代码覆盖率代替行为断言。

当前方案面向后端 HTTP/JSON API。具体项目仍需补充技术栈、环境地址、认证方式、接口清单、测试数据边界和写入授权；这些信息缺失时，运行时结果必须保持 `Unverified`。

## 2. 四层体系

| 层级 | 目的 | 请求边界 | 典型执行时机 | 通过含义 |
| --- | --- | --- | --- | --- |
| L1 可用性探针 | 判断服务、路由和最小响应是否可达 | 部署环境真实请求；优先健康、就绪和只读接口 | 部署前/部署后 | 服务可达，不代表业务正确 |
| L2 真实主流程 | 验证标准参数和真实认证下的关键成功路径 | 已部署服务真实 HTTP；使用隔离数据 | 部署后/发布 | 关键主流程可用 |
| L3 Mock 逻辑与契约 | 覆盖正常、异常、边界、权限和依赖失败 | 被测服务真实，外部依赖 Mock | PR/合并 | 代码逻辑和契约分支可验证 |
| L4 业务逻辑链 | 验证多接口状态变化和业务闭环 | 集成环境真实调用；独立租户/命名空间 | 合并/夜间/发布 | 关键链路闭环 |

## 3. 统一接口测试清单

建议在消费项目维护 `api-test-manifest.yaml`，四层测试都引用它：

```yaml
version: 1
service: item-service
environment: staging
apis:
  - id: item.create
    method: POST
    path: /api/items
    auth: user
    risk: critical
    standard_request: fixtures/item-create.json
    expected:
      http_status: 201
      business_code: SUCCESS
      response_schema: schemas/item-created.json
    preconditions: [test-tenant-exists]
    cleanup: [delete-created-item]
    flows: [item-crud]
flows:
  - id: item-crud
    isolation: test-tenant
    steps:
      - item.list.scoped-empty
      - item.create
      - item.list.count-increment
      - item.detail.created
      - item.update
      - item.detail.updated
      - item.delete
      - item.detail.absent
      - item.list.count-decrement
    cleanup: required
```

清单至少要能表达：接口 ID、方法、路径、认证、标准参数、预期 HTTP/业务结果、响应结构、前置条件、清理动作、风险级别和业务链。

## 4. 数据策略

L2/L4 不应依赖共享环境的“全局为空”。每次运行生成唯一的 `test_run_id`、租户、用户和业务键，并将查询限定在这个范围内：

```text
tenant = api-test-{test_run_id}
business_key = api-test-{test_run_id}-{case_id}
```

执行结构统一为：

```text
prepare -> execute -> assert -> cleanup
```

清理失败必须单独报告为 `TEST_DATA_FAILURE`，不能因为主断言通过就将整条链标记为完整通过。

## 5. CI/CD 门禁

```text
Pull Request：L3 契约、逻辑、异常测试
合并前：L3 全量 + 关键 L4
部署前：L1 预检查
部署后：L1 + L2
夜间：L3 全量 + L4 全量 + 边界/变异抽样
发布：关键接口 L1/L2/L4 通过，L3 无阻断失败
```

生产环境默认只执行 L1 和明确批准的无副作用只读探针，不执行新增、更新、删除型 L4。

## 6. 统一报告与故障分类

每次测试输出 JUnit XML 和 JSON，至少包含：

- 服务、环境、Git commit 和测试版本；
- 稳定接口 ID、业务链 ID、Fixture 版本和 `test_run_id`；
- 请求 ID/Trace ID、实际状态码、业务码和关键断言；
- 首个失败步骤、脱敏响应摘要和清理结果。

失败分类固定为：

```text
DEPLOYMENT_UNAVAILABLE  部署或路由不可达
CONTRACT_DRIFT          请求/响应契约漂移
BUSINESS_FAILURE        业务断言失败
AUTHORIZATION_FAILURE   认证或权限失败
TEST_DATA_FAILURE       前置数据或清理失败
DEPENDENCY_FAILURE      外部依赖失败
TEST_INFRA_FAILURE      测试框架、网络或执行器故障
```

## 7. 落地顺序

1. 先选每个服务 10～20 个关键接口，补齐接口清单和关键业务链。
2. 建立 L1/L2 真实请求入口，先解决部署成功和主流程可用性。
3. 建立 L3 Mock、契约、异常和边界矩阵，接入 PR 门禁。
4. 为高价值模块建设 L4 CRUD 和跨模块链路，接入夜间与发布门禁。
5. 对低价值或不稳定用例做隔离、限时修复；不允许通过无限重试隐藏失败。

## 8. 验收标准

- 每个关键服务至少有四层测试样例，且真实请求和 Mock 请求边界清晰。
- L1 失败可以区分服务未启动、路由错误、认证错误和依赖不可用。
- L2 能用标准参数验证真实部署主流程。
- L3 至少覆盖正向、反向、边界、权限和依赖失败。
- L4 能完成一次隔离的 CRUD 链，并验证每一步状态变化和清理结果。
- 故意修改路由、业务码、响应结构和状态转换时，对应测试能够失败。
- 报告不包含凭据，不把 Mock 或静态报告称为生产运行通过。
