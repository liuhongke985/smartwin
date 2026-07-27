# 智数 (SmartData) 功能差距补充概要设计说明书

| 属性 | 内容 |
|------|------|
| 文档编号 | SD-HLD-02 |
| 文档名称 | 智数平台功能差距补充概要设计说明书 |
| 版本号 | V1.0.0 |
| 状态 | 已评审 |
| 编制日期 | 2026-07-15 |
| 编制人 | 智数架构组 |
| 审核人 | 技术总监 / 架构委员会 |

---

## 目录

1. [补充架构总览](#1-补充架构总览)
2. [新增微服务设计](#2-新增微服务设计)
3. [数据探查服务架构设计](#3-数据探查服务架构设计)
4. [标签管理服务架构设计](#4-标签管理服务架构设计)
5. [治理工作流服务架构设计](#5-治理工作流服务架构设计)
6. [数据资产估值服务架构设计](#6-数据资产估值服务架构设计)
7. [数据产品服务架构设计](#7-数据产品服务架构设计)
8. [自助分析服务架构设计](#8-自助分析服务架构设计)
9. [数据集成服务架构设计](#9-数据集成服务架构设计)
10. [服务间依赖与通信设计](#10-服务间依赖与通信设计)
11. [安全架构补充设计](#11-安全架构补充设计)
12. [部署架构补充设计](#12-部署架构补充设计)

---

## 1. 补充架构总览

### 1.1 V2.0 架构全景图

```
┌────────────────────────────────────────────────────────────────────────────┐
│                          用户层 (User Layer)                                 │
│    Web浏览器  │  移动端H5(审批)  │  开放API  │  CLI工具                       │
├────────────────────────────────────────────────────────────────────────────┤
│                       接入层 (Access Layer)                                  │
│         Spring Cloud Gateway │ Nginx │ WebSocket                            │
├──────────┬──────────┬──────────┬──────────┬──────────┬──────────────────────┤
│  数据资产  │  元数据   │  数据质量  │  数据标准  │  数据血缘  │  主数据管理       │
│catalog-svc│metadata  │quality   │standard  │lineage   │mdm-svc             │
├──────────┼──────────┼──────────┼──────────┼──────────┼──────────────────────┤
│  数据探查  │  标签管理  │  治理工作流 │  资产估值  │  数据产品  │  自助分析        │
│profiling │  tag-svc  │workflow  │valuation │dataproduct│analytics-svc      │
│  -svc    │          │  -svc    │  -svc    │  -svc    │                    │
├──────────┼──────────┴──────────┴──────────┴──────────┼──────────────────────┤
│  数据集成  │           业务术语表  │  生命周期  │  数据服务  │  AI治理            │
│integration│          glossary-svc│lifecycle │dataservice│aigovernance-svc   │
│  -svc    │                    │  -svc    │  -svc    │                    │
├──────────┴────────────────────┴──────────┴──────────┴──────────────────────┤
│                     平台公共层 (Platform Common)                             │
│  common-security │ common-db │ common-mq │ common-ai │ common-storage       │
│  common-util │ common-crypto-gm │ common-db-multi │ common-db-rw            │
├────────────────────────────────────────────────────────────────────────────┤
│                     基础设施层 (Infrastructure)                              │
│  MySQL/DM8 │ Redis │ Elasticsearch │ Neo4j │ Kafka │ MinIO │ Flowable       │
└────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 新增服务清单

| 服务名 | 端口 | 功能域 | 数据库 | 依赖中间件 | 状态 |
|--------|------|--------|--------|-----------|:----:|
| profiling-service | 8409 | 数据探查与画像 | sd_profiling | ES, Redis, Kafka | 新增 |
| tag-service | 8413 | 标签体系管理 | sd_tag | ES, Redis | 新增 |
| workflow-service | 8411 | 治理工作流引擎 | sd_workflow | Redis, Flowable | 新增 |
| valuation-service | 8414 | 数据资产估值 | sd_valuation | Redis | 新增 |
| dataproduct-service | 8415 | 数据产品化与市场 | sd_dataproduct | Redis, Kafka, MinIO | 新增 |
| analytics-service | 8416 | 自助分析与取数 | sd_analytics | ES, Redis, Kafka | 新增 |
| integration-service | 8417 | 轻量级数据集成 | sd_integration | Redis, Kafka, MinIO | 新增 |

### 1.3 技术选型

| 技术领域 | 选型 | 理由 |
|---------|------|------|
| 工作流引擎 | Flowable 7.x (BPMN 2.0) | 轻量级、嵌入式、Spring Boot集成好、社区活跃 |
| 数据探查引擎 | Apache Calcite + 自研统计引擎 | 支持多数据源SQL解析，统计计算高效 |
| 大数据量同步 | 自研基于JDBC Batch + Kafka | 轻量级，不引入额外大数据组件 |
| AI能力 | LangChain4j + 智链AI平台 | 复用已有AI基础设施，支持多模型路由 |
| 前端流程设计器 | bpmn-js (Camunda) | BPMN 2.0标准，开源活跃，Vue适配好 |
| 前端SQL编辑器 | Monaco Editor | VS Code同款，功能强大 |
| 前端图表 | ECharts 5.x | 复用已有组件库 |

---

## 2. 新增微服务设计

### 2.1 微服务总体依赖图

```
                          ┌──────────────────┐
                          │  Gateway (8080)   │
                          └────────┬─────────┘
                                   │
          ┌────────────────────────┼────────────────────────┐
          │                        │                        │
   ┌──────┴──────┐         ┌──────┴──────┐         ┌──────┴──────┐
   │ integration │         │  profiling  │         │     tag     │
   │   -svc      │         │    -svc     │         │    -svc     │
   └──────┬──────┘         └──────┬──────┘         └──────┬──────┘
          │                       │                       │
          │ 采集元数据              │ 探查数据               │ 打标
          ▼                       ▼                       ▼
   ┌──────────────┐        ┌──────────────┐        ┌──────────────┐
   │  metadata    │        │  catalog     │        │  catalog     │
   │    -svc      │        │    -svc      │        │    -svc      │
   └──────────────┘        └──────┬───────┘        └──────────────┘
                                   │
                    ┌──────────────┼──────────────┐
                    │              │              │
             ┌──────┴──────┐ ┌────┴──────┐ ┌─────┴───────┐
             │  workflow   │ │ valuation │ │dataproduct  │
             │    -svc     │ │   -svc    │ │    -svc     │
             └──────┬──────┘ └─────┬─────┘ └──────┬──────┘
                    │              │              │
                    │ RACI分配      │ 估值数据      │ 上架审批
                    │ 审批触发      │              │
                    ▼              ▼              ▼
             ┌──────────────┐ ┌──────────┐ ┌──────────────┐
             │ 全部服务      │ │ quality  │ │ dataservice  │
             │ (审批集成)    │ │  -svc    │ │    -svc      │
             └──────────────┘ └──────────┘ └──────────────┘
                                                      │
                                               ┌──────┴──────┐
                                               │  analytics  │
                                               │    -svc     │
                                               └─────────────┘
```

### 2.2 服务职责定义

| 服务 | 职责 | 对外API | 事件消费 | 事件发布 |
|------|------|---------|---------|---------|
| profiling-service | 数据探查任务管理、统计分析、异常检测、AI解读 | RESTful | asset.published | profiling.completed, profiling.anomaly |
| tag-service | 标签体系管理、自动打标、标签集市 | RESTful | asset.published, profiling.completed | tag.assigned, tag.removed |
| workflow-service | 流程设计、审批中心、RACI矩阵、SLA管理 | RESTful + Webhook | asset.draft, quality.issue.created | workflow.approved, workflow.rejected |
| valuation-service | 资产估值模型、ROI分析、成本管理 | RESTful | profiling.completed, quality.score.updated | valuation.completed |
| dataproduct-service | 数据产品管理、市场、订阅、计量计费 | RESTful | workflow.approved, dataservice.api.called | product.published, product.subscribed |
| analytics-service | SQL工作台、可视化分析、无代码取数 | RESTful + WebSocket | — | query.executed |
| integration-service | 数据源管理、同步任务、元数据采集 | RESTful | — | metadata.collected, sync.completed |

---

## 3. 数据探查服务架构设计

### 3.1 架构图

```
┌─────────────────────────────────────────────────────────┐
│                  profiling-service                       │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌─ API Layer ────────────────────────────────────────┐ │
│  │  ProfilingController                                │ │
│  │  ├── POST /api/profiling/tasks        发起探查      │ │
│  │  ├── GET  /api/profiling/tasks/{id}   任务详情      │ │
│  │  ├── GET  /api/profiling/tasks        任务列表      │ │
│  │  ├── GET  /api/profiling/results/{id} 探查结果      │ │
│  │  ├── POST /api/profiling/schedules    定时策略      │ │
│  │  ├── GET  /api/profiling/sampling     数据采样      │ │
│  │  └── POST /api/profiling/ai-insight   AI解读        │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌─ Service Layer ────────────────────────────────────┐ │
│  │  ProfilingTaskService    任务管理                    │ │
│  │  ProfilingEngine         探查引擎                    │ │
│  │  ├── StatisticsModule    统计计算(空值/唯一/最值/分布)│ │
│  │  ├── AnomalyModule       异常检测(IQR/Z-Score)      │ │
│  │  ├── PatternModule       模式识别(正则匹配)          │ │
│  │  └── SamplingModule      数据采样(随机/条件/脱敏)    │ │
│  │  AiInsightService        AI解读(调用智链AI)          │ │
│  │  ProfilingScheduleService 定时调度                   │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌─ Data Access Layer ─────────────────────────────────┐│
│  │  ProfileTaskMapper → sd_profile_task               ││
│  │  ProfileColumnMapper → sd_profile_column           ││
│  │  ProfileReportMapper → sd_profile_report           ││
│  │  ProfileScheduleMapper → sd_profile_schedule       ││
│  └─────────────────────────────────────────────────────┘│
│                                                          │
│  ┌─ Async Layer ──────────────────────────────────────┐ │
│  │  Kafka Consumer: profiling.task.queue              │ │
│  │  Kafka Producer: profiling.completed               │ │
│  │  Kafka Producer: profiling.anomaly                 │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌─ Integration Layer ────────────────────────────────┐ │
│  │  DataSourceConnector → 多数据源连接(JDBC)           │ │
│  │  CatalogServiceClient → 资产信息查询(Feign)         │ │
│  │  AiClient → AI能力调用(common-ai)                   │ │
│  │  SecurityClient → 脱敏规则查询(Feign)               │ │
│  └─────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### 3.2 探查执行流程

```
用户发起探查
    │
    ▼
ProfilingTaskService.createTask()
    ├── 参数校验（数据源权限、并发限制）
    ├── 保存任务记录(status=PENDING)
    └── 发送Kafka消息: profiling.task.queue
         │
         ▼
    ProfilingEngine.execute(task)
         │
         ├── 1. 连接数据源（DataSourceConnector）
         │      └── 支持MySQL/DM8/Kingbase/openGauss
         │
         ├── 2. 获取表结构（列名、类型、行数）
         │
         ├── 3. 统计计算（StatisticsModule）
         │      ├── 全表/抽样：SELECT COUNT(*), COUNT(DISTINCT col)...
         │      ├── 数值型：MIN/MAX/AVG/STDDEV/PERCENTILE
         │      ├── 字符型：LENGTH统计 + Top-N高频值
         │      └── 日期型：MIN/MAX + 分布统计
         │
         ├── 4. 异常检测（AnomalyModule）
         │      ├── IQR: Q1-1.5*IQR ~ Q3+1.5*IQR
         │      └── Z-Score: |value - mean| / stddev > 3
         │
         ├── 5. 模式识别（PatternModule）
         │      └── 正则匹配: 手机/邮箱/身份证/URL/IP...
         │
         ├── 6. AI解读（AiInsightService，异步）
         │      ├── 组装探查结果摘要
         │      ├── 调用智链AI生成解读文本
         │      └── 生成质量规则推荐
         │
         ├── 7. 保存结果到ES索引（支持全文检索）
         │
         └── 8. 更新任务状态(status=SUCCESS)
              └── 发送Kafka: profiling.completed
                   └── 触发: 标签服务(AI打标)、估值服务(更新评分)
```

### 3.3 多数据源适配设计

```
┌──────────────────────────────────────────┐
│         DataSourceConnector              │
│            (接口定义)                     │
│  + connect(config): Connection           │
│  + getTableSchema(table): TableSchema    │
│  + executeQuery(sql): ResultSet          │
│  + executeCount(table): long             │
│  + sample(table, limit): ResultSet       │
└─────────────┬────────────────────────────┘
              │
    ┌─────────┼─────────┬──────────┬──────────┐
    │         │         │          │          │
┌───┴───┐ ┌──┴───┐ ┌───┴──┐ ┌────┴───┐ ┌────┴───┐
│ MySQL │ │ DM8  │ │Kingbase│ │openGauss│ │PostgreSQL│
│Conn.  │ │Conn. │ │Conn.  │ │Conn.   │ │Conn.   │
└───────┘ └──────┘ └───────┘ └────────┘ └────────┘
```

> 使用 common-db-multi 的 DatabaseDialectResolver 自动适配方言，统计SQL根据方言生成。

---

## 4. 标签管理服务架构设计

### 4.1 架构图

```
┌─────────────────────────────────────────────────────────┐
│                    tag-service                            │
├─────────────────────────────────────────────────────────┤
│  ┌─ API Layer ────────────────────────────────────────┐ │
│  │  TagCategoryController  标签分类管理                 │ │
│  │  TagController          标签CRUD + 版本管理          │ │
│  │  TagRuleController      打标规则管理                 │ │
│  │  TagAssignmentController 打标操作(手动/AI/规则)      │ │
│  │  TagMarketController    标签集市                    │ │
│  │  TagDashboardController 标签统计看板                 │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌─ Service Layer ────────────────────────────────────┐ │
│  │  TagCategoryService     分类树管理                   │ │
│  │  TagService             标签生命周期                 │ │
│  │  TagRuleEngine          规则打标引擎                 │ │
│  │  ├── RegexRuleMatcher   正则匹配                    │ │
│  │  ├── KeywordMatcher     关键字匹配                  │ │
│  │  └── FieldNameMatcher   字段名匹配                  │ │
│  │  AiTaggingService       AI打标(调用智链AI)           │ │
│  │  TagInheritanceService  标签继承                    │ │
│  │  TagAuditService        打标审计                    │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌─ Data Access Layer ─────────────────────────────────┐│
│  │  TagCategoryMapper → sd_tag_category                ││
│  │  TagMapper → sd_tag_definition                      ││
│  │  TagRuleMapper → sd_tag_rule                        ││
│  │  TagAssignmentMapper → sd_tag_assignment            ││
│  │  TagVersionMapper → sd_tag_version                  ││
│  └─────────────────────────────────────────────────────┘│
│                                                          │
│  ┌─ Event Layer ──────────────────────────────────────┐ │
│  │  Kafka Consumer:                                     │ │
│  │  ├── asset.published → 触发规则打标                  │ │
│  │  └── profiling.completed → 触发AI打标                │ │
│  │  Kafka Producer:                                     │ │
│  │  ├── tag.assigned → 通知catalog更新标签              │ │
│  │  └── tag.removed → 通知catalog更新标签              │ │
│  └─────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### 4.2 自动打标流程

```
事件触发（asset.published 或 profiling.completed）
    │
    ▼
TagRuleEngine.match(asset)
    │
    ├── 加载所有启用的打标规则
    │
    ├── 逐规则匹配
    │   ├── RegexRuleMatcher: 正则匹配表名/字段名
    │   ├── KeywordMatcher: 关键字匹配表名/字段名/描述
    │   └── FieldNameMatcher: 字段名模式匹配
    │
    ├── 匹配结果去重 + 优先级排序
    │
    └── 输出匹配标签列表
         │
         ▼ (并行)
    AiTaggingService.recommend(asset, profilingResult)
         │
         ├── 组装上下文（表名/字段/数据探查摘要/业务术语）
         ├── 调用智链AI生成标签推荐
         └── 输出AI推荐标签列表(含置信度)
              │
              ▼
    合并规则标签 + AI标签
         │
         ├── 规则标签: 自动打标（高置信度）
         ├── AI标签(置信度≥80%): 自动打标
         ├── AI标签(置信度60-80%): 待确认
         └── AI标签(置信度<60%): 丢弃
              │
              ▼
    保存打标记录 → 发送 tag.assigned 事件
```

---

## 5. 治理工作流服务架构设计

### 5.1 架构图

```
┌─────────────────────────────────────────────────────────┐
│                 workflow-service                          │
├─────────────────────────────────────────────────────────┤
│  ┌─ API Layer ────────────────────────────────────────┐ │
│  │  ProcessDefinitionController  流程定义管理            │ │
│  │  ProcessInstanceController    流程实例管理            │ │
│  │  TaskController               审批任务管理            │ │
│  │  RaciMatrixController         RACI矩阵管理            │ │
│  │  SlaController                SLA配置与监控            │ │
│  │  ProcessTemplateController    流程模板管理             │ │
│  │  ProcessAnalyticsController   流程统计分析             │ │
│  │  WorkflowCallbackController   外部回调接口             │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌─ Service Layer ────────────────────────────────────┐ │
│  │  ProcessDefinitionService 流程定义(部署Flowable BPMN) │ │
│  │  ProcessInstanceService   流程实例(启动/查询/终止)    │ │
│  │  TaskService              审批任务(待办/审批/转办)    │ │
│  │  RaciService              RACI矩阵(角色/活动/分配)   │ │
│  │  SlaService               SLA(配置/监控/超时处理)    │ │
│  │  ProcessTemplateService   流程模板(内置模板/自定义)   │ │
│  │  ProcessAnalyticsService  流程分析(统计/瓶颈)        │ │
│  │  WorkflowEventListener    事件监听(流程事件→通知)    │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌─ Flowable Engine ──────────────────────────────────┐ │
│  │  ProcessEngine          流程引擎核心                  │ │
│  │  RepositoryService      流程部署管理                  │ │
│  │  RuntimeService         流程运行时                    │ │
│  │  TaskService            任务管理                      │ │
│  │  HistoryService         历史记录                      │ │
│  │  ManagementService      引擎管理                      │ │
│  │  ┌─ Custom Listeners ────────────────────────────┐  │ │
│  │  │  SlaTimerListener    SLA超时监听器              │  │ │
│  │  │  RaciAssignmentListener RACI审批人分配          │  │ │
│  │  │  NotificationListener 审批通知                  │  │ │
│  │  │  AuditListener       流程审计                   │  │ │
│  │  └────────────────────────────────────────────────┘  │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌─ Integration Layer ────────────────────────────────┐ │
│  │  NotificationClient → 通知服务(站内信/邮件)          │ │
│  │  CatalogClient → 资产状态更新                       │ │
│  │  QualityClient → 质量问题状态更新                    │ │
│  │  StandardClient → 标准状态更新                      │ │
│  │  MdmClient → 主数据变更执行                         │ │
│  │  DataProductClient → 数据产品上架                   │ │
│  └─────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### 5.2 Flowable集成设计

#### 5.2.1 嵌入式部署

```java
// Flowable与Spring Boot集成配置
@Configuration
public class FlowableConfig implements EngineConfigurationConfigurer<SpringProcessEngineConfiguration> {
    @Override
    public void configure(SpringProcessEngineConfiguration config) {
        config.setDatabaseType("mysql"); // 支持切换为dm8
        config.setAsyncExecutorEnabled(true);
        config.setAsyncExecutorActivate(true);
        config.setJobExecutorActivate(true);
        // SLA超时定时器
        config.setClock(new DefaultClockImpl());
    }
}
```

#### 5.2.2 BPMN流程定义示例（资产发布审批）

```xml
<?xml version="1.0" encoding="UTF-8"?>
<definitions xmlns="http://www.omg.org/spec/BPMN/20100524/MODEL"
             xmlns:flowable="http://flowable.org/bpmn"
             targetNamespace="smartwin">
  <process id="asset_publish_approval" name="资产发布审批流程">
    <startEvent id="start" name="发起"/>
    <userTask id="admin_review" name="数据管理员审核"
              flowable:assignee="${raciService.getApprover('ASSET_PUBLISH', 'DATA_ADMIN')}">
      <extensionElements>
        <flowable:taskListener event="create"
          class="com.smartwin.smartdata.workflow.listener.SlaTimerListener">
          <flowable:field name="slaHours"><flowable:string>24</flowable:string></flowable:field>
        </flowable:taskListener>
      </extensionElements>
    </userTask>
    <exclusiveGateway id="gateway1" name="审核结果"/>
    <userTask id="owner_approve" name="数据所有者审批"
              flowable:assignee="${raciService.getApprover('ASSET_PUBLISH', 'DATA_OWNER')}"/>
    <exclusiveGateway id="gateway2" name="审批结果"/>
    <endEvent id="approved" name="发布"/>
    <endEvent id="rejected" name="拒绝"/>
    <endEvent id="returned" name="退回"/>
    <!-- 连线省略 -->
  </process>
</definitions>
```

### 5.3 RACI引擎设计

```
┌─────────────────────────────────────────────────────────┐
│                    RACI引擎                               │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  治理活动定义         角色定义           RACI矩阵         │
│  ┌──────────┐       ┌──────────┐      ┌──────────┐      │
│  │ASSET_PUBLISH│    │DATA_OWNER│      │  R │  A  │      │
│  │STANDARD_APPROVAL│ │DATA_ADMIN│      │  C │  R  │      │
│  │QUALITY_FIX │     │DATA_STEWARD│    │  I │  C  │      │
│  │MDM_CHANGE  │     │QUALITY_OWNER│   │    │  I  │      │
│  │PRODUCT_LIST│     │BIZ_OWNER │      │    │     │      │
│  │...         │     │...       │      │    │     │      │
│  └──────────┘       └──────────┘      └──────────┘      │
│                                                          │
│  raciService.getApprover(activity, roleType)             │
│    → 查询矩阵获取角色 → 查询用户角色映射 → 返回审批人      │
│                                                          │
│  raciService.getResponsible(activity)                    │
│    → 查询矩阵获取R角色 → 返回责任人列表                    │
│                                                          │
│  raciService.checkCoverage()                             │
│    → 检查所有活动是否有A角色 → 检查角色负载均衡             │
│    → 返回覆盖率报告                                       │
└─────────────────────────────────────────────────────────┘
```

### 5.4 SLA超时处理流程

```
Flowable定时器触发 (SlaTimerListener)
    │
    ▼
SlaService.checkTimeout(task)
    │
    ├── 获取任务SLA配置和已耗时
    │
    ├── 判断超时等级
    │   ├── 临近超时（80% SLA）→ 发送提醒通知
    │   ├── 超时 → 执行超时策略
    │   │   ├── REMIND: 发送催办通知（站内信+邮件）
    │   │   ├── ESCALATE: 升级到上级审批人
    │   │   ├── TRANSFER: 转办到指定代理人
    │   │   ├── AUTO_APPROVE: 自动通过
    │   │   └── AUTO_REJECT: 自动拒绝
    │   └── 严重超时（200% SLA）→ 通知管理员
    │
    └── 记录SLA事件 → 更新SLA监控看板
```

---

## 6. 数据资产估值服务架构设计

### 6.1 架构图

```
┌─────────────────────────────────────────────────────────┐
│                 valuation-service                         │
├─────────────────────────────────────────────────────────┤
│  ┌─ API Layer ────────────────────────────────────────┐ │
│  │  ValuationController       估值管理(触发/查询/配置)  │ │
│  │  RoiController             ROI分析(计算/趋势/导出)   │ │
│  │  CostController            成本管理(采集/录入/分摊)  │ │
│  │  ValuationDashboardController 估值看板               │ │
│  │  ValuationReportController 估值报告导出              │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌─ Service Layer ────────────────────────────────────┐ │
│  │  ValuationService         估值核心服务               │ │
│  │  ├── CostValuationMethod  成本法估值                 │ │
│  │  ├── RevenueValuationMethod 收益法估值               │ │
│  │  ├── MarketValuationMethod 市场法估值                │ │
│  │  └── CompositeValuationMethod 综合估值               │ │
│  │  DimensionScoreService    维度评分服务               │ │
│  │  ├── QualityDimension     质量维度                   │ │
│  │  ├── UsageDimension       使用频率维度               │ │
│  │  ├── CoverageDimension    业务覆盖维度               │ │
│  │  ├── ScarcityDimension    稀缺性维度                 │ │
│  │  ├── TimelinessDimension  时效性维度                 │ │
│  │  └── ComplianceDimension  合规性维度                 │ │
│  │  RoiService               ROI计算与分析              │ │
│  │  CostService              成本采集与分摊              │ │
│  │  ValuationScheduleService 估值定时调度               │ │
│  │  ValuationReportService   估值报告生成               │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌─ Data Aggregation Layer ────────────────────────────┐│
│  │  CatalogDataFetcher  → 资产基本信息(Feign)           ││
│  │  QualityDataFetcher  → 质量评分(Feign)               ││
│  │  DataServiceFetcher  → API调用统计(Feign)             ││
│  │  DataProductFetcher  → 订阅收入(Feign)                ││
│  │  LineageDataFetcher  → 血缘覆盖度(Feign)              ││
│  │  StorageDataFetcher  → 存储成本(监控API)              ││
│  └─────────────────────────────────────────────────────┘│
│                                                          │
│  ┌─ Event Layer ──────────────────────────────────────┐ │
│  │  Kafka Consumer:                                     │ │
│  │  ├── profiling.completed → 触发维度评分更新           │ │
│  │  ├── quality.score.updated → 触发质量维度更新         │ │
│  │  └── product.subscribed → 触发收益维度更新           │ │
│  └─────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### 6.2 估值计算流程

```
估值触发（定时/手动）
    │
    ▼
ValuationService.executeValuation(assetId)
    │
    ├── 1. 数据聚合（并行）
    │   ├── CatalogDataFetcher → 资产基本信息
    │   ├── QualityDataFetcher → 质量评分
    │   ├── DataServiceFetcher → 月调用次数
    │   ├── DataProductFetcher → 订阅收入
    │   ├── LineageDataFetcher → 关联系统数
    │   └── StorageDataFetcher → 存储成本
    │
    ├── 2. 维度评分计算
    │   ├── QualityDimension.score(qualityScore) → 0-100
    │   ├── UsageDimension.score(monthlyCalls) → 0-100
    │   ├── CoverageDimension.score(relatedSystems) → 0-100
    │   ├── ScarcityDimension.score(similarAssetCount) → 0-100
    │   ├── TimelinessDimension.score(updateFrequency) → 0-100
    │   └── ComplianceDimension.score(complianceRate) → 0-100
    │
    ├── 3. 估值方法计算
    │   ├── CostValuation: 采集成本 + 存储成本 + 治理成本
    │   ├── RevenueValuation: 月均收入 × 12 × 估值倍数
    │   └── MarketValuation: 参考价格 × 资产规模系数
    │
    ├── 4. 综合估值
    │   └── compositeValue = costValue × W_cost
    │                       + revenueValue × W_revenue
    │                       + marketValue × W_market
    │   └── dimensionMultiplier = Σ(dimensionScore × W_dimension) / 100
    │   └── finalValue = compositeValue × dimensionMultiplier
    │
    ├── 5. 保存估值快照（不可修改）
    │
    └── 6. 更新估值看板缓存
```

---

## 7. 数据产品服务架构设计

### 7.1 架构图

```
┌─────────────────────────────────────────────────────────┐
│                dataproduct-service                        │
├─────────────────────────────────────────────────────────┤
│  ┌─ API Layer ────────────────────────────────────────┐ │
│  │  DataProductController     产品CRUD + 版本管理       │ │
│  │  ProductMarketController   市场浏览/搜索/推荐        │ │
│  │  SubscriptionController    订阅申请/审批/管理         │ │
│  │  BillingController         计量采集/计费/账单         │ │
│  │  ProductReviewController   产品评价                  │ │
│  │  ProductAuditController    产品审计                  │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌─ Service Layer ────────────────────────────────────┐ │
│  │  DataProductService       产品生命周期管理           │ │
│  │  ProductMarketService     市场搜索/推荐              │ │
│  │  SubscriptionService      订阅全流程                 │ │
│  │  ├── SubscriptionValidator 订阅校验                 │ │
│  │  ├── AuthorizationManager  授权管理(API Key+权限)   │ │
│  │  └── SubscriptionLifecycle 订阅生命周期(续订/退订)  │ │
│  │  BillingService           计量计费                  │ │
│  │  ├── MeteringCollector    计量数据采集(Kafka消费)   │ │
│  │  ├── BillingCalculator    费用计算                  │ │
│  │  └── BillGenerator        账单生成                  │ │
│  │  ProductReviewService     评价管理                  │ │
│  │  ProductComplianceService 合规检查                  │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌─ Integration Layer ────────────────────────────────┐ │
│  │  WorkflowClient → 上架审批(Feign)                   │ │
│  │  CatalogClient → 资产信息查询(Feign)                │ │
│  │  DataServiceClient → API授权(Feign)                 │ │
│  │  StorageClient → 样例数据存储(MinIO)                │ │
│  │  SecurityClient → 合规检查(Feign)                   │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌─ Event Layer ──────────────────────────────────────┐ │
│  │  Kafka Consumer:                                     │ │
│  │  ├── dataservice.api.called → 计量采集              │ │
│  │  └── workflow.approved → 订阅/上架审批回调           │ │
│  │  Kafka Producer:                                     │ │
│  │  ├── product.published → 通知市场更新               │ │
│  │  └── product.subscribed → 通知估值服务更新收益      │ │
│  └─────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### 7.2 订阅授权流程

```
消费者提交订阅申请
    │
    ▼
SubscriptionValidator.validate(request)
    ├── 校验产品状态（上架中）
    ├── 校验用户权限（有订阅权限）
    └── 校验用量规格（合理范围）
    │
    ▼
SubscriptionService.createSubscription(request)
    ├── 保存订阅记录(status=PENDING)
    └── 调用WorkflowClient启动审批流程
         │
         ▼
    WorkflowService.startProcess("product_subscribe_approval")
         ├── RACI分配审批人（数据产品提供方）
         ├── 审批人审批
         │   ├── 通过 → 回调通知
         │   └── 拒绝 → 回调通知
         │
         ▼ (审批通过)
    WorkflowCallbackController.onApproved(instanceId)
         │
         ▼
    AuthorizationManager.authorize(subscription)
         ├── 生成API Key
         ├── 分配数据权限（调用DataServiceClient）
         ├── 设置有效期（订阅周期）
         └── 保存授权记录
              │
              ▼
         SubscriptionService.activate(subscriptionId)
              ├── 更新状态(status=ACTIVE)
              ├── 发送通知（站内信+邮件）
              └── 发送Kafka: product.subscribed
```

---

## 8. 自助分析服务架构设计

### 8.1 架构图

```
┌─────────────────────────────────────────────────────────┐
│                 analytics-service                         │
├─────────────────────────────────────────────────────────┤
│  ┌─ API Layer ────────────────────────────────────────┐ │
│  │  SqlQueryController       SQL查询(执行/历史/保存)   │ │
│  │  VisualAnalysisController 可视化分析(图表/仪表盘)   │ │
│  │  WizardQueryController    无代码取数(向导)          │ │
│  │  QueryAuditController     查询审计                  │ │
│  │  SlowQueryController      慢查询监控                │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌─ WebSocket Layer ───────────────────────────────────┐│
│  │  QueryWebSocket          实时查询进度推送            ││
│  │  ├── 推送查询状态（排队/执行/完成/超时）             ││
│  │  └── 推送结果数据（分批流式返回）                    ││
│  └─────────────────────────────────────────────────────┘│
│                                                          │
│  ┌─ Service Layer ────────────────────────────────────┐ │
│  │  SqlQueryService         SQL查询核心                 │ │
│  │  ├── SqlValidator        SQL校验(防DML/DDL)         │ │
│  │  ├── QueryExecutor       查询执行(超时/限行)        │ │
│  │  ├── ResultProcessor     结果处理(脱敏/格式化)      │ │
│  │  └── QueryHistoryService 查询历史                   │ │
│  │  VisualAnalysisService   可视化分析                  │ │
│  │  ├── ChartGenerator      图表生成                   │ │
│  │  ├── DashboardService    仪表盘管理                 │ │
│  │  └── PivotService        数据透视                   │ │
│  │  WizardQueryService      无代码取数                  │ │
│  │  ├── TableSelector       表选择                     │ │
│  │  ├── FieldSelector       字段选择                   │ │
│  │  ├── ConditionBuilder    条件构建                   │ │
│  │  └── SqlBuilder          SQL生成                    │ │
│  │  QueryAuditService       查询审计                   │ │
│  │  SlowQueryService        慢查询监控+AI优化建议       │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌─ Security Layer ───────────────────────────────────┐ │
│  │  PermissionChecker       权限检查(表级/字段级)      │ │
│  │  DynamicMasking          动态脱敏                   │ │
│  │  ConcurrencyLimiter      并发限制(3并发/用户)       │ │
│  │  RowLimitEnforcer        行数限制(10000行)          │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌─ Integration Layer ────────────────────────────────┐ │
│  │  DataSourceConnector → 多数据源连接(复用profiling)  │ │
│  │  CatalogClient → 权限查询(Feign)                    │ │
│  │  SecurityClient → 脱敏规则查询(Feign)               │ │
│  │  AiClient → 慢查询AI优化建议(common-ai)             │ │
│  └─────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### 8.2 SQL查询执行流程

```
用户提交SQL
    │
    ▼
SqlValidator.validate(sql)
    ├── 语法检查
    ├── 安全检查（仅允许SELECT，禁止DML/DDL）
    └── 注入检测
    │
    ▼
PermissionChecker.check(user, sql)
    ├── 解析SQL涉及的表和字段
    ├── 检查用户对每张表的查询权限
    └── 检查字段级权限
    │
    ▼
ConcurrencyLimiter.acquire(user)
    ├── 检查用户并发数（≤3）
    └── 超限则排队等待
    │
    ▼
QueryExecutor.execute(sql, timeout=60s, limit=10000)
    ├── 连接数据源
    ├── 执行查询（带超时控制）
    └── 流式读取结果（分批）
    │
    ▼ (并行)
QueryAuditService.record(user, sql, result)
    ├── 记录审计日志（用户/SQL/时间/行数/耗时/状态）
    └── 异步写入（不影响查询响应）
    │
    ▼
DynamicMasking.apply(result, maskingRules)
    ├── 遍历结果列
    ├── 匹配脱敏规则
    └── 敏感字段脱敏处理
    │
    ▼
ResultProcessor.format(result, format)
    ├── 表格格式（默认）
    ├── Excel导出（异步，≤10000行）
    └── CSV导出（同步）
    │
    ▼ (如果慢查询)
SlowQueryService.analyze(sql, duration)
    ├── 记录慢查询日志
    ├── 调用AI生成优化建议
    └── 推送优化建议给用户
```

---

## 9. 数据集成服务架构设计

### 9.1 架构图

```
┌─────────────────────────────────────────────────────────┐
│                integration-service                        │
├─────────────────────────────────────────────────────────┤
│  ┌─ API Layer ────────────────────────────────────────┐ │
│  │  DataSourceController     数据源CRUD + 连接测试      │ │
│  │  SyncTaskController       同步任务CRUD + 执行        │ │
│  │  SyncMonitorController    同步监控(状态/进度/错误)   │ │
│  │  MetadataCollectController 元数据采集(手动/定时)     │ │
│  │  DataTransformController  数据转换规则管理           │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌─ Service Layer ────────────────────────────────────┐ │
│  │  DataSourceService       数据源管理                  │ │
│  │  ├── DataSourceValidator 连接校验                   │ │
│  │  ├── HealthChecker       健康检查(定时)              │ │
│  │  └── ConnectionPoolManager 连接池管理               │ │
│  │  SyncTaskService         同步任务管理                │ │
│  │  ├── SyncExecutor        同步执行引擎               │ │
│  │  │   ├── FullSyncExecutor 全量同步                  │ │
│  │  │   ├── IncrSyncExecutor 增量同步(时间戳/CDC)     │ │
│  │  │   └── BatchWriter      批量写入(500行/批)       │ │
│  │  ├── DataTransformEngine 数据转换引擎               │ │
│  │  │   ├── TypeConverter    类型转换                  │ │
│  │  │   ├── NullHandler      空值处理                  │ │
│  │  │   ├── FieldConcatenator 字段拼接                 │ │
│  │  │   └── FieldSplitter    字段拆分                  │ │
│  │  └── ErrorHandlers       错误处理                   │ │
│  │  MetadataCollectService  元数据采集                 │ │
│  │  ├── SchemaCollector     结构采集                   │ │
│  │  ├── ChangeDetector      变更检测                   │ │
│  │  └── MetadataPublisher   元数据发布(Kafka)          │ │
│  │  SyncScheduleService     同步调度(Quartz)           │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌─ Connector Layer ──────────────────────────────────┐ │
│  │  SourceConnector (读)                                │ │
│  │  ├── MySqlSourceConnector                            │ │
│  │  ├── Dm8SourceConnector                              │ │
│  │  ├── KingbaseSourceConnector                         │ │
│  │  ├── OpenGaussSourceConnector                        │ │
│  │  ├── PostgresSourceConnector                         │ │
│  │  ├── CsvSourceConnector                              │ │
│  │  ├── ExcelSourceConnector                            │ │
│  │  └── ApiSourceConnector                              │ │
│  │  SinkConnector (写)                                  │ │
│  │  ├── MySqlSinkConnector                              │ │
│  │  ├── Dm8SinkConnector                                │ │
│  │  ├── KingbaseSinkConnector                           │ │
│  │  └── OpenGaussSinkConnector                          │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌─ Event Layer ──────────────────────────────────────┐ │
│  │  Kafka Producer:                                     │ │
│  │  ├── metadata.collected → 通知metadata-svc更新      │ │
│  │  ├── sync.completed → 通知监控更新                   │ │
│  │  └── sync.failed → 通知告警                          │ │
│  └─────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### 9.2 数据同步架构

```
SyncExecutor.execute(task)
    │
    ├── 1. 初始化
    │   ├── 加载同步配置（源/目标/映射/转换/错误策略）
    │   ├── 创建源端连接（SourceConnector）
    │   ├── 创建目标端连接（SinkConnector）
    │   └── 初始化进度计数器
    │
    ├── 2. 数据读取（流式）
    │   ├── 全量模式：SELECT * FROM source_table
    │   ├── 增量模式（时间戳）：SELECT * WHERE update_time > #{lastSyncTime}
    │   └── 分页读取（LIMIT/OFFSET 或 游标）
    │
    ├── 3. 数据转换（逐行）
    │   ├── 类型转换（MySQL VARCHAR → DM8 VARCHAR2）
    │   ├── 空值处理（NULL → 默认值）
    │   ├── 字段拼接（first_name + last_name → full_name）
    │   ├── 字段拆分（full_name → first_name, last_name）
    │   └── 自定义UDF
    │
    ├── 4. 批量写入
    │   ├── 每500行一批
    │   ├── JDBC Batch INSERT
    │   └── 错误处理（跳过/终止/重试）
    │
    ├── 5. 增量标记
    │   └── 更新 lastSyncTime 到同步任务记录
    │
    └── 6. 完成处理
        ├── 更新任务状态(SUCCESS)
        ├── 记录同步统计（行数/耗时/速率）
        └── 发送Kafka: sync.completed
```

---

## 10. 服务间依赖与通信设计

### 10.1 服务间通信矩阵

| 源服务 | 目标服务 | 通信方式 | 场景 | 超时 |
|--------|---------|---------|------|:----:|
| profiling-svc | catalog-svc | Feign (同步) | 查询资产信息 | 3s |
| profiling-svc | metadata-svc | Feign (同步) | 查询表结构 | 3s |
| profiling-svc | common-ai | Feign (同步) | AI解读调用 | 30s |
| tag-svc | catalog-svc | Kafka (异步) | 标签更新通知 | - |
| tag-svc | common-ai | Feign (同步) | AI打标调用 | 15s |
| workflow-svc | notification-svc | Feign (同步) | 审批通知 | 5s |
| workflow-svc | catalog-svc | Feign (同步) | 资产状态更新 | 3s |
| workflow-svc | quality-svc | Feign (同步) | 质量问题更新 | 3s |
| valuation-svc | catalog-svc | Feign (同步) | 资产信息查询 | 3s |
| valuation-svc | quality-svc | Feign (同步) | 质量评分查询 | 3s |
| valuation-svc | dataservice-svc | Feign (同步) | 调用统计查询 | 3s |
| valuation-svc | lineage-svc | Feign (同步) | 血缘覆盖查询 | 3s |
| dataproduct-svc | workflow-svc | Feign (同步) | 启动上架审批 | 5s |
| dataproduct-svc | catalog-svc | Feign (同步) | 资产信息查询 | 3s |
| dataproduct-svc | dataservice-svc | Feign (同步) | API授权 | 5s |
| analytics-svc | catalog-svc | Feign (同步) | 权限查询 | 3s |
| integration-svc | metadata-svc | Kafka (异步) | 元数据采集通知 | - |

### 10.2 事件驱动架构

```
┌─────────── Kafka Event Bus ──────────────────────────────┐
│                                                          │
│  Topic: profiling.task.queue                              │
│  Producer: profiling-svc (API层)                         │
│  Consumer: profiling-svc (引擎层)                         │
│                                                          │
│  Topic: profiling.completed                               │
│  Producer: profiling-svc                                  │
│  Consumer: tag-svc (触发AI打标), valuation-svc (更新评分) │
│                                                          │
│  Topic: profiling.anomaly                                 │
│  Producer: profiling-svc                                  │
│  Consumer: quality-svc (创建质量问题)                     │
│                                                          │
│  Topic: tag.assigned                                      │
│  Producer: tag-svc                                        │
│  Consumer: catalog-svc (更新资产标签缓存)                 │
│                                                          │
│  Topic: quality.score.updated                             │
│  Producer: quality-svc                                    │
│  Consumer: valuation-svc (更新质量维度)                   │
│                                                          │
│  Topic: workflow.approved / workflow.rejected             │
│  Producer: workflow-svc                                   │
│  Consumer: catalog-svc, quality-svc, dataproduct-svc     │
│                                                          │
│  Topic: dataservice.api.called                            │
│  Producer: dataservice-svc                                │
│  Consumer: dataproduct-svc (计量采集)                     │
│                                                          │
│  Topic: product.subscribed                                │
│  Producer: dataproduct-svc                                │
│  Consumer: valuation-svc (更新收益维度)                   │
│                                                          │
│  Topic: metadata.collected                                │
│  Producer: integration-svc                                │
│  Consumer: metadata-svc (更新元数据)                      │
│                                                          │
│  Topic: sync.completed / sync.failed                      │
│  Producer: integration-svc                                │
│  Consumer: monitoring (告警)                              │
└──────────────────────────────────────────────────────────┘
```

### 10.3 事务一致性策略

| 场景 | 策略 | 说明 |
|------|------|------|
| 资产发布审批 | 最终一致性 | 审批通过后通过Kafka通知catalog-svc更新状态 |
| 数据产品订阅授权 | 本地事务 + 事件补偿 | 授权记录和权限分配在同一事务，失败时回滚+事件补偿 |
| 同步任务执行 | 最终一致性 | 同步完成后通过Kafka通知元数据更新，失败时告警 |
| 估值计算 | 最终一致性 | 估值数据异步聚合，容忍短暂不一致 |
| 打标操作 | 最终一致性 | 打标结果通过Kafka通知catalog-svc，失败重试3次 |

---

## 11. 安全架构补充设计

### 11.1 数据安全设计

```
┌─────────────────────────────────────────────────────────┐
│                    安全架构                                │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌─ 身份认证 ──────────────────────────────────────────┐│
│  │  JWT Token (HttpOnly Cookie) ← P4安全加固已完成      ││
│  │  RBAC + ABAC 权限模型                                ││
│  └─────────────────────────────────────────────────────┘│
│                                                          │
│  ┌─ 数据探查安全 ──────────────────────────────────────┐│
│  │  · 探查权限：用户需对目标表有"探查"权限              ││
│  │  · 数据安全：探查统计结果不含原始数据                ││
│  │  · 采样安全：采样数据自动脱敏                       ││
│  │  · 日志安全：探查日志不含原始数据                   ││
│  └─────────────────────────────────────────────────────┘│
│                                                          │
│  ┌─ 自助分析安全 ──────────────────────────────────────┐│
│  │  · SQL注入防护：参数化查询 + SQL解析校验             ││
│  │  · DML/DDL防护：仅允许SELECT语句                    ││
│  │  · 动态脱敏：查询结果敏感字段自动脱敏               ││
│  │  · 行数限制：防止全表导出（默认10,000行）           ││
│  │  · 并发限制：单用户≤3并发                          ││
│  │  · 查询审计：全量查询日志记录                       ││
│  └─────────────────────────────────────────────────────┘│
│                                                          │
│  ┌─ 数据产品安全 ──────────────────────────────────────┐│
│  │  · 合规检查：上架前自动合规检查（数据来源/隐私/版权）││
│  │  · 数据脱敏：产品样例数据自动脱敏                   ││
│  │  · API Key管理：加密存储 + 定期轮换                 ││
│  │  · 访问控制：订阅授权 + 权限回收                    ││
│  └─────────────────────────────────────────────────────┘│
│                                                          │
│  ┌─ 数据集成安全 ──────────────────────────────────────┐│
│  │  · 传输加密：TLS 1.3 / 国密SSL                     ││
│  │  · 凭证管理：数据源密码加密存储(SM4)                ││
│  │  · 限流保护：同步查询限流（可配置行/秒）            ││
│  └─────────────────────────────────────────────────────┘│
│                                                          │
│  ┌─ 工作流安全 ────────────────────────────────────────┐│
│  │  · 审批委托：支持委托授权 + 委托审计                ││
│  │  · 流程隔离：多租户流程定义和实例完全隔离           ││
│  │  · 审计日志：全量审批操作记录，不可篡改             ││
│  └─────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────┘
```

### 11.2 数据库隔离策略

| 隔离级别 | 适用服务 | 策略 |
|---------|---------|------|
| 行级隔离 | profiling, tag, workflow, valuation, dataproduct, analytics, integration | tenant_id字段隔离 |
| 库级隔离（可选） | 大客户SaaS模式 | 每租户独立数据库 |

---

## 12. 部署架构补充设计

### 12.1 资源规划（新增服务）

| 服务 | CPU | 内存 | 存储 | 副本数 | 说明 |
|------|:---:|:----:|:----:|:------:|------|
| profiling-service | 4 | 8G | - | 2 | 探查计算资源密集 |
| tag-service | 1 | 2G | - | 1 | 轻量级 |
| workflow-service | 2 | 4G | - | 2 | Flowable引擎 |
| valuation-service | 2 | 4G | - | 1 | 定时计算 |
| dataproduct-service | 2 | 4G | - | 2 | 市场访问 |
| analytics-service | 4 | 8G | - | 2 | SQL执行资源密集 |
| integration-service | 4 | 8G | - | 2 | 同步IO密集 |
| Flowable DB | 2 | 4G | 50G SSD | 1(主从) | 工作流引擎数据库 |
| **新增合计** | **21** | **42G** | **50G** | - | |

### 12.2 总体资源规划（V2.0）

| 组件 | CPU | 内存 | 存储 | 副本数 |
|------|:---:|:----:|:----:|:------:|
| 已有服务(V1.0) | 45 | 110G | 2.8T | - |
| 新增服务(V2.0) | 21 | 42G | 50G | - |
| **V2.0合计** | **66** | **152G** | **2.85T** | - |

### 12.3 部署拓扑

```
┌─── Kubernetes Cluster ──────────────────────────────────┐
│                                                          │
│  Namespace: smartwin-smartdata                           │
│  ┌──────────────────────────────────────────────────┐   │
│  │  catalog-svc (x2)      metadata-svc (x2)         │   │
│  │  quality-svc (x2)      standard-svc (x1)         │   │
│  │  lineage-svc (x2)      mdm-svc (x2)              │   │
│  │  lifecycle-svc (x1)    dataservice-svc (x2)      │   │
│  │  glossary-svc (x1)     aigovernance-svc (x1)     │   │
│  │                                                    │   │
│  │  profiling-svc (x2)     tag-svc (x1)              │   │
│  │  workflow-svc (x2)      valuation-svc (x1)        │   │
│  │  dataproduct-svc (x2)   analytics-svc (x2)        │   │
│  │  integration-svc (x2)                             │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  Namespace: smartwin-infra                               │
│  ┌──────────────────────────────────────────────────┐   │
│  │  MySQL (主从)    Redis (集群)    ES (3节点)       │   │
│  │  Neo4j (主从)   Kafka (3节点)   MinIO (4节点)     │   │
│  │  Flowable DB (主从)                               │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  Namespace: smartwin-monitoring                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Prometheus    Grafana    Loki    AlertManager    │   │
│  └──────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────┘
```

### 12.4 HP弹缩策略

| 服务 | 最小副本 | 最大副本 | CPU阈值 | 内存阈值 |
|------|:--------:|:--------:|:-------:|:--------:|
| profiling-svc | 2 | 6 | 70% | 80% |
| analytics-svc | 2 | 8 | 70% | 80% |
| integration-svc | 2 | 6 | 70% | 80% |
| workflow-svc | 2 | 4 | 70% | 80% |
| dataproduct-svc | 2 | 4 | 70% | 80% |
| tag-svc | 1 | 3 | 70% | 80% |
| valuation-svc | 1 | 2 | 70% | 80% |

---

*文档结束 — 智数架构组 — 2026-07-15 — SD-HLD-02 V1.0.0*
