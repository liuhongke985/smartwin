# ENV-01 环境总体规划与准备指南

> **文档编号**: ENV-01
> **版本**: V1.0
> **创建日期**: 2026-07-09
> **文档状态**: 正式发布
> **文档负责人**: DevOps负责人

---

## 1. 环境总体规划

### 1.1 环境体系架构

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       SmartWin 环境体系架构                              │
│                                                                         │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐     │
│  │ DEV     │→│ SIT     │→│ UAT     │→│ PERF    │→│ PROD    │     │
│  │ 开发环境 │  │ 集成测试 │  │ 用户验收 │  │ 性能测试 │  │ 生产环境 │     │
│  │ Docker  │  │ Docker  │  │ K8s     │  │ K8s     │  │ K8s     │     │
│  │ Compose │  │ Compose │  │ Cluster │  │ Cluster │  │ Cluster │     │
│  └─────────┘  └─────────┘  └─────────┘  └─────────┘  └─────────┘     │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                    共享基础设施层                                  │   │
│  │  GitLab · Harbor · SonarQube · Nexus · JIRA · Confluence        │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                    监控可观测性层                                  │   │
│  │  Prometheus · Grafana · Loki · AlertManager · Jaeger            │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

### 1.2 环境规划矩阵

| 环境 | 用途 | 部署方式 | 数据库 | 硬件要求 | 访问权限 | 生命周期 |
|------|------|---------|--------|----------|---------|:--------:|
| **DEV** | 开发调试 | Docker Compose | MySQL 8.0 | 8C/16G/200G | 开发团队 | 长期 |
| **SIT** | 集成测试 | Docker Compose | MySQL 8.0 | 16C/32G/500G | 测试团队 | 长期 |
| **UAT** | 用户验收 | K8s单节点 | DM8 | 32C/64G/1T | 业务团队 | 长期 |
| **PERF** | 性能测试 | K8s 3节点 | DM8 | 64C/128G/2T | 测试团队 | 按需 |
| **STAGE** | 预生产 | K8s 3节点 | DM8 | 32C/64G/1T | 运维团队 | 长期 |
| **PROD** | 生产环境 | K8s多节点 | DM8主从 | 128C/256G/5T | 运维团队 | 长期 |
| **DR** | 灾备环境 | K8s多节点 | DM8主从 | 128C/256G/5T | 运维团队 | 长期 |
| **SANDBOX** | 沙箱体验 | Docker Compose | H2/MySQL | 4C/8G/100G | 公开 | 按需 |

### 1.3 数据流与晋升规则

```
DEV (开发自测)
  │ ↓ PR合并
SIT (自动化测试+集成测试)
  │ ↓ 全部通过
UAT (业务验收测试)
  │ ↓ 验收签字
PERF (性能压测) ← 每月/每版本
  │ ↓ 性能达标
STAGE (预生产验证)
  │ ↓ 最终审批
PROD (正式发布)
  │ ↓ 异步同步
DR (灾备同步)
```

**晋升门禁标准**:

| 晋升路径 | 门禁条件 | 审批人 |
|---------|---------|--------|
| DEV→SIT | 代码审查通过+单元测试≥70% | 开发Lead |
| SIT→UAT | 集成测试100%通过+无P0/P1 | 测试Lead |
| UAT→PERF | UAT验收通过+业务签字 | 产品经理 |
| PERF→STAGE | 性能指标达标(P95≤200ms) | 架构师 |
| STAGE→PROD | 预生产验证通过+安全扫描 | 运维负责人 |
| PROD→DR | 数据同步完成+一致性校验 | DBA |

---

## 2. 硬件资源规划

### 2.1 生产环境硬件规划

| 节点类型 | 数量 | CPU | 内存 | 磁盘 | 网络 | 用途 |
|---------|:----:|:---:|:----:|:----:|:----:|------|
| **K8s Master** | 3 | 16C | 32G | 200G SSD | 万兆 | 集群管理 |
| **K8s Worker** | 8 | 32C | 128G | 1T SSD | 万兆 | 微服务运行 |
| **DB Master** | 1 | 32C | 128G | 2T SSD | 万兆 | 数据库主节点 |
| **DB Slave** | 2 | 32C | 128G | 2T SSD | 万兆 | 数据库从节点 |
| **Redis** | 3 | 16C | 64G | 200G SSD | 万兆 | Redis集群 |
| **ES集群** | 3 | 16C | 64G | 1T SSD | 万兆 | 搜索+日志 |
| **Neo4j** | 1 | 16C | 64G | 500G SSD | 万兆 | 图数据库 |
| **MinIO** | 4 | 8C | 32G | 5T HDD | 万兆 | 对象存储 |
| **AI推理** | 2 | 32C | 128G | 1T SSD+GPU | 万兆 | AI模型推理 |
| **监控** | 2 | 8C | 32G | 2T SSD | 千兆 | Prometheus+Grafana |
| **Nginx/SLB** | 2 | 8C | 16G | 100G SSD | 万兆 | 负载均衡 |
| **NFS** | 1 | 8C | 16G | 10T HDD | 千兆 | 共享存储 |
| **堡垒机** | 1 | 4C | 8G | 100G SSD | 千兆 | 运维跳板 |
| **合计** | 31 | 504C | 1792G | 98.9T | — | — |

### 2.2 网络拓扑规划

```
┌─────────────────────────────────────────────────────────────────┐
│                      互联网用户                                   │
│                    (HTTPS :443)                                  │
└────────────────────────┬────────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────────┐
│                   DMZ区 (192.168.1.0/24)                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                      │
│  │ F5/SLB   │  │ WAF      │  │ 堡垒机    │                      │
│  └────┬─────┘  └────┬─────┘  └──────────┘                      │
└───────┼─────────────┼──────────────────────────────────────────┘
        │             │
┌───────▼─────────────▼──────────────────────────────────────────┐
│               前端区 (192.168.2.0/24)                            │
│  ┌──────────┐  ┌──────────┐                                    │
│  │ Nginx-1  │  │ Nginx-2  │                                    │
│  └────┬─────┘  └────┬─────┘                                    │
└───────┼─────────────┼──────────────────────────────────────────┘
        │             │
┌───────▼─────────────▼──────────────────────────────────────────┐
│               应用区 (192.168.3.0/24)                            │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │ K8s      │  │ K8s      │  │ AI推理    │  │ 监控      │       │
│  │ Master×3 │  │ Worker×8 │  │ GPU×2    │  │ Grafana  │       │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └──────────┘       │
└───────┼─────────────┼─────────────┼────────────────────────────┘
        │             │             │
┌───────▼─────────────▼─────────────▼────────────────────────────┐
│               数据区 (192.168.4.0/24)                            │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │ DM8主    │  │ DM8从×2  │  │ Redis×3  │  │ ES×3     │       │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘       │
│  ┌──────────┐  ┌──────────┐                                    │
│  │ Neo4j    │  │ MinIO×4  │                                    │
│  └──────────┘  └──────────┘                                    │
└────────────────────────────────────────────────────────────────┘
```

### 2.3 端口规划

| 服务 | 端口 | 协议 | 暴露范围 |
|------|:----:|:----:|---------|
| Nginx/SLB | 443 | HTTPS | 互联网 |
| API Gateway | 9000 | HTTP | 内网 |
| Auth Service | 8081 | HTTP | 内网 |
| System Service | 8082 | HTTP | 内网 |
| ... | 8083-8090 | HTTP | 内网 |
| AI Engine | 8200-8201 | HTTP | 内网 |
| DM8 | 5236 | TCP | 数据区 |
| Redis | 6379 | TCP | 数据区 |
| ES | 9200-9300 | HTTP | 数据区 |
| Neo4j | 7474/7687 | HTTP/Bolt | 数据区 |
| MinIO | 9000-9001 | HTTP | 数据区 |
| Grafana | 3000 | HTTP | 运维区 |
| Prometheus | 9090 | HTTP | 运维区 |

---

## 3. 软件依赖准备

### 3.1 基础软件清单

| 类别 | 软件 | 版本 | 用途 | 安装方式 |
|------|------|:----:|------|---------|
| **OS** | 麒麟V10 / CentOS 7+ | V10 / 7.9 | 服务器操作系统 | ISO安装 |
| **容器** | Docker | 24.0+ | 容器运行时 | yum安装 |
| | containerd | 1.7+ | K8s容器运行时 | 随K8s安装 |
| **编排** | Kubernetes | 1.28+ | 容器编排 | kubeadm/Rancher |
| | Helm | 3.13+ | 包管理 | 二进制安装 |
| **JDK** | 毕昇JDK / Temurin | 17 | Java运行时 | tar包安装 |
| **数据库** | 达梦DM8 | 8.1+ | 主数据库 | DM安装包 |
| | MySQL(DEV) | 8.0+ | 开发数据库 | Docker |
| **缓存** | Redis | 7.2+ | 分布式缓存 | Docker/源码 |
| **消息** | Kafka | 3.6+ | 消息队列 | Helm |
| **搜索** | Elasticsearch | 8.13+ | 全文搜索 | Helm/Docker |
| **图库** | Neo4j | 5.20+ | 数据血缘 | Docker |
| **存储** | MinIO | 最新 | 对象存储 | Docker/Helm |
| **注册** | Nacos | 2.4+ | 服务注册+配置 | Docker/Helm |
| **监控** | Prometheus | 2.50+ | 指标采集 | Helm |
| | Grafana | 10.4+ | 可视化看板 | Helm |
| | Loki | 3.0+ | 日志聚合 | Helm |
| | AlertManager | 0.27+ | 告警管理 | Helm |
| **CI/CD** | GitLab | 16.9+ | 代码仓库 | Helm |
| | Harbor | 2.10+ | 镜像仓库 | Helm |
| | SonarQube | 10.4+ | 代码质量 | Helm |
| **网关** | Nginx | 1.24+ | 反向代理 | yum/源码 |

### 3.2 信创环境适配清单

| 类别 | 信创产品 | 对应开源/商业 | 适配状态 |
|------|---------|:------------:|:--------:|
| **OS** | 麒麟V10 | CentOS替代 | ✅ |
| | 统信UOS | Ubuntu替代 | ✅ |
| | openEuler | CentOS替代 | ✅ |
| **CPU** | 飞腾2000+ | ARM64 | ✅ |
| | 鲲鹏920 | ARM64 | ✅ |
| | 龙芯3C5000 | LoongArch | ✅ |
| | 海光C86 | x86_64 | ✅ |
| **数据库** | 达梦DM8 | Oracle兼容 | ✅ |
| | 金仓Kingbase | PostgreSQL兼容 | ✅ |
| | openGauss | PostgreSQL开源 | ✅ |
| **中间件** | 东方通TongWeb | Tomcat替代 | ✅ |
| | 中创InforSuite | Nginx替代 | ✅ |
| **浏览器** | 奇安信浏览器 | Chrome内核 | ✅ |

---

## 4. 环境准备检查清单

### 4.1 基础环境检查

| 序号 | 检查项 | 检查方法 | 通过标准 | 状态 |
|:----:|--------|---------|---------|:----:|
| 1 | OS版本 | `cat /etc/os-release` | 麒麟V10/CentOS 7+ | ☐ |
| 2 | 内核版本 | `uname -r` | ≥ 4.19 | ☐ |
| 3 | CPU架构 | `uname -m` | x86_64/aarch64 | ☐ |
| 4 | 磁盘空间 | `df -h` | / ≥ 200G, /data ≥ 2T | ☐ |
| 5 | 内存 | `free -h` | ≥ 64G(生产) | ☐ |
| 6 | 时间同步 | `chronyc tracking` | 偏差 < 50ms | ☐ |
| 7 | DNS解析 | `nslookup` | 内网DNS可达 | ☐ |
| 8 | 防火墙 | `firewall-cmd --list-all` | 仅开放必要端口 | ☐ |
| 9 | SELinux | `getenforce` | Disabled/Permissive | ☐ |
| 10 | 文件描述符 | `ulimit -n` | ≥ 65536 | ☐ |
| 11 | 最大进程数 | `ulimit -u` | ≥ 32768 | ☐ |
| 12 | Swap | `swapon -s` | 生产环境关闭 | ☐ |
| 13 | 网络连通性 | `ping/ip route` | 各网段可达 | ☐ |
| 14 | SSH互信 | `ssh` | 管理节点互信 | ☐ |

### 4.2 软件依赖检查

| 序号 | 检查项 | 检查命令 | 通过标准 | 状态 |
|:----:|--------|---------|---------|:----:|
| 1 | Docker | `docker version` | 24.0+ | ☐ |
| 2 | Docker Compose | `docker-compose version` | 2.20+ | ☐ |
| 3 | K8s集群 | `kubectl get nodes` | All Ready | ☐ |
| 4 | Helm | `helm version` | 3.13+ | ☐ |
| 5 | JDK | `java -version` | 17 | ☐ |
| 6 | DM8 | `disql SYSDBA/SYSDBA` | 连接成功 | ☐ |
| 7 | Redis | `redis-cli ping` | PONG | ☐ |
| 8 | ES | `curl localhost:9200` | 响应正常 | ☐ |
| 9 | Neo4j | `curl localhost:7474` | 响应正常 | ☐ |
| 10 | MinIO | `curl localhost:9001` | Web可访问 | ☐ |
| 11 | Nacos | `curl localhost:8848/nacos` | Web可访问 | ☐ |
| 12 | Kafka | `kafka-topics --list` | 列出Topic | ☐ |
| 13 | GitLab | `curl gitlab.example.com` | Web可访问 | ☐ |
| 14 | Harbor | `curl harbor.example.com` | Web可访问 | ☐ |
| 15 | Prometheus | `curl localhost:9090/-/healthy` | 健康检查通过 | ☐ |
| 16 | Grafana | `curl localhost:3000/api/health` | 健康检查通过 | ☐ |

### 4.3 网络与安全检查

| 序号 | 检查项 | 检查方法 | 通过标准 | 状态 |
|:----:|--------|---------|---------|:----:|
| 1 | SSL证书 | `openssl s_client` | 有效期>90天 | ☐ |
| 2 | 防火墙规则 | `iptables -L` | 最小化开放 | ☐ |
| 3 | 安全组 | 云控制台 | 仅必要端口 | ☐ |
| 4 | VPN/堡垒机 | 连接测试 | 可访问内网 | ☐ |
| 5 | 数据库端口 | `nmap -p 5236` | 仅内网可达 | ☐ |
| 6 | Redis端口 | `nmap -p 6379` | 仅内网+认证 | ☐ |
| 7 | 管理端口 | `nmap -p 22` | 仅堡垒机可达 | ☐ |

---

## 5. 环境配置基线

### 5.1 系统参数基线

```bash
# /etc/sysctl.conf 系统内核参数
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_tw_reuse = 1
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 65535
vm.swappiness = 0
vm.overcommit_memory = 1
vm.max_map_count = 262144
fs.file-max = 2097152

# /etc/security/limits.conf 资源限制
* soft nofile 655360
* hard nofile 655360
* soft nproc 655360
* hard nproc 655360
* soft memlock unlimited
* hard memlock unlimited
```

### 5.2 Docker配置基线

```json
// /etc/docker/daemon.json
{
  "data-root": "/data/docker",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "5"
  },
  "storage-driver": "overlay2",
  "insecure-registries": ["harbor.smartwin.local"],
  "registry-mirrors": ["https://harbor.smartwin.local"],
  "live-restore": true,
  "max-concurrent-downloads": 10,
  "max-concurrent-uploads": 5,
  "default-ulimits": {
    "nofile": {
      "Name": "nofile",
      "Hard": 655360,
      "Soft": 655360
    }
  }
}
```

### 5.3 K8s节点标签规划

```bash
# 节点标签
kubectl label nodes <node> node-role.smartwin.io/zone=frontend
kubectl label nodes <node> node-role.smartwin.io/zone=application
kubectl label nodes <node> node-role.smartwin.io/zone=data
kubectl label nodes <node> node-role.smartwin.io/zone=monitoring
kubectl label nodes <node> node-role.smartwin.io/zone=ai-gpu

# 污点容忍
kubectl taint nodes <ai-node> nvidia.com/gpu=true:NoSchedule
```

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-09 | DevOps负责人 | 初始版本: 环境体系规划+硬件资源+网络拓扑+软件依赖+检查清单+配置基线 |
