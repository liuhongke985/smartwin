# 无用/过时交付物标记清单

> **文档编号**: DEL-04  
> **版本**: V1.0  
> **创建日期**: 2026-07-12  
> **编制人**: 项目管理部  
> **文档状态**: ⚠️ 待用户确认  
> **用途**: 列出项目中发现的重复、过时、无用文件，供用户确认后删除  

---

## 一、根目录重复文件（已有对应版本迁移至DocDesign）

以下文件均已在 `DocDesign` 目录下有对应的正式版本，根目录下的副本为重复文件，建议删除：

| 序号 | 文件路径 | DocDesign对应文件 | 状态 | 建议 |
|------|---------|------------------|------|------|
| 1 | `SmartWinProject/项目综合测试报告.md` | `DocDesign/06-测试验收/TST-14 项目综合测试报告.md` | 重复 | 🗑️ 建议删除 |
| 2 | `SmartWinProject/SIT全量系统测试报告.md` | `DocDesign/06-测试验收/TST-13 SIT全量系统测试报告.md` | 重复 | 🗑️ 建议删除 |
| 3 | `SmartWinProject/产品级全方位审计报告.md` | `DocDesign/10-系统附件/ATT-08 产品级全方位审计报告.md` | 重复 | 🗑️ 建议删除 |
| 4 | `SmartWinProject/运营推广产品执行方案.md` | `DocDesign/11-产品方案/PRD-04 运营推广产品执行方案.md` | 重复 | 🗑️ 建议删除 |
| 5 | `SmartWinProject/系统待办事项列表.md` | `DocDesign/09-项目管理/PM-20 系统全量待办事项列表.md` | 重复 | 🗑️ 建议删除 |
| 6 | `SmartWinProject/运营中心架构决策分析.md` | `DocDesign/04-系统设计/DES-16 运营中心架构决策分析.md` | 重复 | 🗑️ 建议删除 |
| 7 | `SmartWinProject/运营推广系统设计与商业生态战略分析.md` | `DocDesign/10-系统附件/ATT-09 运营推广系统设计与商业生态战略分析.md` | 重复 | 🗑️ 建议删除 |

---

## 二、CodeProject/WebDesign/docs 重复文件（已迁移至DocDesign）

以下文件已从 `CodeProject/WebDesign/docs` 迁移至 `DocDesign` 对应目录，原文件可删除：

| 序号 | 原文件路径 | 迁移目标 | 状态 | 建议 |
|------|---------|---------|------|------|
| 8 | `CodeProject/WebDesign/docs/audit/第二轮综合审计报告.md` | `DocDesign/10-系统附件/ATT-10 第二轮综合审计报告.md` | 已迁移 | 🗑️ 建议删除原件 |
| 9 | `CodeProject/WebDesign/docs/audit/系统界面效果综合评审报告.md` | `DocDesign/10-系统附件/ATT-11 系统界面效果综合评审报告.md` | 已迁移 | 🗑️ 建议删除原件 |
| 10 | `CodeProject/WebDesign/docs/audit/综合评审审计报告.md` | `DocDesign/10-系统附件/ATT-12 综合评审审计报告.md` | 已迁移 | 🗑️ 建议删除原件 |
| 11 | `CodeProject/WebDesign/docs/deployment/灾备恢复手册.md` | `DocDesign/07-部署上线/OPS-02 灾备恢复手册.md` | 已迁移 | 🗑️ 建议删除原件 |
| 12 | `CodeProject/WebDesign/docs/development/项目管理跟踪大盘.md` | `DocDesign/09-项目管理/PMO-04 项目管理跟踪大盘.md` | 已迁移 | 🗑️ 建议删除原件 |
| 13 | `CodeProject/WebDesign/docs/api/smartdata-api-v1.0.md` | `DocDesign/05-开发实施/API-02 智数平台API文档.md` | 已迁移 | 🗑️ 建议删除原件 |
| 14 | `CodeProject/WebDesign/docs/api/smartdata-user-manual-v1.0.md` | `DocDesign/10-系统附件/ATT-13 智数平台用户手册.md` | 已迁移 | 🗑️ 建议删除原件 |
| 15 | `CodeProject/WebDesign/ops-platform/docs/ops-openapi.yaml` | `DocDesign/05-开发实施/API-03 运营推广平台OpenAPI.yaml` | 已迁移 | 🗑️ 建议删除原件 |

---

## 三、临时脚本文件（替换过程中产生）

| 序号 | 文件路径 | 说明 | 建议 |
|------|---------|------|------|
| 16 | `SmartWinProject/replace_brand.ps1` | 临时PowerShell替换脚本（已失败） | 🗑️ 建议删除 |
| 17 | `SmartWinProject/replace_brand.py` | 临时Python替换脚本（已完成） | 🗑️ 建议删除 |
| 18 | `SmartWinProject/replace_brand2.py` | 临时Python替换脚本（已完成） | 🗑️ 建议删除 |
| 19 | `SmartWinProject/migrate-ops.ps1` | 临时PowerShell迁移脚本（已使用） | 🗑️ 建议删除 |

---

## 四、空目录

| 序号 | 目录路径 | 说明 | 建议 |
|------|---------|------|------|
| 20 | `CodeProject/WebDesign/docs/architecture/` | 空目录 | 🗑️ 建议删除 |
| 21 | `DesignProject/smartChain/` | 空目录 | 🗑️ 建议删除 |
| 22 | `DesignProject/smartWin/` | 空目录 | 🗑️ 建议删除 |

---

## 五、确认与操作指引

### 5.1 确认方式

请用户对上述文件逐项确认：
- ✅ **确认删除** — 同意删除该文件
- ❌ **保留** — 需要保留该文件，请说明原因
- ⏸️ **暂缓** — 暂不处理，后续再决定

### 5.2 操作方式

确认后，可使用以下命令批量删除已确认的文件（示例）：

```bash
# 删除根目录重复文件
del "d:\CodeBuddyProject\SmartWinProject\项目综合测试报告.md"
del "d:\CodeBuddyProject\SmartWinProject\SIT全量系统测试报告.md"
# ... 其他文件类推
```

### 5.3 注意事项

1. **删除前请确认** DocDesign 下的对应文件内容完整无误
2. **Git版本控制** — 如果项目已纳入Git，删除操作可通过Git恢复
3. **备份建议** — 建议在删除前对整个项目做一次完整备份

---

> **文档版本**: V1.0  
> **最后更新**: 2026-07-12  
> **下次评审**: 用户确认后归档  
