# 智赢·智链 — 多模式架构设计方案补充（基于竞品分析V2.0）

> **文档版本**：V1.0  
> **编制日期**：2026年7月7日  
> **文档状态**：正式发布  
> **基于文档**：竞品分析报告V2.0 + 独立可售与无缝集成架构设计方案 + SaaS业务可行性与实现方案  
> **核心目标**：一套统一代码线，同时支持SaaS/私有化/独立销售/集成销售四种模式  

---

## 目录

- [第一章 竞品洞察驱动的架构设计原则](#第一章-竞品洞察驱动的架构设计原则)
- [第二章 四模式统一架构总览](#第二章-四模式统一架构总览)
- [第三章 统一代码线与Profile切换设计](#第三章-统一代码线与profile切换设计)
- [第四章 多租户隔离增强设计](#第四章-多租户隔离增强设计)
- [第五章 License授权与功能开关体系](#第五章-license授权与功能开关体系)
- [第六章 SaaS运营平台设计](#第六章-saas运营平台设计)
- [第七章 数据安全与合规增强设计](#第七章-数据安全与合规增强设计)
- [第八章 多模式部署拓扑设计](#第八章-多模式部署拓扑设计)
- [第九章 商业化包装与定价方案](#第九章-商业化包装与定价方案)
- [第十章 SaaS→私有化升级管道设计](#第十章-saas私有化升级管道设计)

---

# 第一章 竞品洞察驱动的架构设计原则

## 1.1 竞品分析核心洞察

基于竞品分析报告V2.0，提炼出以下驱动架构设计的核心洞察：

| 洞察编号 | 洞察内容 | 架构设计影响 |
|:--------:|----------|-------------|
| I-01 | 82.7%客户将信创+DCMM作为选型首要前提 | 信创适配必须全栈化、从设计之初嵌入 |
| I-02 | AI驱动型治理平台占比突破65% | AI能力必须原生嵌入，非外挂模块 |
| I-03 | 全链路一体化采用率同比+48% | 数据治理+AI治理必须深度集成，非简单拼接 |
| I-04 | 瓴羊SaaS领先但无AI治理，亿信有数据治理但SaaS弱 | SaaS+双栈是独占定位 |
| I-05 | 无竞品同时覆盖信创+SaaS | 信创SaaS是空白蓝海 |
| I-06 | Salesforce 80亿美元收购Informatica | 数据治理+AI融合是终局方向 |
| I-07 | 竞品无独立可售+组合销售能力 | 双产品独立/集成是独占商业模式 |
| I-08 | 76.5%企业通过一体化平台降低50%+成本 | 必须提供全链路一体化体验 |

## 1.2 架构设计原则（V2.0升级）

| 原则 | V1.0设计 | V2.0升级 | 升级原因 |
|------|----------|----------|----------|
| **统一代码线** | 三模式切换 | **四模式切换**（+SaaS模式） | 需同时支持SaaS和私有化 |
| **多租户** | 字段隔离 | **混合隔离**（字段+Schema+独立库） | 不同租户级别不同隔离策略 |
| **信创优先** | 达梦+国密 | **全栈信创**（芯片/OS/DB/中间件/密码） | 82.7%客户首要前提 |
| **AI原生** | 双AI引擎 | **双AI引擎+Agentic治理** | AI Agent是核心趋势 |
| **功能开关** | License控制 | **模块化功能开关+用量计量** | 支持模块化组合销售 |
| **数据安全** | 分级分类+脱敏 | **+隐私计算+数据不出域** | SaaS版数据安全要求更高 |
| **可插拔底座** | 内置/独立 | **内置/独立/共享三种模式** | SaaS多租户需共享底座 |

## 1.3 设计约束矩阵

```
四模式设计约束矩阵:

                    私有化                    SaaS
                 ┌──────────────┐        ┌──────────────┐
   独立部署      │ 模式A:       │        │ 模式C:       │
   (Standalone)  │ IC/SW独立    │        │ IC/SW独立    │
                 │ 内置底座     │        │ SaaS租户     │
                 │ 独立数据库   │        │ 字段隔离     │
                 │ 独立License  │        │ 用量计费     │
                 └──────────────┘        └──────────────┘
                 ┌──────────────┐        ┌──────────────┐
   集成部署      │ 模式B:       │        │ 模式D:       │
   (Integrated)  │ SC+SD集成    │        │ SC+SD集成    │
                 │ 共享底座     │        │ SaaS租户     │
                 │ 统一数据库   │        │ 企业版独立库 │
                 │ 组合License  │        │ 组合用量计费 │
                 └──────────────┘        └──────────────┘

四种模式必须一套代码支持，通过Profile切换:
  - spring.profiles.active=sc-standalone    (模式A: 智链私有化独立)
  - spring.profiles.active=sw-standalone    (模式A: 智赢私有化独立)
  - spring.profiles.active=integrated       (模式B: 私有化集成)
  - spring.profiles.active=sc-saas          (模式C: 智链SaaS)
  - spring.profiles.active=sw-saas          (模式C: 智赢SaaS)
  - spring.profiles.active=integrated-saas  (模式D: SaaS集成)
```

---

# 第二章 四模式统一架构总览

## 2.1 统一架构全景图

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SmartWin智赢平台四模式统一架构                                       │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                       前端门户层                                      │   │
│  │                                                                     │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────────────────────────────┐  │   │
│  │  │智链门户   │  │智数门户   │  │统一门户(集成模式)                  │  │   │
│  │  │(Vue 3)   │  │(Vue 3)   │  │微前端联邦→智链+智赢+统一驾驶舱     │  │   │
│  │  │独立运行   │  │独立运行   │  │集成运行                          │  │   │
│  │  └────┬─────┘  └────┬─────┘  └──────────┬───────────────────────┘  │   │
│  └───────┼─────────────┼────────────────────┼──────────────────────────┘   │
│          │             │                    │                              │
│  ┌───────┼─────────────┼────────────────────┼──────────────────────────┐   │
│  │       ▼             ▼                    ▼     API网关层            │   │
│  │  ┌──────────────────────────────────────────────────────────────┐   │   │
│  │  │              Spring Cloud Gateway                            │   │   │
│  │  │                                                              │   │   │
│  │  │  ┌─────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────┐ │   │   │
│  │  │  │租户识别  │  │SSO认证   │  │License   │  │用量计量       │ │   │   │
│  │  │  │Filter   │  │JWT/RBAC  │  │校验Filter│  │Filter        │ │   │   │
│  │  │  │(SaaS)   │  │OAuth2    │  │(功能开关) │  │(SaaS计费)    │ │   │   │
│  │  │  └─────────┘  └──────────┘  └──────────┘  └──────────────┘ │   │   │
│  │  │                                                              │   │   │
│  │  │  路由: /api/smartchain/** → 智链服务                        │   │   │
│  │  │        /api/smartwin/**   → 智赢服务                        │   │   │
│  │  │        /api/platform/**   → 共享服务                        │   │   │
│  │  │        /api/saas-admin/** → SaaS运营服务                    │   │   │
│  │  └──────────────────────────────────────────────────────────────┘   │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│          │             │                    │                              │
│  ┌───────┼─────────────┼────────────────────┼──────────────────────────┐   │
│  │       ▼             ▼                    ▼     服务层                │   │
│  │                                                                     │   │
│  │  ┌─────────────────────────────────────────────────────────────┐    │   │
│  │  │              SaaS运营服务 (仅SaaS模式激活)                    │    │   │
│  │  │  tenant-svc │ billing-svc │ metering-svc │ quota-svc        │    │   │
│  │  └─────────────────────────────────────────────────────────────┘    │   │
│  │                                                                     │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐      │   │
│  │  │共享底座服务    │  │智链独有服务    │  │智赢独有服务            │      │   │
│  │  │              │  │              │  │                      │      │   │
│  │  │auth-svc      │  │model-svc     │  │catalog-svc           │      │   │
│  │  │system-svc    │  │app-svc       │  │metadata-svc          │      │   │
│  │  │security-svc  │  │agent-svc     │  │quality-svc           │      │   │
│  │  │audit-svc     │  │cost-svc      │  │standard-svc          │      │   │
│  │  │dashboard-svc │  │risk-svc      │  │lineage-svc           │      │   │
│  │  │ai-engine-svc │  │prompt-svc    │  │mdm-svc               │      │   │
│  │  │              │  │              │  │lifecycle-svc         │      │   │
│  │  │(可插拔:      │  │              │  │dataservice-svc        │      │   │
│  │  │ 内置/独立/   │  │              │  │asset-svc             │      │   │
│  │  │ 共享)        │  │              │  │                      │      │   │
│  │  └──────────────┘  └──────────────┘  └──────────────────────┘      │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│          │             │                    │                              │
│  ┌───────┼─────────────┼────────────────────┼──────────────────────────┐   │
│  │       ▼             ▼                    ▼     数据层                │   │
│  │                                                                     │   │
│  │  ┌─────────────────────────────────────────────────────────────┐    │   │
│  │  │  私有化模式:                          SaaS模式:              │    │   │
│  │  │  ┌──────────┐                        ┌──────────────────┐   │    │   │
│  │  │  │DM8       │                        │DM8 (共享)         │   │    │   │
│  │  │  │sys_*     │                        │sys_* + tenant_id │   │    │   │
│  │  │  │ic_*      │                        │ic_* + tenant_id  │   │    │   │
│  │  │  │sw_*      │                        │sw_* + tenant_id  │   │    │   │
│  │  │  │(独立库)   │                        │  或独立Schema     │   │    │   │
│  │  │  └──────────┘                        │  (企业版租户)     │   │    │   │
│  │  │                                        └──────────────────┘   │    │   │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │    │   │
│  │  │  │Redis     │  │ES        │  │Neo4j     │  │MinIO     │   │    │   │
│  │  │  │(缓存)    │  │(搜索)    │  │(血缘)    │  │(对象存储) │   │    │   │
│  │  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │    │   │
│  │  └─────────────────────────────────────────────────────────────┘    │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 2.2 四模式对比

| 维度 | 模式A: 私有化独立 | 模式B: 私有化集成 | 模式C: SaaS独立 | 模式D: SaaS集成 |
|------|:---:|:---:|:---:|:---:|
| **部署方式** | 单产品独立部署 | 双产品统一部署 | SaaS租户(字段隔离) | SaaS租户(企业版独立库) |
| **共享底座** | 内置 | 共享一份 | SaaS共享 | SaaS共享 |
| **前端门户** | 独立门户 | 统一门户(微前端) | 独立门户(租户隔离) | 统一门户(租户隔离) |
| **数据库** | 独立库(ic_*/sw_*) | 统一库(sys_*+ic_*+sw_*) | 共享库(+tenant_id) | 独立Schema(企业版) |
| **License** | 单产品License | 组合License | SaaS订阅(按功能) | SaaS订阅(组合) |
| **计费** | License买断 | License买断 | 按年订阅+用量 | 按年订阅+用量 |
| **多租户** | ❌ | ❌ | ✅ | ✅ |
| **数据隔离** | 物理隔离 | 物理隔离 | 逻辑隔离(字段) | 物理隔离(Schema) |
| **适用客户** | 只需单产品的中大型客户 | 需双产品的大型客户 | 中小企业 | 中大型企业SaaS |
| **Profile** | ic/sw-standalone | integrated | ic/sw-saas | integrated-saas |

---

# 第三章 统一代码线与Profile切换设计

## 3.1 Maven多模块Profile设计

### 3.1.1 Profile层次结构

```
spring.profiles.active 层次:

Layer 1: 部署模式
  ├── private     (私有化模式)
  └── saas        (SaaS模式)

Layer 2: 产品组合
  ├── sc           (仅智链)
  ├── sw           (仅智赢)
  └── integrated   (智链+智赢集成)

Layer 3: 信创适配
  ├── standard     (标准版: MySQL/Redis/ES)
  └── xinchuang    (信创版: 达梦/国密/ARM64)

组合Profile示例:
  - private-ic-standard       → 私有化·智链独立·标准版
  - private-sw-xinchuang      → 私有化·智数独立·信创版
  - private-integrated-xinchuang → 私有化·集成·信创版
  - saas-ic-standard          → SaaS·智链独立·标准版
  - saas-integrated-xinchuang → SaaS·集成·信创版
```

### 3.1.2 application.yml 多Profile配置

```yaml
# application.yml (主配置)
spring:
  profiles:
    active: ${SPRING_PROFILES_ACTIVE:private-ic-standard}
    group:
      "private-ic-standard": ["private", "sc", "standard"]
      "private-ic-xinchuang": ["private", "sc", "xinchuang"]
      "private-sw-standard": ["private", "sw", "standard"]
      "private-sw-xinchuang": ["private", "sw", "xinchuang"]
      "private-integrated-standard": ["private", "integrated", "standard"]
      "private-integrated-xinchuang": ["private", "integrated", "xinchuang"]
      "saas-ic-standard": ["saas", "sc", "standard"]
      "saas-sw-standard": ["saas", "sw", "standard"]
      "saas-integrated-standard": ["saas", "integrated", "standard"]
      "saas-integrated-xinchuang": ["saas", "integrated", "xinchuang"]

# application-private.yml (私有化模式通用配置)
app:
  mode: private
  multi-tenant:
    enabled: false
  saas:
    enabled: false
  license:
    mode: perpetual  # 买断制
  datasource:
    strategy: standalone  # 独立数据库

# application-saas.yml (SaaS模式通用配置)
app:
  mode: saas
  multi-tenant:
    enabled: true
    isolation: hybrid  # 混合隔离
  saas:
    enabled: true
    billing: true
    metering: true
  license:
    mode: subscription  # 订阅制
  datasource:
    strategy: shared  # 共享数据库

# application-ic.yml (智链产品配置)
app:
  product: smartchain
  modules:
    enabled: [model, app, agent, cost, risk, prompt]
    disabled: [catalog, metadata, quality, standard, lineage, mdm, lifecycle, dataservice, asset]
  gateway:
    routes:
      - path: /api/smartchain/**
        service: smartchain-service

# application-sw.yml (智赢产品配置)
app:
  product: smartwin
  modules:
    enabled: [catalog, metadata, quality, standard, lineage, mdm, lifecycle, dataservice, asset]
    disabled: [model, app, agent, cost, risk, prompt]
  gateway:
    routes:
      - path: /api/smartwin/**
        service: smartwin-service

# application-integrated.yml (集成模式配置)
app:
  product: integrated
  modules:
    enabled: [model, app, agent, cost, risk, prompt, catalog, metadata, quality, standard, lineage, mdm, lifecycle, dataservice, asset]
  portal:
    type: unified  # 统一门户
    micro-frontend: true
  gateway:
    routes:
      - path: /api/smartchain/**
        service: smartchain-service
      - path: /api/smartwin/**
        service: smartwin-service
      - path: /api/platform/**
        service: platform-service

# ===== 前端主题与国际化通用配置 (详见DES-10) =====
app:
  ui:
    theme:
      default-mode: auto          # light / dark / auto(跟随系统)
      allow-user-switch: true     # 允许用户切换
      brand:
        smartchain: "#58a6ff"     # 智链品牌蓝
        smartwin: "#2dd4bf"       # 智赢品牌青
    i18n:
      default-locale: zh-CN       # 默认中文
      available-locales: [zh-CN, en-US]  # 当前支持中英双语
      # available-locales: [zh-CN, en-US, ja-JP, ko-KR]  # 预留多语言扩展
      fallback-locale: zh-CN      # 回退语言
      lazy-load: true             # 按模块懒加载locale文件

# application-xinchuang.yml (信创版配置)
# ⚠️ 信创全栈适配详细设计见《SmartWin智赢平台信创全栈适配与国密算法设计方案》(DES-09)
app:
  xinchuang:
    enabled: true
  db:
    type: auto      # 自动探测: dm8/kingbase/opengauss/gbase/shentong
  datasource:
    driver: dm.jdbc.driver.DmDriver   # 支持达梦/人大金仓/openGauss多DB
    url: jdbc:dm://localhost:5236
  redis:
    type: tongrds    # 东方通TongRDS替代Redis (协议兼容)
  mq:
    type: tongmq     # 东方通TongMQ替代RocketMQ (JMS接口)
  crypto:
    provider: software   # software(BC) 或 hsm(硬件密码机)
    algorithm:
      symmetric: SM4     # 国密SM4替代AES
      asymmetric: SM2    # 国密SM2替代RSA
      hash: SM3          # 国密SM3替代SHA-256
      sign: SM3withSM2   # 国密签名
      jwt: SM3-HMAC      # JWT用SM3-HMAC
  ssl:
    protocol: TLCP       # 国密SSL双证书(GB/T 38636)
  os:
    target: kylin        # 麒麟V10 / 统信UOS / openEuler (自动探测)
  arch:
    target: arm64        # 飞腾/鲲鹏(aarch64) / 龙芯(loongarch64) (自动探测)
  middleware:
    app-server: tongweb  # 东方通TongWeb替代Tomcat
```

> **信创适配详细设计**: Profile层仅做配置切换，完整的方言抽象层、国密算法SDK、自动探测机制、
> 多架构镜像构建、兼容性测试矩阵及认证规划见专项文档 **DES-09《SmartWin智赢平台信创全栈适配与国密算法设计方案》**。
> 新增共享模块: `common-db-multi`(多国产数据库适配) + `common-crypto-gm`(国密算法统一模块)。

## 3.2 条件化Bean加载设计

```java
/**
 * 部署模式条件注解
 */
@Target({ElementType.TYPE, ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
@Conditional(OnPrivateModeCondition.class)
public @interface ConditionalPrivate {
}

@Target({ElementType.TYPE, ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
@Conditional(OnSaaModeCondition.class)
public @interface ConditionalSaaS {
}

/**
 * 产品线条件注解
 */
@Target({ElementType.TYPE, ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
@ConditionalOnProperty(name = "app.product", havingValue = "smartchain")
public @interface ConditionalSmartChain {
}

@Target({ElementType.TYPE, ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
@ConditionalOnProperty(name = "app.product", havingValue = "smartwin")
public @interface ConditionalSmartWin {
}

@Target({ElementType.TYPE, ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
@ConditionalOnProperty(name = "app.product", havingValue = "integrated")
public @interface ConditionalIntegrated {
}

// 使用示例
@Service
@ConditionalSaaS
public class TenantGatewayFilter implements GlobalFilter {
    // 仅SaaS模式加载
}

@Service
@ConditionalPrivate
public class StandaloneLicenseValidator implements LicenseValidator {
    // 仅私有化模式加载
}

@Service
@ConditionalSmartChain
public class ModelService implements IModelService {
    // 仅智链模式加载
}

@Service
@ConditionalSmartWin
public class CatalogService implements ICatalogService {
    // 仅智赢模式加载
}
```

## 3.3 统一启动入口设计

```java
/**
 * 统一启动类 — 根据Profile自动装配对应模块
 */
@SpringBootApplication
@MapperScan(basePackages = {"com.smartwin.common", "${app.scan-packages}"})
public class SmartWinApplication {
    
    public static void main(String[] args) {
        String profile = System.getenv().getOrDefault("SPRING_PROFILES_ACTIVE", "private-ic-standard");
        
        // 根据Profile输出启动信息
        StartupBanner banner = new StartupBanner(profile);
        banner.print();
        
        new SpringApplicationBuilder(SmartWinApplication.class)
            .profiles(profile)
            .banner(banner)
            .logStartupInfo(true)
            .run(args);
    }
}
```

---

# 第四章 多租户隔离增强设计

## 4.1 混合多租户隔离策略

### 4.1.1 三级隔离模型

```
┌──────────────────────────────────────────────────────────────────┐
│                  混合多租户隔离模型                                 │
│                                                                  │
│  Level 1: 字段隔离 (基础版租户)                                    │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  共享数据库 + 共享Schema + tenant_id字段隔离               │   │
│  │                                                          │   │
│  │  适用: SaaS基础版/标准版租户 (年费<5万)                   │   │
│  │  隔离: tenant_id字段过滤                                  │   │
│  │  成本: 最低 (共享一切)                                    │   │
│  │  安全: 中 (逻辑隔离)                                      │   │
│  │                                                          │   │
│  │  sys_user (id, tenant_id, username, ...)                 │   │
│  │  ic_model (id, tenant_id, model_name, ...)               │   │
│  │  sw_catalog (id, tenant_id, catalog_name, ...)           │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  Level 2: Schema隔离 (企业版租户)                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  共享数据库 + 独立Schema + 无需tenant_id                  │   │
│  │                                                          │   │
│  │  适用: SaaS企业版租户 (年费5-35万)                        │   │
│  │  隔离: 独立Schema (tenant_ic_001, tenant_sw_001)          │   │
│  │  成本: 中 (共享数据库实例)                                 │   │
│  │  安全: 高 (物理Schema隔离)                                │   │
│  │                                                          │   │
│  │  Database: smartwin_saas                                 │   │
│  │    Schema: tenant_ic_001 (智链租户1的表)                  │   │
│  │    Schema: tenant_sw_001 (智赢租户1的表)                  │   │
│  │    Schema: tenant_ic_002 (智链租户2的表)                  │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  Level 3: 独立数据库 (旗舰版租户/私有化)                           │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  独立数据库实例 + 完全物理隔离                             │   │
│  │                                                          │   │
│  │  适用: SaaS旗舰版租户/私有化部署 (年费>35万)              │   │
│  │  隔离: 独立数据库实例                                     │   │
│  │  成本: 最高 (独立资源)                                    │   │
│  │  安全: 最高 (完全物理隔离)                                │   │
│  │                                                          │   │
│  │  Database: tenant_001_db (独立实例)                       │   │
│  │    Schema: public (标准表结构，无tenant_id)               │   │
│  └──────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────┘
```

### 4.1.2 租户隔离策略选择逻辑

```java
/**
 * 租户隔离策略路由器
 */
@Service
@ConditionalSaaS
public class TenantIsolationRouter {
    
    @Autowired
    private TenantManager tenantManager;
    
    /**
     * 根据租户级别动态选择数据源
     */
    public DataSource routeDataSource(String tenantId) {
        Tenant tenant = tenantManager.getTenant(tenantId);
        
        switch (tenant.getIsolationLevel()) {
            case FIELD:
                // 字段隔离: 返回共享数据源，在SQL层加tenant_id过滤
                return sharedDataSource;
                
            case SCHEMA:
                // Schema隔离: 返回共享数据库实例，切换到租户Schema
                return createSchemaDataSource(tenant.getSchemaName());
                
            case DATABASE:
                // 独立库: 返回租户专属数据源
                return tenantDataSourceMap.get(tenantId);
                
            default:
                return sharedDataSource;
        }
    }
    
    /**
     * 字段隔离模式 — MyBatis拦截器自动注入tenant_id
     */
    @Intercepts({
        @Signature(type = Executor.class, method = "query", 
                   args = {MappedStatement.class, Object.class, RowBounds.class, ResultHandler.class}),
        @Signature(type = Executor.class, method = "update", 
                   args = {MappedStatement.class, Object.class})
    })
    public class TenantIdInterceptor implements Interceptor {
        @Override
        public Object intercept(Invocation invocation) throws Throwable {
            if (!isFieldIsolationMode()) {
                return invocation.proceed();
            }
            
            // 获取当前SQL和参数
            Object[] args = invocation.getArgs();
            MappedStatement ms = (MappedStatement) args[0];
            BoundSql boundSql = ms.getBoundSql(args[1]);
            String sql = boundSql.getSql();
            
            // 自动注入tenant_id条件
            String tenantId = TenantContext.getCurrentTenantId();
            if (tenantId != null && !sql.contains("tenant_id")) {
                sql = injectTenantIdCondition(sql, tenantId);
                // 替换SQL执行
                return executeWithModifiedSql(invocation, sql);
            }
            
            return invocation.proceed();
        }
    }
}
```

## 4.2 租户识别增强设计

### 4.2.1 多维度租户识别

```java
/**
 * 增强版租户识别过滤器
 */
@Component
@ConditionalSaaS
@Order(-100)  // 最高优先级
public class EnhancedTenantGatewayFilter implements GlobalFilter {
    
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        ServerHttpRequest request = exchange.getRequest();
        
        // 策略1: 从域名提取租户 (xxx.smartwin.com → tenant=xxx)
        String tenantCode = extractFromDomain(request.getURI().getHost());
        
        // 策略2: 从Header提取 (API调用)
        if (tenantCode == null) {
            tenantCode = request.getHeaders().getFirst("X-Tenant-Code");
        }
        
        // 策略3: 从Token提取 (已认证用户)
        if (tenantCode == null) {
            tenantCode = extractFromJwt(request);
        }
        
        // 策略4: 从子路径提取 (/t/{tenantCode}/api/...)
        if (tenantCode == null) {
            tenantCode = extractFromPath(request.getPath().value());
        }
        
        if (tenantCode != null) {
            Tenant tenant = tenantManager.validateTenant(tenantCode);
            
            // 注入租户上下文
            exchange.getRequest().mutate()
                .header("X-Tenant-Id", tenant.getTenantId())
                .header("X-Tenant-Mode", tenant.getMode())           // ic/sw/integrated
                .header("X-Tenant-Level", tenant.getLevel())         // basic/enterprise/flagship
                .header("X-Tenant-Isolation", tenant.getIsolation()) // field/schema/database
                .build();
            
            // 设置租户上下文到Reactor
            return chain.filter(exchange)
                .contextWrite(Context.of("tenantId", tenant.getTenantId()));
        }
        
        // 未识别租户 — 公共接口放行，业务接口拒绝
        if (isPublicEndpoint(request.getPath().value())) {
            return chain.filter(exchange);
        }
        
        return unauthorizedResponse(exchange, "租户未识别");
    }
}
```

---

# 第五章 License授权与功能开关体系

## 5.1 License体系设计

### 5.1.1 License类型矩阵

```
License类型矩阵:

┌──────────────────────────────────────────────────────────────────┐
│                     License授权体系                                │
│                                                                  │
│  私有化License:                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  SC-Standard    智链标准版    30-80万/年                   │   │
│  │  SC-Enterprise  智链企业版    80-200万/年                  │   │
│  │  SD-Standard    智赢标准版    30-80万/年                   │   │
│  │  SD-Enterprise  智赢企业版    80-200万/年                  │   │
│  │  IC-SW-Combo    集成组合版    50-500万/年 (优惠15-20%)     │   │
│  │  IC-SW-Flagship 集成旗舰版    200-500万/年                 │   │
│  │  Module-Addon   模块增购      按模块报价                    │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  SaaS订阅License:                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  IC-SaaS-Basic    智链SaaS基础版  5-10万/年               │   │
│  │  IC-SaaS-Pro      智链SaaS专业版  10-15万/年              │   │
│  │  SW-SaaS-Basic    智赢SaaS基础版  2-5万/年                │   │
│  │  SW-SaaS-Pro      智赢SaaS专业版  5-15万/年               │   │
│  │  Combo-SaaS-Pro   集成SaaS专业版  8-25万/年 (优惠15%)     │   │
│  │  Combo-SaaS-Ent   集成SaaS企业版  25-35万/年              │   │
│  │  Usage-Addon      用量增购       按量计费                  │   │
│  └──────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────┘
```

### 5.1.2 功能开关矩阵

| 功能模块 | SC-Standard | SC-Enterprise | SD-Standard | SD-Enterprise | Combo | SaaS-Basic | SaaS-Pro | SaaS-Ent |
|----------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **认证授权** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **系统管理** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **安全治理** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **审计日志** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **模型管理** | ✅ | ✅ | — | — | ✅ | ✅ | ✅ | ✅ |
| **应用管理** | ✅ | ✅ | — | — | ✅ | ❌ | ✅ | ✅ |
| **Agent管理** | ❌ | ✅ | — | — | ✅ | ❌ | ❌ | ✅ |
| **AI成本管控** | ❌ | ✅ | — | — | ✅ | ❌ | ✅ | ✅ |
| **AI安全检测** | ❌ | ✅ | — | — | ✅ | ❌ | ❌ | ✅ |
| **AI风险管控** | ❌ | ✅ | — | — | ✅ | ❌ | ❌ | ✅ |
| **Prompt管理** | ✅ | ✅ | — | — | ✅ | ✅ | ✅ | ✅ |
| **数据目录** | — | — | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **元数据管理** | — | — | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **数据质量** | — | — | ✅ | ✅ | ✅ | 基础 | ✅ | ✅ |
| **数据标准** | — | — | ❌ | ✅ | ✅ | ❌ | ✅ | ✅ |
| **数据血缘** | — | — | ❌ | ✅ | ✅ | ❌ | ✅ | ✅ |
| **主数据管理** | — | — | ❌ | ✅ | ✅ | ❌ | ❌ | ✅ |
| **数据集成** | — | — | ❌ | ✅ | ✅ | ❌ | ❌ | ✅ |
| **数据生命周期** | — | — | ❌ | ✅ | ✅ | ❌ | ❌ | ✅ |
| **数据服务API** | — | — | ❌ | ✅ | ✅ | ❌ | ✅ | ✅ |
| **数据资产评估** | — | — | ❌ | ✅ | ✅ | ❌ | ❌ | ✅ |
| **AI Copilot** | 基础 | ✅ | 基础 | ✅ | ✅ | 基础 | ✅ | ✅ |
| **Agentic治理** | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ✅ |
| **多租户管理** | — | — | — | — | — | ✅ | ✅ | ✅ |

## 5.2 License校验实现

### 5.2.1 License文件结构

```json
{
  "licenseId": "LIC-2026-001234",
  "licenseType": "IC-SW-Combo",
  "customer": {
    "name": "XX银行股份有限公司",
    "code": "BANK_XX_001"
  },
  "products": ["smartchain", "smartwin"],
  "modules": {
    "smartchain": ["model", "app", "agent", "cost", "risk", "prompt", "security"],
    "smartwin": ["catalog", "metadata", "quality", "standard", "lineage", "mdm", "asset"]
  },
  "features": {
    "agenticGovernance": true,
    "aiCopilot": true,
    "dataAssetValuation": true,
    "multiTenant": false
  },
  "deployment": {
    "mode": "integrated",
    "environment": "private",
    "maxUsers": 500,
    "maxDataSources": 50,
    "maxAIModels": 100
  },
  "validity": {
    "startDate": "2026-07-01",
    "endDate": "2027-06-30",
    "type": "annual"
  },
  "signature": "SM2:MEUCIQDx...签名数据..."
}
```

### 5.2.2 License校验过滤器

```java
/**
 * License校验与功能开关过滤器
 */
@Component
@Order(-50)  // 在租户识别之后
public class LicenseGatewayFilter implements GlobalFilter {
    
    @Autowired
    private LicenseManager licenseManager;
    
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String path = exchange.getRequest().getPath().value();
        
        // 公共接口跳过
        if (isPublicEndpoint(path)) {
            return chain.filter(exchange);
        }
        
        // 获取当前License
        License license = licenseManager.getCurrentLicense();
        if (license == null || !license.isValid()) {
            return licenseErrorResponse(exchange, "License无效或已过期");
        }
        
        // 解析请求对应模块
        String module = extractModuleFromPath(path);
        if (module != null && !license.hasModule(module)) {
            return licenseErrorResponse(exchange, "模块未授权: " + module);
        }
        
        // 解析请求对应功能
        String feature = extractFeatureFromPath(path);
        if (feature != null && !license.hasFeature(feature)) {
            return licenseErrorResponse(exchange, "功能未授权: " + feature);
        }
        
        // 注入License信息到请求头
        exchange.getRequest().mutate()
            .header("X-License-Type", license.getLicenseType())
            .header("X-License-Modules", String.join(",", license.getModules()))
            .build();
        
        return chain.filter(exchange);
    }
}
```

## 5.3 功能开关注解设计

```java
/**
 * 功能开关注解 — 基于License控制API访问
 */
@Target({ElementType.METHOD, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
public @interface FeatureSwitch {
    String module() default "";
    String feature() default "";
    String minEdition() default "standard"; // standard/enterprise/flagship
}

// 使用示例
@RestController
@RequestMapping("/api/smartchain/model")
public class ModelController {
    
    @GetMapping
    @FeatureSwitch(module = "model", minEdition = "standard")
    public Result listModels() { ... }
    
    @PostMapping
    @FeatureSwitch(module = "model", feature = "model_register", minEdition = "standard")
    public Result registerModel() { ... }
}

@RestController
@RequestMapping("/api/smartchain/agent")
public class AgentController {
    
    @GetMapping
    @FeatureSwitch(module = "agent", minEdition = "enterprise")
    public Result listAgents() { ... }
}

@RestController
@RequestMapping("/api/smartwin/lineage")
public class LineageController {
    
    @GetMapping
    @FeatureSwitch(module = "lineage", minEdition = "enterprise")
    public Result getLineage() { ... }
}

@RestController
@RequestMapping("/api/platform/agentic")
public class AgenticController {
    
    @PostMapping
    @FeatureSwitch(feature = "agenticGovernance", minEdition = "flagship")
    public Result executeAgent() { ... }
}
```

---

# 第六章 SaaS运营平台设计

## 6.1 SaaS运营平台架构

```
┌──────────────────────────────────────────────────────────────────┐
│                  SaaS运营平台架构                                   │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              SaaS运营管理门户                               │   │
│  │  • 租户管理  • 计费管理  • 用量监控  • 运营看板            │   │
│  │  • 客户成功  • 工单系统  • 财务管理  • 渠道管理            │   │
│  └──────────────────────────┬───────────────────────────────┘   │
│                             │                                    │
│  ┌──────────────────────────┴───────────────────────────────┐   │
│  │              SaaS运营服务层                                 │   │
│  │                                                            │   │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐   │   │
│  │  │tenant-svc│ │billing-svc│ │metering- │ │quota-svc │   │   │
│  │  │          │ │          │ │svc       │ │          │   │   │
│  │  │•租户注册  │ │•订阅管理  │ │•用量采集  │ │•配额管理  │   │   │
│  │  │•租户配置  │ │•账单生成  │ │•用量统计  │ │•限流控制  │   │   │
│  │  │•租户隔离  │ │•支付对接  │ │•用量预警  │ │•超额阻断  │   │   │
│  │  │•租户冻结  │ │•发票管理  │ │•用量报表  │ │•弹性扩容  │   │   │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘   │   │
│  │                                                            │   │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐   │   │
│  │  │notify-svc│ │upgrade-svc│ │template- │ │channel-  │   │   │
│  │  │          │ │          │ │svc       │ │svc       │   │   │
│  │  │•消息通知  │ │•SaaS→私有│ │•行业模板  │ │•渠道管理  │   │   │
│  │  │•告警推送  │ │ 化升级    │ │•配置模板  │ │•代理商    │   │   │
│  │  │•邮件/短信 │ │•数据迁移  │ │•快速初始化│ │•分成结算  │   │   │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘   │   │
│  └────────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────┘
```

## 6.2 计费与计量设计

### 6.2.1 计费维度

| 计费维度 | 智链计量项 | 智赢计量项 | 计费方式 |
|----------|-----------|-----------|----------|
| **基础订阅** | 按版本(基础/专业/企业) | 按版本(基础/专业/企业) | 年费预付 |
| **用户数** | 管理用户数 | 管理用户数 | 按用户数阶梯 |
| **AI调用量** | AI模型调用Token数 | AI Copilot调用次数 | 按量计费 |
| **数据源数** | AI应用接入数 | 数据源接入数 | 按数量阶梯 |
| **存储量** | AI调用日志存储 | 元数据/质量数据存储 | 按GB/月 |
| **API调用** | 平台API调用次数 | 数据服务API调用次数 | 按万次计费 |
| **增值服务** | AI安全检测次数 | 数据资产评估次数 | 按次计费 |

### 6.2.2 用量计量实现

```java
/**
 * 用量计量服务
 */
@Service
@ConditionalSaaS
public class MeteringService {
    
    @Autowired
    private RedisTemplate<String, String> redis;
    
    /**
     * 实时计量API调用
     */
    public void recordApiCall(String tenantId, String apiPath, long duration) {
        String key = String.format("meter:%s:api:%s", tenantId, DateUtil.today());
        redis.opsForHash().increment(key, apiPath, 1);
        redis.opsForHash().increment(key + ":duration", apiPath, duration);
        redis.expire(key, 90, TimeUnit.DAYS);
    }
    
    /**
     * 实时计量AI调用Token
     */
    public void recordAITokenUsage(String tenantId, String modelId, int tokenCount) {
        String key = String.format("meter:%s:aitoken:%s", tenantId, DateUtil.today());
        redis.opsForHash().increment(key, modelId, tokenCount);
        redis.expire(key, 90, TimeUnit.DAYS);
        
        // 检查配额
        quotaService.checkQuota(tenantId, "ai_token", getCurrentUsage(tenantId, "ai_token"));
    }
    
    /**
     * 实时计量数据源接入
     */
    public void recordDataSource(String tenantId, String sourceType) {
        String key = String.format("meter:%s:datasource", tenantId);
        redis.opsForSet().add(key, sourceType);
    }
    
    /**
     * 生成月度账单
     */
    public BillingStatement generateMonthlyBill(String tenantId, YearMonth month) {
        BillingStatement statement = new BillingStatement();
        statement.setTenantId(tenantId);
        statement.setMonth(month);
        
        // 基础订阅费
        Subscription sub = subscriptionService.getSubscription(tenantId);
        statement.setBaseFee(sub.getPlan().getMonthlyFee());
        
        // 用量计费
        long apiCalls = getMonthlyUsage(tenantId, "api", month);
        statement.setApiCallFee(calculateApiFee(apiCalls, sub.getPlan()));
        
        long aiTokens = getMonthlyUsage(tenantId, "aitoken", month);
        statement.setAiTokenFee(calculateAiTokenFee(aiTokens, sub.getPlan()));
        
        long storageGB = getMonthlyUsage(tenantId, "storage", month);
        statement.setStorageFee(calculateStorageFee(storageGB, sub.getPlan()));
        
        // 增值服务费
        statement.setAddonFee(calculateAddonFee(tenantId, month));
        
        // 合计
        statement.setTotal(statement.getBaseFee()
            .add(statement.getApiCallFee())
            .add(statement.getAiTokenFee())
            .add(statement.getStorageFee())
            .add(statement.getAddonFee()));
        
        return statement;
    }
}
```

## 6.3 配额与限流设计

```java
/**
 * 配额管理服务 — SaaS模式租户用量控制
 */
@Service
@ConditionalSaaS
public class QuotaService {
    
    /**
     * 租户配额配置
     */
    public TenantQuota getQuota(String tenantId) {
        Subscription sub = subscriptionService.getSubscription(tenantId);
        
        return TenantQuota.builder()
            .maxUsers(getMaxUsers(sub.getPlan()))          // 基础:10 专业:50 企业:200
            .maxDataSources(getMaxDataSources(sub.getPlan())) // 基础:5 专业:20 企业:100
            .maxAIModels(getMaxAIModels(sub.getPlan()))     // 基础:5 专业:20 企业:100
            .maxApiCallsPerDay(getMaxApiCalls(sub.getPlan())) // 基础:1000 专业:10000 企业:无限
            .maxAITokensPerMonth(getMaxAITokens(sub.getPlan())) // 基础:10万 专业:100万 企业:500万
            .maxStorageGB(getMaxStorage(sub.getPlan()))     // 基础:5GB 专业:50GB 企业:500GB
            .build();
    }
    
    /**
     * 配额检查 — 超额时阻断或告警
     */
    public QuotaCheckResult checkQuota(String tenantId, String resource, long currentUsage) {
        TenantQuota quota = getQuota(tenantId);
        long limit = quota.getLimit(resource);
        
        if (limit > 0 && currentUsage >= limit) {
            // 超额 — 阻断
            return QuotaCheckResult.blocked("配额已用尽: " + resource + 
                " (当前: " + currentUsage + ", 上限: " + limit + ")");
        }
        
        // 80%预警
        if (limit > 0 && currentUsage >= limit * 0.8) {
            notifyService.sendQuotaWarning(tenantId, resource, currentUsage, limit);
            return QuotaCheckResult.warning("配额使用达80%");
        }
        
        return QuotaCheckResult.ok();
    }
}
```

---

# 第七章 数据安全与合规增强设计

## 7.1 SaaS版数据安全增强

### 7.1.1 数据不落云设计（Connector Mode）

```
┌──────────────────────────────────────────────────────────────────┐
│              SaaS版"数据不落云"架构 (Connector Mode)               │
│                                                                  │
│  SaaS平台 (云端)                      客户侧 (本地)                │
│  ┌──────────────────┐                ┌──────────────────┐       │
│  │  SmartWin智赢平台SaaS     │                │  客户数据源       │       │
│  │                  │                │                  │       │
│  │  • 仅存储元数据   │←─元数据同步──→ │  • 业务数据库     │       │
│  │  • 仅存储规则配置  │                │  • 数据仓库      │       │
│  │  • 仅存储治理结果  │                │  • 文件系统      │       │
│  │  • 不存储原始数据  │                │                  │       │
│  │                  │                │  ┌────────────┐  │       │
│  │  ┌────────────┐  │←─安全连接──→  │  │Connector   │  │       │
│  │  │Connector   │  │   (VPN/专线)   │  │Agent       │  │       │
│  │  │Manager     │  │                │  │            │  │       │
│  │  └────────────┘  │                │  │•数据采集   │  │       │
│  │                  │                │  │•质量检测   │  │       │
│  │  原始数据: ❌     │                │  │•血缘扫描   │  │       │
│  │  元数据: ✅      │                │  │•脱敏执行   │  │       │
│  │  治理结果: ✅    │                │  └────────────┘  │       │
│  └──────────────────┘                └──────────────────┘       │
│                                                                  │
│  核心原则:                                                       │
│  • 原始数据永不离开客户网络                                       │
│  • SaaS平台只存元数据和治理配置                                    │
│  • 所有数据操作通过Connector Agent在客户侧执行                     │
│  • 满足"数据不出域"合规要求                                       │
└──────────────────────────────────────────────────────────────────┘
```

### 7.1.2 数据加密设计

| 数据状态 | 加密方案 | 私有化模式 | SaaS模式 |
|----------|----------|:----------:|:--------:|
| **传输加密** | TLS 1.3 + 国密SM2 | ✅ | ✅ |
| **存储加密** | AES-256 / 国密SM4 | 可选 | **强制** |
| **字段加密** | 敏感字段SM4加密 | 可选 | **强制** |
| **备份加密** | SM4加密备份 | 可选 | **强制** |
| **密钥管理** | 本地KMS / 国密HSM | 本地 | 云KMS+HSM |

## 7.2 合规认证规划

| 认证/合规 | 优先级 | 时间节点 | 说明 |
|-----------|:------:|:--------:|------|
| **DCMM四级** | P0 | M1-M6 | 82.7%客户首要前提，必须优先获取 |
| **等保三级** | P0 | M3-M9 | SaaS版必须，政务客户必需 |
| **ISO 27001** | P1 | M6-M12 | 国际安全标准，金融客户认可 |
| **ISO 27701** | P1 | M12-M18 | 隐私信息管理体系 |
| **可信云认证** | P1 | M6-M12 | SaaS版可信认证 |
| **CMMI三级** | P2 | M12-M18 | 软件能力成熟度 |
| **国密认证** | P0 | M3-M9 | SM2/SM4密码产品认证 |

---

# 第八章 多模式部署拓扑设计

## 8.1 模式A：私有化独立部署拓扑

```
┌─────────────────────────────────────────────┐
│         模式A: 智链/智赢 私有化独立部署       │
│                                             │
│  Docker Compose / K8s 单集群                │
│                                             │
│  ┌─────────────────────────────────┐        │
│  │  Nginx (Port 80/443)            │        │
│  │  → 前端静态资源                  │        │
│  │  → API反向代理                   │        │
│  └────────────┬────────────────────┘        │
│               │                             │
│  ┌────────────┴────────────────────┐        │
│  │  Spring Cloud Gateway (9000)    │        │
│  └────────────┬────────────────────┘        │
│               │                             │
│  ┌────────────┴────────────────────┐        │
│  │  共享底座 (内置)                  │        │
│  │  auth(8081) system(8082)         │        │
│  │  security(8083) audit(8084)      │        │
│  │  dashboard(8085) ai-engine(8086) │        │
│  └────────────┬────────────────────┘        │
│               │                             │
│  ┌────────────┴────────────────────┐        │
│  │  产品独有服务                     │        │
│  │  IC: model/app/agent/cost/risk  │        │
│  │  SW: catalog/metadata/quality.. │        │
│  └────────────┬────────────────────┘        │
│               │                             │
│  ┌────────────┴────────────────────┐        │
│  │  DM8 + Redis + ES + MinIO       │        │
│  └─────────────────────────────────┘        │
│                                             │
│  License: IC/SD-Standard/Enterprise         │
│  部署时间: 2-4周                             │
│  最低配置: 8C 32G 500G                       │
└─────────────────────────────────────────────┘
```

## 8.2 模式B：私有化集成部署拓扑

```
┌──────────────────────────────────────────────────────────────┐
│         模式B: 智链+智赢 私有化集成部署                        │
│                                                              │
│  K8s集群 (推荐) / Docker Compose                             │
│                                                              │
│  ┌────────────────────────────────────────────────────┐      │
│  │  Nginx (Port 80/443)                               │      │
│  │  → 统一门户(微前端)                                  │      │
│  │  → API反向代理                                       │      │
│  └──────────────┬─────────────────────────────────────┘      │
│                 │                                            │
│  ┌──────────────┴─────────────────────────────────────┐      │
│  │  Spring Cloud Gateway (9000)                       │      │
│  │  /api/smartchain/** → 智链服务                     │      │
│  │  /api/smartwin/**   → 智赢服务                     │      │
│  │  /api/platform/**   → 共享服务                     │      │
│  └──────┬───────────────┬───────────────┬─────────────┘      │
│         │               │               │                    │
│  ┌──────┴──────┐ ┌─────┴───────┐ ┌────┴──────────┐          │
│  │ 共享底座(一份)│ │ 智链服务     │ │ 智赢服务       │          │
│  │ auth/system  │ │ model/app   │ │ catalog/meta  │          │
│  │ security/    │ │ agent/cost  │ │ quality/std   │          │
│  │ audit/dash   │ │ risk/prompt │ │ lineage/mdm   │          │
│  │ ai-engine    │ │             │ │ lifecycle/..  │          │
│  └──────┬──────┘ └─────┬───────┘ └────┬──────────┘          │
│         │               │               │                    │
│  ┌──────┴───────────────┴───────────────┴─────────────────┐  │
│  │  统一数据库 (DM8)                                       │  │
│  │  sys_* (共享) + ic_* (智链) + sw_* (智赢)              │  │
│  │  + Redis + ES + Neo4j + MinIO                          │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  License: IC-SW-Combo/Flagship                               │
│  部署时间: 3-6周                                              │
│  最低配置: 16C 64G 1T                                         │
└──────────────────────────────────────────────────────────────┘
```

## 8.3 模式C/D：SaaS部署拓扑

```
┌──────────────────────────────────────────────────────────────────────┐
│         模式C/D: SaaS部署 (智链/智赢 独立/集成)                         │
│                                                                      │
│  Kubernetes集群 (多节点高可用)                                        │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐      │
│  │  CDN + WAF + DDoS防护                                      │      │
│  └────────────────────────┬───────────────────────────────────┘      │
│                           │                                          │
│  ┌────────────────────────┴───────────────────────────────────┐      │
│  │  Ingress Controller (TLS终止)                               │      │
│  │  → *.smartwin-saas.com (多租户域名路由)                     │      │
│  └────────────────────────┬───────────────────────────────────┘      │
│                           │                                          │
│  ┌────────────────────────┴───────────────────────────────────┐      │
│  │  API Gateway (高可用集群)                                   │      │
│  │  • 租户识别Filter • License校验 • 用量计量 • 限流熔断       │      │
│  └──┬──────────┬──────────┬──────────┬──────────┬─────────────┘      │
│     │          │          │          │          │                    │
│  ┌──┴────┐┌───┴────┐┌───┴────┐┌───┴────┐┌───┴──────┐              │
│  │SaaS   ││共享底座  ││智链服务  ││智赢服务  ││连接器     │              │
│  │运营   ││(共享)   ││(共享)   ││(共享)   ││Manager   │              │
│  │服务   ││        ││        ││        ││          │              │
│  │tenant ││auth    ││model   ││catalog ││←→ Agent  │              │
│  │billing││system  ││app     ││metadata││  (客户侧) │              │
│  │meter  ││security││agent   ││quality ││          │              │
│  │quota  ││audit   ││cost    ││standard││          │              │
│  │upgrade││dashboard││risk   ││lineage ││          │              │
│  └──┬────┘└───┬────┘└───┬────┘└───┬────┘└──────────┘              │
│     │         │         │         │                                 │
│  ┌──┴─────────┴─────────┴─────────┴─────────────────────────────┐  │
│  │  数据层 (高可用)                                               │  │
│  │  • DM8主从集群 (共享库+租户独立Schema)                         │  │
│  │  • Redis集群 (多租户缓存隔离)                                  │  │
│  │  • ES集群 (多租户索引隔离)                                     │  │
│  │  • Neo4j集群 (血缘图谱)                                        │  │
│  │  • MinIO集群 (对象存储)                                        │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                      │
│  部署: Kubernetes + Helm + ArgoCD                                    │
│  高可用: 3节点+ 跨可用区                                              │
│  备份: 每日全量 + 实时增量 + 异地容灾                                 │
└──────────────────────────────────────────────────────────────────────┘
```

---

# 第九章 商业化包装与定价方案

## 9.1 四模式商业化矩阵

### 9.1.1 私有化定价

| 版本 | 包含产品 | 价格区间 | 功能范围 | 适用客户 |
|------|----------|:--------:|----------|----------|
| SC-Standard | 智链 | 30-80万/年 | 模型/应用/Prompt管理+基础安全 | 中型AI企业 |
| SC-Enterprise | 智链 | 80-200万/年 | 全功能+Agent+AI安全+成本+风险 | 大型AI企业 |
| SD-Standard | 智赢 | 30-80万/年 | 目录/元数据/质量+基础功能 | 中型企业 |
| SD-Enterprise | 智赢 | 80-200万/年 | 全功能+血缘/MDM/资产/入表 | 大型企业 |
| **Combo-Pro** | 智链+智赢 | **50-200万/年** | 两产品专业版(优惠15%) | 中大型企业 |
| **Combo-Ent** | 智链+智赢 | **150-500万/年** | 两产品企业版(优惠18%) | 大型企业/集团 |
| **Combo-Flagship** | 智链+智赢 | **300-500万+/年** | 全功能+Agentic+定制 | 涉密/央企 |

### 9.1.2 SaaS定价

| 版本 | 包含产品 | 月费/年费 | 功能范围 | 配额 | 适用客户 |
|------|----------|:---------:|----------|------|----------|
| IC-SaaS-Basic | 智链 | 5,000/月 (5万/年) | 模型/应用/Prompt | 10用户/5模型/1万Token/月 | 小型AI团队 |
| IC-SaaS-Pro | 智链 | 10,000/月 (10万/年) | +成本+基础安全 | 50用户/20模型/100万Token/月 | 中型AI企业 |
| SW-SaaS-Basic | 智赢 | 2,000/月 (2万/年) | 目录/元数据/基础质量 | 10用户/5数据源/5GB | 小型企业 |
| SW-SaaS-Pro | 智赢 | 5,000/月 (5万/年) | +标准+血缘+API | 50用户/20数据源/50GB | 中型企业 |
| **Combo-SaaS-Pro** | 智链+智赢 | **8,000/月 (8万/年)** | 两产品专业版(优惠15%) | 合并配额 | 中小企业 |
| **Combo-SaaS-Ent** | 智链+智赢 | **25,000/月 (25万/年)** | 全功能+企业隔离 | 200用户/无限/500万Token | 中大型企业 |

### 9.1.3 用量计费标准

| 计量项 | 基础版包含 | 超出部分单价 | 企业版包含 |
|--------|:----------:|:----------:|:----------:|
| AI调用Token | 1万/月 | 0.01元/千Token | 500万/月 |
| API调用 | 1,000次/天 | 0.1元/百次 | 无限 |
| 数据源接入 | 5个 | 500元/个/月 | 100个 |
| 存储空间 | 5GB | 1元/GB/月 | 500GB |
| AI安全检测 | 100次/月 | 5元/次 | 10,000次/月 |
| 数据资产评估 | ❌ | 2,000元/次 | 5次/月 |

## 9.2 SaaS→私有化升级定价

| SaaS版本 | 升级目标 | 升级优惠 | 数据迁移 | 停机时间 |
|----------|----------|:--------:|:--------:|:--------:|
| IC-SaaS-Pro → SC-Enterprise | 私有化智链企业版 | SaaS已付费用100%抵扣 | 免费迁移工具 | <4小时 |
| SW-SaaS-Pro → SD-Enterprise | 私有化智赢企业版 | SaaS已付费用100%抵扣 | 免费迁移工具 | <4小时 |
| Combo-SaaS-Ent → Combo-Ent | 私有化集成企业版 | SaaS已付费用100%抵扣 | 免费迁移工具 | <8小时 |

---

# 第十章 SaaS→私有化升级管道设计

## 10.1 升级管道架构

```
┌──────────────────────────────────────────────────────────────────┐
│              SaaS → 私有化 升级管道                                 │
│                                                                  │
│  Step 1: 触发升级                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  客户在SaaS平台发起升级请求                                │   │
│  │  → 选择目标私有化版本                                      │   │
│  │  → 系统生成升级报价单(SaaS已付费用抵扣)                    │   │
│  │  → 签署私有化合同                                          │   │
│  └────────────────────────┬─────────────────────────────────┘   │
│                           │                                      │
│  Step 2: 环境准备                                                 │
│  ┌────────────────────────┴─────────────────────────────────┐   │
│  │  → 客户提供私有化部署环境(服务器/VM/K8s)                   │   │
│  │  → 生成私有化部署配置文件(Profile切换)                     │   │
│  │  → 生成私有化License文件                                   │   │
│  │  → 部署私有化版本(自动化脚本)                              │   │
│  └────────────────────────┬─────────────────────────────────┘   │
│                           │                                      │
│  Step 3: 数据迁移                                                 │
│  ┌────────────────────────┴─────────────────────────────────┐   │
│  │  → SaaS侧: 导出租户数据(元数据/配置/规则/治理结果)         │   │
│  │  → 加密传输(国密SM4)                                      │   │
│  │  → 私有化侧: 导入数据                                     │   │
│  │  → 数据一致性校验                                          │   │
│  │  → 原始数据无需迁移(Connector模式本就在客户侧)             │   │
│  └────────────────────────┬─────────────────────────────────┘   │
│                           │                                      │
│  Step 4: 切换与验证                                               │
│  ┌────────────────────────┴─────────────────────────────────┐   │
│  │  → DNS切换/SaaS标记为"已升级"                              │   │
│  │  → 私有化环境功能验证                                      │   │
│  │  → 用户引导至私有化环境                                    │   │
│  │  → SaaS数据保留30天(回退窗口)                              │   │
│  └────────────────────────┬─────────────────────────────────┘   │
│                           │                                      │
│  Step 5: 完成                                                     │
│  ┌────────────────────────┴─────────────────────────────────┐   │
│  │  → 私有化环境正式运行                                      │   │
│  │  → SaaS租户状态更新为"已升级"                              │   │
│  │  → 30天后清理SaaS侧数据                                    │   │
│  │  → 后续按私有化License续费                                 │   │
│  └──────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────┘
```

## 10.2 升级工具设计

```java
/**
 * SaaS→私有化升级服务
 */
@Service
public class UpgradePipelineService {
    
    /**
     * 生成升级报价单
     */
    public UpgradeQuote generateQuote(String tenantId, String targetEdition) {
        // 获取SaaS订阅信息
        Subscription sub = subscriptionService.getSubscription(tenantId);
        
        // 计算SaaS已付费用（按剩余月份比例）
        BigDecimal saasPaidRemaining = calculateRemainingPrepaid(tenantId);
        
        // 私有化目标版本价格
        BigDecimal privatePrice = getPrivateEditionPrice(targetEdition);
        
        // SaaS已付费用100%抵扣
        BigDecimal finalPrice = privatePrice.subtract(saasPaidRemaining);
        
        return UpgradeQuote.builder()
            .tenantId(tenantId)
            .currentPlan(sub.getPlan())
            .targetEdition(targetEdition)
            .privatePrice(privatePrice)
            .saasCredit(saasPaidRemaining)
            .finalPrice(finalPrice)
            .dataMigrationIncluded(true)
            .estimatedDowntime("4-8小时")
            .build();
    }
    
    /**
     * 导出租户数据
     */
    public ExportResult exportTenantData(String tenantId) {
        ExportResult result = new ExportResult();
        
        // 导出元数据
        result.addMetadata(catalogService.exportAll(tenantId));
        result.addMetadata(metadataService.exportAll(tenantId));
        
        // 导出配置
        result.addConfig(qualityService.exportRules(tenantId));
        result.addConfig(standardService.exportStandards(tenantId));
        result.addConfig(securityService.exportPolicies(tenantId));
        
        // 导出治理结果
        result.addResults(qualityService.exportResults(tenantId));
        result.addResults(lineageService.exportLineage(tenantId));
        
        // 加密打包
        result.encrypt("SM4", tenantSpecificKey);
        result.packageAs("tar.gz");
        
        return result;
    }
    
    /**
     * 生成私有化部署配置
     */
    public DeploymentConfig generateDeploymentConfig(String tenantId, String targetEdition) {
        return DeploymentConfig.builder()
            .profile(determineProfile(targetEdition))
            .license(generatePrivateLicense(tenantId, targetEdition))
            .datasource(generateDatasourceConfig(targetEdition))
            .modules(determineModules(targetEdition))
            .build();
    }
}
```

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-07 | 智赢项目组 | 初始版本：基于竞品分析V2.0，设计四模式统一架构、多租户增强、License体系、SaaS运营平台、数据安全增强、多模式部署拓扑、商业化定价、升级管道 |
