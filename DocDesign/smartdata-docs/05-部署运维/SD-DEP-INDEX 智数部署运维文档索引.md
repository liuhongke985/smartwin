# 智数(SmartData) 部署运维文档索引

> **文档编号**: SD-DEP-INDEX  
> **版本**: V1.0  
> **创建日期**: 2026-07-12  
> **文档状态**: 正式发布

---

## 文档索引

| 编号 | 文档名称 | 路径 | 说明 |
|------|----------|------|------|
| DEP-01 | 部署方案 | `DocDesign/07-部署上线/` | 含智数部署方案 |
| DEP-03 | 生产环境部署手册 | `DocDesign/07-部署上线/` | 智数生产部署 |
| DEP-05 | 用户手册 | `DocDesign/07-部署上线/` | 智数用户操作指南 |
| REL-01 | 版本发布说明 | `DocDesign/07-部署上线/` | V1.0.0发布说明 |
| CM-01 | 配置管理计划 | `DocDesign/07-部署上线/` | 智数配置管理 |
| IVR-01 | 安装验证报告 | `DocDesign/07-部署上线/` | 智数安装验证 |
| DRC-01 | 业务连续性与灾备方案 | `DocDesign/15-灾备连续性/` | 灾备方案 |
| MAINT-01 | 系统升级维护与巡检强化手册 | `DocDesign/18-系统维护/` | 维护手册 |

## 智数部署架构

### 微服务清单

| 服务 | 说明 | 数据库依赖 |
|------|------|-----------|
| catalog-service | 数据目录 | MySQL + Elasticsearch |
| metadata-service | 元数据管理 | MySQL |
| lineage-service | 数据血缘 | Neo4j + MySQL |
| quality-service | 数据质量 | MySQL |
| standard-service | 数据标准 | MySQL |
| mdm-service | 主数据管理 | MySQL |
| lifecycle-service | 数据生命周期 | MySQL |
| data-service | 数据服务 | MySQL |
| asset-service | 资产管理 | MySQL |

### 独立部署模式

智数支持独立部署（`application-sd.yml` profile），不依赖智链服务。

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-12 | DevOps | 初始版本 |
