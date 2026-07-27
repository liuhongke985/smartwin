# SmartWin 故障排查指南

## 文档信息
- **版本**: 1.0.0
- **创建日期**: 2026-07-27

---

## 目录
1. [常见问题快速检索](#1-常见问题快速检索)
2. [服务启动问题](#2-服务启动问题)
3. [数据库问题](#3-数据库问题)
4. [性能问题](#4-性能问题)
5. [AI服务问题](#5-ai服务问题)
6. [诊断工具](#6-诊断工具)

---

## 1. 常见问题快速检索

| 问题 | 解决方案 |
|------|---------|
| 服务无法启动 | [查看 2.1](#21-服务无法启动) |
| 数据库连接失败 | [查看 3.1](#31-数据库连接失败) |
| API响应超时 | [查看 4.1](#41-api响应超时) |
| AI模型不可用 | [查看 5.1](#51-ai模型不可用) |
| 认证Token失效 | [查看 2.3](#23-认证问题) |
| 内存溢出 (OOM) | [查看 4.3](#43-内存问题) |

---

## 2. 服务启动问题

### 2.1 服务无法启动

**症状**: 服务启动后立即退出，日志出现异常

**诊断步骤:**
```bash
# 查看服务日志
docker-compose logs --tail=100 smartwin-gateway

# Kubernetes环境
kubectl logs -n smartwin deployment/smartwin-gateway --previous
kubectl describe pod -n smartwin -l app=smartwin-gateway
```

**常见原因及解决方案:**

| 原因 | 日志特征 | 解决方法 |
|------|---------|---------|
| 数据库不可用 | `Connection refused` | 确保MySQL已启动 |
| 端口冲突 | `Address already in use` | 检查端口占用 `lsof -i :8080` |
| 配置错误 | `Configuration error` | 检查application.yml |
| 内存不足 | `OutOfMemoryError` | 增加JVM堆内存 `-Xmx2g` |
| 依赖服务未就绪 | `Connection timeout` | 等待依赖服务启动 |

### 2.2 服务健康检查失败

```bash
# 手动检查健康端点
curl http://localhost:8080/actuator/health

# 预期响应
{"status":"UP","components":{"db":{"status":"UP"},"redis":{"status":"UP"}}}
```

### 2.3 认证问题

**症状**: API返回401或403错误

**解决方案:**
```bash
# 检查Token是否过期
# JWT Token解码 (在线工具: jwt.io)

# 刷新Token
curl -X POST http://localhost:8080/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{"refresh_token": "your_refresh_token"}'

# 检查权限配置
kubectl get configmap smartwin-rbac -n smartwin -o yaml
```

---

## 3. 数据库问题

### 3.1 数据库连接失败

**症状**: 日志出现 `Communications link failure` 或 `Connection refused`

**诊断:**
```bash
# 检查MySQL状态
docker-compose ps mysql
mysql -h localhost -u smartwin -p -e "SELECT 1"

# 检查连接数
mysql -e "SHOW STATUS LIKE 'Threads_connected'"

# 检查最大连接数
mysql -e "SHOW VARIABLES LIKE 'max_connections'"
```

**解决方案:**
```yaml
# 调整连接池配置 (application.yml)
spring:
  datasource:
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
```

### 3.2 慢查询

**诊断:**
```sql
-- 开启慢查询日志
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 1;

-- 查看当前慢查询
SELECT * FROM information_schema.PROCESSLIST 
WHERE TIME > 5 ORDER BY TIME DESC;
```

---

## 4. 性能问题

### 4.1 API响应超时

**诊断步骤:**
```bash
# 测试API响应时间
curl -w "\n响应时间: %{time_total}s\n" http://localhost:8080/api/v1/health

# 查看请求追踪 (如果有SkyWalking)
# 访问 http://localhost:8080/skywalking

# 检查数据库慢查询
tail -f /var/log/mysql/slow.log
```

### 4.2 高CPU使用率

```bash
# 查看Java线程状态
jstack <pid> | grep -A 1 "RUNNABLE" | head -50

# 找出CPU最高的线程
top -H -p <pid>
```

### 4.3 内存问题

```bash
# 生成堆转储
jmap -dump:format=b,file=/tmp/heapdump.hprof <pid>

# 分析堆转储 (使用 Eclipse MAT 或 jhat)
jhat /tmp/heapdump.hprof

# 调整JVM内存
export JAVA_OPTS="-Xms1g -Xmx4g -XX:+UseG1GC"
```

---

## 5. AI服务问题

### 5.1 AI模型不可用

**诊断:**
```bash
# 检查AI服务状态
curl http://localhost:8092/health

# 检查模型加载状态
curl http://localhost:8092/models

# 查看AI服务日志
docker-compose logs smartchain-llm
```

**常见解决方案:**
- 检查GPU/CPU资源是否充足
- 验证API密钥有效性
- 检查网络连接（外部LLM API）
- 重启AI服务容器

---

## 6. 诊断工具

### 6.1 常用命令

```bash
# 查看所有服务状态
docker-compose ps
kubectl get pods -n smartwin

# 实时日志
docker-compose logs -f service-name
kubectl logs -f deployment/service-name -n smartwin

# 进入容器
docker-compose exec service-name /bin/sh
kubectl exec -it pod-name -n smartwin -- /bin/sh

# 检查网络连通性
kubectl exec -it pod-name -n smartwin -- curl http://other-service/health
```

### 6.2 监控面板

| 工具 | URL | 用途 |
|------|-----|------|
| Grafana | http://localhost:3000 | 系统指标可视化 |
| Prometheus | http://localhost:9090 | 指标查询 |
| Kibana | http://localhost:5601 | 日志分析 |
| Nacos | http://localhost:8848/nacos | 服务注册/配置 |
| RabbitMQ | http://localhost:15672 | 消息队列监控 |

---

*版本: 1.0.0 | 最后更新: 2026-07-27*
