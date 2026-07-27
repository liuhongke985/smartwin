# SmartWin AI Governance Platform

> 智赢(智数+智链) — AI原生数据治理与AI模型治理监控双平台 Monorepo

## 产品体系

| 产品名 | 英文名 | 定位 | 独立可售 |
|--------|--------|------|:--------:|
| **智数** | SmartData | AI原生数据治理平台 (数据目录/元数据/质量/标准/血缘/资产) | ✅ |
| **智链** | SmartChain | AI模型治理与监控平台 (模型/应用/成本/风险/Agent/Prompt管理) | ✅ |
| **智赢** | SmartWin | 集成平台 (智数+智链统一门户+SSO+数据互通) | ✅ |

> 智数与智链可独立销售部署，也可集成为"智赢"平台组合销售。

## 技术栈

| 层次 | 技术 | 版本 |
|------|------|------|
| 后端 | Spring Boot 3 + Spring Cloud Alibaba | 3.2.5 |
| ORM | MyBatis-Plus | 3.5.7 |
| 前端 | Vue 3 + TypeScript + Vite + Pinia | 3.5+ |
| 国际化 | vue-i18n | 10.0+ |
| 数据库 | MySQL(开发) / 达梦DM8 / 人大金仓 / openGauss(信创) | — |
| 缓存 | Redis | 7.2+ |
| 搜索 | Elasticsearch | 8.x |
| 图数据库 | Neo4j | 5.x |
| 消息队列 | RocketMQ | 5.2.0 |
| 对象存储 | MinIO | latest |
| AI引擎 | Python FastAPI(智数) / LangChain4j(智链) | — |
| 国密 | BouncyCastle SM2/SM3/SM4/SM9 + TLCP | 1.78.1 |

## 工程结构

```
WebDesign/                         # 顶层仓库
├── platform-common/               # 共享技术底座（12个Maven模块）
│   ├── common-util/               # 通用工具（响应体、异常、基类、Profile、条件注解）
│   ├── common-db/                 # MyBatis-Plus配置
│   ├── common-dm8/                # 达梦DM8适配
│   ├── common-db-multi/           # 多国产数据库统一适配
│   ├── common-crypto-gm/          # 国密算法（SM2/SM3/SM4/SM9）
│   ├── common-xinchuang/          # 信创环境自动探测
│   ├── common-security/           # JWT + Spring Security
│   ├── common-ai/                 # AI引擎客户端
│   ├── common-mq/                 # RocketMQ封装
│   ├── common-storage/            # MinIO对象存储
│   ├── common-test/               # 测试基类
│   └── common-gateway/            # Spring Cloud Gateway
├── platform-services/             # 共享微服务（7个服务）
├── smartchain/                    # 智链产品线 (AI模型治理与监控)
│   ├── smartchain-services/       # 智链独有微服务 (模型/应用/成本/风险)
│   ├── smartchain-frontend/       # 智链前端门户 (5173)
│   └── smartchain-ai-engine/      # 智链AI引擎 (Python)
├── smartdata/                     # 智数产品线 (AI原生数据治理)
│   ├── smartdata-services/        # 智数独有微服务 (数据目录/元数据/质量等)
│   └── smartdata-frontend/        # 智数前端门户 (5174)
├── shared-components/             # 前端共享组件库（主题/i18n/UI组件）
├── gateway/                       # 统一API网关 (9000)
├── infra/                         # 基础设施（Docker/SQL/脚本）
├── docs/                          # 工程文档
├── pom.xml                        # 根POM
├── package.json                   # 前端workspace
├── Makefile                       # 常用命令
└── .gitignore
```

## 快速开始

### 1. 启动基础设施

```bash
make docker-up    # 启动 MySQL, Redis, MinIO, Nacos, ES, Neo4j, RocketMQ
make db-init      # 初始化数据库
```

### 2. 构建后端

```bash
make install      # Maven 编译安装所有模块
```

### 3. 启动前端

```bash
npm install       # 安装前端依赖
make dev-sc       # 启动智链前端 (端口5173)
make dev-sd       # 启动智数前端 (端口5174)
```

### 4. 默认管理员

```
用户名: admin
密码: admin123
```

## 多模式部署

一套代码通过 Profile 组合支持四种交付模式：

| 模式 | Profile组合 | 说明 |
|------|------------|------|
| 模式A | `prod,sc` | 私有化·智链独立 (AI模型治理与监控) |
| 模式B | `prod,sd` | 私有化·智数独立 (AI原生数据治理) |
| 模式C | `prod,saas,sc` | SaaS·智链独立 |
| 模式D | `prod,saas,integrated` | SaaS·集成(智赢) |

## 信创适配

系统支持完整的信创环境，详见 DES-09 设计方案：

- **CPU**: 鲲鹏/飞腾/海光/龙芯（多架构Docker镜像）
- **OS**: 统信UOS/麒麟V10/openEuler
- **数据库**: 达梦DM8/人大金仓/openGauss/南大通用/神通（自动探测+路由）
- **国密**: SM2/SM3/SM4/SM9 + TLCP双证书（软件实现+HSM透明切换）

## 主题与国际化

系统支持浅色/深色/自动三种主题模式和中文/英文双语切换，详见 DES-10 设计方案：

- **主题**: CSS Variables变量体系，Pinia状态管理，localStorage持久化
- **i18n**: vue-i18n，按模块拆分locale文件，懒加载，TypeScript类型安全

## 相关文档

| 编号 | 文档 | 说明 |
|------|------|------|
| REQ-01 | 业务需求说明书BRD | 产品需求基线 |
| REQ-02 | 智数SRS | AI原生数据治理平台需求规格 |
| DES-09 | 信创全栈适配与国密算法设计方案 | 信创适配详细设计 |
| DES-10 | 前端主题与国际化设计方案 | 主题/i18n详细设计 |

## License

Copyright © 2026 SmartWin Team. All rights reserved.
