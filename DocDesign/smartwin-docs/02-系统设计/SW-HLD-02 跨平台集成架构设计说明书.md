# 智赢 (SmartWin) 跨平台集成架构设计说明书

| 属性 | 内容 |
|------|------|
| 文档编号 | SW-HLD-02 |
| 文档名称 | 跨平台集成架构设计说明书 |
| 版本号 | V1.0.0 |
| 状态 | 已评审 |
| 编制日期 | 2026-07-10 |
| 编制人 | 平台架构组 |
| 审核人 | 技术总监 |

---

## 目录

1. [设计目标与原则](#1-设计目标与原则)
2. [跨平台集成总体架构](#2-跨平台集成总体架构)
3. [共享服务集成层](#3-共享服务集成层)
4. [智链×智数业务协同集成](#4-智链智数业务协同集成)
5. [跨平台数据流转架构](#5-跨平台数据流转架构)
6. [跨平台前端集成设计](#6-跨平台前端集成设计)
7. [跨平台安全与合规集成](#7-跨平台安全与合规集成)
8. [跨平台运维与监控集成](#8-跨平台运维与监控集成)
9. [集成接口清单](#9-集成接口清单)
10. [部署与实施路径](#10-部署与实施路径)

---

## 1. 设计目标与原则

### 1.1 设计目标

| 目标 | 描述 | 验收标准 |
|------|------|---------|
| 统一身份 | 一次登录，三平台通行 | SSO会话共享，切换零延迟 |
| 统一审计 | 全链路操作可追溯 | TraceId贯穿智链→智数→共享服务 |
| 统一看板 | 跨平台运营数据一屏总览 | 全局Dashboard聚合双平台指标 |
| 深度协同 | 智链AI能力赋能智数治理 | AI标注/检测/搜索调用智链模型API |
| 数据闭环 | 智数质量数据反哺智链训练 | 训练数据质量检测结果同步至智链 |
| 统一通知 | 跨平台消息统一收件箱 | 审批/告警/系统通知统一推送 |

### 1.2 设计原则

```
┌───────────────────────────────────────────────────────┐
│                  跨平台集成设计原则                       │
├───────────┬───────────┬───────────┬───────────────────┤
│  松耦合    │  高内聚    │  可独立    │  标准化            │
│  Loose    │  High     │  Independ. │  Standardized     │
│  Coupling │  Cohesion │  Deployable│                   │
├───────────┼───────────┼───────────┼───────────────────┤
│ 平台间通过│ 每个平台内│ 智链/智数/ │ 统一API规范、统一   │
│ API/MQ通信│ 部署完整、│ 共享服务可│ 响应格式、统一错误码│
│ 不共享DB  │ 功能自洽  │ 独立部署  │ 统一认证体系       │
└───────────┴───────────┴───────────┴───────────────────┘
```

---

## 2. 跨平台集成总体架构

### 2.1 三层集成架构全景图

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          用户接入层 (User Access)                             │
│                                                                              │
│   ┌─────────────────────────────────────────────────────────────────┐       │
│   │              统一门户入口 (Unified Portal)                        │       │
│   │   智赢工作台 │ 智链控制台 │ 智数治理台 │ 全局Dashboard            │       │
│   └────────────────────────────┬────────────────────────────────────┘       │
│                                │ SSO Session共享                            │
├────────────────────────────────┼────────────────────────────────────────────┤
│                          网关层 (Gateway)                                     │
│                                │                                             │
│   ┌────────────────────────────┴────────────────────────────────────┐       │
│   │           Spring Cloud Gateway (Port: 9000)                      │       │
│   │                                                                  │       │
│   │  /api/auth/**     → auth-service (8081)                         │       │
│   │  /api/system/**   → system-service (8082)                       │       │
│   │  /api/security/**  → security-service (8083)                    │       │
│   │  /api/audit/**     → audit-service (8084)                       │       │
│   │  /api/dashboard/** → dashboard-service (8085)                   │       │
│   │  /api/config/**    → config-service (8086)                      │       │
│   │  /api/notification/** → notification-service (8087)             │       │
│   │  /api/smartchain/** → 智链服务集群 (8101-8108)                   │       │
│   │  /api/smartdata/**  → 智数服务集群 (8401-8412)                   │       │
│   └──────────────────────────────────────────────────────────────────┘       │
├──────────────────────────────────────────────────────────────────────────────┤
│                     业务平台层 (Business Platform)                             │
│                                                                              │
│   ┌──────────────────────┐         ┌──────────────────────┐                 │
│   │  智链 SmartChain      │         │  智数 SmartData       │                 │
│   │  (AI运营管理)          │         │  (数据治理)            │                 │
│   │                      │         │                      │                 │
│   │  model-service:8101  │◄────────►│  catalog-service:8401│                 │
│   │  agent-service:8102   │  API/   │  metadata-svc:8402   │                 │
│   │  cost-service:8103    │  MQ     │  quality-svc:8403    │                 │
│   │  risk-service:8104    │  协同   │  standard-svc:8404   │                 │
│   │  prompt-service:8105  │         │  lineage-svc:8405    │                 │
│   │  app-service:8106     │         │  mdm-svc:8406        │                 │
│   │  (7个微服务)           │         │  lifecycle-svc:8407  │                 │
│   │                      │         │  dataservice-svc:8408│                 │
│   │                      │         │  profiling-svc:8409  │                 │
│   │                      │         │  glossary-svc:8410   │                 │
│   │                      │         │  workflow-svc:8411   │                 │
│   │                      │         │  aigovernance-svc:8412│                 │
│   └──────────┬───────────┘         └──────────┬───────────┘                 │
│              │                                │                              │
│              └──────────┬─────────────────────┘                              │
│                         │                                                    │
├─────────────────────────┼────────────────────────────────────────────────────┤
│                  共享服务层 (Shared Services)                                  │
│                         │                                                    │
│   ┌─────────────────────┴──────────────────────────────────────────┐        │
│   │                                                                │        │
│   │  auth-service    │ system-service  │ security-service          │        │
│   │  (8081)          │ (8082)          │ (8083)                    │        │
│   │  JWT/SSO/RBAC    │ 用户/角色/组织   │ 分级分类/脱敏/国密         │        │
│   │                  │                 │                            │        │
│   │  audit-service   │ dashboard-svc   │ config-service            │        │
│   │  (8084)          │ (8085)          │ (8086)                    │        │
│   │  全链路审计       │ 统一仪表盘       │ 动态配置/Feature Flag     │        │
│   │                  │                 │                            │        │
│   │  notification-service (8087)                                   │        │
│   │  站内信/邮件/短信/钉钉/飞书                                      │        │
│   └────────────────────────────────────────────────────────────────┘        │
├──────────────────────────────────────────────────────────────────────────────┤
│                  基础设施层 (Infrastructure)                                   │
│                                                                              │
│  Nacos(注册/配置) │ Redis(缓存/会话) │ Kafka(消息总线) │ MySQL/DM8(业务库)    │
│  ES(搜索引擎) │ Neo4j(血缘图) │ MinIO(对象存储) │ Flowable(工作流引擎)      │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 三平台职责边界

| 层级 | SmartWin (智赢) | SmartChain (智链) | SmartData (智数) |
|------|----------------|-------------------|------------------|
| **定位** | 一体化平台底座 | AI运营管理 | 数据治理 |
| **服务范围** | 7个共享微服务 | 7个业务微服务 | 12个业务微服务 |
| **端口段** | 8081-8087, 9000 | 8101-8108 | 8401-8412 |
| **数据库** | sw_auth, sw_system, sw_audit, sw_security | sc_model, sc_agent, sc_cost, sc_risk | sd_catalog, sd_metadata, sd_quality 等12个 |
| **独立部署** | ✅ 可独立部署 | ✅ 可独立部署 | ✅ 可独立部署 |
| **组合部署** | 智赢=智链+智数+共享服务 | 智链+共享服务 | 智数+共享服务 |

### 2.3 集成模式矩阵

| 集成场景 | 集成模式 | 通信方式 | 技术实现 |
|---------|---------|---------|---------|
| 认证鉴权 | 中心化 | 同步 | JWT Token + Redis Session |
| 审计日志 | 中心化 | 异步 | Kafka → audit-service |
| 数据看板 | 聚合 | 同步(并行) | CompletableFuture + RestTemplate |
| AI能力调用 | 点对点 | 同步 | OpenFeign → 智链model-service |
| 训练数据治理 | 点对点 | 同步+异步 | API + Kafka事件通知 |
| 消息通知 | 中心化 | 异步 | Kafka → notification-service |
| 配置管理 | 中心化 | 发布订阅 | Nacos Config + Spring Cloud Bus |
| 工作流审批 | 中心化 | 同步 | Flowable + workflow-service |

---

## 3. 共享服务集成层

### 3.1 统一认证授权 (auth-service)

#### 3.1.1 SSO集成架构

```
┌──────────┐     ┌──────────┐     ┌──────────┐
│ 智链前端  │     │ 智数前端  │     │ 智赢门户  │
│ :5173    │     │ :5174    │     │ :5175    │
└────┬─────┘     └────┬─────┘     └────┬─────┘
     │                │                │
     │  ① 携带JWT     │  ① 携带JWT     │  ① 携带JWT
     │    请求API     │    请求API     │    请求API
     ↓                ↓                ↓
┌─────────────────────────────────────────────┐
│        Spring Cloud Gateway (:9000)          │
│                                              │
│  ② JwtAuthenticationFilter                  │
│     ├── 解析JWT Token                        │
│     ├── 校验Redis Session有效性               │
│     ├── 注入用户信息到Header                  │
│     │   X-User-Id / X-Username / X-Tenant   │
│     │   X-Roles / X-Permissions              │
│     └── 注入TraceId                           │
└──────────────────┬──────────────────────────┘
                   │
     ┌─────────────┼─────────────┐
     ↓             ↓             ↓
┌─────────┐  ┌─────────┐  ┌─────────┐
│智链服务  │  │智数服务  │  │共享服务  │
│8101-8108│  │8401-8412│  │8081-8087│
└─────────┘  └─────────┘  └─────────┘
```

#### 3.1.2 跨平台权限模型

```
RBAC + ABAC 双模型

角色树 (跨平台统一):
├── SUPER_ADMIN (超级管理员)
│   ├── 智链: 全部权限
│   ├── 智数: 全部权限
│   └── 平台: 全部权限
├── AI_OPS_MANAGER (AI运营经理)
│   ├── 智链: 模型/Agent/成本/风险 管理
│   ├── 智数: AI治理 查看
│   └── 平台: Dashboard 查看
├── DATA_GOVERNOR (数据治理管理员)
│   ├── 智数: 全部治理权限
│   ├── 智链: 模型 查看
│   └── 平台: Dashboard 查看
├── DATA_ANALYST (数据分析师)
│   ├── 智数: 资产搜索/质量查看/血缘分析
│   ├── 智链: AI应用 使用
│   └── 平台: 个人工作台
└── VIEWER (查看者)
    ├── 智链: 只读
    ├── 智数: 只读
    └── 平台: 只读

权限编码规范:
  {platform}:{module}:{action}
  示例:
    smartchain:model:create    → 智链-模型-创建
    smartdata:catalog:publish  → 智数-资产-发布
    platform:audit:export      → 平台-审计-导出
```

### 3.2 统一审计 (audit-service)

#### 3.2.1 全链路审计架构

```
用户操作
  │
  ├── 智链操作 (model/agent/cost/risk)
  │     └── audit-client (AOP切面) ──→ Kafka: audit-queue ──→ audit-service
  │
  ├── 智数操作 (catalog/metadata/quality/standard)
  │     └── audit-client (AOP切面) ──→ Kafka: audit-queue ──→ audit-service
  │
  └── 平台操作 (auth/system/security)
        └── audit-client (AOP切面) ──→ Kafka: audit-queue ──→ audit-service
                                                                    │
                                                                    ↓
                                                          ┌─────────────────┐
                                                          │ audit-service   │
                                                          │                 │
                                                          │ ├── 日志存储     │
                                                          │ │   (MySQL/ES)  │
                                                          │ ├── TraceId关联  │
                                                          │ ├── 合规报告     │
                                                          │ └── 审计查询API  │
                                                          └─────────────────┘
```

#### 3.2.2 审计事件分类

| 事件类别 | 来源平台 | 审计要点 | 示例 |
|---------|---------|---------|------|
| 认证事件 | SmartWin | 登录/登出/Token刷新 | admin登录智赢平台 |
| 模型操作 | SmartChain | 模型CRUD/版本发布/APIKey | 创建GPT-4o模型接入 |
| Agent操作 | SmartChain | Agent编排/执行/停止 | 运维巡检Agent执行 |
| 成本操作 | SmartChain | 预算设置/成本导出 | 设置月度AI预算10万 |
| 风险事件 | SmartChain | 风险检测/事件处理 | 检测到敏感信息泄露 |
| 资产操作 | SmartData | 资产注册/发布/下架 | 发布客户主数据资产 |
| 元数据操作 | SmartData | 采集/标注/变更 | AI自动标注100个字段 |
| 质量操作 | SmartData | 规则创建/检测/修复 | 执行数据质量巡检 |
| 标准操作 | SmartData | 标准定义/映射/审批 | 发布数据标准DM-001 |
| 血缘操作 | SmartData | 血缘采集/影响分析 | 查询客户表下游影响 |
| 安全操作 | SmartData | 分级分类/脱敏配置 | 修改手机号脱敏策略 |
| 工作流操作 | SmartData | 流程审批/SLA超时 | 审批资产发布申请 |

### 3.3 统一仪表盘 (dashboard-service)

#### 3.3.1 跨平台指标聚合架构

```
                    ┌─────────────────────┐
                    │  全局Dashboard API   │
                    │  /api/dashboard/     │
                    │  global-overview     │
                    └──────────┬──────────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
    ┌─────────┴──────┐ ┌──────┴───────┐ ┌──────┴───────┐
    │ 智链指标聚合    │ │ 智数指标聚合   │ │ 平台指标聚合  │
    │ fetchSCStats() │ │ fetchSDStats()│ │ fetchSWStats()│
    └───────┬────────┘ └──────┬───────┘ └──────┬───────┘
            │                 │                │
     ┌──────┴──────┐   ┌─────┴──────┐   ┌─────┴──────┐
     │ model-svc   │   │catalog-svc │   │ auth-svc   │
     │ /stats      │   │ /stats     │   │ /stats     │
     ├─────────────┤   ├────────────┤   ├────────────┤
     │ cost-svc    │   │quality-svc │   │ audit-svc  │
     │ /summary    │   │ /stats     │   │ /stats     │
     ├─────────────┤   ├────────────┤   ├────────────┤
     │ risk-svc    │   │lineage-svc │   │ config-svc │
     │ /statistics │   │ /stats     │   │ /health    │
     ├─────────────┤   ├────────────┤   └────────────┘
     │ app-svc     │   │aigov-svc   │
     │ /stats      │   │ /dashboard │
     ├─────────────┤   └────────────┘
     │ agent-svc   │
     │ /stats      │
     └─────────────┘

     CompletableFuture 并行聚合
     Redis 缓存 TTL=30s
     超时降级 3s → 返回缓存/空数据
```

#### 3.3.2 全局Dashboard指标体系

| 指标分类 | 指标名称 | 来源 | 单位 | 说明 |
|---------|---------|------|------|------|
| **AI运营** | 在线模型数 | model-service | 个 | 当前在线可用模型 |
| **AI运营** | 今日调用量 | model-service | 次 | 今日AI API调用次数 |
| **AI运营** | 今日成本 | cost-service | 元 | 今日AI调用总成本 |
| **AI运营** | 活跃应用数 | app-service | 个 | 当前活跃AI应用 |
| **AI运营** | 运行中Agent | agent-service | 个 | 正在执行的Agent |
| **AI运营** | 风险事件数 | risk-service | 个 | 待处理风险事件 |
| **数据治理** | 资产总数 | catalog-service | 个 | 已注册数据资产 |
| **数据治理** | 治理健康分 | catalog-service | 分 | 平台治理健康度评分 |
| **数据治理** | 质量评分 | quality-service | % | 数据质量综合评分 |
| **数据治理** | 血缘覆盖率 | lineage-service | % | 有血缘表/总表 |
| **数据治理** | 标准落地率 | standard-service | % | 已落地标准/总标准 |
| **数据治理** | AI治理合规率 | aigovernance-svc | % | 训练数据合规率 |
| **平台运营** | 总用户数 | auth-service | 个 | 平台注册用户 |
| **平台运营** | 活跃用户数 | auth-service | 个 | 今日活跃用户 |
| **平台运营** | 服务健康度 | config-service | % | 健康服务/总服务 |
| **平台运营** | 今日审计数 | audit-service | 条 | 今日操作审计条数 |

---

## 4. 智链×智数业务协同集成

### 4.1 协同场景总览

```
┌──────────────────────────────────────────────────────────────────────┐
│                    智链 × 智数 六大协同场景                              │
│                                                                      │
│  ┌─────────────┐                          ┌─────────────┐           │
│  │ 智链SmartChain│                        │ 智数SmartData │           │
│  │             │                          │             │           │
│  │  ┌─────────┐│  ① AI能力供给            │┌──────────┐ │           │
│  │  │大模型API │├─────────────────────────→││AI辅助标注 │ │           │
│  │  │模型路由  ││  LLM/Embedding/Multimodal││智能搜索   │ │           │
│  │  └─────────┘│                          ││异常检测   │ │           │
│  │             │                          │└──────────┘ │           │
│  │             │                          │             │           │
│  │  ┌─────────┐│  ② 训练数据供给           │┌──────────┐ │           │
│  │  │模型训练  │├─────────────────────────→││数据资产   │ │           │
│  │  │模型微调  ││  高质量数据集             ││数据服务API│ │           │
│  │  └─────────┘│                          │└──────────┘ │           │
│  │             │                          │             │           │
│  │  ┌─────────┐│  ③ 训练数据质量治理       │┌──────────┐ │           │
│  │  │模型管理  │├─────────────────────────→││AI治理服务 │ │           │
│  │  │版本管理  ││  质量检测/合规检查         ││质量检测   │ │           │
│  │  └─────────┘│                          ││合规检查   │ │           │
│  │             │                          │└──────────┘ │           │
│  │             │                          │             │           │
│  │  ┌─────────┐│  ④ 数据漂移预警           │┌──────────┐ │           │
│  │  │模型推理  ││←─────────────────────────┤│漂移监控   │ │           │
│  │  │模型监控  ││  漂移事件通知             ││预警通知   │ │           │
│  │  └─────────┘│                          │└──────────┘ │           │
│  │             │                          │             │           │
│  │  ┌─────────┐│  ⑤ 血缘追踪               │┌──────────┐ │           │
│  │  │模型血缘  │├─────────────────────────→││数据血缘   │ │           │
│  │  │训练追溯  ││  血缘查询/影响分析         ││Neo4j图    │ │           │
│  │  └─────────┘│                          │└──────────┘ │           │
│  │             │                          │             │           │
│  │  ┌─────────┐│  ⑥ 成本数据联动           │┌──────────┐ │           │
│  │  │成本中心  ││←─────────────────────────┤│数据服务   │ │           │
│  │  │成本分摊  ││  数据服务调用量/成本       ││API计量    │ │           │
│  │  └─────────┘│                          │└──────────┘ │           │
│  └─────────────┘                          └─────────────┘           │
└──────────────────────────────────────────────────────────────────────┘
```

### 4.2 场景一：AI能力供给（智链→智数）

#### 4.2.1 AI能力调用链路

```
智数服务 (metadata/quality/catalog/glossary/aigovernance)
  │
  ├── common-ai SDK
  │     ├── AiEngineProperties (配置模型路由)
  │     ├── SmartDataAiClient (智数专用AI客户端)
  │     └── MultimodalAIService (多模态服务)
  │
  ├── 请求路由
  │     ├── 场景: 元数据标注 → 智链model-service /api/smartchain/models/invoke
  │     ├── 场景: 质量异常检测 → 智链model-service /api/smartchain/models/invoke
  │     ├── 场景: 自然语言搜索 → 智链model-service /api/smartchain/models/embed
  │     └── 场景: 数据探查解读 → 智链model-service /api/smartchain/models/invoke
  │
  └── 降级策略
        ├── 智链模型不可用 → 切换备用模型
        ├── 所有模型不可用 → 降级为规则引擎
        └── 超时(5s) → 返回缓存结果/默认值
```

#### 4.2.2 AI能力调用接口

| 接口 | 方向 | 路径 | 说明 |
|------|------|------|------|
| 模型调用 | 智数→智链 | POST /api/smartchain/models/invoke | 统一模型调用入口 |
| 向量嵌入 | 智数→智链 | POST /api/smartchain/models/embed | 文本向量化 |
| 多模态识别 | 智数→智链 | POST /api/smartchain/models/multimodal | 图像/文档识别 |
| 模型列表 | 智数→智链 | GET /api/smartchain/models?status=1 | 获取可用模型列表 |
| 模型健康 | 智数→智链 | GET /api/smartchain/models/health | 模型健康检查 |

### 4.3 场景二：训练数据治理（智链→智数）

#### 4.3.1 训练数据治理流程

```
智链: 模型训练任务启动
  │
  ├── ① 训练数据集注册
  │     POST /api/smartdata/aigovernance/datasets/register
  │     { datasetName, modelId, datasetType, sourceSystem }
  │
  ├── ② 触发质量检测
  │     POST /api/smartdata/aigovernance/datasets/{id}/quality
  │     → 完整性/准确性/多样性/偏见检测
  │     → 返回质量报告
  │
  ├── ③ 触发合规检查
  │     POST /api/smartdata/aigovernance/datasets/{id}/compliance
  │     → 版权/隐私/敏感信息扫描
  │     → 返回合规报告
  │
  ├── ④ 查询血缘
  │     GET /api/smartdata/aigovernance/datasets/{id}/lineage
  │     → 训练数据全链路血缘
  │
  └── ⑤ 获取治理看板
        GET /api/smartdata/aigovernance/dashboard
        → AI治理全景看板
```

#### 4.3.2 数据漂移监控流程

```
智链: 模型推理服务
  │
  ├── 实时采集模型输入数据特征
  │
  ├── 定期推送基线数据
  │     POST /api/smartdata/aigovernance/drift/baseline
  │     { modelId, baselineFeatures, baselineVersion }
  │
  └── 智数: 漂移检测引擎
        ├── 计算分布距离 (PSI/KL散度/JS散度)
        ├── 判定漂移状态
        ├── 如果漂移:
        │     ├── Kafka事件: drift-alert
        │     ├── 通知智链: POST /api/smartchain/models/drift-notify
        │     └── 通知平台: notification-service
        └── 更新漂移记录
```

### 4.4 场景三：数据服务成本联动（智数→智链）

```
智数: 数据服务API调用
  │
  ├── API调用计量
  │     ├── 记录调用次数/数据量/响应时间
  │     └── 按AppKey维度统计
  │
  ├── 成本数据推送 (定时/事件)
  │     Kafka: data-service-cost → cost-service
  │     { appKey, apiId, callCount, dataSize, timestamp }
  │
  └── 智链: 成本中心
        ├── 接收数据服务成本
        ├── 按部门/项目分摊
        ├── 合并AI调用成本 + 数据服务成本
        └── 生成综合成本报告
```

---

## 5. 跨平台数据流转架构

### 5.1 Kafka消息总线设计

```
┌──────────────────────────────────────────────────────────────┐
│                  Kafka 消息总线 (3节点集群)                    │
│                                                              │
│  Topic 设计:                                                 │
│                                                              │
│  ┌── 平台级 ─────────────────────────────────────────────┐  │
│  │ audit-queue          → audit-service 消费              │  │
│  │ notification-queue   → notification-service 消费       │  │
│  │ config-refresh       → 所有服务订阅                     │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌── 智链→智数 ──────────────────────────────────────────┐  │
│  │ sc-training-data-request → aigovernance-svc 消费       │  │
│  │ sc-model-deployed       → aigovernance-svc 消费       │  │
│  │ sc-drift-baseline       → aigovernance-svc 消费       │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌── 智数→智链 ──────────────────────────────────────────┐  │
│  │ sd-drift-alert         → risk-service 消费             │  │
│  │ sd-quality-report      → model-service 消费            │  │
│  │ sd-data-service-cost   → cost-service 消费             │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌── 智数内部 ───────────────────────────────────────────┐  │
│  │ sd-quality-task        → quality-svc 消费              │  │
│  │ sd-profiling-task      → profiling-svc 消费            │  │
│  │ sd-metadata-changed    → catalog/lineage/quality 订阅  │  │
│  └────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

### 5.2 事件驱动通信规范

```json
// 统一事件消息格式
{
  "eventId": "uuid-v4",
  "eventType": "sd.drift.alert",
  "source": "aigovernance-service",
  "target": "risk-service",
  "traceId": "从网关传递的TraceId",
  "tenantId": 1001,
  "timestamp": "2026-07-10T10:00:00Z",
  "payload": {
    "modelId": 1,
    "datasetId": 42,
    "driftScore": 0.35,
    "threshold": 0.2,
    "driftDimensions": ["age", "income"]
  }
}
```

### 5.3 数据一致性策略

| 场景 | 一致性级别 | 策略 |
|------|----------|------|
| 认证状态 | 强一致 | Redis同步写入，JWT实时校验 |
| 审计日志 | 最终一致 | Kafka异步投递，at-least-once |
| 跨平台指标 | 最终一致 | Redis缓存30s，容忍短暂不一致 |
| 训练数据治理 | 最终一致 | API同步调用 + Kafka事件确认 |
| 漂移预警 | 最终一致 | Kafka事件，30s内送达 |
| 成本数据 | 最终一致 | 定时批量同步 + 事件增量同步 |

---

## 6. 跨平台前端集成设计

### 6.1 统一门户架构

```
┌──────────────────────────────────────────────────────────────────┐
│                    智赢统一门户 (Unified Portal)                   │
│                                                                  │
│  ┌── 顶部导航栏 (Shared Header) ──────────────────────────────┐ │
│  │ [智赢Logo] [全局Dashboard] [智链] [智数] [系统管理]  🔍 🔔 👤│ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌── 全局搜索 ───────────────────────────────────────────────┐  │
│  │ 输入关键词 → 同时搜索:                                      │  │
│  │   智链: 模型/Agent/应用/Prompt                              │  │
│  │   智数: 数据资产/元数据/术语/标准                            │  │
│  │   平台: 用户/审计日志/配置项                                 │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌── 统一通知中心 ───────────────────────────────────────────┐  │
│  │ 📋 待办审批 (智数工作流)                                    │  │
│  │ ⚠️ 风险告警 (智链风险监控)                                   │  │
│  │ 📊 质量报告 (智数质量检测)                                   │  │
│  │ 💰 预算预警 (智链成本管控)                                   │  │
│  │ 🔧 系统通知 (平台运维)                                      │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌── 内容区域 (Micro-Frontend) ──────────────────────────────┐  │
│  │                                                            │  │
│  │  根据导航选择加载对应的子应用:                                │  │
│  │  ├── 全局Dashboard → dashboard模块 (内嵌)                   │  │
│  │  ├── 智链 → smartchain-frontend (qiankun子应用)             │  │
│  │  ├── 智数 → smartdata-frontend (qiankun子应用)              │  │
│  │  └── 系统管理 → system模块 (内嵌)                           │  │
│  │                                                            │  │
│  └────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
```

### 6.2 共享组件库集成

| 共享组件 | 用途 | 使用方 |
|---------|------|-------|
| AppLayout | 统一应用布局框架 | 智链/智数/平台 |
| GlobalSearch | 跨平台全局搜索 | 统一门户 |
| NotificationCenter | 统一通知中心 | 智链/智数/平台 |
| Breadcrumb | 面包屑导航 | 智链/智数/平台 |
| ThemeSwitcher | 主题切换(亮/暗) | 智链/智数/平台 |
| LangSwitcher | 语言切换(中/英) | 智链/智数/平台 |
| StatCard | 统计卡片 | Dashboard/各模块 |
| Pagination | 分页组件 | 智链/智数列表 |
| ConfirmDialog | 确认弹窗 | 智链/智数/平台 |
| Toast | 消息提示 | 智链/智数/平台 |

### 6.3 前端路由规划

```
统一门户路由:
/
├── /global-dashboard          → 全局Dashboard (平台)
├── /smartchain/*              → 智链子应用 (qiankun)
│   ├── /smartchain/dashboard  → 智链工作台
│   ├── /smartchain/models     → 模型管理
│   ├── /smartchain/agents     → Agent编排
│   ├── /smartchain/cost       → 成本管控
│   ├── /smartchain/risk       → 风险监控
│   └── ...
├── /smartdata/*               → 智数子应用 (qiankun)
│   ├── /smartdata/catalog     → 数据资产
│   ├── /smartdata/metadata    → 元数据管理
│   ├── /smartdata/quality     → 数据质量
│   ├── /smartdata/lineage     → 血缘分析
│   ├── /smartdata/aigovernance→ AI治理
│   └── ...
├── /system/*                  → 系统管理 (平台内嵌)
│   ├── /system/users          → 用户管理
│   ├── /system/roles          → 角色管理
│   ├── /system/orgs           → 组织管理
│   └── ...
├── /audit/*                   → 审计管理 (平台内嵌)
│   ├── /audit/logs            → 审计日志
│   └── /audit/trace           → 链路追踪
└── /profile/*                 → 个人中心 (平台内嵌)
    ├── /profile/info          → 个人资料
    ├── /profile/security      → 安全设置
    └── /profile/notifications → 通知设置
```

---

## 7. 跨平台安全与合规集成

### 7.1 统一安全架构

```
┌─────────────────────────────────────────────────────────────┐
│                    安全防护层级                                │
│                                                             │
│  ┌── L1: 网络安全 ──────────────────────────────────────┐ │
│  │ VPC隔离 │ 安全组 │ WAF │ DDoS防护 │ 零信任网络         │ │
│  └─────────────────────────────────────────────────────┘ │
│  ┌── L2: 传输安全 ──────────────────────────────────────┐ │
│  │ 国密TLS (SM2+SM4) │ 证书管理 │ HSTS │ 安全响应头       │ │
│  └─────────────────────────────────────────────────────┘ │
│  ┌── L3: 认证授权 ──────────────────────────────────────┐ │
│  │ JWT Token │ RBAC+ABAC │ SSO(LDAP/OAuth2/CAS)          │ │
│  │ 速率限制 │ XSS防护 │ CSRF防护                          │ │
│  └─────────────────────────────────────────────────────┘ │
│  ┌── L4: 数据安全 ──────────────────────────────────────┐ │
│  │ SM4存储加密 │ SM2数字签名 │ SM3完整性校验              │ │
│  │ 动态脱敏 │ 敏感数据分级分类 │ 数据生命周期管理           │ │
│  └─────────────────────────────────────────────────────┘ │
│  ┌── L5: 审计合规 ──────────────────────────────────────┐ │
│  │ 全链路审计 │ 合规报告 │ 等保2.0三级 │ 数据安全法合规     │ │
│  └─────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### 7.2 跨平台安全策略联动

| 策略场景 | 联动方式 | 说明 |
|---------|---------|------|
| 敏感数据识别 | 智数DSC → 平台security-service | 智数AI分级结果同步至平台安全策略 |
| 脱敏策略执行 | 平台security-service → 网关Filter | 网关层统一脱敏，覆盖所有平台 |
| API速率限制 | 平台 → 网关RateLimitFilter | 按用户/角色/API维度限流 |
| 安全告警 | 任意平台 → Kafka → notification | 安全事件统一告警通道 |
| 密钥管理 | 平台crypto-gm → 所有服务 | 统一国密密钥管理 |

---

## 8. 跨平台运维与监控集成

### 8.1 统一监控架构

```
┌──────────────────────────────────────────────────────────────┐
│                   统一监控体系                                  │
│                                                              │
│  ┌── 指标采集 ───────────────────────────────────────────┐  │
│  │ Prometheus (指标) + Loki (日志) + Jaeger (追踪)        │  │
│  │                                                       │  │
│  │  智链服务 → Micrometer → Prometheus                   │  │
│  │  智数服务 → Micrometer → Prometheus                   │  │
│  │  共享服务 → Micrometer → Prometheus                   │  │
│  │  所有服务 → Logback → Promtail → Loki                 │  │
│  │  所有服务 → Sleuth → Jaeger                           │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌── 可视化 ─────────────────────────────────────────────┐  │
│  │ Grafana Dashboard                                      │  │
│  │  ├── 平台总览看板 (服务健康/资源/告警)                   │  │
│  │  ├── 智链运营看板 (模型QPS/成本/风险)                   │  │
│  │  ├── 智数治理看板 (采集/质量/血缘)                      │  │
│  │  └── 基础设施看板 (DB/Redis/ES/Neo4j/Kafka)            │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌── 告警 ───────────────────────────────────────────────┐  │
│  │ Alertmanager → notification-service                   │  │
│  │  ├── 服务宕机 → URGENT (电话+短信+钉钉)                │  │
│  │  ├── 响应超时 → HIGH (钉钉+邮件)                       │  │
│  │  ├── 资源告警 → NORMAL (邮件)                          │  │
│  │  └── 业务异常 → LOW (站内信)                           │  │
│  └───────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

### 8.2 统一日志规范

```
日志格式 (JSON):
{
  "timestamp": "2026-07-10T10:00:00.000Z",
  "level": "INFO",
  "service": "catalog-service",
  "platform": "smartdata",
  "traceId": "a1b2c3d4e5f6",
  "spanId": "a1b2c3d4",
  "tenantId": 1001,
  "userId": 1,
  "username": "admin",
  "action": "ASSET_PUBLISH",
  "message": "资产[客户主数据]发布成功",
  "extra": {
    "assetId": 42,
    "assetName": "客户主数据"
  }
}
```

---

## 9. 集成接口清单

### 9.1 跨平台API接口

| 编号 | 接口名称 | 方向 | 方法 | 路径 | 说明 |
|------|---------|------|------|------|------|
| INT-001 | 统一登录 | 前端→Auth | POST | /api/auth/login | 跨平台SSO登录 |
| INT-002 | Token刷新 | 前端→Auth | POST | /api/auth/refresh | 刷新JWT Token |
| INT-003 | 用户权限 | 前端→Auth | GET | /api/auth/permissions | 获取跨平台权限 |
| INT-004 | 审计日志查询 | 前端→Audit | GET | /api/audit/logs | 统一审计查询 |
| INT-005 | 链路追踪 | 前端→Audit | GET | /api/audit/trace/{traceId} | 全链路追踪 |
| INT-006 | 全局看板 | 前端→Dashboard | GET | /api/dashboard/global-overview | 跨平台指标聚合 |
| INT-007 | 时序指标 | 前端→Dashboard | GET | /api/dashboard/metrics | 指标时序数据 |
| INT-008 | 通知收件箱 | 前端→Notification | GET | /api/notification/inbox | 统一通知 |
| INT-009 | 发送通知 | 服务→Notification | POST | /api/notification/send | 内部通知发送 |
| INT-010 | 配置查询 | 服务→Config | GET | /api/config/items | 动态配置查询 |
| INT-011 | Feature Flag | 服务→Config | GET | /api/config/feature-flags | 功能开关 |
| INT-012 | 模型调用 | 智数→智链 | POST | /api/smartchain/models/invoke | AI能力调用 |
| INT-013 | 向量嵌入 | 智数→智链 | POST | /api/smartchain/models/embed | 文本向量化 |
| INT-014 | 训练数据注册 | 智链→智数 | POST | /api/smartdata/aigovernance/datasets/register | 训练数据集注册 |
| INT-015 | 质量检测 | 智链→智数 | POST | /api/smartdata/aigovernance/datasets/{id}/quality | 训练数据质量检测 |
| INT-016 | 合规检查 | 智链→智数 | POST | /api/smartdata/aigovernance/datasets/{id}/compliance | 合规性检查 |
| INT-017 | 漂移预警 | 智数→智链 | POST | /api/smartchain/models/drift-notify | 数据漂移通知 |
| INT-018 | AI治理看板 | 智链→智数 | GET | /api/smartdata/aigovernance/dashboard | AI治理数据 |
| INT-019 | 安全分级规则 | 服务→Security | GET | /api/security/classification/rules | 分级分类规则 |
| INT-020 | 脱敏策略 | 服务→Security | GET | /api/security/desensitize/masks | 脱敏策略查询 |
| INT-021 | 国密状态 | 服务→Security | GET | /api/security/crypto/status | 密码服务状态 |

### 9.2 Kafka事件接口

| 编号 | Topic | 生产者 | 消费者 | 说明 |
|------|-------|--------|--------|------|
| EVT-001 | audit-queue | 所有服务 | audit-service | 审计日志事件 |
| EVT-002 | notification-queue | 所有服务 | notification-service | 通知事件 |
| EVT-003 | config-refresh | config-service | 所有服务 | 配置变更事件 |
| EVT-004 | sc-training-data-request | model-service | aigovernance-svc | 训练数据请求 |
| EVT-005 | sc-model-deployed | model-service | aigovernance-svc | 模型部署事件 |
| EVT-006 | sc-drift-baseline | model-service | aigovernance-svc | 漂移基线推送 |
| EVT-007 | sd-drift-alert | aigovernance-svc | risk-service | 漂移预警事件 |
| EVT-008 | sd-quality-report | quality-service | model-service | 质量报告事件 |
| EVT-009 | sd-data-service-cost | dataservice-svc | cost-service | 数据服务成本 |
| EVT-010 | sd-metadata-changed | metadata-service | catalog/lineage/quality | 元数据变更事件 |

---

## 10. 部署与实施路径

### 10.1 部署模式

| 模式 | 说明 | 智链 | 智数 | 共享服务 | 适用场景 |
|------|------|------|------|---------|---------|
| 一体化部署 | 全量部署 | ✅ | ✅ | ✅ | 大型企业/政府 |
| 智链独立 | 仅智链 | ✅ | ❌ | ✅ | AI运营需求 |
| 智数独立 | 仅智数 | ❌ | ✅ | ✅ | 数据治理需求 |
| SaaS模式 | 云端多租户 | ✅ | ✅ | ✅ | 中小企业 |

### 10.2 实施里程碑

| 阶段 | 时间 | 集成任务 | 交付物 |
|------|------|---------|--------|
| **阶段一** | Sprint 7-9 | 共享服务集成(认证/审计/通知) | SSO打通、统一审计、统一通知 |
| **阶段二** | Sprint 10-12 | 全局Dashboard + 全局搜索 | 跨平台看板、全局搜索 |
| **阶段三** | Sprint 13-15 | 智链×智数AI能力协同 | AI能力调用链路、训练数据治理 |
| **阶段四** | Sprint 16-18 | 深度协同 + 安全联动 | 漂移监控、安全策略联动、成本联动 |
| **阶段五** | Sprint 19+ | 统一门户 + 微前端 | qiankun微前端、统一门户上线 |

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|---------|
| V1.0.0 | 2026-07-10 | 平台架构组 | 初始版本，定义跨平台集成总体架构 |

---

> **文档结束** — 智赢(SmartWin)跨平台集成架构设计说明书 V1.0.0
