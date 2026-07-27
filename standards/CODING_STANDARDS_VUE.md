# SmartWin Vue 3 编码规范

## 文档信息
- **版本**: 1.0.0
- **适用**: Vue 3, TypeScript, Pinia

---

## 1. 组件规范

### 1.1 组件命名
- 文件名: PascalCase，示例: `DataAssetList.vue`
- 组件名: PascalCase多词，示例: `DataAssetCard`
- 单文件组件结构:
  ```
  <script setup lang="ts">
  // 1. 导入
  // 2. Props/Emits定义
  // 3. 响应式数据
  // 4. 计算属性
  // 5. 方法
  // 6. 生命周期
  </script>
  
  <template>
    <!-- 模板 -->
  </template>
  
  <style scoped lang="scss">
  /* 样式 */
  </style>
  ```

### 1.2 组件目录结构
```
src/
├── components/          # 通用组件
│   ├── common/         # 基础UI组件
│   └── business/       # 业务组件
├── views/              # 页面组件
├── layouts/            # 布局组件
├── composables/        # 可复用逻辑
├── stores/             # Pinia状态管理
├── router/             # 路由配置
├── api/                # API接口
├── types/              # TypeScript类型定义
└── utils/              # 工具函数
```

---

## 2. TypeScript规范

### 2.1 类型定义
```typescript
// types/dataAsset.ts
export interface DataAsset {
  id: number
  name: string
  description?: string
  status: DataAssetStatus
  createdAt: string
  updatedAt: string
}

export type DataAssetStatus = 'active' | 'inactive' | 'pending'

export interface DataAssetListRequest {
  page: number
  pageSize: number
  keyword?: string
  status?: DataAssetStatus
}

export interface PageResult<T> {
  data: T[]
  total: number
  page: number
  pageSize: number
}
```

### 2.2 Props定义
```typescript
interface Props {
  assetId: number
  readonly?: boolean
  onSuccess?: (asset: DataAsset) => void
}

const props = withDefaults(defineProps<Props>(), {
  readonly: false,
})
```

---

## 3. Pinia状态管理

### 3.1 Store命名和结构
```typescript
// stores/dataAsset.ts
import { defineStore } from 'pinia'
import type { DataAsset, DataAssetListRequest } from '@/types/dataAsset'
import { dataAssetApi } from '@/api/dataAsset'

export const useDataAssetStore = defineStore('dataAsset', () => {
  // State
  const assets = ref<DataAsset[]>([])
  const loading = ref(false)
  const total = ref(0)

  // Getters
  const activeAssets = computed(() =>
    assets.value.filter(a => a.status === 'active')
  )

  // Actions
  async function fetchAssets(params: DataAssetListRequest) {
    loading.value = true
    try {
      const result = await dataAssetApi.list(params)
      assets.value = result.data
      total.value = result.total
    } finally {
      loading.value = false
    }
  }

  return { assets, loading, total, activeAssets, fetchAssets }
})
```

---

## 4. API封装规范

```typescript
// api/dataAsset.ts
import { request } from '@/utils/request'
import type { DataAsset, DataAssetListRequest, PageResult } from '@/types/dataAsset'

export const dataAssetApi = {
  list(params: DataAssetListRequest): Promise<PageResult<DataAsset>> {
    return request.get('/api/v1/data-assets', { params })
  },

  getById(id: number): Promise<DataAsset> {
    return request.get(`/api/v1/data-assets/${id}`)
  },

  create(data: Partial<DataAsset>): Promise<DataAsset> {
    return request.post('/api/v1/data-assets', data)
  },

  update(id: number, data: Partial<DataAsset>): Promise<DataAsset> {
    return request.put(`/api/v1/data-assets/${id}`, data)
  },

  delete(id: number): Promise<void> {
    return request.delete(`/api/v1/data-assets/${id}`)
  },
}
```

---

## 5. 样式规范

### 5.1 CSS/SCSS组织
```scss
// 使用BEM命名
.data-asset-card {
  // 组件根样式

  &__header {
    // 子元素
  }

  &__content {
    // 子元素
  }

  &--active {
    // 修饰符
  }
}

// 使用CSS变量
.data-asset-card {
  background: var(--color-bg-secondary);
  border-radius: var(--border-radius-md);
  padding: var(--spacing-md);
}
```

### 5.2 样式规则
- 使用 `scoped` 样式防止污染
- 全局样式放在 `src/styles/` 目录
- 颜色、间距等使用CSS变量/Design Token
- 禁止使用内联样式（除非动态绑定）

---

## 6. 性能优化规范

### 6.1 组件优化
```typescript
// 使用 v-memo 缓存列表项
// 使用 defineAsyncComponent 懒加载
const HeavyComponent = defineAsyncComponent(
  () => import('./HeavyComponent.vue')
)

// 使用 shallowRef/shallowReactive 处理大型对象
const bigData = shallowRef<BigDataType[]>([])

// v-for 必须使用唯一 key
// <div v-for="item in items" :key="item.id">
```

### 6.2 路由懒加载
```typescript
const routes = [
  {
    path: '/data-assets',
    component: () => import('@/views/DataAssetList.vue'),
  },
]
```

---

*版本: 1.0.0 | 最后更新: 2026-07-27*
