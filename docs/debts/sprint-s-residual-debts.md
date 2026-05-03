# Sprint S 衍生债 — 押后清单（Sprint L→S 累计 / 含 ADR-030 锁定的 Sprint T 路径）

> Status: registered（押后状态）
> 来源 sprint: Sprint S Stage 4 closeout (2026-04-30)
> 总计 4 项押后（2 v0.2 + 1 v0.3 + 1 v0.4 新增）
> 触发条件: 见每项 §"处理时机"

---

## 0. 总览

Sprint S 收口后（vs Sprint R 后）：

| 维度 | Sprint R 后 | Sprint S 后 |
|------|-----------|-----------|
| v0.2 押后 | 2 (DGF-N-04 / DGF-N-05) | 2（不变）|
| v0.3 押后 | 1 (T-V03-FW-005) | 1（不变 / 候选 fold 进 Sprint T release sprint）|
| v0.4 候选 | 0 | **1**（T-V04-FW-001 commit message hygiene）|
| 累计 patch 落地率 | 23/26 = 88.5% | 23/26 = 88.5%（不变 / 评估 sprint 不 land 新 patch）|
| **v0.3 release timing** | 5/6 触发条件待评估 | **6/6 ✓（ADR-030 锁定 / Sprint T = v0.3 release sprint）** ⭐ |

---

## 1. v0.2 押后清单（2 项 / 不变 / 等外部触发）

### 1.1 DGF-N-04 — 跨域 reference impl（合并 DGF-O-03 / 等案例方接触）

按 ADR-030 §2.1 + §4.3，跨域 reference impl 不阻塞 v0.3 release（已用 cross-domain-mapping.md v0.x 替代实现该条件）。但仍是 v0.4 / v1.0 release 候选条件之一。

**处理时机**：等真案例方接触触发。优先 legal（per Sprint Q debt §1.1 推荐）。

### 1.2 DGF-N-05 — EntityLoader.load_subset feature

**处理时机**：等用户提需求。huadian ~700 person 全量加载性能不是瓶颈。

---

## 2. v0.3 押后清单（1 项 / Sprint T 内 fold 候选）

### 2.1 T-V03-FW-005 — Docker compose Postgres + seed fixtures

**描述**：让 sandbox 可跑 framework dogfood（vs 当前必须 user local）。

**估算**：≥ 4 hours。

**Sprint T (v0.3 release sprint) fold 决策**（per Sprint S retro §7.4）：

| 选项 | 路径 | Sprint T 工时 |
|------|------|------------|
| **选 1（推荐）** | fold 进 Sprint T 批 1（与 release prep 同 sprint）| 1.5-2 会话（与 Sprint P scale 一致）|
| 选 2 | 单独 Sprint S+0.5 mini-sprint | Sprint T 0.5-1 会话（更紧凑 release-only）|

→ Sprint T brief 起草时根据用户偏好决定。

---

## 3. v0.4 候选清单（1 项 / 新增）

### 3.1 T-V04-FW-001 — chief-architect.md §工程小细节 v0.2.2 加 commit message hygiene 规则

**描述**：来源 Sprint R commit `35f371d` 残留问题（commit message 仅说 hooks 但实际包含 6 files = hooks + 4 framework polish）。

**修改建议**：
chief-architect.md §工作风格 §工程小细节 加：

> - **commit message 应反映实际改动 file 集合** — pre-commit 失败重试时确认 `git status` 中的 staged file list，避免 commit message 与实际 diff 不匹配。
>   来源：Sprint R commit `35f371d` 实际包含 6 files（hooks + 4 framework polish）但 message 仅说 hooks → Sprint S retro §3.2 沉淀。

**处理时机**：Sprint T 内如有合适机会 fold；或 v0.4 polish sprint 单独 land。

---

## 4. 与 Sprint L→S 衍生债合并视图（最新）

| Sprint | v0.2 候选 | 已 patch | 押后 v0.2 | v0.3 候选 | 已 land | 押后 v0.3 | v0.4 候选 |
|--------|---------|---------|---------|----------|--------|----------|----------|
| L+M+N+O | 20 | 18 ✓ | 2 | — | — | — | — |
| P | 0 | 0 | 0 | 2 | — | — | — |
| Q | 0 | 0 | 0 | 4 | — | — | — |
| R | 0 | 0 | 0 | 0 | 5 ✓ | 1 | — |
| S | 0 | 0 | 0 | 0 | 0 | 0 | **1** |
| **合计** | **20** | **18** ✅ | **2** | **6** | **5** ✅ | **1** | **1** |

**累计 patch 落地率**：23 / (20 + 6) = **88.5%**（v0.4 候选不计入此率，新生）。

---

## 5. v0.3 release Sprint T 候选议程（per ADR-030 + Sprint S retro §8）

**Sprint T = v0.3 release sprint**（不可降级 / per ADR-030 §2.2 锁定）

形态：与 Sprint P (v0.2 release) 同 / 5-batch maintenance sprint / 1-2 会话 / 推荐 Sonnet（patch + 文档撰写主导 / 模板化强 / 成本优化）

batch 候选结构（per Sprint S retro §8）：

| 批 | 主题 | 估时 |
|----|------|------|
| 1 | T-V03-FW-005 Docker compose（如选 fold）| 4-6h（大工作）|
| 2 | 5 模块 README §8 加 v0.3.0 行 + `__version__` bump | ~30 min |
| 3 | framework/RELEASE_NOTES_v0.3.md 起草 | ~45 min |
| 4 | docs/STATUS.md / CHANGELOG.md 更新 v0.3.0 标记 | ~20 min |
| 5 | sanity 回归 + 60 pytest + ruff/format clean | ~10 min |
| 4 (closeout) | closeout + retro + STATUS/CHANGELOG | ~30 min |

**完成判据预测**（per Sprint S retro §8）：

- ✅ 5 模块各 v0.3.0 statement 一致
- ✅ framework/RELEASE_NOTES_v0.3.md 落地
- ✅ git tag v0.3.0 准备命令就位
- ✅ sanity 不回归 + 60 pytest + ruff/format clean
- ✅ Sprint T closeout + retro
- ✅ ADR-030 §5 Validation Criteria 6 条 checklist 回填

---

**本债务清单 Sprint S 起草于 2026-04-30 / Stage 4 closeout / Architect Opus**
