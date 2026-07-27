# SmartData API 文档

> **版本**: v1.0  
> **最后更新**: 2026-07-11  
> **基础URL**: `/api/smartdata`  
> **认证方式**: Bearer Token (JWT)

---

## 目录

1. [认证 API](#1-认证-api)
2. [仪表盘 API](#2-仪表盘-api)
3. [数据目录 API](#3-数据目录-api)
4. [元数据管理 API](#4-元数据管理-api)
5. [数据血缘 API](#5-数据血缘-api)
6. [数据质量 API](#6-数据质量-api)
7. [数据标准 API](#7-数据标准-api)
8. [主数据管理 API](#8-主数据管理-api)
9. [数据生命周期 API](#9-数据生命周期-api)
10. [数据服务 API](#10-数据服务-api)
11. [业务术语表 API](#11-业务术语表-api)
12. [AI 智能搜索 API (Sprint 16)](#12-ai-智能搜索-api)
13. [AI 智能标注 API (Sprint 17)](#13-ai-智能标注-api)
14. [系统性能 API](#14-系统性能-api)

---

## 通用说明

### 请求头

| Header | 说明 | 示例 |
|--------|------|------|
| `Authorization` | JWT Token | `Bearer eyJhbGciOi...` |
| `Content-Type` | 内容类型 | `application/json` |
| `Accept-Language` | 语言偏好 | `zh-CN` / `en-US` |

### 响应格式

```json
{
  "code": 200,
  "message": "success",
  "data": {},
  "timestamp": 1720000000000
}
```

### 分页响应

```json
{
  "records": [],
  "total": 100,
  "page": 1,
  "size": 20
}
```

### 错误码

| Code | 说明 |
|------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未认证 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

---

## 1. 认证 API

### POST /auth/login
用户登录

**请求体:**
```json
{
  "username": "admin",
  "password": "encrypted_password"
}
```

**响应:**
```json
{
  "accessToken": "eyJ...",
  "refreshToken": "eyJ...",
  "expiresIn": 7200,
  "userInfo": {
    "id": 1,
    "username": "admin",
    "realName": "管理员",
    "roles": ["admin"],
    "permissions": ["*"]
  }
}
```

### POST /auth/refresh
刷新 Token

### POST /auth/logout
退出登录

---

## 2. 仪表盘 API

### GET /dashboard/stats
获取治理概览统计

**响应:**
```json
{
  "totalAssets": 156,
  "qualityRate": 92.5,
  "totalStandards": 48,
  "lineageCoverage": 78.0,
  "assetTrend": 5,
  "qualityTrend": 2,
  "standardsTrend": 0,
  "lineageTrend": 3
}
```

### GET /dashboard/quality-trend?days=30
获取质量趋势数据

### GET /dashboard/asset-distribution
获取资产分布

---

## 3. 数据目录 API

### GET /catalog
分页查询数据资产

**查询参数:**
| 参数 | 类型 | 说明 |
|------|------|------|
| page | int | 页码 (默认1) |
| size | int | 每页条数 (默认20) |
| keyword | string | 搜索关键词 |
| domain | string | 数据域筛选 |
| type | string | 资产类型 |

### GET /catalog/{id}
获取资产详情

### POST /catalog
注册数据资产

### PUT /catalog/{id}
更新资产信息

### DELETE /catalog/{id}
删除资产

### GET /catalog/domains
获取数据域分类列表

---

## 4. 元数据管理 API

### GET /metadata
分页查询元数据

### GET /metadata/{id}
获取元数据详情

### POST /metadata
创建元数据

### PUT /metadata/{id}
更新元数据

### DELETE /metadata/{id}
删除元数据

---

## 5. 数据血缘 API

### GET /lineage/graph?assetId=1&depth=3
获取血缘图数据

**响应:**
```json
{
  "nodes": [
    { "id": "t1", "name": "用户表", "type": "table", "level": 0 },
    { "id": "t2", "name": "订单表", "type": "table", "level": 1 }
  ],
  "edges": [
    { "source": "t1", "target": "t2", "label": "user_id" }
  ]
}
```

---

## 6. 数据质量 API

### GET /quality/stats
获取质量统计

### GET /quality/prediction
获取质量预测

### GET /quality/dimensions
获取六维质量评分

### GET /quality/warnings?status=0&severity=1
获取质量预警列表

### PUT /quality/warnings/{id}/handle
处理质量预警

### POST /quality/warnings/generate
生成质量预警

### GET /quality/results
获取质量检查结果

### GET /quality/historical-trend
获取历史趋势

### GET /quality/predicted-trend
获取预测趋势

---

## 7. 数据标准 API

### GET /standards
分页查询数据标准

### POST /standards
创建数据标准

### PUT /standards/{id}
更新数据标准

### DELETE /standards/{id}
删除数据标准

---

## 8. 主数据管理 API

### GET /mdm
分页查询主数据模型

### POST /mdm
创建主数据模型

### PUT /mdm/{id}
更新主数据模型

### DELETE /mdm/{id}
删除主数据模型

---

## 9. 数据生命周期 API

### GET /lifecycle
分页查询生命周期策略

### POST /lifecycle
创建生命周期策略

### PUT /lifecycle/{id}
更新生命周期策略

### DELETE /lifecycle/{id}
删除生命周期策略

---

## 10. 数据服务 API

### GET /services
分页查询数据服务

### POST /services
创建数据服务

### PUT /services/{id}
更新数据服务

### DELETE /services/{id}
删除数据服务

---

## 11. 业务术语表 API

### GET /glossary
分页查询业务术语

### POST /glossary
创建业务术语

### PUT /glossary/{id}
更新业务术语

### DELETE /glossary/{id}
删除业务术语

---

## 12. AI 智能搜索 API

### POST /ai-search/search
自然语言搜索

**请求体:**
```json
{
  "query": "查找最近质量下降的数据表",
  "filters": { "type": "catalog" },
  "page": 1,
  "size": 20,
  "sortBy": "relevance",
  "sortOrder": "desc"
}
```

**响应:**
```json
{
  "query": "查找最近质量下降的数据表",
  "rewrittenQuery": "quality_score DESC AND trend = 'down' type:table",
  "results": [
    {
      "id": 1,
      "type": "catalog",
      "name": "用户行为表",
      "description": "记录用户行为数据",
      "source": "用户数据库",
      "score": 0.95,
      "highlights": ["质量", "下降"],
      "url": "/catalog/1"
    }
  ],
  "total": 15,
  "took": 128,
  "ragContext": "根据知识库，质量下降通常与...",
  "suggestions": ["质量评分低于80的表", "质量趋势下降的资产"]
}
```

### GET /ai-search/suggestions?query=质量
搜索建议

### GET /ai-search/history
搜索历史

### GET /ai-search/rag/knowledge-bases
RAG 知识库列表

### POST /ai-search/rag/knowledge-bases
创建 RAG 知识库

### POST /ai-search/rag/knowledge-bases/{kbId}/documents
上传文档到知识库 (multipart/form-data)

### POST /ai-search/rag/knowledge-bases/{kbId}/rebuild
重建索引

### POST /ai-search/rerank
搜索结果重新排序

---

## 13. AI 智能标注 API

### POST /ai-annotation/tasks
创建标注任务

**请求体:**
```json
{
  "name": "用户表字段标注",
  "targetType": "table",
  "targetId": 1,
  "annotationTypes": ["classification", "tagging", "sensitivity"]
}
```

### GET /ai-annotation/tasks
标注任务列表

### GET /ai-annotation/tasks/{id}
任务详情

### GET /ai-annotation/tasks/{taskId}/results
标注结果

### POST /ai-annotation/anomalies/detect
执行质量异常AI检测

**请求体:**
```json
{
  "table": "user_behavior",
  "days": 7
}
```

### GET /ai-annotation/anomalies
异常列表

### PUT /ai-annotation/results/{id}/approve
审核通过

### PUT /ai-annotation/results/{id}/reject
审核驳回

### POST /ai-annotation/results/batch-review
批量审核

---

## 14. 系统性能 API

### POST /system/perf-report
上报前端性能数据

**请求体:**
```json
{
  "navigation": { "loadTime": 1200, "domReady": 800 },
  "fps": 58,
  "memory": { "used": 50000000, "total": 100000000 },
  "errors": [{ "type": "javascript", "message": "...", "stack": "..." }],
  "routeTimings": [{ "path": "/dashboard", "duration": 350 }]
}
```

---

## 变更日志

| 日期 | 版本 | 变更内容 |
|------|------|---------|
| 2026-07-11 | v1.0 | 初始版本，包含14个API模块 |
| 2026-07-11 | v1.1 | 新增 AI 搜索 API (Sprint 16) |
| 2026-07-11 | v1.2 | 新增 AI 标注 API (Sprint 17) |
