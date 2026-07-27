# SmartWin / SmartData / SmartChain 三系统综合评审审计报告

> **审计日期**: 2026-07-11  
> **审计范围**: SmartWin 共享平台、SmartData 数据治理平台、SmartChain AI 运营管理平台  
> **审计版本**: 当前代码库主干 (main 分支)  
> **审计团队**: SmartWin 技术评审组  

---

## 目录

1. [审计概述](#1-审计概述)
2. [系统总体架构评估](#2-系统总体架构评估)
3. [SmartWin 平台审计](#3-smartwin-平台审计)
4. [SmartData 平台审计](#4-smartdata-平台审计)
5. [SmartChain 平台审计](#5-smartchain-平台审计)
6. [跨系统公共问题](#6-跨系统公共问题)
7. [优先级修改清单](#7-优先级修改清单)
8. [测试覆盖度评估](#8-测试覆盖度评估)
9. [结论与建议](#9-结论与建议)

---

## 1. 审计概述

### 1.1 审计目标

对 SmartWin、SmartData、SmartChain 三套系统进行全面、多维度的代码审计与功能完整性评估，识别系统现有的欠缺和未完善之处，按优先级整理成报告并给出修改意见。

### 1.2 审计维度

| 维度 | 说明 |
|------|------|
| **功能完整性** | 对比设计文档，评估各模块功能实现是否闭环 |
| **代码质量** | 代码规范性、可维护性、重复代码、硬编码等 |
| **安全性** | 密钥管理、权限控制、输入校验、敏感数据处理 |
| **架构合理性** | 微服务划分、依赖管理、数据一致性 |
| **测试覆盖度** | 单元测试、集成测试、E2E 测试的覆盖情况 |
| **生产就绪度** | 是否具备上线条件，哪些功能仅为原型/Mock |

### 1.3 审计方法

- 全量代码扫描（Java/Python/TypeScript/Vue）
- 设计文档对比（DocDesign 目录下架构设计文档）
- 依赖关系与接口调用链追踪
- 安全模式扫描（硬编码密钥、明文存储、注入风险）
- TODO/FIXME 标记追踪

---

## 2. 系统总体架构评估

### 2.1 架构概览

```
┌─────────────────────────────────────────────────────┐
│                   API Gateway (Spring Cloud Gateway) │
│              金丝雀发布 / OpenAPI / 动态路由          │
├─────────────┬──────────────────┬────────────────────┤
│  SmartWin   │    SmartData     │    SmartChain      │
│  共享平台    │    数据治理平台    │    AI运营平台       │
├─────────────┼──────────────────┼────────────────────┤
│ auth-svc    │ catalog-svc      │ model-svc          │
│ system-svc  │ metadata-svc     │ agent-svc          │
│ audit-svc ❌│ lineage-svc      │ app-svc            │
│ config-svc❌│ quality-svc      │ cost-svc           │
│ notif-svc ❌│ mdm-svc          │ prompt-svc         │
│ security❌  │ glossary-svc     │ risk-svc           │
│ dashboard   │ standard-svc     │ ai-engine (Python) │
│             │ lifecycle-svc    │ smartchain-frontend│
│             │ dataservice-svc  │                    │
│             │ smartdata-frontend│                   │
├─────────────┼──────────────────┼────────────────────┤
│ common-security │ common-db-multi │ common-ai       │
│ common-mq    │ common-crypto-gm  │ common-storage   │
│ common-util  │ common-xinchuang  │ common-db-rw     │
└─────────────┴──────────────────┴────────────────────┘
```

### 2.2 技术栈评估

| 层面 | 技术选型 | 评价 |
|------|---------|------|
| 后端框架 | Spring Boot 3 + MyBatis-Plus | ✅ 主流稳定 |
| 前端框架 | Vue 3 + TypeScript + Vite | ✅ 现代化 |
| AI 引擎 | Python + FastAPI + httpx | ✅ 轻量高效 |
| 消息队列 | RocketMQ | ✅ 企业级 |
| 数据库 | MySQL + DM8 (信创) | ✅ 国产化兼容 |
| 图数据库 | Neo4j (血缘分析) | ✅ 合理选择 |
| 搜索引擎 | Elasticsearch (数据目录) | ✅ 适用场景 |
| 容器化 | Docker + K8s + Helm | ✅ 云原生 |
| 监控 | Prometheus + Grafana + Loki | ✅ 可观测性完备 |

### 2.3 总体完成度评估

| 系统 | 设计模块数 | 已实现模块数 | 完成度 | 备注 |
|------|-----------|-------------|--------|------|
| **SmartWin** | 7 | 3 | **43%** | 4个核心服务为空壳 |
| **SmartData** | 9 | 9 | **85%** | 全部有实现，部分功能为Mock |
| **SmartChain 后端** | 6 | 6 | **75%** | 全部有实现，部分功能为Mock |
| **SmartChain AI引擎** | 3 | 3 | **70%** | 检测完善，评测为模拟数据 |
| **SmartChain 前端** | 50+ | 48+ | **92%** | 路由/视图覆盖完整 |

---

## 3. SmartWin 平台审计

### 3.1 平台公共模块 (platform-common)

#### 3.1.1 common-security
- **JwtTokenProvider**: JWT 生成与验证逻辑完整
- **SecurityContextHolder**: 基于 ThreadLocal 的上下文管理
- **TenantFilter**: 租户隔离过滤器实现到位
- **RateLimitFilter**: 限流过滤器存在但未接入 Redis 分布式限流
- **ZeroTrustEngine**: 零信任引擎框架存在，但信任评估算法过于简化

#### 3.1.2 common-db-multi
- **DatabaseTypeDetector**: 支持 MySQL/DM8/Kingbase/OpenGauss 四种数据库自动检测 ✅
- **DatabaseDialect**: 方言适配完整，分页拦截器实现合理 ✅
- **FlywayMultiDbStrategy**: 多数据库 Flyway 迁移策略 ✅

#### 3.1.3 common-crypto-gm
- **CryptoFacade**: 国密 SM2/SM3/SM4/SM9 统一接口 ✅
- **SoftwareCryptoService**: 纯 Java 实现的国密算法 ✅
- ⚠️ 未提供硬件加密机适配实现

#### 3.1.4 common-ai
- **SmartDataAiClient**: 数据治理 AI 客户端，支持主数据识别、语义去重
- **AIOpsAiClient**: 运维 AI 客户端
- **MultimodalAIService**: 多模态 AI 服务接口
- ⚠️ AI 客户端缺少熔断/降级机制，AI 服务不可用时仅靠 try-catch 降级

#### 3.1.5 common-mq
- **MqProducerService**: 消息生产者封装完整
- **BaseMessageConsumer**: 消费者基类设计合理
- ⚠️ 缺少消息轨迹追踪和死信队列处理

#### 3.1.6 其他公共模块
- **common-storage**: MinIO 对象存储，支持分片上传 ✅
- **common-util**: 响应封装、异常处理、i18n 国际化、条件装配 ✅
- **common-xinchuang**: 信创环境自动检测与配置激活 ✅
- **common-db-rw**: 读写分离 AOP + 注解驱动 ✅
- **common-test**: 集成测试基类 ✅

### 3.2 平台服务层 (platform-services)

#### 🔴 P0 — 空壳服务（无任何 Java 实现）

| 服务 | 状态 | 影响 |
|------|------|------|
| **audit-service** | ❌ 0个Java文件 | 审计日志无法采集，合规性不达标 |
| **notification-service** | ❌ 0个Java文件 | 消息通知功能完全缺失 |
| **config-service** | ❌ 0个Java文件 | 动态配置中心缺失 |
| **security-service** | ❌ 0个Java文件 | 安全策略管理缺失 |

> **严重程度**: P0 — 这些是平台基础设施服务，缺失将导致整个系统无法在生产环境正常运行。

#### 🟡 P2 — dashboard-service（功能存在但为内存Mock）

dashboard-service 包含大量高级功能服务，但全部使用 `ConcurrentHashMap` 内存存储，数据不持久化：

| 服务类 | 功能描述 | 问题 |
|--------|---------|------|
| `AgentOrchestrationService` | 多Agent协作编排 | 任务注册表为内存Map，重启丢失 |
| `FederatedLearningService` | 联邦学习 | 模拟执行，无真实训练逻辑 |
| `FederatedQueryController` | 联邦查询 | 返回模拟数据 |
| `ModelFineTuningService` | 模型微调 | 返回模拟结果 |
| `AnomalyDetectionService` | 异常检测 | 基于规则的简化检测 |
| `CapacityForecastService` | 容量预测 | 返回模拟预测数据 |
| `AutoOpsService` | 自动运维 | 返回模拟操作 |
| `AICopilotService` | AI 副驾驶 | 返回模拟建议 |
| `AITrustGovernanceService` | AI 信任治理 | 返回模拟评分 |
| `AgenticGovernanceService` | Agent 治理 | 返回模拟治理数据 |
| `ApiMarketplaceService` | API 市场 | 返回模拟数据 |

> **评价**: 这些服务的设计文档完善、接口定义规范，但实现全部为原型级别的内存 Mock。适合演示，**完全不适合生产**。

#### ✅ auth-service（基本可用）

- 登录/刷新Token/登出接口完整
- JWT + RefreshToken 双令牌机制
- 用户/角色/权限实体定义完整
- ⚠️ 密码加密使用 BCrypt 但未接入国密 SM3
- ⚠️ 缺少登录失败锁定、验证码等防暴力破解机制

#### ✅ system-service（基本可用）

- 租户管理、字典管理、插件管理、SaaS运维、计费管理接口完整
- ⚠️ `LifecycleServiceImpl` 中 `action.setApprovedBy(0L)` 硬编码用户ID
- ⚠️ `UserPreferenceController` 偏好设置未持久化（TODO标记）

### 3.3 SmartWin 前端 (shared-components)

- **组件库**: 28个通用组件（AppLayout, Pagination, Toast, ConfirmDialog 等）✅
- **国际化**: zh-CN / en-US 双语支持 ✅
- **主题**: 明暗主题 + 品牌定制 ✅
- **Composables**: 8个组合式函数（表单校验、图表缩放、Toast 等）✅

---

## 4. SmartData 平台审计

### 4.1 服务清单与完成度

| 服务 | Controller | Service | Mapper | Entity | DTO | Migration | Test | 完成度 |
|------|-----------|---------|--------|--------|-----|-----------|------|--------|
| catalog-service | ✅ | ✅ (5个) | ✅ | ✅ | ✅ | ✅ | ✅ (3个) | **90%** |
| metadata-service | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | **85%** |
| quality-service | ✅ | ✅ (4个) | ✅ | ✅ | ✅ | ✅ (2个) | ✅ (3个) | **85%** |
| mdm-service | ✅ | ✅ | ✅ (4个) | ✅ (4个) | ✅ (6个) | ✅ (2个) | ✅ (2个) | **90%** |
| lineage-service | ✅ | ✅ (2个) | ✅ | ✅ | ✅ | ✅ | ✅ (2个) | **85%** |
| glossary-service | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | **85%** |
| standard-service | ✅ | ✅ | ✅ (3个) | ✅ (3个) | ✅ | ✅ | ✅ | **85%** |
| lifecycle-service | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | **80%** |
| dataservice-service | ✅ | ✅ (2个) | ✅ (3个) | ✅ (3个) | ✅ | ✅ | ✅ (2个) | **85%** |

### 4.2 核心功能审计

#### 4.2.1 数据质量管理 (quality-service)

**亮点**:
- 六维质量规则模型（完整性/唯一性/一致性/有效性/及时性/准确性）完整实现
- AI 质量规则推荐服务 (`AiQualityRuleServiceImpl`) 有完整的规则模板库
- 预测性预警服务 (`PredictiveWarningServiceImpl`) 实现了趋势分析
- 质量调度服务 (`QualityScheduleServiceImpl`) 支持定时任务

**问题**:
- 🔴 `QualityServiceImpl.executeTask()` 使用 `Random` 生成模拟检测数据，**未真正执行数据质量检测SQL**
- 🟡 预测性预警中的维度偏移量使用 `new Random(dim.hashCode())` 生成，预测结果不可信
- 🟡 问题处理仅支持 fix/ignore/reassign 三种方式，缺少自动修复

#### 4.2.2 主数据管理 (mdm-service) — ⭐ 最完善的服务

**亮点**:
- 多策略去重管道：精确匹配 → 模糊匹配(Levenshtein) → AI 语义去重
- 黄金记录评分模型：完整度(30%) + 来源优先级(25%) + 数据质量(25%) + 时效性(20%)
- 字段级黄金记录构建：逐字段选择最佳值
- 自动合并：基于置信度阈值的自动决策
- 去重审计追踪：完整记录每次去重操作
- AI 语义去重：接入 `SmartDataAiClient.deduplicateWithSemantics()`

**问题**:
- 🟡 `identify()` 方法降级到规则识别时，置信度使用 `70 + new Random().nextInt(30)` 随机生成
- 🟡 分发功能 `distribute()` 仅写入分发记录，未实现真实的数据推送

#### 4.2.3 数据血缘 (lineage-service)

**亮点**:
- Neo4j 图数据库 + 关系型数据库双存储架构
- Neo4j 不可用时自动降级到关系型 BFS 遍历
- 支持上游/下游/双向血缘查询
- 影响分析支持递归遍历（最大深度5层）

**问题**:
- 🔴 `collectLineage()` 方法为完全模拟实现，未解析 ETL 作业、SQL 视图、存储过程
- 🟡 Neo4j 配置中的密码默认值为 `neo4j`（弱密码）

#### 4.2.4 数据目录 (catalog-service)

**亮点**:
- Elasticsearch 全文搜索 + 数据库降级查询双模式
- 资产生命周期管理（注册→发布→废弃）
- 联合治理服务 (`JointGovernanceServiceImpl`) 和治理健康度评估
- 数据分类服务 (`DataCategoryServiceImpl`)

**问题**:
- 🟡 `getFavorites()` 返回热门资产而非用户实际收藏列表（注释标注"简化实现"）
- 🟡 `GovernanceHealthServiceImpl` 中健康度评分使用 Random 生成

#### 4.2.5 其他服务

| 服务 | 状态 | 主要问题 |
|------|------|---------|
| metadata-service | ✅ 基本可用 | 元数据采集返回模拟响应时间 |
| glossary-service | ✅ 基本可用 | 无明显问题 |
| standard-service | ✅ 基本可用 | 无明显问题 |
| lifecycle-service | ✅ 基本可用 | 归档/销毁操作返回模拟影响行数 |
| dataservice-service | ✅ 基本可用 | SQL 执行服务需要更严格的SQL注入防护 |

### 4.3 SmartData 前端

- 路由覆盖 12 个核心页面 ✅
- 使用 Hash 模式路由（与 SmartChain 的 History 模式不一致）
- ⚠️ LoginView 仅有 TODO 注释，登录表单未实现
- ⚠️ MetadataView 有 TODO 标记（元数据编辑弹窗未实现）
- ⚠️ 缺少权限控制（路由守卫仅检查 token，无权限码校验）
- ⚠️ 前端 API 层缺失（未发现 api/ 目录下的请求封装）

---

## 5. SmartChain 平台审计

### 5.1 后端服务审计

#### 5.1.1 model-service

**功能完成度**: 70%

| 功能 | 状态 | 说明 |
|------|------|------|
| 模型 CRUD | ✅ | 增删改查完整，含重名校验 |
| 模型对比 | ⚠️ | 仅返回模型属性对比，无性能/能力对比 |
| 模型监控 | 🔴 | 返回全零的模拟数据 |
| 模型评测 | 🔴 | 仅返回 pending 状态和 UUID，无实际评测 |
| 版本管理 | ✅ | 有独立的版本服务 |
| API密钥管理 | 🔴 | **密钥明文存储**，未加密 |

> 🔴 **严重安全漏洞**: `ModelApikeyServiceImpl.create()` 中 API Key 明文存入数据库，代码注释明确标注 TODO 需接入 SM4 加密。生产环境下这是 **P0 级安全漏洞**。

#### 5.1.2 app-service

**功能完成度**: 60%

| 服务 | 状态 | 说明 |
|------|------|------|
| AiAppService | ✅ | 应用 CRUD 基本可用 |
| DataFabricService | 🟡 | 架构设计优秀但全内存Mock |
| DataTradingService | 🟡 | 数据交易服务 |
| EtlEngineService | 🟡 | ETL 引擎返回模拟数据 |
| FlinkStreamProcessingService | 🟡 | Flink 流处理返回模拟数据 |
| IndustrySolutionService | 🟡 | 行业解决方案 |

> `DataFabricService` 的设计非常优秀（虚拟视图、语义层、智能路由、缓存层），但 `executeCrossSourceQuery()` 使用 `Random` 生成模拟数据，未连接真实数据源。

#### 5.1.3 cost-service

**功能完成度**: 85%

- 成本记录管理完整 ✅
- 预算管理含告警逻辑 ✅
- 有集成测试 (`CostBudgetIntegrationTest`) ✅
- ⚠️ 成本统计数据可能缺少实时 Token 用量采集

#### 5.1.4 risk-service

**功能完成度**: 85%

- 风险事件管理完整 ✅
- 风险规则管理完整 ✅
- 有集成测试 (`RiskEventRuleIntegrationTest`) ✅
- ⚠️ 风险规则触发引擎可能需要实时事件流支持

#### 5.1.5 prompt-service

**功能完成度**: 80%

- Prompt CRUD 基本可用 ✅
- 版本管理 ✅
- ⚠️ Prompt 测试功能需要连接 AI 引擎

#### 5.1.6 agent-service

**功能完成度**: 80%

- Agent CRUD 基本可用 ✅
- 有单元测试 ✅
- ⚠️ Agent 执行引擎未实现（仅有数据管理）

### 5.2 AI 引擎审计 (smartchain-ai-engine)

#### 5.2.1 安全检测服务 (detection.py) — ⭐ 最完善的模块

**亮点**:
- 6 类安全检测全部实现：Prompt注入、内容安全、隐私泄露、毒性、偏见、幻觉
- 注入检测：17种模式匹配（角色覆盖/越狱/信息窃取/指令注入）
- 隐私检测：6种正则（手机/身份证/银行卡/邮箱/电话/IP）
- 批量检测支持
- 风险分级：LOW / MEDIUM / HIGH / CRITICAL
- 有增强测试 (`test_detection_enhanced.py`)

**问题**:
- 🟡 检测基于关键词和正则匹配，缺少基于 ML 模型的语义级检测
- 🟡 幻觉检测为启发式规则，准确率有限
- 🟡 关键词库为硬编码，无法动态更新

#### 5.2.2 多模型代理服务 (proxy.py)

**亮点**:
- 统一适配器模式，支持 OpenAI/Claude/文心/通义/星火/GLM
- 输入输出双向安全检测
- 流式/非流式双模式
- 重试机制（指数退避）

**问题**:
- 🔴 `_init_adapters()` 中**仅初始化了 OpenAI 适配器**，其他5个厂商的适配器未实现
- 🟡 无速率限制实现
- 🟡 无请求日志和审计追踪
- 🟡 无 Token 用量统计

#### 5.2.3 模型评测服务 (evaluation.py)

**问题**:
- 🔴 **所有评测结果为硬编码常量**（如 `"accuracy": 0.85`），未连接真实模型
- 🔴 评测数据集过于简化（仅3-5条测试用例）
- 🟡 无异步任务队列，评测在大规模场景下会阻塞
- 🟡 历史结果查询标注 TODO，未实现

#### 5.2.4 治理 API (governance.py)

- 治理策略管理接口存在
- ⚠️ 治理规则执行引擎需要完善

### 5.3 SmartChain 前端审计

#### 5.3.1 路由与视图

**亮点**:
- 50+ 路由覆盖全部业务模块 ✅
- 路由守卫含权限码校验 ✅
- 静态路由前置避免参数路由冲突 ✅
- 菜单分组与权限过滤 ✅

**问题**:
- 🟡 `AgentFlowView.vue` 有 TODO：流程数据未调用后端API保存
- 🟡 `AppPublishView.vue` 有 TODO：发布API未替换为实际调用
- 🟡 `StatusPageView.vue` 中联系电话为占位符 `400-888-XXXX`
- 🟡 缺少错误边界 (Error Boundary) 组件

#### 5.3.2 组合式函数 (Composables)

| Composable | 状态 | 说明 |
|-----------|------|------|
| usePermission | ✅ | 权限校验 |
| useClipboard | ✅ | 剪贴板 |
| useConfirmDialog | ✅ | 确认对话框 |
| useTableSort | ✅ | 表格排序 |
| useKeyboardShortcuts | ✅ | 键盘快捷键 |
| useABTest | ✅ | A/B测试 |
| useFeatureFlags | ✅ | 功能开关 |
| useScrollReveal | ✅ | 滚动动画 |

#### 5.3.3 测试覆盖

- 组件测试: 8个 ✅
- Composable 测试: 8个 ✅
- E2E 测试: 1个 (`core-flows.spec.ts`) ✅
- ⚠️ 视图级测试仅3个，覆盖率偏低

---

## 6. 跨系统公共问题

### 6.1 🔴 P0 级问题（阻断上线）

| # | 问题 | 涉及系统 | 影响 |
|---|------|---------|------|
| 1 | **4个平台基础服务为空壳** | SmartWin | 审计/通知/配置/安全服务完全缺失，系统无法生产运行 |
| 2 | **API Key 明文存储** | SmartChain | 数据库泄露即暴露所有模型API密钥 |
| 3 | **质量检测使用Random模拟** | SmartData | 数据质量检测结果完全不可信 |
| 4 | **AI评测结果为硬编码常量** | SmartChain AI引擎 | 模型评测报告无参考价值 |
| 5 | **多模型代理仅OpenAI可用** | SmartChain AI引擎 | 声称支持6家厂商但实际仅1家可用 |
| 6 | **血缘采集为模拟实现** | SmartData | 无法自动发现真实数据血缘关系 |

### 6.2 🟡 P1 级问题（影响功能完整性）

| # | 问题 | 涉及系统 | 影响 |
|---|------|---------|------|
| 7 | Dashboard 11个高级服务全内存Mock | SmartWin | 演示级功能，重启数据丢失 |
| 8 | DataFabricService 全内存Mock | SmartChain | 数据编织功能不可用 |
| 9 | dev环境硬编码密码 (smartwin123) | SmartWin | 开发环境密码暴露 |
| 10 | 用户上下文缺失 | SmartWin/SmartData | 审批人ID硬编码为0 |
| 11 | SmartData前端缺少API请求层 | SmartData | 前后端无法联调 |
| 12 | SmartData前端登录表单未实现 | SmartData | 无法登录 |
| 13 | 模型监控数据全零 | SmartChain | 无法监控模型运行状态 |
| 14 | 收藏功能返回热门数据 | SmartData | 用户收藏功能失效 |
| 15 | AI客户端缺少熔断机制 | common-ai | AI服务不可用时可能级联故障 |

### 6.3 🟢 P2 级问题（代码质量/技术债务）

| # | 问题 | 涉及系统 |
|---|------|---------|
| 16 | 大量使用 `new Random()` 生成业务数据 | SmartData/SmartChain |
| 17 | `ConcurrentHashMap` 替代数据库存储 | SmartWin Dashboard |
| 18 | Neo4j默认密码 `neo4j` | SmartData |
| 19 | 路由模式不统一（Hash vs History） | SmartData vs SmartChain |
| 20 | 检测关键词库硬编码无法动态更新 | SmartChain AI引擎 |
| 21 | 缺少API限流（RateLimitFilter未接入Redis） | SmartWin common-security |
| 22 | MQ缺少死信队列处理 | SmartWin common-mq |
| 23 | i18n偏好设置未持久化 | SmartWin common-util |
| 24 | 前端缺少错误边界组件 | SmartChain Frontend |
| 25 | 视图级测试覆盖率偏低 | SmartChain Frontend |

---

## 7. 优先级修改清单

### P0 — 必须在上线前完成

#### P0-1: 实现四个空壳平台服务

```
优先级: P0 | 预估工时: 15人天 | 负责团队: SmartWin平台组

1. audit-service (3人天)
   - AuditLogEntity / AuditLogMapper / AuditLogService
   - 审计日志采集Interceptor（自动记录API调用）
   - 审计日志查询接口（支持时间/用户/操作类型筛选）
   - 接入MQ异步写入

2. notification-service (3人天)
   - 通知模板管理（邮件/短信/站内信/Webhook）
   - NotificationService + 各渠道Sender实现
   - 接入common-mq消费通知消息
   - 用户通知偏好设置（对接UserPreferenceController）

3. config-service (4人天)
   - 配置项CRUD + 配置组管理
   - 配置变更监听与推送（Spring Cloud Bus / Nacos）
   - 配置灰度发布
   - 配置历史版本与回滚

4. security-service (5人天)
   - 安全策略管理（密码策略/会话策略/IP黑白名单）
   - 安全事件采集与告警
   - 安全扫描任务管理
   - 合规检查规则引擎
```

#### P0-2: API Key 加密存储

```
优先级: P0 | 预估工时: 0.5人天 | 负责团队: SmartChain后端

文件: ModelApikeyServiceImpl.java
修改:
1. 注入 CryptoFacade
2. create() 时: apikey.setApiKey(cryptoFacade.sm4Encrypt(dto.getApiKey()))
3. 查询时: 解密返回（或仅返回掩码）
4. 数据库迁移: 存量明文密钥批量加密
```

#### P0-3: 数据质量检测真实化

```
优先级: P0 | 预估工时: 5人天 | 负责团队: SmartData后端

文件: QualityServiceImpl.executeTask()
修改:
1. 根据 QualityRule.ruleType 构建真实检测SQL
   - completeness: SELECT COUNT(*) FROM table WHERE column IS NULL
   - uniqueness: SELECT column, COUNT(*) FROM table GROUP BY column HAVING COUNT(*) > 1
   - validity: SELECT * FROM table WHERE column NOT REGEXP pattern
2. 通过 dynamic DataSource 执行检测SQL
3. 真实记录检测结果到 QualityIssue
4. 移除 Random 相关代码
```

#### P0-4: AI 引擎多模型适配器实现

```
优先级: P0 | 预估工时: 5人天 | 负责团队: SmartChain AI引擎

文件: proxy.py → ProxyService._init_adapters()
修改:
1. 实现 AnthropicAdapter (Claude API)
2. 实现 WenxinAdapter (百度文心 API)
3. 实现 QwenAdapter (阿里通义 API)
4. 实现 SparkAdapter (讯飞星火 API)
5. 实现 ZhipuAdapter (智谱GLM API)
6. 各适配器从环境变量读取API Key
```

#### P0-5: 模型评测真实化

```
优先级: P0 | 预估工时: 5人天 | 负责团队: SmartChain AI引擎

文件: evaluation.py
修改:
1. 通过 ProxyService 调用真实模型
2. 扩充评测数据集（至少100条/类型）
3. 实现真实评分逻辑（BLEU/ROUGE/精确匹配/语义相似度）
4. 评测结果持久化到数据库
5. 支持异步评测（Celery/asyncio task queue）
```

#### P0-6: 血缘采集真实化

```
优先级: P0 | 预估工时: 5人天 | 负责团队: SmartData后端

文件: LineageServiceImpl.collectLineage()
修改:
1. SQL视图解析: 解析 CREATE VIEW 语句提取字段映射
2. ETL作业解析: 解析 DataX/Sqoop/Kettle 配置文件
3. 存储过程解析: 解析存储过程SQL提取数据流向
4. 实时SQL解析: 解析应用层SQL日志
```

### P1 — 上线后第一个迭代完成

#### P1-1: Dashboard 服务持久化

将 `AgentOrchestrationService` 等11个服务的 `ConcurrentHashMap` 存储替换为数据库 + Redis。

#### P1-2: SmartData 前端补全

- 实现 LoginView 完整登录表单
- 创建 `src/api/` 目录，封装 axios 请求层
- 路由守卫增加权限码校验
- MetadataView 实现元数据编辑弹窗

#### P1-3: AI 客户端熔断机制

为 `common-ai` 中的 AI 客户端添加 Resilience4j 熔断器：
- 5次失败触发熔断
- 30秒后半开探测
- 熔断期间快速降级

#### P1-4: 模型监控数据采集

实现 `AiModelServiceImpl.getMonitorData()` 的真实数据采集：
- 从 Prometheus 查询模型调用指标
- 从成本服务查询 Token 用量
- 从日志服务查询错误率

#### P1-5: 用户上下文修复

- `LifecycleServiceImpl`: 从 SecurityContextHolder 获取当前用户ID
- `UserPreferenceController`: 实现 `sys_user_preference` 表持久化
- `CatalogServiceImpl.getFavorites()`: 查询用户收藏表

### P2 — 技术债务清理

#### P2-1: 消除 Random 模拟数据

全局搜索 `new Random()` 并替换为真实数据源：
- `QualityServiceImpl` → 真实SQL检测
- `MetadataServiceImpl` → 真实元数据采集
- `GovernanceHealthServiceImpl` → 真实健康度计算
- `DataFabricService` → 真实跨源查询
- `EtlEngineService` → 真实ETL执行
- `FlinkStreamProcessingService` → 真实Flink指标

#### P2-2: 安全加固

- dev 环境 docker-compose 密码改为环境变量
- Neo4j 默认密码修改
- RateLimitFilter 接入 Redis 实现分布式限流
- common-mq 实现死信队列处理

#### P2-3: 前端统一

- SmartData 前端路由模式改为 History（与 SmartChain 一致）
- SmartChain 前端添加 ErrorBoundary 组件
- 补充视图级测试覆盖率至 60%+

---

## 8. 测试覆盖度评估

### 8.1 后端测试统计

| 系统 | 服务数 | 有测试的服务数 | 测试类总数 | 覆盖率评估 |
|------|--------|-------------|-----------|-----------|
| SmartWin | 3 (有代码的) | 2 | ~5 | 40% |
| SmartData | 9 | 9 | ~15 | 70% |
| SmartChain | 6 | 5 | ~10 | 65% |
| **合计** | 18 | 16 | ~30 | **60%** |

### 8.2 前端测试统计

| 系统 | 组件测试 | Composable测试 | E2E测试 | 视图测试 | 覆盖率评估 |
|------|---------|---------------|--------|---------|-----------|
| SmartChain | 8 | 8 | 1 | 3 | 35% |
| SmartData | 3 | 0 | 0 | 0 | 15% |
| shared-components | - | - | - | - | 包含在上述中 |

### 8.3 AI 引擎测试统计

| 模块 | 测试文件数 | 覆盖场景 |
|------|-----------|---------|
| detection | 1 (enhanced) | 6类检测全覆盖 |
| proxy | 1 | 基础代理+安全检测 |
| governance | 1 (合并) | 治理基础流程 |
| evaluation | 0 | ❌ 无测试 |

### 8.4 测试改进建议

1. **补充 evaluation.py 测试**: 评测服务目前0测试覆盖
2. **补充集成测试**: SmartWin 的 auth-service 和 system-service 缺少集成测试
3. **补充 SmartData 前端测试**: 目前仅有3个组件测试，需要大幅补充
4. **E2E 测试增强**: SmartChain 仅有1个 E2E 测试，需要覆盖核心业务流程
5. **安全测试**: 需要增加 SQL注入/XSS/Prompt注入的自动化安全测试

---

## 9. 结论与建议

### 9.1 总体评价

| 系统 | 架构设计 | 代码质量 | 功能完成度 | 生产就绪度 | 综合评分 |
|------|---------|---------|-----------|-----------|---------|
| SmartWin | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ (43%) | ⭐⭐ | **C+** |
| SmartData | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ (85%) | ⭐⭐⭐ | **B+** |
| SmartChain | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ (75%) | ⭐⭐⭐ | **B** |

### 9.2 核心优势

1. **架构设计成熟**: 微服务划分清晰，公共模块抽象合理，信创兼容设计领先
2. **SmartData MDM 最完善**: 多策略去重 + 黄金记录 + AI语义去重的组合在业界领先
3. **AI 安全检测体系完整**: 6类检测覆盖了 LLM 安全的主要风险面
4. **基础设施完善**: Docker/K8s/Helm/Prometheus/Grafana/Loki 全链路可观测性
5. **前端工程化程度高**: Vue3 + TS + 组件库 + 国际化 + 主题系统 + 权限控制

### 9.3 核心风险

1. **平台基础设施缺失**: 4个核心服务为空壳，系统无法独立运行
2. **安全漏洞**: API Key 明文存储是必须立即修复的安全风险
3. **Mock 数据泛滥**: 大量服务使用 Random 生成假数据，功能验证不可信
4. **AI 引擎落地不足**: 多模型代理仅1家可用，评测全为硬编码
5. **前端联调受阻**: SmartData 前端缺少 API 层，无法与后端联调

### 9.4 建议的修复优先级路线图

```
第1周 (P0): API Key加密 → 质量检测真实化 → 多模型适配器
第2周 (P0): audit-service → notification-service → 评测真实化
第3周 (P0): config-service → security-service → 血缘采集
第4周 (P1): Dashboard持久化 → SmartData前端补全 → 熔断机制
第5-6周 (P1): 模型监控 → 用户上下文修复 → 收藏功能
第7-8周 (P2): Random清理 → 安全加固 → 测试补充
```

### 9.5 上线就绪度判定

| 系统 | 当前可上线？ | 阻塞项数 | 预计就绪时间 |
|------|------------|---------|------------|
| SmartWin | ❌ | 6项 P0 | 4-5周 |
| SmartData | ⚠️ 条件可上 | 3项 P0 | 2-3周 |
| SmartChain | ❌ | 4项 P0 | 3-4周 |

> **结论**: 当前系统整体处于 **"功能原型完成、生产化未完成"** 阶段。建议按上述路线图完成 P0 项后，再进行生产环境部署评估。

---

*报告结束 — SmartWin 技术评审组*
