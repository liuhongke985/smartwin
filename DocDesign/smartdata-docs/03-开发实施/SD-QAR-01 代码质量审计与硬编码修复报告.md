# 代码质量审计与硬编码修复报告

| 属性 | 内容 |
|------|------|
| 文档编号 | SD-QAR-01 |
| 文档名称 | 代码质量审计与硬编码修复报告 |
| 版本号 | V1.0.0 |
| 状态 | 已完成 |
| 审计日期 | 2026-07-10 |
| 审计范围 | SmartWin + SmartChain + SmartData 三套系统全量代码 |

---

## 1. 审计概述

### 1.1 审计目标

对三套系统（智赢SmartWin、智链SmartChain、智数SmartData）进行代码质量审计，识别：
- 硬编码值（URL、密码、密钥、端口等）
- 服务间耦合问题
- 常见开发问题（console.log、TODO/FIXME、缺失错误处理等）
- 独立部署能力与无缝集成能力评估

### 1.2 审计方法

| 工具 | 用途 |
|------|------|
| 语义搜索 (grep) | 全量扫描硬编码模式（http://localhost、password、secret、jwt等） |
| 文件审查 | 逐文件审查配置文件、Java源码、前端源码 |
| 架构分析 | 分析服务间依赖关系、配置外部化程度 |

---

## 2. 审计发现与修复清单

### 2.1 JWT密钥硬编码（严重 - 安全漏洞）

| 文件 | 问题 | 修复方式 |
|------|------|---------|
| `gateway/application.yml` | `jwt.secret: smartwin-jwt-secret-key-2026-...` 明文 | 改为 `${JWT_SECRET:}` 环境变量引用 |
| `auth-service/application.yml` | 同上 | 同上 |
| `system-service/application.yml` | 同上 | 同上 |
| `JwtTokenProvider.java` | `@Value("${jwt.secret:smartwin-jwt-...}")` 硬编码回退默认值 | 移除回退默认值，添加 `@PostConstruct` 启动时校验 |
| `application-test.yml` | 测试环境JWT密钥明文 | 改为 `${JWT_SECRET:test-jwt-...}` 环境变量引用 |

**修复说明**：
- 移除所有明文JWT密钥，统一使用 `${JWT_SECRET:}` 环境变量注入
- `JwtTokenProvider` 添加启动时校验：密钥为空或长度不足256位时抛出 `IllegalStateException` 阻止启动
- 测试环境保留环境变量回退默认值（仅用于测试）

### 2.2 数据库/Redis密码硬编码（严重 - 安全漏洞）

| 文件 | 问题 | 修复方式 |
|------|------|---------|
| `auth-service/application.yml` | `password: smartwin123` MySQL/Redis明文密码 | 改为 `${DB_PASSWORD:}` / `${REDIS_PASSWORD:}` 环境变量引用 |
| `system-service/application.yml` | 同上 | 同上 |
| `application-dev.yml` | `password: smartwin123` + 国密SM2/SM4密钥明文 | 全部改为环境变量引用 |
| `infra/helm/values.yaml` | `SmartWin@2026` 中间件密码明文 | 改为 `existingSecret` 引用 K8s Secret |
| `docker-compose.yml` | `DS_CRYPTO_KEY` 硬编码默认值 | 改为 `${DS_CRYPTO_KEY:?...}` 强制环境变量 |

**修复说明**：
- 所有数据库/Redis/MinIO/Neo4j密码统一使用环境变量注入
- Helm Chart 改为 `existingSecret` 模式，密码通过 K8s Secret Manager 注入
- Docker Compose 加密密钥改为强制环境变量（无默认值）
- 新增 `.env.example` 文件文档化所有所需环境变量
- 开发环境国密密钥也改为环境变量引用

### 2.3 Dashboard服务URL硬编码（中等 - 可维护性）

| 文件 | 问题 | 修复方式 |
|------|------|---------|
| `DashboardOverviewService.java` | 17处 `http://xxx-service/api/...` 硬编码URL字符串 | 创建 `DashboardServiceEndpointsProperties` 配置类，所有URL外部化到 `application.yml` |

**修复说明**：
- 新建 `DashboardServiceEndpointsProperties.java` 配置属性类
- 新建 `dashboard-service/application.yml` 配置文件
- 重构 `DashboardOverviewService.java` 使用配置注入的URL
- 同步更新 `DashboardOverviewServiceTest.java` 测试文件
- 所有URL支持通过 Nacos 配置中心动态覆盖

### 2.4 Properties类默认值硬编码（中等 - 可维护性）

| 文件 | 问题 | 修复方式 |
|------|------|---------|
| `StorageProperties.java` | `endpoint = "http://localhost:9000"` + `accessKey = "minioadmin"` + `secretKey = "minioadmin"` | 改为 `${platform.storage.minio.endpoint:...}` 环境变量引用 |
| `AiEngineProperties.java` | `baseUrl = "http://localhost:11434/v1"` | 改为 `${platform.ai.base-url:...}` 环境变量引用 |

### 2.5 前端硬编码与console.log（低 - 代码规范）

| 文件 | 问题 | 修复方式 |
|------|------|---------|
| `SystemSettingsView.vue` | `aiEngineUrl: 'http://localhost:8000'` 硬编码 | 改为空字符串，由后端配置返回 |
| `main.ts` | `console.log` 无 eslint 抑制 | 添加 `// eslint-disable-next-line no-console` |
| `MetadataView.vue` | `console.log('Edit:', item)` 调试代码残留 | 替换为 TODO 注释占位 |

### 2.6 Helm模板敏感信息泄漏（严重 - 安全漏洞）

| 文件 | 问题 | 修复方式 |
|------|------|---------|
| `configmap.yaml` | Secret 中 `stringData` 直接引用 `.Values.mysql.rootPassword` 等明文密码 | 改为占位模板，实际密码通过外部 Secret Manager 注入 |
| `deployments.yaml` | `DS_CRYPTO_KEY` 直接通过 `env` 注入明文 | 改为 `envFrom.secretRef` 批量注入 |

---

## 3. 独立部署与无缝集成评估

### 3.1 独立部署能力

| 系统 | 独立部署 | 依赖说明 |
|------|:--------:|---------|
| SmartWin (智赢) | ✅ | 仅依赖自身共享服务（auth/system/audit等） |
| SmartChain (智链) | ✅ | 依赖共享服务层，可通过 Profile 配置独立运行 |
| SmartData (智数) | ✅ | 依赖共享服务层，可通过 Profile 配置独立运行 |

**评估结论**：三套系统均可独立部署，通过 Spring Profile 控制 `integrated` / `standalone` 模式。

### 3.2 无缝集成能力

| 集成维度 | 状态 | 说明 |
|---------|:----:|------|
| SSO单点登录 | ✅ | 共享 JWT Token + Redis Session |
| 服务发现 | ✅ | 统一 Nacos 注册中心 |
| 配置中心 | ✅ | 统一 Nacos Config，环境变量外部化 |
| API网关 | ✅ | 统一 Spring Cloud Gateway (9000) 路由分发 |
| 消息队列 | ✅ | 共享 RocketMQ Topic/Group 规范 |
| 审计日志 | ✅ | Kafka 异步投递至 audit-service |
| 监控告警 | ✅ | Prometheus + Grafana 统一监控 |

### 3.3 服务间通信解耦

| 通信方式 | 使用情况 | 评估 |
|---------|---------|------|
| RestTemplate + 服务名 | ✅ | 通过 Nacos 服务发现，URL外部化到配置 |
| Kafka 异步消息 | ✅ | Topic/Group 规范化，消费者自动 ack |
| Redis 共享缓存 | ✅ | Key 命名规范统一 |

---

## 4. 修复统计

| 类别 | 修复文件数 | 修复问题数 | 严重等级 |
|------|:---------:|:---------:|:--------:|
| JWT密钥硬编码 | 5 | 5 | 严重 |
| 数据库/Redis密码 | 6 | 12 | 严重 |
| 服务URL硬编码 | 4 | 17 | 中等 |
| Properties默认值 | 2 | 5 | 中等 |
| 前端硬编码 | 3 | 3 | 低 |
| Helm模板 | 3 | 5 | 严重 |
| 新增文件 | 3 | - | - |
| **合计** | **26** | **47** | - |

### 新增文件

| 文件 | 用途 |
|------|------|
| `DashboardServiceEndpointsProperties.java` | Dashboard服务端点配置属性类 |
| `dashboard-service/application.yml` | Dashboard服务应用配置 |
| `.env.example` | Docker Compose 环境变量模板 |

---

## 5. 后续建议

### 5.1 短期（本Sprint）
- [ ] 配置 CI/CD 流水线扫描敏感信息泄漏（如 git-secrets、truffleHog）
- [ ] 在 `.gitignore` 中添加 `.env` 文件
- [ ] 编写部署文档说明环境变量配置方法

### 5.2 中期（下2个Sprint）
- [ ] 引入 Spring Cloud Config Server 或 Vault 作为集中式密钥管理
- [ ] 实现配置加密解密（Jasypt 或 国密SM4）
- [ ] 前端组件统一使用 CSS 变量（Design Tokens），消除硬编码颜色值

### 5.3 长期
- [ ] 引入 Sealed Secrets 或 External Secrets Operator 管理 K8s Secret
- [ ] 实现配置变更审计追踪
- [ ] 定期执行安全扫描（SonarQube + Dependency Check）

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|---------|
| V1.0.0 | 2026-07-10 | SmartWin开发组 | 初始版本，完成全量审计与修复 |

---

> **文档结束** — 代码质量审计与硬编码修复报告 V1.0.0
