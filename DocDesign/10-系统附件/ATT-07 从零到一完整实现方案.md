# 智赢·智链 — 从零到一完整实现方案

> **文档版本**：V1.0  
> **编制日期**：2026年7月7日  
> **文档状态**：正式发布  
> **适用场景**：从零重新开发两套产品的完整工程实现指南  

---

## 目录

- [第一章 总体设计原则与架构总览](#第一章-总体设计原则与架构总览)
- [第二章 Monorepo工程结构设计](#第二章-monorepo工程结构设计)
- [第三章 共享技术底座设计](#第三章-共享技术底座设计)
- [第四章 智链产品线实现方案](#第四章-智链产品线实现方案)
- [第五章 智赢产品线实现方案](#第五章-智赢产品线实现方案)
- [第六章 AI引擎双引擎设计](#第六章-ai引擎双引擎设计)
- [第七章 前端双门户设计](#第七章-前端双门户设计)
- [第八章 数据库设计](#第八章-数据库设计)
- [第九章 DevOps与部署方案](#第九章-devops与部署方案)
- [第十章 开发实施路线图](#第十章-开发实施路线图)
- [第十一章 团队组织与分工](#第十一章-团队组织与分工)
- [第十二章 质量保障体系](#第十二章-质量保障体系)

---

# 第一章 总体设计原则与架构总览

## 1.1 核心设计原则

| 原则 | 说明 | 实现体现 |
|------|------|----------|
| **共享底座** | 认证/权限/安全/审计/信创等通用能力抽为共享模块 | common-platform 公共模块群 |
| **独立产品线** | 智链和智赢各有独立前端门户和独有业务服务 | 两个前端App + 独有微服务 |
| **统一技术栈** | 两套产品使用相同技术栈，降低维护成本 | Vue 3 + Spring Boot 3 + 达梦DM8 |
| **API契约驱动** | 服务间通过明确定义的API契约通信 | OpenAPI 3.0 + gRPC Proto |
| **信创优先** | 从设计之初就考虑国产化适配 | 达梦/金仓/openGauss多DB + 国密SM2/SM3/SM4/SM9 + 飞腾/鲲鹏/龙芯多CPU + 麒麟/UOS/openEuler多OS，详见DES-09 |
| **渐进式交付** | 分阶段交付，每个阶段都有可运行产出 | Sprint迭代 + MVP优先 |

## 1.2 架构总览

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        统一AI数据治理平台                                 │
│                                                                         │
│  ┌─────────────────────┐          ┌─────────────────────┐              │
│  │   智链前端门户        │          │   智赢前端门户        │              │
│  │   (Vue 3 SPA)        │          │   (Vue 3 SPA)        │              │
│  │   Port: 5173         │          │   Port: 5174         │              │
│  │                      │          │                      │              │
│  │  • 模型管理           │          │  • 数据目录           │              │
│  │  • 应用管理           │          │  • 元数据管理         │              │
│  │  • AI成本管控         │          │  • 数据质量           │              │
│  │  • AI安全检测         │          │  • 数据标准           │              │
│  │  • AI合规审计         │          │  • 数据血缘           │              │
│  │  • Agent管理         │          │  • 主数据管理         │              │
│  │  • Prompt管理        │          │  • 数据服务API        │              │
│  └──────────┬──────────┘          └──────────┬──────────┘              │
│             │                                │                          │
│  ┌──────────┴────────────────────────────────┴──────────┐               │
│  │              Spring Cloud Gateway (统一网关)            │               │
│  │          Port: 9000                                   │               │
│  │  • 统一认证(SSO)  • 路由分发  • 限流熔断  • 日志       │               │
│  └──────────┬────────────────────────────────┬──────────┘               │
│             │                                │                          │
│  ┌──────────┼────────────────────────────────┼──────────┐               │
│  │          ▼          智链独有服务            ▼          │               │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐│               │
│  │  │model-svc │ │app-svc   │ │agent-svc │ │cost-svc  ││               │
│  │  │8083      │ │8084      │ │8085      │ │8086      ││               │
│  │  │模型管理   │ │应用管理   │ │Agent管理  │ │成本管控   ││               │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘│               │
│  │  ┌──────────┐ ┌──────────┐                            │               │
│  │  │risk-svc  │ │prompt-svc│                            │               │
│  │  │8087      │ │8088      │                            │               │
│  │  │风险管控   │ │Prompt管理│                            │               │
│  │  └──────────┘ └──────────┘                            │               │
│  └──────────┬────────────────────────────────┬──────────┘               │
│             │          智赢独有服务            │                          │
│  │          ▼                                ▼          │               │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐│               │
│  │  │catalog   │ │metadata  │ │quality   │ │standard  ││               │
│  │  │-svc 8091 │ │-svc 8092 │ │-svc 8093 │ │-svc 8094 ││               │
│  │  │数据目录   │ │元数据     │ │数据质量   │ │数据标准   ││               │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘│               │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐│               │
│  │  │lineage   │ │mdm-svc   │ │lifecycle │ │datasvc   ││               │
│  │  │-svc 8095 │ │8096      │ │-svc 8097 │ │-svc 8098 ││               │
│  │  │数据血缘   │ │主数据     │ │生命周期   │ │数据服务   ││               │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘│               │
│  │  ┌──────────┐                                         │               │
│  │  │asset-svc │                                         │               │
│  │  │8099      │                                         │               │
│  │  │资产评估   │                                         │               │
│  │  └──────────┘                                         │               │
│  └──────────┬───────────────────────────────────────────┘               │
│             │                                                           │
│  ┌──────────┴───────────────────────────────────────────┐               │
│  │              共享服务层（两套产品共用）                   │               │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐│               │
│  │  │auth-svc  │ │system-svc│ │security  │ │audit-svc ││               │
│  │  │8081      │ │8082      │ │-svc 8090 │ │8100      ││               │
│  │  │认证授权   │ │系统管理   │ │安全治理   │ │审计日志   ││               │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘│               │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐             │               │
│  │  │dashboard │ │notif-svc │ │config-svc│             │               │
│  │  │-svc 8101 │ │8102      │ │8103      │             │               │
│  │  │仪表盘     │ │消息通知   │ │系统配置   │             │               │
│  │  └──────────┘ └──────────┘ └──────────┘             │               │
│  └──────────┬───────────────────────────────────────────┘               │
│             │                                                           │
│  ┌──────────┴───────────────────────────────────────────┐               │
│  │              AI引擎层                                  │               │
│  │  ┌──────────────────┐    ┌──────────────────┐        │               │
│  │  │ 智链AI安全引擎     │    │ 智赢AI治理引擎     │        │               │
│  │  │ (Python FastAPI)  │    │ (Java LangChain4j)│        │               │
│  │  │ Port: 8200/8201   │    │ 内嵌于微服务       │        │               │
│  │  │ • Prompt注入检测   │    │ • 元数据AI补全     │        │               │
│  │  │ • 内容安全检测     │    │ • 数据质量AI检测   │        │               │
│  │  │ • AI输出合规检查   │    │ • 标准AI推荐       │        │               │
│  │  │ • 模型评测         │    │ • 血缘AI补全       │        │               │
│  │  └──────────────────┘    └──────────────────┘        │               │
│  └──────────┬───────────────────────────────────────────┘               │
│             │                                                           │
│  ┌──────────┴───────────────────────────────────────────┐               │
│  │              数据存储层                                 │               │
│  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌──────┐│               │
│  │  │达梦DM8 │ │ Redis  │ │MinIO   │ │ ES     │ │Neo4j ││               │
│  │  │业务数据 │ │缓存    │ │对象存储 │ │搜索引擎│ │图数据库││               │
│  │  │5236    │ │6379    │ │9000    │ │9200    │ │7687  ││               │
│  │  └────────┘ └────────┘ └────────┘ └────────┘ └──────┘│               │
│  └──────────────────────────────────────────────────────┘               │
│                                                                         │
│  ┌──────────────────────────────────────────────────────┐               │
│  │              基础设施层                                 │               │
│  │  Nacos(8848) + Docker + Nginx + Prometheus + Grafana │               │
│  └──────────────────────────────────────────────────────┘               │
└─────────────────────────────────────────────────────────────────────────┘
```

## 1.3 技术栈统一选型

| 层次 | 技术选型 | 版本 | 说明 |
|------|----------|------|------|
| **前端框架** | Vue 3 + Composition API | 3.5+ | 两套产品统一，便于团队复用 |
| **前端构建** | Vite | 6.0+ | 极速HMR，开发体验好 |
| **前端语言** | TypeScript | 5.7+ | 类型安全 |
| **前端状态** | Pinia | 3.0+ | 轻量响应式 |
| **前端路由** | Vue Router | 4.5+ | Hash模式 |
| **前端图表** | ECharts + vue-echarts | 5.6 / 7.0 | 数据可视化 |
| **前端国际化** | vue-i18n | 10.0+ | 中英双语+多语言扩展接口，详见DES-10 |
| **前端HTTP** | Axios | 1.7+ | 拦截器+Token刷新 |
| **后端框架** | Spring Boot | 3.2.5 | JDK 17 |
| **后端ORM** | MyBatis-Plus | 3.5.7 | 代码生成+分页 |
| **后端安全** | Spring Security + JWT | — | HS256签名(标准)/SM3-HMAC(信创) |
| **微服务网关** | Spring Cloud Gateway | — | 统一路由+鉴权 |
| **服务注册** | Nacos | 2.3.2 | 服务发现+配置中心 |
| **消息队列** | RocketMQ | 5.2.0 | 异步事件总线 |
| **AI安全引擎** | Python FastAPI + gRPC | 0.115+ | 智链AI检测 |
| **AI治理引擎** | Java LangChain4j | — | 智赢AI治理 |
| **数据库** | 达梦DM8(主) / 人大金仓 / openGauss / MySQL / H2(开发) | 8.1+ | 多国产DB自动适配，详见DES-09信创方案 |
| **缓存** | Redis | 7.2+ | 多级缓存 |
| **对象存储** | MinIO | latest | 文件/附件 |
| **搜索引擎** | Elasticsearch | 8.x | 数据目录搜索 |
| **图数据库** | Neo4j | 5.x | 数据血缘图谱 |
| **容器** | Docker + Docker Compose (多架构: x86_64/aarch64/loongarch64) | — | 一键部署+信创多架构 |
| **监控** | Prometheus + Grafana + Loki | — | 可观测性 |
| **CI/CD** | GitHub Actions / Jenkins | — | 自动化流水线 |

---

# 第二章 Monorepo工程结构设计

## 2.1 顶层目录结构

采用 Monorepo（单仓库多模块）方式管理两套产品的全部代码：

```
smartwin-platform/                          # 顶层仓库
│
├── platform-common/                        # 共享技术底座（Maven多模块）
│   ├── pom.xml                             # 父POM
│   ├── common-util/                        # 工具类 + 统一响应 + 导入导出
│   ├── common-db/                          # 数据库配置 + MyBatis + BaseEntity
│   ├── common-dm8/                         # 达梦DM8适配（保留向后兼容）
│   ├── common-db-multi/                    # 多国产数据库统一适配（达梦/金仓/openGauss/GBase/神通）
│   ├── common-crypto-gm/                   # 国密算法统一模块（SM2/SM3/SM4/SM9 + TLCP + HSM）
│   ├── common-xinchuang/                   # 信创环境自动探测与适配
│   ├── common-security/                    # JWT + Spring Security
│   ├── common-ai/                          # AI引擎REST/gRPC客户端
│   ├── common-mq/                          # RocketMQ消息封装
│   ├── common-storage/                     # MinIO对象存储
│   ├── common-test/                        # 测试工具 + 测试基类
│   └── common-gateway/                     # Spring Cloud Gateway配置
│
├── platform-services/                      # 共享微服务（两套产品共用）
│   ├── pom.xml
│   ├── auth-service/                       # 认证授权服务 (8081)
│   ├── system-service/                     # 用户/角色/权限/组织 (8082)
│   ├── security-service/                   # 安全治理服务 (8090)
│   ├── audit-service/                      # 审计日志服务 (8100)
│   ├── dashboard-service/                  # 仪表盘服务 (8101)
│   ├── notification-service/               # 消息通知服务 (8102)
│   └── config-service/                     # 系统配置服务 (8103)
│
├── smartchain/                             # 智链产品线
│   ├── smartchain-services/                # 智链独有微服务
│   │   ├── pom.xml
│   │   ├── model-service/                  # 模型管理 (8083)
│   │   ├── app-service/                    # 应用管理 (8084)
│   │   ├── agent-service/                  # Agent管理 (8085)
│   │   ├── cost-service/                   # 成本管控 (8086)
│   │   ├── risk-service/                   # 风险管控 (8087)
│   │   └── prompt-service/                 # Prompt管理 (8088)
│   │
│   ├── smartchain-frontend/                # 智链前端门户
│   │   ├── package.json
│   │   ├── vite.config.ts
│   │   ├── src/
│   │   │   ├── App.vue
│   │   │   ├── main.ts
│   │   │   ├── router/                     # 路由配置
│   │   │   ├── stores/                     # Pinia状态
│   │   │   ├── api/                        # API请求层
│   │   │   ├── views/                      # 页面视图
│   │   │   ├── components/                 # 组件
│   │   │   ├── composables/                # 组合式函数
│   │   │   ├── layouts/                    # 布局
│   │   │   ├── styles/                     # 样式
│   │   │   ├── i18n/                       # 国际化
│   │   │   ├── types/                      # 类型定义
│   │   │   └── utils/                      # 工具函数
│   │   └── tsconfig.json
│   │
│   └── smartchain-ai-engine/              # 智链AI安全引擎 (Python)
│       ├── pyproject.toml
│       ├── app/
│       │   ├── main.py
│       │   ├── api/                        # REST API
│       │   ├── services/                   # 业务逻辑
│       │   ├── core/                       # 配置/gRPC
│       │   └── models/                     # 数据模型
│       └── tests/
│
├── smartwin/                               # 智赢产品线
│   ├── smartwin-services/                  # 智赢独有微服务
│   │   ├── pom.xml
│   │   ├── catalog-service/                # 数据目录 (8091)
│   │   ├── metadata-service/               # 元数据管理 (8092)
│   │   ├── quality-service/                # 数据质量 (8093)
│   │   ├── standard-service/               # 数据标准 (8094)
│   │   ├── lineage-service/                # 数据血缘 (8095)
│   │   ├── mdm-service/                    # 主数据管理 (8096)
│   │   ├── lifecycle-service/              # 生命周期管理 (8097)
│   │   ├── dataservice-service/            # 数据服务 (8098)
│   │   └── asset-service/                  # 资产评估 (8099)
│   │
│   └── smartwin-frontend/                  # 智赢前端门户
│       ├── package.json
│       ├── vite.config.ts
│       ├── src/
│       │   ├── App.vue
│       │   ├── main.ts
│       │   ├── router/
│       │   ├── stores/
│       │   ├── api/
│       │   ├── views/
│       │   ├── components/
│       │   ├── composables/
│       │   ├── layouts/
│       │   ├── styles/
│       │   ├── i18n/
│       │   ├── types/
│       │   └── utils/
│       └── tsconfig.json
│
├── gateway/                                # 统一API网关
│   ├── pom.xml
│   └── src/
│
├── infra/                                  # 基础设施
│   ├── docker/                             # Docker配置
│   │   ├── docker-compose.yml              # 全量部署
│   │   ├── docker-compose.dev.yml          # 开发环境
│   │   ├── docker-compose.lite.yml         # 精简版
│   │   ├── Dockerfile.java
│   │   ├── Dockerfile.frontend
│   │   ├── Dockerfile.ai-engine
│   │   ├── nginx.conf                      # Nginx配置
│   │   ├── prometheus/
│   │   ├── grafana/
│   │   └── loki/
│   ├── scripts/                            # 脚本
│   │   ├── init-database.sh                # 数据库初始化
│   │   ├── init-redis.sh                   # Redis初始化
│   │   ├── seed-data.sh                    # 种子数据
│   │   └── start-all.sh                    # 一键启动
│   └── sql/                                # SQL脚本
│       ├── platform-schema.sql             # 共享底座表结构
│       ├── smartchain-schema.sql           # 智链表结构
│       └── smartwin-schema.sql             # 智赢表结构
│
├── docs/                                   # 文档
│   ├── architecture/                       # 架构文档
│   ├── api/                                # API文档
│   ├── deployment/                         # 部署文档
│   └── development/                        # 开发指南
│
├── pom.xml                                 # 根POM（聚合所有模块）
├── package.json                            # 根package.json（workspace）
├── docker-compose.yml                      # 顶层编排
├── Makefile                                # 常用命令快捷方式
├── .gitignore
└── README.md
```

## 2.2 Maven模块依赖关系

```
根POM (smartwin-platform)
├── platform-common (共享公共模块)
│   ├── common-util        ← 所有模块依赖
│   ├── common-db          ← 所有服务依赖
│   ├── common-dm8         ← 生产环境依赖
│   ├── common-security    ← auth/system/所有需认证服务
│   ├── common-ai          ← 需调用AI引擎的服务
│   ├── common-mq          ← 需消息队列的服务
│   ├── common-storage     ← 需文件存储的服务
│   └── common-test        ← 所有测试模块
│
├── platform-services (共享微服务)
│   ├── auth-service       → common-security, common-db, common-util
│   ├── system-service     → common-security, common-db, common-util
│   ├── security-service   → common-security, common-db, common-util
│   ├── audit-service      → common-security, common-db, common-util
│   ├── dashboard-service  → common-security, common-db, common-util
│   ├── notification-service → common-mq, common-db, common-util
│   └── config-service     → common-db, common-util
│
├── smartchain/smartchain-services (智链独有)
│   ├── model-service      → common-ai, common-security, common-db
│   ├── app-service        → common-security, common-db
│   ├── agent-service      → common-ai, common-security, common-db
│   ├── cost-service       → common-db, common-util
│   ├── risk-service       → common-db, common-util
│   └── prompt-service     → common-ai, common-db
│
├── smartwin/smartwin-services (智赢独有)
│   ├── catalog-service    → common-db, common-util
│   ├── metadata-service   → common-db, common-util
│   ├── quality-service    → common-db, common-util
│   ├── standard-service   → common-db, common-util
│   ├── lineage-service    → common-db, common-util
│   ├── mdm-service        → common-db, common-util
│   ├── lifecycle-service  → common-db, common-util
│   ├── dataservice-service→ common-security, common-db
│   └── asset-service      → common-db, common-util
│
└── gateway                → common-security, Spring Cloud Gateway
```

## 2.3 根POM设计

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.smartwin</groupId>
    <artifactId>smartwin-platform</artifactId>
    <version>1.0.0-SNAPSHOT</version>
    <packaging>pom</packaging>
    <name>SmartWin AI Data Governance Platform</name>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.5</version>
    </parent>

    <properties>
        <java.version>17</java.version>
        <mybatis-plus.version>3.5.7</mybatis-plus.version>
        <jjwt.version>0.12.5</jjwt.version>
        <hutool.version>5.8.28</hutool.version>
        <knife4j.version>4.5.0</knife4j.version>
        <bouncycastle.version>1.78.1</bouncycastle.version>
        <rocketmq.version>2.3.6</rocketmq.version>
        <elasticsearch.version>8.13.0</elasticsearch.version>
        <neo4j.version>5.20.0</neo4j.version>
        <langchain4j.version>0.34.0</langchain4j.version>
    </properties>

    <modules>
        <module>platform-common</module>
        <module>platform-services</module>
        <module>smartchain/smartchain-services</module>
        <module>smartwin/smartwin-services</module>
        <module>gateway</module>
    </modules>

    <!-- dependencyManagement 统一版本管理 -->
</project>
```

## 2.4 前端Workspace设计

```json
// 根 package.json
{
  "name": "smartwin-platform",
  "private": true,
  "workspaces": [
    "smartchain/smartchain-frontend",
    "smartwin/smartwin-frontend"
  ],
  "scripts": {
    "dev:smartchain": "npm -w smartchain-frontend dev",
    "dev:smartdata": "npm -w smartwin-frontend dev",
    "build:smartchain": "npm -w smartchain-frontend build",
    "build:smartwin": "npm -w smartwin-frontend build",
    "build:all": "npm run build:smartchain && npm run build:smartwin"
  }
}
```

---

# 第三章 共享技术底座设计

共享技术底座是两套产品的公共能力层，包含7个公共模块和7个共享微服务，一次开发、两套产品复用。

## 3.1 共享公共模块设计（platform-common）

### 3.1.1 common-util — 通用工具模块

```
common-util/
└── src/main/java/com/smartwin/common/util/
    ├── response/                     # 统一响应
    │   ├── ApiResponse.java          # 统一响应体 {code, message, data}
    │   ├── PageResult.java           # 分页结果 {records, total, page, size}
    │   └── ResultCode.java           # 响应码枚举
    ├── exception/                    # 统一异常
    │   ├── BusinessException.java    # 业务异常
    │   ├── SystemException.java      # 系统异常
    │   └── GlobalExceptionHandler.java # 全局异常处理器
    ├── entity/                       # 基础实体
    │   └── BaseEntity.java           # 基类(id, createTime, updateTime, createBy, updateBy, deleted)
    ├── utils/                        # 工具类
    │   ├── DateUtils.java            # 日期工具
    │   ├── StringUtils.java          # 字符串工具
    │   ├── CryptoUtils.java          # 加密工具(AES/SM4)
    │   ├── JsonUtils.java            # JSON工具
    │   └── TreeUtils.java            # 树形结构工具
    ├── export/                       # 导入导出
    │   ├── CsvExporter.java          # CSV导出
    │   ├── ExcelExporter.java        # Excel导出(POI)
    │   └── ExcelImporter.java        # Excel导入
    └── constant/                     # 常量
        ├── CommonConstants.java      # 通用常量
        └── RegexConstants.java       # 正则常量
```

### 3.1.2 common-db — 数据库配置模块

```java
// common-db 核心配置
@Configuration
@MapperScan("com.smartwin.**.mapper")
public class MyBatisPlusConfig {

    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor() {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
        // 分页插件
        interceptor.addInnerInterceptor(
            new PaginationInnerInterceptor(DbType.MYSQL));
        // 乐观锁插件
        interceptor.addInnerInterceptor(new OptimisticLockerInnerInterceptor());
        return interceptor;
    }

    @Bean
    public MetaObjectHandler metaObjectHandler() {
        return new MetaObjectHandler() {
            @Override
            public void insertFill(MetaObject metaObject) {
                this.strictInsertFill(metaObject, "createTime",
                    LocalDateTime.class, LocalDateTime.now());
                this.strictInsertFill(metaObject, "updateTime",
                    LocalDateTime.class, LocalDateTime.now());
            }
            @Override
            public void updateFill(MetaObject metaObject) {
                this.strictUpdateFill(metaObject, "updateTime",
                    LocalDateTime.class, LocalDateTime.now());
            }
        };
    }
}
```

### 3.1.3 common-dm8 — 达梦适配模块（保留向后兼容）

```
common-dm8/
└── src/main/java/com/smartwin/common/dm8/
    ├── config/
    │   └── Dm8DataSourceConfig.java    # 达梦数据源配置
    ├── dialect/
    │   └── Dm8Dialect.java             # 达梦SQL方言适配
    └── handler/
        └── Dm8TypeHandler.java          # 达梦类型处理器
```

### 3.1.3a common-db-multi — 多国产数据库统一适配模块

> 详见 **DES-09《SmartWin智赢平台信创全栈适配与国密算法设计方案》** 第三章

```
common-db-multi/
└── src/main/java/com/smartwin/common/db/multi/
    ├── dialect/
    │   ├── DatabaseDialect.java           # 方言抽象接口
    │   ├── Dm8Dialect.java                # 达梦方言
    │   ├── KingbaseDialect.java           # 人大金仓方言
    │   ├── OpenGaussDialect.java          # openGauss方言
    │   ├── GBaseDialect.java              # 南大通用方言 [P1]
    │   └── ShenTongDialect.java           # 神通方言 [P1]
    ├── detector/
    │   └── DatabaseTypeDetector.java      # JDBC自动探测数据库类型
    ├── router/
    │   └── DialectRouter.java             # 方言路由工厂
    ├── config/
    │   └── MybatisPlusMultiDbConfig.java  # ORM多DB自动配置
    ├── handler/
    │   └── JsonTypeHandler.java           # JSON字段跨库兼容处理器
    └── migration/
        └── FlywayMultiDbConfig.java       # Flyway多库迁移配置
```

### 3.1.3b common-crypto-gm — 国密算法统一模块

> 详见 **DES-09《SmartWin智赢平台信创全栈适配与国密算法设计方案》** 第四章

```
common-crypto-gm/
└── src/main/java/com/smartwin/common/crypto/gm/
    ├── api/
    │   ├── CryptoService.java              # 密码服务统一接口(软件/HSM透明切换)
    │   └── CryptoAlgorithm.java            # 算法枚举(SM2/SM3/SM4/SM9)
    ├── sm2/
    │   ├── SM2CryptoUtil.java              # SM2非对称加密(替代RSA)
    │   ├── SM2SignUtil.java                # SM2签名验签(SM3withSM2)
    │   └── GMCertificateManager.java       # 国密X.509证书管理
    ├── sm3/
    │   └── SM3HashUtil.java                # SM3杂凑算法(替代SHA-256)
    ├── sm4/
    │   └── SM4CryptoUtil.java              # SM4对称加密(替代AES)
    ├── sm9/
    │   └── SM9CryptoUtil.java              # SM9标识密码 [P1]
    ├── impl/
    │   ├── SoftwareCryptoService.java      # 软件实现(BouncyCastle)
    │   └── HsmCryptoService.java           # HSM硬件密码机实现 [P1]
    ├── cert/
    │   └── GMCertGenerator.java            # 国密TLCP双证书生成
    └── config/
        └── CryptoAutoConfiguration.java    # 标准/国密自动切换配置
```

### 3.1.4 common-security — 安全认证模块

```
common-security/
└── src/main/java/com/smartwin/common/security/
    ├── config/
    │   ├── SecurityConfig.java          # Spring Security配置
    │   └── JwtConfig.java               # JWT配置
    ├── filter/
    │   ├── JwtAuthenticationFilter.java # JWT认证过滤器
    │   └── JwtAuthorizationFilter.java  # JWT授权过滤器
    ├── handler/
    │   ├── AuthenticationEntryPoint.java # 401处理器
    │   └── AccessDeniedHandler.java      # 403处理器
    ├── jwt/
    │   ├── JwtTokenProvider.java         # Token生成/验证
    │   └── JwtTokenStore.java            # Token存储(Redis)
    ├── context/
    │   ├── SecurityContextHolder.java    # 当前用户上下文
    │   └── UserContext.java              # 用户信息载体
    └── annotation/
        ├── @RequiresPermission.java      # 权限注解
        └── @RequiresRole.java            # 角色注解
```

### 3.1.5 common-ai — AI引擎客户端模块

```
common-ai/
└── src/main/java/com/smartwin/common/ai/
    ├── client/
    │   ├── AiSecurityClient.java         # 智链AI安全引擎客户端
    │   ├── AiGovernanceClient.java       # 智赢AI治理引擎客户端
    │   └── ModelProxyClient.java         # 大模型代理客户端
    ├── config/
    │   └── AiEngineConfig.java           # AI引擎配置
    └── dto/
        ├── DetectionRequest.java         # 检测请求
        ├── DetectionResponse.java        # 检测响应
        └── EvaluationRequest.java        # 评测请求
```

### 3.1.6 common-mq — 消息队列模块

```
common-mq/
└── src/main/java/com/smartwin/common/mq/
    ├── producer/
    │   └── MessageProducer.java          # 消息生产者
    ├── consumer/
    │   └── MessageConsumer.java          # 消息消费者基类
    ├── topic/
    │   ├── AuditTopic.java               # 审计事件Topic
    │   ├── AlertTopic.java               # 告警事件Topic
    │   └── DataEventTopic.java           # 数据事件Topic
    └── config/
        └── RocketMQConfig.java           # RocketMQ配置
```

### 3.1.7 common-storage — 对象存储模块

```
common-storage/
└── src/main/java/com/smartwin/common/storage/
    ├── service/
    │   ├── FileStorageService.java       # 文件存储接口
    │   └── MinioStorageService.java      # MinIO实现
    ├── config/
    │   └── MinioConfig.java              # MinIO配置
    └── dto/
        ├── UploadResult.java             # 上传结果
        └── FileInfo.java                 # 文件信息
```

## 3.2 共享微服务设计（platform-services）

### 3.2.1 auth-service — 认证授权服务（8081）

| API | 方法 | 路径 | 说明 |
|-----|:----:|------|------|
| 登录 | POST | /api/auth/login | 账号密码登录 |
| 登出 | POST | /api/auth/logout | 登出 |
| 刷新Token | POST | /api/auth/refresh | 刷新JWT |
| 获取验证码 | GET | /api/auth/captcha | 获取图形验证码 |
| 社交登录 | POST | /api/auth/oauth/{provider} | 企微/钉钉/飞书/LDAP |
| 获取当前用户 | GET | /api/auth/me | 获取当前登录用户信息 |

```java
// auth-service 核心结构
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @PostMapping("/login")
    public ApiResponse<LoginResponse> login(@RequestBody LoginRequest request) {
        // 1. 验证验证码
        // 2. 根据用户名查询用户
        // 3. BCrypt密码校验
        // 4. 生成JWT Token (Access + Refresh)
        // 5. 存储Token到Redis
        // 6. 返回Token和用户信息
    }

    @PostMapping("/refresh")
    public ApiResponse<TokenResponse> refresh(@RequestBody RefreshRequest request) {
        // 1. 验证Refresh Token
        // 2. 生成新的Access Token
        // 3. 返回新Token
    }
}
```

### 3.2.2 system-service — 系统管理服务（8082）

| 功能模块 | API路径 | 说明 |
|----------|---------|------|
| 用户管理 | /api/system/users | CRUD + 批量导入导出 |
| 角色管理 | /api/system/roles | CRUD + 权限分配 |
| 权限管理 | /api/system/permissions | 权限树 + 权限点 |
| 组织管理 | /api/system/orgs | 组织树 + 部门管理 |
| 菜单管理 | /api/system/menus | 菜单树 + 路由配置 |

### 3.2.3 security-service — 安全治理服务（8090）

| 功能模块 | API路径 | 说明 |
|----------|---------|------|
| 数据分类分级 | /api/security/classify | 分级分类规则 + 结果 |
| 数据脱敏 | /api/security/masking | 脱敏规则 + 预览 |
| 数据水印 | /api/security/watermark | 水印策略 + 模板 |
| 泄露防护 | /api/security/leak | 防护规则 + 事件 |
| 密钥管理 | /api/security/keys | 密钥CRUD + 轮换 |
| 国密工具 | /api/security/crypto | SM2/SM3/SM4加解密 |

### 3.2.4 audit-service — 审计日志服务（8100）

| 功能模块 | API路径 | 说明 |
|----------|---------|------|
| 操作审计 | /api/audit/operations | 全量操作日志 |
| 数据审计 | /api/audit/data | 数据访问/修改日志 |
| 合规审计 | /api/audit/compliance | 合规规则 + 检查 |
| 监管报表 | /api/audit/reports | 报表生成 + 导出 |
| 合规预警 | /api/audit/alerts | 预警事件管理 |

### 3.2.5 共享服务数据库表设计

```sql
-- ============ 认证授权表 ============
CREATE TABLE sys_user (
    id BIGINT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,          -- BCrypt加密
    real_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20),
    avatar VARCHAR(500),
    status TINYINT DEFAULT 1,                -- 1启用 0禁用
    org_id BIGINT,
    last_login_time TIMESTAMP,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    create_by BIGINT,
    update_by BIGINT,
    deleted TINYINT DEFAULT 0
);

CREATE TABLE sys_role (
    id BIGINT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL,
    role_code VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(200),
    status TINYINT DEFAULT 1,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0
);

CREATE TABLE sys_permission (
    id BIGINT PRIMARY KEY,
    parent_id BIGINT DEFAULT 0,
    perm_name VARCHAR(50) NOT NULL,
    perm_code VARCHAR(100) NOT NULL UNIQUE,
    perm_type TINYINT,                       -- 1菜单 2按钮 3API
    path VARCHAR(200),
    component VARCHAR(200),
    icon VARCHAR(50),
    sort_order INT DEFAULT 0,
    status TINYINT DEFAULT 1
);

CREATE TABLE sys_user_role (
    user_id BIGINT,
    role_id BIGINT,
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE sys_role_permission (
    role_id BIGINT,
    permission_id BIGINT,
    PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE sys_org (
    id BIGINT PRIMARY KEY,
    parent_id BIGINT DEFAULT 0,
    org_name VARCHAR(100) NOT NULL,
    org_code VARCHAR(50) NOT NULL UNIQUE,
    org_type TINYINT,                        -- 1公司 2部门 3小组
    sort_order INT DEFAULT 0,
    status TINYINT DEFAULT 1
);

-- ============ 安全治理表 ============
CREATE TABLE sec_classification (
    id BIGINT PRIMARY KEY,
    data_name VARCHAR(200) NOT NULL,
    data_source VARCHAR(100),
    security_level TINYINT NOT NULL,          -- 1公开 2内部 3机密 4绝密
    classify_rule VARCHAR(500),
    status TINYINT DEFAULT 1,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sec_masking_rule (
    id BIGINT PRIMARY KEY,
    rule_name VARCHAR(100) NOT NULL,
    field_type VARCHAR(50),                   -- 身份证/手机号/银行卡/地址/自定义
    mask_pattern VARCHAR(200),                -- 脱敏规则正则
    mask_replacement VARCHAR(50),             -- 替换字符
    status TINYINT DEFAULT 1
);

CREATE TABLE sec_watermark_policy (
    id BIGINT PRIMARY KEY,
    policy_name VARCHAR(100) NOT NULL,
    watermark_type TINYINT,                   -- 1文本水印 2图片水印
    content_template VARCHAR(500),            -- 模板变量 {platform}/{user}/{date}
    opacity DECIMAL(3,2) DEFAULT 0.10,
    status TINYINT DEFAULT 1
);

-- ============ 审计日志表 ============
CREATE TABLE audit_operation_log (
    id BIGINT PRIMARY KEY,
    user_id BIGINT,
    username VARCHAR(50),
    operation VARCHAR(200),                   -- 操作描述
    module VARCHAR(50),                       -- 功能模块
    method VARCHAR(10),                       -- GET/POST/PUT/DELETE
    request_url VARCHAR(500),
    request_params TEXT,
    response_status INT,
    ip_address VARCHAR(50),
    user_agent VARCHAR(500),
    execution_time BIGINT,                    -- 执行时长(ms)
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user (user_id),
    INDEX idx_time (operation_time),
    INDEX idx_module (module)
);

CREATE TABLE audit_compliance_rule (
    id BIGINT PRIMARY KEY,
    rule_name VARCHAR(200) NOT NULL,
    regulation VARCHAR(100),                  -- 法规名称
    rule_content TEXT,                        -- 规则内容
    check_type VARCHAR(50),                   -- 检查类型
    severity TINYINT,                         -- 严重级别
    status TINYINT DEFAULT 1
);

CREATE TABLE audit_alert (
    id BIGINT PRIMARY KEY,
    alert_type VARCHAR(50),
    alert_level TINYINT,                      -- 1低 2中 3高 4紧急
    alert_content TEXT,
    source VARCHAR(100),
    status TINYINT DEFAULT 0,                 -- 0未处理 1已处理 2已忽略
    handle_time TIMESTAMP,
    handler VARCHAR(50),
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

# 第四章 智链产品线实现方案

智链是AI模型治理与监控平台，治理对象是AI模型、AI应用、AI调用过程。本章定义智链6个独有微服务、前端页面和AI安全引擎的完整实现。

## 4.1 智链独有微服务设计

### 4.1.1 model-service — 模型管理服务（8083）

| API | 方法 | 路径 | 说明 |
|-----|:----:|------|------|
| 模型列表 | GET | /api/smartchain/models | 分页查询模型列表 |
| 模型详情 | GET | /api/smartchain/models/{id} | 模型详情 |
| 接入模型 | POST | /api/smartchain/models | 接入新模型 |
| 更新模型 | PUT | /api/smartchain/models/{id} | 更新模型配置 |
| 删除模型 | DELETE | /api/smartchain/models/{id} | 删除模型 |
| 模型版本管理 | GET/POST | /api/smartchain/models/{id}/versions | 版本CRUD |
| 模型评测 | POST | /api/smartchain/models/{id}/evaluate | 发起评测 |
| 模型监控 | GET | /api/smartchain/models/{id}/monitor | 监控数据 |
| API密钥管理 | CRUD | /api/smartchain/models/keys | 密钥CRUD |
| 模型对比 | POST | /api/smartchain/models/compare | 多模型对比 |

```sql
-- 智链模型管理表
CREATE TABLE ic_model (
    id BIGINT PRIMARY KEY,
    model_name VARCHAR(100) NOT NULL,
    model_type VARCHAR(50),                   -- LLM/image/voice/video/multimodal
    provider VARCHAR(50),                     -- OpenAI/Qwen/Ernie/DeepSeek/Claude
    api_endpoint VARCHAR(500),
    api_key_id BIGINT,                        -- 关联密钥
    version VARCHAR(50),
    status TINYINT DEFAULT 1,                 -- 1在线 2离线 3异常 4维护
    description VARCHAR(500),
    max_tokens INT,
    temperature DECIMAL(3,2),
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0
);

CREATE TABLE ic_model_version (
    id BIGINT PRIMARY KEY,
    model_id BIGINT NOT NULL,
    version_number VARCHAR(50) NOT NULL,
    changelog TEXT,
    status TINYINT DEFAULT 1,                 -- 1当前 2活跃 3废弃
    config_json TEXT,                         -- 模型参数配置JSON
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ic_model_apikey (
    id BIGINT PRIMARY KEY,
    key_name VARCHAR(100) NOT NULL,
    api_key VARCHAR(255) NOT NULL,            -- 加密存储
    model_id BIGINT,
    permissions VARCHAR(500),                 -- 权限范围
    daily_limit BIGINT,                       -- 日调用上限
    total_calls BIGINT DEFAULT 0,
    total_tokens BIGINT DEFAULT 0,
    status TINYINT DEFAULT 1,
    expire_time TIMESTAMP,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ic_model_evaluation (
    id BIGINT PRIMARY KEY,
    model_id BIGINT NOT NULL,
    eval_type VARCHAR(50),                    -- accuracy/robustness/fairness/safety/efficiency
    eval_score DECIMAL(5,2),
    eval_detail TEXT,                         -- 详细评测结果JSON
    eval_report_url VARCHAR(500),
    evaluator VARCHAR(50),
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 4.1.2 app-service — 应用管理服务（8084）

```sql
CREATE TABLE ic_app (
    id BIGINT PRIMARY KEY,
    app_name VARCHAR(100) NOT NULL,
    app_type VARCHAR(50),                     -- chatbot/RAG/agent/copilot/custom
    description VARCHAR(500),
    department VARCHAR(100),
    owner VARCHAR(50),
    model_ids VARCHAR(500),                   -- 关联模型ID列表
    status TINYINT DEFAULT 1,                 -- 1运行中 2异常 3已下线 4审批中
    risk_level TINYINT DEFAULT 1,             -- 1低 2中 3高
    api_endpoint VARCHAR(500),
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0
);

CREATE TABLE ic_app_permission (
    id BIGINT PRIMARY KEY,
    app_id BIGINT NOT NULL,
    user_id BIGINT,
    permission_type TINYINT,                  -- 1管理员 2开发者 3使用者 4只读
    granted_by VARCHAR(50),
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ic_app_offline_request (
    id BIGINT PRIMARY KEY,
    app_id BIGINT NOT NULL,
    applicant VARCHAR(50),
    reason VARCHAR(500),
    status TINYINT DEFAULT 0,                 -- 0待审批 1已批准 2已拒绝 3已完成
    approver VARCHAR(50),
    approve_time TIMESTAMP,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 4.1.3 agent-service — AI Agent管理服务（8085）

```sql
CREATE TABLE ic_agent (
    id BIGINT PRIMARY KEY,
    agent_name VARCHAR(100) NOT NULL,
    description VARCHAR(500),
    agent_type VARCHAR(50),                   -- assistant/automation/analysis/custom
    model_id BIGINT,
    prompt_template TEXT,                     -- 系统提示词
    tools VARCHAR(500),                       -- 可用工具列表
    status TINYINT DEFAULT 1,
    config_json TEXT,                         -- Agent配置JSON
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0
);

CREATE TABLE ic_prompt (
    id BIGINT PRIMARY KEY,
    prompt_name VARCHAR(100) NOT NULL,
    model_id BIGINT,
    category VARCHAR(50),
    content TEXT NOT NULL,                    -- Prompt内容
    variables VARCHAR(500),                   -- 变量列表
    tags VARCHAR(200),
    version VARCHAR(50) DEFAULT '1.0',
    test_result TEXT,                         -- 测试结果
    status TINYINT DEFAULT 1,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 4.1.4 cost-service — 成本管控服务（8086）

```sql
CREATE TABLE ic_cost_budget (
    id BIGINT PRIMARY KEY,
    budget_name VARCHAR(100) NOT NULL,
    fiscal_year INT,
    total_amount DECIMAL(12,2) NOT NULL,
    allocated_amount DECIMAL(12,2) DEFAULT 0,
    used_amount DECIMAL(12,2) DEFAULT 0,
    department VARCHAR(100),
    status TINYINT DEFAULT 1,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ic_cost_allocation (
    id BIGINT PRIMARY KEY,
    budget_id BIGINT,
    department VARCHAR(100),
    allocated_amount DECIMAL(12,2),
    used_amount DECIMAL(12,2) DEFAULT 0,
    ratio DECIMAL(5,2)
);

CREATE TABLE ic_cost_record (
    id BIGINT PRIMARY KEY,
    model_id BIGINT,
    app_id BIGINT,
    user_id BIGINT,
    call_time TIMESTAMP,
    input_tokens INT,
    output_tokens INT,
    total_tokens INT,
    cost_amount DECIMAL(10,4),
    department VARCHAR(100),
    INDEX idx_model (model_id),
    INDEX idx_time (call_time)
);

CREATE TABLE ic_cost_optimization (
    id BIGINT PRIMARY KEY,
    optimization_type VARCHAR(50),            -- model_switch/cache/rate_limit/batch
    description VARCHAR(500),
    potential_saving DECIMAL(10,2),
    status TINYINT DEFAULT 0,                 -- 0建议 1采纳 2已实施
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 4.1.5 risk-service — 风险管控服务（8087）

```sql
CREATE TABLE ic_risk_event (
    id BIGINT PRIMARY KEY,
    event_type VARCHAR(50),                   -- prompt_injection/data_leak/content_violation/model_attack
    risk_level TINYINT NOT NULL,              -- 1低 2中 3高 4紧急
    source VARCHAR(100),
    description TEXT,
    model_id BIGINT,
    app_id BIGINT,
    detection_result TEXT,                    -- 检测结果JSON
    status TINYINT DEFAULT 0,                 -- 0未处理 1处理中 2已处理 3已忽略
    handler VARCHAR(50),
    handle_time TIMESTAMP,
    handle_result TEXT,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_level (risk_level),
    INDEX idx_status (status)
);
```

### 4.1.6 prompt-service — Prompt管理服务（8088）

```sql
CREATE TABLE ic_prompt_template (
    id BIGINT PRIMARY KEY,
    template_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    content TEXT NOT NULL,
    variables TEXT,                           -- JSON格式的变量定义
    industry VARCHAR(50),                     -- 适用行业
    description VARCHAR(500),
    usage_count INT DEFAULT 0,
    rating DECIMAL(3,2) DEFAULT 0,
    status TINYINT DEFAULT 1,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 4.2 智链前端页面规划

| 模块 | 页面数 | 核心页面 |
|------|:------:|----------|
| 登录认证 | 2 | 登录、忘记密码 |
| 数据驾驶舱 | 1 | 总览仪表盘 |
| 运维监控 | 3 | 运维监控、监控告警、异常列表 |
| 模型管理 | 9 | 总览/接入/监控/版本/评测/配置/API密钥/导入/导出 |
| 应用管理 | 6 | 列表/注册/详情/监控/权限/下线 |
| Agent管理 | 5 | Agent列表/新建/Prompt管理/Prompt新建/模板 |
| 安全治理 | 9 | 概览/AI检测/批量检测/隐私/分类/脱敏/水印/溯源/泄露 |
| 国密加密 | 2 | 加密工具箱/密钥管理 |
| 风险监控 | 5 | 风险事件/合规规则/告警/报告/监管报告 |
| 成本预算 | 10 | 总览/分摊/优化/报告/费用/Token/预算×4 |
| 审计日志 | 5 | 全面审计/审计/系统日志/操作日志/导出 |
| 系统管理 | 4 | 个人中心/消息/帮助/系统配置 |
| **总计** | **61** | |

## 4.3 智链AI安全引擎设计

```python
# smartchain-ai-engine/app/main.py
from fastapi import FastAPI
from app.api import detection, evaluation, governance, proxy, security, stream

app = FastAPI(title="SmartChain AI Security Engine")

# REST API路由
app.include_router(detection.router, prefix="/api/detection", tags=["检测"])
app.include_router(evaluation.router, prefix="/api/evaluation", tags=["评测"])
app.include_router(governance.router, prefix="/api/governance", tags=["治理"])
app.include_router(proxy.router, prefix="/api/proxy", tags=["代理"])
app.include_router(security.router, prefix="/api/security", tags=["安全"])
app.include_router(stream.router, prefix="/api/stream", tags=["流式"])

@app.get("/health")
async def health():
    return {"status": "healthy"}
```

```python
# app/services/detection.py — AI安全检测核心
class DetectionService:
    """AI安全检测引擎"""

    async def detect_prompt_injection(self, prompt: str) -> dict:
        """Prompt注入检测"""
        # 1. 规则匹配（SQL注入/命令注入/角色越狱模式）
        # 2. 语义分析（调用大模型判断意图）
        # 3. 返回检测结果 {is_injected, confidence, pattern_matched, risk_level}

    async def detect_content_safety(self, content: str) -> dict:
        """内容安全检测"""
        # 1. 敏感词过滤
        # 2. 暴力/色情/政治内容检测
        # 3. 返回 {is_safe, categories, confidence}

    async def detect_data_leak(self, output: str, context: str) -> dict:
        """数据泄露检测"""
        # 1. PII检测（身份证/手机号/邮箱/银行卡）
        # 2. 敏感数据模式匹配
        # 3. 上下文关联分析
        # 4. 返回 {has_leak, leak_types, positions, risk_level}

    async def evaluate_model(self, model_id: str, eval_config: dict) -> dict:
        """模型评测"""
        # 1. 准确性评测
        # 2. 鲁棒性评测
        # 3. 公平性评测
        # 4. 安全性评测
        # 5. 效率评测
        # 6. 返回综合评分和详细报告
```

---

# 第五章 智赢产品线实现方案

智数是AI原生数据治理平台，治理对象是数据资产、数据质量、数据标准。本章定义智数9个独有微服务、前端页面和AI治理引擎的完整实现。

## 5.1 智赢独有微服务设计

### 5.1.1 catalog-service — 数据目录服务（8091）

| API | 方法 | 路径 | 说明 |
|-----|:----:|------|------|
| 数据资产列表 | GET | /api/smartwin/catalog | 分页查询数据资产 |
| 数据资产详情 | GET | /api/smartwin/catalog/{id} | 资产详情 |
| 注册数据资产 | POST | /api/smartwin/catalog | 注册新资产 |
| AI智能搜索 | GET | /api/smartwin/catalog/search | 自然语言搜索数据 |
| 数据问答 | POST | /api/smartwin/catalog/ask | 自然语言问答 |
| 自动扫描 | POST | /api/smartwin/catalog/scan | 自动扫描数据源 |
| 资产收藏 | POST | /api/smartwin/catalog/{id}/favorite | 收藏资产 |
| 资产评价 | POST | /api/smartwin/catalog/{id}/rate | 评分评价 |

```sql
CREATE TABLE sw_data_catalog (
    id BIGINT PRIMARY KEY,
    asset_name VARCHAR(200) NOT NULL,
    asset_type VARCHAR(50),                   -- table/api/file/stream/metric
    source_system VARCHAR(100),
    source_database VARCHAR(100),
    source_table VARCHAR(200),
    description TEXT,
    owner VARCHAR(50),
    owner_dept VARCHAR(100),
    security_level TINYINT DEFAULT 2,
    tags VARCHAR(500),
    business_domain VARCHAR(100),
    quality_score DECIMAL(3,1) DEFAULT 0,
    popularity INT DEFAULT 0,                  -- 热度
    status TINYINT DEFAULT 1,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted TINYINT DEFAULT 0,
    INDEX idx_name (asset_name),
    INDEX idx_source (source_system)
);

CREATE TABLE sw_data_catalog_tag (
    id BIGINT PRIMARY KEY,
    tag_name VARCHAR(50) NOT NULL UNIQUE,
    tag_category VARCHAR(50),
    description VARCHAR(200),
    color VARCHAR(20)
);

CREATE TABLE sw_data_catalog_favorite (
    user_id BIGINT,
    catalog_id BIGINT,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, catalog_id)
);
```

### 5.1.2 metadata-service — 元数据管理服务（8092）

```sql
CREATE TABLE sw_technical_metadata (
    id BIGINT PRIMARY KEY,
    catalog_id BIGINT,
    database_type VARCHAR(50),                 -- MySQL/DM8/PostgreSQL/Oracle
    database_name VARCHAR(100),
    table_name VARCHAR(200),
    column_name VARCHAR(200),
    data_type VARCHAR(50),
    column_length INT,
    column_precision INT,
    is_nullable TINYINT,
    is_primary_key TINYINT DEFAULT 0,
    default_value VARCHAR(200),
    column_comment VARCHAR(500),
    last_sync_time TIMESTAMP
);

CREATE TABLE sw_business_metadata (
    id BIGINT PRIMARY KEY,
    catalog_id BIGINT,
    business_name VARCHAR(200),                -- 业务名称
    business_definition TEXT,                  -- 业务定义
    business_domain VARCHAR(100),              -- 业务域
    data_steward VARCHAR(50),                  -- 数据管家
    business_rules TEXT,                       -- 业务规则
    synonyms VARCHAR(500)                      -- 同义词
);

CREATE TABLE sw_operational_metadata (
    id BIGINT PRIMARY KEY,
    catalog_id BIGINT,
    last_access_time TIMESTAMP,
    access_count BIGINT DEFAULT 0,
    avg_query_time BIGINT,                     -- 平均查询时长(ms)
    data_volume BIGINT,                        -- 数据量(行)
    storage_size BIGINT,                       -- 存储大小(bytes)
    last_update_time TIMESTAMP,
    update_frequency VARCHAR(50)               -- 实时/小时/日/周/月
);
```

### 5.1.3 quality-service — 数据质量管理服务（8093）

```sql
CREATE TABLE sw_quality_rule (
    id BIGINT PRIMARY KEY,
    rule_name VARCHAR(200) NOT NULL,
    rule_type VARCHAR(50),                     -- completeness/accuracy/consistency/timeliness/uniqueness/validity
    rule_expression TEXT NOT NULL,             -- 规则表达式SQL
    target_catalog_id BIGINT,                  -- 目标数据资产
    target_column VARCHAR(200),
    threshold DECIMAL(5,2) DEFAULT 100.00,     -- 合格阈值(%)
    severity TINYINT DEFAULT 2,                -- 1提示 2警告 3错误
    schedule VARCHAR(50),                      -- 调度周期 cron
    status TINYINT DEFAULT 1,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sw_quality_task (
    id BIGINT PRIMARY KEY,
    rule_id BIGINT NOT NULL,
    task_status TINYINT,                       -- 0待执行 1执行中 2成功 3失败
    total_count BIGINT,                        -- 检查总记录数
    error_count BIGINT,                        -- 错误记录数
    pass_rate DECIMAL(5,2),                    -- 通过率
    score DECIMAL(3,1),                        -- 质量评分
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    error_sample TEXT,                         -- 错误样本JSON
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sw_quality_report (
    id BIGINT PRIMARY KEY,
    report_name VARCHAR(200),
    report_period VARCHAR(20),                 -- daily/weekly/monthly
    overall_score DECIMAL(3,1),
    dimension_scores TEXT,                     -- 各维度评分JSON
    issue_count INT,
    resolved_count INT,
    report_url VARCHAR(500),
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 5.1.4 standard-service — 数据标准管理服务（8094）

```sql
CREATE TABLE sw_data_standard (
    id BIGINT PRIMARY KEY,
    standard_code VARCHAR(50) NOT NULL UNIQUE,
    standard_name VARCHAR(200) NOT NULL,
    standard_type VARCHAR(50),                 -- 字段标准/编码标准/命名标准/值域标准
    category VARCHAR(100),                     -- 标准分类
    definition TEXT,                           -- 标准定义
    data_type VARCHAR(50),
    data_length INT,
    data_precision INT,
    value_domain TEXT,                         -- 值域范围
    reference_standard VARCHAR(200),           -- 参考标准
    status TINYINT DEFAULT 1,                  -- 1有效 0废止
    publish_date DATE,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sw_standard_mapping (
    id BIGINT PRIMARY KEY,
    standard_id BIGINT NOT NULL,
    catalog_id BIGINT,                         -- 映射到的数据资产
    column_name VARCHAR(200),
    mapping_status TINYINT DEFAULT 0,          -- 0未贯标 1已贯标 2不一致
    compliance_rate DECIMAL(5,2)
);
```

### 5.1.5 lineage-service — 数据血缘服务（8095）

```sql
-- 关系型存储血缘关系（同时使用Neo4j图数据库存储完整图谱）
CREATE TABLE sw_data_lineage (
    id BIGINT PRIMARY KEY,
    source_catalog_id BIGINT,                  -- 源数据资产
    target_catalog_id BIGINT,                  -- 目标数据资产
    source_column VARCHAR(200),
    target_column VARCHAR(200),
    transformation_type VARCHAR(50),           -- direct/aggregate/transform/join/union
    transformation_logic TEXT,                 -- 转换逻辑
    process_name VARCHAR(200),                 -- 处理过程名称
    process_type VARCHAR(50),                  -- ETL/API/SQL/Script
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Neo4j 图数据库模型
// 节点: DataAsset {id, name, type, system, database, table}
// 关系: FLOWS_TO {transformation, process, time}
// 查询: 查找某数据资产的完整血缘链路
```

### 5.1.6 mdm-service — 主数据管理服务（8096）

```sql
CREATE TABLE sw_master_data_entity (
    id BIGINT PRIMARY KEY,
    entity_code VARCHAR(50) NOT NULL UNIQUE,
    entity_name VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),                   -- customer/product/org/employee/account
    description VARCHAR(500),
    source_systems VARCHAR(500),               -- 来源系统列表
    golden_record_rule TEXT,                   -- 黄金记录规则
    match_rule TEXT,                           -- 匹配规则
    status TINYINT DEFAULT 1,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sw_master_data_record (
    id BIGINT PRIMARY KEY,
    entity_id BIGINT NOT NULL,
    source_system VARCHAR(100),
    source_id VARCHAR(100),
    record_data TEXT,                          -- JSON格式的记录数据
    is_golden TINYINT DEFAULT 0,               -- 1是黄金记录 0不是
    match_confidence DECIMAL(5,2),
    status TINYINT DEFAULT 1,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 5.1.7 lifecycle-service — 生命周期管理服务（8097）

```sql
CREATE TABLE sw_lifecycle_policy (
    id BIGINT PRIMARY KEY,
    policy_name VARCHAR(200) NOT NULL,
    catalog_id BIGINT,
    hot_retention_days INT,                    -- 热数据保留天数
    warm_retention_days INT,                   -- 温数据保留天数
    cold_retention_days INT,                   -- 冷数据保留天数
    archive_action VARCHAR(50),                -- archive/delete/anonymize
    archive_target VARCHAR(200),
    status TINYINT DEFAULT 1,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sw_lifecycle_record (
    id BIGINT PRIMARY KEY,
    policy_id BIGINT,
    catalog_id BIGINT,
    action VARCHAR(50),                        -- move_hot_to_warm/move_warm_to_cold/archive/delete
    data_volume BIGINT,
    execution_time TIMESTAMP,
    status TINYINT DEFAULT 0,                  -- 0待执行 1成功 2失败
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 5.1.8 dataservice-service — 数据服务服务（8098）

```sql
CREATE TABLE sw_data_api (
    id BIGINT PRIMARY KEY,
    api_name VARCHAR(100) NOT NULL,
    api_path VARCHAR(200) NOT NULL UNIQUE,
    api_method VARCHAR(10),                    -- GET/POST
    api_type TINYINT,                          -- 1查询 2写入 3聚合 4AI生成
    source_sql TEXT,                           -- 源SQL
    source_catalog_id BIGINT,
    parameters TEXT,                           -- 参数定义JSON
    response_format VARCHAR(20),               -- JSON/CSV/XML
    rate_limit INT DEFAULT 1000,
    auth_required TINYINT DEFAULT 1,
    status TINYINT DEFAULT 1,                  -- 1已发布 0草稿 2下线
    version VARCHAR(20) DEFAULT '1.0',
    call_count BIGINT DEFAULT 0,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sw_data_api_log (
    id BIGINT PRIMARY KEY,
    api_id BIGINT,
    caller VARCHAR(50),
    request_params TEXT,
    response_status INT,
    response_time BIGINT,
    request_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_api (api_id),
    INDEX idx_time (request_time)
);
```

### 5.1.9 asset-service — 资产评估服务（8099）

```sql
CREATE TABLE sw_asset_evaluation (
    id BIGINT PRIMARY KEY,
    catalog_id BIGINT,
    evaluation_type VARCHAR(50),               -- data_value/health_score/usage_score
    evaluation_score DECIMAL(5,2),
    evaluation_detail TEXT,                    -- 评估明细JSON
    evaluator VARCHAR(50),
    evaluation_date DATE,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sw_asset_health (
    id BIGINT PRIMARY KEY,
    catalog_id BIGINT,
    health_score DECIMAL(3,1),
    quality_dimension TEXT,                    -- 质量维度评分JSON
    usage_dimension TEXT,                      -- 使用维度评分JSON
    security_dimension TEXT,                   -- 安全维度评分JSON
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 5.2 智赢前端页面规划

| 模块 | 页面数 | 核心页面 |
|------|:------:|----------|
| 登录认证 | 2 | 登录、忘记密码（复用共享） |
| 治理驾驶舱 | 1 | 治理总览仪表盘 |
| 数据目录 | 4 | 资产浏览/资产详情/AI搜索/数据问答 |
| 元数据管理 | 3 | 技术元数据/业务元数据/操作元数据 |
| 数据质量 | 5 | 总览/规则管理/任务监控/报告/告警 |
| 数据标准 | 3 | 标准列表/标准详情/贯标映射 |
| 数据血缘 | 3 | 血缘图谱/影响分析/血缘详情 |
| 主数据管理 | 3 | 主数据实体/黄金记录/匹配规则 |
| 数据安全 | 4 | 分类分级/脱敏/水印/泄露防护（复用共享） |
| 数据集成 | 3 | 数据源管理/集成任务/同步监控 |
| 生命周期 | 2 | 策略管理/执行记录 |
| 数据服务 | 4 | API列表/API详情/API市场/调用日志 |
| 资产评估 | 3 | 价值评估/健康分/资产入表 |
| 审计合规 | 3 | 审计日志/合规检查/监管报表（复用共享） |
| 系统管理 | 4 | 用户/角色/权限/系统配置（复用共享） |
| **总计** | **47** | 含复用共享页面 |

## 5.3 智赢AI治理引擎设计

智赢AI治理引擎使用Java LangChain4j内嵌于微服务中，不独立部署：

```java
// metadata-service 中的AI补全能力
@Service
public class AiMetadataService {

    private final ChatLanguageModel chatModel;  // LangChain4j

    /**
     * AI自动补全业务元数据
     */
    public BusinessMetadata autoFillBusinessMetadata(TechnicalMetadata techMeta) {
        String prompt = """
            根据以下技术元数据，推断业务含义：
            表名: %s
            字段: %s
            数据库: %s

            请返回JSON格式：
            {"businessName": "...", "businessDefinition": "...",
             "businessDomain": "...", "synonyms": "..."}
            """.formatted(
            techMeta.getTableName(),
            techMeta.getColumnName(),
            techMeta.getDatabaseName()
        );

        String response = chatModel.generate(prompt);
        return parseBusinessMetadata(response);
    }

    /**
     * AI推荐数据标准
     */
    public List<DataStandard> recommendStandards(String columnName, String dataType) {
        // 基于字段名和数据类型，AI推荐匹配的数据标准
    }
}

// quality-service 中的AI异常检测
@Service
public class AiQualityService {

    /**
     * AI检测数据异常
     */
    public List<QualityAnomaly> detectAnomalies(List<DataRecord> records) {
        // 1. 统计特征分析（均值/方差/分位数）
        // 2. AI模型检测异常模式
        // 3. 返回异常记录列表
    }

    /**
     * AI生成数据质量修复建议
     */
    public List<RepairSuggestion> generateRepairSuggestions(QualityIssue issue) {
        // 基于质量问题，AI生成修复建议
    }
}

// lineage-service 中的AI血缘补全
@Service
public class AiLineageService {

    /**
     * AI自动补全数据血缘
     */
    public List<DataLineage> autoDiscoverLineage(String sqlScript) {
        // 1. SQL解析提取表级血缘
        // 2. AI分析字段级血缘
        // 3. 返回血缘关系列表
    }
}

// catalog-service 中的AI搜索和问答
@Service
public class AiCatalogService {

    /**
     * 自然语言搜索数据资产
     */
    public List<DataCatalog> naturalLanguageSearch(String query) {
        // 1. AI理解查询意图
        // 2. 向量搜索匹配数据资产
        // 3. 返回排序结果
    }

    /**
     * 数据问答
     */
    public String dataQuestionAnswering(String question) {
        // 1. 理解问题
        // 2. 查找相关数据资产
        // 3. RAG方式生成回答
    }
}
```

---

# 第六章 AI引擎双引擎设计

两套产品各自有独立的AI引擎，定位不同但共享大模型API密钥管理。

## 6.1 双引擎架构对比

| 维度 | 智链AI安全引擎 | 智赢AI治理引擎 |
|------|:--------------:|:--------------:|
| 语言 | Python | Java |
| 框架 | FastAPI + gRPC | LangChain4j |
| 部署方式 | 独立容器 | 内嵌微服务 |
| 端口 | 8200(REST) / 8201(gRPC) | 无独立端口 |
| 核心能力 | Prompt注入检测/内容安全/泄露检测/模型评测 | 元数据补全/质量检测/标准推荐/血缘补全/智能搜索 |
| 大模型调用 | 直接调用OpenAI/通义千问等 | 通过LangChain4j调用 |
| 共享 | 共享大模型API密钥管理（通过common-ai模块） | 同左 |

## 6.2 智链AI安全引擎API设计

```
REST API (Port 8200):
  POST /api/detection/prompt-injection    → Prompt注入检测
  POST /api/detection/content-safety      → 内容安全检测
  POST /api/detection/data-leak           → 数据泄露检测
  POST /api/evaluation/model              → 模型评测
  POST /api/proxy/chat                    → 大模型代理（带安全检测）
  GET  /api/stream/chat                   → 流式代理（SSE）
  GET  /api/governance/rules              → 治理规则管理
  GET  /health                            → 健康检查

gRPC API (Port 8201):
  service DetectionService {
    rpc DetectPromptInjection(DetectionRequest) returns (DetectionResponse);
    rpc DetectContentSafety(DetectionRequest) returns (DetectionResponse);
    rpc DetectDataLeak(DetectionRequest) returns (DetectionResponse);
  }
  service EvaluationService {
    rpc EvaluateModel(EvaluationRequest) returns (EvaluationResponse);
  }
```

## 6.3 大模型API密钥共享管理

```yaml
# 统一大模型配置（通过Nacos配置中心管理）
ai:
  models:
    - provider: openai
      api-key: ${OPENAI_API_KEY}
      base-url: https://api.openai.com/v1
      models: [gpt-4, gpt-3.5-turbo]
    - provider: qwen
      api-key: ${QWEN_API_KEY}
      base-url: https://dashscope.aliyuncs.com
      models: [qwen-max, qwen-plus]
    - provider: ernie
      api-key: ${ERNIE_API_KEY}
      base-url: https://aip.baidubce.com
      models: [ernie-bot-4, ernie-bot-turbo]
    - provider: deepseek
      api-key: ${DEEPSEEK_API_KEY}
      base-url: https://api.deepseek.com
      models: [deepseek-chat, deepseek-coder]
```

---

# 第七章 前端双门户设计

## 7.1 统一设计规范

两套前端门户共享设计规范但独立部署：

| 规范项 | 智链门户 | 智数门户 |
|--------|----------|----------|
| 主题色 | 蓝色系 `#58a6ff` | 青色系 `#2dd4bf` |
| 侧边栏 | 220px 可折叠 | 220px 可折叠 |
| 顶栏 | 56px 固定 | 56px 固定 |
| 图表 | ECharts 5（共享调色板） | ECharts 5（共享调色板） |
| 响应式 | 480/768/1200px三断点 | 480/768/1200px三断点 |
| 亮暗主题 | 深浅双主题CSS Variables变量体系，支持light/dark/auto三种模式，一键切换+持久化+系统偏好跟随，详见DES-10 | 深浅双主题CSS Variables变量体系，支持light/dark/auto三种模式，一键切换+持久化+系统偏好跟随，详见DES-10 |
| 国际化 | 中英双语 vue-i18n，按模块拆分locale文件+懒加载+TypeScript类型安全+后端国际化+预留多语言扩展接口，详见DES-10 | 中英双语 vue-i18n，按模块拆分locale文件+懒加载+TypeScript类型安全+后端国际化+预留多语言扩展接口，详见DES-10 |

## 7.2 前端共享组件库

两套前端共享以下组件（提取为 npm workspace 共享包或直接复制）：

```
shared-components/
├── AppLayout.vue          # 主布局（侧边栏+顶栏+内容区）
├── Pagination.vue         # 分页组件
├── SearchBar.vue          # 搜索栏
├── StatCard.vue           # 统计卡片（支持下钻）
├── SkeletonLoader.vue     # 骨架屏
├── EmptyState.vue         # 空状态
├── ConfirmDialog.vue      # 确认对话框
├── Toast.vue              # 通知提示
├── ThemeSwitcher.vue      # 主题切换(light/dark/auto三模式)
├── LangSwitcher.vue       # 语言切换(中英双语+扩展接口)
├── StepWizard.vue         # 步骤向导
├── ConfigSection.vue      # 配置区块
├── ConfigRow.vue          # 配置行
├── CountUp.vue            # 数字动画
├── theme/                 # [新增] 主题子系统(详见DES-10)
│   ├── stores/theme.ts          # ThemeStore(Pinia)
│   ├── themes/light.css         # 浅色变量(40+CSS变量)
│   ├── themes/dark.css          # 深色变量(40+CSS变量)
│   ├── themes/brand/            # 品牌色覆盖
│   └── composables/
│       ├── useTheme.ts          # 主题组合式函数
│       └── useEchartsTheme.ts   # ECharts主题联动
└── i18n/                  # [新增] 国际化子系统(详见DES-10)
    ├── stores/locale.ts         # LocaleStore(Pinia)
    ├── locales/zh-CN/           # 中文消息文件
    ├── locales/en-US/           # 英文消息文件
    └── composables/useLocale.ts # 语言组合式函数
```

## 7.3 前端路由结构

### 智链前端路由

```typescript
// smartchain-frontend/src/router/index.ts
const routes = [
  { path: '/login', component: LoginView },
  { path: '/', component: AppLayout, children: [
    { path: '', component: DashboardView },
    { path: 'models', children: [
      { path: '', component: ModelOverviewView },
      { path: 'access', component: ModelAccessView },
      { path: 'monitor/:id', component: ModelMonitorView },
      { path: 'version/:id', component: ModelVersionView },
      { path: 'eval', component: ModelEvalView },
      { path: 'config/:id', component: ModelConfigView },
      { path: 'keys', component: ModelApikeyView },
    ]},
    { path: 'apps', children: [
      { path: '', component: AppListView },
      { path: 'register', component: AppRegisterView },
      { path: 'monitor/:id', component: AppMonitorView },
      { path: 'permission/:id', component: AppPermissionView },
      { path: 'offline/:id', component: AppOfflineView },
    ]},
    { path: 'agents', children: [
      { path: '', component: AgentView },
      { path: 'prompt', component: PromptMgmtView },
      { path: 'prompt/new', component: PromptNewView },
      { path: 'template', component: SceneTemplateView },
    ]},
    { path: 'security', children: [
      { path: '', component: DataSecurityView },
      { path: 'classify', component: ClassifyView },
      { path: 'masking', component: MaskingView },
      { path: 'watermark', component: WatermarkView },
      { path: 'trace', component: DataTraceView },
      { path: 'leak', component: LeakProtectionView },
      { path: 'ai-detect', component: AiDetectView },
      { path: 'batch-detect', component: BatchDetectView },
      { path: 'crypto', component: CryptoToolboxView },
      { path: 'keys', component: KeyManagementView },
    ]},
    { path: 'risk', children: [
      { path: '', component: RiskControlView },
      { path: 'rules', component: ComplianceRuleView },
      { path: 'alerts', component: ComplianceAlertView },
      { path: 'report', component: ComplianceReportView },
      { path: 'regulatory', component: RegulatoryReportView },
    ]},
    { path: 'cost', children: [
      { path: '', component: CostView },
      { path: 'share', component: CostShareView },
      { path: 'optimize', component: CostOptimizeView },
      { path: 'report', component: CostReportView },
      { path: 'token', component: TokenMeterView },
      { path: 'budget', component: BudgetView },
      { path: 'budget/new', component: BudgetNewView },
      { path: 'budget/detail/:id', component: BudgetDetailView },
      { path: 'budget/export', component: BudgetExportView },
      { path: 'fee', component: FeeAccountingView },
    ]},
    { path: 'audit', children: [
      { path: '', component: AuditView },
      { path: 'full', component: FullAuditView },
      { path: 'op-log', component: OpLogView },
      { path: 'op-log/export', component: OpLogExportView },
    ]},
    { path: 'system', children: [
      { path: 'users', component: UserMgmtView },
      { path: 'roles', component: RoleMgmtView },
      { path: 'permissions', component: PermissionMgmtView },
      { path: 'config', component: SystemConfigView },
      { path: 'profile', component: ProfileView },
      { path: 'messages', component: MessagesView },
      { path: 'help', component: HelpView },
    ]},
  ]},
]
```

### 智赢前端路由

```typescript
// smartwin-frontend/src/router/index.ts
const routes = [
  { path: '/login', component: LoginView },
  { path: '/', component: AppLayout, children: [
    { path: '', component: GovernanceDashboardView },
    { path: 'catalog', children: [
      { path: '', component: CatalogBrowseView },
      { path: ':id', component: CatalogDetailView },
      { path: 'search', component: AiSearchView },
      { path: 'ask', component: DataQaView },
    ]},
    { path: 'metadata', children: [
      { path: 'technical', component: TechnicalMetadataView },
      { path: 'business', component: BusinessMetadataView },
      { path: 'operational', component: OperationalMetadataView },
    ]},
    { path: 'quality', children: [
      { path: '', component: QualityOverviewView },
      { path: 'rules', component: QualityRulesView },
      { path: 'tasks', component: QualityTasksView },
      { path: 'reports', component: QualityReportsView },
      { path: 'alerts', component: QualityAlertsView },
    ]},
    { path: 'standard', children: [
      { path: '', component: StandardListView },
      { path: ':id', component: StandardDetailView },
      { path: 'mapping', component: StandardMappingView },
    ]},
    { path: 'lineage', children: [
      { path: '', component: LineageGraphView },
      { path: 'impact', component: ImpactAnalysisView },
      { path: ':id', component: LineageDetailView },
    ]},
    { path: 'mdm', children: [
      { path: '', component: MdmEntityView },
      { path: 'golden/:id', component: GoldenRecordView },
      { path: 'match-rules', component: MatchRuleView },
    ]},
    { path: 'integration', children: [
      { path: 'sources', component: DataSourceView },
      { path: 'tasks', component: IntegrationTaskView },
      { path: 'monitor', component: SyncMonitorView },
    ]},
    { path: 'lifecycle', children: [
      { path: '', component: LifecyclePolicyView },
      { path: 'records', component: LifecycleRecordView },
    ]},
    { path: 'dataservice', children: [
      { path: '', component: ApiListView },
      { path: ':id', component: ApiDetailView },
      { path: 'market', component: ApiMarketView },
      { path: 'logs', component: ApiLogView },
    ]},
    { path: 'asset', children: [
      { path: 'value', component: AssetValueView },
      { path: 'health', component: AssetHealthView },
      { path: 'capitalization', component: AssetCapitalizationView },
    ]},
    // 安全/审计/系统管理复用共享页面
    { path: 'security', children: [/* 复用共享 */] },
    { path: 'audit', children: [/* 复用共享 */] },
    { path: 'system', children: [/* 复用共享 */] },
  ]},
]
```

---

# 第八章 数据库设计

## 8.1 数据库整体规划

| 数据库 | 用途 | 表前缀 | 部署 |
|--------|------|:------:|:----:|
| 达梦DM8 | 主业务数据库 | sys_/sec_/audit_/ic_/sw_ | 独立容器 |
| Redis | 缓存/Token/Session | — | 独立容器 |
| Elasticsearch | 数据目录全文搜索 | — | 独立容器 |
| Neo4j | 数据血缘图谱 | — | 独立容器 |
| MinIO | 文件/报告/附件 | — | 独立容器 |
| H2 | 开发测试数据库 | — | 内存 |

## 8.2 表命名规范

| 前缀 | 归属 | 示例 |
|------|------|------|
| `sys_` | 共享-系统管理 | sys_user, sys_role, sys_permission |
| `sec_` | 共享-安全治理 | sec_classification, sec_masking_rule |
| `audit_` | 共享-审计日志 | audit_operation_log, audit_alert |
| `ic_` | 智链独有 | ic_model, ic_app, ic_agent, ic_cost_budget |
| `sw_` | 智赢独有 | sw_data_catalog, sw_quality_rule, sw_data_standard |

## 8.3 数据库初始化顺序

```sql
-- 1. 共享底座表（必须先建）
@sql/platform-schema.sql

-- 2. 智链业务表
@sql/smartchain-schema.sql

-- 3. 智赢业务表
@sql/smartwin-schema.sql

-- 4. 种子数据
@sql/seed-data.sql
```

---

# 第九章 DevOps与部署方案

## 9.1 Docker Compose全量部署

```yaml
# infra/docker/docker-compose.yml
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
    command: redis-server --appendonly yes

  dm8:
    image: dm8:latest
    ports: ["5236:5236"]
    volumes:
      - dm8-data:/opt/dmdbms/data

  elasticsearch:
    image: elasticsearch:8.13.0
    ports: ["9200:9200"]
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false

  neo4j:
    image: neo4j:5.20
    ports: ["7474:7474", "7687:7687"]
    environment:
      - NEO4J_AUTH=neo4j/smartwin123

  minio:
    image: minio/minio:latest
    ports: ["9000:9000", "9001:9001"]
    command: server /data --console-address ":9001"

  # ======== AI引擎 ========
  ai-engine-smartchain:
    build: ../../smartchain/smartchain-ai-engine
    ports: ["8200:8200", "8201:8201"]
    depends_on: [redis]

  # ======== 网关 ========
  gateway:
    build:
      context: ../../gateway
    ports: ["9000:9000"]
    depends_on: [nacos]

  # ======== 共享服务 ========
  auth-service:
    build: ../../platform-services/auth-service
    ports: ["8081:8080"]
    depends_on: [nacos, redis, dm8]

  system-service:
    build: ../../platform-services/system-service
    ports: ["8082:8080"]
    depends_on: [nacos, redis, dm8]

  security-service:
    build: ../../platform-services/security-service
    ports: ["8090:8080"]
    depends_on: [nacos, redis, dm8]

  audit-service:
    build: ../../platform-services/audit-service
    ports: ["8100:8080"]
    depends_on: [nacos, redis, dm8]

  dashboard-service:
    build: ../../platform-services/dashboard-service
    ports: ["8101:8080"]
    depends_on: [nacos, redis, dm8]

  notification-service:
    build: ../../platform-services/notification-service
    ports: ["8102:8080"]
    depends_on: [nacos, redis, dm8]

  config-service:
    build: ../../platform-services/config-service
    ports: ["8103:8080"]
    depends_on: [nacos, redis, dm8]

  # ======== 智链服务 ========
  model-service:
    build: ../../smartchain/smartchain-services/model-service
    ports: ["8083:8080"]
    depends_on: [nacos, redis, dm8, ai-engine-smartchain]

  app-service:
    build: ../../smartchain/smartchain-services/app-service
    ports: ["8084:8080"]
    depends_on: [nacos, redis, dm8]

  agent-service:
    build: ../../smartchain/smartchain-services/agent-service
    ports: ["8085:8080"]
    depends_on: [nacos, redis, dm8]

  cost-service:
    build: ../../smartchain/smartchain-services/cost-service
    ports: ["8086:8080"]
    depends_on: [nacos, redis, dm8]

  risk-service:
    build: ../../smartchain/smartchain-services/risk-service
    ports: ["8087:8080"]
    depends_on: [nacos, redis, dm8]

  prompt-service:
    build: ../../smartchain/smartchain-services/prompt-service
    ports: ["8088:8080"]
    depends_on: [nacos, redis, dm8]

  # ======== 智赢服务 ========
  catalog-service:
    build: ../../smartwin/smartwin-services/catalog-service
    ports: ["8091:8080"]
    depends_on: [nacos, redis, dm8, elasticsearch]

  metadata-service:
    build: ../../smartwin/smartwin-services/metadata-service
    ports: ["8092:8080"]
    depends_on: [nacos, redis, dm8]

  quality-service:
    build: ../../smartwin/smartwin-services/quality-service
    ports: ["8093:8080"]
    depends_on: [nacos, redis, dm8]

  standard-service:
    build: ../../smartwin/smartwin-services/standard-service
    ports: ["8094:8080"]
    depends_on: [nacos, redis, dm8]

  lineage-service:
    build: ../../smartwin/smartwin-services/lineage-service
    ports: ["8095:8080"]
    depends_on: [nacos, redis, dm8, neo4j]

  mdm-service:
    build: ../../smartwin/smartwin-services/mdm-service
    ports: ["8096:8080"]
    depends_on: [nacos, redis, dm8]

  lifecycle-service:
    build: ../../smartwin/smartwin-services/lifecycle-service
    ports: ["8097:8080"]
    depends_on: [nacos, redis, dm8]

  dataservice-service:
    build: ../../smartwin/smartwin-services/dataservice-service
    ports: ["8098:8080"]
    depends_on: [nacos, redis, dm8]

  asset-service:
    build: ../../smartwin/smartwin-services/asset-service
    ports: ["8099:8080"]
    depends_on: [nacos, redis, dm8]

  # ======== 前端 ========
  frontend-smartchain:
    build: ../../smartchain/smartchain-frontend
    ports: ["80:80"]
    depends_on: [gateway]

  frontend-smartwin:
    build: ../../smartwin/smartwin-frontend
    ports: ["81:80"]
    depends_on: [gateway]

  # ======== 监控 ========
  prometheus:
    image: prom/prometheus
    ports: ["9090:9090"]

  grafana:
    image: grafana/grafana
    ports: ["3000:3000"]

volumes:
  dm8-data:
  redis-data:
  es-data:
  neo4j-data:
  minio-data:
```

## 9.2 Nginx路由配置

```nginx
# infra/docker/nginx.conf
server {
    listen 80;
    server_name smartchain.local;
    location / { proxy_pass http://frontend-smartchain:80; }
    location /api/ { proxy_pass http://gateway:9000/api/; }
}

server {
    listen 81;
    server_name smartwin.local;
    location / { proxy_pass http://frontend-smartwin:80; }
    location /api/ { proxy_pass http://gateway:9000/api/; }
}
```

## 9.3 Spring Cloud Gateway路由配置

```yaml
# gateway/src/main/resources/application.yml
server:
  port: 9000

spring:
  cloud:
    gateway:
      routes:
        # ======== 共享服务路由 ========
        - id: auth-service
          uri: lb://auth-service
          predicates: [Path=/api/auth/**]
        - id: system-service
          uri: lb://system-service
          predicates: [Path=/api/system/**]
        - id: security-service
          uri: lb://security-service
          predicates: [Path=/api/security/**]
        - id: audit-service
          uri: lb://audit-service
          predicates: [Path=/api/audit/**]
        - id: dashboard-service
          uri: lb://dashboard-service
          predicates: [Path=/api/dashboard/**]
        # ======== 智链服务路由 ========
        - id: model-service
          uri: lb://model-service
          predicates: [Path=/api/smartchain/models/**]
        - id: app-service
          uri: lb://app-service
          predicates: [Path=/api/smartchain/apps/**]
        - id: agent-service
          uri: lb://agent-service
          predicates: [Path=/api/smartchain/agents/**]
        - id: cost-service
          uri: lb://cost-service
          predicates: [Path=/api/smartchain/cost/**]
        - id: risk-service
          uri: lb://risk-service
          predicates: [Path=/api/smartchain/risk/**]
        - id: prompt-service
          uri: lb://prompt-service
          predicates: [Path=/api/smartchain/prompts/**]
        # ======== 智赢服务路由 ========
        - id: catalog-service
          uri: lb://catalog-service
          predicates: [Path=/api/smartwin/catalog/**]
        - id: metadata-service
          uri: lb://metadata-service
          predicates: [Path=/api/smartwin/metadata/**]
        - id: quality-service
          uri: lb://quality-service
          predicates: [Path=/api/smartwin/quality/**]
        - id: standard-service
          uri: lb://standard-service
          predicates: [Path=/api/smartwin/standard/**]
        - id: lineage-service
          uri: lb://lineage-service
          predicates: [Path=/api/smartwin/lineage/**]
        - id: mdm-service
          uri: lb://mdm-service
          predicates: [Path=/api/smartwin/mdm/**]
        - id: lifecycle-service
          uri: lb://lifecycle-service
          predicates: [Path=/api/smartwin/lifecycle/**]
        - id: dataservice-service
          uri: lb://dataservice-service
          predicates: [Path=/api/smartwin/dataservice/**]
        - id: asset-service
          uri: lb://asset-service
          predicates: [Path=/api/smartwin/asset/**]
```

---

# 第十章 开发实施路线图

## 10.1 总体时间线（12个月）

```
月份:  M1    M2    M3    M4    M5    M6    M7    M8    M9    M10   M11   M12
       │     │     │     │     │     │     │     │     │     │     │     │
阶段一: 共享底座 + 智链核心
       ├─────────────────┤     │     │     │     │     │     │     │     │
       底座+认证+安全+审计     │     │     │     │     │     │     │     │
                            │     │     │     │     │     │     │     │
阶段二: 智链业务模块               │     │     │     │     │     │     │
       ├─────────────────────┤     │     │     │     │     │     │
       模型+应用+成本+风险+Agent     │     │     │     │     │     │
                                  │     │     │     │     │     │
阶段三: 智链前端+AI引擎                  │     │     │     │     │
       ├─────────────────────┤     │     │     │     │
       智链61页+Python引擎+联调          │     │     │     │
                                        │     │     │     │
阶段四: 智赢核心模块                           │     │     │
       ├─────────────────────┤     │     │
       目录+元数据+质量+标准+血缘               │     │
                                                  │     │
阶段五: 智赢扩展+前端+联调                            │
       ├─────────────────────┤
       MDM+生命周期+服务+资产+前端47页+联调

交付节点:
  M4:  共享底座V1.0 + 智链核心API就绪
  M6:  智链V1.0（前后端+AI引擎）可演示
  M8:  智链V1.0正式发布 + 智赢核心开发启动
  M10: 智赢核心模块就绪
  M12: 智赢V1.0正式发布 + 双产品联调完成
```

## 10.2 各阶段详细任务

### 阶段一：共享底座 + 智链核心（M1-M3）

| Sprint | 时间 | 任务 | 产出 |
|:------:|:----:|------|------|
| S1 | M1 W1-2 | Monorepo初始化 + 根POM + 前端workspace | 项目骨架 |
| S2 | M1 W3-4 | common-util + common-db + common-security | 3个公共模块 |
| S3 | M2 W1-2 | auth-service + system-service | 认证+用户管理可运行 |
| S4 | M2 W3-4 | security-service + audit-service | 安全+审计可运行 |
| S5 | M3 W1-2 | common-ai + common-mq + common-storage | 全部公共模块完成 |
| S6 | M3 W3-4 | gateway + Nacos集成 + Docker Compose基础 | 网关+一键启动 |

### 阶段二：智链业务模块（M4-M5）

| Sprint | 时间 | 任务 | 产出 |
|:------:|:----:|------|------|
| S7 | M4 W1-2 | model-service（模型管理+版本+密钥+评测） | 模型管理API |
| S8 | M4 W3-4 | app-service + agent-service + prompt-service | 应用+Agent+Prompt API |
| S9 | M5 W1-2 | cost-service（成本+预算+Token+费用） | 成本管控API |
| S10 | M5 W3-4 | risk-service（风险+合规规则+告警+报告） | 风险管控API |

### 阶段三：智链前端 + AI引擎（M6-M7）

| Sprint | 时间 | 任务 | 产出 |
|:------:|:----:|------|------|
| S11 | M6 W1-2 | 智链前端脚手架 + 布局 + 路由 + 登录 | 前端骨架 |
| S12 | M6 W3-4 | 模型管理9页 + 应用管理6页 | 15个页面 |
| S13 | M7 W1-2 | 安全治理9页 + 成本预算10页 + 风险5页 | 24个页面 |
| S14 | M7 W3-4 | Agent 5页 + 审计5页 + 系统4页 + 仪表盘 + 运维3页 | 18个页面 |
| S15 | M7 W1-2 | Python AI安全引擎（检测+评测+代理） | AI引擎 |
| S16 | M7 W3-4 | 前后端联调 + Docker全量部署 + 测试 | 智链V1.0 RC |

### 阶段四：智赢核心模块（M8-M9）

| Sprint | 时间 | 任务 | 产出 |
|:------:|:----:|------|------|
| S17 | M8 W1-2 | catalog-service + ES集成（数据目录+搜索） | 数据目录API |
| S18 | M8 W3-4 | metadata-service + AI补全（元数据管理） | 元数据API |
| S19 | M9 W1-2 | quality-service + AI检测（数据质量） | 质量管理API |
| S20 | M9 W3-4 | standard-service + lineage-service + Neo4j | 标准+血缘API |

### 阶段五：智赢扩展 + 前端 + 联调（M10-M12）

| Sprint | 时间 | 任务 | 产出 |
|:------:|:----:|------|------|
| S21 | M10 W1-2 | mdm-service + lifecycle-service + dataservice-service | 3个扩展API |
| S22 | M10 W3-4 | asset-service + LangChain4j AI治理引擎 | 资产+AI引擎 |
| S23 | M11 W1-2 | 智赢前端脚手架 + 布局 + 路由 + 治理驾驶舱 | 前端骨架 |
| S24 | M11 W3-4 | 数据目录4页 + 元数据3页 + 质量5页 + 标准3页 + 血缘3页 | 18个页面 |
| S25 | M12 W1-2 | MDM3页 + 集成3页 + 生命周期2页 + 服务4页 + 资产3页 | 15个页面 |
| S26 | M12 W3-4 | 全量联调 + 集成测试 + Docker部署 + 文档 | 双产品V1.0 |

## 10.3 关键里程碑

| 里程碑 | 时间 | 验收标准 |
|--------|:----:|----------|
| **M1** | M3底 | 共享底座V1.0发布，7个公共模块+7个共享服务可运行 |
| **M2** | M6底 | 智链V1.0 RC，61页前端+6个业务服务+AI引擎联调通过 |
| **M3** | M7底 | 智链V1.0正式发布，Docker一键部署，可进行POC |
| **M4** | M9底 | 智赢核心模块就绪，5个核心服务API可运行 |
| **M5** | M12底 | 智赢V1.0正式发布，双产品联调完成，可组合销售 |

---

# 第十一章 团队组织与分工

## 11.1 团队规模与配置

| 角色 | 人数 | 职责 | 到岗时间 |
|------|:----:|------|:--------:|
| 技术总监/架构师 | 1 | 架构设计+技术决策+代码审查 | M1 |
| 共享平台Lead | 1 | 共享底座开发+API契约 | M1 |
| 后端工程师 | 6 | 微服务开发（2共享+2智链+2智赢） | M1-M3 |
| 前端工程师 | 4 | 两套前端并行开发（2智链+2智赢） | M2-M6 |
| Python工程师 | 1 | AI安全引擎开发 | M3 |
| AI算法工程师 | 1 | AI治理引擎（LangChain4j） | M6 |
| 测试工程师 | 2 | 功能测试+集成测试+E2E | M3 |
| DevOps工程师 | 1 | CI/CD+Docker+监控 | M1 |
| 产品经理 | 1 | 需求管理+验收 | M1 |
| **总计** | **18** | | |

## 11.2 分工矩阵

| 阶段 | 共享平台组 | 智链组 | 智赢组 | 前端组 | AI组 |
|------|:---:|:---:|:---:|:---:|:---:|
| M1-M3 | 底座+共享服务 | — | — | 智链脚手架 | — |
| M4-M5 | 支持联调 | 6个业务服务 | — | 智链61页 | AI引擎 |
| M6-M7 | 支持联调 | 联调+修复 | — | 智链完善 | 联调 |
| M8-M9 | 支持联调 | V1.1迭代 | 5个核心服务 | 智赢脚手架 | — |
| M10-M12 | 支持联调 | 交叉销售支持 | 5个扩展服务 | 智赢47页 | AI治理引擎 |

---

# 第十二章 质量保障体系

## 12.1 代码质量

| 维度 | 标准 | 工具 |
|------|------|------|
| 代码规范 | 阿里巴巴Java开发手册 + Vue官方风格指南 | Checkstyle + ESLint |
| 代码重复 | 重复率 < 5% | SonarQube |
| 圈复杂度 | < 15 | SonarQube |
| 单元测试覆盖率 | 后端 > 70%，前端 > 60% | JaCoCo + Vitest |
| API文档 | 100%接口有文档 | Knife4j (Swagger) |
| TypeScript类型 | strict模式，无any | vue-tsc |

## 12.2 测试策略

| 测试类型 | 范围 | 工具 | 执行时机 |
|----------|------|------|:--------:|
| 单元测试 | 服务/组件级 | JUnit5 + Mockito / Vitest | 每次提交 |
| 集成测试 | 微服务间 | SpringBootTest / Testcontainers | 每日CI |
| E2E测试 | 关键用户路径 | Playwright | 每周 |
| 性能测试 | API响应/并发 | k6 / JMeter | 每个里程碑 |
| 安全测试 | 漏洞扫描 | OWASP ZAP | 发布前 |

## 12.3 CI/CD流水线

```yaml
# .github/workflows/ci.yml
name: CI Pipeline
on: [push, pull_request]

jobs:
  backend-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with: { java-version: '17', distribution: 'temurin' }
      - run: mvn clean test -B
      - run: mvn jacoco:report
      - uses: codecov/codecov-action@v4

  frontend-test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        app: [smartchain-frontend, smartwin-frontend]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20' }
      - run: npm ci -w ${{ matrix.app }}
      - run: npm run lint -w ${{ matrix.app }}
      - run: npm run typecheck -w ${{ matrix.app }}
      - run: npm run test -w ${{ matrix.app }}

  docker-build:
    needs: [backend-test, frontend-test]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: docker compose build
```

## 12.4 发布检查清单

- [ ] 所有P0/P1 Bug已修复
- [ ] 单元测试覆盖率达标
- [ ] E2E测试全部通过
- [ ] 性能测试达标（API P95 < 500ms）
- [ ] 安全扫描无高危漏洞
- [ ] Docker镜像构建成功
- [ ] Docker Compose一键启动验证
- [ ] API文档已更新
- [ ] 数据库迁移脚本验证
- [ ] 回归测试通过

---

## 文档修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-07 | 智赢项目组 | 初始版本发布 |

---

> **总结**：本方案以Monorepo方式管理两套产品，共享7个公共模块+7个共享服务，智链独有6个服务+Python AI引擎+61页前端，智赢独有9个服务+Java AI引擎+47页前端，总计22个微服务+108页前端+双AI引擎，12个月完成双产品V1.0。
