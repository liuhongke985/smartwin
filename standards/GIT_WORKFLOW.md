# SmartWin Git 工作流规范

## 文档信息
- **版本**: 1.0.0
- **创建日期**: 2026-07-27

---

## 1. 分支策略

### 1.1 分支结构

```
main          ←── 生产环境，始终稳定
  └── develop ←── 开发主干，持续集成
        ├── feature/ISSUE-123-add-data-export ←── 功能分支
        ├── bugfix/ISSUE-456-fix-login-error  ←── Bug修复
        ├── refactor/improve-cache-layer       ←── 重构
        └── docs/update-api-docs               ←── 文档更新

release/v1.0.0  ←── 发布准备分支 (从develop创建)
hotfix/ISSUE-789 ←── 紧急修复 (从main创建)
```

### 1.2 分支命名规范

| 分支类型 | 格式 | 示例 |
|---------|------|------|
| 功能分支 | `feature/ISSUE-NNN-brief-description` | `feature/ISSUE-123-add-data-export` |
| Bug修复 | `bugfix/ISSUE-NNN-brief-description` | `bugfix/ISSUE-456-fix-login-error` |
| 热修复 | `hotfix/ISSUE-NNN-brief-description` | `hotfix/ISSUE-789-critical-security-fix` |
| 发布分支 | `release/vX.Y.Z` | `release/v1.0.0` |
| 重构 | `refactor/brief-description` | `refactor/improve-cache-layer` |
| 文档 | `docs/brief-description` | `docs/update-api-docs` |

### 1.3 分支保护规则

| 分支 | 直接推送 | PR要求 | 状态检查 |
|------|---------|--------|---------|
| `main` | 禁止 | 2个审批 | 所有CI必须通过 |
| `develop` | 禁止 | 1个审批 | 所有CI必须通过 |
| `release/*` | 禁止 | SA批准 | 完整测试套件 |

---

## 2. 提交消息规范

### 2.1 Conventional Commits 格式

```
<type>(<scope>): <short description>

[optional body]

[optional footer]
```

### 2.2 类型 (Type)

| 类型 | 描述 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat(data): add data export API` |
| `fix` | Bug修复 | `fix(auth): resolve token expiry issue` |
| `docs` | 文档更新 | `docs(api): update REST API examples` |
| `style` | 代码格式 | `style: fix indentation in UserService` |
| `refactor` | 重构 | `refactor(cache): optimize Redis usage` |
| `perf` | 性能优化 | `perf(query): add index for data_assets` |
| `test` | 测试 | `test(service): add unit tests for DataAssetService` |
| `build` | 构建 | `build: upgrade Spring Boot to 3.2.0` |
| `ci` | CI/CD | `ci: add SonarQube analysis step` |
| `chore` | 杂务 | `chore: update .gitignore` |
| `revert` | 回滚 | `revert: revert "feat: add export API"` |

### 2.3 提交消息示例

```
feat(smartdata): add data lineage tracking

Implement data lineage tracking feature for SmartData module.
This allows users to visualize data flow and dependencies.

- Add DataLineageService with graph traversal
- Implement lineage API endpoints
- Add Neo4j integration for graph storage

Closes #123
```

---

## 3. Pull Request 流程

### 3.1 创建PR

1. 确保分支是最新的 (`git fetch && git rebase origin/develop`)
2. 运行本地测试通过
3. 创建PR，填写PR模板
4. 添加适当的标签 (feature, bugfix等)
5. 关联相关Issue (`Closes #NNN`)
6. 指定审查者

### 3.2 PR模板

```markdown
## 变更说明

(简要描述此PR的目的和主要改动)

## 关联Issue

Closes #NNN

## 变更类型

- [ ] 新功能
- [ ] Bug修复
- [ ] 性能优化
- [ ] 重构
- [ ] 文档更新

## 测试

- [ ] 已添加单元测试
- [ ] 已通过所有现有测试
- [ ] 已在本地验证功能

## 截图 (如适用)

## 审查清单

- [ ] 代码符合编码规范
- [ ] 注释清晰完整
- [ ] 无调试代码残留
- [ ] 安全性考虑充分
```

### 3.3 代码审查清单

**功能审查**:
- [ ] 逻辑正确，符合需求
- [ ] 边界条件处理
- [ ] 错误处理完善

**代码质量**:
- [ ] 命名清晰
- [ ] 无重复代码
- [ ] 复杂度可接受

**安全审查**:
- [ ] 输入验证
- [ ] 权限检查
- [ ] 无敏感信息泄露

**测试覆盖**:
- [ ] 单元测试覆盖主要逻辑
- [ ] 测试命名规范

---

## 4. 合并冲突解决指南

### 4.1 预防冲突
- 保持分支生命周期短 (< 3天)
- 频繁从develop同步
- 小批量提交

### 4.2 解决步骤
```bash
# 1. 获取最新代码
git fetch origin

# 2. 在你的功能分支上 rebase
git rebase origin/develop

# 3. 遇到冲突时:
#    - 打开冲突文件
#    - 查看 <<<<<<, ======, >>>>>> 标记
#    - 保留正确的代码
#    - 删除冲突标记

# 4. 标记冲突已解决
git add <resolved-file>
git rebase --continue

# 5. 如果无法解决，放弃 rebase
git rebase --abort
```

### 4.3 冲突原则
- 理解双方改动的意图再合并
- 不清楚时与原作者沟通
- 合并后验证功能仍正常

---

## 5. 版本标签规范

### 5.1 语义化版本
格式: `vMAJOR.MINOR.PATCH`
- `MAJOR`: 不兼容的API变更
- `MINOR`: 新增向后兼容的功能
- `PATCH`: 向后兼容的Bug修复

示例: `v1.0.0`, `v1.2.0`, `v1.2.3`

### 5.2 创建标签
```bash
# 创建带注释的标签
git tag -a v1.0.0 -m "Release v1.0.0: SmartData核心功能上线"
git push origin v1.0.0
```

---

*版本: 1.0.0 | 最后更新: 2026-07-27*
