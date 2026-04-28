# T-P1-030 — ADR-014 addendum：textbook-fact merge_rule 正式规范

## 元信息

| 字段 | 值 |
|------|-----|
| ID | T-P1-030 |
| 优先级 | P1 |
| 状态 | registered |
| 主导角色 | 首席架构师 + 古籍专家 |
| 创建日期 | 2026-04-28 |
| 触发 | T-P0-006-ε Sprint J（textbook-fact 累计 4 次，超过 3 次阈值） |

## 背景

ADR-014（names-stay model-A）定义了 `manual_textbook_fact` 作为 merge_rule 枚举值，
但未给出正式的适用条件、举证要求和拒绝准则。

Sprint E→J 期间积累了 4 个 textbook-fact 合并案例：

| # | Sprint | 对 | 史料引用 | 关系 |
|---|--------|-----|---------|------|
| 1 | Sprint E（T-P1-025） | 重耳 → 晋文公 | 《史记·晋世家》: "重耳，晋献公之子" | 名→庙号 |
| 2 | Sprint G（T-P0-006-δ G15） | 项籍 → 项羽 | 《史记·项羽本纪》: "名籍，字羽" | 名→字 |
| 3 | Sprint J（T-P0-006-ε G8） | 嬴政 → 始皇帝 | 《史记·秦始皇本纪》: "朕为始皇帝" | 名→尊号 |
| 4 | Sprint J（T-P0-006-ε G11） | 陈胜 → 陈涉 | 《史记·陈涉世家》: "陈胜者，阳城人也，字涉" | 名→字 |

## 任务目标

在 ADR-014 增补 §textbook-fact 章节，规范以下内容：

1. **适用条件**：须满足 (a) 史料直接言明同人关系 + (b) 无歧义（唯一对应）
2. **举证格式**：史料原文 + 篇目 + 关系类型（名/字/号/尊号/庙号等）
3. **拒绝准则**：仅有 surface overlap 无史料直言同人者，不得用 textbook-fact
4. **与 R1+historian-confirm 的区别**：historian-confirm 是推断，textbook-fact 是史料明文
5. **chain merge 处理规范**：当 textbook-fact 合并导致 chain（如陈王→陈胜→陈涉），
   read-side 需 follow chain（现有逻辑已支持），文档需明确说明

## 参考文件

- `docs/decisions/ADR-014-person-merge-model.md`（待增补）
- `docs/sprint-logs/sprint-j/historian-review-2026-04-28.md`（4 个案例的 historian 举证）

## 验收条件

- [ ] ADR-014 增补 §textbook-fact 章节（≥200 字，含 4 个已有案例作为 precedent list）
- [ ] historian 确认适用条件与拒绝准则表述准确
- [ ] 架构师 sign-off（ADR 更新需架构师审核）
- [ ] `merge_rule` 枚举注释更新（schema 或 Python enum）
