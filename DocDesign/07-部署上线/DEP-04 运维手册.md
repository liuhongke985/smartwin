# SmartWin 平台运维手册

## 文档控制

| 信息项 | 内容 |
|--------|------|
| **文档编号** | OPS-01 |
| **文档版本** | V1.0 |
| **创建日期** | 2026-07-08 |
| **文档状态** | 正式发布 |
| **文档负责人** | 运维团队 |

---

## 1. 日常运维

### 1.1 服务状态检查

```bash
# 查看所有服务状态
docker-compose ps

# 查看某服务日志
docker-compose logs -f --tail=100 gateway
docker-compose logs -f --tail=100 catalog-service

# 检查服务健康
for svc in gateway auth-service system-service catalog-service; do
  echo "=== $svc ==="
  docker-compose exec $svc curl -s http://localhost:8080/actuator/health
done
```

### 1.2 K8s 环境

```bash
# 查看Pod状态
kubectl get pods -n smartwin

# 查看服务日志
kubectl logs -f deployment/gateway -n smartwin --tail=100

# 查看资源使用
kubectl top pods -n smartwin

# 查看事件
kubectl get events -n smartwin --sort-by='.lastTimestamp'
```

### 1.3 中间件巡检

| 中间件 | 检查命令 | 关注指标 |
|--------|----------|----------|
| MySQL | `mysql -e "SHOW STATUS LIKE 'Threads_connected'"` | 连接数<80% |
| Redis | `redis-cli INFO memory` | used_memory < 85% |
| ES | `curl localhost:9200/_cluster/health` | status=green |
| Neo4j | `curl -u neo4j:pwd localhost:7474/db/neo4j/tx/commit -d '{"statements":[{"statement":"RETURN 1"}]}'` | 返回200 |
| Nacos | `curl localhost:8848/nacos/v1/ns/catalog/services?pageNo=1&pageSize=20` | 服务列表完整 |
| RocketMQ | `docker exec smartwin-rocketmq-broker sh mqadmin clusterList -n namesrv:9876` | broker在线 |

---

## 2. 故障排查

### 2.1 服务无法启动

```bash
# 1. 查看容器日志
docker-compose logs --tail=200 <service-name>

# 常见原因:
#   - 数据库连接失败 → 检查 DB_HOST/DB_PASSWORD
#   - Nacos注册失败 → 检查 NACOS_HOST/NACOS_PORT
#   - 端口被占用 → docker-compose ps 检查端口冲突
#   - 内存不足 → 增加JAVA_OPTS的 -Xmx

# 2. 查看容器资源使用
docker stats smartwin-<service-name>

# 3. 进入容器排查
docker exec -it smartwin-<service-name> sh
```

### 2.2 API 502/503

```bash
# 1. 检查网关是否正常
curl http://localhost:9000/actuator/health

# 2. 检查目标服务是否注册到Nacos
curl "http://localhost:8848/nacos/v1/ns/instance/list?serviceName=catalog-service"

# 3. 检查网关路由配置
curl http://localhost:9000/actuator/gateway/routes

# 4. 检查网关日志
docker-compose logs --tail=100 gateway | grep ERROR
```

### 2.3 数据库连接异常

```bash
# 1. 检查数据库状态
docker-compose exec mysql mysql -uroot -p -e "SHOW PROCESSLIST"

# 2. 检查连接数
docker-compose exec mysql mysql -uroot -p -e "SHOW STATUS LIKE 'Threads_%'"

# 3. 检查慢查询
docker-compose exec mysql mysql -uroot -p -e "SHOW VARIABLES LIKE 'slow_query%'"

# 4. 检查数据源密码是否正确加密
# 查看datasource_config表中的password字段，应为 ENC(密文) 格式
```

### 2.4 ES搜索无结果

```bash
# 1. 检查ES健康
curl localhost:9200/_cluster/health

# 2. 检查索引是否存在
curl localhost:9200/_cat/indices

# 3. 检查索引映射
curl localhost:9200/smartwin-catalog/_mapping

# 4. 手动触发索引重建
curl -X POST http://localhost:9000/api/smartdata/catalog/reindex
```

### 2.5 Neo4j血缘查询失败

```bash
# 1. 检查Neo4j状态
docker-compose exec neo4j cypher-shell -u neo4j -p password "RETURN 1"

# 2. 检查节点数据
docker-compose exec neo4j cypher-shell -u neo4j -p password "MATCH (n:LineageNode) RETURN count(n)"

# 3. 服务会自动降级到数据库查询（Neo4j不可用时）
```

### 2.6 AI引擎无响应

```bash
# 1. 检查Ollama服务
curl http://localhost:11434/api/tags

# 2. 检查模型是否加载
curl http://localhost:11434/api/ps

# 3. AI不可用时系统自动降级到规则引擎
```

---

## 3. 备份与恢复

### 3.1 数据库备份

```bash
# MySQL全量备份
docker exec smartwin-mysql mysqldump -uroot -p${DB_ROOT_PASSWORD} \
  --single-transaction --routines --triggers \
  smartwin_platform > /backup/mysql/smartwin_$(date +%Y%m%d_%H%M%S).sql

# 定时备份（crontab）
# 每天凌晨2点备份
0 2 * * * /opt/smartwin/scripts/backup-mysql.sh >> /var/log/smartwin-backup.log 2>&1
```

### 3.2 Redis备份

```bash
# 触发RDB快照
docker exec smartwin-redis redis-cli -a ${REDIS_PASSWORD} BGSAVE

# 复制RDB文件
docker cp smartwin-redis:/data/dump.rdb /backup/redis/dump_$(date +%Y%m%d).rdb
```

### 3.3 ES备份

```bash
# 创建快照仓库
curl -X PUT "localhost:9200/_snapshot/smartwin_backup" -H 'Content-Type: application/json' -d '{
  "type": "fs",
  "settings": {"location": "/backup/es"}
}'

# 创建快照
curl -X PUT "localhost:9200/_snapshot/smartwin_backup/snapshot_$(date +%Y%m%d)?wait_for_completion=false"
```

### 3.4 Neo4j备份

```bash
# 全量备份
docker exec smartwin-neo4j neo4j-admin database backup neo4j --to-path=/backup/neo4j
```

### 3.5 恢复流程

```bash
# MySQL恢复
docker exec -i smartwin-mysql mysql -uroot -p${DB_ROOT_PASSWORD} smartwin_platform < /backup/mysql/smartwin_20260708.sql

# Redis恢复
docker cp /backup/redis/dump_20260708.rdb smartwin-redis:/data/dump.rdb
docker-compose restart redis

# ES恢复
curl -X POST "localhost:9200/_snapshot/smartwin_backup/snapshot_20260708/_restore"
```

---

## 4. 扩容缩容

### 4.1 Docker Compose 扩容

```bash
# 扩容网关（需要修改docker-compose.yml的replicas或使用docker-compose up --scale）
docker-compose up -d --scale gateway=2 --scale catalog-service=2
```

### 4.2 K8s 扩容

```bash
# 扩容指定服务
kubectl scale deployment gateway -n smartwin --replicas=4
kubectl scale deployment catalog-service -n smartwin --replicas=3

# HPA自动扩容（需提前配置）
kubectl autoscale deployment gateway -n smartwin --min=2 --max=10 --cpu-percent=70
```

### 4.3 中间件扩容

| 中间件 | 扩容方式 | 说明 |
|--------|----------|------|
| MySQL | 主从复制 | 增加只读从库 |
| Redis | Cluster模式 | 增加分片节点 |
| ES | 增加节点 | 修改discovery.seed_hosts |
| Neo4j | 社区版单节点 | 企业版支持Causal Cluster |

---

## 5. 版本升级

### 5.1 滚动升级（K8s）

```bash
# 更新镜像版本
kubectl set image deployment/gateway -n smartwin gateway=smartwin/gateway:1.1.0
kubectl set image deployment/catalog-service -n smartwin catalog-service=smartwin/catalog-service:1.1.0

# 或通过Helm升级
helm upgrade smartwin infra/helm -f my-values.yaml -n smartwin
```

### 5.2 Docker Compose 升级

```bash
# 1. 拉取新镜像
docker pull smartwin/gateway:1.1.0

# 2. 逐个升级（避免全部中断）
docker-compose stop gateway
docker-compose rm -f gateway
# 修改image tag为1.1.0
docker-compose up -d gateway

# 3. 验证后继续其他服务
```

---

## 6. 安全运维

### 6.1 密码轮换

```bash
# 1. 修改MySQL密码
docker exec smartwin-mysql mysql -uroot -p -e "ALTER USER 'root'@'%' IDENTIFIED BY 'NewPassword@2026'"

# 2. 更新.env文件
sed -i 's/DB_ROOT_PASSWORD=.*/DB_ROOT_PASSWORD=NewPassword@2026/' .env

# 3. 重启依赖数据库的服务
docker-compose restart auth-service system-service catalog-service
```

### 6.2 证书更新

```bash
# 更新TLS证书
kubectl create secret tls smartwin-tls \
  --cert=new-cert.pem \
  --key=new-key.pem \
  -n smartwin \
  --dry-run=client -o yaml | kubectl apply -f -
```

### 6.3 日志清理

```bash
# 清理Docker日志
docker system prune -a --volumes --filter "until=168h"

# 清理Loki旧日志（自动保留30天，配置在loki-config.yml）

# 清理Prometheus旧数据（自动保留30天，配置在启动参数）
```

---

## 7. 监控告警响应

### 7.1 告警级别与响应

| 级别 | 响应时间 | 响应动作 |
|------|----------|----------|
| Critical | 5分钟 | 立即排查，电话通知 |
| Warning | 30分钟 | 工作时间内排查 |

### 7.2 常见告警处理

| 告警 | 可能原因 | 处理步骤 |
|------|----------|----------|
| ServiceDown | 容器崩溃/OOM | 查看日志→重启服务→扩容 |
| JvmMemoryHigh | 内存泄漏 | 查看Heap Dump→重启→排查代码 |
| MysqlConnectionHigh | 连接泄漏 | 查看PROCESSLIST→杀连接→排查 |
| RedisMemoryHigh | 大Key/未过期 | 检查内存→清理Key→调整策略 |
| HighErrorRate | 代码bug/依赖故障 | 查看异常日志→定位→修复 |
| ApiServiceLatencyHigh | 慢SQL/资源不足 | 查看慢查询→优化→扩容 |

---

## 8. 运维检查清单（每日）

| 检查项 | 检查方式 | 正常标准 |
|--------|----------|----------|
| 所有服务在线 | `docker-compose ps` / `kubectl get pods` | 100% Running |
| API网关健康 | `curl :9000/actuator/health` | status=UP |
| 数据库连接 | 慢查询日志 | 无慢查询 |
| 磁盘空间 | `df -h` | 使用率<80% |
| 内存使用 | `free -h` / `docker stats` | 使用率<85% |
| 备份状态 | 检查备份目录 | 当日备份存在 |
| 监控告警 | Grafana/Prometheus | 无未处理告警 |
| 日志异常 | Loki日志查询 | 无ERROR级别日志激增 |
