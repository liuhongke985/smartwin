# 数据库设计说明书

## 文档控制

| 信息项 | 内容 |
|--------|------|
| **文档编号** | DES-03 |
| **文档版本** | V1.0 |
| **创建日期** | 2026-07-08 |
| **最后修订** | 2026-07-08 |
| **文档状态** | 正式发布 |
| **文档负责人** | DBA / 架构师 |
| **审批人** | 项目总监 |

---

## 1. 数据库概述

### 1.1 数据库选型

| 环境 | 数据库 | 说明 |
|------|--------|------|
| 开发环境 | H2 / MySQL 8.0+ | 快速启动、方便调试 |
| 测试环境 | MySQL 8.0+ / 达梦DM8 | 与生产环境对齐 |
| 生产环境(信创) | 达梦DM8 8.1+ | 信创合规要求 |
| 备选适配 | 人大金仓 / openGauss | common-db-multi自动适配 |

### 1.2 多数据库适配方案

通过 `common-db-multi` 模块实现多数据库透明切换：

```
DatabaseTypeDetector → 检测当前数据库类型
    → DialectRouter → 选择对应DatabaseDialect
        → MySQLDialect / Dm8Dialect / KingbaseDialect / OpenGaussDialect
```

### 1.3 ORM框架

- **MyBatis-Plus 3.5+**：代码生成、分页、逻辑删除
- **Flyway**：数据库版本管理，每个服务独立迁移脚本
- **Druid**：连接池监控

---

## 2. 表命名规范

### 2.1 前缀规范

| 前缀 | 归属 | 示例 |
|------|------|------|
| `sys_` | 共享-系统管理 | sys_user, sys_role, sys_permission |
| `sec_` | 共享-安全治理 | sec_classification, sec_masking_rule |
| `audit_` | 共享-审计日志 | audit_operation_log |
| `sc_` | 智链(SmartChain) | sc_model, sc_app, sc_agent |
| `sd_` | 智数(SmartData) | sd_data_asset, sd_quality_rule |

### 2.2 通用字段规范

所有业务表统一包含以下审计字段：

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | BIGINT PRIMARY KEY | 雪花算法生成 |
| `create_time` | TIMESTAMP | 创建时间，默认CURRENT_TIMESTAMP |
| `update_time` | TIMESTAMP | 更新时间，自动更新 |
| `create_by` | BIGINT | 创建人ID |
| `update_by` | BIGINT | 更新人ID |
| `deleted` | TINYINT DEFAULT 0 | 逻辑删除标记(0未删除/1已删除) |

### 2.3 命名规则

- 表名：小写下划线，`前缀_业务名`
- 字段名：小写下划线，`column_name`
- 索引：`idx_表名_字段名`
- 主键：`pk_表名`
- 外键：`fk_表名_字段名`（实际不创建外键约束，应用层维护）

---

## 3. 共享底座表设计

### 3.1 认证授权模块（auth-service + system-service）

#### sys_user — 用户表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 用户ID |
| username | VARCHAR(50) UNIQUE | 用户名 |
| password | VARCHAR(255) | 密码(BCrypt加密) |
| real_name | VARCHAR(50) | 真实姓名 |
| email | VARCHAR(100) | 邮箱 |
| phone | VARCHAR(20) | 手机号 |
| avatar | VARCHAR(500) | 头像URL |
| status | TINYINT DEFAULT 1 | 状态(1启用/2禁用) |
| org_id | BIGINT | 组织ID |
| last_login_time | TIMESTAMP | 最后登录时间 |

#### sys_role — 角色表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 角色ID |
| role_name | VARCHAR(50) | 角色名称 |
| role_code | VARCHAR(50) UNIQUE | 角色编码 |
| description | VARCHAR(200) | 描述 |
| status | TINYINT DEFAULT 1 | 状态 |

#### sys_permission — 权限表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 权限ID |
| parent_id | BIGINT DEFAULT 0 | 父权限ID |
| perm_name | VARCHAR(50) | 权限名称 |
| perm_code | VARCHAR(100) UNIQUE | 权限编码 |
| perm_type | TINYINT | 类型(1菜单/2按钮/3API) |
| path | VARCHAR(200) | 前端路由 |
| component | VARCHAR(200) | 前端组件 |
| icon | VARCHAR(50) | 图标 |
| sort_order | INT DEFAULT 0 | 排序 |

#### sys_user_role — 用户角色关联表

| 字段 | 类型 | 说明 |
|------|------|------|
| user_id | BIGINT | 用户ID |
| role_id | BIGINT | 角色ID |
| | PK(user_id, role_id) | 联合主键 |

#### sys_role_permission — 角色权限关联表

| 字段 | 类型 | 说明 |
|------|------|------|
| role_id | BIGINT | 角色ID |
| permission_id | BIGINT | 权限ID |
| | PK(role_id, permission_id) | 联合主键 |

#### sys_org — 组织表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 组织ID |
| parent_id | BIGINT DEFAULT 0 | 父组织ID |
| org_name | VARCHAR(100) | 组织名称 |
| org_code | VARCHAR(50) UNIQUE | 组织编码 |
| org_type | TINYINT | 类型(1公司/2部门/3小组) |
| sort_order | INT DEFAULT 0 | 排序 |

### 3.2 安全治理模块（security-service）

#### sec_classification — 数据安全分级表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | ID |
| data_name | VARCHAR(200) | 数据名称 |
| data_source | VARCHAR(100) | 数据来源 |
| security_level | TINYINT | 安全等级(1公开/2内部/3机密/4绝密) |
| classify_rule | VARCHAR(500) | 分级规则 |
| status | TINYINT DEFAULT 1 | 状态 |

#### sec_masking_rule — 数据脱敏规则表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | ID |
| rule_name | VARCHAR(100) | 规则名称 |
| field_type | VARCHAR(50) | 字段类型 |
| mask_pattern | VARCHAR(200) | 脱敏模式 |
| mask_replacement | VARCHAR(50) | 替换字符 |
| status | TINYINT DEFAULT 1 | 状态 |

### 3.3 审计日志模块（audit-service）

#### audit_operation_log — 操作审计日志表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 日志ID |
| user_id | BIGINT | 用户ID |
| username | VARCHAR(50) | 用户名 |
| operation | VARCHAR(200) | 操作描述 |
| module | VARCHAR(50) | 模块 |
| method | VARCHAR(10) | HTTP方法 |
| request_url | VARCHAR(500) | 请求URL |
| request_params | TEXT | 请求参数 |
| response_status | INT | 响应状态码 |
| ip_address | VARCHAR(50) | IP地址 |
| user_agent | VARCHAR(500) | User-Agent |
| execution_time | BIGINT | 执行耗时(ms) |
| operation_time | TIMESTAMP | 操作时间 |

> 索引：idx_audit_user(user_id), idx_audit_time(operation_time), idx_audit_module(module)

---

## 4. 智链(SmartChain)表设计

### 4.1 model-service — AI模型管理

#### sc_model — AI模型表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 模型ID |
| model_name | VARCHAR(100) | 模型名称 |
| model_type | VARCHAR(50) | 类型(LLM/image/voice/video/multimodal) |
| provider | VARCHAR(50) | 供应商(OpenAI/Qwen/Ernie/DeepSeek/Claude/Gemini) |
| api_endpoint | VARCHAR(500) | API端点 |
| api_key_id | BIGINT | 关联密钥ID |
| version | VARCHAR(50) | 版本号 |
| status | TINYINT DEFAULT 1 | 状态(1在线/2离线/3异常/4维护) |
| max_tokens | INT | 最大Token数 |
| temperature | DECIMAL(3,2) | 温度参数(0.00-2.00) |
| description | VARCHAR(500) | 描述 |
| icon_url | VARCHAR(500) | 图标URL |

#### sc_model_version — 模型版本表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 版本ID |
| model_id | BIGINT | 关联模型ID |
| version_number | VARCHAR(50) | 版本号 |
| changelog | TEXT | 变更日志 |
| status | TINYINT DEFAULT 2 | 状态(1当前/2活跃/3废弃) |
| config_json | TEXT | 参数配置JSON |

#### sc_model_apikey — 模型API密钥表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 密钥ID |
| key_name | VARCHAR(100) | 密钥名称 |
| api_key | VARCHAR(255) | API密钥(加密存储) |
| model_id | BIGINT | 关联模型ID(空=通用) |
| permissions | VARCHAR(500) | 权限范围 |
| daily_limit | BIGINT | 日调用上限 |
| expire_time | TIMESTAMP | 过期时间 |

### 4.2 app-service — 智能体应用管理

#### sc_app — 智能体应用表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 应用ID |
| app_name | VARCHAR(100) | 应用名称 |
| app_type | VARCHAR(50) | 类型(chat/agent/workflow) |
| model_id | BIGINT | 默认模型ID |
| system_prompt | TEXT | 系统提示词 |
| description | VARCHAR(500) | 描述 |
| status | TINYINT DEFAULT 1 | 状态 |
| temperature | DECIMAL(3,2) | 温度 |
| max_tokens | INT | 最大Token |
| is_public | TINYINT DEFAULT 0 | 是否公开 |
| icon_url | VARCHAR(500) | 图标 |

### 4.3 cost-service — 成本管理

#### sc_cost_record — 调用成本记录表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 记录ID |
| model_id | BIGINT | 模型ID |
| app_id | BIGINT | 应用ID |
| user_id | BIGINT | 用户ID |
| input_tokens | INT | 输入Token数 |
| output_tokens | INT | 输出Token数 |
| total_tokens | INT | 总Token数 |
| unit_price | DECIMAL(10,6) | 单价 |
| total_cost | DECIMAL(10,4) | 总成本 |
| call_time | TIMESTAMP | 调用时间 |

### 4.4 risk-service — 风险评估

#### sc_risk_rule — 风险规则表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 规则ID |
| rule_name | VARCHAR(100) | 规则名称 |
| risk_type | VARCHAR(50) | 风险类型 |
| rule_content | TEXT | 规则内容 |
| severity | TINYINT | 严重程度(1低/2中/3高/4严重) |
| status | TINYINT DEFAULT 1 | 状态 |

### 4.5 agent-service — 智能体编排

#### sc_agent — 智能体表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 智能体ID |
| agent_name | VARCHAR(100) | 名称 |
| agent_type | VARCHAR(50) | 类型 |
| model_id | BIGINT | 模型ID |
| tools | TEXT | 工具列表(JSON) |
| memory_type | VARCHAR(50) | 记忆类型 |
| config_json | TEXT | 配置JSON |
| status | TINYINT DEFAULT 1 | 状态 |

### 4.6 prompt-service — 提示词管理

#### sc_prompt_template — 提示词模板表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 模板ID |
| template_name | VARCHAR(100) | 名称 |
| category | VARCHAR(50) | 分类 |
| content | TEXT | 提示词内容 |
| variables | TEXT | 变量定义(JSON) |
| model_type | VARCHAR(50) | 适用模型类型 |
| status | TINYINT DEFAULT 1 | 状态 |

---

## 5. 智数(SmartData)表设计

### 5.1 catalog-service — 数据资产目录

#### sd_data_asset — 数据资产表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 资产ID |
| asset_name | VARCHAR(200) | 资产名称 |
| asset_code | VARCHAR(100) | 资产编码 |
| asset_type | VARCHAR(50) | 类型(table/api/file/stream/model) |
| domain | VARCHAR(100) | 业务域 |
| category_id | BIGINT | 分类ID |
| owner | VARCHAR(100) | 负责人 |
| tags | VARCHAR(500) | 标签(逗号分隔) |
| status | TINYINT DEFAULT 1 | 状态(1注册/2发布/3废弃) |
| popularity | BIGINT DEFAULT 0 | 热度 |
| quality_score | INT DEFAULT 0 | 质量评分(0-100) |

#### sd_data_category — 数据分类表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 分类ID |
| category_name | VARCHAR(200) | 分类名称 |
| category_code | VARCHAR(100) | 分类编码 |
| parent_id | BIGINT DEFAULT 0 | 父分类ID |
| sort_order | INT DEFAULT 0 | 排序 |

### 5.2 metadata-service — 元数据管理

#### sd_metadata — 元数据表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 元数据ID |
| asset_id | BIGINT | 关联资产ID |
| field_name | VARCHAR(200) | 字段名 |
| field_type | VARCHAR(50) | 字段类型 |
| field_comment | VARCHAR(500) | 字段注释 |
| is_primary_key | TINYINT DEFAULT 0 | 是否主键 |
| is_nullable | TINYINT DEFAULT 1 | 是否可空 |
| default_value | VARCHAR(200) | 默认值 |
| data_length | INT | 数据长度 |
| ai_description | TEXT | AI补全描述 |

### 5.3 quality-service — 数据质量管理

#### sd_quality_rule — 质量规则表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 规则ID |
| rule_name | VARCHAR(200) | 规则名称 |
| rule_type | VARCHAR(50) | 规则类型(完整性/准确性/一致性/时效性/唯一性/有效性) |
| rule_config | TEXT | 规则配置(JSON) |
| asset_id | BIGINT | 关联资产ID |
| severity | TINYINT | 严重程度(1提示/2警告/3错误) |
| status | TINYINT DEFAULT 1 | 状态 |

#### sd_quality_task — 质量检测任务表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 任务ID |
| task_name | VARCHAR(200) | 任务名称 |
| rule_ids | VARCHAR(500) | 关联规则ID列表 |
| target_asset | VARCHAR(200) | 检测目标 |
| schedule_type | VARCHAR(50) | 调度类型(manual/cron/event) |
| cron_expression | VARCHAR(100) | Cron表达式 |
| last_run_time | TIMESTAMP | 最后执行时间 |
| status | TINYINT DEFAULT 1 | 状态 |

#### sd_quality_issue — 质量问题表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 问题ID |
| task_id | BIGINT | 关联任务ID |
| rule_id | BIGINT | 关联规则ID |
| asset_id | BIGINT | 关联资产ID |
| issue_desc | TEXT | 问题描述 |
| severity | TINYINT | 严重程度 |
| status | TINYINT DEFAULT 1 | 状态(1待处理/2处理中/3已解决/4已忽略) |
| resolve_time | TIMESTAMP | 解决时间 |

### 5.4 lineage-service — 数据血缘

#### sd_lineage_node — 血缘节点表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 节点ID |
| node_name | VARCHAR(200) | 节点名称 |
| node_type | VARCHAR(50) | 类型(source/transform/target) |
| asset_id | BIGINT | 关联资产ID |
| metadata | TEXT | 节点元数据(JSON) |

#### sd_lineage_edge — 血缘边表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK | 边ID |
| source_node_id | BIGINT | 源节点ID |
| target_node_id | BIGINT | 目标节点ID |
| relation_type | VARCHAR(50) | 关系类型(derive/transform/copy) |
| transform_logic | TEXT | 转换逻辑 |

> 注：血缘图谱同时存储于Neo4j图数据库，支持BFS遍历和影响分析

### 5.5 其他智数服务表（简表）

| 服务 | 表名 | 说明 |
|------|------|------|
| standard-service | sd_standard | 数据标准定义表 |
| standard-service | sd_standard_mapping | 标准贯标映射表 |
| mdm-service | sd_mdm_model | 主数据模型表 |
| mdm-service | sd_mdm_record | 主数据记录表 |
| lifecycle-service | sd_lifecycle_policy | 生命周期策略表 |
| lifecycle-service | sd_archive_record | 归档记录表 |
| dataservice-service | sd_api_definition | 数据API定义表 |
| dataservice-service | sd_api_call_log | API调用日志表 |

---

## 6. 索引设计规范

### 6.1 索引创建原则

| 原则 | 说明 |
|------|------|
| 主键索引 | 所有表主键自动创建索引 |
| 外键关联字段 | 关联字段创建索引(如user_id, model_id) |
| 高频查询字段 | 查询条件中的字段创建索引 |
| 唯一约束 | 业务唯一字段创建唯一索引 |
| 复合索引 | 按查询频率从高到低排列字段 |

### 6.2 已建索引

| 表 | 索引名 | 字段 |
|------|--------|------|
| audit_operation_log | idx_audit_user | user_id |
| audit_operation_log | idx_audit_time | operation_time |
| audit_operation_log | idx_audit_module | module |

---

## 7. 数据库迁移管理

### 7.1 Flyway迁移规范

```
xxx-service/src/main/resources/db/migration/
├── V1__xxx_tables.sql     # 初始建表
├── V2__xxx_alter.sql      # 表结构变更
└── V3__xxx_index.sql      # 索引优化
```

### 7.2 迁移规则

| 规则 | 说明 |
|------|------|
| 版本号递增 | V1, V2, V3...不可跳号 |
| 不可修改已执行脚本 | 已执行的迁移脚本不可修改 |
| 向下兼容 | 表结构变更不可破坏现有功能 |
| 附带注释 | 每个CREATE TABLE/ALTER附带COMMENT ON |

---

## 8. 数据安全

### 8.1 敏感数据加密

| 数据类型 | 加密方式 | 说明 |
|----------|----------|------|
| 用户密码 | BCrypt | 单向哈希 |
| API密钥 | SM4对称加密 | 可逆加密存储 |
| 身份证号 | SM4+脱敏 | 加密存储+展示脱敏 |
| 手机号 | 脱敏 | 138****8888 |

### 8.2 数据备份

| 备份类型 | 频率 | 保留周期 | 存储位置 |
|----------|:----:|:--------:|----------|
| 全量备份 | 每日 | 30天 | NAS存储 |
| 增量备份 | 每小时 | 7天 | NAS存储 |
| 归档备份 | 每月 | 1年 | 离线存储 |

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-08 | DBA/架构师 | 初始版本发布，覆盖共享+智链+智数全量表结构 |
