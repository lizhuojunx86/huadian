# Sprint K · Stage 0 — Frontend Inventory（T-P0-028 Triage UI）

- **角色**：Frontend Engineer（Opus 4.7）
- **日期**：2026-04-28
- **Brief 引用**：`docs/sprint-logs/sprint-k/stage-0-brief-2026-04-28.md` §3 Frontend / §6 V1 scope
- **范围**：apps/web/ 前端栈现状 + /triage 路由结构推荐 + auth 简化方案 + 工时 + 跨角色依赖
- **本文件不修改任何代码**：纯调研产物。

---

## §1 现有路由结构（apps/web/app/）

### 路由清单

| 路径 | 文件 | 类型 | 数据源 | 说明 |
|------|------|------|--------|------|
| `/` | `app/page.tsx` | RSC（async） | `FeaturedPersonDocument` × 6 + `StatsDocument` | Hero + Featured + Stats + CTA |
| `/persons` | `app/persons/page.tsx` | RSC（async） | `PersonsSearchDocument`（search/limit/offset） | 列表 + 分页（URL searchParams） |
| `/persons/[slug]` | `app/persons/[slug]/page.tsx` | RSC（async） | `PersonDocument` | 详情 + `generateMetadata` SEO |
| `/about` | `app/about/page.tsx` | 静态 | — | 项目简介 |

### 路由约定（项目当前 pattern）

1. **Server Component first**：所有 page.tsx 默认 RSC，`async` 直接 `await graphqlClient.request(Document, vars)`，不走 TanStack Query / SWR
2. **URL 即状态**：`searchParams` 承载列表的 `search` / `page`；客户端 SearchBar / Pagination 用 `router.replace()` 修改 URL，不维护本地分页 state
3. **状态文件三件套**：`loading.tsx`（Suspense fallback）+ `error.tsx`（client component，含 `reset()`）+ `not-found.tsx`
4. **layout 嵌套**：仅 `app/layout.tsx` 单根；`<Header>` sticky top + `<main flex-1>` + `<Footer>`，无嵌套 layout
5. **客户端组件极简化**：仅 SearchBar、Pagination、Header（用 `useSelectedLayoutSegment`）、PersonsError 是 `"use client"`，其余皆 RSC
6. **graphql-request 而非 TanStack Query**：与 `.claude/agents/frontend-engineer.md` §职责描述（"TanStack Query + GraphQL Codegen"）不一致；当前实现走 RSC + `graphql-request`，无客户端缓存层

### 中间件 / Auth 现状

- `apps/web/middleware.ts` **不存在**
- 无 cookie / session / auth 任何机制
- API URL 由 `NEXT_PUBLIC_API_URL` 注入，client.ts 直接 `new GraphQLClient(API_URL)`，无 header 注入
- 无 i18n / next-intl

---

## §2 shadcn/ui 组件清单 + /triage 候选

### 现已 import 的 shadcn 组件（4 个）

| 组件 | 文件 | 现使用处 |
|------|------|---------|
| `Button` + `buttonVariants` | `components/ui/button.tsx` | PersonsError / Pagination / 首页 CTA Link as Button |
| `Card` 系（Card / Header / Title / Content / Description） | `components/ui/card.tsx` | PersonCard / FeaturedPersonCard |
| `Badge` + `badgeVariants` | `components/ui/badge.tsx` | PersonCard tier/reality / PersonListItem dynasty |
| `Skeleton` | `components/ui/skeleton.tsx` | persons/loading.tsx |

### 配置

- `components.json`：style=default / rsc=true / baseColor=zinc / cssVariables=true / aliases @/components @/lib/utils
- `tailwind.config.ts`：darkMode=class（实际未切换）/ HSL CSS 变量 / `@tailwindcss/typography` plugin
- `globals.css`：标准 shadcn zinc 变量（root + .dark）
- 无 `cmdk`、`@radix-ui/*`（除 shadcn 间接依赖外项目根没有显式依赖）、无 `sonner` / `vaul`

### /triage 候选（按 brief §6 / §3 三层流程推断）

| 需求场景 | 现有可复用 | 需新增 | 必要性 |
|----------|-----------|--------|--------|
| 列表页卡片展示 | Card / Badge | — | ✅ |
| 列表分页 | Pagination 模式可移植 | — | ✅ |
| 按 guard_type / mapping_method 切换 | — | **Tabs** (`shadcn add tabs`) | ✅ |
| 详情页结构 | Card | — | ✅ |
| 决策表单（approve/reject/defer + reason） | Button | **Textarea** (`shadcn add textarea`) | ✅ |
| 决策类型单选 | — | **RadioGroup** (`shadcn add radio-group`) 或 3×Button | ⚠️ 用 3×Button 即可，省一组件 |
| 决策成功反馈 | — | **Toast / Sonner**（`shadcn add sonner`，引入 `sonner` 包） | ⚠️ V1 可用 router redirect + 列表页 banner 替代 |
| 决策错误反馈 | error.tsx 模式 | — | ✅（路由级 error 即可） |
| Filter 下拉（如 historian / 日期） | — | **Select**（`shadcn add select`） | ⚠️ V1 可用 URL searchParams + button group 替代 |
| 状态徽标（pending / decided / deferred） | Badge | — | ✅ |
| Tooltip（surface form 上下文 hover） | — | **Tooltip**（`shadcn add tooltip`） | ⚠️ V1 可省，hover 用 `title` 属性 |
| 加载态 | Skeleton | — | ✅ |
| Drawer / Sheet（仅 §3 方案 B 需要） | — | **Sheet**（`shadcn add sheet`） | 仅方案 B 需 |

**结论**：V1 最小新增 = **Tabs + Textarea**（2 组件 / 0 新 npm 依赖，因 shadcn 基于 Radix 已在 transitive 中）。Toast / Select / Tooltip 可放 V1.1。

---

## §3 路由结构推荐 + UX 模式优劣对比

### 候选方案

#### 方案 A：独立路由 `/triage` + `/triage/[itemId]`（**推荐**）

- **结构**：列表页 RSC `/triage`（按 type Tabs + 卡片 + 分页）→ 详情页 RSC `/triage/[itemId]`（context + decision form）
- **决策提交**：表单 `action={recordDecisionAction}` Server Action → 写 DB → `redirect()` 回列表 OR 下一条详情
- **inbox 模式实现**（V1.1）：Server Action 调 BE `recordTriageDecision` mutation → BE 在响应中返回 `nextPendingItemId` → action 内 `redirect('/triage/' + nextPendingItemId)`
- **预取**：列表 `<Link href="/triage/[id]">` 自动 Next.js prefetch；inbox 跳转目标也享受 prefetch
- **已审过滤**：列表 RSC 每次 fetch 自带 `status='pending'`，决策完毕后 `router.refresh()` 或 redirect 自然过滤掉

#### 方案 B：单页 `/triage` + Sheet / Drawer 内嵌详情

- **结构**：单 `/triage` 路由，左列表 + 点击行从右侧滑出 `<Sheet>` 详情；URL 用 `?selected=itemId` 标识当前
- **决策提交**：客户端 Sheet 内 form → mutation → close Sheet + revalidate list
- **inbox**：mutation 完成后 client-side 取列表下一条 id 打开新 Sheet（无 navigate）

#### 方案 C：完全 client-side / 全局 store（队列预拉）

- **结构**：`/triage` 进入即 fetch 全队列到 client，本地 store 管理 cursor，所有切换在 client 完成
- **决策提交**：mutation → 本地 store mark + 自动 cursor++

### 优劣对比

| 维度 | A 独立路由 | B Sheet 内嵌 | C 全 client store |
|------|-----------|-------------|------------------|
| **贴合现有 RSC pattern** | ✅ 完全一致（同 `/persons + /persons/[slug]`） | ⚠️ 需大量 client-side 状态 | ❌ 完全偏离 |
| **新引入依赖** | 0（用 Server Action + redirect） | shadcn sheet（小）+ client mutation 库（如未来上 TanStack） | 全局 store（zustand）+ mutation 库 |
| **URL 可分享** | ✅ `/triage/[id]` 直链 | ⚠️ `?selected=id` 仅 client 同步 | ❌ 无路由变化 |
| **inbox 实现成本** | 中（需 BE mutation 返回 nextId + Server Action redirect） | 低（client 拿队列下一条） | 极低（store cursor++） |
| **预取下一条** | ✅ Next.js Link prefetch + Server Action prefetch | ⚠️ 需手动 prefetch query | ✅ 已在内存 |
| **已审过滤** | ✅ RSC fetch 自带 filter，最稳 | ✅ 重 fetch list | ⚠️ 需手动 invalidate store |
| **页面刷新 / 浏览器后退** | ✅ 可恢复 | ⚠️ Sheet 状态丢失 | ❌ 队列丢失 |
| **决策审计可观测性**（DevTools Network） | ✅ 标准 form POST / Server Action | 客户端 mutation | 客户端 mutation |
| **a11y / 键盘流** | ✅ 标准导航 | ⚠️ Sheet trap 需调试 | ⚠️ 自定义 |
| **首屏性能** | ✅ RSC 渲染 | 略差（client hydration） | 差（全队列 fetch） |
| **大数据量（>500 pending）** | ✅ 分页天然限流 | ⚠️ 仍需分页 | ❌ 内存压力 |
| **学习成本（新 historian / 新工程师）** | ✅ 同 /persons | 中 | 高 |

### 推荐：方案 A（V1）+ inbox-as-V1.1 增量

**理由**：

1. **零新增范式**：与现有 `/persons + /persons/[slug]` 完全同构，新工程师 / 新 historian 都能快速上手
2. **零新依赖**：Server Action（Next.js 14 内置）+ `redirect()` 即可实现 inbox，不需 zustand / TanStack
3. **架构师 brief §6 默认形态**："列表 + 详情 三层流程可用" 直接命中
4. **inbox 模式作为 V1.1 增量**：
   - V1 base：决策完毕 → `redirect('/triage')` 回列表，列表自动剔除已审条目
   - V1.1 inbox：BE mutation 增加 `nextPendingItemId` 返回字段（按当前 filter / sort 计算）→ Server Action 改为 `redirect(nextId ? '/triage/' + nextId : '/triage')`
   - 实现成本：FE +0.25~0.5 day（只改 Server Action 跳转目标）；BE +0.25 day（mutation 返回字段）
   - 预取：列表中 `<Link href="/triage/[id]">` Next.js 自动 prefetch，连续审阅时下一条已暖
   - 已审过滤：列表 fetch + nextId 计算均在 BE 端走 `status='pending'`，FE 侧零状态

5. **inbox 的 FE 复杂度评估**（架构师 brief 提示）：
   - **router push state 管理**：Server Action `redirect()` 直接生成新 history entry，浏览器后退正常
   - **pre-fetch 下一条**：方案 A 享受 Next.js 默认 Link prefetch（对当前可见列表行）；inbox 跳转目标因来自 BE mutation 响应，无法事先 prefetch，但首次 navigate 走 RSC streaming 体验仍可接受（典型 P50 < 200ms）
   - **已审条目过滤**：BE 端 SQL `WHERE status='pending'` 是单点真相，FE 侧无需做 client-side filter 或本地 mark
   - **结论**：FE 实现成本低，主要复杂度在 BE 决定"下一条"语义（按创建时间 ASC？按 guard_type 优先级？需 Hist 确认默认 sort）

### V1 vs V1.1 scope 划分建议

| 功能 | V1 base | V1.1 inbox 增量 |
|------|--------|----------------|
| 列表 / 分页 / Tabs filter | ✅ | — |
| 详情页（context + form） | ✅ | — |
| 决策提交（approve/reject/defer + reason） | ✅ | — |
| 提交后跳转 | redirect 回 `/triage` | redirect 到 `/triage/[nextId]` |
| BE mutation 字段 | `recordTriageDecision(input) → TriageDecision` | + `nextPendingItemId: ID` |
| FE 工时 | 3.0 day | +0.5 day |

**架构师裁决点**：是否把 inbox 纳入 V1 base？我的倾向是 **V1 base 不包含**，理由：架构师 brief §6 收口判定写"列表 + 详情 + 决策三层流程可用"未提自动下一条；inbox 涉及"下一条语义"（创建时间 ASC 还是 guard_type 优先级？跨 type 还是同 type？）需要 Hist 在 Stage 0 / Stage 1 给出明确规则，避免 V1 实施期 churn。

---

## §4 新组件 / 依赖清单

### V1 base 新增（最小集）

1. **`shadcn add tabs`** — 列表页按 type 切换（seed_mapping / guard_blocked_merge / all）
2. **`shadcn add textarea`** — 决策 reason 输入框

依赖增量：shadcn 自动注入 `@radix-ui/react-tabs`（小）；不引入 `sonner` / `cmdk` / `vaul`。

### V1.1 / V2 候选（视 historian 反馈再加）

3. **`shadcn add select`** — 多 filter（historian / dynasty / 日期范围）
4. **`shadcn add tooltip`** — surface 上下文 hover 详情
5. **`shadcn add sonner`**（引入 `sonner` 包） — 决策成功 toast
6. **`shadcn add sheet`** — 仅当方案 B 复活才用
7. **`shadcn add radio-group`** — decision 单选（V1 用 3×Button 替代）

### 不推荐引入

- ❌ `@tanstack/react-table`（DataTable）— 当前数据量 < 200 条 / 简单 div+grid 即可
- ❌ `react-hook-form` + `zod`（Form 抽象）— V1 表单仅 1 textarea + 3 button + URL hidden id，原生 form + Server Action FormData 足矣
- ❌ `zustand` — RSC pattern 不需要全局 store
- ❌ `@tanstack/react-query` — 与项目现有 RSC + graphql-request 模式冲突，独立 PR 评估

---

## §5 简化 Auth 实现路径（URL token `?historian=xxx`）

### 需求（brief §3.2）

- V1 简化 auth：URL `?historian=xxx` 接受
- 决策需关联 historian 标识（写入 `triage_decisions.historian_id`）
- 下次访问无需重新输入

### 候选实现

#### 路径 A：纯 URL searchParams（最简）

```ts
// /triage RSC
export default async function TriagePage({ searchParams }: { searchParams: { historian?: string } }) {
  const historian = searchParams.historian ?? 'anonymous';
  // ...
}
```

- ✅ 实现成本最低（0 新文件）
- ❌ 每次 navigate 必须显式带 `?historian=` 否则丢失
- ❌ 跨路由污染：详情页 / 列表页 / mutation 都得手动透传
- 不推荐

#### 路径 B：URL token + Next.js middleware → cookie sync（**推荐**）

新建 `apps/web/middleware.ts` ~30 行：

```ts
import { NextResponse, type NextRequest } from 'next/server';

export function middleware(req: NextRequest) {
  const url = req.nextUrl;
  const historianFromQuery = url.searchParams.get('historian');
  const historianFromCookie = req.cookies.get('huadian.historian')?.value;

  if (historianFromQuery && historianFromQuery !== historianFromCookie) {
    // first time: write cookie + strip query
    const cleanUrl = new URL(url.pathname, url);
    url.searchParams.forEach((v, k) => k !== 'historian' && cleanUrl.searchParams.set(k, v));
    const res = NextResponse.redirect(cleanUrl);
    res.cookies.set('huadian.historian', historianFromQuery, {
      httpOnly: false, // RSC 端可读 + 客户端不依赖（用 cookies() server-side）
      sameSite: 'lax',
      maxAge: 60 * 60 * 24 * 30,
      path: '/',
    });
    return res;
  }
  return NextResponse.next();
}

export const config = {
  matcher: ['/triage/:path*'], // 只在 triage 段生效
};
```

RSC / Server Action 内：

```ts
import { cookies } from 'next/headers';
const historianId = cookies().get('huadian.historian')?.value ?? 'anonymous';
```

- ✅ 一次输入，长期生效（30 天 cookie）
- ✅ URL 干净（首次写 cookie 后 strip query 重定向）
- ✅ RSC + Server Action 直接 `cookies()` 读，零客户端代码
- ✅ matcher 限定仅 /triage 段，对 /persons 等无侵入
- ⚠️ 任何人能猜 token（URL token 本就不安全），V1 不解决；V2 走 OAuth / SSO
- 推荐 V1 走此路径

#### 路径 C：HTTP Header from reverse proxy（V2+）

- nginx / vercel 注入 `X-Historian-Id` → middleware 读 → cookie sync
- 需运维参与，V1 不上

### 推荐：路径 B + 加注释 V2 升级路径

新建文件：`apps/web/middleware.ts` + 改动 ~30 行；不改任何现有路由。

**安全注**：URL token 无加密、无后端验证，仅作 V1 标识用途；triage_decisions 表保留原始 `historian_id` 字符串值，V2 SSO 接入时按字符串映射回真实账号（或 force re-decide）。**架构师需在 ADR-027 / Stage 1 决定**：是否要求 `historian_id` 在白名单内（YAML 配置）？还是接受任意字符串？

---

## §6 V1 实施工时估计（FE 段）

| 任务 | 估时 | 说明 |
|------|------|------|
| `/triage` 路由骨架（page.tsx + loading.tsx + error.tsx + not-found.tsx） | 0.25 day | 复用 /persons 模板 |
| 列表页 + Tabs filter（按 type） + 分页 | 0.5 day | 复用 PersonList / Pagination 模式；Tabs URL 同步 |
| 卡片组件 `<TriageItemCard>`（surface + type badge + context preview + 决策状态） | 0.5 day | 新组件，约 80~120 行 |
| `/triage/[itemId]` 详情页骨架（context + form 容器） | 0.25 day | RSC 拉详情 |
| 决策表单（textarea + 3×Button + Server Action） | 0.5 day | 含 redirect 回 list |
| BE GraphQL codegen 同步（待 BE schema 落地后跑 `pnpm --filter @huadian/web codegen`） | 0.1 day | 自动 |
| middleware.ts + cookie auth | 0.25 day | 新文件 ~30 行 + 1 测试 |
| shadcn add tabs + textarea | 0.1 day | CLI |
| 单元测试（≥3：TriageItemCard / 列表空态 / 决策表单 disabled state） | 0.5 day | vitest + jsdom，复用现有 setup |
| Playwright E2E ≥2（覆盖：列表→详情→提交→列表过滤、空态） | 0.5 day | 需 BE seeded data 配合 |
| 内联文档 + retro 段产物 | 0.25 day | docs/sprint-logs |
| **V1 base 合计** | **~3.7 day** | 含 codegen 等待 |
| V1.1 inbox 增量（Server Action redirect 改 nextId + 1 E2E） | +0.5 day | BE 提供 nextPendingItemId 后 |

**风险/缓冲**：
- BE schema 与 codegen 同步阻塞 → 缓冲 0.5 day（先 mock data 起 UI 框架）
- shadcn add 与 RSC 兼容性问题（zinc → 与现 globals.css 一致，理论无冲突） → 缓冲 0.1 day
- middleware redirect 与 Next.js 14 App Router 行为细节 → 缓冲 0.2 day

**净 FE 估时（含缓冲）**：**4.5 day FE base + 0.5 day inbox 增量**

与架构师 brief §7 节奏（Day 3-4 BE/FE 并行 = 2 天）的偏差：**FE 实际 ~4 个工作日，brief 给的 2 天偏紧**；建议 brief Day 3-5 三天 BE/FE 并行（V1 base 不含 inbox），Day 5 末尾合龙 smoke。

---

## §7 跨角色依赖

### 向 Backend Engineer 提的需求

1. **GraphQL Schema 设计**：
   - 推荐 `TriageItem` interface（不是 union），含公共字段 `id / itemType / status / createdAt / surface / contextSnippet`
   - 子类型 `SeedMappingTriageItem` + `GuardBlockedMergeTriageItem`，扩展类型特异字段
   - 理由：interface 在 codegen client-preset 下 fragment 复用更顺；union 适合无公共字段场景
   - **是否走 union vs interface，请 BE 在 Stage 0 inventory 中给出权衡，架构师 Stage 1 裁决**

2. **Query 列表 + 详情**：
   - `Query.pendingTriageItems(filter: TriageFilterInput, limit: Int = 20, offset: Int = 0): TriageConnection`
     - filter 含：itemType / historianId（可选） / dateFrom / dateTo
     - 返回 `{ items, total, hasMore }`（与 `PersonsConnection` 同构）
   - `Query.triageItem(id: ID!): TriageItem`（详情）

3. **Mutation 决策**：
   - `Mutation.recordTriageDecision(input: TriageDecisionInput!): TriageDecisionResult`
     - input: `{ itemId, decision: APPROVE|REJECT|DEFER, reason: String, historianId: String }`
     - V1 result: `{ decision, item }`（含更新后的 item.status）
     - V1.1 result 增量: `{ decision, item, nextPendingItemId: ID }`（按当前 filter / sort 计算下一条）

4. **错误约定**：
   - 失败用 GraphQL `errors[]` 标准路径（不用 union error type，与现有 `Person` query 风格一致）
   - 失败 message 结构化（用于 FE error.tsx 友好提示）

5. **codegen 触发**：
   - schema 改完后请 `pnpm --filter @huadian/api schema:emit`（或现有触发 SDL snapshot 命令）
   - FE 跑 `pnpm --filter @huadian/web codegen` 生成类型

6. **inbox sort 语义**（V1.1）：
   - `nextPendingItemId` 按什么排序选下一条？建议默认 = `created_at ASC, id ASC`（FIFO），避免 historian 跳来跳去
   - 是否跨 type 选下一条 / 还是同 type 选下一条？请 Hist 确认 + BE 实现

### 向 Pipeline Engineer 提的需求

1. **数据采样 ≥10 条 / 类**：
   - 至少 10 条 `seed_mappings WHERE mapping_status='pending_review'` 真实样本（含 surface / mapping_method / 提议 QID / 创建时间）
   - 至少 10 条 `pending_merge_reviews WHERE status='pending'` 真实样本（含 a/b 双方 surface / guard_type / guard_payload）
   - 用途：FE mock data fixture（在 BE schema 未就绪时先起 UI 骨架）+ 详情页字段完整性验证
   - 输出建议：`docs/sprint-logs/sprint-k/inventory-pe-2026-04-28.md` 附 SQL + 脱敏样本

2. **决策枚举澄清**：
   - V1 "approve / reject / defer" 在两表的具体 status 写入值是什么？
   - `seed_mappings.mapping_status`：`pending_review` → `active` (approve) / `rejected` (reject) / `deferred`?（"deferred" 是否需要新枚举值 / migration？）
   - `pending_merge_reviews.status`：同上
   - **影响**：FE 决策按钮 label / 是否区分两表的可用决策

### 向 Historian 提的需求（UX 验证愿景）

1. **详情页关键字段确认**：
   - 必须显示哪些上下文？候选：surface / 上下文段落（前后 50 字） / 同 surface 历史决策 / guard 拦截原因 / 候选 QID 详情（label / description / sample claims）
   - 哪些字段排序最关键（影响详情页布局）

2. **inbox 语义确认**（影响 V1 vs V1.1 划分）：
   - 决策完毕希望 redirect 回列表 还是 自动跳下一条？
   - 如自动跳下一条：跨 type 还是同 type？按创建时间 FIFO 还是 guard_type 优先级？
   - 是否需要"跳过本条但不 defer"快捷键？（V2 候选）

3. **默认 sort**：
   - 列表默认按什么排序？候选：创建时间 DESC（最新） / 创建时间 ASC（最旧 / FIFO） / guard_type 优先级
   - 影响：列表页 default ordering + V1.1 inbox 下一条算法

4. **reason 必填策略**：
   - reject / defer 必填 reason？approve 选填？
   - 影响：FE form validation

5. **E2E 验证场景**：
   - V1 验证场景设计：用 UI 处理 5-10 条历史 pending；具体哪几条？哪几个 case 是黄金集？
   - 验证标准：决策正确持久化 + 详情页所有关键 metadata 可见 + 错误能恢复

### 向架构师（Stage 1 裁决点汇总）

1. **inbox 是否纳入 V1 base？**（§3 / §6 涉及）
2. **GraphQL schema 抽象选 interface 还是 union？**（§7.1）
3. **historian_id 是否需白名单（yaml）？**（§5）
4. **`deferred` 是否需要新枚举值 + migration 0014.X？**（§7 PE 部分）
5. **brief §7 节奏 Day 3-4 BE/FE 并行偏紧，是否调整为 Day 3-5（含 inbox 则 Day 3-6）？**（§6）

---

## §8 风险登记

| 风险 | 等级 | 缓解 |
|------|------|------|
| BE schema 未就绪即开工 → 类型不齐 | 中 | FE 先用 mock data 起骨架 / 等 codegen sync 再 wire 真数据 |
| Server Action redirect 与 Next.js 14 App Router 行为不一致 | 低 | 早期 spike 一个最小例子（0.25 day）验证 |
| middleware matcher 误伤其他路由 | 低 | matcher 严格限定 `/triage/:path*` + manual smoke |
| shadcn add 装新组件破坏现有 zinc 主题 | 低 | shadcn diff 模式 / 装完先 lint+typecheck |
| Hist E2E 反馈核心字段缺失 → 详情页重构 | 中 | Stage 0 Hist inventory + Stage 1 ADR-027 字段 freeze |
| URL token auth 被滥用 / 跨 historian 决策污染 | 中 | V1 注释明确 V2 升级路径；triage_decisions 保原始字符串 |
| inbox 模式纳入 V1 但下一条语义未敲定 → 实施期 churn | 高 | 推荐 inbox = V1.1，V1 base 仅 redirect 回 list |

---

## §9 自检 checklist（FE 段）

- [x] 现有路由结构 listed（4 路由 + 3 状态文件 + 1 layout）
- [x] shadcn 已用清单（4 组件） + /triage 候选（最小新增 = Tabs + Textarea）
- [x] 路由结构 3 方案对比表 + 推荐方案 A + 理由
- [x] inbox 模式实现成本评估（FE +0.5 day / BE +0.25 day）
- [x] auth 简化 3 路径对比 + 推荐 B（middleware + cookie）
- [x] V1 base 工时 ~3.7 day，含缓冲 4.5 day；brief §7 Day 3-4 偏紧已标注
- [x] BE / PE / Hist / 架构师 4 类跨角色需求清单
- [x] 风险 7 项登记
- [x] V1 vs V1.1 scope 划分明确

---

## §10 不在本 inventory 范围

- ❌ 视觉设计（字号 / 颜色 / 间距等）—— UI/UX 设计师负责（本 sprint Hist + 架构师代行 UX 验证）
- ❌ 具体 GraphQL schema 字段定义 —— BE Stage 0 inventory + 架构师 Stage 1 设计
- ❌ 数据库 schema (`triage_decisions` 表) —— BE / 架构师 Stage 1 设计
- ❌ 实际代码改动 —— 本 inventory 仅产出文档，不改 apps/web

> 由 frontend-engineer 角色（Opus 4.7）于 2026-04-28 完成。
