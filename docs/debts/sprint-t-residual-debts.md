# Sprint T 衍生债 — 押后清单（Sprint L→T 累计 / v0.3 全清里程碑 ⭐）

> Status: registered（押后状态）
> 来源 sprint: Sprint T Stage 4 closeout (2026-04-30)
> 总计 4 项押后（2 v0.2 + 0 v0.3 ⭐ + 2 v0.4）
> 触发条件: 见每项 §"处理时机"

---

## 0. 总览

Sprint T 收口后（vs Sprint S 后）：

| 维度 | Sprint S 后 | Sprint T 后 |
|------|-----------|-----------|
| v0.2 押后 | 2 (DGF-N-04 / DGF-N-05) | 2（不变 / 等外部触发）|
| **v0.3 押后** | 1 (T-V03-FW-005) | **0** ⭐（fold land）|
| v0.4 候选 | 1 (T-V04-FW-001) | **2**（+ T-V04-FW-002）|
| 累计 patch 落地率 | 23/26 = 88.5% | **24/26 = 92.3%** ⭐ |
| **v0.3.0 release** | 待 Sprint T 启动 | **✅ 准备就位 / 待用户 push tag** ⭐ |
| 5 sprint zero-trigger | 4 (P→Q→R→S) | **5 (P→Q→R→S→T)** → 触发 v1.0 候选议程评估 ⭐ |

---

## 1. v0.2 押后清单（2 项 / 不变 / 等外部触发）

### 1.1 DGF-N-04 — 跨域 reference impl（合并 DGF-O-03）

按 ADR-030 §4.3，跨域 reference impl 不阻塞 v0.3 release（已用 cross-domain-mapping.md v0.x 替代实现）。但仍是 v0.4 / v1.0 release 候选条件之一。

**处理时机**：等真案例方接触触发。优先 legal（per Sprint Q debt §1.1）。

### 1.2 DGF-N-05 — EntityLoader.load_subset feature

**处理时机**：等用户提需求。

---

## 2. v0.3 押后清单（**0 项** ⭐ / Sprint T fold land 完成）

无押后。T-V03-FW-005 (Docker compose) 已在 Sprint T 批 1 fold land + user local PASSED。

---

## 3. v0.4 候选清单（2 项 / 新增）

### 3.1 T-V04-FW-001（Sprint S 留存）— chief-architect §工程小细节 v0.2.2 commit message hygiene 规则

**描述**：Sprint R commit `35f371d` 实际包含 6 files (hooks + 4 framework polish) 但 message 仅说 hooks → 触发"commit message 应反映实际改动 file 集合"规则建议。

**估算**：~5 min（一行规则 + 来源说明 + role-templates v0.2.1 → v0.2.2 patch entry）

**处理时机**：Sprint U 如启动 v0.4 maintenance 时优先 fold；或独立 5 min 提交。

### 3.2 T-V04-FW-002（Sprint T 新增）— brief-template v0.1.3 §2.1 Code 类估算分子类

**描述**：Sprint T retro §3.1 实证：Sprint S（Code=0）+ Sprint T（Code 主导）累计 2 次外部 dogfood 暴露 Code 类估算盲区——"框架 spike"（实证偏快 / Approach B 简化路径 + 工具加成）vs "新模块抽象"（如 Sprint Q audit_triage 实证更慢 / 走 1 sprint）vs "纯 docs 改"（Sprint S 偏慢 / cross-ref 多文件）需要分子类估算。

**修改建议**：
brief-template §2.1 Code 类加 sub-rows：

```
| **Code (框架 spike / 已有 pattern fold)** | T-V03-FW-005 类型 | ⚠️FILL hours |
| **Code (新模块抽象 / 全新 Plugin Protocol)** | Sprint Q audit_triage 类型 | ⚠️FILL hours |
| **Code (patch / version bump 等模板化改)** | Sprint P 类型 | ⚠️FILL hours |
```

**估算**：~15 min（brief-template v0.1.3 → v0.1.4 patch + 变更日志 + sprint-templates v0.3.0 → v0.3.1 sync bump）

**处理时机**：Sprint U+ v0.4 maintenance 时 fold。

---

## 4. 与 Sprint L→T 衍生债合并视图（最终）

| Sprint | v0.2 候选 | 已 patch | 押后 v0.2 | v0.3 候选 | 已 land | 押后 v0.3 | v0.4 候选 |
|--------|---------|---------|---------|----------|--------|----------|----------|
| L+M+N+O | 20 | 18 ✓ | 2 | — | — | — | — |
| P | 0 | 0 | 0 | 2 | — | — | — |
| Q | 0 | 0 | 0 | 4 | — | — | — |
| R | 0 | 0 | 0 | 0 | 5 ✓ | 1 | — |
| S | 0 | 0 | 0 | 0 | 0 | 0 | 1 |
| **T (Docker fold land)** | 0 | 0 | 0 | 0 | **1 ✓** | **0** ⭐ | **+1**（累计 2）|
| **合计** | **20** | **18** ✅ | **2** | **6** | **6** ✅ | **0** ⭐ | **2** |

**累计 patch 落地率**：(18 + 6) / (20 + 6) = **24/26 = 92.3%** ⭐（vs Sprint S 后 88.5%）

---

## 5. v0.4 release 触发条件预估（per Sprint T retro §7.4 + Sprint S residual debts §4 模板）

**v0.4 release 仍未触发**（v0.4 候选仅 2 项 / 远低于 ≥ 5 阈值 / 不急）。

候选触发条件（参考 ADR-030 §2.1 v0.3 6 条 + 调整）：

| # | 条件 | 评估 |
|---|------|------|
| 1 | ≥ 5 模块稳定 | ✅ 5 模块齐备 (不变 / v0.3 已实证) |
| 2 | Maintenance sprint 稳定 ≥ 2 sprint after v0.3 | ⏳ Sprint U+ 等观察 |
| 3 | 累计 v0.4 候选 ≥ 5 land | ❌ 仅 2 候选 / 待 Sprint U+ 累积 |
| 4 | 押后 v0.2 ≥ 1 项 land | ⏳ DGF-N-04 / DGF-N-05 等触发 |
| 5 | ≥ 1 跨域 reference impl 完整 working code | ⏳ DGF-N-04 等案例方接触 |
| 6 | 连续 zero-trigger sprint ≥ 5 (after v0.3 release) | ⏳ Sprint U+ 等观察 |

→ **v0.4 release 预估**：Sprint U + 4-6 sprint 后（约 2026-05 中旬到 2026-06 上旬）。

不急 / 不规划 v0.4 release sprint。Sprint U 候选 A（v1.0 候选议程评估）+ B（methodology/06+07）+ C（v0.4 maintenance）相互独立。

---

## 6. v1.0 候选议程评估（Sprint T 触发 / per retro §5.1 期待）

**5 sprint zero-trigger 连续达成** = v1.0 候选议程**开始评估**（**非触发 release**）。

候选 v1.0 触发条件（待 Sprint U+ 候选 A 起草 ADR-031 锁定）：

| # | 候选条件 | 当前评估 |
|---|---------|---------|
| 1 | ≥ 5 模块稳定 + ≥ 2 release cycle (v0.x → v1.0)| ✅ 5 模块齐备 / 2 release cycle (v0.2 + v0.3) |
| 2 | Maintenance + Release sprint 累计 ≥ 5 个 zero-trigger | ✅ Sprint P+Q+R+S+T = 5 ⭐ |
| 3 | API 稳定 ≥ 6 个月 (no breaking changes)| ⏳ 当前 v0.3 cycle 内 / 远未 6 个月 |
| 4 | ≥ 1 跨域 reference impl 完整 working code | ❌ DGF-N-04 等触发 |
| 5 | 第三方 review (≥ 2 person) 表示 production-ready | ❌ 待跨外部读者 review |
| 6 | 累计 v0.x patch 落地率 ≥ 95% | ⏳ 当前 92.3% / 接近但未达 |
| 7 | methodology 7 doc 全 ≥ v0.2 | ❌ 当前 5 doc ≥ v0.1.1 / 0 doc ≥ v0.2 |

→ **v1.0 候选议程评估**预估：还需 6-12 个月 + 多个跨域案例方接触 + methodology v0.2 cycle 完成。

Sprint U 候选 A 起草 ADR-031 锁定这些条件 + 评估优先级（不立即 release）。

---

## 7. Sprint U 候选议程（per Sprint T retro §8）

按推荐顺序：

1. **A + B 合并（推荐 / 1.5-2 会话）**：
   - A. v1.0 候选议程评估 + 起草 ADR-031（v1.0 触发条件 / 不立即 release）
   - B. methodology/06 + /07 起草（Stage C 待起草草案）
2. **C. v0.4 maintenance sprint**（fold T-V04-FW-001 + -002 / 等候选累积更多再触发）
3. **D. 跨域 reference impl (legal)** — 押后等触发

---

**本债务清单 Sprint T 起草于 2026-04-30 / Stage 4 closeout / Architect Opus**
