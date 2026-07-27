# 智赢·智链 信创全栈适配与国密算法设计方案

## 文档控制

| 信息项 | 内容 |
|--------|------|
| **文档编号** | DES-09 |
| **文档版本** | V1.0 |
| **创建日期** | 2026-07-07 |
| **最后修订** | 2026-07-07 |
| **文档状态** | 正式发布 |
| **文档负责人** | 架构师 |
| **关联文档** | DES-00 从零到一完整实现方案、多模式架构设计方案补充、项目设计开发实施计划、SmartWin智赢平台竞品分析报告V2.0 |

---

## 目录

- [第一章 信创适配现状分析与需求基线](#第一章-信创适配现状分析与需求基线)
- [第二章 信创全栈技术矩阵](#第二章-信创全栈技术矩阵)
- [第三章 多国产数据库统一适配设计](#第三章-多国产数据库统一适配设计)
- [第四章 国密算法完整体系设计](#第四章-国密算法完整体系设计)
- [第五章 信创中间件适配设计](#第五章-信创中间件适配设计)
- [第六章 信创自动检测与运行时适配](#第六章-信创自动检测与运行时适配)
- [第七章 信创部署架构](#第七章-信创部署架构)
- [第八章 信创兼容性测试矩阵与认证规划](#第八章-信创兼容性测试矩阵与认证规划)
- [第九章 信创适配实施路径与任务分解](#第九章-信创适配实施路径与任务分解)

---

# 第一章 信创适配现状分析与需求基线

## 1.1 信创产业背景与政策要求

### 1.1.1 政策驱动

| 政策文件 | 核心要求 | 对本系统影响 |
|----------|---------|-------------|
| 《"十四五"国家信息化规划》 | 党政机关信创替代2027年全面完成 | 政务客户强制要求信创全栈 |
| 《关键信息基础设施安全保护条例》 | 关键信息基础设施使用自主可控技术 | 金融/能源/通信客户强制信创 |
| 《密码法》（2020年施行） | 关键信息基础设施使用商用密码技术保护 | 强制使用国密算法 |
| 《信息安全技术 网络安全等级保护基本要求》（等保2.0） | 三级以上系统密码合规 | 国密SM系列为合规首选 |
| 国资委79号文 | 国企信创替代2027年完成 | 国企客户信创刚需 |
| 金融信创"二期"试点扩容 | 金融行业信创从办公系统向业务系统延伸 | 金融客户核心业务系统信创 |

### 1.1.2 市场驱动

根据竞品分析报告V2.0数据：

- **82.7%政企客户将"信创适配+DCMM认证"作为选型首要前提**，信创已从"加分项"变为"准入门槛"
- 信创产业市场规模2025年突破2.5万亿元，年复合增长率35%+
- 金融信创试点已覆盖超5000家金融机构
- 信创SaaS为空白蓝海市场，无竞品同时覆盖"信创+SaaS"

## 1.2 现有文档信创覆盖度审计

对现有设计文档中信创/国密相关内容进行系统性审计，识别覆盖深度与缺口：

| 文档 | 现有覆盖 | 覆盖深度 | 缺口分析 |
|------|---------|:--------:|----------|
| 从零到一完整实现方案 | 达梦DM8主库、common-dm8模块、国密工具API | ▁ 浅层 | 仅单数据库，无多DB适配；无CPU/OS/中间件适配 |
| 多模式架构设计方案补充 | xinchuang Profile、SM2/SM4配置、麒麟/ARM64配置 | ▂ 配置层 | 仅有YAML配置片段，无工程实现设计 |
| 竞品分析报告V2.0 | 信创作为差异化战略优势反复提及 | ▁ 战略层 | 仅战略定位，无技术落地 |
| 项目设计开发实施计划 | Sprint 3含3个信创任务 | ▂ 任务层 | 任务颗粒粗，无详细技术方案与验收标准 |

### 1.2.1 关键缺口清单

| 编号 | 缺口项 | 严重性 | 影响范围 |
|:----:|--------|:------:|----------|
| G-01 | **多国产数据库适配**——仅支持达梦，缺人大金仓/GBase/openGauss/PolarDB及方言抽象层 | 🔴高 | 无法满足多客户异构数据库要求 |
| G-02 | **国产CPU全栈适配**——仅泛指ARM64，缺飞腾/鲲鹏/龙芯LoongArch/海光/兆芯专项 | 🔴高 | 无法通过信创认证兼容性测试 |
| G-03 | **国产操作系统适配**——仅麒麟，缺统信UOS/openEuler及自动检测 | 🔴高 | 无法适配多OS客户环境 |
| G-04 | **国产中间件全栈**——仅东方通Redis替代，缺TongWeb/TongMQ/TongDiscovery | 🟡中 | 无法满足全栈国产化中间件要求 |
| G-05 | **国密算法完整体系**——仅SM2/SM4，缺SM3/SM9/TLCP国密SSL/证书体系/HSM | 🔴高 | 不满足《密码法》合规要求 |
| G-06 | **自动适配机制**——无运行时自动探测与路由 | 🔴高 | 无法实现"一套代码多环境自动适配" |
| G-07 | **信创兼容性测试矩阵**——无芯片×OS×DB×中间件组合测试 | 🟡中 | 无法保证信创环境稳定性 |
| G-08 | **信创认证与资质规划**——无国密认证/信创工委会/等保2.0详细规划 | 🟡中 | 影响市场准入与投标资格 |
| G-09 | **信创容器化**——无多架构Docker镜像/K8s信创集群方案 | 🟡中 | 影响信创环境容器化部署 |
| G-10 | **国产浏览器适配**——无前端浏览器兼容方案 | 🟢低 | 影响信创终端用户体验 |

## 1.3 信创适配需求基线

### 1.3.1 强制性需求（P0）

| 编号 | 需求 | 验收标准 |
|:----:|------|----------|
| XC-P0-01 | 支持达梦DM8、人大金仓KingbaseES、openGauss三种以上国产数据库 | 三种数据库全部通过功能+性能测试 |
| XC-P0-02 | 支持飞腾、鲲鹏、龙芯三种以上国产CPU架构 | 三种架构编译运行通过 |
| XC-P0-03 | 支持麒麟V10、统信UOS、openEuler三种国产OS | 三种OS部署运行通过 |
| XC-P0-04 | 全面使用国密SM2/SM3/SM4算法替代RSA/SHA/AES | 密码合规性检测通过 |
| XC-P0-05 | 支持国密SSL/TLCP协议 | 国密HTTPS双证书通信通过 |
| XC-P0-06 | 启动时自动探测信创环境并切换适配 | 标准环境与信创环境零配置切换 |
| XC-P0-07 | 通过等保2.0三级测评 | 等保三级测评报告通过 |

### 1.3.2 增强性需求（P1）

| 编号 | 需求 | 验收标准 |
|:----:|------|----------|
| XC-P1-01 | 支持南大通用GBase 8s、神通数据库、PolarDB-PG | 额外数据库适配通过 |
| XC-P1-02 | 支持海光、兆芯CPU架构 | 额外CPU架构适配通过 |
| XC-P1-03 | 支持东方通TongWeb应用服务器替代嵌入式Tomcat | TongWeb部署运行通过 |
| XC-P1-04 | 支持东方通TongMQ替代RocketMQ | TongMQ消息收发通过 |
| XC-P1-05 | 支持国密SM9标识密码算法 | SM9加解密功能通过 |
| XC-P1-06 | 集成HSM硬件密码机 | 密码机加解密性能达标 |
| XC-P1-07 | 通过国密二级密码模块认证 | 获得国密产品认证证书 |
| XC-P1-08 | 多架构Docker镜像构建（x86+ARM64+LoongArch64） | 多架构镜像推送拉取通过 |

### 1.3.3 锦上添花需求（P2）

| 编号 | 需求 | 说明 |
|:----:|------|------|
| XC-P2-01 | 支持申威SW64架构 | 超算/军工场景 |
| XC-P2-02 | 支持360安全浏览器/奇安信浏览器适配 | 信创终端浏览器兼容 |
| XC-P2-03 | 信创SaaS云部署（华为云/移动云信创区） | 信创SaaS蓝海 |
| XC-P2-04 | 信创出海（东南亚信创市场） | 国际化扩展 |

## 1.4 本文档补充范围与目标

本文档作为信创适配专项工程设计文档，系统性补充以下内容：

1. **信创全栈技术矩阵**——明确芯片/OS/数据库/中间件/浏览器的支持清单与优先级
2. **多国产数据库统一适配设计**——方言抽象层、ORM适配、自动检测路由、common-db-multi模块
3. **国密算法完整体系设计**——SM2/SM3/SM4/SM9/TLCP/证书体系/HSM/common-crypto-gm模块
4. **信创中间件适配设计**——应用服务器/消息队列/缓存/注册中心/Web服务器国产化替代
5. **信创自动检测与运行时适配**——启动探测、多架构镜像、自适应配置
6. **信创部署架构**——私有化信创拓扑/SaaS信创云/K8s信创集群
7. **信创兼容性测试矩阵与认证规划**——组合测试矩阵/认证资质路线图
8. **信创适配实施路径与任务分解**——与项目Sprint对齐的任务清单

---

# 第二章 信创全栈技术矩阵

## 2.1 信创全栈适配分层模型

```
┌─────────────────────────────────────────────────────────────────┐
│                     信创全栈适配分层模型                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Layer 7: 国产浏览器层                                           │
│  ├── 360安全浏览器 / 奇安信浏览器 / 火狐中国版 / Chromium内核    │
│  └── [P2] 前端兼容性适配                                         │
│                                                                 │
│  Layer 6: 国产中间件层                                           │
│  ├── 应用服务器: 东方通TongWeb / 宝兰德BES [P1]                 │
│  ├── 消息队列:   东方通TongMQ [P1]                               │
│  ├── 缓存:       东方通TongRDS [P1]                              │
│  ├── 注册中心:   东方通TongDiscovery [P1]                        │
│  └── Web服务器:  东方通TongWeb Server [P1]                       │
│                                                                 │
│  Layer 5: 国产数据库层                                           │
│  ├── 达梦DM8 [P0] / 人大金仓KingbaseES [P0] / openGauss [P0]   │
│  ├── 南大通用GBase 8s [P1] / 神通数据库 [P1] / PolarDB-PG [P1] │
│  └── 统一方言抽象层 + 自动检测路由                               │
│                                                                 │
│  Layer 4: 国密密码层                                             │
│  ├── SM2非对称加密 + SM3杂凑 + SM4对称加密 + SM9标识密码 [P1]  │
│  ├── TLCP国密SSL双证书 [P0] / 国密X.509证书体系 [P0]           │
│  └── HSM硬件密码机集成 [P1] / common-crypto-gm模块              │
│                                                                 │
│  Layer 3: 国产操作系统层                                         │
│  ├── 麒麟V10服务器版 [P0] / 统信UOS Server [P0]                │
│  ├── openEuler [P0] / 中标麒麟 [P1]                            │
│  └── OS自动检测与适配                                            │
│                                                                 │
│  Layer 2: 国产CPU芯片层                                         │
│  ├── 飞腾FT-2000+ [P0] / 鲲鹏920 [P0] / 龙芯LoongArch [P0]    │
│  ├── 海光Hygon [P1] / 兆芯Zhaoxin [P1]                         │
│  └── 申威SW64 [P2]                                              │
│                                                                 │
│  Layer 1: 自适应运行时底座                                       │
│  ├── JDK 17 (多架构: x86_64 / aarch64 / loongarch64)           │
│  ├── 多架构Docker镜像构建 (buildx multi-platform)              │
│  ├── 启动时环境自动探测 (CPU/OS/DB/Middleware)                  │
│  └── Spring Profile自适应加载 (standard / xinchuang)           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 2.2 国产CPU芯片适配矩阵

| 芯片厂商 | 芯片型号 | 指令集架构 | 优先级 | JDK支持 | 适配要点 |
|----------|---------|-----------|:------:|:-------:|----------|
| 飞腾 | FT-2000+/64, S2500 | ARM64 (aarch64) | P0 | 毕昇JDK 17 | ARM64原生编译，NEON指令优化 |
| 华为鲲鹏 | Kunpeng 920 | ARM64 (aarch64) | P0 | 毕昇JDK 17 / openJDK 17 | 鲲鹏加速引擎，KAE加密加速 |
| 龙芯 | 3A5000, 3C5000 | LoongArch (loongarch64) | P0 | 龙芯JDK 17 | LoongArch独立指令集，需专用JDK |
| 海光 | Hygon 7280/7390 | x86_64 (兼容AMD) | P1 | openJDK 17 | x86兼容，适配成本低 |
| 兆芯 | KaiXian KX-7000 | x86_64 (兼容VIA) | P1 | openJDK 17 | x86兼容，适配成本低 |
| 申威 | SW3232 | SW64 | P2 | openJDK 17 (SW64移植版) | 超算场景，社区支持弱 |

### 2.2.1 多架构编译构建策略

```xml
<!-- pom.xml: Maven多架构资源过滤 -->
<profiles>
    <profile>
        <id>arch-x86_64</id>
        <activation>
            <os><arch>x86_64</arch></os>
        </activation>
        <properties>
            <jdk.distro>openjdk</jdk.distro>
            <native.lib.arch>x86_64</native.lib.arch>
        </properties>
    </profile>
    <profile>
        <id>arch-aarch64</id>
        <activation>
            <os><arch>aarch64</arch></os>
        </activation>
        <properties>
            <jdk.distro>bisheng-jdk</jdk.distro>  <!-- 毕昇JDK ARM优化 -->
            <native.lib.arch>aarch64</native.lib.arch>
        </properties>
    </profile>
    <profile>
        <id>arch-loongarch64</id>
        <activation>
            <os><arch>loongarch64</arch></os>
        </activation>
        <properties>
            <jdk.distro>loongson-jdk</jdk.distro>  <!-- 龙芯JDK -->
            <native.lib.arch>loongarch64</native.lib.arch>
        </properties>
    </profile>
</profiles>
```

```dockerfile
# Dockerfile.multiarch: 多架构Docker镜像构建
FROM --platform=$BUILDPLATFORM eclipse-temurin:17-jdk AS builder
ARG TARGETARCH
ARG TARGETPLATFORM

# 根据目标架构选择JDK
RUN if [ "$TARGETARCH" = "arm64" ]; then \
        echo "使用毕昇JDK ARM64优化版"; \
    elif [ "$TARGETARCH" = "loong64" ]; then \
        echo "使用龙芯JDK LoongArch版"; \
    else \
        echo "使用标准OpenJDK x86_64"; \
    fi

COPY . /build
WORKDIR /build
RUN ./mvnw clean package -DskipTests

FROM --platform=$TARGETPLATFORM eclipse-temurin:17-jre
COPY --from=builder /build/target/*.jar /app/app.jar
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
```

```bash
# 构建多架构镜像并推送
docker buildx build \
  --platform linux/amd64,linux/arm64,linux/loong64 \
  -t registry.example.com/smartwin/auth-service:latest \
  --push \
  -f Dockerfile.multiarch .
```

## 2.3 国产操作系统适配矩阵

| 操作系统 | 版本 | 内核 | 优先级 | 适配要点 |
|----------|------|------|:------:|----------|
| 麒麟V10 | Server (SP3) | Linux 4.19 | P0 | 主流信创服务器OS，通过等保四级 |
| 统信UOS | Server 1060e | Linux 5.10 | P0 | 党政信创主力OS |
| openEuler | 22.03 LTS | Linux 5.10 | P0 | 华为开源OS，社区活跃 |
| 中标麒麟 | Server V7.0 | Linux 4.4 | P1 | 老牌信创OS |
| 麒麟V10桌面 | Desktop | Linux 4.19 | P2 | 信创终端桌面 |

### 2.3.1 OS自动检测机制

```java
/**
 * 操作系统探测器——启动时自动检测OS类型
 */
public class OsDetector {

    public enum OsType {
        KYLIN_V10("麒麟V10", "kylin"),
        UNIONTECH_UOS("统信UOS", "uos"),
        OPENEULER("openEuler", "openEuler"),
        NEOKYLIN("中标麒麟", "neokylin"),
        STANDARD_LINUX("标准Linux", "linux"),
        WINDOWS("Windows", "windows");

        private final String displayName;
        private final String profileKey;
        // ... constructor, getters
    }

    public static OsType detect() {
        String osName = System.getProperty("os.name", "").toLowerCase();
        String osVersion = System.getProperty("os.version", "");
        String osRelease = readOsRelease();

        // 读取 /etc/os-release 或 /etc/lsb-release 精确识别
        if (osRelease.contains("Kylin Linux Advanced Server V10")) {
            return OsType.KYLIN_V10;
        }
        if (osRelease.contains("UnionTech OS Server") || osRelease.contains("UOS")) {
            return OsType.UNIONTECH_UOS;
        }
        if (osRelease.contains("openEuler")) {
            return OsType.OPENEULER;
        }
        if (osRelease.contains("NeoKylin")) {
            return OsType.NEOKYLIN;
        }
        if (osName.contains("windows")) {
            return OsType.WINDOWS;
        }
        return OsType.STANDARD_LINUX;
    }

    private static String readOsRelease() {
        try {
            Path osRelease = Paths.get("/etc/os-release");
            if (Files.exists(osRelease)) {
                return Files.readString(osRelease).toLowerCase();
            }
        } catch (IOException e) {
            // 忽略，回退到系统属性判断
        }
        return "";
    }
}
```

## 2.4 国产数据库适配矩阵

| 数据库 | 厂商 | 版本 | 内核血统 | 优先级 | 适配要点 |
|--------|------|------|---------|:------:|----------|
| 达梦DM8 | 达梦数据 | 8.1+ | 自主研发（Oracle兼容） | P0 | DM方言、`dm.jdbc.driver`、SQL Oracle风格 |
| 人大金仓 | 人大金仓 | KingbaseES V8R6+ | PostgreSQL系 | P0 | PG方言、Kingbase8Dialect、`com.kingbase8.Driver` |
| openGauss | 华为开源 | 5.0+ | PostgreSQL系（增强版） | P0 | PG方言、OpenGaussDialect、`org.opengauss.Driver` |
| GBase 8s | 南大通用 | 8.8+ | Informix兼容 | P1 | Informix风格SQL、GBaseDialect |
| 神通数据库 | 神舟通用 | V7+ | 自主研发 | P1 | 神通方言、自定义Driver |
| PolarDB-PG | 阿里云 | 2.0+ | PostgreSQL系 | P1 | PG方言兼容、云原生部署 |

## 2.5 国产中间件适配矩阵

| 中间件类型 | 标准版（开源） | 信创替代 | 厂商 | 优先级 | 适配方式 |
|-----------|:-------------:|---------|------|:------:|----------|
| 应用服务器 | 嵌入式Tomcat | TongWeb 7.0 | 东方通 | P1 | Spring Boot可插拔Servlet容器 |
| 应用服务器 | 嵌入式Tomcat | BES 9.5 | 宝兰德 | P1 | Spring Boot可插拔Servlet容器 |
| 消息队列 | RocketMQ 5.2 | TongMQ 5.x | 东方通 | P1 | 统一JMS接口抽象 |
| 缓存 | Redis 7.2 | TongRDS | 东方通 | P1 | Redis协议兼容，零代码改动 |
| 注册/配置中心 | Nacos 2.3 | TongDiscovery | 东方通 | P1 | Nacos协议兼容 |
| Web服务器/反代 | Nginx | TongWeb Server | 东方通 | P1 | Nginx配置兼容 |
| 对象存储 | MinIO | MinIO (ARM64) | 开源 | P0 | 多架构镜像直接部署 |
| 搜索引擎 | Elasticsearch | ES (ARM64) | 开源 | P0 | 多架构镜像直接部署 |
| 图数据库 | Neo4j | Neo4j (ARM64) | 开源 | P0 | 多架构镜像直接部署 |

> **注**: Redis/ES/Neo4j/MinIO 本身为开源软件，在信创环境下通过多架构镜像在国产CPU上直接运行即可满足信创要求，无需国产商业替代。

## 2.6 国产浏览器适配矩阵

| 浏览器 | 内核 | 优先级 | 适配要点 |
|--------|------|:------:|----------|
| 360安全浏览器 | Chromium | P2 | 信创终端主流浏览器 |
| 奇安信浏览器 | Chromium | P2 | 党政信创终端 |
| 火狐中国版 | Gecko | P2 | 跨平台兼容 |
| Chromium (信创版) | Chromium | P2 | 开源，多架构编译 |

> 前端基于Vue 3 + TypeScript，使用标准Web API，对信创浏览器兼容性天然较好。P2阶段进行兼容性测试即可。

## 2.7 信创全栈组合兼容矩阵

以下为推荐的信创认证组合（即"信创目录"常见组合），系统需全部通过认证：

| 组合编号 | CPU | OS | 数据库 | 中间件 | 目标客户 |
|:--------:|-----|-----|--------|--------|---------|
| XC-COMBO-01 | 飞腾FT-2000+ | 麒麟V10 | 达梦DM8 | 东方通TongWeb | 党政军 |
| XC-COMBO-02 | 鲲鹏920 | openEuler | 人大金仓 | 东方通TongWeb | 金融/运营商 |
| XC-COMBO-03 | 龙芯3A5000 | 统信UOS | openGauss | 宝兰德BES | 党政/教育 |
| XC-COMBO-04 | 海光7280 | 麒麟V10 | 达梦DM8 | 东方通TongWeb | 金融 |
| XC-COMBO-05 | 鲲鹏920 | openEuler | openGauss | 嵌入式Tomcat | 互联网/混合 |
| XC-COMBO-06 | 飞腾S2500 | 麒麟V10 | 人大金仓 | 东方通TongWeb | 军工/能源 |

---

# 第三章 多国产数据库统一适配设计

## 3.1 设计目标

实现**一套代码、多种国产数据库自动适配**，解决不同客户使用不同国产数据库的异构问题。核心设计原则：

1. **方言抽象**——通过数据库方言抽象层屏蔽底层SQL差异
2. **自动检测**——启动时自动探测数据库类型并加载对应方言
3. **零代码切换**——切换数据库仅需修改配置，无需改代码
4. **SQL兼容**——统一SQL编写规范，自动处理不兼容语法

## 3.2 数据库方言抽象层（Dialect Abstraction Layer）

### 3.2.1 方言接口设计

```java
/**
 * 数据库方言抽象接口——屏蔽各国产数据库差异
 */
public interface DatabaseDialect {

    /** 获取方言标识 */
    String getDialectId();

    /** 获取数据库显示名称 */
    String getDisplayName();

    /** 获取JDBC驱动类名 */
    String getDriverClassName();

    /** 获取JDBC URL前缀 */
    String getJdbcUrlPrefix();

    /** 获取默认端口 */
    int getDefaultPort();

    /** 获取MyBatis-Plus DBType */
    DbType getMybatisPlusDbType();

    /** 获取分页SQL模板 */
    String getPaginationSql(String originalSql, long offset, long limit);

    /** 获取当前时间函数 */
    String getCurrentTimestampFunction();

    /** 获取日期格式化函数 */
    String getDateFormatFunction(String column, String pattern);

    /** 获取字符串拼接函数 */
    String getConcatFunction(String... columns);

    /** 获取布尔值字面量 */
    String getBooleanLiteral(boolean value);

    /** 获取空值判断函数 */
    String getNullCheckFunction(String column, String defaultValue);

    /** 是否支持IF NOT EXISTS语法 */
    boolean supportsIfNotExists();

    /** 是否支持ON DUPLICATE KEY UPDATE */
    boolean supportsOnDuplicateKeyUpdate();

    /** 获取批量插入SQL模板 */
    String getBatchInsertSql(String table, List<String> columns, int rowCount);

    /** SQL关键字转义符 */
    char getIdentifierQuoteChar();
}
```

### 3.2.2 各国产数据库方言实现

```java
/**
 * 达梦DM8方言实现
 */
@Component
@ConditionalOnProperty(name = "app.db.type", havingValue = "dm8")
public class Dm8Dialect implements DatabaseDialect {

    @Override
    public String getDialectId() { return "dm8"; }

    @Override
    public String getDisplayName() { return "达梦DM8"; }

    @Override
    public String getDriverClassName() { return "dm.jdbc.driver.DmDriver"; }

    @Override
    public String getJdbcUrlPrefix() { return "jdbc:dm://"; }

    @Override
    public int getDefaultPort() { return 5236; }

    @Override
    public DbType getMybatisPlusDbType() { return DbType.DM; }

    @Override
    public String getPaginationSql(String sql, long offset, long limit) {
        // 达梦兼容Oracle分页: OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
        return sql + " OFFSET " + offset + " ROWS FETCH NEXT " + limit + " ROWS ONLY";
    }

    @Override
    public String getCurrentTimestampFunction() { return "SYSDATE"; }

    @Override
    public String getDateFormatFunction(String column, String pattern) {
        return "TO_CHAR(" + column + ", '" + pattern + "')";
    }

    @Override
    public String getConcatFunction(String... columns) {
        return String.join(" || ", columns);
    }

    @Override
    public String getBooleanLiteral(boolean value) {
        return value ? "1" : "0";
    }

    @Override
    public boolean supportsIfNotExists() { return false; }

    @Override
    public boolean supportsOnDuplicateKeyUpdate() { return false; }

    @Override
    public char getIdentifierQuoteChar() { return '"'; }
}

/**
 * 人大金仓KingbaseES方言实现
 */
@Component
@ConditionalOnProperty(name = "app.db.type", havingValue = "kingbase")
public class KingbaseDialect implements DatabaseDialect {

    @Override
    public String getDialectId() { return "kingbase"; }

    @Override
    public String getDisplayName() { return "人大金仓KingbaseES"; }

    @Override
    public String getDriverClassName() { return "com.kingbase8.Driver"; }

    @Override
    public String getJdbcUrlPrefix() { return "jdbc:kingbase8://"; }

    @Override
    public int getDefaultPort() { return 54321; }

    @Override
    public DbType getMybatisPlusDbType() { return DbType.POSTGRE_SQL; }

    @Override
    public String getPaginationSql(String sql, long offset, long limit) {
        // KingbaseES兼容PostgreSQL分页: LIMIT ? OFFSET ?
        return sql + " LIMIT " + limit + " OFFSET " + offset;
    }

    @Override
    public String getCurrentTimestampFunction() { return "CURRENT_TIMESTAMP"; }

    @Override
    public String getDateFormatFunction(String column, String pattern) {
        return "TO_CHAR(" + column + ", '" + pattern + "')";
    }

    @Override
    public String getConcatFunction(String... columns) {
        return String.join(" || ", columns);
    }

    @Override
    public String getBooleanLiteral(boolean value) {
        return value ? "TRUE" : "FALSE";
    }

    @Override
    public boolean supportsIfNotExists() { return true; }

    @Override
    public boolean supportsOnDuplicateKeyUpdate() { return false; }

    @Override
    public char getIdentifierQuoteChar() { return '"'; }
}

/**
 * openGauss方言实现
 */
@Component
@ConditionalOnProperty(name = "app.db.type", havingValue = "opengauss")
public class OpenGaussDialect implements DatabaseDialect {

    @Override
    public String getDialectId() { return "opengauss"; }

    @Override
    public String getDisplayName() { return "华为openGauss"; }

    @Override
    public String getDriverClassName() { return "org.opengauss.Driver"; }

    @Override
    public String getJdbcUrlPrefix() { return "jdbc:opengauss://"; }

    @Override
    public int getDefaultPort() { return 5432; }

    @Override
    public DbType getMybatisPlusDbType() { return DbType.POSTGRE_SQL; }

    @Override
    public String getPaginationSql(String sql, long offset, long limit) {
        return sql + " LIMIT " + limit + " OFFSET " + offset;
    }

    @Override
    public String getCurrentTimestampFunction() { return "CURRENT_TIMESTAMP"; }

    @Override
    public String getDateFormatFunction(String column, String pattern) {
        return "TO_CHAR(" + column + ", '" + pattern + "')";
    }

    @Override
    public String getConcatFunction(String... columns) {
        return String.join(" || ", columns);
    }

    @Override
    public String getBooleanLiteral(boolean value) {
        return value ? "TRUE" : "FALSE";
    }

    @Override
    public boolean supportsIfNotExists() { return true; }

    @Override
    public boolean supportsOnDuplicateKeyUpdate() { return false; }

    @Override
    public char getIdentifierQuoteChar() { return '"'; }
}
```

### 3.2.3 数据库自动检测与方言路由

```java
/**
 * 数据库类型自动探测器
 * 启动时通过JDBC连接元数据自动识别数据库类型
 */
@Slf4j
public class DatabaseTypeDetector {

    private static final Map<String, String> PRODUCT_NAME_TO_DIALECT = Map.of(
        "DM DBMS",            "dm8",
        "KingbaseES",         "kingbase",
        "openGauss",          "opengauss",
        "PostgreSQL",         "kingbase",      // 兼容PG
        "GBase 8s Server",    "gbase",
        "ShenTong",           "shentong",
        "PolarDB",            "opengauss"
    );

    /**
     * 通过JDBC连接自动探测数据库类型
     */
    public static String detect(DataSource dataSource) {
        try (Connection conn = dataSource.getConnection()) {
            DatabaseMetaData metaData = conn.getMetaData();
            String productName = metaData.getDatabaseProductName();
            String productVersion = metaData.getDatabaseProductVersion();
            log.info("数据库自动探测: product={}, version={}", productName, productVersion);

            String dialectId = PRODUCT_NAME_TO_DIAULT.get(productName);
            if (dialectId != null) {
                log.info("自动匹配方言: {} -> {}", productName, dialectId);
                return dialectId;
            }
            log.warn("未知的数据库类型: {}，使用默认方言 dm8", productName);
            return "dm8";
        } catch (SQLException e) {
            log.error("数据库类型探测失败", e);
            return "dm8"; // 降级为默认
        }
    }

    private static final Map<String, String> PRODUCT_NAME_TO_DIAULT = PRODUCT_NAME_TO_DIALECT;
}

/**
 * 方言路由工厂——根据数据库类型动态选择方言实现
 */
@Component
public class DialectRouter implements ApplicationContextAware {

    private ApplicationContext ctx;
    private DatabaseDialect activeDialect;

    @Value("${app.db.type:auto}")
    private String configuredDbType;

    @Autowired
    private DataSource dataSource;

    @PostConstruct
    public void init() {
        String dialectId = "auto".equals(configuredDbType)
            ? DatabaseTypeDetector.detect(dataSource)
            : configuredDbType;

        Map<String, DatabaseDialect> dialects = ctx.getBeansOfType(DatabaseDialect.class);
        this.activeDialect = dialects.values().stream()
            .filter(d -> d.getDialectId().equals(dialectId))
            .findFirst()
            .orElseThrow(() -> new IllegalStateException("未找到方言实现: " + dialectId));

        log.info("数据库方言路由完成: {} ({})",
            activeDialect.getDisplayName(), activeDialect.getDialectId());
    }

    public DatabaseDialect getDialect() {
        return activeDialect;
    }

    @Override
    public void setApplicationContext(ApplicationContext ctx) {
        this.ctx = ctx;
    }
}
```

## 3.3 统一ORM适配设计

### 3.3.1 MyBatis-Plus多数据库自动配置

```java
/**
 * MyBatis-Plus多数据库自动配置
 */
@Configuration
public class MybatisPlusMultiDbConfig {

    @Autowired
    private DialectRouter dialectRouter;

    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor() {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();

        // 分页插件——自动适配数据库类型
        PaginationInnerInterceptor pageInterceptor = new PaginationInnerInterceptor();
        pageInterceptor.setDbType(dialectRouter.getDialect().getMybatisPlusDbType());
        pageInterceptor.setMaxLimit(500L);
        interceptor.addInnerInterceptor(pageInterceptor);

        // 乐观锁插件
        interceptor.addInnerInterceptor(new OptimisticLockerInnerInterceptor());

        return interceptor;
    }
}
```

### 3.3.2 SQL兼容性处理策略

| SQL特性 | 达梦DM8 | 人大金仓 | openGauss | 统一处理策略 |
|---------|:------:|:-------:|:---------:|-------------|
| 分页 | OFFSET…FETCH | LIMIT…OFFSET | LIMIT…OFFSET | 方言层自动转换 |
| 自增主键 | IDENTITY | SERIAL | SERIAL | MyBatis-Plus `@TableId(type=ASSIGN_ID)` 雪花ID统一 |
| 布尔类型 | 1/0 | TRUE/FALSE | TRUE/FALSE | 方言层 `getBooleanLiteral()` |
| 日期格式 | TO_CHAR | TO_CHAR | TO_CHAR | 方言层 `getDateFormatFunction()` |
| 字符串拼接 | \|\| | \|\| | \|\| | 方言层 `getConcatFunction()` |
| IF NOT EXISTS | ✗ | ✓ | ✓ | DDL迁移脚本按方言生成 |
| ON DUPLICATE KEY | ✗ | ✗ | ✗ | 统一用 MERGE INTO 或 先查后插 |
| 批量插入 | INSERT ALL | INSERT…VALUES(),() | INSERT…VALUES(),() | 方言层 `getBatchInsertSql()` |
| 关键字转义 | 双引号 | 双引号 | 双引号 | 方言层 `getIdentifierQuoteChar()` |

### 3.3.3 统一SQL编写规范

为所有业务代码制定统一的SQL编写规范，确保跨数据库兼容：

1. **禁止使用数据库特有函数**——所有数据库函数调用通过方言层封装
2. **主键统一使用雪花算法**——`@TableId(type = IdType.ASSIGN_ID)`，避免依赖数据库自增
3. **DDL通过Flyway管理**——每种数据库独立维护迁移脚本目录
4. **禁止使用`*`查询**——显式列出字段名
5. **布尔字段统一用TINYINT(1)**——跨库兼容
6. **时间字段统一用TIMESTAMP**——避免DATE/DATETIME差异

## 3.4 DDL迁移脚本管理（Flyway多数据库）

```
platform-common/
└── common-db-multi/
    └── src/main/resources/
        ├── db/migration/
        │   ├── dm8/                          # 达梦DM8迁移脚本
        │   │   ├── V1.0.0__init_schema.sql
        │   │   ├── V1.0.1__add_tenant.sql
        │   │   └── V1.1.0__add_ai_governance.sql
        │   ├── kingbase/                     # 人大金仓迁移脚本
        │   │   ├── V1.0.0__init_schema.sql
        │   │   ├── V1.0.1__add_tenant.sql
        │   │   └── V1.1.0__add_ai_governance.sql
        │   ├── opengauss/                    # openGauss迁移脚本
        │   │   ├── V1.0.0__init_schema.sql
        │   │   ├── V1.0.1__add_tenant.sql
        │   │   └── V1.1.0__add_ai_governance.sql
        │   ├── mysql/                        # MySQL标准版迁移脚本
        │   │   ├── V1.0.0__init_schema.sql
        │   │   └── ...
        │   └── h2/                           # H2开发测试迁移脚本
        │       ├── V1.0.0__init_schema.sql
        │       └── ...
        └── db/seed/                          # 初始化数据
            ├── dm8/
            ├── kingbase/
            └── opengauss/
```

```yaml
# application-xinchuang.yml: Flyway多数据库路径配置
spring:
  flyway:
    enabled: true
    locations: classpath:db/migration/${app.db.type:dm8}
    baseline-on-migrate: true
    validate-on-migrate: true
```

## 3.5 common-db-multi模块设计

在现有`common-dm8`模块基础上，升级为统一多数据库适配模块：

```
platform-common/
├── common-dm8/                    # [保留] 达梦DM8适配（向后兼容）
└── common-db-multi/               # [新增] 多国产数据库统一适配
    ├── pom.xml
    └── src/main/java/com/smartwin/common/db/multi/
        ├── dialect/
        │   ├── DatabaseDialect.java           # 方言接口
        │   ├── Dm8Dialect.java                # 达梦方言
        │   ├── KingbaseDialect.java           # 人大金仓方言
        │   ├── OpenGaussDialect.java          # openGauss方言
        │   ├── GBaseDialect.java              # 南大通用方言 [P1]
        │   ├── ShenTongDialect.java           # 神通方言 [P1]
        │   └── PolarDbDialect.java            # PolarDB方言 [P1]
        ├── detector/
        │   └── DatabaseTypeDetector.java      # 自动探测器
        ├── router/
        │   └── DialectRouter.java             # 方言路由工厂
        ├── config/
        │   ├── MybatisPlusMultiDbConfig.java  # ORM自动配置
        │   └── DataSourceMultiDbConfig.java   # 数据源配置
        ├── handler/
        │   ├── MultiDbTypeHandler.java        # 统一类型处理器
        │   └── JsonTypeHandler.java           # JSON字段处理器（各库兼容）
        ├── migration/
        │   └── FlywayMultiDbConfig.java       # Flyway多库配置
        └── util/
            └── SqlCompatibilityUtils.java     # SQL兼容性工具
```

## 3.6 数据库切换配置示例

```yaml
# 达梦DM8环境
app:
  db:
    type: dm8    # 或 auto 自动探测
spring:
  datasource:
    driver-class-name: dm.jdbc.driver.DmDriver
    url: jdbc:dm://192.168.1.100:5236/SMARTWIN?compatibleMode=oracle
    username: SYSDBA
    password: '{cipher}SM4加密密文'

# 人大金仓环境
app:
  db:
    type: kingbase
spring:
  datasource:
    driver-class-name: com.kingbase8.Driver
    url: jdbc:kingbase8://192.168.1.101:54321/SMARTWIN
    username: system
    password: '{cipher}SM4加密密文'

# openGauss环境
app:
  db:
    type: opengauss
spring:
  datasource:
    driver-class-name: org.opengauss.Driver
    url: jdbc:opengauss://192.168.1.102:5432/SMARTWIN
    username: gaussdb
    password: '{cipher}SM4加密密文'
```

---

# 第四章 国密算法完整体系设计

## 4.1 国密算法清单与适用场景

| 算法 | 类型 | 标准编号 | 替代的国际算法 | 适用场景 | 优先级 |
|------|------|---------|:-------------:|---------|:------:|
| **SM2** | 椭圆曲线非对称加密 | GB/T 32918 | RSA / ECDSA | 数字签名、密钥交换、证书签名 | P0 |
| **SM3** | 密码杂凑算法（256bit） | GB/T 32905 | SHA-256 | 摘要计算、数字签名前置、完整性校验 | P0 |
| **SM4** | 分组对称加密（128bit） | GB/T 32907 | AES-128 | 数据加密存储、传输加密、字段加密 | P0 |
| **SM9** | 标识密码算法 | GB/T 32915 | —（无直接对应） | 基于身份标识的加密/签名（免证书场景） | P1 |

## 4.2 国密算法在各场景中的应用映射

| 安全场景 | 标准版算法 | 信创版国密算法 | 切换方式 |
|---------|-----------|---------------|---------|
| JWT Token签名 | HS256 (HMAC-SHA256) | SM3-HMAC | `app.crypto.jwt-algorithm` |
| 用户密码存储 | bcrypt + SHA-256 | bcrypt + SM3 | `app.crypto.hash-algorithm` |
| 敏感字段加密 | AES-256 | SM4-CBC/ECB | `app.crypto.symmetric` |
| HTTPS传输加密 | TLS 1.3 + RSA/ECDHE | TLCP + SM2/SM3/SM4 | Nginx/TongWeb SSL配置 |
| API请求签名 | RSA-SHA256 | SM2-SM3 | `app.crypto.sign-algorithm` |
| 文件加密存储 | AES-256 | SM4 | `app.crypto.file-encryption` |
| 数据库密码加密 | AES | SM4 | Jasypt国密扩展 |
| License签名 | RSA-2048 | SM2 | License生成/校验模块 |
| 审计日志完整性 | SHA-256链式 | SM3链式 | 审计日志模块 |

## 4.3 SM2非对称加密与证书体系

### 4.3.1 SM2工具类设计

```java
/**
 * SM2非对称加密工具——基于Bouncy Castle国密实现
 */
public class SM2CryptoUtil {

    private static final String ALGORITHM = "SM2";
    private static final String SIGN_ALGORITHM = "SM3withSM2";
    private static final int KEY_SIZE = 256;

    static {
        // 注册Bouncy Castle国密Provider
        Security.addProvider(new BouncyCastleProvider());
    }

    /** 生成SM2密钥对 */
    public static KeyPair generateKeyPair() {
        try {
            KeyPairGenerator gen = KeyPairGenerator.getInstance(ALGORITHM, "BC");
            gen.initialize(KEY_SIZE);
            return gen.generateKeyPair();
        } catch (Exception e) {
            throw new CryptoException("SM2密钥对生成失败", e);
        }
    }

    /** SM2加密 */
    public static byte[] encrypt(byte[] plaintext, PublicKey publicKey) {
        try {
            Cipher cipher = Cipher.getInstance(ALGORITHM, "BC");
            cipher.init(Cipher.ENCRYPT_MODE, publicKey);
            return cipher.doFinal(plaintext);
        } catch (Exception e) {
            throw new CryptoException("SM2加密失败", e);
        }
    }

    /** SM2解密 */
    public static byte[] decrypt(byte[] ciphertext, PrivateKey privateKey) {
        try {
            Cipher cipher = Cipher.getInstance(ALGORITHM, "BC");
            cipher.init(Cipher.DECRYPT_MODE, privateKey);
            return cipher.doFinal(ciphertext);
        } catch (Exception e) {
            throw new CryptoException("SM2解密失败", e);
        }
    }

    /** SM2签名（SM3withSM2） */
    public static byte[] sign(byte[] data, PrivateKey privateKey) {
        try {
            Signature signature = Signature.getInstance(SIGN_ALGORITHM, "BC");
            signature.initSign(privateKey);
            signature.update(data);
            return signature.sign();
        } catch (Exception e) {
            throw new CryptoException("SM2签名失败", e);
        }
    }

    /** SM2验签（SM3withSM2） */
    public static boolean verify(byte[] data, byte[] sign, PublicKey publicKey) {
        try {
            Signature signature = Signature.getInstance(SIGN_ALGORITHM, "BC");
            signature.initVerify(publicKey);
            signature.update(data);
            return signature.verify(sign);
        } catch (Exception e) {
            throw new CryptoException("SM2验签失败", e);
        }
    }

    /** 密钥对转PEM格式（用于证书生成） */
    public static String toPem(PrivateKey privateKey) {
        PemObject pem = new PemObject("PRIVATE KEY", privateKey.getEncoded());
        StringWriter sw = new StringWriter();
        new PemWriter(sw).writeObject(pem);
        return sw.toString();
    }
}
```

## 4.4 SM3密码杂凑算法

```java
/**
 * SM3密码杂凑算法工具——替代SHA-256
 */
public class SM3HashUtil {

    private static final String ALGORITHM = "SM3";
    private static final int DIGEST_LENGTH = 256; // 32字节

    static {
        Security.addProvider(new BouncyCastleProvider());
    }

    /** SM3摘要计算 */
    public static byte[] digest(byte[] data) {
        try {
            MessageDigest md = MessageDigest.getInstance(ALGORITHM, "BC");
            return md.digest(data);
        } catch (Exception e) {
            throw new CryptoException("SM3摘要计算失败", e);
        }
    }

    /** SM3摘要转十六进制字符串 */
    public static String digestHex(byte[] data) {
        return Hex.encodeHexString(digest(data));
    }

    /** SM3-HMAC消息认证码 */
    public static byte[] hmac(byte[] data, byte[] key) {
        try {
            Mac mac = Mac.getInstance("HMAC-SM3", "BC");
            mac.init(new SecretKeySpec(key, ALGORITHM));
            return mac.doFinal(data);
        } catch (Exception e) {
            throw new CryptoException("SM3-HMAC计算失败", e);
        }
    }

    /** SM3文件摘要（用于文件完整性校验） */
    public static String fileDigest(String filePath) throws IOException {
        try (InputStream is = Files.newInputStream(Paths.get(filePath))) {
            MessageDigest md = MessageDigest.getInstance(ALGORITHM, "BC");
            byte[] buffer = new byte[8192];
            int len;
            while ((len = is.read(buffer)) != -1) {
                md.update(buffer, 0, len);
            }
            return Hex.encodeHexString(md.digest());
        } catch (NoSuchAlgorithmException | NoSuchProviderException e) {
            throw new CryptoException("SM3文件摘要失败", e);
        }
    }
}
```

## 4.5 SM4对称加密

```java
/**
 * SM4对称加密工具——替代AES-128
 * 支持 ECB / CBC / CTR 模式
 */
public class SM4CryptoUtil {

    private static final String ALGORITHM = "SM4";
    private static final String PROVIDER = "BC";
    private static final int KEY_SIZE = 128;  // 16字节
    private static final int IV_SIZE = 128;   // 16字节
    private static final String DEFAULT_MODE = "SM4/CBC/PKCS5Padding";

    static {
        Security.addProvider(new BouncyCastleProvider());
    }

    /** 生成SM4密钥 */
    public static byte[] generateKey() {
        try {
            KeyGenerator gen = KeyGenerator.getInstance(ALGORITHM, PROVIDER);
            gen.init(KEY_SIZE, new SecureRandom());
            return gen.generateKey().getEncoded();
        } catch (Exception e) {
            throw new CryptoException("SM4密钥生成失败", e);
        }
    }

    /** SM4-CBC加密 */
    public static byte[] encrypt(byte[] plaintext, byte[] key, byte[] iv) {
        try {
            Cipher cipher = Cipher.getInstance(DEFAULT_MODE, PROVIDER);
            SecretKeySpec keySpec = new SecretKeySpec(key, ALGORITHM);
            IvParameterSpec ivSpec = new IvParameterSpec(iv);
            cipher.init(Cipher.ENCRYPT_MODE, keySpec, ivSpec);
            return cipher.doFinal(plaintext);
        } catch (Exception e) {
            throw new CryptoException("SM4加密失败", e);
        }
    }

    /** SM4-CBC解密 */
    public static byte[] decrypt(byte[] ciphertext, byte[] key, byte[] iv) {
        try {
            Cipher cipher = Cipher.getInstance(DEFAULT_MODE, PROVIDER);
            SecretKeySpec keySpec = new SecretKeySpec(key, ALGORITHM);
            IvParameterSpec ivSpec = new IvParameterSpec(iv);
            cipher.init(Cipher.DECRYPT_MODE, keySpec, ivSpec);
            return cipher.doFinal(ciphertext);
        } catch (Exception e) {
            throw new CryptoException("SM4解密失败", e);
        }
    }

    /** 敏感字段加密（Base64输出，便于数据库存储） */
    public static String encryptField(String plaintext, byte[] key) {
        byte[] iv = new byte[IV_SIZE / 8];
        new SecureRandom().nextBytes(iv);
        byte[] encrypted = encrypt(plaintext.getBytes(StandardCharsets.UTF_8), key, iv);
        // IV + 密文拼接后Base64
        byte[] combined = new byte[iv.length + encrypted.length];
        System.arraycopy(iv, 0, combined, 0, iv.length);
        System.arraycopy(encrypted, 0, combined, iv.length, encrypted.length);
        return Base64.encodeBase64String(combined);
    }

    /** 敏感字段解密 */
    public static String decryptField(String ciphertextBase64, byte[] key) {
        byte[] combined = Base64.decodeBase64(ciphertextBase64);
        int ivLen = IV_SIZE / 8;
        byte[] iv = Arrays.copyOf(combined, ivLen);
        byte[] encrypted = Arrays.copyOfRange(combined, ivLen, combined.length);
        return new String(decrypt(encrypted, key, iv), StandardCharsets.UTF_8);
    }
}
```

## 4.6 国密SSL/TLCP协议设计

### 4.6.1 TLCP双证书体系

国密SSL（TLCP，Transport Layer Cryptographic Protocol，GB/T 38636-2020）采用**双证书**体系（签名证书 + 加密证书），与国际TLS单证书体系不同：

```
国密SSL/TLCP双证书体系:

┌──────────────┐                          ┌──────────────┐
│   客户端      │                          │   服务端      │
│ (浏览器/App)  │                          │(TongWeb/Nginx)│
└──────┬───────┘                          └──────┬───────┘
       │                                         │
       │  1. ClientHello (支持的密码套件)         │
       │ ───────────────────────────────────────→ │
       │                                         │
       │  2. ServerHello + 双证书                 │
       │     ├── 签名证书 (SM2签名, CA签发)       │
       │     └── 加密证书 (SM2加密, CA签发)       │
       │ ←─────────────────────────────────────── │
       │                                         │
       │  3. 密钥交换 (SM2加密协商SM4会话密钥)    │
       │ ───────────────────────────────────────→ │
       │                                         │
       │  4. Finished (SM3摘要校验)               │
       │ ←──────────────────────────────────────→ │
       │                                         │
       │  5. 加密通信 (SM4-CBC)                   │
       │ ←──────────────────────────────────────→ │
       └─────────────────────────────────────────┘

国密密码套件:
  ECC-SM4-SM3     (SM2非对称 + SM4对称 + SM3摘要)
  ECDHE-SM4-SM3   (ECDHE密钥交换 + SM4对称 + SM3摘要)
```

### 4.6.2 国密SSL证书生成

```bash
# 1. 生成SM2签名密钥对
openssl ecparam -genkey -name SM2 -out sign_key.pem
openssl req -new -key sign_key.pem -out sign_req.csr -sm3

# 2. 生成SM2加密密钥对
openssl ecparam -genkey -name SM2 -out enc_key.pem
openssl req -new -key enc_key.pem -out enc_req.csr -sm3

# 3. CA签发国密双证书（使用国密CA或自签名）
openssl x509 -req -in sign_req.csr -CA ca_cert.pem -CAkey ca_key.pem \
  -CAcreateserial -out sign_cert.pem -days 3650 -sm3
openssl x509 -req -in enc_req.csr -CA ca_cert.pem -CAkey ca_key.pem \
  -CAcreateserial -out enc_cert.pem -days 3650 -sm3

# 4. 国密Nginx配置 (使用支持国密的Tengine/TongWeb Server)
# nginx.conf:
# server {
#     listen 443 ssl;
#     ssl_certificate     sign_cert.pem;    # 签名证书
#     ssl_certificate_key sign_key.pem;     # 签名私钥
#     ssl_certificate     enc_cert.pem;     # 加密证书
#     ssl_certificate_key enc_key.pem;      # 加密私钥
#     ssl_ciphers         ECC-SM4-SM3:ECDHE-SM4-SM3;
#     ssl_protocols       TLCPv1.1;
# }
```

## 4.7 国密X.509证书管理

```java
/**
 * 国密X.509证书管理——签发/验证/吊销
 */
public class GMCertificateManager {

    /**
     * 生成国密CA根证书
     */
    public static X509Certificate generateRootCA(KeyPair keyPair, String subject) {
        try {
            X500Name dn = new X500Name("CN=" + subject);
            X509v3CertificateBuilder builder = new X509v3CertificateBuilder(
                dn,                               // issuer
                BigInteger.valueOf(System.currentTimeMillis()),
                Date.from(Instant.now()),
                Date.from(Instant.now().plus(3650, ChronoUnit.DAYS)),
                dn,                               // subject
                new SubjectPublicKeyInfo(
                    AlgorithmIdentifier.getInstance("SM2"),
                    keyPair.getPublic().getEncoded()
                )
            );
            ContentSigner signer = new JcaContentSignerBuilder("SM3withSM2", "BC")
                .build(keyPair.getPrivate());
            return new JcaX509CertificateConverter()
                .setProvider("BC")
                .getCertificate(builder.build(signer));
        } catch (Exception e) {
            throw new CryptoException("国密CA根证书生成失败", e);
        }
    }

    /**
     * 验证证书链
     */
    public static boolean verifyCertificateChain(X509Certificate cert,
                                                  X509Certificate caCert) {
        try {
            cert.verify(caCert.getPublicKey(), "BC");
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}
```

## 4.8 密码资源池与HSM硬件密码机集成

### 4.8.1 HSM集成架构

对于金融/军工等高安全级别客户，密钥存储于硬件密码机（HSM）中，密钥不出设备：

```
┌─────────────────────────────────────────────────────────┐
│                    应用层 (Spring Boot)                   │
│                   ↓ 调用国密SDK接口                       │
├─────────────────────────────────────────────────────────┤
│              common-crypto-gm (国密SDK封装)               │
│            ↓                  ↓                          │
│     ┌─────────────┐   ┌──────────────┐                  │
│     │ 软件国密实现  │   │ HSM硬件密码机  │                  │
│     │ (BouncyCastle)│   │  (通过PKCS#11)│                  │
│     │ [标准版/中小企业]│  │ [金融/军工客户]│                 │
│     └─────────────┘   └──────────────┘                  │
│         ↓ 密钥在内存         ↓ 密钥在硬件                  │
│    ┌──────────┐        ┌────────────┐                   │
│    │ 密钥文件   │        │ HSM密码机   │                   │
│    │ (SM4加密) │        │(密钥永不出设备)│                  │
│    └──────────┘        └────────────┘                   │
└─────────────────────────────────────────────────────────┘
```

### 4.8.2 密码服务统一接口（软件/HSM透明切换）

```java
/**
 * 密码服务统一接口——软件实现与HSM实现透明切换
 */
public interface CryptoService {

    /** 对称加密 */
    byte[] symmetricEncrypt(byte[] data, String keyId);

    /** 对称解密 */
    byte[] symmetricDecrypt(byte[] data, String keyId);

    /** 签名 */
    byte[] sign(byte[] data, String keyId);

    /** 验签 */
    boolean verify(byte[] data, byte[] signature, String keyId);

    /** 摘要 */
    byte[] digest(byte[] data);

    /** 获取加密算法类型 */
    CryptoAlgorithm getAlgorithm();
}

/**
 * 软件国密实现（BouncyCastle）
 */
@Component
@ConditionalOnProperty(name = "app.crypto.provider", havingValue = "software",
                       matchIfMissing = true)
public class SoftwareCryptoService implements CryptoService {
    // 使用SM2CryptoUtil / SM3HashUtil / SM4CryptoUtil 实现
}

/**
 * HSM硬件密码机实现（PKCS#11接口）
 */
@Component
@ConditionalOnProperty(name = "app.crypto.provider", havingValue = "hsm")
public class HsmCryptoService implements CryptoService {

    private PKCS11Token token;

    @PostConstruct
    public void init() {
        // 加载HSM PKCS#11库
        String pkcs11Config = "--name=HSM\nlibrary=/opt/hsm/lib/pkcs11.so\nslotListIndex=0";
        Provider pkcs11Provider = new SunPKCS11(new ByteArrayInputStream(
            pkcs11Config.getBytes()));
        Security.addProvider(pkcs11Provider);
        // 登录HSM
        token = loginHsm();
    }

    @Override
    public byte[] symmetricEncrypt(byte[] data, String keyId) {
        // 密钥操作在HSM内部完成，密钥永不出设备
        // ...
    }
}
```

## 4.9 common-crypto-gm模块设计

```
platform-common/
└── common-crypto-gm/                      # [新增] 国密算法统一模块
    ├── pom.xml
    │   # 依赖: bouncycastle:bcprov-jdk18on:1.78+ (国密Provider)
    │   # 依赖: bouncycastle:bcpkix-jdk18on:1.78+ (证书管理)
    └── src/main/java/com/smartwin/common/crypto/gm/
        ├── api/
        │   ├── CryptoService.java              # 密码服务统一接口
        │   ├── CryptoAlgorithm.java            # 算法枚举(SM2/SM3/SM4/SM9)
        │   └── KeyManagementService.java       # 密钥管理接口
        ├── sm2/
        │   ├── SM2CryptoUtil.java              # SM2加解密
        │   ├── SM2SignUtil.java                # SM2签名验签
        │   └── GMCertificateManager.java       # 国密证书管理
        ├── sm3/
        │   └── SM3HashUtil.java                # SM3摘要/HMAC
        ├── sm4/
        │   └── SM4CryptoUtil.java              # SM4加解密
        ├── sm9/
        │   └── SM9CryptoUtil.java              # SM9标识密码 [P1]
        ├── impl/
        │   ├── SoftwareCryptoService.java      # 软件实现(BC)
        │   └── HsmCryptoService.java           # HSM硬件实现 [P1]
        ├── cert/
        │   ├── GMCertGenerator.java            # 国密证书生成
        │   ├── GMCertValidator.java            # 证书链验证
        │   └── CRLManager.java                 # 证书吊销列表
        ├── config/
        │   ├── CryptoAutoConfiguration.java    # 自动配置
        │   └── CryptoProperties.java           # 密码配置属性
        └── keystore/
            ├── KeyStoreManager.java            # 密钥库管理
            └── HsmKeyStore.java                # HSM密钥库 [P1]
```

## 4.10 标准算法与国密算法自动切换

### 4.10.1 统一加密门面

```java
/**
 * 统一加密门面——根据运行模式自动选择标准算法或国密算法
 * 标准模式: AES + RSA + SHA-256
 * 信创模式: SM4 + SM2 + SM3
 */
@Component
public class CryptoFacade {

    private final CryptoService cryptoService;
    private final boolean xinchuangMode;

    public CryptoFacade(CryptoService cryptoService,
                        @Value("${app.xinchuang.enabled:false}") boolean xinchuangMode) {
        this.cryptoService = cryptoService;
        this.xinchuangMode = xinchuangMode;
    }

    /** 对称加密——自动选择AES或SM4 */
    public String encrypt(String plaintext) {
        byte[] data = plaintext.getBytes(StandardCharsets.UTF_8);
        byte[] encrypted = cryptoService.symmetricEncrypt(data, "default-key");
        return Base64.encodeBase64String(encrypted);
    }

    /** 对称解密 */
    public String decrypt(String ciphertext) {
        byte[] data = Base64.decodeBase64(ciphertext);
        return new String(cryptoService.symmetricDecrypt(data, "default-key"),
                          StandardCharsets.UTF_8);
    }

    /** 签名——自动选择RSA-SHA256或SM2-SM3 */
    public String sign(String data) {
        byte[] signature = cryptoService.sign(data.getBytes(StandardCharsets.UTF_8),
                                               "sign-key");
        return Base64.encodeBase64String(signature);
    }

    /** 验签 */
    public boolean verify(String data, String signature) {
        return cryptoService.verify(
            data.getBytes(StandardCharsets.UTF_8),
            Base64.decodeBase64(signature),
            "sign-key"
        );
    }

    /** 摘要——自动选择SHA-256或SM3 */
    public String digest(String data) {
        return Hex.encodeHexString(
            cryptoService.digest(data.getBytes(StandardCharsets.UTF_8))
        );
    }

    public boolean isXinchuangMode() {
        return xinchuangMode;
    }
}
```

### 4.10.2 配置自动切换

```yaml
# 标准版配置 (application-standard.yml)
app:
  xinchuang:
    enabled: false
  crypto:
    provider: software
    algorithm:
      symmetric: AES-256
      asymmetric: RSA-2048
      hash: SHA-256
      sign: RSA-SHA256
      jwt: HS256

# 信创版配置 (application-xinchuang.yml)
app:
  xinchuang:
    enabled: true
  crypto:
    provider: software        # 或 hsm
    algorithm:
      symmetric: SM4          # 国密SM4替代AES
      asymmetric: SM2         # 国密SM2替代RSA
      hash: SM3               # 国密SM3替代SHA-256
      sign: SM3withSM2        # 国密签名
      jwt: SM3-HMAC           # JWT用SM3-HMAC
    hsm:
      enabled: false          # 高安全客户设为true
      library: /opt/hsm/lib/pkcs11.so
      slot: 0
      pin: '{cipher}SM4加密'
```

---

# 第五章 信创中间件适配设计

## 5.1 应用服务器适配（TongWeb / BES）

Spring Boot默认使用嵌入式Tomcat，信创环境下需支持切换为东方通TongWeb或宝兰德BES。

### 5.1.1 可插拔Servlet容器设计

```xml
<!-- pom.xml: 通过Profile切换Servlet容器 -->
<profiles>
    <!-- 默认: 嵌入式Tomcat -->
    <profile>
        <id>container-tomcat</id>
        <activation>
            <activeByDefault>true</activeByDefault>
        </activation>
        <dependencies>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-starter-tomcat</artifactId>
            </dependency>
        </dependencies>
    </profile>

    <!-- 信创: 东方通TongWeb -->
    <profile>
        <id>container-tongweb</id>
        <dependencies>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-starter-web</artifactId>
                <exclusions>
                    <exclusion>
                        <groupId>org.springframework.boot</groupId>
                        <artifactId>spring-boot-starter-tomcat</artifactId>
                    </exclusion>
                </exclusions>
            </dependency>
            <dependency>
                <groupId>com.tongweb</groupId>
                <artifactId>tongweb-spring-boot-starter</artifactId>
                <version>7.0</version>
            </dependency>
        </dependencies>
    </profile>

    <!-- 信创: 宝兰德BES -->
    <profile>
        <id>container-bes</id>
        <dependencies>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-starter-web</artifactId>
                <exclusions>
                    <exclusion>
                        <groupId>org.springframework.boot</groupId>
                        <artifactId>spring-boot-starter-tomcat</artifactId>
                    </exclusion>
                </exclusions>
            </dependency>
            <dependency>
                <groupId>com.bes</groupId>
                <artifactId>bes-spring-boot-starter</artifactId>
                <version>9.5</version>
            </dependency>
        </dependencies>
    </profile>
</profiles>
```

## 5.2 消息队列适配（TongMQ）

### 5.2.1 统一JMS接口抽象

```java
/**
 * 消息服务统一接口——屏蔽RocketMQ与TongMQ差异
 */
public interface MessageService {
    void send(String topic, Object message);
    <T> void subscribe(String topic, Class<T> type, Consumer<T> handler);
}

/**
 * RocketMQ实现（标准版）
 */
@Component
@ConditionalOnProperty(name = "app.mq.type", havingValue = "rocketmq",
                       matchIfMissing = true)
public class RocketMqMessageService implements MessageService {
    @Autowired
    private RocketMQTemplate template;
    // ...
}

/**
 * TongMQ实现（信创版）——东方通TongMQ兼容JMS规范
 */
@Component
@ConditionalOnProperty(name = "app.mq.type", havingValue = "tongmq")
public class TongMqMessageService implements MessageService {
    @Autowired
    private JmsTemplate jmsTemplate;  // TongMQ通过JMS接口接入
    // ...
}
```

```yaml
# 信创版消息队列配置
app:
  mq:
    type: tongmq
spring:
  jms:
    template:
      default-destination-name: smartwin.default
  # TongMQ连接配置
  tongmq:
    broker-url: tcp://192.168.1.200:9876
    username: admin
    password: '{cipher}SM4加密'
```

## 5.3 缓存中间件适配

东方通TongRDS兼容Redis协议，应用层零代码改动，仅需修改连接地址：

```yaml
# 标准版
spring:
  data:
    redis:
      host: 192.168.1.10
      port: 6379

# 信创版（TongRDS，Redis协议兼容）
spring:
  data:
    redis:
      host: 192.168.1.20    # TongRDS地址
      port: 6379             # 端口不变
      password: '{cipher}SM4加密'
```

## 5.4 注册配置中心适配

东方通TongDiscovery兼容Nacos协议，可通过Nacos Client直接连接：

```yaml
# 信创版注册中心
spring:
  cloud:
    nacos:
      discovery:
        server-addr: 192.168.1.30:8848   # TongDiscovery地址
      config:
        server-addr: 192.168.1.30:8848
```

## 5.5 Web服务器/反向代理适配

```nginx
# 信创版Nginx替代——TongWeb Server 或 国密Tengine
# 配置语法与Nginx完全兼容，支持国密SSL

server {
    listen 443 ssl;
    server_name governance.example.com;

    # 国密SSL双证书
    ssl_certificate      /etc/ssl/gm/sign_cert.pem;
    ssl_certificate_key  /etc/ssl/gm/sign_key.pem;
    ssl_certificate      /etc/ssl/gm/enc_cert.pem;
    ssl_certificate_key  /etc/ssl/gm/enc_key.pem;
    ssl_ciphers          ECC-SM4-SM3:ECDHE-SM4-SM3;
    ssl_protocols        TLCPv1.1;

    # 前端静态资源
    location / {
        root /opt/smartwin/frontend;
        try_files $uri $uri/ /index.html;
    }

    # API反代
    location /api/ {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

# 第六章 信创自动检测与运行时适配

## 6.1 启动时环境自动探测机制

### 6.1.1 信创环境探测器

```java
/**
 * 信创环境统一探测器——启动时自动探测CPU/OS/DB/中间件
 * 自动激活对应的Spring Profile
 */
@Slf4j
public class XinchuangEnvironmentDetector {

    /**
     * 探测并返回信创环境信息
     */
    public static XinchuangEnvironment detect() {
        XinchuangEnvironment env = new XinchuangEnvironment();

        // 1. 探测CPU架构
        env.setCpuArch(detectCpuArch());
        env.setCpuVendor(detectCpuVendor());

        // 2. 探测OS
        env.setOsType(OsDetector.detect());

        // 3. 探测是否信创环境
        env.setXinchuang(isXinchuangEnvironment(env));

        log.info("信创环境探测结果: {}", env);
        return env;
    }

    private static String detectCpuArch() {
        String arch = System.getProperty("os.arch", "").toLowerCase();
        return switch (arch) {
            case "aarch64", "arm64" -> "aarch64";
            case "loongarch64" -> "loongarch64";
            case "amd64", "x86_64" -> "x86_64";
            case "sw64" -> "sw64";
            default -> arch;
        };
    }

    private static String detectCpuVendor() {
        try {
            String cpuInfo = Files.readString(Paths.get("/proc/cpuinfo"));
            if (cpuInfo.contains("Phytium") || cpuInfo.contains("ft-2000"))
                return "phytium";       // 飞腾
            if (cpuInfo.contains("Kunpeng") || cpuInfo.contains("Hi1616"))
                return "kunpeng";        // 鲲鹏
            if (cpuInfo.contains("Loongson"))
                return "loongson";       // 龙芯
            if (cpuInfo.contains("Hygon"))
                return "hygon";          // 海光
            if (cpuInfo.contains("Zhaoxin"))
                return "zhaoxin";        // 兆芯
            if (cpuInfo.contains("Sunway"))
                return "sunway";         // 申威
        } catch (IOException ignored) {}
        return "unknown";
    }

    private static boolean isXinchuangEnvironment(XinchuangEnvironment env) {
        // 信创环境判定: 非x86架构 或 国产OS
        boolean nonX86 = !"x86_64".equals(env.getCpuArch());
        boolean nationalOs = env.getOsType() != OsDetector.OsType.STANDARD_LINUX
                          && env.getOsType() != OsDetector.OsType.WINDOWS;
        return nonX86 || nationalOs;
    }
}
```

### 6.1.2 自动Profile激活

```java
/**
 * 信创环境自动配置监听器
 * 在Spring启动前自动激活xinchuang Profile
 */
public class XinchuangProfileActivator
        implements EnvironmentPostProcessor, Ordered {

    @Override
    public void postProcessEnvironment(ConfigurableEnvironment env,
                                        SpringApplication app) {
        XinchuangEnvironment xcEnv = XinchuangEnvironmentDetector.detect();

        if (xcEnv.isXinchuang()) {
            // 自动追加 xinchuang Profile
            Set<String> activeProfiles = new LinkedHashSet<>(
                Arrays.asList(env.getActiveProfiles()));
            activeProfiles.add("xinchuang");
            env.setActiveProfiles(activeProfiles.toArray(new String[0]));
            log.info("信创环境已检测到，自动激活 xinchuang Profile: {}", xcEnv);
        }
    }

    @Override
    public int getOrder() {
        return Ordered.HIGHEST_PRECEDENCE;
    }
}
```

```yaml
# META-INF/spring.factories
org.springframework.boot.env.EnvironmentPostProcessor=\
  com.smartwin.common.xinchuang.XinchuangProfileActivator
```

## 6.2 自适应配置加载流程

```
应用启动流程:

┌──────────────────────────────────────────────┐
│ 1. JVM启动                                     │
└──────────────────┬───────────────────────────┘
                   ▼
┌──────────────────────────────────────────────┐
│ 2. XinchuangProfileActivator 执行              │
│    ├── 探测CPU架构 (aarch64/loong64/x86_64)   │
│    ├── 探测OS类型 (麒麟/UOS/openEuler)        │
│    ├── 探测是否信创环境                        │
│    └── 是→自动追加 "xinchuang" Profile        │
└──────────────────┬───────────────────────────┘
                   ▼
┌──────────────────────────────────────────────┐
│ 3. Spring上下文初始化                          │
│    ├── 加载 application.yml                    │
│    ├── 加载 application-{mode}.yml             │
│    ├── 加载 application-{product}.yml          │
│    ├── 加载 application-standard.yml (标准版)  │
│    │   └── 或 application-xinchuang.yml (信创)│
│    │       ├── 数据源→达梦/金仓/openGauss      │
│    │       ├── 加密→SM2/SM3/SM4               │
│    │       └── 中间件→东方通系列              │
│    └── 条件化Bean加载                          │
└──────────────────┬───────────────────────────┘
                   ▼
┌──────────────────────────────────────────────┐
│ 4. 数据库方言自动路由                          │
│    ├── DatabaseTypeDetector 探测数据库类型     │
│    └── DialectRouter 加载对应方言实现          │
└──────────────────┬───────────────────────────┘
                   ▼
┌──────────────────────────────────────────────┐
│ 5. Flyway自动执行DDL迁移                       │
│    └── 加载 db/migration/{dbType}/ 脚本        │
└──────────────────┬───────────────────────────┘
                   ▼
┌──────────────────────────────────────────────┐
│ 6. 应用就绪，日志输出环境信息                  │
│    "系统运行在信创环境: 鲲鹏920 + openEuler + │
│     openGauss + 国密SM2/SM3/SM4"              │
└──────────────────────────────────────────────┘
```

---

# 第七章 信创部署架构

## 7.1 私有化信创部署拓扑

```
┌─────────────────────────────────────────────────────────────────────┐
│                    私有化信创部署拓扑                                  │
│            (飞腾/鲲鹏 + 麒麟/openEuler + 达梦/金仓)                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────────────────────────────────────────────────┐      │
│  │                  接入层 (信创终端)                         │      │
│  │   360安全浏览器 / 奇安信浏览器 ──→ 国密HTTPS(TLCP)        │      │
│  └──────────────────────────┬───────────────────────────────┘      │
│                              │                                      │
│  ┌───────────────────────────▼──────────────────────────────┐      │
│  │            反向代理层 (TongWeb Server / Tengine)          │      │
│  │            国密SSL双证书终止 + 负载均衡                    │      │
│  └──────────────────────────┬───────────────────────────────┘      │
│                              │                                      │
│  ┌───────────────────────────▼──────────────────────────────┐      │
│  │               应用层 (Spring Boot 微服务)                  │      │
│  │   TongWeb嵌入式容器 + 国密SDK + 多DB方言层                 │      │
│  │   ┌────────┐┌────────┐┌────────┐┌────────┐┌────────┐    │      │
│  │   │auth-svc││system- ││catalog-││quality-││model-svc│    │      │
│  │   │(8081)  ││svc(8082)││svc(8083)││svc(8084)││(8085)  │    │      │
│  │   └────────┘└────────┘└────────┘└────────┘└────────┘    │      │
│  │   服务注册: TongDiscovery (Nacos协议兼容)                  │      │
│  │   消息总线: TongMQ (JMS接口)                               │      │
│  └──────────────────────────┬───────────────────────────────┘      │
│                              │                                      │
│  ┌───────────────────────────▼──────────────────────────────┐      │
│  │               数据存储层 (国产数据库)                      │      │
│  │   ┌──────────┐  ┌──────────┐  ┌────────┐  ┌──────────┐  │      │
│  │   │达梦DM8   │  │TongRDS   │  │MinIO   │  │ES(ARM64) │  │      │
│  │   │/金仓     │  │(Redis兼容)│  │(ARM64) │  │          │  │      │
│  │   │/openGauss│  │          │  │        │  │          │  │      │
│  │   │:5236    │  │:6379     │  │:9000   │  │:9200     │  │      │
│  │   └──────────┘  └──────────┘  └────────┘  └──────────┘  │      │
│  └──────────────────────────────────────────────────────────┘      │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────┐      │
│  │               基础设施层                                   │      │
│  │   CPU: 飞腾FT-2000+ / 鲲鹏920 / 龙芯3A5000              │      │
│  │   OS:  麒麟V10 / 统信UOS / openEuler                     │      │
│  │   JDK: 毕昇JDK 17 (ARM64) / 龙芯JDK 17 (LoongArch)      │      │
│  │   容器: Docker (多架构) / Docker Compose                 │      │
│  └──────────────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────────────┘
```

## 7.2 信创Docker Compose编排

```yaml
# docker-compose-xinchuang.yml (信创环境一键部署)
version: '3.8'

services:
  # 国产数据库 (按需选择一个)
  dm8:
    image: dm8_database:8.1-aarch64      # 达梦ARM64镜像
    # kingbase: image: kingbase:v8r6-aarch64
    # opengauss: image: opengauss:5.0-aarch64
    ports: ["5236:5236"]
    volumes: ["dm8_data:/opt/dmdbms/data"]
    environment:
      - LD_LIBRARY_PATH=/opt/dmdbms/bin
    deploy:
      resources:
        limits: { cpus: '4', memory: 4G }

  tongrds:
    image: tongrds:7.0-aarch64           # 东方通Redis ARM64
    ports: ["6379:6379"]

  minio:
    image: minio:latest                   # 开源，多架构
    ports: ["9000:9000", "9001:9001"]
    environment:
      MINIO_ROOT_USER: admin
      MINIO_ROOT_PASSWORD: '{cipher}SM4加密'

  elasticsearch:
    image: elasticsearch:8.11-aarch64     # ES ARM64镜像
    ports: ["9200:9200"]
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false

  # 应用服务 (多架构镜像)
  auth-service:
    image: registry.example.com/smartwin/auth-service:latest
    ports: ["8081:8081"]
    environment:
      - SPRING_PROFILES_ACTIVE=private-ic-xinchuang
      - APP_DB_TYPE=auto
    depends_on: [dm8, tongrds]

volumes:
  dm8_data:
```

## 7.3 信创K8s集群部署

```yaml
# k8s-xinchuang-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: smartwin-auth-service
  namespace: smartwin
spec:
  replicas: 2
  selector:
    matchLabels:
      app: auth-service
  template:
    metadata:
      labels:
        app: auth-service
    spec:
      # 信创节点选择器
      nodeSelector:
        kubernetes.io/arch: arm64          # ARM64节点
        os: kylin                           # 麒麟OS节点
      containers:
      - name: auth-service
        image: registry.example.com/smartwin/auth-service:latest
        ports:
        - containerPort: 8081
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "private-integrated-xinchuang"
        - name: APP_DB_TYPE
          value: "auto"
        resources:
          requests: { cpu: '1', memory: 1Gi }
          limits: { cpu: '2', memory: 2Gi }
        livenessProbe:
          httpGet: { path: /actuator/health, port: 8081 }
          initialDelaySeconds: 60
        readinessProbe:
          httpGet: { path: /actuator/health/readiness, port: 8081 }
          initialDelaySeconds: 30
---
# 信创多架构镜像仓库
apiVersion: v1
kind: ConfigMap
metadata:
  name: xinchuang-config
data:
  # 鲲鹏+openEuler+openGauss组合
  arch: "arm64"
  os: "openEuler"
  db: "opengauss"
  crypto: "SM2,SM3,SM4"
```

---

# 第八章 信创兼容性测试矩阵与认证规划

## 8.1 信创兼容性测试矩阵

### 8.1.1 全组合测试矩阵（P0必测 + P1选测）

| 编号 | CPU | OS | 数据库 | 中间件 | 优先级 | 测试状态 |
|:----:|-----|-----|--------|--------|:------:|:--------:|
| T-01 | 飞腾FT-2000+ | 麒麟V10 | 达梦DM8 | TongWeb+TongMQ | P0 | ☐ |
| T-02 | 飞腾FT-2000+ | 麒麟V10 | 人大金仓 | TongWeb+TongMQ | P0 | ☐ |
| T-03 | 鲲鹏920 | openEuler | openGauss | TongWeb+TongMQ | P0 | ☐ |
| T-04 | 鲲鹏920 | openEuler | 达梦DM8 | TongWeb+TongMQ | P0 | ☐ |
| T-05 | 龙芯3A5000 | 统信UOS | 人大金仓 | BES+RocketMQ | P0 | ☐ |
| T-06 | 龙芯3A5000 | 统信UOS | openGauss | BES+RocketMQ | P0 | ☐ |
| T-07 | 海光7280 | 麒麟V10 | 达梦DM8 | TongWeb+TongMQ | P1 | ☐ |
| T-08 | 海光7280 | openEuler | openGauss | Tomcat+RocketMQ | P1 | ☐ |
| T-09 | 兆芯KX-7000 | 麒麟V10 | 人大金仓 | TongWeb+TongMQ | P1 | ☐ |
| T-10 | 飞腾S2500 | 麒麟V10 | 达梦DM8 | TongWeb+TongMQ | P1 | ☐ |

### 8.1.2 国密算法专项测试

| 编号 | 测试项 | 验收标准 | 优先级 |
|:----:|--------|---------|:------:|
| C-01 | SM2加解密 | 与国密标准测试向量一致 | P0 |
| C-02 | SM2签名/验签 | SM3withSM2签名验证通过 | P0 |
| C-03 | SM3摘要 | 与GB/T 32905标准测试向量一致 | P0 |
| C-04 | SM4加解密 | ECB/CBC模式与标准测试向量一致 | P0 |
| C-05 | TLCP国密SSL | 双证书握手成功，通信加密 | P0 |
| C-06 | JWT-SM3HMAC | Token签发与校验通过 | P0 |
| C-07 | 数据库密码SM4加密 | 配置文件密文解密成功 | P0 |
| C-08 | 审计日志SM3链式 | 日志篡改可检测 | P0 |
| C-09 | SM9标识加密 | 加解密功能正常 | P1 |
| C-10 | HSM密码机集成 | 密钥操作在硬件内完成 | P1 |

### 8.1.3 信创CI/CD流水线

```yaml
# .github/workflows/xinchuang-ci.yml
name: 信创兼容性CI

on: [push, pull_request]

jobs:
  # 多架构编译
  build-multi-arch:
    strategy:
      matrix:
        arch: [x86_64, arm64, loong64]
    runs-on: ${{ matrix.arch == 'arm64' && 'self-hosted-arm64' || 'ubuntu-latest' }}
    steps:
      - uses: actions/checkout@v4
      - name: Setup JDK (多架构)
        uses: actions/setup-java@v4
        with:
          distribution: ${{ matrix.arch == 'arm64' && 'bisheng' || 'temurin' }}
          java-version: '17'
      - name: Maven Build
        run: ./mvnw clean package -DskipTests
      - name: Build Docker Image (multi-arch)
        run: |
          docker buildx build --platform linux/${{ matrix.arch }} \
            -t smartwin/auth-service:${{ github.sha }}-${{ matrix.arch }} .

  # 国密算法测试
  crypto-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: 国密算法标准向量测试
        run: ./mvnw test -Dtest=GM*Test
      - name: TLCP国密SSL测试
        run: ./mvnw test -Dtest=TLCP*Test

  # 多数据库兼容测试
  db-compat-test:
    strategy:
      matrix:
        db: [dm8, kingbase, opengauss]
    runs-on: ubuntu-latest
    services:
      db:
        image: ${{ matrix.db == 'dm8' && 'dm8:8.1' || matrix.db == 'kingbase' && 'kingbase:v8r6' || 'opengauss:5.0' }}
        ports: ["5236:5236"]
    steps:
      - uses: actions/checkout@v4
      - name: 多数据库兼容性测试
        run: ./mvnw test -Dspring.profiles.active=test-${{ matrix.db }}
```

## 8.2 信创认证与资质规划

### 8.2.1 认证路线图

| 认证/资质 | 发证机构 | 优先级 | 计划时间 | 费用预算 | 说明 |
|-----------|---------|:------:|:--------:|:--------:|------|
| **等保2.0三级** | 公安部 | P0 | M6-M9 | 15万 | 网络安全等级保护三级测评 |
| **国密二级密码模块认证** | 国家密码管理局 | P0 | M6-M12 | 20万 | 商用密码产品认证 |
| **信创工委会认证** | 信创工委会 | P1 | M9-M15 | 10万 | 信息技术应用创新工作委员会认证 |
| **麒麟软件兼容认证** | 麒麟软件 | P0 | M4-M6 | 5万 | 麒麟V10兼容性认证 |
| **达梦数据库兼容认证** | 达梦数据 | P0 | M3-M5 | 3万 | DM8兼容性认证 |
| **人大金仓兼容认证** | 人大金仓 | P1 | M6-M8 | 3万 | KingbaseES兼容认证 |
| **openGauss兼容认证** | openGauss社区 | P1 | M6-M8 | 免费 | 社区兼容认证 |
| **东方通中间件认证** | 东方通 | P1 | M9-M12 | 5万 | TongWeb/TongMQ兼容认证 |
| **DCMM四级认证** | 中国电子信息行业联合会 | P0 | M12-M18 | 30万 | 数据管理能力成熟度模型 |
| **飞腾CPU兼容认证** | 飞腾信息 | P1 | M6-M8 | 3万 | 飞腾平台兼容认证 |
| **鲲鹏兼容认证** | 华为 | P1 | M6-M8 | 免费 | 鲲鹏应用兼容认证(Kunpeng Compatible) |

### 8.2.2 认证预算与时间线

```
认证时间线 (M3-M18):

M3  M4  M5  M6  M7  M8  M9  M10 M11 M12 M13 M14 M15 M16 M17 M18
│   │   │   │   │   │   │   │   │   │   │   │   │   │   │   │
├───┤   │   │   │   │   │   │   │   │   │   │   │   │   │   │  达梦认证 (3万)
│   ├───┼───┼───┤   │   │   │   │   │   │   │   │   │   │   │  麒麟认证 (5万)
│   │   │   ├───┼───┼───┼───┤   │   │   │   │   │   │   │   │  等保三级 (15万)
│   │   │   ├───┼───┼───┼───┼───┼───┼───┤   │   │   │   │   │  国密认证 (20万)
│   │   │   │   ├───┼───┤   │   │   │   │   │   │   │   │   │  金仓认证 (3万)
│   │   │   │   ├───┼───┤   │   │   │   │   │   │   │   │   │  openGauss认证 (免费)
│   │   │   │   ├───┼───┤   │   │   │   │   │   │   │   │   │  飞腾认证 (3万)
│   │   │   │   ├───┼───┤   │   │   │   │   │   │   │   │   │  鲲鹏认证 (免费)
│   │   │   │   │   │   ├───┼───┼───┼───┼───┼───┼───┤   │   │  信创工委会 (10万)
│   │   │   │   │   │   ├───┼───┼───┼───┼───┼───┼───┤   │   │  东方通认证 (5万)
│   │   │   │   │   │   │   │   │   ├───┼───┼───┼───┼───┼───┤  DCMM四级 (30万)
                                                                       总计: ~94万
```

---

# 第九章 信创适配实施路径与任务分解

## 9.1 信创适配阶段化路线

| 阶段 | 时间 | 信创目标 | 关键交付物 |
|:----:|:----:|---------|-----------|
| Phase 1 | M1-M6 | 达梦DM8适配 + 国密SM2/SM3/SM4 | common-db-multi(V1) + common-crypto-gm |
| Phase 1 | M2-M3 | 麒麟V10 + ARM64适配 | 信创环境验证报告 |
| Phase 2 | M7-M12 | 多DB(金仓/openGauss) + 多CPU(飞腾/鲲鹏/龙芯) | 6种组合认证 |
| Phase 2 | M9-M12 | 国密SSL/TLCP + 等保三级 + 国密认证 | TLCP通信 + 认证证书 |
| Phase 3 | M13-M16 | 信创中间件(TongWeb/TongMQ) + 信创SaaS云 | 中间件认证 + 信创云部署 |
| Phase 4 | M17-M24 | 全栈信创(海光/兆芯 + 信创出海) | 全组合兼容矩阵覆盖 |

## 9.2 信创适配任务分解（与项目Sprint对齐）

### Sprint 2 (M2, 第5-8周): 达梦DM8适配与国密基础

| 任务编号 | 任务 | 负责人 | 工时 | 交付物 |
|:--------:|------|:------:|:----:|--------|
| XC-S2-01 | common-db-multi模块骨架搭建 | 架构师 | 3d | 模块工程结构 |
| XC-S2-02 | DatabaseDialect接口设计与达梦方言实现 | DBA | 3d | Dm8Dialect |
| XC-S2-03 | DatabaseTypeDetector自动探测器 | DBA | 2d | 探测器代码 |
| XC-S2-04 | Flyway多数据库迁移脚本目录 | DBA | 2d | dm8/迁移脚本 |
| XC-S2-05 | common-crypto-gm模块骨架搭建 | 安全团队 | 3d | 模块工程结构 |
| XC-S2-06 | SM2/SM3/SM4工具类实现 | 安全团队 | 5d | 国密工具类 |
| XC-S2-07 | CryptoFacade统一门面 + 自动切换 | 安全团队 | 3d | 加密门面 |
| XC-S2-08 | 达梦DM8兼容性测试 | DBA | 3d | DM8测试报告 |

### Sprint 3 (M3, 第9-12周): 信创环境适配扩展

| 任务编号 | 任务 | 负责人 | 工时 | 交付物 |
|:--------:|------|:------:|:----:|--------|
| XC-S3-01 | 麒麟V10服务器部署验证 | DevOps | 3d | 部署验证报告 |
| XC-S3-02 | ARM64多架构Docker镜像构建 | DevOps | 3d | multi-arch镜像 |
| XC-S3-03 | XinchuangEnvironmentDetector探测器 | 架构师 | 3d | 环境探测器 |
| XC-S3-04 | XinchuangProfileActivator自动Profile | 架构师 | 2d | 自动配置 |
| XC-S3-05 | 人大金仓KingbaseES方言实现 | DBA | 3d | KingbaseDialect |
| XC-S3-06 | openGauss方言实现 | DBA | 3d | OpenGaussDialect |
| XC-S3-07 | 金仓/openGauss迁移脚本编写 | DBA | 3d | 迁移脚本 |
| XC-S3-08 | 国密SSL/TLCP双证书体系 | 安全团队 | 5d | TLCP配置方案 |
| XC-S3-09 | 国密X.509证书管理模块 | 安全团队 | 3d | 证书管理代码 |
| XC-S3-10 | 信创组合测试矩阵T-01~T-06首轮 | 测试团队 | 5d | 兼容性测试报告 |

### Sprint 5 (M5, 第17-20周): 多CPU架构适配

| 任务编号 | 任务 | 负责人 | 工时 | 交付物 |
|:--------:|------|:------:|:----:|--------|
| XC-S5-01 | 飞腾FT-2000+编译运行验证 | DevOps | 3d | 飞腾验证报告 |
| XC-S5-02 | 鲲鹏920编译运行验证 + KAE加速 | DevOps | 3d | 鲲鹏验证报告 |
| XC-S5-03 | 龙芯LoongArch JDK验证 | DevOps | 5d | 龙芯验证报告 |
| XC-S5-04 | 统信UOS + openEuler部署验证 | DevOps | 3d | OS验证报告 |
| XC-S5-05 | 鲲鹏兼容认证申请 | DevOps | 5d | 认证申请材料 |
| XC-S5-06 | 飞腾兼容认证申请 | DevOps | 5d | 认证申请材料 |

### Sprint 8 (M8, 第29-32周): 等保三级与国密认证

| 任务编号 | 任务 | 负责人 | 工时 | 交付物 |
|:--------:|------|:------:|:----:|--------|
| XC-S8-01 | 等保2.0三级测评准备 | 安全团队 | 5d | 测评准备材料 |
| XC-S8-02 | 等保三级整改 | 安全团队 | 10d | 整改报告 |
| XC-S8-03 | 等保三级测评 | 第三方 | 5d | 等保三级证书 |
| XC-S8-04 | 国密二级密码模块认证申请 | 安全团队 | 5d | 认证申请材料 |
| XC-S8-05 | 国密密码模块送检 | 第三方 | 20d | 送检报告 |
| XC-S8-06 | SM9标识密码算法实现 | 安全团队 | 5d | SM9工具类 |
| XC-S8-07 | HSM硬件密码机PKCS#11集成 | 安全团队 | 5d | HSM集成代码 |

### Sprint 11 (M11, 第41-44周): 信创中间件全栈适配

| 任务编号 | 任务 | 负责人 | 工时 | 交付物 |
|:--------:|------|:------:|:----:|--------|
| XC-S11-01 | TongWeb应用服务器适配验证 | DevOps | 5d | TongWeb验证报告 |
| XC-S11-02 | TongMQ消息队列适配 | DevOps | 5d | TongMQ适配代码 |
| XC-S11-03 | TongRDS缓存适配验证 | DevOps | 2d | TongRDS验证报告 |
| XC-S11-04 | TongDiscovery注册中心适配 | DevOps | 3d | 适配验证报告 |
| XC-S11-05 | TongWeb Server(国密Nginx)部署 | DevOps | 3d | 部署方案 |
| XC-S11-06 | 信创中间件全组合测试 | 测试团队 | 5d | 中间件测试报告 |
| XC-S11-07 | 东方通中间件认证申请 | DevOps | 5d | 认证申请材料 |

### Sprint 16 (M16, 第61-64周): 信创SaaS云部署

| 任务编号 | 任务 | 负责人 | 工时 | 交付物 |
|:--------:|------|:------:|:----:|--------|
| XC-S16-01 | 华为云信创区部署验证 | DevOps | 5d | 华为云部署方案 |
| XC-S16-02 | 移动云信创区部署验证 | DevOps | 5d | 移动云部署方案 |
| XC-S16-03 | 信创K8s集群搭建(鲲鹏) | DevOps | 5d | K8s信创集群 |
| XC-S16-04 | 信创SaaS四模式验证 | 测试团队 | 5d | 四模式验证报告 |
| XC-S16-05 | 信创工委会认证申请 | 架构师 | 5d | 认证申请材料 |

## 9.3 信创适配里程碑

| 里程碑 | 时间 | 信创交付物 | 验收标准 |
|:------:|:----:|-----------|---------|
| **XC-M1** | M3 | 达梦DM8 + 国密SM2/SM3/SM4 | DM8功能测试通过 + 国密算法标准向量测试通过 |
| **XC-M2** | M5 | 三CPU(飞腾/鲲鹏/龙芯) + 三OS(麒麟/UOS/openEuler) | 6种组合编译运行通过 |
| **XC-M3** | M6 | 三DB(达梦/金仓/openGauss) + 自动检测 | 三数据库全部功能+性能测试通过 |
| **XC-M4** | M9 | 等保三级 + 国密二级认证 | 获得两项认证证书 |
| **XC-M5** | M12 | TLCP国密SSL + HSM集成 | 国密HTTPS通信通过 + HSM加解密通过 |
| **XC-M6** | M14 | 信创中间件全栈(TongWeb/TongMQ) | 中间件全组合测试通过 |
| **XC-M7** | M16 | 信创SaaS云部署(华为云/移动云) | 信创云四模式SaaS部署通过 |
| **XC-M8** | M18 | DCMM四级 + 信创工委会认证 | 获得两项资质证书 |

## 9.4 信创适配资源需求

| 角色 | 人数 | 信创职责 | 投入阶段 |
|------|:----:|---------|---------|
| 信创架构师 | 1 | 信创整体架构设计与适配方案 | 全程 |
| DBA(信创) | 1 | 多国产数据库适配与方言开发 | Phase 1-2 |
| 安全工程师(国密) | 1 | 国密算法实现与认证 | Phase 1-2 |
| DevOps(信创) | 1 | 信创环境部署与多架构镜像 | 全程 |
| 测试工程师(信创) | 1 | 信创兼容性测试矩阵执行 | Phase 1-3 |

## 9.5 信创适配风险与应对

| 风险 | 可能性 | 影响 | 应对措施 |
|------|:------:|:----:|---------|
| 龙芯LoongArch JDK兼容性问题 | 高 | 高 | 提前与龙芯技术支持对接，预留2周调试时间 |
| 国密认证周期长 | 高 | 中 | M6即启动认证流程，并行开发 |
| 东方通中间件API不兼容 | 中 | 中 | 统一接口抽象层，隔离中间件差异 |
| 信创环境性能下降 | 中 | 中 | 鲲鹏KAE加速 + JVM调优 + 数据库索引优化 |
| 达梦/金仓SQL不兼容 | 中 | 中 | 方言层统一适配 + Flyway分库脚本 |
| 信创认证费用超预算 | 低 | 低 | 优先P0认证，P1认证视客户需求推进 |

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-07 | 架构师 | 初始版本：信创全栈适配与国密算法完整设计方案 |
