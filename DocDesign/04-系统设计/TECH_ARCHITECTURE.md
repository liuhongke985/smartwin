# SmartWin 技术架构全景设计

> **Version**: 2.0 | **Last Updated**: 2026-07-27 | **Status**: Production Ready
>
> 下一代 AI 原生数据+模型治理平台的技术架构方案，融合最新技术栈、云原生设计、AI 赋能能力

---

## 🎯 架构设计原则

```yaml
核心原则:
  1. AI-First: 大模型+Agent驱动全流程自动化
  2. Cloud-Native: K8s Ready、微服务、12因子应用
  3. Scalability: 支持百亿级数据、千万级模型
  4. Security: 国密内置、权限细粒度、审计完整
  5. Observability: 全链路追踪、实时监控、智能告警
  6. Flexibility: 私有化/SaaS/混合部署
```

---

## 📐 整体架构设计

### 分层架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                    展示层 (Presentation Layer)                    │
│  SmartData Portal │ SmartChain Portal │ SmartWin Portal (Web+Mobile)
├─────────────────────────────────────────────────────────────────┤
│                   网关层 (Gateway Layer)                          │
│  API Gateway (Spring Cloud Gateway) │ WebSocket Gateway │ GraphQL Gateway
├─────────────────────────────────────────────────────────────────┤
│                   应用层 (Application Layer)                      │
│  ┌──────────────────┬──────────────────┬──────────────────┐
│  │  SmartData 服务  │  SmartChain 服务  │  SmartWin 服务   │
│  │  - 数据治理      │  - 模型治理      │  - 门户/SSO      │
│  │  - 元数据管理    │  - 监控告警      │  - 权限管理      │
│  │  - 质量检测      │  - 成本管理      │  - 数据互通      │
│  └──────────────────┴──────────────────┴──────────────────┘
├─────────────────────────────────────────────────────────────────┤
│                   业务逻辑层 (Business Logic Layer)               │
│  ┌──────────────────┬──────────────────┬──────────────────┐
│  │  AI 智能层        │  数据处理层      │  模型处理层      │
│  │  - LLM Adaptor   │  - ETL 引擎      │  - 训练引擎      │
│  │  - Agent Engine  │  - 质量规则      │  - 推理引擎      │
│  │  - RAG Module    │  - 脱敏加密      │  - 监控引擎      │
│  └──────────────────┴──────────────────┴──────────────────┘
├─────────────────────────────────────────────────────────────────┤
│                   公共基础层 (Common Layer)                       │
│  ┌────────────────┬────────────────┬────────────────┐
│  │  common-util   │  common-db     │  common-security
│  │  - 响应体      │  - MyBatis-Plus│  - JWT         
│  │  - 异常处理    │  - 多库适配    │  - Spring Sec.  
│  │  - AOP 框架    │  - 数据源管理  │  - OAuth2       
│  ├────────────────┼────────────────┼────────────────┤
│  │  common-ai     │  common-mq     │  common-storage 
│  │  - LLM 适配    │  - RocketMQ    │  - MinIO
│  │  - Prompt 管理 │  - 事件驱动    │  - 对象存储
│  └────────────────┴────────────────┴────────────────┘
├─────────────────────────────────────────────────────────────────┤
│                   中间件层 (Middleware Layer)                     │
│  MySQL/DM8  │  Redis  │  Elasticsearch  │  Neo4j  │  RocketMQ   │
│  MinIO      │ Nacos   │ Prometheus      │ Jaeger  │ SkyWalking  │
├─────────────────────────────────────────────────────────────────┤
│                   基础设施层 (Infrastructure Layer)               │
│  Kubernetes | Docker | Linux | 云服务商 (阿里云/华为云/本地IDC) │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚀 技术栈选型

### 后端技术栈（核心竞争力）

```yaml
# 核心框架 - 最新LTS版本
Framework:
  Java Version: JDK 21 LTS
    - 特性: 虚拟线程(Virtual Threads) ← 关键优势
    - 特性: 结构化并发
    - 特性: 模式匹配增强
  
  Spring Boot: 3.2.5+
    - Spring Cloud: 2023.0.x (Leyton)
    - Spring Data: 2023.0.x
    - Spring Security: 6.1.x
  
  Spring Cloud Alibaba: 2022.0.x
    - Nacos: 服务注册发现/配置管理
    - Sentinel: 限流熔断降级
    - Seata: 分布式事务

# ORM 框架
ORM:
  MyBatis-Plus: 3.5.7+
  JPA/Hibernate: 仅限只读场景

# 响应式编程（高并发）
Reactive:
  Project Reactor: 3.5.x
  WebFlux: 用于 Gateway/高吞吐 API
  R2DBC: 异步数据库驱动

# AI 与大模型集成
AI_LLM:
  LangChain4j: 0.25.0+
    - Prompt Engineering
    - Chain/Agent 编排
    - Memory 管理
    - Tools 调用
  
  Spring AI: 0.11.0+ (Spring 官方)
    - OpenAI/通义千问/文心一言 适配
    - Embedding 支持
    - Vector Store 集成
  
  大模型 API:
    - 阿里通义千问 (Qwen)
    - 百度文心一言 (Ernie)
    - 智谱 GLM-4
    - 本地开源: LLaMA2/Qwen-Local

# 搜索与向量数据库
Search:
  Elasticsearch: 8.10.x+
    - 全文搜索
    - 日志聚合
    - 时序分析
  
  Milvus: 2.3.x+ (向量数据库)
    - RAG 支持
    - Embedding 存储
    - 相似度检索

# 图数据库（血缘追踪）
Graph:
  Neo4j: 5.x
  Neo4j Spring Data: 7.x
  用途: 数据血缘、依赖关系、影响分析

# 缓存框架
Cache:
  Redis: 7.2.x (分布式缓存)
  Caffeine: 本地缓存 (L1)
  
  缓存策略:
    - L1: 本地内存 (Caffeine, 5min TTL)
    - L2: Redis (1h TTL)
    - 穿透保护: BloomFilter + CacheAside

# 消息队列
MQ:
  RocketMQ: 5.2.0+
    - 事件驱动
    - 异步处理
    - 可靠投递
  
  Kafka: 支持(备选)

# 分布式配置
Config:
  Nacos: 2.3.x
  Apollo: 支持(备选)

# 监控与可观测性
Observability:
  Prometheus: 指标采集
  Grafana: 展示与告警
  Jaeger: 分布式追踪
  SkyWalking: APM (备选)
  ELK Stack: 日志分析
    - Elasticsearch
    - Logstash
    - Kibana

# 测试框架
Testing:
  JUnit 5: 单元测试
  Mockito: 单元测试Mock
  TestContainers: 集成测试 (Docker容器)
  Arquillian: 服务级别测试

# 构建与包管理
Build:
  Maven: 3.9.x (多模块管理)
  Gradle: 支持 (备选)
  
  依赖管理:
    - Spring Dependency Management
    - Maven BOM (Bill of Materials)

# 国密与安全
Security:
  BouncyCastle: 1.78.1+
    - SM2/SM3/SM4/SM9 国密算法
    - TLCP 双证书
  
  JWT: 令牌认证
  Spring Security: 权限管理 (ABAC/RBAC)
  TLS 1.3: 传输加密
```

### 前端技术栈（云原生化）

```yaml
# 前端框架
Framework:
  Vue: 3.5.x (Composition API + TypeScript)
  Vite: 5.0.x (极速开发、优化构建)
  TypeScript: 5.x

# 状态管理
State Management:
  Pinia: 2.1.x (官方推荐)
  VueUse: 工具函数库

# UI 组件库
UI:
  Element Plus: 2.8.x (企业级)
  Arco Design: 支持 (字节跳动)
  
  高级组件:
    - 数据可视化: ECharts 5.x + Apache Superset 集成
    - 流程图: Mxgraph 或 GoJS
    - 代码编辑: Monaco Editor
    - 富文本: Tiptap

# 国际化
i18n:
  vue-i18n: 10.0.x
  
  特性:
    - 按模块懒加载
    - TypeScript 类型安全
    - 运行时切换

# HTTP 客户端
HTTP:
  Axios: 0.27.x
  Interceptors: 请求/响应拦截
  
  高级:
    - 自动重试
    - 超时控制
    - 请求去重

# 权限与认证
Auth:
  JWT (localStorage)
  刷新令牌策略
  权限守卫 (v-permission)

# 可视化工具
Visualization:
  ECharts: 5.4.x (图表)
  D3.js: 图表和网络图
  Apache Superset: BI 集成
  AntV: 图表库 (备选)

# 构建与部署
Build:
  pnpm: 包管理器 (性能优于 npm)
  Monorepo: pnpm workspace
  
  构建优化:
    - Tree-shaking
    - Code splitting
    - 动态导入

# PWA 支持
PWA:
  Workbox: Service Worker
  离线支持
  安装应用

# 性能监控
Performance:
  Web Vitals
  Sentry: 错误追踪
  应用性能监控 (APM)

# 测试
Testing:
  Vitest: 单元测试 (Vite原生)
  Playwright: E2E 测试
  Testing Library: 组件测试
```

### 数据库与存储

```yaml
# 关系数据库（企业级支持）
Relational_DB:
  Primary:
    - MySQL 8.0 (开发环境主要)
  
  国产适配:
    - 达梦 DM8 (商业、可靠性高)
    - 人大金仓 Kingbase (国产之光)
    - openGauss (华为开源)
    - 南大通用 GBase
  
  自动适配策略:
    - 方言识别
    - 连接池优化
    - 功能兼容性补丁

# NoSQL 数据库
NoSQL:
  Redis: 缓存、消息订阅、分布式锁
  MongoDB: 灵活数据存储 (如果需要)
  
# 搜索引擎
Search_Engine:
  Elasticsearch: 8.10.x+
  - 日志存储 (30天滚动)
  - 全文搜索
  - 聚合分析

# 向量数据库 (AI 新能力)
Vector_DB:
  Milvus: 2.3.x (开源、高性能)
  
  用途:
    - Embedding 存储
    - 语义搜索
    - 推荐系统

# 图数据库
Graph_DB:
  Neo4j: 5.x (数据血缘、关系追踪)

# 对象存储
Object_Storage:
  MinIO: 开源 S3 兼容
  
  支持国云:
    - 阿里云 OSS
    - 华为云 OBS
    - 腾讯云 COS

# 时序数据库 (监控告警)
TimeSeries_DB:
  Prometheus: 指标存储
  InfluxDB: 备选方案

# 配置管理
Config_DB:
  Nacos: 分布式配置 + 服务注册
```

---

## 🤖 AI 引擎架构（核心竞争力）

### AI 能力分层

```
┌─────────────────────────────────────────────────┐
│          应用层 (Application Layer)              │
│  - 数据治理 Agent    - 模型治理 Agent           │
│  - 代码生成          - 智能诊断                  │
│  - 自动规则生成      - 特征推荐                  │
├─────────────────────────────────────────────────┤
│          Agent 编排层 (Orchestration)            │
│  - Agent Framework   - Tool Registry            │
│  - 决策引擎          - 内存管理                  │
│  - 链式调用          - 反馈循环                  │
├─────────────────────────────────────────────────┤
│          LLM 适配层 (LLM Adaptation)            │
│  通义千问 │ 文心一言 │ 智谱 GLM │ 开源大模型   │
│  (多模型支持、一键切换)                          │
├─────────────────────────────────────────────────┤
│          增强层 (Enhancement)                   │
│  - Prompt 工程       - Few-shot 学习            │
│  - RAG 检索          - 向量数据库               │
│  - Chain of Thought  - 思维链推理               │
├─────────────────────────────────────────────────┤
│          基础模型层 (Foundation Models)          │
│  - 本地部署模型      - API 模型                 │
│  - 模型微调          - 量化加速                 │
└─────────────────────────────────────────────────┘
```

### Agent 编排框架

```java
// 核心能力示例：智能规则生成 Agent
@Service
public class DataQualityAgent {
  
  private final LLMAdapter llm;  // LLM 适配器
  private final ToolRegistry toolRegistry;  // 工具注册表
  private final RAGModule rag;  // 检索增强
  
  /**
   * 核心能力：一句话生成数据质量规则
   * 输入: "检查用户名不能为空且长度<50"
   * 输出: 可执行的质量规则脚本
   */
  public QualityRule generateRuleFromNL(String naturalLanguage) {
    // 1. 上下文检索 (RAG)
    List<Example> examples = rag.retrieve(naturalLanguage);
    
    // 2. Prompt 工程
    String prompt = buildPrompt(naturalLanguage, examples);
    
    // 3. LLM 推理
    String ruleScript = llm.generate(prompt);
    
    // 4. 工具调用：规则验证
    boolean valid = toolRegistry.get("validateRule").execute(ruleScript);
    
    // 5. 反馈优化
    if (!valid) {
      return agentRetry(naturalLanguage);
    }
    
    return parseRuleScript(ruleScript);
  }
}
```

### AI 集成点

```yaml
数据治理 AI:
  1. 智能规则生成 (NL→规则)
  2. 异常自动检测 (统计+ML)
  3. 修复建议推荐 (上下文感知)
  4. 血缘自动追踪 (图遍历+NL)
  5. 合规检查自动化 (知识库)

模型治理 AI:
  1. 模型性能智能诊断
  2. 漂移原因根因分析
  3. 超参优化建议
  4. 特征工程自动化
  5. 模型可解释性生成

公共 AI:
  1. 代码生成 (SQL/Python)
  2. 自然语言检索 (语义理解)
  3. 多语言支持 (i18n 智能)
  4. 文档生成自动化
```

---

## 🔄 微服务架构设计

### 服务划分

```
┌─────────────────────────────────────────────────────────┐
│                    API Gateway                          │
│  (Spring Cloud Gateway + 限流熔断降级 + 权限校验)        │
└──────────────┬──────────────┬──────────────┬────────────┘
               │              │              │
     ┌─────────▼──┐   ┌──────▼───┐   ┌─────▼──────┐
     │ SmartData   │   │SmartChain │   │ SmartWin   │
     │  Services   │   │  Services │   │ Services   │
     └─────────────┘   └───────────┘   └────────────┘
           │                 │               │
    ┌──────┼──────┐    ┌──────┼─────┐  ┌─────┼──────┐
    │      │      │    │      │     │  │     │      │
  ┌─▼──┐ ┌─▼──┐ ┌▼──┐┌─▼──┐ ┌─▼──┐┌──▼──┐┌──▼──┐┌──▼──┐
  │数据│ │元数│ │质量││模型│ │应用││成本││门户││权限││数据│
  │采集│ │据  │ │检测││注册││发布││管理││管理││管理││互通│
  └────┘ └────┘ └───┘└────┘ └────┘└─────┘└─────┘└─────┘
```

### 微服务通信

```yaml
同步通信:
  Protocol: HTTP/2 (TLS 1.3) + gRPC (性能关键路径)
  Load Balance: 客户端负载均衡 (Ribbon/LoadBalancer)
  
  路由策略:
    - 轮询
    - 权重
    - 一致性哈希 (有状态服务)

异步通信:
  Protocol: RocketMQ (可靠投递)
  
  场景:
    - 数据质量规则执行 (异步分布式)
    - 模型预测结果回写
    - 监控告警异步处理
  
  特性:
    - 事务消息
    - 顺序消息
    - 延迟消息

服务治理:
  注册发现: Nacos (动态)
  配置管理: Nacos Config (热更新)
  限流熔断: Sentinel
  分布式追踪: Jaeger
```

---

## 💾 数据流架构

### 实时 vs 批处理

```yaml
实时处理 (Streaming):
  需求:
    - 实时监控告警
    - 模型预测响应
    - 数据质量实时评分
  
  技术栈:
    - RocketMQ Consumer (消息消费)
    - Project Reactor (响应式编程)
    - WebSocket (推送到前端)
    - Redis Stream (消息流)

批处理 (Batch):
  需求:
    - 数据采集 ETL
    - 定期质量检测
    - 模型训练
    - 报表生成
  
  技术栈:
    - Spring Batch (框架)
    - Quartz (调度)
    - Apache Camel (集成)
    - Spark (大规模数据处理)

混合处理 (Lambda Architecture):
  速度层: 实时数据流
  批处理层: 离线计算
  服务层: 统一查询
```

### 数据血缘追踪

```
来源数据 → 采集 → ETL → 存储 → 计算 → 输出
  ↓         ↓      ↓     ↓      ↓      ↓
  │────────────────────────────────────│
        Neo4j 血缘图谱记录所有关系
  
  查询示例: 某个用户字段被哪些模型使用?
  Neo4j: MATCH (field)-[*]->(model) RETURN path
```

---

## ⚡ 性能优化策略

### 多级缓存

```yaml
L1 Cache (进程内):
  框架: Caffeine
  TTL: 5 min
  大小限制: 100MB
  用途: 热点数据 (用户信息、权限等)

L2 Cache (分布式):
  框架: Redis
  TTL: 1h
  用途: 共享数据 (元数据、配置等)
  
  缓存穿透: BloomFilter
  缓存雪崩: 随机 TTL + 热数据预热
  缓存击穿: 互斥锁 + 双重检查

Database Query Cache:
  MyBatis Query Cache
  结合 TTL 失效策略

策略示例:
  1. 先查 L1 缓存 (命中率 80%)
  2. 再查 L2 缓存 (命中率 15%)
  3. 最后查数据库 (命中率 5%)
```

### 虚拟线程优化 (JDK 21)

```java
// 传统线程池 (10000 连接需要 10000 线程)
ExecutorService executor = Executors.newFixedThreadPool(10000);

// 虚拟线程 (10000 连接只需 1-2 个平台线程!)
ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor();

// 优势:
// 1. 内存占用减少 99%
// 2. 线程切换快 1000 倍
// 3. 编程模型不变 (同步代码即可)
// 4. 自动扩展

// Spring Boot 3.2.5 自动支持
server:
  tomcat:
    threads:
      virtual:
        enabled: true  # 虚拟线程启用
```

### 异步非阻塞

```yaml
Web 框架:
  Spring WebFlux (Netty)
  - 代替 Spring MVC (对于高并发场景)
  - 完全异步非阻塞
  
  R2DBC:
    - 异步数据库驱动
    - 支持 MySQL/PostgreSQL
    - 虚拟线程完美搭配

消息处理:
  Project Reactor (Mono/Flux)
  RocketMQ Async Consumer
```

### 数据库查询优化

```sql
-- 查询优化
1. 索引策略:
   - 联合索引 (字段顺序符合查询条件)
   - 覆盖索引 (避免回表)
   - 分区索引 (大表分区)

2. 查询优化:
   - 避免全表扫描
   - 使用 LIMIT
   - 分页查询
   - 异步查询分离

3. 国产数据库适配:
   - 达梦: 支持分区、索引优化器类似 Oracle
   - Kingbase: 类 PostgreSQL 优化
   - openGauss: 华为优化，OLAP 能力强
```

---

## 📊 可观测性（Observability）设计

### 三大支柱

```yaml
Logging (日志):
  框架: Logback + SLF4J
  
  收集:
    - Logstash → Elasticsearch
    - 30天滚动存储
  
  关键内容:
    - 服务调用链 (TraceId)
    - 用户操作日志 (审计)
    - 错误堆栈 (故障诊断)
  
  日志级别:
    - DEBUG: 仅开发环境
    - INFO: 关键业务事件
    - WARN: 潜在问题
    - ERROR: 异常错误
  
  性能: 异步日志输出 (AsyncAppender)

Metrics (指标):
  框架: Prometheus + Micrometer
  
  采集间隔: 30s
  
  关键指标:
    - 应用: JVM内存/GC/线程
    - 业务: 请求延迟/错误率/吞吐量
    - 数据库: 连接数/查询时间/慢查询
    - 服务: 可用性/健康检查
  
  告警阈值 (Grafana Alert):
    - 错误率 > 1%
    - P99 延迟 > 1s
    - 内存使用率 > 80%
    - 数据库连接数 > 90%

Tracing (追踪):
  框架: Jaeger + Spring Cloud Sleuth
  
  采样策略:
    - 错误 100% 采样
    - 正常 10% 采样
  
  追踪内容:
    - 跨服务调用链
    - 数据库操作
    - 缓存命中/缺失
    - 消息队列延迟
  
  性能开销: < 5%
```

### 健康检查

```yaml
健康检查 (/actuator/health):
  
  应用级别:
    - 启动状态: UP/DOWN
    - 内存: 充足/警告/危急
    - 数据库连接: OK/ERROR
    - Redis连接: OK/ERROR
    - 服务依赖: OK/PARTIAL/DOWN
  
  业务级别:
    - 队列堆积: 正常/告警/阻塞
    - 缓存命中率: > 90% 正常
    - 数据同步延迟: < 1min 正常
  
  定期检查 (心跳):
    - 间隔: 10s
    - 失败重试: 3次
    - 自动熔断阈值: 失败 5次
```

---

## 🔐 安全架构

### 认证与授权

```yaml
认证 (Authentication):
  流程:
    1. 用户登录 → JWT Token 生成
    2. Token 包含: 用户ID/角色/权限
    3. 刷新令牌 (Refresh Token) → 7天过期
    4. 访问令牌 (Access Token) → 1小时过期

授权 (Authorization):
  模型:
    - RBAC (Role-Based Access Control)
    - ABAC (Attribute-Based Access Control)
  
  字段级别权限:
    - 敏感字段脱敏
    - 跨部门字段隐藏
    - 根据角色动态展示

会话管理:
  Redis 存储会话
  支持分布式环境下的会话共享
```

### 数据加密

```yaml
传输层:
  TLS 1.3
  HTTPS + HSTS
  
静态数据:
  敏感字段:
    - 密码: bcrypt (盐值加密)
    - 身份证/电话: SM4 (国密)
    - 金额: AES-256
  
  国密 (国家密码局标准):
    - SM2: 椭圆曲线加密 (代替 RSA)
    - SM3: 哈希算法 (代替 SHA-256)
    - SM4: 分组加密 (代替 AES)
    - SM9: 身份基密码
  
  实现: BouncyCastle 1.78.1+

数据脱敏 (动态):
  查询结果自动脱敏
  
  策略:
    1. 掩码: 显示前 3 位 + * + 最后 2 位
    2. 替换: 替换为虚拟值
    3. 加密: 存储密文，查询时需解密
    4. 隐藏: 完全不显示
```

### 审计日志

```yaml
记录内容:
  1. 谁 (Who): 用户ID/角色
  2. 做了什么 (What): 操作类型/修改字段
  3. 什么时候 (When): 时间戳
  4. 在哪里 (Where): IP地址/系统
  5. 结果 (Result): 成功/失败/错误信息

存储:
  - Elasticsearch (日志聚合)
  - 定期备份到分析数据库
  - 7年归档法规要求

查询:
  - 审计报告自动生成
  - 异常行为告警
```

---

## 🌍 国际化与多区域支持

### 前后端 i18n

```yaml
前端 (vue-i18n):
  支持语言: 中文/英文/日文 (可扩展)
  
  切换方式:
    1. UI 切换
    2. 浏览器语言自动检测
    3. localStorage 记忆
  
  管理:
    - 按模块拆分 locale 文件
    - 懒加载 (按需加载语言包)
    - 类型安全 (TypeScript)

后端 (Spring i18n):
  支持:
    1. 响应消息国际化
    2. 验证错误消息国际化
    3. 业务逻辑参数国际化 (数据字典)
  
  实现:
    - MessageSource bean
    - LocaleResolver (请求头或 Cookie)
    - Accept-Language 协议支持

数据库:
  字段支持多语言:
    1. 冗余字段: name_cn / name_en
    2. 翻译表: 关联翻译记录
    3. JSON 字段: {"cn": "", "en": ""}
```

### 多区域部署

```yaml
架构:
  主区域 (Master): 核心数据处理
  从区域 (Slave): 只读副本 + CDN
  
  同步:
    - 主从复制 (MySQL binlog)
    - 异步队列通知
    - 最终一致性保证

CDN:
  前端静态资源加速
  API 就近接入
```

---

## 📦 部署与容器化

### Docker 镜像

```dockerfile
# 多阶段构建 (优化镜像大小)
FROM maven:3.9-openjdk-21 as builder
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

FROM openjdk:21-jdk-slim
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar

# JVM 优化
ENV JAVA_OPTS="-XX:+UseZGC \
  -XX:+ZGenerational \
  -XX:-TieredCompilation \
  -Xmx2g -Xms2g"

EXPOSE 8080
CMD ["java", "$JAVA_OPTS", "-jar", "app.jar"]
```

### Kubernetes 部署

```yaml
# Deployment 示例
apiVersion: apps/v1
kind: Deployment
metadata:
  name: smartdata-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: smartdata
  template:
    metadata:
      labels:
        app: smartdata
    spec:
      containers:
      - name: smartdata
        image: liuhongke985/smartdata:1.0.0
        ports:
        - containerPort: 8080
        
        # 资源限制 (JDK21 虚拟线程友好)
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
        
        # 健康检查
        livenessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        
        readinessProbe:
          httpGet:
            path: /actuator/health/readiness
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
        
        # 环境变量
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "prod,sc"
        - name: JAVA_OPTS
          value: "-XX:+UseZGC -XX:+ZGenerational"

  # 灰度更新
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
```

---

## 🎯 性能基准 (Benchmarks)

### 目标性能指标

```yaml
吞吐量 (Throughput):
  目标: > 10,000 RPS (单服务实例)
  
  优化:
    - 虚拟线程支持
    - 异步数据库驱动
    - 连接池优化
    - 缓存策略

延迟 (Latency):
  P50: < 50ms
  P99: < 500ms
  P999: < 1s
  
  假设:
    - 本地缓存命中
    - 单数据库查询

可用性 (Availability):
  目标: 99.99% (四个九)
  
  支撑:
    - 多副本部署
    - 自动故障转移
    - 限流熔断降级
    - 多活架构 (可选)

内存占用 (Memory):
  单实例 JVM: 512MB-2GB
  
  优化:
    - JDK21 虚拟线程 (轻量级)
    - 对象池复用
    - GC 优化 (ZGC)

数据处理能力:
  批处理吞吐: 100万+ 行/分钟
  实时处理延迟: < 5s
  元数据管理: 百万级字段级别
```

---

## 🔄 演进路线图

### Phase 1 (Q3 2026): 基础架构
- ✅ 核心微服务框架
- ✅ JDK21 虚拟线程集成
- ✅ 基础 AI 能力 (LLM 适配)
- ✅ 数据治理基础功能

### Phase 2 (Q4 2026): AI 增强
- 🚀 Agent 框架完善
- 🚀 RAG 检索增强
- 🚀 智能规则生成上线
- 🚀 模型治理完整

### Phase 3 (Q1 2027): 生态完善
- 生态集成 (30+ 数据源)
- 开放 API + SDK
- 行业解决方案包
- 性能优化到极致

---

## 📊 架构决策记录 (ADR)

### ADR-001: 为什么选择 JDK 21?

**决策**: 采用 JDK 21 LTS 作为基础

**原因**:
1. 虚拟线程: 支持百万级并发，内存占用减少 99%
2. 结构化并发: 简化异步代码，易于维护
3. LTS 支持: 8年长期支持 (到 2031年9月)
4. Spring Boot 3.2+ 原生支持

**权衡**: 需要 Java 21+ 运行环境 (不影响，市场普及)

### ADR-002: 为什么选择 LangChain4j?

**决策**: 采用 LangChain4j 作为 AI 框架

**原因**:
1. 轻量级: 无外部依赖，方便集成
2. 灵活性: 支持多种 LLM 模型
3. Agent 支持: 完整的 Agent 编排能力
4. 社区活跃: Spring 生态友好

**权衡**: 相比 Python LangChain 功能略少，但 Java 场景够用

---

## 🎓 参考资源

- [JDK 21 官方文档](https://openjdk.org/projects/loom/)
- [Spring Boot 3.2 文档](https://spring.io/projects/spring-boot)
- [LangChain4j](https://github.com/langchain4j/langchain4j)
- [微服务架构最佳实践](https://microservices.io/)
- [云原生最佳实践](https://www.cncf.io/)

---

**架构版本**: 2.0 | **更新日期**: 2026-07-27 | **维护者**: @liuhongke985
