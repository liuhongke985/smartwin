# DEV-02 SmartWin智赢平台开发环境配置指南

> **文档编号**: DEV-02  
> **版本**: V2.0  
> **创建日期**: 2026-07-08  
> **文档状态**: 正式发布  
> **文档负责人**: DevOps工程师  
> **审批人**: 技术总监  

---

## 一、环境概览

| 环境 | 用途 | 地址 | 配置 |
|------|------|------|------|
| 本地开发 | 开发人员本地 | localhost | Docker Compose |
| 开发环境(DEV) | 联调测试 | dev.intelchain.local | K8s 3节点 |
| 测试环境(TEST) | QA测试 | test.intelchain.local | K8s 3节点 |
| 预发布(UAT) | 上线前验证 | uat.intelchain.local | K8s 5节点 |
| 生产(PROD) | 正式运行 | prod.intelchain.com | K8s 10+节点 |

---

## 二、本地开发环境

### 2.1 基础工具

| 工具 | 版本要求 | 用途 |
|------|---------|------|
| JDK | 17+ | Java运行时 |
| Node.js | 20+ | 前端构建 |
| Maven | 3.9+ | Java构建 |
| Docker | 24+ | 容器运行 |
| Docker Compose | 2.20+ | 本地编排 |
| Git | 2.40+ | 版本控制 |
| IDE: IntelliJ IDEA | 2024+ | 后端开发 |
| IDE: WebStorm/VS Code | 最新 | 前端开发 |

### 2.2 信创开发工具

| 工具 | 版本 | 用途 |
|------|------|------|
| 达梦DM8客户端 | 8.1+ | 信创数据库开发 |
| 国密工具包 | BouncyCastle 1.78+ | 国密算法调试 |
| 麒麟开发环境(可选) | V10 | 信创环境模拟 |

### 2.3 本地服务启动

```bash
# 1. 克隆代码
git clone git@gitlab.com:smartwin/intelchain.git
cd intelchain

# 2. 启动基础设施
cd infra/docker
docker-compose up -d postgres redis kafka neo4j elasticsearch minio

# 3. 后端启动
cd CodeProject/WebDesign
mvn clean install -DskipTests
# 启动网关
cd gateway && mvn spring-boot:run
# 启动各微服务（按需）

# 4. 前端启动
cd smartchain/smartchain-frontend
npm install
npm run dev
```

### 2.4 环境变量配置

```bash
# .env.local
DB_HOST=localhost
DB_PORT=5432
DB_NAME=intelchain
DB_USER=postgres
DB_PASS=postgres

REDIS_HOST=localhost
REDIS_PORT=6379

KAFKA_BROKERS=localhost:9092

NEO4J_URI=bolt://localhost:7687
NEO4J_USER=neo4j
NEO4J_PASS=neo4j

AI_API_KEY=your-api-key
AI_MODEL_PROVIDER=zhipu

JWT_SECRET=your-jwt-secret
```

---

## 三、数据库初始化

### 3.1 PostgreSQL

```bash
# 创建数据库
createdb intelchain
createdb intelchain_audit

# 执行Flyway迁移
mvn flyway:migrate -pl platform-common/common-db
mvn flyway:migrate -pl platform-services/auth-service
# ... 各服务依次执行
```

### 3.2 达梦DM8

```bash
# 使用达梦管理工具创建数据库实例
# 执行初始化SQL
cd infra/sql/dm8
sqlplus SYSDBA/SYSDBA@localhost:5236 @init.sql
```

### 3.3 Neo4j

```bash
# 创建约束
cypher-shell -u neo4j -p neo4j \
  "CREATE CONSTRAINT dataset_id IF NOT EXISTS FOR (d:Dataset) REQUIRE d.id IS UNIQUE"
```

---

## 四、代码结构

```
intelchain/
├── CodeProject/WebDesign/
│   ├── gateway/                    # API网关
│   ├── platform-common/            # 公共模块
│   │   ├── common-ai/              # AI能力
│   │   ├── common-crypto-gm/       # 国密算法
│   │   ├── common-db/              # 数据库适配
│   │   ├── common-db-multi/        # 多数据库
│   │   ├── common-dm8/             # 达梦适配
│   │   ├── common-gateway/         # 网关配置
│   │   ├── common-mq/              # 消息队列
│   │   ├── common-security/        # 安全框架
│   │   ├── common-storage/         # 存储服务
│   │   ├── common-util/            # 工具类
│   │   └── common-xinchuang/       # 信创适配
│   ├── platform-services/          # 平台服务
│   │   ├── audit-service/          # 审计服务
│   │   ├── auth-service/           # 认证服务
│   │   ├── config-service/         # 配置服务
│   │   ├── dashboard-service/      # 看板服务
│   │   ├── notification-service/   # 通知服务
│   │   ├── security-service/       # 安全服务
│   │   └── system-service/         # 系统服务
│   ├── smartchain/                 # 智链产品线
│   │   ├── smartchain-ai-engine/   # AI引擎
│   │   ├── smartchain-frontend/    # 前端
│   │   └── smartchain-services/    # 微服务
│   └── shared-components/          # 前端共享组件
├── infra/                          # 基础设施
│   ├── docker/                     # Docker配置
│   ├── scripts/                    # 脚本
│   └── sql/                        # SQL脚本
└── DocDesign/                      # 项目文档
```

---

## 五、调试指南

### 5.1 后端调试

| 场景 | 方法 |
|------|------|
| 本地调试 | IDEA Debug模式启动 |
| 远程调试 | `-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005` |
| 日志调试 | Logback配置，按模块调整日志级别 |
| SQL调试 | MyBatis日志开启`logging.level.com.smartwin=DEBUG` |

### 5.2 前端调试

| 场景 | 方法 |
|------|------|
| Vue DevTools | 浏览器插件 |
| 网络调试 | 浏览器Network面板 |
| 状态调试 | Pinia DevTools |
| API Mock | Vite proxy + Mock数据 |

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-08 | DevOps | 初始版本 |
| V2.0 | 2026-07-08 | DevOps | 补充信创开发环境和V2.0服务配置 |
