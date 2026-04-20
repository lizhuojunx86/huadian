# T-P1-009: NER 合成词护栏（文武/尧舜 类识别）

## 元信息

- **优先级**: P1
- **主导角色**: pipeline-engineer
- **协作角色**: historian（合成词黑名单审查）
- **触发来源**: T-P0-006 α sprint Stage 4c（"文武" surface 硬 DELETE 清理）
- **预估工作量**: S
- **依赖**: none

## 背景

T-P0-006 α 的 NER v1-r4 将"文武"（文王+武王的合称，如"文武之道""文武之业"）误识别为 posthumous name_type 分别挂到两个独立人物上。这导致 R1 surface_form 匹配产生错误连接，Union-Find 将文王族和武王族合入同一组（Group 3）。

Stage 4c 用硬 DELETE 清理了 2 条"文武" surface，但根因未治——下一本书 ingest 若遇到类似合称（"尧舜""汤武""桓文"等）会再现同一问题。

## 验收标准

- [ ] NER prompt v1-r5 增加明确指令：避免把合称 X+Y 作为独立 name/surface 挂到任一单个人物
- [ ] 添加合称黑名单 few-shot 示例（"文武"→不提取；"尧舜"→不提取；"汤武"→不提取）
- [ ] `_filter_pronoun_surfaces` 或新函数增加合称过滤规则
- [ ] ≥ 5 条测试覆盖合称过滤
- [ ] 现有 NER 测试不回归

## 非范围

- Resolver 端 Union-Find 簇验证 → T-P1-008
- R2 dynasty 预过滤 → T-P1-010
- u6853-u516c 桓公拆分 → T-P1-007

## 相关文档

- docs/sprint-logs/T-P0-006-alpha/stage-3b-historian-package.md (Group 3 根因)
- docs/sprint-logs/T-P0-006-alpha/stage-5-sprint-summary.md
