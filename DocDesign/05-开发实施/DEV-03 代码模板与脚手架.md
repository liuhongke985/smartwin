# DEV-03 SmartWin智赢平台代码模板与脚手架

> **文档编号**: DEV-03  
> **版本**: V2.0  
> **创建日期**: 2026-07-08  
> **文档状态**: 正式发布  
> **文档负责人**: 架构师  
> **审批人**: 技术总监  

---

## 一、后端代码模板

### 1.1 微服务标准结构

```
{service-name}/
├── src/main/java/com/smartwin/{module}/
│   ├── {Module}Application.java          # 启动类
│   ├── controller/                        # 控制层
│   │   └── {Entity}Controller.java
│   ├── service/                           # 服务层
│   │   ├── {Entity}Service.java          # 接口
│   │   └── impl/
│   │       └── {Entity}ServiceImpl.java  # 实现
│   ├── entity/                            # 实体层
│   │   └── {Entity}.java
│   ├── dto/                               # 数据传输对象
│   │   ├── {Entity}CreateDTO.java
│   │   ├── {Entity}UpdateDTO.java
│   │   └── {Entity}QueryDTO.java
│   ├── mapper/                            # MyBatis映射
│   │   └── {Entity}Mapper.java
│   └── config/                            # 配置类
│       └── {Module}Config.java
├── src/main/resources/
│   ├── application.yml                    # 主配置
│   ├── application-dev.yml                # 开发环境
│   ├── application-prod.yml               # 生产环境
│   ├── mapper/                            # MyBatis XML
│   │   └── {Entity}Mapper.xml
│   └── db/migration/                      # Flyway迁移
│       └── V1__init.sql
└── pom.xml
```

### 1.2 Controller模板

```java
@RestController
@RequestMapping("/api/v1/{module}")
@Tag(name = "{模块名}", description = "{模块描述}")
@RequiredArgsConstructor
@Validated
public class {Entity}Controller {

    private final {Entity}Service {entity}Service;

    @GetMapping
    @Operation(summary = "分页查询")
    @PreAuthorize("@ss.hasPermi('{module}:list')")
    public Result<PageResult<{Entity}VO>> list({Entity}QueryDTO query) {
        return Result.success({entity}Service.page(query));
    }

    @GetMapping("/{id}")
    @Operation(summary = "详情查询")
    @PreAuthorize("@ss.hasPermi('{module}:query')")
    public Result<{Entity}VO> getById(@PathVariable Long id) {
        return Result.success({entity}Service.getById(id));
    }

    @PostMapping
    @Operation(summary = "创建")
    @PreAuthorize("@ss.hasPermi('{module}:add')")
    @AuditLog(type = AuditType.CREATE, module = "{module}")
    public Result<{Entity}VO> create(@Valid @RequestBody {Entity}CreateDTO dto) {
        return Result.success({entity}Service.create(dto));
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新")
    @PreAuthorize("@ss.hasPermi('{module}:edit')")
    @AuditLog(type = AuditType.UPDATE, module = "{module}")
    public Result<{Entity}VO> update(@PathVariable Long id, 
                                     @Valid @RequestBody {Entity}UpdateDTO dto) {
        return Result.success({entity}Service.update(id, dto));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除")
    @PreAuthorize("@ss.hasPermi('{module}:del')")
    @AuditLog(type = AuditType.DELETE, module = "{module}")
    public Result<Void> delete(@PathVariable Long id) {
        {entity}Service.delete(id);
        return Result.success();
    }
}
```

### 1.3 Entity模板

```java
@Data
@TableName("{table_name}")
public class {Entity} {

    @TableId(type = IdType.ASSIGN_ID)
    private Long id;

    @TableField("name")
    private String name;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    @TableField(fill = FieldFill.INSERT)
    private String createBy;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private String updateBy;

    @TableLogic
    @TableField("deleted")
    private Integer deleted;
}
```

---

## 二、前端代码模板

### 2.1 页面模板

```vue
<template>
  <div class="{module}-container">
    <!-- 搜索栏 -->
    <SearchBar v-model="queryParams" :fields="searchFields" @search="handleSearch" />
    
    <!-- 操作栏 -->
    <ActionBar :selected-ids="selectedIds" @add="handleAdd" @batch-delete="handleBatchDelete" />
    
    <!-- 表格 -->
    <DataTable :data="tableData" :columns="columns" :loading="loading"
      :pagination="pagination" @page-change="handlePageChange"
      @selection-change="handleSelectionChange" />
    
    <!-- 表单弹窗 -->
    <FormDialog v-model="dialogVisible" :form-data="formData" 
      :title="dialogTitle" @submit="handleSubmit" />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { {module}Api } from '@/api/{module}'
import type { {Entity}, {Entity}Query } from '@/types/{module}'

// 查询参数
const queryParams = reactive<{Entity}Query>({ page: 1, size: 20 })
// 表格数据
const tableData = ref<{Entity}[]>([])
const loading = ref(false)
const pagination = ref({ total: 0, page: 1, size: 20 })
// 弹窗
const dialogVisible = ref(false)
const dialogTitle = ref('')
const formData = ref<Partial<{Entity}>>({})
// 选中
const selectedIds = ref<number[]>([])

// 加载数据
const loadData = async () => {
  loading.value = true
  try {
    const res = await {module}Api.list(queryParams)
    tableData.value = res.data.list
    pagination.value.total = res.data.total
  } finally {
    loading.value = false
  }
}

onMounted(() => loadData())
</script>
```

### 2.2 API模板

```typescript
// src/api/{module}.ts
import request from '@/utils/request'
import type { {Entity}, {Entity}Query, {Entity}Create, {Entity}Update } from '@/types/{module}'

export const {module}Api = {
  list: (params: {Entity}Query) => 
    request.get<{ list: {Entity}[]; total: number }>('/api/v1/{module}', { params }),
  
  getById: (id: number) => 
    request.get<{Entity}>(`/api/v1/{module}/${id}`),
  
  create: (data: {Entity}Create) => 
    request.post<{Entity}>('/api/v1/{module}', data),
  
  update: (id: number, data: {Entity}Update) => 
    request.put<{Entity}>(`/api/v1/{module}/${id}`, data),
  
  delete: (id: number) => 
    request.delete(`/api/v1/{module}/${id}`),
}
```

---

## 三、SQL迁移模板

```sql
-- V{version}__{description}.sql
-- Flyway迁移脚本

-- 创建表
CREATE TABLE {table_name} (
    id BIGINT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(64),
    update_by VARCHAR(64),
    deleted INT DEFAULT 0
);

-- 创建索引
CREATE INDEX idx_{table}_name ON {table_name}(name);
CREATE INDEX idx_{table}_create_time ON {table_name}(create_time);

-- 达梦兼容（如需）
-- 注意：达梦不支持某些PostgreSQL语法，需使用common-db-multi方言适配
```

---

## 四、Docker模板

```dockerfile
# 后端Dockerfile
FROM eclipse-temurin:17-jre-alpine
LABEL maintainer="IntelChain Team"
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 8080
ENV JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC"
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

```dockerfile
# 前端Dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
```

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-08 | 架构师 | 初始版本 |
| V2.0 | 2026-07-08 | 架构师 | 补充Docker和前端模板 |
