# 监控告警手册

## 文档控制

| 信息项 | 内容 |
|--------|------|
| **文档编号** | OPS-04 |
| **文档版本** | V1.0 |
| **创建日期** | 2026-07-08 |
| **最后修订** | 2026-07-08 |
| **文档状态** | 正式发布 |
| **文档负责人** | DevOps |
| **审批人** | 运维Lead |

---

## 1. 监控架构

### 1.1 监控体系

```
┌─────────────────────────────────────────┐
│              Grafana (可视化)            │
├────────────┬────────────┬───────────────┤
│ Prometheus │   Loki     │  AlertManager │
│ (指标)     │  (日志)    │   (告警)      │
├────────────┴────────────┴───────────────┤
│            数据采集层                    │
│  ┌──────────┬──────────┬──────────┐    │
│  │ Node     │ JMX      │ Docker   │    │
│  │ Exporter │ Exporter │ Stats    │    │
│  └──────────┴──────────┴──────────┘    │
├─────────────────────────────────────────┤
│            被监控目标                    │
│  22个微服务 + DM8 + Redis + ES + Neo4j  │
└─────────────────────────────────────────┘
```

### 1.2 监控组件

| 组件 | 版本 | 用途 | 端口 |
|------|------|------|:----:|
| Prometheus | 2.50+ | 指标采集存储 | 9090 |
| Grafana | 10.4+ | 可视化仪表盘 | 3000 |
| Loki | 3.0+ | 日志聚合 | 3100 |
| AlertManager | 0.27+ | 告警管理 | 9093 |
| Node Exporter | 1.7+ | 主机指标 | 9100 |

---

## 2. 监控指标

### 2.1 主机指标

| 指标 | PromQL | 告警阈值 |
|------|--------|----------|
| CPU使用率 | `100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)` | >80% 持续5min |
| 内存使用率 | `(1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100` | >85% 持续5min |
| 磁盘使用率 | `(1 - node_filesystem_avail_bytes / node_filesystem_size_bytes) * 100` | >80% 持续10min |
| 磁盘IO | `rate(node_disk_io_time_seconds_total[5m])` | >0.8 持续5min |
| 网络流量 | `rate(node_network_receive_bytes_total[5m])` | >100MB/s |

### 2.2 应用指标

| 指标 | 来源 | 告警阈值 |
|------|------|----------|
| 服务存活 | `/actuator/health` | DOWN 持续1min |
| JVM堆内存 | JMX Exporter | >85% 持续5min |
| JVM GC时间 | JMX Exporter | Full GC >5s |
| API响应时间 | Micrometer | P95 >500ms 持续5min |
| API错误率 | Micrometer | 5xx >1% 持续2min |
| 线程池活跃 | JMX Exporter | 活跃线程>80%最大 |

### 2.3 数据库指标

| 指标 | 说明 | 告警阈值 |
|------|------|----------|
| 连接数 | 活跃数据库连接 | >80%最大连接 |
| 慢查询 | 执行时间>1s的SQL | >10/min |
| 表空间 | 表空间使用率 | >80% |
| 锁等待 | 锁等待事件 | >5/min |

### 2.4 中间件指标

| 组件 | 指标 | 告警阈值 |
|------|------|----------|
| Redis | 内存使用率 | >80% |
| Redis | 连接数 | >80%最大 |
| ES | 集群状态 | 非green |
| ES | 堆内存 | >85% |
| Neo4j | 活跃事务 | >100 |
| MinIO | 磁盘使用 | >80% |

---

## 3. Grafana仪表盘

### 3.1 仪表盘规划

| 仪表盘 | 说明 | 刷新频率 |
|--------|------|:--------:|
| 系统总览 | 全部服务状态总览 | 30s |
| 主机监控 | CPU/内存/磁盘/网络 | 30s |
| 微服务监控 | 各服务JVM/API指标 | 30s |
| 数据库监控 | DM8连接/慢SQL/表空间 | 1min |
| 中间件监控 | Redis/ES/Neo4j/MinIO | 1min |
| AI引擎监控 | 检测QPS/延迟/成本 | 30s |
| 审计日志 | 操作审计统计 | 5min |

### 3.2 核心仪表盘面板

**系统总览仪表盘**：
- 服务状态列表（绿/红）
- API总QPS趋势
- API错误率趋势
- 主机资源使用率
- 最近告警列表

---

## 4. 告警规则

### 4.1 告警级别

| 级别 | 说明 | 通知方式 | 响应时间 |
|:----:|------|----------|:--------:|
| P0-致命 | 系统不可用 | 电话+飞书+邮件 | 5min |
| P1-严重 | 核心功能异常 | 飞书+邮件 | 15min |
| P2-警告 | 性能下降 | 飞书 | 30min |
| P3-提示 | 容量预警 | 邮件 | 4h |

### 4.2 Prometheus告警规则

```yaml
# prometheus/rules/smartwin-alerts.yml
groups:
  - name: smartwin-service
    rules:
      # 服务宕机
      - alert: ServiceDown
        expr: up{job="smartwin-services"} == 0
        for: 1m
        labels:
          severity: P0
        annotations:
          summary: "服务 {{ $labels.instance }} 宕机"
          description: "{{ $labels.service }} 已离线超过1分钟"

      # API高错误率
      - alert: HighErrorRate
        expr: |
          sum(rate(http_server_requests_seconds_count{status=~"5.."}[5m])) by (service)
          / sum(rate(http_server_requests_seconds_count[5m])) by (service) > 0.01
        for: 2m
        labels:
          severity: P1
        annotations:
          summary: "{{ $labels.service }} API错误率超过1%"
          description: "当前错误率: {{ $value }}%"

      # JVM内存告警
      - alert: JvmMemoryHigh
        expr: |
          jvm_memory_used_bytes{area="heap"} / jvm_memory_max_bytes{area="heap"} > 0.85
        for: 5m
        labels:
          severity: P2
        annotations:
          summary: "{{ $labels.service }} JVM堆内存使用率超过85%"

      # API响应慢
      - alert: ApiSlowResponse
        expr: |
          histogram_quantile(0.95, rate(http_server_requests_seconds_bucket[5m])) > 0.5
        for: 5m
        labels:
          severity: P2
        annotations:
          summary: "{{ $labels.service }} API P95响应时间超过500ms"

  - name: smartwin-infrastructure
    rules:
      # 主机CPU高
      - alert: HighCpuUsage
        expr: 100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: P2
        annotations:
          summary: "主机 {{ $labels.instance }} CPU使用率超过80%"

      # 磁盘空间不足
      - alert: DiskSpaceLow
        expr: |
          (1 - node_filesystem_avail_bytes / node_filesystem_size_bytes) * 100 > 80
        for: 10m
        labels:
          severity: P1
        annotations:
          summary: "磁盘 {{ $labels.mountpoint }} 使用率超过80%"

      # 数据库连接数高
      - alert: DbConnectionsHigh
        expr: dm_db_active_connections / dm_db_max_connections > 0.8
        for: 5m
        labels:
          severity: P2
        annotations:
          summary: "DM8数据库连接数超过80%"
```

### 4.3 AlertManager配置

```yaml
# alertmanager.yml
route:
  group_by: ['alertname', 'service']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h
  receiver: 'default'
  routes:
    - matchers: ['severity=P0']
      receiver: 'phone-feishu-email'
      group_wait: 0s
    - matchers: ['severity=P1']
      receiver: 'feishu-email'
    - matchers: ['severity=P2']
      receiver: 'feishu'
    - matchers: ['severity=P3']
      receiver: 'email'

receivers:
  - name: 'phone-feishu-email'
    webhook_configs:
      - url: 'https://open.feishu.cn/open-apis/bot/v2/hook/xxx'
    email_configs:
      - to: 'ops@smartwin.com'

  - name: 'feishu-email'
    webhook_configs:
      - url: 'https://open.feishu.cn/open-apis/bot/v2/hook/xxx'
    email_configs:
      - to: 'ops@smartwin.com'

  - name: 'feishu'
    webhook_configs:
      - url: 'https://open.feishu.cn/open-apis/bot/v2/hook/xxx'

  - name: 'email'
    email_configs:
      - to: 'ops@smartwin.com'

  - name: 'default'
    webhook_configs:
      - url: 'https://open.feishu.cn/open-apis/bot/v2/hook/xxx'
```

---

## 5. 告警处理流程

### 5.1 处理流程

```
告警触发 → 告警通知 → 确认接收 → 排查定位 → 处理恢复 → 确认解除 → 记录归档
              │            │          │           │           │
          飞书/邮件     5min内     查看日志    执行修复    验证恢复
                       确认       查看指标    或升级      关闭告警
```

### 5.2 告警处理规范

| 步骤 | 说明 | 时限 |
|:----:|------|:----:|
| 确认接收 | 在飞书群回复"收到，处理中" | P0: 5min / P1: 15min |
| 初步定位 | 查看日志和指标，定位问题 | P0: 15min / P1: 30min |
| 处理恢复 | 执行修复操作 | P0: 30min / P1: 2h |
| 确认恢复 | 验证服务恢复正常 | 处理后立即 |
| 记录归档 | 填写故障处理记录 | 24h内 |

### 5.3 升级机制

| 时限 | P0 | P1 |
|:----:|:---|:---|
| 未确认 | 5min→电话升级至运维Lead | 15min→飞书@运维Lead |
| 未恢复 | 30min→升级至架构师 | 2h→升级至运维Lead |
| 重大故障 | 1h→升级至项目总监 | 4h→升级至架构师 |

---

## 6. 日志查询指南

### 6.1 Loki日志查询（通过Grafana）

```
# 查看某服务错误日志
{container="auth-service"} |= "ERROR"

# 查看某服务异常堆栈
{container="model-service"} |= "Exception"

# 查看慢请求
{container="gateway"} |= "慢请求" or {container="gateway"} |= "slow"

# 多服务联合查询
{container=~"auth-service|system-service"} |= "ERROR"

# 时间范围查询
{container="catalog-service"} |= "timeout" | json | line_format "{{.timestamp}} {{.message}}"
```

### 6.2 日志关键字告警

| 关键字 | 含义 | 告警级别 |
|--------|------|:--------:|
| `OutOfMemoryError` | JVM内存溢出 | P0 |
| `StackOverflowError` | 栈溢出 | P0 |
| `Connection refused` | 连接被拒绝 | P1 |
| `Deadlock` | 死锁 | P0 |
| `Disk full` | 磁盘满 | P0 |
| `Too many connections` | 连接数超限 | P1 |

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-08 | DevOps | 初始版本发布 |
