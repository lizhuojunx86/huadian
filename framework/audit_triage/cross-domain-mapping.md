# audit_triage — Cross-Domain Mapping Guide

> Status: v0.1 (Sprint Q Stage 1 first abstraction)
> Date: 2026-04-30
> License: Apache 2.0 (代码) / CC BY 4.0 (文档)

## 0. 本文件目标

audit_triage 框架抽象的是"AI candidate + 人决策 + 异步 apply"工作流。本文件给出 6 个领域的具体 instantiation 指南——把华典智谱古籍领域的概念映射到法律 / 医疗 / 专利 / 学术 / 金融 / 商业流程。

每个领域 §：
- 有哪些 ItemKind（review 类型）
- 对应什么 source_table
- HistorianAllowlist 怎么定义
- ReasonValidator 应该用什么词汇
- DecisionApplier (V0.2) 怎么 apply

---

## 1. 古籍 Knowledge Engineering（华典智谱主案例）

### 1.1 ItemKind 映射

| Framework ItemKind | Production source_table | 触发 |
|--------------------|------------------------|------|
| `seed_mapping` | `seed_mappings` (mapping_status='pending_review') | 字典批次 + Wikidata seed match 不确定时 |
| `guard_blocked_merge` | `pending_merge_reviews` (status='pending') | R1-R6 candidates 被 GUARD_CHAINS 拦截时 |

### 1.2 HistorianAllowlist

文件：`apps/web/lib/historian-allowlist.yaml`
```yaml
historians:
  - chief-historian
  - backfill-script        # 自动化 Sprint K 回填脚本
  - e2e-test               # 测试 fixture
  - historical-backfill    # Sprint K Stage 2.5 backfill
```

### 1.3 ReasonValidator

`DefaultReasonValidator()` — 6-tag 默认词汇正适合本领域。

### 1.4 DecisionApplier (V0.2)

- approve seed_mapping → seed_mappings.mapping_status='confirmed' + persons 表加 alias
- reject seed_mapping → seed_mappings.mapping_status='rejected' + 不动 persons
- approve guard_blocked_merge → 调用 MergeApplier (framework/identity_resolver) merge persons + 写 merge_log
- reject guard_blocked_merge → pending_merge_reviews.status='blocked_persistent'
- defer → 不动 source 状态（Hist 可后续 revisit）

### 1.5 V1 → V2 已实证轨迹

Sprint K 完成 V1（177 triage_decisions rows / Hist E2E 真决策 1 reject + 1 approve）。
V2 应用 job 待 Sprint Q+M 起。

---

## 2. 法律 Contract Review

### 2.1 ItemKind 映射

| Framework ItemKind | Likely source_table | 触发 |
|--------------------|---------------------|------|
| `contract_party_match` | `pending_party_matches` | 同一公司多种命名（"Apple Inc." vs "Apple Computer Inc."）需法务确认 |
| `clause_revision` | `pending_clause_reviews` | NLP detect 合同条款偏离 firm template，需 senior 审阅 |
| `precedent_citation` | `pending_citations` | AI 建议的 case law 参考需律师二审 |
| `regulatory_compliance` | `pending_compliance_flags` | AI 标记的 GDPR / SOX / 等 compliance 风险 |

### 2.2 HistorianAllowlist

```yaml
historians:
  - senior-counsel
  - compliance-officer
  - paralegal-junior        # limited authority (只能 defer，不能 approve)
  - automated-precedent-bot
```

进阶：可定制 `HistorianAllowlist` 实现"分级 authz"（junior 只能 defer，不能 approve / reject）。

### 2.3 ReasonValidator

```python
LEGAL_REASON_TYPES = (
    "contract_text",           # 合同明文
    "case_law",                # 判例
    "regulatory",              # 法规 / 监管
    "client_communication",    # 客户来信 / 邮件
    "firm_precedent",          # 内部 precedent
    "external_counsel",        # 外部律师意见
)
validator = DefaultReasonValidator(allowed=LEGAL_REASON_TYPES)
```

### 2.4 DecisionApplier (V0.2)

- approve party_match → 写入 contract_parties canonical + alias
- approve clause_revision → 写入 clause_revisions 触发 amendment workflow
- reject anything → 写入 audit log + 通知 originating attorney

### 2.5 跨 sprint hint banner

> Hist Banner: "你之前在 Project X / Project Y 都 reject 过 'Apple Computer Inc.' (1 reject + 1 approve / 2 sprint ago)"

---

## 3. 医疗 Clinical Decision Review

### 3.1 ItemKind 映射

| Framework ItemKind | Likely source_table | 触发 |
|--------------------|---------------------|------|
| `drug_substitution` | `pending_substitutions` | AI 建议的 generic / interchangeable 替换需药剂师确认 |
| `dosage_review` | `pending_dosage_reviews` | AI flag 的剂量偏离 standard 需主治医生审 |
| `diagnosis_disambig` | `pending_diagnoses` | 多个 ICD-10 codes 都 fit 患者症状 |
| `imaging_finding` | `pending_imaging_reviews` | radiologist AI 标记的 incidental findings |

### 3.2 HistorianAllowlist

```yaml
historians:
  - attending-physician
  - clinical-pharmacist
  - radiologist
  - resident-mid-year       # limited (仅 dosage_review)
```

### 3.3 ReasonValidator

```python
MEDICAL_REASON_TYPES = (
    "patient_record",         # EMR 数据
    "clinical_guideline",     # 临床指南（如 NICE / ACOG）
    "peer_consultation",      # 同事会诊
    "imaging",                # 影像支持
    "lab_results",            # 实验室
    "patient_preference",     # 患者偏好（informed consent）
    "drug_interaction_db",    # 药物相互作用数据库
)
```

### 3.4 DecisionApplier (V0.2)

⚠️ **医疗领域强烈建议 V2 异步 apply 之前还有一道 EHR 审计层**——决策不直接写处方，而是生成 order draft 让医生 e-sign。

### 3.5 PHI / HIPAA 注意

- `surface_snapshot` 不存敏感信息（用 patient_id hash 而不是姓名）
- `reason_text` 字段需 PHI sanitization
- audit log 留存 ≥ 6 年（HIPAA 要求）

---

## 4. 专利 Prior Art Search

### 4.1 ItemKind 映射

| Framework ItemKind | Likely source_table | 触发 |
|--------------------|---------------------|------|
| `claim_overlap` | `pending_overlaps` | AI 检测的 claim 与现有 patent 高度重叠 |
| `prior_art_match` | `pending_prior_art` | semantic search 找到的 prior art 候选需 patent agent 审 |
| `inventor_disambig` | `pending_inventors` | 同名 inventor 跨 patent 的归一化 |

### 4.2 HistorianAllowlist

```yaml
historians:
  - patent-agent
  - patent-examiner
  - subject-matter-expert
  - automated-search-bot
```

### 4.3 ReasonValidator

```python
PATENT_REASON_TYPES = (
    "patent_claim_text",      # patent claim 明文
    "uspto_record",           # USPTO 数据库
    "academic_publication",   # 学术论文
    "industry_practice",      # 行业惯例
    "expert_declaration",     # SME declaration
    "examiner_office_action", # OA 反馈
)
```

---

## 5. 学术 Author / Citation Disambiguation

### 5.1 ItemKind 映射

| Framework ItemKind | Likely source_table | 触发 |
|--------------------|---------------------|------|
| `author_disambig` | `pending_authors` | "Yang Liu" 几十人 / 需 librarian / ORCID 审 |
| `citation_match` | `pending_citations` | 文献 reference 自动 resolve 不确定 |
| `affiliation_link` | `pending_affiliations` | 机构归一化 |

### 5.2 HistorianAllowlist

```yaml
historians:
  - librarian
  - graduate-student         # limited (仅 defer)
  - automated-orcid-bot
```

### 5.3 ReasonValidator

```python
ACADEMIC_REASON_TYPES = (
    "orcid",                  # ORCID 记录
    "author_homepage",        # 个人主页
    "publication_metadata",   # 文章 metadata
    "co-author_overlap",      # 合著者交叉
    "topic_affinity",         # 主题相似度
)
```

---

## 6. 金融 KYC / AML Review

### 6.1 ItemKind 映射

| Framework ItemKind | Likely source_table | 触发 |
|--------------------|---------------------|------|
| `entity_match` | `pending_entity_matches` | 客户 entity 与制裁名单 fuzzy match |
| `transaction_anomaly` | `pending_anomalies` | AML AI flag 的可疑交易 |
| `beneficial_owner` | `pending_owners` | UBO disambiguation |

### 6.2 HistorianAllowlist

```yaml
historians:
  - aml-officer
  - kyc-analyst
  - compliance-head
```

### 6.3 ReasonValidator

```python
FINANCIAL_REASON_TYPES = (
    "ofac_listing",           # 制裁名单
    "internal_kyc",           # 内部 KYC 档案
    "transaction_pattern",    # 历史交易 pattern
    "third_party_data",       # 第三方数据源（Refinitiv / etc）
    "regulatory_filing",      # 监管报告
    "client_self_disclosure", # 客户自报
)
```

⚠️ **金融领域**通常需要 audit log 的不可篡改性更强（blockchain / WORM storage），且 retention 期限往往 7-10 年。

---

## 7. 商业流程 Approval Workflow

### 7.1 ItemKind 映射

| Framework ItemKind | Likely source_table | 触发 |
|--------------------|---------------------|------|
| `expense_approval` | `pending_expenses` | 超过阈值 / 偏离 policy |
| `vendor_onboarding` | `pending_vendors` | 新供应商 vetting |
| `contract_renewal` | `pending_renewals` | AI 检测的 auto-renewal 风险 |

### 7.2 HistorianAllowlist

```yaml
historians:
  - department-head
  - finance-manager
  - cfo                     # 高额阈值
  - vendor-coordinator
```

### 7.3 ReasonValidator

```python
BUSINESS_REASON_TYPES = (
    "policy_compliant",
    "policy_exception_approved",
    "budget_available",
    "strategic_priority",
    "vendor_diligence",
    "historical_precedent",
)
```

---

## 8. 跨域共通的"应该 / 不应该"

### 8.1 应该

- ✅ 把 `surface_snapshot` 设为对人友好的 representative string（人名 / 公司名 / 处方名）
- ✅ `reason_source_type` 设计 controlled vocabulary（不要 free text only）
- ✅ multi-row audit per source_id（defer → revisit → approve）
- ✅ V1 zero-downstream（决策与 mutation 解耦）

### 8.2 不应该

- ❌ 把 PII / PHI 直接放 `surface_snapshot`（用 hash / token）
- ❌ enforce `UNIQUE(source_id)` on `triage_decisions`（破坏多值审计）
- ❌ 决策 + mutation 同事务（破坏 V1 zero-downstream + 测试）
- ❌ 把 GraphQL / REST 层硬塞回 framework（每项目栈不同）

---

## 9. 6 领域 Plugin Protocol 适配总表

| 领域 | TriageStore 复杂度 | Allowlist 来源 | ReasonValidator | V0.2 Applier 风险 |
|------|------------------|--------------|----------------|-----------------|
| 古籍 | 中（2 source tables）| static yaml | 6 default tags | 中（merge 逻辑复杂）|
| 法律 | 中-高 | static + 分级 authz | 6 法律 tags | 高（合同修订涉及 e-sign）|
| 医疗 | 高 | EMR SSO | 7 医疗 tags + PHI sanitize | **极高**（误判可能影响诊疗）|
| 专利 | 中 | static | 6 专利 tags | 中（USPTO filing）|
| 学术 | 低 | static + ORCID | 5 学术 tags | 低（metadata 改动）|
| 金融 | 高 | enterprise IAM | 6 金融 tags + 不可篡改 | 高（监管 filing）|
| 商业流程 | 低-中 | enterprise IAM | 6 业务 tags | 中（depends on action）|

---

## 10. fork checklist（任何领域）

把 `framework/audit_triage/examples/huadian_classics/` 复制为 `examples/your_domain/` 后：

- [ ] `asyncpg_store.py`：改 `_SEED_SELECT` / `_GUARD_SELECT` SQL → 你的领域 source tables
- [ ] `asyncpg_store.py`：改 `_row_to_pending_item` 的 raw_payload 字段集合
- [ ] `asyncpg_store.py`：改 `find_pending_by_id` 的 kind 分支
- [ ] `allowlist.py`：改 yaml path + `_HARD_CODED_ALLOWLIST` fallback
- [ ] `schema.sql`：改 `triage_decisions_source_table_chk` CHECK → 你的表名
- [ ] 自定义 `ReasonValidator`：传入领域词汇
- [ ] 写 README §"与 production 实现的对应关系"段
- [ ] 写 ≥ 1 个 `test_soft_equivalent.py` (如有 production 实现可对比)

---

**audit_triage cross-domain-mapping v0.1 / Sprint Q Stage 1 / 2026-04-30**

---

## 附录：6 领域 v0.x 落地状态

| 领域 | 状态 | 触发条件 |
|------|------|---------|
| 古籍 | ✅ v0.1 huadian_classics 完整 | Sprint Q (本 sprint) |
| 法律 | ⏳ 押后 | 跨领域案例方主动接触 (DGF-N-04 / DGF-O-03) |
| 医疗 | ⏳ 押后 | 跨领域案例方 + PHI 法务评估 |
| 专利 | ⏳ 押后 | 案例方触发 |
| 学术 | ⏳ 押后 | 案例方触发 |
| 金融 | ⏳ 押后 | 案例方触发 + 监管评估 |
| 商业流程 | ⏳ 押后 | 案例方触发 |

押后 6 领域参考: `docs/debts/sprint-p-residual-v02-debts.md` DGF-N-04 / DGF-O-03。
