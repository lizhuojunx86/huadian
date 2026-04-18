# T-P0-011: 跨 Chunk 身份消歧

- **状态**：done
- **主导角色**：管线工程师 + 首席架构师（ADR）
- **协作角色**：古籍/历史专家（规则审核）
- **所属 Phase**：Phase 0
- **依赖任务**：T-P0-010 ✅（pilot 暴露的问题驱动）
- **创建日期**：2026-04-18

---

## 目标（Why）

T-P0-010 Phase A 发现：LLM 逐 chunk 独立抽取无法解决跨 chunk 身份消歧问题。具体表现：

1. **通假字/异体字同人未合并**：倕(chui) / 垂(u5782) 是同一人的通假写法，被拆为两个 person
2. **同人不同称谓未合并**：弃(u5f03) / 后稷(hou-ji) 是同一人（周始祖），被拆为两个 person
3. **identity_notes 标注了但未消费**：LLM 已在 identity_notes 中标注"倕与垂或为同人"，但无下游消歧步骤处理

根因：每个 chunk 独立调用 LLM，LLM 看不到其他 chunk 的抽取结果，无法做跨 chunk 合并。

---

## 范围（What）

### 包含

1. **ADR：跨文本身份消歧策略选型**
   - Option A：抽取后 Python 规则合并（基于 surface_forms 重合 + identity_notes 交叉引用 + variant_chars 字典）
   - Option B：二次 LLM 调用（将一本书的全部抽取结果喂给 LLM 做合并）
   - Option C：混合（规则先跑，歧义再调 LLM）

2. **identity_resolver 模块**
   - `services/pipeline/src/huadian_pipeline/resolve.py`
   - 输入：ExtractionResult (所有 chunk 的 ExtractedPerson)
   - 输出：合并后的 MergedPerson 列表 + identity_hypotheses 候选
   - 规则引擎：
     - R1: surface_form 完全匹配 → 合并
     - R2: variant_chars 字典匹配 → 合并 + 标注
     - R3: identity_notes 交叉引用 → 生成 identity_hypothesis
     - R4: 同音/近音检测（pypinyin）→ 候选合并

3. **variant_chars 字典加载**
   - 从 `data/dictionaries/` 加载通假字/异体字映射
   - 在 resolve 阶段消费

4. **回溯跑**
   - 对 T-P0-010 已入库的 169 persons 做合并
   - 验证合并结果

### 不包含

- 不改 NER prompt（NER 阶段的 identity_notes 标注已足够）
- 不改 DB schema
- 不做跨书消歧（仅本书内）

---

## 交付物

- ADR-0XX：跨文本身份消歧策略
- `resolve.py` 模块
- 回溯合并报告
- 测试覆盖

---

## 估算

- 1~2 天（含 ADR 讨论 + 实现 + 回溯）
