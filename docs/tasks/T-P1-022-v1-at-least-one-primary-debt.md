# T-P1-022: V1 Invariant 下界缺失（27 个 active person 缺 is_primary=true name）

- **状态**: registered
- **优先级**: P1（治理性盲点，不阻塞 Sprint B，但影响后续依赖 is_primary 的功能）
- **主导角色**: 管线工程师 + 架构师
- **所属 Phase**: Phase 1
- **发现来源**: T-P0-025 Gate 0a Wikidata coverage probe 副发现（4cf34b5, 2026-04-21）
- **创建日期**: 2026-04-21

---

## 1. 背景

### 1.1 问题

V1 不变量的现行 SQL 语义是 **"每个 active person 的 is_primary=true 的 person_names 行数 ≤ 1"**（上界约束）。

但 V1 没有覆盖**下界**：每个 active person 是否**至少**有 1 个 is_primary=true 的 name。

T-P0-025 Gate 0a probe 执行时，从生产 DB 查询 320 active persons，发现 **27 个 active person 的 `person_names` 全部 is_primary=false**。这些 person 不违反 V1（"≤ 1" 成立，因为 0 ≤ 1），但明显违反项目的隐含语义（每个 person 至少有一个"主名"）。

### 1.2 溯源推测

最可能的历史成因：
- T-P0-016 `is_primary_demotion`：当年为根治 F5/F11 问题，对 W1/W2 路径做了 is_primary 降级；可能某些被降级的 person 没有被同步"拔一个新 primary"
- canonical merge 历史事件：merged source person 的 primary 被迁移到 target，source 自身留下 0 primary（然后又 active，未被 soft-delete）

**本 debt 当前只记录现象，未做根因 SQL 审计。** 启动 fix 时 Gate 0 需先扫：

```sql
-- 27 个 active person 列表
SELECT p.id, p.slug, p.canonical_name, p.dynasty, p.reality_status
FROM persons p
WHERE p.deleted_at IS NULL
  AND p.merged_into_id IS NULL
  AND NOT EXISTS (
    SELECT 1 FROM person_names pn
    WHERE pn.person_id = p.id AND pn.is_primary = true
  )
ORDER BY p.slug;
```

---

## 2. 修复路径（架构师倾向方案 B）

### 方案 A — 扩 V1 语义（双边约束）

把 V1 的 SQL 从 `> 1` 单边改为 `!= 1` 双边。

**优点**：单一不变量职责清晰合并。
**缺点**：V1 历史 SQL 改动会连带 test fixture / migration / 审计脚本同步；破坏"V1 = no-more-than-one-primary"的 decade-long 稳定语义。

### 方案 B — 新增 V9 `at-least-one-primary`（推荐）

新增 V9 不变量，SQL：

```sql
SELECT p.id, p.slug
FROM persons p
WHERE p.deleted_at IS NULL
  AND p.merged_into_id IS NULL
  AND NOT EXISTS (
    SELECT 1 FROM person_names pn
    WHERE pn.person_id = p.id AND pn.is_primary = true
  );
```

**优点**：
- 单一不变量单一职责（V1 管上界、V9 管下界），符合项目现有 invariant 设计哲学
- V1 / V6 历史绿不回归
- V9 可以按 ADR-022 / ADR-023 同级 ADR 起草：**V9 Invariant 引入 ADR**
- 若生产有违反，fix 完后直接收尾；若 fix 困难，V9 可暂以 warning 级落地（类似 V7 曾做的）

**缺点**：invariant 集再扩一条（V1-V8 → V1-V9），CI / docs / migration 相应扩容

### 方案 C — 仅修数据不改规则

对 27 个 person 手动/批量 promote 其中一条 alias 到 primary：

```sql
-- 对每个违规 person，选 name_type='primary' 的一条 promote；若无则选 name_type='alias' 的按规则选一条
UPDATE person_names pn SET is_primary = true WHERE pn.id IN (
  SELECT DISTINCT ON (pn.person_id) pn.id
  FROM person_names pn
  WHERE pn.person_id IN (<27 persons>)
  ORDER BY pn.person_id,
    CASE pn.name_type WHEN 'primary' THEN 0 WHEN 'alias' THEN 1 ELSE 2 END,
    pn.created_at
);
```

**优点**：最低成本
**缺点**：不防未来回归（同类问题可能再出现但永远没人知道）。**单独不可取**，但可作为方案 A 或 B 的前置 Stage 1（清数据 → 立规则）。

### 架构师初步倾向

**方案 B + 方案 C 前置**：Stage 1 按方案 C 清 27 行数据，Stage 2 立 V9 + ADR。Sprint 规模估 0.5-1 工作日。

---

## 3. 验收标准

- [ ] 27 个 active person 的生产数据审计报告（含每条的 person_names 明细 + 候选 promote name）
- [ ] 架构师 ruling：最终方案（A/B/C 或组合）
- [ ] 若方案 B：V9 ADR + SQL + self-test（≥ 2 cases）
- [ ] 数据清零 → V9 = 0 violations 且 V1 无回归
- [ ] STATUS.md 不变量表新增 V9 行
- [ ] CHANGELOG 登记

---

## 4. 关联

- **发现来源**：T-P0-025 Gate 0a probe（commit 4cf34b5 side finding）
- **前置**：无（可独立执行，不阻塞 Sprint B T-P0-025）
- **可能关联**：T-P0-016（is_primary demotion 历史成因推测）/ T-P1-002（person_names 降级去重）
- **ADR 候选**：若采纳方案 B，起草 ADR-024 V9 invariant

---

## 5. 备注

- 本 debt 不阻塞 Sprint B T-P0-025，因为 seed matching 走 canonical_name + 全 person_names alias 扫描，不依赖 is_primary
- 但在 Sprint B Stage 3 集成 R6 前值得跑一次，避免 seed_mappings 对这 27 person 产生"外部锚点但本体无 primary"的混乱状态
- 若 Sprint B 节奏许可，可作为 Sprint B 收尾后的 Sprint C 首发
