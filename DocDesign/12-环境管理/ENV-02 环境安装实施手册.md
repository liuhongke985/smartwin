# ENV-02 环境安装实施手册

> **文档编号**: ENV-02
> **版本**: V1.0
> **创建日期**: 2026-07-09
> **文档状态**: 正式发布
> **文档负责人**: DevOps工程师

---

## 1. 安装概述

### 1.1 安装阶段划分

```
阶段一: 基础设施安装 (Day 1-2)
  ├── OS初始化与系统调优
  ├── Docker/containerd安装
  └── 网络与存储配置

阶段二: K8s集群安装 (Day 2-3)
  ├── Master节点初始化
  ├── Worker节点加入
  ├── 网络插件(Calico)安装
  └── 存储类(CSI)配置

阶段三: 中间件安装 (Day 3-4)
  ├── DM8数据库安装
  ├── Redis集群安装
  ├── Elasticsearch集群安装
  ├── Neo4j安装
  ├── MinIO安装
  ├── Nacos安装
  └── Kafka安装

阶段四: 监控栈安装 (Day 4)
  ├── Prometheus安装
  ├── Grafana安装
  ├── Loki安装
  └── AlertManager安装

阶段五: SmartWin平台安装 (Day 5)
  ├── 镜像推送
  ├── Helm部署
  ├── 数据库初始化
  └── 服务验证
```

---

## 2. 阶段一: 基础设施安装

### 2.1 OS初始化脚本

```bash
#!/bin/bash
# smartwin-os-init.sh — SmartWin OS初始化
# 适用: 麒麟V10 / CentOS 7+ / Ubuntu 22+

set -e

echo "===== 1. 关闭防火墙 ====="
systemctl stop firewalld 2>/dev/null || true
systemctl disable firewalld 2>/dev/null || true

echo "===== 2. 关闭SELinux ====="
setenforce 0 2>/dev/null || true
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config 2>/dev/null || true

echo "===== 3. 关闭Swap ====="
swapoff -a
sed -i '/swap/s/^/#/' /etc/fstab

echo "===== 4. 时间同步 ====="
yum install -y chrony 2>/dev/null || apt install -y chrony 2>/dev/null
cat > /etc/chrony.conf << 'EOF'
server ntp.aliyun.com iburst
server ntp1.aliyun.com iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
allow 192.168.0.0/16
local stratum 10
logdir /var/log/chrony
EOF
systemctl enable chronyd
systemctl restart chronyd

echo "===== 5. 内核参数调优 ====="
cat > /etc/sysctl.d/99-smartwin.conf << 'EOF'
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
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system

echo "===== 6. 文件描述符限制 ====="
cat > /etc/security/limits.d/99-smartwin.conf << 'EOF'
* soft nofile 655360
* hard nofile 655360
* soft nproc 655360
* hard nproc 655360
* soft memlock unlimited
* hard memlock unlimited
EOF

echo "===== 7. 加载内核模块 ====="
modprobe br_netfilter
modprobe overlay
cat > /etc/modules-load.d/k8s.conf << 'EOF'
br_netfilter
overlay
EOF

echo "===== 8. 创建数据目录 ====="
mkdir -p /data/docker
mkdir -p /data/k8s
mkdir -p /data/logs
mkdir -p /data/backup

echo "===== OS初始化完成 ====="
```

### 2.2 Docker安装

```bash
#!/bin/bash
# smartwin-docker-install.sh

set -e

echo "===== 安装Docker ====="
# 麒麟V10/CentOS
yum install -y yum-utils
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum install -y docker-ce-24.0.9 docker-ce-cli-24.0.9 containerd.io

# 配置Docker
mkdir -p /etc/docker
cat > /etc/docker/daemon.json << 'EOF'
{
  "data-root": "/data/docker",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "5"
  },
  "storage-driver": "overlay2",
  "insecure-registries": ["harbor.smartwin.local"],
  "live-restore": true,
  "max-concurrent-downloads": 10,
  "max-concurrent-uploads": 5,
  "default-ulimits": {
    "nofile": {"Name": "nofile", "Hard": 655360, "Soft": 655360}
  }
}
EOF

systemctl enable docker
systemctl start docker
docker info
echo "===== Docker安装完成 ====="
```

---

## 3. 阶段二: K8s集群安装

### 3.1 Master节点初始化

```bash
#!/bin/bash
# smartwin-k8s-master-init.sh

set -e

echo "===== 1. 安装kubeadm/kubelet/kubectl ====="
cat > /etc/yum.repos.d/kubernetes.repo << 'EOF'
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-$basearch
enabled=1
gpgcheck=0
EOF

yum install -y kubelet-1.28.12 kubeadm-1.28.12 kubectl-1.28.12
systemctl enable kubelet

echo "===== 2. 初始化Master ====="
kubeadm init \
  --kubernetes-version=v1.28.12 \
  --apiserver-advertise-address=192.168.3.10 \
  --pod-network-cidr=10.244.0.0/16 \
  --service-cidr=10.96.0.0/12 \
  --image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers \
  --v=5

echo "===== 3. 配置kubectl ====="
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo "===== 4. 安装Calico网络 ====="
kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
kubectl create -f https://docs.projectcalico.org/manifests/custom-resources.yaml

echo "===== 5. 等待节点Ready ====="
echo "等待K8s节点就绪..."
kubectl wait --for=condition=Ready node/$(hostname) --timeout=300s

echo "===== K8s Master初始化完成 ====="
```

### 3.2 Worker节点加入

```bash
#!/bin/bash
# smartwin-k8s-worker-join.sh
# 在Master上执行kubeadm token create --print-join-command获取命令

JOIN_COMMAND=$(kubeadm token create --print-join-command)
echo "Worker节点加入命令: $JOIN_COMMAND"

# 在每个Worker节点执行
# kubeadm join 192.168.3.10:6443 --token xxx --discovery-token-ca-cert-hash xxx
```

### 3.3 存储类配置

```bash
# NFS StorageClass (用于开发/测试环境)
kubectl apply -f - << 'EOF'
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-storage
provisioner: nfs-storage
parameters:
  archiveOnDelete: "false"
reclaimPolicy: Retain
volumeBindingMode: Immediate
allowVolumeExpansion: true
EOF

# 标记默认StorageClass
kubectl patch storageclass nfs-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

---

## 4. 阶段三: 中间件安装

### 4.1 DM8数据库安装

```bash
#!/bin/bash
# smartwin-dm8-install.sh — 达梦DM8安装

set -e

echo "===== 1. 创建DM8用户 ====="
groupadd dinstall
useradd -g dinstall -m -d /home/dmdba dmdba
echo "SmartWin@2028" | passwd --stdin dmdba

echo "===== 2. 创建安装目录 ====="
mkdir -p /opt/dmdbms /opt/dmdbms/data /opt/dmdbms/arch
chown -R dmdba:dinstall /opt/dmdbms

echo "===== 3. 配置资源限制 ====="
cat >> /etc/security/limits.d/99-dm.conf << 'EOF'
dmdba soft nofile 65536
dmdba hard nofile 65536
dmdba soft nproc 65536
dmdba hard nproc 65536
dmdba soft core unlimited
dmdba hard core unlimited
EOF

echo "===== 4. 解压安装 ====="
cd /opt
chown dmdba:dinstall DM8Install.bin
su - dmdba -c "/opt/DM8Install.bin -i"

echo "===== 5. 初始化数据库 ====="
su - dmdba -c "/opt/dmdbms/bin/dminit PATH=/opt/dmdbms/data INSTANCE_NAME=SMARTWIN PORT_NUM=5236 SYSDBA_PWD=SmartWin@2028 EXTENT_SIZE=32 PAGE_SIZE=16 LOG_SIZE=2048"

echo "===== 6. 注册服务 ====="
/opt/dmdbms/script/root/dm_service_installer.sh -t dmserver -p SMARTWIN -dm_ini /opt/dmdbms/data/SMARTWIN/dm.ini

echo "===== 7. 启动DM8 ====="
systemctl enable DmServiceSMARTWIN
systemctl start DmServiceSMARTWIN

echo "===== 8. 验证连接 ====="
/opt/dmdbms/bin/disql SYSDBA/SmartWin@2028@localhost:5236 "SELECT * FROM v$version;"

echo "===== DM8安装完成 ====="
```

### 4.2 Redis集群安装

```bash
#!/bin/bash
# smartwin-redis-install.sh — Redis 3主3从集群

set -e

echo "===== 部署Redis集群(K8s) ====="
cat > /tmp/redis-cluster.yaml << 'EOF'
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: redis-cluster
  namespace: smartwin
spec:
  serviceName: redis-cluster
  replicas: 6
  selector:
    matchLabels:
      app: redis-cluster
  template:
    metadata:
      labels:
        app: redis-cluster
    spec:
      containers:
      - name: redis
        image: redis:7.2-alpine
        ports:
        - containerPort: 6379
          name: redis
        - containerPort: 16379
          name: cluster
        command:
        - redis-server
        - --cluster-enabled yes
        - --cluster-config-file nodes.conf
        - --cluster-node-timeout 5000
        - --appendonly yes
        - --requirepass SmartWin@Redis2028
        - --masterauth SmartWin@Redis2028
        resources:
          requests:
            cpu: 2
            memory: 4Gi
          limits:
            cpu: 4
            memory: 8Gi
        volumeMounts:
        - name: redis-data
          mountPath: /data
  volumeClaimTemplates:
  - metadata:
      name: redis-data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 50Gi
EOF

kubectl apply -f /tmp/redis-cluster.yaml
kubectl wait --for=condition=Ready pod -l app=redis-cluster -n smartwin --timeout=300s

echo "===== 初始化Redis集群 ====="
kubectl exec -n smartwin redis-cluster-0 -- redis-cli --cluster create \
  redis-cluster-0.redis-cluster:6379 redis-cluster-1.redis-cluster:6379 \
  redis-cluster-2.redis-cluster:6379 redis-cluster-3.redis-cluster:6379 \
  redis-cluster-4.redis-cluster:6379 redis-cluster-5.redis-cluster:6379 \
  --cluster-replicas 1 --cluster-yes \
  -a SmartWin@Redis2028

echo "===== Redis集群安装完成 ====="
```

### 4.3 Elasticsearch集群安装

```bash
#!/bin/bash
# smartwin-es-install.sh — ES 3节点集群

set -e

cat > /tmp/es-values.yaml << 'EOF'
clusterName: smartwin-es
nodeGroup: master
replicas: 3
roles:
  master: "true"
  ingest: "true"
  data: "true"

esJavaOpts: "-Xms16g -Xmx16g"
resources:
  requests:
    cpu: 4
    memory: 32Gi
  limits:
    cpu: 8
    memory: 32Gi

volumeClaimTemplate:
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 500Gi

esConfig:
  elasticsearch.yml: |
    cluster.max_shards_per_node: 5000
    indices.fielddata.cache.size: 40%
    indices.memory.index_buffer_size: 20%

extraEnvs:
  - name: ELASTIC_PASSWORD
    value: SmartWin@ES2028
  - name: xpack.security.enabled
    value: "true"
EOF

helm repo add elastic https://helm.elastic.co
helm install smartwin-es elastic/elasticsearch -f /tmp/es-values.yaml -n smartwin

echo "===== ES集群安装完成 ====="
```

### 4.4 其他中间件安装

```bash
#!/bin/bash
# smartwin-middleware-install.sh — Neo4j + MinIO + Nacos + Kafka

set -e

echo "===== 1. Neo4j安装 ====="
kubectl apply -f - << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: neo4j
  namespace: smartwin
spec:
  replicas: 1
  selector:
    matchLabels:
      app: neo4j
  template:
    metadata:
      labels:
        app: neo4j
    spec:
      containers:
      - name: neo4j
        image: neo4j:5.20-community
        ports:
        - containerPort: 7474
        - containerPort: 7687
        env:
        - name: NEO4J_AUTH
          value: neo4j/SmartWin@Neo4j2028
        - name: NEO4J_dbms_memory_heap_max__size
          value: "8G"
        resources:
          requests:
            cpu: 4
            memory: 16Gi
          limits:
            cpu: 8
            memory: 32Gi
EOF

echo "===== 2. MinIO安装 ====="
helm repo add minio https://charts.min.io/
helm install minio minio/minio -n smartwin \
  --set mode=distributed,replicas=4 \
  --set accessKey=smartwinadmin \
  --set secretKey=SmartWin@MinIO2028 \
  --set persistence.size=5Ti \
  --set resources.requests.cpu=2 \
  --set resources.requests.memory=8Gi

echo "===== 3. Nacos安装 ====="
helm repo add nacos https://nacos-group.github.io/nacos-k8s
helm install nacos nacos/nacos -n smartwin \
  --set mode=cluster \
  --set replicaCount=3 \
  --set auth.enabled=true \
  --set auth.username=nacos \
  --set auth.password=SmartWin@Nacos2028

echo "===== 4. Kafka安装 ====="
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install kafka bitnami/kafka -n smartwin \
  --set replicaCount=3 \
  --set zookeeper.replicaCount=3 \
  --set auth.clientProtocol=sasl \
  --set auth.sasl.jaas.clientPasswords=SmartWin@Kafka2028

echo "===== 中间件安装完成 ====="
```

---

## 5. 阶段四: 监控栈安装

```bash
#!/bin/bash
# smartwin-monitoring-install.sh — Prometheus + Grafana + Loki + AlertManager

set -e

echo "===== 安装kube-prometheus-stack ====="
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring \
  --create-namespace \
  --set grafana.adminPassword=SmartWin@Grafana2028 \
  --set grafana.persistence.enabled=true \
  --set grafana.persistence.size=100Gi \
  --set prometheus.prometheusSpec.retention=90d \
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=500Gi

echo "===== 安装Loki ====="
helm repo add grafana https://grafana.github.io/helm-charts
helm install loki grafana/loki -n monitoring \
  --set persistence.enabled=true \
  --set persistence.size=500Gi

echo "===== 安装Promtail ====="
helm install promtail grafana/promtail -n monitoring \
  --set config.lokiAddress=http://loki:3100/loki/api/v1/push

echo "===== 配置告警规则 ====="
kubectl apply -f - << 'EOF'
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: smartwin-alerts
  namespace: monitoring
spec:
  groups:
  - name: smartwin-platform
    rules:
    - alert: ServiceDown
      expr: up{namespace="smartwin"} == 0
      for: 2m
      labels:
        severity: critical
      annotations:
        summary: "服务 {{ $labels.pod }} 不可用"
        description: "{{ $labels.namespace }}/{{ $labels.pod }} 已宕机超过2分钟"
    - alert: HighCPU
      expr: rate(container_cpu_usage_seconds_total{namespace="smartwin"}[5m]) > 0.8
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "CPU使用率过高: {{ $labels.pod }}"
    - alert: HighMemory
      expr: container_memory_working_set_bytes{namespace="smartwin"} / container_spec_memory_limit_bytes{namespace="smartwin"} > 0.85
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "内存使用率过高: {{ $labels.pod }}"
    - alert: PodRestart
      expr: increase(kube_pod_container_status_restarts_total{namespace="smartwin"}[1h]) > 3
      labels:
        severity: warning
      annotations:
        summary: "Pod频繁重启: {{ $labels.pod }}"
EOF

echo "===== 监控栈安装完成 ====="
```

---

## 6. 阶段五: SmartWin平台安装

### 6.1 镜像推送

```bash
#!/bin/bash
# smartwin-images-push.sh

set -e

HARBOR="harbor.smartwin.local/smartwin"

# 登录Harbor
docker login harbor.smartwin.local -u admin -p SmartWin@Harbor2028

# 构建并推送所有镜像
SERVICES=(
  "gateway" "auth-service" "system-service" "security-service"
  "audit-service" "config-service" "notification-service" "dashboard-service"
  "model-service" "app-service" "agent-service" "cost-service" "risk-service"
  "catalog-service" "metadata-service" "quality-service" "standard-service"
  "lineage-service" "master-data-service" "data-api-service" "asset-service"
)

for svc in "${SERVICES[@]}"; do
  echo "===== 构建推送: $svc ====="
  cd /opt/smartwin/$svc
  docker build -t $HARBOR/$svc:V1.0 .
  docker push $HARBOR/$svc:V1.0
done

# AI引擎
cd /opt/smartwin/ai-engine
docker build -t $HARBOR/ai-engine:V1.0 .
docker push $HARBOR/ai-engine:V1.0

# 前端
cd /opt/smartwin/frontend
docker build -t $HARBOR/smartchain-frontend:V1.0 .
docker push $HARBOR/smartchain-frontend:V1.0

echo "===== 镜像推送完成 ====="
```

### 6.2 Helm部署

```bash
#!/bin/bash
# smartwin-platform-deploy.sh

set -e

echo "===== 1. 创建命名空间 ====="
kubectl create namespace smartwin --dry-run=client -o yaml | kubectl apply -f -

echo "===== 2. 创建密钥 ====="
kubectl create secret generic smartwin-db-secret -n smartwin \
  --from-literal=password=SmartWin@DM82028 \
  --from-literal=username=SYSDBA \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic smartwin-redis-secret -n smartwin \
  --from-literal=password=SmartWin@Redis2028 \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic smartwin-jwt-secret -n smartwin \
  --from-literal=secret=SmartWin-JWT-Secret-Key-2025-Production \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic smartwin-ai-secret -n smartwin \
  --from-literal=openai-key=sk-xxx \
  --from-literal=anthropic-key=sk-ant-xxx \
  --dry-run=client -o yaml | kubectl apply -f -

echo "===== 3. 数据库初始化 ====="
kubectl apply -f /opt/smartwin/helm/templates/job-db-init.yaml -n smartwin
kubectl wait --for=condition=complete job/db-init -n smartwin --timeout=600s

echo "===== 4. 部署SmartWin平台 ====="
helm install smartwin /opt/smartwin/helm -n smartwin \
  --set image.tag=V1.0 \
  --set image.repository=harbor.smartwin.local/smartwin \
  --set environment=prod \
  --set replicas.gateway=2 \
  --set replicas.auth=2 \
  --set replicas.system=1 \
  --set replicas.audit=1 \
  --set replicas.model=2 \
  --set replicas.agent=2 \
  --set replicas.catalog=2 \
  --set hpa.enabled=true \
  --set hpa.minReplicas=2 \
  --set hpa.maxReplicas=10

echo "===== 5. 等待所有Pod就绪 ====="
kubectl wait --for=condition=Ready pod -n smartwin --all --timeout=600s

echo "===== 6. 验证服务 ====="
kubectl get pods -n smartwin
kubectl get svc -n smartwin
kubectl get ingress -n smartwin

echo "===== SmartWin平台部署完成 ====="
```

---

## 7. 安装后验证

### 7.1 自动化验证脚本

```bash
#!/bin/bash
# smartwin-install-verify.sh — 安装验证

set -e

PASS=0
FAIL=0

check() {
  if eval "$2" > /dev/null 2>&1; then
    echo "✅ $1"
    PASS=$((PASS+1))
  else
    echo "❌ $1"
    FAIL=$((FAIL+1))
  fi
}

echo "===== 1. K8s集群验证 ====="
check "K8s节点全部Ready" "kubectl get nodes | grep -v Ready | grep -v NAME | wc -l | grep -q '^0$'"
check "K8s组件健康" "kubectl get componentstatus | grep -c Healthy | grep -q '4'"
check "CoreDNS运行" "kubectl get pods -n kube-system | grep coredns | grep -c Running | grep -q '2'"

echo "===== 2. 中间件验证 ====="
check "DM8可达" "kubectl exec -n smartwin smartwin-db-0 -- /opt/dmdbms/bin/disql SYSDBA/SmartWin@2028@localhost:5236 'SELECT 1;'"
check "Redis集群" "kubectl exec -n smartwin redis-cluster-0 -- redis-cli -a SmartWin@Redis2028 CLUSTER INFO | grep cluster_state | grep ok"
check "ES健康" "curl -s -u elastic:SmartWin@ES2028 http://smartwin-es-master:9200/_cluster/health | grep green"
check "Neo4j连接" "kubectl exec -n smartwin neo4j-0 -- cypher-shell -u neo4j -p SmartWin@Neo4j2028 'RETURN 1;'"
check "MinIO连接" "kubectl exec -n smartwin minio-0 -- mc alias set local http://localhost:9000 smartwinadmin SmartWin@MinIO2028"
check "Nacos可用" "curl -s http://nacos:8848/nacos/v1/console/health/readiness | grep true"
check "Kafka Topic" "kubectl exec -n smartwin kafka-0 -- kafka-topics.sh --bootstrap-server kafka:9092 --list"

echo "===== 3. SmartWin服务验证 ====="
check "Gateway健康" "curl -s http://gateway:9000/actuator/health | grep UP"
check "AuthService健康" "curl -s http://auth-service:8081/actuator/health | grep UP"
check "SystemService健康" "curl -s http://system-service:8082/actuator/health | grep UP"
check "ModelService健康" "curl -s http://model-service:8083/actuator/health | grep UP"
check "AgentService健康" "curl -s http://agent-service:8085/actuator/health | grep UP"
check "CatalogService健康" "curl -s http://catalog-service:8088/actuator/health | grep UP"

echo "===== 4. 监控验证 ====="
check "Prometheus健康" "curl -s http://prometheus:9090/-/healthy | grep Prometheus"
check "Grafana健康" "curl -s http://grafana:3000/api/health | grep ok"
check "Loki健康" "curl -s http://loki:3100/ready | grep ready"

echo ""
echo "===== 验证结果: 通过 $PASS / 失败 $FAIL ====="

if [ $FAIL -gt 0 ]; then
  echo "❌ 存在失败项，请检查后重试"
  exit 1
else
  echo "✅ 所有验证项通过"
  exit 0
fi
```

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-09 | DevOps工程师 | 初始版本: 5阶段安装流程+自动化脚本+验证脚本 |
