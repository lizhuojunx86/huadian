# T-P0-010 最终报告：真书端到端 Pilot — 史记·本纪（前 3 篇）

- **日期**：2026-04-18
- **执行角色**：管线工程师（主导）+ 古籍/历史专家（质量抽检）
- **性质**：Phase 0 pipeline 基础设施建设 + 首次真实数据 pilot

---

## 一、成本实测 vs 预算

| 阶段 | 段落数 | 成本 | 预算 | 使用率 |
|------|-------|------|------|--------|
| Phase A（五帝本纪） | 29 | $0.54 | $5.00 | 10.8% |
| Phase B（夏本纪） | 35 | $0.56 | — | — |
| Phase B（殷本纪） | 35 | $0.67 | — | — |
| Phase B 合计 | 70 | $1.23 | $15.00 | 8.2% |
| **总计** | **99** | **$1.77** | **$20.00** | **8.9%** |

**结论**：实际成本远低于预算。Sonnet 4.6 对古文 NER 的性价比极高。

### 单段成本分布

- 平均：$0.018/段
- 最低：$0.011（地理描述段，无人物）
- 最高：$0.040（§25 五帝本纪，16 人物密集段）
- 无任何段超过 $2 单段上限

### 成本推算

按此实测数据推算全量：
- 史记 130 篇 × ~30 段/篇 × $0.018 ≈ **$70**
- 二十四史全量（~4000 万字）粗估 ~$2000-3000

---

## 二、质量指标

### Phase A vs Phase B 对比

| 指标 | Phase A（五帝） | Phase B（夏+殷） | 趋势 |
|------|----------------|-----------------|------|
| 成功率 | 100% (29/29) | 100% (70/70) | 稳定 ✅ |
| 抽样正确率 | 80% (8/10) | 90% (9/10) | 改善 ✅ |
| 人物召回率 | ~100% | ~100% | 稳定 ✅ |
| 人物精确率 | ~94% | ~93% | 稳定 |
| 帝X 误归 | 1 处 (帝舜→尧) | 0 处 | 修复 ✅ |
| 姓氏提取 | 0/4 提取 | 部分提取 | 改善 |
| 同人重复 | 2 对 | 11 对 | 恶化 ⚠️ |

### 累计产出

| 指标 | 值 |
|------|-----|
| Books | 3 |
| Persons | 169 |
| Person names | 273 |
| Seed SQL | 3 files |
| 模型 | claude-sonnet-4-6 |
| Prompt | ner/v1 (r2) |

---

## 三、发现的问题（按严重性）

### CRITICAL

| # | 问题 | 根因 | 修复方向 | 状态 |
|---|------|------|---------|------|
| C1 | 帝舜被挂在尧名下 | LLM 段落语境混淆 | prompt 帝X校验规则 | **Phase B 已修复** |

### HIGH

| # | 问题 | 根因 | 修复方向 | 状态 |
|---|------|------|---------|------|
| H1 | 同人重复（弃/后稷, 倕/垂, 汤/成汤/商汤, 帝号/庙号 等 13 对） | 跨 chunk 独立抽取 + merge 按 name_zh 字面匹配 | **T-P0-011** identity_resolver | planned |
| H2 | 商王 reality_status 标 legendary | prompt 判定规则不够精细 | 提供甲骨文已证实商王列表 | planned |

### MEDIUM

| # | 问题 | 根因 | 修复方向 | 状态 |
|---|------|------|---------|------|
| M1 | 冗余实体（羲氏, 和氏, 荤粥, 昆吾氏） | LLM 对部族/合称判断偏差 | prompt v2 部族排除 + 合称规则 | **Phase B 部分修复** |
| M2 | 姓氏系统性遗漏（公孙/姒/子/姬） | prompt 缺姓氏规则 | prompt v2 姓氏规则 | **Phase B 部分修复** |
| M3 | 76% slug 使用 Unicode fallback | _PINYIN_MAP 覆盖不足 | 引入 pypinyin 或扩展 map | planned |

### LOW

| # | 问题 | 根因 | 修复方向 | 状态 |
|---|------|------|---------|------|
| L1 | name_type 偶有不精确 | 古人称谓体系复杂 | 迭代优化 | deferred |
| L2 | 复合称呼整体保留为 surface_form | prompt 规则执行不一致 | 迭代优化 | deferred |

---

## 四、对系统各组件的反馈

### LLM Gateway
- ✅ 稳定，99 段零失败
- ✅ 成本追踪准确
- ✅ TraceGuard shadow 模式无干扰
- ⚠️ 审计未走 AuditSink（脚本直接调 Gateway，绕过了 audit writer 的 DB 写入）

### TraceGuard
- ✅ shadow 模式正常
- ⚠️ 规则未实际 enforce（Phase 0 预期行为）
- 建议 Phase 1 启用 enforce 模式并补充 NER 专用规则

### NER Prompt
- ✅ structured surface_forms 设计正确，LLM 能稳定输出
- ✅ identity_notes 机制有效（少典/神农/炎帝等争议点均标注）
- ✅ reality_status 判定基本合理
- ⚠️ 姓氏规则有效但覆盖不完整（"赐姓X氏"模式未触发）
- ⚠️ 同人合并不是 prompt 能解决的问题

### DB Schema
- ✅ persons / person_names / raw_texts / books 表结构够用
- ✅ identity_hypotheses 表已就绪但本次未写入（等 T-P0-011）
- ⚠️ pipeline_runs 只记录了 ingest 阶段，extract/load 未记录

### Seed Dump
- ✅ SQL 文件生成正确，可重放
- ⚠️ dump 覆盖所有 persons（非 book-scoped），Phase B dump 包含 Phase A 数据

---

## 五、建议的下一步

### 立即（T-P0-011）
1. **跨 chunk 身份消歧 identity_resolver**：基于 surface_form 交叉匹配 + variant_chars 字典 + identity_notes
2. 回溯合并已入库的 169 persons

### 近期（Phase 0 收尾）
3. **slug 生成改进**：引入 pypinyin 替代硬编码 map
4. **商王 reality_status 校正**：historian 提供甲骨文已证实王列表
5. **pipeline_runs 补全**：extract/load 阶段也记录 run
6. **audit 通路打通**：确保 LLM 调用写入 llm_calls 表

### 中期（Phase 1）
7. **prompt v2 正式版**：吸收 pilot 所有发现，替换示例为非目标篇目
8. **TraceGuard enforce 模式**：启用 NER 专用规则
9. **扩量跑**：周本纪及以后

---

## 六、Commit 汇总

| # | Hash | 内容 |
|---|------|------|
| 1 | a17c0de | fix: Python 模块导入修复 |
| 2 | f30450c | feat: ctext adapter + 三篇 fixtures |
| 3 | c0c5646 | feat: ingest 模块 |
| 4 | 6b7fe38 | feat: NER prompt v1 + loader |
| 5 | 9dd6950 | feat: extract 模块 |
| 6 | 7ad3ab0 | feat: load 模块 |
| 7 | 76c3c5f | feat: CLI + seed dump |
| 8 | dccd123 | feat: structured surface_forms (P0) |
| 9 | 077e69f | feat: prompt v1-r2 (A-class fixes) |
| 10 | 7fbb3b4 | docs: Phase A quality report |
| 11 | 77dd8f4 | chore: relocate seeds + cli fix |
| 12 | 649a176 | docs: Phase B quality report |
| 13 | (本次) | docs: findings + STATUS/CHANGELOG |
| 14 | (本次) | docs: T-P0-011 task card |
