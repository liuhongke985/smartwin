# DEV-05 SmartWin智赢平台Git分支管理规范

> **文档编号**: DEV-05  
> **版本**: V2.0  
> **创建日期**: 2026-07-08  
> **文档状态**: 正式发布  
> **文档负责人**: DevOps工程师  
> **审批人**: 技术总监  

---

## 一、分支模型

### 1.1 分支策略：Git Flow + Trunk Based 混合

| 分支 | 命名规则 | 来源 | 生命周期 | 说明 |
|------|---------|------|---------|------|
| main | main | — | 永久 | 生产分支，受保护 |
| develop | develop | main | 永久 | 开发集成分支 |
| feature | feature/{ticket}-{desc} | develop | 临时 | 功能开发 |
| bugfix | bugfix/{ticket}-{desc} | develop | 临时 | 缺陷修复 |
| hotfix | hotfix/{ticket}-{desc} | main | 临时 | 生产紧急修复 |
| release | release/{version} | develop | 临时 | 发布准备 |

### 1.2 分支流转图

```
main ─────●──────────────●──────────────●──────────→ 生产
          │            ↑ │            ↑ │
          │  hotfix    │ │  release   │ │
          ↓            │ ↓            │ │
hotfix-001 ─→ merge ─→ │ release-1.0 ─→ │
                         │              │
develop ──●──┬──●──┬──●──┬──●──┬──●──→ 集成
              │   │   │   │   │
feature/001 ──┘   │   │   │   │
feature/002 ──────┘   │   │   │
bugfix/003 ──────────┘   │   │
feature/004 ────────────────┘
```

---

## 二、提交规范

### 2.1 Commit Message格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 2.2 Type定义

| Type | 说明 | 示例 |
|------|------|------|
| feat | 新功能 | feat(catalog): 新增AI搜索功能 |
| fix | 缺陷修复 | fix(quality): 修复质量评分计算错误 |
| docs | 文档更新 | docs(api): 更新API文档 |
| style | 代码格式 | style(frontend): 格式化代码 |
| refactor | 重构 | refactor(security): 重构权限校验逻辑 |
| test | 测试 | test(catalog): 新增目录服务单元测试 |
| chore | 构建/工具 | chore(docker): 更新Dockerfile |
| perf | 性能优化 | perf(etl): 优化ETL批量写入性能 |
| ci | CI/CD | ci(gitlab): 更新流水线配置 |

### 2.3 Scope定义

| Scope | 对应模块 |
|-------|---------|
| catalog | 数据目录 |
| metadata | 元数据 |
| quality | 数据质量 |
| lineage | 数据血缘 |
| security | 安全治理 |
| audit | 审计日志 |
| ai | AI引擎 |
| etl | ETL引擎 |
| fabric | 数据编织 |
| agent | AI Agent |
| ops | AutoOps |
| frontend | 前端 |
| gateway | API网关 |
| common | 公共模块 |
| docker | Docker |
| ci | CI/CD |

---

## 三、合并规范

### 3.1 Pull Request / Merge Request

| 规则 | 说明 |
|------|------|
| 标题 | 与Commit Message一致 |
| 描述 | 包含变更说明、测试方式、影响范围 |
| 审查 | 至少1名审查人 approve |
| 测试 | CI流水线全部通过 |
| 冲突 | 提前rebase解决冲突 |

### 3.2 合并方式

| 场景 | 合并方式 | 说明 |
|------|---------|------|
| feature → develop | Squash Merge | 压缩为单个提交 |
| release → main | Merge Commit | 保留合并记录 |
| hotfix → main | Merge Commit | 保留合并记录 |
| hotfix → develop | Cherry-pick | 同步修复到开发分支 |

---

## 四、版本标签

### 4.1 Tag命名

```
v{major}.{minor}.{patch}[-{prerelease}]

示例:
  v1.0.0          — V1.0正式版
  v1.5.0          — V1.5正式版
  v1.5.0-rc1      — V1.5候选版本1
  v2.0.0          — V2.0正式版
  v2.0.0-beta1    — V2.0测试版本1
```

### 4.2 发布流程

```
1. develop → 创建release分支
2. release分支 → 测试验证 → 修复
3. release → 合并到main + 打Tag
4. release → 合并回develop
5. main → 触发CI/CD自动部署
```

---

## 五、Git Hooks

### 5.1 Pre-commit Hook

```bash
#!/bin/bash
# 代码格式检查
mvn spotless:check
# 单元测试
mvn test -pl $(git diff --name-only HEAD | grep -oP 'CodeProject/[^/]+/[^/]+' | head -1)
# 前端lint
cd smartchain/smartchain-frontend && npm run lint
```

### 5.2 Commit-msg Hook

```bash
#!/bin/bash
# 校验Commit Message格式
pattern="^(feat|fix|docs|style|refactor|test|chore|perf|ci)(\(.+\))?: .{1,100}"
if ! grep -qP "$pattern" "$1"; then
  echo "Invalid commit message format!"
  exit 1
fi
```

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-08 | DevOps | 初始版本 |
| V2.0 | 2026-07-08 | DevOps | 补充Git Hooks和版本标签规范 |
