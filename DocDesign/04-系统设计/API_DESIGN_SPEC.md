# SmartWin API 设计规范

> **版本**: 1.0 | **日期**: 2026-07-27
>
> 定义了 SmartWin 全栈应用的 API 设计标准，确保 API 的一致性、易用性和可维护性

---

## 📋 API 设计原则

1. **RESTful 规范** - 遵循 REST 最佳实践
2. **版本管理** - 支持 API 版本控制
3. **错误处理** - 统一的错误响应格式
4. **文档完善** - 使用 OpenAPI/Swagger 自动生成文档
5. **安全性** - 完整的认证、授权和审计
6. **可扩展性** - 支持分页、排序、过滤等常见操作
7. **性能** - 合理的缓存策略和响应体大小

---

## 🔗 URL 规范

### 基础 URL 格式

```
https://api.smartwin.io/api/v1/resource
        ↓              ↓    ↓   ↓
      域名           基础路径 版本 资源
```

### 资源命名

```yaml
复数形式:
  ✅ /api/v1/users              # 用户集合
  ✅ /api/v1/data-sources       # 数据源集合
  ✅ /api/v1/quality-rules      # 质量规则集合
  ❌ /api/v1/user               # 不要用单数
  ❌ /api/v1/User               # 不要用大写

层级关系:
  ✅ /api/v1/users/{id}/roles              # 用户的角色
  ✅ /api/v1/models/{id}/metrics           # 模型的指标
  ✅ /api/v1/projects/{id}/datasets        # 项目的数据集
  ❌ /api/v1/users/{id}/get-roles          # 不要在 URL 中写动词

复杂资源:
  /api/v1/quality-rules/{id}/execute       # 执行质量规则
  /api/v1/models/{id}/deploy               # 部署模型
  /api/v1/datasets/{id}/export              # 导出数据集
```

---

## 📝 HTTP 方法

| 方法 | 用途 | 幂等性 | 示例 |
|------|------|--------|------|
| GET | 获取资源 | 是 | `GET /api/v1/users/{id}` |
| POST | 创建资源 | 否 | `POST /api/v1/users` |
| PUT | 完整更新资源 | 是 | `PUT /api/v1/users/{id}` |
| PATCH | 部分更新资源 | 是 | `PATCH /api/v1/users/{id}` |
| DELETE | 删除资源 | 是 | `DELETE /api/v1/users/{id}` |

### 方法使用规则

```yaml
GET:
  - 用于获取单个资源或资源集合
  - 不修改服务器状态
  - 例: GET /api/v1/users, GET /api/v1/users/{id}

POST:
  - 用于创建新资源
  - 不是幂等的
  - 例: POST /api/v1/users (创建用户)
  - 例: POST /api/v1/users/{id}/export (执行导出操作)

PUT:
  - 用于完整替换资源
  - 幂等的 (调用多次结果相同)
  - 需要提供完整的资源体
  - 例: PUT /api/v1/users/{id}

PATCH:
  - 用于部分更新资源
  - 幂等的
  - 只需提供要修改的字段
  - 例: PATCH /api/v1/users/{id} (只更新 email)

DELETE:
  - 用于删除资源
  - 幂等的
  - 例: DELETE /api/v1/users/{id}
```

---

## 📊 响应格式

### 成功响应 (2xx)

```json
{
  "code": 200,
  "message": "Success",
  "data": {
    "id": "123",
    "username": "john",
    "email": "john@example.com"
  },
  "timestamp": "2026-07-27T10:30:00Z"
}
```

### 分页响应

```json
{
  "code": 200,
  "message": "Success",
  "data": {
    "items": [
      { "id": "1", "username": "user1" },
      { "id": "2", "username": "user2" }
    ],
    "pagination": {
      "page": 1,
      "pageSize": 20,
      "total": 100,
      "totalPages": 5
    }
  },
  "timestamp": "2026-07-27T10:30:00Z"
}
```

### 错误响应 (4xx, 5xx)

```json
{
  "code": 400,
  "message": "Invalid request parameter",
  "error": {
    "type": "ValidationException",
    "details": [
      {
        "field": "username",
        "message": "Username is required",
        "value": null
      }
    ]
  },
  "traceId": "abc123def456",
  "timestamp": "2026-07-27T10:30:00Z"
}
```

### HTTP 状态码

```yaml
2xx 成功:
  200 OK: 请求成功
  201 Created: 资源创建成功
  202 Accepted: 请求已接受（异步操作）
  204 No Content: 成功但无返回内容

3xx 重定向:
  301 Moved Permanently: 永久重定向
  302 Found: 临时重定向
  304 Not Modified: 缓存命中

4xx 客户端错误:
  400 Bad Request: 请求参数错误
  401 Unauthorized: 未认证
  403 Forbidden: 无权限
  404 Not Found: 资源不存在
  409 Conflict: 资源冲突（如重复创建）
  429 Too Many Requests: 请求过频

5xx 服务器错误:
  500 Internal Server Error: 服务器内部错误
  502 Bad Gateway: 网关错误
  503 Service Unavailable: 服务不可用
```

---

## 🔑 请求参数

### 参数位置规则

```yaml
Path Parameters:
  位置: URL 路径中
  使用: 标识资源
  例: /api/v1/users/{id}, /api/v1/users/{id}/roles/{roleId}

Query Parameters:
  位置: URL 查询字符串
  使用: 过滤、分页、排序
  例: GET /api/v1/users?page=1&pageSize=20&status=active

Request Body:
  位置: HTTP 请求体
  使用: 创建或更新资源
  例: POST /api/v1/users (JSON 体)

Request Headers:
  位置: HTTP 请求头
  使用: 认证、内容类型、追踪信息
  例: Authorization, Content-Type, X-Trace-Id
```

### 通用查询参数

```yaml
分页:
  page: 页码 (从 1 开始), 默认 1
  pageSize: 每页数量, 默认 20, 最大 100
  例: GET /api/v1/users?page=2&pageSize=50

排序:
  sort: 排序字段, 格式 "field1:asc,field2:desc"
  例: GET /api/v1/users?sort=createdAt:desc,username:asc

过滤:
  filter: 过滤条件, 格式 "field:operator:value"
  例: GET /api/v1/users?filter=status:eq:active,age:gt:18

字段选择:
  fields: 返回的字段, 逗号分隔
  例: GET /api/v1/users/{id}?fields=id,username,email

搜索:
  search: 全文搜索关键词
  例: GET /api/v1/users?search=john
```

---

## 🔐 认证与授权

### 认证方式: JWT

```yaml
流程:
  1. 客户端发送 POST /api/v1/auth/login (用户名+密码)
  2. 服务器返回 JWT token 和刷新令牌
  3. 客户端将 token 存储到 localStorage
  4. 后续请求在 Authorization 头中携带 token

请求头格式:
  Authorization: Bearer <token>
  例: Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

令牌有效期:
  访问令牌 (Access Token): 1 小时
  刷新令牌 (Refresh Token): 7 天
  
刷新令牌:
  POST /api/v1/auth/refresh
  Request: {"refreshToken": "xxx"}
  Response: {"accessToken": "xxx", "refreshToken": "xxx"}
```

### 权限检查

```yaml
角色级别:
  ADMIN: 系统管理员
  MANAGER: 数据管理者
  ANALYST: 数据分析师
  VIEWER: 数据查看者

API 权限:
  创建资源: >= MANAGER
  修改资源: >= MANAGER
  删除资源: >= ADMIN
  查看资源: >= VIEWER
  
字段级权限:
  敏感字段 (salary, idCard): ADMIN 或所有者
  个人信息 (email, phone): 本人或 ADMIN
  公开字段 (name, title): 所有认证用户
```

---

## 📋 API 文档示例

### 数据治理 API

#### 1. 获取数据源列表

```yaml
GET /api/v1/data-sources

描述: 获取所有已配置的数据源

权限: VIEWER

查询参数:
  page: 页码 (可选, 默认 1)
  pageSize: 每页数量 (可选, 默认 20)
  search: 搜索关键词 (可选)
  sort: 排序字段 (可选, 默认 createdAt:desc)

成功响应 (200):
  {
    "code": 200,
    "message": "Success",
    "data": {
      "items": [
        {
          "id": "ds-001",
          "name": "MySQL-Production",
          "type": "mysql",
          "status": "connected",
          "createdAt": "2026-07-27T10:00:00Z"
        }
      ],
      "pagination": {
        "page": 1,
        "pageSize": 20,
        "total": 5,
        "totalPages": 1
      }
    }
  }

错误响应 (401):
  {
    "code": 401,
    "message": "Unauthorized",
    "error": {
      "type": "AuthenticationException",
      "details": []
    }
  }
```

#### 2. 创建数据源

```yaml
POST /api/v1/data-sources

描述: 创建新的数据源连接

权限: MANAGER

请求体:
  {
    "name": "MySQL-Production",
    "type": "mysql",
    "host": "192.168.1.100",
    "port": 3306,
    "database": "smartwin",
    "username": "root",
    "password": "encrypted_password",
    "testConnection": true
  }

成功响应 (201):
  {
    "code": 201,
    "message": "Created",
    "data": {
      "id": "ds-001",
      "name": "MySQL-Production",
      "type": "mysql",
      "status": "connected",
      "createdAt": "2026-07-27T10:00:00Z"
    }
  }

验证错误 (400):
  {
    "code": 400,
    "message": "Invalid request",
    "error": {
      "type": "ValidationException",
      "details": [
        {
          "field": "host",
          "message": "Host is required"
        }
      ]
    }
  }
```

#### 3. 执行数据质量检查

```yaml
POST /api/v1/quality-checks/execute

描述: 异步执行数据质量检查

权限: ANALYST

请求体:
  {
    "dataSourceId": "ds-001",
    "database": "smartwin",
    "tables": ["users", "orders"],
    "ruleIds": ["rule-001", "rule-002"],
    "executeNow": true
  }

成功响应 (202 Accepted):
  {
    "code": 202,
    "message": "Task accepted",
    "data": {
      "taskId": "task-abc123",
      "status": "PENDING",
      "statusUrl": "/api/v1/quality-checks/task-abc123",
      "createdAt": "2026-07-27T10:00:00Z"
    }
  }

查询任务状态:
  GET /api/v1/quality-checks/tasks/{taskId}
  
  响应 (200):
    {
      "code": 200,
      "message": "Success",
      "data": {
        "taskId": "task-abc123",
        "status": "COMPLETED",
        "progress": 100,
        "results": {
          "totalRecords": 10000,
          "validRecords": 9950,
          "invalidRecords": 50,
          "issues": [...]
        },
        "completedAt": "2026-07-27T10:05:00Z"
      }
    }
```

---

## 🎯 速率限制

```yaml
限制规则:
  默认: 1000 请求/小时/用户
  高级: 10000 请求/小时/用户
  
响应头:
  X-RateLimit-Limit: 1000
  X-RateLimit-Remaining: 999
  X-RateLimit-Reset: 1626000000

超限响应 (429):
  {
    "code": 429,
    "message": "Too Many Requests",
    "retryAfter": 60
  }
```

---

## 📈 监控与追踪

```yaml
追踪头:
  X-Trace-Id: 唯一请求追踪 ID
  X-Request-Id: 请求 ID
  X-Correlation-Id: 关联 ID (用于追踪链路)

日志示例:
  2026-07-27 10:30:00.123 | X-Trace-Id: abc123 | GET /api/v1/users | 200 | 45ms

性能指标:
  响应时间: P50 < 100ms, P99 < 500ms
  可用性: >= 99.9%
  错误率: < 0.1%
```

---

**版本**: 1.0.0 | **更新**: 2026-07-27 | **维护者**: @liuhongke985