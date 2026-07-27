# SmartWin 平台 — 数据库备份与灾备恢复手册

> **文档编号**: OPS-DR-001  
> **创建日期**: 2026-07-11  
> **最后更新**: 2026-07-11  
> **文档状态**: 🟢 活跃  
> **维护人**: 运维团队

---

## 1. 概述

### 1.1 目标

确保 SmartWin 平台数据库在发生灾难性故障时，能够在可接受的时间范围内恢复到最近的一致状态。

### 1.2 RTO/RPO 目标

| 级别 | RTO (恢复时间目标) | RPO (恢复点目标) | 适用场景 |
|------|-------------------|-----------------|---------|
| L1-严重 | < 30分钟 | < 1小时 | 主库宕机，从库接管 |
| L2-中等 | < 2小时 | < 24小时 | 数据损坏，需从备份恢复 |
| L3-轻度 | < 4小时 | < 24小时 | 误操作，需PITR恢复 |

### 1.3 备份策略

| 备份类型 | 频率 | 保留期 | 存储位置 | 说明 |
|---------|------|--------|---------|------|
| 日备份 | 每日 02:00 | 7天 | 本地 + MinIO | 全量逻辑备份 |
| 周备份 | 每周日 03:00 | 4周 | 本地 + MinIO | 全量逻辑备份 |
| 月备份 | 每月1日 04:00 | 12月 | 本地 + MinIO | 全量逻辑备份 |
| Binlog | 实时 | 7天 | 本地 | 增量恢复(PITR) |
| Redis RDB | 每日 02:30 | 7天 | 本地 | 快照备份 |
| MinIO数据 | 每日 02:45 | 7天 | 本地 | 对象存储备份 |
| Nacos配置 | 每日 02:15 | 7天 | 本地 | 配置中心备份 |

---

## 2. 备份架构

```
┌─────────────────────────────────────────────────────────────┐
│                     备份架构图                                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────┐    mysqldump     ┌──────────────┐           │
│  │ MySQL主库 │ ──────────────→ │  备份脚本     │            │
│  │ (Master)  │    binlog       │  (backup-     │            │
│  │           │ ──────────────→ │   mysql.sh)   │            │
│  └────┬─────┘                 └──────┬───────┘            │
│       │                              │                     │
│       │ replication                  │ gzip + AES-256      │
│       ▼                              ▼                     │
│  ┌──────────┐                 ┌──────────────┐            │
│  │ MySQL从库 │                 │  本地存储     │            │
│  │ (Slave)   │                 │ /data/backups│            │
│  └──────────┘                 └──────┬───────┘            │
│                                      │                     │
│                                      │ mc cp               │
│                                      ▼                     │
│                               ┌──────────────┐            │
│                               │  MinIO异地    │            │
│                               │  备份存储     │            │
│                               └──────────────┘            │
│                                                             │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐              │
│  │ Redis    │   │ MinIO    │   │ Nacos    │              │
│  │ RDB备份  │   │ 数据备份  │   │ 配置备份  │              │
│  └──────────┘   └──────────┘   └──────────┘              │
│                                                             │
│  ┌──────────────────────────────────────────┐              │
│  │  Prometheus + Grafana 监控               │              │
│  │  备份成功/失败/耗时/大小 指标采集          │              │
│  └──────────────────────────────────────────┘              │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. 备份脚本使用说明

### 3.1 脚本清单

| 脚本 | 路径 | 说明 |
|------|------|------|
| `backup-mysql.sh` | `infra/scripts/backup-mysql.sh` | MySQL全量备份 |
| `restore-mysql.sh` | `infra/scripts/restore-mysql.sh` | MySQL恢复(含PITR) |
| `backup-verify.sh` | `infra/scripts/backup-verify.sh` | 备份验证 |
| `backup-crontab` | `infra/scripts/backup-crontab` | 定时任务配置 |

### 3.2 执行备份

```bash
# 1. 设置环境变量
export DB_HOST=localhost
export DB_PORT=3306
export DB_NAME=smartwin_platform
export DB_USER=root
export DB_PASS=SmartWin@2026
export BACKUP_DIR=/data/backups/mysql
export BACKUP_ENCRYPT_KEY=YourSecretKey

# 2. 执行日备份 (加密 + MinIO上传)
./backup-mysql.sh --encrypt --upload-minio --type=daily

# 3. 执行周备份
./backup-mysql.sh --encrypt --upload-minio --type=weekly

# 4. 执行月备份
./backup-mysql.sh --encrypt --upload-minio --type=monthly

# 5. 仅本地备份 (不上传MinIO)
./backup-mysql.sh --type=daily
```

### 3.3 恢复数据库

```bash
# 1. 列出可用备份
./restore-mysql.sh --list

# 2. 恢复最新备份
./restore-mysql.sh --latest

# 3. 从指定备份文件恢复
./restore-mysql.sh --file=/data/backups/mysql/smartwin_platform_daily_20260711_020000.sql.gz

# 4. 从加密备份恢复
./restore-mysql.sh --file=/data/backups/mysql/smartwin_platform_daily_20260711_020000.sql.gz.enc --decrypt

# 5. Point-in-Time Recovery (恢复到指定时间点)
./restore-mysql.sh --file=/data/backups/mysql/smartwin_platform_daily_20260711_020000.sql.gz --pitr --target-time="2026-07-11 14:30:00"
```

### 3.4 验证备份

```bash
# 验证最新备份
./backup-verify.sh --latest

# 验证指定备份
./backup-verify.sh --file=/data/backups/mysql/smartwin_platform_daily_20260711_020000.sql.gz

# 验证所有备份
./backup-verify.sh --all
```

### 3.5 安装定时任务

```bash
# 1. 复制脚本到部署目录
mkdir -p /opt/smartwin/scripts
cp infra/scripts/backup-mysql.sh /opt/smartwin/scripts/
cp infra/scripts/restore-mysql.sh /opt/smartwin/scripts/
cp infra/scripts/backup-verify.sh /opt/smartwin/scripts/
chmod +x /opt/smartwin/scripts/*.sh

# 2. 创建环境变量配置
cat > /etc/smartwin-backup.env << 'EOF'
DB_HOST=localhost
DB_PORT=3306
DB_NAME=smartwin_platform
DB_USER=root
DB_PASS=SmartWin@2026
BACKUP_DIR=/data/backups/mysql
BACKUP_ENCRYPT_KEY=SmartWinBackup2026SecretKey
MINIO_ENDPOINT=http://localhost:9000
MINIO_ACCESS_KEY=smartwin
MINIO_SECRET_KEY=SmartWin@2026
MINIO_BUCKET=smartwin-backups
PUSHGATEWAY_URL=http://localhost:9091
EOF
chmod 600 /etc/smartwin-backup.env

# 3. 创建备份目录
mkdir -p /data/backups/{mysql,redis,minio,nacos}

# 4. 安装定时任务
cp infra/scripts/backup-crontab /etc/cron.d/smartwin-backup
chmod 644 /etc/cron.d/smartwin-backup
systemctl restart cron
```

---

## 4. 灾备恢复流程

### 4.1 场景一：主库宕机，从库接管 (L1)

```
检测主库故障 (Prometheus告警)
    │
    ▼
确认从库数据一致性 (Seconds_Behind_Source = 0)
    │
    ▼
应用层切换读写数据源 → 从库提升为主库
    │
    ▼
更新Nacos配置中的数据库连接信息
    │
    ▼
重启受影响微服务
    │
    ▼
验证系统功能正常
    │
    ▼
(事后) 修复原主库并重新配置为主库或新从库
```

**操作命令:**
```bash
# 1. 检查从库状态
mysql -h <slave_host> -P 3307 -uroot -p -e "SHOW REPLICA STATUS\G"

# 2. 从库提升为主库
mysql -h <slave_host> -P 3307 -uroot -p -e "
  STOP REPLICA;
  RESET REPLICA ALL;
  SET GLOBAL read_only=OFF;
  SET GLOBAL super_read_only=OFF;
"

# 3. 更新Nacos配置 (通过API或控制台)
curl -X PUT "http://localhost:8848/nacos/v1/cs/configs" \
  -d "dataId=application-prod.yml&group=DEFAULT_GROUP&content=..."

# 4. 重启微服务
docker-compose restart auth-service system-service
```

### 4.2 场景二：数据损坏，从备份恢复 (L2)

```
确认数据损坏范围
    │
    ▼
通知相关团队 (运维+开发+PMO)
    │
    ▼
停止写入服务 (设为只读模式)
    │
    ▼
执行备份恢复脚本
    │
    ▼
执行PITR恢复到损坏前的时间点
    │
    ▼
验证数据完整性
    │
    ▼
恢复写入服务
    │
    ▼
事后分析 + 改进措施
```

**操作命令:**
```bash
# 1. 停止写入服务 (将系统设为只读)
curl -X PUT http://localhost:9000/api/system/maintenance -d '{"mode":"readonly"}'

# 2. 创建恢复前快照
mysqldump -h localhost -P 3306 -uroot -p --single-transaction smartwin_platform | gzip > /data/backups/mysql/presnapshot_$(date +%Y%m%d).sql.gz

# 3. 恢复最新备份
./restore-mysql.sh --latest

# 4. PITR恢复到指定时间
./restore-mysql.sh --file=/data/backups/mysql/smartwin_platform_daily_20260711_020000.sql.gz --pitr --target-time="2026-07-11 10:00:00"

# 5. 验证数据
mysql -h localhost -P 3306 -uroot -p -e "
  SELECT COUNT(*) FROM smartwin_platform.sys_user;
  SELECT COUNT(*) FROM smartwin_platform.sys_tenant;
  SELECT COUNT(*) FROM smartwin_platform.sys_dict;
"

# 6. 恢复写入服务
curl -X PUT http://localhost:9000/api/system/maintenance -d '{"mode":"normal"}'
```

### 4.3 场景三：误操作，PITR恢复 (L3)

```bash
# 1. 确认误操作时间和范围
# 假设: 2026-07-11 14:30:00 误删除了sys_user表数据

# 2. 恢复到误操作前的时间点
./restore-mysql.sh \
  --file=/data/backups/mysql/smartwin_platform_daily_20260711_020000.sql.gz \
  --pitr \
  --target-time="2026-07-11 14:29:00"

# 3. 验证恢复的数据
mysql -h localhost -P 3306 -uroot -p -e "SELECT COUNT(*) FROM smartwin_platform.sys_user;"

# 4. 导出需要恢复的数据
mysqldump -h localhost -P 3306 -uroot -p smartwin_platform sys_user > /tmp/sys_user_recover.sql

# 5. 在生产库上恢复数据
mysql -h <prod_host> -P 3306 -uroot -p smartwin_platform < /tmp/sys_user_recover.sql
```

---

## 5. 监控与告警

### 5.1 Prometheus 指标

| 指标 | 类型 | 说明 |
|------|------|------|
| `mysql_backup_status` | gauge | 备份状态 (1=成功, 0=失败) |
| `mysql_backup_duration_seconds` | gauge | 备份耗时(秒) |
| `mysql_backup_size_bytes` | gauge | 备份文件大小(字节) |
| `mysql_backup_timestamp` | gauge | 备份时间戳 |
| `mysql_backup_verify_status` | gauge | 验证状态 (1=通过, 0=失败, 2=警告) |
| `mysql_backup_verify_errors` | gauge | 验证错误数 |

### 5.2 告警规则 (需添加到 alert-rules.yml)

```yaml
  # ===== 备份告警 =====
  - name: backup_alerts
    rules:
      - alert: MysqlBackupFailed
        expr: mysql_backup_status == 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "MySQL备份失败 (数据库: {{ $labels.db }})"
          description: "备份类型: {{ $labels.type }}，请立即检查"

      - alert: MysqlBackupMissing
        expr: time() - mysql_backup_timestamp > 90000
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "MySQL备份超过25小时未执行"
          description: "上次备份时间距现在已超过25小时"

      - alert: MysqlBackupVerifyFailed
        expr: mysql_backup_verify_status == 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "MySQL备份验证失败 (文件: {{ $labels.file }})"
          description: "备份文件可能已损坏，请检查"

      - alert: MysqlBackupDurationHigh
        expr: mysql_backup_duration_seconds > 3600
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "MySQL备份耗时超过1小时"
          description: "当前耗时: {{ $value }}秒"
```

---

## 6. 备份检查清单

### 6.1 日常检查 (每日)

- [ ] 检查 `/var/log/smartwin-backup-cron.log` 无错误
- [ ] 确认最新备份文件存在且大小正常
- [ ] 检查 Prometheus 备份指标正常
- [ ] 确认备份验证脚本执行通过

### 6.2 周度检查 (每周)

- [ ] 执行 `./backup-verify.sh --all` 验证所有备份
- [ ] 检查 MinIO 异地备份存储空间
- [ ] 确认周备份已生成
- [ ] 检查备份保留策略执行正常

### 6.3 月度检查 (每月)

- [ ] 执行一次完整的灾备恢复演练
- [ ] 验证月备份已生成
- [ ] 检查备份存储容量是否充足
- [ ] 更新灾备恢复手册 (如有变更)

### 6.4 季度检查 (每季度)

- [ ] 执行完整的灾备切换演练 (主从切换)
- [ ] 验证 RTO/RPO 是否达标
- [ ] 审查备份策略是否需要调整
- [ ] 更新灾备联系人信息

---

## 7. 灾备联系人

| 角色 | 姓名 | 电话 | 邮箱 |
|------|------|------|------|
| 运维负责人 | TBD | TBD | ops@smartwin.com |
| DBA | TBD | TBD | dba@smartwin.com |
| 架构师 | TBD | TBD | arch@smartwin.com |
| PMO | TBD | TBD | pmo@smartwin.com |

---

## 8. 变更日志

| 日期 | 变更内容 | 变更人 |
|------|---------|--------|
| 2026-07-11 | 创建灾备恢复手册，包含备份策略、恢复流程、监控告警、检查清单 | 运维团队 |
