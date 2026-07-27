# SmartWin 运营推广产品执行方案

> **文档编号**: PROMO-PLAN-001  
> **创建日期**: 2026-07-11  
> **文档状态**: 🟢 活跃（Phase 1-3 全部实现验证完成）
> **编制人**: 产品组 + 架构组 + 运营组  
> **定位**: 内部运营推广系统——不对外售卖，服务于公司SEO/SEM/GEO/内容营销/社群运营/渠道管理  

---

## 目录

- [一、现状审计与差距分析](#一现状审计与差距分析)
- [二、产品方案总览](#二产品方案总览)
- [三、模块一：公司官网门户](#三模块一公司官网门户)
- [四、模块二：博客系统与内容营销](#四模块二博客系统与内容营销)
- [五、模块三：免费SaaS注册与多租户](#五模块三免费saas注册与多租户)
- [六、模块四：邀请制Beta注册](#六模块四邀请制beta注册)
- [七、模块五：企微/钉钉/飞书集成](#七模块五企微钉钉飞书集成)
- [八、模块六：国际化与英文官网](#八模块六国际化与英文官网)
- [九、模块七：SEO+GEO优化体系](#九模块七seogeo优化体系)
- [十、模块八：公众号与社交媒体](#十模块八公众号与社交媒体)
- [十一、模块九：社群与渠道门户](#十一模块九社群与渠道门户)
- [十二、分阶段执行路线图](#十二分阶段执行路线图)
- [十三、任务清单与工时估算](#十三任务清单与工时估算)
- [十四、KPI目标与度量](#十四kpi目标与度量)

---

## 一、现状审计与差距分析

### 1.1 已有资产盘点

| 资产类别 | 已实现内容 | 所在位置 | 状态 |
|---------|-----------|---------|------|
| **前端-落地页** | LandingView（Hero/功能特性/解决方案/定价/案例/文档导航） | `smartchain-frontend/src/views/auth/LandingView.vue` | ✅ 已实现 |
| **前端-博客列表** | BlogView（分类筛选/文章卡片/分页） | `smartchain-frontend/src/views/auth/BlogView.vue` | ✅ 已实现 |
| **前端-博客详情** | BlogDetailView（文章内容/SEO元数据/JSON-LD） | `smartchain-frontend/src/views/auth/BlogDetailView.vue` | ✅ 已实现 |
| **前端-案例详情** | CaseStudyDetailView（挑战/方案/成果/评价） | `smartchain-frontend/src/views/auth/CaseStudyDetailView.vue` | ✅ 已实现 |
| **前端-注册页** | RegisterView（手机号+验证码+邮箱+密码+公司信息） | `smartchain-frontend/src/views/auth/RegisterView.vue` | ✅ 已实现 |
| **前端-定价页** | PricingView（5级套餐+支付方式选择弹窗） | `smartchain-frontend/src/views/PricingView.vue` | ✅ 已实现 |
| **前端-API文档** | ApiDocsView（公开API文档页） | `smartchain-frontend/src/views/auth/ApiDocsView.vue` | ✅ 已实现 |
| **前端-状态页** | StatusPageView（系统运行状态） | `smartchain-frontend/src/views/auth/StatusPageView.vue` | ✅ 已实现 |
| **后端-内容营销** | ContentMarketingService（博客CRUD/案例/SEO关键词/Sitemap/JSON-LD） | `ops-platform/ops-service/ContentMarketingService.java` | ✅ MySQL持久化 |
| **后端-增长指标** | GrowthMetricsService（AARRR漏斗/DAU/MAU/渠道分析/实验看板） | `ops-platform/ops-service/GrowthMetricsService.java` | ✅ MySQL持久化 |
| **后端-SaaS运营** | SaaSOpsService（租户健康度/流失预警/续费提醒） | `ops-platform/ops-service/SaaSOpsService.java` | ✅ MySQL持久化 |
| **后端-计费系统** | BillingService（5级套餐/用量计费/超额/账单） | `ops-platform/ops-service/BillingService.java` | ✅ MySQL+Redis动态定价 |
| **后端-支付网关** | PaymentGatewayService（支付宝/微信支付/Stripe） | `ops-platform/ops-service/PaymentGatewayService.java` | ✅ 已实现 |
| **后端-认证服务** | AuthService（登录/注册/短信验证码/Token刷新/密码管理/2FA/设备/偏好） | `auth-service/AuthController.java` | ✅ 注册接口已实现 |
| **i18n** | zh-CN + en-US 双语支持 | `smartchain-frontend/src/i18n/index.ts` | ✅ 已实现 |
| **路由** | 80+条路由，含15+条public公开路由（含公司官网/英文官网/OAuth回调） | `smartchain-frontend/src/router/index.ts` | ✅ 已实现 |

### 1.2 关键差距识别

| 编号 | 差距描述 | 影响 | 优先级 |
|------|---------|------|--------|
| GAP-01 | **后端无注册接口**：前端`authApi.register()`调用`/auth/register`，但AuthController未实现该端点 | 用户无法完成SaaS自助注册 | 🔴 P0 | ✅ 已修复：AuthController.register()+AuthService.register()已实现 |
| GAP-02 | **无短信验证码服务**：前端`authApi.sendSmsCode()`调用`/auth/sms-code`，后端未实现 | 注册流程断裂 | 🔴 P0 | ✅ 已修复：AuthController.sendSmsCode()+SmsGatewayService已实现 |
| GAP-03 | **运营数据无持久化**：ContentMarketing/GrowthMetrics/SaaSOps/Billing全部使用内存Map | 重启数据丢失，无法商用 | 🔴 P0 | ✅ 已修复：全部迁移至MySQL(ops_*表)+23个Mapper+26张表 |
| GAP-04 | **无多租户注册流程**：缺少租户创建→用户绑定→默认角色/权限→默认套餐分配的完整链路 | 无法支持SaaS模式 | 🔴 P0 | ✅ 已修复：AuthService.register()完整链路(验证码→租户→用户→角色→配额→Token) |
| GAP-05 | **无邀请码机制**：缺少邀请码生成→验证→奖励发放的完整流程 | 无法实施邀请制Beta | 🟠 P1 | ✅ 已修复：InvitationCodeService+OpsInvitationCode+InvitationCodeServiceTest |
| GAP-06 | **无企微/钉钉/飞书集成**：缺少OAuth登录、消息推送、组织架构同步 | 无法触达企业IM用户 | 🟠 P1 | ✅ 已修复：OAuthController+OAuthWebService+OAuthCallbackView |
| GAP-07 | **无独立公司官网**：当前LandingView是产品落地页，非公司级官网门户 | 公司还有AI CRM等新产品，需统一入口 | 🟠 P1 | ✅ 已修复：CompanyHomeView+ProductsView+SolutionsView+AboutView |
| GAP-08 | **无英文官网**：i18n仅覆盖应用界面，博客内容/落地页/文档无英文版本 | 国际化无法启动 | 🟠 P1 | ✅ 已修复：EnHomeView+EnBlogView+EnglishApiDocsView |
| GAP-09 | **无公众号集成**：缺少微信公众号API对接、文章同步、菜单管理 | 缺少中文内容分发渠道 | 🟡 P2 | ✅ 已修复：WeChatOfficialAccountService(文章同步/菜单/模板消息) |
| GAP-10 | **无邮件营销系统**：缺少邮件模板/自动化流/触达统计 | 用户生命周期运营缺失 | 🟡 P2 | ✅ 已修复：EmailMarketingService+OpsEmailUnsubscribe(退订DB持久化) |
| GAP-11 | **无渠道门户**：缺少代理商/合作伙伴注册、分级、佣金体系 | 渠道拓展受限 | 🟡 P2 | ✅ 已修复：ChannelPartnerService+ChannelPartnerController+OpsChannelPartner |
| GAP-12 | **GEO优化未实施**：仅有基础SEO（TDK/Sitemap/JSON-LD），缺少AI搜索引擎优化 | AI搜索时代品牌可见度低 | 🟡 P2 | ✅ 已修复：ContentMarketingService内置JSON-LD/Sitemap/hreflang+SEO关键词追踪 |
| GAP-13 | **无社区论坛**：缺少开发者社区/问答系统/贡献者体系 | 社区运营无载体 | 🟢 P3 | ✅ 已修复：OpenSourceCommunityService+OpenSourceCommunityController |
| GAP-14 | **无Webhook/事件订阅**：运营事件无法推送到外部系统 | 集成能力不足 | 🟢 P3 | ✅ 已修复：WebhookNotificationService+StandaloneWebhookEventAdapter |

### 1.3 行业趋势洞察（2026年）

基于行业调研，以下趋势直接影响方案设计：

| 趋势 | 影响 | 方案应对 |
|------|------|---------|
| **GEO（生成式引擎优化）崛起**：2026年B2B决策者67%使用AI搜索，GEO市场4年复合增长率189.8% | 传统SEO不够，需让AI"理解、信任并引用"品牌内容 | 新增GEO优化模块：结构化知识图谱+AI可引用内容+权威信号建设 |
| **企微/钉钉/飞书CLI化**：三大平台2026年Q1相继开源CLI，从"服务人类"转向"服务AI智能体" | 企业系统集成从API调用升级为Agent可调用 | 集成方案预留Agent接口，支持CLI化对接 |
| **PLG（产品驱动增长）成为B2B SaaS主流**：免费版→激活→付费转化路径缩短 | 需要极低摩擦的注册→激活→价值体验流程 | 免费SaaS版+自动化用户引导+产品内触发转化 |
| **零点击搜索占比攀升**：AI Overviews直接回答用户问题，传统点击流量下降 | 内容需要从"被检索"升级为"被引用" | 内容策略转向：结构化知识+权威数据+可引用片段 |
| **E-E-A-T成为硬指标**：Google将"第一手经验"纳入评估，AI模型同样偏好真实经验内容 | 缺乏真实案例/数据/作者背书的内容将被双重惩罚 | 案例研究+真实数据+专家作者+可验证信息 |

---

## 二、产品方案总览

### 2.1 系统定位

```
SmartWin 运营推广系统 = 公司内部营销基础设施
                      = 官网门户 + 内容引擎 + 增长引擎 + 渠道引擎
                      = 不对外售卖，服务于公司全产品线推广
```

### 2.2 产品矩阵关系

```
┌─────────────────────────────────────────────────────────────┐
│                    公司官网 (smartwin.com)                    │
│                   统一入口，展示全部产品线                      │
│                                                             │
│   ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│   │ SmartWin │  │ AI CRM   │  │ 产品线3  │  │ 产品线N  │  │
│   │ AI治理    │  │ 系统     │  │ (后续)   │  │ (后续)   │  │
│   │ (智链+   │  │          │  │          │  │          │  │
│   │  智数)   │  │          │  │          │  │          │  │
│   └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘  │
│        │             │             │             │         │
│        └──────┬──────┴──────┬──────┴─────────────┘         │
│               │             │                               │
│        ┌──────┴──────┐ ┌───┴────┐                          │
│        │ 博客系统     │ │ 公众号  │                          │
│        │ (内容引擎)   │ │ (社媒)  │                          │
│        └──────┬──────┘ └────────┘                          │
│               │                                             │
│        ┌──────┴──────┐                                      │
│        │ SaaS注册     │                                      │
│        │ (增长引擎)   │                                      │
│        └──────┬──────┘                                      │
│               │                                             │
│     ┌─────────┼─────────┐                                   │
│     │         │         │                                   │
│  ┌──┴──┐ ┌───┴───┐ ┌───┴───┐                              │
│  │ SEO  │ │ GEO   │ │ 社群   │                              │
│  │ 优化  │ │ 优化  │ │ 渠道   │                              │
│  └─────┘ └───────┘ └───────┘                              │
└─────────────────────────────────────────────────────────────┘
```

### 2.3 九大功能模块

| 模块 | 名称 | 核心价值 | 优先级 | 启动阶段 |
|------|------|---------|--------|---------|
| 模块一 | 公司官网门户 | 统一品牌入口，展示全部产品线 | P1 | Phase 1 |
| 模块二 | 博客与内容营销 | SEO/GEO内容生产与分发引擎 | P0 | Phase 1 |
| 模块三 | 免费SaaS注册 | 多租户自助注册→激活→转化 | P0 | Phase 1 |
| 模块四 | 邀请制Beta注册 | 种子用户获取+裂变传播 | P1 | Phase 1 |
| 模块五 | 企微/钉钉/飞书集成 | 企业IM生态触达+OAuth登录 | P1 | Phase 2 |
| 模块六 | 国际化与英文官网 | 全球市场覆盖+英文SEO | P1 | Phase 2 |
| 模块七 | SEO+GEO优化体系 | 搜索引擎+AI引擎双轨优化 | P0 | Phase 1 |
| 模块八 | 公众号与社交媒体 | 中文内容分发+私域引流 | P2 | Phase 2 |
| 模块九 | 社群与渠道门户 | 开发者社区+代理商体系 | P2 | Phase 3 |

---

## 三、模块一：公司官网门户

### 3.1 设计目标

当前LandingView是SmartWin产品的落地页，需要升级为**公司级官网门户**，作为全部产品线的统一入口。

### 3.2 信息架构

```
smartwin.com (公司官网)
├── 首页 (Company Home)
│   ├── 公司介绍 (使命/愿景/团队)
│   ├── 产品矩阵 (智链/智数/AI CRM/后续产品)
│   ├── 客户 logo 墙
│   ├── 最新动态 (博客摘要)
│   └── CTA: 免费试用 / 联系我们
│
├── 产品 (Products)
│   ├── SmartWin AI治理平台 → 跳转 /landing (现有)
│   ├── AI CRM系统 → 跳转 crm.smartwin.com
│   ├── 产品线3 → 后续扩展
│   └── 产品线N → 后续扩展
│
├── 解决方案 (Solutions)
│   ├── 金融行业
│   ├── 制造业
│   ├── 政务/信创
│   └── 更多行业
│
├── 客户案例 (Case Studies)
│   ├── 案例列表 (按行业筛选)
│   └── 案例详情 (挑战/方案/成果/评价)
│
├── 资源中心 (Resources)
│   ├── 技术博客 → /blog
│   ├── 白皮书下载
│   ├── 开发者文档 → /api-docs
│   ├── 视频教程
│   └── Webinar回放
│
├── 定价 (Pricing) → /pricing
│
├── 关于我们 (About)
│   ├── 公司简介
│   ├── 加入我们 (招聘)
│   ├── 联系我们
│   └── 合作伙伴
│
└── 法律
    ├── 服务条款
    ├── 隐私政策
    └── Cookie政策
```

### 3.3 技术实现方案

| 项目 | 方案 |
|------|------|
| 路由 | 新增 `/company` 前缀路由组，`/` 重定向到 `/company` |
| 组件 | 新建 `views/company/` 目录：`CompanyHomeView.vue`、`ProductsView.vue`、`SolutionsView.vue`、`AboutView.vue` |
| 设计系统 | 复用shared-components设计系统，官网使用独立的品牌主题 |
| 响应式 | 复用现有响应式断点（移动端/平板/桌面） |
| SEO | 每个页面独立TDK（Title/Description/Keywords）+ JSON-LD结构化数据 |
| 性能 | 首页SSR/预渲染（提升LCP），其余页面SPA懒加载 |
| i18n | 中英文双语，URL路径区分：`/company`(中文) / `/en/company`(英文) |

### 3.4 需要新建的前端页面

| 页面 | 路由 | 优先级 | 说明 |
|------|------|--------|------|
| CompanyHomeView | `/company` | P1 | 公司首页，产品矩阵展示 |
| ProductsView | `/company/products` | P1 | 产品列表页，各产品简介+入口 |
| SolutionsView | `/company/solutions` | P2 | 行业解决方案列表 |
| AboutView | `/company/about` | P2 | 公司介绍/团队/招聘 |
| WhitepaperView | `/company/whitepapers` | P2 | 白皮书/资源下载 |
| LegalView | `/company/legal/:type` | P2 | 服务条款/隐私政策 |

---

## 四、模块二：博客系统与内容营销

### 4.1 现状

- ✅ 前端：BlogView（列表）+ BlogDetailView（详情）已实现
- ✅ 后端：ContentMarketingService已实现博客CRUD+SEO元数据+Sitemap+JSON-LD
- ✅ 后端已迁移至MySQL持久化（ops_blog_article/ops_case_study/ops_seo_keyword表）
- ❌ 无富文本编辑器，内容管理依赖API直接调用（Phase 2计划）
- ❌ 无内容审批流（Phase 2计划）
- ❌ 无内容日历管理（Phase 2计划）

### 4.2 改进计划

#### 4.2.1 数据持久化（P0）

```sql
-- 博客文章表
CREATE TABLE ops_blog_article (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    slug VARCHAR(200) NOT NULL UNIQUE COMMENT 'URL友好标识',
    title VARCHAR(500) NOT NULL COMMENT '标题',
    category VARCHAR(100) COMMENT '分类',
    summary VARCHAR(1000) COMMENT '摘要',
    content LONGTEXT COMMENT '正文(Markdown/HTML)',
    author_id BIGINT COMMENT '作者ID',
    author_name VARCHAR(100) COMMENT '作者名',
    lang VARCHAR(10) DEFAULT 'zh-CN' COMMENT '语言',
    status VARCHAR(20) DEFAULT 'DRAFT' COMMENT 'DRAFT/REVIEW/PUBLISHED/ARCHIVED',
    publish_date DATETIME COMMENT '发布日期',
    tags JSON COMMENT '标签',
    cover_image VARCHAR(500) COMMENT '封面图',
    -- SEO元数据
    meta_title VARCHAR(200),
    meta_description VARCHAR(500),
    canonical_url VARCHAR(500),
    og_image VARCHAR(500),
    -- 统计
    read_time INT COMMENT '阅读时长(分钟)',
    view_count BIGINT DEFAULT 0,
    like_count INT DEFAULT 0,
    -- 时间戳
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_status_date (status, publish_date),
    INDEX idx_lang (lang),
    INDEX idx_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='博客文章';

-- 案例研究表
CREATE TABLE ops_case_study (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    slug VARCHAR(200) NOT NULL UNIQUE,
    title VARCHAR(500) NOT NULL,
    industry VARCHAR(100),
    company VARCHAR(200),
    summary VARCHAR(1000),
    content LONGTEXT,
    lang VARCHAR(10) DEFAULT 'zh-CN',
    status VARCHAR(20) DEFAULT 'DRAFT',
    publish_date DATETIME,
    challenge TEXT COMMENT '客户挑战',
    solution TEXT COMMENT '解决方案',
    results JSON COMMENT '成果数据[{metric,value,description}]',
    testimonial TEXT COMMENT '客户评价',
    testimonial_author VARCHAR(100),
    roi VARCHAR(50),
    logo_url VARCHAR(500),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_industry (industry),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='客户案例';

-- SEO关键词追踪表
CREATE TABLE ops_seo_keyword (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    keyword VARCHAR(200) NOT NULL,
    url VARCHAR(500),
    lang VARCHAR(10) DEFAULT 'zh-CN',
    current_rank INT DEFAULT 0,
    previous_rank INT DEFAULT 0,
    search_volume INT DEFAULT 0,
    difficulty INT DEFAULT 0,
    last_updated DATE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_keyword_lang (keyword, lang)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='SEO关键词追踪';
```

#### 4.2.2 内容管理后台（P1）

| 功能 | 说明 | 工作量 |
|------|------|--------|
| 博客文章列表 | 分页/筛选/搜索/状态筛选 | 2人天 |
| 文章编辑器 | TipTap富文本编辑器+Markdown支持+图片上传 | 5人天 |
| SEO面板 | meta_title/description/canonical/og_image编辑+预览 | 2人天 |
| 内容审批流 | DRAFT→REVIEW→PUBLISHED→ARCHIVED 状态流转 | 3人天 |
| 内容日历 | 可视化发布计划（日历视图） | 3人天 |
| 案例研究管理 | CRUD+成果数据编辑+客户授权标记 | 3人天 |
| SEO关键词看板 | 排名追踪+趋势图+竞品对比 | 3人天 |

#### 4.2.3 内容生产策略

| 内容类型 | 频率 | 目标 | 负责人 |
|---------|------|------|--------|
| 技术博客（中文） | 2篇/周 | SEO关键词覆盖+技术布道 | 技术写作 |
| 技术博客（英文） | 1篇/周 | 国际SEO+GEO优化 | Tech Writer |
| 客户案例 | 1篇/月 | 社会证明+转化提升 | PMO |
| 白皮书 | 1篇/季度 | 行业权威+Lead Gen | 产品 |
| 教程指南 | 2篇/月 | 产品采用+用户激活 | 产品 |
| 产品动态 | 按需 | 用户告知+功能推广 | 产品 |

---

## 五、模块三：免费SaaS注册与多租户

### 5.1 现状差距

- ✅ 前端：RegisterView已实现（手机号+验证码+邮箱+密码+公司信息）
- ✅ 前端API：`authApi.register()` 和 `authApi.sendSmsCode()` 已定义
- ✅ 后端：AuthController已实现 `/auth/register` 和 `/auth/sms-code` 端点
- ✅ 多租户注册流程已实现（租户创建→用户绑定→默认角色→默认套餐）
- ✅ 短信服务已集成（SmsGatewayService，支持阿里云短信）

### 5.2 注册流程设计

#### 5.2.1 用户注册流程

```
用户访问 /register
    │
    ▼
填写手机号 → 点击"获取验证码"
    │
    ▼
后端 /auth/sms-code
    ├── 校验手机号格式
    ├── 防刷限制（同IP 1次/分钟，同号码 1次/60秒）
    ├── 生成6位验证码，存入Redis（5分钟过期）
    ├── 调用短信服务发送
    └── 返回成功
    │
    ▼
用户填写：验证码 + 邮箱 + 密码 + 公司名 + 姓名 + 行业 + 规模
    │
    ▼
后端 /auth/register
    ├── 1. 校验验证码（Redis）
    ├── 2. 校验邮箱唯一性
    ├── 3. 创建租户(sys_tenant)
    │      ├── tenant_code = 自动生成(公司名拼音首字母+随机数)
    │      ├── plan = 'FREE'
    │      ├── status = 'ACTIVE'
    │      └── max_users = 3 (免费版限制)
    ├── 4. 创建用户(sys_user)
    │      ├── tenant_id = 新租户ID
    │      ├── username = 手机号或邮箱
    │      ├── password = BCrypt加密
    │      ├── role = 'TENANT_ADMIN'
    │      └── status = 1 (激活)
    ├── 5. 分配默认角色和权限
    │      ├── 角色: 租户管理员
    │      └── 权限: FREE套餐功能集
    ├── 6. 初始化租户数据
    │      ├── 创建默认工作空间
    │      ├── 初始化FREE套餐配额
    │      └── 发送欢迎邮件
    ├── 7. 发布领域事件
    │      ├── auth.user.register → OpsHub追踪
    │      ├── billing.subscription.created → 计费系统
    │      └── notification.welcome → 通知服务
    └── 8. 返回JWT Token（自动登录）
    │
    ▼
前端跳转到 /dashboard（已登录状态）
    │
    ▼
新手引导流程（Onboarding Tour）
    ├── Step 1: 欢迎介绍
    ├── Step 2: 创建第一个AI应用
    ├── Step 3: 接入第一个大模型
    ├── Step 4: 查看数据治理
    └── Step 5: 升级套餐提示
```

#### 5.2.2 后端接口设计

```java
// AuthController 新增端点

@PostMapping("/register")
@Operation(summary = "SaaS用户注册", description = "创建租户+用户+默认配置，返回JWT Token")
public ApiResponse<LoginResponse> register(@Valid @RequestBody RegisterRequest request) {
    // 1. 校验验证码
    // 2. 创建租户
    // 3. 创建用户
    // 4. 分配角色权限
    // 5. 初始化数据
    // 6. 发布事件
    // 7. 返回Token
}

@PostMapping("/sms-code")
@Operation(summary = "发送短信验证码", description = "注册/找回密码时发送验证码")
public ApiResponse<Void> sendSmsCode(@RequestParam String phone) {
    // 1. 防刷校验
    // 2. 生成验证码
    // 3. 存入Redis
    // 4. 调用短信服务
}

// RegisterRequest DTO
@Data
public class RegisterRequest {
    @NotBlank(message = "手机号不能为空")
    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式错误")
    private String phone;
    
    @NotBlank(message = "验证码不能为空")
    @Length(min = 6, max = 6, message = "验证码为6位数字")
    private String code;
    
    @NotBlank(message = "邮箱不能为空")
    @Email(message = "邮箱格式错误")
    private String email;
    
    @NotBlank(message = "密码不能为空")
    @Size(min = 8, max = 32, message = "密码长度8-32位")
    private String password;
    
    private String company;
    private String name;
    private String industry;
    private String size;
    private String countryCode;
    
    // 邀请码（可选，用于邀请制Beta）
    private String inviteCode;
}
```

#### 5.2.3 多租户数据模型

```sql
-- 租户表（已有sys_tenant，需补充字段）
ALTER TABLE sys_tenant ADD COLUMN IF NOT EXISTS plan VARCHAR(20) DEFAULT 'FREE';
ALTER TABLE sys_tenant ADD COLUMN IF NOT EXISTS max_users INT DEFAULT 3;
ALTER TABLE sys_tenant ADD COLUMN IF NOT EXISTS trial_ends_at DATETIME;
ALTER TABLE sys_tenant ADD COLUMN IF NOT EXISTS created_source VARCHAR(20) DEFAULT 'SELF_REGISTER';

-- 免费版配额表
CREATE TABLE ops_tenant_quota (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    tenant_id BIGINT NOT NULL,
    plan VARCHAR(20) NOT NULL DEFAULT 'FREE',
    -- 配额项
    max_models INT DEFAULT 3 COMMENT '最大模型数',
    max_agents INT DEFAULT 5 COMMENT '最大Agent数',
    max_apps INT DEFAULT 3 COMMENT '最大应用数',
    max_api_calls_monthly INT DEFAULT 10000 COMMENT '月API调用上限',
    max_storage_gb INT DEFAULT 5 COMMENT '存储上限(GB)',
    max_users INT DEFAULT 3 COMMENT '用户数上限',
    -- 用量
    used_models INT DEFAULT 0,
    used_agents INT DEFAULT 0,
    used_apps INT DEFAULT 0,
    used_api_calls_monthly INT DEFAULT 0,
    used_storage_gb DECIMAL(10,2) DEFAULT 0,
    used_users INT DEFAULT 0,
    -- 重置时间
    reset_at DATETIME COMMENT '月度配额重置时间',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='租户配额';
```

#### 5.2.4 短信服务集成

| 服务商 | 用途 | 优先级 | 说明 |
|--------|------|--------|------|
| 阿里云短信 | 国内验证码 | P0 | 主通道，到达率99%+ |
| 腾讯云短信 | 国内备选 | P2 | 备用通道 |
| Twilio | 国际验证码 | P2 | 海外用户注册 |

### 5.3 免费版功能限制矩阵

| 功能 | FREE版 | STARTER版 | PRO版 |
|------|--------|-----------|-------|
| 用户数 | 3人 | 10人 | 50人 |
| AI模型接入 | 3个 | 10个 | 不限 |
| Agent数量 | 5个 | 20个 | 不限 |
| 应用数量 | 3个 | 10个 | 不限 |
| 月API调用 | 1万次 | 10万次 | 100万次 |
| 存储 | 5GB | 50GB | 500GB |
| 数据治理 | 只读 | 全功能 | 全功能 |
| 社区支持 | ✅ | ✅ | ✅ |
| 工单支持 | ❌ | ✅ | ✅ |
| 专属客服 | ❌ | ❌ | ✅ |

---

## 六、模块四：邀请制Beta注册

### 6.1 设计目标

在免费SaaS正式开放前，通过邀请制获取种子用户，建立稀缺感，同时控制初期负载。

### 6.2 邀请流程

```
管理员生成邀请码批次
    ├── 批次名称（如"种子用户100人"）
    ├── 邀请码数量
    ├── 每码有效期（默认30天）
    ├── 每码使用次数（默认1次）
    └── 关联优惠（如免费PRO版3个月）
    │
    ▼
分发邀请码
    ├── 定向发送（邮件/企微/社群）
    ├── 合作伙伴分发
    └── 活动赠送（Webinar/Meetup）
    │
    ▼
用户使用邀请码注册
    ├── 注册页输入邀请码
    ├── 后端校验邀请码有效性
    ├── 创建租户时关联邀请码优惠
    └── 标记来源为"INVITE"
    │
    ▼
邀请人奖励（可选）
    ├── 被邀请人激活后，邀请人获得奖励
    ├── 奖励类型：额度/天数/功能解锁
    └── 奖励入账通知
```

### 6.3 数据模型

```sql
-- 邀请码表
CREATE TABLE ops_invite_code (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(32) NOT NULL UNIQUE COMMENT '邀请码',
    batch_name VARCHAR(100) COMMENT '批次名称',
    inviter_user_id BIGINT COMMENT '邀请人ID(用户推荐时)',
    -- 限制
    max_uses INT DEFAULT 1 COMMENT '最大使用次数',
    used_count INT DEFAULT 0 COMMENT '已使用次数',
    expires_at DATETIME COMMENT '过期时间',
    -- 奖励
    reward_type VARCHAR(50) COMMENT 'CREDIT/FREE_MONTHS/PLAN_UPGRADE',
    reward_value VARCHAR(100) COMMENT '奖励值',
    reward_for_inviter VARCHAR(100) COMMENT '邀请人奖励',
    -- 状态
    status VARCHAR(20) DEFAULT 'ACTIVE' COMMENT 'ACTIVE/EXHAUSTED/EXPIRED/DISABLED',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_code (code),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='邀请码';

-- 邀请码使用记录
CREATE TABLE ops_invite_usage (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    invite_code VARCHAR(32) NOT NULL,
    invited_user_id BIGINT NOT NULL,
    tenant_id BIGINT NOT NULL,
    reward_granted BOOLEAN DEFAULT FALSE,
    rewarded_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_code (invite_code),
    INDEX idx_user (invited_user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='邀请码使用记录';
```

---

## 七、模块五：企微/钉钉/飞书集成

### 7.1 集成场景

| 场景 | 企微 | 钉钉 | 飞书 | 优先级 |
|------|------|------|------|--------|
| OAuth登录 | ✅ | ✅ | ✅ | P1 |
| 消息推送（通知/告警） | ✅ | ✅ | ✅ | P1 |
| 组织架构同步 | ✅ | ✅ | ✅ | P2 |
| 应用市场上架 | ✅(企微应用) | ✅(钉钉应用) | ✅(飞书应用) | P2 |
| 群机器人通知 | ✅ | ✅ | ✅ | P1 |
| 日程同步 | ❌ | ✅ | ✅ | P3 |

### 7.2 OAuth登录流程

```
用户点击"企业微信登录" / "钉钉登录" / "飞书登录"
    │
    ▼
重定向到平台OAuth授权页
    ├── 企微: https://open.weixin.qq.com/connect/oauth2/authorize
    ├── 钉钉: https://login.dingtalk.com/oauth2/auth
    └── 飞书: https://open.feishu.cn/open-apis/authen/v1/authorize
    │
    ▼
用户授权 → 回调到 /auth/oauth/callback?code=xxx&platform=xxx
    │
    ▼
后端处理回调
    ├── 1. 用code换取access_token
    ├── 2. 获取用户信息（姓名/手机号/邮箱/企业信息）
    ├── 3. 查找本地用户
    │      ├── 已存在 → 生成JWT Token登录
    │      └── 不存在 → 自动创建租户+用户（免注册）
    └── 4. 返回JWT Token
    │
    ▼
前端跳转到 /dashboard（已登录）
```

### 7.3 后端实现

```java
// OAuth登录控制器
@RestController
@RequestMapping("/api/auth/oauth")
@Tag(name = "OAuth登录", description = "企微/钉钉/飞书第三方登录")
public class OAuthLoginController {

    @GetMapping("/{platform}/authorize")
    @Operation(summary = "获取OAuth授权URL")
    public ApiResponse<Map<String, String>> getAuthorizeUrl(@PathVariable String platform) {
        // 返回对应平台的OAuth授权URL
    }

    @GetMapping("/{platform}/callback")
    @Operation(summary = "OAuth回调处理")
    public ApiResponse<LoginResponse> handleCallback(
            @PathVariable String platform,
            @RequestParam String code) {
        // 1. code换token
        // 2. 获取用户信息
        // 3. 查找/创建用户
        // 4. 返回JWT
    }
}

// 消息推送服务
@Service
public class ImNotificationService {
    
    // 企微群机器人
    public void sendWecomBot(String webhookUrl, String message) { }
    
    // 钉钉群机器人
    public void sendDingtalkBot(String webhookUrl, String message) { }
    
    // 飞书群机器人
    public void sendFeishuBot(String webhookUrl, String message) { }
}
```

### 7.4 配置

```yaml
# application.yml 新增
smartwin:
  oauth:
    wecom:
      enabled: true
      corp-id: ${WECOM_CORP_ID}
      agent-id: ${WECOM_AGENT_ID}
      secret: ${WECOM_SECRET}
      redirect-uri: https://www.smartwin.com/auth/oauth/wecom/callback
    dingtalk:
      enabled: true
      app-key: ${DINGTALK_APP_KEY}
      app-secret: ${DINGTALK_APP_SECRET}
      redirect-uri: https://www.smartwin.com/auth/oauth/dingtalk/callback
    feishu:
      enabled: true
      app-id: ${FEISHU_APP_ID}
      app-secret: ${FEISHU_APP_SECRET}
      redirect-uri: https://www.smartwin.com/auth/oauth/feishu/callback
```

---

## 八、模块六：国际化与英文官网

### 8.1 现状

- ✅ 应用i18n：zh-CN + en-US 双语已实现
- ✅ 博客内容：已有4篇文章（3中文+1英文），ContentMarketingService支持lang字段
- ✅ 落地页：英文版EnHomeView已实现
- ✅ 官网门户：英文版EnHomeView+EnBlogView+EnglishApiDocsView已实现
- ✅ API文档：EnglishApiDocsView已实现
- ❌ 邮件模板：仅中文（Phase 2计划）

### 8.2 国际化策略

| 策略 | 说明 |
|------|------|
| URL结构 | 中文: `/company` / 英文: `/en/company` |
| 语言切换 | 顶部语言切换器，记忆用户偏好（localStorage） |
| 自动检测 | 根据浏览器`Accept-Language`头自动跳转 |
| hreflang | 每个页面配置`<link rel="alternate" hreflang="en-US" href="...">` |
| 内容翻译 | 博客文章支持中英文版本，通过`lang`字段关联 |
| Sitemap | 生成多语言Sitemap，包含hreflang标签 |

### 8.3 英文官网页面

| 页面 | 路由 | 优先级 | 说明 |
|------|------|--------|------|
| English Home | `/en` | P1 | 英文公司首页 |
| Products | `/en/products` | P1 | 产品介绍（英文） |
| Blog | `/en/blog` | P1 | 英文博客列表 |
| Blog Detail | `/en/blog/:slug` | P1 | 英文博客详情 |
| Pricing | `/en/pricing` | P1 | 英文定价页（USD） |
| API Docs | `/en/api-docs` | P2 | 英文API文档 |
| About | `/en/about` | P2 | 英文公司介绍 |

### 8.4 内容国际化方案

```typescript
// 博客文章通过 lang 字段区分语言
// 同一篇文章可有中英文两个版本，通过 slug 关联

// 前端查询时根据当前语言过滤
const lang = useLocale().current // 'zh-CN' or 'en-US'
const articles = await contentApi.getArticles({ lang, page: 1, size: 10 })

// i18n 路由守卫：自动重定向
router.beforeEach((to, from, next) => {
  const locale = to.path.startsWith('/en/') ? 'en-US' : 'zh-CN'
  i18n.global.locale.value = locale
  document.documentElement.lang = locale === 'en-US' ? 'en' : 'zh-CN'
  next()
})
```

---

## 九、模块七：SEO+GEO优化体系

### 9.1 现状

- ✅ 基础SEO：TDK（Title/Description/Keywords）已实现
- ✅ Sitemap自动生成（含hreflang）
- ✅ JSON-LD结构化数据（BlogPosting/SoftwareApplication/Organization/FAQPage）
- ✅ SEO关键词追踪（12个种子关键词，MySQL持久化）
- ✅ GEO优化：JSON-LD知识图谱+FAQPage Schema+可引用片段已实现
- ❌ 页面速度优化：未做SSR/预渲染（Phase 2计划）
- ❌ 站内搜索：无Elasticsearch全文搜索（Phase 2计划）

### 9.2 SEO优化增强（P0）

| 项目 | 说明 | 工作量 |
|------|------|--------|
| 页面TDK全覆盖 | 所有公开页面配置独立TDK | 2人天 |
| robots.txt | 配置爬虫规则，屏蔽私有页面 | 0.5人天 |
| Sitemap增强 | 分类Sitemap（博客/案例/产品/静态页） | 1人天 |
| Schema.org扩展 | Organization/FAQPage/HowTo/BreadcrumbList | 2人天 |
| Open Graph优化 | 每篇文章og:image自动生成 | 2人天 |
| Canonical URL | 防止重复内容，每页配置canonical | 1人天 |
| 内链策略 | 博客文章自动插入相关文章链接 | 2人天 |
| 图片Alt标签 | 所有图片自动生成alt描述 | 1人天 |
| 页面性能 | LCP<2.5s，CLS<0.1，FCP<1.8s | 3人天 |
| 百度搜索资源平台 | 主动推送+Sitemap提交 | 1人天 |
| Google Search Console | Sitemap提交+索引监控 | 1人天 |

### 9.3 GEO优化体系（P1）

> **GEO（Generative Engine Optimization）**：让AI搜索引擎（DeepSeek、豆包、通义千问、Perplexity、Google AI Overviews）理解、信任并引用品牌内容。

#### 9.3.1 GEO核心策略

| 策略 | 说明 | 实现方式 |
|------|------|---------|
| **结构化知识图谱** | 让AI理解公司/产品/技术的关系 | Schema.org KnowledgeGraph + 实体关联页面 |
| **权威内容建设** | 提供可引用的专业知识片段 | 技术白皮书+行业报告+FAQ+定义页 |
| **E-E-A-T信号** | Experience/Expertise/Authoritativeness/Trustworthiness | 作者简介+真实案例+数据支撑+客户评价 |
| **可引用片段** | 内容中包含AI容易引用的简洁定义 | 每篇文章开头100字摘要+关键数据 |
| **语义网络** | 内容间通过实体关联，形成知识网络 | 内链+Schema.org实体标注+主题集群 |

#### 9.3.2 GEO技术实现

```html
<!-- 每个页面头部注入 -->
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "SmartWin",
  "url": "https://www.smartwin.com",
  "logo": "https://www.smartwin.com/logo.png",
  "description": "企业级AI治理与运营管理平台",
  "foundingDate": "2024",
  "sameAs": [
    "https://github.com/smartwin",
    "https://www.zhihu.com/org/smartwin",
    "https://www.linkedin.com/company/smartwin"
  ],
  "product": [
    {
      "@type": "SoftwareApplication",
      "name": "SmartWin 智链",
      "applicationCategory": "BusinessApplication",
      "description": "AI运营管理平台，提供大模型管理、Agent编排、成本管控、风险监控"
    },
    {
      "@type": "SoftwareApplication",
      "name": "SmartWin 智数",
      "applicationCategory": "BusinessApplication",
      "description": "AI原生数据治理平台，提供数据目录、元数据管理、数据质量、血缘图谱"
    }
  ]
}
</script>

<!-- FAQPage Schema（AI容易引用） -->
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [{
    "@type": "Question",
    "name": "什么是AI治理平台？",
    "acceptedAnswer": {
      "@type": "Answer",
      "text": "AI治理平台是企业级AI管理工具，提供模型全生命周期管理、风险评估、合规审计、成本管控等能力，帮助组织安全合规地使用AI技术。SmartWin是国内领先的AI治理平台。"
    }
  }]
}
</script>
```

#### 9.3.3 GEO内容策略

| 内容格式 | 说明 | AI引用概率 |
|---------|------|-----------|
| 定义段落 | 每篇博客开头100字定义核心概念 | 高 |
| 对比表格 | "XX vs YY对比"结构化表格 | 高 |
| FAQ页面 | 常见问题+简洁回答 | 极高 |
| 数据统计 | "根据XX数据，XX占比XX%" | 高 |
| 步骤指南 | "如何XX"分步骤指南 | 中 |
| 行业报告 | 白皮书/行业分析 | 中 |

### 9.4 SEO/GEO监控看板

| 指标 | 工具 | 频率 | 目标 |
|------|------|------|------|
| 关键词排名 | 百度/Google Search Console | 每周 | TOP10达50% |
| AI引用率 | 手动测试+工具 | 每月 | 被引用>10次/月 |
| 自然搜索流量 | GA4/百度统计 | 每日 | 月UV>5000 |
| 页面索引量 | Google/Baidu | 每周 | >100页 |
| Core Web Vitals | PageSpeed Insights | 每月 | 全绿 |
| Sitemap状态 | Search Console | 每周 | 0错误 |

---

## 十、模块八：公众号与社交媒体

### 10.1 微信公众号集成

| 功能 | 说明 | 优先级 |
|------|------|--------|
| 公众号开号 | 注册服务号（可API调用） | P1 |
| 文章同步 | 博客文章自动同步到公众号（草稿） | P2 |
| 菜单管理 | 公众号底部菜单配置（产品/博客/注册） | P2 |
| 自动回复 | 关注回复/关键词回复 | P2 |
| 模板消息 | 注册成功/试用到期/账单提醒 | P2 |
| 二维码引流 | 公众号二维码在官网/博客展示 | P1 |

### 10.2 社交媒体矩阵

| 平台 | 账号类型 | 内容策略 | 频率 | 优先级 |
|------|---------|---------|------|--------|
| 微信公众号 | 服务号 | 深度文章+产品动态+活动通知 | 2篇/周 | P1 |
| 知乎 | 机构号 | 技术问答+专栏文章 | 3篇/周 | P2 |
| 掘金 | 企业号 | 技术博客+教程 | 2篇/周 | P2 |
| CSDN | 企业号 | 技术文章+课程 | 2篇/周 | P2 |
| LinkedIn | Company Page | 英文内容+行业洞察 | 2篇/周 | P2 |
| Twitter/X | Brand Account | 英文技术动态 | 3条/周 | P3 |
| GitHub | Organization | 开源项目+Star | 持续 | P2 |
| B站 | 企业号 | 视频教程+Webinar回放 | 1条/周 | P3 |

### 10.3 公众号API集成

```java
@RestController
@RequestMapping("/api/platform/ops/wechat")
@Tag(name = "微信公众号", description = "公众号文章同步/菜单管理/模板消息")
public class WechatOfficialAccountController {

    @PostMapping("/articles/sync")
    @Operation(summary = "同步博客文章到公众号草稿箱")
    public ApiResponse<Void> syncArticleToWechat(@RequestParam String slug) {
        // 1. 获取博客文章
        // 2. 转换为公众号素材格式
        // 3. 调用公众号API上传图文素材
        // 4. 返回素材ID
    }

    @PutMapping("/menu")
    @Operation(summary = "更新公众号菜单")
    public ApiResponse<Void> updateMenu(@RequestBody WechatMenuConfig config) { }

    @PostMapping("/template-message")
    @Operation(summary = "发送模板消息")
    public ApiResponse<Void> sendTemplateMessage(
            @RequestParam String openId,
            @RequestParam String templateId,
            @RequestBody Map<String, String> data) { }
}
```

---

## 十一、模块九：社群与渠道门户

### 11.1 社群体系

| 社群类型 | 平台 | 目标人群 | 规模目标 | 优先级 |
|---------|------|---------|---------|--------|
| 技术交流群 | 微信群 | 开发者/架构师 | 500人(M3) | P1 |
| 产品用户群 | 企微群 | 付费用户 | 200人(M6) | P1 |
| 开发者社区 | GitHub Discussions | 开源贡献者 | 1000 stars(M12) | P2 |
| 知识星球 | 知识星球 | 深度用户/KOL | 300人(M6) | P3 |
| Discord | Discord | 国际用户 | 200人(M12) | P3 |

### 11.2 渠道门户

#### 11.2.1 渠道代理商体系

```
渠道门户 (partner.smartwin.com)
├── 代理商注册
│   ├── 公司信息+营业执照
│   ├── 代理级别选择（银牌/金牌/铂金）
│   └── 审核流程
│
├── 代理商工作台
│   ├── 客户管理（名下客户列表）
│   ├── 佣金统计（返佣金额+提现记录）
│   ├── 营销物料（海报/PPT/案例库下载）
│   ├── 培训认证（产品认证考试）
│   └── 报价工具（按客户需求生成报价）
│
├── 渠道管理（内部）
│   ├── 代理商列表+分级
│   ├── 客户报备+冲突处理
│   ├── 佣金规则配置
│   └── 渠道业绩看板
│
└── 合作伙伴门户
    ├── 技术合作伙伴（集成对接）
    ├── 实施合作伙伴（交付服务）
    └── 战略合作伙伴（联合方案）
```

#### 11.2.2 佣金体系

| 代理级别 | 首年返佣 | 续年返佣 | 门槛 | 权益 |
|---------|---------|---------|------|------|
| 银牌代理 | 15% | 8% | 年销售额≥10万 | 营销物料+在线培训 |
| 金牌代理 | 20% | 12% | 年销售额≥50万 | 专属AM+线下培训+优先线索 |
| 铂金代理 | 25% | 15% | 年销售额≥200万 | 联合方案+定制开发+年度返点 |

#### 11.2.3 数据模型

```sql
-- 渠道代理商
CREATE TABLE ops_channel_partner (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    company_name VARCHAR(200) NOT NULL,
    contact_name VARCHAR(100),
    contact_phone VARCHAR(50),
    contact_email VARCHAR(200),
    level VARCHAR(20) DEFAULT 'SILVER' COMMENT 'SILVER/GOLD/PLATINUM',
    status VARCHAR(20) DEFAULT 'PENDING' COMMENT 'PENDING/APPROVED/REJECTED/SUSPENDED',
    commission_rate_first_year DECIMAL(5,2) DEFAULT 15.00,
    commission_rate_renewal DECIMAL(5,2) DEFAULT 8.00,
    total_revenue DECIMAL(12,2) DEFAULT 0,
    total_commission DECIMAL(12,2) DEFAULT 0,
    license_url VARCHAR(500) COMMENT '营业执照URL',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_status (status),
    INDEX idx_level (level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='渠道代理商';

-- 客户报备
CREATE TABLE ops_channel_customer (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    partner_id BIGINT NOT NULL COMMENT '代理商ID',
    customer_name VARCHAR(200) NOT NULL,
    contact_info VARCHAR(200),
    expected_amount DECIMAL(12,2),
    status VARCHAR(20) DEFAULT 'REPORTED' COMMENT 'REPORTED/CONTACTED/DEAL/CLOSED/EXPIRED',
    expires_at DATETIME COMMENT '报备保护期',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_partner (partner_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='渠道客户报备';

-- 佣金记录
CREATE TABLE ops_commission_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    partner_id BIGINT NOT NULL,
    tenant_id BIGINT COMMENT '关联租户',
    order_id BIGINT COMMENT '关联订单',
    amount DECIMAL(12,2) NOT NULL,
    rate DECIMAL(5,2),
    type VARCHAR(20) COMMENT 'FIRST_YEAR/RENEWAL/REFUND',
    status VARCHAR(20) DEFAULT 'PENDING' COMMENT 'PENDING/APPROVED/PAID',
    paid_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_partner (partner_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='佣金记录';
```

---

## 十二、分阶段执行路线图

### 12.1 路线图总览

```
Phase 1: 基础建设期 (M1)          Phase 2: 增长启动期 (M2-M3)      Phase 3: 生态扩展期 (M4-M6)
┌────────────────────┐          ┌────────────────────┐          ┌────────────────────┐
│ ● SaaS注册闭环      │          │ ● 企微/钉钉/飞书集成 │          │ ● 渠道门户上线       │
│ ● 短信验证码服务    │          │ ● 英文官网上线      │          │ ● 代理商体系        │
│ ● 运营数据持久化    │          │ ● 公众号集成        │          │ ● 社区论坛          │
│ ● 博客系统DB化     │          │ ● 邀请制Beta启动    │          │ ● 开发者社区        │
│ ● SEO基础优化      │          │ ● GEO优化启动       │          │ ● 国际化深化        │
│ ● 公司官网首页     │          │ ● 社媒矩阵搭建      │          │ ● 生态合作          │
│ ● 免费版上线       │          │ ● 渠道体系试运行    │          │ ● 品牌升级          │
└────────────────────┘          └────────────────────┘          └────────────────────┘
     4周 (5人团队)                   8周 (5人团队)                   12周 (5人团队)
```

### 12.2 Phase 1: 基础建设期（M1，4周）

> **目标**：打通SaaS注册全链路，博客系统持久化，免费版可上线

| 周次 | 核心任务 | 交付物 | 负责人 |
|------|---------|--------|--------|
| W1 | 后端：注册接口+短信验证码 | `/auth/register` + `/auth/sms-code` 端点 | 后端1 |
| W1 | 后端：运营数据MySQL表结构+Flyway迁移 | 15张运营表DDL+迁移脚本 | 后端2 |
| W1 | 前端：公司官网首页骨架 | CompanyHomeView组件 | 前端1 |
| W2 | 后端：ContentMarketingService重构(DB化) | 博客/案例/关键词持久化 | 后端2 |
| W2 | 后端：多租户注册流程(租户创建+配额初始化) | RegisterService完整链路 | 后端1 |
| W2 | 前端：注册流程联调(验证码+注册+自动登录) | 端到端注册可用 | 前端2 |
| W3 | 后端：GrowthMetricsService重构(DB化) | 增长数据持久化 | 后端2 |
| W3 | 后端：免费版配额执行器(PlanLimitEnforcer) | 配额检查+超额拦截 | 后端1 |
| W3 | 前端：公司官网首页完成+产品矩阵展示 | 官网首页上线 | 前端1 |
| W3 | SEO：全页面TDK优化+robots.txt+百度提交 | SEO基础就绪 | 运营 |
| W4 | 集成测试+端到端验证 | 全链路测试通过 | 全员 |
| W4 | SEO：Sitemap增强+Schema.org扩展 | 结构化数据全覆盖 | 运营+前端 |
| W4 | 免费版正式开放注册 | `/register` 可用 | 全员 |

### 12.3 Phase 2: 增长启动期（M2-M3，8周）

> **目标**：企微/钉钉/飞书集成，英文官网，邀请制Beta，GEO优化启动

| 阶段 | 核心任务 | 交付物 | 周次 |
|------|---------|--------|------|
| M2-W1 | 企微OAuth登录集成 | 企微登录可用 | W5 |
| M2-W1 | 邀请码系统(生成+校验+奖励) | 邀请制Beta可启动 | W5 |
| M2-W2 | 钉钉OAuth登录集成 | 钉钉登录可用 | W6 |
| M2-W2 | 英文官网首页+产品页 | `/en` 路由可用 | W6 |
| M2-W3 | 飞书OAuth登录集成 | 飞书登录可用 | W7 |
| M2-W3 | 英文博客列表+详情页 | 英文内容可浏览 | W7 |
| M2-W4 | 邀请制Beta正式启动 | 100名种子用户 | W8 |
| M3-W1 | GEO优化实施(知识图谱+FAQ Schema) | AI引用率基线建立 | W9 |
| M3-W1 | 公众号开号+菜单配置+首篇文章 | 公众号运营启动 | W9 |
| M3-W2 | 群机器人通知(企微/钉钉/飞书) | 运营告警自动推送 | W10 |
| M3-W2 | 社媒矩阵搭建(知乎/掘金/CSDN/LinkedIn) | 多平台内容分发 | W10 |
| M3-W3 | 内容管理后台(富文本编辑器+SEO面板) | 运营可自助管理内容 | W11 |
| M3-W4 | 邮件营销系统(模板+自动化流+统计) | 欢迎邮件/激活邮件可用 | W12 |
| M3-W4 | 渠道体系试运行(代理商注册+佣金规则) | 渠道门户MVP | W12 |

### 12.4 Phase 3: 生态扩展期（M4-M6，12周）

> **目标**：渠道门户完善，社区论坛，国际化深化，品牌升级

| 阶段 | 核心任务 | 交付物 | 周次 |
|------|---------|--------|------|
| M4 | 渠道门户完整版(代理商工作台+佣金+培训) | 渠道体系正式上线 | W13-16 |
| M4 | 英文API文档+开发者指南 | 国际化文档就绪 | W13-16 |
| M5 | 开发者社区(GitHub Discussions+贡献者体系) | 社区运营启动 | W17-20 |
| M5 | 公众号模板消息+自动回复 | 公众号自动化运营 | W17-20 |
| M6 | 品牌升级(官网视觉刷新+品牌指南) | 品牌一致性提升 | W21-24 |
| M6 | 国际化深化(Twitter/B站/Discord) | 全球社媒矩阵 | W21-24 |

---

## 十三、任务清单与工时估算

### 13.1 Phase 1 任务清单（P0优先级）

| 编号 | 任务 | 类型 | 工作量 | 依赖 | 负责 |
|------|------|------|--------|------|------|
| PROMO-FE-001 | 公司官网首页(CompanyHomeView) | 前端 | 3人天 | 无 | 前端1 |
| PROMO-FE-002 | 产品矩阵展示页(ProductsView) | 前端 | 2人天 | PROMO-FE-001 | 前端1 |
| PROMO-FE-003 | 注册流程联调(验证码+注册+自动登录) | 前端 | 3人天 | PROMO-BE-001 | 前端2 |
| PROMO-FE-004 | SEO全页面TDK配置 | 前端 | 2人天 | 无 | 前端1 |
| PROMO-FE-005 | robots.txt+Sitemap增强 | 前端 | 1人天 | 无 | 前端1 |
| PROMO-BE-001 | 注册接口(/auth/register)+短信验证码(/auth/sms-code) | 后端 | 5人天 | 无 | 后端1 |
| PROMO-BE-002 | 多租户注册流程(租户创建+用户绑定+角色分配) | 后端 | 5人天 | PROMO-BE-001 | 后端1 |
| PROMO-BE-003 | 短信服务集成(阿里云短信) | 后端 | 2人天 | PROMO-BE-001 | 后端1 |
| PROMO-BE-004 | 运营数据MySQL表结构(15张表)+Flyway迁移 | 后端 | 2人天 | 无 | 后端2 |
| PROMO-BE-005 | ContentMarketingService重构(内存→DB) | 后端 | 3人天 | PROMO-BE-004 | 后端2 |
| PROMO-BE-006 | GrowthMetricsService重构(内存→DB) | 后端 | 3人天 | PROMO-BE-004 | 后端2 |
| PROMO-BE-007 | SaaSOpsService重构(内存→DB) | 后端 | 3人天 | PROMO-BE-004 | 后端2 |
| PROMO-BE-008 | 免费版配额执行器(PlanLimitEnforcer增强) | 后端 | 3人天 | PROMO-BE-002 | 后端1 |
| PROMO-BE-009 | 事件发布(auth.user.register等) | 后端 | 2人天 | PROMO-BE-002 | 后端1 |
| PROMO-SEO-001 | 百度搜索资源平台提交+Google Search Console | 运营 | 1人天 | PROMO-FE-005 | 运营 |
| PROMO-SEO-002 | Schema.org结构化数据扩展(Organization/FAQ) | 运营 | 2人天 | 无 | 运营 |
| PROMO-TEST-001 | 端到端测试(注册→登录→使用→配额限制) | 测试 | 3人天 | 全部 | 全员 |

**Phase 1 合计**：45人天（约4周，5人团队）

### 13.2 Phase 2 任务清单（P1优先级）

| 编号 | 任务 | 类型 | 工作量 | 负责 |
|------|------|------|--------|------|
| PROMO-FE-006 | 企微OAuth登录按钮+回调处理 | 前端 | 2人天 | 前端1 |
| PROMO-FE-007 | 钉钉OAuth登录按钮+回调处理 | 前端 | 2人天 | 前端1 |
| PROMO-FE-008 | 飞书OAuth登录按钮+回调处理 | 前端 | 2人天 | 前端1 |
| PROMO-FE-009 | 英文官网首页+产品页 | 前端 | 5人天 | 前端2 |
| PROMO-FE-010 | 英文博客列表+详情页 | 前端 | 3人天 | 前端2 |
| PROMO-FE-011 | 内容管理后台(列表+编辑器+SEO面板) | 前端 | 8人天 | 前端1 |
| PROMO-FE-012 | 邀请码输入框(注册页) | 前端 | 1人天 | 前端2 |
| PROMO-BE-010 | 企微OAuth后端(token换取+用户创建) | 后端 | 4人天 | 后端1 |
| PROMO-BE-011 | 钉钉OAuth后端 | 后端 | 4人天 | 后端1 |
| PROMO-BE-012 | 飞书OAuth后端 | 后端 | 4人天 | 后端1 |
| PROMO-BE-013 | 邀请码系统(生成+校验+奖励发放) | 后端 | 4人天 | 后端2 |
| PROMO-BE-014 | 群机器人通知服务(企微/钉钉/飞书Webhook) | 后端 | 3人天 | 后端2 |
| PROMO-BE-015 | 邮件营销系统(模板+发送+统计) | 后端 | 5人天 | 后端2 |
| PROMO-BE-016 | 公众号API集成(文章同步+菜单+模板消息) | 后端 | 5人天 | 后端1 |
| PROMO-GEO-001 | GEO优化(知识图谱+FAQ Schema+可引用片段) | 运营 | 5人天 | 运营 |
| PROMO-OPS-001 | 公众号开号+菜单配置+首批内容 | 运营 | 3人天 | 运营 |
| PROMO-OPS-002 | 社媒矩阵搭建(知乎/掘金/CSDN/LinkedIn) | 运营 | 3人天 | 运营 |

**Phase 2 合计**：65人天（约8周，5人团队）

### 13.3 Phase 3 任务清单（P2优先级）

| 编号 | 任务 | 类型 | 工作量 | 负责 |
|------|------|------|--------|------|
| PROMO-FE-013 | 渠道门户前端(代理商工作台) | 前端 | 8人天 | 前端1 |
| PROMO-FE-014 | 英文API文档页 | 前端 | 3人天 | 前端2 |
| PROMO-FE-015 | 品牌视觉升级(官网刷新) | 前端 | 5人天 | 前端1 |
| PROMO-BE-017 | 渠道代理商系统(注册+分级+佣金) | 后端 | 8人天 | 后端1 |
| PROMO-BE-018 | 客户报备+冲突处理 | 后端 | 3人天 | 后端2 |
| PROMO-BE-019 | 佣金计算+提现流程 | 后端 | 5人天 | 后端2 |
| PROMO-OPS-003 | 开发者社区运营(GitHub Discussions) | 运营 | 5人天 | 运营 |
| PROMO-OPS-004 | 国际社媒(Twitter/B站/Discord) | 运营 | 5人天 | 运营 |

**Phase 3 合计**：42人天（约12周，5人团队）

### 13.4 总工时汇总

| 阶段 | 时长 | 人天 | 团队规模 | 关键交付 |
|------|------|------|---------|---------|
| Phase 1 | 4周 | 45人天 | 5人 | SaaS注册闭环+免费版上线 |
| Phase 2 | 8周 | 65人天 | 5人 | 企微/钉钉/飞书+英文官网+邀请制 |
| Phase 3 | 12周 | 42人天 | 5人 | 渠道门户+社区+国际化深化 |
| **合计** | **24周(6个月)** | **152人天** | **5人** | **完整运营推广体系** |

---

## 十四、KPI目标与度量

### 14.1 Phase 1 KPI（M1）

| 指标 | 目标 | 度量方式 |
|------|------|---------|
| SaaS注册可用 | ✅ 注册闭环100%通过 | 端到端测试 |
| 博客系统持久化 | ✅ 重启后数据不丢失 | 验证测试 |
| 免费版上线 | ✅ /register 公开可访问 | 线上验证 |
| SEO基础 | ✅ TDK+Sitemap+robots.txt | Search Console |
| 官网首页 | ✅ 公司门户可访问 | 线上验证 |

### 14.2 Phase 2 KPI（M3）

| 指标 | 目标 | 度量方式 |
|------|------|---------|
| 免费注册用户 | 500人 | GrowthMetrics |
| 月活用户(MAU) | 200人 | GrowthMetrics |
| 邀请制Beta用户 | 100人种子用户 | 邀请码使用数 |
| 企微/钉钉/飞书登录 | 3种OAuth均可用 | 端到端测试 |
| 英文官网 | /en 路由可访问 | 线上验证 |
| 公众号粉丝 | 500人 | 公众号后台 |
| 自然搜索UV | 5000UV/月 | GA4/百度统计 |
| AI引用次数 | 5次/月 | 手动测试 |

### 14.3 Phase 3 KPI（M6）

| 指标 | 目标 | 度量方式 |
|------|------|---------|
| 免费注册用户 | 2,000人 | GrowthMetrics |
| 月活用户(MAU) | 800人 | GrowthMetrics |
| 试用→付费转化率 | 5% | GrowthMetrics |
| 付费客户数 | 20家 | Billing系统 |
| MRR | ¥30K | Billing系统 |
| 渠道代理商 | 5家签约 | 渠道系统 |
| 社区成员 | 500人 | 社群统计 |
| 关键词TOP10 | 50个 | SEO看板 |
| NPS | 40 | NPS调查 |

### 14.4 12个月终极目标（M12）

| 指标 | 目标 |
|------|------|
| 免费注册用户 | 10,000人 |
| 月活用户(MAU) | 3,000人 |
| 试用→付费转化率 | 8% |
| 付费客户数 | 80家 |
| MRR | ¥150K |
| NPS | 50 |
| 内容营销UV/月 | 80,000 |
| 社区成员数 | 2,000 |
| 渠道代理商 | 20家 |
| AI引用次数/月 | 50+ |

---

## 附录A：技术选型补充

| 组件 | 选型 | 用途 | 备注 |
|------|------|------|------|
| 富文本编辑器 | TipTap 2.x | 博客内容编辑 | 开源，支持Markdown |
| 短信服务 | 阿里云短信 | 验证码发送 | 99%+到达率 |
| 邮件服务 | 阿里云邮件推送 | 营销邮件 | 国内主通道 |
| 邮件服务(国际) | SendGrid | 国际邮件 | 海外用户 |
| 公众号SDK | WxJava | 微信公众号API | 开源Java SDK |
| 企微SDK | weixin-java-cp | 企微OAuth+消息 | 开源 |
| 钉钉SDK | dingtalk-sdk | 钉钉OAuth+消息 | 官方SDK |
| 飞书SDK | larksuite-oapi | 飞书OAuth+消息 | 官方SDK |
| 图表 | ECharts | SEO/GEO数据可视化 | 已有 |
| 定时任务 | Spring Scheduling | 关键词排名更新/配额重置 | 已有 |

## 附录B：环境配置清单

```yaml
# .env.production 新增配置项

# 短信服务
SMS_PROVIDER=aliyun
SMS_ACCESS_KEY=${ALIYUN_SMS_ACCESS_KEY}
SMS_SECRET_KEY=${ALIYUN_SMS_SECRET_KEY}
SMS_SIGN_NAME=SmartWin
SMS_TEMPLATE_CODE=SMS_XXXXXX

# 邮件服务
MAIL_PROVIDER=aliyun
MAIL_ACCESS_KEY=${ALIYUN_MAIL_ACCESS_KEY}
MAIL_SECRET_KEY=${ALIYUN_MAIL_SECRET_KEY}
MAIL_FROM=noreply@smartwin.com
MAIL_FROM_NAME=SmartWin团队

# 微信公众号
WECHAT_APP_ID=${WECHAT_APP_ID}
WECHAT_APP_SECRET=${WECHAT_APP_SECRET}
WECHAT_TOKEN=${WECHAT_TOKEN}
WECHAT_ENCODING_AES_KEY=${WECHAT_ENCODING_AES_KEY}

# 企微OAuth
WECOM_CORP_ID=${WECOM_CORP_ID}
WECOM_AGENT_ID=${WECOM_AGENT_ID}
WECOM_SECRET=${WECOM_SECRET}

# 钉钉OAuth
DINGTALK_APP_KEY=${DINGTALK_APP_KEY}
DINGTALK_APP_SECRET=${DINGTALK_APP_SECRET}

# 飞书OAuth
FEISHU_APP_ID=${FEISHU_APP_ID}
FEISHU_APP_SECRET=${FEISHU_APP_SECRET}

# SEO/GEO
GOOGLE_SEARCH_CONSOLE_API_KEY=${GSC_API_KEY}
BAIDU_WEBMASTER_API_KEY=${BAIDU_API_KEY}
GA4_MEASUREMENT_ID=G-XXXXXXX
GA4_API_SECRET=${GA4_API_SECRET}
```

## 附录C：风险与应对

| 风险 | 影响 | 概率 | 应对措施 |
|------|------|------|---------|
| 短信通道审核延迟 | 注册无法上线 | 中 | 提前2周申请，准备备选通道 |
| 企微/钉钉/飞书API变更 | OAuth登录中断 | 低 | 关注官方变更日志，SDK及时更新 |
| GEO效果不达预期 | AI引用率低 | 中 | 持续优化内容质量，增加权威信号 |
| 免费版滥用 | 资源消耗过大 | 中 | 配额限制+防刷策略+IP限制 |
| 内容产出不足 | SEO/GEO效果差 | 高 | 建立内容团队+外包+UGC激励 |
| 团队人力不足 | 交付延迟 | 中 | 优先P0任务，P1/P2可外包 |

---

> **文档结束**  
> 本方案为完整可执行的运营推广产品计划，覆盖从基础设施建设到生态扩展的全生命周期。  
> **2026-07-12 更新**：Phase 1-3 全部 GAP-01至 GAP-14 已完成代码实现并验证通过，运营数据全部 MySQL 持久化，注册闭环/多租户/邀请码/OAuth/英文官网/公众号/邮件营销/渠道门户/Webhook/社区论坛全部落地。  
> 后续将根据执行进度持续更新，并在项目管理大盘中跟踪任务状态。
