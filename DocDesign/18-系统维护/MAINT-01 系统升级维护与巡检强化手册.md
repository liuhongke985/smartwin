# MAINT-01 系统升级维护与巡检强化手册

> **文档编号**: MAINT-01
> **版本**: V1.0
> **创建日期**: 2026-07-09
> **文档状态**: 正式发布
> **文档负责人**: 运维负责人

---

## 1. 系统升级管理

### 1.1 版本发布策略

| 版本类型 | 命名规则 | 频率 | 内容 | 维护窗口 | 回滚时间 |
|---------|---------|:----:|------|:--------:|:--------:|
| 大版本(X.0) | V1.0→V2.0 | 12-18月 | 架构升级+新模块 | 周末8h窗口 | ≤30min |
| 小版本(X.Y) | V1.0→V1.5 | 3-6月 | 新功能+增强 | 周末4h窗口 | ≤15min |
| 补丁版本(X.Y.Z) | V1.0.0→V1.0.1 | 按需 | Bug修复+安全补丁 | 凌晨2h窗口 | ≤5min |
| 紧急修复 | V1.0.0-hotfix | 按需 | 紧急Bug修复 | 随时 | ≤5min |

### 1.2 升级流程

```
Phase 1: 升级准备 (T-7天)
  ├── 版本发布公告
  ├── 升级文档编制
  ├── 回滚方案准备
  ├── 备份策略确认
  └── 通知干系人

Phase 2: 预生产验证 (T-3天)
  ├── STAGE环境升级
  ├── 功能验证
  ├── 性能验证
  ├── 兼容性验证
  └── 升级评审会

Phase 3: 生产升级 (T日)
  ├── T-2h: 全量备份
  ├── T-1h: 通知用户+维护页
  ├── T+0:  开始升级
  ├── T+1h: 服务更新
  ├── T+2h: 数据迁移
  ├── T+3h: 功能验证
  ├── T+4h: 性能验证
  └── T+5h: 恢复服务

Phase 4: 升级后验证 (T+1天)
  ├── 全量功能验证
  ├── 监控指标确认
  ├── 用户反馈收集
  └── 升级报告发布
```

### 1.3 升级操作手册

#### 滚动升级(K8s)

```bash
#!/bin/bash
# smartwin-rolling-update.sh — 滚动升级

set -e

VERSION=$1
NAMESPACE="smartwin"

if [ -z "$VERSION" ]; then
  echo "Usage: $0 <version>"
  echo "Example: $0 V1.1.0"
  exit 1
fi

echo "===== 1. 全量备份 ====="
bash /opt/smartwin/scripts/backup.sh

echo "===== 2. 推送新镜像 ====="
# 镜像已在CI中推送, 此处仅验证
for svc in gateway auth-service system-service; do
  docker pull harbor.smartwin.local/smartwin/$svc:$VERSION
done

echo "===== 3. 更新Helm配置 ====="
helm upgrade smartwin /opt/smartwin/helm -n $NAMESPACE \
  --set image.tag=$VERSION \
  --set strategy.type=RollingUpdate \
  --set strategy.rollingUpdate.maxUnavailable=0 \
  --set strategy.rollingUpdate.maxSurge=1

echo "===== 4. 等待滚动更新完成 ====="
kubectl rollout status deployment/gateway -n $NAMESPACE --timeout=600s
kubectl rollout status deployment/auth-service -n $NAMESPACE --timeout=600s
kubectl rollout status deployment/system-service -n $NAMESPACE --timeout=600s
# ... 其他服务

echo "===== 5. 健康检查 ====="
for svc in gateway auth-service system-service; do
  echo -n "Checking $svc... "
  kubectl exec -n $NAMESPACE deployment/$svc -- \
    curl -s http://localhost:8080/actuator/health | grep -q UP && echo "✅ UP" || echo "❌ DOWN"
done

echo "===== 6. 功能验证 ====="
bash /opt/smartwin/scripts/verify.sh

echo "===== 升级完成: $VERSION ====="
```

#### 回滚操作

```bash
#!/bin/bash
# smartwin-rollback.sh — 快速回滚

set -e

VERSION=$1  # 回滚到的版本
NAMESPACE="smartwin"

echo "===== 紧急回滚到: $VERSION ====="

# Helm回滚
helm rollback smartwin -n $NAMESPACE

# 或者指定版本
# helm upgrade smartwin /opt/smartwin/helm -n $NAMESPACE --set image.tag=$VERSION

# 等待回滚完成
kubectl rollout status deployment/gateway -n $NAMESPACE --timeout=300s

# 验证
for svc in gateway auth-service system-service; do
  kubectl exec -n $NAMESPACE deployment/$svc -- \
    curl -s http://localhost:8080/actuator/health | grep -q UP && echo "✅ $svc" || echo "❌ $svc"
done

echo "===== 回滚完成 ====="
```

### 1.4 数据库迁移

```bash
#!/bin/bash
# smartwin-db-migrate.sh — 数据库迁移

set -e

echo "===== 1. 备份数据库 ====="
su - dmdba -c "/opt/dmdbms/bin/dmrman CTLSTMT='BACKUP DATABASE FULL TO DB_BACKUP_PRE_MIGRATE BACKUPSET /data/backup/pre_migrate'"

echo "===== 2. 执行Flyway迁移 ====="
kubectl apply -f /opt/smartwin/helm/templates/job-db-migrate.yaml -n smartwin
kubectl wait --for=condition=complete job/db-migrate -n smartwin --timeout=600s

echo "===== 3. 验证迁移结果 ====="
# 检查Flyway状态
kubectl logs job/db-migrate -n smartwin | grep "Successfully applied"

# 验证表结构
su - dmdba -c "/opt/dmdbms/bin/disql SYSDBA/SmartWin@2025@localhost:5236 \
  'SELECT version, description, success FROM flyway_schema_history ORDER BY installed_rank DESC LIMIT 5;'"

echo "===== 数据库迁移完成 ====="
```

---

## 2. 补丁管理

### 2.1 补丁分类

| 补丁类型 | 优先级 | 频率 | 测试要求 | 审批 |
|---------|:------:|:----:|---------|:----:|
| 安全补丁 | P0 | 按需 | SIT验证 | 运维负责人 |
| Bug修复补丁 | P1 | 月度 | SIT+UAT | 开发Lead |
| 功能补丁 | P2 | 季度 | 全量测试 | 产品经理 |
| OS/中间件补丁 | P1 | 月度 | 兼容性测试 | 运维负责人 |

### 2.2 补丁安装检查清单

| 序号 | 检查项 | 标准 | 状态 |
|:----:|--------|------|:----:|
| 1 | 补丁来源 | 官方渠道 | ☐ |
| 2 | 补丁签名 | 签名验证通过 | ☐ |
| 3 | 影响评估 | 影响范围已评估 | ☐ |
| 4 | 兼容性测试 | SIT环境验证通过 | ☐ |
| 5 | 回滚方案 | 回滚方案已准备 | ☐ |
| 6 | 备份 | 全量备份已完成 | ☐ |
| 7 | 审批 | 变更审批已通过 | ☐ |
| 8 | 维护窗口 | 在维护窗口内 | ☐ |
| 9 | 通知 | 干系人已通知 | ☐ |
| 10 | 验证 | 安装后验证通过 | ☐ |

---

## 3. 版本兼容性矩阵

### 3.1 软件版本兼容性

| 组件 | V1.0 | V1.5 | V2.0 | V2.5 |
|------|:----:|:----:|:----:|:----:|
| JDK | 17 | 17 | 17/21 | 21 |
| Spring Boot | 3.2 | 3.2 | 3.3 | 3.4 |
| Vue | 3.4 | 3.4 | 3.5 | 3.5 |
| K8s | 1.28 | 1.28 | 1.30 | 1.32 |
| Docker | 24.0 | 24.0 | 25.0 | 26.0 |
| DM8 | 8.1 | 8.1 | 8.1 | 8.2 |
| Redis | 7.2 | 7.2 | 7.4 | 7.4 |
| ES | 8.13 | 8.13 | 8.15 | 8.15 |
| Neo4j | 5.20 | 5.20 | 5.23 | 5.25 |

### 3.2 API版本兼容性

| API版本 | 状态 | 废弃时间 | 迁移指南 |
|---------|:----:|:--------:|---------|
| v1 | ✅ 当前 | — | — |
| v1.5 | ✅ 当前 | — | — |
| v2 | 📋 计划 | — | v1→v2迁移指南 |

---

## 4. 巡检强化方案

### 4.1 自动化巡检体系

| 巡检类型 | 频率 | 工具 | 自动化 | 报告 |
|---------|:----:|------|:------:|:----:|
| 基础巡检 | 每日9:00 | Cron+脚本 | ✅ 自动 | 邮件+钉钉 |
| 深度巡检 | 每周一10:00 | Cron+脚本 | ✅ 自动 | 邮件+钉钉 |
| 全面巡检 | 每月1日14:00 | Cron+脚本 | ✅ 自动 | 邮件+报告 |
| AI智能巡检 | 实时 | AutoOps AI | ✅ 自动 | 看板+告警 |

### 4.2 巡检项扩展(强化版)

| 类别 | 巡检项 | 频率 | 告警阈值 | 自动处理 |
|------|--------|:----:|---------|:--------:|
| **系统** | CPU使用率 | 5min | >80% | HPA扩容 |
| | 内存使用率 | 5min | >85% | 重启Pod |
| | 磁盘使用率 | 30min | >80% | 清理日志 |
| | 磁盘IO | 5min | >90% | — |
| | 网络流量 | 5min | >90%带宽 | 限流 |
| **K8s** | 节点状态 | 1min | NotReady | 通知 |
| | Pod重启次数 | 5min | >3次/h | 分析日志 |
| | Pod CPU | 5min | >80% | HPA扩容 |
| | PVC使用率 | 30min | >80% | 扩容 |
| | etcd健康 | 1min | 不可用 | 通知 |
| **数据库** | 连接数 | 5min | >80% | 释放连接 |
| | 慢查询 | 10min | >5s | 优化索引 |
| | 表空间 | 30min | >80% | 扩容 |
| | 主从延迟 | 5min | >10s | 检查网络 |
| | 锁等待 | 5min | >30s | Kill会话 |
| **中间件** | Redis内存 | 5min | >80% | 清理Key |
| | Redis连接 | 5min | >80% | 释放连接 |
| | ES集群健康 | 1min | 非green | 检查分片 |
| | ES磁盘 | 30min | >85% | 删除旧索引 |
| | Kafka Lag | 5min | >10000 | 扩消费者 |
| | Nacos服务数 | 5min | <22 | 检查服务 |
| **应用** | 服务健康 | 30s | 非UP | 重启Pod |
| | API响应时间 | 1min | P95>200ms | 限流降级 |
| | 错误率 | 1min | >1% | 告警 |
| | JVM GC | 5min | Full GC>0 | 分析Heap |
| | JVM内存 | 5min | >85% | 重启Pod |
| **安全** | 登录失败 | 实时 | >5次/min | 锁定IP |
| | 异常访问 | 实时 | 异常模式 | 告警 |
| | 证书有效期 | 每日 | <30天 | 续期 |
| | 安全告警 | 实时 | 高危告警 | 立即处理 |
| **备份** | 备份状态 | 每日 | 失败 | 重试 |
| | 备份大小 | 每日 | 异常变化 | 检查 |
| | 恢复测试 | 每周 | 失败 | 排查 |

### 4.3 自动化巡检脚本

```bash
#!/bin/bash
# smartwin-auto-inspect.sh — 自动化巡检脚本

set -e

REPORT="/tmp/inspection_$(date +%Y%m%d_%H%M%S).html"
ALERT=false

cat > "$REPORT" << 'EOF'
<html><head><style>
body { font-family: sans-serif; margin: 20px; }
.ok { color: green; } .warn { color: orange; } .fail { color: red; }
table { border-collapse: collapse; width: 100%; }
td, th { border: 1px solid #ddd; padding: 8px; text-align: left; }
th { background: #f5f5f5; }
</style></head><body>
<h1>SmartWin 自动巡检报告</h1>
<table><tr><th>巡检项</th><th>状态</th><th>详情</th><th>时间</th></tr>
EOF

inspect() {
  local name=$1
  local cmd=$2
  local threshold=$3
  local value=$(eval "$cmd" 2>/dev/null || echo "N/A")
  local status="✅"
  local class="ok"
  
  if [ "$value" != "N/A" ] && [ -n "$threshold" ]; then
    if (( $(echo "$value > $threshold" | bc -l 2>/dev/null || echo 0) )); then
      status="⚠️"
      class="warn"
      ALERT=true
    fi
  fi
  
  echo "<tr><td>$name</td><td class='$class'>$status</td><td>$value</td><td>$(date)</td></tr>" >> "$REPORT"
}

# K8s巡检
inspect "K8s节点Ready" "kubectl get nodes --no-headers | grep -c 'Ready'" "0"
inspect "异常Pod数" "kubectl get pods -A --no-headers | grep -v Running | grep -v Completed | wc -l" "0"
inspect "Pod重启(1h)" "kubectl get pods -A -o jsonpath='{.items[*].status.containerStatuses[*].restartCount}' | tr ' ' '\n' | awk '{s+=$1} END {print s}'" "10"

# 数据库巡检
inspect "DM8连接数" "su - dmdba -c \"/opt/dmdbms/bin/disql SYSDBA/SmartWin@2025@localhost:5236 'SELECT count(*) FROM v\\\$sessions;'\" | tail -1" "500"

# 中间件巡检
inspect "Redis内存%" "kubectl exec redis-cluster-0 -- redis-cli -a SmartWin@Redis2025 INFO memory | grep used_memory_peak_perc | cut -d: -f2 | tr -d ' \r'" "80"
inspect "ES健康" "curl -s -u elastic:SmartWin@ES2025 http://smartwin-es-master:9200/_cluster/health | grep -o '\"status\":\"[a-z]*\"' | cut -d'\"' -f4" ""

# 应用巡检
for svc in gateway auth-service system-service; do
  inspect "$svc健康" "kubectl exec deployment/$svc -n smartwin -- curl -s http://localhost:8080/actuator/health | grep -o '\"status\":\"[A-Z]*\"' | cut -d'\"' -f4" ""
done

cat >> "$REPORT" << EOF
</table>
<p>巡检时间: $(date)</p>
<p>巡检结果: $([ "$ALERT" = true ] && echo '⚠️ 存在告警项' || echo '✅ 全部正常')</p>
</body></html>
EOF

# 发送报告
mail -s "SmartWin巡检报告 $(date +%Y%m%d)" ops@smartwin.com < "$REPORT"

# 钉钉通知
if [ "$ALERT" = true ]; then
  curl -s -X POST "https://oapi.dingtalk.com/robot/send?access_token=$DINGTALK_TOKEN" \
    -H 'Content-Type: application/json' \
    -d "{\"msgtype\":\"text\",\"text\":{\"content\":\"⚠️ SmartWin巡检发现告警项，请查看邮件报告\"}}"
fi

echo "巡检完成: $REPORT"
```

---

## 5. 预防性维护

### 5.1 维护日历

| 维护类型 | 频率 | 时间 | 持续 | 内容 |
|---------|:----:|:----:|:----:|------|
| 日常维护 | 每日 | 9:00 | 30min | 巡检+告警处理 |
| 周维护 | 每周日 | 2:00 | 2h | 日志清理+索引优化 |
| 月维护 | 每月1日 | 2:00 | 4h | 补丁+重启+清理 |
| 季维护 | 每季首月 | 周末 | 8h | 大版本升级+全面检查 |
| 年维护 | 年末 | 周末 | 16h | 架构评审+容量规划 |

### 5.2 预防性维护项

| 维护项 | 频率 | 操作 | 自动化 |
|--------|:----:|------|:------:|
| 日志清理 | 每周 | 删除30天前日志 | ✅ Cron |
| 临时文件清理 | 每周 | 清理/tmp /var/tmp | ✅ Cron |
| 索引重建 | 每月 | DM8索引重建 | ✅ 脚本 |
| 统计信息更新 | 每周 | DM8统计信息 | ✅ 脚本 |
| ES索引清理 | 每月 | 删除90天前索引 | ✅ 脚本 |
| Redis碎片整理 | 每周 | activedefrag | ✅ 脚本 |
| 镜像清理 | 每周 | 清理旧版本镜像 | ✅ Cron |
| 证书检查 | 每日 | 检查有效期 | ✅ 脚本 |
| 密码轮换 | 每季 | 轮换关键密码 | ☐ 手动 |
| 容量评估 | 每月 | 评估资源使用 | ☐ 手动 |

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-09 | 运维负责人 | 初始版本: 升级管理+补丁管理+版本兼容+巡检强化+预防性维护 |
