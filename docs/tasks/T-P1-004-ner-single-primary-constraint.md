# T-P1-004: NER 阶段单人多 primary 约束

- **状态**：done
- **主导角色**：管线工程师 + QA 工程师
- **所属 Phase**：Phase 1（技术债）
- **依赖任务**：T-P1-002 ✅（历史数据 backfill 已清理）
- **创建日期**：2026-04-19
- **登记来源**：T-P1-002 S-5 衍生债（docs/debts/T-P1-004-ner-single-primary.md）

## 目标

在 NER 阶段加硬约束 + ingest 层校验，让"每 person 最多 1 个 name_type='primary'"
成为管线不变量，防止新书 ingest 时再生多 primary 脏数据。

三层防御：
1. **NER prompt 硬约束**：明确要求 LLM 每个 person 输出恰好 1 个 name_type='primary'
2. **Ingest 校验**：load.py 在 person_names insert 前检查，违反时自动降级 + 日志
3. **（可选）DB partial unique index**：schema 层兜底，S-3 评估

## 范围（IN SCOPE）

1. NER prompt v1 修订（single-primary 约束 + few-shot 示例）
2. load.py validation + auto-demotion 逻辑
3. QC 规则：ner.single_primary_per_person
4. pytest 新增测试
5. ADR-012 决策记录

## 范围（OUT OF SCOPE）

- 历史数据修复（T-P1-002 已完成）
- name_type 枚举值扩展
- NER prompt 其他优化（非 primary 相关）

## 风险

| 风险 | 缓解 |
|------|------|
| prompt 变更影响 NER cache 命中 | prompt 版本号升级（v1→v1-r3），已有 cache 按旧版本 key 保留 |
| auto-demotion 误降正确 primary | 降级 + warn log，事后可发现；NER prompt 改善后误触率应极低 |
| partial unique index 阻断现有数据 | T-P1-002 已清理所有多 primary，约束可直接加 |

## 工作流

### S-0：任务卡 ✅
本文件。

### S-1：现状分析
- 定位 NER prompt、load.py 代码路径
- 回放 T-P1-002 数据：14 NER-source 多 primary 冲突类型分类
- 交付：docs/tasks/T-P1-004-s1-analysis.md

### S-2：规则设计
- NER prompt single-primary 规则 + few-shot 示例
- load.py validation 逻辑
- ADR-012 初稿
- 报告用户确认

### S-3：实施
- 3.1 NER prompt 修订（v1-r3）
- 3.2 load.py ingest 校验 + auto-demotion
- 3.3 评估 DB partial unique index
- 3.4 pytest 测试

### S-4：DB 写入（仅 3.3 需要）
- 红线协议确认

### S-5：验证 + 收尾
- 验证 + STATUS / CHANGELOG / debt doc 更新
- ADR-012 accepted
- commit + push
