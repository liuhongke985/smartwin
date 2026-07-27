# REQ-06 SmartWin智赢平台接口需求说明书

> **文档编号**: REQ-06  
> **版本**: V2.0  
> **创建日期**: 2026-07-08  
> **最后修订**: 2026-07-08  
> **文档状态**: 正式发布  
> **文档负责人**: 架构师  
> **审批人**: 技术总监  

---

## 一、接口设计概述

### 1.1 设计原则

| 原则 | 说明 |
|------|------|
| RESTful | 遵循REST架构风格，资源导向 |
| 标准化 | 统一请求/响应格式、错误码、分页 |
| 版本化 | URL路径版本控制（/api/v1/） |
| 安全性 | JWT认证 + 接口签名 + 限流 |
| 可观测 | 全链路追踪 + 调用日志 |
| 信创兼容 | 兼容国密TLS（TLCP）协议 |

### 1.2 接口分类

| 接口类型 | 协议 | 数量 | 说明 |
|---------|------|:----:|------|
| RESTful API | HTTP/HTTPS | 180+ | 核心业务接口 |
| GraphQL | HTTP | 1端点 | 灵活查询接口 |
| gRPC | HTTP/2 | 45+ | 微服务间通信 |
| WebSocket | WS/WSS | 5+ | 实时推送 |
| 消息队列 | Kafka | 12+topic | 异步事件 |
| SDK | Java/Python | 2套 | 开发者集成 |

---

## 二、RESTful API规范

### 2.1 统一响应格式

```json
{
  "code": 200,
  "message": "success",
  "data": { ... },
  "timestamp": "2025-06-30T12:00:00Z",
  "traceId": "trace-xxx-xxx"
}
```

### 2.2 分页响应格式

```json
{
  "code": 200,
  "data": {
    "list": [ ... ],
    "total": 1000,
    "page": 1,
    "size": 20,
    "totalPages": 50
  }
}
```

### 2.3 错误码定义

| 错误码范围 | 说明 |
|-----------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未认证 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 409 | 资源冲突 |
| 429 | 请求限流 |
| 500 | 服务器内部错误 |
| 503 | 服务不可用 |

---

## 三、核心API清单

### 3.1 数据目录API

| 方法 | 路径 | 说明 | 认证 | 版本 |
|------|------|------|:----:|:----:|
| GET | /api/v1/catalog/datasets | 获取数据集列表 | JWT | v1 |
| POST | /api/v1/catalog/datasets | 注册数据集 | JWT | v1 |
| GET | /api/v1/catalog/datasets/{id} | 获取数据集详情 | JWT | v1 |
| PUT | /api/v1/catalog/datasets/{id} | 更新数据集 | JWT | v1 |
| DELETE | /api/v1/catalog/datasets/{id} | 删除数据集 | JWT | v1 |
| GET | /api/v1/catalog/search | AI搜索数据 | JWT | v1 |
| POST | /api/v1/catalog/datasets/{id}/tags | 设置标签 | JWT | v1 |
| GET | /api/v1/catalog/categories | 获取分类树 | JWT | v1 |

### 3.2 元数据管理API

| 方法 | 路径 | 说明 | 认证 | 版本 |
|------|------|------|:----:|:----:|
| GET | /api/v1/metadata/technical | 获取技术元数据 | JWT | v1 |
| GET | /api/v1/metadata/business | 获取业务元数据 | JWT | v1 |
| POST | /api/v1/metadata/ai-complete | AI补全元数据 | JWT | v1 |
| GET | /api/v1/metadata/lineage | 获取血缘关系 | JWT | v1 |
| POST | /api/v1/metadata/lineage/ai-fill | AI补全血缘 | JWT | v1 |

### 3.3 数据质量API

| 方法 | 路径 | 说明 | 认证 | 版本 |
|------|------|------|:----:|:----:|
| GET | /api/v1/quality/rules | 获取质量规则 | JWT | v1 |
| POST | /api/v1/quality/rules | 创建质量规则 | JWT | v1 |
| POST | /api/v1/quality/tasks | 创建检测任务 | JWT | v1 |
| GET | /api/v1/quality/results | 获取检测结果 | JWT | v1 |
| GET | /api/v1/quality/reports | 获取质量报告 | JWT | v1 |
| POST | /api/v1/quality/ai-detect | AI异常检测 | JWT | v1 |

### 3.4 AI智能API

| 方法 | 路径 | 说明 | 认证 | 版本 |
|------|------|------|:----:|:----:|
| POST | /api/v1/ai/search | AI语义搜索 | JWT | v1 |
| POST | /api/v1/ai/qa | AI数据问答 | JWT | v1 |
| POST | /api/v1/ai/sql-generate | AI生成SQL | JWT | v1 |
| POST | /api/v1/ai/insight | AI洞察推荐 | JWT | v1 |
| GET | /api/v1/ai/agents | 获取Agent列表 | JWT | v2 |
| POST | /api/v1/ai/agents | 创建Agent | JWT | v2 |
| POST | /api/v1/ai/agents/{id}/execute | 执行Agent任务 | JWT | v2 |
| GET | /api/v1/ai/trust/explain | AI可解释性 | JWT | v2 |

### 3.5 安全合规API

| 方法 | 路径 | 说明 | 认证 | 版本 |
|------|------|------|:----:|:----:|
| GET | /api/v1/security/classification | 获取分类分级 | JWT | v1 |
| POST | /api/v1/security/classification | 设置分类分级 | JWT | v1 |
| GET | /api/v1/security/masking-rules | 获取脱敏规则 | JWT | v1 |
| POST | /api/v1/security/masking-rules | 创建脱敏规则 | JWT | v1 |
| GET | /api/v1/security/audit-logs | 查询审计日志 | JWT | v1 |
| GET | /api/v1/security/compliance/report | 生成合规报告 | JWT | v1 |
| POST | /api/v1/security/quantum/encrypt | 国密安全加密 | JWT | v2 |

### 3.6 ETL与数据编织API

| 方法 | 路径 | 说明 | 认证 | 版本 |
|------|------|------|:----:|:----:|
| GET | /api/v1/etl/connectors | 获取连接器列表 | JWT | v1.5 |
| POST | /api/v1/etl/pipelines | 创建ETL管道 | JWT | v1.5 |
| POST | /api/v1/etl/pipelines/{id}/run | 运行ETL管道 | JWT | v1.5 |
| POST | /api/v1/fabric/query | 跨源查询 | JWT | v1.5 |
| GET | /api/v1/fabric/semantic-layer | 获取语义层 | JWT | v1.5 |

### 3.7 AutoOps API

| 方法 | 路径 | 说明 | 认证 | 版本 |
|------|------|------|:----:|:----:|
| GET | /api/v1/ops/health | 系统健康状态 | JWT | v2 |
| POST | /api/v1/ops/diagnose | AI故障诊断 | JWT | v2 |
| POST | /api/v1/ops/auto-heal | 触发自愈 | JWT | v2 |
| GET | /api/v1/ops/capacity/forecast | 容量预测 | JWT | v2 |

---

## 四、gRPC接口（微服务间通信）

### 4.1 核心gRPC服务

| 服务名 | 方法数 | 说明 |
|--------|:------:|------|
| CatalogService | 12 | 数据目录服务 |
| MetadataService | 8 | 元数据服务 |
| QualityService | 10 | 数据质量服务 |
| SecurityService | 15 | 安全治理服务 |
| AuditService | 6 | 审计日志服务 |
| AIService | 8 | AI引擎服务 |
| ETLService | 10 | ETL引擎服务 |
| FabricService | 6 | 数据编织服务 |
| AgentService | 8 | Agent编排服务 |
| OpsService | 10 | AutoOps服务 |

### 4.2 gRPC通信规范

| 规范项 | 说明 |
|--------|------|
| 序列化 | Protocol Buffers v3 |
| 认证 | mTLS双向认证 |
| 超时 | 默认5s，可配置 |
| 重试 | 指数退避，最多3次 |
| 熔断 | 错误率>50%触发熔断 |
| 负载均衡 | Round Robin + 权重 |

---

## 五、WebSocket接口

| 端点 | 说明 | 消息格式 |
|------|------|---------|
| /ws/notifications | 实时通知推送 | JSON |
| /ws/alerts | 告警实时推送 | JSON |
| /ws/etl/status | ETL执行状态推送 | JSON |
| /ws/agent/status | Agent执行状态推送 | JSON |
| /ws/dashboard | 看板数据实时刷新 | JSON |

---

## 六、消息队列Topic

| Topic | 说明 | 生产者 | 消费者 |
|-------|------|--------|--------|
| data-quality-events | 数据质量事件 | QualityService | NotificationService |
| security-alerts | 安全告警事件 | SecurityService | NotificationService |
| audit-events | 审计事件 | 所有服务 | AuditService |
| etl-status-events | ETL状态事件 | ETLService | DashboardService |
| agent-status-events | Agent状态事件 | AgentService | DashboardService |
| ops-alerts | 运维告警事件 | OpsService | NotificationService |
| data-lineage-events | 血缘变更事件 | MetadataService | CatalogService |

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-08 | 架构师 | 初始版本，V1.0接口定义 |
| V2.0 | 2026-07-08 | 架构师 | 补充V1.5 ETL/数据编织和V2.0 AI Agent/AutoOps接口 |
