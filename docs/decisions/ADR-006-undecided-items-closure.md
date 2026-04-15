# ADR-006: 未决项 U-01 ~ U-07 封版决策

- **状态**：accepted
- **日期**：2026-04-15
- **提议人**：首席架构师
- **决策人**：用户授权相应"需决定者"角色代为拍板（下表逐项注明）
- **影响范围**：产品路线图、付费墙策略、用户贡献机制、模拟器输出属性、检索能力范围、SLA 规划
- **Supersedes**：`docs/01_风险与决策清单_v2.md §未决项` 表格
- **Superseded by**：无

## 背景

`docs/01` 末尾列出 7 个未决项 U-01~U-07。用户明确授权："我同意'当前倾向'，请'需决定者'来给出最终决策。"

本 ADR 以各角色 agent 代表"需决定者"身份，将"当前倾向"转为最终决策，并补充执行条件、触发条件和回滚线。未来 Phase 推进中若现实数据挑战本决策，任一方可发起新 ADR 推翻。

## 决策矩阵

### U-01：用户贡献内容（Wiki 式）

- **决策人**：产品经理（role）
- **决定**：**Phase 3 之后开放**；Phase 0~2 用户只能提交"反馈"（feedback 表），不能直接改内容
- **执行条件（Phase 3 开闸前门槛）**：
  1. 用户基数 ≥ 1 万 MAU
  2. 核心实体库 ≥ 5 万人物 / 10 万事件
  3. 建立"编辑者信誉系统"（投票、版本回滚）
  4. 法务评审（UGC 合规 / 版权）
- **中间过渡**：Phase 2 起允许"建议修订"（suggested edits）入 feedback 表，由历史专家审批后合入
- **回滚线**：若开放后 6 个月内恶意编辑占比 > 5%，关闭并改回审批制

### U-02：争议事件的"默认叙述"选择

- **决策人**：历史/古籍专家（role）
- **决定**：**依据 `books.credibility_tier` + 人工覆盖**
- **详细规则**：
  1. 默认：`books.credibility_tier` 最高 > `source_book_tier` 时代最近 > `credibility_tier = primary_text` 优先
  2. 历史专家可对任一 event 的某 account 标记 `is_default=TRUE`（覆盖自动规则）
  3. 人工覆盖必须附"理由"字段，登记到 `account_conflicts.resolution_note`
  4. 前端展示默认 account 的同时必须有"查看其他叙述"入口（宪法 C-4）
- **落地**：`event_accounts` 表的 `is_default` 字段由历史专家维护；算法默认规则写入 `services/api/src/services/event_account_resolver.ts`

### U-03：模拟器输出是否保留为用户可引用数据

- **决策人**：PM + 架构师
- **决定**：**保留，但明确标注 `provenance_tier = 'ai_inference'` + `is_simulator_output = TRUE`**
- **规则**：
  1. 模拟器产出的"假设性叙述"可存入 `event_accounts` 或 `scenarios` 表（Phase 2 新增）
  2. 必须有 `is_simulator_output` 布尔字段，前端展示必须带徽标"AI 推演"
  3. 用户引用（分享、导出）时自动附"本内容为 AI 推演，非史料"
  4. **不进入**语义检索默认召回池（检索时需显式 `?include_simulated=true`）
  5. 不参与黄金集评估
- **回滚线**：若用户投诉"误认为史料" > 3% 反馈量，强制下线该功能

### U-04：付费墙切分点（免费 / 付费）

- **决策人**：产品经理
- **决定**：**Phase 3 前不做付费墙**；Phase 3 启动时重评估
- **Phase 3 预案（暂定，非本 ADR 最终）**：
  - 免费：全部实体浏览 / 搜索 / 关系图 1 度
  - 付费：关系图 ≥ 2 度 / 时间线模拟器 / API 调用 / 批量导出 / 高级筛选
- **Phase 0~2 的留痕要求**：埋点必须已经能区分"将来可能付费的行为"（见埋点字典 `premium_feature_used`），便于 Phase 3 做定价数据分析
- **回滚线**：无（延后决策）

### U-05：拼音 / 粤语 / 方言检索

- **决策人**：前端 + 历史专家
- **决定**：
  - **Phase 2：支持普通话拼音检索**（基于 pypinyin 生成 `person_names.pinyin` 字段，pg_trgm 模糊）
  - **粤语 / 吴语 / 闽南语：Phase 4 之后**，视用户地域分布（来自 analytics）决定
  - **古音 / 反切：不做**（学术价值低于成本）
- **Phase 0 的留痕要求**：schema 已预留 `person_names.pinyin` 和 `places.pinyin` 字段
- **回滚线**：若 Phase 2 埋点显示拼音检索占比 < 5%，Phase 3 可下线简化

### U-06："错题集" / 用户学习记录

- **决策人**：产品经理
- **决定**：**Phase 3 考虑**；Phase 0~2 不做任何用户学习数据持久化
- **Phase 0~2 的替代**：
  - 只做"最近浏览"（localStorage，前端本地存储，不入库）
  - 允许"收藏"（若登录），但不关联"学习进度"
- **Phase 3 启动条件**：U-04 付费墙方案已确定（因错题集可能属于付费功能）
- **回滚线**：无

### U-07：商业版 SLA 与数据更新频率

- **决策人**：产品经理 + DevOps
- **决定**：**Phase 4 才谈**
- **Phase 0~3 的留痕要求**：
  - DevOps 从 Phase 0 就建立"免费版 SLA 基线"（可用率、响应延迟），作为 Phase 4 商业版的对照
  - 数据更新频率基线：新书入库批次每月 ≥ 1 次，Phase 4 商业版可能要求每周
  - 监控系统（Grafana / Sentry）从 Phase 0 起必须齐全，Phase 4 只需"增加 SLA 告警阈值"
- **回滚线**：无

## 决策汇总表

| 编号 | 议题 | 决定（本 ADR 封版） | 执行阶段 |
|------|------|---------------------|---------|
| U-01 | 用户贡献内容 | Phase 3 后开放，过渡期走 feedback | Phase 3 |
| U-02 | 默认叙述选择 | credibility_tier + 人工覆盖 | Phase 0 起 |
| U-03 | 模拟器输出 | 保留但强制 ai_inference + 徽标 + 不默认召回 | Phase 2 |
| U-04 | 付费墙 | Phase 3 前不做，埋点预留 | Phase 3 |
| U-05 | 拼音/方言 | Phase 2 拼音，其他延后 | Phase 2 |
| U-06 | 错题集 | Phase 3 考虑 | Phase 3 |
| U-07 | 商业版 SLA | Phase 4 | Phase 4 |

## 影响

- 正面：清除所有未决项阻塞；Phase 0~2 范围明确
- 负面：U-01/U-04/U-06/U-07 依赖 Phase 3+ 的产品洞察，本 ADR 提供的仅为"当前规划"，实际执行时可能被新 ADR 推翻
- 迁移成本：schema 预留字段（U-05 拼音、U-03 is_simulator_output）需纳入 ADR-002 / 数据模型 v2

## 回滚方案

任一决策在后续 Phase 中发现不适用，由相应"决策人"角色发起新 ADR 推翻，本 ADR 相关条目设为 `superseded by ADR-XXX`。

## 相关链接
- 来源：`docs/01_风险与决策清单_v2.md §未决项`
- 相关 ADR：ADR-002（U-02 依赖 Event-Account 拆分）/ ADR-004（U-03 模拟器输出走 TraceGuard 校验）
- 宪法条款：C-4 / C-10 / C-18
