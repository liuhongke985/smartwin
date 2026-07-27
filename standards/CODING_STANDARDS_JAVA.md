# SmartWin Java 编码规范

## 文档信息
- **版本**: 1.0.0
- **适用**: Java 17+, Spring Boot 3.x

---

## 1. 命名规范

### 1.1 包名
- 全部小写，使用点分隔
- 格式: `com.smartwin.<module>.<layer>`
- 示例: `com.smartwin.smartdata.service`

### 1.2 类名
- 使用 PascalCase (大驼峰)
- 名词或名词短语
- Controller类: `XxxController`
- Service接口: `XxxService`
- Service实现: `XxxServiceImpl`
- Repository: `XxxRepository`
- DTO: `XxxDTO` 或 `XxxRequest`/`XxxResponse`
- 示例: `DataAssetService`, `UserController`

### 1.3 方法名
- 使用 camelCase (小驼峰)
- 动词或动词短语开头
- 查询方法: `getXxx`, `findXxx`, `listXxx`
- 判断方法: `isXxx`, `hasXxx`, `canXxx`
- 操作方法: `createXxx`, `updateXxx`, `deleteXxx`
- 示例: `getUserById`, `createDataAsset`

### 1.4 变量名
- 使用 camelCase
- 有意义的名称，避免单字母变量（循环变量除外）
- 常量: 全大写+下划线分隔，示例: `MAX_RETRY_COUNT`
- Boolean变量: 使用 `is`, `has`, `can` 前缀

### 1.5 数据库相关
- 表名: 下划线分隔，小写，示例: `data_asset`
- 字段名: 下划线分隔，小写，示例: `created_at`
- 实体类字段: camelCase，使用 `@Column` 映射

---

## 2. 代码格式

### 2.1 缩进与空格
- 使用4个空格缩进（不使用Tab）
- 运算符两侧各一个空格
- 方法参数列表逗号后加空格
- 代码块大括号: 左括号不换行，右括号独占一行

### 2.2 行长度
- 最大120字符
- 超长行使用换行，换行处增加8个空格缩进

### 2.3 空行
- 类的属性与方法之间空一行
- 方法之间空一行
- 逻辑相关代码块之间空一行

### 2.4 Import
- 禁止使用通配符导入（`import java.util.*`）
- 按组排列: java.*, javax.*, org.*, com.*
- 删除未使用的import

---

## 3. 注释规范

### 3.1 类注释
```java
/**
 * 数据资产管理服务实现
 * <p>提供数据资产的创建、查询、更新和删除功能</p>
 *
 * @author 作者名
 * @version 1.0.0
 * @since 2026-01-01
 */
@Service
public class DataAssetServiceImpl implements DataAssetService {
```

### 3.2 方法注释
```java
/**
 * 根据ID查询数据资产
 *
 * @param id 数据资产ID，不能为null
 * @return 数据资产信息，如不存在返回null
 * @throws DataAssetNotFoundException 当数据资产不存在时抛出
 */
public DataAssetDTO getById(Long id) {
```

### 3.3 行内注释
- 用于解释复杂逻辑，不是描述显而易见的事情
- 放在代码右侧或上方
- 示例: `// 使用悲观锁防止并发修改`

---

## 4. 错误处理

### 4.1 异常规范
```java
// 使用自定义业务异常
public class BusinessException extends RuntimeException {
    private final String errorCode;
    // ...
}

// 全局异常处理器
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ErrorResponse> handleBusinessException(BusinessException e) {
        log.warn("Business error: code={}, message={}", e.getErrorCode(), e.getMessage());
        return ResponseEntity.badRequest().body(ErrorResponse.of(e.getErrorCode(), e.getMessage()));
    }
}
```

### 4.2 日志规范
```java
// 使用SLF4J + Logback
private static final Logger log = LoggerFactory.getLogger(XxxService.class);
// 或使用 @Slf4j 注解

// 日志级别使用规范
log.debug("Processing request: {}", requestId);   // 调试信息
log.info("User {} created asset {}", userId, assetId);  // 业务关键步骤
log.warn("Retry attempt {} for {}", retryCount, operation); // 警告
log.error("Failed to process {}: {}", operation, e.getMessage(), e); // 错误

// 禁止使用 System.out.println
// 禁止在日志中记录密码、token等敏感信息
```

### 4.3 资源管理
```java
// 使用 try-with-resources
try (InputStream is = Files.newInputStream(path)) {
    // process stream
}

// 不使用 catch 吞掉异常
// 错误示范: catch (Exception e) { }
// 正确示范: catch (Exception e) { log.error(...); throw new BusinessException(...); }
```

---

## 5. 测试规范

### 5.1 单元测试命名
```java
// 格式: methodName_scenario_expectedResult
@Test
void getUserById_existingUser_returnsUser() { ... }

@Test
void getUserById_nonExistingUser_throwsNotFoundException() { ... }
```

### 5.2 覆盖率要求
- 业务逻辑层 (Service): ≥85%
- 工具类: ≥90%
- Controller层: ≥80%（集成测试覆盖）

### 5.3 测试结构 (AAA模式)
```java
@Test
void createDataAsset_validRequest_returnsCreatedAsset() {
    // Arrange
    DataAssetRequest request = buildTestRequest();
    when(repository.save(any())).thenReturn(buildTestAsset());

    // Act
    DataAssetDTO result = service.createDataAsset(request);

    // Assert
    assertThat(result).isNotNull();
    assertThat(result.getName()).isEqualTo(request.getName());
    verify(repository).save(any());
}
```

---

## 6. Spring规范

### 6.1 依赖注入
```java
// 推荐构造器注入
@Service
@RequiredArgsConstructor
public class DataAssetServiceImpl implements DataAssetService {
    private final DataAssetRepository repository;
    private final EventPublisher eventPublisher;
}

// 禁止使用字段注入 (@Autowired 直接在字段上)
```

### 6.2 事务管理
```java
// Service层管理事务
@Transactional(readOnly = true)
public DataAssetDTO getById(Long id) { ... }

@Transactional
public DataAssetDTO createDataAsset(DataAssetRequest request) { ... }
```

---

*版本: 1.0.0 | 最后更新: 2026-07-27*
