# ADR-004: 认证与授权方案

## 状态
已接受 (Accepted)

## 日期
2026-02-01

## 背景与问题陈述

SmartWin 是一个多租户企业级平台，需要：
- 支持多种认证方式（用户名密码、SSO、OAuth）
- 细粒度的权限控制（资源级别）
- 安全的Token管理
- 审计日志

## 考察的方案

### 方案A: 自研认证系统
**优点:** 完全自控
**缺点:** 开发成本高，安全风险大，不推荐

### 方案B: Keycloak [推荐]
**优点:**
- 企业级成熟方案，安全经过验证
- 支持OAuth 2.0 / OIDC / SAML
- 内置用户管理、SSO、社交登录
- 丰富的定制能力

**缺点:**
- 引入新的基础设施组件
- 需要额外运维

### 方案C: Auth0 / Okta (SaaS)
**优点:** 免运维
**缺点:** 数据出境合规问题，成本较高

## 决策结果

**选择方案B: Keycloak**

## 认证架构

```
客户端
  │
  ▼
API Gateway (Spring Cloud Gateway)
  │── Token验证 (调用Keycloak introspection)
  │── 路由到对应服务
  │
  ▼
业务服务
  │── 从JWT提取用户信息
  │── RBAC权限检查 (@PreAuthorize)
  │
  ▼
Keycloak (身份提供者)
  │── 用户存储
  │── Token签发/验证
  │── SSO会话管理
```

## JWT Token设计

### Access Token (短期, 1小时)
```json
{
  "sub": "user-uuid",
  "name": "张三",
  "email": "zhangsan@example.com",
  "roles": ["ROLE_DATA_ANALYST"],
  "permissions": ["data:read", "asset:create"],
  "tenant_id": "org-001",
  "iat": 1706745600,
  "exp": 1706749200
}
```

### Refresh Token (长期, 30天)
- 存储在 HttpOnly Cookie
- 服务器端维护黑名单

## RBAC权限模型

### 角色定义

| 角色 | 权限范围 |
|------|---------|
| SUPER_ADMIN | 平台全部权限 |
| ORG_ADMIN | 组织内所有权限 |
| DATA_MANAGER | 数据资产管理权限 |
| DATA_ANALYST | 数据查询和分析权限 |
| AI_OPERATOR | AI链操作权限 |
| VIEWER | 只读查看权限 |

### 权限命名规范
格式: `{resource}:{action}`

```
data:read, data:write, data:delete
asset:create, asset:update, asset:delete
ai:execute, ai:manage
admin:users, admin:roles
```

### Spring Security集成
```java
@PreAuthorize("hasAuthority('data:write')")
public DataAsset createDataAsset(DataAssetRequest request) { ... }

@PostAuthorize("returnObject.ownerId == authentication.name")
public DataAsset getDataAsset(Long id) { ... }
```

## 安全措施

### Token安全
- Access Token 1小时过期，减少泄露风险
- Refresh Token 存 HttpOnly Cookie，防止XSS
- Token Rotation: 每次刷新生成新Refresh Token

### API安全
- 所有API强制HTTPS
- 速率限制 (Rate Limiting) 在网关层实现
- CORS配置白名单

### 审计日志
- 所有认证事件记录（登录、登出、Token刷新）
- 权限拒绝事件记录
- 敏感操作记录（删除、批量操作）

## 结果与影响

**正面影响:**
- 安全性由专业产品保障
- 开发团队专注业务逻辑
- 标准协议，易于集成第三方系统

**负面影响:**
- Keycloak资源消耗较大（最低512MB内存）
- 增加一个需要运维的组件

**缓解:**
- 开发/测试环境使用精简配置
- 生产环境Keycloak高可用部署
- 完整的Keycloak运维文档
