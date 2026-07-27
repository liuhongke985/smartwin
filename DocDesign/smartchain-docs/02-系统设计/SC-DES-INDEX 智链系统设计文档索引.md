# 智链(SmartChain) 系统设计文档索引

> **文档编号**: SC-DES-INDEX  
> **版本**: V1.0  
> **创建日期**: 2026-07-12  
> **文档状态**: 正式发布

---

## 文档索引

智链系统的系统设计文档分布在 DocDesign 主目录中，以下为关联索引：

| 编号 | 文档名称 | 路径 | 说明 |
|------|----------|------|------|
| DES-01 | 系统架构设计说明书 | `DocDesign/04-系统设计/` | 包含智链微服务架构设计 |
| DES-02 | 接口设计说明书 | `DocDesign/04-系统设计/` | 包含智链API接口设计 |
| DES-03 | 数据库设计说明书 | `DocDesign/04-系统设计/` | 包含智链数据库表设计 |
| DES-05 | 安全架构设计说明书 | `DocDesign/04-系统设计/` | JWT认证+RBAC权限设计 |
| DES-06 | 前端架构设计说明书 | `DocDesign/04-系统设计/` | Vue 3 + TypeScript架构 |
| DES-15 | 架构决策记录ADR | `DocDesign/04-系统设计/` | 智链相关架构决策 |
| DES-16 | 运营中心架构决策分析 | `DocDesign/04-系统设计/` | 运营中心架构归属决策 |

## 智链系统架构概要

### 微服务清单

| 服务 | 端口 | 说明 |
|------|------|------|
| model-service | 8083 | AI模型管理 |
| app-service | 8084 | 智能体应用 |
| agent-service | — | Agent编排 |
| cost-service | 8085 | 成本管控 |
| risk-service | 8086 | 风险评估 |
| prompt-service | — | 提示词管理 |

### 前端页面清单(69个)

- 工作台: Overview / CallTrends / CostDashboard / RiskDashboard
- AI模型管理: List / Create / Detail / Compare / Stats / Versions / ApiKeys / Test
- 智能体应用: List / Create / Detail / Chat / Publish / Stats / Settings / Categories / Favorites
- Agent编排: List / Create / Detail / Tools / Flow / Logs / Versions
- 成本管理: Overview / Records / Budgets / Alerts / Reports / Analysis
- 风险评估: Overview / Rules / Events / Reports / Handle / Trends
- 提示词管理: Library / Editor / Versions / Test / Categories
- 系统管理: Users / Roles / Permissions / Orgs / Dicts / Logs / Settings / Changelog
- 内容营销: Blog / BlogDetail / CaseStudy / Landing / Register / Status / ApiDocs / Company / En

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-12 | 架构组 | 初始版本 |
