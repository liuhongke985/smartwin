# 系统架构设计说明书

## 文档控制

| 信息项 | 内容 |
|--------|------|
| **文档编号** | DES-01 |
| **文档版本** | V1.0 |
| **创建日期** | 2026-07-08 |
| **最后修订** | 2026-07-08 |
| **文档状态** | 正式发布 |
| **文档负责人** | 架构师 |
| **审批人** | 项目总监 |

---

## 1. 架构概述

### 1.1 设计目标

| 目标 | 说明 |
|------|------|
| 一套底座两套产品 | 共享底座+智链+智数独立产品线，支持独立部署和集成部署 |
| 信创原生适配 | 达梦DM8+国密SM2/SM3/SM4+ARM64，从设计之初考虑国产化 |
| 多模式运行 | 支持智链独立模式、智数独立模式、集成模式、SaaS模式 |
| AI双引擎 | 智链Python AI安全引擎 + 智数Java LangChain4j AI治理引擎 |
| 高可用 | 微服务架构，服务注册发现，无单点故障 |

### 1.2 架构风格

采用**微服务架构**，基于Spring Cloud生态，以Nacos为注册中心和配置中心，Spring Cloud Gateway为统一网关。

---

## 2. 系统总体架构

### 2.1 分层架构

```
┌──────────────────────────────────────────────────────────────┐
│                      前端展示层                                │
│   智链前端(Vue3:5173)    智数前端(Vue3:5174)   共享组件库     │
├──────────────────────────────────────────────────────────────┤
│                      API网关层                                │
│              Spring Cloud Gateway (:9000)                    │
│         统一认证 · 路由分发 · 限流熔断 · 日志                  │
├──────────────────────────────────────────────────────────────┤
│                      业务服务层                                │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │  共享服务(7) │  │ 智链服务(6)  │  │ 智数服务(9)  │          │
│  │ auth 8081   │  │ model 8083  │  │ catalog 8091│          │
│  │ system 8082 │  │ app 8084    │  │ metadata8092│          │
│  │ security8090│  │ agent 8085  │  │ quality 8093│          │
│  │ audit 8100  │  │ cost 8086   │  │ standard8094│          │
│  │ dashboard   │  │ risk 8087   │  │ lineage 8095│          │
│  │ notif config│  │ prompt 8088 │  │ mdm 8096    │          │
│  │             │  │             │  │ lifecycle   │          │
│  │             │  │             │  │ dataservice │          │
│  │             │  │             │  │ asset 8099  │          │
│  └─────────────┘  └─────────────┘  └─────────────┘          │
├──────────────────────────────────────────────────────────────┤
│                      AI引擎层                                 │
│   智链AI安全引擎(Python:8200/8201)  智数AI治理(Java内嵌)      │
├──────────────────────────────────────────────────────────────┤
│                      公共模块层                                │
│  common-util · common-db · common-db-multi · common-dm8      │
│  common-security · common-crypto-gm · common-xinchuang       │
│  common-ai · common-mq · common-storage · common-test        │
│  common-gateway                                              │
├──────────────────────────────────────────────────────────────┤
│                      数据存储层                                │
│  达梦DM8/H2 · Redis · Elasticsearch · Neo4j · MinIO          │
├──────────────────────────────────────────────────────────────┤
│                      基础设施层                                │
│  Nacos · Docker · Nginx · Prometheus · Grafana · Loki        │
└──────────────────────────────────────────────────────────────┘
```

### 2.2 多模式架构

系统支持四种运行模式，通过Spring Profile实现：

| 模式 | Profile | 说明 | 包含服务 |
|------|---------|------|----------|
| 智链独立模式 | `ic` | 仅部署智链+共享底座 | 7共享+6智链+AI引擎 |
| 智数独立模式 | `sd` | 仅部署智数+共享底座 | 7共享+9智数 |
| 集成模式 | `integrated` | 双产品全量部署 | 7共享+6智链+9智数+双AI引擎 |
| SaaS模式 | `saas` | 多租户云化部署 | 全部服务+多租户隔离 |

---

## 3. 公共模块层设计

### 3.1 模块清单

| 模块 | 说明 | 关键类 |
|------|------|--------|
| common-util | 统一响应/异常/实体/工具 | ApiResponse, BaseEntity, GlobalExceptionHandler |
| common-db | MyBatis-Plus配置 | MyBatisPlusConfig, MetaObjectHandler |
| common-db-multi | 多数据库适配 | DatabaseDialect, DialectRouter, DatabaseTypeDetector |
| common-dm8 | 达梦DM8适配 | Dm8Dialect, Dm8TypeHandler |
| common-security | JWT+Spring Security | JwtTokenProvider, SecurityConfig, JwtAuthenticationFilter |
| common-crypto-gm | 国密算法(SM2/SM3/SM4) | CryptoService, CryptoFacade, SoftwareCryptoService |
| common-xinchuang | 信创环境探测 | XinchuangEnvironmentDetector, XinchuangAutoProfilePostProcessor |
| common-ai | AI引擎客户端 | AiSecurityClient, AiGovernanceClient |
| common-mq | RocketMQ消息封装 | MessageProducer, MessageConsumer |
| common-storage | MinIO对象存储 | FileStorageService, MinioStorageService |
| common-test | 测试工具基类 | TestBase, TestDataProvider |
| common-gateway | 网关配置 | GatewayConfig, RouteDefinitions |

### 3.2 统一响应规范

```java
// 所有API统一返回格式
{
    "code": 200,        // 业务码：200成功/400参数错误/401未认证/403无权限/500系统错误
    "message": "success",
    "data": { ... },    // 业务数据
    "timestamp": 1720000000000
}

// 分页响应
{
    "code": 200,
    "message": "success",
    "data": {
        "records": [ ... ],
        "total": 100,
        "page": 1,
        "size": 20
    }
}
```

### 3.3 条件化Bean加载体系

```
@ConditionalOnPlatform(PlatformProfile.INTELCHAIN_ONLY)  // 智链独立模式
@ConditionalOnPlatform(PlatformProfile.SMARTDATA_ONLY)   // 智数独立模式
@ConditionalOnPlatform(PlatformProfile.INTEGRATED)       // 集成模式
@ConditionalOnXinchuang                                  // 信创环境
@ConditionalOnDatabaseType(DatabaseType.DM8)             // 达梦数据库
```

---

## 4. 微服务设计

### 4.1 服务清单与端口分配

| 服务 | 端口 | 归属 | 状态 |
|------|:----:|:----:|:----:|
| auth-service | 8081 | 共享 | ✅ 已实现 |
| system-service | 8082 | 共享 | ✅ 已实现 |
| model-service | 8083 | 智链 | ✅ 已实现 |
| app-service | 8084 | 智链 | ✅ 已实现 |
| agent-service | 8085 | 智链 | ✅ 已实现 |
| cost-service | 8086 | 智链 | ✅ 已实现 |
| risk-service | 8087 | 智链 | ✅ 已实现 |
| prompt-service | 8088 | 智链 | ✅ 已实现 |
| security-service | 8090 | 共享 | ✅ 已实现 |
| catalog-service | 8091 | 智数 | ✅ 已实现 |
| metadata-service | 8092 | 智数 | ✅ 已实现 |
| quality-service | 8093 | 智数 | ✅ 已实现 |
| standard-service | 8094 | 智数 | ✅ 已实现 |
| lineage-service | 8095 | 智数 | ✅ 已实现 |
| mdm-service | 8096 | 智数 | ✅ 已实现 |
| lifecycle-service | 8097 | 智数 | ✅ 已实现 |
| dataservice-service | 8098 | 智数 | ✅ 已实现 |
| asset-service | 8099 | 智数 | ✅ 已实现 |
| audit-service | 8100 | 共享 | ✅ 已实现 |
| dashboard-service | 8101 | 共享 | ✅ 已实现 |
| notification-service | 8102 | 共享 | ✅ 已实现 |
| config-service | 8103 | 共享 | ✅ 已实现 |
| ai-engine-intelchain | 8200/8201 | 智链 | 📋 待开发 |
| gateway | 9000 | 共享 | ✅ 已实现 |

### 4.2 服务分层规范

每个微服务遵循统一的分层结构：

```
xxx-service/
└── src/main/java/com/smartwin/xxx/
    ├── controller/          # REST API层
    ├── service/             # 业务逻辑层
    │   └── impl/
    ├── mapper/              # 数据访问层
    ├── entity/              # 数据库实体
    ├── dto/                 # 数据传输对象
    │   ├── request/         # 请求DTO
    │   └── response/        # 响应DTO
    └── config/              # 服务配置
```

### 4.3 服务间通信

| 通信方式 | 场景 | 实现 |
|----------|------|------|
| REST HTTP | 同步调用 | RestTemplate / OpenFeign |
| gRPC | AI引擎调用 | Proto + gRPC Stub |
| 消息队列 | 异步事件 | RocketMQ |
| Redis Pub/Sub | 实时通知 | RedisTemplate |

---

## 5. 网关设计

### 5.1 路由规则

| 路径前缀 | 目标服务 | 说明 |
|----------|----------|------|
| /api/auth/** | auth-service | 认证授权 |
| /api/system/** | system-service | 系统管理 |
| /api/security/** | security-service | 安全治理 |
| /api/audit/** | audit-service | 审计日志 |
| /api/intelchain/** | 智链各服务 | 智链产品线API |
| /api/smartdata/** | 智数各服务 | 智数产品线API |

### 5.2 网关过滤器

| 过滤器 | 说明 |
|--------|------|
| JwtAuthFilter | JWT认证，解析Token并注入用户信息 |
| RateLimitFilter | 限流，基于Token Bucket算法 |
| LogFilter | 请求日志记录 |
| CorsFilter | 跨域处理 |
| ProfileFilter | 运行模式标识注入 |

---

## 6. 安全架构

### 6.1 认证体系

```
用户登录 → auth-service验证 → 生成JWT(Access+Refresh)
    → Access Token有效期2h，Refresh Token有效期7d
    → Token存储Redis，支持主动失效
    → 网关JwtAuthFilter统一校验
```

### 6.2 权限模型

RBAC（基于角色的访问控制）：

```
用户 → 角色 → 权限(菜单/按钮/API)
```

| 注解 | 说明 |
|------|------|
| @RequiresPermission("model:create") | 需要指定权限 |
| @RequiresRole("ADMIN") | 需要指定角色 |

### 6.3 国密算法集成

| 算法 | 用途 | 实现类 |
|------|------|--------|
| SM2 | 非对称加密/数字签名 | CryptoFacade.sign/verify |
| SM3 | 哈希摘要 | CryptoFacade.hash |
| SM4 | 对称加密 | CryptoFacade.encrypt/decrypt |

> 详见 [DES-09 信创全栈适配与国密算法设计方案.md](./DES-09%20信创全栈适配与国密算法设计方案.md)

---

## 7. 数据存储架构

### 7.1 存储选型

| 存储 | 用途 | 版本 | 部署 |
|------|------|------|:----:|
| 达梦DM8 | 主业务数据库 | 8.1+ | 独立容器 |
| H2/MySQL | 开发环境数据库 | — | 内存/容器 |
| Redis | 缓存/Token/Session | 7.2 | 独立容器 |
| Elasticsearch | 数据目录全文搜索 | 8.13 | 独立容器 |
| Neo4j | 数据血缘图谱 | 5.20 | 独立容器 |
| MinIO | 文件/报告/附件 | latest | 独立容器 |

### 7.2 表命名规范

| 前缀 | 归属 | 示例 |
|------|------|------|
| sys_ | 共享-系统管理 | sys_user, sys_role |
| sec_ | 共享-安全治理 | sec_classification |
| audit_ | 共享-审计日志 | audit_operation_log |
| ic_ | 智链独有 | ic_model, ic_app |
| sw_ / sd_ | 智数独有 | sd_data_catalog, sd_quality_rule |

---

## 8. AI引擎架构

### 8.1 智链AI安全引擎（Python）

| 组件 | 技术 | 说明 |
|------|------|------|
| REST API | FastAPI | :8200 检测/评测/代理 |
| gRPC | grpcio | :8201 高性能检测 |
| 缓存 | Redis | 检测结果缓存 |
| 大模型 | OpenAI/通义千问/文心 | 多模型备选 |

### 8.2 智数AI治理引擎（Java）

| 组件 | 技术 | 说明 |
|------|------|------|
| 框架 | LangChain4j | Java原生LLM框架 |
| 部署 | 内嵌微服务 | 无独立进程 |
| 向量搜索 | Elasticsearch | 语义搜索 |
| RAG | LangChain4j RAG | 检索增强生成 |

---

## 9. 前端架构

### 9.1 技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| Vue 3 | 3.5+ | 前端框架 |
| TypeScript | 5.7+ | 类型安全 |
| Vite | 6.0+ | 构建工具 |
| Pinia | 3.0+ | 状态管理 |
| Vue Router | 4.5+ | 路由 |
| ECharts | 5.6 | 数据可视化 |
| vue-i18n | 10.0+ | 国际化 |

### 9.2 共享组件库

两套前端共享 `shared-components` 包，包含：
- AppLayout（主布局）
- Pagination/SearchBar/StatCard/SkeletonLoader等14个通用组件
- 主题系统（亮/暗模式CSS变量驱动）
- 国际化（中英双语，15模块locale文件）

> 详见 [DES-10 前端主题与国际化设计方案.md](./DES-10%20前端主题与国际化设计方案.md) 和 [DES-06 前端架构设计说明书.md](./DES-06%20前端架构设计说明书.md)

---

## 10. 部署架构

### 10.1 Docker Compose部署

全量部署包含35个容器：6基础设施 + 1AI引擎 + 1网关 + 7共享服务 + 6智链服务 + 9智数服务 + 2前端 + 3监控。

### 10.2 多模式部署

| 模式 | 容器数 | 说明 |
|------|:------:|------|
| 智链独立 | ~20 | 6基础+1AI+1网关+7共享+6智链+1前端+监控 |
| 智数独立 | ~24 | 6基础+1网关+7共享+9智数+1前端+监控 |
| 集成模式 | ~35 | 全量部署 |
| 精简模式 | ~12 | 精简版，合并部分服务 |

---

## 11. 架构决策记录

| 编号 | 决策 | 理由 | 日期 |
|:----:|------|------|:----:|
| ADR-001 | 采用微服务而非单体 | 双产品独立演进、独立部署 | 2026-07 |
| ADR-002 | Vue 3而非React | 团队经验、生态完善 | 2026-07 |
| ADR-003 | 达梦DM8而非MySQL(生产) | 信创适配要求 | 2026-07 |
| ADR-004 | 智链AI引擎用Python | AI生态成熟、gRPC性能 | 2026-07 |
| ADR-005 | 智数AI引擎用Java(LangChain4j) | 与Java生态深度集成 | 2026-07 |
| ADR-006 | Monorepo而非多仓库 | 共享模块复用、统一版本 | 2026-07 |
| ADR-007 | 多Profile多模式架构 | 支持独立/集成/SaaS多种部署 | 2026-07 |
| ADR-008 | 国密SM2/SM3/SM4 | 信创合规要求 | 2026-07 |

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-08 | 架构师 | 初始版本发布，基于Sprint 1-9实际实现状态 |
