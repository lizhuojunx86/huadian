# T-P0-012 Web 首页 + 全局导航

| 字段 | 值 |
|------|-----|
| **ID** | T-P0-012 |
| **标题** | Web 首页 + 全局导航 |
| **状态** | `in_progress` |
| **Phase** | Phase 0 |
| **主导角色** | 前端工程师 |
| **协作角色** | 后端工程师（S-4 stats query） |
| **依赖** | T-P0-008 ✅ / T-P0-009 ✅ |
| **创建日期** | 2026-04-18 |

---

## 背景

Phase 0 已有 `/persons` 搜索页和 `/persons/[slug]` 详情页，但根路径 `/` 是 Next.js 默认 stub。
需要实现一个真正的"古籍 AI 知识平台"入口页，并建立全局导航骨架。

完成后站点形态：
- `/` → 首页（Hero + 搜索 + 推荐人物 + 数据概览）
- `/persons` → 搜索/列表
- `/persons/[slug]` → 详情
- `/about` → 项目简介

## 预批决定

1. 沿用 T-P0-008/009 UI/UX 豁免：shadcn 默认样式 + Tailwind，视觉打磨延后
2. 不引入新依赖（Tailwind / shadcn / next-image 已有的够用）
3. 推荐人物 MVP 硬编码 6 slug：`huang-di` / `yao` / `shun` / `yu` / `tang` / `xi-bo-chang`
4. 运行时 fetch 这 6 人的基本信息展示
5. Future Work：动态推荐（基于 identity_notes 丰富度 / names 数量 / 引用计数）

## 核对结果

- [x] 6 个推荐人物 slug 均已验证存在于 DB
  - `huang-di`（黄帝）/ `yao`（尧）/ `shun`（舜）/ `yu`（禹）/ `tang`（汤）/ `xi-bo-chang`（西伯昌）
- [x] 当前 `app/page.tsx` 是 stub（h1 + p 标签）
- [x] 当前 `app/layout.tsx` 无 Header / Footer
- [x] GraphQL schema 无 stats query → S-4 需新增
- [x] DB 当前数据：157 persons / 272 names / 3 books

---

## 子任务

### S-1 布局骨架
- `app/layout.tsx` 加 Header + Footer slots
- 新建 `components/layout/Header.tsx`
  - Logo / 站名"华典智谱" → 链接首页
  - 导航链接：[人物](/persons)、[关于](/about)
  - 当前路由高亮（`useSelectedLayoutSegment`）
- 新建 `components/layout/Footer.tsx`
  - 项目简介一行 + GitHub 链接 + 版权 © 2026

### S-2 首页 Hero
- 站名 + 一句话定位（"探索中国古籍中的人物、事件与地理"）
- 主搜索框（`onSubmit` → `router.push('/persons?q=...')`）
- 视觉：居中大标题 + 搜索框，简洁古风感

### S-3 "知名人物"区
- 硬编码 6 slug 数组
- Server Component 复用 `PersonQuery`，`Promise.all` 并发 fetch
- 新建 `components/home/FeaturedPersonCard.tsx`
  - 展示：name.zhHans / dynasty / slug 链接
  - 基于 shadcn Card 组件
- 6 张卡片网格布局（桌面 3 列，移动 2 列）

### S-4 "数据概览"（含 API 扩展）
- **SDL 扩展**：`queries.graphql` 新增 `stats: Stats!`
- **新增类型**：`Stats { personsCount: Int!, namesCount: Int!, booksCount: Int! }`
- **Resolver**：`query.ts` 新增 stats resolver（3 个 COUNT 查询）
- **Web codegen** 更新
- 新建 `components/home/StatsBlock.tsx`
  - 三个数字卡片：人物数 / 别名数 / 典籍数
- 新建 `lib/graphql/queries/stats.ts`

### S-5 "探索全部" CTA
- 底部引导按钮 → `/persons`
- 文案："探索全部人物 →"

### S-6 /about 页
- `app/about/page.tsx`
- 最小内容：
  - 项目简介（一段话）
  - 技术栈列表
  - 开源 / 联系方式占位
- 纯 JSX，不引入 MDX

### S-7 SEO metadata
- `app/page.tsx`：`generateMetadata` — title / description / OG 基础
- `app/about/page.tsx`：`generateMetadata`

### S-8 vitest 单元测试（≥ 8 cases）
- Header 渲染 + 导航链接
- Footer 渲染 + 版权文本
- FeaturedPersonCard 渲染 + 链接正确性
- StatsBlock 数字展示
- 搜索框提交行为

### S-9 Playwright E2E（3 cases）
- 首页加载 → 看到推荐卡片
- 搜索框输入 → 回车 → 跳转 `/persons?q=xxx`
- 导航点击"关于" → `/about` 页

### S-10 收尾
- STATUS.md 更新
- CHANGELOG.md 追加
- T-000-index.md 更新（T-P0-012 done + 原 T-P0-012 重编号为 T-P0-014）

---

## 技术要点

- **Header 路由高亮**：`useSelectedLayoutSegment()` 判断当前段
- **推荐人物数据获取**：Server Component 直接 fetch，无需客户端状态
- **Stats query**：走 SDL 扩展 + codegen，不直接访问 DB
- **响应式**：shadcn 组件 + Tailwind breakpoints（`md:` / `lg:`）
- **搜索框**：非受控 form + `action` 或 `onSubmit`，跳转而非 AJAX

## 不做的事

- 不做动态推荐算法
- 不做 i18n（Phase 1）
- 不做 Sentry 接入（Phase 1）
- 不做埋点（Phase 1）
- 不做 SSG/ISR 优化（Phase 1）

## Future Work

- 动态推荐人物（基于 identity_notes 丰富度 / names 数量 / 引用计数）
- 首页更多区块（最近更新的人物、事件时间线预览等）
- 深色模式支持
- 首页性能优化（ISR / 缓存）
