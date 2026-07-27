# Sprint 3-6 单元测试用例

## 文档控制

| 信息项 | 内容 |
|--------|------|
| **文档编号** | TC-01 |
| **文档版本** | V1.0 |
| **创建日期** | 2026-07-07 |
| **最后修订** | 2026-07-07 |
| **文档状态** | 正式发布 |
| **文档负责人** | 测试团队 |
| **覆盖范围** | Sprint 3-6 全部新增/修改代码 |

---

## 1. 测试范围总览

| Sprint | 模块 | 测试类 | 测试用例数 | 覆盖率目标 |
|:------:|------|--------|:----------:|:----------:|
| S3 | common-db-multi | DatabaseTypeDetectorTest | 13 | ≥80% |
| S3 | common-util (i18n) | HeaderLocaleResolverTest | 8 | ≥80% |
| S3 | common-crypto-gm | CryptoFacadeTest | 9 | ≥80% |
| S3 | model-service | AiModelServiceTest | 8 | ≥80% |
| S3 | model-service | ModelVersionServiceTest | 5 | ≥80% |
| S3 | app-service | AiAppServiceTest | 9 | ≥80% |
| S4 | agent-service | AgentServiceTest | 10 | ≥80% |
| S4 | prompt-service | PromptServiceTest | 10 | ≥80% |
| S5 | catalog-service | CatalogServiceTest | 11 | ≥80% |
| S6 | metadata-service | MetadataServiceTest | 9 | ≥80% |
| **合计** | **10个模块** | **10个测试类** | **92** | **≥80%** |

---

## 2. Sprint 3 测试用例

### 2.1 DatabaseTypeDetectorTest (S3-05b)

| 用例ID | 测试方法 | 测试描述 | 前置条件 | 预期结果 | 优先级 |
|:------:|----------|----------|----------|----------|:------:|
| TC-S3-001 | detect_MySql_ByUrl | 通过JDBC URL探测MySQL | Mock DataSource返回mysql URL | isMysql()=true | P0 |
| TC-S3-002 | detect_Dm8_ByUrl | 通过JDBC URL探测达梦DM8 | Mock DataSource返回dm URL | isDm8()=true, isXinchuangDb()=true | P0 |
| TC-S3-003 | detect_Kingbase_ByUrl | 通过JDBC URL探测人大金仓 | Mock DataSource返回kingbase URL | isKingbase()=true | P0 |
| TC-S3-004 | detect_OpenGauss_ByUrl | 通过JDBC URL探测openGauss | Mock DataSource返回opengauss URL | isOpenGauss()=true | P0 |
| TC-S3-005 | resolver_AllDialectsRegistered | 验证所有方言已注册 | 无 | 4种方言全部注册 | P0 |
| TC-S3-006 | resolver_ResolveByUrl | URL解析各类型方言 | 提供各类型JDBC URL | 返回正确方言 | P0 |
| TC-S3-007 | resolver_UnknownUrl_FallbackToMysql | 未知URL回退MySQL | 提供未知URL前缀 | 回退到MySQL方言 | P1 |
| TC-S3-008 | resolver_NullUrl_FallbackToMysql | 空URL回退MySQL | URL为null | 回退到MySQL方言 | P1 |
| TC-S3-009 | dm8Dialect_FirstPage | 达梦分页SQL(第一页) | offset=0 | 包含TOP关键字 | P1 |
| TC-S3-010 | dm8Dialect_WithOffset | 达梦分页SQL(带偏移) | offset=20 | 包含ROWNUM | P1 |
| TC-S3-011 | kingbaseDialect_Pagination | 金仓分页SQL | offset=10,limit=20 | 包含LIMIT/OFFSET | P1 |
| TC-S3-012 | allDialects_DriverClassName | 各方言驱动类名正确 | 无 | 4种驱动类名正确 | P1 |
| TC-S3-013 | detect连接失败回退 | 连接异常时回退MySQL | Mock抛出SQLException | 回退到MySQL方言 | P1 |

### 2.2 AiModelServiceTest (S3-01)

| 用例ID | 测试方法 | 测试描述 | 预期结果 | 优先级 |
|:------:|----------|----------|----------|:------:|
| TC-S3-014 | getById_Success | 获取模型详情成功 | 返回正确模型 | P0 |
| TC-S3-015 | getById_NotFound_ThrowsException | 模型不存在抛异常 | BusinessException | P0 |
| TC-S3-016 | create_Success | 创建模型成功 | 模型状态=1(在线) | P0 |
| TC-S3-017 | create_DuplicateName_ThrowsException | 模型名称重复 | BusinessException | P0 |
| TC-S3-018 | update_Success | 更新模型配置成功 | 字段更新正确 | P0 |
| TC-S3-019 | delete_Success | 删除模型成功 | 调用deleteById | P0 |
| TC-S3-020 | compare_Success | 多模型对比成功 | 返回2条对比数据 | P1 |
| TC-S3-021 | getMonitorData_Success | 获取监控数据成功 | 返回metrics对象 | P1 |

### 2.3 AiAppServiceTest (S3-02)

| 用例ID | 测试方法 | 测试描述 | 预期结果 | 优先级 |
|:------:|----------|----------|----------|:------:|
| TC-S3-022 | getById_Success | 获取应用详情成功 | 返回正确应用 | P0 |
| TC-S3-023 | create_Success | 创建应用成功 | 状态=草稿 | P0 |
| TC-S3-024 | create_DuplicateName | 应用名称重复 | BusinessException | P0 |
| TC-S3-025 | update_Success | 更新应用成功 | 字段更新正确 | P0 |
| TC-S3-026 | delete_Success | 删除应用成功 | 调用deleteById | P0 |
| TC-S3-027 | offlineRequest_Success | 提交下线申请成功 | 状态=审核中 | P1 |
| TC-S3-028 | approveOffline_Success | 审批下线成功 | 状态=已下线 | P1 |
| TC-S3-029 | getStatus_Success | 获取应用状态成功 | 返回状态信息 | P1 |
| TC-S3-030 | getById_NotFound | 应用不存在 | BusinessException | P0 |

---

## 3. Sprint 4 测试用例

### 3.1 AgentServiceTest (S4-03)

| 用例ID | 测试方法 | 测试描述 | 预期结果 | 优先级 |
|:------:|----------|----------|----------|:------:|
| TC-S4-001 | getById_Success | 获取Agent详情成功 | 返回正确Agent | P0 |
| TC-S4-002 | getById_NotFound_ThrowsException | Agent不存在 | BusinessException | P0 |
| TC-S4-003 | create_Success | 创建Agent成功 | 状态=1(启用), callCount=0 | P0 |
| TC-S4-004 | create_DuplicateName_ThrowsException | Agent名称重复 | BusinessException | P0 |
| TC-S4-005 | update_Success | 更新Agent配置成功 | maxSteps更新正确 | P0 |
| TC-S4-006 | delete_Success | 删除Agent成功 | 调用deleteById | P0 |
| TC-S4-007 | toggleStatus_EnableToDisable | 状态切换:启用→禁用 | status=0 | P0 |
| TC-S4-008 | toggleStatus_DisableToEnable | 状态切换:禁用→启用 | status=1 | P0 |
| TC-S4-009 | testAgent_Success | 测试Agent执行成功 | status=completed, callCount+1 | P1 |
| TC-S4-010 | getExecutionLog_Success | 获取执行日志成功 | 返回分页结构 | P1 |

### 3.2 PromptServiceTest (S4-04)

| 用例ID | 测试方法 | 测试描述 | 预期结果 | 优先级 |
|:------:|----------|----------|----------|:------:|
| TC-S4-011 | getById_Success | 获取Prompt详情成功 | 返回正确Prompt | P0 |
| TC-S4-012 | getById_NotFound_ThrowsException | Prompt不存在 | BusinessException | P0 |
| TC-S4-013 | create_Success | 创建Prompt成功 | 状态=1(草稿), 版本=v1.0.0 | P0 |
| TC-S4-014 | create_DuplicateName_ThrowsException | Prompt名称重复 | BusinessException | P0 |
| TC-S4-015 | publish_Success | 发布Prompt成功 | 状态=2(已发布) | P0 |
| TC-S4-016 | publish_NotDraft_ThrowsException | 非草稿状态发布 | BusinessException | P0 |
| TC-S4-017 | archive_Success | 归档Prompt成功 | 状态=3(已归档) | P0 |
| TC-S4-018 | archive_NotPublished_ThrowsException | 非已发布状态归档 | BusinessException | P0 |
| TC-S4-019 | testPrompt_Success | 测试Prompt变量替换成功 | 变量已替换, 无{{}}残留 | P1 |
| TC-S4-020 | delete_Success | 删除Prompt及关联版本成功 | 调用两个Mapper的delete | P0 |

---

## 4. Sprint 5 测试用例

### 4.1 CatalogServiceTest (S5/S6-01)

| 用例ID | 测试方法 | 测试描述 | 预期结果 | 优先级 |
|:------:|----------|----------|----------|:------:|
| TC-S5-001 | getById_Success | 获取数据资产详情成功 | 返回正确资产 | P0 |
| TC-S5-002 | getById_NotFound_ThrowsException | 资产不存在 | BusinessException | P0 |
| TC-S5-003 | create_Success | 注册数据资产成功 | 状态=1(已注册), popularity=0 | P0 |
| TC-S5-004 | create_DuplicateCode_ThrowsException | 资产编码重复 | BusinessException | P0 |
| TC-S5-005 | publish_Success | 发布数据资产成功 | 状态=2(已发布) | P0 |
| TC-S5-006 | publish_NotRegistered_ThrowsException | 非已注册状态发布 | BusinessException | P0 |
| TC-S5-007 | deprecate_Success | 废弃数据资产成功 | 状态=3(已废弃) | P0 |
| TC-S5-008 | delete_Success | 删除数据资产成功 | 调用deleteById | P0 |
| TC-S5-009 | aiSearch_Success | AI智能搜索成功 | 返回keyword+aiSummary+suggestions | P1 |
| TC-S5-010 | getStatistics_Success | 获取统计概览成功 | 返回totalAssets+typeStats | P1 |
| TC-S5-011 | favorite_Success | 收藏资产热度+1 | popularity增加 | P1 |

---

## 5. Sprint 6 测试用例

### 5.1 MetadataServiceTest (S6-02)

| 用例ID | 测试方法 | 测试描述 | 预期结果 | 优先级 |
|:------:|----------|----------|----------|:------:|
| TC-S6-001 | getById_Success | 获取元数据详情成功 | 返回正确元数据 | P0 |
| TC-S6-002 | getById_NotFound_ThrowsException | 元数据不存在 | BusinessException | P0 |
| TC-S6-003 | createDataSource_Success | 注册数据源成功 | syncStatus=0(未同步) | P0 |
| TC-S6-004 | deleteDataSource_Success | 删除数据源及关联列元数据 | 两个Mapper均调用delete | P0 |
| TC-S6-005 | getColumns_Success | 获取列元数据列表成功 | 返回正确列列表 | P0 |
| TC-S6-006 | updateColumn_Success | 更新列业务元数据成功 | businessMeaning更新, aiCompleted=0 | P0 |
| TC-S6-007 | updateColumn_NotFound_ThrowsException | 列不存在 | BusinessException | P0 |
| TC-S6-008 | testConnection_Success | 测试数据源连接成功 | status=connected | P1 |
| TC-S6-009 | getStatistics_Success | 获取元数据统计成功 | 返回totalSources+typeStats | P1 |

---

## 6. 测试环境

| 环境项 | 配置 |
|--------|------|
| JDK | 17 |
| 构建工具 | Maven 3.9+ |
| 测试框架 | JUnit 5 (Jupiter) |
| Mock框架 | Mockito 5.x |
| 断言库 | AssertJ / JUnit5 Assertions |
| 覆盖率工具 | JaCoCo |
| CI环境 | GitHub Actions |

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-07 | 测试团队 | 初始版本，覆盖Sprint 3-6共92个测试用例 |
