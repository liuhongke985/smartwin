# DES-02 SmartWin智赢平台接口设计说明书

> **文档编号**: DES-02  
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
| RESTful | 资源导向，HTTP语义化方法 |
| 统一规范 | 统一请求/响应格式、错误码、分页 |
| 版本控制 | URL路径版本（/api/v1/） |
| 安全性 | JWT + 接口签名 + 限流 + 国密TLS |
| 可观测 | 全链路追踪 + 调用日志 |
| 向后兼容 | 新增字段不破坏旧版本 |

### 1.2 技术选型

| 接口类型 | 技术栈 | 用途 |
|---------|--------|------|
| RESTful | Spring Boot + SpringDoc OpenAPI | 对外API |
| gRPC | protobuf + gRPC-Java | 微服务间通信 |
| WebSocket | Spring WebSocket + STOMP | 实时推送 |
| GraphQL | Spring for GraphQL | 灵活查询 |
| 消息队列 | Apache Kafka | 异步事件 |

---

## 二、RESTful API设计

### 2.1 URL规范

```
基础路径: /api/{version}/{module}/{resource}

示例:
  /api/v1/catalog/datasets          — 数据集列表
  /api/v1/catalog/datasets/{id}     — 数据集详情
  /api/v1/quality/rules             — 质量规则
  /api/v2/ai/agents                 — AI Agent (V2.0)
```

### 2.2 HTTP方法语义

| 方法 | 语义 | 幂等 | 示例 |
|------|------|:----:|------|
| GET | 查询资源 | ✅ | GET /api/v1/catalog/datasets |
| POST | 创建资源 | ❌ | POST /api/v1/catalog/datasets |
| PUT | 更新资源（全量） | ✅ | PUT /api/v1/catalog/datasets/{id} |
| PATCH | 更新资源（部分） | ❌ | PATCH /api/v1/catalog/datasets/{id} |
| DELETE | 删除资源 | ✅ | DELETE /api/v1/catalog/datasets/{id} |

### 2.3 统一响应格式

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": "ds-001",
    "name": "客户主数据",
    "description": "客户基本信息表",
    "qualityScore": 98.5,
    "sensitivityLevel": "L3",
    "fields": [...]
  },
  "timestamp": "2025-06-30T12:00:00Z",
  "traceId": "trace-a1b2c3d4"
}
```

### 2.4 分页规范

```
请求参数:
  page=1          — 页码，从1开始
  size=20         — 每页条数，最大100
  sort=name,asc   — 排序字段和方向

响应:
{
  "code": 200,
  "data": {
    "list": [...],
    "total": 1000,
    "page": 1,
    "size": 20,
    "totalPages": 50
  }
}
```

### 2.5 过滤与查询

```
精确查询: ?name=客户主数据
模糊查询: ?nameLike=客户
范围查询: ?qualityScoreGte=80&qualityScoreLte=100
多值查询: ?status=ACTIVE,PENDING
排序:   ?sort=createTime,desc
字段过滤: ?fields=id,name,qualityScore
```

### 2.6 错误码体系

| 错误码 | HTTP状态码 | 说明 | 示例场景 |
|--------|:---------:|------|---------|
| 200 | 200 | 成功 | — |
| 400 | 400 | 参数校验失败 | 必填字段缺失 |
| 401 | 401 | 未认证 | Token无效/过期 |
| 403 | 403 | 无权限 | 无数据访问权限 |
| 404 | 404 | 资源不存在 | 数据集ID无效 |
| 409 | 409 | 资源冲突 | 重复创建 |
| 422 | 422 | 业务规则失败 | 质量规则不满足 |
| 429 | 429 | 请求限流 | 超过QPS限制 |
| 500 | 500 | 服务器错误 | 未捕获异常 |
| 503 | 503 | 服务不可用 | 依赖服务宕机 |

### 2.7 认证与授权

```
请求头:
  Authorization: Bearer {JWT_TOKEN}
  X-Request-ID: {UUID}           — 请求追踪ID
  X-Tenant-ID: {TENANT_ID}       — 租户ID（SaaS模式）
  X-Signature: {HMAC-SIGNATURE}  — 接口签名（API集成）
```

### 2.8 限流策略

| API级别 | 限流策略 | 说明 |
|---------|---------|------|
| L1-核心 | 1000 QPS/IP | 认证/网关 |
| L2-业务 | 500 QPS/IP | 数据治理/安全 |
| L3-查询 | 200 QPS/IP | 报表/分析 |
| L4-AI | 50 QPS/IP | AI搜索/问答 |
| L5-导出 | 10 QPS/IP | 数据导出 |

---

## 三、gRPC接口设计

### 3.1 Protobuf定义示例

```protobuf
syntax = "proto3";
package com.smartwin.catalog;

service CatalogService {
  rpc GetDataset(GetDatasetRequest) returns (DatasetResponse);
  rpc SearchDatasets(SearchRequest) returns (DatasetListResponse);
  rpc CreateDataset(CreateDatasetRequest) returns (DatasetResponse);
  rpc UpdateDataset(UpdateDatasetRequest) returns (DatasetResponse);
  rpc DeleteDataset(DeleteDatasetRequest) returns (EmptyResponse);
  rpc StreamDatasets(SearchRequest) returns (stream DatasetResponse);
}

message Dataset {
  string id = 1;
  string name = 2;
  string description = 3;
  string source_id = 4;
  repeated Field fields = 5;
  double quality_score = 6;
  string sensitivity_level = 7;
  int64 create_time = 8;
  int64 update_time = 9;
}
```

### 3.2 gRPC通信规范

| 规范项 | 配置 | 说明 |
|--------|------|------|
| 序列化 | Protocol Buffers v3 | 高效二进制序列化 |
| 认证 | mTLS双向认证 | 证书+JWT |
| 超时 | 连接5s/请求30s | 可配置 |
| 重试 | 指数退避，最多3次 | 可配置 |
| 熔断 | 错误率>50%触发 | 30s后恢复探测 |
| 负载均衡 | Round Robin | 客户端负载均衡 |
| 拦截器 | 认证/日志/追踪/限流 | 全局拦截器 |

---

## 四、WebSocket接口设计

### 4.1 连接规范

```
连接URL: wss://api.intelchain.com/ws/{endpoint}
认证: URL参数 ?token={JWT_TOKEN}
心跳: 30秒一次ping/pong
重连: 指数退避，最多5次
```

### 4.2 消息格式

```json
{
  "type": "notification",
  "event": "data_quality_alert",
  "data": {
    "datasetId": "ds-001",
    "ruleId": "qr-001",
    "severity": "HIGH",
    "message": "数据质量下降至85%"
  },
  "timestamp": "2025-06-30T12:00:00Z"
}
```

### 4.3 端点清单

| 端点 | 事件类型 | 推送频率 | 说明 |
|------|---------|---------|------|
| /ws/notifications | notification | 实时 | 系统通知 |
| /ws/alerts | alert | 实时 | 告警推送 |
| /ws/dashboard | metric | 5秒 | 看板数据刷新 |
| /ws/etl/status | status | 1秒 | ETL执行状态 |
| /ws/agent/status | status | 1秒 | Agent执行状态 |

---

## 五、API文档管理

### 5.1 文档生成

| 工具 | 用途 | 说明 |
|------|------|------|
| SpringDoc OpenAPI | 自动生成API文档 | 基于注解 |
| Swagger UI | 在线API调试 | 集成到管理后台 |
| Postman Collection | API测试集合 | 自动导出 |
| protobuf + buf | gRPC文档 | .proto生成 |

### 5.2 API版本管理

| 版本 | 状态 | 说明 |
|------|------|------|
| v1 | ✅ 当前版本 | V1.0-V1.5功能 |
| v2 | ✅ 当前版本 | V2.0新增AI Agent/AutoOps |
| v3 | 🔶 规划中 | V3.0生态市场/全球化 |

### 5.3 向后兼容策略

| 变更类型 | 兼容性 | 处理方式 |
|---------|:------:|---------|
| 新增字段 | ✅ 兼容 | 旧客户端忽略新字段 |
| 删除字段 | ❌ 不兼容 | 先标记废弃，下个大版本删除 |
| 修改字段类型 | ❌ 不兼容 | 新版本路径 |
| 新增端点 | ✅ 兼容 | 不影响现有端点 |
| 修改业务逻辑 | 🔶 视情况 | 通过特性开关控制 |

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-08 | 架构师 | 初始版本 |
| V2.0 | 2026-07-08 | 架构师 | 补充V2.0 gRPC服务和WebSocket端点 |
