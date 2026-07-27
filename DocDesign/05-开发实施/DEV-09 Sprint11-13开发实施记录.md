# Sprint 11-13 阶段四开发实施记录

## 文档控制

| 信息项 | 内容 |
|--------|------|
| **文档编号** | DEV-09 |
| **文档版本** | V1.0 |
| **创建日期** | 2026-07-08 |
| **文档状态** | 正式发布 |
| **文档负责人** | 项目经理 |

---

## 1. 总览

### 1.1 阶段目标

| Sprint | 主题 | 任务数 | 完成状态 |
|:------:|------|:------:|:--------:|
| S11 | 集成测试与性能验证 | 8 | ✅ |
| S12 | 信创环境适配 | 8 | ✅ |
| S13 | 生产部署与交付 | 9 | ✅ |
| **合计** | | **25** | **✅** |

### 1.2 交付物清单

| 编号 | 交付物 | 类型 | 路径 |
|:----:|--------|:----:|------|
| 1 | ES搜索集成测试 | 测试 | `catalog-service/src/test/.../EsSearchServiceTest.java` |
| 2 | SQL执行安全校验测试 | 测试 | `dataservice-service/src/test/.../SqlExecutionServiceTest.java` |
| 3 | Neo4j血缘服务测试 | 测试 | `lineage-service/src/test/.../Neo4jLineageServiceTest.java` |
| 4 | Neo4j初始化Cypher脚本 | 脚本 | `infra/scripts/neo4j-init.cypher` |
| 5 | 数据源密码SM4加密 | 代码 | `SqlExecutionServiceImpl.java` |
| 6 | Nacos动态路由配置 | 代码 | `NacosDynamicRouteConfig.java` |
| 7 | Gatling压测脚本 | 脚本 | `infra/scripts/gatling/SmartWinStressTest.scala` |
| 8 | JMeter压测脚本 | 脚本 | `infra/scripts/jmeter/SmartWin_Stress_Test.jmx` |
| 9 | 达梦DM8迁移脚本 | SQL | `infra/sql/dm8-schema.sql` |
| 10 | 信创ARM64 Dockerfile | 部署 | `infra/docker/Dockerfile.xinchuang` |
| 11 | 生产Docker Compose | 部署 | `infra/docker/docker-compose.yml` |
| 12 | K8s Helm Chart | 部署 | `infra/helm/` |
| 13 | Prometheus监控配置 | 配置 | `infra/docker/prometheus/prometheus.yml` |
| 14 | 告警规则 | 配置 | `infra/docker/prometheus/alert-rules.yml` |
| 15 | Loki日志聚合配置 | 配置 | `infra/docker/loki/loki-config.yml` |
| 16 | Promtail采集配置 | 配置 | `infra/docker/loki/promtail-config.yml` |
| 17 | Grafana数据源&看板 | 配置 | `infra/docker/grafana/` |
| 18 | 数据库种子数据 | SQL | `infra/sql/seed-data.sql` |
| 19 | 生产部署手册 | 文档 | `DocDesign/06-部署运维/DEP-01` |
| 20 | 运维手册 | 文档 | `DocDesign/06-部署运维/OPS-01` |

---

## 2. Sprint 11: 集成测试与性能验证

### 2.1 S11-01 全链路集成测试用例

**新增测试类**：

| 测试类 | 测试场景 | 用例数 |
|--------|----------|:------:|
| `EsSearchServiceTest` | ES降级策略、空结果返回、索引操作 | 5 |
| `SqlExecutionServiceTest` | SQL注入防护（DROP/DELETE/UPDATE/INSERT/分号注入） | 10 |
| `Neo4jLineageServiceTest` | Neo4j降级策略、图查询/影响分析降级 | 6 |

**修复已有测试**：
- `CatalogServiceTest`：适配S10新增的`EsSearchService`依赖注入

### 2.2 S11-03 Neo4j数据初始化

创建 `neo4j-init.cypher` 脚本，包含：
- 唯一约束与索引创建
- 示例血缘节点（ODS→DWD→DWS→ADS 四层）
- 血缘关系边（ETL转换链路）
- 数据验证查询

### 2.3 S11-05 数据源密码SM4加密

**实现方案**：
- 引入 `common-crypto-gm` 依赖到 `dataservice-service`
- `SqlExecutionServiceImpl` 新增 `CryptoFacade` 依赖
- 密码存储格式：`ENC(Base64密文)`
- 支持 SM4（信创）和 AES（标准）双模式自动切换
- `DataServiceController` 创建数据源时自动加密密码
- 兼容明文密码（旧数据平滑迁移）

**配置项**：
```yaml
platform:
  crypto:
    mode: ${CRYPTO_MODE:standard}    # gm=国密 standard=标准
    datasource-key: ${DS_CRYPTO_KEY:smartwin-ds-key16}
```

### 2.4 S11-06 网关动态路由Nacos集成

- 创建 `NacosDynamicRouteConfig` 实现 `RouteDefinitionLocator`
- 路由规则存储在 Nacos Data ID: `gateway-routes.json`
- 静态路由保留为降级备份
- 网关 `application.yml` 增加动态路由配置说明

### 2.5 S11-07 性能压测脚本

**Gatling脚本** (`SmartWinStressTest.scala`)：
- 5个压测场景：ES搜索、SQL执行、质量检测、模型查询、血缘图查询
- 渐进式注入：rampUsers → constantUsersPerSec
- 断言标准：P95<3s、平均RT<500ms、成功率>95%

**JMeter脚本** (`SmartWin_Stress_Test.jmx`)：
- 2个线程组：ES搜索(50并发×20轮)、SQL执行(30并发×15轮)
- 参数化测试数据 (`search_keywords.csv`)
- 汇总报告监听器

---

## 3. Sprint 12: 信创环境适配

### 3.1 S12-02 达梦DM8数据库适配

创建 `dm8-schema.sql` 迁移脚本：
- **数据类型映射**：MySQL `AUTO_INCREMENT` → DM8 `IDENTITY(1,1)`、`TEXT` → `CLOB`
- **语法兼容**：`ON DUPLICATE KEY UPDATE` → `MERGE INTO`
- **建表DDL**：智数模块5张核心表（数据资产、数据源、质量任务、血缘节点、血缘边）
- **初始化数据**：管理员账号、角色、权限（DM8 MERGE INTO 语法）
- 兼容模式配置：`COMPATIBLE_MODE = 4`（MySQL兼容）

### 3.2 S12-07 信创ARM64镜像构建

创建 `Dockerfile.xinchuang`：
- **多架构支持**：`--platform=linux/arm64`（鲲鹏/飞腾）
- **基础镜像**：`eclipse-temurin:17-jre-jammy`（ARM64可用）
- **语言环境**：中文UTF-8、上海时区
- **JVM优化**：G1GC + StringDeduplication + HeapDump
- **国密默认启用**：`CRYPTO_MODE=gm`
- **健康检查**：`curl /actuator/health`

构建命令：
```bash
docker buildx build --platform linux/arm64 \
  --build-arg JAR_FILE=app.jar \
  -t smartwin-service:latest-arm64 \
  -f Dockerfile.xinchuang .
```

---

## 4. Sprint 13: 生产部署与交付

### 4.1 S13-02 Docker Compose一键编排

创建生产级 `docker-compose.yml`：
- **全量服务编排**：7中间件 + 8微服务 + 4监控组件 + 前端
- **健康检查**：所有服务配置 healthcheck
- **依赖编排**：`depends_on.condition: service_healthy`
- **环境变量管理**：`.env` 文件统一管理密码
- **资源限制**：MySQL连接池、Redis内存策略
- **网络隔离**：`smartwin-net` Bridge 网络
- **数据持久化**：9个命名Volume

### 4.2 S13-03 K8s Helm Chart

创建完整 Helm Chart (`infra/helm/`)：

| 文件 | 说明 |
|------|------|
| `Chart.yaml` | Chart元数据 |
| `values.yaml` | 全局配置（中间件+微服务+监控+Ingress） |
| `templates/deployments.yaml` | 22个微服务自动生成Deployment+Service |
| `templates/configmap.yaml` | 统一ConfigMap + Secret |
| `templates/ingress.yaml` | Ingress路由（API+前端） |
| `templates/monitoring.yaml` | Prometheus+Grafana部署 |

### 4.3 S13-04 监控告警配置

**Prometheus**：
- 5个Job分组：网关、共享服务、智数服务、智链服务、中间件
- 自监控 + Node Exporter

**告警规则** (`alert-rules.yml`)：
| 告警组 | 告警数 | 覆盖场景 |
|--------|:------:|----------|
| service_availability | 2 | 服务下线、5xx错误率 |
| jvm_alerts | 3 | 堆内存、GC停顿、死锁 |
| middleware_alerts | 3 | MySQL连接、Redis内存、ES集群 |
| business_alerts | 2 | API延迟、SQL慢查询 |

**Loki + Promtail**：
- Docker容器日志自动采集
- 应用日志正则解析（时间/级别/线程/Logger/消息）
- 日志保留30天
- Grafana数据源自动配置

**Grafana看板** (`smartwin-overview.json`)：
- 服务在线状态、API QPS、P95延迟
- JVM堆内存、5xx错误率
- MySQL连接数、Redis内存、ES健康
- GC停顿时间

### 4.4 S13-05 数据库初始化种子数据

创建 `seed-data.sql`：
- **权限初始化**：11个一级菜单 + 17个二级按钮权限
- **角色权限关联**：超管全权限、数据工程师（排除系统管理）、安全审计员（查看+安全+审计）
- **组织架构**：集团→中心→部门→团队 4层结构
- **默认用户**：admin/admin123、data_engineer/data123、security_auditor/sec123
- **脱敏规则**：手机号/身份证/邮箱/银行卡/姓名 5种脱敏模式
- **安全分级**：4级数据安全分级标准

### 4.5 S13-01 生产环境部署手册

创建 `DEP-01 生产环境部署手册`：
- 部署架构图与拓扑
- 硬件/软件/信创环境要求
- Docker Compose 部署步骤（构建→配置→启动→验证）
- K8s Helm 部署步骤
- 信创环境专项（DM8部署、ARM64构建、国密配置）
- 网络与端口规划
- 部署检查清单（10项）
- 回滚方案

### 4.6 S13-06 运维手册

创建 `OPS-01 运维手册`：
- 日常运维（状态检查、中间件巡检）
- 故障排查（6类常见故障：启动失败、502/503、DB连接、ES无结果、Neo4j失败、AI无响应）
- 备份恢复（MySQL/Redis/ES/Neo4j 全量备份+恢复）
- 扩容缩容（Docker Compose / K8s / 中间件）
- 版本升级（滚动升级流程）
- 安全运维（密码轮换、证书更新、日志清理）
- 监控告警响应（级别+常见告警处理矩阵）
- 每日运维检查清单（9项）

---

## 5. 质量指标

| 指标 | 目标 | 实际 |
|------|------|------|
| 集成测试用例数 | ≥20 | 21 (ES:5 + SQL:10 + Neo4j:6) |
| Lint错误 | 0 | 0 |
| 告警规则数 | ≥8 | 10 |
| Grafana面板数 | ≥1 | 1（9个Panel） |
| 部署文档页数 | ≥30 | ~40页 |
| 运维文档页数 | ≥20 | ~30页 |
| Docker服务编排 | 全量 | 20+服务 |
| Helm模板 | ≥4 | 4个模板 |

---

## 6. 技术决策记录

| 决策 | 选项 | 选择 | 原因 |
|------|------|------|------|
| 密码加密格式 | 1.密文直接存储 2.`ENC()`前缀 | `ENC()`前缀 | 明确标识加密/明文，支持平滑迁移 |
| 压测工具 | 1.JMeter 2.Gatling | 两者都提供 | JMeter易用+Gatling高性能 |
| Helm模板策略 | 1.逐服务编写 2.range循环 | range循环 | 减少代码量，统一配置 |
| 监控日志方案 | 1.ELK 2.PLG(Promtail+Loki+Grafana) | PLG | 轻量级，与Prometheus共用Grafana |
| DM8兼容方式 | 1.重写SQL 2.方言适配+DDL修正 | 方言适配+DDL修正 | common-dm8已处理大部分，仅修正DDL差异 |

---

## 7. 下一阶段建议（已完成）

| 项目 | 建议 | 优先级 | 完成状态 | 实施Sprint |
|------|------|:------:|:--------:|:----------:|
| 集成测试CI化 | 将集成测试纳入GitHub Actions流水线 | 高 | ✅ 已完成 | S14 |
| HPA自动扩容 | K8s HorizontalPodAutoscaler配置 | 高 | ✅ 已完成 | S14 |
| 服务网格 | 引入Istio实现mTLS+可观测性 | 中 | ✅ 已完成 | S14 |
| 数据库读写分离 | MySQL主从+ShardingSphere | 中 | ✅ 已完成 | S15 |
| 灰度发布 | Gateway+Nacos实现金丝雀发布 | 中 | ✅ 已完成 | S15 |
| 安全合规等保 | 等保三级测评整改 | 高 | ✅ 已完成 | S15 |

> 以上建议已在 Sprint 14-15 优化加固阶段全部实施完成，详见 `DEV-10 Sprint14-15优化加固实施记录.md`。
