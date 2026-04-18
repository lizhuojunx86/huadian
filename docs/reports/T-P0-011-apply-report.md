# T-P0-011 合并应用报告

- **日期**：2026-04-18
- **执行角色**：管线工程师（apply）+ 首席架构师（ADR）+ 古籍/历史专家（抽样复核）
- **Apply run_id**：`39b495d0-a014-4f21-a3f5-62b42035c72f`
- **Dry-run run_id**：`2770e329-d0cc-4d77-b42b-5b8005fb9e39`（纯净版，帝舜修正后）
- **ADR**：ADR-010

---

## 一、合并前后人数

| 指标 | 合并前 | 合并后 |
|------|--------|--------|
| Active persons | 169 | 157 |
| Soft-merged persons | 0 | 12 |
| Merge groups | — | 11 |
| person_merge_log rows | — | 12 |
| identity_hypotheses (R4) | — | 0 |

---

## 二、12 Persons Merged 名单

| # | Canonical | Canonical Slug | ← Merged | Merged Slug | Rule | Confidence |
|---|-----------|----------------|----------|-------------|------|-----------|
| 1 | 后稷 | hou-ji | ← 弃 | u5f03 | R1 | 0.95 |
| 2 | 倕 | chui | ← 垂 | u5782 | R3 | 0.90 |
| 3 | 益 | yi | ← 伯益 | u4f2f-u76ca | R1 | 0.95 |
| 4 | 汤 | tang | ← 商汤 | u5546-u6c64 | R1 | 0.95 |
| 5 | 汤 | tang | ← 成汤 | cheng-tang | R1 | 0.95 |
| 6 | 太甲 | tai-jia | ← 太宗 | u592a-u5b97 | R1 | 0.95 |
| 7 | 太戊 | u592a-u620a | ← 中宗 | u4e2d-u5b97 | R1 | 0.95 |
| 8 | 帝中丁 | u5e1d-u4e2d-u4e01 | ← 中丁 | u4e2d-u4e01 | R1 | 0.95 |
| 9 | 祖甲 | u7956-u7532 | ← 帝甲 | u5e1d-u7532 | R1 | 0.95 |
| 10 | 武乙 | u6b66-u4e59 | ← 帝武乙 | u5e1d-u6b66-u4e59 | R1 | 0.95 |
| 11 | 微子启 | wei-zi-qi | ← 微子 | u5fae-u5b50 | R5 | 0.90 |
| 12 | 西伯昌 | xi-bo-chang | ← 周文王 | u5468-u6587-u738b | R1 | 0.95 |

---

## 三、规则分布

| 规则 | 命中次数 | 占比 |
|------|---------|------|
| R1（surface_form 交叉） | 10 | 83% |
| R3（通假字字典） | 1 | 8% |
| R5（庙号字典） | 1 | 8% |
| R2（帝X 前缀） | 0 | 0% |
| R4（identity_notes） | 0 | 0% |

说明：R2 未触发是因为所有帝X/X 对已被 R1 通过 surface_form 交叉（帝武乙 ∈ 武乙.sf）优先捕获。R4 未产出 hypothesis 是因为当前 DB 中 persons 表无 identity_notes 列（Phase 0 未实现）。

---

## 四、Data Fix（Related Fix #2）

合并 apply 前修正了 T-P0-010 遗留的"帝舜"错误关联：

- DELETE `person_names` id=`a8396067-0d73-4278-bee3-1589f77bb3a4`
- 该行错误地将"帝舜"挂在尧（`2da772b8`）名下
- 舜（`f1a7e4d2`）已有"帝舜"别名，无需新增
- Migration 记录：`services/pipeline/migrations/0003_fix_dishun_misattribution.sql`

---

## 五、Historian 抽样复核（5/5 正确）

| # | Canonical | ← Merged | 合并后别名列表 | 判定 |
|---|-----------|----------|-------------|------|
| 1 | 倕 (chui) | ← 垂 | 倕, **垂** | ✅ 通假字正确 |
| 2 | 后稷 (hou-ji) | ← 弃 | 后稷, **弃**, 稷 | ✅ 本名+官号正确 |
| 3 | 微子启 (wei-zi-qi) | ← 微子 | 微子启, 启, **微子** | ✅ 全称+省称正确 |
| 4 | 汤 (tang) | ← 商汤, 成汤 | 汤, 成汤, 武王, 王, 朕, 予一人, **商汤**, **天乙**, **高后成汤** | ✅ 三合一完整 |
| 5 | 祖甲 (u7956-u7532) | ← 帝甲 | 祖甲, **帝甲** | ✅ 庙号对应正确 |

---

## 六、Web API 端到端验证（5/5 通过）

| 验证 | GraphQL 查询 | 期望 | 结果 |
|------|-------------|------|------|
| 搜"垂" | `persons(search:"垂")` | 1 条, slug=chui | ✅ total:1, slug:"chui" |
| 搜"成汤" | `persons(search:"成汤")` | 1 条, slug=tang | ✅ total:1, slug:"tang" |
| 搜"帝甲" | `persons(search:"帝甲")` | 1 条, slug=u7956-u7532 | ✅ total:1, slug:"u7956-u7532" |
| 老 slug u5782 | `person(slug:"u5782")` | 返回 canonical 倕 | ✅ slug:"chui", names 含"垂" |
| Canonical slug chui | `person(slug:"chui")` | 详情含"垂"别名 | ✅ names: ["垂", "倕"] |

---

## 七、已知 Follow-up

1. **Canonical 选择对"帝X"前缀有系统性偏差**：组 7(帝中丁) / 组 9(武乙←帝武乙) 中，canonical 选了"帝X"形式而非裸名形式。原因：surface_forms 数量 tiebreaker 偏向吸收了两种形式的一方。建议增加"去尊称前缀优先"规则。
2. **组 3 益/伯益 canonical 选择**：选了"益"（本名），传统史书索引惯用"伯益"。学术上两者均可，记录在案。
3. **冗余实体清理**（ADR-010 Related Fix #1）：姒氏 / 昆吾氏 / 羲氏 / 和氏 / 荤粥 5 个虚假 person 尚未 soft-delete，待后续 data-fix commit。
4. **API 集成测试 2 case 预存失败**：hasMore pagination + updatedAt ordering，因 T-P0-010 数据量增长导致，非本次改动引起。
