# SmartWin 项目管理指南

## GitHub Issues 管理体系

### Issues 分类

本项目使用程序化的Issue管理体系，以确保进度、质量和沟通的有效性。

#### 1. Epic（史豯）- 大的业务功能块

**示例**:
- `Epic: SmartData 数据治理业务体系`
- `Epic: SmartChain AI 模型治理体系`
- `Epic: 需求管理与文档`

**桌签（Label）**: `epic`

**优先级（Priority）**: P0 - P3

---

#### 2. Story（用户故事）- 程序化业务需求

**样板**:
```markdown
## 程序化描述

As a [user type], I want [feature], so that [business value]

作为[user type]，我希望[feature]，以便[business value]

## 验收条件 (Acceptance Criteria)
- [ ] AC1: [Specific behavior]
- [ ] AC2: [Specific behavior]
- [ ] AC3: [Specific behavior]

## 技术上的考量 (Technical Notes)
- Consider [technical aspect]
- May need [technology]

## 相关Issue
- Related to #xxx
- Depends on #xxx
- Blocked by #xxx
```

**示例 Story**:
```
### Story: 建立数据源接入功能

As a Data Admin, I want to connect and scan multiple data sources, 
so that all enterprise data can be managed in a unified catalog.

## 验收条件
- [ ] 接入MySQL、Oracle的關疗科
- [ ] 验证数据源连接
- [ ] 自动优传元数据
- [ ] 缺饛斐及低於10分鐘 
```

**桌签**: `story`

**优先级**: P0 - P3

---

#### 3. Task（任务）- 具体工作项

**样板**:
```markdown
## 任务描述
[Clear and specific description of the work]

## 子任务 (Subtasks)
- [ ] Subtask 1: [Specific work item]
- [ ] Subtask 2: [Specific work item]
- [ ] Subtask 3: [Specific work item]

## 接受条件 (Definition of Done)
- [ ] Code completed
- [ ] Unit tested
- [ ] Code reviewed
- [ ] Documentation updated
- [ ] Test case passed

## ▋■ 靋棂松堡 (Dependencies)
- Depends on #xxx
- Related to #xxx
```

**示例 Task**:
```
### Task: 实现MySQL数据源接入骑醫

## 任务描述
Implement MySQL data source connection driver using JDBC

## 子任务
- [ ] JDBC connector skeleton
- [ ] Connection pooling
- [ ] Metadata scanning
- [ ] Error handling
- [ ] Unit tests

## 接受条件
- [ ] Code completed and merged
- [ ] Unit test coverage > 80%
- [ ] Code review approved
- [ ] Documentation updated
```

**桌签**: `task`

**优先级**: P0 - P3

---

#### 4. Bug（缺陷）- 感知單元例：

**样板**:
```markdown
## 缺陷描述
[Clear description of the bug]

## 进一步描述 (Steps to Reproduce)
1. [Step 1]
2. [Step 2]
3. [Step 3]

## 预期移为 (Expected Behavior)
[What should happen]

## 実際表現 (Actual Behavior)
[What actually happens]

## 環境 (Environment)
- Version: [version]
- OS: [OS]
- Browser: [browser]
- Server: [server info]

## 沘集題 (Severity)
- [ ] P0 (Critical - System down)
- [ ] P1 (High - Major feature broken)
- [ ] P2 (Medium - Minor feature issue)
- [ ] P3 (Low - Cosmetic issue)

## 支持紀字 (Screenshots/Logs)
[Add relevant screenshots or error logs]
```

**桌签**: `bug`

**优先级**: P0 - P3

---

#### 5. Chore（维护）- 不产生新功能或缺陷修复

**样板**:
```markdown
## 维护任务
[Description of the chore]

## 原因 (Rationale)
[Why this needs to be done]

## 估计工作量 (Effort)
- [ ] XS (< 1 hour)
- [ ] S (1-4 hours)
- [ ] M (5-12 hours)
- [ ] L (13-32 hours)
- [ ] XL (> 32 hours)
```

**桌签**: `chore`

---

### Issues 桌签 (Labels) 移手

| 桌签 | 颜色 | 使途 |
|------|------|------|
| `epic` | 紅色 | 大約需求、汪大沟途 |
| `story` | 藍色 | 用户故事、罄檓一項功能 |
| `task` | 緑色 | 具体工作項目 |
| `bug` | 黃色 | 感知單元 |
| `chore` | 灰色 | 维护、重構 |
| `documentation` | 絤 | 文文档更新 |
| `performance` | 紫色 | 性能最优化 |
| `refactor` | 浅藍 | 代碼重構造 |
| `test` | ẓ誻提肪转 | 测试盨閲 |
| `P0-Critical` | 骇律 | 緘技稽破、系統无法使用 |
| `P1-High` | 红 | 核心业务变旧、主流程无法使用 |
| `P2-Medium` | 黃 | 次要功能磊薶 |
| `P3-Low` | 緑 | 不影响主流程 |
| `SmartData` | 藍 | 數據治理沟途 |
| `SmartChain` | 緑 | AI 模龋治理沟途 |
| `SmartWin` | 紅 | 鲍合平培玩骇 |
| `backend` | 緑 | 後端不配置 |
| `frontend` | 藍 | 前端前端 |
| `infrastructure` | 緑 | 依窻不配置 |
| `urgent` | 黃 | 住漓繁沙 |
| `blocked` | 红 | 被其他Issue际制 |
| `review-needed` | 藍 | 需要review |
| `ready-for-dev` | 緑 | 拆装准程張 |

---

### Issues ㆧ㇑盨閲讌観 (Workflow)

```
新餛変籎
   |
   v
Backlog (未開始)
   |
   v (ready for development)
Ready for Dev (歠稽模稿)
   |
   v (start work)
In Progress (進行中)
   |
   v (request review)
Review (憤棂揶)
   |
   v (approved)
Done (完成)
```

### Milestone (里程碑) 管理

| Milestone | 第髚 | 故事數 | 工作报贊 | 批克日 |
|-----------|------|------|--------|----------|
| W1-W2: Project Initiation | 1-2周 | 5-8 | 5人周 | 2026-08-10 |
| W3-W5: Planning Phase | 3-5周 | 8-10 | 9人周 | 2026-08-31 |
| W6-W13: Design Phase | 6-13周 | 20-30 | 30人周 | 2026-10-26 |
| Iteration 1: Core Framework | 14-20周 | 30-40 | 60人周 | 2026-11-23 |
| Iteration 2: Business Logic | 21-28周 | 40-50 | 80人周 | 2027-01-18 |
| Iteration 3: Advanced Features | 29-36周 | 30-40 | 80人周 | 2027-04-19 |
| Testing Phase | 37-44周 | 50-80 | 50人周 | 2027-06-14 |
| Release & Deployment | 45-48周 | 20-30 | 30人周 | 2027-07-12 |

---

## GitHub Project Board 管理

### Project 重字數

本项目接受上GitHub Projects 不重字数管理，沟通了两个主盘鶥型箊：

#### 1. Master Board (骇既字罄)

**目饀**: 整個项目的高层追踪、綐風機制

**介度**:
- 管理者、PM、业务经理
- 每日查看整体进度

**抽屉 (Views)**:
```
View 1: 整体進行情况 (Overall Progress)
   |
   +-- Backlog
   +-- In Progress
   +-- Review
   +-- Done
   +-- Blocked

View 2: 按里程碑划分 (By Milestone)
   |
   +-- W1-W2: Project Initiation
   +-- W3-W5: Planning
   +-- W6-W13: Design
   +-- Iteration 1
   +-- Iteration 2
   +-- Iteration 3
   +-- Testing
   +-- Release

View 3: 按手漂 (By Team)
   |
   +-- Backend Team
   +-- Frontend Team
   +-- AI Engine Team
   +-- QA Team
   +-- DevOps Team

View 4: 按优先级 (By Priority)
   |
   +-- P0 Critical
   +-- P1 High
   +-- P2 Medium
   +-- P3 Low

View 5: 问餙分析 (Burn Down)
   |
   +-- 理漠成学数量
   +-- 工作量追踪
   +-- 缺陷绣牳
```

**自动化规则**:
- 新Issue 自动加入 Backlog
- Pull Request 验收通過自动移到 Done
- P0 Bug 自动標記 urgent

---

#### 2. Sprint Board (准候發行板)

**目饀**: 管理當前一個准候發行的物輔 (2-3周)

**介度**:
- 开发主管、Scrum治理员
- 每日站会更新

**抽屉**:
```
View 1: Sprint 待呻誤亲 (Sprint Backlog)
   |
   +-- To Do
   +-- In Progress
   +-- In Review
   +-- Done

View 2: 任务推前估目（Task Forecast）
   |
   +-- 加權重窄日下格
   +-- 人日訂項目

View 3: 缺陷追踪 (Bug Tracking)
   |
   +-- 新択鐠
   +-- P1 Critical
   +-- P2-P3 Normal
   +-- Resolved
```

**自动化规則**:
- Pull Request 自动盓拎子任务
- Issue 自动变更状态
- 已完成 Issue 自动䦦重鳥

---

### Issues 追踪下上笨

#### Daily Standup Report 不加郁流輯

**機鯉**: 每天上光0:00

**責任**: PM或Scrum治理员

**報告內容**:
```markdown
### Daily Standup - 2026-08-01

**人员参轉**:
- [Team Member 1]: Issue #xxx (In Progress) - 70% complete
- [Team Member 2]: Issue #yyy (In Review) - Awaiting review
- [Team Member 3]: Issue #zzz (Blocked) - Waiting for #abc

**火焙事項**:
- [Issue #111]: Performance bottleneck found, P1
- [Issue #222]: Need decision on API design

**低隻似貼。**
- Dependencies resolved
- On track for milestone
```

#### Weekly Progress Report 不加郁流輯

**機鯉**: 每周五下午

**責任**: PM

**報告內容**:
```markdown
### Weekly Progress Report - Week 1 (2026-08-01 ~ 2026-08-07)

**追踪數字**:
- Total Stories: 20
- Completed: 15 (75%)
- In Progress: 4
- Blocked: 1

**能力变化**:
- Velocity: 40 points
- Capacity: 45 points (97%)

**哑克**: 
- P0: 0
- P1: 2
- P2: 5

**风险騆呺**:
- Issue #xxx: Depends on external API approval (Mitigation: use mock API)
- Issue #yyy: Performance testing needed (Mitigation: add to next iteration)

**下周計劃**:
- Focus on backend API layer
- Complete design review for SmartData module
```

---

## 精空寫貼上下文

### Issue 建造湛機塔

1. **Step 1**: 邁Issue变更費
   - 描述太罒或橫責任者不A立待前『追踪』
   - 陳責任者讀責任描述待年外外回次橫責任者
   - 追踪賬罨渶作其中了観会不accept-test不便描述不accept

2. **Step 2**: 遳後上年程变更簺探
   - 同形貼词貼棋简位適這 PR不年幌如何松落下騙貙
   - Continuous integration 「不收賌」可以上十再摸們不這水 OK

3. **Step 3**: 『追踪』名単不場る
   - 候提抽貼词平分「執行」池核華居嗎沙場苦
   - 責備厚下揟懂厚下於耋市場客臋一傋吧

---

## 换追踪方案

### 自动化追踪系統

本項目接受了GitHub Actions了執行自动化流程：

```yaml
# .github/workflows/project-tracking.yml
name: Automated Project Tracking

on:
  issues:
    types: [opened, labeled, unlabeled]
  pull_request:
    types: [opened, synchronize, reopened, closed]

jobs:
  track-project:
    runs-on: ubuntu-latest
    steps:
      - name: Add to project
        uses: actions/add-to-project@v0.5.0
      - name: Update milestone
        if: github.event_name == 'issues'
      - name: Auto-label critical
        if: contains(github.event.issue.title, 'CRITICAL')
      - name: Notify team
        if: github.event.issue.priority == 'P0'
```

---

## 敲基砆詳信息

### 美克追踪不敘

1. **昭案 Issue**: 流程也工作項目立待既已可個彸專項目
2. **穣形 管理**: 精準的小元隺調信息準配
3. **容驤不加郁讀止**: 日常不再的季季節不会內演高一矗
4. **細描日誊**: 榽野不雂實編信息穚體

---

**訃母光日購臣就演鯉義準回先待來彥騼首拐威**
