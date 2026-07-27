# 智赢·智链 — 独立可售与无缝集成架构设计方案

> **文档版本**：V1.0  
> **编制日期**：2026年7月7日  
> **文档状态**：正式发布  
> **核心目标**：实现两套产品既能独立销售部署，又能无缝集成组合销售  

---

## 目录

- [第一章 设计目标与核心挑战](#第一章-设计目标与核心挑战)
- [第二章 三模式部署架构总览](#第二章-三模式部署架构总览)
- [第三章 共享底座三模式适配设计](#第三章-共享底座三模式适配设计)
- [第四章 独立部署模式设计](#第四章-独立部署模式设计)
- [第五章 无缝集成模式设计](#第五章-无缝集成模式设计)
- [第六章 数据互通与联邦查询设计](#第六章-数据互通与联邦查询设计)
- [第七章 统一门户与SSO设计](#第七章-统一门户与sso设计)
- [第八章 API联邦与服务网格设计](#第八章-api联邦与服务网格设计)
- [第九章 License授权与功能开关设计](#第九章-license授权与功能开关设计)
- [第十章 商业化包装与组合定价方案](#第十章-商业化包装与组合定价方案)
- [第十一章 实施交付SOP](#第十一章-实施交付sop)
- [第十二章 客户场景Playbook](#第十二章-客户场景playbook)

---

# 第一章 设计目标与核心挑战

## 1.1 设计目标

| 目标编号 | 目标描述 | 验收标准 |
|:--------:|----------|----------|
| G-01 | **智链独立可售** | 智链可单独部署、单独运行、单独销售，不依赖智赢任何组件 |
| G-02 | **智数独立可售** | 智数可单独部署、单独运行、单独销售，不依赖智链任何组件 |
| G-03 | **双产品无缝集成** | 双产品组合部署时，用户感知为"一个平台"，SSO+统一门户+数据互通 |
| G-04 | **平滑升级** | 客户从单产品升级到双产品时，无需重新部署，只需激活License+开启服务 |
| G-05 | **数据不重复** | 组合模式下用户/权限/安全/审计数据只存一份，两套产品共享 |
| G-06 | **灵活组合** | 支持智链+智赢全量组合，也支持部分模块组合（如智链+智赢数据安全） |

## 1.2 核心挑战分析

```
挑战1: 共享底座的"既独立又共享"问题
  └── 独立部署时：共享底座必须随产品一起部署
  └── 组合部署时：共享底座只能部署一份，不能重复

挑战2: 前端门户的"独立又统一"问题
  └── 独立部署时：各自独立门户，独立登录
  └── 组合部署时：统一门户，一次登录访问两套功能

挑战3: 数据库的"分离又互通"问题
  └── 独立部署时：各自独立数据库
  └── 组合部署时：共享数据表（用户/权限/安全），业务表互通

挑战4: License的"独立又组合"问题
  └── 独立部署时：各自独立License
  └── 组合部署时：一份组合License或两份License联动

挑战5: API的"独立又联邦"问题
  └── 独立部署时：各自独立网关
  └── 组合部署时：统一网关路由分发
```

## 1.3 设计原则

| 原则 | 说明 | 实现策略 |
|------|------|----------|
| **底座可插拔** | 共享底座既可以内置也可以独立部署 | 通过部署配置决定共享底座运行模式 |
| **数据可分可合** | 数据库Schema设计支持分离和共享 | 共享表使用统一前缀，业务表使用产品前缀 |
| **门户可嵌可独** | 前端门户可独立运行也可嵌入统一门户 | 微前端架构 + 路由联邦 |
| **API可聚可散** | API网关可独立也可聚合 | 网关路由配置化，支持级联模式 |
| **License可单可组** | 授权支持单产品和组合产品 | License模块化，功能开关动态控制 |

---

# 第二章 三模式部署架构总览

## 2.1 三种部署模式定义

### 模式A：智链独立部署（SmartChain Standalone）

```
┌─────────────────────────────────────────────┐
│           智链独立部署 (IC Standalone)         │
│                                             │
│  ┌─────────────────────────────────────┐    │
│  │         智链前端门户 (Port 80)         │    │
│  │  模型管理│应用管理│成本管控│AI安全│风险  │    │
│  └──────────────────┬──────────────────┘    │
│                     │                        │
│  ┌──────────────────┴──────────────────┐    │
│  │         API网关 (Port 9000)           │    │
│  └──────────────────┬──────────────────┘    │
│                     │                        │
│  ┌──────────────────┴──────────────────┐    │
│  │  共享底座(内置)                      │    │
│  │  auth-svc │ system-svc │ security-svc│    │
│  │  audit-svc │ dashboard-svc           │    │
│  └──────────────────┬──────────────────┘    │
│                     │                        │
│  ┌──────────────────┴──────────────────┐    │
│  │  智链业务服务                        │    │
│  │  model-svc │ app-svc │ agent-svc     │    │
│  │  cost-svc │ risk-svc │ prompt-svc   │    │
│  └──────────────────┬──────────────────┘    │
│                     │                        │
│  ┌──────────────────┴──────────────────┐    │
│  │  Python AI安全引擎 (Port 8200)       │    │
│  └─────────────────────────────────────┘    │
│                                             │
│  数据库: DM8 (ic_schema)                    │
│  License: SC-Standard / SC-Enterprise       │
└─────────────────────────────────────────────┘
```

**适用客户**：仅需AI模型治理的客户（如AI公司、大模型应用企业）

### 模式B：智数独立部署（SmartWin Standalone）

```
┌─────────────────────────────────────────────┐
│           智数独立部署 (SD Standalone)         │
│                                             │
│  ┌─────────────────────────────────────┐    │
│  │         智赢前端门户 (Port 80)         │    │
│  │  数据目录│元数据│数据质量│数据标准│血缘  │    │
│  └──────────────────┬──────────────────┘    │
│                     │                        │
│  ┌──────────────────┴──────────────────┐    │
│  │         API网关 (Port 9000)           │    │
│  └──────────────────┬──────────────────┘    │
│                     │                        │
│  ┌──────────────────┴──────────────────┐    │
│  │  共享底座(内置)                      │    │
│  │  auth-svc │ system-svc │ security-svc│    │
│  │  audit-svc │ dashboard-svc           │    │
│  └──────────────────┬──────────────────┘    │
│                     │                        │
│  ┌──────────────────┴──────────────────┐    │
│  │  智赢业务服务                        │    │
│  │  catalog-svc │ metadata-svc          │    │
│  │  quality-svc │ standard-svc          │    │
│  │  lineage-svc │ mdm-svc               │    │
│  │  lifecycle-svc │ dataservice-svc     │    │
│  │  asset-svc                           │    │
│  └──────────────────┬──────────────────┘    │
│                     │                        │
│  ┌──────────────────┴──────────────────┐    │
│  │  Java AI治理引擎 (LangChain4j 内嵌)   │    │
│  └─────────────────────────────────────┘    │
│                                             │
│  数据库: DM8 (sw_schema)                    │
│  License: SD-Standard / SD-Enterprise       │
└─────────────────────────────────────────────┘
```

**适用客户**：仅需数据治理的客户（如传统企业、金融机构、政府部门）

### 模式C：双产品集成部署（Integrated Mode）

```
┌─────────────────────────────────────────────────────────────────┐
│              双产品集成部署 (Integrated Mode)                      │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              统一前端门户 (Port 80)                        │    │
│  │  ┌─────────────┐  ┌─────────────┐  ┌──────────────┐    │    │
│  │  │  统一驾驶舱   │  │  智链功能区   │  │  智赢功能区    │    │    │
│  │  │  (融合仪表盘) │  │  模型/应用/   │  │  目录/元数据/  │    │    │
│  │  │  统一告警     │  │  成本/安全/   │  │  质量/标准/    │    │    │
│  │  │  统一审计     │  │  风险/Agent   │  │  血缘/MDM/     │    │    │
│  │  │              │  │              │  │  服务/资产      │    │    │
│  │  └─────────────┘  └─────────────┘  └──────────────┘    │    │
│  └──────────────────────────┬──────────────────────────────┘    │
│                             │                                    │
│  ┌──────────────────────────┴──────────────────────────────┐    │
│  │              统一API网关 (Port 9000)                       │    │
│  │  /api/smartchain/** → 智链服务                            │    │
│  │  /api/smartwin/**   → 智赢服务                            │    │
│  │  /api/platform/**   → 共享服务                            │    │
│  └──────┬──────────────────┬──────────────────┬────────────┘    │
│         │                  │                  │                  │
│  ┌──────┴──────┐  ┌───────┴───────┐  ┌───────┴──────┐          │
│  │ 共享底座(一份)│  │ 智链业务服务   │  │ 智赢业务服务   │          │
│  │ auth-svc    │  │ model-svc     │  │ catalog-svc  │          │
│  │ system-svc  │  │ app-svc       │  │ metadata-svc │          │
│  │ security-svc│  │ agent-svc     │  │ quality-svc  │          │
│  │ audit-svc   │  │ cost-svc      │  │ standard-svc │          │
│  │ dashboard   │  │ risk-svc      │  │ lineage-svc  │          │
│  │             │  │ prompt-svc    │  │ mdm-svc      │          │
│  │ (只部署一份) │  │               │  │ lifecycle    │          │
│  │             │  │ AI安全引擎     │  │ dataservice  │          │
│  │             │  │ (Port 8200)   │  │ asset-svc    │          │
│  └──────┬──────┘  └───────┬───────┘  └───────┬──────┘          │
│         │                 │                  │                  │
│  ┌──────┴─────────────────┴──────────────────┴──────────────┐  │
│  │              统一数据库 (DM8)                               │  │
│  │  sys_* (共享) │ ic_* (智链) │ sw_* (智赢)                  │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                 │
│  License: SC+SD-Combo (组合License)                             │
└─────────────────────────────────────────────────────────────────┘
```

**适用客户**：同时需要数据治理和AI治理的客户（如大型企业、银行、运营商）

## 2.2 三模式对比

| 维度 | 模式A(智链独立) | 模式B(智数独立) | 模式C(集成部署) |
|------|:---:|:---:|:---:|
| 微服务数量 | 13个(7共享+6智链) | 16个(7共享+9智赢) | 22个(7共享+6智链+9智赢) |
| 前端门户 | 1个(智链) | 1个(智赢) | 1个(统一) |
| 数据库 | 1个(ic_schema) | 1个(sw_schema) | 1个(sys+ic+sw) |
| 登录方式 | 独立登录 | 独立登录 | SSO统一登录 |
| 部署方式 | Docker Compose | Docker Compose | Docker Compose |
| License | IC单产品 | SW单产品 | SC+SD组合 |
| 客户感知 | 一个产品 | 一个产品 | 一个平台两个模块 |

## 2.3 模式切换矩阵

| 当前模式 | 目标模式 | 切换方式 | 是否需要重新部署 |
|:--------:|:--------:|----------|:----------------:|
| A(智链独立) | C(集成) | 激活SW License + 部署智赢服务 + 切换统一门户 | 否（增量部署） |
| B(智数独立) | C(集成) | 激活IC License + 部署智链服务 + 切换统一门户 | 否（增量部署） |
| C(集成) | A(智链独立) | 停用智赢服务 + 切换智链门户 | 否（减量配置） |
| C(集成) | B(智数独立) | 停用智链服务 + 切换智数门户 | 否（减量配置） |

> **关键设计**：模式切换不需要重新部署，通过配置和License控制。

---

# 第三章 共享底座三模式适配设计

## 3.1 共享底座部署模式设计

共享底座（7个公共模块+7个共享服务）采用**可插拔部署**设计：

```yaml
# 部署配置文件: platform-config.yml
platform:
  mode: standalone    # standalone | integrated
  product: smartchain # smartchain | smartwin | both
  shared:
    auth-service: embedded    # embedded | shared
    system-service: embedded  # embedded | shared
    security-service: embedded
    audit-service: embedded
    dashboard-service: embedded
    notification-service: embedded
    config-service: embedded
```

### 独立模式（embedded）

```
智链独立部署:
  共享服务作为智链的一部分内嵌运行
  auth-service 使用 ic_schema.sys_user 表
  system-service 使用 ic_schema.sys_role 表

智数独立部署:
  共享服务作为智赢的一部分内嵌运行
  auth-service 使用 sw_schema.sys_user 表
  system-service 使用 sw_schema.sys_role 表
```

### 集成模式（shared）

```
集成部署:
  共享服务独立运行一份
  auth-service 使用 platform_schema.sys_user 表
  两套产品都连接同一个 auth-service
```

## 3.2 共享底座适配层设计

```java
// 共享底座模式适配器
@Configuration
public class PlatformModeConfig {

    @Value("${platform.mode:standalone}")
    private String platformMode;

    @Value("${platform.product:smartchain}")
    private String product;

    /**
     * 独立模式：共享服务使用产品自己的Schema
     * 集成模式：共享服务使用统一的platform Schema
     */
    @Bean
    public DataSource platformDataSource() {
        if ("integrated".equals(platformMode)) {
            // 集成模式：连接统一platform数据库
            return createDataSource("jdbc:dm://localhost:5236/platform");
        } else {
            // 独立模式：连接产品自己的数据库
            String schema = "smartchain".equals(product) ? "smartchain" : "smartwin";
            return createDataSource("jdbc:dm://localhost:5236/" + schema);
        }
    }
}
```

## 3.3 数据库Schema分离设计

```
独立模式 (智链):
  数据库: dm8
  Schema: smartchain
  表: smartchain.sys_user, smartchain.sys_role, smartchain.ic_model, ...

独立模式 (智赢):
  数据库: dm8
  Schema: smartwin
  表: smartwin.sys_user, smartwin.sys_role, smartwin.sw_catalog, ...

集成模式:
  数据库: dm8
  Schema: platform (共享表) + smartchain (智链业务表) + smartwin (智赢业务表)
  表: platform.sys_user, platform.sys_role,         ← 共享
      smartchain.ic_model, smartchain.ic_app,        ← 智链独有
      smartwin.sw_catalog, smartwin.sw_quality_rule  ← 智赢独有
```

### SQL Schema管理脚本

```sql
-- ============ 独立模式初始化(智链) ============
CREATE SCHEMA smartchain;
SET SCHEMA smartchain;
-- 共享表
CREATE TABLE sys_user (...);
CREATE TABLE sys_role (...);
-- 智链业务表
CREATE TABLE ic_model (...);
CREATE TABLE ic_app (...);

-- ============ 独立模式初始化(智赢) ============
CREATE SCHEMA smartwin;
SET SCHEMA smartwin;
-- 共享表
CREATE TABLE sys_user (...);
CREATE TABLE sys_role (...);
-- 智赢业务表
CREATE TABLE sw_data_catalog (...);
CREATE TABLE sw_quality_rule (...);

-- ============ 集成模式初始化 ============
CREATE SCHEMA platform;
CREATE SCHEMA smartchain;
CREATE SCHEMA smartwin;

-- 共享表在platform schema
SET SCHEMA platform;
CREATE TABLE sys_user (...);
CREATE TABLE sys_role (...);

-- 智链业务表在smartchain schema
SET SCHEMA smartchain;
CREATE TABLE ic_model (...);

-- 智赢业务表在smartwin schema
SET SCHEMA smartwin;
CREATE TABLE sw_data_catalog (...);
```

## 3.4 微服务注册适配

```yaml
# Nacos服务注册配置

# 独立模式(智链) - auth-service注册为 smartchain-auth
spring:
  application:
    name: smartchain-auth    # 独立模式带产品前缀
  cloud:
    nacos:
      discovery:
        metadata:
          mode: standalone
          product: smartchain

# 集成模式 - auth-service注册为 platform-auth
spring:
  application:
    name: platform-auth      # 集成模式统一前缀
  cloud:
    nacos:
      discovery:
        metadata:
          mode: integrated
          product: both
```

---

# 第四章 独立部署模式设计

## 4.1 智链独立部署包

### Docker Compose配置

```yaml
# docker-compose-smartchain-standalone.yml
version: '3.8'

services:
  # ======== 基础设施 ========
  nacos:
    image: nacos/nacos-server:v2.3.2
    ports: ["8848:8848"]
    environment:
      MODE: standalone

  redis:
    image: redis:7.2-alpine
    ports: ["6379:6379"]

  dm8:
    image: dm8:latest
    ports: ["5236:5236"]
    volumes:
      - dm8-data:/opt/dmdbms/data
      - ./sql/smartchain-standalone-init.sql:/docker-entrypoint-initdb.d/init.sql

  # ======== 共享底座(内置) ========
  auth-service:
    build: ../../platform-services/auth-service
    ports: ["8081:8080"]
    environment:
      - PLATFORM_MODE=standalone
      - PLATFORM_PRODUCT=smartchain
      - DB_SCHEMA=smartchain
    depends_on: [nacos, redis, dm8]

  system-service:
    build: ../../platform-services/system-service
    ports: ["8082:8080"]
    environment:
      - PLATFORM_MODE=standalone
      - PLATFORM_PRODUCT=smartchain
      - DB_SCHEMA=smartchain
    depends_on: [nacos, redis, dm8]

  security-service:
    build: ../../platform-services/security-service
    ports: ["8090:8080"]
    environment:
      - PLATFORM_MODE=standalone
      - PLATFORM_PRODUCT=smartchain
    depends_on: [nacos, redis, dm8]

  audit-service:
    build: ../../platform-services/audit-service
    ports: ["8100:8080"]
    environment:
      - PLATFORM_MODE=standalone
      - PLATFORM_PRODUCT=smartchain
    depends_on: [nacos, redis, dm8]

  # ======== 智链业务服务 ========
  model-service:
    build: ../../smartchain/smartchain-services/model-service
    ports: ["8083:8080"]
    depends_on: [nacos, redis, dm8, auth-service]

  app-service:
    build: ../../smartchain/smartchain-services/app-service
    ports: ["8084:8080"]
    depends_on: [nacos, redis, dm8, auth-service]

  agent-service:
    build: ../../smartchain/smartchain-services/agent-service
    ports: ["8085:8080"]
    depends_on: [nacos, redis, dm8, auth-service]

  cost-service:
    build: ../../smartchain/smartchain-services/cost-service
    ports: ["8086:8080"]
    depends_on: [nacos, redis, dm8, auth-service]

  risk-service:
    build: ../../smartchain/smartchain-services/risk-service
    ports: ["8087:8080"]
    depends_on: [nacos, redis, dm8, auth-service]

  prompt-service:
    build: ../../smartchain/smartchain-services/prompt-service
    ports: ["8088:8080"]
    depends_on: [nacos, redis, dm8, auth-service]

  # ======== AI引擎 ========
  ai-engine:
    build: ../../smartchain/smartchain-ai-engine
    ports: ["8200:8200"]
    depends_on: [redis]

  # ======== 网关 ========
  gateway:
    build: ../../gateway
    ports: ["9000:9000"]
    environment:
      - PLATFORM_MODE=standalone
      - PRODUCT=smartchain
    depends_on: [auth-service, model-service, app-service]

  # ======== 前端 ========
  frontend:
    build: ../../smartchain/smartchain-frontend
    ports: ["80:80"]
    depends_on: [gateway]

volumes:
  dm8-data:
```

### 网关路由配置（独立模式）

```yaml
# gateway-standalone.yml - 智链独立网关
spring:
  cloud:
    gateway:
      routes:
        # 共享服务路由
        - id: auth-service
          uri: lb://smartchain-auth
          predicates: [Path=/api/auth/**]
        - id: system-service
          uri: lb://smartchain-system
          predicates: [Path=/api/system/**]
        - id: security-service
          uri: lb://smartchain-security
          predicates: [Path=/api/security/**]
        - id: audit-service
          uri: lb://smartchain-audit
          predicates: [Path=/api/audit/**]
        # 智链业务路由
        - id: model-service
          uri: lb://model-service
          predicates: [Path=/api/smartchain/models/**]
        - id: app-service
          uri: lb://app-service
          predicates: [Path=/api/smartchain/apps/**]
        # ... 其他智链服务路由
```

## 4.2 智数独立部署包

结构与智链类似，区别在于：
- 业务服务替换为智赢9个服务
- 前端替换为智赢前端
- 无Python AI引擎（LangChain4j内嵌）
- 新增Elasticsearch和Neo4j

```yaml
# docker-compose-smartwin-standalone.yml (关键差异部分)
services:
  # 额外基础设施
  elasticsearch:
    image: elasticsearch:8.13.0
    ports: ["9200:9200"]
    environment:
      - discovery.type=single-node

  neo4j:
    image: neo4j:5.20
    ports: ["7474:7474", "7687:7687"]

  # 共享底座(内置) - 与智链相同但Schema不同
  auth-service:
    environment:
      - PLATFORM_MODE=standalone
      - PLATFORM_PRODUCT=smartwin
      - DB_SCHEMA=smartwin

  # 智赢业务服务
  catalog-service:
    build: ../../smartwin/smartwin-services/catalog-service
    ports: ["8091:8080"]
    depends_on: [nacos, redis, dm8, elasticsearch]

  metadata-service:
    build: ../../smartwin/smartwin-services/metadata-service
    ports: ["8092:8080"]
    depends_on: [nacos, redis, dm8]

  lineage-service:
    build: ../../smartwin/smartwin-services/lineage-service
    ports: ["8095:8080"]
    depends_on: [nacos, redis, dm8, neo4j]
  # ... 其他智赢服务
```

---

# 第五章 无缝集成模式设计

## 5.1 集成部署核心机制

集成模式的**四大核心机制**：

| 机制 | 说明 | 实现 |
|------|------|------|
| **统一认证(SSO)** | 一次登录访问两套产品 | 共享JWT Token + 统一auth-service |
| **统一门户** | 一个前端门户包含两套功能 | 微前端 + 路由联邦 |
| **数据互通** | 两套产品可互访对方数据 | 跨服务API调用 + 数据联邦层 |
| **统一审计** | 操作日志统一存储查询 | 统一audit-service + 双向日志上报 |

## 5.2 集成部署Docker Compose

```yaml
# docker-compose-integrated.yml
version: '3.8'

services:
  # ======== 基础设施 ========
  nacos:
    image: nacos/nacos-server:v2.3.2
    ports: ["8848:8848"]
    environment:
      MODE: standalone

  redis:
    image: redis:7.2-alpine
    ports: ["6379:6379"]

  dm8:
    image: dm8:latest
    ports: ["5236:5236"]
    volumes:
      - dm8-data:/opt/dmdbms/data
      - ./sql/integrated-init.sql:/docker-entrypoint-initdb.d/init.sql

  elasticsearch:
    image: elasticsearch:8.13.0
    ports: ["9200:9200"]
    environment:
      - discovery.type=single-node

  neo4j:
    image: neo4j:5.20
    ports: ["7474:7474", "7687:7687"]

  minio:
    image: minio/minio:latest
    ports: ["9001:9000", "9002:9001"]
    command: server /data --console-address ":9001"

  # ======== 共享底座(一份) ========
  auth-service:
    build: ../../platform-services/auth-service
    ports: ["8081:8080"]
    environment:
      - PLATFORM_MODE=integrated
      - DB_SCHEMA=platform
    depends_on: [nacos, redis, dm8]

  system-service:
    build: ../../platform-services/system-service
    ports: ["8082:8080"]
    environment:
      - PLATFORM_MODE=integrated
      - DB_SCHEMA=platform
    depends_on: [nacos, redis, dm8]

  security-service:
    build: ../../platform-services/security-service
    ports: ["8090:8080"]
    environment:
      - PLATFORM_MODE=integrated
      - DB_SCHEMA=platform
    depends_on: [nacos, redis, dm8]

  audit-service:
    build: ../../platform-services/audit-service
    ports: ["8100:8080"]
    environment:
      - PLATFORM_MODE=integrated
      - DB_SCHEMA=platform
    depends_on: [nacos, redis, dm8]

  dashboard-service:
    build: ../../platform-services/dashboard-service
    ports: ["8101:8080"]
    environment:
      - PLATFORM_MODE=integrated
      - DASHBOARD_TYPE=unified    # unified仪表盘融合两套数据
    depends_on: [nacos, redis, dm8]

  # ======== 智链业务服务 ========
  model-service:
    build: ../../smartchain/smartchain-services/model-service
    ports: ["8083:8080"]
    environment:
      - PLATFORM_MODE=integrated
      - DB_SCHEMA=smartchain
      - AUTH_SERVICE=platform-auth  # 指向统一认证
    depends_on: [nacos, redis, dm8, auth-service]

  app-service:
    build: ../../smartchain/smartchain-services/app-service
    ports: ["8084:8080"]
    environment:
      - PLATFORM_MODE=integrated
      - DB_SCHEMA=smartchain
    depends_on: [nacos, redis, dm8, auth-service]

  # ... 其他智链服务

  ai-engine:
    build: ../../smartchain/smartchain-ai-engine
    ports: ["8200:8200"]
    depends_on: [redis]

  # ======== 智赢业务服务 ========
  catalog-service:
    build: ../../smartwin/smartwin-services/catalog-service
    ports: ["8091:8080"]
    environment:
      - PLATFORM_MODE=integrated
      - DB_SCHEMA=smartwin
      - AUTH_SERVICE=platform-auth
    depends_on: [nacos, redis, dm8, elasticsearch, auth-service]

  metadata-service:
    build: ../../smartwin/smartwin-services/metadata-service
    ports: ["8092:8080"]
    environment:
      - PLATFORM_MODE=integrated
      - DB_SCHEMA=smartwin
    depends_on: [nacos, redis, dm8, auth-service]

  # ... 其他智赢服务

  # ======== 统一网关 ========
  gateway:
    build: ../../gateway
    ports: ["9000:9000"]
    environment:
      - PLATFORM_MODE=integrated
    depends_on: [auth-service, model-service, catalog-service]

  # ======== 统一前端 ========
  frontend-unified:
    build: ../../frontend-unified    # 统一前端门户
    ports: ["80:80"]
    depends_on: [gateway]

volumes:
  dm8-data:
```

## 5.3 集成模式网关路由

```yaml
# gateway-integrated.yml - 集成模式统一网关
spring:
  cloud:
    gateway:
      routes:
        # ======== 共享服务路由(统一) ========
        - id: platform-auth
          uri: lb://platform-auth
          predicates: [Path=/api/auth/**]
        - id: platform-system
          uri: lb://platform-system
          predicates: [Path=/api/system/**]
        - id: platform-security
          uri: lb://platform-security
          predicates: [Path=/api/security/**]
        - id: platform-audit
          uri: lb://platform-audit
          predicates: [Path=/api/audit/**]
        - id: platform-dashboard
          uri: lb://platform-dashboard
          predicates: [Path=/api/dashboard/**]

        # ======== 智链业务路由 ========
        - id: ic-model
          uri: lb://model-service
          predicates: [Path=/api/smartchain/models/**]
        - id: ic-app
          uri: lb://app-service
          predicates: [Path=/api/smartchain/apps/**]
        - id: ic-agent
          uri: lb://agent-service
          predicates: [Path=/api/smartchain/agents/**]
        - id: ic-cost
          uri: lb://cost-service
          predicates: [Path=/api/smartchain/cost/**]
        - id: ic-risk
          uri: lb://risk-service
          predicates: [Path=/api/smartchain/risk/**]
        - id: ic-prompt
          uri: lb://prompt-service
          predicates: [Path=/api/smartchain/prompts/**]

        # ======== 智赢业务路由 ========
        - id: sw-catalog
          uri: lb://catalog-service
          predicates: [Path=/api/smartwin/catalog/**]
        - id: sw-metadata
          uri: lb://metadata-service
          predicates: [Path=/api/smartwin/metadata/**]
        - id: sw-quality
          uri: lb://quality-service
          predicates: [Path=/api/smartwin/quality/**]
        - id: sw-standard
          uri: lb://standard-service
          predicates: [Path=/api/smartwin/standard/**]
        - id: sw-lineage
          uri: lb://lineage-service
          predicates: [Path=/api/smartwin/lineage/**]
        - id: sw-mdm
          uri: lb://mdm-service
          predicates: [Path=/api/smartwin/mdm/**]
        - id: sw-lifecycle
          uri: lb://lifecycle-service
          predicates: [Path=/api/smartwin/lifecycle/**]
        - id: sw-dataservice
          uri: lb://dataservice-service
          predicates: [Path=/api/smartwin/dataservice/**]
        - id: sw-asset
          uri: lb://asset-service
          predicates: [Path=/api/smartwin/asset/**]
```

---

# 第六章 数据互通与联邦查询设计

## 6.1 数据互通场景

集成模式下，两套产品之间有以下数据互通需求：

| 场景 | 数据流向 | 说明 |
|------|----------|------|
| AI应用关联数据资产 | 智链→智赢 | 智链的AI应用使用了智赢的哪些数据资产 |
| 数据质量影响AI模型 | 智赢→智链 | 智赢检测到数据质量问题，预警智链相关AI模型 |
| AI模型输出数据治理 | 智链→智赢 | 智链的AI模型输出数据自动注册到智赢数据目录 |
| 统一安全分级 | 双向 | 共享底座统一管理数据分级和AI输出分级 |
| 统一审计追溯 | 双向 | 数据操作和AI调用统一审计 |

## 6.2 跨产品API调用设计

```java
// 智链 model-service 调用智赢 catalog-service 示例
@Service
public class ModelDataLinkService {

    private final RestClient restClient;

    /**
     * 查询AI应用关联的数据资产
     * 智链 → 智赢 跨产品调用
     */
    public List<DataAssetDTO> getLinkedDataAssets(Long appId) {
        // 集成模式：直接调用智赢catalog-service API
        // 独立模式：返回空列表（功能降级）
        if (!isIntegratedMode()) {
            return Collections.emptyList();
        }
        return restClient.get()
            .uri("/api/smartwin/catalog/by-app/{appId}", appId)
            .header("Authorization", getCurrentToken())
            .retrieve()
            .body(new ParameterizedTypeReference<>() {});
    }
}
```

```java
// 智赢 quality-service 检测到质量问题后通知智链 risk-service
@Service
public class QualityRiskNotifier {

    /**
     * 数据质量问题通知AI风险管控
     * 智赢 → 智链 跨产品事件通知
     */
    @EventListener
    public void onQualityIssue(QualityIssueEvent event) {
        if (!isIntegratedMode()) {
            return;  // 独立模式不处理
        }
        // 通过RocketMQ发送跨产品事件
        messageProducer.send("ic-risk-topic", QualityRiskEvent.builder()
            .source("smartwin-quality")
            .catalogId(event.getCatalogId())
            .qualityScore(event.getScore())
            .issueType(event.getIssueType())
            .build());
    }
}
```

## 6.3 数据联邦查询层

```java
// 统一仪表盘服务 - 融合两套产品的数据
@Service
public class UnifiedDashboardService {

    /**
     * 统一治理驾驶舱数据
     * 同时查询智链和智赢的核心指标
     */
    public UnifiedDashboardVO getUnifiedDashboard() {
        UnifiedDashboardVO dashboard = new UnifiedDashboardVO();

        // 共享数据（直接查）
        dashboard.setUserCount(systemService.countUsers());
        dashboard.setAlertCount(auditService.countActiveAlerts());

        if (isSmartChainEnabled()) {
            // 智链指标
            dashboard.setModelCount(modelService.countModels());
            dashboard.setAiCallToday(modelService.countTodayCalls());
            dashboard.setAiCostThisMonth(costService.getMonthlyCost());
            dashboard.setAiRiskCount(riskService.countActiveRisks());
        }

        if (isSmartwinEnabled()) {
            // 智赢指标
            dashboard.setDataAssetCount(catalogService.countAssets());
            dashboard.setQualityAvgScore(qualityService.getAvgScore());
            dashboard.setStandardCoverage(standardService.getCoverageRate());
            dashboard.setLineageNodeCount(lineageService.countNodes());
        }

        return dashboard;
    }

    /**
     * 根据License判断智链功能是否启用
     */
    private boolean isSmartChainEnabled() {
        return licenseManager.hasModule("smartchain");
    }

    private boolean isSmartwinEnabled() {
        return licenseManager.hasModule("smartwin");
    }
}
```

## 6.4 跨产品数据关联表

```sql
-- 集成模式专用的跨产品关联表（仅集成模式创建）
CREATE TABLE platform.cross_product_link (
    id BIGINT PRIMARY KEY,
    link_type VARCHAR(50) NOT NULL,           -- app_to_asset / model_to_data / quality_to_risk
    source_product VARCHAR(20) NOT NULL,      -- smartchain / smartwin
    target_product VARCHAR(20) NOT NULL,      -- smartchain / smartwin
    source_id BIGINT NOT NULL,                -- 源对象ID
    source_type VARCHAR(50) NOT NULL,         -- 源对象类型(app/model/catalog)
    target_id BIGINT NOT NULL,                -- 目标对象ID
    target_type VARCHAR(50) NOT NULL,         -- 目标对象类型
    relation_metadata TEXT,                   -- 关联元数据JSON
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_source (source_product, source_id),
    INDEX idx_target (target_product, target_id)
);
```

---

# 第七章 统一门户与SSO设计

## 7.1 微前端统一门户架构

```
┌─────────────────────────────────────────────────────────────────┐
│                    统一前端门户 (Portal Shell)                     │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  顶栏: Logo │ 全局搜索 │ 告警 │ 用户中心 │ 主题切换 │ 语言切换   │    │
│  └─────────────────────────────────────────────────────────┘    │
│  ┌────────┬────────────────────────────────────────────────┐    │
│  │        │                                                        │    │
│  │ 侧边栏  │              内容区域 (Content Area)                │    │
│  │        │                                                        │    │
│  │ ┌───┐  │  ┌──────────────────────────────────────────────┐  │    │
│  │ │统 │  │  │                                              │  │    │
│  │ │一 │  │  │   根据路由动态加载子应用:                      │  │    │
│  │ │驾 │  │  │   • /dashboard → 统一驾驶舱                    │  │    │
│  │ │驶 │  │  │   • /smartchain/* → 智链子应用                 │  │    │
│  │ │舱 │  │  │   • /smartwin/* → 智赢子应用                   │  │    │
│  │ ├───┤  │  │   • /security/* → 安全治理(共享)               │  │    │
│  │ │智 │  │  │   • /audit/* → 审计日志(共享)                  │  │    │
│  │ │链 │  │  │                                              │  │    │
│  │ │功 │  │  └──────────────────────────────────────────────┘  │    │
│  │ │能 │  │                                                      │    │
│  │ ├───┤  │                                                      │    │
│  │ │智 │  │                                                      │    │
│  │ │赢 │  │                                                      │    │
│  │ │功 │  │                                                      │    │
│  │ │能 │  │                                                      │    │
│  │ ├───┤  │                                                      │    │
│  │ │共 │  │                                                      │    │
│  │ │享 │  │                                                      │    │
│  │ │功 │  │                                                      │    │
│  │ │能 │  │                                                      │    │
│  │ └───┘  │                                                      │    │
│  └────────┴──────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

## 7.2 前端路由联邦设计

```typescript
// frontend-unified/src/router/index.ts
// 统一门户路由配置

const routes = [
  // 公共路由
  { path: '/login', component: () => import('@/views/LoginView.vue') },

  // 主布局
  {
    path: '/',
    component: () => import('@/layouts/UnifiedLayout.vue'),
    children: [
      // 统一驾驶舱（融合双产品数据）
      { path: '', component: () => import('@/views/UnifiedDashboard.vue') },

      // 智链功能区 - 动态加载智链子应用
      {
        path: 'smartchain',
        component: () => import('@/views/smartchain/SmartChainLoader.vue'),
        children: [
          { path: 'models', component: () => import('@/views/smartchain/ModelOverview.vue') },
          { path: 'models/access', component: () => import('@/views/smartchain/ModelAccess.vue') },
          { path: 'apps', component: () => import('@/views/smartchain/AppList.vue') },
          { path: 'cost', component: () => import('@/views/smartchain/CostView.vue') },
          { path: 'risk', component: () => import('@/views/smartchain/RiskControl.vue') },
          { path: 'agents', component: () => import('@/views/smartchain/AgentView.vue') },
          // ...
        ]
      },

      // 智赢功能区 - 动态加载智赢子应用
      {
        path: 'smartwin',
        component: () => import('@/views/smartwin/SmartWinLoader.vue'),
        children: [
          { path: 'catalog', component: () => import('@/views/smartwin/CatalogBrowse.vue') },
          { path: 'metadata', component: () => import('@/views/smartwin/MetadataView.vue') },
          { path: 'quality', component: () => import('@/views/smartwin/QualityOverview.vue') },
          { path: 'standard', component: () => import('@/views/smartwin/StandardList.vue') },
          { path: 'lineage', component: () => import('@/views/smartwin/LineageGraph.vue') },
          // ...
        ]
      },

      // 共享功能区
      {
        path: 'security',
        children: [
          { path: '', component: () => import('@/views/shared/DataSecurity.vue') },
          { path: 'classify', component: () => import('@/views/shared/Classify.vue') },
          { path: 'masking', component: () => import('@/views/shared/Masking.vue') },
        ]
      },
      {
        path: 'audit',
        children: [
          { path: '', component: () => import('@/views/shared/AuditView.vue') },
          { path: 'op-log', component: () => import('@/views/shared/OpLogView.vue') },
        ]
      },
      {
        path: 'system',
        children: [
          { path: 'users', component: () => import('@/views/shared/UserMgmt.vue') },
          { path: 'roles', component: () => import('@/views/shared/RoleMgmt.vue') },
        ]
      },
    ]
  }
]
```

## 7.3 动态菜单与功能开关

```typescript
// frontend-unified/src/composables/useMenu.ts
// 根据License动态生成菜单

export function useMenu() {
  const licenseStore = useLicenseStore()
  const menuTree = ref<MenuItem[]>([])

  // 根据License动态构建菜单
  function buildMenu() {
    const menu: MenuItem[] = []

    // 统一驾驶舱（始终显示）
    menu.push({
      title: '统一驾驶舱',
      icon: 'DashboardOutlined',
      path: '/',
      alwaysShow: true
    })

    // 智链功能（License控制）
    if (licenseStore.hasModule('smartchain')) {
      menu.push({
        title: 'AI模型治理',
        icon: 'RobotOutlined',
        path: '/smartchain',
        children: [
          { title: '模型管理', path: '/smartchain/models' },
          { title: '应用管理', path: '/smartchain/apps' },
          { title: '成本管控', path: '/smartchain/cost' },
          { title: '风险管控', path: '/smartchain/risk' },
          { title: 'Agent管理', path: '/smartchain/agents' },
        ]
      })
    }

    // 智赢功能（License控制）
    if (licenseStore.hasModule('smartwin')) {
      menu.push({
        title: '数据治理',
        icon: 'DatabaseOutlined',
        path: '/smartwin',
        children: [
          { title: '数据目录', path: '/smartwin/catalog' },
          { title: '元数据', path: '/smartwin/metadata' },
          { title: '数据质量', path: '/smartwin/quality' },
          { title: '数据标准', path: '/smartwin/standard' },
          { title: '数据血缘', path: '/smartwin/lineage' },
        ]
      })
    }

    // 共享功能（始终显示）
    menu.push({
      title: '安全治理',
      icon: 'SafetyOutlined',
      path: '/security',
      children: [
        { title: '分类分级', path: '/security/classify' },
        { title: '数据脱敏', path: '/security/masking' },
      ]
    })

    menu.push({
      title: '审计日志',
      icon: 'AuditOutlined',
      path: '/audit'
    })

    menu.push({
      title: '系统管理',
      icon: 'SettingOutlined',
      path: '/system'
    })

    menuTree.value = menu
  }

  return { menuTree, buildMenu }
}
```

## 7.4 SSO统一认证流程

```
集成模式SSO流程:

1. 用户访问统一门户 → 检查JWT Token
2. 无Token → 跳转统一登录页
3. 登录成功 → auth-service生成JWT（包含产品权限）
4. JWT Payload包含:
   {
     "userId": 123,
     "username": "admin",
     "modules": ["smartchain", "smartwin"],  // 授权的产品模块
     "permissions": ["ic:model:view", "sw:catalog:view", ...],
     "exp": 1234567890
   }
5. 前端根据JWT中的modules动态渲染菜单
6. 所有API请求携带JWT，网关统一鉴权
7. 智链/智赢服务通过JWT获取用户信息，无需二次认证
```

```java
// JWT Token生成（集成模式）
public String generateToken(User user, License license) {
    return Jwts.builder()
        .setSubject(user.getUsername())
        .claim("userId", user.getId())
        .claim("username", user.getUsername())
        .claim("modules", license.getModules())         // ["smartchain", "smartwin"]
        .claim("permissions", user.getPermissions())    // 细粒度权限
        .claim("mode", "integrated")                    // 部署模式
        .setIssuedAt(new Date())
        .setExpiration(expireDate)
        .signWith(secretKey)
        .compact();
}
```

---

# 第八章 API联邦与服务网格设计

## 8.1 API版本兼容设计

所有跨产品API采用版本化设计，确保独立和集成模式下的API兼容性：

```
API路径规范:
  /api/{product}/{module}/{version}/{resource}

示例:
  /api/smartchain/models/v1/list        → 智链模型列表
  /api/smartwin/catalog/v1/search       → 智赢数据搜索
  /api/platform/auth/v1/login           → 统一认证
```

## 8.2 服务发现适配

```
独立模式服务注册:
  smartchain-auth        (智链内置认证)
  smartchain-system      (智链内置系统管理)
  model-service          (智链模型管理)
  ...

集成模式服务注册:
  platform-auth          (统一认证)
  platform-system        (统一系统管理)
  model-service          (智链模型管理)
  catalog-service        (智赢数据目录)
  ...
```

## 8.3 跨服务调用适配层

```java
// 跨产品服务调用适配器
@Component
public class CrossProductClient {

    @Value("${platform.mode:standalone}")
    private String platformMode;

    /**
     * 获取认证服务名称（根据部署模式自动适配）
     */
    private String getAuthServiceName() {
        return "integrated".equals(platformMode) ? "platform-auth" : "smartchain-auth";
    }

    /**
     * 调用智赢数据目录API（智链→智赢）
     * 独立模式返回降级结果
     */
    public List<DataAssetDTO> queryDataAssets(Long appId) {
        if (!"integrated".equals(platformMode)) {
            log.debug("独立模式，跳过跨产品调用");
            return Collections.emptyList();
        }
        try {
            return restClient.get()
                .uri("lb://catalog-service/api/smartwin/catalog/v1/by-app/{appId}", appId)
                .retrieve()
                .body(new ParameterizedTypeReference<>() {});
        } catch (Exception e) {
            log.warn("跨产品调用失败，降级处理", e);
            return Collections.emptyList();
        }
    }
}
```

---

# 第九章 License授权与功能开关设计

## 9.1 License体系设计

```
License层级:
  产品级 License
    ├── 智链 License (SC-Standard / SC-Enterprise)
    ├── 智数 License (SD-Standard / SD-Enterprise)
    └── 组合 License (SC+SD-Combo)
  模块级 License
    ├── 智链: 模型管理 / 应用管理 / 成本管控 / AI安全 / ...
    └── 智赢: 数据目录 / 元数据 / 数据质量 / 数据标准 / ...
  功能级 License
    ├── AI安全检测(高级功能)
    ├── AI智能搜索(高级功能)
    └── 数据资产入表(高级功能)
```

## 9.2 License数据结构

```java
// License信息模型
public class LicenseInfo {
    private String licenseId;           // License唯一ID
    private String customerName;        // 客户名称
    private String licenseType;         // STANDARD / ENTERPRISE / COMBO
    private List<String> products;      // ["smartchain"] / ["smartwin"] / ["smartchain","smartwin"]
    private List<String> modules;       // 授权模块列表
    private List<String> features;      // 高级功能列表
    private int maxUsers;               // 最大用户数
    private int maxModels;              // 最大模型数(智链)
    private long maxDataAssets;         // 最大数据资产数(智赢)
    private LocalDate expireDate;       // 到期日期
    private String deployMode;          // STANDALONE_IC / STANDALONE_SW / INTEGRATED
    private String signature;           // 数字签名
}
```

## 9.3 功能开关机制

```java
// 功能开关注解
@Target({ElementType.METHOD, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
public @interface RequiresModule {
    String value();                    // 模块名: smartchain / smartwin
    String feature() default "";       // 可选功能名
}

// 使用示例
@RestController
@RequestMapping("/api/smartchain/models")
@RequiresModule("smartchain")          // 需要智链License
public class ModelController {

    @PostMapping("/evaluate")
    @RequiresModule(value = "smartchain", feature = "ai_evaluation")  // 需要AI评测功能
    public ApiResponse evaluateModel(@RequestBody EvaluationRequest req) {
        // ...
    }
}

// 拦截器实现
@Component
public class LicenseInterceptor implements HandlerInterceptor {
    @Override
    public boolean preHandle(HttpServletRequest request, ...) {
        RequiresModule annotation = getAnnotation(handler);
        if (annotation != null) {
            LicenseInfo license = licenseManager.getCurrentLicense();
            if (!license.getProducts().contains(annotation.value())) {
                throw new LicenseException("未授权该产品模块");
            }
            if (!annotation.feature().isEmpty()
                && !license.getFeatures().contains(annotation.feature())) {
                throw new LicenseException("未授权该功能");
            }
        }
        return true;
    }
}
```

## 9.4 License文件示例

```json
{
  "licenseId": "LIC-2027-001",
  "customerName": "某银行股份有限公司",
  "licenseType": "COMBO",
  "products": ["smartchain", "smartwin"],
  "modules": [
    "smartchain.model", "smartchain.app", "smartchain.cost",
    "smartchain.risk", "smartchain.agent", "smartchain.prompt",
    "smartwin.catalog", "smartwin.metadata", "smartwin.quality",
    "smartwin.standard", "smartwin.lineage", "smartwin.mdm",
    "smartwin.lifecycle", "smartwin.dataservice", "smartwin.asset"
  ],
  "features": [
    "ai_security_detection", "ai_model_evaluation",
    "ai_metadata_autofill", "ai_quality_detection",
    "ai_smart_search", "ai_data_qa", "data_capitalization"
  ],
  "maxUsers": 500,
  "maxModels": 50,
  "maxDataAssets": 100000,
  "expireDate": "2026-07-07",
  "deployMode": "INTEGRATED",
  "signature": "SM2:MEUCIQDx..."
}
```

---

# 第十章 商业化包装与组合定价方案

## 10.1 产品包装矩阵

| 包装 | 包含内容 | 目标客户 | 定价(万元/年) |
|------|----------|----------|:----------:|
| **智链标准版** | 智链6模块+共享底座+5模型 | AI应用企业 | 30-50 |
| **智链企业版** | 智链6模块+AI安全+AI评测+共享底座 | 大型企业AI中心 | 60-100 |
| **智赢标准版** | 智赢5核心模块+共享底座 | 传统企业 | 40-60 |
| **智赢企业版** | 智赢9模块+AI治理引擎+共享底座 | 大型企业/金融 | 80-150 |
| **双平台组合版** | 智链企业版+智赢企业版+统一门户 | 大型企业/银行/运营商 | 120-250 |
| **双平台旗舰版** | 组合版+定制化+专属支持 | 央企/头部金融 | 200-500 |

## 10.2 组合销售优惠策略

| 购买方式 | 原价(万元) | 组合价(万元) | 优惠率 | 附加价值 |
|----------|:----------:|:----------:|:------:|----------|
| 智链企业版单独 | 100 | — | — | — |
| 智赢企业版单独 | 150 | — | — | — |
| 双平台组合版 | 250 | 200 | 20% | 统一门户+数据互通 |
| 双平台旗舰版 | 250+定制 | 250起 | 定制 | 专属支持+定制开发 |

## 10.3 模块化按需组合

除了标准包装外，支持模块级按需组合：

| 组合场景 | 说明 | 适用客户 |
|----------|------|----------|
| 智链 + 智赢数据安全 | AI治理 + 数据安全合规 | AI公司+合规需求 |
| 智赢 + 智链AI安全 | 数据治理 + AI安全检测 | 金融数据治理+AI安全 |
| 智赢 + 智链成本管控 | 数据治理 + AI成本管理 | 大规模AI调用企业 |
| 全量组合 | 全部模块 | 大型企业/央企 |

```java
// 按需组合定价计算器
public class PricingCalculator {

    /**
     * 计算组合价格
     */
    public BigDecimal calculatePrice(List<String> modules, int userCount) {
        BigDecimal total = BigDecimal.ZERO;

        // 基础底座费用（必选）
        total = total.add(BASE_PLATFORM_FEE);

        // 模块费用累加
        for (String module : modules) {
            total = total.add(getModulePrice(module));
        }

        // 用户数阶梯计价
        total = total.multiply(getUserMultiplier(userCount));

        // 组合优惠（3个以上模块打9折，5个以上打8折）
        if (modules.size() >= 5) {
            total = total.multiply(new BigDecimal("0.8"));
        } else if (modules.size() >= 3) {
            total = total.multiply(new BigDecimal("0.9"));
        }

        return total;
    }
}
```

---

# 第十一章 实施交付SOP

## 11.1 独立部署交付SOP

### 智链独立部署（4小时）

| 步骤 | 时间 | 操作 | 产出 |
|:----:|:----:|------|------|
| 1 | 15min | 环境检查（OS/Docker/网络） | 环境检查报告 |
| 2 | 15min | 上传部署包+解压 | 部署目录就绪 |
| 3 | 10min | 修改.env配置（IP/端口/密码） | 配置文件就绪 |
| 4 | 5min | 导入License | License验证通过 |
| 5 | 30min | docker-compose up -d | 全部容器启动 |
| 6 | 10min | 数据库初始化+种子数据 | 数据库就绪 |
| 7 | 15min | 配置大模型API密钥 | AI引擎就绪 |
| 8 | 10min | 创建管理员账号 | 管理员可登录 |
| 9 | 30min | 功能验证测试 | 验证通过 |
| 10 | 60min | 客户培训 | 培训完成 |

### 智数独立部署（6小时）

与智链类似，额外包含ES和Neo4j初始化，时间增加2小时。

## 11.2 集成部署交付SOP

### 双平台集成部署（8小时）

| 步骤 | 时间 | 操作 | 产出 |
|:----:|:----:|------|------|
| 1 | 20min | 环境检查 | 环境检查报告 |
| 2 | 20min | 上传部署包+解压 | 部署目录就绪 |
| 3 | 20min | 修改integrated.env配置 | 配置文件就绪 |
| 4 | 10min | 导入组合License | License验证通过 |
| 5 | 45min | docker-compose up -d（22个服务+6个基础设施） | 全部容器启动 |
| 6 | 20min | 数据库初始化（3个Schema） | 数据库就绪 |
| 7 | 15min | ES索引初始化 | 搜索引擎就绪 |
| 8 | 15min | Neo4j图数据库初始化 | 血缘引擎就绪 |
| 9 | 15min | 配置大模型API密钥 | AI引擎就绪 |
| 10 | 10min | 创建管理员账号 | 管理员可登录 |
| 11 | 30min | 统一门户验证（SSO+菜单+路由） | 门户验证通过 |
| 12 | 30min | 跨产品功能验证（数据互通） | 互通验证通过 |
| 13 | 60min | 功能全面验证测试 | 验证通过 |
| 14 | 120min | 客户培训（双产品） | 培训完成 |

## 11.3 从独立升级到集成SOP

### 智链独立 → 集成升级（4小时，不停机）

| 步骤 | 时间 | 操作 | 说明 |
|:----:|:----:|------|------|
| 1 | 10min | 备份当前智链数据 | 数据库+配置备份 |
| 2 | 10min | 更新License为组合版 | 导入新License |
| 3 | 5min | 创建smartwin Schema | 数据库扩展 |
| 4 | 30min | 部署智赢9个业务服务 | docker-compose扩展 |
| 5 | 5min | 部署ES+Neo4j | 智赢依赖组件 |
| 6 | 10min | 更新网关路由配置 | 添加智赢路由 |
| 7 | 15min | 部署统一前端门户 | 替换智链门户为统一门户 |
| 8 | 10min | 修改共享底座为集成模式 | PLATFORM_MODE=integrated |
| 9 | 30min | 验证SSO+功能 | 全功能验证 |
| 10 | 15min | 数据互通配置 | 配置跨产品关联 |

> **关键**：升级过程不停机，智链已有数据完全保留。

---

# 第十二章 客户场景Playbook

## 12.1 场景一：客户只需要AI模型治理

```
客户画像: AI公司/大模型应用企业
需求: 管理多个大模型、监控AI调用、控制成本、AI安全检测
推荐: 智链独立部署 (模式A)
定价: 智链企业版 60-100万/年
部署: 4小时
```

| 销售话术 | 说明 |
|----------|------|
| 痛点切入 | "您接入多个大模型，如何统一管理？API费用如何管控？" |
| 价值主张 | "智链提供一站式AI模型治理，从接入到安全到成本全闭环" |
| 升级路径 | "未来如需数据治理，可无缝升级到双平台，无需重新部署" |

## 12.2 场景二：客户只需要数据治理

```
客户画像: 传统企业/金融机构/政府部门
需求: 数据目录、元数据管理、数据质量、数据标准、数据血缘
推荐: 智数独立部署 (模式B)
定价: 智赢企业版 80-150万/年
部署: 6小时
```

| 销售话术 | 说明 |
|----------|------|
| 痛点切入 | "数据分散各处，找不到、用不好、质量差，合规难" |
| 价值主张 | "智赢用AI赋能数据治理，让数据可见、可用、可信、可管" |
| 升级路径 | "未来接入AI应用后，可升级双平台，实现AI+数据双重治理" |

## 12.3 场景三：客户同时需要数据治理和AI治理

```
客户画像: 大型企业/银行/运营商（有AI应用+大量数据）
需求: 既要管理数据资产，又要管控AI模型
推荐: 双平台集成部署 (模式C)
定价: 双平台组合版 120-250万/年
部署: 8小时
```

| 销售话术 | 说明 |
|----------|------|
| 痛点切入 | "数据治理和AI治理割裂，数据质量问题影响AI效果，AI输出又缺乏数据治理" |
| 价值主张 | "唯一同时覆盖数据治理+AI治理的一体化平台，数据驱动AI优化，AI赋能数据治理" |
| 组合优势 | "组合购买享8折优惠，统一门户一次登录，数据互通消除信息孤岛" |
| 独特价值 | "AI应用关联数据资产可追溯，数据质量预警自动通知AI风险管控" |

## 12.4 场景四：已有智链客户升级

```
客户画像: 已购买智链的客户
触发: 客户开始建设数据治理体系
推荐: 从模式A升级到模式C
定价: 补差价+升级服务费
部署: 4小时增量升级（不停机）
```

| 升级话术 | 说明 |
|----------|------|
| 时机切入 | "您已用智链管理AI模型，是否需要将底层数据也纳入治理？" |
| 升级优势 | "无需重新部署，4小时增量升级，智链数据完整保留" |
| 升级优惠 | "老客户升级享专属折扣，组合价更优" |

## 12.5 场景五：已有智赢客户升级

```
客户画像: 已购买智赢的客户
触发: 客户开始引入大模型/AI应用
推荐: 从模式B升级到模式C
定价: 补差价+升级服务费
部署: 4小时增量升级（不停机）
```

| 升级话术 | 说明 |
|----------|------|
| 时机切入 | "您已用智赢管理数据资产，现在引入AI后如何治理AI模型？" |
| 升级优势 | "数据治理+AI治理一体化，数据质量预警联动AI风险管控" |
| 升级优惠 | "老客户升级享专属折扣" |

---

## 总结

本方案通过以下五大设计实现了"独立可售+无缝集成"的核心目标：

| 设计 | 独立模式价值 | 集成模式价值 |
|------|:---:|:---:|
| **共享底座可插拔** | 共享服务内置运行，自包含 | 共享服务只部署一份，不重复 |
| **数据库Schema分离** | 各自独立Schema，数据隔离 | 3个Schema共存，共享表统一 |
| **统一门户微前端** | 各自独立门户，独立登录 | 统一门户+SSO，一个平台感 |
| **API联邦+数据互通** | 跨产品调用自动降级 | 跨产品API互通+联邦查询 |
| **License模块化** | 单产品License，独立计价 | 组合License，模块自由组合 |

**核心结论**：客户无论购买单产品还是双产品组合，无论是首次部署还是后期升级，都能获得最优体验——**独立时是完整产品，组合时是统一平台**。
