# Sprint 16-18 阶段六开发实施记录

## 文档控制

| 信息项 | 内容 |
|--------|------|
| **文档编号** | DEV-12 |
| **文档版本** | V1.0 |
| **创建日期** | 2026-07-08 |
| **文档状态** | 正式发布 |
| **文档负责人** | 项目经理 |

---

## 1. 总览

### 1.1 阶段目标

**智能化运营、性能深度优化、多租户SaaS化、正式验收交付**

| Sprint | 主题 | 任务数 | 完成状态 |
|:------:|------|:------:|:--------:|
| S16 | 智能化运营与AIOps | 6 | ✅ |
| S17 | 性能深度优化 | 8 | ✅ |
| S18 | 多租户SaaS化与正式验收 | 9 | ✅ |
| **合计** | | **23** | **✅** |

### 1.2 交付物清单

| 编号 | 交付物 | 类型 | 路径 |
|:----:|--------|:----:|------|
| 1 | AIOps AI客户端 | 代码 | `common-ai/.../client/AIOpsAiClient.java` |
| 2 | 告警分析结果DTO | 代码 | `common-ai/.../dto/AlertAnalysisResult.java` |
| 3 | SQL优化建议DTO | 代码 | `common-ai/.../dto/SqlOptimizationResult.java` |
| 4 | 日志分析结果DTO | 代码 | `common-ai/.../dto/LogAnalysisResult.java` |
| 5 | 容量预测服务 | 代码 | `dashboard-service/.../service/CapacityForecastService.java` |
| 6 | 异常检测服务 | 代码 | `dashboard-service/.../service/AnomalyDetectionService.java` |
| 7 | AIOps API控制器 | 代码 | `dashboard-service/.../controller/AIOpsController.java` |
| 8 | JVM调优参数配置 | 配置 | `infra/config/jvm-tuning.yml` |
| 9 | HikariCP连接池调优 | 配置 | `infra/config/hikari-tuning.yml` |
| 10 | Redis缓存策略工具 | 代码 | `common-util/.../utils/CacheStrategyUtils.java` |
| 11 | ES索引优化方案 | 配置 | `infra/config/es-index-optimization.yml` |
| 12 | 慢SQL治理方案 | 配置 | `infra/config/slow-sql-governance.yml` |
| 13 | 前端性能优化 | 代码 | `smartchain-frontend/vite.config.ts` |
| 14 | 多租户上下文 | 代码 | `common-util/.../entity/TenantContext.java` |
| 15 | 租户过滤器 | 代码 | `common-security/.../filter/TenantFilter.java` |
| 16 | 租户DB拦截器 | 代码 | `common-db/.../config/TenantDbConfig.java` |
| 17 | MyBatis-Plus租户集成 | 代码 | `common-db/.../config/MyBatisPlusConfig.java` |
| 18 | 租户实体 | 代码 | `system-service/.../entity/SysTenant.java` |
| 19 | 租户管理服务 | 代码 | `system-service/.../service/SysTenantService.java` |
| 20 | 租户管理API | 代码 | `system-service/.../controller/TenantController.java` |
| 21 | 租户数据库迁移脚本 | SQL | `infra/sql/tenant-migration.sql` |
| 22 | UAT验收报告 | 文档 | `DocDesign/05-测试验收/TR-03` |
| 23 | 性能验收报告 | 文档 | `DocDesign/05-测试验收/TR-04` |
| 24 | 项目验收报告 | 文档 | `DocDesign/05-测试验收/TR-05` |

---

## 2. Sprint 16: 智能化运营与AIOps

### 2.1 S16-01 AI智能告警根因分析

**实现方案**：
- 创建 `AIOpsAiClient`，封装LangChain4j调用
- 接收告警上下文（名称、级别、指标值、服务名、时间线）和历史告警数据
- 大模型返回结构化JSON：根因分析、置信度、影响评估、修复建议、关联告警
- 支持降级：AI引擎不可用时返回降级标记，上层回退到规则引擎

**API**：`POST /api/dashboard/aiops/alert/analyze`

### 2.2 S16-02 容量预测模型

**实现方案**：
- 创建 `CapacityForecastService`，采用线性回归 + 阈值预测算法
- 无需外部ML依赖，纯Java实现
- 预测CPU/内存/磁盘/连接数的使用趋势
- 计算预计达到预警(70%)/临界(85%)/满载(100%)阈值的剩余天数
- 生成扩容建议

**API**：`POST /api/dashboard/aiops/capacity/forecast`

### 2.3 S16-03 智能SQL优化建议

**实现方案**：
- 在 `AIOpsAiClient` 中实现 `analyzeSlowSql` 方法
- 输入：慢SQL + 表结构信息 + 执行计划
- 输出：问题诊断、索引建议（DDL+选择性评估）、SQL改写方案、预期提升百分比
- 支持多种优化类型：INDEX_HINT / JOIN_OPTIMIZE / SUBQUERY_UNNEST / PAGINATION_FIX

**API**：`POST /api/dashboard/aiops/sql/optimize`

### 2.4 S16-05 异常检测算法

**实现方案**：
- 创建 `AnomalyDetectionService`，实现5种轻量级异常检测算法
- **3-Sigma**：基于均值±3倍标准差的统计检测
- **IQR**：基于四分位距的稳健检测
- **移动平均偏离**：基于滑动窗口均值偏离检测
- **突变检测**：相邻数据点变化率异常检测
- **EWMA**：指数加权移动平均检测
- 综合检测：多算法取并集，合并去重，按检出算法数量升级严重级别

**API**：`POST /api/dashboard/aiops/anomaly/detect`

### 2.5 S16-06 智能日志分析

**实现方案**：
- 在 `AIOpsAiClient` 中实现 `analyzeLogs` 方法
- 输入：日志条目列表（含时间、级别、服务、消息）
- 输出：异常模式分类、错误聚类（相似度评分）、趋势分析、建议措施
- 限制分析日志数量（前100条）避免token超限

**API**：`POST /api/dashboard/aiops/logs/analyze`

---

## 3. Sprint 17: 性能深度优化

### 3.1 S17-01 JVM调优（G1GC参数精调）

**交付物**：`infra/config/jvm-tuning.yml`

**参数分级**：
| 服务类型 | JVM参数组 | 堆内存 | 特点 |
|---------|---------|--------|------|
| 默认服务 | SMARTWIN_JVM_DEFAULT | 512-768m | 通用G1GC，200ms暂停目标 |
| 高吞吐服务 | SMARTWIN_JVM_HIGH | 768m-1.5g | 100ms暂停，大Region(32m) |
| AI服务 | SMARTWIN_JVM_AI | 1-1.5g | 高DirectMemory(1g) |
| 网关服务 | SMARTWIN_JVM_GATEWAY | 512-768m | 50ms暂停，低延迟 |

**关键参数**：
- `+UseG1GC` + `MaxGCPauseMillis` + `G1HeapRegionSize`
- `+UseStringDeduplication` 减少字符串内存占用
- `+HeapDumpOnOutOfMemoryError` OOM自动dump
- GC日志输出到文件，自动轮转

### 3.2 S17-02 数据库连接池调优

**交付物**：`infra/config/hikari-tuning.yml`

**按服务类型差异化配置**：
| 配置组 | MaxPool | MinIdle | 适用场景 |
|--------|---------|---------|---------|
| 高并发 | 30 | 15 | 网关/认证 |
| 高吞吐 | 25 | 10 | 数据服务 |
| 低频 | 10 | 3 | 配置/通知 |
| AI服务 | 15 | 5 | AI模型/Agent |

**关键配置**：
- `leak-detection-threshold: 60000` 生产环境开启泄漏检测
- `auto-commit: false` 配合Spring事务管理
- `max-lifetime: 1800000` 比数据库wait_timeout小

### 3.3 S17-03 Redis缓存策略优化

**交付物**：`common-util/.../utils/CacheStrategyUtils.java`

**解决的缓存问题**：
| 问题 | 解决方案 |
|------|---------|
| 缓存穿透 | 空值标记缓存（短TTL）+ 布隆过滤器 |
| 缓存击穿 | 互斥锁（双重检查）+ 降级策略 |
| 缓存雪崩 | 随机TTL（0-300秒偏移）+ 缓存预热 |

**布隆过滤器**：基于Redis BitMap的多重Hash实现

### 3.4 S17-04 ES索引优化

**交付物**：`infra/config/es-index-optimization.yml`

**优化内容**：
- 索引分片策略（按读写特性差异化配置）
- 中文分词器（IK Smart/Max Word + 拼音）
- ILM索引生命周期管理（hot→warm→cold→delete）
- 查询DSL优化建议（filter替代query、search_after分页）
- 监控指标阈值

### 3.5 S17-05 前端性能优化

**交付物**：`smartchain-frontend/vite.config.ts`

**优化内容**：
- **代码分割**：手动分包（vue-vendor/ui-vendor/chart-vendor/utils-vendor/editor-vendor）
- **路由懒加载**：所有路由使用动态import（已有）
- **Terser压缩**：移除console.log/debugger/注释
- **CSS压缩**：autoprefixer + cssnano
- **依赖预构建**：常用依赖预构建，monaco-editor动态加载
- **Tree Shaking**：关闭Options API，减小Vue体积
- **打包分析**：rollup-plugin-visualizer

### 3.6 S17-06 SQL慢查询治理

**交付物**：`infra/config/slow-sql-governance.yml`

**治理内容**：
- MySQL慢查询日志配置（2秒阈值）
- Druid SQL监控（慢SQL检测+SQL防火墙）
- 慢SQL治理清单（5条已修复，含优化前后对比）
- 索引优化建议清单（5张表15+索引）
- SQL审计规则（5条规则：全表扫描/SELECT */无WHERE更新/大OFFSET/强制索引）
- 慢SQL自动告警规则

---

## 4. Sprint 18: 多租户SaaS化与正式验收

### 4.1 S18-01 多租户数据隔离方案

**实现方案**：共享数据库 + 租户字段隔离（COLUMN模式）

**架构设计**：
```
请求 → TenantFilter → TenantContext(ThreadLocal) → TenantLineInnerInterceptor → SQL自动追加tenant_id
```

**核心组件**：
| 组件 | 职责 |
|------|------|
| `TenantContext` | ThreadLocal持有当前租户ID |
| `TenantFilter` | 从请求头/子域名提取租户ID |
| `TenantDbConfig` | MyBatis-Plus租户拦截器配置 |
| `MyBatisPlusConfig` | 集成租户拦截器到拦截器链 |

**忽略表**（全局共享）：sys_tenant, sys_dict, sys_config, sys_permission, flyway_schema_history

### 4.2 S18-02 租户管理模块

**实体**：`SysTenant` — 租户编码、名称、类型、联系人、域名、状态、配额、用量

**服务**：`SysTenantService`
- 租户CRUD + 分页查询
- 按类型自动分配默认配额（TRIAL/STARTER/PRO/ENTERPRISE）
- 配额检查（API调用/存储/AI Token/用户数）
- 用量统计与月度重置
- 到期租户自动停用

**API**：
| 方法 | 路径 | 说明 |
|------|------|------|
| POST | /api/platform/tenants | 创建租户 |
| GET | /api/platform/tenants | 分页查询 |
| GET | /api/platform/tenants/{id} | 租户详情 |
| PUT | /api/platform/tenants/{id} | 更新租户 |
| PUT | /api/platform/tenants/{id}/status | 启用/禁用 |
| GET | /api/platform/tenants/{id}/quota | 配额使用 |
| GET | /api/platform/tenants/current | 当前租户 |

### 4.3 S18-03 租户级权限隔离

**实现方案**：
- 所有业务表添加 `tenant_id` 字段
- MyBatis-Plus TenantLineInnerInterceptor 自动在SQL WHERE追加 `tenant_id = ?`
- INSERT时自动填充tenant_id（由拦截器处理）
- 系统管理操作通过 `TenantContext.setIgnoreTenant(true)` 临时忽略租户过滤

### 4.4 S18-04 租户级资源配额

**配额维度**：
| 维度 | 单位 | TRIAL | STARTER | PRO | ENTERPRISE |
|------|------|-------|---------|-----|------------|
| 用户数 | 人 | 5 | 10 | 50 | 200 |
| API调用 | 次/月 | 1K | 10K | 100K | 1M |
| 存储 | GB | 1 | 5 | 50 | 500 |
| AI Token | 千/月 | 100 | 1K | 10K | 100K |

**数据库迁移**：`infra/sql/tenant-migration.sql`
- 创建 `sys_tenant` 表
- 为所有业务表添加 `tenant_id` 字段和索引
- 初始化3个示例租户（默认/试用/专业版）

### 4.5 S18-05~09 正式验收

详见：
- `TR-03 UAT验收报告` — 用户验收测试结果
- `TR-04 性能验收报告` — 性能SLA达标验证
- `TR-05 项目验收报告` — 项目终验报告

---

## 5. 质量指标

| 指标 | 目标 | 实际 |
|------|------|------|
| AIOps功能数 | ≥4 | 5（告警分析+SQL优化+日志分析+容量预测+异常检测） |
| 异常检测算法数 | ≥3 | 5（3-Sigma/IQR/MA/Spike/EWMA） |
| 缓存策略 | 3种 | 3种（防穿透+防击穿+防雪崩） |
| 多租户配额维度 | ≥3 | 4（用户/API/存储/AI Token） |
| Lint错误 | 0 | 0 |
| 租户API数 | ≥5 | 7 |

---

## 6. 技术决策记录

| 决策 | 选项 | 选择 | 原因 |
|------|------|------|------|
| 异常检测算法 | 1.外部ML库 2.纯Java实现 | 纯Java实现 | 无额外依赖，轻量级，满足时序数据检测需求 |
| 容量预测 | 1.Python ML 2.线性回归 | 线性回归 | 无需Python环境，Java原生实现，R²评估置信度 |
| 租户隔离 | 1.独立数据库 2.共享表+字段 | 共享表+字段 | 运维成本低，适合中小规模SaaS，后续可升级 |
| 布隆过滤器 | 1.RedisBloom模块 2.BitMap模拟 | BitMap模拟 | 无需Redis模块依赖，3重Hash够用 |
| 前端分包 | 1.按页面 2.按依赖库 | 按依赖库 | 减少重复打包，缓存命中率更高 |
