# SmartWin 快速开始指南

> **版本**: 1.0 | **日期**: 2026-07-27
>
> 5 分钟快速部署 SmartWin 完整环境，包括前后端 + 所有中间件

---

## 前置要求

### 系统环境

```bash
# 检查系统要求
OS: Linux (CentOS 7+) / macOS / Windows WSL2
CPU: 4核+
Memory: 8GB+
Disk: 50GB+ (docker images)

# 检查版本
java -version        # JDK 21+
maven -version       # Maven 3.9+
node -v              # Node 18+
npm -v               # npm 9+
docker --version     # Docker 20.10+
docker-compose --version  # Docker Compose 2.0+
```

### 项目克隆

```bash
# 克隆仓库
git clone https://github.com/liuhongke985/smartwin.git
cd smartwin

# 查看分支
git branch -a
# 切换到开发分支
git checkout develop
```

---

## 🚀 一键启动（推荐）

### Step 1: 启动基础设施

```bash
# 进入项目根目录
cd smartwin

# 启动所有中间件 (Docker Compose)
make docker-up

# 或者手动启动
docker-compose -f docker-compose.yml up -d

# 验证中间件状态
docker ps

# 预期输出:
# - MySQL (3306)
# - Redis (6379)
# - MinIO (9000)
# - Nacos (8848)
# - Elasticsearch (9200)
# - Neo4j (7687)
# - RocketMQ (9876)
```

### Step 2: 初始化数据库

```bash
# 初始化数据库表结构和数据
make db-init

# 或者手动执行
cd infra/sql
./init-db.sh

# 验证数据库连接
mysql -h 127.0.0.1 -u root -p123456 smartwin -e "SELECT COUNT(*) FROM sys_user;"
```

### Step 3: 编译后端

```bash
# 编译所有 Maven 模块
make install

# 或者手动编译
mvn clean install -DskipTests

# 编译输出
# BUILD SUCCESS
```

### Step 4: 启动后端服务

```bash
# 启动 API Gateway
make start-gateway

# 启动 SmartData 服务
make start-smartdata

# 启动 SmartChain 服务  
make start-smartchain

# 启动 SmartWin 门户
make start-smartwin

# 验证服务运行
curl http://localhost:9000/actuator/health
```

### Step 5: 启动前端

```bash
# 安装前端依赖
cd shared-components
npm install
cd ..

# 启动 SmartData 前端 (端口 5174)
cd smartdata/smartdata-frontend
npm install
npm run dev

# 新终端：启动 SmartChain 前端 (端口 5173)
cd smartchain/smartchain-frontend
npm install
npm run dev

# 访问应用
# SmartData: http://localhost:5174
# SmartChain: http://localhost:5173
# 网关: http://localhost:9000
```

---

## 📝 配置说明

### 核心配置文件

```yaml
# 后端配置
platform-services/
├── application.yml           # 通用配置
├── application-dev.yml       # 开发环境
├── application-prod.yml      # 生产环境

# 数据库配置
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/smartwin?useUnicode=true&characterEncoding=utf8
    username: root
    password: 123456
    driver-class-name: com.mysql.cj.jdbc.Driver

# Redis 配置
  redis:
    host: localhost
    port: 6379
    password: 

# Nacos 配置
spring:
  cloud:
    nacos:
      server-addr: localhost:8848
      namespace: smartwin-dev

# Elasticsearch 配置
spring:
  elasticsearch:
    uris:
      - http://localhost:9200
```

### 默认登录凭证

```yaml
用户名: admin
密码: admin123

备注: 首次登录后建议修改密码
```

---

## 🔍 验证安装

### 检查清单

```bash
# 1. 检查后端服务
✓ API Gateway: http://localhost:9000/doc.html
✓ SmartData: http://localhost:8081/doc.html
✓ SmartChain: http://localhost:8082/doc.html
✓ SmartWin: http://localhost:8083/doc.html

# 2. 检查前端应用
✓ SmartData: http://localhost:5174
✓ SmartChain: http://localhost:5173

# 3. 检查中间件
✓ MySQL: mysql -h localhost -u root -p123456
✓ Redis: redis-cli -h localhost
✓ Elasticsearch: curl http://localhost:9200
✓ Neo4j: http://localhost:7474 (WEB 界面)

# 4. 检查服务健康
curl http://localhost:9000/actuator/health
# 预期返回:
# {"status": "UP"}
```

### 登录应用

```
访问: http://localhost:5174 或 http://localhost:5173
用户名: admin
密码: admin123

预期:
- 成功登录
- 显示首页仪表板
- 无错误信息
```

---

## 📚 常见问题

### Q1: Docker 启动失败

```bash
# 解决方案
# 1. 检查 Docker 服务
sudo systemctl start docker

# 2. 检查磁盘空间
df -h

# 3. 检查端口占用
lsof -i :3306  # 检查 MySQL 端口
lsof -i :6379  # 检查 Redis 端口

# 4. 重新启动
docker-compose down
docker-compose up -d
```

### Q2: 编译失败 (Maven)

```bash
# 解决方案
# 1. 清除缓存
mvn clean

# 2. 更新依赖
mvn dependency:resolve

# 3. 指定 JDK 版本
export JAVA_HOME=/path/to/jdk21
mvn clean install

# 4. 检查网络
# 确保能访问 maven 中央仓库
```

### Q3: 前端包依赖错误

```bash
# 解决方案
# 1. 清除 npm 缓存
npm cache clean --force

# 2. 删除 node_modules 和 lock 文件
rm -rf node_modules package-lock.json

# 3. 重新安装
npm install

# 4. 使用 pnpm (推荐)
pnpm install
```

### Q4: 数据库连接失败

```bash
# 解决方案
# 1. 检查 MySQL 服务
docker ps | grep mysql

# 2. 检查数据库凭证
mysql -h localhost -u root -p123456 -e "SELECT 1;"

# 3. 检查网络连通性
telnet localhost 3306

# 4. 查看 MySQL 日志
docker logs smartwin-mysql
```

### Q5: 虚拟线程 JDK 版本问题

```bash
# 解决方案
# 确保使用 JDK 21+
java -version
# 输出应该包含 "21.x.x"

# 如果版本不对
export JAVA_HOME=/path/to/jdk21
export PATH=$JAVA_HOME/bin:$PATH
java -version  # 再次验证
```

---

## 🛠️ 开发命令

### Makefile 常用命令

```bash
# 基础设施
make docker-up       # 启动所有中间件
make docker-down     # 停止所有中间件
make db-init         # 初始化数据库
make docker-clean    # 清理 Docker 资源

# 后端
make install         # 编译所有模块
make start-gateway   # 启动网关
make start-smartdata # 启动数据治理
make start-smartchain # 启动模型治理
make test            # 运行单元测试
make build-image     # 构建 Docker 镜像

# 前端
make dev-sd          # 启动智数前端 (5174)
make dev-sc          # 启动智链前端 (5173)
make build-sd        # 构建智数 (生产)
make build-sc        # 构建智链 (生产)

# 日志
make logs-gateway    # 查看网关日志
make logs-all        # 查看所有日志

# 清理
make clean           # 清理编译产物
make clean-all       # 完全清理
```

### Git 工作流

```bash
# 新建开发分支
git checkout -b feature/your-feature develop

# 提交代码
git add .
git commit -m "feat: add new feature"

# 推送分支
git push origin feature/your-feature

# 创建 Pull Request
# 在 GitHub 上创建 PR

# 代码审查后合并
git checkout develop
git pull origin develop
git merge feature/your-feature
git push origin develop
```

---

## 📖 下一步

1. **阅读架构文档**: `DocDesign/04-系统设计/TECH_ARCHITECTURE.md`
2. **开发指南**: `DocDesign/05-开发实施/DEVELOPMENT_GUIDE.md`
3. **API 文档**: http://localhost:9000/doc.html
4. **代码贡献**: 参考 CONTRIBUTING.md

---

## 💬 获取帮助

```
遇到问题？
1. 查看 FAQ (本文档)
2. 提交 GitHub Issue
3. 加入讨论组 (Discussions)
4. 联系维护者
```

---

**版本**: 1.0 | **更新**: 2026-07-27 | **维护**: @liuhongke985