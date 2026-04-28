# T-P1-027 — disambig_seeds 楚汉多义封号扩充

## 元信息

| 字段 | 值 |
|------|-----|
| ID | T-P1-027 |
| 优先级 | P1 |
| 状态 | registered |
| 主导角色 | 管线工程师 + 古籍专家 |
| 创建日期 | 2026-04-26 |
| 触发 | T-P0-006-δ historian review §4.3（commit fdfb7cb）|
| 触发案例 | Group 18: 韩信↔田荣 via"齐王" surface overlap → false positive |

## 背景

T-P0-006-δ dry-run 中，Group 18（韩信↔田荣）因"齐王"surface form 重叠触发 R1，为严重 false positive。
"齐王"在楚汉时期先后由田荣（前206自立）和韩信（前203被封）分别持有，时段不同、身份不同。

历史专家 §4.3 同时指出以下楚汉时期多义封号需纳入 disambig_seeds：

| surface | 候选人物 | 说明 |
|---------|---------|------|
| 齐王 | 田荣 / 韩信 / 田建 / 田横 | 秦末-楚汉多人先后称齐王 |
| 楚王 | 楚怀王(熊槐) / 楚怀王(熊心) / 项羽 | 跨时代泛称 |
| 汉王 | 刘邦 | 楚汉时期专指，但未来扩章可能遇同号 |
| 怀王 | 楚怀王(熊槐) / 楚怀王(熊心) / 晋怀公(太子圉) / 秦怀公 | 跨代跨国 |

## 实施方案

1. 在 `data/dictionaries/disambiguation_seeds.seed.json` 增补上述 4 组 surface form
2. 每组指定候选 slugs（参考现有数据库中的 canonical persons）
3. `怀王`组需处理 T-P0-031 entity-split 完成后才能精确填写熊心 slug（前置依赖）

## 依赖

- T-P0-031 完成后（熊心独立 entity 确认）再填写 `怀王` group 的 disambig candidates

## Sprint J 增项（2026-04-28）

T-P0-006-ε dry-run 新增 FP proposals（historian reject）：

| 组 | Surface | 人物对 | 性质 |
|----|---------|--------|------|
| G10 | 塞王欣 | 司马欣↔董翳 | 职衔≠shared identity |
| G13 | 齐王 | 田广↔韩信（+田荣） | 同 surface 不同时期不同人 |

`齐王` surface 扩展为 {田荣, 韩信, 田广, 田横, 田建} 5 候选；
`塞王` 需作为新 surface 独立注册。

## 验收条件

- [ ] disambig_seeds 新增 4 组楚汉时期封号
- [ ] 每组 surface 的 candidates 列表完整、slug 均存在于数据库
- [ ] 下次 resolver dry-run 对应 surface form 不触发 false positive
- [ ] `塞王欣` 新增 surface → 消除 G10 类 FP
- [ ] `齐王` 候选列表扩展为 5 人
