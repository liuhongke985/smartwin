# ENV-03 环境验证与验收规程

> **文档编号**: ENV-03
> **版本**: V1.0
> **创建日期**: 2026-07-09
> **文档状态**: 正式发布
> **文档负责人**: QA负责人

---

## 1. 验证体系概述

### 1.1 验证层次

```
┌─────────────────────────────────────────────────────────┐
│                  环境验证五层模型                          │
├─────────────────────────────────────────────────────────┤
│  L5: 业务场景验证 — 端到端业务流程通过                     │
│  L4: 集成验证    — 服务间调用+数据一致性                  │
│  L3: 服务验证    — 每个微服务健康+API可用                 │
│  L2: 组件验证    — 中间件功能+性能+安全                   │
│  L1: 基础验证    — OS+网络+存储+容器+K8s                 │
└─────────────────────────────────────────────────────────┘
```

### 1.2 验收标准矩阵

| 验证层 | 验证项数 | 通过标准 | 验证人 | 验收人 |
|:------:|:--------:|---------|--------|--------|
| L1-基础 | 30项 | 100%通过 | DevOps | 运维负责人 |
| L2-组件 | 25项 | 100%通过 | DevOps | 架构师 |
| L3-服务 | 22项 | 100%通过 | 开发 | 测试Lead |
| L4-集成 | 15项 | 100%通过 | 测试 | 架构师 |
| L5-业务 | 10项 | 100%通过 | 业务 | 产品经理 |

---

## 2. L1 基础设施验证

### 2.1 操作系统验证

| 序号 | 验证项 | 验证方法 | 预期结果 | 实际结果 | 状态 |
|:----:|--------|---------|---------|---------|:----:|
| 1 | OS版本 | `cat /etc/os-release` | 麒麟V10/CentOS 7.9+ | | ☐ |
| 2 | 内核版本 | `uname -r` | ≥ 4.19 | | ☐ |
| 3 | CPU核心数 | `nproc` | 符合规划 | | ☐ |
| 4 | 内存大小 | `free -h` | 符合规划 | | ☐ |
| 5 | 磁盘空间 | `df -h` | / ≥200G, /data ≥2T | | ☐ |
| 6 | Swap状态 | `swapon -s` | 空列表(已关闭) | | ☐ |
| 7 | SELinux | `getenforce` | Disabled | | ☐ |
| 8 | 防火墙 | `systemctl status firewalld` | inactive | | ☐ |
| 9 | 文件描述符 | `ulimit -n` | ≥ 655360 | | ☐ |
| 10 | 最大进程 | `ulimit -u` | ≥ 655360 | | ☐ |
| 11 | 时间同步 | `chronyc tracking` | 偏差 < 50ms | | ☐ |
| 12 | 内核参数 | `sysctl -a \| grep somaxconn` | 65535 | | ☐ |

### 2.2 网络验证

| 序号 | 验证项 | 验证方法 | 预期结果 | 状态 |
|:----:|--------|---------|---------|:----:|
| 1 | 节点互通 | `ping <node-ip>` | 0% packet loss | ☐ |
| 2 | DNS解析 | `nslookup kubernetes.default` | 解析成功 | ☐ |
| 3 | 内网带宽 | `iperf3 -c <node>` | ≥ 9Gbps(万兆) | ☐ |
| 4 | 端口连通 | `nc -zv <ip> <port>` | 指定端口可达 | ☐ |
| 5 | 防火墙规则 | `iptables -L -n` | 仅必要端口 | ☐ |
| 6 | SSL证书 | `openssl s_client -connect` | 有效期>90天 | ☐ |

### 2.3 存储验证

| 序号 | 验证项 | 验证方法 | 预期结果 | 状态 |
|:----:|--------|---------|---------|:----:|
| 1 | 磁盘IOPS | `fio --name=test --rw=randwrite --bs=4k --size=1G` | ≥ 5000 IOPS(SSD) | ☐ |
| 2 | 磁盘吞吐 | `dd if=/dev/zero of=/data/test bs=1M count=1024` | ≥ 500MB/s | ☐ |
| 3 | NFS挂载 | `mount -t nfs` | 挂载成功 | ☐ |
| 4 | PV动态供给 | `kubectl get pvc` | Bound状态 | ☐ |
| 5 | 存储类 | `kubectl get sc` | 默认SC存在 | ☐ |

### 2.4 K8s集群验证

| 序号 | 验证项 | 验证方法 | 预期结果 | 状态 |
|:----:|--------|---------|---------|:----:|
| 1 | 节点状态 | `kubectl get nodes` | All Ready | ☐ |
| 2 | 组件状态 | `kubectl get componentstatus` | All Healthy | ☐ |
| 3 | CoreDNS | `kubectl get pods -n kube-system \| grep coredns` | Running | ☐ |
| 4 | Calico | `kubectl get pods -n calico-system` | All Running | ☐ |
| 5 | Pod网络 | `kubectl exec test -- ping <pod-ip>` | 可达 | ☐ |
| 6 | Service网络 | `kubectl exec test -- curl <svc-ip>` | 可达 | ☐ |
| 7 | DNS解析 | `kubectl exec test -- nslookup kubernetes` | 解析成功 | ☐ |
| 8 | HPA | `kubectl get hpa -A` | HPA规则存在 | ☐ |
| 9 | PDB | `kubectl get pdb -A` | PDB规则存在 | ☐ |
| 10 | 命名空间 | `kubectl get ns` | smartwin命名空间存在 | ☐ |

---

## 3. L2 中间件验证

### 3.1 DM8数据库验证

| 序号 | 验证项 | 验证方法 | 预期结果 | 状态 |
|:----:|--------|---------|---------|:----:|
| 1 | 连接测试 | `disql SYSDBA/pass@host:5236` | 连接成功 | ☐ |
| 2 | 版本查询 | `SELECT * FROM v$version;` | DM8 8.1.x | ☐ |
| 3 | 表空间 | `SELECT * FROM dba_tablespaces;` | SMARTWIN表空间存在 | ☐ |
| 4 | 用户权限 | `SELECT * FROM dba_users;` | SMARTWIN用户存在 | ☐ |
| 5 | 归档模式 | `SELECT arch_mode FROM v$database;` | ARCHIVELOG | ☐ |
| 6 | 字符集 | `SELECT unicode FROM v$nls_parameters;` | UTF-8 | ☐ |
| 7 | 连接数 | `SELECT count(*) FROM v$sessions;` | < 80%最大连接 | ☐ |
| 8 | 慢查询 | 查询v$long_exec_sql | 无>5s慢查询 | ☐ |
| 9 | 表结构 | 验证所有DDL | 所有表已创建 | ☐ |
| 10 | 初始数据 | 验证初始数据 | 字典/菜单/角色已初始化 | ☐ |

### 3.2 Redis集群验证

| 序号 | 验证项 | 验证方法 | 预期结果 | 状态 |
|:----:|--------|---------|---------|:----:|
| 1 | 集群状态 | `CLUSTER INFO` | cluster_state:ok | ☐ |
| 2 | 节点信息 | `CLUSTER NODES` | 6节点(3主3从) | ☐ |
| 3 | 槽位分配 | `CLUSTER SLOTS` | 16384槽全分配 | ☐ |
| 4 | 读写测试 | `SET test_key test_value` / `GET test_key` | 读写成功 | ☐ |
| 5 | 故障转移 | 关闭一个主节点 | 自动切换到从节点 | ☐ |
| 6 | 内存使用 | `INFO memory` | used_memory < maxmemory | ☐ |
| 7 | 持久化 | `INFO persistence` | RDB+AOF开启 | ☐ |
| 8 | 密码认证 | `AUTH password` | 认证成功 | ☐ |

### 3.3 Elasticsearch验证

| 序号 | 验证项 | 验证方法 | 预期结果 | 状态 |
|:----:|--------|---------|---------|:----:|
| 1 | 集群健康 | `GET _cluster/health` | status: green | ☐ |
| 2 | 节点列表 | `GET _cat/nodes` | 3节点 | ☐ |
| 3 | 索引列表 | `GET _cat/indices` | 预置索引存在 | ☐ |
| 4 | 分片分配 | `GET _cat/shards` | 无unassigned | ☐ |
| 5 | 搜索测试 | `POST test-index/_search` | 搜索正常 | ☐ |
| 6 | 安全认证 | `GET _security/user` | elastic用户存在 | ☐ |
| 7 | 磁盘水位 | `GET _cluster/stats` | disk < 85% | ☐ |

### 3.4 其他中间件验证

| 序号 | 组件 | 验证项 | 预期结果 | 状态 |
|:----:|------|--------|---------|:----:|
| 1 | Neo4j | 连接测试 | 连接成功 | ☐ |
| 2 | Neo4j | Cypher查询 | `RETURN 1` 返回1 | ☐ |
| 3 | MinIO | Bucket列表 | smartwin bucket存在 | ☐ |
| 4 | MinIO | 上传测试 | 文件上传成功 | ☐ |
| 5 | Nacos | 配置列表 | smartwin配置存在 | ☐ |
| 6 | Nacos | 服务列表 | 所有服务已注册 | ☐ |
| 7 | Kafka | Topic列表 | smartwin-* topic存在 | ☐ |
| 8 | Kafka | 生产消费测试 | 消息生产+消费成功 | ☐ |
| 9 | Kafka | 消费者组 | smartwin消费者组存在 | ☐ |
| 10 | Kafka | 分区数 | 每个Topic ≥ 3分区 | ☐ |

---

## 4. L3 服务验证

### 4.1 微服务健康验证

| 序号 | 服务 | 健康检查 | 预期结果 | 状态 |
|:----:|------|---------|---------|:----:|
| 1 | gateway | `GET /actuator/health` | {"status":"UP"} | ☐ |
| 2 | auth-service | `GET /actuator/health` | {"status":"UP"} | ☐ |
| 3 | system-service | `GET /actuator/health` | {"status":"UP"} | ☐ |
| 4 | security-service | `GET /actuator/health` | {"status":"UP"} | ☐ |
| 5 | audit-service | `GET /actuator/health` | {"status":"UP"} | ☐ |
| 6 | config-service | `GET /actuator/health` | {"status":"UP"} | ☐ |
| 7 | notification-service | `GET /actuator/health` | {"status":"UP"} | ☐ |
| 8 | dashboard-service | `GET /actuator/health` | {"status":"UP"} | ☐ |
| 9 | model-service | `GET /actuator/health` | {"status":"UP"} | ☐ |
| 10 | app-service | `GET /actuator/health` | {"status":"UP"} | ☐ |
| 11 | agent-service | `GET /actuator/health` | {"status":"UP"} | ☐ |
| 12 | cost-service | `GET /actuator/health` | {"status":"UP"} | ☐ |
| 13 | risk-service | `GET /actuator/health` | {"status":"UP"} | ☐ |
| 14 | catalog-service | `GET /actuator/health` | {"status":"UP"} | ☐ |
| 15 | metadata-service | `GET /actuator/health` | {"status":"UP"} | ☐ |
| 16 | quality-service | `GET /actuator/health` | {"status":"UP"} | ☐ |
| 17 | standard-service | `GET /actuator/health` | {"status":"UP"} | ☐ |
| 18 | lineage-service | `GET /actuator/health` | {"status":"UP"} | ☐ |
| 19 | master-data-service | `GET /actuator/health` | {"status":"UP"} | ☐ |
| 20 | data-api-service | `GET /actuator/health` | {"status":"UP"} | ☐ |
| 21 | asset-service | `GET /actuator/health` | {"status":"UP"} | ☐ |
| 22 | ai-engine | `GET /health` | {"status":"healthy"} | ☐ |

### 4.2 API可用性验证

| 序号 | API | 方法 | 预期响应 | 状态 |
|:----:|-----|:----:|---------|:----:|
| 1 | /api/auth/login | POST | 200 + Token | ☐ |
| 2 | /api/auth/refresh | POST | 200 + New Token | ☐ |
| 3 | /api/system/users | GET | 200 + 用户列表 | ☐ |
| 4 | /api/system/menus | GET | 200 + 菜单树 | ☐ |
| 5 | /api/models | GET | 200 + 模型列表 | ☐ |
| 6 | /api/models/{id} | GET | 200 + 模型详情 | ☐ |
| 7 | /api/apps | GET | 200 + 应用列表 | ☐ |
| 8 | /api/agents | GET | 200 + Agent列表 | ☐ |
| 9 | /api/prompts | GET | 200 + Prompt列表 | ☐ |
| 10 | /api/cost/summary | GET | 200 + 成本汇总 | ☐ |
| 11 | /api/catalog/assets | GET | 200 + 资产目录 | ☐ |
| 12 | /api/metadata/tables | GET | 200 + 元数据表 | ☐ |
| 13 | /api/quality/rules | GET | 200 + 质量规则 | ☐ |
| 14 | /api/lineage/graph | GET | 200 + 血缘图 | ☐ |
| 15 | /api/audit/logs | GET | 200 + 审计日志 | ☐ |

---

## 5. L4 集成验证

| 序号 | 集成场景 | 验证方法 | 预期结果 | 状态 |
|:----:|---------|---------|---------|:----:|
| 1 | 认证→系统管理 | 登录后获取菜单 | 菜单根据角色过滤 | ☐ |
| 2 | 认证→安全 | Token验证 | 过期Token被拒绝 | ☐ |
| 3 | 模型管理→AI引擎 | 调用模型推理 | 返回推理结果 | ☐ |
| 4 | 应用管理→模型管理 | 应用关联模型 | 模型切换生效 | ☐ |
| 5 | Agent→工具箱 | Agent调用工具 | 工具执行成功 | ☐ |
| 6 | 成本管控→AI引擎 | Token计费 | 成本记录准确 | ☐ |
| 7 | 安全检测→AI引擎 | 内容安全检测 | 敏感内容被拦截 | ☐ |
| 8 | 审计→所有服务 | 操作审计 | 审计日志完整记录 | ☐ |
| 9 | 数据目录→ES | 全文搜索 | 搜索结果准确 | ☐ |
| 10 | 数据血缘→Neo4j | 血缘图查询 | 血缘关系正确 | ☐ |
| 11 | 数据质量→通知 | 质量告警 | 告警通知发送 | ☐ |
| 12 | 配置中心→所有服务 | 配置更新 | 服务动态感知 | ☐ |
| 13 | Kafka→消费者 | 消息消费 | 消息处理成功 | ☐ |
| 14 | MinIO→文件服务 | 文件上传下载 | 文件操作正常 | ☐ |
| 15 | 监控→所有服务 | 指标采集 | Grafana看板有数据 | ☐ |

---

## 6. L5 业务场景验证

| 序号 | 业务场景 | 验证步骤 | 预期结果 | 状态 |
|:----:|---------|---------|---------|:----:|
| 1 | 用户登录全流程 | 输入账号→密码→验证码→登录 | 登录成功,返回Token+菜单 | ☐ |
| 2 | AI模型注册调用 | 注册模型→配置路由→测试调用 | 模型调用成功,成本记录 | ☐ |
| 3 | Agent创建执行 | 创建Agent→编排工具→执行 | Agent执行成功,结果正确 | ☐ |
| 4 | 数据资产编目 | 创建目录→注册资产→搜索 | 资产可搜索可查看 | ☐ |
| 5 | 数据质量检测 | 创建规则→执行检测→查看报告 | 质量评分+问题列表 | ☐ |
| 6 | 数据血缘查看 | 查看表级→字段级血缘 | 血缘图正确展示 | ☐ |
| 7 | 成本分析报表 | 选择时间→查看报表→导出 | 报表数据准确 | ☐ |
| 8 | 安全审计查询 | 查询操作日志→筛选→导出 | 审计日志完整 | ☐ |
| 9 | 权限配置验证 | 配置角色→分配权限→验证 | 权限控制生效 | ☐ |
| 10 | 系统监控看板 | 查看Grafana→检查告警 | 看板数据正常 | ☐ |

---

## 7. 环境验收签字

### 7.1 验收记录

| 验证层 | 总项数 | 通过数 | 失败数 | 通过率 | 验证人 | 验收人 | 日期 | 签字 |
|:------:|:------:|:------:|:------:|:------:|--------|--------|------|:----:|
| L1-基础 | 30 | | | | | | | |
| L2-组件 | 25 | | | | | | | |
| L3-服务 | 22 | | | | | | | |
| L4-集成 | 15 | | | | | | | |
| L5-业务 | 10 | | | | | | | |
| **合计** | **102** | | | | | | | |

### 7.2 验收结论

- [ ] ✅ 所有验证项通过，环境验收合格，可进入系统部署阶段
- [ ] ❌ 存在失败项，需修复后重新验证

### 7.3 签字确认

| 角色 | 姓名 | 签字 | 日期 |
|------|------|:----:|------|
| DevOps负责人 | | | |
| 架构师 | | | |
| 测试Lead | | | |
| 产品经理 | | | |
| 项目经理 | | | |

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-09 | QA负责人 | 初始版本: 五层验证体系+102项验证项+验收签字流程 |
