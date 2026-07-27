# 压测计划与脚本（概要）

## 目标
- 建立全文搜索、关键REST API（catalog/search、lineage/解析）、AI RAG接口的性能基线
- 验证系统在百万级资产下搜索响应与并发用户场景（500 并发）

## 场景
1. 搜索场景（ES）：模拟用户全文检索并翻页（高并发）
2. API 场景：catalog 查询、metadata 拉取、lineage 解析（复杂任务并发）
3. AI 场景：RAG 请求（需模拟向量查询和LLM响应延迟）

## 数据规模建议
- 资产（documents）: 1,000,000 条
- 元数据字段: 每条包含 15-30 字段
- 向量索引: 1,000,000 向量

## 工具
- k6（主脚本）：轻量化、易集成CI
- 可选：JMeter（用于复杂事务录制）

## 可执行脚本
- k6 主脚本路径: `scripts/k6/search_test.js`
- 数据生成脚本: `scripts/data/gen_assets.py`

### k6 示例脚本说明
- 场景: ramp-up 1m -> sustain 5m -> ramp-down 1m
- 目标: 最大 500 VUs（虚拟用户），按场景分配

脚本已保存：`scripts/k6/search_test.js`
数据生成脚本已保存：`scripts/data/gen_assets.py`

## 执行步骤
1. 在测试环境准备 ES 索引并通过 `gen_assets.py` 导入数据（或使用 Bulk API）
2. 启动目标服务（gateway + es + services）
3. 运行 k6：

```bash
k6 run scripts/k6/search_test.js
```

4. 收集指标（k6 输出 + Prometheus 数据），生成报告并对比 SLO

## k6 脚本（简化，见 scripts/k6/search_test.js）

## 数据生成脚本（Python）说明
- 生成 JSON Lines 文件，符合 ES bulk 导入格式
- 支持并发写入与伪造标签/权限/质量评分字段

