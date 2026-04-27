# T-P0-031 — 楚怀王 Entity Split (熊槐/熊心 同号异人)

## 元信息

| 字段 | 值 |
|------|-----|
| ID | T-P0-031 |
| 优先级 | **P0** — 数据正确性 critical issue |
| 状态 | **done** (2026-04-27, Sprint H session 4) |
| 主导角色 | historian + pipeline-engineer |
| 创建日期 | 2026-04-25 |
| 创建者 | historian@huadian（Sprint G T-P0-006-δ Stage 3 merge review） |
| 触发 | T-P0-006-δ historian review Group 13 split 裁决 |
| 关联 | ADR-014 (canonical merge model) / **ADR-026 (entity split protocol, first application)** / T-P0-006-γ (秦本纪 ingest) / T-P0-006-δ (项羽本纪 ingest) |

---

## §背景

中国历史上有**两个"楚怀王"**，均为楚国国君，但相隔约 90 年，是完全不同的人：

### 楚怀王·熊槐（战国）

- **朝代**：战国楚
- **生卒**：?–前 296 年
- **身份**：楚威王之子，楚国第 37 任国君
- **关键事件**：被秦国张仪欺骗入秦，扣留不返，客死秦国
- **史源**：
  - 《史记·秦本纪》：秦昭襄王段"楚怀王走赵，赵不受，复归秦"
  - 《史记·楚世家》："怀王三十年，秦复来伐……怀王乃入秦……遂留怀王，以求割地"
  - 《战国策·楚策》：张仪诳楚详载

### 楚怀王·熊心（秦末）

- **朝代**：秦末
- **生卒**：?–前 206 年
- **身份**：战国楚怀王·熊槐的**孙辈后裔**（非直系子），秦末反秦义军的名义领袖
- **关键事件**：项梁寻得民间牧羊人熊心，立为"楚怀王"（借用其祖先号召力）；后被项羽尊为义帝，迁长沙，遣杀于江中
- **史源**：
  - 《史记·项羽本纪》："项梁乃求楚怀王孙心民间，为人牧羊，立以为楚怀王，从民所望也"
  - 《史记·高祖本纪》："怀王约入关者王之"
  - 《汉书·高帝纪》同载

### 两人关系

熊心被立为"楚怀王"，正是因为人民怀念熊槐——"从民所望也"。这是中国历史上典型的"借号召令"策略。**二者共享"楚怀王"称号，但是完全不同的历史人物。**

---

## §当前状态

### Entity 层

数据库中仅有**一个**"楚怀王"entity：

| 字段 | 值 |
|------|-----|
| slug | `u695a-u6000-u738b` |
| dynasty | 战国 |
| 创建来源 | T-P0-006-γ 秦本纪 ingest |

### Source Evidence / Mentions 分桶（按章节）

| 章节 | 实际指代 | mentions 归属 |
|------|---------|--------------|
| 史记·秦本纪 | **熊槐**（战国，秦昭襄王段叙事） | 正确归入现有 entity ✅ |
| 史记·项羽本纪 | **熊心**（秦末，项梁立楚怀王段叙事） | **错误归入**现有 entity ❌ |

### 相关 Entities

T-P0-006-δ Stage 3 historian review 中，Group 13 安全子合并已裁决：
- **熊心**（新 entity from 项羽本纪 NER）
- **怀王**（新 entity → merged into 熊心）
- **义帝**（新 entity → merged into 熊心）

Stage 4 apply 后，熊心 entity 将吸收 怀王 + 义帝 两个 alias。但楚怀王 entity 仍包含项羽本纪的错误 mentions。

---

## §处理方案候选

### 方案 A — Entity Split + Mention Redirect（推荐）

1. 将现有"楚怀王"entity 的 source_evidences 按章节分桶
2. 秦本纪 mentions 留在现有 entity（= 熊槐，保持 dynasty=战国）
3. 项羽本纪 mentions redirect 到 熊心 entity（Stage 4 apply 后已有）
4. 为熊心 entity 添加"楚怀王"alias（name_type=alias，标注 source_evidence 来自项羽本纪）
5. 为 disambig_seeds 添加"楚怀王"歧义组（熊槐 vs 熊心）

**优点**：精确修复，数据模型干净
**风险**：需要 mention-level SQL 操作（source_evidences UPDATE），须遵守 ADR-017 pg_dump anchor 协议

### 方案 B — 新建第二 Entity + 人工迁移

1. 新建"楚怀王(秦末)"entity（可能需新 slug 或 disambig 后缀）
2. 手动将项羽本纪 mentions 从现有 entity 迁移到新 entity
3. 将新 entity merge into 熊心（或反向）

**优点**：不修改现有 entity 的 identity
**缺点**：新建 entity → slug 命名问题（如何区分两个楚怀王的 slug）；额外 merge 步骤

### 方案 C — 标记 + 延后

1. 在现有"楚怀王"entity 上添加 identity_hypothesis（标注跨章同号异人）
2. 不做 entity split，等 mention-level 消歧基础设施就绪后再处理

**优点**：零风险
**缺点**：数据错误持续存在；查看"楚怀王"详情页会混合两人信息

### 建议

**方案 A**。理由：
- 数据正确性是项目宪法（docs/00_项目宪法.md）的核心原则
- mention-level SQL 操作复杂度可控（按 chapter slug 过滤 source_evidences 即可分桶）
- ADR-017 pg_dump anchor 协议已成熟（Sprint A-F 累计 6 次使用）

---

## §不在本卡

- ADR-014 manual_textbook_fact rule taxonomy 升级（如熊心 entity 的 canonical name 选择涉及命名规范，但属 ADR 层面讨论，非本 task 范畴）
- V12 invariant 设计（"同号异人跨时段 entity 完整性检查"——Sprint G retro 候选，但 invariant 规则设计属架构师职责）
- disambig_seeds 楚汉扩充（T-P1-027 单独卡）
- R1 dynasty 前置过滤改进（T-P1-028 单独卡）

---

## §验收条件（Sprint H 完成）

- [x] 楚怀王(熊槐) entity (777778a4) 保留秦本纪 §65 楚怀王 primary mention（hist a117fbf §5 keep）
- [x] 项羽本纪 §6 mentions（怀王 + 楚王）通过 ADR-026 split_for_safety 机制 INSERT 副本到熊心 entity（48061967）；source 行保留
- [x] 熊心 entity dynasty='秦末'（Sprint G G13 子合并产物已设置）
- [x] V1-V11 无回归（16 V invariant tests 全绿 + SQL 探针 0/0/0/0/0/0/0）
- [x] pg_dump anchor 创建：`ops/rollback/pre-t-p0-031-stage-3-20260427-204634.dump:52bd6f91da5c`
- [x] entity_split_log 2 行 audit（split_for_safety × 2，per ADR-026 §4 option X）
- [ ] disambig_seeds 包含"楚怀王"歧义组（**deferred to T-P1-027 楚汉 disambig_seeds 扩充，关联但非本卡范畴**）

---

## §实施记录（Sprint H Stage 3）

| 阶段 | Commit | 内容 |
|------|--------|------|
| ADR-026 accepted | `ed2e8c8` | Entity Split Protocol 协议落地（双签 + 4 闸门 + dry-run + pg_dump anchor + 单事务）|
| Migration 0013 | `c119b7c` | entity_split_log 表 + Drizzle schema |
| Split script | `ba01dea` | ops/scripts/one-time/split_chu_huai_wang_entity.py（dry-run + apply 双模式）|
| Dry-run 报告 | `ddc6108` + `56a6743` | docs/sprint-logs/sprint-h/chu-huai-wang-split-dry-run.md（含 4 闸门 + RETURNING 双 pn_id 对账）|
| Real apply | `14eb2f5` | --apply COMMIT；2 person_names INSERTs + 2 entity_split_log 行；V1-V11 全绿 |

### 数据形态变化

- **Source entity** 777778a4（楚怀王/战国/熊槐）：3 行 person_names 不变（8fb2afc3 楚怀王 primary / 7a68ff90 怀王 posthumous / 2afc61fc 楚王 nickname）
- **Target entity** 48061967（熊心/秦末）：3 行 → 5 行（+99ecacfc 怀王 posthumous, +a298f8d5 楚王 nickname；共享 SE 73e39311）
- **entity_split_log**：0 行 → 2 行（split_for_safety × 2）
- **active persons**：663 → 663（无变化，仅 mention-level INSERT）

### 双签 trace

- **Architect ACK**：commit `ed2e8c8` ADR-026 §8（10 决策点）+ commit `56a6743` 选项 P 文档澄清
- **Historian ruling**：commit `a117fbf` §5 mention bucketing 裁决
