# PoC：智数AI治理引擎独立化服务化方案

目标：将当前嵌入在 Java 进程内的 LangChain4j 驱动的 AI 治理能力拆出为独立服务，验证灵活伸缩、资源隔离、故障隔离与性能提升。

## PoC 目标与成功标准
- 独立部署为容器化微服务，支持水平伸缩。
- 与主系统通过 gRPC 或 REST 调用，认证与鉴权通过 `auth-service`。
- CPU-only 与 GPU 两种运行模式均能部署（PoC 以 CPU 模式为主）。
- 成功响应率 ≥ 99%，单实例在 4 CPU/8GB 下吞吐满足基础请求 50 RPS。

## 架构（Mermaid）

```mermaid
graph LR
  subgraph 用户层
    U[前端 / 调试客户端]
  end
  subgraph 网关
    GW[API Gateway]
  end
  subgraph 平台
    Auth[auth-service]
    Catalog[catalog-service]
    AIAPI[ai-governance-service]
    ES[Elasticsearch]
    VEC[向量DB(Milvus可选)]
  end
  U -->|API| GW -->|JWT| Auth
  GW --> Catalog
  Catalog -->|调用| AIAPI
  AIAPI --> ES
  AIAPI --> VEC
```

## 部署方案
- Docker 镜像: `liuhongke985/ai-governance:poC`（示例）
- K8s: Deployment + HPA（基于 CPU），Service ClusterIP，ResourceRequests: 500m CPU / 1024Mi；Limits: 2000m / 8Gi
- Config: 支持外部化配置（Nacos 或 ConfigMap），可切换 LLM 后端地址

## 接口草案（REST + gRPC）

REST 示例：
- POST /api/ai/governance/v1/analyze
  - 描述：对给定元数据或文本执行注释/归类/生成质量建议
  - 请求体：{ "type":"metadata|text", "payload":{...}, "context":{...} }
  - 返回：{ "taskId":"...", "result":{...}, "score":0.95 }

- POST /api/ai/governance/v1/rag
  - 描述：基于检索增强生成，返回自然语言回答
  - 请求体：{ "query":"...", "topK":5, "vectorStore":"es|milvus" }
  - 返回：{ "answer":"...", "sources":[{id,score,excerpt}] }

gRPC 示例 proto（简化）:

service AIGovernance {
  rpc Analyze(AnalyzeRequest) returns (AnalyzeResponse);
  rpc RAG(RAGRequest) returns (RAGResponse);
}

message AnalyzeRequest { string id = 1; string type = 2; bytes payload = 3; }
message AnalyzeResponse{ string id = 1; double score = 2; bytes result = 3; }

## 数据与向量存储
- 使用 Elasticsearch 作为初期向量/检索后端（PoC），并保留 Milvus 作为替换选项。
- 向量化模块可选用 SentenceTransformers 或接口化调用外部嵌入服务。

## 性能验证项
- 单实例在 4vCPU/8G 内存下可稳定处理 50 RPS（小请求）；响应 P95 ≤ 500ms（不含外部模型延迟）。
- 并发伸缩验证：HPA 在 CPU 使用率 >70% 时自动扩容。

## 监控与指标
- 埋点：请求量、错误率、平均/分位响应时延、模型调用延迟、向量索引延迟
- 集成 Prometheus 指标：/metrics

## 集成步骤（PoC）
1. 编写 Dockerfile 并构建镜像。
2. 部署至测试 k8s（或 docker-compose）并配置服务发现/网关路由。
3. 实现 REST/gRPC 接口并与 `catalog-service` 做简单调用示例。
4. 运行性能基线测试，采集指标并调优。

## 备注
- PoC 不必在首轮支持国密/信创特殊加密，但应设计好加密接口以供后续接入。
- 生产化需要加入限流、熔断、退避与隔离策略，以及模型托管与成本控制策略。
