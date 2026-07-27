# 智数 (SmartData) 详细设计说明书

| 属性 | 内容 |
|------|------|
| 文档编号 | SD-DD-01 |
| 文档名称 | 智数平台详细设计说明书 |
| 版本号 | V1.0.0 |
| 状态 | 已评审 |
| 编制日期 | 2026-07-10 |
| 编制人 | 智数研发组 |
| 审核人 | 架构委员会 |

---

## 目录

1. [数据资产管理详细设计](#1-数据资产管理详细设计)
2. [元数据管理详细设计](#2-元数据管理详细设计)
3. [数据质量管理详细设计](#3-数据质量管理详细设计)
4. [数据标准管理详细设计](#4-数据标准管理详细设计)
5. [数据血缘分析详细设计](#5-数据血缘分析详细设计)
6. [主数据管理详细设计](#6-主数据管理详细设计)
7. [数据生命周期管理详细设计](#7-数据生命周期管理详细设计)
8. [数据服务管理详细设计](#8-数据服务管理详细设计)
9. [前端详细设计](#9-前端详细设计)

---

## 1. 数据资产管理详细设计

### 1.1 数据库设计

#### 1.1.1 数据资产表 (sd_asset)

```sql
CREATE TABLE sd_asset (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    asset_code      VARCHAR(64)  NOT NULL UNIQUE COMMENT '资产编码',
    asset_name      VARCHAR(200) NOT NULL COMMENT '资产名称',
    asset_type      VARCHAR(32)  NOT NULL COMMENT '类型: TABLE/VIEW/API/FILE/STREAM',
    description     TEXT         COMMENT '描述',
    source_id       BIGINT       COMMENT '数据源ID',
    source_system   VARCHAR(100) COMMENT '来源系统',
    catalog_id      BIGINT       NOT NULL COMMENT '目录ID',
    owner           VARCHAR(64)  COMMENT '负责人',
    department      VARCHAR(100) COMMENT '部门',
    tags            JSON         COMMENT '标签列表',
    classification  VARCHAR(32)  DEFAULT 'INTERNAL' COMMENT '密级',
    quality_score   DECIMAL(5,2) DEFAULT 0 COMMENT '质量评分',
    usage_count     BIGINT       DEFAULT 0 COMMENT '使用次数',
    status          VARCHAR(16)  DEFAULT 'DRAFT' COMMENT '状态',
    tenant_id       BIGINT       NOT NULL,
    created_by      VARCHAR(64),
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    updated_by      VARCHAR(64),
    updated_at      DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted         TINYINT      DEFAULT 0,
    INDEX idx_catalog (catalog_id),
    INDEX idx_tenant (tenant_id),
    INDEX idx_status (status),
    INDEX idx_name (asset_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据资产表';
```

#### 1.1.2 资产目录表 (sd_catalog)

```sql
CREATE TABLE sd_catalog (
    id          BIGINT       PRIMARY KEY AUTO_INCREMENT,
    parent_id   BIGINT       DEFAULT 0 COMMENT '父节点ID',
    node_name   VARCHAR(200) NOT NULL COMMENT '节点名称',
    node_code   VARCHAR(64)  NOT NULL COMMENT '节点编码',
    node_level  INT          DEFAULT 1 COMMENT '层级',
    sort_order  INT          DEFAULT 0 COMMENT '排序',
    description VARCHAR(500),
    visibility  VARCHAR(16)  DEFAULT 'PUBLIC' COMMENT '可见性',
    tenant_id   BIGINT       NOT NULL,
    created_by  VARCHAR(64),
    created_at  DATETIME     DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted     TINYINT      DEFAULT 0,
    INDEX idx_parent (parent_id),
    INDEX idx_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='资产目录表';
```

#### 1.1.3 资产评分表 (sd_asset_score)

```sql
CREATE TABLE sd_asset_score (
    id              BIGINT   PRIMARY KEY AUTO_INCREMENT,
    asset_id        BIGINT   NOT NULL,
    dimension       VARCHAR(32) NOT NULL COMMENT '维度: COMPLETENESS/ACCURACY/CONSISTENCY/TIMELINESS/UNIQUENESS/VALIDITY',
    score           DECIMAL(5,2) NOT NULL COMMENT '评分(0-100)',
    weight          DECIMAL(3,2) DEFAULT 1.00 COMMENT '权重',
    check_count     INT      DEFAULT 0 COMMENT '检测次数',
    pass_count      INT      DEFAULT 0 COMMENT '通过次数',
    check_time      DATETIME COMMENT '检测时间',
    tenant_id       BIGINT   NOT NULL,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_asset (asset_id),
    INDEX idx_dimension (dimension)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='资产评分表';
```

### 1.2 核心类设计

```java
// === Entity ===
@Data
@TableName("sd_asset")
public class Asset {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String assetCode;
    private String assetName;
    private String assetType;
    private String description;
    private Long sourceId;
    private String sourceSystem;
    private Long catalogId;
    private String owner;
    private String department;
    private String tags;          // JSON
    private String classification;
    private BigDecimal qualityScore;
    private Long usageCount;
    private String status;
    private Long tenantId;
    // 审计字段...
}

// === Service ===
public interface AssetService {
    PageResult<AssetVO> queryAssets(AssetQueryDTO query);
    AssetVO getAssetDetail(Long id);
    AssetVO createAsset(AssetCreateDTO dto);
    AssetVO updateAsset(Long id, AssetUpdateDTO dto);
    void deleteAsset(Long id);
    void publishAsset(Long id);
    void offlineAsset(Long id);
    List<AssetVO> searchAssets(String keyword, AssetFilterDTO filter);
    AssetScoreVO getAssetScore(Long assetId);
    void importAssets(MultipartFile file);
    void exportAssets(AssetQueryDTO query, HttpServletResponse response);
}

// === Controller ===
@RestController
@RequestMapping("/api/v1/assets")
public class AssetController {
    @GetMapping
    public ApiResponse<PageResult<AssetVO>> list(AssetQueryDTO query) { ... }
    
    @GetMapping("/search")
    public ApiResponse<List<AssetVO>> search(@RequestParam String q, AssetFilterDTO filter) { ... }
    
    @GetMapping("/{id}")
    public ApiResponse<AssetDetailVO> detail(@PathVariable Long id) { ... }
    
    @PostMapping
    public ApiResponse<AssetVO> create(@Valid @RequestBody AssetCreateDTO dto) { ... }
    
    @PutMapping("/{id}")
    public ApiResponse<AssetVO> update(@PathVariable Long id, @Valid @RequestBody AssetUpdateDTO dto) { ... }
    
    @PostMapping("/{id}/publish")
    public ApiResponse<Void> publish(@PathVariable Long id) { ... }
    
    @PostMapping("/import")
    public ApiResponse<ImportResult> importAssets(@RequestParam MultipartFile file) { ... }
}
```

### 1.3 Elasticsearch索引设计

```json
{
  "sd_asset_index": {
    "mappings": {
      "properties": {
        "assetCode": { "type": "keyword" },
        "assetName": { "type": "text", "analyzer": "ik_max_word", "search_analyzer": "ik_smart" },
        "description": { "type": "text", "analyzer": "ik_max_word" },
        "assetType": { "type": "keyword" },
        "sourceSystem": { "type": "keyword" },
        "catalogPath": { "type": "keyword" },
        "tags": { "type": "keyword" },
        "classification": { "type": "keyword" },
        "qualityScore": { "type": "double" },
        "status": { "type": "keyword" },
        "owner": { "type": "keyword" },
        "department": { "type": "keyword" },
        "tenantId": { "type": "long" },
        "createdAt": { "type": "date" }
      }
    }
  }
}
```

### 1.4 核心流程设计

#### 1.4.1 资产自动发现流程

```
1. 配置数据源连接 (DataSource)
2. 调度采集任务 (Schedule)
3. 执行采集:
   a. 连接数据源
   b. 获取表/视图/字段信息
   c. 转换为标准元数据模型
   d. 与已有资产比对(增量)
   e. 新增资产自动注册(DRAFT状态)
   f. 变更资产记录变更日志
4. 触发元数据采集
5. 更新Elasticsearch索引
6. 通知资产管理员审核
```

#### 1.4.2 全文检索流程

```
1. 用户输入关键词
2. ES执行多字段匹配查询(assetName^3 + description + tags)
3. 叠加过滤条件(分类/标签/数据源/质量评分)
4. 按相关度+质量评分+使用热度综合排序
5. 高亮匹配结果
6. 返回分页结果
```

---

## 2. 元数据管理详细设计

### 2.1 数据库设计

```sql
CREATE TABLE sd_metadata_source (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    source_name     VARCHAR(200) NOT NULL COMMENT '数据源名称',
    source_type     VARCHAR(32)  NOT NULL COMMENT 'MYSQL/ORACLE/DM8/HIVE/KAFKA',
    host            VARCHAR(200) NOT NULL,
    port            INT          NOT NULL,
    database_name   VARCHAR(100),
    username        VARCHAR(100),
    password_enc    VARCHAR(500) COMMENT 'SM4加密',
    params          JSON         COMMENT '额外参数',
    status          VARCHAR(16)  DEFAULT 'ACTIVE',
    tenant_id       BIGINT       NOT NULL,
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_type (source_type),
    INDEX idx_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='元数据数据源';

CREATE TABLE sd_metadata (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    source_id       BIGINT       NOT NULL,
    asset_id        BIGINT       COMMENT '关联资产ID',
    metadata_type   VARCHAR(16)  NOT NULL COMMENT 'TECHNICAL/BUSINESS/MANAGEMENT',
    object_type     VARCHAR(16)  NOT NULL COMMENT 'DATABASE/TABLE/COLUMN/INDEX/VIEW',
    object_name     VARCHAR(200) NOT NULL,
    object_comment  VARCHAR(500),
    parent_id       BIGINT       COMMENT '父对象ID',
    data_type       VARCHAR(50)  COMMENT '数据类型(列级)',
    data_length     INT          COMMENT '长度',
    data_precision  INT          COMMENT '精度',
    nullable        TINYINT      DEFAULT 1,
    primary_key     TINYINT      DEFAULT 0,
    business_name   VARCHAR(200) COMMENT '业务名称',
    business_desc   TEXT         COMMENT '业务描述',
    data_format     VARCHAR(50)  COMMENT '数据格式',
    sensitive_level VARCHAR(16)  COMMENT '敏感级别',
    version         INT          DEFAULT 1,
    tenant_id       BIGINT       NOT NULL,
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_source (source_id),
    INDEX idx_asset (asset_id),
    INDEX idx_type (metadata_type),
    INDEX idx_parent (parent_id),
    INDEX idx_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='元数据表';

CREATE TABLE sd_metadata_change_log (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    metadata_id     BIGINT       NOT NULL,
    change_type     VARCHAR(16)  NOT NULL COMMENT 'ADD/MODIFY/DELETE',
    field_name      VARCHAR(100) COMMENT '变更字段',
    old_value       TEXT,
    new_value       TEXT,
    change_time     DATETIME     DEFAULT CURRENT_TIMESTAMP,
    change_by       VARCHAR(64),
    tenant_id       BIGINT       NOT NULL,
    INDEX idx_metadata (metadata_id),
    INDEX idx_time (change_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='元数据变更日志';
```

### 2.2 采集器架构

```java
// 采集器接口
public interface MetadataCollector {
    String getSourceType();
    List<MetadataDTO> collect(DataSourceDTO source) throws CollectException;
    boolean testConnection(DataSourceDTO source);
    boolean supportsIncremental();
    List<MetadataDTO> collectIncremental(DataSourceDTO source, Date lastCollectTime);
}

// MySQL采集器
@Component
public class MySqlMetadataCollector implements MetadataCollector {
    @Override
    public String getSourceType() { return "MYSQL"; }
    
    @Override
    public List<MetadataDTO> collect(DataSourceDTO source) {
        // 1. 获取所有数据库
        // 2. 遍历数据库获取表
        // 3. 获取列信息
        // 4. 获取索引信息
        // 5. 转换为标准MetadataDTO
    }
}

// DM8采集器
@Component
public class Dm8MetadataCollector implements MetadataCollector { ... }

// 采集器工厂
@Component
public class MetadataCollectorFactory {
    private final Map<String, MetadataCollector> collectors;
    
    public MetadataCollector getCollector(String sourceType) {
        return collectors.get(sourceType);
    }
}
```

### 2.3 AI辅助标注设计

```java
@Service
public class AiMetadataAnnotationService {
    
    private final AiClient aiClient;
    
    /**
     * AI标注字段业务信息
     */
    public FieldAnnotation annotate(FieldMetadata field) {
        String prompt = buildAnnotationPrompt(field);
        AiChatResponse response = aiClient.chat(prompt);
        return parseAnnotation(response.getContent());
    }
    
    private String buildAnnotationPrompt(FieldMetadata field) {
        return String.format("""
            作为数据治理专家，请为以下数据库字段标注业务信息：
            表名: %s
            表注释: %s
            字段名: %s
            字段注释: %s
            数据类型: %s
            
            请返回JSON格式:
            {"businessName": "业务名称", "businessDesc": "业务描述", "sensitiveLevel": "敏感级别"}
            """, field.getTableName(), field.getTableComment(),
            field.getColumnName(), field.getColumnComment(), field.getDataType());
    }
}
```

---

## 3. 数据质量管理详细设计

### 3.1 数据库设计

```sql
CREATE TABLE sd_quality_rule (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    rule_code       VARCHAR(64)  NOT NULL UNIQUE,
    rule_name       VARCHAR(200) NOT NULL,
    dimension       VARCHAR(32)  NOT NULL COMMENT '质量维度',
    rule_type       VARCHAR(16)  NOT NULL COMMENT 'TEMPLATE/CUSTOM',
    template_id     BIGINT       COMMENT '模板ID',
    target_type     VARCHAR(16)  NOT NULL COMMENT 'TABLE/COLUMN',
    target_asset_id BIGINT,
    target_table    VARCHAR(200),
    target_column   VARCHAR(200),
    rule_expression TEXT         NOT NULL COMMENT '规则表达式(SQL)',
    rule_config     JSON         COMMENT '规则参数',
    severity        VARCHAR(16)  DEFAULT 'WARNING' COMMENT '严重级别',
    enabled         TINYINT      DEFAULT 1,
    tenant_id       BIGINT       NOT NULL,
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_asset (target_asset_id),
    INDEX idx_dimension (dimension),
    INDEX idx_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='质量规则表';

CREATE TABLE sd_quality_check_result (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    rule_id         BIGINT       NOT NULL,
    asset_id        BIGINT       NOT NULL,
    check_time      DATETIME     NOT NULL,
    total_count     BIGINT       COMMENT '总记录数',
    error_count     BIGINT       COMMENT '错误记录数',
    pass_rate       DECIMAL(5,2) COMMENT '通过率',
    score           DECIMAL(5,2) COMMENT '评分',
    status          VARCHAR(16)  COMMENT 'PASS/FAIL',
    error_samples   JSON         COMMENT '错误样本',
    tenant_id       BIGINT       NOT NULL,
    INDEX idx_rule (rule_id),
    INDEX idx_asset (asset_id),
    INDEX idx_time (check_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='质量检测结果表';

CREATE TABLE sd_quality_issue (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    issue_code      VARCHAR(64)  NOT NULL UNIQUE,
    rule_id         BIGINT       NOT NULL,
    asset_id        BIGINT       NOT NULL,
    severity        VARCHAR(16)  NOT NULL,
    description     TEXT,
    status          VARCHAR(16)  DEFAULT 'OPEN' COMMENT 'OPEN/ASSIGNED/RESOLVED/CLOSED',
    assignee        VARCHAR(64),
    due_date        DATE,
    resolved_at     DATETIME,
    resolution      TEXT,
    tenant_id       BIGINT       NOT NULL,
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_asset (asset_id),
    INDEX idx_status (status),
    INDEX idx_assignee (assignee)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='质量问题工单表';
```

### 3.2 规则模板设计

```java
public enum QualityRuleTemplate {
    NOT_NULL("非空检查", "COMPLETENESS", 
        "SELECT COUNT(*) FROM {table} WHERE {column} IS NULL"),
    UNIQUE("唯一性检查", "UNIQUENESS",
        "SELECT {column}, COUNT(*) as cnt FROM {table} GROUP BY {column} HAVING COUNT(*) > 1"),
    RANGE("范围检查", "VALIDITY",
        "SELECT COUNT(*) FROM {table} WHERE {column} < {min} OR {column} > {max}"),
    REGEX("正则检查", "VALIDITY",
        "SELECT COUNT(*) FROM {table} WHERE {column} NOT REGEXP '{pattern}'"),
    ENUM("枚举检查", "VALIDITY",
        "SELECT COUNT(*) FROM {table} WHERE {column} NOT IN ({values})"),
    REFERENCE("引用完整性", "CONSISTENCY",
        "SELECT COUNT(*) FROM {table} a WHERE NOT EXISTS (SELECT 1 FROM {ref_table} b WHERE a.{column} = b.{ref_column})"),
    FRESHNESS("时效性检查", "TIMELINESS",
        "SELECT MAX({column}) as latest FROM {table}");
    
    // ...
}
```

### 3.3 质量检测执行流程

```
1. 调度器触发检测任务
2. 加载启用的质量规则列表
3. 并行执行规则检测(线程池)
4. 每条规则:
   a. 解析规则表达式(替换变量)
   b. 连接目标数据源
   c. 执行检测SQL
   d. 计算通过率和评分
   e. 保存检测结果
   f. 如果不通过，生成质量问题工单
5. 汇总检测报告
6. 更新资产质量评分
7. 发送通知
```

---

## 4. 数据标准管理详细设计

### 4.1 数据库设计

```sql
CREATE TABLE sd_standard (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    standard_code   VARCHAR(64)  NOT NULL UNIQUE COMMENT '标准编码',
    standard_name   VARCHAR(200) NOT NULL COMMENT '标准名称',
    standard_type   VARCHAR(16)  NOT NULL COMMENT 'BUSINESS/TECHNICAL/MANAGEMENT',
    category_id     BIGINT       COMMENT '分类ID',
    data_type       VARCHAR(50)  COMMENT '数据类型',
    data_format     VARCHAR(100) COMMENT '数据格式',
    value_domain    TEXT         COMMENT '值域(JSON)',
    unit            VARCHAR(50)  COMMENT '计量单位',
    description     TEXT,
    status          VARCHAR(16)  DEFAULT 'DRAFT' COMMENT 'DRAFT/PUBLISHED/OBSOLETE',
    version         INT          DEFAULT 1,
    tenant_id       BIGINT       NOT NULL,
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_type (standard_type),
    INDEX idx_category (category_id),
    INDEX idx_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据标准表';

CREATE TABLE sd_standard_mapping (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    standard_id     BIGINT       NOT NULL,
    metadata_id     BIGINT       NOT NULL,
    mapping_status  VARCHAR(16)  DEFAULT 'MAPPED' COMMENT 'MAPPED/CONFLICT/EXEMPT',
    compliance      TINYINT      DEFAULT 1 COMMENT '是否合规',
    exemption_reason VARCHAR(500) COMMENT '豁免原因',
    tenant_id       BIGINT       NOT NULL,
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_std_meta (standard_id, metadata_id),
    INDEX idx_standard (standard_id),
    INDEX idx_metadata (metadata_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='标准映射表';
```

---

## 5. 数据血缘分析详细设计

### 5.1 Neo4j图模型

```cypher
// 节点标签
(:DataSource {id, name, type})
(:Database {id, name, sourceId})
(:Table {id, name, databaseId, sourceSystem})
(:Column {id, name, tableId, dataType})
(:Process {id, name, type, script, schedule})

// 关系类型
[:CONTAINS_DB]     (DataSource -> Database)
[:CONTAINS_TABLE]  (Database -> Table)
[:HAS_COLUMN]      (Table -> Column)
[:INPUT_TO]        (Table -> Process)     // 表作为ETL输入
[:OUTPUT_FROM]     (Process -> Table)     // ETL输出到表
[:DERIVED_FROM]    (Column -> Column)     // 字段级血缘
[:JOINED_WITH]     (Table -> Table)       // JOIN关系
```

### 5.2 SQL解析血缘采集

```java
@Component
public class SqlLineageParser {
    
    /**
     * 解析SQL提取血缘关系
     */
    public LineageResult parse(String sql, String sourceType) {
        // 1. SQL方言适配
        SqlDialect dialect = getDialect(sourceType);
        
        // 2. 使用Calcite/Druid解析SQL AST
        SqlNode ast = parseSql(sql, dialect);
        
        // 3. 提取源表和目标表
        List<TableRef> sources = extractSourceTables(ast);
        List<TableRef> targets = extractTargetTables(ast);
        
        // 4. 提取字段级映射(SELECT字段 → 源字段)
        List<ColumnMapping> mappings = extractColumnMappings(ast);
        
        // 5. 构建血缘关系
        return LineageResult.builder()
            .sources(sources)
            .targets(targets)
            .columnMappings(mappings)
            .build();
    }
    
    /**
     * 存储血缘到Neo4j
     */
    public void saveToNeo4j(LineageResult result) {
        // 创建/合并Table节点
        // 创建/合并Column节点
        // 创建DERIVED_FROM关系
        // 创建INPUT_TO/OUTPUT_FROM关系
    }
}
```

### 5.3 血缘查询API

```java
@RestController
@RequestMapping("/api/v1/lineage")
public class LineageController {
    
    @GetMapping("/{assetId}")
    public ApiResponse<LineageGraphVO> getLineage(
            @PathVariable Long assetId,
            @RequestParam(defaultValue = "BOTH") String direction,  // UPSTREAM/DOWNSTREAM/BOTH
            @RequestParam(defaultValue = "3") int depth) {
        // Cypher查询
        // MATCH path = (n:Table)-[:INPUT_TO|OUTPUT_FROM*1..3]-(related:Table)
        // WHERE n.id = $assetId
        // RETURN path
    }
    
    @GetMapping("/impact")
    public ApiResponse<ImpactResultVO> impactAnalysis(
            @RequestParam Long assetId,
            @RequestParam String changeType) {
        // 分析下游影响
    }
}
```

---

## 6. 主数据管理详细设计

### 6.1 核心表设计

```sql
CREATE TABLE sd_mdm_entity (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    entity_code     VARCHAR(64)  NOT NULL UNIQUE,
    entity_name     VARCHAR(200) NOT NULL,
    entity_type     VARCHAR(32)  COMMENT 'CUSTOMER/PRODUCT/ORG/PERSON/ACCOUNT',
    description     TEXT,
    source_system   VARCHAR(100),
    status          VARCHAR(16)  DEFAULT 'ACTIVE',
    tenant_id       BIGINT       NOT NULL,
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='主数据实体定义';

CREATE TABLE sd_mdm_attribute (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    entity_id       BIGINT       NOT NULL,
    attr_code       VARCHAR(64)  NOT NULL,
    attr_name       VARCHAR(200) NOT NULL,
    data_type       VARCHAR(50)  NOT NULL,
    data_length     INT,
    nullable        TINYINT      DEFAULT 1,
    is_unique       TINYINT      DEFAULT 0,
    is_primary      TINYINT      DEFAULT 0,
    default_value   VARCHAR(200),
    validation_rule VARCHAR(500),
    standard_id     BIGINT       COMMENT '关联数据标准',
    sort_order      INT          DEFAULT 0,
    tenant_id       BIGINT       NOT NULL,
    INDEX idx_entity (entity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='主数据属性定义';
```

---

## 7. 数据生命周期管理详细设计

### 7.1 核心表设计

```sql
CREATE TABLE sd_lifecycle_policy (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    policy_name     VARCHAR(200) NOT NULL,
    policy_type     VARCHAR(32)  NOT NULL COMMENT 'ARCHIVE/DESTROY/RETAIN',
    target_type     VARCHAR(32)  NOT NULL COMMENT 'TABLE/PARTITION/RECORD',
    condition_expr  TEXT         COMMENT '条件表达式',
    action_type     VARCHAR(32)  COMMENT 'MOVE_TO_COLD/DELETE/EXPORT',
    target_storage  VARCHAR(100) COMMENT '目标存储(归档)',
    schedule_cron   VARCHAR(100) COMMENT '调度周期',
    retention_days  INT          COMMENT '保留天数',
    enabled         TINYINT      DEFAULT 1,
    tenant_id       BIGINT       NOT NULL,
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='生命周期策略表';

CREATE TABLE sd_lifecycle_execution (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    policy_id       BIGINT       NOT NULL,
    target_asset_id BIGINT,
    execution_time  DATETIME     NOT NULL,
    status          VARCHAR(16)  COMMENT 'RUNNING/SUCCESS/FAILED',
    affected_rows   BIGINT,
    detail          TEXT,
    tenant_id       BIGINT       NOT NULL,
    INDEX idx_policy (policy_id),
    INDEX idx_time (execution_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='生命周期执行记录';
```

---

## 8. 数据服务管理详细设计

### 8.1 核心表设计

```sql
CREATE TABLE sd_data_service (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    service_code    VARCHAR(64)  NOT NULL UNIQUE,
    service_name    VARCHAR(200) NOT NULL,
    service_type    VARCHAR(16)  NOT NULL COMMENT 'QUERY/INSERT/UPDATE/DELETE',
    source_type     VARCHAR(16)  NOT NULL COMMENT 'TABLE/SQL/VIEW',
    source_config   JSON         NOT NULL COMMENT '数据源配置',
    api_path        VARCHAR(200) NOT NULL UNIQUE COMMENT 'API路径',
    api_method      VARCHAR(10)  DEFAULT 'GET',
    parameters      JSON         COMMENT 'API参数定义',
    response_format VARCHAR(16)  DEFAULT 'JSON',
    cache_enabled   TINYINT      DEFAULT 0,
    cache_ttl       INT          DEFAULT 0,
    status          VARCHAR(16)  DEFAULT 'PUBLISHED',
    version         INT          DEFAULT 1,
    tenant_id       BIGINT       NOT NULL,
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_path (api_path),
    INDEX idx_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据服务表';

CREATE TABLE sd_data_service_auth (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    service_id      BIGINT       NOT NULL,
    app_key         VARCHAR(128) NOT NULL UNIQUE,
    app_secret_enc  VARCHAR(500) NOT NULL COMMENT 'SM4加密',
    allowed_ips     JSON         COMMENT 'IP白名单',
    rate_limit_qps  INT          DEFAULT 100,
    daily_limit     INT          DEFAULT 0 COMMENT '日调用上限(0=不限)',
    expires_at      DATETIME,
    enabled         TINYINT      DEFAULT 1,
    tenant_id       BIGINT       NOT NULL,
    INDEX idx_service (service_id),
    INDEX idx_appkey (app_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据服务授权表';
```

### 8.2 API动态发布设计

```java
@Service
public class DataApiInvoker {
    
    public Object invoke(DataService service, Map<String, Object> params) {
        // 1. 参数校验
        validateParams(service, params);
        
        // 2. 鉴权检查
        checkAuth(service, params);
        
        // 3. 限流检查
        checkRateLimit(service);
        
        // 4. 缓存检查
        if (service.isCacheEnabled()) {
            Object cached = cache.get(buildCacheKey(service, params));
            if (cached != null) return cached;
        }
        
        // 5. 执行查询
        Object result;
        if ("TABLE".equals(service.getSourceType())) {
            result = queryByTable(service, params);
        } else if ("SQL".equals(service.getSourceType())) {
            result = queryBySql(service, params);
        }
        
        // 6. 响应格式化
        result = formatResponse(service, result);
        
        // 7. 缓存写入
        if (service.isCacheEnabled()) {
            cache.put(buildCacheKey(service, params), result, service.getCacheTtl());
        }
        
        // 8. 记录调用日志
        logInvocation(service, params, result);
        
        return result;
    }
}
```

---

## 9. 前端详细设计

### 9.1 页面结构

```
src/
├── api/                    # API请求
│   ├── catalog.ts          # 数据资产API
│   ├── metadata.ts         # 元数据API
│   ├── quality.ts          # 质量API
│   ├── standard.ts         # 标准API
│   ├── lineage.ts          # 血缘API
│   ├── mdm.ts              # 主数据API
│   ├── lifecycle.ts        # 生命周期API
│   └── service.ts          # 数据服务API
├── components/             # 公共组件
│   ├── CatalogTree.vue     # 目录树
│   ├── AssetCard.vue       # 资产卡片
│   ├── QualityScore.vue    # 质量评分卡
│   ├── LineageGraph.vue    # 血缘图
│   ├── StandardMapping.vue # 标准映射
│   ├── MetadataTable.vue   # 元数据表格
│   ├── RuleEditor.vue      # 规则编辑器
│   └── ServiceTester.vue   # API测试器
├── views/                  # 页面
│   ├── DashboardView.vue   # 治理总览
│   ├── catalog/            # 数据资产
│   ├── metadata/           # 元数据
│   ├── quality/            # 数据质量
│   ├── standards/          # 数据标准
│   ├── lineage/            # 数据血缘
│   ├── mdm/                # 主数据
│   ├── lifecycle/          # 生命周期
│   └── services/           # 数据服务
├── stores/                 # Pinia状态
├── composables/            # 组合函数
├── router/                 # 路由
├── styles/                 # 样式
├── types/                  # 类型定义
└── utils/                  # 工具函数
```

### 9.2 路由设计

```typescript
const routes = [
  { path: '/', redirect: '/dashboard' },
  { path: '/dashboard', component: () => import('@/views/DashboardView.vue'), meta: { title: '治理总览' } },
  
  // 数据资产
  { path: '/catalog', component: () => import('@/views/catalog/CatalogView.vue'), meta: { title: '数据目录' } },
  { path: '/catalog/:id', component: () => import('@/views/catalog/CatalogDetailView.vue'), meta: { title: '资产详情' } },
  
  // 元数据
  { path: '/metadata', component: () => import('@/views/metadata/MetadataView.vue'), meta: { title: '元数据管理' } },
  { path: '/metadata/lineage', component: () => import('@/views/metadata/LineageView.vue'), meta: { title: '血缘分析' } },
  
  // 数据质量
  { path: '/quality', component: () => import('@/views/quality/QualityView.vue'), meta: { title: '质量总览' } },
  { path: '/quality/rules', component: () => import('@/views/quality/QualityRulesView.vue'), meta: { title: '质量规则' } },
  { path: '/quality/reports', component: () => import('@/views/quality/QualityReportsView.vue'), meta: { title: '质量报告' } },
  
  // 数据标准
  { path: '/standards', component: () => import('@/views/standards/StandardsView.vue'), meta: { title: '数据标准' } },
  
  // 血缘
  { path: '/lineage', component: () => import('@/views/metadata/LineageView.vue'), meta: { title: '血缘分析' } },
  
  // 主数据
  { path: '/mdm', component: () => import('@/views/mdm/MDMView.vue'), meta: { title: '主数据管理' } },
  
  // 生命周期
  { path: '/lifecycle', component: () => import('@/views/lifecycle/LifecycleView.vue'), meta: { title: '生命周期' } },
  
  // 数据服务
  { path: '/services', component: () => import('@/views/services/DataServicesView.vue'), meta: { title: '数据服务' } },
]
```

### 9.3 核心组件设计

#### 血缘图组件 (LineageGraph.vue)

```vue
<template>
  <div class="lineage-graph" ref="container">
    <div class="lineage-toolbar">
      <el-button-group>
        <el-button @click="zoomIn">放大</el-button>
        <el-button @click="zoomOut">缩小</el-button>
        <el-button @click="fitView">适应</el-button>
      </el-button-group>
      <el-radio-group v-model="viewLevel" @change="reload">
        <el-radio-button value="table">表级</el-radio-button>
        <el-radio-button value="column">字段级</el-radio-button>
      </el-radio-group>
      <el-radio-group v-model="direction" @change="reload">
        <el-radio-button value="upstream">上游</el-radio-button>
        <el-radio-button value="downstream">下游</el-radio-button>
        <el-radio-button value="both">全部</el-radio-button>
      </el-radio-group>
    </div>
    <div class="lineage-canvas" ref="canvas"></div>
  </div>
</template>

<script setup lang="ts">
import G6 from '@antv/g6'
import { ref, onMounted, watch } from 'vue'

const props = defineProps<{
  assetId: number
  direction?: 'upstream' | 'downstream' | 'both'
  depth?: number
}>()

// G6 DAG图初始化
// 节点拖拽、缩放、点击交互
// 表级/字段级切换
// 影响分析高亮路径
</script>
```

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|---------|
| V1.0.0 | 2026-07-10 | 智数研发组 | 初始版本 |

---

> **文档结束** — 智数(SmartData)详细设计说明书 V1.0.0
