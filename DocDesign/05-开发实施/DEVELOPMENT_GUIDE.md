# SmartWin 开发规范与指南

> **版本**: 1.0 | **日期**: 2026-07-27
>
> 为保证代码质量、团队协作效率和产品稳定性，本文档定义了 SmartWin 项目的开发规范

---

## 📋 目录

1. [代码规范](#代码规范)
2. [Git 工作流](#git-工作流)
3. [提交规范](#提交规范)
4. [分支管理](#分支管理)
5. [代码审查](#代码审查)
6. [测试标准](#测试标准)
7. [文档要求](#文档要求)
8. [安全最佳实践](#安全最佳实践)

---

## 🎯 代码规范

### Java 后端规范

#### 1. 编码规范

```java
// ✅ 好的例子
public class UserService {
    private final UserRepository userRepository;
    
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }
    
    /**
     * 获取用户信息
     * @param userId 用户 ID
     * @return 用户数据
     * @throws UserNotFoundException 用户不存在
     */
    public UserDTO getUserById(String userId) {
        return userRepository.findById(userId)
            .map(this::convertToDTO)
            .orElseThrow(() -> new UserNotFoundException(userId));
    }
}

// ❌ 不好的例子
public class UserService {
    private UserRepository userRepository;
    
    public void setUserRepository(UserRepository userRepository) {
        this.userRepository = userRepository;
    }
    
    public UserDTO getUserById(String userId) {
        User user = userRepository.findById(userId);
        if (user != null) {
            return new UserDTO();
        }
        return null;  // 错误处理不当
    }
}
```

#### 2. 命名规范

```yaml
类名:
  - 格式: PascalCase
  - 例子: UserService, DataQualityEngine, SmartDataApplication
  - Service: xxxService
  - Controller: xxxController
  - Repository: xxxRepository
  - Entity: Xxx (如 User)
  - DTO: XxxDTO (如 UserDTO)
  - VO: XxxVO (如 UserVO)

方法名:
  - 格式: camelCase
  - 动词开头: get/set/find/save/delete/create/update/validate
  - 例子: getUserById(), saveUser(), deleteUserBatch()

常量:
  - 格式: UPPER_SNAKE_CASE
  - 例子: MAX_RETRY_COUNT, DEFAULT_TIMEOUT_MS

变量:
  - 格式: camelCase
  - 例子: userId, userName, isActive
```

#### 3. 代码组织

```
一个类的顺序:
  1. 类注释 (JavaDoc)
  2. 静态变量
  3. 实例变量 (private > public)
  4. 构造方法
  5. 公共方法
  6. 保护方法
  7. 私有方法
  8. 内部类
```

#### 4. 异常处理

```java
// ✅ 好的例子
try {
    // 业务逻辑
    return userRepository.save(user);
} catch (DataIntegrityViolationException e) {
    log.error("User data integrity violation", e);
    throw new BusinessException("用户数据冲突", e);
} catch (Exception e) {
    log.error("Unexpected error saving user", e);
    throw new SystemException("系统异常", e);
}

// ❌ 不好的例子
try {
    return userRepository.save(user);
} catch (Exception e) {
    e.printStackTrace();  // 不要这样
    return null;          // 不要返回 null
}
```

#### 5. 日志规范

```java
// ✅ 规范用法
log.debug("Processing user: {}", userId);  // 参数化
log.info("User {} created successfully", userName);
log.warn("Retry attempt {} for user {}", attempt, userId);
log.error("Failed to save user", exception);  // 异常作为参数

// ❌ 不规范用法
log.debug("Processing user: " + userId);     // 字符串拼接
log.info("User " + name + " created");
System.out.println("Debug message");         // 不要用 System.out
```

### Vue 3 + TypeScript 前端规范

#### 1. 组件结构

```vue
<template>
  <div class="user-form">
    <Form @submit="handleSubmit">
      <FormItem label="用户名" prop="username">
        <Input v-model="form.username" />
      </FormItem>
    </Form>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import type { UserForm } from '@/types';

// 定义 Props
interface Props {
  userId?: string;
}

// 定义 Emits
interface Emits {
  submit: [data: UserForm];
}

const props = withDefaults(defineProps<Props>(), {
  userId: '',
});

const emit = defineEmits<Emits>();

// 状态
const form = ref<UserForm>({
  username: '',
  email: '',
});

// 计算属性
const isValid = computed(() => form.value.username && form.value.email);

// 方法
const handleSubmit = () => {
  if (isValid.value) {
    emit('submit', form.value);
  }
};
</script>

<style scoped lang="less">
.user-form {
  padding: 16px;
}
</style>
```

#### 2. 类型定义

```typescript
// src/types/user.ts
export interface User {
  id: string;
  username: string;
  email: string;
  status: 'active' | 'inactive';
  createdAt: Date;
}

export type UserDTO = Omit<User, 'createdAt'>;

export interface UserForm {
  username: string;
  email: string;
}
```

#### 3. API 调用

```typescript
// src/api/user.ts
import type { User, UserForm } from '@/types';
import http from '@/utils/http';

const API_PREFIX = '/api/users';

export const userApi = {
  getUser(id: string) {
    return http.get<User>(`${API_PREFIX}/${id}`);
  },
  
  createUser(data: UserForm) {
    return http.post<User>(API_PREFIX, data);
  },
  
  updateUser(id: string, data: Partial<UserForm>) {
    return http.put<User>(`${API_PREFIX}/${id}`, data);
  },
  
  deleteUser(id: string) {
    return http.delete(`${API_PREFIX}/${id}`);
  },
};
```

---

## 🌳 Git 工作流

### 分支模型 (Git Flow)

```
┌─ main (生产环境)
│  │
│  └─ release/v1.0.0 (发布准备)
│     │
│     ├─ develop (开发主分支)
│     │  │
│     │  ├─ feature/user-management
│     │  ├─ feature/data-quality
│     │  ├─ bugfix/login-issue
│     │  └─ hotfix/security-patch
│     │
│     └─ (合并回 main)
│
└─ (标签: v1.0.0, v1.0.1)
```

### 分支命名规则

```bash
主要分支:
  main              # 生产环境
  develop           # 开发主分支

功能分支:
  feature/xxx       # 新功能
  bugfix/xxx        # Bug 修复
  hotfix/xxx        # 紧急修复 (从 main 切出)
  refactor/xxx      # 代码重构
  docs/xxx          # 文档更新
  test/xxx          # 测试相关

例子:
  feature/ai-rule-generation        # AI 规则生成功能
  bugfix/data-quality-calculation   # 数据质量计算 Bug
  hotfix/security-vulnerability     # 安全漏洞修复
```

### Git 基本操作

```bash
# 1. 创建功能分支
git checkout develop
git pull origin develop
git checkout -b feature/user-management

# 2. 提交代码
git add .
git commit -m "feat: add user management feature"
git push origin feature/user-management

# 3. 创建 Pull Request
# 在 GitHub 上创建 PR
# - 标题: feat: add user management feature
# - 描述: 详细说明功能
# - 关联 Issue: Fixes #123

# 4. 代码审查后合并
git checkout develop
git pull origin develop
git merge feature/user-management
git push origin develop

# 5. 删除本地和远程分支
git branch -d feature/user-management
git push origin --delete feature/user-management
```

---

## 💬 提交规范 (Conventional Commits)

### 格式

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### 类型 (type)

| 类型 | 说明 | 例子 |
|------|------|------|
| feat | 新功能 | feat: add user login |
| fix | 修复 Bug | fix: correct user query |
| docs | 文档 | docs: update README |
| style | 代码风格 (不改逻辑) | style: format code |
| refactor | 代码重构 | refactor: extract method |
| perf | 性能优化 | perf: improve query speed |
| test | 测试 | test: add user service test |
| chore | 构建/依赖 | chore: update dependencies |
| ci | CI/CD 配置 | ci: update GitHub Actions |

### 好的提交示例

```bash
# 简单提交
git commit -m "feat: add user authentication"

# 带范围的提交
git commit -m "fix(auth): fix JWT token expiration"

# 详细提交
git commit -m "feat(user): add user profile endpoint

Add new endpoint GET /api/users/{id}/profile

- Fetch user basic information
- Include user preferences
- Add proper error handling

Fixes #123

# 破坏性变更
git commit -m "feat!: redesign user API

BREAKING CHANGE: Changed response format from XML to JSON"
```

---

## 🔍 代码审查

### Pull Request 检查清单

- [ ] 代码符合编码规范
- [ ] 有单元测试并覆盖新功能
- [ ] 已更新相关文档
- [ ] 没有硬编码的密钥/密码
- [ ] 性能考虑合理
- [ ] 错误处理完善
- [ ] 日志记录适当

### 审查者职责

```
1. 代码质量
   ✓ 遵循编码规范
   ✓ 逻辑清晰
   ✓ 没有代码重复
   ✓ 性能可接受

2. 功能正确性
   ✓ 实现了需求
   ✓ 处理了边界情况
   ✓ 测试充分

3. 安全性
   ✓ 没有 SQL 注入
   ✓ 没有 XSS 漏洞
   ✓ 权限检查完善
   ✓ 敏感数据保护

4. 文档
   ✓ JavaDoc/注释完整
   ✓ README 已更新
   ✓ API 文档已更新
```

---

## ✅ 测试标准

### 测试覆盖率要求

```yaml
目标: >= 70%

模块级别:
  核心业务逻辑: >= 80%
  工具类: >= 60%
  Controller: >= 50%
  配置类: >= 30%
```

### 单元测试示例 (JUnit 5 + Mockito)

```java
@DisplayName("UserService 测试")
class UserServiceTest {
    
    @Mock
    private UserRepository userRepository;
    
    @InjectMocks
    private UserService userService;
    
    @Test
    @DisplayName("应该正确获取用户")
    void testGetUserById() {
        // Arrange
        String userId = "123";
        User expectedUser = new User(userId, "john");
        when(userRepository.findById(userId))
            .thenReturn(Optional.of(expectedUser));
        
        // Act
        UserDTO result = userService.getUserById(userId);
        
        // Assert
        assertThat(result)
            .isNotNull()
            .hasFieldOrPropertyWithValue("username", "john");
        verify(userRepository).findById(userId);
    }
    
    @Test
    @DisplayName("用户不存在时应抛出异常")
    void testGetUserByIdNotFound() {
        // Arrange
        String userId = "404";
        when(userRepository.findById(userId))
            .thenReturn(Optional.empty());
        
        // Act & Assert
        assertThatThrownBy(() -> userService.getUserById(userId))
            .isInstanceOf(UserNotFoundException.class);
    }
}
```

---

## 📚 文档要求

### 代码注释规范

```java
/**
 * 用户服务类
 * 
 * 提供用户相关的���务操作，包括用户查询、创建、更新、删除等功能。
 * 所有操作都包含权限检查和审计日志记录。
 * 
 * @author John Doe
 * @version 1.0.0
 * @since 2026-07-27
 */
public class UserService {
    
    /**
     * 根据用户 ID 获取用户信息
     * 
     * @param userId 用户唯一标识，不能为空
     * @return 用户数据传输对象
     * @throws UserNotFoundException 当用户不存在时抛出
     * @throws UnauthorizedException 当用户无权限时抛出
     * 
     * @example
     * UserDTO user = userService.getUserById("user-123");
     */
    public UserDTO getUserById(String userId) {
        // ...
    }
}
```

### API 文档

所有 API 都应使用 Swagger/OpenAPI 注解：

```java
@RestController
@RequestMapping("/api/users")
@Api(tags = "用户管理")
public class UserController {
    
    @GetMapping("/{id}")
    @ApiOperation(value = "获取用户信息", notes = "根据用户 ID 获取用户详细信息")
    @ApiResponses({
        @ApiResponse(code = 200, message = "成功", response = UserDTO.class),
        @ApiResponse(code = 404, message = "用户不存在"),
        @ApiResponse(code = 500, message = "服务器内部错误")
    })
    public ResponseEntity<UserDTO> getUser(
        @ApiParam(value = "用户 ID", example = "123")
        @PathVariable String id) {
        // ...
    }
}
```

---

## 🔐 安全最佳实践

### 1. 敏感信息保护

```yaml
禁止:
  ❌ 提交密码到版本控制
  ❌ 提交 API 密钥
  ❌ 提交数据库连接字符串
  ❌ 提交私钥文件

应该:
  ✅ 使用环境变量
  ✅ 使用配置中心 (Nacos)
  ✅ 使用密钥管理服务
  ✅ .gitignore 忽略敏感文件
```

### 2. SQL 注入防护

```java
// ❌ 不安全
String query = "SELECT * FROM users WHERE name = '" + userName + "'";
List<User> users = repository.query(query);

// ✅ 安全 (使用参数化查询)
String query = "SELECT * FROM users WHERE name = ?";
List<User> users = repository.query(query, userName);

// ✅ 安全 (使用 ORM)
List<User> users = userRepository.findByName(userName);
```

### 3. 权限检查

```java
@PostMapping("/users")
@PreAuthorize("hasRole('ADMIN')")
public ResponseEntity<UserDTO> createUser(@RequestBody UserForm form) {
    // 只有管理员才能创建用户
    return ResponseEntity.ok(userService.createUser(form));
}
```

---

## 🛠️ 开发环境配置

### IDE 配置 (IntelliJ IDEA)

1. **代码风格**
   - File > Settings > Editor > Code Style > Java
   - 设置缩进为 4 个空格
   - 启用自动格式化

2. **插件推荐**
   - Lombok
   - SonarLint
   - Checkstyle-IDEA
   - Google Java Format

3. **代码检查**
   - 启用 Inspections
   - 设置 Error 等级的检查

---

## 📊 质量门禁标准

PR 合并前必须满足:

```yaml
代码覆盖率: >= 70%
代码重复率: < 5%
Bug 数量: 0
安全漏洞: 0
代码规范违规: 0 (Error 级别)
通过所有单元测试: ✅
CodeReview 至少 1 人批准: ✅
所有 CI/CD 检查通过: ✅
```

---

**版本**: 1.0.0 | **更新**: 2026-07-27 | **维护者**: @liuhongke985