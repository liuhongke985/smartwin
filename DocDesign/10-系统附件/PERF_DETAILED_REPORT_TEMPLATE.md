# 压测详细报告模板

## 1. 报告概要
- 报告名称：
- 编写人：
- 日期：
- 测试目标：简述此次压测的目的（验证容量/基线/回归/稳定性/峰值承载）
- 结论摘要：一段 2-4 行的关键结论（是否通过、主要瓶颈、建议）

## 2. 测试环境与前提
- 被测服务版本/分支：
- 部署方式：本地 Mock / Docker Compose / Kubernetes（填写具体 manifest/镜像）
- 基础设施：CPU、内存、磁盘、网络带宽说明（若为本地，注明 VM/主机规格）
- 依赖服务及版本：Elasticsearch、Neo4j、Redis、DM8/MySQL、LLM（若有）
- 数据规模：资产数量、索引大小、示例数据路径（如 `scripts/data/*.jsonl`）
- 监控采集：是否启用 Prometheus/Grafana、采样粒度、采集点

## 3. 测试工具与脚本
- 工具：`k6` / `scripts/load/run_load_test.py`（aiohttp 替代）
- 脚本路径：`scripts/k6/search_test.js`、`scripts/load/run_load_test.py`
- 数据生成脚本：`scripts/data/gen_assets.py`
- 运行命令（示例）：

```bash
# 使用本地 Python 压测器
python3 scripts/load/run_load_test.py --vus 200 --duration 120 --base http://localhost:9000/api/smartdata

# 使用 k6（若环境可用）
k6 run --vus 200 --duration 2m scripts/k6/search_test.js --out json=results/k6_results.json
```

## 4. 测试场景与负载模型
- 场景 A：搜索查询（比例 X%）
- 场景 B：metadata 查询（比例 Y%）
- 场景 C：写入/更新（如需）
- 负载曲线：阶跃/恒定/阶梯/峰值（说明每个阶段的 VU 与持续时间）

## 5. 配置参数（本次测试）
- 并发 VUs：200
- 持续时间：120s
- 请求分布：请求比例、目标 URL（例：`/api/smartdata/search` 70%，`/api/smartdata/metadata/{id}` 30%）
- 其它：连接池、超时、重试策略

## 6. 原始结果（摘要）
- 总请求数：
- 成功/失败：
- 平均延迟（ms）：
- P50/P90/P95/P99（ms）：
- 吞吐（req/s）：
- 错误类型分解（HTTP 状态码、超时、连接错误等）

（示例已填）
- 总请求数: 47064
- 错误数: 0 (0.00%)
- 平均延迟: 8.37 ms
- P95: 30.50 ms
- P99: 162.79 ms

## 7. 关键指标时间序列与图表
- 提供以下图表（若有 Prometheus 或 k6 输出文件，可生成）：
  - 并发用户数（VU）随时间变化
  - 请求吞吐（req/s）随时间变化
  - 平均/中位/P95/P99 延迟随时间变化
  - 错误率随时间变化
  - 后端资源使用：CPU、内存、GC（JVM）、磁盘 I/O、网络带宽

（附：若没有图表，说明如何用 k6/CSV/Prometheus 生成）

## 8. 详细结果与样本（可附文件）
- k6 输出文件路径：results/k6_results.json
- Python 压测输出：results/local_load_200x120.txt
- 监控采样文件路径：prometheus/scrape_*.yaml / grafana/export_*.json

## 9. 分析与诊断
- 延迟分布分析（哪类请求占用大部分 P99）
- 资源相关性（CPU/GC/IO 与延迟关系）
- 失败根因（若有）
- 重点怀疑点：例如 ES 查询慢、LLM 响应时间高、数据库锁竞争

## 10. 风险与影响等级
- 高风险项：会影响可用性/数据一致性/安全
- 中低风险项：性能衰减、临时超时等

## 11. 建议与缓解措施
- 短期（可在下一次迭代内完成）：参数调整、连接池、缓存策略
- 中期（架构调整）：查询优化、分片/索引调整、服务拆分
- 长期（容量规划）：水平扩缩容、异步化、后端资源独立化

## 12. 重现步骤（操作手册）
1. 启动 Mock 服务：

```bash
python3 -m uvicorn scripts.mock.server:app --host 0.0.0.0 --port 9000
```

2. 生成测试数据（如需）：

```bash
python3 scripts/data/gen_assets.py --count 100000 --out data/assets.jsonl
```

3. 运行压测（示例）：

```bash
python3 scripts/load/run_load_test.py --vus 200 --duration 120 --base http://localhost:9000/api/smartdata
```

4. 收集监控并导出结果，合并至本报告

## 13. 附件与工件清单
- 本次压测脚本：`scripts/load/run_load_test.py`
- k6 脚本（备用）：`scripts/k6/search_test.js`
- 数据生成：`scripts/data/gen_assets.py`
- 原始结果文件：results/

## 14. 下一步建议的实验项
- 在包含 ES 与 Neo4j 的真实测试环境重复本次场景
- 对不同数据规模（100k/1M/10M）做横向对比
- 增加后端探针（JVM GC、ES slowlog、DB slow query）并复测

----
（使用说明：将本文件复制为具体测报告并替换各处占位内容；可结合 `results/` 中的原始输出生成图表）
