# DES-07 UIUX设计规范

## 文档控制

| 信息项 | 内容 |
|--------|------|
| **文档编号** | DES-07 |
| **文档版本** | V1.0 |
| **创建日期** | 2026-07-10 |
| **最后修订** | 2026-07-10 |
| **文档状态** | 正式发布 |
| **文档负责人** | UI/UX设计组 |
| **审批人** | 前端Lead |
| **关联文档** | DES-06 前端架构设计说明书、DES-12 品牌与前端设计方案、DES-10 前端主题与国际化设计方案 |

---

## 一、设计规范概述

### 1.1 目的

本规范为「智赢(智数+智链)双平台」项目建立统一的UI/UX设计标准，确保全平台界面视觉一致性、交互流畅性和用户体验专业性。涵盖设计令牌、组件规范、交互模式、响应式适配和无障碍标准。

### 1.2 适用范围

- 智链AI模型治理与监控平台（SmartChain）—— 61个前端页面
- 智数AI原生数据治理平台（SmartData）—— 47个前端页面
- 共享组件库（shared-components）—— 19个共享组件 + 7个组合式函数
- 品牌官网与营销页面

### 1.3 设计原则

| 原则 | 说明 | 实现方式 |
|------|------|----------|
| **一致性** | 全平台视觉和交互统一 | CSS变量+共享组件库 |
| **层次性** | 信息架构清晰，视觉层次分明 | 间距令牌+字重层级 |
| **反馈性** | 每个操作都有即时视觉反馈 | 微交互动画+Toast通知 |
| **效率性** | 减少用户操作步骤 | 命令面板+快捷键+批量操作 |
| **包容性** | 支持不同能力和设备 | 响应式+a11y+暗色模式 |
| **科技感** | 现代化、专业、有科技质感 | 渐变+毛玻璃+微动画+SVG图标 |

---

## 二、设计令牌体系

### 2.1 色彩令牌

#### 2.1.1 品牌色

| 令牌 | 浅色模式 | 深色模式 | 用途 |
|------|----------|----------|------|
| `--brand-primary` | #2563eb | #3b82f6 | 主按钮、链接、选中态 |
| `--brand-primary-light` | #dbeafe | #1e3a5f | 主色浅底、hover态 |
| `--brand-primary-dark` | #1d4ed8 | #60a5fa | 主色深色变体 |
| `--brand-accent` | #8b5cf6 | #a78bfa | 强调色、标签 |
| `--brand-accent-light` | #ede9fe | #3c2a5e | 强调色浅底 |
| `--brand-gradient` | linear-gradient(135deg, #2563eb, #8b5cf6) | 同左 | 渐变背景 |

#### 2.1.2 语义色

| 令牌 | 浅色模式 | 深色模式 | 用途 |
|------|----------|----------|------|
| `--color-success` | #16a34a | #4ade80 | 成功状态 |
| `--color-success-bg` | #dcfce7 | #052e16 | 成功背景 |
| `--color-warning` | #f59e0b | #fbbf24 | 警告状态 |
| `--color-warning-bg` | #fef3c7 | #422006 | 警告背景 |
| `--color-danger` | #dc2626 | #f87171 | 错误/危险状态 |
| `--color-danger-bg` | #fee2e2 | #450a0a | 错误背景 |
| `--color-info` | #0891b2 | #22d3ee | 信息提示 |
| `--color-info-bg` | #cffafe | #083344 | 信息背景 |

#### 2.1.3 中性色

| 令牌 | 浅色模式 | 深色模式 | 用途 |
|------|----------|----------|------|
| `--color-bg` | #f0f2f5 | #0f172a | 页面背景 |
| `--color-card` | #ffffff | #1e293b | 卡片背景 |
| `--color-text` | #1e293b | #f1f5f9 | 主文本 |
| `--color-text-secondary` | #64748b | #94a3b8 | 次要文本 |
| `--color-text-disabled` | #94a3b8 | #475569 | 禁用文本 |
| `--color-border` | #e5e7eb | #334155 | 边框 |
| `--color-border-light` | #f3f4f6 | #1e293b | 浅色边框 |

### 2.2 间距令牌

| 令牌 | 值 | 用途 |
|------|:---:|------|
| `--space-xs` | 4px | 紧凑间距（图标与文字） |
| `--space-sm` | 8px | 小间距（卡片内元素） |
| `--space-md` | 12px | 中间距（卡片间距） |
| `--space-lg` | 16px | 大间距（区块内间距） |
| `--space-xl` | 24px | 超大间距（区块间间距） |
| `--space-2xl` | 32px | 双倍超大间距（页面内边距） |

### 2.3 圆角令牌

| 令牌 | 值 | 用途 |
|------|:---:|------|
| `--radius-sm` | 6px | 小圆角（按钮、标签） |
| `--radius-md` | 10px | 中圆角（卡片、面板） |
| `--radius-lg` | 16px | 大圆角（模态框、弹窗） |
| `--radius-full` | 9999px | 全圆角（头像、药丸标签） |

### 2.4 字体令牌

| 令牌 | 值 | 用途 |
|------|------|------|
| `--font-family` | -apple-system, BlinkMacSystemFont, "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif | 全局字体 |
| `--font-mono` | "JetBrains Mono", "Fira Code", "Cascadia Code", Consolas, monospace | 代码字体 |
| `--font-size-xs` | 11px | 辅助文字 |
| `--font-size-sm` | 12px | 次要文字 |
| `--font-size-base` | 14px | 正文 |
| `--font-size-lg` | 16px | 标题 |
| `--font-size-xl` | 20px | 区块标题 |
| `--font-size-2xl` | 28px | 页面标题 |
| `--font-weight-normal` | 400 | 正文 |
| `--font-weight-medium` | 500 | 次要标题 |
| `--font-weight-semibold` | 600 | 卡片标题 |
| `--font-weight-bold` | 700 | 页面标题 |
| `--font-weight-extrabold` | 800 | KPI数值 |

### 2.5 阴影令牌

| 令牌 | 值 | 用途 |
|------|------|------|
| `--shadow-sm` | 0 1px 2px rgba(0,0,0,.04) | 轻微阴影 |
| `--shadow` | 0 1px 3px rgba(0,0,0,.08), 0 1px 2px rgba(0,0,0,.06) | 默认卡片阴影 |
| `--shadow-lg` | 0 10px 25px rgba(0,0,0,.08), 0 4px 10px rgba(0,0,0,.04) | 悬浮卡片阴影 |
| `--shadow-glow` | 0 0 20px rgba(37,99,235,.15) | 品牌发光阴影 |

### 2.6 过渡令牌

| 令牌 | 值 | 用途 |
|------|------|------|
| `--transition-fast` | all .15s ease | 快速过渡（按钮hover） |
| `--transition` | all .2s ease | 默认过渡（卡片hover） |
| `--transition-slow` | all .3s ease | 慢速过渡（面板展开） |
| `--transition-bounce` | all .3s cubic-bezier(.34,1.56,.64,1) | 弹性过渡（弹出动画） |

### 2.7 Z-index令牌

| 令牌 | 值 | 用途 |
|------|:---:|------|
| `--z-dropdown` | 100 | 下拉菜单 |
| `--z-sticky` | 200 | 粘性定位 |
| `--z-modal` | 1000 | 模态框 |
| `--z-toast` | 2000 | Toast通知 |
| `--z-tooltip` | 3000 | Tooltip |
| `--z-command-palette` | 5000 | 命令面板 |

---

## 三、品牌预设系统

### 3.1 品牌预设列表

系统支持6种品牌预设，通过CSS变量一键切换：

| 品牌名称 | 主色 | 强调色 | 适用场景 |
|----------|------|--------|----------|
| SmartWin（默认） | #2563eb | #8b5cf6 | 智赢集成平台 |
| SmartChain | #0891b2 | #6366f1 | 智链独立部署 |
| SmartData | #16a34a | #f59e0b | 智数独立部署 |
| Enterprise | #1e293b | #475569 | 企业内网部署 |
| Government | #b91c1c | #f59e0b | 政务信创部署 |
| Custom | 用户自定义 | 用户自定义 | OEM定制 |

### 3.2 品牌切换实现

```typescript
// 通过 theme store 切换品牌
const { brand, setBrand } = useTheme();
setBrand('smartchain'); // 切换至智链品牌
```

---

## 四、组件设计规范

### 4.1 共享组件库概览

| 组件 | 用途 | 关键Props | 状态 |
|------|------|-----------|:----:|
| AppLayout | 应用主布局框架 | sidebar, header, content | ✅ |
| Breadcrumb | 面包屑导航 | items[] | ✅ |
| Pagination | 分页器 | current, total, pageSize | ✅ |
| SearchBar | 搜索栏 | placeholder, onSearch | ✅ |
| StatCard | 统计卡片 | icon, value, label, trend | ✅ |
| ChartSwitcher | 图表切换器 | charts[], onSwitch | ✅ |
| ConfirmDialog | 确认对话框 | title, message, onConfirm | ✅ |
| ToastContainer | Toast通知容器 | — | ✅ |
| EmptyState | 空状态 | icon, title, description, action | ✅ |
| SkeletonLoader | 骨架屏 | type, count | ✅ |
| DateRangePicker | 日期范围选择 | modelValue, presets | ✅ |
| ExportButton | 数据导出 | formats[], onExport | ✅ |
| BatchActionBar | 批量操作栏 | selected, actions[] | ✅ |
| SavedFilters | 筛选预设 | filters[], onSave | ✅ |
| VersionDiff | 版本对比 | oldVersion, newVersion | ✅ |
| GlobalSearch | 全局搜索 | onSearch, results | ✅ |
| NotificationCenter | 通知中心 | notifications[] | ✅ |
| OnboardingTour | 新手引导 | steps[] | ✅ |
| HelpFeedback | 帮助反馈 | — | ✅ |
| CommandPalette | 命令面板 | commands[], shortcut | ✅ |
| TabBar | 多标签页 | tabs[], activeTab | ✅ |
| ThemeSwitcher | 主题切换 | mode, onSwitch | ✅ |
| LangSwitcher | 语言切换 | locale, onSwitch | ✅ |
| TemplateGallery | 模板库 | templates[], onSelect | ✅ |
| StepWizard | 分步向导 | steps[], current | ✅ |
| CountUp | 数字递增动画 | start, end, duration | ✅ |

### 4.2 组件设计标准

#### 4.2.1 按钮规范

| 类型 | 背景 | 文字 | 圆角 | 用途 |
|------|------|------|:----:|------|
| Primary | var(--brand-primary) | #fff | sm | 主操作（提交/保存） |
| Secondary | var(--color-card) | var(--color-text) | sm | 次要操作（取消） |
| Ghost | transparent | var(--brand-primary) | sm | 文字按钮 |
| Danger | var(--color-danger) | #fff | sm | 危险操作（删除） |
| Icon | transparent | var(--color-text-secondary) | full | 图标按钮 |

#### 4.2.2 表单规范

| 元素 | 高度 | 圆角 | 边框 | 聚焦态 |
|------|:----:|:----:|------|--------|
| Input | 36px | sm | var(--color-border) | border-color: var(--brand-primary) |
| Select | 36px | sm | var(--color-border) | border-color: var(--brand-primary) |
| Textarea | auto | sm | var(--color-border) | border-color: var(--brand-primary) |
| Checkbox | 16px | sm | var(--color-border) | bg: var(--brand-primary) |
| Radio | 16px | full | var(--color-border) | border-color: var(--brand-primary) |
| Switch | 24px | full | — | bg: var(--brand-primary) |

#### 4.2.3 表格规范

| 元素 | 规范 |
|------|------|
| 表头背景 | var(--color-border-light) |
| 表头字重 | var(--font-weight-semibold) |
| 行高 | 44px |
| 斑马纹 | 偶数行 var(--color-border-light) |
| 悬浮行 | var(--brand-primary-light) |
| 选中行 | var(--brand-primary-light) |
| 排序图标 | SVG arrow-up/arrow-down |

#### 4.2.4 卡片规范

| 属性 | 值 |
|------|------|
| 背景 | var(--color-card) |
| 圆角 | var(--radius-md) |
| 阴影 | var(--shadow) |
| 内边距 | var(--space-lg) |
| 悬浮阴影 | var(--shadow-lg) |
| 边框 | 1px solid var(--color-border) |

---

## 五、交互设计规范

### 5.1 微交互动画体系

| 交互场景 | 动画类型 | 时长 | 缓动函数 |
|----------|----------|:----:|----------|
| 按钮hover | 背景色过渡 | .15s | ease |
| 按钮click | 缩放反馈 | .1s | ease |
| 卡片hover | 上移+阴影增强 | .2s | ease |
| 页面切换 | 淡入+滑动 | .3s | ease |
| 模态框打开 | 缩放+淡入 | .3s | cubic-bezier(.34,1.56,.64,1) |
| 模态框关闭 | 缩放+淡出 | .2s | ease |
| Toast出现 | 右侧滑入 | .3s | ease |
| Toast消失 | 右侧滑出 | .3s | ease |
| 下拉展开 | 高度展开+淡入 | .2s | ease |
| 标签页切换 | 淡入 | .15s | ease |
| 滚动渐入 | 上移+淡入 | .4s | ease |
| 数字递增 | CountUp动画 | 1s | ease-out |
| 骨架屏 | 光波扫描 | 1.5s | ease-in-out (infinite) |
| 进度条 | 宽度过渡 | .8s | ease |

### 5.2 键盘快捷键体系

| 快捷键 | 功能 | 适用场景 |
|--------|------|----------|
| `Cmd/Ctrl + K` | 打开命令面板 | 全局 |
| `Cmd/Ctrl + Shift + F` | 全局搜索 | 全局 |
| `Cmd/Ctrl + B` | 折叠/展开侧边栏 | 全局 |
| `Cmd/Ctrl + ,` | 打开设置 | 全局 |
| `Escape` | 关闭弹窗/面板 | 弹窗/面板 |
| `Tab` | 下一个焦点 | 表单 |
| `Shift + Tab` | 上一个焦点 | 表单 |
| `Enter` | 确认/提交 | 表单/对话框 |
| `↑/↓` | 上下导航 | 列表/表格 |
| `←/→` | 前进/后退 | 标签页 |

### 5.3 反馈规范

| 场景 | 反馈方式 | 持续时间 |
|------|----------|:--------:|
| 操作成功 | Toast success | 3s |
| 操作失败 | Toast error | 5s |
| 操作警告 | Toast warning | 4s |
| 信息提示 | Toast info | 3s |
| 加载中 | SkeletonLoader / Spinner | 直到完成 |
| 删除确认 | ConfirmDialog | 用户确认 |
| 批量操作结果 | Toast + 高亮变更项 | 3s |
| 表单验证错误 | 行内红色提示 | 持续 |
| 网络异常 | Toast error + 重试按钮 | 5s |

---

## 六、响应式设计规范

### 6.1 断点定义

| 断点 | 宽度 | 设备 | 布局调整 |
|------|------|------|----------|
| `xs` | <768px | 手机 | 单列、抽屉侧边栏、卡片视图 |
| `sm` | ≥768px | 平板 | 双列、折叠侧边栏 |
| `md` | ≥1024px | 小屏笔记本 | 三列、固定侧边栏 |
| `lg` | ≥1280px | 标准桌面 | 完整布局 |
| `xl` | ≥1536px | 大屏 | 宽布局 |

### 6.2 响应式策略

| 组件 | 桌面端 | 移动端 |
|------|--------|--------|
| 侧边栏 | 固定展开 | 抽屉式（汉堡菜单触发） |
| 表格 | 完整列展示 | 横向滚动 + 卡片视图切换 |
| 搜索栏 | 顶部固定 | 底部浮动按钮 |
| 筛选器 | 侧边面板 | 底部弹出Sheet |
| 分页器 | 完整页码 | 简化（上一页/下一页） |
| 统计卡片 | 4列网格 | 1列堆叠 |
| 图表 | 完整尺寸 | 简化+横向滚动 |

---

## 七、无障碍设计规范（a11y）

### 7.1 WCAG 2.1 AA 合规项

| 检查项 | 标准 | 实现方式 |
|--------|------|----------|
| 颜色对比度 | ≥4.5:1（正文）/ 3:1（大文字） | CSS变量色板验证 |
| 键盘可操作 | 所有功能键盘可达 | tabindex + 键盘事件 |
| 焦点可见 | 焦点有明显视觉提示 | :focus-visible 样式 |
| ARIA标签 | 交互元素有aria-label | 组件Props传入 |
| 屏幕阅读器 | 语义化HTML + role属性 | 使用nav/main/aside等 |
| 表单标签 | label与input关联 | for/id绑定 |
| 模态框 | focus trap + Esc关闭 | useFocusTrap composable |
| 图片替代 | 所有img有alt | alt属性必填 |

### 7.2 已适配组件

以下共享组件已完成a11y基础适配：
- ConfirmDialog（focus trap + Esc + ARIA）
- ToastContainer（aria-live="polite"）
- Pagination（aria-label + role）
- SearchBar（aria-label + autocomplete）
- OnboardingTour（aria-describedby + Esc）
- CommandPalette（role="dialog" + focus management）

---

## 八、SVG图标系统规范

### 8.1 图标设计标准

| 属性 | 标准 |
|------|------|
| 格式 | SVG（内联，非img引用） |
| 尺寸 | 16px / 20px / 24px / 32px |
| 线宽 | 1.5px / 2px |
| 颜色 | currentColor（继承文本色） |
| 视图框 | 24x24（默认） |
| 填充 | fill="none" stroke="currentColor" |

### 8.2 图标注册系统

所有图标通过 `icons/registry.ts` 统一注册，组件通过 `Icon` 组件引用：

```vue
<Icon name="dashboard" :size="20" />
<Icon name="model" :size="16" color="var(--brand-primary)" />
```

### 8.3 禁止事项

- ❌ 禁止使用Emoji作为功能图标
- ❌ 禁止使用img标签引用图标
- ❌ 禁止硬编码图标颜色（使用currentColor）
- ✅ 所有功能图标使用SVG系统

---

## 九、暗色模式规范

### 9.1 三种模式

| 模式 | 说明 | 检测方式 |
|------|------|----------|
| `light` | 强制浅色 | 用户手动选择 |
| `dark` | 强制深色 | 用户手动选择 |
| `auto` | 跟随系统 | `prefers-color-scheme` |

### 9.2 实现方式

```css
:root[data-theme="light"] { /* 浅色变量 */ }
:root[data-theme="dark"] { /* 深色变量 */ }
```

### 9.3 图表暗色适配

ECharts图表通过 `useEchartsTheme` composable 自动适配暗色模式，切换时重新渲染。

---

## 十、国际化设计规范

### 10.1 文案规范

| 规范 | 说明 | 示例 |
|------|------|------|
| 不硬编码中文 | 所有文案通过t()函数引用 | `{{ t('common.save') }}` |
| i18n Key命名 | module.page.element | `smartchain.agent.list.title` |
| 模块拆分 | 按功能模块拆分locale文件 | common.ts / smartchain.ts / smartdata.ts |
| 占位符 | 使用命名占位符 | `t('msg.welcome', { name: userName })` |

### 10.2 支持语言

| 语言 | locale | 状态 |
|------|--------|:----:|
| 简体中文 | zh-CN | ✅ |
| English | en-US | ✅ |
| 繁体中文 | zh-TW | 📋 计划中 |
| 日本語 | ja-JP | 📋 计划中 |

---

## 十一、PWA设计规范

### 11.1 PWA配置

| 配置项 | 值 |
|--------|------|
| manifest.json | `/public/manifest.json` |
| Service Worker | `/public/sw.js` |
| 缓存策略 | App Shell + 运行时缓存 |
| 离线降级 | 缓存页面 + 离线提示 |
| 安装提示 | beforeinstallprompt事件 |

### 11.2 图标规范

| 尺寸 | 用途 |
|:----:|------|
| 192x192 | PWA标准图标 |
| 512x512 | PWA高清图标 |
| maskable | 自适应图标 |
| favicon | 浏览器标签图标 |

---

## 十二、性能设计规范

### 12.1 性能指标

| 指标 | 目标 | 当前 |
|------|:----:|:----:|
| 首屏加载(FCP) | <1.5s | 1.2s |
| 可交互时间(TTI) | <3s | 2.5s |
| 路由切换 | <200ms | 150ms |
| API响应(P95) | <200ms | 156ms |
| Lighthouse评分 | ≥90 | 92 |

### 12.2 优化策略

| 策略 | 实现方式 |
|------|----------|
| 路由懒加载 | `() => import()` 动态导入 |
| 组件按需加载 | 异步组件 + Suspense |
| 图片懒加载 | IntersectionObserver |
| 虚拟滚动 | 大列表虚拟化 |
| 骨架屏 | 数据加载时显示Skeleton |
| 防抖节流 | useDebounce/useThrottle |
| 缓存策略 | Service Worker + Redis |

---

## 十三、实施检查清单

### 13.1 页面开发检查清单

- [ ] 使用共享组件库组件，无重复造轮子
- [ ] 所有文案使用t()国际化函数，无硬编码中文
- [ ] 所有图标使用SVG图标系统，无Emoji
- [ ] 使用CSS变量，无硬编码颜色值
- [ ] 使用设计令牌间距，无硬编码margin/padding
- [ ] 数据加载使用SkeletonLoader骨架屏
- [ ] 操作反馈使用Toast通知，无alert/confirm/prompt
- [ ] 列表页支持搜索、排序、分页、批量操作、数据导出
- [ ] 表单使用useFormValidation验证
- [ ] 响应式适配（桌面+移动端）
- [ ] 暗色模式兼容
- [ ] a11y基础适配（ARIA + 键盘导航）
- [ ] 微交互动画使用transitions.css定义

---

## 修订记录

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| V1.0 | 2026-07-10 | UI/UX设计组 | 初始版本发布，涵盖设计令牌、品牌预设、组件规范、交互设计、响应式、无障碍、SVG图标、暗色模式、国际化、PWA、性能规范 |
