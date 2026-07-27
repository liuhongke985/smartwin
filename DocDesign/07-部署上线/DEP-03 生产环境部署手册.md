# SmartWin 平台生产环境部署手册

## 文档控制

| 信息项 | 内容 |
|--------|------|
| **文档编号** | DEP-01 |
| **文档版本** | V1.0 |
| **创建日期** | 2026-07-08 |
| **文档状态** | 正式发布 |
| **文档负责人** | DevOps团队 |

---

## 1. 部署架构

### 1.1 整体拓扑

```
                    ┌─────────────────────────────────────┐
                    │           负载均衡 (Nginx/SLB)       │
                    │         smartwin.example.com         │
                    └──────────────┬──────────────────────┘
                                   │
                    ┌──────────────▼──────────────────────┐
                    │         API 网关 (Gateway)           │
                    │            :9000 (x2)                │
                    └──────────────┬──────────────────────┘
                                   │
          ┌────────────────────────┼────────────────────────┐
          │                        │                        │
   ┌──────▼──────┐         ┌──────▼──────┐         ┌──────▼──────┐
   │  共享服务层  │         │  智数服务层  │         │  智链服务层  │
   │  (7服务)    │         │  (8服务)    │         │  (4服务)    │
   └──────┬──────┘         └──────┬──────┘         └──────┬──────┘
          │                        │                        │
   ┌──────▼────────────────────────▼────────────────────────▼──────┐
   │                       中间件层                                  │
   │  MySQL/DM8 · Redis · MinIO · Nacos · ES · Neo4j · RocketMQ    │
   └────────────────────────────────────────────────────────────────┘
   ┌────────────────────────────────────────────────────────────────┐
   │                       监控层                                    │
   │  Prometheus · Grafana · Loki · Promtail                       │
   └────────────────────────────────────────────────────────────────┘
```

### 1.2 服务清单

| 层级 | 服务 | 端口 | 副本数 | 说明 |
|:----:|------|:----:|:------:|------|
| 网关 | gateway | 9000 | 2 | API路由+限流+鉴权 |
| 共享 | auth-service | 8080 | 2 | 认证授权 |
| 共享 | system-service | 8080 | 1 | 系统管理 |
| 共享 | audit-service | 8080 | 1 | 审计日志 |
| 共享 | config-service | 8080 | 1 | 配置中心 |
| 共享 | notification-service | 8080 | 1 | 通知服务 |
| 共享 | dashboard-service | 8080 | 1 | 仪表盘 |
| 共享 | security-service | 8080 | 1 | 安全治理 |
| 智数 | catalog-service | 8080 | 2 | 数据目录+ES搜索 |
| 智数 | metadata-service | 8080 | 1 | 元数据管理 |
| 智数 | quality-service | 8080 | 1 | 质量检测+调度 |
| 智数 | lineage-service | 8080 | 1 | 血缘图谱+Neo4j |
| 智数 | standard-service | 8080 | 1 | 数据标准 |
| 智数 | lifecycle-service | 8080 | 1 | 生命周期 |
| 智数 | dataservice-service | 8080 | 1 | 数据API+SQL执行 |
| 智数 | mdm-service | 8080 | 1 | 主数据管理 |
| 智链 | model-service | 8080 | 1 | 模型管理 |
| 智链 | agent-service | 8080 | 1 | Agent编排 |
| 智链 | app-service | 8080 | 1 | 应用管理 |
| 智链 | cost-service | 8080 | 1 | 成本管理 |

---

## 2. 环境要求

### 2.1 硬件要求

| 角色 | CPU | 内存 | 磁盘 | 说明 |
|------|:---:|:----:|:----:|------|
| 应用节点 | 8C | 16G | 100G SSD | 运行微服务 |
| 数据库节点 | 8C | 32G | 500G SSD | MySQL/DM8 |
| 中间件节点 | 4C | 16G | 200G SSD | Redis/ES/Neo4j/MinIO |
| 监控节点 | 4C | 8G | 200G SSD | Prometheus/Grafana/Loki |
| **总计(最小)** | **24C** | **72G** | **1000G** | 3节点部署 |

### 2.2 软件要求

| 组件 | 版本 | 说明 |
|------|------|------|
| OS | CentOS 7.9+ / 麒麟V10 SP3 | x86_64 或 ARM64 |
| Docker | 24.0+ | 容器运行时 |
| Docker Compose | 2.20+ | 编排工具 |
| JDK | 17+ | 仅源码编译需要 |
| Maven | 3.9+ | 仅源码编译需要 |

### 2.3 信创环境

| 组件 | 信创替代 | 说明 |
|------|----------|------|
| OS | 麒麟V10 SP3 / 统信UOS | 国产操作系统 |
| 数据库 | 达梦DM8 / 人大金仓 / openGauss | 国产数据库 |
| CPU | 鲲鹏920 / 飞腾2000+ | ARM64架构 |
| 密码 | SM2/SM3/SM4 | 国密算法 |

---

## 3. Docker Compose 部署

### 3.1 前置准备

```bash
# 1. 克隆代码仓库
git clone <repo-url> /opt/smartwin
cd /opt/smartwin/CodeProject/WebDesign

# 2. 构建所有微服务JAR
mvn clean package -DskipTests

# 3. 将JAR复制到部署目录
mkdir -p infra/docker/jars
cp platform-services/*/target/*.jar infra/docker/jars/
cp smartdata/smartdata-services/*/target/*.jar infra/docker/jars/
cp smartchain/smartchain-services/*/target/*.jar infra/docker/jars/
cp gateway/target/*.jar infra/docker/jars/

# 4. 构建前端
cd shared-components && npm install && npm run build
cp -r dist ../infra/docker/frontend/

# 5. 构建Docker镜像
cd infra/docker
for jar in jars/*.jar; do
  svc=$(basename $jar .jar)
  docker build --build-arg JAR_FILE=jars/$jar -t smartwin/$svc:latest -f Dockerfile.java .
done

# 6. 构建前端镜像
docker build -t smartwin/frontend:latest -f Dockerfile.frontend .
```

### 3.2 配置环境变量

```bash
# 创建 .env 文件
cat > .env << 'EOF'
DB_ROOT_PASSWORD=YourStrongPassword@2026
REDIS_PASSWORD=YourRedisPassword@2026
MINIO_USER=smartwin
MINIO_PASSWORD=YourMinioPassword@2026
NEO4J_PASSWORD=YourNeo4jPassword@2026
GRAFANA_PASSWORD=YourGrafanaPassword@2026
CRYPTO_MODE=standard
DS_CRYPTO_KEY=your-16-byte-key!!
EOF
```

### 3.3 启动服务

```bash
# 启动中间件（等待健康检查）
docker-compose up -d mysql redis minio nacos elasticsearch neo4j rocketmq-namesrv rocketmq-broker

# 等待中间件就绪
sleep 60

# 启动微服务
docker-compose up -d gateway auth-service system-service
docker-compose up -d catalog-service metadata-service quality-service lineage-service
docker-compose up -d standard-service lifecycle-service dataservice-service mdm-service
docker-compose up -d model-service agent-service app-service cost-service

# 启动监控
docker-compose up -d prometheus grafana loki promtail

# 启动前端
docker-compose up -d frontend
```

### 3.4 验证部署

```bash
# 检查所有容器状态
docker-compose ps

# 检查服务健康
curl http://localhost:9000/actuator/health
curl http://localhost:3000  # Grafana
curl http://localhost:9090  # Prometheus
curl http://localhost:9200/_cluster/health  # ES

# 验证登录
curl -X POST http://localhost:9000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

---

## 4. K8s Helm 部署

### 4.1 部署步骤

```bash
# 1. 创建命名空间
kubectl create namespace smartwin

# 2. 配置 values.yaml
cp infra/helm/values.yaml my-values.yaml
# 编辑 my-values.yaml 修改密码、镜像仓库等

# 3. 安装 Chart
helm install smartwin infra/helm \
  -f my-values.yaml \
  -n smartwin

# 4. 查看部署状态
kubectl get pods -n smartwin
kubectl get svc -n smartwin

# 5. 配置 Ingress
# 确保 Ingress Controller 已安装
kubectl get ingress -n smartwin
```

### 4.2 扩缩容

```bash
# 扩容网关到4副本
kubectl scale deployment gateway -n smartwin --replicas=4

# 扩容数据目录服务
kubectl scale deployment catalog-service -n smartwin --replicas=3
```

---

## 5. 信创环境部署

### 5.1 达梦DM8部署

```bash
# 1. 安装DM8（参考达梦官方文档）
# 2. 创建数据库实例
# 3. 执行初始化脚本
./infra/scripts/init-database.sh dm8

# 4. 修改微服务配置
# application-prod.yml:
#   spring.datasource.url: jdbc:dm://localhost:5236?schema=SMARTWIN
#   spring.datasource.driver-class-name: dm.jdbc.driver.DmDriver
```

### 5.2 ARM64镜像构建

```bash
# 使用 buildx 构建多架构镜像
docker buildx create --name smartwin-builder --use
docker buildx build --platform linux/arm64 \
  --build-arg JAR_FILE=app.jar \
  -t smartwin/gateway:latest-arm64 \
  -f infra/docker/Dockerfile.xinchuang \
  --push .
```

### 5.3 国密配置

```yaml
# application-xinchuang.yml
platform:
  crypto:
    mode: gm           # 启用国密模式
    datasource-key: your-sm4-key-16bytes

# 环境变量
CRYPTO_MODE=gm
DS_CRYPTO_KEY=your-sm4-key-16bytes
```

---

## 6. 网络与端口规划

| 端口 | 服务 | 协议 | 说明 |
|:----:|------|:----:|------|
| 80 | Nginx/Frontend | HTTP | 前端访问 |
| 443 | Nginx/Ingress | HTTPS | HTTPS访问 |
| 9000 | Gateway | HTTP | API网关 |
| 3306 | MySQL/DM8 | TCP | 数据库 |
| 6379 | Redis | TCP | 缓存 |
| 8848 | Nacos | HTTP | 注册中心 |
| 9000/9001 | MinIO | HTTP | 对象存储 |
| 9200 | Elasticsearch | HTTP | 搜索引擎 |
| 7687 | Neo4j | Bolt | 图数据库 |
| 9876 | RocketMQ | TCP | 消息队列 |
| 9090 | Prometheus | HTTP | 监控 |
| 3000 | Grafana | HTTP | 可视化 |
| 3100 | Loki | HTTP | 日志聚合 |

---

## 7. 部署检查清单

| 检查项 | 命令 | 预期结果 |
|--------|------|----------|
| 容器全部运行 | `docker-compose ps` | 所有服务 Up |
| 网关健康 | `curl localhost:9000/actuator/health` | `{"status":"UP"}` |
| 数据库连接 | `docker exec -it smartwin-mysql mysql -uroot -p -e "SELECT 1"` | 成功 |
| Redis连接 | `docker exec -it smartwin-redis redis-cli -a password ping` | `PONG` |
| ES健康 | `curl localhost:9200/_cluster/health` | `"status":"green"` |
| Neo4j连接 | `curl -u neo4j:password localhost:7474` | 200 OK |
| Nacos控制台 | `http://localhost:8848/nacos` | 登录页 |
| Grafana | `http://localhost:3000` | 登录页 |
| 前端页面 | `http://localhost` | 登录页 |
| API登录 | `POST /api/auth/login` | 返回Token |

---

## 8. 回滚方案

### 8.1 Docker Compose 回滚

```bash
# 回滚到上一版本
docker-compose down
# 替换JAR为旧版本
cp /backup/v1.0.0/*.jar infra/docker/jars/
docker-compose up -d
```

### 8.2 K8s 回滚

```bash
# 查看发布历史
helm history smartwin -n smartwin

# 回滚到上一版本
helm rollback smartwin 1 -n smartwin
```
