# 前端架构设计说明书

## 文档控制

| 信息项 | 内容 |
|--------|------|
| **文档编号** | DES-06 |
| **文档版本** | V1.0 |
| **创建日期** | 2026-07-08 |
| **最后修订** | 2026-07-08 |
| **文档状态** | 正式发布 |
| **文档负责人** | 前端Lead |
| **审批人** | 架构师 |

---

## 1. 前端架构概述

### 1.1 设计原则

| 原则 | 说明 |
|------|------|
| 双前端共享底座 | 智链前端与智数前端共享 `shared-components` 包 |
| 类型安全 | TypeScript全覆盖，严格模式 |
| 组件化 | 通用组件抽离至共享包，业务组件内聚 |
| 国际化 | 中英双语，vue-i18n，模块化locale文件 |
| 主题化 | CSS变量驱动，亮/暗模式无缝切换 |
| 响应式 | 移动端适配，断点设计 |

### 1.2 技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| Vue 3 | 3.5+ | 响应式前端框架 |
| TypeScript | 5.7+ | 类型安全 |
| Vite | 6.0+ | 构建工具/开发服务器 |
| Pinia | 3.0+ | 状态管理 |
| Vue Router | 4.5+ | SPA路由 |
| VueUse | 12.0+ | 组合式工具函数 |
| ECharts | 5.6 | 数据可视化图表 |
| vue-i18n | 10.0+ | 国际化 |
| Axios | 1.7+ | HTTP客户端 |
| Tailwind CSS | 4.0+ | 原子化CSS（按需） |

---

## 2. Monorepo前端结构

### 2.1 目录结构

```
CodeProject/WebDesign/
├── shared-components/          # 共享前端包
│   ├── package.json            # 包名: @smartwin/shared
│   └── src/
│       ├── index.ts            # 统一导出
│       ├── components/         # 通用组件
│       │   ├── LangSwitcher.vue
│       │   └── ThemeSwitcher.vue
│       ├── i18n/               # 国际化
│       │   ├── composables/
│       │   │   └── useLocale.ts
│       │   ├── locales/
│       │   │   ├── zh-CN/      # 中文
│       │   │   │   ├── common.ts
│       │   │   │   ├── smartchain.ts
│       │   │   │   └── smartdata.ts
│       │   │   └── en-US/      # 英文
│       │   │       ├── common.ts
│       │   │       ├── smartchain.ts
│       │   │       └── smartdata.ts
│       │   └── stores/
│       │       └── locale.ts
│       └── theme/              # 主题系统
│           ├── composables/
│           │   ├── useTheme.ts
│           │   └── useEchartsTheme.ts
│           ├── stores/
│           │   └── theme.ts
│           └── themes/
│               ├── light.css   # 亮色主题
│               ├── dark.css    # 暗色主题
│               └── brand/      # 品牌主题
│
├── smartchain/smartchain-frontend/   # 智链前端
│   ├── package.json            # 包名: @smartwin/intelchain-frontend
│   └── src/
│       ├── App.vue
│       ├── main.ts
│       ├── api/                # API调用层
│       ├── components/         # 业务组件
│       ├── composables/        # 组合式函数
│       ├── layouts/            # 布局组件
│       ├── router/             # 路由配置
│       ├── stores/             # Pinia状态
│       ├── styles/             # 全局样式
│       ├── types/              # 类型定义
│       ├── utils/              # 工具函数
│       └── views/              # 页面视图
│
└── smartdata/smartdata-frontend/     # 智数前端
    ├── package.json            # 包名: @smartwin/smartdata-frontend
    └── src/
        └── (同上结构)
```

### 2.2 Workspace配置

```json
// 根package.json
{
  "name": "smartwin-platform",
  "workspaces": [
    "shared-components",
    "smartchain/smartchain-frontend",
    "smartdata/smartdata-frontend"
  ]
}
```

---

## 3. 共享组件库设计

### 3.1 通用组件清单

| 组件 | 说明 | 状态 |
|------|------|:----:|
| AppLayout | 主布局（Header+Sidebar+Content） | 📋 计划 |
| BaseTable | 基础表格（分页+排序+筛选） | 📋 计划 |
| BaseForm | 基础表单（校验+布局） | 📋 计划 |
| Pagination | 分页组件 | 📋 计划 |
| SearchBar | 搜索栏 | 📋 计划 |
| StatCard | 统计卡片 | 📋 计划 |
| StatusBadge | 状态徽章 | 📋 计划 |
| ConfirmDialog | 确认对话框 | 📋 计划 |
| EmptyState | 空状态 | 📋 计划 |
| SkeletonLoader | 骨架屏加载 | 📋 计划 |
| ThemeSwitcher | 主题切换 | ✅ 已实现 |
| LangSwitcher | 语言切换 | ✅ 已实现 |
| DateTimePicker | 日期时间选择器 | 📋 计划 |
| FileUploader | 文件上传 | 📋 计划 |

### 3.2 共享包导出

```typescript
// shared-components/src/index.ts
export { default as ThemeSwitcher } from './components/ThemeSwitcher.vue'
export { default as LangSwitcher } from './components/LangSwitcher.vue'
export { useTheme } from './theme/composables/useTheme'
export { useLocale } from './i18n/composables/useLocale'
export { useEchartsTheme } from './theme/composables/useEchartsTheme'
export { useThemeStore } from './theme/stores/theme'
export { useLocaleStore } from './i18n/stores/locale'
export { zhCN, enUS } from './i18n/locales'
```

---

## 4. 主题系统设计

### 4.1 CSS变量方案

```css
/* light.css */
:root {
  --color-primary: #1890ff;
  --color-primary-hover: #40a9ff;
  --color-success: #52c41a;
  --color-warning: #faad14;
  --color-error: #ff4d4f;

  --bg-base: #ffffff;
  --bg-card: #f9fafb;
  --bg-sidebar: #001529;

  --text-primary: #1f2937;
  --text-secondary: #6b7280;
  --text-disabled: #d1d5db;

  --border-color: #e5e7eb;
  --border-radius: 8px;
  --shadow-sm: 0 1px 2px rgba(0,0,0,0.05);
  --shadow-md: 0 4px 6px rgba(0,0,0,0.1);
}

/* dark.css */
:root[data-theme="dark"] {
  --color-primary: #1890ff;
  --bg-base: #1a1a2e;
  --bg-card: #16213e;
  --bg-sidebar: #0f0f23;
  --text-primary: #e2e8f0;
  --text-secondary: #94a3b8;
  --border-color: #334155;
}
```

### 4.2 主题切换

```typescript
// theme/stores/theme.ts
export const useThemeStore = defineStore('theme', () => {
  const theme = ref<'light' | 'dark'>('light')

  function toggleTheme() {
    theme.value = theme.value === 'light' ? 'dark' : 'light'
    document.documentElement.setAttribute('data-theme', theme.value)
    localStorage.setItem('theme', theme.value)
  }

  function initTheme() {
    const saved = localStorage.getItem('theme') as 'light' | 'dark' | null
    theme.value = saved || 'light'
    document.documentElement.setAttribute('data-theme', theme.value)
  }

  return { theme, toggleTheme, initTheme }
})
```

### 4.3 ECharts主题联动

```typescript
// theme/composables/useEchartsTheme.ts
export function useEchartsTheme() {
  const themeStore = useThemeStore()
  const chartTheme = computed(() =>
    themeStore.theme === 'dark' ? darkTheme : lightTheme
  )
  watch(() => themeStore.theme, () => {
    // 触发图表重绘
  })
  return { chartTheme }
}
```

---

## 5. 国际化设计

### 5.1 Locale文件结构

```
i18n/locales/
├── zh-CN/
│   ├── common.ts        # 通用文本(登录/确认/取消/搜索等)
│   ├── smartchain.ts    # 智链模块文本
│   └── smartdata.ts     # 智数模块文本
└── en-US/
    ├── common.ts
    ├── smartchain.ts
    └── smartdata.ts
```

### 5.2 Locale Store

```typescript
// i18n/stores/locale.ts
export const useLocaleStore = defineStore('locale', () => {
  const locale = ref<'zh-CN' | 'en-US'>('zh-CN')

  function setLocale(lang: 'zh-CN' | 'en-US') {
    locale.value = lang
    i18n.global.locale.value = lang
    localStorage.setItem('locale', lang)
  }

  function initLocale() {
    const saved = localStorage.getItem('locale') as 'zh-CN' | 'en-US' | null
    locale.value = saved || 'zh-CN'
  }

  return { locale, setLocale, initLocale }
})
```

> 详见 [DES-10 前端主题与国际化设计方案](./DES-10%20前端主题与国际化设计方案.md)

---

## 6. 路由设计

### 6.1 路由结构

```typescript
// 智链前端路由示例
const routes = [
  {
    path: '/login',
    component: () => import('@/views/LoginView.vue'),
    meta: { public: true }
  },
  {
    path: '/',
    component: AppLayout,
    meta: { requiresAuth: true },
    children: [
      { path: '', redirect: '/dashboard' },
      { path: 'dashboard', component: () => import('@/views/DashboardView.vue') },
      { path: 'models', component: () => import('@/views/model/ModelListView.vue') },
      { path: 'models/:id', component: () => import('@/views/model/ModelDetailView.vue') },
      { path: 'apps', component: () => import('@/views/app/AppListView.vue') },
      { path: 'agents', component: () => import('@/views/agent/AgentListView.vue') },
      { path: 'cost', component: () => import('@/views/cost/CostAnalysisView.vue') },
      { path: 'risk', component: () => import('@/views/risk/RiskMonitorView.vue') },
      { path: 'prompts', component: () => import('@/views/prompt/PromptLibraryView.vue') },
    ]
  }
]
```

### 6.2 路由守卫

```typescript
router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()
  if (to.meta.requiresAuth && !authStore.isLoggedIn) {
    next('/login')
  } else if (to.meta.public && authStore.isLoggedIn) {
    next('/')
  } else {
    next()
  }
})
```

---

## 7. API层设计

### 7.1 Axios封装

```typescript
// utils/request.ts
const request = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || '/api',
  timeout: 30000,
})

// 请求拦截器：注入JWT
request.interceptors.request.use(config => {
  const authStore = useAuthStore()
  if (authStore.token) {
    config.headers.Authorization = `Bearer ${authStore.token}`
  }
  return config
})

// 响应拦截器：统一错误处理
request.interceptors.response.use(
  response => response.data,
  error => {
    if (error.response?.status === 401) {
      useAuthStore().logout()
      router.push('/login')
    }
    ElMessage.error(error.response?.data?.message || '请求失败')
    return Promise.reject(error)
  }
)
```

### 7.2 API模块化

```typescript
// api/model.ts
export const modelApi = {
  list: (params: ModelQuery) => request.get('/intelchain/models', { params }),
  detail: (id: number) => request.get(`/intelchain/models/${id}`),
  create: (data: ModelCreateDTO) => request.post('/intelchain/models', data),
  update: (id: number, data: ModelUpdateDTO) => request.put(`/intelchain/models/${id}`, data),
  delete: (id: number) => request.delete(`/intelchain/models/${id}`),
}
```

---

## 8. 状态管理设计

### 8.1 Store清单

| Store | 归属 | 说明 |
|-------|------|------|
| useAuthStore | 各前端独立 | 用户认证状态、Token |
| useUserStore | 各前端独立 | 当前用户信息、权限 |
| useThemeStore | 共享 | 主题状态 |
| useLocaleStore | 共享 | 语言状态 |
| useAppStore | 各前端独立 | 应用全局状态（侧边栏折叠等） |

### 8.2 Auth Store设计

```typescript
export const useAuthStore = defineStore('auth', () => {
  const token = ref<string>(localStorage.getItem('token') || '')
  const refreshToken = ref<string>(localStorage.getItem('refreshToken') || '')
  const isLoggedIn = computed(() => !!token.value)

  async function login(username: string, password: string) {
    const res = await authApi.login({ username, password })
    token.value = res.accessToken
    refreshToken.value = res.refreshToken
    localStorage.setItem('token', res.accessToken)
    localStorage.setItem('refreshToken', res.refreshToken)
  }

  function logout() {
    token.value = ''
    refreshToken.value = ''
    localStorage.removeItem('token')
    localStorage.removeItem('refreshToken')
  }

  return { token, refreshToken, isLoggedIn, login, logout }
})
```

---

## 9. 智链前端页面规划（61页）

### 9.1 页面模块

| 模块 | 页面数 | 核心页面 |
|------|:------:|----------|
| 登录/注册 | 3 | 登录、注册、忘记密码 |
| 工作台 | 4 | 概览、调用趋势、成本看板、风险看板 |
| AI模型管理 | 8 | 模型列表、详情、版本、密钥、对比、注册 |
| 智能体应用 | 10 | 应用列表、详情、编排、对话、发布 |
| 智能体编排 | 6 | Agent列表、详情、工具配置、流程设计 |
| 成本管理 | 6 | 成本概览、明细、预算、告警、报表 |
| 风险评估 | 6 | 风险概览、规则、事件、报告、处置 |
| 提示词管理 | 5 | 模板库、编辑器、版本、测试 |
| 系统管理 | 9 | 用户、角色、权限、组织、字典、日志、设置 |
| 个人中心 | 4 | 资料、安全、通知、偏好 |

### 9.2 智链前端开发计划（Sprint 10-12）

| Sprint | 开发内容 | 页面数 |
|--------|----------|:------:|
| Sprint 10 | 登录+工作台+系统管理 | 16 |
| Sprint 11 | AI模型+提示词+个人中心 | 17 |
| Sprint 12 | 智能体应用+编排+成本+风险 | 28 |

---

## 10. 智数前端页面规划（47页）

| 模块 | 页面数 | 核心页面 |
|------|:------:|----------|
| 登录/注册 | 2 | 登录、注册 |
| 工作台 | 3 | 数据概览、质量看板、血缘全景 |
| 数据资产目录 | 6 | 资产列表、详情、分类、搜索、收藏 |
| 元数据管理 | 4 | 元数据列表、详情、同步、AI补全 |
| 数据质量 | 6 | 规则、任务、问题、看板 |
| 数据标准 | 4 | 标准定义、贯标映射、对标检查 |
| 数据血缘 | 3 | 血缘图谱、影响分析、节点详情 |
| 主数据管理 | 4 | 模型、记录、合并、分发 |
| 生命周期 | 4 | 策略、归档、销毁、恢复 |
| 数据服务 | 4 | API定义、调用日志、统计 |
| 系统管理 | 7 | 用户、角色、权限、日志、设置 |

---

## 11. 构建与部署

### 11.1 开发模式

```bash
# 智链前端开发
cd smartchain/smartchain-frontend
npm run dev          # Vite dev server (:5173)

# 智数前端开发
cd smartdata/smartdata-frontend
npm run dev          # Vite dev server (:5174)
```

### 11.2 生产构建

```bash
npm run build        # 输出到 dist/
# Nginx托管静态文件
```

### 11.3 Nginx配置

```nginx
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
    proxy_pass http://gateway:9000;
}
```

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-08 | 前端Lead | 初始版本发布，覆盖共享组件、主题、i18n、路由、API、状态管理 |
