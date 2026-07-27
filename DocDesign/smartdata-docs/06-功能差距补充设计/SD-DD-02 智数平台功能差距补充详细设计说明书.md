# 智数 (SmartData) 功能差距补充详细设计说明书

| 属性 | 内容 |
|------|------|
| 文档编号 | SD-DD-02 |
| 文档名称 | 智数平台功能差距补充详细设计说明书 |
| 版本号 | V1.0.0 |
| 状态 | 已评审 |
| 编制日期 | 2026-07-15 |
| 编制人 | 智数研发组 |
| 审核人 | 架构委员会 |

---

## 目录

1. [数据探查服务详细设计](#1-数据探查服务详细设计)
2. [标签管理服务详细设计](#2-标签管理服务详细设计)
3. [治理工作流服务详细设计](#3-治理工作流服务详细设计)
4. [数据资产估值服务详细设计](#4-数据资产估值服务详细设计)
5. [数据产品服务详细设计](#5-数据产品服务详细设计)
6. [自助分析服务详细设计](#6-自助分析服务详细设计)
7. [数据集成服务详细设计](#7-数据集成服务详细设计)
8. [API接口规格总览](#8-api接口规格总览)

---

## 1. 数据探查服务详细设计

### 1.1 数据库设计

#### 1.1.1 探查任务表 (sd_profile_task)

```sql
CREATE TABLE sd_profile_task (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    task_name       VARCHAR(200) NOT NULL COMMENT '任务名称',
    asset_id        BIGINT       NOT NULL COMMENT '资产ID',
    data_source_id  BIGINT       NOT NULL COMMENT '数据源ID',
    table_name      VARCHAR(200) NOT NULL COMMENT '表名',
    scope_type      VARCHAR(16)  DEFAULT 'SAMPLE' COMMENT 'FULL/SAMPLE',
    sample_ratio    DECIMAL(5,2) DEFAULT 10.00 COMMENT '抽样比例(%)',
    options         JSON         COMMENT '探查选项',
    status          VARCHAR(16)  DEFAULT 'PENDING' COMMENT 'PENDING/RUNNING/SUCCESS/FAILED/CANCELLED',
    row_count       BIGINT       DEFAULT 0 COMMENT '总行数',
    column_count    INT          DEFAULT 0 COMMENT '字段数',
    health_score    DECIMAL(5,2) DEFAULT 0 COMMENT '健康分(0-100)',
    anomaly_count   INT          DEFAULT 0 COMMENT '异常字段数',
    error_message   TEXT         COMMENT '失败原因',
    started_at      DATETIME     COMMENT '开始时间',
    finished_at     DATETIME     COMMENT '完成时间',
    duration_ms     BIGINT       DEFAULT 0 COMMENT '执行耗时(毫秒)',
    tenant_id       BIGINT       NOT NULL,
    created_by      VARCHAR(64),
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted         TINYINT      DEFAULT 0,
    INDEX idx_asset (asset_id),
    INDEX idx_source (data_source_id),
    INDEX idx_status (status),
    INDEX idx_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据探查任务表';
```

#### 1.1.2 字段画像表 (sd_profile_column)

```sql
CREATE TABLE sd_profile_column (
    id               BIGINT       PRIMARY KEY AUTO_INCREMENT,
    task_id          BIGINT       NOT NULL COMMENT '探查任务ID',
    column_name      VARCHAR(200) NOT NULL COMMENT '字段名',
    data_type        VARCHAR(64)  NOT NULL COMMENT '数据类型',
    ordinal_position INT          DEFAULT 0 COMMENT '字段顺序',
    total_count      BIGINT       DEFAULT 0 COMMENT '总行数',
    null_count       BIGINT       DEFAULT 0 COMMENT '空值数',
    null_rate        DECIMAL(8,4) DEFAULT 0 COMMENT '空值率',
    unique_count     BIGINT       DEFAULT 0 COMMENT '唯一值数',
    unique_rate      DECIMAL(8,4) DEFAULT 0 COMMENT '唯一值率',
    min_value        VARCHAR(500) COMMENT '最小值',
    max_value        VARCHAR(500) COMMENT '最大值',
    avg_value        DECIMAL(20,4) COMMENT '平均值',
    median_value     VARCHAR(500) COMMENT '中位数',
    stddev_value     DECIMAL(20,4) COMMENT '标准差',
    q1_value         VARCHAR(500) COMMENT '第一四分位数',
    q3_value         VARCHAR(500) COMMENT '第三四分位数',
    min_length       INT          COMMENT '最小长度',
    max_length       INT          COMMENT '最大长度',
    avg_length       DECIMAL(10,2) COMMENT '平均长度',
    top_values       JSON         COMMENT 'Top-N高频值',
    histogram        JSON         COMMENT '直方图',
    detected_pattern VARCHAR(32)  COMMENT '识别模式: PHONE/EMAIL/ID_CARD/URL/IP',
    is_anomaly       TINYINT      DEFAULT 0 COMMENT '是否异常',
    anomaly_type     VARCHAR(64)  COMMENT '异常类型: IQR/Z_SCORE/PATTERN/NULL_SPIKE',
    anomaly_detail   JSON         COMMENT '异常详情',
    tenant_id        BIGINT       NOT NULL,
    created_at       DATETIME     DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_task (task_id),
    INDEX idx_anomaly (is_anomaly),
    INDEX idx_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='字段画像表';
```

#### 1.1.3 探查定时策略表 (sd_profile_schedule)

```sql
CREATE TABLE sd_profile_schedule (
    id                BIGINT       PRIMARY KEY AUTO_INCREMENT,
    schedule_name     VARCHAR(200) NOT NULL,
    asset_id          BIGINT       NOT NULL,
    cron_expression   VARCHAR(128) NOT NULL COMMENT 'Cron表达式',
    scope_type        VARCHAR(16)  DEFAULT 'SAMPLE',
    sample_ratio      DECIMAL(5,2) DEFAULT 10.00,
    options           JSON         COMMENT '探查选项',
    notify_on_complete TINYINT     DEFAULT 1,
    notify_on_anomaly  TINYINT     DEFAULT 1,
    enabled           TINYINT      DEFAULT 1,
    last_run_at       DATETIME,
    next_run_at       DATETIME,
    tenant_id         BIGINT       NOT NULL,
    created_by        VARCHAR(64),
    created_at        DATETIME     DEFAULT CURRENT_TIMESTAMP,
    updated_at        DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted           TINYINT      DEFAULT 0,
    INDEX idx_asset (asset_id),
    INDEX idx_next_run (next_run_at),
    INDEX idx_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='探查定时策略表';
```

#### 1.1.4 AI数据洞察表 (sd_profile_insight)

```sql
CREATE TABLE sd_profile_insight (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    task_id         BIGINT       NOT NULL,
    insight_type    VARCHAR(32)  NOT NULL COMMENT 'INTERPRETATION/RULE_RECOMMEND/TAG_RECOMMEND',
    insight_content TEXT         NOT NULL COMMENT '洞察内容',
    insight_data    JSON         COMMENT '结构化数据',
    confidence      DECIMAL(5,2) COMMENT '置信度',
    adopted         TINYINT      DEFAULT 0,
    adopted_by      VARCHAR(64),
    adopted_at      DATETIME,
    tenant_id       BIGINT       NOT NULL,
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_task (task_id),
    INDEX idx_type (insight_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI数据洞察表';
```

### 1.2 核心类设计

```java
// ==================== Entity ====================

@Data
@TableName("sd_profile_task")
public class ProfileTask {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String taskName;
    private Long assetId;
    private Long dataSourceId;
    private String tableName;
    private String scopeType;       // FULL / SAMPLE
    private BigDecimal sampleRatio;
    private String options;         // JSON
    private String status;          // PENDING/RUNNING/SUCCESS/FAILED/CANCELLED
    private Long rowCount;
    private Integer columnCount;
    private BigDecimal healthScore;
    private Integer anomalyCount;
    private String errorMessage;
    private LocalDateTime startedAt;
    private LocalDateTime finishedAt;
    private Long durationMs;
    private Long tenantId;
    private String createdBy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Integer deleted;
}

@Data
@TableName("sd_profile_column")
public class ProfileColumn {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long taskId;
    private String columnName;
    private String dataType;
    private Integer ordinalPosition;
    private Long totalCount;
    private Long nullCount;
    private BigDecimal nullRate;
    private Long uniqueCount;
    private BigDecimal uniqueRate;
    private String minValue;
    private String maxValue;
    private BigDecimal avgValue;
    private String medianValue;
    private BigDecimal stddevValue;
    private String q1Value;
    private String q3Value;
    private Integer minLength;
    private Integer maxLength;
    private BigDecimal avgLength;
    private String topValues;       // JSON
    private String histogram;       // JSON
    private String detectedPattern;
    private Integer isAnomaly;
    private String anomalyType;
    private String anomalyDetail;   // JSON
    private Long tenantId;
    private LocalDateTime createdAt;
}
```

### 1.3 API接口设计

| 接口 | 方法 | 路径 | 说明 |
|------|:----:|------|------|
| 发起探查 | POST | `/api/profiling/tasks` | 创建探查任务 |
| 任务详情 | GET | `/api/profiling/tasks/{id}` | 查看任务状态 |
| 任务列表 | GET | `/api/profiling/tasks` | 分页查询任务 |
| 取消任务 | PUT | `/api/profiling/tasks/{id}/cancel` | 取消运行中任务 |
| 探查结果 | GET | `/api/profiling/tasks/{id}/result` | 获取完整探查结果 |
| 字段画像 | GET | `/api/profiling/tasks/{id}/columns` | 字段级画像列表 |
| 数据采样 | GET | `/api/profiling/tasks/{id}/sampling` | 获取采样数据(脱敏) |
| AI洞察 | GET | `/api/profiling/tasks/{id}/insights` | 获取AI解读结果 |
| 采纳推荐 | POST | `/api/profiling/insights/{id}/adopt` | 采纳AI推荐规则/标签 |
| 定时策略-创建 | POST | `/api/profiling/schedules` | 创建定时探查策略 |
| 定时策略-列表 | GET | `/api/profiling/schedules` | 查询定时策略 |
| 定时策略-更新 | PUT | `/api/profiling/schedules/{id}` | 修改定时策略 |
| 定时策略-删除 | DELETE | `/api/profiling/schedules/{id}` | 删除定时策略 |
| 导出报告 | GET | `/api/profiling/tasks/{id}/report` | 导出PDF/Excel报告 |
| 历史对比 | GET | `/api/profiling/tasks/{id}/compare` | 与历史探查结果对比 |

### 1.4 探查执行流程

```
用户发起探查
    │
    ▼
ProfilingTaskService.createTask()
    ├── 校验资产存在性和探查权限
    ├── 校验并发限制（同一表仅允许1个运行中任务）
    ├── 保存任务记录(status=PENDING)
    └── 发送Kafka消息: profiling.task.queue
         │
         ▼
    ProfilingEngine.execute(taskId)
         ├── 1. 连接数据源（DataSourceConnectorFactory）
         ├── 2. 获取表结构（列名/类型/行数）
         ├── 3. 统计计算（StatisticsModule）
         │      ├── SELECT COUNT(*), COUNT(col), COUNT(DISTINCT col)
         │      ├── 数值型: MIN/MAX/AVG/STDDEV/PERCENTILE_CONT
         │      ├── 字符型: LENGTH统计 + Top-N高频值
         │      └── 日期型: MIN/MAX + 分布统计
         ├── 4. 异常检测（AnomalyModule）
         │      ├── IQR: Q1-1.5*IQR ~ Q3+1.5*IQR
         │      └── Z-Score: |value - mean| / stddev > 3
         ├── 5. 模式识别（PatternModule）
         │      └── 正则匹配: 手机/邮箱/身份证/URL/IP
         ├── 6. AI解读（AiInsightService，异步调用智链AI）
         ├── 7. 保存结果到DB + ES索引
         ├── 8. 更新任务状态(SUCCESS)
         └── 9. 发送Kafka: profiling.completed
              └── 触发: tag-svc(AI打标), valuation-svc(更新评分)
```

---

## 2. 标签管理服务详细设计

### 2.1 数据库设计

#### 2.1.1 标签分类表 (sd_tag_category)

```sql
CREATE TABLE sd_tag_category (
    id            BIGINT       PRIMARY KEY AUTO_INCREMENT,
    parent_id     BIGINT       DEFAULT 0 COMMENT '父分类ID',
    category_name VARCHAR(200) NOT NULL,
    category_code VARCHAR(64)  NOT NULL UNIQUE,
    node_level    INT          DEFAULT 1,
    sort_order    INT          DEFAULT 0,
    description   VARCHAR(500),
    status        VARCHAR(16)  DEFAULT 'ACTIVE',
    tenant_id     BIGINT       NOT NULL,
    created_by    VARCHAR(64),
    created_at    DATETIME     DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted       TINYINT      DEFAULT 0,
    INDEX idx_parent (parent_id),
    INDEX idx_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='标签分类表';
```

#### 2.1.2 标签定义表 (sd_tag_definition)

```sql
CREATE TABLE sd_tag_definition (
    id            BIGINT       PRIMARY KEY AUTO_INCREMENT,
    tag_name      VARCHAR(200) NOT NULL COMMENT '标签名称',
    tag_code      VARCHAR(64)  NOT NULL UNIQUE COMMENT '标签编码',
    category_id   BIGINT       NOT NULL COMMENT '所属分类ID',
    tag_type      VARCHAR(32)  DEFAULT 'BUSINESS' COMMENT 'BUSINESS/SECURITY/QUALITY/VALUE',
    description   TEXT,
    value_type    VARCHAR(32)  DEFAULT 'BOOLEAN' COMMENT 'BOOLEAN/ENUM/NUMERIC/STRING',
    value_range   VARCHAR(500) COMMENT '取值范围(JSON)',
    status        VARCHAR(16)  DEFAULT 'DRAFT' COMMENT 'DRAFT/PENDING/PUBLISHED/OFFLINE',
    version       INT          DEFAULT 1 COMMENT '版本号',
    owner         VARCHAR(64),
    tenant_id     BIGINT       NOT NULL,
    created_by    VARCHAR(64),
    created_at    DATETIME     DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted       TINYINT      DEFAULT 0,
    INDEX idx_category (category_id),
    INDEX idx_status (status),
    INDEX idx_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='标签定义表';
```

#### 2.1.3 打标规则表 (sd_tag_rule)

```sql
CREATE TABLE sd_tag_rule (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    tag_id          BIGINT       NOT NULL COMMENT '标签ID',
    rule_name       VARCHAR(200) NOT NULL,
    rule_type       VARCHAR(32)  NOT NULL COMMENT 'REGEX/KEYWORD/FIELD_NAME/AI',
    rule_expression TEXT         NOT NULL COMMENT '规则表达式',
    match_target    VARCHAR(32)  DEFAULT 'TABLE_NAME' COMMENT 'TABLE_NAME/FIELD_NAME/DESCRIPTION/ALL',
    priority        INT          DEFAULT 50 COMMENT '优先级(数字越大优先级越高)',
    enabled         TINYINT      DEFAULT 1,
    tenant_id       BIGINT       NOT NULL,
    created_by      VARCHAR(64),
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted         TINYINT      DEFAULT 0,
    INDEX idx_tag (tag_id),
    INDEX idx_type (rule_type),
    INDEX idx_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='打标规则表';
```

#### 2.1.4 标签关联表 (sd_tag_assignment)

```sql
CREATE TABLE sd_tag_assignment (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    tag_id          BIGINT       NOT NULL COMMENT '标签ID',
    asset_id        BIGINT       NOT NULL COMMENT '资产ID',
    assignment_type VARCHAR(32)  NOT NULL COMMENT 'MANUAL/RULE/AI/INHERITED',
    confidence      DECIMAL(5,2) COMMENT 'AI置信度(0-100)',
    status          VARCHAR(16)  DEFAULT 'ACTIVE' COMMENT 'ACTIVE/PENDING/REMOVED',
    rule_id         BIGINT       COMMENT '匹配的规则ID(规则打标)',
    tag_value       VARCHAR(500) COMMENT '标签值(ENUM/NUMERIC类型)',
    tenant_id       BIGINT       NOT NULL,
    assigned_by     VARCHAR(64),
    assigned_at     DATETIME     DEFAULT CURRENT_TIMESTAMP,
    removed_by      VARCHAR(64),
    removed_at      DATETIME,
    UNIQUE INDEX uk_tag_asset (tag_id, asset_id, tenant_id),
    INDEX idx_asset (asset_id),
    INDEX idx_tag (tag_id),
    INDEX idx_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='标签关联表';
```

### 2.2 API接口设计

| 接口 | 方法 | 路径 | 说明 |
|------|:----:|------|------|
| 分类树查询 | GET | `/api/tag/categories/tree` | 获取标签分类树 |
| 分类-创建 | POST | `/api/tag/categories` | 新建标签分类 |
| 分类-更新 | PUT | `/api/tag/categories/{id}` | 修改分类 |
| 标签-创建 | POST | `/api/tags` | 新建标签定义 |
| 标签-列表 | GET | `/api/tags` | 分页查询标签 |
| 标签-详情 | GET | `/api/tags/{id}` | 标签详情 |
| 标签-更新 | PUT | `/api/tags/{id}` | 修改标签 |
| 标签-发布 | PUT | `/api/tags/{id}/publish` | 发布标签(审批) |
| 标签-停用 | PUT | `/api/tags/{id}/offline` | 停用标签 |
| 规则-创建 | POST | `/api/tag-rules` | 新建打标规则 |
| 规则-列表 | GET | `/api/tag-rules` | 查询打标规则 |
| 规则-测试 | POST | `/api/tag-rules/test` | 测试规则匹配 |
| 手动打标 | POST | `/api/tag-assignments` | 手动给资产打标 |
| 批量打标 | POST | `/api/tag-assignments/batch` | 批量打标 |
| 移除标签 | DELETE | `/api/tag-assignments/{id}` | 移除资产标签 |
| AI打标推荐 | POST | `/api/tag-assignments/ai-recommend` | AI推荐标签 |
| 采纳AI推荐 | POST | `/api/tag-assignments/ai-adopt` | 采纳AI推荐标签 |
| 标签集市 | GET | `/api/tag/market` | 标签集市浏览 |
| 标签统计 | GET | `/api/tag/dashboard` | 标签统计看板 |
| 资产标签 | GET | `/api/tag-assignments/asset/{assetId}` | 查询资产的标签 |

### 2.3 自动打标引擎流程

```
事件触发（asset.published 或 profiling.completed）
    │
    ▼
TagRuleEngine.match(asset)
    ├── 加载所有启用的打标规则
    ├── 逐规则匹配:
    │   ├── RegexRuleMatcher: 正则匹配表名/字段名
    │   ├── KeywordMatcher: 关键字匹配
    │   └── FieldNameMatcher: 字段名模式匹配
    └── 输出匹配标签列表（按优先级排序）
         │
         ▼ (并行)
    AiTaggingService.recommend(asset, profilingResult)
         ├── 组装上下文（表名/字段/数据探查摘要/业务术语）
         ├── 调用智链AI生成标签推荐
         └── 输出AI推荐标签列表(含置信度)
              │
              ▼
    合并规则标签 + AI标签
    ├── 规则标签: 自动打标（高置信度）
    ├── AI标签(置信度≥80%): 自动打标
    ├── AI标签(置信度60-80%): 待确认
    └── AI标签(置信度<60%): 丢弃
         │
         ▼
    保存打标记录 → 发送 tag.assigned 事件 → 更新资产标签缓存
```

---

## 3. 治理工作流服务详细设计

### 3.1 数据库设计

#### 3.1.1 治理角色表 (sd_governance_role)

```sql
CREATE TABLE sd_governance_role (
    id          BIGINT       PRIMARY KEY AUTO_INCREMENT,
    role_name   VARCHAR(100) NOT NULL COMMENT '角色名称',
    role_code   VARCHAR(64)  NOT NULL UNIQUE COMMENT '角色编码',
    role_type   VARCHAR(32)  DEFAULT 'CUSTOM' COMMENT 'BUILTIN/CUSTOM',
    description VARCHAR(500),
    parent_role_id BIGINT    COMMENT '父角色ID(继承)',
    sort_order  INT          DEFAULT 0,
    status      VARCHAR(16)  DEFAULT 'ACTIVE',
    tenant_id   BIGINT       NOT NULL,
    created_by  VARCHAR(64),
    created_at  DATETIME     DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted     TINYINT      DEFAULT 0,
    INDEX idx_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='治理角色表';
```

#### 3.1.2 RACI矩阵表 (sd_raci_matrix)

```sql
CREATE TABLE sd_raci_matrix (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    activity_code   VARCHAR(64)  NOT NULL COMMENT '治理活动编码',
    activity_name   VARCHAR(200) NOT NULL COMMENT '治理活动名称',
    role_id         BIGINT       NOT NULL COMMENT '角色ID',
    raci_type       VARCHAR(1)   NOT NULL COMMENT 'R/A/C/I',
    tenant_id       BIGINT       NOT NULL,
    created_by      VARCHAR(64),
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uk_activity_role (activity_code, role_id, tenant_id),
    INDEX idx_activity (activity_code),
    INDEX idx_role (role_id),
    INDEX idx_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='RACI矩阵表';
```

#### 3.1.3 流程模板表 (sd_process_template)

```sql
CREATE TABLE sd_process_template (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    template_name   VARCHAR(200) NOT NULL COMMENT '模板名称',
    template_code   VARCHAR(64)  NOT NULL UNIQUE COMMENT '模板编码',
    category        VARCHAR(32)  COMMENT '分类: ASSET/STANDARD/QUALITY/MDM/...',
    bpmn_xml        TEXT         NOT NULL COMMENT 'BPMN流程定义XML',
    description     TEXT,
    default_sla_hours INT        DEFAULT 48 COMMENT '默认SLA(小时)',
    is_builtin      TINYINT      DEFAULT 0 COMMENT '是否内置模板',
    status          VARCHAR(16)  DEFAULT 'DRAFT' COMMENT 'DRAFT/PUBLISHED/OFFLINE',
    version         INT          DEFAULT 1,
    tenant_id       BIGINT       NOT NULL,
    created_by      VARCHAR(64),
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted         TINYINT      DEFAULT 0,
    INDEX idx_category (category),
    INDEX idx_status (status),
    INDEX idx_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='流程模板表';
```

#### 3.1.4 SLA配置表 (sd_sla_config)

```sql
CREATE TABLE sd_sla_config (
    id                BIGINT       PRIMARY KEY AUTO_INCREMENT,
    process_template_id BIGINT     NOT NULL COMMENT '流程模板ID',
    node_id           VARCHAR(64)  NOT NULL COMMENT 'BPMN节点ID',
    node_name         VARCHAR(200) COMMENT '节点名称',
    sla_hours         INT          NOT NULL COMMENT 'SLA时长(小时)',
    reminder_hours    INT          DEFAULT 2 COMMENT '提前提醒(小时)',
    timeout_strategy  VARCHAR(32)  DEFAULT 'REMIND' COMMENT 'REMIND/ESCALATE/TRANSFER/AUTO_APPROVE/AUTO_REJECT',
    escalate_to_role  BIGINT       COMMENT '升级到的角色ID',
    transfer_to_user  VARCHAR(64)  COMMENT '转办到的用户',
    enabled           TINYINT      DEFAULT 1,
    tenant_id         BIGINT       NOT NULL,
    created_at        DATETIME     DEFAULT CURRENT_TIMESTAMP,
    updated_at        DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_template (process_template_id),
    INDEX idx_node (node_id),
    INDEX idx_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='SLA配置表';
```

> **注**: Flowable引擎自带流程定义表(ACT_RE_*)、流程实例表(ACT_RU_*)、历史表(ACT_HI_*)，无需自行创建。

### 3.2 API接口设计

| 接口 | 方法 | 路径 | 说明 |
|------|:----:|------|------|
| **流程定义** | | | |
| 部署流程 | POST | `/api/workflow/definitions/deploy` | 部署BPMN流程定义 |
| 流程定义列表 | GET | `/api/workflow/definitions` | 查询已部署流程 |
| 流程定义详情 | GET | `/api/workflow/definitions/{id}` | 流程定义详情 |
| 删除流程定义 | DELETE | `/api/workflow/definitions/{id}` | 删除流程定义 |
| **流程实例** | | | |
| 启动流程 | POST | `/api/workflow/instances` | 启动流程实例 |
| 流程实例列表 | GET | `/api/workflow/instances` | 查询流程实例 |
| 流程实例详情 | GET | `/api/workflow/instances/{id}` | 含流程图高亮 |
| 终止流程 | PUT | `/api/workflow/instances/{id}/terminate` | 终止流程实例 |
| **审批任务** | | | |
| 待办列表 | GET | `/api/workflow/tasks/todo` | 当前用户待办 |
| 已办列表 | GET | `/api/workflow/tasks/done` | 当前用户已办 |
| 抄送列表 | GET | `/api/workflow/tasks/cc` | 抄送给我的 |
| 任务详情 | GET | `/api/workflow/tasks/{id}` | 审批任务详情 |
| 审批-同意 | PUT | `/api/workflow/tasks/{id}/approve` | 同意审批 |
| 审批-拒绝 | PUT | `/api/workflow/tasks/{id}/reject` | 拒绝审批 |
| 审批-转办 | PUT | `/api/workflow/tasks/{id}/transfer` | 转办给他人 |
| 审批-退回 | PUT | `/api/workflow/tasks/{id}/return` | 退回到指定节点 |
| 审批-加签 | PUT | `/api/workflow/tasks/{id}/add-signer` | 增加审批人 |
| 批量审批 | PUT | `/api/workflow/tasks/batch-approve` | 批量同意 |
| 设置委托 | POST | `/api/workflow/delegation` | 设置审批委托 |
| **流程模板** | | | |
| 模板列表 | GET | `/api/workflow/templates` | 查询流程模板 |
| 模板详情 | GET | `/api/workflow/templates/{id}` | 模板详情 |
| 创建模板 | POST | `/api/workflow/templates` | 新建自定义模板 |
| 更新模板 | PUT | `/api/workflow/templates/{id}` | 修改模板 |
| 发布模板 | PUT | `/api/workflow/templates/{id}/publish` | 发布模板 |
| **RACI矩阵** | | | |
| 角色列表 | GET | `/api/workflow/raci/roles` | 查询治理角色 |
| 角色创建 | POST | `/api/workflow/raci/roles` | 新建角色 |
| RACI矩阵查询 | GET | `/api/workflow/raci/matrix` | 查询RACI矩阵 |
| RACI矩阵配置 | PUT | `/api/workflow/raci/matrix` | 批量配置RACI |
| 覆盖率分析 | GET | `/api/workflow/raci/coverage` | RACI覆盖率报告 |
| **SLA管理** | | | |
| SLA配置列表 | GET | `/api/workflow/sla/configs` | 查询SLA配置 |
| SLA配置更新 | PUT | `/api/workflow/sla/configs` | 修改SLA配置 |
| SLA监控看板 | GET | `/api/workflow/sla/dashboard` | SLA达成率/超时统计 |
| **流程分析** | | | |
| 流程统计 | GET | `/api/workflow/analytics/summary` | 数量/耗时/通过率 |
| 瓶颈分析 | GET | `/api/workflow/analytics/bottleneck` | Top-N瓶颈节点 |
| 趋势分析 | GET | `/api/workflow/analytics/trend` | 流程趋势图 |

### 3.3 Flowable集成设计

```java
// Flowable配置
@Configuration
public class FlowableConfig implements EngineConfigurationConfigurer<SpringProcessEngineConfiguration> {
    @Override
    public void configure(SpringProcessEngineConfiguration config) {
        config.setDatabaseType("mysql"); // 支持切换dm8
        config.setAsyncExecutorEnabled(true);
        config.setAsyncExecutorActivate(true);
        config.setJobExecutorActivate(true);
    }
}

// RACI审批人分配监听器
@Component("raciAssignmentListener")
public class RaciAssignmentListener implements TaskListener {
    @Autowired private RaciService raciService;

    @Override
    public void notify(DelegateTask delegateTask) {
        String activityCode = (String) delegateTask.getVariable("activityCode");
        String roleType = (String) delegateTask.getVariable("roleType");
        // 根据RACI矩阵获取审批人
        List<String> approvers = raciService.getApproverUsernames(activityCode, roleType);
        if (approvers.size() == 1) {
            delegateTask.setAssignee(approvers.get(0));
        } else {
            delegateTask.addCandidateUsers(approvers);
        }
    }
}

// SLA超时监听器
@Component("slaTimerListener")
public class SlaTimerListener implements TaskListener {
    @Autowired private SlaService slaService;

    @Override
    public void notify(DelegateTask delegateTask) {
        slaService.startTimer(delegateTask.getId(), delegateTask.getTaskDefinitionKey());
    }
}
```

### 3.4 内置流程模板

| 编码 | 模板名称 | 流程节点 | 默认SLA |
|------|---------|---------|:-------:|
| ASSET_PUBLISH | 资产发布审批 | 发起人→数据管理员审核→数据所有者审批→发布 | 48h |
| STANDARD_APPROVAL | 数据标准审批 | 发起人→标准管理员审核→标准委员会审批→发布 | 72h |
| QUALITY_FIX | 质量问题修复 | 系统创建→数据管家分派→责任人修复→质量验证→关闭 | 24h |
| MDM_CHANGE | 主数据变更审批 | 发起人→MDM管理员审核→影响分析→数据所有者审批→执行 | 48h |
| GLOSSARY_APPROVAL | 业务术语审批 | 发起人→术语管理员审核→业务负责人审批→发布 | 48h |
| TAG_APPROVAL | 标签定义审批 | 发起人→标签管理员审核→发布 | 24h |
| PRODUCT_LISTING | 数据产品上架 | 发起人→合规检查→安全审批→治理管理员审批→上架 | 72h |
| MASKING_APPROVAL | 数据脱敏审批 | 发起人→安全管理员审核→数据所有者审批→执行 | 24h |
| ARCHIVE_APPROVAL | 数据归档审批 | 系统触发→数据管理员审核→数据所有者审批→归档 | 48h |
| ACCESS_REQUEST | 数据权限申请 | 发起人→数据管理员审核→数据所有者审批→授权 | 24h |

---

## 4. 数据资产估值服务详细设计

### 4.1 数据库设计

#### 4.1.1 资产估值表 (sd_asset_valuation)

```sql
CREATE TABLE sd_asset_valuation (
    id                  BIGINT       PRIMARY KEY AUTO_INCREMENT,
    asset_id            BIGINT       NOT NULL COMMENT '资产ID',
    valuation_period    VARCHAR(7)   NOT NULL COMMENT '估值周期(YYYY-MM)',
    cost_value          DECIMAL(18,2) DEFAULT 0 COMMENT '成本法估值',
    revenue_value       DECIMAL(18,2) DEFAULT 0 COMMENT '收益法估值',
    market_value        DECIMAL(18,2) DEFAULT 0 COMMENT '市场法估值',
    composite_value     DECIMAL(18,2) DEFAULT 0 COMMENT '综合估值',
    dimension_score     JSON         COMMENT '维度评分{quality,usage,coverage,...}',
    dimension_multiplier DECIMAL(8,4) DEFAULT 1.0 COMMENT '维度乘数',
    final_value         DECIMAL(18,2) NOT NULL COMMENT '最终估值',
    valuation_method    VARCHAR(32)  DEFAULT 'COMPOSITE' COMMENT 'COST/REVENUE/MARKET/COMPOSITE',
    status              VARCHAR(16)  DEFAULT 'DRAFT' COMMENT 'DRAFT/CONFIRMED',
    confirmed_by        VARCHAR(64),
    confirmed_at        DATETIME,
    tenant_id           BIGINT       NOT NULL,
    created_by          VARCHAR(64),
    created_at          DATETIME     DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_asset (asset_id),
    INDEX idx_period (valuation_period),
    INDEX idx_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='资产估值表';
```

#### 4.1.2 治理成本表 (sd_governance_cost)

```sql
CREATE TABLE sd_governance_cost (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    cost_period     VARCHAR(7)   NOT NULL COMMENT '成本周期(YYYY-MM)',
    cost_type       VARCHAR(32)  NOT NULL COMMENT 'PERSONNEL/TOOL/INFRA/TRAINING',
    cost_category   VARCHAR(64)  COMMENT '成本细项',
    amount          DECIMAL(18,2) NOT NULL COMMENT '金额(元)',
    department      VARCHAR(100) COMMENT '部门',
    data_source     VARCHAR(32)  DEFAULT 'MANUAL' COMMENT 'SYSTEM/MANUAL',
    description     VARCHAR(500),
    tenant_id       BIGINT       NOT NULL,
    created_by      VARCHAR(64),
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_period (cost_period),
    INDEX idx_type (cost_type),
    INDEX idx_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='治理成本表';
```

#### 4.1.3 治理收益表 (sd_governance_revenue)

```sql
CREATE TABLE sd_governance_revenue (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    revenue_period  VARCHAR(7)   NOT NULL COMMENT '收益周期(YYYY-MM)',
    revenue_type    VARCHAR(32)  NOT NULL COMMENT 'QUALITY_IMPROVEMENT/EFFICIENCY/COMPLIANCE/DATA_PRODUCT',
    revenue_category VARCHAR(64) COMMENT '收益细项',
    amount          DECIMAL(18,2) NOT NULL COMMENT '金额(元)',
    department      VARCHAR(100),
    calculation_basis VARCHAR(500) COMMENT '计算依据',
    data_source     VARCHAR(32)  DEFAULT 'MANUAL' COMMENT 'SYSTEM/MANUAL',
    tenant_id       BIGINT       NOT NULL,
    created_by      VARCHAR(64),
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_period (revenue_period),
    INDEX idx_type (revenue_type),
    INDEX idx_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='治理收益表';
```

#### 4.1.4 估值配置表 (sd_valuation_config)

```sql
CREATE TABLE sd_valuation_config (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    config_key      VARCHAR(64)  NOT NULL,
    config_value    TEXT         NOT NULL,
    config_type     VARCHAR(32)  DEFAULT 'WEIGHT' COMMENT 'WEIGHT/METHOD/FORMULA',
    description     VARCHAR(500),
    tenant_id       BIGINT       NOT NULL,
    updated_by      VARCHAR(64),
    updated_at      DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX uk_key_tenant (config_key, tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='估值配置表';
```

### 4.2 估值计算公式

```
最终估值(final_value) = 综合估值(composite_value) × 维度乘数(dimension_multiplier)

综合估值(composite_value) = cost_value × W_cost + revenue_value × W_revenue + market_value × W_market
  默认权重: W_cost=0.4, W_revenue=0.4, W_market=0.2

维度乘数(dimension_multiplier) = Σ(dimension_score_i × W_i) / 100
  维度评分:
    - 质量(quality):     取资产quality_score (0-100), 权重=1/6
    - 使用频率(usage):   log10(monthly_calls+1) × 20, 上限100, 权重=1/6
    - 业务覆盖(coverage): related_systems × 20, 上限100, 权重=1/6
    - 稀缺性(scarcity):  100 - similar_count × 10, 下限0, 权重=1/6
    - 时效性(timeliness): 实时=100/日更=80/周更=60/月更=40/年更=20, 权重=1/6
    - 合规性(compliance): compliance_pass_rate × 100, 权重=1/6
```

### 4.3 API接口设计

| 接口 | 方法 | 路径 | 说明 |
|------|:----:|------|------|
| 触发估值 | POST | `/api/valuation/execute` | 手动触发资产估值 |
| 估值列表 | GET | `/api/valuation/list` | 查询估值结果 |
| 估值详情 | GET | `/api/valuation/{assetId}` | 资产估值详情 |
| 估值趋势 | GET | `/api/valuation/{assetId}/trend` | 估值历史趋势 |
| 估值排行 | GET | `/api/valuation/ranking` | Top-N资产排行 |
| 估值看板 | GET | `/api/valuation/dashboard` | 估值总览看板 |
| 确认估值 | PUT | `/api/valuation/{id}/confirm` | 人工确认估值 |
| 修正估值 | PUT | `/api/valuation/{id}/adjust` | 人工修正估值 |
| 估值配置 | GET/PUT | `/api/valuation/config` | 估值模型配置 |
| ROI总览 | GET | `/api/valuation/roi/summary` | ROI汇总 |
| ROI趋势 | GET | `/api/valuation/roi/trend` | ROI趋势分析 |
| 成本列表 | GET | `/api/valuation/cost/list` | 治理成本列表 |
| 成本录入 | POST | `/api/valuation/cost` | 手动录入成本 |
| 收益列表 | GET | `/api/valuation/revenue/list` | 治理收益列表 |
| 收益录入 | POST | `/api/valuation/revenue` | 手动录入收益 |
| 报告导出 | GET | `/api/valuation/report` | 导出估值报告(PDF/Excel) |

---

## 5. 数据产品服务详细设计

### 5.1 数据库设计

#### 5.1.1 数据产品表 (sd_data_product)

```sql
CREATE TABLE sd_data_product (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    product_code    VARCHAR(64)  NOT NULL UNIQUE COMMENT '产品编码',
    product_name    VARCHAR(200) NOT NULL COMMENT '产品名称',
    product_type    VARCHAR(32)  NOT NULL COMMENT 'DATASET/API/REPORT/MODEL/VISUALIZATION',
    category_id     BIGINT       COMMENT '分类ID',
    description     TEXT,
    asset_id        BIGINT       NOT NULL COMMENT '关联资产ID',
    source_config   JSON         NOT NULL COMMENT '数据源配置',
    sample_data_url VARCHAR(500) COMMENT '样例数据URL(MinIO)',
    field_schema    JSON         COMMENT '字段说明',
    quality_score   DECIMAL(5,2) COMMENT '质量评分',
    sla_config      JSON         COMMENT 'SLA配置',
    pricing_model   VARCHAR(32)  DEFAULT 'MONTHLY' COMMENT 'PER_USE/MONTHLY/YEARLY/TIERED',
    price           DECIMAL(18,2) DEFAULT 0 COMMENT '价格',
    trial_enabled   TINYINT      DEFAULT 1 COMMENT '是否支持试用',
    trial_duration  INT          DEFAULT 7 COMMENT '试用天数',
    trial_limit     INT          DEFAULT 100 COMMENT '试用次数限制',
    status          VARCHAR(16)  DEFAULT 'DRAFT' COMMENT 'DRAFT/PENDING/LISTED/OFFLINE',
    version         INT          DEFAULT 1,
    tags            JSON         COMMENT '产品标签',
    provider        VARCHAR(100) COMMENT '提供方',
    update_frequency VARCHAR(32) COMMENT '更新频率',
    rating_avg      DECIMAL(3,2) DEFAULT 0 COMMENT '平均评分',
    subscribe_count INT          DEFAULT 0 COMMENT '订阅数',
    tenant_id       BIGINT       NOT NULL,
    created_by      VARCHAR(64),
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted         TINYINT      DEFAULT 0,
    INDEX idx_type (product_type),
    INDEX idx_category (category_id),
    INDEX idx_status (status),
    INDEX idx_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据产品表';
```

#### 5.1.2 产品订阅表 (sd_product_subscription)

```sql
CREATE TABLE sd_product_subscription (
    id                BIGINT       PRIMARY KEY AUTO_INCREMENT,
    product_id        BIGINT       NOT NULL,
    subscriber        VARCHAR(64)  NOT NULL COMMENT '订阅人',
    subscriber_dept   VARCHAR(100) COMMENT '订阅部门',
    subscription_type VARCHAR(32)  DEFAULT 'NORMAL' COMMENT 'NORMAL/TRIAL',
    start_date        DATE         NOT NULL,
    end_date          DATE         NOT NULL,
    usage_limit       BIGINT       COMMENT '用量限制',
    usage_used        BIGINT       DEFAULT 0 COMMENT '已用量',
    api_key           VARCHAR(128) COMMENT 'API Key(加密存储)',
    status            VARCHAR(16)  DEFAULT 'PENDING' COMMENT 'PENDING/ACTIVE/EXPIRED/CANCELLED',
    use_case          TEXT         COMMENT '使用场景说明',
    workflow_instance_id VARCHAR(64) COMMENT '审批流程实例ID',
    tenant_id         BIGINT       NOT NULL,
    created_by        VARCHAR(64),
    created_at        DATETIME     DEFAULT CURRENT_TIMESTAMP,
    updated_at        DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_product (product_id),
    INDEX idx_subscriber (subscriber),
    INDEX idx_status (status),
    INDEX idx_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='产品订阅表';
```

#### 5.1.3 计量记录表 (sd_metering_record)

```sql
CREATE TABLE sd_metering_record (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    product_id      BIGINT       NOT NULL,
    subscription_id BIGINT       NOT NULL,
    metering_type   VARCHAR(32)  NOT NULL COMMENT 'API_CALL/DATA_VOLUME/DURATION',
    metering_value  BIGINT       NOT NULL COMMENT '计量值',
    metering_unit   VARCHAR(32)  COMMENT '次/MB/天',
    metering_date   DATE         NOT NULL,
    cost            DECIMAL(18,4) DEFAULT 0 COMMENT '费用(元)',
    tenant_id       BIGINT       NOT NULL,
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_product (product_id),
    INDEX idx_subscription (subscription_id),
    INDEX idx_date (metering_date),
    INDEX idx_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='计量记录表';
```

#### 5.1.4 账单表 (sd_billing)

```sql
CREATE TABLE sd_billing (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    bill_no         VARCHAR(64)  NOT NULL UNIQUE COMMENT '账单编号',
    bill_period     VARCHAR(7)   NOT NULL COMMENT '账单周期(YYYY-MM)',
    subscriber      VARCHAR(64)  NOT NULL,
    subscriber_dept VARCHAR(100),
    total_amount    DECIMAL(18,2) NOT NULL COMMENT '总金额',
    detail          JSON         COMMENT '账单明细',
    status          VARCHAR(16)  DEFAULT 'UNPAID' COMMENT 'UNPAID/PAID/RECONCILED',
    tenant_id       BIGINT       NOT NULL,
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_period (bill_period),
    INDEX idx_subscriber (subscriber),
    INDEX idx_status (status),
    INDEX idx_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='账单表';
```

### 5.2 API接口设计

| 接口 | 方法 | 路径 | 说明 |
|------|:----:|------|------|
| **产品管理** | | | |
| 创建产品 | POST | `/api/dataproduct/products` | 创建数据产品 |
| 产品列表 | GET | `/api/dataproduct/products` | 管理端产品列表 |
| 产品详情 | GET | `/api/dataproduct/products/{id}` | 产品详情 |
| 更新产品 | PUT | `/api/dataproduct/products/{id}` | 修改产品 |
| 上架申请 | POST | `/api/dataproduct/products/{id}/list` | 申请上架(触发审批) |
| 下架产品 | PUT | `/api/dataproduct/products/{id}/delist` | 下架产品 |
| 产品版本 | GET | `/api/dataproduct/products/{id}/versions` | 版本历史 |
| **数据市场** | | | |
| 市场首页 | GET | `/api/dataproduct/market` | 热门/新品/推荐 |
| 市场搜索 | GET | `/api/dataproduct/market/search` | 搜索+筛选+排序 |
| 产品评价 | POST | `/api/dataproduct/products/{id}/reviews` | 提交评价 |
| 评价列表 | GET | `/api/dataproduct/products/{id}/reviews` | 评价列表 |
| **订阅管理** | | | |
| 提交订阅 | POST | `/api/dataproduct/subscriptions` | 提交订阅申请 |
| 我的订阅 | GET | `/api/dataproduct/subscriptions/mine` | 我的订阅列表 |
| 订阅详情 | GET | `/api/dataproduct/subscriptions/{id}` | 订阅详情 |
| 续订 | POST | `/api/dataproduct/subscriptions/{id}/renew` | 续订 |
| 退订 | PUT | `/api/dataproduct/subscriptions/{id}/cancel` | 退订 |
| 订阅审批 | GET | `/api/dataproduct/subscriptions/pending` | 待审批订阅 |
| 审批订阅 | PUT | `/api/dataproduct/subscriptions/{id}/approve` | 审批通过/拒绝 |
| 用量统计 | GET | `/api/dataproduct/subscriptions/{id}/usage` | 用量统计 |
| **计量计费** | | | |
| 账单列表 | GET | `/api/dataproduct/billing/list` | 账单列表 |
| 账单详情 | GET | `/api/dataproduct/billing/{id}` | 账单详情 |
| 导出账单 | GET | `/api/dataproduct/billing/{id}/export` | 导出Excel/PDF |
| 计量统计 | GET | `/api/dataproduct/metering/summary` | 计量汇总 |

### 5.3 订阅授权流程

```
消费者提交订阅申请
    │
    ▼
SubscriptionValidator.validate(request)
    ├── 校验产品状态(LISTED)
    ├── 校验用户权限
    └── 校验用量规格
    │
    ▼
SubscriptionService.createSubscription(request)
    ├── 保存订阅记录(status=PENDING)
    └── 调用WorkflowClient启动审批流程
         │
         ▼ (审批通过)
    AuthorizationManager.authorize(subscription)
         ├── 生成API Key (SM4加密存储)
         ├── 分配数据权限(调用DataServiceClient)
         ├── 设置有效期(订阅周期)
         └── 保存授权记录
              │
              ▼
    SubscriptionService.activate(subscriptionId)
         ├── 更新状态(ACTIVE)
         ├── 发送通知(站内信+邮件)
         └── 发送Kafka: product.subscribed
```

---

## 6. 自助分析服务详细设计

### 6.1 数据库设计

#### 6.1.1 查询记录表 (sd_query_record)

```sql
CREATE TABLE sd_query_record (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    user_id         VARCHAR(64)  NOT NULL COMMENT '用户ID',
    user_name       VARCHAR(100) COMMENT '用户名',
    data_source_id  BIGINT       NOT NULL COMMENT '数据源ID',
    sql_content     TEXT         NOT NULL COMMENT 'SQL语句',
    sql_type        VARCHAR(16)  DEFAULT 'SQL' COMMENT 'SQL/WIZARD',
    status          VARCHAR(16)  NOT NULL COMMENT 'SUCCESS/FAILED/TIMEOUT',
    result_rows     BIGINT       DEFAULT 0 COMMENT '结果行数',
    duration_ms     BIGINT       DEFAULT 0 COMMENT '执行耗时(毫秒)',
    error_message   TEXT,
    is_slow         TINYINT      DEFAULT 0 COMMENT '是否慢查询(>5s)',
    is_masked       TINYINT      DEFAULT 0 COMMENT '是否脱敏',
    tenant_id       BIGINT       NOT NULL,
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user (user_id),
    INDEX idx_source (data_source_id),
    INDEX idx_status (status),
    INDEX idx_slow (is_slow),
    INDEX idx_created (created_at),
    INDEX idx_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='查询记录表';
```

#### 6.1.2 查询模板表 (sd_query_template)

```sql
CREATE TABLE sd_query_template (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    template_name   VARCHAR(200) NOT NULL,
    description     TEXT,
    sql_content     TEXT         NOT NULL,
    data_source_id  BIGINT,
    parameters      JSON         COMMENT '参数定义',
    tags            JSON         COMMENT '标签',
    is_shared       TINYINT      DEFAULT 0 COMMENT '是否分享',
    share_scope     VARCHAR(32)  DEFAULT 'PRIVATE' COMMENT 'PRIVATE/DEPT/PUBLIC',
    use_count       INT          DEFAULT 0 COMMENT '使用次数',
    owner           VARCHAR(64),
    tenant_id       BIGINT       NOT NULL,
    created_by      VARCHAR(64),
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted         TINYINT      DEFAULT 0,
    INDEX idx_owner (owner),
    INDEX idx_shared (is_shared),
    INDEX idx_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='查询模板表';
```

#### 6.1.3 仪表盘表 (sd_dashboard)

```sql
CREATE TABLE sd_dashboard (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    dashboard_name  VARCHAR(200) NOT NULL,
    description     TEXT,
    layout_config   JSON         NOT NULL COMMENT '布局配置(图表位置/尺寸)',
    charts          JSON         NOT NULL COMMENT '图表配置[{type,sql,config}]',
    refresh_interval INT         DEFAULT 0 COMMENT '自动刷新间隔(秒), 0=不刷新',
    is_shared       TINYINT      DEFAULT 0,
    owner           VARCHAR(64),
    tenant_id       BIGINT       NOT NULL,
    created_by      VARCHAR(64),
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted         TINYINT      DEFAULT 0,
    INDEX idx_owner (owner),
    INDEX idx_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='仪表盘表';
```

### 6.2 API接口设计

| 接口 | 方法 | 路径 | 说明 |
|------|:----:|------|------|
| **SQL工作台** | | | |
| 执行查询 | POST | `/api/analytics/query/execute` | 执行SQL查询 |
| 查询结果 | GET | `/api/analytics/query/{id}/result` | 获取查询结果 |
| 导出结果 | POST | `/api/analytics/query/{id}/export` | 导出Excel/CSV |
| 查询历史 | GET | `/api/analytics/query/history` | 查询历史列表 |
| 执行计划 | POST | `/api/analytics/query/explain` | 查看执行计划 |
| SQL格式化 | POST | `/api/analytics/query/format` | SQL格式化 |
| **查询模板** | | | |
| 保存模板 | POST | `/api/analytics/templates` | 保存查询为模板 |
| 模板列表 | GET | `/api/analytics/templates` | 查询模板列表 |
| 模板详情 | GET | `/api/analytics/templates/{id}` | 模板详情 |
| 分享模板 | PUT | `/api/analytics/templates/{id}/share` | 分享模板 |
| **可视化分析** | | | |
| 生成图表 | POST | `/api/analytics/charts` | 基于查询生成图表 |
| 图表列表 | GET | `/api/analytics/charts` | 图表列表 |
| 创建仪表盘 | POST | `/api/analytics/dashboards` | 创建仪表盘 |
| 仪表盘列表 | GET | `/api/analytics/dashboards` | 仪表盘列表 |
| 仪表盘详情 | GET | `/api/analytics/dashboards/{id}` | 仪表盘详情 |
| 数据透视 | POST | `/api/analytics/pivot` | 数据透视分析 |
| **无代码取数** | | | |
| 向导-选表 | GET | `/api/analytics/wizard/tables` | 可用表列表 |
| 向导-字段 | GET | `/api/analytics/wizard/fields` | 表字段列表 |
| 向导-执行 | POST | `/api/analytics/wizard/execute` | 执行向导取数 |
| **审计监控** | | | |
| 查询审计 | GET | `/api/analytics/audit/list` | 审计日志列表 |
| 慢查询列表 | GET | `/api/analytics/slow-queries` | 慢查询列表 |
| AI优化建议 | GET | `/api/analytics/slow-queries/{id}/suggestion` | AI优化建议 |

### 6.3 SQL执行安全链

```
用户提交SQL
    │
    ▼
SqlValidator.validate(sql)
    ├── 语法检查
    ├── 安全检查（仅SELECT，禁止DML/DDL）
    └── SQL注入检测
    │
    ▼
PermissionChecker.check(user, sql)
    ├── 解析SQL涉及的表和字段
    ├── 检查表级权限
    └── 检查字段级权限
    │
    ▼
ConcurrencyLimiter.acquire(user)  // ≤3并发/用户
    │
    ▼
QueryExecutor.execute(sql, timeout=60s, limit=10000)
    ├── 连接数据源
    ├── 执行查询（带超时控制）
    └── 流式读取结果
    │
    ▼ (并行)
QueryAuditService.record(user, sql, result)  // 异步审计
    │
    ▼
DynamicMasking.apply(result, maskingRules)  // 动态脱敏
    │
    ▼
ResultProcessor.format(result)  // 格式化/导出
    │
    ▼ (如果>5s)
SlowQueryService.analyze(sql, duration)
    ├── 记录慢查询
    └── AI生成优化建议
```

---

## 7. 数据集成服务详细设计

### 7.1 数据库设计

#### 7.1.1 数据源表 (sd_data_source)

```sql
CREATE TABLE sd_data_source (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    source_name     VARCHAR(200) NOT NULL COMMENT '数据源名称',
    source_code     VARCHAR(64)  NOT NULL UNIQUE COMMENT '编码',
    source_type     VARCHAR(32)  NOT NULL COMMENT 'MYSQL/ORACLE/DM8/KINGBASE/OPENGAUSS/POSTGRES/CSV/EXCEL/API',
    category        VARCHAR(32)  DEFAULT 'RDBMS' COMMENT 'RDBMS/FILE/API/MQ/NOSQL',
    host            VARCHAR(200) COMMENT '主机',
    port            INT          COMMENT '端口',
    database_name   VARCHAR(200) COMMENT '数据库名',
    username        VARCHAR(100) COMMENT '用户名',
    password        VARCHAR(500) COMMENT '密码(SM4加密)',
    extra_params    JSON         COMMENT '额外连接参数',
    connection_pool JSON         COMMENT '连接池配置',
    health_check_enabled TINYINT DEFAULT 1,
    health_check_interval INT    DEFAULT 300 COMMENT '健康检查间隔(秒)',
    last_check_time DATETIME,
    last_check_status VARCHAR(16) COMMENT 'HEALTHY/UNHEALTHY',
    status          VARCHAR(16)  DEFAULT 'ACTIVE',
    tenant_id       BIGINT       NOT NULL,
    created_by      VARCHAR(64),
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted         TINYINT      DEFAULT 0,
    INDEX idx_type (source_type),
    INDEX idx_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据源表';
```

#### 7.1.2 同步任务表 (sd_sync_task)

```sql
CREATE TABLE sd_sync_task (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    task_name       VARCHAR(200) NOT NULL,
    source_ds_id    BIGINT       NOT NULL COMMENT '源数据源ID',
    target_ds_id    BIGINT       NOT NULL COMMENT '目标数据源ID',
    source_table    VARCHAR(200) NOT NULL,
    target_table    VARCHAR(200) NOT NULL,
    field_mapping   JSON         NOT NULL COMMENT '字段映射[{source,target,transform}]',
    sync_mode       VARCHAR(16)  DEFAULT 'FULL' COMMENT 'FULL/INCREMENTAL',
    incr_field      VARCHAR(100) COMMENT '增量字段(增量模式)',
    last_sync_value VARCHAR(500) COMMENT '上次同步值(增量断点)',
    cron_expression VARCHAR(128) COMMENT '调度Cron',
    transform_rules JSON         COMMENT '数据转换规则',
    error_strategy  VARCHAR(32)  DEFAULT 'SKIP' COMMENT 'SKIP/ABORT/RETRY',
    retry_count     INT          DEFAULT 3,
    rate_limit      INT          DEFAULT 1000 COMMENT '限流(行/秒)',
    status          VARCHAR(16)  DEFAULT 'CREATED' COMMENT 'CREATED/RUNNING/SUCCESS/FAILED/PAUSED',
    last_run_at     DATETIME,
    last_run_status VARCHAR(16),
    last_run_duration_ms BIGINT,
    last_sync_rows  BIGINT,
    total_sync_rows BIGINT       DEFAULT 0,
    tenant_id       BIGINT       NOT NULL,
    created_by      VARCHAR(64),
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted         TINYINT      DEFAULT 0,
    INDEX idx_source (source_ds_id),
    INDEX idx_status (status),
    INDEX idx_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='同步任务表';
```

#### 7.1.3 同步日志表 (sd_sync_log)

```sql
CREATE TABLE sd_sync_log (
    id              BIGINT       PRIMARY KEY AUTO_INCREMENT,
    task_id         BIGINT       NOT NULL,
    run_batch       VARCHAR(64)  NOT NULL COMMENT '运行批次号',
    status          VARCHAR(16)  NOT NULL COMMENT 'RUNNING/SUCCESS/FAILED',
    sync_mode       VARCHAR(16)  COMMENT 'FULL/INCREMENTAL',
    read_rows       BIGINT       DEFAULT 0 COMMENT '读取行数',
    write_rows      BIGINT       DEFAULT 0 COMMENT '写入行数',
    error_rows      BIGINT       DEFAULT 0 COMMENT '错误行数',
    error_detail    JSON         COMMENT '错误明细(前100条)',
    started_at      DATETIME     NOT NULL,
    finished_at     DATETIME,
    duration_ms     BIGINT,
    rate_rows_per_sec DECIMAL(10,2) COMMENT '同步速率(行/秒)',
    tenant_id       BIGINT       NOT NULL,
    INDEX idx_task (task_id),
    INDEX idx_batch (run_batch),
    INDEX idx_status (status),
    INDEX idx_started (started_at),
    INDEX idx_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='同步日志表';
```

### 7.2 API接口设计

| 接口 | 方法 | 路径 | 说明 |
|------|:----:|------|------|
| **数据源管理** | | | |
| 创建数据源 | POST | `/api/integration/datasources` | 注册数据源 |
| 数据源列表 | GET | `/api/integration/datasources` | 数据源列表 |
| 数据源详情 | GET | `/api/integration/datasources/{id}` | 数据源详情 |
| 连接测试 | POST | `/api/integration/datasources/{id}/test` | 测试连接 |
| 更新数据源 | PUT | `/api/integration/datasources/{id}` | 修改数据源 |
| 删除数据源 | DELETE | `/api/integration/datasources/{id}` | 删除数据源 |
| 健康检查 | GET | `/api/integration/datasources/health` | 数据源健康状态 |
| **同步任务** | | | |
| 创建同步任务 | POST | `/api/integration/sync-tasks` | 创建同步任务 |
| 同步任务列表 | GET | `/api/integration/sync-tasks` | 任务列表 |
| 任务详情 | GET | `/api/integration/sync-tasks/{id}` | 任务详情 |
| 执行同步 | POST | `/api/integration/sync-tasks/{id}/execute` | 手动执行 |
| 暂停任务 | PUT | `/api/integration/sync-tasks/{id}/pause` | 暂停调度 |
| 恢复任务 | PUT | `/api/integration/sync-tasks/{id}/resume` | 恢复调度 |
| 字段映射建议 | GET | `/api/integration/sync-tasks/mapping-suggest` | 自动映射建议 |
| **同步监控** | | | |
| 同步日志列表 | GET | `/api/integration/sync-logs` | 同步日志列表 |
| 同步日志详情 | GET | `/api/integration/sync-logs/{id}` | 日志详情(含错误明细) |
| 同步监控看板 | GET | `/api/integration/monitor/dashboard` | 监控总览 |
| **元数据采集** | | | |
| 手动采集 | POST | `/api/integration/metadata/collect` | 手动触发元数据采集 |
| 采集历史 | GET | `/api/integration/metadata/history` | 采集历史 |
| 变更检测 | GET | `/api/integration/metadata/changes` | 结构变更记录 |

### 7.3 数据同步执行流程

```
SyncExecutor.execute(task)
    │
    ├── 1. 初始化
    │   ├── 加载同步配置（源/目标/映射/转换/错误策略）
    │   ├── 创建源端连接（SourceConnector）
    │   ├── 创建目标端连接（SinkConnector）
    │   └── 创建同步日志记录(status=RUNNING)
    │
    ├── 2. 数据读取（流式分页）
    │   ├── 全量模式：SELECT * FROM source_table
    │   ├── 增量模式：SELECT * WHERE incr_field > #{lastSyncValue}
    │   └── 分页读取（LIMIT/OFFSET 或 游标，每批5000行）
    │
    ├── 3. 数据转换（逐行）
    │   ├── 类型转换（VARCHAR → VARCHAR2 等）
    │   ├── 空值处理（NULL → 默认值）
    │   ├── 字段拼接/拆分
    │   └── 自定义UDF
    │
    ├── 4. 批量写入（500行/批）
    │   ├── JDBC Batch INSERT
    │   └── 错误处理（SKIP跳过/ABORT终止/RETRY重试3次）
    │
    ├── 5. 增量标记
    │   └── 更新 lastSyncValue 到同步任务记录
    │
    ├── 6. 完成
    │   ├── 更新日志(status=SUCCESS, 统计行数/耗时/速率)
    │   ├── 更新任务状态和统计
    │   └── 发送Kafka: sync.completed
    │
    └── 7. 失败处理
        ├── 更新日志(status=FAILED, 错误详情)
        ├── 重试（如策略为RETRY）
        └── 发送Kafka: sync.failed → 告警通知
```

---

## 8. API接口规格总览

### 8.1 接口统计

| 服务 | 接口数量 | 说明 |
|------|:--------:|------|
| profiling-service | 15 | 数据探查任务/结果/定时/AI洞察 |
| tag-service | 19 | 标签体系/打标规则/标签关联/集市 |
| workflow-service | 28 | 流程定义/实例/审批/RACI/SLA/分析 |
| valuation-service | 16 | 估值/ROI/成本/收益/报告 |
| dataproduct-service | 20 | 产品/市场/订阅/计量/账单 |
| analytics-service | 18 | SQL查询/可视化/向导/审计 |
| integration-service | 16 | 数据源/同步任务/监控/元数据采集 |
| **合计** | **132** | |

### 8.2 统一响应格式

```json
{
  "code": 200,
  "message": "success",
  "data": {
    // 业务数据
  },
  "timestamp": "2026-07-15T10:30:00.000Z",
  "traceId": "a1b2c3d4e5f6"
}
```

### 8.3 统一分页格式

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [...],
    "total": 156,
    "page": 1,
    "size": 20,
    "pages": 8
  }
}
```

### 8.4 错误码定义

| 错误码 | 说明 |
|--------|------|
| 40001 | 参数校验失败 |
| 40003 | 权限不足 |
| 40004 | 资源不存在 |
| 40901 | 探查任务冲突（同一表已有运行中任务） |
| 40902 | 查询并发超限 |
| 40903 | SQL不合法（非SELECT语句） |
| 40904 | 查询行数超限 |
| 50001 | 系统内部错误 |
| 50002 | 数据源连接失败 |
| 50003 | AI服务调用失败 |
| 50004 | 工作流引擎异常 |
| 50005 | 同步任务执行失败 |

---

*文档结束 — 智数研发组 — 2026-07-15 — SD-DD-02 V1.0.0*
