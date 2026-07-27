# 智链(SmartChain) 开发实施文档索引

> **文档编号**: SC-DEV-INDEX  
> **版本**: V1.0  
> **创建日期**: 2026-07-12  
> **文档状态**: 正式发布

---

## 文档索引

智链系统的开发实施文档分布在 DocDesign 主目录中，以下为关联索引：

| 编号 | 文档名称 | 路径 | 说明 |
|------|----------|------|------|
| DEV-01 | 编码规范 | `DocDesign/05-开发实施/` | Java/Vue/Python编码规范 |
| DEV-02 | 开发环境配置指南 | `DocDesign/05-开发实施/` | 智链开发环境配置 |
| DEV-03 | 代码模板与脚手架 | `DocDesign/05-开发实施/` | 智链项目脚手架 |
| DEV-06~19 | Sprint开发实施记录 | `DocDesign/05-开发实施/` | 各Sprint实施记录 |
| DEV-18 | 技术债务管理 | `DocDesign/05-开发实施/` | 智链技术债清理 |

## 智链开发实施数据

| 指标 | 数值 |
|------|------|
| 后端微服务数 | 6 Java + 1 Python |
| 后端API端点数 | ~81 |
| 前端Vue页面数 | 69 |
| 前端路由数 | 80+ |
| 单元测试用例数 | 78 (Java) + 19 (前端) |
| E2E测试用例数 | 核心流程覆盖 |

## 代码仓库结构

```
smartchain/
├── smartchain-ai-engine/      # Python AI引擎
│   ├── app/
│   │   ├── api/               # FastAPI路由
│   │   ├── core/              # 核心配置
│   │   ├── models/            # 数据模型
│   │   └── services/          # 业务逻辑
│   └── tests/                 # Python测试
├── smartchain-frontend/       # Vue 3前端
│   ├── src/
│   │   ├── api/               # API调用层
│   │   ├── views/             # 页面视图
│   │   ├── router/            # 路由配置
│   │   ├── stores/            # Pinia状态管理
│   │   ├── composables/       # 组合式函数
│   │   └── types/             # TypeScript类型
│   └── tests/                 # 前端测试
└── smartchain-services/       # Java微服务
    ├── model-service/         # AI模型管理
    ├── app-service/           # 智能体应用
    ├── agent-service/         # Agent编排
    ├── cost-service/          # 成本管控
    ├── risk-service/          # 风险评估
    └── prompt-service/        # 提示词管理
```

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-12 | 架构组 | 初始版本 |
