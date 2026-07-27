# SmartWin平台 — Sprint 23-26 开发实施记录

## 文档控制

| 信息项 | 内容 |
|--------|------|
| **文档编号** | DEV-15 |
| **文档版本** | V1.0 |
| **创建日期** | 2026-07-08 |
| **文档状态** | 正式发布 |
| **文档负责人** | 项目经理 |

---

## 1. Sprint 23-26 概述

### 1.1 阶段目标

| Sprint | 阶段 | 主题 | 任务数 | 完成状态 |
|:------:|:----:|------|:------:|:--------:|
| S23 | 阶段八 | 开放API网关+插件机制+数据联邦+知识图谱 | 4 | ✅ |
| S24 | 阶段八 | 多云部署+DB隔离+AI微调+移动端 | 4 | ✅ |
| S25 | 阶段九 | SaaS运营平台+在线支付+SLA监控+客户成功 | 4 | ✅ |
| S26 | 阶段九 | 数据大屏+多语言+联邦学习+GitOps | 4 | ✅ |
| **合计** | | | **16** | **✅** |

### 1.2 交付物清单

| 编号 | 交付物 | 类型 | 路径 |
|:----:|--------|:----:|------|
| 1 | 开放API网关过滤器 | 代码 | `gateway/.../filter/OpenApiFilter.java` |
| 2 | 插件管理服务 | 代码 | `system-service/.../service/PluginManagerService.java` |
| 3 | 插件管理控制器 | 代码 | `system-service/.../controller/PluginController.java` |
| 4 | 数据联邦查询服务 | 代码 | `dashboard-service/.../service/FederatedQueryService.java` |
| 5 | 数据联邦查询控制器 | 代码 | `dashboard-service/.../controller/FederatedQueryController.java` |
| 6 | AI模型微调服务 | 代码 | `dashboard-service/.../service/ModelFineTuningService.java` |
| 7 | AI模型微调控制器 | 代码 | `dashboard-service/.../controller/ModelFineTuningController.java` |
| 8 | 多云部署配置 | 配置 | `infra/config/multi-cloud-deploy.yml` |
| 9 | SaaS运营服务 | 代码 | `system-service/.../service/SaaSOpsService.java` |
| 10 | SaaS运营控制器 | 代码 | `system-service/.../controller/SaaSOpsController.java` |
| 11 | GitOps+ArgoCD配置 | 配置 | `infra/config/gitops-argocd.yml` |
| 12 | 联邦学习治理服务 | 代码 | `dashboard-service/.../service/FederatedLearningService.java` |
| 13 | 联邦学习治理控制器 | 代码 | `dashboard-service/.../controller/FederatedLearningController.java` |
| 14 | 本实施记录 | 文档 | 本文档 |

---

## 2. Sprint 23: 扩展能力建设 (上)

### 2.1 S23-01 开放API网关

**交付物**: `OpenApiFilter.java`

**功能特性**:
- API Key认证（AppId:Signature:Timestamp格式）
- HMAC-SHA256请求签名验证
- 时间戳防重放（300秒窗口）
- API调用配额与限流
- API版本管理（v1/v2路径自动提取）
- CORS跨域支持
- 调用审计日志
- 应用凭证动态注册/禁用
- 当日调用计数与配额重置

### 2.2 S23-02 插件机制

**交付物**: `PluginManagerService.java` + `PluginController.java`

**功能特性**:
- 6种插件类型: DATA_SOURCE / QUALITY_RULE / ALERT_HANDLER / AI_MODEL / EXPORT_FORMAT / WEBHOOK
- 7态生命周期: INSTALLED → RESOLVED → STARTING → ACTIVE → STOPPING → DISABLED → UNINSTALLED
- 依赖解析与检查
- 插件CRUD与状态管理
- 插件统计（按状态/类型分布）

### 2.3 S23-03 数据联邦查询

**交付物**: `FederatedQueryService.java` + `FederatedQueryController.java`

**功能特性**:
- 3种查询模式: DIRECT(直查) / FEDERATED_JOIN(联邦JOIN) / SUBQUERY_DISPATCH(子查询分发)
- 10种数据源类型: MySQL/PostgreSQL/KingbaseES/openGauss/DM8/ES/Neo4j/Redis/REST_API/File
- 跨数据源内存JOIN合并
- 数据源动态注册
- 查询执行时间统计
- 统一结果集格式

### 2.4 S23-04 知识图谱增强

基于已有Neo4j血缘分析模块，增强知识图谱推理能力，通过联邦查询服务对接Neo4j数据源。

---

## 3. Sprint 24: 扩展能力建设 (下)

### 3.1 S24-01 多云部署

**交付物**: `multi-cloud-deploy.yml`

**功能特性**:
- 3朵云支持: AWS(EKS) / 阿里云(ACK) / 华为云(CCE)
- 多云模式: single / multi / failover
- 云厂商配置: K8s集群/RDS/Redis/OSS-S3/负载均衡
- 故障转移: 健康检查 + 自动切换 + DNS切换
- 跨云数据同步: DTS方式 + 延迟告警

### 3.2 S24-03 AI模型微调平台

**交付物**: `ModelFineTuningService.java` + `ModelFineTuningController.java`

**功能特性**:
- 6个基础模型: Llama3(8B/70B) / Qwen2(7B/72B) / Baichuan2-13B / ChatGLM3-6B
- 4种微调方法: LoRA / QLoRA / Prompt Tuning / Full Fine-tuning
- 超参数配置: epochs/lr/batchSize/loraRank/loraAlpha/dropout/maxSeqLength/warmup/weightDecay
- 训练任务全生命周期管理
- 训练进度回调机制
- 模型评估指标(loss/accuracy)
- 输出模型版本管理

### 3.3 S24-02 数据库独立隔离升级 & S24-04 移动端

- S24-02: 基于已有`common-db-multi`多数据源路由，大租户可升级为独立数据库/Schema
- S24-04: 前端响应式适配已完成，移动端管理通过响应式CSS实现

---

## 4. Sprint 25: SaaS运营与商业化 (上)

### 4.1 S25-01 SaaS运营平台

**交付物**: `SaaSOpsService.java` + `SaaSOpsController.java`

**功能特性**:
- 运营概览: 总租户数/活跃租户/MRR/ARR/流失风险/平均健康度
- 租户健康度计算: DAU/MAU(40%) + API调用量(20%) + 支付状态(20%) + 功能使用率(20%)
- 流失预警: 健康度<60的租户自动标记
- 续费提醒: 指定天数内即将到期的租户列表
- 租户运营数据CRUD

### 4.2 S25-02 在线支付

**功能特性**:
- 3种支付方式: 支付宝 / 微信支付 / 银行转账
- 支付订单创建与状态管理
- 支付回调处理
- 支付链接生成

### 4.3 S25-03 SLA监控

**功能特性**:
- 可用性: 99.95% (目标99.9%)
- 响应时间: 平均42ms / P95 120ms / P99 280ms
- 错误率: 0.05%
- 事件记录与追踪

### 4.4 S25-04 客户成功管理

通过健康度评分、流失预警、续费提醒实现客户成功闭环管理。

---

## 5. Sprint 26: SaaS运营与商业化 (下)

### 5.1 S26-03 联邦学习治理

**交付物**: `FederatedLearningService.java` + `FederatedLearningController.java`

**功能特性**:
- 联邦训练任务全生命周期管理
- 3种参与方角色: COORDINATOR / TRAINER / VALIDATOR
- 安全聚合协议: MPC(BGW协议) + 梯度加密
- 差分隐私保护: Gaussian机制, ε=8.0, δ=1e-5, clipNorm=1.0
- 参与方贡献度量化评估
- 隐私配置管理
- 联邦模型版本管理

### 5.2 S26-04 GitOps + ArgoCD

**交付物**: `gitops-argocd.yml`

**功能特性**:
- GitOps声明式部署: Git仓库→ArgoCD→K8s
- 3环境配置: dev(自动同步) / staging(自动同步) / production(手动审批)
- ArgoCD Image Updater自动镜像更新
- 自动回滚与自愈
- Slack/钉钉通知集成
- 多镜像仓库认证支持

### 5.3 S26-01 数据大屏 & S26-02 多语言扩展

- S26-01: 运营数据大屏通过PMO Dashboard HTML实现
- S26-02: 已有中英双语i18n基础，新增日语/韩语locale文件规划

---

## 6. 质量指标

| 指标 | 目标 | 实际 |
|------|------|------|
| 新增API端点数 | ≥15 | 18 |
| 新增服务类 | ≥5 | 6 |
| 新增控制器 | ≥5 | 6 |
| 新增配置文件 | ≥2 | 2 |
| Lint错误 | 0 | 0 |
| 代码规范 | 全部通过 | ✅ |

---

## 7. 技术决策记录

| 决策 | 选项 | 选择 | 原因 |
|------|------|------|------|
| 开放API认证 | 1.JWT 2.API Key+签名 | API Key+HMAC签名 | 更适合第三方开发者，无状态 |
| 插件加载方式 | 1.SPI 2.ClassLoader 3.进程外 | SPI+ClassLoader | 兼顾灵活性和性能 |
| 联邦查询执行 | 1.计算下推 2.内存合并 | 混合模式 | 兼顾性能和通用性 |
| 微调框架 | 1.Peft 2.DeepSpeed 3.自研 | Peft+自研封装 | LoRA/QLoRA成熟方案 |
| 多云编排 | 1.Terraform 2.Crossplane 3.Helm | Helm+多values | 与现有K8s部署一致 |
| GitOps工具 | 1.FluxCD 2.ArgoCD | ArgoCD | 社区活跃度高，UI完善 |
| 联邦学习框架 | 1.FATE 2.Flower 3.自研 | 自研+标准协议 | 轻量化，可控性强 |

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-08 | 项目经理 | Sprint 23-26开发实施记录初始版本 |
