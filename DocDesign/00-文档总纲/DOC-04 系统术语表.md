# DOC-04 系统术语表

> **文档编号**: DOC-04  
> **版本**: V2.0  
> **创建日期**: 2026-07-08  
> **最后修订**: 2026-07-08  
> **文档状态**: 正式发布  
> **文档负责人**: 项目管理办公室（PMO）  
> **审批人**: 项目总监  

---

## 一、术语管理说明

### 1.1 目的

本术语表为SmartWin智赢平台（IntelChain）项目提供统一的术语定义和解释，确保项目团队、客户、合作伙伴在沟通和文档中使用一致的术语体系。

### 1.2 适用范围

适用于项目全生命周期的所有文档、会议、沟通和培训材料。

### 1.3 术语分类

| 分类编号 | 分类名称 | 术语数量 | 说明 |
|:--------:|---------|:--------:|------|
| T-01 | 业务术语 | 25 | 数据治理、AI、商业模式相关 |
| T-02 | 技术术语 | 35 | 架构、开发、安全相关 |
| T-03 | 信创术语 | 20 | 国产化替代、国密算法相关 |
| T-04 | 管理术语 | 20 | 项目管理、PMO相关 |
| — | **合计** | **100** | — |

---

## 二、业务术语（T-01）

| 术语 | 英文/缩写 | 定义 |
|------|----------|------|
| 数据治理 | Data Governance | 对数据资产的管理行使权力和控制的活动集合，包括组织、制度、流程、工具 |
| 数据资产 | Data Asset | 企业拥有或控制的、能为企业带来未来经济利益的数据资源 |
| 数据要素 | Data Factor | 作为生产要素参与社会经济活动的数据资源，是国家战略层面的概念 |
| 数据编织 | Data Fabric | 一种数据架构模式，通过元数据驱动、AI辅助的方式实现跨数据源的统一数据访问 |
| 数据质量 | Data Quality | 数据满足使用要求的程度，包括准确性、完整性、一致性、及时性、唯一性、有效性 |
| 数据目录 | Data Catalog | 对企业数据资产进行编目、分类、描述和检索的系统 |
| 数据血缘 | Data Lineage | 数据从产生到消费的全链路追踪记录 |
| 数据脱敏 | Data Masking | 对敏感数据进行变形处理，使其在不影响使用的前提下无法还原原始数据 |
| 元数据管理 | Metadata Management | 对描述数据的数据（元数据）进行统一管理 |
| 主数据管理 | MDM | 对企业核心共享数据进行统一管理的流程和技术 |
| 数据仓库 | Data Warehouse | 面向主题的、集成的、非易失的、时变的数据集合 |
| 数据湖 | Data Lake | 以原生格式存储大量结构化和非结构化数据的存储系统 |
| 数据中台 | Data Middle Platform | 将数据能力沉淀、共享和复用的平台化架构 |
| 数据资产化 | Data Capitalization | 将数据资源转化为可计量、可交易、可增值的资产的过程 |
| 数据交易 | Data Trading | 以数据为标的物的买卖交换活动 |
| AI原生 | AI-Native | 在系统架构设计之初即将AI能力作为核心设计要素，而非事后集成 |
| Agentic治理 | Agentic Governance | 以AI Agent为核心驱动的数据治理模式，实现自主决策和执行 |
| 大模型 | LLM | 大语言模型，具有数十亿至数千亿参数的语言模型 |
| RAG | RAG | 检索增强生成，结合检索和生成能力提升AI输出准确性 |
| 数据飞轮 | Data Flywheel | 数据越多→模型越准→价值越大→用户越多→数据更多的正向循环 |
| 信创 | Xinchuang | 信息技术应用创新，即国产化替代，实现IT基础设施自主可控 |
| SaaS | SaaS | 软件即服务，通过云端提供软件应用 |
| 私有化部署 | On-Premise | 将软件部署在客户自有服务器上 |
| NPS | NPS | 净推荐值，衡量客户满意度和推荐意愿的指标 |
| LTV/CAC | LTV/CAC | 客户终身价值与获客成本之比，衡量商业模式健康度 |

---

## 三、技术术语（T-02）

| 术语 | 英文/缩写 | 定义 |
|------|----------|------|
| 微服务架构 | Microservices | 将应用拆分为独立部署、独立扩展的小型服务 |
| 服务网格 | Service Mesh | 处理服务间通信的专用基础设施层 |
| API网关 | API Gateway | 统一的API入口，负责路由、认证、限流、监控等 |
| 容器化 | Containerization | 将应用及其依赖打包到容器中，实现环境一致性和可移植性 |
| Kubernetes | K8s | 容器编排平台，负责容器的部署、扩展和管理 |
| CI/CD | CI/CD | 持续集成/持续交付，自动化构建、测试和部署流程 |
| 零信任 | Zero Trust | "永不信任，始终验证"的安全架构理念 |
| ETL | ETL | 提取-转换-加载，数据集成的基本流程 |
| CDC | CDC | 变更数据捕获，实时捕获数据变更的技术 |
| Flink | Apache Flink | 分布式流处理框架，支持实时数据处理 |
| Spark | Apache Spark | 分布式大数据处理框架 |
| vLLM | vLLM | 高性能大模型推理引擎 |
| Ollama | Ollama | 本地化大模型运行框架 |
| MoE | MoE | 混合专家模型，通过动态激活部分专家模型提升效率 |
| DAG | DAG | 有向无环图，用于任务编排和依赖管理 |
| GraphQL | GraphQL | API查询语言，支持客户端精确获取所需数据 |
| gRPC | gRPC | Google开源的高性能RPC框架 |
| Redis | Redis | 内存数据库，用于缓存和消息队列 |
| Kafka | Apache Kafka | 分布式消息队列系统 |
| Elasticsearch | ES | 分布式搜索和分析引擎 |
| Prometheus | Prometheus | 监控系统和时间序列数据库 |
| Grafana | Grafana | 数据可视化平台 |
| Loki | Loki | 日志聚合系统 |
| OpenTelemetry | OTel | 可观测性数据采集标准 |
| MyBatis | MyBatis | Java持久层框架 |
| Spring Cloud | Spring Cloud | 微服务开发框架集 |
| Spring Boot | Spring Boot | Java应用快速开发框架 |
| Vue.js | Vue.js | 渐进式前端框架 |
| TypeScript | TS | JavaScript的超集，添加了静态类型 |
| Pinia | Pinia | Vue状态管理库 |
| Vite | Vite | 前端构建工具 |
| TailwindCSS | TailwindCSS | 原子化CSS框架 |
| i18n | i18n | 国际化，支持多语言 |
| Web3 | Web3 | 基于区块链的去中心化网络 |
| NIST PQC | NIST PQC | 美国NIST后量子密码标准化项目 |

---

## 四、信创与安全术语（T-03）

| 术语 | 英文/缩写 | 定义 |
|------|----------|------|
| 信创 | Xinchuang | 信息技术应用创新产业，实现IT自主可控 |
| 国密算法 | Chinese Crypto | 国家密码管理局发布的密码算法标准 |
| SM2 | SM2 | 国密椭圆曲线公钥密码算法（非对称加密） |
| SM3 | SM3 | 国密密码杂凑算法（哈希） |
| SM4 | SM4 | 国密分组密码算法（对称加密） |
| SM9 | SM9 | 国密标识密码算法（基于标识的非对称加密） |
| 量子密钥分发 | QKD | 利用量子力学原理实现安全的密钥分发 |
| 后量子密码 | PQC | 能够抵抗量子计算机攻击的密码算法 |
| 等保三级 | MLPS Level 3 | 信息系统安全等级保护第三级 |
| 密码评估 | Crypto Assessment | 商用密码应用安全性评估 |
| 麒麟OS | Kylin OS | 国产Linux操作系统 |
| 统信UOS | UOS | 国产Linux操作系统 |
| 达梦数据库 | DMDB | 国产关系型数据库 |
| 人大金仓 | Kingbase | 国产关系型数据库 |
| 华为鲲鹏 | Kunpeng | 华为自主研发的ARM架构处理器 |
| 飞腾CPU | Phytium | 国产ARM架构处理器 |
| 海光CPU | Hygon | 国产x86架构处理器 |
| 信创认证 | Xinchuang Certification | 信创产品兼容性认证 |
| TLCP | TLCP | 传输层密码协议，国密版TLS |
| 可信计算 | Trusted Computing | 通过硬件信任根实现系统可信 |

---

## 五、项目管理术语（T-04）

| 术语 | 英文/缩写 | 定义 |
|------|----------|------|
| PMO | PMO | 项目管理办公室 |
| Sprint | Sprint | Scrum中的迭代周期，通常1-4周 |
| Scrum | Scrum | 敏捷开发框架 |
| Epic | Epic | 大型用户故事，需拆分为多个Story |
| User Story | User Story | 从用户视角描述需求的简短叙述 |
| MVP | MVP | 最小可行产品 |
| 里程碑 | Milestone | 项目中的重要时间节点或事件 |
| 基线 | Baseline | 经过审批的项目计划、范围或产品的快照 |
| 变更控制 | Change Control | 对项目变更进行识别、评估、审批和实施的过程 |
| 风险登记册 | Risk Register | 记录所有已识别风险及其应对策略的文档 |
| RACI | RACI | 责任分配矩阵：负责、审批、咨询、知情 |
| WBS | WBS | 工作分解结构 |
| KPI | KPI | 关键绩效指标 |
| OKR | OKR | 目标与关键结果 |
| SLA | SLA | 服务等级协议 |
| SLO | SLO | 服务等级目标 |
| 甘特图 | Gantt Chart | 项目进度可视化工具 |
| 燃尽图 | Burndown Chart | 显示剩余工作量的图表 |
| DoD | DoD | 完成定义，判断工作是否完成的标准 |
| 干系人 | Stakeholder | 受项目影响或能影响项目的个人或组织 |

---

## 六、缩写速查

| 缩写 | 全称 | 中文 |
|------|------|------|
| BRD | Business Requirements Document | 业务需求说明书 |
| SRS | Software Requirements Specification | 软件需求规格说明书 |
| ADR | Architecture Decision Record | 架构决策记录 |
| UAT | User Acceptance Testing | 用户验收测试 |
| TCO | Total Cost of Ownership | 总拥有成本 |
| ROI | Return on Investment | 投资回报率 |
| IRR | Internal Rate of Return | 内部收益率 |
| NPV | Net Present Value | 净现值 |
| TAM | Total Addressable Market | 总可触达市场 |
| SAM | Serviceable Available Market | 可服务市场 |
| SOM | Serviceable Obtainable Market | 可获得市场 |
| CAGR | Compound Annual Growth Rate | 复合年增长率 |
| Mau | Monthly Active Users | 月活跃用户 |
| CAC | Customer Acquisition Cost | 获客成本 |
| ARPU | Average Revenue Per User | 每用户平均收入 |

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-08 | PMO | 初始版本发布，100个术语 |
| V2.0 | 2026-07-08 | PMO | 补充国密安全、MoE、Web3等V2.0新增术语 |
