# `data/dictionaries/` 裁决与约束备忘

> 本文件记录**历史专家/架构师就字典种子文件作出的裁决**。
> 不构成代码，但 T-P0-006 加载器、后端 API、前端展示层均须遵守。
> 新增裁决请追加 `## Ruling-NNN` 章节，不修改历史条目。

---

## 背景

- **任务**：T-P0-004 历史专家字典初稿（Phase 0：秦汉）
- **首批交付物**（2026-04-16）：
  - `polities.seed.json`（5 条：秦 / 西汉 / 新 / 更始 / 东汉）
  - `reign_eras.seed.json`（89 条，含 `_datingGapNote` 7 节）
  - `disambiguation_seeds.seed.json`（10 组 surface / 26 行）
- **裁决者**：架构师（用户本人）
- **裁决日期**：2026-04-16
- **生效范围**：Phase 0 全部字典加载 + 相关展示层

---

## Ruling-001 · 西汉起始年

> 1. 西汉起始年 → 采纳 BC -202（称帝说，主流叙事）。要改成 BC -206 汉王元年
>    说需新开 ADR，不走默认。

**落地**：
- `polities.seed.json → han-western.yearStart = -202` 保持不变。
- 若未来改 BC -206 说：必须开 ADR 记录依据 + 影响面（event_accounts / 年号起点 / 诗词系年等全部回归）。

---

## Ruling-002 · 更始政权（更始帝刘玄 CE 23–25）

> 2. 更始 → 独立 polity（han-gengshi），叙述层归入"过渡政权"。与东汉并存期
>    由 event_accounts 的 sequence_step + ruler_overlap 字段处理（属 T-P0-006
>    加载器范畴，非本卡）。

**落地**：
- `polities.seed.json → han-gengshi` 保留为独立 polity，`metadata.classification = "han_restoration"`，叙述层分类为"过渡政权"。
- **CE 25 并存处理**：
  - 更始帝 CE 23 二月即位至 CE 25 九月被赤眉杀。
  - 光武帝 CE 25 六月己未即位于鄗，建武元年。
  - CE 25 共六—九月段更始/建武并行。
  - event_accounts 表通过 `sequence_step`（事件内时序）+ `ruler_overlap`（政权并列标记）字段承载；属 **T-P0-006 加载器范畴**，本批种子不处理。
- 前端"王朝时间轴"展示时，"更始"单列色块，不与东汉合并。

---

## Ruling-003 · "后元"三撞（文帝 / 景帝 / 武帝）

> 3. 后元三撞（文帝/景帝/武帝）→ 保留 (emperorPersonSlug, name) 二元组识别。
>    T-P0-006 加载器必须 validate unique on (emperorPersonSlug, name)；前端展
>    示层强制带前缀「文帝后元 / 景帝后元 / 武帝后元」，不裸用"后元"。

**落地**：
- **唯一性键**：`(emperorPersonSlug, name)` 二元组；加载器须 validate unique，违反即拒绝加载。
  - ⚠️ 注意：`reignEras.emperorPersonSlug` schema 允许 null，但"后元"这类跨朝同名必须要求非 null，否则无法区分。加载器对同名条目强制要求 emperorPersonSlug 非 null。
- **展示层规则**：
  - 凡 `(emperorPersonSlug, name)` 在表中出现 ≥2 次（即 name 重名），前端展示**强制带帝号前缀**：`文帝后元`、`景帝后元`、`武帝后元`。
  - 同理适用于"前元""中元"：`文帝前元 / 景帝前元` vs `景帝中元`。
  - API 返回同时带 `displayName`（含前缀）与 `name`（裸名）两字段，前端优先用 displayName。
- **reign_eras.seed.json 中的条目名**：已以"文帝前元 / 景帝前元"等带前缀形式录入，无需运行时拼接。裸名（后元/前元/中元）不作主 key。

---

## Ruling-004 · "甘露"跨代同名（西汉宣帝 / 曹魏曹髦 / 西晋武帝）

> 4. 甘露跨代（西汉宣帝 / 曹魏曹髦 / 西晋武帝）→ Phase 0 内唯一 OK。
>    reign_eras 表加 (polity_slug, name) 唯一约束这件事记入 T-P0-002 follow-up
>    F-5（由后端在 Phase 1 前处理，本卡不动）。

**落地**：
- **Phase 0 范围内**：甘露（宣帝 BC 53–BC 50）是唯一的"甘露"年号，当前无冲突。
- **Phase 1 前必须补**：在 reign_eras 表增加 `(polity_slug, name)` 唯一约束（或更强的 `(polity_slug, name, year_start)`），以支持曹魏甘露（CE 256–260）、西晋武帝 **实际使用的"咸宁"等**、以及后代同名年号入库。
- **Follow-up 登记**：T-P0-002 后续清单 **F-5**（由后端工程师负责），Phase 1 启动前完成。本卡（T-P0-004）不动 schema。

---

## Ruling-005 · 未落库 slug 的加载策略

> 5. slug 指向未落库对象 → 下一步继续拆出 persons.seed.json + places.seed.json
>    （你负责，秦汉 20~40 人重点 + 重点都城 + 郡国）。T-P0-006 加载器采用两
>    阶段策略：(a) 先加载基础字典（polities / reign_eras / disambiguation），
>    (b) 再加载依赖字典（persons / places），FK 检查用 PG 的
>    DEFERRABLE INITIALLY DEFERRED。

**落地**：
- **字典加载顺序（T-P0-006 加载器）**：
  - **Stage A（基础字典，无 person/place FK 依赖或接受 null FK）**：
    1. `polities.seed.json`
    2. `reign_eras.seed.json`（`emperorPersonSlug` 暂允许 null）
    3. `disambiguation_seeds.seed.json`（`personSlug` 暂允许 null）
  - **Stage B（依赖字典）**：
    4. `persons.seed.json` — 建人物实体。
    5. `places.seed.json` — 建地点实体。
  - **Stage C（回填 FK）**：
    6. 解析 Stage A 中的 slug 引用，UPDATE reign_eras.emperor_person_id、disambiguation_seeds.person_id、polities.capital_place_id。
- **事务策略**：单一 transaction，使用 PG 的 `SET CONSTRAINTS ALL DEFERRED` 或 `DEFERRABLE INITIALLY DEFERRED` 约束定义，容许 Stage A 的外键在 commit 前暂不校验。schema 中相关 FK 若尚未声明 DEFERRABLE，由后端在 T-P0-006 loader 设计阶段一并处理。
- **persons.seed.json 范围**（本卡后半段交付）：秦汉 20–40 人重点，须覆盖：
  - 全部 disambiguation_seeds 引用的 personSlug（硬性 FK）。
  - 鸿门宴 NER 必要角色（T-P0-006 首批金集）。
  - 各朝代锚点帝王（用于 reign_eras.emperor_person_id 回填）。
- **places.seed.json 范围**：秦汉重点都城 + 重点郡国 + 战役/典故地。

---

## 工作约束（非裁决，但与本批种子等价约束）

### C-01 · `_` 前缀字段为历史专家元数据

- 所有 `_meta / _notes / _sources / _transitionNote / _datingGapNote` 字段**仅供历史专家/审核者核对**；
- T-P0-006 加载器**必须**识别并忽略所有 `_` 前缀键，不写入 DB；
- 加载器单元测试须对此行为断言。

### C-02 · 公元年份编码

- BC 用负整数（BC 1 = -1）；CE 用正整数（CE 1 = 1）；**无 0 年**。
- 跨公元元年的条目（如平帝元始）在 `_notes` 中显式说明。
- 加载器在 year 解析/展示时须提供 BC/CE 标签化工具，不裸输出整数。

### C-03 · slug 命名规范

- 朝代 polity：`{dynasty-lower-hyphen}` 或 `{dynasty}-{qualifier}`（han-western、han-eastern、han-gengshi）。
- 人物 person：优先 `{surname}-{given}-{distinguisher}`（han-xin-huai-yin-hou、wang-shang-cheng-du-hou）。
- 地点 place：优先古名拼音（xianyang、changan、luoyang）；郡加 `-jun` 后缀（yingchuan-jun、nanyang-jun）。
- 帝王 person：`{dynasty}-{posthumous-pinyin}`（han-wu-di、han-guang-wu-di、qin-shi-huang）。
- 全小写、kebab-case，不得含 unicode。

### C-04 · 跨 seed 文件 FK 引用以 slug 写死

- 加载器解析 slug → UUID 由 Stage C 回填；种子 JSON 中**不得**预填 UUID。
- 若出现未被任何 seed 定义的 slug，加载器记 WARN，不中断（以支持增量扩展）。

### C-05 · 种子版本字段

- 每份 seed 顶层 `_meta.version` 采用 semver。当前 Phase 0 首批全部标 `0.1.0-draft`；审核通过后升 `0.1.0`（去 draft）；扩展秦汉覆盖（如加更多人物/郡国）升 `0.2.0`；扩展到其他朝代升 `1.0.0`。

---

## 变更日志

| 日期 | 版本 | 变更 | 责任人 |
|------|------|------|--------|
| 2026-04-16 | 初版 | 录入 Ruling-001~005 + C-01~C-05 | 历史专家 + 架构师（用户） |
| 2026-04-16 | 初版补 | 批次 1 交付：polities(5) / reign_eras(89) / disambiguation_seeds(26) / persons(40) / places(25) = **185 条种子数据** | 历史专家 |

---

## 待办（跨任务卡 TODO）

### TODO-001 · T-P0-006 加载器的 20 帝王 FK stub 前置要求

**来源**：2026-04-16 架构师裁决（本次会话）  
**指向**：T-P0-006 任务卡（尚未起草）的前置要求段落  
**内容**：

T-P0-006 加载器在 **Stage B persons 加载后 / Stage C FK 回填前**，须执行以下 stub 生成步骤：

- **扫描 `reign_eras.seed.json` 中所有 `emperorPersonSlug`**，若该 slug **未在 `persons.seed.json` 中定义**，则为其生成 stub person 记录。
- **Stub 字段最小集**（三字段）：
  - `slug`：照抄 emperorPersonSlug
  - `name`：{ "zh-Hans": <从 slug 推导的中文名> }（推导规则见下）
  - `dynasty`：根据 slug 前缀判定（han- → "西汉"/"东汉"，qin- → "秦"，xin- / wang-mang → "新"）
- **其余字段**（birthDate / deathDate / biography / realityStatus / provenanceTier）**留空或走 schema default**，不阻塞 reign_eras 加载。
- **Slug → zh-Hans 推导规则**（本批次覆盖需求内的映射）：

| slug | zh-Hans name | dynasty |
|------|--------------|---------|
| qin-er-shi | 秦二世 | 秦 |
| qin-zi-ying | 秦王子婴 | 秦 |
| han-hui-di | 汉惠帝 | 西汉 |
| han-gao-hou | 汉高后（吕后） | 西汉 |
| han-zhao-di | 汉昭帝 | 西汉 |
| han-xuan-di | 汉宣帝 | 西汉 |
| han-yuan-di | 汉元帝 | 西汉 |
| han-cheng-di | 汉成帝 | 西汉 |
| han-ai-di | 汉哀帝 | 西汉 |
| han-ping-di | 汉平帝 | 西汉 |
| han-ru-zi-ying | 汉孺子婴 | 西汉 |
| han-ming-di | 汉明帝 | 东汉 |
| han-zhang-di | 汉章帝 | 东汉 |
| han-he-di | 汉和帝 | 东汉 |
| han-shang-di | 汉殇帝 | 东汉 |
| han-an-di | 汉安帝 | 东汉 |
| han-shun-di | 汉顺帝 | 东汉 |
| han-chong-di | 汉冲帝 | 东汉 |
| han-zhi-di | 汉质帝 | 东汉 |
| han-huan-di | 汉桓帝 | 东汉 |
| han-ling-di | 汉灵帝 | 东汉 |
| han-shao-di-bian | 汉少帝辩（弘农王） | 东汉 |

（共 22 位；已 explicit 定义的 2 位 ——秦始皇 qin-shi-huang、汉光武帝 han-guang-wu-di ——不在此 stub 列表。其余 18 位在 reign_eras 中被引用但未在 persons.seed.json 中展开。）

- **后续扩展**：在下一批（0.2.0）字典扩展中，逐位把 stub 升级为完整 person 记录（加 birth/death/biography），stub 记录以 `slug` 为键被 UPSERT 覆盖，避免重复。
- **错误处理**：若 stub 生成失败（如 slug 前缀无法解析 dynasty），加载器须 ERROR 中断，不得默默跳过。

**责任人**：T-P0-006 主导角色（管线工程师）在起草任务卡时须把本 TODO 吸收为"前置要求"段落。
