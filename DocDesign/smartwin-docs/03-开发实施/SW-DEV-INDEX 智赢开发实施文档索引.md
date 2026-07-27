# 智赢(SmartWin) 开发实施文档索引

> **文档编号**: SW-DEV-INDEX  
> **版本**: V1.0  
> **创建日期**: 2026-07-12  
> **文档状态**: 正式发布

---

## 文档索引

| 编号 | 文档名称 | 路径 | 说明 |
|------|----------|------|------|
| DEV-01 | 编码规范 | `DocDesign/05-开发实施/` | 平台编码规范 |
| DEV-02 | 开发环境配置指南 | `DocDesign/05-开发实施/` | 平台开发环境 |
| DEV-06~19 | Sprint开发实施记录 | `DocDesign/05-开发实施/` | 各Sprint实施记录 |
| DEV-18 | 技术债务管理 | `DocDesign/05-开发实施/` | 平台技术债管理 |

## 智赢平台开发数据

| 指标 | 数值 |
|------|------|
| 共享微服务数 | 7 Java |
| 共享API端点数 | ~114 |
| 平台common模块数 | 13 |
| 运营推广微服务 | 1 Java (ops-service) |
| 运营推广API端点数 | ~60 |

## 平台common模块

| 模块 | 说明 |
|------|------|
| common-util | 通用工具(响应体/异常/i18n/Profile) |
| common-security | 安全(JWT/RBAC/零信任/限流) |
| common-crypto-gm | 国密算法(SM2/SM3/SM4/SM9) |
| common-db | 数据库配置(MyBatis-Plus) |
| common-db-multi | 多数据源(方言路由/分页/迁移) |
| common-db-rw | 读写分离(注解+AOP) |
| common-dm8 | 达梦数据库适配 |
| common-gateway | 网关配置(动态路由) |
| common-mq | 消息队列(RocketMQ) |
| common-storage | 对象存储(MinIO) |
| common-ai | AI引擎(多模态/私有模型) |
| common-test | 测试框架 |
| common-xinchuang | 信创环境适配 |

## 平台服务

| 服务 | 说明 |
|------|------|
| auth-service | 认证服务(JWT/OAuth2/RBAC) |
| system-service | 系统管理(用户/角色/字典/租户/计费) |
| security-service | 安全服务(策略/零信任) |
| audit-service | 审计服务(操作日志) |
| config-service | 配置服务(动态配置) |
| notification-service | 通知服务(邮件/短信/站内) |
| dashboard-service | 仪表盘服务(聚合/AI运维) |

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-12 | 架构组 | 初始版本 |
