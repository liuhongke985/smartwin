# SmartWin 数据库设计文档

## 文档信息
- **版本**: 1.0.0
- **创建日期**: 2026-07-27
- **数据库**: MySQL 8.0

---

## 目录
1. [数据库概述](#1-数据库概述)
2. [核心表设计](#2-核心表设计)
3. [索引策略](#3-索引策略)
4. [命名规范](#4-命名规范)

---

## 1. 数据库概述

### 1.1 数据库列表

| 数据库名 | 用途 | 字符集 |
|---------|------|--------|
| smartwin_data | SmartData数据治理 | utf8mb4 |
| smartwin_chain | SmartChain AI协同 | utf8mb4 |
| smartwin_auth | 认证授权 | utf8mb4 |
| smartwin_monitor | 监控告警 | utf8mb4 |

### 1.2 公共字段约定

所有业务表都包含以下公共字段：

```sql
id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
created_at  DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT '创建时间',
updated_at  DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3) COMMENT '更新时间',
created_by  VARCHAR(64) NOT NULL DEFAULT '' COMMENT '创建人',
updated_by  VARCHAR(64) NOT NULL DEFAULT '' COMMENT '更新人',
is_deleted  TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否删除: 0=否, 1=是',
version     INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号'
```

---

## 2. 核心表设计

### 2.1 数据资产表 (data_asset)

```sql
CREATE TABLE data_asset (
    id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    asset_code      VARCHAR(64) NOT NULL COMMENT '资产编码，全局唯一',
    asset_name      VARCHAR(256) NOT NULL COMMENT '资产名称',
    description     TEXT COMMENT '资产描述',
    category_id     BIGINT UNSIGNED COMMENT '分类ID',
    status          TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 0=未激活, 1=活跃, 2=废弃',
    owner_id        BIGINT UNSIGNED COMMENT '负责人ID',
    quality_score   DECIMAL(5,2) COMMENT '质量评分 0-100',
    storage_type    VARCHAR(32) COMMENT '存储类型: mysql/hdfs/s3/etc',
    storage_location VARCHAR(512) COMMENT '存储位置',
    sensitivity_level TINYINT NOT NULL DEFAULT 0 COMMENT '敏感级别: 0=公开, 1=内部, 2=保密, 3=绝密',
    tags            JSON COMMENT '标签列表',
    extra_info      JSON COMMENT '扩展信息',
    created_at      DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at      DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    created_by      VARCHAR(64) NOT NULL DEFAULT '',
    updated_by      VARCHAR(64) NOT NULL DEFAULT '',
    is_deleted      TINYINT(1) NOT NULL DEFAULT 0,
    version         INT NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    UNIQUE KEY uk_asset_code (asset_code),
    KEY idx_category_id (category_id),
    KEY idx_owner_id (owner_id),
    KEY idx_status (status),
    KEY idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='数据资产表';
```

### 2.2 数据质量检测结果表 (data_quality_check)

```sql
CREATE TABLE data_quality_check (
    id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    asset_id        BIGINT UNSIGNED NOT NULL COMMENT '数据资产ID',
    check_type      VARCHAR(32) NOT NULL COMMENT '检测类型: completeness/accuracy/consistency/timeliness',
    check_status    TINYINT NOT NULL DEFAULT 0 COMMENT '0=待执行, 1=执行中, 2=成功, 3=失败',
    score           DECIMAL(5,2) COMMENT '质量评分',
    total_records   BIGINT COMMENT '总记录数',
    passed_records  BIGINT COMMENT '通过记录数',
    failed_records  BIGINT COMMENT '失败记录数',
    failure_details JSON COMMENT '失败详情',
    started_at      DATETIME(3) COMMENT '开始时间',
    finished_at     DATETIME(3) COMMENT '完成时间',
    created_at      DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at      DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    created_by      VARCHAR(64) NOT NULL DEFAULT '',
    updated_by      VARCHAR(64) NOT NULL DEFAULT '',
    is_deleted      TINYINT(1) NOT NULL DEFAULT 0,
    version         INT NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_asset_id (asset_id),
    KEY idx_check_status (check_status),
    KEY idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='数据质量检测结果';
```

### 2.3 AI协同链执行记录 (ai_chain_execution)

```sql
CREATE TABLE ai_chain_execution (
    id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    execution_id    VARCHAR(64) NOT NULL COMMENT '执行ID，全局唯一',
    chain_id        VARCHAR(64) NOT NULL COMMENT '协同链ID',
    chain_version   VARCHAR(16) COMMENT '协同链版本',
    status          TINYINT NOT NULL DEFAULT 0 COMMENT '0=待执行, 1=执行中, 2=成功, 3=失败, 4=取消',
    input_params    JSON COMMENT '输入参数',
    output_result   LONGTEXT COMMENT '输出结果',
    error_message   TEXT COMMENT '错误信息',
    tokens_used     INT COMMENT '消耗的Token数量',
    cost_amount     DECIMAL(10,6) COMMENT '消耗费用',
    duration_ms     INT COMMENT '执行时长(毫秒)',
    started_at      DATETIME(3) COMMENT '开始时间',
    finished_at     DATETIME(3) COMMENT '完成时间',
    created_at      DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at      DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    created_by      VARCHAR(64) NOT NULL DEFAULT '',
    updated_by      VARCHAR(64) NOT NULL DEFAULT '',
    is_deleted      TINYINT(1) NOT NULL DEFAULT 0,
    version         INT NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    UNIQUE KEY uk_execution_id (execution_id),
    KEY idx_chain_id (chain_id),
    KEY idx_status (status),
    KEY idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='AI协同链执行记录';
```

### 2.4 用户权限表 (sys_user)

```sql
CREATE TABLE sys_user (
    id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    username        VARCHAR(64) NOT NULL COMMENT '用户名',
    email           VARCHAR(128) NOT NULL COMMENT '邮箱',
    display_name    VARCHAR(128) COMMENT '显示名称',
    status          TINYINT NOT NULL DEFAULT 1 COMMENT '0=禁用, 1=启用',
    last_login_at   DATETIME COMMENT '最后登录时间',
    created_at      DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at      DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    created_by      VARCHAR(64) NOT NULL DEFAULT '',
    updated_by      VARCHAR(64) NOT NULL DEFAULT '',
    is_deleted      TINYINT(1) NOT NULL DEFAULT 0,
    version         INT NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    UNIQUE KEY uk_username (username),
    UNIQUE KEY uk_email (email),
    KEY idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统用户表';
```

---

## 3. 索引策略

### 3.1 索引规范

- 主键: 使用 `BIGINT UNSIGNED AUTO_INCREMENT`
- 唯一索引: `uk_` 前缀
- 普通索引: `idx_` 前缀
- 联合索引: 遵循最左前缀原则
- 禁止冗余索引

### 3.2 分页优化

大表分页使用游标分页代替OFFSET：

```sql
-- 低效 (大offset时性能差)
SELECT * FROM data_asset LIMIT 10000, 20;

-- 高效 (游标分页)
SELECT * FROM data_asset WHERE id > :lastId ORDER BY id LIMIT 20;
```

---

## 4. 命名规范

| 对象 | 规范 | 示例 |
|------|------|------|
| 数据库 | 小写，下划线 | `smartwin_data` |
| 表名 | 小写，下划线，名词 | `data_asset` |
| 字段名 | 小写，下划线 | `created_at` |
| 主键 | `id` | `id` |
| 外键 | `关联表单数_id` | `category_id` |
| 唯一索引 | `uk_字段名` | `uk_asset_code` |
| 普通索引 | `idx_字段名` | `idx_created_at` |

---

*版本: 1.0.0 | 最后更新: 2026-07-27*
