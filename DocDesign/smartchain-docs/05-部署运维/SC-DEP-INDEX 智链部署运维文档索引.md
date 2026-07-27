# 智链(SmartChain) 部署运维文档索引

> **文档编号**: SC-DEP-INDEX  
> **版本**: V1.0  
> **创建日期**: 2026-07-12  
> **文档状态**: 正式发布

---

## 文档索引

| 编号 | 文档名称 | 路径 | 说明 |
|------|----------|------|------|
| DEP-01 | 部署方案 | `DocDesign/07-部署上线/` | 含智链部署方案 |
| DEP-03 | 生产环境部署手册 | `DocDesign/07-部署上线/` | 智链生产部署步骤 |
| DEP-05 | 用户手册 | `DocDesign/07-部署上线/` | 智链用户操作指南 |
| DEP-06 | 管理员手册 | `DocDesign/07-部署上线/` | 智链管理员操作 |
| REL-01 | 版本发布说明 | `DocDesign/07-部署上线/` | V1.0.0发布说明 |
| CM-01 | 配置管理计划 | `DocDesign/07-部署上线/` | 智链配置管理 |
| IVR-01 | 安装验证报告 | `DocDesign/07-部署上线/` | 智链安装验证 |
| OPS-01 | 运维手册 | `DocDesign/08-运维运营/` | 智链运维操作 |

## 智链部署架构

### Docker部署

```bash
docker-compose -f infra/docker/docker-compose.yml up -d
```

### K8s部署

```bash
helm install smartchain infra/helm/ -f infra/helm/values.yaml
```

### 服务端口

| 服务 | 端口 | 健康检查 |
|------|------|----------|
| model-service | 8083 | /actuator/health |
| app-service | 8084 | /actuator/health |
| cost-service | 8085 | /actuator/health |
| risk-service | 8086 | /actuator/health |
| ai-engine | 8000 | /health |
| frontend | 3000 | HTTP 200 |

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-12 | DevOps | 初始版本 |
