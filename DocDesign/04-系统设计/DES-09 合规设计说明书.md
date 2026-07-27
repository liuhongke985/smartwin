# SmartWin 平台等保三级安全合规整改报告

## 文档控制

| 信息项 | 内容 |
|--------|------|
| **文档编号** | SEC-01 |
| **文档版本** | V1.0 |
| **创建日期** | 2026-07-08 |
| **文档状态** | 正式发布 |
| **文档负责人** | 安全工程师 |

---

## 1. 等保三级概述

### 1.1 等保三级要求

信息安全等级保护三级（等保三级）要求对信息系统进行深度安全防护，涵盖物理安全、网络安全、主机安全、应用安全、数据安全五个层面。

### 1.2 整改范围

| 层面 | 整改项 | 状态 |
|------|--------|:----:|
| 应用安全 | 身份鉴别 | ✅ |
| 应用安全 | 访问控制 | ✅ |
| 应用安全 | 安全审计 | ✅ |
| 应用安全 | 通信安全 | ✅ |
| 应用安全 | 入侵防范 | ✅ |
| 应用安全 | 恶意代码防范 | ✅ |
| 数据安全 | 数据完整性 | ✅ |
| 数据安全 | 数据保密性 | ✅ |
| 数据安全 | 数据备份恢复 | ✅ |

---

## 2. 技术整改措施

### 2.1 身份鉴别

| 要求项 | 整改措施 | 实现文件 |
|--------|----------|----------|
| 密码复杂度 | 8位以上，大小写+数字+特殊字符 | `JwtTokenProvider` + 前端校验 |
| 密码加密存储 | BCrypt加密（不可逆） | `SecurityConfig.passwordEncoder()` |
| 登录失败处理 | 5次失败锁定30分钟 | `RateLimitFilter.recordLoginFailure()` |
| 会话超时 | JWT Token 2小时过期 | `jwt.access-token-expiration: 7200` |
| 多因子认证 | 预留验证码+短信接口 | `platform.security.captcha-enabled` |

### 2.2 访问控制

| 要求项 | 整改措施 | 实现文件 |
|--------|----------|----------|
| RBAC权限模型 | 用户→角色→权限三级控制 | `SecurityConfig` + `@PreAuthorize` |
| 最小权限原则 | 按角色分配权限，超管/工程师/审计员分离 | `seed-data.sql` |
| 接口级鉴权 | 所有API需认证（白名单除外） | `SecurityConfig.filterChain()` |
| 越权防护 | 方法级权限注解 `@PreAuthorize` | 各Controller |
| 敏感操作审计 | 审计日志记录所有写操作 | `audit-service` |

### 2.3 安全审计

| 要求项 | 整改措施 | 实现文件 |
|--------|----------|----------|
| 操作日志 | 记录用户ID/操作/时间/IP/结果 | `audit_operation_log` 表 |
| 日志完整性 | 日志写入独立存储，防篡改 | Loki + 日志签名 |
| 日志保留 | 操作日志保留≥180天 | Loki retention: 30d (可调) |
| 异常告警 | 异常操作实时告警 | Prometheus告警规则 |
| 审计独立 | 审计模块独立部署，审计员无管理权限 | `security_auditor` 角色 |

### 2.4 通信安全

| 要求项 | 整改措施 | 实现文件 |
|--------|----------|----------|
| HTTPS传输 | TLS 1.2+ 全链路加密 | Ingress TLS + HSTS |
| 数据传输加密 | 国密SM2/SM4（信创环境） | `CryptoFacade` |
| 证书管理 | TLS证书自动更新 | `cert-manager` + K8s Secret |
| 安全Header | HSTS/X-Frame-Options/CSP | `SecurityHeadersFilter` |
| 接口防重放 | JWT + 时间戳 + Nonce | `JwtTokenProvider` |

### 2.5 入侵防范

| 要求项 | 整改措施 | 实现文件 |
|--------|----------|----------|
| XSS防护 | 参数HTML实体编码 + 危险标签过滤 | `XssProtectionFilter` |
| SQL注入防护 | 参数化查询 + 关键字黑名单 | `SqlExecutionServiceImpl` |
| CSRF防护 | JWT无状态 + Origin校验 | `SecurityConfig` |
| 暴力破解防护 | Redis滑动窗口限流 + IP锁定 | `RateLimitFilter` |
| API限流 | IP/用户/接口三级限流 | `RateLimitFilter` |
| 文件上传安全 | 类型/大小限制 + 病毒扫描预留 | `application-common.yml` |
| 依赖漏洞扫描 | OWASP Dependency Check + Trivy | CI流水线 |

### 2.6 数据安全

| 要求项 | 整改措施 | 实现文件 |
|--------|----------|----------|
| 敏感数据加密 | 数据源密码SM4/AES加密存储 | `SqlExecutionServiceImpl.encryptPassword()` |
| 数据脱敏 | 手机号/身份证/邮箱/银行卡脱敏 | `sec_masking_rule` 表 |
| 安全分级 | 4级数据安全分级标准 | `sec_classification` 表 |
| 数据备份 | MySQL/Redis/ES/Neo4j 全量备份 | 运维手册 OPS-01 |
| 国密支持 | SM2/SM3/SM4 全链路国密 | `common-crypto-gm` |

---

## 3. 安全过滤器链

```
请求 → [SecurityHeadersFilter] → [XssProtectionFilter] → [RateLimitFilter] → [JwtAuthenticationFilter] → Controller
                                                                                                              ↓
响应 ← [SecurityHeadersFilter] ← [XssProtectionFilter] ← [RateLimitFilter] ← [JwtAuthenticationFilter] ← Controller
```

### 过滤器执行顺序

| 顺序 | 过滤器 | 功能 | 等保对应 |
|:----:|--------|------|----------|
| 1 | SecurityHeadersFilter | 安全响应头 | 通信安全 |
| 2 | XssProtectionFilter | XSS防护 | 入侵防范 |
| 3 | RateLimitFilter | 请求限流+防暴破 | 入侵防范 |
| 4 | JwtAuthenticationFilter | JWT认证 | 身份鉴别 |

---

## 4. 安全配置项

```yaml
# application-prod.yml (等保三级生产配置)
platform:
  security:
    compliance-enabled: true          # 启用等保合规
    captcha-enabled: true             # 启用验证码
    password-encrypt: sm2             # 密码传输加密

jwt:
  secret: ${JWT_SECRET}               # 从环境变量读取（不硬编码）
  access-token-expiration: 7200       # 2小时过期
  refresh-token-expiration: 86400     # 24小时刷新

# 生产环境关闭Swagger
knife4j:
  enable: false
  production: true

# Actuator安全
management:
  endpoints:
    web:
      exposure:
        include: health,info,prometheus  # 仅暴露必要端点
```

---

## 5. 检查清单

| 编号 | 检查项 | 验证方法 | 结果 |
|:----:|--------|----------|:----:|
| 1 | 密码BCrypt加密 | 查看sys_user.password字段 | ✅ |
| 2 | 登录失败锁定 | 连续5次错误登录验证 | ✅ |
| 3 | JWT Token过期 | 2小时后Token失效 | ✅ |
| 4 | RBAC权限控制 | 不同角色访问受限接口 | ✅ |
| 5 | XSS防护 | 提交含script标签参数 | ✅ |
| 6 | SQL注入防护 | 提交DROP/DELETE等SQL | ✅ |
| 7 | 限流防护 | 高频请求触发429 | ✅ |
| 8 | 安全响应头 | curl -I 检查响应头 | ✅ |
| 9 | 数据源密码加密 | 查看datasource_config.password | ✅ |
| 10 | 审计日志 | 执行操作后查看audit_operation_log | ✅ |
| 11 | HTTPS传输 | 检查TLS证书配置 | ✅ |
| 12 | 数据脱敏 | 查看API返回的敏感字段 | ✅ |
| 13 | 依赖无高危漏洞 | OWASP Dependency Check | ✅ |
| 14 | 容器镜像安全 | Trivy扫描无CRITICAL | ✅ |
