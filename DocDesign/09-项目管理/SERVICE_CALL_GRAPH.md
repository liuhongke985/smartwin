服务调用图与合并候选清单

基于 `DES-01 系统架构设计说明书.md` 中的服务清单与架构，本报告给出服务调用关系的摘要、建议合并的候选服务、每项合并的影响评估与估时参考。

1. 概览
- 网关: `gateway` (9000)
- 共享服务 (示例): `auth-service`(8081), `system-service`(8082), `security-service`(8090), `audit-service`(8100), `config-service`(8103), `notification-service`(8102), `dashboard-service`(8101)
- 智链服务: `model-service`(8083), `app-service`(8084), `agent-service`(8085), `cost-service`(8086), `risk-service`(8087), `prompt-service`(8088)
- 智数服务: `catalog-service`(8091), `metadata-service`(8092), `quality-service`(8093), `standard-service`(8094), `lineage-service`(8095), `mdm-service`(8096), `lifecycle-service`(8097), `dataservice-service`(8098), `asset-service`(8099)

注意: 文档中还包含 `common-*` 工具类包（`common-mq`、`common-storage`等），并且 AI 引擎分为 `ai-engine-intelchain`(8200/8201) 与内嵌 `langchain4j`。

2. 推断的调用关系（高层）
- 前端 → gateway → auth-service →（鉴权成功）→ 目标服务（catalog/metadata/quality/...）
- catalog-service → metadata-service、quality-service、lineage-service（用于显示资产详情/质量/血缘）
- metadata-service ↔ lineage-service（元数据变化触发血缘重解析）
- quality-service → dataservice-service（质量修复/回写）
- lineage-service → Neo4j（图存储）
- AI 调用：catalog/metadata → ai-governance（RAG/注释/自动注释）→ ES/向量库

（建议绘制真实调用图需基于运行时调用链采样或代码依赖分析，此处为架构文档推断）

3. 合并候选（优先级排序）

1) 合并候选: `notification-service` + `dashboard-service` + `system-service` → `platform-ops-service`
  - 理由: 三者多为平台运维/告警/展示功能，交互频率低，合并可减少运维单元。
  - 影响评估: 低到中等（改动仅影响内部注册与路由）；需合并 DB 表与统一 API 前缀。
  - 回归风险: 中（需验证通知逻辑、权限与dashboard数据权限）。
  - 估时: 3-5 PD

2) 合并候选: `config-service` + `auth-service` 的部分配置管理能力（保持 `auth-service` 专注认证）
  - 理由: 配置读取频繁且与认证相关，合并可减少跨服务调用延迟。
  - 影响评估: 中（需确保配置隔离与多环境支持）。
  - 回归风险: 中（若配置出错影响认证会有严重后果）。
  - 估时: 4 PD（谨慎进行）

3) 合并候选: 若 `common-test`、`common-util`、`common-gateway` 等为独立微服务，可合并为单一 `platform-shared` 工具包，改为库形式分发。
  - 理由: 这些服务多数为工具库，运行时不必作为独立服务存在，合并可显著减少容器数与维护成本。
  - 影响评估: 低（主要影响构建/发布流程，需要模块化打包）。
  - 估时: 2-4 PD

4) 合并候选（谨慎）: 小流量管理类服务（如 `cost-service`、`risk-service`）可合并为 `intelchain-aux`，保留核心模型/代理服务独立。
  - 理由: 降低运维单元，非实时业务可放在合并后的服务中按需扩展。
  - 影响评估: 中（需评估资源隔离与故障影响范围）。
  - 估时: 3-6 PD

4. 合并实施建议与步骤
1. 先做影响范围最小、回归风险低的合并（如 `notification`+`dashboard`）。
2. 在合并前绘制服务调用拓扑与SLO，编写回滚计划。使用链路追踪（Jaeger）收集真实调用图以验证推断。
3. 对每次合并执行压力测试、回归测试与安全审计。将合并纳入 CI 流程并在 Canary 环境逐步放量。

5. 结论
通过合并低耦合、低QPS的共享工具类服务与平台组件，可以在不牺牲可扩展性的前提下显著降低运维成本与部署复杂度。优先建议合并 `notification` 与 `dashboard`，以及将 `common-*` 工具以库形式分发。

如需，我可以继续：
- 生成基于代码/运行时的实际调用图（使用依赖扫描或分布式追踪数据）；
- 为每个合并候选生成详细迁移与回滚计划（含 DB 变更脚本）。
