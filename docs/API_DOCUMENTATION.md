# SmartWin API 文档

## 文档信息
- **版本**: 1.0.0
- **Base URL**: `https://api.smartwin.example.com/api/v1`
- **认证**: ****** (JWT)

---

## 目录
1. [认证](#1-认证)
2. [数据资产 API](#2-数据资产-api)
3. [数据质量 API](#3-数据质量-api)
4. [AI协同链 API](#4-ai协同链-api)
5. [错误码说明](#5-错误码说明)

---

## 1. 认证

所有API请求需要在Header中携带******

```
Authorization: ******
```

### 获取Token

```
POST /auth/token
Content-Type: application/json

{
  "username": "user@example.com",
  "password": "your_password"
}
```

**Response:**
```json
{
  "access_token": "eyJhbGci...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "refresh_token": "dGhpcyBp..."
}
```

---

## 2. 数据资产 API

### 2.1 获取数据资产列表

```
GET /data-assets
```

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | integer | 否 | 页码，默认1 |
| pageSize | integer | 否 | 每页数量，默认20，最大100 |
| keyword | string | 否 | 搜索关键词 |
| status | string | 否 | 状态过滤: active/inactive |
| category | string | 否 | 分类过滤 |

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": 150,
    "page": 1,
    "pageSize": 20,
    "items": [
      {
        "id": 1,
        "name": "用户行为数据集",
        "description": "记录用户在平台上的行为数据",
        "category": "user_data",
        "status": "active",
        "owner": "data_team",
        "qualityScore": 95.5,
        "createdAt": "2026-01-01T08:00:00Z",
        "updatedAt": "2026-06-01T10:00:00Z"
      }
    ]
  }
}
```

### 2.2 获取数据资产详情

```
GET /data-assets/{id}
```

**路径参数:**
- `id`: 数据资产ID (integer)

**响应示例:**
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "name": "用户行为数据集",
    "description": "详细描述...",
    "schema": {
      "fields": [
        {"name": "user_id", "type": "BIGINT", "nullable": false},
        {"name": "event_type", "type": "VARCHAR(50)", "nullable": false},
        {"name": "created_at", "type": "TIMESTAMP", "nullable": false}
      ]
    },
    "lineage": {
      "upstream": [],
      "downstream": ["报表数据集", "AI训练数据集"]
    },
    "tags": ["用户数据", "行为分析"],
    "qualityMetrics": {
      "completeness": 98.5,
      "accuracy": 99.1,
      "consistency": 97.8,
      "timeliness": 100.0
    }
  }
}
```

### 2.3 创建数据资产

```
POST /data-assets
Content-Type: application/json
```

**请求体:**
```json
{
  "name": "新数据集名称",
  "description": "数据集描述",
  "category": "business_data",
  "schema": {
    "fields": [
      {"name": "id", "type": "BIGINT", "nullable": false, "primaryKey": true}
    ]
  },
  "tags": ["标签1", "标签2"],
  "owner": "team_name"
}
```

**响应:** `201 Created` + 数据资产对象

### 2.4 更新数据资产

```
PUT /data-assets/{id}
Content-Type: application/json
```

### 2.5 删除数据资产

```
DELETE /data-assets/{id}
```

**响应:** `204 No Content`

---

## 3. 数据质量 API

### 3.1 触发质量检测

```
POST /data-assets/{id}/quality-checks
Content-Type: application/json

{
  "checkTypes": ["completeness", "accuracy", "consistency"],
  "sampleRate": 100
}
```

**响应:**
```json
{
  "code": 202,
  "data": {
    "jobId": "qc-job-12345",
    "status": "running",
    "estimatedDuration": "30s"
  }
}
```

### 3.2 获取质量检测结果

```
GET /data-assets/{id}/quality-checks/{jobId}
```

---

## 4. AI协同链 API

### 4.1 执行AI分析

```
POST /ai-chains/execute
Content-Type: application/json

{
  "chainId": "data-governance-chain",
  "input": {
    "dataAssetId": 1,
    "analysisType": "risk_assessment"
  },
  "options": {
    "model": "gpt-4",
    "temperature": 0.7,
    "maxTokens": 2000
  }
}
```

**响应:**
```json
{
  "code": 200,
  "data": {
    "executionId": "exec-67890",
    "result": {
      "riskScore": 0.15,
      "riskLevel": "low",
      "recommendations": [
        "建议增加数据访问日志",
        "建议定期进行数据质量检测"
      ],
      "analysisDetails": "..."
    },
    "tokensUsed": 1500,
    "duration": "2.3s"
  }
}
```

---

## 5. 错误码说明

| 错误码 | HTTP状态 | 说明 |
|--------|---------|------|
| 200 | 200 | 成功 |
| 400 | 400 | 请求参数错误 |
| 401 | 401 | 未认证或Token过期 |
| 403 | 403 | 无权限访问 |
| 404 | 404 | 资源不存在 |
| 409 | 409 | 资源冲突（如重名） |
| 422 | 422 | 业务逻辑错误 |
| 429 | 429 | 请求频率超限 |
| 500 | 500 | 服务器内部错误 |
| 503 | 503 | 服务暂时不可用 |

**错误响应格式:**
```json
{
  "code": 404,
  "message": "数据资产不存在",
  "errorCode": "DATA_ASSET_NOT_FOUND",
  "traceId": "abc123def456",
  "timestamp": "2026-01-01T08:00:00Z"
}
```

---

*版本: 1.0.0 | 最后更新: 2026-07-27*
