# Sprint Q 衍生债 — v0.2 押后 + v0.3 候选清单

> Status: registered（押后状态）
> 来源 sprint: Sprint Q Stage 4 closeout (2026-04-30)
> 优先级: 2 v0.2 押后 P3 + 6 v0.3 候选 P3
> 触发条件: 见每项 §"处理时机"

---

## 0. 总览

Sprint Q 收口后：

- **v0.2 累计 18/20 已 patch**（vs Sprint P 后 14/20；本 sprint 合并补 DGF-N-03 + DGF-O-02）
- **v0.2 押后 2 项**（DGF-N-04 + DGF-N-05）
- **v0.3 候选累计 6 项**（Sprint P 留 2 + Sprint Q 新增 4）
- v0.3 release 触发条件：6 项 v0.3 候选都 land + 跨领域案例触发 + 5 模块齐备稳定 ≥ 1 sprint

---

## 1. v0.2 押后清单（2 项 / 不变）

### 1.1 DGF-N-04 — examples/legal/ 跨领域 reference impl（合并 DGF-O-03）

**描述**：framework/identity_resolver/ + framework/invariant_scaffold/ 都只有 huadian_classics 完整 reference impl；其他领域（法律 / 医疗 / 等）只有 cross-domain-mapping.md 设计 intent，未实证。

**影响**：
- 跨领域 mapping 未实证 → 5 pattern (invariant) + R1-R6 (identity) 跨领域 valid 论证只有 huadian 1 case
- 跨领域案例方 fork 时无 reference impl 可参考

**修改建议**：至少加 1 个 legal example sprint
- examples/legal_contracts/ for identity_resolver（合同方实体匹配）
- examples/legal_contracts/ for invariant_scaffold（合同完整性 5 pattern）

**处理时机**：
- A. 跨领域案例方主动接触 → 优先做对方领域 reference impl
- B. 主动起 1 个 legal example sprint（Sprint R+1 或更晚）— 不建议在无外部触发时主动起

### 1.2 DGF-N-05 — EntityLoader.load_subset feature

**描述**：当前 `EntityLoader` 只支持 `load_all()` — 全表加载。跨领域案例方可能需要按 dimension / 时间窗口 / entity_type 子集加载。

**修改建议**：

```python
class EntityLoader(Protocol):
    async def load_all(self) -> list[EntitySnapshot]: ...

    # 新增（v0.3 候选）
    async def load_subset(
        self,
        *,
        filter_predicate: Callable[[EntitySnapshot], bool] | None = None,
        sql_where_clause: str | None = None,
    ) -> list[EntitySnapshot]: ...
```

**处理时机**：等用户/案例方提需求。当前 huadian ~700 person，全量加载性能不是瓶颈。

---

## 2. v0.3 候选清单（6 项）

### 2.1 来自 Sprint P retro §6（2 项 / 已登记）

| ID | 描述 | 来源 |
|----|------|------|
| T-V03-FW-001 | identity_resolver/README §2 加 `__all__` 等价"公共 API"段 | Sprint P retro §3.3 |
| T-V03-FW-002 | methodology/02-sprint-governance-pattern.md v0.2 加 "Maintenance Sprint Pattern" + "P3 复发升级 P2" 暗规则 | Sprint P retro §5.1 |

### 2.2 来自 Sprint Q retro §6（4 项 / 新增）

| ID | 描述 | 来源 |
|----|------|------|
| T-V03-FW-003 | brief-template §2.1 表格估时按 code/docs/retro 3 类分别列 | Sprint Q retro §3.3 |
| T-V03-FW-004 | dataclass shape test 起草前 grep target 字段（流程规则）| Sprint Q retro §3.1 |
| T-V03-FW-005 | Docker compose Postgres + seed fixtures 让 sandbox 跑 dogfood | Sprint Q retro §3.2 |
| T-V03-FW-006 | pre-commit hook 检 services↔framework/examples sync warning | Sprint Q retro §5.2 |

### 2.3 隐含 v0.3 候选（未单独登记）

- audit_triage tests/（Sprint Q+M+ DGF-Q-XX 候选）— 等同 N+O pytest 节律：先 framework code + dogfood，再回头补单测
- methodology/07-cross-stack-abstraction-pattern.md（待起草）— 跨 stack 抽象 pattern 沉淀
- audit_triage v0.2 DecisionApplier hook 实现（Sprint Q+M）

---

## 3. 与 Sprint L+M+N+O+P+Q 衍生债合并视图（最新）

| Sprint | v0.2 候选 | 已 patch | 押后 v0.2 | v0.3 候选新增 |
|--------|---------|---------|---------|--------------|
| L | 4 | 4 ✓ | 0 | 0 |
| M | 7 | 7 ✓ | 0 | 0 |
| N | 5 | 3 ✓ | 2 (DGF-N-04 / -05) | 0 |
| O | 4 | 4 ✓ | 0 | 0 |
| P | 0 | 0 | 0 | 2 (T-V03-FW-001 / -002) |
| Q | 0 | 0 | 0 | 4 (T-V03-FW-003 ~ -006) |
| **合计** | **20** | **18** ✅ | **2** ⏳ | **6** v0.3 候选 |

---

## 4. v0.3 release 触发条件预估

参考 v0.2 release 触发条件（Sprint O closeout §2.4 / Sprint P 落地）：

- ⏳ 押后 2 项 v0.2 都 land（DGF-N-04 + DGF-N-05）
- ⏳ 累计 v0.3 候选 ≥ 5（已达 6 ✅）
- ⏳ 5 模块在跨 sprint dogfood 中无回归（Sprint Q 后 1-2 sprint 验证）
- ⏳ ≥ 1 个跨领域 reference impl（DGF-N-04 或 audit_triage 跨域 example）
- ⏳ 完成后正式 v0.3 release sprint（patch + release 同 Sprint P 模式 / 1-2 会话）

→ **预估 v0.3 release**：Sprint R + 2-3 sprint 后（约 2026-06，与 D-route 路线图 2026-08 milestone 对齐 / 提前）。

---

## 5. Sprint R 候选议程（来自 Sprint Q retro §8）

按价值 / 风险综合：

1. **A. v0.3 patch sprint**（推荐 / 清 6 项 v0.3 候选 + 修 BlockedMerge 这种小 nit + framework v0.3 release 候选条件评估）
2. **B. methodology v0.2 polish sprint**（与 A 合并 / Stage 1 加批 / +0.5-1 会话）
3. **C. 跨领域 reference impl (legal)**（押后 / 等案例方主动接触触发）

---

**本债务清单 Sprint Q 起草于 2026-04-30 / Stage 4 closeout / Architect Opus**
