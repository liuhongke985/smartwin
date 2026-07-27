# 部署方案

## 文档控制

| 信息项 | 内容 |
|--------|------|
| **文档编号** | DEP-01 |
| **文档版本** | V1.0 |
| **创建日期** | 2026-07-08 |
| **最后修订** | 2026-07-08 |
| **文档状态** | 正式发布 |
| **文档负责人** | DevOps |
| **审批人** | 架构师 |

---

## 1. 部署架构概述

### 1.1 部署模式

| 模式 | 说明 | 适用场景 |
|------|------|----------|
| 智链独立部署 | 7共享+6智链+AI引擎+智链前端 | 仅需AI运营平台 |
| 智数独立部署 | 7共享+9智数+智数前端 | 仅需数据治理平台 |
| 集成部署 | 全量服务+双前端 | 双产品一体化 |
| SaaS部署 | 全量+多租户隔离 | 云化服务 |

### 1.2 环境规划

| 环境 | 用途 | 数据库 | 说明 |
|------|------|--------|------|
| DEV | 开发调试 | H2/MySQL | Docker Compose |
| SIT | 集成测试 | MySQL | Docker Compose |
| UAT | 用户验收 | DM8 | 与生产一致 |
| PERF | 性能测试 | DM8 | 独立隔离 |
| PROD | 生产环境 | DM8 | 正式运行 |

---

## 2. Docker容器化部署

### 2.1 容器清单

| 分类 | 容器 | 镜像 | 端口 |
|------|------|------|:----:|
| 基础设施 | nacos | nacos/nacos-server:v2.4 | 8848 |
| 基础设施 | mysql/dm8 | mysql:8.0 / dm8:v8.1 | 3306/5236 |
| 基础设施 | redis | redis:7.2-alpine | 6379 |
| 基础设施 | elasticsearch | elasticsearch:8.13 | 9200 |
| 基础设施 | neo4j | neo4j:5.20 | 7474/7687 |
| 基础设施 | minio | minio/minio:latest | 9001 |
| AI引擎 | ai-engine-intelchain | smartwin/ai-engine:latest | 8200/8201 |
| 网关 | gateway | smartwin/gateway:latest | 9000 |
| 共享服务 | auth-service | smartwin/auth-service:latest | 8081 |
| 共享服务 | system-service | smartwin/system-service:latest | 8082 |
| 共享服务 | security-service | smartwin/security-service:latest | 8090 |
| 共享服务 | audit-service | smartwin/audit-service:latest | 8100 |
| 智链服务 | model-service | smartwin/model-service:latest | 8083 |
| 智链服务 | app-service | smartwin/app-service:latest | 8084 |
| 智链服务 | agent-service | smartwin/agent-service:latest | 8085 |
| 智链服务 | cost-service | smartwin/cost-service:latest | 8086 |
| 智链服务 | risk-service | smartwin/risk-service:latest | 8087 |
| 智链服务 | prompt-service | smartwin/prompt-service:latest | 8088 |
| 智数服务 | catalog-service | smartwin/catalog-service:latest | 8091 |
| 智数服务 | metadata-service | smartwin/metadata-service:latest | 8092 |
| 智数服务 | quality-service | smartwin/quality-service:latest | 8093 |
| 智数服务 | standard-service | smartwin/standard-service:latest | 8094 |
| 智数服务 | lineage-service | smartwin/lineage-service:latest | 8095 |
| 智数服务 | mdm-service | smartwin/mdm-service:latest | 8096 |
| 智数服务 | lifecycle-service | smartwin/lifecycle-service:latest | 8097 |
| 智数服务 | dataservice-service | smartwin/dataservice-service:latest | 8098 |
| 智数服务 | asset-service | smartwin/asset-service:latest | 8099 |
| 前端 | intelchain-frontend | nginx:alpine | 80→/ic/ |
| 前端 | smartdata-frontend | nginx:alpine | 80→/sd/ |
| 监控 | prometheus | prom/prometheus:latest | 9090 |
| 监控 | grafana | grafana/grafana:latest | 3000 |
| 监控 | loki | grafana/loki:latest | 3100 |

### 2.2 Docker Compose编排

```yaml
# docker-compose.prod.yml (集成模式)
version: '3.8'

services:
  # ===== 基础设施 =====
  nacos:
    image: nacos/nacos-server:v2.4
    environment:
      MODE: standalone
    ports: ["8848:8848"]

  dm8:
    image: dm8:v8.1
    environment:
      CASE_SENSITIVE: 1
    ports: ["5236:5236"]
    volumes: ["dm8_data:/opt/dmdbms/data"]

  redis:
    image: redis:7.2-alpine
    ports: ["6379:6379"]

  elasticsearch:
    image: elasticsearch:8.13
    environment:
      discovery.type: single-node
      xpack.security.enabled: "false"
    ports: ["9200:9200"]

  neo4j:
    image: neo4j:5.20
    environment:
      NEO4J_AUTH: neo4j/smartwin123
    ports: ["7474:7474", "7687:7687"]

  minio:
    image: minio/minio:latest
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: smartwin
      MINIO_ROOT_PASSWORD: SmartWin@2026
    ports: ["9000:9000", "9001:9001"]

  # ===== AI引擎 =====
  ai-engine:
    image: smartwin/ai-engine:latest
    depends_on: [redis]
    ports: ["8200:8200", "8201:8201"]

  # ===== 网关 =====
  gateway:
    image: smartwin/gateway:latest
    depends_on: [nacos]
    ports: ["9000:9000"]

  # ===== 共享服务 =====
  auth-service:
    image: smartwin/auth-service:latest
    depends_on: [nacos, dm8, redis]
    # ...其他服务类似

volumes:
  dm8_data:
  es_data:
  neo4j_data:
  minio_data:
```

---

## 3. 构建流程

### 3.1 后端构建

```bash
# Maven构建
mvn clean package -DskipTests

# Docker镜像构建
docker build -t smartwin/auth-service:latest \
  -f auth-service/Dockerfile auth-service/
```

### 3.2 Dockerfile模板

```dockerfile
# Java服务Dockerfile
FROM eclipse-temurin:17-jre-alpine
LABEL maintainer="SmartWin Team"

WORKDIR /app
COPY target/*.jar app.jar

ENV JAVA_OPTS="-Xms256m -Xmx512m -Duser.timezone=Asia/Shanghai"
ENV SPRING_PROFILES_ACTIVE=prod

EXPOSE 8080
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

### 3.3 前端构建

```bash
# 智链前端构建
cd smartchain/smartchain-frontend
npm run build
# 输出 dist/ → Nginx托管

# 智数前端构建
cd smartdata/smartdata-frontend
npm run build
```

### 3.4 AI引擎构建

```bash
cd smartchain/smartchain-ai-engine
docker build -t smartwin/ai-engine:latest .
```

---

## 4. CI/CD流水线

### 4.1 流水线阶段

```
代码提交 → 编译构建 → 单元测试 → 代码扫描 → 镜像构建 → 镜像推送 → 部署
```

### 4.2 GitHub Actions流水线

| 流水线 | 触发条件 | 说明 |
|--------|----------|------|
| ci.yml | push到develop/main | 编译+测试+扫描 |
| cd.yml | tag发布 | 镜像构建+推送+部署 |
| pr-check.yml | Pull Request | 编译+测试+扫描检查 |

### 4.3 部署策略

| 策略 | 说明 | 适用 |
|------|------|------|
| 滚动部署 | 逐个替换容器 | 生产环境 |
| 蓝绿部署 | 双环境切换 | 关键版本 |
| 金丝雀部署 | 小流量验证 | 高风险变更 |

---

## 5. 网络与域名规划

### 5.1 端口规划

| 用途 | 端口 | 说明 |
|------|:----:|------|
| Nginx(前端入口) | 80/443 | HTTPS入口 |
| API网关 | 9000 | 后端API入口 |
| Nacos | 8848 | 注册中心 |
| DM8 | 5236 | 达梦数据库 |
| Redis | 6379 | 缓存 |
| Elasticsearch | 9200 | 搜索引擎 |
| Neo4j | 7474/7687 | 图数据库 |
| MinIO | 9000/9001 | 对象存储 |
| Prometheus | 9090 | 监控 |
| Grafana | 3000 | 可视化 |

### 5.2 Nginx反向代理

```nginx
upstream gateway {
    server gateway:9000;
}

server {
    listen 443 ssl http2;
    server_name smartwin.example.com;

    # SSL国密证书
    ssl_certificate /etc/nginx/ssl/server.crt;
    ssl_certificate_key /etc/nginx/ssl/server.key;

    # 智链前端
    location /ic/ {
        alias /usr/share/nginx/html/intelchain/;
        try_files $uri $uri/ /ic/index.html;
    }

    # 智数前端
    location /sd/ {
        alias /usr/share/nginx/html/smartdata/;
        try_files $uri $uri/ /sd/index.html;
    }

    # API代理
    location /api/ {
        proxy_pass http://gateway;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

## 6. 信创环境部署

### 6.1 信创环境要求

| 组件 | 要求 |
|------|------|
| CPU | 鲲鹏920 / 飞腾2000+ (ARM64) |
| OS | 麒麟V10 / 统信UOS |
| 数据库 | 达梦DM8 8.1+ |
| JDK | 毕昇JDK 17 (ARM64) |
| 国密 | SM2证书 + SM4加密 |

### 6.2 ARM64镜像构建

```bash
# 多架构构建
docker buildx build --platform linux/arm64,linux/amd64 \
  -t smartwin/auth-service:latest \
  --push .
```

---

## 7. 数据库初始化

### 7.1 初始化流程

```
1. 创建数据库 → 2. 执行platform-schema.sql → 3. Flyway自动迁移 → 4. 初始化数据
```

### 7.2 初始化脚本

```bash
# 开发环境
./infra/scripts/init-database.sh

# 生产环境(DM8)
./infra/scripts/init-database-dm8.sh
```

---

## 8. 回滚方案

### 8.1 回滚策略

| 场景 | 回滚方式 | 回滚时间 |
|------|----------|:--------:|
| 应用回滚 | 切换镜像版本 | <5min |
| 数据库回滚 | Flyway undo / 备份恢复 | <30min |
| 配置回滚 | Nacos配置版本切换 | <1min |
| 全量回滚 | 蓝绿切换 | <5min |

### 8.2 回滚步骤

```bash
# 1. 确认回滚版本号
docker images smartwin/auth-service

# 2. 修改docker-compose.yml中镜像tag
# 3. 重启服务
docker-compose up -d auth-service

# 4. 验证服务
curl http://localhost:9000/api/auth/health
```

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-08 | DevOps | 初始版本发布 |
