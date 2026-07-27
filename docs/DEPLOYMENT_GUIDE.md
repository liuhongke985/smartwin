# SmartWin 部署指南

## 文档信息
- **版本**: 1.0.0
- **创建日期**: 2026-07-27

---

## 目录
1. [环境要求](#1-环境要求)
2. [本地开发部署](#2-本地开发部署)
3. [Kubernetes部署](#3-kubernetes部署)
4. [配置管理](#4-配置管理)
5. [健康检查](#5-健康检查)

---

## 1. 环境要求

### 1.1 硬件要求

| 环境 | CPU | 内存 | 磁盘 |
|------|-----|------|------|
| 开发 | 4核 | 16GB | 100GB |
| 测试 | 8核 | 32GB | 200GB |
| 生产 | 16核+ | 64GB+ | 1TB+ |

### 1.2 软件要求

| 软件 | 版本 | 必需 |
|------|------|------|
| Docker | 24.0+ | 是 |
| Docker Compose | 2.20+ | 开发环境 |
| Kubernetes | 1.28+ | 生产环境 |
| Helm | 3.12+ | 生产环境 |
| Java | 17 LTS | 是 |
| Node.js | 18 LTS+ | 前端构建 |

---

## 2. 本地开发部署

### 2.1 快速启动

```bash
# 1. 克隆仓库
git clone https://github.com/liuhongke985/smartwin.git
cd smartwin

# 2. 初始化项目
./scripts/init-project.sh

# 3. 启动基础设施
docker-compose up -d mysql redis elasticsearch

# 4. 等待服务就绪
docker-compose ps

# 5. 构建并启动后端
mvn clean package -DskipTests
java -jar target/smartwin.jar --spring.profiles.active=dev

# 6. 启动前端 (新终端)
cd frontend && npm install && npm run dev
```

### 2.2 使用 Makefile

```bash
make docker-up    # 启动所有Docker服务
make build        # 构建所有模块
make test         # 运行所有测试
make docker-down  # 停止所有服务
```

---

## 3. Kubernetes部署

### 3.1 使用 Helm 部署

```bash
# 添加 SmartWin Helm 仓库
helm repo add smartwin https://charts.smartwin.example.com

# 创建命名空间
kubectl create namespace smartwin

# 部署
helm install smartwin smartwin/smartwin \
  --namespace smartwin \
  --values helm/values-production.yaml \
  --set image.tag=v1.0.0

# 查看状态
kubectl get pods -n smartwin
```

### 3.2 滚动更新

```bash
# 更新镜像版本
helm upgrade smartwin smartwin/smartwin \
  --namespace smartwin \
  --set image.tag=v1.1.0

# 查看更新状态
kubectl rollout status deployment/smartwin-gateway -n smartwin
```

### 3.3 回滚

```bash
# 查看历史版本
helm history smartwin -n smartwin

# 回滚到上一版本
helm rollback smartwin -n smartwin

# 回滚到指定版本
helm rollback smartwin 2 -n smartwin
```

---

## 4. 配置管理

### 4.1 环境变量

```bash
# 数据库配置
SPRING_DATASOURCE_URL=jdbc:mysql://localhost:3306/smartwin
SPRING_DATASOURCE_USERNAME=smartwin
SPRING_DATASOURCE_PASSWORD=<secure_password>

# Redis配置
SPRING_REDIS_HOST=localhost
SPRING_REDIS_PORT=6379
SPRING_REDIS_PASSWORD=<secure_password>

# Nacos配置
NACOS_SERVER_ADDR=localhost:8848
NACOS_NAMESPACE=smartwin-dev

# JWT配置
JWT_SECRET=<strong_secret_key>
JWT_EXPIRATION=3600
```

### 4.2 Kubernetes Secrets

```bash
# 创建密钥
kubectl create secret generic smartwin-secrets \
  --from-literal=db-cred=<db_value> \
  --from-literal=redis-cred=<redis_value> \
  --from-literal=jwt-secret=<jwt_secret> \
  -n smartwin
```

---

## 5. 健康检查

### 5.1 服务健康端点

```
GET /actuator/health        # 整体健康状态
GET /actuator/health/db     # 数据库连接状态
GET /actuator/health/redis  # Redis连接状态
GET /actuator/info          # 服务信息
GET /actuator/metrics       # 指标数据
```

### 5.2 检查所有服务状态

```bash
# 使用 kubectl
kubectl get pods -n smartwin
kubectl describe pod <pod-name> -n smartwin

# 使用脚本检查
for service in gateway smartdata smartchain; do
  status=$(curl -s http://localhost:8080/$service/actuator/health | jq .status)
  echo "$service: $status"
done
```

---

*版本: 1.0.0 | 最后更新: 2026-07-27*
