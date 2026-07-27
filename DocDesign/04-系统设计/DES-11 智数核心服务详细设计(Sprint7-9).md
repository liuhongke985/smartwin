# 智数核心服务详细设计说明书（Sprint 7-9）

## 文档控制

| 信息项 | 内容 |
|--------|------|
| **文档编号** | DES-11 |
| **文档版本** | V1.0 |
| **创建日期** | 2026-07-07 |
| **最后修订** | 2026-07-07 |
| **文档状态** | 正式发布 |
| **文档负责人** | 架构师 |
| **审批人** | 技术委员会 |

---

## 1. 设计概述

### 1.1 文档范围

本文档覆盖 Sprint 7-9 阶段开发的 6 个智数核心服务的详细设计，包括：
- **quality-service** (8093) — 六维数据质量管理
- **standard-service** (8094) — 数据标准管理
- **lineage-service** (8095) — 数据血缘管理
- **mdm-service** (8096) — 主数据管理
- **lifecycle-service** (8097) — 数据生命周期管理
- **dataservice-service** (8098) — 数据服务管理

### 1.2 设计原则

| 原则 | 说明 |
|------|------|
| 微服务架构 | 每个服务独立部署、独立数据库、独立扩缩容 |
| 统一规范 | 遵循 BaseEntity + MyBatis-Plus + ApiResponse 统一规范 |
| 信创兼容 | 全部服务支持 DM8/MySQL/Kingbase/openGauss 多数据库 |
| API优先 | 所有功能通过 RESTful API 对外暴露，Knife4j 文档自动生成 |
| 六维质量 | 质量管理覆盖完整性/唯一性/一致性/有效性/及时性/准确性 |

---

## 2. quality-service 详细设计

### 2.1 架构设计

```
quality-service (8093)
├── entity/
│   ├── QualityRule        — 质量规则(六维)
│   ├── QualityTask        — 检测任务
│   └── QualityIssue       — 质量问题(闭环)
├── mapper/
│   ├── QualityRuleMapper
│   ├── QualityTaskMapper
│   └── QualityIssueMapper
├── dto/
│   ├── QualityRuleCreateDTO / UpdateDTO / QueryDTO
│   ├── QualityTaskCreateDTO / QueryDTO
│   └── IssueHandleDTO
├── service/
│   └── QualityService     — 规则管理+任务执行+问题闭环+统计
└── controller/
    └── QualityController  — REST API
```

### 2.2 核心数据模型

#### sd_quality_rule (质量规则表)
| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT | 主键 |
| rule_name | VARCHAR(200) | 规则名称 |
| dimension | VARCHAR(50) | 六维: completeness/uniqueness/consistency/validity/timeliness/accuracy |
| rule_type | VARCHAR(50) | 类型: not_null/unique/range/regex/reference/custom |
| severity | INT | 严重级别: 1-提示 2-一般 3-严重 4-致命 |
| status | INT | 0-草稿 1-已启用 2-已禁用 |

#### sd_quality_task (检测任务表)
| 字段 | 类型 | 说明 |
|------|------|------|
| rule_ids | TEXT | 关联规则ID(逗号分隔) |
| schedule_type | VARCHAR(20) | manual/scheduled |
| quality_score | INT | 质量评分(0-100) |
| status | INT | 0-待执行 1-执行中 2-已完成 3-执行失败 |

#### sd_quality_issue (质量问题表)
| 字段 | 类型 | 说明 |
|------|------|------|
| task_id | BIGINT | 关联任务 |
| rule_id | BIGINT | 关联规则 |
| status | INT | 1-待处理 2-处理中 3-已修复 4-已忽略 |
| handle_type | VARCHAR(20) | fix/ignore/reassign |

### 2.3 API设计

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | /api/smartdata/quality/rules | 分页查询规则 |
| POST | /api/smartdata/quality/rules | 创建规则 |
| PUT | /api/smartdata/quality/rules/{id} | 更新规则 |
| DELETE | /api/smartdata/quality/rules/{id} | 删除规则 |
| PUT | /api/smartdata/quality/rules/{id}/toggle | 启用/禁用规则 |
| POST | /api/smartdata/quality/tasks | 创建检测任务 |
| POST | /api/smartdata/quality/tasks/{id}/execute | 执行检测 |
| GET | /api/smartdata/quality/issues | 查询问题 |
| PUT | /api/smartdata/quality/issues/{id}/handle | 处理问题(闭环) |
| GET | /api/smartdata/quality/dashboard | 质量看板 |

---

## 3. standard-service 详细设计

### 3.1 核心设计

- **标准定义**：支持数据元、参考数据、主数据、指标四类标准
- **贯标映射**：标准与实际字段的映射关系，自动检查类型/长度一致性
- **对标检查**：一键检查所有映射的对标情况，输出不一致列表
- **标准字典**：参考数据标准字典管理

### 3.2 核心数据模型

#### sd_data_standard (数据标准表)
| 字段 | 类型 | 说明 |
|------|------|------|
| standard_code | VARCHAR(100) | 标准编码 |
| category | VARCHAR(50) | 分类: data_element/reference_data/master_data/indicator |
| data_type | VARCHAR(50) | 数据类型 |
| data_length | INT | 数据长度 |
| status | INT | 0-草稿 1-已发布 2-已废止 |

#### sd_standard_mapping (贯标映射表)
| 字段 | 类型 | 说明 |
|------|------|------|
| standard_id | BIGINT | 关联标准 |
| mapping_status | INT | 1-已贯标 2-待对标 3-不一致 |
| diff_remark | VARCHAR(500) | 对标差异说明 |

---

## 4. lineage-service 详细设计

### 4.1 核心设计

- **图模型**：节点(LineageNode) + 边(LineageEdge) 构建有向无环图(DAG)
- **BFS遍历**：支持指定深度的上游/下游/双向血缘图谱查询
- **影响分析**：递归遍历受影响节点链路
- **自动采集**：模拟解析ETL作业/SQL视图，自动构建血缘关系

### 4.2 核心数据模型

#### sd_lineage_node (血缘节点表)
| 字段 | 类型 | 说明 |
|------|------|------|
| node_type | VARCHAR(50) | table/column/api/file/stream |
| table_name | VARCHAR(200) | 表名 |
| column_name | VARCHAR(200) | 列名 |

#### sd_lineage_edge (血缘关系表)
| 字段 | 类型 | 说明 |
|------|------|------|
| source_node_id | BIGINT | 源节点 |
| target_node_id | BIGINT | 目标节点 |
| edge_type | VARCHAR(50) | etl/view/api_push/api_pull/stream |
| transformation | VARCHAR(500) | 转换说明 |

---

## 5. mdm-service 详细设计

### 5.1 核心设计

- **模型管理**：支持客户/产品/组织/供应商/员工/账户等主数据类型
- **识别算法**：基于名称相似度的重复数据识别（后续引入AI增强）
- **合并策略**：支持自动/手动合并，主记录+重复记录归并
- **分发机制**：推/拉模式分发到目标系统

### 5.2 核心数据模型

#### sd_mdm_record (主数据记录表)
| 字段 | 类型 | 说明 |
|------|------|------|
| merge_status | INT | 1-主记录 2-已合并 3-待合并 4-冲突 |
| master_record_id | BIGINT | 合并指向的主记录 |
| confidence | INT | 置信度(0-100) |

---

## 6. lifecycle-service 详细设计

### 6.1 核心设计

- **冷热分离**：热数据(在线查询) → 温数据(低频查询) → 冷数据(归档存储) → 销毁
- **归档策略**：冷存储/文件归档/数据库归档
- **销毁审批**：支持审批流程，安全销毁(secure_delete/overwrite/physical_delete)
- **数据恢复**：归档数据可恢复

### 6.2 核心数据模型

#### sd_lifecycle_policy (策略表)
| 字段 | 类型 | 说明 |
|------|------|------|
| hot_retention_days | INT | 热数据保留天数 |
| warm_retention_days | INT | 温数据保留天数 |
| cold_retention_days | INT | 冷数据保留天数 |
| archive_strategy | VARCHAR(50) | 归档策略 |
| destroy_strategy | VARCHAR(50) | 销毁策略 |
| destroy_approval_required | INT | 是否需要审批 |

---

## 7. dataservice-service 详细设计

### 7.1 核心设计

- **API生命周期**：草稿 → 发布 → 下线，支持版本管理
- **网关集成**：发布时注册到API网关路由
- **调用统计**：每次调用记录日志，支持QPS限流和缓存
- **认证方式**：api_key/jwt/public 三种认证

### 7.2 核心数据模型

#### sd_data_api (数据API表)
| 字段 | 类型 | 说明 |
|------|------|------|
| api_path | VARCHAR(500) | API路径 |
| http_method | VARCHAR(10) | GET/POST |
| api_type | VARCHAR(20) | query/aggregate/realtime/file |
| query_sql | TEXT | 查询SQL |
| auth_type | VARCHAR(20) | api_key/jwt/public |
| rate_limit | INT | 限流QPS |
| cache_ttl | INT | 缓存TTL(秒) |
| status | INT | 0-草稿 1-已发布 2-已下线 |

#### sd_api_call_log (调用日志表)
| 字段 | 类型 | 说明 |
|------|------|------|
| api_id | BIGINT | 关联API |
| response_code | INT | 响应状态码 |
| response_time | BIGINT | 响应时间(毫秒) |
| cache_hit | INT | 是否命中缓存 |

---

## 8. 服务端口规划

| 服务 | 端口 | Sprint |
|------|:----:|:------:|
| catalog-service | 8091 | S6 |
| metadata-service | 8092 | S6 |
| quality-service | 8093 | S7 |
| standard-service | 8094 | S8 |
| lineage-service | 8095 | S8 |
| mdm-service | 8096 | S9 |
| lifecycle-service | 8097 | S9 |
| dataservice-service | 8098 | S9 |
| asset-service | 8099 | S10(预留) |
| integration-service | 8100 | S10(预留) |
