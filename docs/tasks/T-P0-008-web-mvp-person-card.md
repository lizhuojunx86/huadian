# T-P0-008: Web MVP — 人物卡片页 (`/persons/[slug]`)

- **状态**：ready
- **主导角色**：前端工程师
- **协作角色**：首席架构师（豁免裁定）
- **所属 Phase**：Phase 0
- **依赖任务**：T-P0-007 ✅（API person query — `person(slug)` / `persons` resolver 已就绪）
- **预估工时**：2 人日（前端主）
- **创建日期**：2026-04-18

## 目标（Why）

把 T-P0-007 打通的 GraphQL `person(slug)` 端到端链路延伸到浏览器：实现华典智谱第一个可交互的 Web 页面 `/persons/[slug]`。

这是 Phase 0 的第二个里程碑：证明 **DB → Service → GraphQL → Codegen → React → 浏览器** 全链路在真实数据上跑通。后续所有实体详情页（event / place）都将以本任务为范本。

**不含**：搜索、列表页、i18n、Sentry、MapLibre、认证、SSR 缓存优化。

---

## 范围（What）

### 包含

1. **基础设施搭建**（S-0）：
   - Tailwind CSS + PostCSS + Autoprefixer 初始化
   - shadcn/ui 初始化（含 Radix UI / cva / clsx / tailwind-merge）
   - graphql-request 安装
   - @graphql-codegen/client-preset 安装 + 前端 codegen 配置
   - vitest + @testing-library/react + jsdom 安装
   - @playwright/test 安装

2. **前端 GraphQL Codegen**（S-1）：
   - `apps/web/codegen.ts` 配置（读 `services/api/src/schema/*.graphql`）
   - 生成 typed documents（`apps/web/lib/graphql/generated/`）
   - `apps/web/lib/graphql/client.ts`：graphql-request client 封装
   - package.json 增加 `codegen` script

3. **路由 + 数据获取**（S-2）：
   - `apps/web/app/persons/[slug]/page.tsx`：Next.js App Router 动态路由
   - Server Component 通过 graphql-request 直接 fetch（SSR，不走 React Query）
   - Slug 路由参数直接传入 GraphQL `person(slug)` query
   - `generateMetadata` 生成 `<title>` / `<description>`

4. **PersonCard 组件**（S-3）：
   - `apps/web/components/person/PersonCard.tsx`
   - 展示：slug / name（zhHans 为主，en 辅显）/ dynasty / realityStatus / provenanceTier 徽标
   - birthDate / deathDate 格式化显示（originalText 优先，fallback yearMin~yearMax）
   - biography 展示（zhHans）

5. **names / identityHypotheses 分区**（S-4）：
   - `apps/web/components/person/PersonNames.tsx`：别名列表（nameType 标签 + pinyin）
   - `apps/web/components/person/PersonHypotheses.tsx`：身份假说卡片（relationType + scholarlySupport + notes）
   - 空数据时显示占位文案

6. **Loading / Error / notFound**（S-5）：
   - `apps/web/app/persons/[slug]/loading.tsx`：骨架屏 Skeleton
   - `apps/web/app/persons/[slug]/error.tsx`：错误边界 + 重试
   - `apps/web/app/persons/[slug]/not-found.tsx`：404 页
   - Server Component 中 `person === null` → `notFound()`

7. **vitest 单元测试**（S-6）：
   - PersonCard render 测试（传入 mock data）
   - PersonNames render 测试
   - PersonHypotheses render 测试
   - HistoricalDate 格式化函数测试
   - 空数据 / edge case 测试
   - ≥ 10 test cases

8. **Playwright E2E 冒烟**（S-7）：
   - `apps/web/e2e/person-card.spec.ts`
   - 前置条件：API + DB 已启动且有种子数据（使用 T-P0-007 的 fixture 思路）
   - 冒烟用例：访问 `/persons/liu-bang` → 页面包含"刘邦" + 至少一个别名
   - 404 用例：访问 `/persons/nonexistent` → 显示 404 页
   - ≥ 2 test cases

9. **文档更新**（S-8）：STATUS / CHANGELOG / T-000-index

### 不包含（防止 scope creep）

- ❌ **人物列表页 `/persons`**：延到 T-P0-009 或 T-P1-XXX
- ❌ **搜索功能**：Phase 1+
- ❌ **i18n / next-intl**：本期不装
- ❌ **Sentry 错误上报**：本期不装
- ❌ **MapLibre 地图**：本期不装
- ❌ **SSR 缓存 / ISR / revalidate**：Phase 1 优化
- ❌ **认证 / 权限**：Phase 1+
- ❌ **DataLoader / N+1 优化**：后端侧 Phase 1
- ❌ **Zustand 状态管理**：本页无客户端状态需求
- ❌ **自定义设计稿 / 朝代色 / 古风字体**：Q-X 豁免，延到 T-P1-XXX

---

## 架构师决策点（Q-X 问题清单）

### Q-1 设计稿豁免

本期 MVP 无 UI/UX 设计师参与，无 `docs/design/D-NNN-*.md` 设计稿。

- **裁定**：**架构师豁免：Phase 0 暂免 UI/UX 角色参与**。使用 shadcn/ui 默认样式 + Tailwind utility classes。视觉打磨延到 T-P1-XXX，届时由 UI/UX 设计师主导。
- **依据**：Phase 0 目标是证明全链路跑通，非视觉完美。

### Q-2 数据获取方式：Server Component 直接 fetch vs React Query

- **选项 A**：Server Component 中用 graphql-request 直接 fetch（SSR 一次性获取）
- **选项 B**：Client Component + React Query（需要 QueryClientProvider + hydration）
- **裁定**：**A**。人物详情页是只读展示页，SSR 直接获取最简。`@tanstack/react-query` 本期不装，待 T-P1-XXX 有客户端交互需求（搜索联想、MapLibre 筛选）时再引入。

### Q-3 GraphQL Codegen 输出位置

- **选项 A**：`apps/web/lib/graphql/generated/`（Web 专属）
- **选项 B**：`packages/shared-types/`（monorepo 共享）
- **裁定**：**A**。前端 codegen（client-preset typed documents）与后端 codegen（typescript-resolvers）职责不同，各自独立生成，不共享产物。

### Q-4 API 地址配置

- **裁定**：`NEXT_PUBLIC_API_URL` 环境变量，默认 `http://localhost:4000/graphql`（与 `services/api` dev server 端口一致）。`.env.local` 本地覆盖，不入 git。
- **P1 部署备注**：生产部署时需拆分为 `INTERNAL_API_URL`（server-side，容器内网地址）+ `NEXT_PUBLIC_API_URL`（client-side，公网入口）。Server Component fetch 走 internal，客户端 hydration 走 public。本期不做。

---

## 新增依赖（用户一次性批准）

| 包名 | 用途 | 类型 |
|------|------|------|
| `tailwindcss` | CSS utility framework | devDep |
| `postcss` | CSS 处理 | devDep |
| `autoprefixer` | CSS 前缀 | devDep |
| `@tailwindcss/typography` | 长文排版（biography） | devDep |
| `clsx` | 条件 className | dep |
| `tailwind-merge` | Tailwind class 合并 | dep |
| `class-variance-authority` | 组件变体（cva） | dep |
| `graphql` | GraphQL 核心 | dep |
| `graphql-request` | 轻量 GraphQL client | dep |
| `@graphql-codegen/cli` | codegen CLI | devDep |
| `@graphql-codegen/client-preset` | typed document codegen | devDep |
| `@graphql-tools/load-files` | SDL 文件加载（codegen 共享） | devDep |
| `vitest` | 单元测试 | devDep |
| `@testing-library/react` | React 测试工具 | devDep |
| `@testing-library/jest-dom` | DOM matcher | devDep |
| `jsdom` | 浏览器环境模拟 | devDep |
| `@playwright/test` | E2E 测试 | devDep |

> shadcn/ui 通过 `npx shadcn@latest init` 安装，自动引入 Radix UI 组件。

**本期不装**：next-intl / @sentry/nextjs / maplibre-gl / zustand

---

## 子任务拆解

### S-0 Tailwind + shadcn init + 依赖安装（~0.3 天）
- [ ] `pnpm --filter @huadian/web add` 上表所有 dep
- [ ] `pnpm --filter @huadian/web add -D` 上表所有 devDep
- [ ] Tailwind CSS 初始化：`tailwind.config.ts` + `postcss.config.mjs` + `globals.css`
- [ ] shadcn/ui 初始化（`npx shadcn@latest init`）→ `components.json` + shadcn CSS variables
- [ ] 安装 shadcn 组件：`card` / `badge` / `skeleton` / `button`（按需）
- [ ] `apps/web/lib/utils.ts`（`cn()` 函数 — clsx + tailwind-merge）
- [ ] `pnpm --filter @huadian/web build` 验证 Next.js + Tailwind 编译通过
- [ ] **Checkpoint commit**

### S-1 GraphQL codegen 前端管线（~0.2 天）
- [ ] `apps/web/codegen.ts`：配置 client-preset，读 `services/api/src/schema/*.graphql`
- [ ] `apps/web/lib/graphql/queries/person.ts`：`PersonQuery` + `PersonsQuery` typed documents
- [ ] `apps/web/lib/graphql/client.ts`：graphql-request client 封装（读 `NEXT_PUBLIC_API_URL`）
- [ ] `apps/web/package.json` 增加 `"codegen": "graphql-codegen"` script
- [ ] 跑 codegen → 生成 `apps/web/lib/graphql/generated/`
- [ ] `pnpm --filter @huadian/web typecheck` 通过
- [ ] **Checkpoint commit**

### S-2 路由 /persons/[slug] + Server Component 数据获取（~0.3 天）
- [ ] `apps/web/app/persons/[slug]/page.tsx`：async Server Component
- [ ] 调用 `person(slug)` query → 获取 Person 数据
- [ ] `person === null` → `notFound()`
- [ ] `generateMetadata`：`<title>` 使用 `name.zhHans`，`<description>` 使用 `biography.zhHans` 前 160 字
- [ ] 将 Person 数据传入 PersonCard 组件
- [ ] **Checkpoint commit**

### S-3 PersonCard 组件（~0.3 天）
- [ ] `apps/web/components/person/PersonCard.tsx`
- [ ] 展示字段：name（zhHans 主、en 辅）/ dynasty / realityStatus / provenanceTier 徽标
- [ ] `apps/web/components/person/HistoricalDateDisplay.tsx`：日期格式化组件
  - originalText 优先显示
  - fallback：`yearMin` 或 `yearMin ~ yearMax` 范围
  - 负数年份显示为"公元前 X 年"
- [ ] birthDate / deathDate 区域
- [ ] biography 显示（zhHans，prose typography）
- [ ] 使用 shadcn `Card` / `Badge` 组件
- [ ] **Checkpoint commit**

### S-4 names / identityHypotheses 分区（~0.2 天）
- [ ] `apps/web/components/person/PersonNames.tsx`：别名列表
  - 每项：name + nameType Badge + namePinyin（灰字）
  - isPrimary 高亮标记
  - 空数据占位文案："暂无别名记录"
- [ ] `apps/web/components/person/PersonHypotheses.tsx`：身份假说卡片
  - 每项：relationType 标签 + scholarlySupport + notes
  - acceptedByDefault 标记
  - 空数据占位文案："暂无身份假说"
- [ ] 集成到 PersonCard / page 中
- [ ] **Checkpoint commit**

### S-5 Loading / Error / notFound（~0.2 天）
- [ ] `apps/web/app/persons/[slug]/loading.tsx`：骨架屏（Skeleton 组件模拟 PersonCard 布局）
- [ ] `apps/web/app/persons/[slug]/error.tsx`：错误边界 + 重试按钮（"use client"）
- [ ] `apps/web/app/persons/[slug]/not-found.tsx`：404 页面，提示 slug 不存在
- [ ] **Checkpoint commit**

### S-6 vitest 单元测试（~0.3 天）
- [ ] `apps/web/vitest.config.ts`：配置 jsdom 环境
- [ ] `apps/web/__tests__/components/PersonCard.test.tsx`
- [ ] `apps/web/__tests__/components/PersonNames.test.tsx`
- [ ] `apps/web/__tests__/components/PersonHypotheses.test.tsx`
- [ ] `apps/web/__tests__/components/HistoricalDateDisplay.test.tsx`
- [ ] mock data fixtures（从 GraphQL schema 推导类型）
- [ ] ≥ 10 test cases 全绿
- [ ] **Checkpoint commit**

### S-7 Playwright E2E 冒烟（~0.2 天）
- [ ] `apps/web/playwright.config.ts`：配置 webServer + baseURL
- [ ] `apps/web/e2e/person-card.spec.ts`
  - 冒烟：`/persons/liu-bang` → 页面含"刘邦"
  - 404：`/persons/nonexistent-slug` → 404 页面
- [ ] ≥ 2 test cases
- [ ] **Checkpoint commit**（E2E 可选跳过 CI，标记 `@smoke`）

### S-8 STATUS / CHANGELOG 收尾（~0.1 天）
- [ ] 更新 `docs/STATUS.md`
- [ ] 更新 `docs/CHANGELOG.md`
- [ ] 更新 `docs/tasks/T-000-index.md`
- [ ] **Final commit**

---

## 交付物（Deliverables）

- [ ] Tailwind + shadcn 初始化配置
- [ ] `apps/web/codegen.ts` + `apps/web/lib/graphql/` codegen 管线
- [ ] `apps/web/app/persons/[slug]/page.tsx` 路由页（+ loading / error / not-found）
- [ ] `apps/web/components/person/*.tsx` 组件（PersonCard / PersonNames / PersonHypotheses / HistoricalDateDisplay）
- [ ] `apps/web/__tests__/` 单元测试
- [ ] `apps/web/e2e/` E2E 测试
- [ ] 文档更新：STATUS / CHANGELOG / T-000-index

---

## 完成定义（DoD）

1. `/persons/liu-bang` 在浏览器中渲染人物卡片（含 name / dynasty / dates / biography）
2. 别名列表正确显示（至少 1 条 PersonName）
3. 身份假说区域正确显示或显示空占位
4. `/persons/nonexistent` 显示 404 页面
5. Loading 状态显示骨架屏
6. vitest ≥ 10 test cases 全绿
7. Playwright ≥ 2 E2E cases 通过
8. `pnpm --filter @huadian/web build` 成功
9. `pnpm --filter @huadian/web lint && pnpm --filter @huadian/web typecheck` 全绿
10. codegen 产物与 SDL 一致（`pnpm --filter @huadian/web codegen && git diff --exit-code`）
11. STATUS.md / CHANGELOG.md / T-000-index.md 已更新

---

## 依赖分析

| 依赖 | 状态 | 阻塞？ |
|------|------|--------|
| T-P0-007 API person query | ✅ done | 否 |
| T-P0-003 GraphQL schema 骨架 | ✅ done | 否 |
| T-P0-002 DB Schema | ✅ done | 否 |
| T-P0-001 Monorepo 骨架（apps/web） | ✅ done | 否 |
| D-NNN 设计稿 | ❌ 不存在 | **否**（Q-1 豁免） |

---

## 风险与缓解

| 风险 | 缓解 |
|------|------|
| 无设计稿，视觉一致性无保证 | Q-1 豁免：shadcn 默认 + Tailwind，视觉延到 P1 |
| API 地址硬编码泄露 | 使用 `NEXT_PUBLIC_API_URL` 环境变量，`.env.local` 不入 git |
| E2E 测试需要 API + DB 同时运行 | playwright.config 配置 webServer 启动前置检查；CI 阶段可标记 `@smoke` 跳过 |
| codegen 产物在 monorepo 跨包引用 SDL 时路径问题 | codegen 直接读 `../../services/api/src/schema/*.graphql`（monorepo 内部） |
| Tailwind + Next.js App Router CSS 加载顺序 | 遵循 Next.js 官方 Tailwind 集成文档 |

---

## 宪法条款检查清单

- [ ] **C-2** ProvenanceTier 徽标在卡片上可见，用户可知数据来源等级
- [ ] **C-6** Schema-first：前端 codegen 从 SDL 生成类型，不手写 GraphQL 类型
- [ ] **C-12** MultiLangText：正确展示 zhHans 主文本
- [ ] **C-13** Slug 作为路由参数，保持 URL 稳定性
- [ ] **C-15** 角色解耦：前端工程师不修改 GraphQL schema / 不做设计决策
- [ ] **C-20** 错误状态明确：404 / Error / Loading 三态完整

---

## 协作交接

- **← T-P0-007**：`person(slug)` / `persons` GraphQL query 已就绪
- **← T-P0-003**：Person / PersonName / IdentityHypothesis SDL types
- **→ T-P0-009 / T-P1-XXX**：人物列表页 / 搜索页以本任务的前端基础设施为底座
- **→ UI/UX 设计师（T-P1-XXX）**：视觉打磨基于本任务的组件结构
- **→ 后续实体详情页**：event / place 详情页以本任务为范本

---

## 接续提示

```
本任务 ID：T-P0-008
你将担任：前端工程师
请先读：
1. CLAUDE.md → docs/STATUS.md → docs/CHANGELOG.md 最近 5 条
2. .claude/agents/frontend-engineer.md
3. docs/tasks/T-P0-008-web-mvp-person-card.md（本文件）
4. apps/web/package.json（当前依赖）
5. services/api/src/schema/b-persons.graphql（Person type）
6. services/api/src/schema/common.graphql（MultiLangText / HistoricalDate）
7. services/api/src/schema/queries.graphql（person / persons query 入口）

按子任务 S-0 → S-8 顺序执行，每个 S-N 完成后 checkpoint commit。
```

---

## 修订历史

- 2026-04-18 v1：前端工程师起草，状态 ready，待用户确认后开工
