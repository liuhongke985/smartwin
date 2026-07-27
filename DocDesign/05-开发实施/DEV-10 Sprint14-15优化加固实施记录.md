# Sprint 14-15 优化加固阶段开发实施记录

## 文档控制

| 信息项 | 内容 |
|--------|------|
| **文档编号** | DEV-10 |
| **文档版本** | V1.0 |
| **创建日期** | 2026-07-08 |
| **文档状态** | 正式发布 |
| **文档负责人** | 项目经理 |

---

## 1. 总览

### 1.1 阶段目标

本阶段在 Sprint 11-13 生产交付基础上，实施6项优化加固任务，提升平台的可观测性、可扩展性、安全性和运维能力。

| 任务编号 | 任务 | 优先级 | 完成状态 |
|:--------:|------|:------:|:--------:|
| OPT-01 | 集成测试CI化 | 高 | ✅ |
| OPT-02 | HPA自动扩容 | 高 | ✅ |
| OPT-03 | 服务网格(Istio) | 中 | ✅ |
| OPT-04 | 数据库读写分离 | 中 | ✅ |
| OPT-05 | 灰度发布 | 中 | ✅ |
| OPT-06 | 安全合规等保三级 | 高 | ✅ |

---

## 2. OPT-01: 集成测试CI化

### 2.1 交付物清单

| 文件 | 类型 | 说明 |
|------|------|------|
| `.github/workflows/integration-test.yml` | CI流水线 | 5个Job: 集成测试/安全扫描/契约测试/E2E/测试门禁 |
| `infra/config/application-test.yml` | 测试配置 | 集成测试专用Profile（MySQL/Redis/ES/Neo4j） |
| `infra/security/dependency-check-suppressions.xml` | 安全配置 | OWASP依赖检查抑制规则 |
| `common-test/.../IntegrationTest.java` | 测试注解 | 集成测试基类注解 |

### 2.2 流水线架构

```
Push/PR → [集成测试(Testcontainers)] → [安全扫描(OWASP+Bandit+CodeQL+TruffleHog)] → [契约测试] → [E2E(Playwright)] → [测试门禁]
```

**集成测试矩阵**:
- ES搜索服务测试 (MySQL + ES容器)
- SQL执行安全测试 (MySQL容器)
- Neo4j血缘服务测试 (Neo4j容器)
- 国密加密测试
- 多数据库探测测试

**安全扫描矩阵**:
- Java: OWASP Dependency Check (CVSS≥7阻断)
- Python: Bandit (AI引擎)
- 全局: TruffleHog Secrets扫描
- 全局: GitHub CodeQL (Java/JS/Python)

### 2.3 质量门禁

| 门禁项 | 规则 | 阻断级别 |
|--------|------|:--------:|
| 集成测试 | 必须通过 | 🔴 阻断 |
| 安全扫描 | CRITICAL漏洞 | 🟡 警告 |
| 契约测试 | API规范一致 | 🟡 警告 |
| E2E测试 | 核心流程通过 | 🟡 警告 |

---

## 3. OPT-02: HPA自动扩容

### 3.1 交付物

| 文件 | 说明 |
|------|------|
| `infra/helm/templates/hpa.yaml` | HPA模板（range遍历所有微服务） |
| `infra/helm/values.yaml` | HPA全局配置 + 各服务覆盖配置 |

### 3.2 扩缩容策略

| 服务 | 最小 | 最大 | CPU阈值 | 内存阈值 | 特殊策略 |
|------|:----:|:----:|:-------:|:-------:|----------|
| gateway | 2 | 10 | 60% | 80% | 网关高敏感 |
| auth-service | 2 | 8 | 65% | 80% | 认证高可用 |
| catalog-service | 2 | 8 | 65% | 80% | 搜索高并发 |
| dataservice-service | 1 | 6 | 75% | 80% | SQL执行CPU密集 |
| 其他服务 | 1 | 5 | 70% | 80% | 默认策略 |

**扩容行为**: 30秒稳定窗口, 每次+100%或+4Pod, 快速扩容
**缩容行为**: 300秒稳定窗口, 每次-10%, 缓慢缩容

---

## 4. OPT-03: 服务网格 (Istio)

### 4.1 交付物

| 文件 | 说明 |
|------|------|
| `infra/helm/templates/istio.yaml` | Istio CRD模板（PeerAuth/Authz/DestinationRule/VirtualService/Telemetry） |
| `infra/scripts/install-istio.sh` | Istio一键安装脚本 |

### 4.2 安全策略

| 策略 | 配置 | 说明 |
|------|------|------|
| mTLS全网格加密 | STRICT模式 | 所有服务间通信加密 |
| 默认拒绝 | AuthorizationPolicy | 空spec=拒绝所有入站 |
| 命名空间内互通 | ALLOW规则 | 同namespace服务可互调 |
| 网关外部入口 | PERMISSIVE | 网关端口允许非mTLS |
| Prometheus采集 | 特许规则 | 监控命名空间可采集指标 |

### 4.3 可观测性

- **链路追踪**: Jaeger + 1%采样率 + 自定义Tag(platform/namespace)
- **指标增强**: 自定义指标(request_method/request_path/response_code)
- **可视化**: Kiali服务拓扑图

### 4.4 流量管理

- **负载均衡**: LEAST_REQUEST策略
- **离群检测**: 5次5xx→30秒剔除(最多50%)
- **连接池**: TCP 100连接 + HTTP 50pending/100req
- **重试**: 3次重试(5xx/reset/connect-failure)

---

## 5. OPT-04: 数据库读写分离

### 5.1 交付物

| 文件 | 说明 |
|------|------|
| `common-db-rw/pom.xml` | 模块POM(ShardingSphere-JDBC可选依赖) |
| `common-db-rw/.../annotation/Master.java` | 主库注解 |
| `common-db-rw/.../annotation/Slave.java` | 从库注解 |
| `common-db-rw/.../holder/RoutingHolder.java` | ThreadLocal路由上下文 |
| `common-db-rw/.../aspect/ReadWriteAspect.java` | AOP自动路由切面 |
| `common-db-rw/.../datasource/ReadWriteRoutingDataSource.java` | 路由数据源(轮询+降级) |
| `common-db-rw/.../config/ReadWriteDataSourceConfig.java` | 自动配置(一主多从) |
| `common-db-rw/.../ReadWriteSplittingTest.java` | 单元测试(10个用例) |
| `infra/config/shardingsphere-readwrite.yml` | ShardingSphere配置方案 |
| `infra/scripts/setup-mysql-replication.sh` | MySQL主从搭建脚本 |

### 5.2 路由规则

| 条件 | 路由 | 示例 |
|------|------|------|
| @Master注解 | 主库 | `@Master void create()` |
| @Slave注解 | 从库 | `@Slave void search()` |
| 方法名get/find/query/search开头 | 从库 | `getUserById()` |
| 方法名insert/update/delete开头 | 主库 | `updateAsset()` |
| 默认 | 主库 | 保证数据安全 |

### 5.3 双方案支持

| 方案 | 实现 | 优点 | 适用场景 |
|------|------|------|----------|
| 轻量级路由 | AbstractRoutingDataSource | 无额外依赖 | 单主一从/多从 |
| ShardingSphere | shardingsphere-jdbc-core | 功能全面 | 分库分表+读写分离 |

---

## 6. OPT-05: 灰度发布

### 6.1 交付物

| 文件 | 说明 |
|------|------|
| `gateway/.../CanaryReleaseFilter.java` | 网关灰度发布过滤器 |
| `gateway/application.yml` | 灰度配置项 |
| `infra/helm/templates/canary.yaml` | K8s灰度Deployment模板 |
| `infra/config/gateway-canary-rules.json` | Nacos灰度规则示例 |
| `infra/scripts/canary-manage.sh` | 灰度发布管理脚本 |

### 6.2 灰度策略

| 策略 | 触发条件 | 流量比例 |
|------|----------|:--------:|
| Header路由 | `x-canary: true` | 100%灰度 |
| 权重路由 | 随机数 < 权重 | 配置比例(如10%) |
| 用户白名单 | 用户ID在白名单中 | 100%灰度 |
| 路径白名单 | 请求路径匹配 | 100%灰度 |

### 6.3 发布流程

```
1. canary-manage.sh start <service>      → 启动灰度版本
2. canary-manage.sh weight <service> 10  → 10%流量到灰度
3. 观察监控指标（错误率/延迟/日志）
4. canary-manage.sh weight <service> 50  → 逐步增加流量
5. canary-manage.sh promote <service>    → 全量发布
   或 canary-manage.sh rollback <service> → 回滚
```

---

## 7. OPT-06: 安全合规等保三级

### 7.1 交付物

| 文件 | 说明 |
|------|------|
| `common-security/.../filter/XssProtectionFilter.java` | XSS防护过滤器 |
| `common-security/.../filter/SecurityHeadersFilter.java` | 安全响应头过滤器 |
| `common-security/.../filter/RateLimitFilter.java` | 请求限流+防暴破过滤器 |
| `common-security/.../config/SecurityConfig.java` | 安全配置集成(等保加固) |
| `DocDesign/07-安全合规/SEC-01 等保三级安全合规整改报告.md` | 等保三级整改报告 |

### 7.2 安全过滤器链

```
请求 → SecurityHeadersFilter → XssProtectionFilter → RateLimitFilter → JwtAuthenticationFilter → Controller
```

### 7.3 等保三级整改矩阵

| 等保要求 | 整改措施 | 实现文件 |
|----------|----------|----------|
| 身份鉴别 | BCrypt加密+失败锁定+Token过期 | `JwtTokenProvider` + `RateLimitFilter` |
| 访问控制 | RBAC三级权限+最小权限原则 | `SecurityConfig` + `seed-data.sql` |
| 安全审计 | 操作日志+日志完整性+180天保留 | `audit-service` + Loki |
| 通信安全 | HTTPS+国密+安全Header+HSTS | `SecurityHeadersFilter` + `CryptoFacade` |
| 入侵防范 | XSS防护+SQL注入防护+限流+依赖扫描 | `XssProtectionFilter` + `RateLimitFilter` |
| 数据安全 | SM4加密+脱敏+分级+备份 | `SqlExecutionServiceImpl` + `sec_masking_rule` |

### 7.4 安全响应头

| Header | 值 | 等保对应 |
|--------|-----|----------|
| X-Content-Type-Options | nosniff | 防MIME嗅探 |
| X-Frame-Options | DENY | 防点击劫持 |
| X-XSS-Protection | 1; mode=block | 浏览器XSS过滤 |
| Strict-Transport-Security | max-age=31536000 | 强制HTTPS |
| Content-Security-Policy | default-src 'self' | 内容安全策略 |
| Referrer-Policy | strict-origin-when-cross-origin | 防信息泄露 |

### 7.5 限流策略

| 限流维度 | 阈值 | 说明 |
|----------|------|------|
| 登录接口 | 5次/分钟 | 防暴力破解 |
| API接口 | 100次/分钟 | 防滥用 |
| IP全局 | 1000次/分钟 | 防DDoS |
| 登录失败锁定 | 5次失败→锁30分钟 | 防暴破 |

---

## 8. 质量指标

| 指标 | 目标 | 实际 |
|------|------|------|
| CI流水线Job数 | ≥4 | 5 (集成/安全/契约/E2E/门禁) |
| HPA覆盖服务数 | 全量 | 22个微服务 |
| Istio安全策略数 | ≥4 | 6 (PeerAuth/Authz/DestRule/VS/Telemetry×2) |
| 读写分离测试用例 | ≥8 | 10 |
| 灰度策略数 | ≥3 | 4 (Header/权重/白名单/路径) |
| 等保整改项 | ≥10 | 14项 |
| 新增安全过滤器 | ≥3 | 3 (XSS/Header/RateLimit) |
| Lint错误 | 0 | 0 |

---

## 9. 技术决策记录

| 决策 | 选项 | 选择 | 原因 |
|------|------|------|------|
| CI测试容器 | 1.Testcontainers 2.GA services | GA services | 免额外依赖，GA原生支持 |
| HPA指标 | 1.CPU 2.CPU+内存 3.自定义 | CPU+内存 | 覆盖主要资源维度 |
| 服务网格 | 1.Linkerd 2.Istio | Istio | 功能更全(mTLS+RBAC+流量管理) |
| 读写分离 | 1.ShardingSphere 2.自研路由 | 双方案 | 轻量路由优先+ShardingSphere可选 |
| 灰度方案 | 1.Istio VS 2.Gateway Filter | 双方案 | Gateway层+Istio层双重支持 |
| 限流实现 | 1.Guava 2.Redis | Redis | 分布式限流，支持多实例 |
