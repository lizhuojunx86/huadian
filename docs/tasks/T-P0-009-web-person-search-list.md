# T-P0-009 — Web 人物搜索 / 列表页

> **状态**：`in_progress`
> **主导角色**：前端工程师
> **协作角色**：后端工程师（API 扩展，本 session 授权直接改）
> **依赖**：T-P0-007 ✅ / T-P0-008 ✅
> **创建日期**：2026-04-18

---

## 目标

实现 `/persons` 列表 + 搜索页，让用户从首页入口即可搜索人物、点进详情页。
跨栈任务：API 需增加 search 参数 + PersonSearchResult 类型。

---

## DoD（Definition of Done）

- [ ] `/persons` 路由渲染人物列表，默认展示前 20 条
- [ ] 搜索框输入关键词后，列表实时过滤（300ms 防抖）
- [ ] URL 保持 `?search=xxx&page=1` 状态，可直接分享/刷新
- [ ] 分页组件（上一页/下一页 + total 显示）
- [ ] 列表项点击跳转 `/persons/[slug]`
- [ ] 三态完整：加载中（骨架屏）/ 空结果提示 / 错误重试
- [ ] API `persons(search, limit, offset)` 返回 `PersonSearchResult`
- [ ] pg_trgm 相似度搜索（阈值 0.3）+ ILIKE fallback
- [ ] API 集成测试覆盖 search + 分页 + 空结果
- [ ] vitest 单元测试 + Playwright E2E 冒烟
- [ ] lint / typecheck / build / codegen 全绿

---

## 预裁决策（Q-1 ~ Q-7）

| # | 问题 | 裁定 |
|---|------|------|
| Q-1 | 搜索实现方式 | PostgreSQL pg_trgm 相似度，阈值 0.3，fallback ILIKE（pg_trgm 未启用时） |
| Q-2 | 分页方式 | offset/limit，默认 limit=20，max=100 |
| Q-3 | URL 状态管理 | Next.js `useSearchParams`，不引入 nuqs |
| Q-4 | 防抖策略 | 300ms，自写 `useDebounce` hook，不引入 use-debounce |
| Q-5 | 数据获取 | URL-driven SSR（Server Component fetch），不引入 @tanstack/react-query |
| Q-6 | 列表项点击 | → `/persons/[slug]`（复用 T-P0-008 详情页） |
| Q-7 | 三态 | 空结果 / loading / error 全部实现 |

---

## 子任务

### S-0 任务卡起草
- [x] 起草本任务卡含 DoD / 子任务 / Q-1~Q-7 裁定

### S-1 API: SDL 扩展
- [ ] `services/api/src/schema/queries.graphql`：
  - `persons(search: String, limit: Int = 20, offset: Int = 0): PersonSearchResult!`
- [ ] `services/api/src/schema/b-persons.graphql`：
  - 新增 `type PersonSearchResult { items: [Person!]! total: Int! hasMore: Boolean! }`
- [ ] 运行 codegen 更新 TS 类型

### S-2 API: service + resolver 实现
- [ ] `person.service.ts` 新增 `searchPersons(db, search?, limit, offset)`:
  - search 非空时：`similarity(person_names.name, $search) > 0.3 OR persons.name->>'zh-Hans' ILIKE '%$search%'`
  - 结合 `person_names` 表 trigram 索引
  - 返回 `{ items, total, hasMore }`
  - SQL 全部用 Drizzle `sql` template，零字符串拼接
- [ ] `query.ts` resolver 更新 `persons` 调用新 service
- [ ] 原有 `findPersons` 可能被替代或复用

### S-3 API: 集成测试
- [ ] 新增 `person-search.integration.test.ts`
- [ ] 覆盖场景：
  - search 匹配（trigram / ILIKE）
  - search 无匹配 → `{ items: [], total: 0, hasMore: false }`
  - 分页 limit/offset
  - search 为空/undefined → 全量列表
  - soft-deleted 排除

### S-4 Web: codegen 更新
- [ ] `pnpm --filter web codegen` 更新前端类型
- [ ] 新增 GraphQL query: `PersonsSearchQuery`

### S-5 Web: /persons 路由 + Server Component
- [ ] `apps/web/app/persons/page.tsx` — 读 searchParams → fetch → render
- [ ] `apps/web/app/persons/layout.tsx` — 页面标题 metadata

### S-6 Web: SearchBar 客户端组件
- [ ] `apps/web/components/person-search/SearchBar.tsx`
  - 'use client'
  - 受控 input，300ms 防抖
  - `router.replace` 更新 URL `?search=xxx`
- [ ] `apps/web/lib/hooks/useDebounce.ts` — 通用防抖 hook

### S-7 Web: PersonListItem + PersonList
- [ ] `apps/web/components/person-search/PersonListItem.tsx` — 紧凑卡片（name / dynasty / slug link）
- [ ] `apps/web/components/person-search/PersonList.tsx` — 列表容器

### S-8 Web: Pagination 组件
- [ ] `apps/web/components/person-search/Pagination.tsx`
  - 上一页 / 下一页按钮
  - 显示 total 和当前页码
  - `router.replace` 更新 URL `?page=N`

### S-9 Web: loading / 空结果 / error
- [ ] `apps/web/app/persons/loading.tsx` — 骨架屏
- [ ] `apps/web/app/persons/error.tsx` — 错误边界 + 重试
- [ ] 空结果：在 PersonList 中显示提示

### S-10 测试
- [ ] vitest 单元测试（SearchBar / PersonListItem / Pagination / useDebounce）
- [ ] Playwright E2E 冒烟：有结果 + 空结果（2 cases）

### S-11 收尾
- [ ] STATUS.md 更新
- [ ] CHANGELOG.md 追加
- [ ] T-000-index.md 更新
- [ ] lint / typecheck / build 全绿

---

## 搜索 SQL 策略

```sql
-- When search is provided:
-- 1. Join persons with person_names for trigram search
-- 2. Use similarity() on person_names.name (has GIN trigram index)
-- 3. Also ILIKE on persons.name->>'zh-Hans' for direct match
-- 4. Deduplicate by person id
-- 5. Order by similarity score DESC

SELECT DISTINCT ON (p.id) p.*,
  GREATEST(
    similarity(pn.name, $1),
    CASE WHEN p.name->>'zh-Hans' ILIKE '%' || $1 || '%' THEN 0.5 ELSE 0 END
  ) AS score
FROM persons p
LEFT JOIN person_names pn ON pn.person_id = p.id
WHERE p.deleted_at IS NULL
  AND (
    similarity(pn.name, $1) > 0.3
    OR p.name->>'zh-Hans' ILIKE '%' || $1 || '%'
  )
ORDER BY p.id, score DESC
-- Then re-order by score DESC, apply LIMIT/OFFSET
```

Fallback: If `similarity()` function is unavailable, use pure ILIKE.

---

## 风险

| 风险 | 缓解 |
|------|------|
| pg_trgm extension 未启用 | Docker init script 已启用；fallback ILIKE 确保功能可用 |
| 搜索性能（大数据集） | Phase 0 数据量 <100 条，暂无性能风险；GIN 索引已就位 |
| SDL breaking change | `persons` 返回类型从 `[Person!]!` 变为 `PersonSearchResult!` — 需同步更新前端 codegen |

---

## 红线提醒

- ✅ pg_trgm 已在 `db/init/01-extensions.sql` 中启用，无需新 Drizzle migration
- ⚠️ SQL 全部通过 Drizzle `sql` tagged template，零手拼字符串
- ⚠️ 不自动 push、不自动 merge

---

## Future Work（Phase 1+）

- **total COUNT 优化**：Phase 0 数据量下 `COUNT(*)` 无碍。扩容时可考虑：
  - 纯 `hasMore` 模式（无限滚动）
  - 窗口函数 `COUNT(*) OVER()` 单查询
  - 近似计数（`pg_stat` 估算）
- **排序精度**：当前按 similarity DESC 排序。可进一步引入 `is_primary` 权重，确保精确命中排前
- **API 版本策略**：Phase 0 breaking change 零成本（无外部消费者）。Phase 1 需定版本策略
