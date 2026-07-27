# 智赢·智链 前端主题与国际化设计方案

## 文档控制

| 信息项 | 内容 |
|--------|------|
| **文档编号** | DES-10 |
| **文档版本** | V1.0 |
| **创建日期** | 2026-07-07 |
| **最后修订** | 2026-07-07 |
| **文档状态** | 正式发布 |
| **文档负责人** | 前端Lead |
| **关联文档** | DES-00 从零到一完整实现方案、独立可售与无缝集成架构设计方案、多模式架构设计方案补充 |

---

## 目录

- [第一章 现状审计与设计目标](#第一章-现状审计与设计目标)
- [第二章 深浅双主题设计](#第二章-深浅双主题设计)
- [第三章 国际化(i18n)设计](#第三章-国际化i18n设计)
- [第四章 后端国际化与多语言API接口](#第四章-后端国际化与多语言api接口)
- [第五章 主题与语言切换交互设计](#第五章-主题与语言切换交互设计)
- [第六章 共享模块设计](#第六章-共享模块设计)
- [第七章 微前端集成模式下的主题与i18n协同](#第七章-微前端集成模式下的主题与i18n协同)
- [第八章 实施计划与验收标准](#第八章-实施计划与验收标准)

---

# 第一章 现状审计与设计目标

## 1.1 现有文档覆盖度审计

| 文档 | 现有覆盖 | 覆盖深度 | 缺口 |
|------|---------|:--------:|------|
| 从零到一完整实现方案 | 技术栈表列 `vue-i18n 10.0+`；前端目录含 `i18n/` 文件夹；设计规范表"双主题CSS变量驱动""中英双语" | ▂ 提及层 | 无主题变量体系、无i18n文件结构、无切换持久化、无后端国际化接口 |
| 独立可售与集成架构方案 | 统一门户顶栏含"主题切换"文字 | ▁ UI层 | 仅文字提及，无交互与工程方案 |
| 业务需求说明书BRD | DC-014"多语言支持 P2" | ▁ 需求层 | 仅一行需求，无技术方案 |

## 1.2 关键缺口清单

| 编号 | 缺口项 | 严重性 |
|:----:|--------|:------:|
| G-01 | **主题变量体系**——无CSS自定义属性(CSS Variables)设计，无浅色/深色完整色板 | 🔴高 |
| G-02 | **主题切换机制**——无Pinia store、无localStorage持久化、无系统偏好跟随 | 🔴高 |
| G-03 | **i18n文件结构**——无locale目录结构、无消息键命名规范、无懒加载方案 | 🔴高 |
| G-04 | **后端国际化接口**——无多语言API、无后端消息/校验错误国际化 | 🔴高 |
| G-05 | **语言切换持久化**——无用户偏好存储(前端+后端)、无Accept-Language协商 | 🟡中 |
| G-06 | **微前端主题/i18n协同**——集成模式下子应用间主题与语言状态同步 | 🟡中 |
| G-07 | **ECharts图表主题联动**——图表配色未随主题切换 | 🟡中 |
| G-08 | **i18n扩展接口**——未预留多语言扩展端口(日/韩/法等) | 🟡中 |

## 1.3 设计目标

| 编号 | 目标 | 验收标准 |
|:----:|------|----------|
| T-01 | 支持浅色/深色双主题一键切换，全站即时生效 | 切换无刷新、无闪烁 |
| T-02 | 主题偏好持久化，跟随系统偏好(`prefers-color-scheme`) | 用户下次进入保持上次选择 |
| T-03 | 支持中英文双语，预留多语言扩展接口 | 新增语言仅需添加locale文件，零代码改动 |
| T-04 | 语言偏好持久化，前端+后端双重存储 | 用户切换语言后全站(含后端消息)生效 |
| T-05 | 集成模式(微前端)下子应用主题/语言状态同步 | 子应用跟随主应用主题/语言 |
| T-06 | ECharts图表随主题切换 | 深色模式下图表可读性良好 |
| T-07 | 后端校验错误/系统消息国际化 | API返回的错误消息按语言切换 |

---

# 第二章 深浅双主题设计

## 2.1 主题架构总览

```
┌─────────────────────────────────────────────────────────────────┐
│                     前端主题架构                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌───────────────────────────────────────────────────────┐     │
│  │  Pinia ThemeStore (主题状态管理)                        │     │
│  │  ├── mode: 'light' | 'dark' | 'auto'                  │     │
│  │  ├── systemPreference: 'light' | 'dark'               │     │
│  │  └── persist → localStorage                           │     │
│  └──────────────────────────┬────────────────────────────┘     │
│                             │                                   │
│  ┌──────────────────────────▼────────────────────────────┐     │
│  │  CSS Variables (主题变量层)                             │     │
│  │  :root[data-theme="light"] { --color-bg: #fff; ... }  │     │
│  │  :root[data-theme="dark"]  { --color-bg: #1a1a2e; ...}│     │
│  └──────────────────────────┬────────────────────────────┘     │
│                             │                                   │
│  ┌──────────────────────────▼────────────────────────────┐     │
│  │  组件层 (Vue组件 + Element Plus + ECharts)              │     │
│  │  所有样式引用CSS变量，不硬编码颜色                       │     │
│  └───────────────────────────────────────────────────────┘     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 2.2 CSS Variables 主题变量体系

### 2.2.1 变量命名规范

```
命名层级: --{类别}-{属性}-{状态}

类别:
  color    颜色
  bg       背景
  border   边框
  text     文字
  shadow   阴影
  spacing  间距(主题不变)
  radius   圆角(主题不变)

状态(可选):
  hover    悬停
  active   激活
  disabled 禁用
  focus    聚焦
```

### 2.2.2 完整主题变量定义

```css
/* styles/themes/light.css — 浅色主题 */
:root[data-theme="light"] {
  /* ===== 基础背景 ===== */
  --color-bg-primary:      #ffffff;     /* 页面主背景 */
  --color-bg-secondary:    #f5f7fa;     /* 卡片/区块背景 */
  --color-bg-tertiary:     #ebeef5;     /* 悬浮面板/输入框背景 */
  --color-bg-hover:        #f0f2f5;     /* 列表项悬停 */
  --color-bg-active:       #e6f0ff;     /* 选中态背景 */

  /* ===== 品牌色（智链蓝 / 智赢青 通过产品变量覆盖） ===== */
  --color-brand-primary:   #58a6ff;     /* 智链品牌主色 */
  --color-brand-hover:     #4096ff;
  --color-brand-active:    #1677ff;
  --color-brand-light:     #e6f4ff;     /* 品牌浅色背景 */

  /* ===== 文字颜色 ===== */
  --color-text-primary:    #1f2329;     /* 主文字 */
  --color-text-regular:    #4e5969;     /* 常规文字 */
  --color-text-secondary:  #86909c;     /* 辅助文字 */
  --color-text-disabled:   #c9cdd4;     /* 禁用文字 */
  --color-text-inverse:    #ffffff;     /* 深色背景上的文字 */
  --color-text-brand:      #1677ff;     /* 品牌色文字 */

  /* ===== 边框颜色 ===== */
  --color-border-light:    #e5e6eb;     /* 浅边框 */
  --color-border-base:     #c9cdd4;     /* 常规边框 */
  --color-border-dark:     #86909c;     /* 深边框 */
  --color-border-brand:    #58a6ff;     /* 品牌边框 */

  /* ===== 功能色 ===== */
  --color-success:         #00b42a;
  --color-success-light:   #e8ffea;
  --color-warning:         #ff7d00;
  --color-warning-light:   #fff7e8;
  --color-error:           #f53f3f;
  --color-error-light:     #ffece8;
  --color-info:            #86909c;
  --color-info-light:      #f2f3f5;

  /* ===== 阴影 ===== */
  --shadow-sm:    0 1px 2px rgba(0, 0, 0, 0.06);
  --shadow-md:    0 2px 8px rgba(0, 0, 0, 0.08);
  --shadow-lg:    0 4px 16px rgba(0, 0, 0, 0.10);
  --shadow-xl:    0 8px 32px rgba(0, 0, 0, 0.12);

  /* ===== 遮罩 ===== */
  --color-mask:            rgba(0, 0, 0, 0.45);
  --color-mask-light:      rgba(0, 0, 0, 0.25);

  /* ===== 侧边栏专用 ===== */
  --color-sidebar-bg:      #1d2129;     /* 深色侧边栏(两套主题统一) */
  --color-sidebar-text:    #c9cdd4;
  --color-sidebar-active:  #58a6ff;
  --color-sidebar-hover:   #2a2f38;
}

/* styles/themes/dark.css — 深色主题 */
:root[data-theme="dark"] {
  /* ===== 基础背景 ===== */
  --color-bg-primary:      #1a1a2e;     /* 页面主背景 */
  --color-bg-secondary:    #16213e;     /* 卡片/区块背景 */
  --color-bg-tertiary:     #0f3460;     /* 悬浮面板/输入框背景 */
  --color-bg-hover:        #1e2a4a;     /* 列表项悬停 */
  --color-bg-active:       #1a3a5c;     /* 选中态背景 */

  /* ===== 品牌色 ===== */
  --color-brand-primary:   #58a6ff;
  --color-brand-hover:     #4096ff;
  --color-brand-active:    #1677ff;
  --color-brand-light:     #1a3a5c;     /* 深色品牌背景 */

  /* ===== 文字颜色 ===== */
  --color-text-primary:    #e8eaed;     /* 主文字 */
  --color-text-regular:    #c9cdd4;     /* 常规文字 */
  --color-text-secondary:  #86909c;     /* 辅助文字 */
  --color-text-disabled:   #4e5969;     /* 禁用文字 */
  --color-text-inverse:    #1f2329;     /* 浅色背景上的文字 */
  --color-text-brand:      #58a6ff;     /* 品牌色文字 */

  /* ===== 边框颜色 ===== */
  --color-border-light:    #2a2f38;     /* 浅边框 */
  --color-border-base:     #3a4050;     /* 常规边框 */
  --color-border-dark:     #4e5969;     /* 深边框 */
  --color-border-brand:    #58a6ff;     /* 品牌边框 */

  /* ===== 功能色(深色版调亮) ===== */
  --color-success:         #23c343;
  --color-success-light:   #0e2a18;
  --color-warning:         #ff9a2e;
  --color-warning-light:   #2a1f0e;
  --color-error:           #f76560;
  --color-error-light:     #2a1414;
  --color-info:            #86909c;
  --color-info-light:      #1e2024;

  /* ===== 阴影(深色模式更浓) ===== */
  --shadow-sm:    0 1px 2px rgba(0, 0, 0, 0.3);
  --shadow-md:    0 2px 8px rgba(0, 0, 0, 0.4);
  --shadow-lg:    0 4px 16px rgba(0, 0, 0, 0.5);
  --shadow-xl:    0 8px 32px rgba(0, 0, 0, 0.6);

  /* ===== 遮罩 ===== */
  --color-mask:            rgba(0, 0, 0, 0.6);
  --color-mask-light:      rgba(0, 0, 0, 0.4);

  /* ===== 侧边栏(深色主题下更暗) ===== */
  --color-sidebar-bg:      #0d1117;
  --color-sidebar-text:    #8b949e;
  --color-sidebar-active:  #58a6ff;
  --color-sidebar-hover:   #161b22;
}

/* 智赢产品线品牌色覆盖（青色系） */
:root[data-product="smartwin"] {
  --color-brand-primary:   #2dd4bf;
  --color-brand-hover:     #14b8a6;
  --color-brand-active:    #0d9488;
  --color-brand-light:     #ccfbf1;     /* 浅色 */
  --color-brand-light:     #0e2a26;     /* 深色(被dark覆盖) */
}

/* ===== 间距/圆角(主题不变量) ===== */
:root {
  --spacing-xs: 4px;
  --spacing-sm: 8px;
  --spacing-md: 16px;
  --spacing-lg: 24px;
  --spacing-xl: 32px;
  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;
  --radius-xl: 16px;
}
```

## 2.3 Pinia ThemeStore 设计

```typescript
// stores/theme.ts
import { defineStore } from 'pinia'

export type ThemeMode = 'light' | 'dark' | 'auto'

interface ThemeState {
  mode: ThemeMode          // 用户选择: light / dark / auto
  systemPreference: 'light' | 'dark'  // 系统偏好
  resolvedTheme: 'light' | 'dark'     // 实际生效的主题
}

export const useThemeStore = defineStore('theme', {
  state: (): ThemeState => ({
    mode: 'auto',
    systemPreference: 'light',
    resolvedTheme: 'light',
  }),

  getters: {
    isDark: (state) => state.resolvedTheme === 'dark',
    isAuto: (state) => state.mode === 'auto',
  },

  actions: {
    /** 初始化主题——从localStorage读取并应用 */
    init() {
      const saved = localStorage.getItem('theme-mode') as ThemeMode
      if (saved) this.mode = saved

      // 监听系统偏好变化
      const mql = window.matchMedia('(prefers-color-scheme: dark)')
      this.systemPreference = mql.matches ? 'dark' : 'light'
      mql.addEventListener('change', (e) => {
        this.systemPreference = e.matches ? 'dark' : 'light'
        if (this.mode === 'auto') this.applyTheme()
      })

      this.applyTheme()
    },

    /** 设置主题模式 */
    setMode(mode: ThemeMode) {
      this.mode = mode
      localStorage.setItem('theme-mode', mode)
      this.applyTheme()
      // 通知ECharts重新渲染
      this.notifyChartThemeChange()
      // 通知微前端子应用
      this.broadcastThemeChange()
    },

    /** 切换浅色/深色（便捷方法） */
    toggle() {
      this.setMode(this.resolvedTheme === 'light' ? 'dark' : 'light')
    },

    /** 应用主题到DOM */
    applyTheme() {
      this.resolvedTheme =
        this.mode === 'auto' ? this.systemPreference : this.mode
      document.documentElement.setAttribute('data-theme', this.resolvedTheme)
      // 设置Element Plus暗色模式
      document.documentElement.classList.toggle('dark', this.isDark)
    },

    /** 通知ECharts图表更新主题 */
    notifyChartThemeChange() {
      window.dispatchEvent(new CustomEvent('theme-changed', {
        detail: { theme: this.resolvedTheme }
      }))
    },

    /** 微前端模式下广播主题变化 */
    broadcastThemeChange() {
      window.dispatchEvent(new CustomEvent('app-theme-change', {
        detail: { theme: this.resolvedTheme, mode: this.mode }
      }))
    },
  },
})
```

## 2.4 ECharts 图表主题联动

```typescript
// composables/useEchartsTheme.ts
import { computed } from 'vue'
import { useThemeStore } from '@/stores/theme'

/** ECharts主题配色——跟随主题切换 */
export function useEchartsTheme() {
  const themeStore = useThemeStore()

  const chartTheme = computed(() => {
    if (themeStore.isDark) {
      return {
        backgroundColor: 'transparent',
        textStyle: { color: '#c9cdd4' },
        title: { textStyle: { color: '#e8eaed' } },
        legend: { textStyle: { color: '#c9cdd4' } },
        xAxis: {
          axisLine: { lineStyle: { color: '#3a4050' } },
          axisLabel: { color: '#86909c' },
          splitLine: { lineStyle: { color: '#2a2f38' } },
        },
        yAxis: {
          axisLine: { lineStyle: { color: '#3a4050' } },
          axisLabel: { color: '#86909c' },
          splitLine: { lineStyle: { color: '#2a2f38' } },
        },
        color: ['#58a6ff', '#2dd4bf', '#f76560', '#ff9a2e', '#23c343',
                '#722ed1', '#0fc6c2', '#e8b860'],
        tooltip: {
          backgroundColor: '#16213e',
          borderColor: '#3a4050',
          textStyle: { color: '#e8eaed' },
        },
      }
    }
    return {
      backgroundColor: 'transparent',
      textStyle: { color: '#4e5969' },
      title: { textStyle: { color: '#1f2329' } },
      legend: { textStyle: { color: '#4e5969' } },
      xAxis: {
        axisLine: { lineStyle: { color: '#c9cdd4' } },
        axisLabel: { color: '#86909c' },
        splitLine: { lineStyle: { color: '#e5e6eb' } },
      },
      yAxis: {
        axisLine: { lineStyle: { color: '#c9cdd4' } },
        axisLabel: { color: '#86909c' },
        splitLine: { lineStyle: { color: '#e5e6eb' } },
      },
      color: ['#1677ff', '#0d9488', '#f53f3f', '#ff7d00', '#00b42a',
              '#722ed1', '#0fc6c2', '#d4a017'],
      tooltip: {
        backgroundColor: '#ffffff',
        borderColor: '#c9cdd4',
        textStyle: { color: '#1f2329' },
      },
    }
  })

  return { chartTheme }
}
```

## 2.5 无闪烁主题切换（FOUC 防护）

```html
<!-- index.html <head> 中内联执行，避免页面加载闪烁 -->
<script>
  (function() {
    var saved = localStorage.getItem('theme-mode') || 'auto';
    var systemDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    var resolved = saved === 'auto' ? (systemDark ? 'dark' : 'light') : saved;
    document.documentElement.setAttribute('data-theme', resolved);
    if (resolved === 'dark') document.documentElement.classList.add('dark');
  })();
</script>
```

---

# 第三章 国际化(i18n)设计

## 3.1 i18n 架构总览

```
┌─────────────────────────────────────────────────────────────────┐
│                     前端 i18n 架构                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌───────────────────────────────────────────────────────┐     │
│  │  Pinia LocaleStore (语言状态管理)                       │     │
│  │  ├── locale: 'zh-CN' | 'en-US'                        │     │
│  │  ├── availableLocales: ['zh-CN', 'en-US'] /* 预留 */  │     │
│  │  └── persist → localStorage + 后端用户偏好              │     │
│  └──────────────────────────┬────────────────────────────┘     │
│                             │                                   │
│  ┌──────────────────────────▼────────────────────────────┐     │
│  │  vue-i18n (国际化引擎)                                  │     │
│  │  ├── 消息文件按模块拆分                                 │     │
│  │  ├── 懒加载(按需加载locale)                            │     │
│  │  └── 插值/复数/日期/数字格式化                          │     │
│  └──────────────────────────┬────────────────────────────┘     │
│                             │                                   │
│  ┌──────────────────────────▼────────────────────────────┐     │
│  │  Locale 文件目录 (按语言+模块组织)                      │     │
│  │  locales/                                              │     │
│  │  ├── zh-CN/                                            │     │
│  │  │   ├── common.json    (通用: 按钮/表单/提示)         │     │
│  │  │   ├── menu.json      (菜单/导航)                   │     │
│  │  │   ├── smartchain/    (智链模块)                    │     │
│  │  │   │   ├── model.json                                │     │
│  │  │   │   ├── app.json                                  │     │
│  │  │   │   └── ...                                       │     │
│  │  │   └── smartwin/     (智赢模块)                     │     │
│  │  │       ├── catalog.json                              │     │
│  │  │       ├── quality.json                              │     │
│  │  │       └── ...                                       │     │
│  │  ├── en-US/ (同结构)                                   │     │
│  │  └── index.ts          (注册与导出)                    │     │
│  └───────────────────────────────────────────────────────┘     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 3.2 消息键命名规范

```
命名规则: {模块}.{子模块}.{具体词条}

示例:
  common.button.save          → "保存" / "Save"
  common.button.cancel        → "取消" / "Cancel"
  common.message.saveSuccess  → "保存成功" / "Saved successfully"
  menu.smartchain.model       → "模型管理" / "Model Management"
  smartchain.model.status.running → "运行中" / "Running"
  smartwin.catalog.title      → "数据目录" / "Data Catalog"

命名约束:
  1. 全部使用驼峰命名(camelCase)
  2. 层级不超过4层
  3. 通用词条放common下
  4. 业务词条按模块归类
  5. 不使用魔法字符串，统一通过 $t() 调用
```

## 3.3 Locale 文件结构

```
src/
└── i18n/
    ├── index.ts                    # i18n初始化与配置
    ├── locale-store.ts             # Pinia语言状态管理
    ├── locales/
    │   ├── zh-CN/
    │   │   ├── common.json         # 通用词条
    │   │   ├── menu.json           # 菜单
    │   │   ├── validation.json     # 表单校验消息
    │   │   ├── error.json          # 错误消息
    │   │   ├── smartchain/
    │   │   │   ├── model.json      # 智链-模型管理
    │   │   │   ├── app.json        # 智链-应用管理
    │   │   │   ├── agent.json      # 智链-Agent管理
    │   │   │   ├── cost.json       # 智链-成本管控
    │   │   │   ├── risk.json       # 智链-风险管控
    │   │   │   └── prompt.json     # 智链-Prompt管理
    │   │   └── smartwin/
    │   │       ├── catalog.json    # 智赢-数据目录
    │   │       ├── metadata.json   # 智赢-元数据
    │   │       ├── quality.json    # 智赢-数据质量
    │   │       ├── standard.json   # 智赢-数据标准
    │   │       ├── lineage.json    # 智赢-数据血缘
    │   │       ├── mdm.json        # 智赢-主数据
    │   │       ├── lifecycle.json  # 智赢-生命周期
    │   │       ├── dataservice.json # 智赢-数据服务
    │   │       └── asset.json      # 智赢-资产评估
    │   └── en-US/                  # 英文(同结构)
    │       ├── common.json
    │       ├── menu.json
    │       ├── validation.json
    │       ├── error.json
    │       ├── smartchain/
    │       │   └── ...
    │       └── smartwin/
    │           └── ...
    └── types/
        └── schema.ts               # 消息键TypeScript类型推导
```

## 3.4 消息文件示例

### 3.4.1 通用词条 `zh-CN/common.json`

```json
{
  "button": {
    "save": "保存",
    "cancel": "取消",
    "confirm": "确认",
    "delete": "删除",
    "edit": "编辑",
    "create": "新建",
    "search": "搜索",
    "reset": "重置",
    "export": "导出",
    "import": "导入",
    "refresh": "刷新",
    "back": "返回",
    "submit": "提交",
    "copy": "复制",
    "download": "下载",
    "upload": "上传",
    "enable": "启用",
    "disable": "禁用",
    "expand": "展开",
    "collapse": "收起"
  },
  "message": {
    "saveSuccess": "保存成功",
    "deleteSuccess": "删除成功",
    "operationSuccess": "操作成功",
    "operationFailed": "操作失败",
    "confirmDelete": "确定要删除吗？此操作不可撤销。",
    "loading": "加载中...",
    "noData": "暂无数据",
    "saveFailed": "保存失败",
    "networkError": "网络异常，请稍后重试",
    "permissionDenied": "无权限访问"
  },
  "status": {
    "running": "运行中",
    "stopped": "已停止",
    "pending": "待处理",
    "success": "成功",
    "failed": "失败",
    "processing": "处理中",
    "expired": "已过期",
    "enabled": "已启用",
    "disabled": "已禁用"
  },
  "pagination": {
    "total": "共 {count} 条",
    "pageSize": "{size} 条/页",
    "jumpTo": "跳至",
    "page": "页"
  },
  "theme": {
    "light": "浅色",
    "dark": "深色",
    "auto": "跟随系统",
    "toggle": "切换主题"
  },
  "language": {
    "zh-CN": "简体中文",
    "en-US": "English",
    "switch": "切换语言"
  }
}
```

### 3.4.2 通用词条 `en-US/common.json`

```json
{
  "button": {
    "save": "Save",
    "cancel": "Cancel",
    "confirm": "Confirm",
    "delete": "Delete",
    "edit": "Edit",
    "create": "Create",
    "search": "Search",
    "reset": "Reset",
    "export": "Export",
    "import": "Import",
    "refresh": "Refresh",
    "back": "Back",
    "submit": "Submit",
    "copy": "Copy",
    "download": "Download",
    "upload": "Upload",
    "enable": "Enable",
    "disable": "Disable",
    "expand": "Expand",
    "collapse": "Collapse"
  },
  "message": {
    "saveSuccess": "Saved successfully",
    "deleteSuccess": "Deleted successfully",
    "operationSuccess": "Operation successful",
    "operationFailed": "Operation failed",
    "confirmDelete": "Are you sure you want to delete? This action cannot be undone.",
    "loading": "Loading...",
    "noData": "No data",
    "saveFailed": "Save failed",
    "networkError": "Network error, please try again later",
    "permissionDenied": "Permission denied"
  },
  "status": {
    "running": "Running",
    "stopped": "Stopped",
    "pending": "Pending",
    "success": "Success",
    "failed": "Failed",
    "processing": "Processing",
    "expired": "Expired",
    "enabled": "Enabled",
    "disabled": "Disabled"
  },
  "pagination": {
    "total": "Total {count} items",
    "pageSize": "{size} / page",
    "jumpTo": "Go to",
    "page": ""
  },
  "theme": {
    "light": "Light",
    "dark": "Dark",
    "auto": "System",
    "toggle": "Toggle theme"
  },
  "language": {
    "zh-CN": "简体中文",
    "en-US": "English",
    "switch": "Switch language"
  }
}
```

## 3.5 vue-i18n 初始化配置

```typescript
// i18n/index.ts
import { createI18n } from 'vue-i18n'
import zhCNCommon from './locales/zh-CN/common.json'
import zhCNMenu from './locales/zh-CN/menu.json'
import enUSCommon from './locales/en-US/common.json'
import enUSMenu from './locales/en-US/menu.json'

// 懒加载业务模块locale
const messages = {
  'zh-CN': {
    common: zhCNCommon,
    menu: zhCNMenu,
    // 业务模块按需异步加载
  },
  'en-US': {
    common: enUSCommon,
    menu: enUSMenu,
  },
}

export const i18n = createI18n({
  legacy: false,                    // 使用Composition API模式
  locale: 'zh-CN',                  // 默认语言
  fallbackLocale: 'zh-CN',          // 回退语言
  messages,
  missingWarn: false,               // 生产环境不警告缺失键
  fallbackWarn: false,
})

/**
 * 异步加载业务模块的locale文件
 * @param module 模块名: 'smartchain/model'
 * @param locale 语言: 'zh-CN' | 'en-US'
 */
export async function loadModuleLocale(module: string, locale: string) {
  const key = `${module}.${locale}`
  if (i18n.global.getLocaleMessage(locale)[module]) return

  const data = await import(`./locales/${locale}/${module}.json`)
  i18n.global.mergeLocaleMessage(locale, { [module]: data.default })
}

export default i18n
```

## 3.6 Pinia LocaleStore 设计

```typescript
// i18n/locale-store.ts
import { defineStore } from 'pinia'
import { i18n, loadModuleLocale } from './index'

export type AppLocale = 'zh-CN' | 'en-US'

// 预留多语言扩展——未来新增语言仅需在数组中添加
export const AVAILABLE_LOCALES: { value: AppLocale; label: string; flag: string }[] = [
  { value: 'zh-CN', label: '简体中文', flag: '🇨🇳' },
  { value: 'en-US', label: 'English', flag: '🇺🇸' },
  // 预留:
  // { value: 'ja-JP', label: '日本語', flag: '🇯🇵' },
  // { value: 'ko-KR', label: '한국어', flag: '🇰🇷' },
  // { value: 'fr-FR', label: 'Français', flag: '🇫🇷' },
]

interface LocaleState {
  locale: AppLocale
}

export const useLocaleStore = defineStore('locale', {
  state: (): LocaleState => ({
    locale: 'zh-CN',
  }),

  actions: {
    /** 初始化语言——localStorage → 浏览器语言 → 默认 */
    async init() {
      const saved = localStorage.getItem('app-locale') as AppLocale
      const browserLang = navigator.language
      const initial = saved
        || (browserLang.startsWith('zh') ? 'zh-CN' : 'en-US')
      await this.setLocale(initial)
    },

    /** 设置语言 */
    async setLocale(locale: AppLocale) {
      this.locale = locale
      i18n.global.locale.value = locale

      // 1. 持久化到localStorage
      localStorage.setItem('app-locale', locale)

      // 2. 设置HTML lang属性
      document.documentElement.setAttribute('lang', locale)

      // 3. 通知后端用户语言偏好
      this.notifyBackend(locale)

      // 4. 广播给微前端子应用
      this.broadcastLocaleChange(locale)

      // 5. 重新加载当前路由所需的模块locale
      this.reloadModuleLocales(locale)
    },

    /** 通知后端用户语言偏好 */
    notifyBackend(locale: AppLocale) {
      // 设置后续所有API请求的Accept-Language头
      axios.defaults.headers.common['Accept-Language'] = locale
      // 异步保存到用户偏好(如果已登录)
      if (isLoggedIn()) {
        api.put('/api/system/user/preference', { locale })
      }
    },

    /** 广播给微前端子应用 */
    broadcastLocaleChange(locale: AppLocale) {
      window.dispatchEvent(new CustomEvent('app-locale-change', {
        detail: { locale }
      }))
    },

    /** 重新加载已加载模块的locale */
    async reloadModuleLocales(locale: AppLocale) {
      // 获取当前路由对应的模块并加载locale
      const route = useRoute()
      const module = route.meta?.i18nModule as string
      if (module) {
        await loadModuleLocale(module, locale)
      }
    },
  },
})
```

## 3.7 TypeScript 类型安全推导

```typescript
// i18n/types/schema.ts
import zhCNCommon from '../locales/zh-CN/common.json'

// 从中文消息文件自动推导消息键类型，实现$t()类型检查
type Schema = typeof zhCNCommon

declare module 'vue-i18n' {
  export interface DefineLocaleMessage extends Schema {}
}

// 使用时: $t('common.button.save') 会有自动补全和类型检查
```

## 3.8 路由级懒加载 i18n

```typescript
// router/index.ts — 路由配置i18n模块
const routes = [
  {
    path: '/models',
    meta: { i18nModule: 'smartchain/model' },  // 进入路由时加载此模块locale
    component: () => import('@/views/smartchain/ModelOverviewView.vue'),
  },
  {
    path: '/catalog',
    meta: { i18nModule: 'smartwin/catalog' },
    component: () => import('@/views/smartwin/CatalogView.vue'),
  },
]

// router/before-each.ts — 路由守卫中加载locale
router.beforeEach(async (to) => {
  const module = to.meta?.i18nModule as string
  if (module) {
    const localeStore = useLocaleStore()
    await loadModuleLocale(module, localeStore.locale)
  }
})
```

---

# 第四章 后端国际化与多语言API接口

## 4.1 后端国际化架构

```
┌─────────────────────────────────────────────────────────────────┐
│                     后端国际化架构                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  客户端请求                                                      │
│  ├── HTTP Header: Accept-Language: zh-CN / en-US              │
│  └── 用户偏好: 数据库 user_preference.locale                   │
│                                                                 │
│  ┌───────────────────────────────────────────────────────┐     │
│  │  LocaleResolver (语言解析器)                            │     │
│  │  优先级: 用户DB偏好 > Accept-Language > 默认zh-CN      │     │
│  └──────────────────────────┬────────────────────────────┘     │
│                             │                                   │
│  ┌──────────────────────────▼────────────────────────────┐     │
│  │  Spring MessageSource (消息源)                          │     │
│  │  ├── messages_zh_CN.properties                         │     │
│  │  └── messages_en_US.properties                         │     │
│  └──────────────────────────┬────────────────────────────┘     │
│                             │                                   │
│  ┌──────────────────────────▼────────────────────────────┐     │
│  │  统一响应(错误消息/校验消息/业务提示)                    │     │
│  │  { "code": 400, "message": "保存失败" / "Save failed" }│     │
│  └───────────────────────────────────────────────────────┘     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 4.2 Spring LocaleResolver 配置

```java
/**
 * 多语言解析器配置
 * 解析优先级: 用户DB偏好 > Accept-Language请求头 > 默认中文
 */
@Configuration
public class LocaleConfig {

    @Bean
    public LocaleResolver localeResolver() {
        SmartLocaleResolver resolver = new SmartLocaleResolver();
        resolver.setDefaultLocale(Locale.SIMPLIFIED_CHINESE);
        return resolver;
    }

    @Bean
    public MessageSource messageSource() {
        ReloadableResourceBundleMessageSource source =
            new ReloadableResourceBundleMessageSource();
        source.setBasename("classpath:i18n/messages");
        source.setDefaultEncoding("UTF-8");
        source.setCacheSeconds(3600);
        return source;
    }
}

/**
 * 智能语言解析器——支持用户偏好优先
 */
public class SmartLocaleResolver extends AcceptHeaderLocaleResolver {

    @Override
    public Locale resolveLocale(HttpServletRequest request) {
        // 1. 检查用户DB偏好(通过Token获取用户信息)
        String userLocale = getUserLocaleFromToken(request);
        if (userLocale != null) {
            return Locale.forLanguageTag(userLocale);
        }

        // 2. 检查Accept-Language头
        String acceptLang = request.getHeader("Accept-Language");
        if (acceptLang != null && !acceptLang.isEmpty()) {
            return resolveFromHeader(acceptLang);
        }

        // 3. 默认中文
        return Locale.SIMPLIFIED_CHINESE;
    }

    private String getUserLocaleFromToken(HttpServletRequest request) {
        // 从JWT Token中提取用户ID，查询用户语言偏好
        // 通过ThreadLocal或RequestAttribute传递
        return UserContextHolder.getLocale();
    }
}
```

## 4.3 后端消息文件

```
platform-common/
└── common-util/
    └── src/main/resources/
        └── i18n/
            ├── messages_zh_CN.properties    # 中文消息
            └── messages_en_US.properties    # 英文消息
```

```properties
# messages_zh_CN.properties

# ===== 通用操作 =====
common.save.success=保存成功
common.save.failed=保存失败
common.delete.success=删除成功
common.delete.failed=删除失败
common.update.success=更新成功
common.update.failed=更新失败
common.query.success=查询成功
common.operation.success=操作成功
common.operation.failed=操作失败

# ===== 校验消息 =====
validation.required={0}不能为空
validation.length={0}长度必须在{1}到{2}个字符之间
validation.email=邮箱格式不正确
validation.phone=手机号格式不正确
validation.pattern={0}格式不正确
validation.min={0}不能小于{1}
validation.max={0}不能大于{1}
validation.unique={0}已存在

# ===== 认证授权 =====
auth.login.success=登录成功
auth.login.failed=用户名或密码错误
auth.token.expired=登录已过期，请重新登录
auth.token.invalid=无效的Token
auth.permission.denied=无权限访问该资源
auth.account.locked=账号已被锁定，请联系管理员
auth.account.disabled=账号已被禁用

# ===== 业务错误 =====
business.model.notFound=模型不存在
business.model.nameExists=模型名称已存在
business.catalog.notFound=数据目录不存在
business.quality.ruleError=质量规则配置错误
```

```properties
# messages_en_US.properties

# ===== Common Operations =====
common.save.success=Saved successfully
common.save.failed=Save failed
common.delete.success=Deleted successfully
common.delete.failed=Delete failed
common.update.success=Updated successfully
common.update.failed=Update failed
common.query.success=Query successful
common.operation.success=Operation successful
common.operation.failed=Operation failed

# ===== Validation =====
validation.required={0} is required
validation.length={0} must be between {1} and {2} characters
validation.email=Invalid email format
validation.phone=Invalid phone number format
validation.pattern=Invalid {0} format
validation.min={0} must not be less than {1}
validation.max={0} must not be greater than {1}
validation.unique={0} already exists

# ===== Auth =====
auth.login.success=Login successful
auth.login.failed=Invalid username or password
auth.token.expired=Session expired, please login again
auth.token.invalid=Invalid token
auth.permission.denied=Permission denied
auth.account.locked=Account is locked, please contact administrator
auth.account.disabled=Account is disabled

# ===== Business =====
business.model.notFound=Model not found
business.model.nameExists=Model name already exists
business.catalog.notFound=Data catalog not found
business.quality.ruleError=Quality rule configuration error
```

## 4.4 统一响应国际化

```java
/**
 * 统一响应体——message字段按请求语言国际化
 */
@Data
public class ApiResponse<T> {
    private int code;
    private String message;
    private T data;
    private String timestamp;

    /**
     * 成功响应(自动国际化)
     */
    public static <T> ApiResponse<T> success(MessageSource ms, Locale locale) {
        ApiResponse<T> r = new ApiResponse<>();
        r.code = 200;
        r.message = ms.getMessage("common.operation.success", null, locale);
        r.timestamp = LocalDateTime.now().toString();
        return r;
    }

    /**
     * 失败响应(自动国际化，支持参数插值)
     */
    public static <T> ApiResponse<T> error(int code, String messageKey,
            Object[] args, MessageSource ms, Locale locale) {
        ApiResponse<T> r = new ApiResponse<>();
        r.code = code;
        r.message = ms.getMessage(messageKey, args, locale);
        r.timestamp = LocalDateTime.now().toString();
        return r;
    }
}

/**
 * 全局异常处理器——国际化错误消息
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

    @Autowired
    private MessageSource messageSource;

    @ExceptionHandler(BusinessException.class)
    public ApiResponse<Void> handleBusiness(BusinessException e, Locale locale) {
        return ApiResponse.error(e.getCode(), e.getMessageKey(),
            e.getArgs(), messageSource, locale);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ApiResponse<Void> handleValidation(MethodArgumentNotValidException e,
            Locale locale) {
        FieldError fieldError = e.getBindingResult().getFieldError();
        String message = messageSource.getMessage(
            fieldError.getDefaultMessage(),
            new Object[]{fieldError.getField()},
            locale);
        return ApiResponse.error(400, message, null);
    }
}
```

## 4.5 用户语言偏好 API

```java
/**
 * 用户偏好API——保存/获取用户语言设置
 */
@RestController
@RequestMapping("/api/system/user/preference")
public class UserPreferenceController {

    @Autowired
    private UserPreferenceService preferenceService;

    /** 获取用户偏好 */
    @GetMapping
    public ApiResponse<UserPreference> getPreference() {
        return ApiResponse.success(preferenceService.getByUserId(currentUser()));
    }

    /** 更新语言偏好 */
    @PutMapping
    public ApiResponse<Void> updatePreference(@RequestBody UpdateLocaleRequest req) {
        preferenceService.updateLocale(currentUser(), req.getLocale());
        return ApiResponse.success();
    }
}

/**
 * 用户偏好实体
 */
@Data
public class UserPreference {
    private String locale;        // zh-CN / en-US
    private String themeMode;     // light / dark / auto
    // 预留: timezone, dateFormat, numberFormat ...
}
```

## 4.6 数据库表设计

```sql
-- 用户偏好表
CREATE TABLE sys_user_preference (
    id              BIGINT PRIMARY KEY,
    user_id         BIGINT NOT NULL UNIQUE,
    locale          VARCHAR(10) DEFAULT 'zh-CN',   -- 语言偏好
    theme_mode      VARCHAR(10) DEFAULT 'auto',     -- 主题模式
    timezone        VARCHAR(50) DEFAULT 'Asia/Shanghai',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE sys_user_preference IS '用户偏好设置表';
COMMENT ON COLUMN sys_user_preference.locale IS '语言偏好: zh-CN/en-US，预留多语言扩展';
COMMENT ON COLUMN sys_user_preference.theme_mode IS '主题模式: light/dark/auto';
```

---

# 第五章 主题与语言切换交互设计

## 5.1 顶栏切换组件

```vue
<!-- components/layout/HeaderActions.vue -->
<template>
  <div class="header-actions">
    <!-- 主题切换 -->
    <el-dropdown trigger="click" @command="handleThemeChange">
      <el-button :icon="themeIcon" circle />
      <template #dropdown>
        <el-dropdown-menu>
          <el-dropdown-item command="light" :class="{ active: mode === 'light' }">
            <el-icon><Sunny /></el-icon> {{ $t('common.theme.light') }}
          </el-dropdown-item>
          <el-dropdown-item command="dark" :class="{ active: mode === 'dark' }">
            <el-icon><Moon /></el-icon> {{ $t('common.theme.dark') }}
          </el-dropdown-item>
          <el-dropdown-item command="auto" :class="{ active: mode === 'auto' }">
            <el-icon><Monitor /></el-icon> {{ $t('common.theme.auto') }}
          </el-dropdown-item>
        </el-dropdown-menu>
      </template>
    </el-dropdown>

    <!-- 语言切换 -->
    <el-dropdown trigger="click" @command="handleLocaleChange">
      <el-button circle>
        <span class="locale-flag">{{ currentLocaleFlag }}</span>
      </el-button>
      <template #dropdown>
        <el-dropdown-menu>
          <el-dropdown-item
            v-for="loc in availableLocales"
            :key="loc.value"
            :command="loc.value"
            :class="{ active: locale === loc.value }">
            <span>{{ loc.flag }}</span> {{ loc.label }}
          </el-dropdown-item>
        </el-dropdown-menu>
      </template>
    </el-dropdown>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { Sunny, Moon, Monitor } from '@element-plus/icons-vue'
import { useThemeStore } from '@/stores/theme'
import { useLocaleStore, AVAILABLE_LOCALES } from '@/i18n/locale-store'
import { useI18n } from 'vue-i18n'

const themeStore = useThemeStore()
const localeStore = useLocaleStore()
const { t } = useI18n()

const mode = computed(() => themeStore.mode)
const locale = computed(() => localeStore.locale)
const availableLocales = AVAILABLE_LOCALES

const themeIcon = computed(() => {
  if (themeStore.isDark) return Moon
  return Sunny
})

const currentLocaleFlag = computed(() => {
  return AVAILABLE_LOCALES.find(l => l.value === locale.value)?.flag || '🌐'
})

function handleThemeChange(command: string) {
  themeStore.setMode(command as any)
}

function handleLocaleChange(command: string) {
  localeStore.setLocale(command as any)
}
</script>

<style scoped>
.header-actions {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
}
.locale-flag { font-size: 1.1em; }
</style>
```

## 5.2 切换流程时序

```
用户点击语言切换 → 中文 → English

┌──────┐                    ┌──────────────┐           ┌──────────┐          ┌────────┐
│ 用户  │                    │ LocaleStore  │           │ vue-i18n │          │ 后端API │
└──┬───┘                    └──────┬───────┘           └────┬─────┘          └───┬────┘
   │ 点击English                   │                        │                   │
   │──────────────────────────────→│                        │                   │
   │                               │ setLocale('en-US')     │                   │
   │                               │───────────────────────→│                   │
   │                               │ locale.value = 'en-US' │                   │
   │                               │←───────────────────────│                   │
   │                               │ localStorage.setItem   │                   │
   │                               │ <html lang="en-US">    │                   │
   │                               │                        │                   │
   │                               │ PUT /user/preference   │                   │
   │                               │──────────────────────────────────────────→ │
   │                               │←───────────────── 200 OK ─────────────────│
   │                               │                        │                   │
   │                               │ Accept-Language: en-US (后续所有请求)     │
   │                               │──────────────────────────────────────────→ │
   │                               │                        │                   │
   │                               │ dispatchEvent('app-locale-change')        │
   │                               │──→ (微前端子应用接收)   │                   │
   │                               │                        │                   │
   │ 全站文字切换为英文             │                        │                   │
   │←──────────────────────────────┤                        │                   │
   └                               └                        └                   └
```

---

# 第六章 共享模块设计

## 6.1 shared-components 包结构

```
shared-components/                    # 两套前端共享的npm workspace包
├── package.json
└── src/
    ├── theme/
    │   ├── ThemeProvider.vue          # 主题Provider(初始化+应用)
    │   ├── ThemeSwitcher.vue          # 主题切换下拉组件
    │   ├── stores/
    │   │   └── theme.ts               # ThemeStore(Pinia)
    │   ├── themes/
    │   │   ├── light.css              # 浅色变量
    │   │   ├── dark.css               # 深色变量
    │   │   └── brand/
    │   │       ├── smartchain.css     # 智链品牌色覆盖
    │   │       └── smartwin.css       # 智赢品牌色覆盖
    │   ├── composables/
    │   │   ├── useTheme.ts            # 主题组合式函数
    │   │   └── useEchartsTheme.ts     # ECharts主题联动
    │   └── index.ts                   # 导出
    │
    ├── i18n/
    │   ├── I18nProvider.vue           # i18n Provider(初始化)
    │   ├── LangSwitcher.vue           # 语言切换下拉组件
    │   ├── stores/
    │   │   └── locale.ts              # LocaleStore(Pinia)
    │   ├── locales/                   # 共享locale(通用词条)
    │   │   ├── zh-CN/
    │   │   │   ├── common.json
    │   │   │   ├── menu.json
    │   │   │   ├── validation.json
    │   │   │   └── error.json
    │   │   └── en-US/
    │   │       └── ...
    │   ├── composables/
    │   │   └── useLocale.ts           # 语言组合式函数
    │   ├── types/
    │   │   └── schema.ts              # TypeScript类型推导
    │   └── index.ts                   # 导出
    │
    └── index.ts                       # 包统一导出
```

## 6.2 各前端引用方式

```json
// smartchain-frontend/package.json
{
  "dependencies": {
    "@smartwin/shared-components": "workspace:*"
  }
}
```

```typescript
// smartchain-frontend/src/main.ts
import { ThemeProvider, I18nProvider } from '@smartwin/shared-components'

// 初始化主题与i18n
const themeStore = useThemeStore()
themeStore.init()

const localeStore = useLocaleStore()
await localeStore.init()
```

---

# 第七章 微前端集成模式下的主题与i18n协同

## 7.1 状态同步架构

在集成模式下，智链和智赢作为微前端子应用，需要与统一门户(Portal Shell)共享主题和语言状态：

```
┌─────────────────────────────────────────────────────────────────┐
│              统一门户 (Portal Shell) — 主应用                     │
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐                      │
│  │  ThemeStore     │  │  LocaleStore    │                      │
│  │  (权威状态源)    │  │  (权威状态源)    │                      │
│  └────────┬────────┘  └────────┬────────┘                      │
│           │                    │                                │
│           │ CustomEvent        │ CustomEvent                    │
│           │ 'app-theme-change' │ 'app-locale-change'            │
│           ▼                    ▼                                │
│  ╔═══════════════════════════════════════════════════╗         │
│  ║         window.dispatchEvent (全局事件总线)          ║         │
│  ╚═══════════════════════════════════════════════════╝         │
│           │                    │                                │
│     ┌─────┴──────┐      ┌──────┴─────┐                         │
│     ▼            ▼      ▼            ▼                          │
│  ┌──────┐   ┌──────┐ ┌──────┐   ┌──────┐                      │
│  │智链  │   │智赢  │ │智链  │   │智赢  │                      │
│  │子应用│   │子应用│ │子应用│   │子应用│                      │
│  └──────┘   └──────┘ └──────┘   └──────┘                      │
│  (子应用监听事件，同步本地ThemeStore/LocaleStore)                │
└─────────────────────────────────────────────────────────────────┘
```

## 7.2 子应用同步实现

```typescript
// 子应用(智链/智赢)的 main.ts 中监听主应用事件

// 监听主题变化
window.addEventListener('app-theme-change', (e: CustomEvent) => {
  const { theme, mode } = e.detail
  const themeStore = useThemeStore()
  themeStore.mode = mode
  themeStore.applyTheme()
})

// 监听语言变化
window.addEventListener('app-locale-change', (e: CustomEvent) => {
  const { locale } = e.detail
  const localeStore = useLocaleStore()
  localeStore.setLocale(locale)
})
```

## 7.3 CSS 变量穿透

微前端模式下，子应用的CSS变量需要继承自主应用的 `:root` 定义。由于子应用挂载在主应用的DOM中，CSS变量天然继承，无需额外处理：

```css
/* 子应用样式直接引用主应用定义的CSS变量 */
.my-component {
  background: var(--color-bg-primary);
  color: var(--color-text-primary);
  border: 1px solid var(--color-border-base);
}
```

---

# 第八章 实施计划与验收标准

## 8.1 实施任务分解

### Sprint 2 (M1, 第5-8周): 主题与i18n基础

| 任务编号 | 任务 | 负责人 | 工时 | 交付物 |
|:--------:|------|:------:|:----:|--------|
| UI-S2-01 | shared-components包骨架搭建 + npm workspace配置 | 前端Lead | 2d | 包工程结构 |
| UI-S2-02 | CSS Variables主题变量体系(light.css + dark.css) | 前端Lead | 3d | 完整主题变量 |
| UI-S2-03 | ThemeStore(Pinia) + localStorage持久化 + 系统偏好跟随 | 前端 | 3d | 主题状态管理 |
| UI-S2-04 | ThemeSwitcher.vue切换组件 + 无闪烁FOUC防护 | 前端 | 2d | 切换组件 |
| UI-S2-05 | vue-i18n初始化 + 中英文common.json/menu.json | 前端 | 3d | i18n基础设施 |
| UI-S2-06 | LocaleStore(Pinia) + 语言偏好持久化 | 前端 | 3d | 语言状态管理 |
| UI-S2-07 | LangSwitcher.vue切换组件 | 前端 | 1d | 切换组件 |
| UI-S2-08 | index.html FOUC内联脚本 | 前端 | 1d | 无闪烁加载 |

### Sprint 3 (M2, 第9-12周): 后端国际化与业务i18n

| 任务编号 | 任务 | 负责人 | 工时 | 交付物 |
|:--------:|------|:------:|:----:|--------|
| UI-S3-01 | Spring LocaleResolver + MessageSource配置 | 后端 | 2d | 后端i18n框架 |
| UI-S3-02 | messages_zh_CN/en_US.properties消息文件 | 后端 | 3d | 后端消息文件 |
| UI-S3-03 | 全局异常处理器国际化 | 后端 | 2d | 国际化错误响应 |
| UI-S3-04 | 用户偏好API + sys_user_preference表 | 后端 | 3d | 用户偏好接口 |
| UI-S3-05 | 智链6模块中英文locale文件编写 | 前端 | 5d | 智链locale文件 |
| UI-S3-06 | 智赢9模块中英文locale文件编写 | 前端 | 5d | 智赢locale文件 |
| UI-S3-07 | ECharts图表主题联动 | 前端 | 2d | 图表暗色适配 |
| UI-S3-08 | 路由级i18n懒加载 | 前端 | 2d | 按需加载locale |

### Sprint 6 (M4, 第21-24周): 微前端集成模式协同

| 任务编号 | 任务 | 负责人 | 工时 | 交付物 |
|:--------:|------|:------:|:----:|--------|
| UI-S6-01 | 主应用CustomEvent主题/语言广播机制 | 前端Lead | 2d | 事件广播 |
| UI-S6-02 | 子应用主题/语言监听同步 | 前端 | 3d | 子应用同步 |
| UI-S6-03 | 品牌色CSS变量覆盖(智链蓝/智赢青) | 前端 | 1d | 品牌色体系 |
| UI-S6-04 | TypeScript i18n类型安全推导 | 前端 | 2d | 类型检查 |
| UI-S6-05 | 主题/i18n全量回归测试 | 测试 | 3d | 回归测试报告 |

## 8.2 验收标准

| 编号 | 验收项 | 验收标准 | 优先级 |
|:----:|--------|---------|:------:|
| V-01 | 浅色主题全站展示 | 所有页面浅色主题下无样式异常 | P0 |
| V-02 | 深色主题全站展示 | 所有页面深色主题下无样式异常、文字可读 | P0 |
| V-03 | 主题一键切换 | 点击切换无页面刷新、无白屏闪烁 | P0 |
| V-04 | 主题偏好持久化 | 关闭浏览器后重开保持上次主题选择 | P0 |
| V-05 | 跟随系统偏好 | 'auto'模式下跟随OS暗色/亮色设置 | P1 |
| V-06 | 中文界面完整 | 所有可见文字均为中文，无硬编码英文 | P0 |
| V-07 | 英文界面完整 | 切换英文后所有可见文字均为英文 | P0 |
| V-08 | 语言切换即时生效 | 切换语言后全站即时更新，无刷新 | P0 |
| V-09 | 语言偏好持久化 | 关闭浏览器后重开保持上次语言选择 | P0 |
| V-10 | 后端消息国际化 | API错误/校验消息按语言返回 | P0 |
| V-11 | ECharts图表适配 | 深色模式下图表配色适配、可读性良好 | P1 |
| V-12 | 微前端状态同步 | 集成模式下子应用跟随主应用主题/语言 | P1 |
| V-13 | i18n扩展验证 | 新增语言仅需添加locale文件，零代码改动 | P1 |
| V-14 | 品牌色区分 | 智链蓝色系/智赢青色系正确展示 | P1 |

## 8.3 技术选型确认

| 技术 | 版本 | 用途 |
|------|------|------|
| vue-i18n | 10.0+ | 前端国际化引擎 |
| Pinia | 3.0+ | 主题/语言状态管理 |
| CSS Custom Properties | 原生 | 主题变量体系(无额外依赖) |
| Element Plus Dark Mode | 2.7+ | UI组件库暗色模式支持 |
| Spring MessageSource | Spring Framework 6 | 后端国际化消息源 |
| AcceptHeaderLocaleResolver | Spring Framework 6 | 后端语言解析 |

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-07 | 前端Lead | 初始版本：前端主题与国际化完整设计方案 |
