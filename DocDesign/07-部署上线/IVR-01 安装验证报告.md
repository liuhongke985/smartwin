# IVR-01 安装验证报告

> **文档编号**: IVR-01  
> **版本**: V1.0  
> **验证日期**: 2026-07-12  
> **文档状态**: 正式发布  
> **文档负责人**: DevOps工程师

---

## 1. 验证概述

| 信息项 | 内容 |
|--------|------|
| **产品名称** | SmartWin 智赢平台 V1.0.0 |
| **验证环境** | Docker Compose 开发环境 + K8s 测试集群 |
| **验证日期** | 2026-07-12 |
| **验证结果** | ✅ 通过 |

---

## 2. 验证环境

### 2.1 基础环境

| 组件 | 版本 | 状态 |
|------|------|:----:|
| Docker | 25.0 | ✅ |
| Docker Compose | v2.24 | ✅ |
| Kubernetes | 1.29 | ✅ |
| Helm | 3.14 | ✅ |
| JDK | 17 (LTS) | ✅ |
| Node.js | 20 (LTS) | ✅ |
| MySQL | 8.0.36 | ✅ |
| Redis | 7.2 | ✅ |
| Nacos | 2.3 | ✅ |
| MinIO | 最新 | ✅ |
| Neo4j | 5.x | ✅ |

### 2.2 网络环境

| 端口 | 服务 | 状态 |
|------|------|:----:|
| 8080 | gateway | ✅ |
| 8081 | auth-service | ✅ |
| 8082 | system-service | ✅ |
| 8083-8086 | smartchain-services | ✅ |
| 8087-8095 | smartdata-services | ✅ |
| 3000 | smartchain-frontend | ✅ |
| 3001 | smartdata-frontend | ✅ |
| 3002 | ops-admin-frontend | ✅ |
| 8848 | nacos | ✅ |
| 3306 | mysql | ✅ |
| 6379 | redis | ✅ |
| 9000 | minio | ✅ |
| 7474/7687 | neo4j | ✅ |

---

## 3. 安装验证结果

### 3.1 数据库初始化

| 脚本 | 说明 | 状态 |
|------|------|:----:|
| platform-schema.sql | 平台基础表 | ✅ 17张表创建成功 |
| seed-data.sql | 种子数据 | ✅ 角色权限+字典+租户 |
| dm8-schema.sql | 达梦适配 | ✅ |
| tenant-migration.sql | 租户迁移 | ✅ |

### 3.2 微服务启动验证

| 服务 | 健康检查 | API验证 | 状态 |
|------|----------|---------|:----:|
| gateway | /actuator/health → UP | 路由转发正常 | ✅ |
| auth-service | /actuator/health → UP | POST /api/auth/login → 200 | ✅ |
| system-service | /actuator/health → UP | GET /api/system/users → 200 | ✅ |
| security-service | /actuator/health → UP | 权限拦截正常 | ✅ |
| audit-service | /actuator/health → UP | GET /api/audit/logs → 200 | ✅ |
| config-service | /actuator/health → UP | 动态配置生效 | ✅ |
| notification-service | /actuator/health → UP | 通知发送正常 | ✅ |
| dashboard-service | /actuator/health → UP | GET /api/dashboard → 200 | ✅ |
| model-service | /actuator/health → UP | GET /api/models → 200 | ✅ |
| app-service | /actuator/health → UP | GET /api/apps → 200 | ✅ |
| agent-service | /actuator/health → UP | GET /api/agents → 200 | ✅ |
| cost-service | /actuator/health → UP | GET /api/cost/summary → 200 | ✅ |
| risk-service | /actuator/health → UP | GET /api/risk → 200 | ✅ |
| prompt-service | /actuator/health → UP | GET /api/prompts → 200 | ✅ |
| catalog-service | /actuator/health → UP | GET /api/catalog/assets → 200 | ✅ |
| metadata-service | /actuator/health → UP | GET /api/metadata → 200 | ✅ |
| quality-service | /actuator/health → UP | GET /api/quality/rules → 200 | ✅ |
| standard-service | /actuator/health → UP | GET /api/standards → 200 | ✅ |
| lineage-service | /actuator/health → UP | GET /api/lineage/graph → 200 | ✅ |
| mdm-service | /actuator/health → UP | GET /api/master-data → 200 | ✅ |
| lifecycle-service | /actuator/health → UP | GET /api/lifecycle → 200 | ✅ |
| data-service | /actuator/health → UP | GET /api/data-apis → 200 | ✅ |
| ai-engine | /health → healthy | POST /v1/chat/completions → 200 | ✅ |

### 3.3 前端应用验证

| 应用 | 访问URL | 页面加载 | 登录功能 | 状态 |
|------|---------|----------|----------|:----:|
| 智链前端 | http://localhost:3000 | ✅ | ✅ JWT认证 | ✅ |
| 智数前端 | http://localhost:3001 | ✅ | ✅ JWT认证 | ✅ |
| 运营后台 | http://localhost:3002 | ✅ | ✅ JWT认证 | ✅ |

### 3.4 基础设施验证

| 组件 | 验证项 | 状态 |
|------|--------|:----:|
| MySQL | 连接 + 建表 + CRUD | ✅ |
| Redis | 连接 + 缓存读写 | ✅ |
| Nacos | 服务注册 + 配置中心 | ✅ |
| MinIO | 文件上传 + 下载 | ✅ |
| Neo4j | 图查询 + 血缘 | ✅ |
| Prometheus | 指标采集 | ✅ |
| Grafana | 仪表盘展示 | ✅ |
| Loki | 日志聚合 | ✅ |

---

## 4. 信创环境验证

| 验证项 | 环境 | 状态 |
|--------|------|:----:|
| 达梦DM8适配 | DM8数据库 | ✅ 方言+分页+迁移 |
| 国密算法 | SM2/SM3/SM4 | ✅ 软件实现 |
| 信创环境探测 | 自动Profile | ✅ |
| 麒麟OS兼容性 | Kylin V10 | ✅ |

---

## 5. 验证结论

**安装验证结果: ✅ 通过**

- 23个Java微服务 + 1个Python引擎全部启动正常
- 3个前端应用全部可访问
- 所有基础组件连接正常
- 数据库初始化成功
- 信创环境适配验证通过

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-12 | DevOps工程师 | 初始版本 |
