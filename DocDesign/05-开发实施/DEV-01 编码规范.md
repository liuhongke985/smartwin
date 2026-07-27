# 编码规范

## 文档控制

| 信息项 | 内容 |
|--------|------|
| **文档编号** | DEV-01 |
| **文档版本** | V1.0 |
| **创建日期** | 2026-07-08 |
| **最后修订** | 2026-07-08 |
| **文档状态** | 正式发布 |
| **文档负责人** | 架构师 |
| **审批人** | 项目总监 |

---

## 1. 总则

### 1.1 规范目的

统一项目代码风格，提高代码可读性、可维护性和一致性，降低协作沟通成本。

### 1.2 适用范围

适用于「智赢(智数+智链)双平台」项目所有Java后端、Python AI引擎、Vue前端代码。

---

## 2. Java编码规范

### 2.1 命名规范

| 类型 | 规则 | 示例 |
|------|------|------|
| 包名 | 全小写，域名倒序 | `com.smartwin.smartchain.model` |
| 类名 | UpperCamelCase | `ModelService`, `CatalogController` |
| 接口名 | UpperCamelCase | `CryptoService`, `DatabaseDialect` |
| 实现类 | 接口名+Impl | `ModelServiceImpl`, `SoftwareCryptoService` |
| 方法名 | lowerCamelCase | `getModelById`, `createQualityRule` |
| 变量名 | lowerCamelCase | `modelId`, `qualityScore` |
| 常量名 | UPPER_SNAKE_CASE | `MAX_TOKENS`, `DEFAULT_PAGE_SIZE` |
| 枚举名 | UpperCamelCase | `ModelStatus`, `QualityRuleType` |
| 泛型参数 | 单大写字母 | `T`, `E`, `K`, `V` |

### 2.2 类组织

```java
public class XxxService {
    // 1. 静态常量
    private static final int MAX_RETRY = 3;

    // 2. 实例字段
    private final XxxMapper xxxMapper;

    // 3. 构造器（使用Lombok @RequiredArgsConstructor）
    // 4. 公共方法
    // 5. 私有方法
}
```

### 2.3 分层规范

| 层 | 命名后缀 | 职责 | 禁止 |
|----|----------|------|------|
| Controller | Controller | 接收请求、参数校验、返回响应 | 业务逻辑 |
| Service | Service/ServiceImpl | 业务逻辑、事务管理 | 直接操作数据库 |
| Mapper | Mapper/Repository | 数据访问 | 业务逻辑 |
| Entity | Entity | 数据库映射 | 业务方法 |
| DTO | DTO/Request/Response | 数据传输 | 持久化逻辑 |

### 2.4 API响应规范

```java
// 成功响应
return ApiResponse.success(data);

// 分页响应
return ApiResponse.success(PageResult.of(records, total, page, size));

// 失败响应
return ApiResponse.error(ResultCode.PARAM_ERROR, "参数校验失败");

// 异常抛出
throw new BusinessException(ErrorCode.MODEL_NOT_FOUND, "模型不存在");
```

### 2.5 注释规范

| 注释类型 | 使用场景 | 格式 |
|----------|----------|------|
| 类注释 | 所有public类 | JavaDoc |
| 方法注释 | 所有public方法 | JavaDoc，含@param/@return |
| 字段注释 | 复杂字段 | 行注释或JavaDoc |
| 行内注释 | 复杂逻辑 | `//` 行注释 |

```java
/**
 * 创建AI模型
 *
 * @param request 模型创建请求
 * @return 模型详情响应
 * @throws BusinessException 模型名称重复时抛出
 */
public ModelDetailResponse createModel(ModelCreateRequest request) {
    // 检查模型名称是否重复
    // ...
}
```

### 2.6 异常处理规范

```java
// ✅ 正确：使用统一异常体系
throw new BusinessException(ErrorCode.MODEL_NOT_FOUND);

// ✅ 正确：全局异常处理器统一捕获
@ExceptionHandler(BusinessException.class)
public ApiResponse<Void> handleBusinessException(BusinessException e) {
    return ApiResponse.error(e.getCode(), e.getMessage());
}

// ❌ 错误：吞异常
try { ... } catch (Exception e) { /* ignore */ }

// ❌ 错误：返回null代替异常
if (model == null) return null;
```

### 2.7 Lombok使用规范

| 注解 | 使用场景 |
|------|----------|
| @Data | DTO/Response类 |
| @Getter/@Setter | Entity类（避免@Data的equals/hashCode问题） |
| @RequiredArgsConstructor | Service类（构造器注入） |
| @Builder | 复杂对象构建 |
| @Slf4j | 日志记录 |

### 2.8 日志规范

```java
// 使用SLF4J（通过Lombok @Slf4j）
@Slf4j
public class ModelService {
    public void createModel(ModelCreateRequest request) {
        log.info("创建AI模型, modelName={}, provider={}", request.getModelName(), request.getProvider());
        try {
            // ...
            log.info("AI模型创建成功, modelId={}", model.getId());
        } catch (Exception e) {
            log.error("AI模型创建失败, modelName={}", request.getModelName(), e);
            throw e;
        }
    }
}
```

| 日志级别 | 使用场景 |
|----------|----------|
| ERROR | 系统异常、不可恢复错误 |
| WARN | 可恢复的异常、业务告警 |
| INFO | 关键业务操作、状态变更 |
| DEBUG | 调试信息（生产关闭） |

---

## 3. Vue/TypeScript编码规范

### 3.1 命名规范

| 类型 | 规则 | 示例 |
|------|------|------|
| 组件名 | PascalCase | `ModelList.vue`, `StatCard.vue` |
| 组合式函数 | use前缀+camelCase | `useTheme`, `useModelApi` |
| Store | use前缀+Store后缀 | `useAuthStore`, `useThemeStore` |
| 类型/接口 | PascalCase | `ModelInfo`, `QualityRule` |
| 常量 | UPPER_SNAKE_CASE | `API_BASE_URL` |
| 事件名 | kebab-case | `@model-selected`, `@page-change` |
| CSS类 | kebab-case | `.model-card`, `.stat-value` |

### 3.2 组件规范

```vue
<script setup lang="ts">
// 1. 导入
import { ref, computed, onMounted } from 'vue'
import { useModelStore } from '@/stores/model'

// 2. Props/Emits
const props = defineProps<{
  modelId: number
  readonly?: boolean
}>()

const emit = defineEmits<{
  'model-updated': [model: ModelInfo]
  'close': []
}>()

// 3. 组合式函数
const modelStore = useModelStore()

// 4. 响应式状态
const loading = ref(false)
const model = ref<ModelInfo | null>(null)

// 5. 计算属性
const isOnline = computed(() => model.value?.status === 1)

// 6. 方法
async function fetchModel() {
  loading.value = true
  try {
    model.value = await modelStore.fetchModel(props.modelId)
  } finally {
    loading.value = false
  }
}

// 7. 生命周期
onMounted(fetchModel)
</script>
```

### 3.3 TypeScript规范

| 规则 | 说明 |
|------|------|
| 严格模式 | `strict: true` |
| 禁止any | 使用`unknown`或具体类型 |
| 接口优先 | 优先interface而非type |
| 枚举 | 使用`as const`对象而非enum |

```typescript
// ✅ 正确
interface ModelInfo {
  id: number
  name: string
  status: ModelStatus
}

const ModelStatus = {
  ONLINE: 1,
  OFFLINE: 2,
  ERROR: 3,
} as const
type ModelStatus = typeof ModelStatus[keyof typeof ModelStatus]

// ❌ 错误
function getModel(id: any): any { ... }
```

---

## 4. Python编码规范

### 4.1 基本规范

遵循 PEP 8，额外约定：

| 类型 | 规则 | 示例 |
|------|------|------|
| 模块名 | snake_case | `ai_detector.py` |
| 类名 | PascalCase | `AISecurityEngine` |
| 函数名 | snake_case | `detect_vulnerability` |
| 变量名 | snake_case | `model_name` |
| 常量 | UPPER_SNAKE_CASE | `MAX_TOKENS` |

### 4.2 FastAPI规范

```python
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

router = APIRouter(prefix="/api/ai", tags=["AI安全引擎"])

class DetectionRequest(BaseModel):
    content: str
    model_id: int

class DetectionResponse(BaseModel):
    is_safe: bool
    risk_score: float
    risk_type: str | None

@router.post("/detect", response_model=DetectionResponse)
async def detect(request: DetectionRequest):
    result = await ai_engine.detect(request.content, request.model_id)
    if result is None:
        raise HTTPException(status_code=500, detail="检测失败")
    return DetectionResponse(**result)
```

---

## 5. Git提交规范

### 5.1 Commit Message格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 5.2 Type列表

| Type | 说明 |
|------|------|
| feat | 新功能 |
| fix | 缺陷修复 |
| docs | 文档变更 |
| style | 代码格式（不影响功能） |
| refactor | 重构（非新功能、非修复） |
| perf | 性能优化 |
| test | 测试相关 |
| chore | 构建/工具变更 |
| ci | CI/CD变更 |

### 5.3 示例

```
feat(model-service): 新增AI模型批量导入功能

支持通过Excel文件批量导入AI模型配置，包含：
- 模型名称、类型、供应商、API端点
- 自动校验重复模型
- 导入结果报告

Closes #123
```

---

## 6. 代码质量门禁

### 6.1 SonarQube规则

| 指标 | 标准 |
|------|------|
| 代码覆盖率 | ≥70% |
| 重复代码 | <3% |
| 技术债务 | <5天 |
| Blocker/Critical | 0 |
| Major | <5 |

### 6.2 CI/CD门禁

| 检查项 | 工具 | 要求 |
|--------|------|------|
| 编译 | Maven/npm | 通过 |
| 单元测试 | JUnit5/Vitest | 100%通过 |
| 代码扫描 | SonarQube | 无Blocker |
| 依赖检查 | OWASP DC | 无Critical漏洞 |
| 代码格式 | CheckStyle/ESLint | 无Error |

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-08 | 架构师 | 初始版本发布 |
