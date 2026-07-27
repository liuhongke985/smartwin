# DRC-01 业务连续性与灾备方案

> **文档编号**: DRC-01
> **版本**: V1.0
> **创建日期**: 2026-07-09
> **文档状态**: 正式发布
> **文档负责人**: 架构师

---

## 1. 业务连续性概述

### 1.1 RTO/RPO目标

| 业务系统 | RTO(恢复时间) | RPO(数据丢失) | 可用性目标 | 灾备模式 |
|---------|:------------:|:------------:|:---------:|:--------:|
| 智链-AI模型管理 | ≤15分钟 | ≤1分钟 | 99.9% | 主备 |
| 智链-Agent服务 | ≤15分钟 | ≤5分钟 | 99.9% | 主备 |
| 智链-成本管控 | ≤30分钟 | ≤5分钟 | 99.5% | 数据备份 |
| 智数-数据目录 | ≤30分钟 | ≤1分钟 | 99.9% | 主备 |
| 智数-数据血缘 | ≤60分钟 | ≤30分钟 | 99.5% | 数据备份 |
| 共享-认证授权 | ≤5分钟 | ≤0分钟 | 99.99% | 双活 |
| 共享-审计日志 | ≤60分钟 | ≤5分钟 | 99.5% | 数据备份 |
| AI引擎 | ≤30分钟 | ≤15分钟 | 99.5% | 主备 |

### 1.2 灾备架构

```
┌──────────────────────┐          ┌──────────────────────┐
│     主数据中心(A)      │          │     灾备数据中心(B)    │
│                      │          │                      │
│  ┌────────────────┐  │  异步复制  │  ┌────────────────┐  │
│  │  K8s集群(8节点) │  │ ────────→ │  │  K8s集群(4节点) │  │
│  ├────────────────┤  │          │  ├────────────────┤  │
│  │  DM8主库        │──┼─ DM8同步─┼──│  DM8备库        │  │
│  ├────────────────┤  │          │  ├────────────────┤  │
│  │  Redis集群      │──┼─ Redis同步┼──│  Redis集群      │  │
│  ├────────────────┤  │          │  ├────────────────┤  │
│  │  ES集群         │──┼─ ES跨集群 ┼──│  ES集群         │  │
│  ├────────────────┤  │  复制     │  ├────────────────┤  │
│  │  MinIO          │──┼─ MinIO复制┼──│  MinIO          │  │
│  └────────────────┘  │          │  └────────────────┘  │
│                      │          │                      │
│  域名: smartwin.com  │          │  域名: dr.smartwin.com│
└──────────────────────┘          └──────────────────────┘
           │                                 │
           └────────── Global LB ────────────┘
                    (DNS故障切换)
```

---

## 2. 备份恢复策略

### 2.1 备份策略矩阵

| 数据类型 | 备份方式 | 频率 | 保留期 | 存储位置 | 验证频率 |
|---------|---------|:----:|:------:|---------|:--------:|
| DM8数据库 | 全量+增量 | 全量日1+增量4h | 30天 | 本地+NFS+异地 | 每周 |
| Redis | RDB快照+AOF | RDB 6h+AOF 1s | 7天 | 本地+NFS | 每周 |
| ES索引 | 快照 | 日1 | 14天 | MinIO | 每周 |
| Neo4j | 全量备份 | 日1 | 14天 | 本地+NFS | 每周 |
| MinIO对象 | 跨区复制 | 实时 | 永久 | 异地MinIO | 每月 |
| Nacos配置 | 导出 | 日1 | 90天 | GitLab+NFS | 每月 |
| K8s资源 | etcd备份 | 6h | 30天 | 本地+NFS | 每周 |
| 监控数据 | 快照 | 周1 | 90天 | NFS | 每月 |

### 2.2 备份脚本

```bash
#!/bin/bash
# smartwin-backup.sh — 全量备份脚本

set -e

BACKUP_DIR="/data/backup/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

echo "===== 1. DM8数据库备份 ====="
su - dmdba -c "/opt/dmdbms/bin/dmrman CTLSTMT='BACKUP DATABASE FULL TO DB_FULL BACKUPSET '$BACKUP_DIR/dm8_full''"

echo "===== 2. Redis备份 ====="
kubectl exec -n smartwin redis-cluster-0 -- redis-cli -a SmartWin@Redis2028 BGSAVE
sleep 10
kubectl cp smartwin/redis-cluster-0:/data/dump.rdb "$BACKUP_DIR/redis_dump.rdb"

echo "===== 3. ES快照 ====="
curl -X PUT -u elastic:SmartWin@ES2028 "http://smartwin-es-master:9200/_snapshot/backup_repo/$(date +%Y%m%d)?wait_for_completion=true"

echo "===== 4. Neo4j备份 ====="
kubectl exec -n smartwin neo4j-0 -- neo4j-admin database dump neo4j --to-path=/data/backup
kubectl cp smartwin/neo4j-0:/data/backup/neo4j.dump "$BACKUP_DIR/neo4j.dump"

echo "===== 5. K8s etcd备份 ====="
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save "$BACKUP_DIR/etcd-snapshot.db"

echo "===== 6. Nacos配置导出 ====="
curl -X GET "http://nacos:8848/nacos/v1/cs/configs?export=true" -o "$BACKUP_DIR/nacos_config.zip"

echo "===== 7. 压缩+异地传输 ====="
tar -czf "$BACKUP_DIR.tar.gz" "$BACKUP_DIR"
scp "$BACKUP_DIR.tar.gz" backup@dr.smartwin.local:/data/backup/

echo "===== 8. 清理30天前备份 ====="
find /data/backup -name "*.tar.gz" -mtime +30 -delete

echo "===== 备份完成: $BACKUP_DIR ====="
```

### 2.3 恢复规程

| 故障场景 | 恢复步骤 | 预计时间 | 负责人 |
|---------|---------|:--------:|--------|
| DM8主库宕机 | 1.提升备库 2.更新连接 3.重建备库 | 15分钟 | DBA |
| DM8数据损坏 | 1.停止服务 2.恢复备份 3.应用binlog 4.验证 5.启动 | 60分钟 | DBA |
| Redis集群故障 | 1.切换从节点 2.恢复RDB 3.重建集群 | 10分钟 | 运维 |
| ES集群故障 | 1.恢复快照 2.重建索引 3.验证 | 30分钟 | 运维 |
| K8s集群故障 | 1.恢复etcd 2.重建集群 3.重新部署 | 120分钟 | DevOps |
| 全站灾难 | 1.启动灾备中心 2.DNS切换 3.数据恢复 4.验证 | 240分钟 | 运维负责人 |

---

## 3. 灾备切换方案

### 3.1 切换决策矩阵

| 故障级别 | 影响范围 | 切换决策 | 决策人 | 切换时间 |
|:--------:|---------|:--------:|--------|:--------:|
| P0-全站不可用 | 全部用户 | 立即切换灾备 | 运维总监 | ≤5分钟 |
| P1-核心不可用 | 核心用户 | 评估后切换 | 运维负责人 | ≤15分钟 |
| P2-部分不可用 | 部分用户 | 优先恢复主站 | 运维值班 | 不切换 |
| P3-单点故障 | 少量用户 | 不切换 | 运维值班 | 不切换 |

### 3.2 灾备切换流程

```
Step 1: 故障确认 (≤5分钟)
  ├── 监控告警触发
  ├── 值班运维确认故障
  └── 通知运维总监

Step 2: 切换决策 (≤5分钟)
  ├── 评估故障影响
  ├── 判断是否需要切换
  └── 运维总监授权切换

Step 3: 执行切换 (≤10分钟)
  ├── DNS切换到灾备中心
  ├── 验证灾备中心服务
  ├── 数据一致性检查
  └── 用户流量引导

Step 4: 切换验证 (≤5分钟)
  ├── 核心功能验证
  ├── 性能指标检查
  ├── 用户反馈收集
  └── 切换成功通知

Step 5: 故障修复 (异步)
  ├── 主站故障排查
  ├── 修复方案制定
  ├── 主站修复验证
  └── 数据反向同步

Step 6: 切回主站 (故障修复后)
  ├── 数据同步完成确认
  ├── DNS切回主站
  ├── 灾备中心恢复待命
  └── 切回验证
```

### 3.3 DNS切换脚本

```bash
#!/bin/bash
# smartwin-dns-failover.sh — DNS故障切换

set -e

DNS_PROVIDER="aliyun"  # aliyun/cloudflare
DOMAIN="smartwin.com"
PRIMARY_IP="192.168.1.100"
DR_IP="192.168.2.100"
TARGET=$1  # primary|dr

if [ "$TARGET" = "dr" ]; then
  NEW_IP=$DR_IP
  echo "===== 切换到灾备中心: $NEW_IP ====="
elif [ "$TARGET" = "primary" ]; then
  NEW_IP=$PRIMARY_IP
  echo "===== 切回主站: $NEW_IP ====="
else
  echo "Usage: $0 {primary|dr}"
  exit 1
fi

# 更新DNS记录 (阿里云)
aliyun alidns UpdateDomainRecord \
  --RecordId "$RECORD_ID" \
  --RR "@" \
  --Type "A" \
  --Value "$NEW_IP" \
  --TTL 60

# 更新www记录
aliyun alidns UpdateDomainRecord \
  --RecordId "$WWW_RECORD_ID" \
  --RR "www" \
  --Type "A" \
  --Value "$NEW_IP" \
  --TTL 60

echo "===== DNS切换完成, 等待生效(60s) ====="
sleep 60

# 验证
echo "===== 验证切换结果 ====="
curl -s -o /dev/null -w "%{http_code}" https://smartwin.com/actuator/health

echo "===== DNS切换验证完成 ====="
```

---

## 4. 灾备演练

### 4.1 演练计划

| 演练类型 | 频率 | 范围 | 参与人员 | 成功标准 |
|---------|:----:|------|---------|---------|
| 桌面推演 | 季度 | 流程推演 | 运维+架构 | 流程完整+决策正确 |
| 数据恢复演练 | 月度 | 备份恢复 | DBA+运维 | 恢复成功+数据一致 |
| 局部切换演练 | 半年 | 单服务切换 | 运维+开发 | 切换成功+功能正常 |
| 全量切换演练 | 年度 | 全站切换 | 全体 | RTO≤15min+功能正常 |

### 4.2 演练记录模板

| 项目 | 内容 |
|------|------|
| 演练日期 | 2025-XX-XX |
| 演练类型 | ☐桌面推演 ☐数据恢复 ☐局部切换 ☐全量切换 |
| 参与人员 | |
| 演练场景 | |
| 开始时间 | |
| 切换完成时间 | |
| 验证完成时间 | |
| 实际RTO | |
| 实际RPO | |
| 发现问题 | |
| 改进措施 | |
| 演练结论 | ☐通过 ☐部分通过 ☐不通过 |
| 签字 | |

---

## 5. 业务连续性保障措施

### 5.1 高可用设计

| 组件 | 高可用方案 | 副本数 | 故障切换 |
|------|-----------|:------:|---------|
| K8s Master | 3节点Raft | 3 | 自动 |
| K8s Worker | 多节点+HPA | 8+ | 自动调度 |
| API Gateway | 多副本+SLB | 2 | 自动 |
| 微服务 | 多副本+HPA | 2-10 | 自动 |
| DM8 | 主从复制 | 1主2从 | 自动/手动 |
| Redis | 集群模式 | 6(3主3从) | 自动 |
| ES | 集群模式 | 3 | 自动 |
| Kafka | 集群模式 | 3 | 自动 |
| Nacos | 集群模式 | 3 | 自动 |
| Nginx | Keepalived VIP | 2 | 自动 |

### 5.2 容量与弹性

| 措施 | 说明 | 触发条件 |
|------|------|---------|
| HPA自动扩容 | Pod水平自动伸缩 | CPU>70%或内存>75% |
| VPA自动调优 | Pod垂直自动调优 | 资源使用不均衡 |
| 限流降级 | Gateway限流+熔断 | QPS超限+错误率>5% |
| 队列削峰 | Kafka异步处理 | 请求积压 |
| 缓存加速 | Redis多级缓存 | 数据库压力高 |
| 读写分离 | DM8读写分离 | 读压力大 |
| CDN加速 | 静态资源CDN | 前端加载慢 |

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-09 | 架构师 | 初始版本: BCP目标+灾备架构+备份策略+切换方案+演练计划+高可用设计 |
