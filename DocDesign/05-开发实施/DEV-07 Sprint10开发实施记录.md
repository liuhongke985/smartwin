# Sprint 10 开发实施记录

## 文档控制

| 信息项 | 内容 |
|--------|------|
| **文档编号** | DEV-07 |
| **文档版本** | V1.0 |
| **创建日期** | 2026-07-08 |
| **最后修订** | 2026-07-08 |
| **文档状态** | 正式发布 |
| **文档负责人** | 智数开发团队 |
| **审批人** | 项目经理 |

---

## 1. 开发总览

### 1.1 Sprint 10 交付物清单

| 任务编号 | 任务 | 优先级 | 交付物 | 状态 |
|:--------:|------|:------:|--------|:----:|
| S10-01 | ES集成(数据目录全文搜索) | 高 | ES客户端配置+全文搜索服务+索引同步 | ✅ |
| S10-02 | Neo4j集成(血缘图谱存储) | 中 | Neo4j驱动配置+图谱服务+图遍历查询 | ✅ |
| S10-03 | Java AI引擎(LangChain4j) | 高 | common-ai模块5个类+LangChain4j集成 | ✅ |
| S10-04 | 真实SQL执行(dataservice) | 高 | SQL执行服务+数据源管理+注入防护 | ✅ |
| S10-05 | API网关真实路由注册 | 中 | 22条路由规则+动态路由注册器 | ✅ |
| S10-06 | AI辅助主数据识别 | 低 | AI语义识别+规则降级+置信度评估 | ✅ |
| S10-07 | 质量规则定时调度 | 中 | CRON调度+任务注册/暂停/恢复+扫描机制 | ✅ |

### 1.2 代码统计

| 指标 | 数值 |
|------|:----:|
| 新增Java文件数 | 16 |
| 新增配置文件项 | 12 |
| 新增SQL迁移字段 | 1表 |
| 新增API端点数 | 10 |
| 修改现有服务数 | 6 |
| 新增依赖数 | 3 |

---

## 2. S10-01: ES集成(数据目录全文搜索)

### 2.1 交付文件

| 文件路径 | 说明 |
|----------|------|
| `catalog-service/.../config/ElasticsearchConfig.java` | ES客户端配置(@ConditionalOnProperty) |
| `catalog-service/.../service/EsSearchService.java` | ES全文搜索服务接口 |
| `catalog-service/.../service/impl/EsSearchServiceImpl.java` | ES搜索实现(多字段匹配+高亮+降级) |
| `catalog-service/.../service/impl/CatalogServiceImpl.java` | **修改**：集成ES索引同步和搜索 |
| `catalog-service/.../resources/application.yml` | **修改**：新增ES配置 |

### 2.2 核心实现

- **索引同步**：资产CRUD操作自动同步ES索引(create/update/delete)
- **全文搜索**：multi_match多字段加权搜索(assetName^3, description^2, tags^1.5)
- **中文分词**：IK分词器(ik_max_word索引, ik_smart搜索)
- **搜索高亮**：返回高亮标签`<em>`标记匹配文本
- **降级策略**：ES不可用时自动降级到数据库LIKE查询

### 2.3 配置

```yaml
platform:
  es:
    enabled: ${ES_ENABLED:false}
    host: ${ES_HOST:localhost}
    port: ${ES_PORT:9200}
    scheme: ${ES_SCHEME:http}
```

---

## 3. S10-02: Neo4j集成(血缘图谱存储)

### 3.1 交付文件

| 文件路径 | 说明 |
|----------|------|
| `lineage-service/pom.xml` | **修改**：新增neo4j-java-driver依赖 |
| `lineage-service/.../config/Neo4jConfig.java` | Neo4j Driver配置 |
| `lineage-service/.../service/Neo4jLineageService.java` | Neo4j图谱服务接口 |
| `lineage-service/.../service/impl/Neo4jLineageServiceImpl.java` | Cypher实现(节点/边/图遍历/影响分析/最短路径) |
| `lineage-service/.../service/impl/LineageServiceImpl.java` | **修改**：集成Neo4j图查询优先 |
| `lineage-service/.../resources/application.yml` | **修改**：新增Neo4j配置 |

### 3.2 核心实现

- **图存储**：血缘节点和边同步写入Neo4j(LineageNode/LINEAGE关系)
- **图遍历查询**：Cypher `[:LINEAGE*1..N]` 实现多深度BFS
- **影响分析**：方向性图路径查询，返回影响链路和深度
- **最短路径**：`shortestPath()` Cypher函数查找节点间最短路径
- **降级策略**：Neo4j不可用时降级到关系型数据库BFS遍历
- **Schema初始化**：自动创建约束和索引

---

## 4. S10-03: Java AI引擎(LangChain4j)

### 4.1 交付文件

| 文件路径 | 说明 |
|----------|------|
| `common-ai/.../config/AiEngineProperties.java` | AI引擎配置属性(provider/model/temperature等) |
| `common-ai/.../config/AiEngineConfig.java` | LangChain4j自动配置(OpenAI兼容协议) |
| `common-ai/.../client/SmartDataAiClient.java` | AI客户端(对话/描述生成/主数据识别/规则推荐) |
| `common-ai/.../dto/AiChatRequest.java` | AI对话请求DTO |
| `common-ai/.../dto/AiChatResponse.java` | AI对话响应DTO |
| `common-ai/.../dto/AiIdentificationResult.java` | AI主数据识别结果DTO |
| `common-ai/pom.xml` | **修改**：新增langchain4j-open-ai依赖 |

### 4.2 核心实现

- **LangChain4j集成**：通过OpenAI兼容协议对接Qwen/DeepSeek/Ernie/Ollama等
- **AI场景能力**：
  - 数据资产智能描述生成
  - 主数据AI语义识别（返回JSON格式分组+置信度）
  - 质量规则AI推荐（六维规则建议）
- **降级设计**：AI引擎未启用时返回友好降级响应
- **配置驱动**：`platform.ai.enabled=true` 时自动装配

---

## 5. S10-04: 真实SQL执行(dataservice)

### 5.1 交付文件

| 文件路径 | 说明 |
|----------|------|
| `dataservice-service/.../entity/DatasourceConfig.java` | 数据源配置实体 |
| `dataservice-service/.../mapper/DatasourceConfigMapper.java` | 数据源Mapper |
| `dataservice-service/.../service/SqlExecutionService.java` | SQL执行服务接口 |
| `dataservice-service/.../service/impl/SqlExecutionServiceImpl.java` | SQL执行实现(命名参数+分页+注入防护) |
| `dataservice-service/.../service/impl/DataServiceImpl.java` | **修改**：替换mock为真实SQL执行 |
| `dataservice-service/.../controller/DataServiceController.java` | **修改**：新增数据源管理+SQL测试端点 |
| `dataservice-service/pom.xml` | **修改**：新增spring-boot-starter-jdbc依赖 |
| `dataservice-service/.../db/migration/V1__sd_dataservice_tables.sql` | **修改**：新增sd_datasource_config表 |

### 5.2 核心实现

- **真实SQL执行**：NamedParameterJdbcTemplate执行命名参数SQL
- **数据源管理**：支持MySQL/PostgreSQL/DM8/Kingbase/Oracle/OpenGauss
- **SQL注入防护**：
  - 必须SELECT/WITH开头
  - 禁止DROP/TRUNCATE/DELETE/UPDATE/INSERT/ALTER等关键字
  - 禁止分号（防多语句注入）
- **分页支持**：LIMIT/OFFSET自动追加 + COUNT总数统计
- **类型转换**：Blob/Clob/Timestamp/Date自动转换为可序列化类型
- **连接缓存**：DataSource缓存避免重复创建连接池

### 5.3 新增API端点

| 方法 | 路径 | 功能 |
|------|------|------|
| GET | /api/smartdata/dataservice/datasources | 查询数据源配置列表 |
| POST | /api/smartdata/dataservice/datasources | 创建数据源配置 |
| DELETE | /api/smartdata/dataservice/datasources/{id} | 删除数据源配置 |
| POST | /api/smartdata/dataservice/datasources/{id}/test | 测试数据源连接 |
| POST | /api/smartdata/dataservice/datasources/{id}/query | 执行测试SQL查询 |

---

## 6. S10-05: API网关真实路由注册

### 6.1 交付文件

| 文件路径 | 说明 |
|----------|------|
| `gateway/.../resources/application.yml` | **修改**：从9条路由扩展到22条按服务粒度注册 |
| `common-gateway/.../config/DynamicRouteRegistrar.java` | 动态路由注册器(运行时增删路由) |

### 6.2 核心实现

- **按服务粒度路由**：每个微服务独立路由规则，避免负载均衡到错误服务
  - 智数7个服务：catalog/metadata/quality/standard/lineage/mdm/lifecycle/dataservice
  - 智链6个服务：model/app/agent/prompt/cost/risk
  - 共享7个服务：auth/system/security/audit/dashboard/config/notification
  - 数据API网关入口：/api/gateway/**
- **动态路由注册**：支持运行时通过API注册/删除路由
- **服务发现**：lb://协议自动负载均衡

---

## 7. S10-06: AI辅助主数据识别

### 7.1 交付文件

| 文件路径 | 说明 |
|----------|------|
| `mdm-service/.../service/impl/MdmServiceImpl.java` | **修改**：集成AI语义识别+规则降级 |
| `mdm-service/.../resources/application.yml` | **修改**：新增AI引擎配置 |

### 7.2 核心实现

- **AI语义识别**：调用SmartDataAiClient.identifyMasterData()
  - 构建记录摘要(id/name/code/source)输入大模型
  - 大模型返回JSON格式重复分组+置信度+推荐主记录
  - 限制最多50条记录避免Token超限
- **降级策略**：AI不可用或未识别到重复时，降级到名称相似度规则匹配
- **结果标识**：返回identifyMethod字段区分"ai"/"rule"

---

## 8. S10-07: 质量规则定时调度

### 8.1 交付文件

| 文件路径 | 说明 |
|----------|------|
| `quality-service/.../QualityServiceApplication.java` | **修改**：新增@EnableScheduling |
| `quality-service/.../service/QualityScheduleService.java` | 调度服务接口 |
| `quality-service/.../service/impl/QualityScheduleServiceImpl.java` | CRON调度实现(注册/暂停/恢复/触发/扫描) |
| `quality-service/.../controller/QualityController.java` | **修改**：新增调度管理端点 |
| `quality-service/.../resources/application.yml` | **修改**：新增调度配置 |

### 8.2 核心实现

- **CRON调度**：基于Spring CronExpression解析CRON表达式
- **自动注册**：@PostConstruct初始化时扫描数据库注册定时任务
- **定时扫描**：每5分钟自动扫描注册新增的调度任务
- **任务管理**：
  - 手动触发(trigger)
  - 暂停(pause) / 恢复(resume)
  - 列表查询(含调度状态)
- **线程池**：4线程守护线程池执行调度任务
- **优雅关闭**：@PreDestroy清理线程池资源

### 8.3 新增API端点

| 方法 | 路径 | 功能 |
|------|------|------|
| GET | /api/smartdata/quality/schedule/tasks | 查询调度任务列表 |
| POST | /api/smartdata/quality/schedule/tasks/{id}/trigger | 手动触发定时任务 |
| POST | /api/smartdata/quality/schedule/tasks/{id}/pause | 暂停定时任务 |
| POST | /api/smartdata/quality/schedule/tasks/{id}/resume | 恢复定时任务 |
| POST | /api/smartdata/quality/schedule/refresh | 刷新调度任务注册 |

---

## 9. 技术规范遵循情况

| 规范项 | 遵循情况 | 说明 |
|--------|:--------:|------|
| @ConditionalOnProperty | ✅ | ES/Neo4j/AI均按需装配 |
| 降级策略 | ✅ | 所有外部依赖不可用时自动降级 |
| 异常处理 | ✅ | BusinessException统一包装 |
| 日志规范 | ✅ | @Slf4j + 结构化日志 |
| Knife4j文档 | ✅ | 新增端点配置@Operation |
| 配置外部化 | ✅ | 环境变量占位符 |
| SQL安全 | ✅ | SQL注入防护+关键字过滤 |
| 线程安全 | ✅ | ConcurrentHashMap缓存 |

---

## 10. 依赖变更

| 模块 | 新增依赖 | 版本 |
|------|----------|------|
| common-ai | langchain4j-open-ai | 0.34.0 |
| lineage-service | neo4j-java-driver | 5.20.0 |
| dataservice-service | spring-boot-starter-jdbc | (继承) |

---

## 11. 遗留与待办

| 编号 | 待办项 | 计划Sprint | 优先级 |
|:----:|--------|:----------:|:------:|
| 1 | ES IK分词器插件部署验证 | S11 | 中 |
| 2 | Neo4j数据初始化导入脚本 | S11 | 中 |
| 3 | AI引擎Ollama本地模型对接测试 | S11 | 高 |
| 4 | 数据源密码加密存储(AES/SM4) | S11 | 高 |
| 5 | 质量调度任务执行日志持久化 | S11 | 低 |
| 6 | 网关动态路由Nacos配置中心集成 | S11 | 中 |
