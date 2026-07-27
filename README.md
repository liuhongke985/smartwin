# SmartWin AI 治理平台

> **智赢** (智数 + 智链) — AI 原生数据治理与 AI 模型治理监控双平台 Monorepo
>
> 🎯 **目标市场**: 政企/金融/制造 | 🌍 **国产全栈**: 信创适配 100% | 🤖 **AI 原生**: 一句话自动化

![License](https://img.shields.io/badge/license-Apache%202.0-blue)
![Java](https://img.shields.io/badge/java-21%2B-brightgreen)
![Spring Boot](https://img.shields.io/badge/spring%20boot-3.2.5-brightgreen)
![Vue](https://img.shields.io/badge/vue-3.5%2B-brightgreen)

---

## 🎯 核心竞争力

### 1️⃣ **唯一的数据+模型双平台集成**
- 智数 (SmartData): AI 原生数据治理 ← 独立可售
- 智链 (SmartChain): AI 模型治理与监控 ← 独立可售  
- 智赢 (SmartWin): 统一门户 + SSO + 数据互通 ← 集成平台

**竞品对标**: 华为/阿里只有数据治理强，百分点只有 AI 能力，无人同时覆盖两个领域

### 2️⃣ **国产全栈深度适配**
```
✅ 国产芯片: 鲲鹏/飞腾/海光/龙芯
✅ 国产OS: 统信 UOS/麒麟 V10/openEuler
✅ 国产数据库: 达梦 DM8/人大金仓/openGauss/南大通用
✅ 国密算法: SM2/SM3/SM4/SM9 + TLCP 双证书
✅ 自动探测: 系统自动识别环境并适配（政府采购必选项）
```

### 3️⃣ **AI 原生自动化**
```
用户输入: "检查用户名不能为空且长度<50"
        ↓
    LLM 理解 (LangChain4j)
        ↓
  自动生成 SQL/Python 规则
        ↓
    一键部署执行
```

**结果**: 降低 80% 数据治理人力成本

### 4️⃣ **技术栈领先 5 年**
- JDK 21 虚拟线程 (支持到 2031 年)
- Spring Boot 3.2.5 (最新企业级)
- 云原生 K8s Ready (12 因子应用)
- 可观测性三大支柱 (日志+指标+追踪)

---

## 📊 产品体系

| 产品 | 英文名 | 定位 | 独立可售 | 核心功能 |
|------|--------|------|:--------:|---------|
| **智数** | SmartData | AI 原生数据治理 | ✅ | 数据目录/元数据/质量/标准/血缘/资产 |
| **智链** | SmartChain | AI 模型治理与监控 | ✅ | 模型注册/性能监控/漂移检测/成本管理 |
| **智赢** | SmartWin | 集成门户 | ✅ | SSO/权限/数据互通/统一仪表板 |

---

## 🚀 技术栈

### 后端技术栈
```yaml
基础框架:
  - Java: 21 LTS (虚拟线程支持百万并发)
  - Spring Boot: 3.2.5
  - Spring Cloud Alibaba: 2022.0.x

数据库与存储:
  - MySQL 8.0+ (开发环境)
  - 国产适配: 达梦 DM8 / Kingbase / openGauss
  - Redis 7.2+ (分布式缓存)
  - Elasticsearch 8.10+ (全文搜索+日志)
  - Neo4j 5.x (数据血缘图谱)
  - MinIO latest (对象存储)

消息与集成:
  - RocketMQ 5.2.0 (可靠消息投递)
  - Apache Camel (轻量级集成)
  - Spring WebFlux (异步非阻塞)

AI 与安全:
  - LangChain4j 0.25+ (LLM 应用框架)
  - Spring AI 0.11+ (AI 集成)
  - BouncyCastle 1.78.1 (国密 SM2/SM3/SM4/SM9)
  - Spring Security 6.1+ (权限管理)
  - JWT (令牌认证)

监控与运维:
  - Prometheus (指标采集)
  - Jaeger (分布式追踪)
  - ELK Stack (日志分析)
  - SkyWalking (APM 可选)
```

### 前端技术栈
```yaml
框架与构建:
  - Vue 3.5+ (Composition API + TypeScript)
  - Vite 5.0+ (极速开发)
  - TypeScript 5.x

状态与工具:
  - Pinia 2.1+ (状态管理)
  - Axios 0.27+ (HTTP 客户端)
  - vue-i18n 10.0+ (国际化)

UI 与可视化:
  - Element Plus 2.8+ (企业级组件)
  - ECharts 5.4+ (数据可视化)
  - Monaco Editor (代码编辑)

包管理与发布:
  - pnpm (高性能包管理)
  - GitHub Actions (CI/CD)
```

---

## 📂 项目结构

```
smartwin/                          # 项目根目录
├── platform-common/               # 共享技术底座 (12 个 Maven 模块)
│   ├── common-util/               # 通用工具库
│   ├── common-db/                 # MyBatis-Plus 配置
│   ├── common-db-multi/           # 多国产数据库适配引擎 ⭐
│   ├── common-crypto-gm/          # 国密算法支持库 (SM2/SM3/SM4/SM9)
│   ├── common-xinchuang/          # 信创环境自动探测
│   ├── common-security/           # JWT + Spring Security
│   ├── common-ai/                 # AI 引擎客户端 (LLM 适配)
│   ├── common-mq/                 # RocketMQ 封装
│   ├── common-storage/            # MinIO 对象存储
│   ├── common-test/               # 测试基类
│   ├── common-cache/              # 多级缓存 (Caffeine + Redis)
│   └── common-gateway/            # Spring Cloud Gateway
│
├── platform-services/             # 共享微服务
│   ├── auth-service/              # 统一认证服务 (SSO)
│   ├── user-service/              # 用户与权限管理
│   ├── log-service/               # 审计日志服务
│   ├── notification-service/      # 消息通知服务
│   ├── file-service/              # 文件管理服务
│   ├── config-service/            # 配置管理服务
│   └── monitor-service/           # 监控告警服务
│
├── smartdata/                     # 智数产品线 (数据治理)
│   ├── smartdata-services/        # 独有微服务
│   │   ├── data-collection/       # 数据采集服务 (50+ 数据源)
│   │   ├── metadata-service/      # 元数据管理服务
│   │   ├── quality-service/       # 数据质量检测引擎
│   │   ├── lineage-service/       # 数据血缘追踪服务
│   │   ├── standard-service/      # 数据标准管理
│   │   ├── security-service/      # 数据安全与脱敏
│   │   └── asset-service/         # 数据资产管理
│   ├── smartdata-frontend/        # 数据治理门户 (Vue 3, 端口 5174)
│   └── smartdata-engine/          # 数据处理引擎 (可选 Python)
│
├── smartchain/                    # 智链产品线 (模型治理)
│   ├── smartchain-services/       # 独有微服务
│   │   ├── model-registry/        # 模型注册与版本管理
│   │   ├── model-training/        # 模型训练管理
│   │   ├── model-serving/         # 模型部署与推理
│   │   ├── model-monitoring/      # 模型性能监控与漂移检测
│   │   ├── cost-management/       # 成本管理与优化
│   │   ├── explainability/        # 可解释性分析 (SHAP/LIME)
│   │   └── risk-assessment/       # 风险评估与合规检查
│   ├── smartchain-frontend/       # 模型治理门户 (Vue 3, 端口 5173)
│   └── smartchain-ai-engine/      # AI 推理引擎 (可选 Python/Java)
│
├── smartwin/                      # 智赢集成平台
│   ├── smartwin-gateway/          # 统一网关路由
│   ├── smartwin-portal/           # 集成门户 & 仪表板
│   ├── smartwin-auth/             # SSO 与权限统一
│   └── smartwin-integration/      # 产品数据互通
│
├── shared-components/             # 前端共享组件库
│   ├── ui-components/             # UI 组件库 (Element Plus 拓展)
│   ├── theme/                     # 主题系统 (深色/浅色/自动)
│   ├── i18n/                      # 国际化模块 (中/英/日)
│   └── hooks/                     # 共享业务逻辑 hooks
│
├── gateway/                       # API 网关 (Spring Cloud Gateway)
│   ├── src/main/resources/
│   │   ├── application.yml        # 网关配置
│   │   ├── routes/                # 路由配置
│   │   └── filter/                # 自定义过滤器
│   └── pom.xml
│
├── infra/                         # 基础设施
│   ├── docker-compose.yml         # 本地开发环境
│   ├── kubernetes/                # K8s 部署清单
│   ├── helm/                      # Helm Chart
│   ├── sql/                       # 数据库脚本
│   │   ├── init.sql               # 初始化脚本
│   │   ├── smartdata.sql          # 智数表结构
│   │   ├── smartchain.sql         # 智链表结构
│   │   └── migrations/            # Flyway 迁移脚本
│   ├── scripts/                   # 运维脚本
│   └── monitoring/                # 监控配置
│
├── docs/                          # 工程文档
│   ├── ARCHITECTURE.md            # 架构设计
│   ├── API.md                     # API 文档
│   ├── DEPLOYMENT.md              # 部署指南
│   └── TROUBLESHOOTING.md         # 故障排查
│
├── DocDesign/                     # 项目文档 (产品/设计)
│   ├── 00-文档总纲/               # 文档索引
│   ├── 01-商业模式/               # 商业计划
│   ├── 02-项目启动/               # 快速开始
│   ├── 03-需求分析/               # 需求规格
│   ├── 04-系统设计/               # 技术架构
│   ├── 05-开发实施/               # 开发规范
│   ├── 06-测试验收/               # 测试策略
│   ├── 07-部署上线/               # 部署方案
│   └── ... (更多文档)
│
├── pom.xml                        # Maven 根 POM
├── package.json                   # Node.js workspace 配置
├── Makefile                       # 开发命令集
├── docker-compose.yml             # 本地开发环境 (根级)
├── .github/workflows/             # CI/CD 工作流
├── .gitignore
├── README.md                      # 本文件
├── CONTRIBUTING.md                # 贡献指南
├── CODE_OF_CONDUCT.md             # 行为规范
└── LICENSE                        # Apache 2.0
```

---

## ⚡ 快速开始

### 前置要求

```bash
# 系统环境
OS: Linux (CentOS 7+) / macOS / Windows WSL2
CPU: 4核+
RAM: 8GB+
Disk: 50GB+ (Docker 镜像)

# 必需工具
Java: 21+ (JDK 21 LTS)
Maven: 3.9+
Node: 18+ (npm 9+)
Docker: 20.10+ (Docker Compose 2.0+)

# 快速检查
java -version        # 确保输出 Java 21
mvn -version        # Maven 3.9+
node -v              # 18+
docker --version     # 20.10+
```

### 🚀 一键启动（推荐）

```bash
# 1. 克隆仓库
git clone https://github.com/liuhongke985/smartwin.git
cd smartwin

# 2. 启动全部基础设施 (MySQL/Redis/ES/Neo4j/Nacos/RocketMQ/MinIO)
make docker-up

# 3. 初始化数据库
make db-init

# 4. 编译后端
make install

# 5. 启动后端服务 (新终端)
make start-gateway
make start-smartdata
make start-smartchain

# 6. 启动前端 (新终端)
make dev-sd   # SmartData 前端 (http://localhost:5174)
make dev-sc   # SmartChain 前端 (http://localhost:5173)

# 7. 访问应用
# 用户名: admin
# 密码: admin123
```

### 📋 详细安装步骤

参考 [QUICK_START.md](DocDesign/02-项目启动/QUICK_START.md)

---

## 🏗️ 架构亮点

### 微服务架构
```
用户请求
  ↓
网关 (9000)
  ├→ SmartData (8081)
  ├→ SmartChain (8082)
  └→ SmartWin (8083)
  ↓
Nacos (服务注册)
  ↓
业务服务
  ├→ 数据采集 (50+ 数据源)
  ├→ 质量检测 (200+ 规则库)
  ├→ 模型注册 (版本管理)
  └→ 性能监控 (实时指标)
  ↓
中间件
  ├→ MySQL (元数据)
  ├→ Redis (缓存)
  ├→ Elasticsearch (日志)
  ├→ Neo4j (血缘关系)
  └→ RocketMQ (消息)
```

### AI 赋能全流程
```
用户需求 (自然语言)
  ↓ LangChain4j 理解
  ↓
Agent 编排
  ├→ 需求分析 Agent
  ├→ 规则生成 Agent
  ├→ 验证 Agent
  └→ 部署 Agent
  ↓
自动化执行
  ├→ 数据质量规则自动生成
  ├→ 模型异常自动诊断
  ├→ 修复建议自动生成
  └→ 报告自动输出
```

### 国产全栈适配
```
硬件层: 鲲鹏/飞腾/海光 → 多架构 Docker 镜像
系统层: UOS/麒麟/openEuler → 自适应探测
数据库: DM8/Kingbase/openGauss → 方言自动适配
算法层: SM2/SM3/SM4/SM9 → 国密完全支持
```

---

## 📊 与竞品对标

| 维度 | SmartWin | 华为 DataArts | 阿里 DataWorks | 百分点 AI-DG |
|------|----------|--------------|----------------|------------|
| **数据治理** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **模型治理** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **AI 智能化** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **国产适配** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **成本** | ¥150w-300w | ¥500w+ | ¥200w+ | ¥200w+ |

**SmartWin 优势**:
- 🎯 唯一同时覆盖数据+模型治理的平台
- 🔐 国产全栈深度适配 (政府采购首选)
- 🤖 AI 一句话自动化 (降低 80% 人力成本)
- 💰 成本低 40-60% (同类竞品中最便宜)
- 🚀 技术栈领先 5 年 (JDK21 + Spring Boot 3)

详见 [COMPETITOR_ANALYSIS.md](DocDesign/11-产品方案/COMPETITOR_ANALYSIS.md)

---

## 🎯 产品路线图

### Q3 2026 (MVP 版本)
- ✅ 基础功能框架
- ✅ 数据采集与元数据
- ✅ 基础质量检测

### Q4 2026 (Alpha 版本)
- 🚀 AI 规则生成上线 ⭐
- 🚀 模型注册与版本管理
- 🚀 5-10 个内测客户

### Q1-Q2 2027 (Beta 版本)
- 📈 数据治理功能 90% 成熟
- 📈 模型治理完整
- 📈 10-15 个付费客户

### Q3-Q4 2027 (正式商用 v1.0)
- 🎉 年收入 ¥500w-1000w
- 🎉 生态初步形成
- 🎉 行业方案包

### 2028 年 (v2.0 & 生态完善)
- 🌟 年收入 ¥5000w+
- 🌟 50+ 生态伙伴
- 🌟 国际版本发布

详见 [PRODUCT_ROADMAP.md](DocDesign/11-产品方案/PRODUCT_ROADMAP.md)

---

## 📖 文档导航

| 文档 | 对象 | 用途 |
|------|------|------|
| [TECH_ARCHITECTURE.md](DocDesign/04-系统设计/TECH_ARCHITECTURE.md) | 架构师 | 技术全景设计 |
| [COMPETITOR_ANALYSIS.md](DocDesign/11-产品方案/COMPETITOR_ANALYSIS.md) | 产品/商务 | 竞品对标 |
| [PRODUCT_ROADMAP.md](DocDesign/11-产品方案/PRODUCT_ROADMAP.md) | 产品经理 | 18 月路线图 |
| [QUICK_START.md](DocDesign/02-项目启动/QUICK_START.md) | 开发者 | 5 分钟启动 |
| [SMARTWIN_DOC_INDEX.md](DocDesign/00-文档总纲/SMARTWIN_DOC_INDEX.md) | 所有人 | 文档导航 |

---

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

详见 [CONTRIBUTING.md](CONTRIBUTING.md)

---

## 📞 联系与支持

- 📧 Email: support@smartwin.io
- 💬 讨论: [GitHub Discussions](https://github.com/liuhongke985/smartwin/discussions)
- 🐛 问题: [GitHub Issues](https://github.com/liuhongke985/smartwin/issues)
- 📖 文档: [完整文档](DocDesign/00-文档总纲/SMARTWIN_DOC_INDEX.md)

---

## 📄 License

本项目采用 [Apache License 2.0](LICENSE) 开源协议。

Copyright © 2026 SmartWin Team. All rights reserved.

---

## 🌟 Star History

如果您觉得这个项目有帮助，请给个 Star ⭐

```bash
# 克隆仓库
git clone https://github.com/liuhongke985/smartwin.git

# 进入目录
cd smartwin

# 查看所有文档
cat DocDesign/00-文档总纲/SMARTWIN_DOC_INDEX.md
```

---

**最后更新**: 2026-07-27 | **版本**: 1.1.0 | **维护者**: @liuhongke985
