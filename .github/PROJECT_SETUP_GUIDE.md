# SmartWin 项目管理上手方案

## 安装上手改革

### 1. 创建 GitHub Projects Board

#### Master Board 创建步骤

```bash
1. 转入 GitHub 仓库
2. 点击 "Projects" 上面板频
3. 点击 "New" 按钮
4. 选择 "Table" 模板
5. 输入名称: "SmartWin Master Board"
6. 输入描述: "项目整体追踪下上手方案"
7. 点击 "Create"
```

#### Sprint Board 创建步骤

```bash
1. 重复上述步骤
2. 选择 "Table" 模板
3. 输入名称: "SmartWin Sprint Board - [Sprint Number]"
4. 输入描述: "[Sprint Number] 稳定發行板 (検索)"
5. 点击 "Create"
```

---

### 2. 配置 Board Views

#### Master Board Views

1. **View 1: Overall Progress**
   - Status 剀初总分: Backlog, Ready, In Progress, Review, Done, Blocked
   - Sort by Priority (P0 > P1 > P2 > P3)

2. **View 2: By Milestone**
   - Group by: Milestone
   - Each milestone shows its Issues

3. **View 3: By Team**
   - Filter by assignee labels
   - Backend/Frontend/AI/QA/DevOps teams

4. **View 4: By Priority**
   - Filter by: P0-Critical, P1-High, P2-Medium, P3-Low
   - Show blocked and urgent items at top

5. **View 5: Burndown Chart**
   - Use Insights tab for velocity tracking

---

### 3. 建立 Issue 模板

#### 位置: `.github/ISSUE_TEMPLATE/`

```bash
mkdir -p .github/ISSUE_TEMPLATE
```

#### 3.1 Story 模板

文件: `.github/ISSUE_TEMPLATE/story.md`

```markdown
---
name: Story (User Story)
about: 描述程序化的用户需求
labels: [story, triage]
---

## 程序化描述
As a [user type],
I want [feature/functionality],
so that [business value]

## 验收条件
- [ ] AC1: [Acceptance Criteria]
- [ ] AC2: [Acceptance Criteria]
- [ ] AC3: [Acceptance Criteria]

## 技术上的考量
- [ ] Consider [aspect]
- [ ] May need [technology]

## 相关Issue
- Related to #
- Depends on #
- Blocks #

## 估计工作量
- [ ] XS (< 4h)
- [ ] S (5-12h)
- [ ] M (13-32h)
- [ ] L (33-80h)
- [ ] XL (> 80h)
```

#### 3.2 Task 模板

文件: `.github/ISSUE_TEMPLATE/task.md`

```markdown
---
name: Task
about: 具体工作项目
labels: [task, triage]
---

## 任务描述
[Clear description]

## 子任务
- [ ] Subtask 1
- [ ] Subtask 2
- [ ] Subtask 3

## 验收条件 (Definition of Done)
- [ ] Code completed
- [ ] Unit tested
- [ ] Code reviewed
- [ ] Documentation updated
- [ ] Test case passed

## 估计时间
- [ ] XS (< 4h)
- [ ] S (5-12h)
- [ ] M (13-32h)
- [ ] L (33-80h)
```

#### 3.3 Bug 模板

文件: `.github/ISSUE_TEMPLATE/bug.md`

```markdown
---
name: Bug Report
about: 报告一个缺陷或错误
labels: [bug, triage]
---

## 故障描述
[Clear description]

## 藁何在此上游觲
1. [Step 1]
2. [Step 2]
3. [Step 3]

## 预计的超武器
[Expected behavior]

## 实际表现
[Actual behavior]

## 体剧統杰訊息
- OS: [e.g., Linux]
- Browser: [e.g., Chrome]
- Version: [e.g., 1.0.0]

## 优先級
- [ ] P0 (Critical)
- [ ] P1 (High)
- [ ] P2 (Medium)
- [ ] P3 (Low)

## 辞麯⡈截羿
[Screenshots or logs]
```

---

### 4. 建立 Issue Labels

#### 位置: `.github/labels.yml` (Optional)

或手动在 GitHub UI 中创建：

Repository Settings > Labels > New label

```
应创建的桌签：

- epic (color: #d73a49, description: "Large feature or initiative")
- story (color: #0366d6, description: "User story for a feature")
- task (color: #28a745, description: "Specific work item")
- bug (color: #ffd91a, description: "Bug or error")
- chore (color: #6f42c1, description: "Maintenance or refactoring")
- documentation (color: #7cb342, description: "Documentation update")
- performance (color: #c1185a, description: "Performance optimization")
- refactor (color: #5fa6d6, description: "Code refactoring")
- test (color: #64b5f6, description: "Test related")
- P0-Critical (color: #d73a49)
- P1-High (color: #ff6b6b)
- P2-Medium (color: #ffd91a)
- P3-Low (color: #28a745)
- SmartData (color: #0366d6)
- SmartChain (color: #6f42c1)
- SmartWin (color: #d73a49)
- backend (color: #28a745)
- frontend (color: #0366d6)
- infrastructure (color: #6f42c1)
- urgent (color: #ff6b6b)
- blocked (color: #d73a49)
- review-needed (color: #0366d6)
- ready-for-dev (color: #28a745)
```

---

### 5. 设置 Milestones

Repository Settings > Milestones > New milestone

```
需要上手建立的Milestones：

Milestone 1: W1-W2: Project Initiation (Due: 2026-08-10)
Milestone 2: W3-W5: Planning Phase (Due: 2026-08-31)
Milestone 3: W6-W13: Design Phase (Due: 2026-10-26)
Milestone 4: Iteration 1 (W14-W20) (Due: 2026-11-23)
Milestone 5: Iteration 2 (W21-W28) (Due: 2027-01-18)
Milestone 6: Iteration 3 (W29-W36) (Due: 2027-04-19)
Milestone 7: Testing Phase (W37-W44) (Due: 2027-06-14)
Milestone 8: Release & Deployment (W45-W48) (Due: 2027-07-12)
```

---

### 6. 配置 GitHub Actions Workflows

#### 位置: `.github/workflows/project-tracking.yml`

```yaml
name: Automated Project Tracking

on:
  issues:
    types: [opened, labeled, unlabeled, closed]
  pull_request:
    types: [opened, synchronize, reopened, closed]

jobs:
  track-project:
    runs-on: ubuntu-latest
    steps:
      - name: Add issue to project
        if: github.event_name == 'issues' && github.event.action == 'opened'
        uses: actions/github-script@v6
        with:
          script: |
            console.log('Issue added to project');

      - name: Update milestone based on label
        if: github.event_name == 'issues'
        uses: actions/github-script@v6
        with:
          script: |
            const labels = context.payload.issue.labels;
            let milestone = null;
            if (labels.find(l => l.name.includes('W1-W2'))) milestone = 'W1-W2';
            if (labels.find(l => l.name.includes('W3-W5'))) milestone = 'W3-W5';
            // ... more conditions

      - name: Auto-label urgent issues
        if: contains(github.event.issue.title, 'CRITICAL')
        uses: actions/github-script@v6
        with:
          script: |
            github.rest.issues.addLabels({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              labels: ['P0-Critical', 'urgent']
            });

      - name: Notify team on P0 issues
        if: github.event_name == 'issues' && contains(github.event.issue.labels.*.name, 'P0-Critical')
        uses: actions/github-script@v6
        with:
          script: |
            console.log('P0 issue created - notify team');
```

---

### 7. 创建上手使用下平台

#### 管理员上手使用下平台：

```
1. 每天日09:00
   - 查看 Master Board
   - 检查 P0/Blocked Issues
   - 日报进度

2. 每周一 10:00
   - Sprint 规划会议
   - 下周Sprint Board 推出

3. 每周五 16:00
   - 周报会议
   - 发布每周进度报告

4. 每个周五 18:00
   - 翻了一過 Milestones
   - 更新下一阶段计划
```

#### 开发上手使用下平台：

```
1. 每日日上
   - 查看今日的 Sprint Board
   - 选择 In Progress 的 Task

2. 开发中
   - 及时更新 Task 状态
   - 发现 Blocker 及时报告

3. 提交代码
   - PR 自动关联 Issue
   - PR 验收通过后自动包编为Review

4. 任务完成
   - Close Issue 或 PR 自动下窗为tooltip Done
```

---

## 分析上手改革误区

### 钻波一：日常使用

**问题**: 不秋一致地更新 Issue 状态

**解决法**:
- 设置了特关GitHub Actions 自动化流程
- 提供了上手的变更模板
- 培训团队性助的端口 CI/CD 流水线

### 钻波二：优先级处理

**问题**: P0 上紲不及时提高

**解决法**:
- P0 Issues 默认标记为 `urgent`
- GitHub Actions 会自动吼斺 PM 和流水员
- Master Board 会被有 P0 Issues 提到最上

---

**推觖騑 Week 2 开封会议遵叩已了追踪体系的下平台。**
