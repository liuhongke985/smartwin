# 智数 (SmartData) 概要设计说明书

| 属性 | 内容 |
|------|------|
| 文档编号 | SD-HLD-01 |
| 文档名称 | 智数平台概要设计说明书 |
| 版本号 | V1.0.0 |
| 状态 | 已更新 |
| 编制日期 | 2026-07-10 |
| 编制人 | 智数架构组 |
| 审核人 | 技术总监 |

---

## 目录

1. [系统总体架构](#1-系统总体架构)
2. [微服务划分](#2-微服务划分)
3. [技术选型](#3-技术选型)
4. [数据架构设计](#4-数据架构设计)
5. [接口设计](#5-接口设计)
6. [安全架构设计](#6-安全架构设计)
7. [部署架构设计](#7-部署架构设计)
8. [AI能力架构设计](#8-ai能力架构设计)
9. [信创适配设计](#9-信创适配设计)
10. [新增模块架构设计（V1.1竞品分析补充）](#10-新增模块架构设计v11竞品分析补充)

---

## 1. 系统总体架构

### 1.1 架构全景图

```
┌──────────────────────────────────────────────────────────────────────────┐
│                          用户层 (User Layer)                               │
│    Web浏览器    │   移动端H5    │   开放API    │   CLI工具                 │
├──────────────────────────────────────────────────────────────────────────┤
│                       接入层 (Access Layer)                                │
│         Spring Cloud Gateway │ Nginx │ WebSocket                          │
├──────────────┬──────────────┬──────────────┬───────────────────────────────┤
│   资产管理    │   元数据管理  │   质量管理    │    标准管理                    │
│ catalog-svc │ metadata-svc │ quality-svc │ standard-svc                   │
├──────────────┼──────────────┼──────────────┼───────────────────────────────┤
│   血缘分析    │   主数据管理  │   生命周期    │    数据服务                    │
│ lineage-svc  │   mdm-svc    │ lifecycle-svc│ dataservice-svc               │
├──────────────┼──────────────┼──────────────┼───────────────────────────────┤
│   数据探查    │   业务术语表  │   治理工作流  │    AI治理                     │
│ profiling-svc│ glossary-svc │ workflow-svc │ aigovernance-svc              │
├──────────────┴──────────────┴──────────────┴───────────────────────────────┤
│                     平台公共层 (Platform Common)                           │
│  common-security │ common-db │ common-mq │ common-ai │ common-storage       │
├──────────────────────────────────────────────────────────────────────────┤
│                     基础设施层 (Infrastructure)                            │
│  MySQL/DM8 │ Redis │ Elasticsearch │ Neo4j │ Kafka │ MinIO │ Flowable      │
└──────────────────────────────────────────────────────────────────────────┘
```

### 1.2 架构设计原则

| 原则 | 说明 |
|------|------|
| 微服务化 | 每个功能域独立服务，独立部署，独立扩展 |
| AI原生 | AI能力作为平台基础服务，贯穿所有功能域 |
| 信创优先 | 核心组件全面支持国产化替代 |
| 插件化 | 数据源适配、质量规则、血缘解析采用插件化架构 |
| 云原生 | 容器化部署，支持K8s编排，声明式配置 |
| 多租户 | SaaS模式下支持多租户隔离 |

### 1.3 与智链平台集成架构

```
┌─────────────────┐     ┌─────────────────┐
│   智数 SmartData │     │  智链 SmartChain │
│                 │     │                 │
│ 数据资产 ───────┼─────┼──→ 训练数据供给  │
│ 数据质量 ───────┼─────┼──→ 数据质量反馈  │
│ AI辅助标注 ←───┼─────┼── 大模型能力     │
│                 │     │                 │
└────────┬────────┘     └────────┬────────┘
         │                       │
         └───────┬───────────────┘
                 │
     ┌───────────┴───────────┐
     │  智赢公共平台 SmartWin  │
     │  Gateway / Auth / Audit│
     │  System / Config / Noti│
     └───────────────────────┘
```

---

## 2. 微服务划分

### 2.1 服务清单

| 服务名 | 端口 | 功能域 | 数据库 | 依赖中间件 |
|--------|------|--------|--------|-----------|
| catalog-service | 8401 | 数据资产管理 | sd_catalog | ES, Redis |
| metadata-service | 8402 | 元数据管理 | sd_metadata | ES, Redis |
| quality-service | 8403 | 数据质量管理 | sd_quality | Redis, Kafka |
| standard-service | 8404 | 数据标准管理 | sd_standard | Redis |
| lineage-service | 8405 | 数据血缘分析 | sd_lineage | Neo4j, Redis |
| mdm-service | 8406 | 主数据管理 | sd_mdm | Redis, Kafka |
| lifecycle-service | 8407 | 生命周期管理 | sd_lifecycle | Redis, MinIO |
| dataservice-service | 8408 | 数据服务管理 | sd_dataservice | Redis, Kafka |
| profiling-service | 8409 | 数据探查与画像 | sd_profiling | ES, Redis |
| glossary-service | 8410 | 业务术语表管理 | sd_glossary | ES, Redis |
| workflow-service | 8411 | 治理工作流引擎 | sd_workflow | Redis, Flowable |
| aigovernance-service | 8412 | AI治理 | sd_aigovernance | Redis, Kafka |

### 2.2 服务依赖关系

```
catalog-service ──→ metadata-service (资产关联元数据)
catalog-service ──→ quality-service  (资产质量评分)
catalog-service ──→ standard-service (资产标准合规)
metadata-service ──→ lineage-service  (元数据血缘)
quality-service  ──→ metadata-service (检测目标元数据)
standard-service ──→ metadata-service (标准映射元数据)
mdm-service     ──→ quality-service  (主数据质量)
lifecycle-service ──→ metadata-service (生命周期对象)
dataservice-service ──→ metadata-service (API数据源)
profiling-service ──→ metadata-service (探查目标元数据)
profiling-service ──→ quality-service  (异常值联动质量检测)
glossary-service  ──→ metadata-service (术语关联元数据)
glossary-service  ──→ catalog-service  (术语关联资产)
workflow-service  ──→ catalog-service  (资产发布审批)
workflow-service  ──→ standard-service (标准审批流)
workflow-service  ──→ quality-service  (质量修复工单)
workflow-service  ──→ mdm-service      (主数据变更审批)
workflow-service  ──→ glossary-service (术语审批流)
aigovernance-service ──→ metadata-service (训练数据元数据)
aigovernance-service ──→ quality-service  (训练数据质量检测)
aigovernance-service ──→ lineage-service  (训练数据血缘)
```

### 2.3 服务通信方式

| 通信方式 | 场景 | 技术 |
|---------|------|------|
| 同步调用 | 跨服务实时查询 | OpenFeign + Ribbon |
| 异步消息 | 事件通知、任务派发 | RocketMQ/Kafka |
| 缓存共享 | 配置、字典共享 | Redis Pub/Sub |
| 文件传输 | 大数据量交换 | MinIO |

---

## 3. 技术选型

### 3.1 后端技术栈

| 类别 | 技术 | 版本 | 选型理由 |
|------|------|------|---------|
| 开发框架 | Spring Boot | 3.2.x | 成熟稳定，生态丰富 |
| 微服务框架 | Spring Cloud | 2023.x | 与Spring Boot无缝集成 |
| 服务注册 | Nacos | 2.3.x | 阿里开源，信创兼容 |
| API网关 | Spring Cloud Gateway | 4.1.x | 响应式网关，高性能 |
| ORM | MyBatis-Plus | 3.5.x | 国产ORM，多DB支持 |
| 数据库 | MySQL 8.0 / DM8 | - | 双库支持，信创适配 |
| 缓存 | Redis | 7.0+ | 高性能缓存 |
| 搜索引擎 | Elasticsearch | 8.x | 全文检索 |
| 图数据库 | Neo4j | 5.x | 血缘关系存储 |
| 消息队列 | RocketMQ / Kafka | 3.x / 5.x | 异步通信 |
| AI框架 | LangChain4j | 0.31+ | Java大模型集成 |
| 国密 | BC + 自研 | - | SM2/SM3/SM4 |

### 3.2 前端技术栈

| 类别 | 技术 | 版本 | 选型理由 |
|------|------|------|---------|
| 框架 | Vue 3 | 3.4+ | Composition API, 性能优异 |
| 语言 | TypeScript | 5.3+ | 类型安全 |
| 构建 | Vite | 5.0+ | 极速构建 |
| 路由 | Vue Router | 4.x | 官方路由 |
| 状态 | Pinia | 2.x | 轻量状态管理 |
| UI组件 | Element Plus | 2.5+ | 企业级UI |
| 图表 | ECharts | 5.4+ | 数据可视化 |
| 血缘图 | AntV G6 / VueFlow | 5.x | DAG图渲染 |
| 搜索 | FlexSearch | - | 前端搜索 |
| 国际化 | Vue I18n | 9.x | 多语言 |
| 请求 | Axios | 1.6+ | HTTP客户端 |

---

## 4. 数据架构设计

### 4.1 数据库选型与分布

| 数据库 | 用途 | 数据特点 | 容量预估 |
|--------|------|---------|---------|
| MySQL/DM8 | 业务关系数据 | 结构化、事务性 | 500GB |
| Elasticsearch | 全文索引 | 非结构化、搜索 | 200GB |
| Neo4j | 血缘关系图 | 图结构 | 100GB |
| Redis | 缓存/会话 | KV、TTL | 32GB |
| MinIO | 文件存储 | 二进制 | 1TB |

### 4.2 核心数据模型

#### 4.2.1 数据资产模型

```
sd_asset
├── id (BIGINT, PK)
├── asset_code (VARCHAR(64), UNIQUE)     -- 资产编码
├── asset_name (VARCHAR(200))             -- 资产名称
├── asset_type (VARCHAR(32))              -- 资产类型(TABLE/VIEW/API/FILE)
├── description (TEXT)                    -- 描述
├── source_system (VARCHAR(100))          -- 来源系统
├── source_type (VARCHAR(32))             -- 来源类型
├── catalog_id (BIGINT, FK)               -- 目录ID
├── owner (VARCHAR(64))                   -- 资产负责人
├── department (VARCHAR(100))             -- 所属部门
├── tags (VARCHAR(500))                   -- 标签(JSON)
├── classification (VARCHAR(32))          -- 密级(PUBLIC/INTERNAL/CONFIDENTIAL/SECRET)
├── quality_score (DECIMAL(5,2))          -- 质量评分
├── usage_count (BIGINT)                  -- 使用次数
├── status (VARCHAR(16))                  -- 状态(DRAFT/PUBLISHED/OFFLINE)
├── tenant_id (BIGINT)                    -- 租户ID
├── created_by / created_at
├── updated_by / updated_at
└── deleted (TINYINT)                     -- 软删除
```

#### 4.2.2 元数据模型

```
sd_metadata
├── id (BIGINT, PK)
├── asset_id (BIGINT, FK)                 -- 关联资产
├── metadata_type (VARCHAR(16))           -- 类型(TECHNICAL/BUSINESS/MANAGEMENT)
├── object_type (VARCHAR(16))             -- 对象类型(DATABASE/TABLE/COLUMN/INDEX)
├── object_name (VARCHAR(200))            -- 对象名称
├── object_comment (VARCHAR(500))         -- 对象注释
├── data_type (VARCHAR(50))               -- 数据类型(列级)
├── business_name (VARCHAR(200))          -- 业务名称
├── business_desc (TEXT)                  -- 业务描述
├── data_format (VARCHAR(50))             -- 数据格式
|── nullable (TINYINT)                    -- 是否可空
├── primary_key (TINYINT)                 -- 是否主键
├── sensitive_level (VARCHAR(16))         -- 敏感级别
├── version (INT)                         -- 版本号
├── tenant_id (BIGINT)
├── created_by / created_at
└── updated_by / updated_at
```

#### 4.2.3 血缘关系模型 (Neo4j)

```cypher
// 节点
(:Table {id, name, database, source_system})
(:Column {id, name, table_id, data_type})
(:Process {id, name, type, script})

// 关系
(:Table)-[:HAS_COLUMN]->(:Column)
(:Table)-[:INPUT_TO]->(:Process)
(:Process)-[:OUTPUT_TO]->(:Table)
(:Column)-[:DERIVED_FROM]->(:Column)
```

### 4.3 数据分片与读写分离

| 策略 | 说明 |
|------|------|
| 读写分离 | 主库写、从库读，通过ShardingSphere路由 |
| 数据分片 | 大表按租户ID分片，支持水平扩展 |
| 冷热分离 | 历史/归档数据迁移至冷存储 |
| 多租户 | 行级隔离（共享表+tenant_id），支持切换为库级隔离 |

---

## 5. 接口设计

### 5.1 API规范

| 规范 | 说明 |
|------|------|
| 风格 | RESTful API |
| 协议 | HTTPS (TLS 1.3) |
| 数据格式 | JSON (UTF-8) |
| 认证 | Bearer Token (JWT) |
| 版本 | URL路径版本 (/api/v1/) |
| 分页 | page/size参数，返回total |
| 错误码 | 统一错误码体系 |

### 5.2 核心API清单

| 服务 | 方法 | 路径 | 功能 |
|------|------|------|------|
| catalog | GET | /api/v1/assets | 资产列表查询 |
| catalog | POST | /api/v1/assets | 资产注册 |
| catalog | GET | /api/v1/assets/{id} | 资产详情 |
| catalog | PUT | /api/v1/assets/{id} | 资产更新 |
| catalog | GET | /api/v1/assets/search | 全文搜索 |
| catalog | GET | /api/v1/catalogs/tree | 目录树 |
| metadata | GET | /api/v1/metadata | 元数据查询 |
| metadata | POST | /api/v1/metadata/collect | 手动采集 |
| metadata | GET | /api/v1/metadata/{id}/lineage | 血缘查询 |
| quality | GET | /api/v1/quality/rules | 规则列表 |
| quality | POST | /api/v1/quality/rules | 创建规则 |
| quality | POST | /api/v1/quality/check | 执行检测 |
| quality | GET | /api/v1/quality/reports | 质量报告 |
| standard | GET | /api/v1/standards | 标准列表 |
| standard | POST | /api/v1/standards | 创建标准 |
| standard | POST | /api/v1/standards/mapping | 标准映射 |
| lineage | GET | /api/v1/lineage/{assetId} | 血缘图 |
| lineage | GET | /api/v1/lineage/impact | 影响分析 |
| mdm | GET | /api/v1/mdm/entities | 主数据实体 |
| mdm | POST | /api/v1/mdm/entities | 创建实体 |
| lifecycle | GET | /api/v1/lifecycle/policies | 策略列表 |
| lifecycle | POST | /api/v1/lifecycle/archive | 执行归档 |
| dataservice | GET | /api/v1/services | 服务列表 |
| dataservice | POST | /api/v1/services | 发布API |
| profiling | GET | /api/v1/profiling/tasks | 探查任务列表 |
| profiling | POST | /api/v1/profiling/tasks | 创建探查任务 |
| profiling | GET | /api/v1/profiling/{taskId}/results | 探查结果 |
| profiling | GET | /api/v1/profiling/{taskId}/report | 探查报告 |
| glossary | GET | /api/v1/glossary/terms | 术语列表 |
| glossary | POST | /api/v1/glossary/terms | 创建术语 |
| glossary | GET | /api/v1/glossary/categories | 术语分类树 |
| glossary | POST | /api/v1/glossary/terms/{id}/mapping | 术语关联元数据 |
| glossary | GET | /api/v1/glossary/terms/{id}/lineage | 术语关联资产 |
| workflow | GET | /api/v1/workflow/definitions | 流程定义列表 |
| workflow | POST | /api/v1/workflow/definitions | 部署流程定义 |
| workflow | GET | /api/v1/workflow/tasks | 待办任务列表 |
| workflow | POST | /api/v1/workflow/tasks/{id}/complete | 完成审批任务 |
| workflow | GET | /api/v1/workflow/instances/{id}/status | 流程实例状态 |
| workflow | GET | /api/v1/workflow/dashboard | 流程监控看板 |
| aigovernance | GET | /api/v1/aigovernance/datasets | 训练数据集列表 |
| aigovernance | POST | /api/v1/aigovernance/datasets/{id}/quality | 训练数据质量检测 |
| aigovernance | POST | /api/v1/aigovernance/datasets/{id}/compliance | 训练数据合规检查 |
| aigovernance | GET | /api/v1/aigovernance/drift | 数据漂移监控 |
| aigovernance | GET | /api/v1/aigovernance/dashboard | AI治理看板 |

### 5.3 统一响应格式

```json
{
  "code": 200,
  "message": "success",
  "data": { ... },
  "timestamp": "2026-07-10T10:00:00Z",
  "traceId": "uuid"
}
```

---

## 6. 安全架构设计

### 6.1 安全分层

```
┌─────────────────────────────────────────┐
│           安全审计层 (Audit)             │
│    操作日志 │ 数据访问日志 │ 安全告警     │
├─────────────────────────────────────────┤
│           安全防护层 (Protection)        │
│  WAF │ DDoS │ XSS │ SQL注入 │ CSRF      │
├─────────────────────────────────────────┤
│           认证授权层 (Auth)              │
│  JWT │ RBAC+ABAC │ SSO │ OAuth2         │
├─────────────────────────────────────────┤
│           数据安全层 (Data Security)     │
│  SM4加密 │ SM2签名 │ 脱敏 │ 国密TLS      │
├─────────────────────────────────────────┤
│           网络安全层 (Network)           │
│  VPC │ 安全组 │ 网络ACL │ 零信任          │
└─────────────────────────────────────────┘
```

### 6.2 权限模型

- **RBAC**: 角色-权限矩阵，支持角色继承
- **ABAC**: 基于属性的策略引擎（资源属性+用户属性+环境属性）
- **数据权限**: 行级（tenant_id）+ 列级（字段脱敏/可见性）
- **API权限**: 接口级别鉴权，支持IP白名单

---

## 7. 部署架构设计

### 7.1 部署拓扑

```
┌─────────────── Kubernetes Cluster ───────────────┐
│                                                   │
│  ┌─── Ingress Controller (Nginx) ───┐             │
│  │                                   │             │
│  ┌─── SmartData Services ───────────┐│             │
│  │  catalog-svc (x2)                ││             │
│  │  metadata-svc (x2)               ││             │
│  │  quality-svc (x2)                ││             │
│  │  standard-svc (x1)               ││             │
│  │  lineage-svc (x2)                ││             │
│  │  mdm-svc (x2)                    ││             │
│  │  lifecycle-svc (x1)              ││             │
│  │  dataservice-svc (x2)            ││             │
│  └──────────────────────────────────┘│             │
│                                       │             │
│  ┌─── Data Layer ───────────────────┐│             │
│  │  MySQL (主从) │ Redis (集群)      ││             │
│  │  ES (3节点)   │ Neo4j (主从)      ││             │
│  │  Kafka (3节点)│ MinIO (4节点)     ││             │
│  └──────────────────────────────────┘│             │
│                                       │             │
│  ┌─── Monitoring ───────────────────┐│             │
│  │  Prometheus │ Grafana │ Loki      ││             │
│  └──────────────────────────────────┘│             │
└───────────────────────────────────────┘
```

### 7.2 资源规划

| 组件 | CPU | 内存 | 存储 | 副本数 |
|------|:---:|:----:|:----:|:------:|
| catalog-service | 2 | 4G | - | 2 |
| metadata-service | 2 | 4G | - | 2 |
| quality-service | 4 | 8G | - | 2 |
| standard-service | 1 | 2G | - | 1 |
| lineage-service | 2 | 4G | - | 2 |
| mdm-service | 2 | 4G | - | 2 |
| lifecycle-service | 1 | 2G | - | 1 |
| dataservice-service | 2 | 4G | - | 2 |
| MySQL | 4 | 16G | 500G SSD | 2(主从) |
| Redis | 2 | 8G | - | 3(集群) |
| Elasticsearch | 4 | 16G | 200G SSD | 3 |
| Neo4j | 4 | 16G | 100G SSD | 2(主从) |
| Kafka | 2 | 4G | 200G | 3 |
| MinIO | 1 | 2G | 1T HDD | 4 |
| **合计** | **45** | **110G** | **2.8T** | - |

---

## 8. AI能力架构设计

### 8.1 AI能力分层

```
┌─────────────────────────────────────────┐
│         AI应用层 (AI Applications)       │
│  智能搜索 │ 智能标注 │ 异常检测 │ 修复建议│
├─────────────────────────────────────────┤
│         AI编排层 (AI Orchestration)      │
│  Prompt管理 │ RAG │ Agent │ 多模型路由    │
├─────────────────────────────────────────┤
│         AI基础层 (AI Foundation)         │
│  LangChain4j │ 向量DB │ 模型API适配器    │
├─────────────────────────────────────────┤
│         模型层 (Model Layer)            │
│  GPT-4 │ 文心一言 │ 通义千问 │ 私有模型   │
└─────────────────────────────────────────┘
```

### 8.2 AI能力矩阵

| AI能力 | 服务 | 模型 | 降级方案 |
|--------|------|------|---------|
| 自然语言搜索 | catalog | GPT/文心 | 关键词搜索 |
| 字段业务标注 | metadata | GPT/通义 | 规则匹配 |
| 质量异常检测 | quality | 私有模型 | 统计规则 |
| 血缘智能解析 | lineage | GPT/文心 | 正则解析 |
| 质量修复建议 | quality | GPT/文心 | 规则模板 |
| AI数据探查解读 | profiling | GPT/文心 | 统计报告 |
| AI术语推荐 | glossary | GPT/通义 | 规则匹配 |
| AI质量规则生成 | quality | GPT/文心 | 模板匹配 |
| AI数据分类分级 | metadata/安全 | 私有模型 | 规则引擎 |
| AI主数据去重 | mdm | 私有模型 | 规则匹配 |
| 训练数据偏见检测 | aigovernance | 私有模型 | 统计方法 |
| 数据漂移预测 | aigovernance | 私有模型 | 统计阈值 |

### 8.3 RAG架构

```
用户提问 → Query改写 → 向量检索(知识库) → Context组装 → LLM生成 → 结果过滤 → 返回
```

---

## 9. 信创适配设计

### 9.1 信创适配矩阵

| 层级 | 国产化组件 | 适配方式 |
|------|-----------|---------|
| CPU | 鲲鹏920/飞腾2000/龙芯3A5000 | 多架构Docker镜像 |
| OS | 麒麟V10/统信UOS/openEuler | 基础镜像适配 |
| 数据库 | 达梦DM8/人大金仓KingbaseES/openGauss | MyBatis方言适配 |
| 中间件 | 东方通/宝兰德 | Tomcat替代验证 |
| 浏览器 | 奇安信浏览器/红莲花浏览器 | 前端兼容测试 |
| 密码 | 天融信/卫士通密码机 | JCE Provider适配 |

### 9.2 国密算法应用

| 场景 | 算法 | 实现 |
|------|------|------|
| 传输加密 | SM2+SM4 (TLS) | 国密TLS |
| 数据加密 | SM4 (CBC/ECB) | common-crypto-gm |
| 数字签名 | SM2 | common-crypto-gm |
| 哈希校验 | SM3 | common-crypto-gm |
| 证书 | SM2 X.509 | 国密CA |

## 10. 新增模块架构设计（V1.1竞品分析补充）

> 本章节为V1.1版本基于综合竞品分析与评审报告(SD-CMA-01)新增的模块架构设计。

### 10.1 数据探查服务 (profiling-service)

#### 10.1.1 服务定位

数据探查服务提供自动化的数据画像与分析能力，帮助用户直观了解数据内容、分布特征和质量状况。

#### 10.1.2 核心数据模型

```
sd_profiling
├── sd_profile_task (探查任务)
│   ├── id, task_name, data_source_id, table_name
│   ├── status (PENDING/RUNNING/SUCCESS/FAILED)
│   ├── row_count, column_count
│   ├── health_score, anomaly_count
│   ├── started_at, finished_at
│   └── tenant_id
├── sd_profile_column (字段画像)
│   ├── id, task_id, column_name, data_type
│   ├── total_count, null_count, unique_count
│   ├── null_rate, unique_rate
│   ├── min_value, max_value, avg_value, stddev_value
│   ├── top_values (JSON), histogram (JSON)
│   ├── is_anomaly, anomaly_type
│   └── tenant_id
└── sd_profile_report (探查报告)
    ├── id, task_id, report_format, report_url
    └── tenant_id
```

#### 10.1.3 核心架构

```
用户发起探查 → 任务队列(Kafka) → 探查引擎(分布式)
    │                              ├── 统计计算模块 (空值/唯一/最值/分布)
    │                              ├── 异常检测模块 (IQR/Z-Score)
    │                              └── AI解读模块 (LLM生成数据洞察)
    ↓
探查结果存储 → ES索引(全文检索) → 前端可视化展示
```

### 10.2 业务术语表服务 (glossary-service)

#### 10.2.1 服务定位

业务术语表服务管理企业业务术语的全生命周期，建立业务术语与技术元数据的关联映射，消除业务与技术的语义鸿沟。

#### 10.2.2 核心数据模型

```
sd_glossary
├── sd_glossary_category (术语分类)
│   ├── id, parent_id, category_name, category_code
│   ├── sort_order, status
│   └── tenant_id
├── sd_glossary_term (业务术语)
│   ├── id, term_code, term_name, term_description
│   ├── category_id, status (DRAFT/PENDING/PUBLISHED)
│   ├── synonyms (JSON), abbreviations
│   ├── owner, department
│   ├── version, created_by, created_at
│   └── tenant_id
├── sd_glossary_mapping (术语-元数据关联)
│   ├── id, term_id, metadata_id, asset_id
│   ├── mapping_type (DIRECT/DERIVED/REFERENCE)
│   ├── mapping_status, confirmed_by
│   └── tenant_id
└── sd_glossary_synonym (同义词表)
    ├── id, term_id, synonym_text, synonym_type
    └── tenant_id
```

#### 10.2.3 核心架构

```
业务术语定义 → 分类管理 → 审批发布
     │                        │
     ↓                        ↓
AI术语推荐 ← 字段名/数据特征分析
     │
     ↓
术语关联元数据 → 关联率统计 → 业务语义层
```

### 10.3 治理工作流服务 (workflow-service)

#### 10.3.1 服务定位

治理工作流服务基于Flowable引擎，提供可视化流程设计、审批中心、SLA监控等能力，统一管理数据治理全流程审批。

#### 10.3.2 技术选型

| 组件 | 技术 | 选型理由 |
|------|------|---------|
| 工作流引擎 | Flowable 7.x | BPMN 2.0标准，轻量级，Spring Boot集成 |
| 流程设计器 | bpmn-js | 开源BPMN可视化设计器 |
| 表单引擎 | Flowable Form | 动态表单配置 |
| 消息通知 | 平台通知服务 | 统一通知通道 |

#### 10.3.3 核心架构

```
流程设计器(bpmn-js) → 流程定义部署(Flowable Repository)
                              │
                              ↓
业务事件触发 → 流程实例启动 → 任务分配 → 审批处理
     │              │              │           │
     │              ↓              ↓           ↓
     │         SLA计时器      待办工作台    审批记录
     │              │              │           │
     │              ↓              ↓           ↓
     └──→ 超时提醒/升级/转办 ←── 流程监控看板 ←── 审计日志
```

#### 10.3.4 治理流程模板

| 模板名称 | 触发事件 | 审批节点 |
|---------|---------|--------|
| 资产发布审批 | 资产状态变为待发布 | 数据负责人→数据治理管理员→发布 |
| 标准发布审批 | 标准状态变为待审核 | 标准管理员→标准委员会主任→发布 |
| 质量修复工单 | 质量检测不通过 | 自动派单→责任人修复→复检验证 |
| 主数据变更审批 | 主数据变更申请 | 业务申请人→主数据管理员→审批 |
| 术语发布审批 | 术语状态变为待审核 | 术语管理员→业务负责人→发布 |
| 敏感数据分级变更 | AI分级结果修正 | 安全管理员→合规负责人→确认 |

### 10.4 AI治理服务 (aigovernance-service)

#### 10.4.1 服务定位

AI治理服务是智数×智链双平台协同的核心模块，对AI模型训练数据进行专项治理，覆盖质量检测、合规检查、血缘追踪、漂移监控全链路。

#### 10.4.2 核心数据模型

```
sd_aigovernance
├── sd_ai_dataset (训练数据集)
│   ├── id, dataset_name, dataset_type (TEXT/IMAGE/AUDIO/TABULAR)
│   ├── source_system, model_id (关联智链模型)
│   ├── row_count, size_bytes, version
│   ├── quality_score, compliance_status
│   ├── drift_status, drift_score
│   └── tenant_id
├── sd_ai_quality_rule (训练数据质量规则)
│   ├── id, dataset_id, rule_name, rule_type
│   ├── rule_expression, severity
│   ├── pass_rate, fail_count
│   └── tenant_id
├── sd_ai_compliance_check (合规检查记录)
│   ├── id, dataset_id, check_type (COPYRIGHT/PRIVACY/SENSITIVE/BIAS)
│   ├── check_result, check_detail (JSON)
│   ├── check_time, checked_by
│   └── tenant_id
└── sd_ai_drift_record (数据漂移记录)
    ├── id, dataset_id, drift_dimension
    ├── drift_score, threshold, is_drifted
    ├── detected_at, baseline_version
    └── tenant_id
```

#### 10.4.3 核心架构

```
智链(SmartChain)                          智数(SmartData)
    │                                          │
    ├── 模型注册 ──────────────────────→ 训练数据集注册
    │                                          │
    ├── 训练任务触发 ───────────────────→ 训练数据质量检测
    │                                      ├── 完整性检测
    │                                      ├── 准确性检测
    │                                      ├── 多样性检测
    │                                      └── 偏见检测
    │                                          │
    ├── 模型部署 ──────────────────────→ 数据合规检查
    │                                      ├── 版权检查
    │                                      ├── 隐私检查
    │                                      └── 敏感信息扫描
    │                                          │
    ├── 模型推理 ──────────────────────→ 数据漂移监控
    │                                      ├── 输入分布变化
    │                                      ├── 特征漂移
    │                                      └── 预测分布变化
    │                                          │
    └── AI治理看板 ←──────────────────── AI治理报告
```

#### 10.4.4 与智链集成接口

| 接口 | 方向 | 描述 |
|------|------|------|
| POST /api/v1/aigovernance/datasets/register | 智链→智数 | 训练数据集注册 |
| POST /api/v1/aigovernance/quality/check | 智链→智数 | 触发训练数据质量检测 |
| GET /api/v1/aigovernance/datasets/{id}/lineage | 智链→智数 | 查询训练数据血缘 |
| POST /api/v1/aigovernance/drift/notify | 智数→智链 | 数据漂移预警通知 |
| GET /api/v1/aigovernance/dashboard | 智链→智数 | AI治理看板数据 |

### 10.5 新增服务部署规划

| 组件 | CPU | 内存 | 存储 | 副本数 |
|------|:---:|:----:|:----:|:------:|
| profiling-service | 2 | 4G | - | 2 |
| glossary-service | 1 | 2G | - | 1 |
| workflow-service | 2 | 4G | - | 2 |
| aigovernance-service | 2 | 4G | - | 2 |
| Flowable DB | 1 | 2G | 50G SSD | 1 |
| **新增合计** | **8** | **16G** | **50G** | - |

---

## 11. 跨平台集成架构设计（V1.2 平台协同）

> 本章节为V1.2版本基于全局视角的跨平台集成架构设计，详见《跨平台集成架构设计说明书》(SW-HLD-02)。

### 11.1 与智赢共享服务集成

智数平台所有微服务通过共享服务层获得统一的认证、审计、通知、配置、安全能力：

| 共享服务 | 集成方式 | 智数使用场景 |
|---------|---------|-------------|
| auth-service (8081) | JWT Token + Redis Session | 智数所有API鉴权，SSO共享会话 |
| audit-service (8084) | Kafka异步投递 | 资产发布/元数据变更/质量检测等审计 |
| dashboard-service (8085) | RestTemplate并行聚合 | 智数指标推送至全局Dashboard |
| config-service (8086) | Nacos Config订阅 | 智数动态配置、Feature Flag |
| notification-service (8087) | Kafka事件 + API | 治理审批通知、质量告警通知 |
| security-service (8083) | API调用 + 网关Filter | 敏感数据分级分类、动态脱敏 |
| system-service (8082) | API调用 | 用户/角色/组织/字典共享 |

### 11.2 与智链AI能力协同

```
智数(SmartData)                              智链(SmartChain)
    │                                              │
    ├── AI辅助元数据标注 ←── 模型调用API ←───── model-service
    ├── AI自然语言搜索   ←── 向量嵌入API ←───── model-service
    ├── AI质量异常检测   ←── 模型调用API ←───── model-service
    ├── AI数据探查解读   ←── 模型调用API ←───── model-service
    ├── AI术语推荐      ←── 模型调用API ←───── model-service
    ├── AI质量规则生成   ←── 模型调用API ←───── model-service
    ├── AI数据分类分级   ←── 模型调用API ←───── model-service
    │                                              │
    ├── 训练数据质量检测 ──→ 质量报告 ──→ model-service
    ├── 训练数据合规检查 ──→ 合规报告 ──→ model-service
    ├── 训练数据血缘查询 ──→ 血缘数据 ──→ model-service
    ├── 数据漂移预警    ──→ Kafka事件 ──→ risk-service
    └── 数据服务成本    ──→ Kafka事件 ──→ cost-service
```

### 11.3 智数指标接入全局Dashboard

智数平台以下指标接入智赢全局Dashboard（dashboard-service聚合）：

| 指标 | 来源服务 | API端点 | 说明 |
|------|---------|---------|------|
| 资产总数 | catalog-service | GET /api/smartdata/catalog/stats | 已注册数据资产数量 |
| 治理健康分 | catalog-service | GET /api/smartdata/catalog/health-score | 平台治理健康度评分 |
| 质量综合评分 | quality-service | GET /api/smartdata/quality/stats | 数据质量综合评分 |
| 血缘覆盖率 | lineage-service | GET /api/smartdata/lineage/stats | 有血缘表占比 |
| 标准落地率 | standard-service | GET /api/smartdata/standard/stats | 已落地标准占比 |
| AI治理合规率 | aigovernance-service | GET /api/smartdata/aigovernance/dashboard | 训练数据合规率 |

### 11.4 跨平台事件总线

智数平台通过Kafka消息总线与智链/智赢共享服务进行异步通信：

| Topic | 方向 | 消费者 | 说明 |
|-------|------|--------|------|
| sd-metadata-changed | 智数内部 | catalog/lineage/quality | 元数据变更通知 |
| sd-quality-task | 智数内部 | quality-service | 质量检测任务 |
| sd-profiling-task | 智数内部 | profiling-service | 数据探查任务 |
| sd-drift-alert | 智数→智链 | risk-service | 数据漂移预警 |
| sd-quality-report | 智数→智链 | model-service | 训练数据质量报告 |
| sd-data-service-cost | 智数→智链 | cost-service | 数据服务成本数据 |
| audit-queue | 智数→平台 | audit-service | 审计日志事件 |
| notification-queue | 智数→平台 | notification-service | 通知事件 |
| config-refresh | 平台→智数 | 所有智数服务 | 配置变更通知 |

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|---------|
| V1.0.0 | 2026-07-10 | 智数架构组 | 初始版本 |
| V1.1.0 | 2026-07-10 | 智数架构组 | 基于竞品分析新增模块架构设计（数据探查、业务术语表、治理工作流、AI治理），更新微服务划分与API清单 |
| V1.2.0 | 2026-07-10 | 智数架构组 | 新增跨平台集成架构设计章节，定义与智赢共享服务和智链AI能力的集成方案 |

---

> **文档结束** — 智数(SmartData)概要设计说明书 V1.2.0
