# Sprint 7-9 单元测试用例

## 文档控制

| 信息项 | 内容 |
|--------|------|
| **文档编号** | TC-02 |
| **文档版本** | V1.0 |
| **创建日期** | 2026-07-07 |
| **最后修订** | 2026-07-07 |
| **文档状态** | 正式发布 |
| **文档负责人** | 测试团队 |
| **审批人** | 项目经理 |

---

## 1. 测试范围

本文档覆盖 Sprint 7-9 阶段开发的 6 个智数核心服务的单元测试用例：

| Sprint | 服务 | 端口 | 功能 |
|:------:|------|:----:|------|
| S7 | quality-service | 8093 | 六维质量规则+检测执行+问题闭环 |
| S8 | standard-service | 8094 | 数据标准定义+贯标+对标+标准字典 |
| S8 | lineage-service | 8095 | 血缘采集+可视化+影响分析 |
| S9 | mdm-service | 8096 | 主数据识别+合并+分发 |
| S9 | lifecycle-service | 8097 | 冷热分离+归档+销毁 |
| S9 | dataservice-service | 8098 | 数据API创建+发布+网关 |

---

## 2. QualityService 测试用例

### 2.1 规则管理

| 用例编号 | 测试方法 | 测试场景 | 预期结果 | 优先级 |
|----------|----------|----------|----------|:------:|
| QC-R-001 | getRuleById_Success | 获取已存在的质量规则详情 | 返回正确的规则信息 | P0 |
| QC-R-002 | getRuleById_NotFound_ThrowsException | 获取不存在的规则 | 抛出BusinessException | P0 |
| QC-R-003 | createRule_Success | 创建新的质量规则 | 规则创建成功，状态为已启用 | P0 |
| QC-R-004 | toggleRuleStatus_Success | 切换规则启用/禁用状态 | 状态正确切换 | P1 |

### 2.2 问题闭环

| 用例编号 | 测试方法 | 测试场景 | 预期结果 | 优先级 |
|----------|----------|----------|----------|:------:|
| QC-I-001 | handleIssue_Fix_Success | 修复质量问题 | 状态变为已修复(3) | P0 |
| QC-I-002 | handleIssue_Ignore_Success | 忽略质量问题 | 状态变为已忽略(4) | P0 |
| QC-I-003 | handleIssue_InvalidType_ThrowsException | 使用无效处理方式 | 抛出BusinessException | P0 |

### 2.3 统计看板

| 用例编号 | 测试方法 | 测试场景 | 预期结果 | 优先级 |
|----------|----------|----------|----------|:------:|
| QC-S-001 | getQualityDashboard_Success | 获取质量看板数据 | 返回完整的统计数据 | P1 |

---

## 3. StandardService 测试用例

### 3.1 标准管理

| 用例编号 | 测试方法 | 测试场景 | 预期结果 | 优先级 |
|----------|----------|----------|----------|:------:|
| ST-S-001 | getById_Success | 获取标准详情 | 返回正确的标准信息 | P0 |
| ST-S-002 | getById_NotFound_ThrowsException | 获取不存在的标准 | 抛出BusinessException | P0 |
| ST-S-003 | create_Success | 创建新的数据标准 | 标准创建成功，状态为草稿 | P0 |
| ST-S-004 | publish_Success | 发布数据标准 | 状态变为已发布(1) | P0 |

### 3.2 贯标映射

| 用例编号 | 测试方法 | 测试场景 | 预期结果 | 优先级 |
|----------|----------|----------|----------|:------:|
| ST-M-001 | createMapping_Aligned_Success | 创建贯标映射-类型一致 | 映射状态为已贯标(1) | P0 |
| ST-M-002 | createMapping_Inconsistent_Success | 创建贯标映射-类型不一致 | 映射状态为不一致(3) | P0 |
| ST-M-003 | checkAlignment_Success | 对标检查 | 返回正确的对标统计 | P1 |

### 3.3 标准字典与统计

| 用例编号 | 测试方法 | 测试场景 | 预期结果 | 优先级 |
|----------|----------|----------|----------|:------:|
| ST-D-001 | getDictByCode_Success | 按编码获取字典项 | 返回正确的字典列表 | P1 |
| ST-D-002 | getStatistics_Success | 获取标准统计 | 返回完整的统计数据 | P1 |

---

## 4. LineageService 测试用例

### 4.1 节点管理

| 用例编号 | 测试方法 | 测试场景 | 预期结果 | 优先级 |
|----------|----------|----------|----------|:------:|
| LG-N-001 | createNode_Success | 创建血缘节点 | 节点创建成功 | P0 |
| LG-N-002 | getNodeById_Success | 获取节点详情 | 返回正确的节点信息 | P0 |
| LG-N-003 | getNodeById_NotFound_ThrowsException | 获取不存在的节点 | 抛出BusinessException | P0 |
| LG-N-004 | searchNodes_Success | 搜索血缘节点 | 返回匹配的节点列表 | P1 |

### 4.2 边管理与图谱查询

| 用例编号 | 测试方法 | 测试场景 | 预期结果 | 优先级 |
|----------|----------|----------|----------|:------:|
| LG-E-001 | createEdge_Success | 创建血缘关系 | 边创建成功，状态为活跃 | P0 |
| LG-G-001 | getLineageGraph_Success | 获取血缘图谱 | 返回包含节点和边的图数据 | P0 |
| LG-G-002 | impactAnalysis_Success | 影响分析 | 返回受影响节点列表 | P0 |

### 4.3 采集与统计

| 用例编号 | 测试方法 | 测试场景 | 预期结果 | 优先级 |
|----------|----------|----------|----------|:------:|
| LG-C-001 | collectLineage_Success | 血缘采集 | 返回创建的节点和边数量 | P1 |
| LG-S-001 | getStatistics_Success | 获取血缘统计 | 返回完整的统计数据 | P1 |

---

## 5. MdmService 测试用例

### 5.1 模型管理

| 用例编号 | 测试方法 | 测试场景 | 预期结果 | 优先级 |
|----------|----------|----------|----------|:------:|
| MD-M-001 | createModel_Success | 创建主数据模型 | 模型创建成功，状态为草稿 | P0 |
| MD-M-002 | getModelById_Success | 获取模型详情 | 返回正确的模型信息 | P0 |
| MD-M-003 | getModelById_NotFound_ThrowsException | 获取不存在的模型 | 抛出BusinessException | P0 |

### 5.2 识别与合并

| 用例编号 | 测试方法 | 测试场景 | 预期结果 | 优先级 |
|----------|----------|----------|----------|:------:|
| MD-R-001 | getRecordById_Success | 获取主数据记录详情 | 返回正确的记录信息 | P0 |
| MD-R-002 | merge_Success | 主数据合并 | 合并成功，重复记录指向主记录 | P0 |

### 5.3 分发与统计

| 用例编号 | 测试方法 | 测试场景 | 预期结果 | 优先级 |
|----------|----------|----------|----------|:------:|
| MD-D-001 | distribute_Success | 主数据分发 | 分发记录创建成功 | P0 |
| MD-S-001 | getStatistics_Success | 获取主数据统计 | 返回完整的统计数据 | P1 |

---

## 6. LifecycleService 测试用例

### 6.1 策略管理

| 用例编号 | 测试方法 | 测试场景 | 预期结果 | 优先级 |
|----------|----------|----------|----------|:------:|
| LC-P-001 | createPolicy_Success | 创建生命周期策略 | 策略创建成功，状态为草稿 | P0 |
| LC-P-002 | getPolicyById_Success | 获取策略详情 | 返回正确的策略信息 | P0 |
| LC-P-003 | getPolicyById_NotFound_ThrowsException | 获取不存在的策略 | 抛出BusinessException | P0 |
| LC-P-004 | enablePolicy_Success | 启用策略 | 状态变为已启用(1) | P0 |

### 6.2 操作执行

| 用例编号 | 测试方法 | 测试场景 | 预期结果 | 优先级 |
|----------|----------|----------|----------|:------:|
| LC-A-001 | archive_Success | 执行归档 | 归档完成，返回受影响记录数 | P0 |
| LC-A-002 | archive_PolicyNotEnabled_ThrowsException | 策略未启用时归档 | 抛出BusinessException | P0 |
| LC-A-003 | destroy_NeedsApproval | 销毁需审批 | 返回待审批状态 | P0 |
| LC-A-004 | destroy_NoApproval_Success | 销毁无需审批直接执行 | 销毁完成 | P0 |

### 6.3 统计

| 用例编号 | 测试方法 | 测试场景 | 预期结果 | 优先级 |
|----------|----------|----------|----------|:------:|
| LC-S-001 | getStatistics_Success | 获取生命周期统计 | 返回完整的统计数据 | P1 |

---

## 7. DataService 测试用例

### 7.1 API管理

| 用例编号 | 测试方法 | 测试场景 | 预期结果 | 优先级 |
|----------|----------|----------|----------|:------:|
| DS-A-001 | getById_Success | 获取API详情 | 返回正确的API信息 | P0 |
| DS-A-002 | getById_NotFound_ThrowsException | 获取不存在的API | 抛出BusinessException | P0 |
| DS-A-003 | getByCode_Success | 按编码获取API | 返回正确的API信息 | P0 |
| DS-A-004 | create_Success | 创建数据API | API创建成功，状态为草稿 | P0 |
| DS-A-005 | publish_Success | 发布API | 状态变为已发布，返回网关URL | P0 |
| DS-A-006 | offline_Success | 下线API | 状态变为已下线 | P0 |

### 7.2 API调用

| 用例编号 | 测试方法 | 测试场景 | 预期结果 | 优先级 |
|----------|----------|----------|----------|:------:|
| DS-C-001 | callApi_Success | 调用已发布API | 返回模拟数据，记录调用日志 | P0 |
| DS-C-002 | callApi_NotPublished_ThrowsException | 调用未发布API | 抛出BusinessException | P0 |

### 7.3 统计

| 用例编号 | 测试方法 | 测试场景 | 预期结果 | 优先级 |
|----------|----------|----------|----------|:------:|
| DS-S-001 | getStatistics_Success | 获取数据服务统计 | 返回完整的统计数据 | P1 |

---

## 8. 测试统计汇总

| 服务 | 测试类 | 用例数 | P0 | P1 |
|------|--------|:------:|:--:|:--:|
| quality-service | QualityServiceTest | 8 | 6 | 2 |
| standard-service | StandardServiceTest | 9 | 6 | 3 |
| lineage-service | LineageServiceTest | 10 | 7 | 3 |
| mdm-service | MdmServiceTest | 7 | 6 | 1 |
| lifecycle-service | LifecycleServiceTest | 8 | 7 | 1 |
| dataservice-service | DataServiceTest | 9 | 8 | 1 |
| **合计** | **6** | **51** | **40** | **11** |
