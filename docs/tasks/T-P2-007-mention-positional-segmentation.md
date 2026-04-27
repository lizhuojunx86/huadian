# T-P2-007 — Mention 段内位置切分（split_for_safety 终态化）

## 元信息

| 字段 | 值 |
|------|-----|
| ID | T-P2-007 |
| 优先级 | P2 |
| 状态 | registered |
| 主导角色 | 管线工程师 + 古籍专家 + 后端工程师 |
| 创建日期 | 2026-04-27 |
| 触发 | Sprint H T-P0-031 楚怀王 entity-split historian a117fbf §6.1 + ADR-026 §2.3 scenario #4 |

## 背景

ADR-026 split_for_safety 子场景定义：当一段 SE 内同时指代两个不同人物（如《史记·项羽本纪》§6 段同时含战国楚怀王熊槐 + 秦末楚怀王熊心），现有 schema 无法在 mention 粒度精确分桶，只能 entity-level "保 1 + 复 1" 的过渡态。

T-P0-031 楚怀王 entity-split apply 后，熊心 entity 上 +2 行 person_names 副本（怀王 / 楚王），与 source 楚怀王 entity 上的同 surface 行**共享同一 source_evidence_id**（73e39311）。这是合规过渡态，但产生少量审计噪声："一段引文同时挂在两个 person 上"。

## 终态目标

引入 mention 粒度的 position offset + 段内引文片段，使一段 SE 可以精确分桶到多个不同的 person。

## 候选 schema 设计

- 激活既有空 mentions 表 OR 在 person_names 加位置字段
- 字段：mention_quoted_text（段内引用片段）/ mention_position_start / mention_position_end / mention_subject_dynasty（可选，配 V12）
- 历史回填：现有 ~3000 行 person_names 需要回填位置（NER prompt 升级 v1-r6 输出 position）

## 触发上调条件

累积 **≥ 3 例同类 split_for_safety case**（含本 sprint T-P0-031 = 1 例）→ 由 PM/architect 决定升级到 P1 / P0 优先级。

## 验收条件（未来）

- [ ] mentions 表激活或 person_names 扩字段
- [ ] NER prompt v1-r6 输出 mention position
- [ ] 全 corpus 回填脚本（含成本估算）
- [ ] 关闭已存在 split_for_safety 状态：T-P0-031 楚怀王副本 → 精确分桶
- [ ] V12 invariant 候选实施（关联 T-P2-008）
