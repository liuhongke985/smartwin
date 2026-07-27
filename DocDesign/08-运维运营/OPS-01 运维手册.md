# 运维手册

## 文档控制

| 信息项 | 内容 |
|--------|------|
| **文档编号** | OPS-01 |
| **文档版本** | V1.0 |
| **创建日期** | 2026-07-08 |
| **最后修订** | 2026-07-08 |
| **文档状态** | 正式发布 |
| **文档负责人** | 运维工程师 |
| **审批人** | DevOps Lead |

---

## 1. 运维概述

### 1.1 系统信息

| 项目 | 说明 |
|------|------|
| 系统名称 | 智赢(智数+智链)双平台 |
| 部署方式 | Docker Compose容器化部署 |
| 操作系统 | 麒麟V10 / CentOS 7+ / Ubuntu 22+ |
| JDK | 毕昇JDK 17 / Eclipse Temurin 17 |
| 数据库 | 达梦DM8 8.1+ / MySQL 8.0+ |

### 1.2 运维职责

| 角色 | 职责 |
|------|------|
| 运维工程师 | 日常巡检、故障处理、变更执行 |
| DevOps | CI/CD、监控配置、自动化运维 |
| DBA | 数据库运维、备份恢复、性能调优 |

---

## 2. 日常运维操作

### 2.1 服务管理

```bash
# 启动全部服务
cd /opt/smartwin
docker-compose -f docker-compose.prod.yml up -d

# 停止全部服务
docker-compose -f docker-compose.prod.yml down

# 重启单个服务
docker-compose -f docker-compose.prod.yml restart auth-service

# 查看服务状态
docker-compose -f docker-compose.prod.yml ps

# 查看服务日志
docker-compose -f docker-compose.prod.yml logs -f --tail=200 auth-service

# 进入容器
docker exec -it auth-service sh
```

### 2.2 日常巡检清单

| 巡检项 | 检查命令 | 频率 | 正常标准 |
|--------|----------|:----:|----------|
| 服务状态 | `docker-compose ps` | 每日 | 全部Up |
| 磁盘空间 | `df -h` | 每日 | 使用率<80% |
| 内存使用 | `free -h` | 每日 | 使用率<80% |
| CPU负载 | `top -bn1` | 每日 | load<核心数 |
| 数据库连接 | `docker exec dm8 disql -l` | 每日 | 连接正常 |
| Redis连接 | `docker exec redis redis-cli ping` | 每日 | PONG |
| ES健康 | `curl localhost:9200/_cluster/health` | 每日 | status:green |
| Neo4j状态 | `curl localhost:7474` | 每日 | 200 OK |
| 告警检查 | Grafana告警面板 | 每日 | 无未处理告警 |
| 备份检查 | 备份日志 | 每日 | 备份成功 |

### 2.3 日志管理

| 日志类型 | 位置 | 保留周期 | 说明 |
|----------|------|:--------:|------|
| 应用日志 | Loki (容器stdout) | 30天 | 通过Grafana查询 |
| Nginx日志 | /var/log/nginx/ | 30天 | 访问+错误日志 |
| DM8日志 | /opt/dmdbms/log/ | 30天 | 数据库运行日志 |
| 系统日志 | /var/log/messages | 90天 | OS系统日志 |
| 审计日志 | audit_operation_log表 | 1年 | 业务操作审计 |

```bash
# 查询应用日志(Loki)
# 通过Grafana → Explore → Loki查询
# 查询示例: {container="auth-service"} |= "ERROR"

# 查询Nginx访问日志
tail -f /var/log/nginx/access.log
grep "500\|502\|503" /var/log/nginx/error.log
```

---

## 3. 数据库运维

### 3.1 DM8日常运维

```bash
# 进入DM8命令行
docker exec -it dm8 /opt/dmdbms/bin/disql SYSDBA/SYSDBA@localhost:5236

# 查看数据库状态
SELECT * FROM V$INSTANCE;

# 查看表空间使用率
SELECT
  t.TABLESPACE_NAME,
  t.BYTES / 1024 / 1024 / 1024 AS "大小(GB)",
  (t.BYTES - f.BYTES) / 1024 / 1024 / 1024 AS "已用(GB)",
  f.BYTES / 1024 / 1024 / 1024 AS "空闲(GB)"
FROM DBA_DATA_FILES t
JOIN DBA_FREE_SPACE f ON t.FILE_ID = f.FILE_ID
GROUP BY t.TABLESPACE_NAME;

# 查看活跃连接
SELECT COUNT(*) FROM V$SESSIONS WHERE STATE = 'ACTIVE';

# 查看慢SQL
SELECT * FROM V$LONG_EXEC_SQLS ORDER BY EXEC_TIME DESC FETCH FIRST 10 ROWS ONLY;
```

### 3.2 数据备份

```bash
# 全量备份脚本 (每日凌晨2点执行)
#!/bin/bash
BACKUP_DIR=/opt/backup/dm8
DATE=$(date +%Y%m%d_%H%M%S)
docker exec dm8 /opt/dmdbms/bin/dmrman \
  CTLSTMT="BACKUP DATABASE FULL TO FULL_${DATE} BACKUPSET '${BACKUP_DIR}/FULL_${DATE}'"
# 清理30天前备份
find ${BACKUP_DIR} -mtime +30 -delete
```

### 3.3 数据恢复

```bash
# 恢复全量备份
docker exec dm8 /opt/dmdbms/bin/dmrman \
  CTLSTMT="RESTORE DATABASE FROM BACKUPSET '/opt/backup/dm8/FULL_20260708'"

# 恢复归档日志
docker exec dm8 /opt/dmdbms/bin/dmrman \
  CTLSTMT="RECOVER DATABASE WITH ARCHIVEDIR '/opt/dmdbms/arch'"
```

---

## 4. Redis运维

```bash
# 进入Redis CLI
docker exec -it redis redis-cli -a <password>

# 查看内存使用
INFO memory

# 查看连接数
INFO clients

# 查看慢查询
SLOWLOG GET 10

# 清理缓存(谨慎!)
# FLUSHDB    # 清空当前库
# FLUSHALL   # 清空所有库(危险!)

# 查看Key数量
DBSIZE

# 查找Key
KEYS model:*
# 生产环境使用SCAN代替KEYS
SCAN 0 MATCH model:* COUNT 100
```

---

## 5. Elasticsearch运维

```bash
# 集群健康状态
curl localhost:9200/_cluster/health?pretty

# 查看索引列表
curl localhost:9200/_cat/indices?v

# 查看节点信息
curl localhost:9200/_cat/nodes?v

# 删除索引(谨慎!)
# curl -X DELETE localhost:9200/index_name

# 索引统计
curl localhost:9200/_stats?pretty
```

---

## 6. 常见故障处理

### 6.1 服务无法启动

| 故障现象 | 可能原因 | 处理步骤 |
|----------|----------|----------|
| 容器立即退出 | 配置错误/端口冲突 | 查看日志 `docker logs <container>` |
| 服务启动超时 | 依赖服务未就绪 | 检查Nacos/DB/Redis状态 |
| OOM | 内存不足 | 调整JVM参数/增加服务器内存 |

### 6.2 数据库连接失败

```bash
# 1. 检查DM8容器状态
docker ps | grep dm8

# 2. 检查端口
docker exec dm8 netstat -tlnp | grep 5236

# 3. 测试连接
docker exec dm8 /opt/dmdbms/bin/disql SYSDBA/SYSDBA@localhost:5236

# 4. 检查连接池配置
# 查看application-prod.yml中的spring.datasource配置
```

### 6.3 API响应慢

| 排查步骤 | 命令 |
|----------|------|
| 1. 查看服务资源 | `docker stats` |
| 2. 查看JVM状态 | `docker exec <svc> jstat -gc <pid>` |
| 3. 查看慢SQL | DM8 V$LONG_EXEC_SQLS |
| 4. 查看Redis慢查询 | `SLOWLOG GET 10` |
| 5. 查看网络延迟 | `ping`/`traceroute` |

### 6.4 前端无法访问

| 排查步骤 | 命令 |
|----------|------|
| 1. 检查Nginx | `systemctl status nginx` |
| 2. 检查前端容器 | `docker ps | grep frontend` |
| 3. 检查网关 | `curl localhost:9000/actuator/health` |
| 4. 检查DNS | `nslookup smartwin.example.com` |
| 5. 检查SSL证书 | `openssl s_client -connect smartwin.example.com:443` |

---

## 7. 变更管理

### 7.1 变更流程

```
变更申请 → 影响评估 → 审批 → 变更窗口执行 → 验证 → 回归 → 关闭
```

### 7.2 变更窗口

| 类型 | 窗口 | 审批 |
|------|:----:|:----:|
| 常规变更 | 每周三 22:00-02:00 | 运维Lead |
| 紧急变更 | 随时(需评估) | 项目总监 |
| 重大变更 | 每月维护窗口 | 指导委员会 |

---

## 8. 应急联系

| 角色 | 姓名 | 手机 | 职责 |
|------|------|------|------|
| 运维工程师 | | | 一线响应 |
| DevOps Lead | | | 二线支持 |
| DBA | | | 数据库支持 |
| 架构师 | | | 三线决策 |
| 项目经理 | | | 协调沟通 |

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-08 | 运维工程师 | 初始版本发布 |
