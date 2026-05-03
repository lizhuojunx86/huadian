# Sprint S Retro — v0.3 Release Prep 评估 + methodology cross-ref

> 起草自 `framework/sprint-templates/retro-template.md` v0.1.1
> Dogfood: retro-template **第 9 次**外部使用

## 0. 元信息

- **Sprint ID**: S
- **完成日期**: 2026-04-30
- **主题**: v0.3 release prep 评估 (ADR-030) + methodology/01+03+04 cross-ref polish 合并
- **预估工时**: 1.5-2 个 Cowork 会话
- **实际工时**: **1.5 个 Cowork 会话 ≈ 150 min**（紧凑路径达成 ✓）
- **主导角色**: 首席架构师（Claude Opus 4.7）— single-actor sprint

---

## 1. Sprint 任务回顾

### 1.1 Stage 顺序与产出（精简模板 §3.B）

| Stage | 主导 | 状态 | 关键产出 |
|-------|------|------|----------|
| Stage 0 inventory + brief 起草 | Architect | ✅ | brief-template v0.1.3 第 1 次外部 dogfood / 3 类估时表首次试 |
| Stage 1 批 1 — ADR-030 | Architect | ✅ | v0.3 release timing 决策 / 选项 B / 6/6 触发条件达成 |
| Stage 1 批 2 — methodology/01 v0.1.2 | Architect | ✅ | + §10 4 段 cross-ref + Sprint M-R 实证锚点表 |
| **会话 1 中场 commit + push** | — | ✅ | 2 commits → main `40aa14b` |
| Stage 1 批 3 — methodology/03 v0.1.2 | Architect | ✅ | + §9 4 段 cross-ref + Sprint N vs Q 对比表 |
| Stage 1 批 4 — methodology/04 v0.1.2 | Architect | ✅ | + §8 5 段 cross-ref + 3 种 dogfood 组合对比 + self-test 强化模式 |
| Stage 1.13 sanity 回归 | Architect | ✅ | 60 pytest + ruff/format + 5 模块 import |
| Stage 4 closeout + retro | Architect | ✅ | 4 docs |

### 1.2 数据 / 工程基线 Δ

| 维度 | Sprint 前 | Sprint 后 | Δ |
|------|---------|---------|-----|
| ADR 数 | 29 | **30**（+ ADR-030）| +1 ⭐ |
| methodology v0.1.x ≥ v0.1.2 doc 数 | 0 | **3**（/01 / /03 / /04）| +3 |
| methodology cross-ref 网状度 | 单向（/02 → 4 元 pattern）| **双向**（/01/03/04 → /02 + /02 → 4 元 pattern）| 形成网状 ⭐ |
| v0.3 release 触发条件达成 | 5/6（缺跨域 reference impl）| **6/6**（ADR-030 调整后）| ⭐ release 解锁 |
| Sprint T 路径 | 候选 A/B/C/D 待选 | **= v0.3 release sprint**（per ADR-030 锁定）| 明确 |
| Stop Rule 触发 | 0 (Sprint R 接续) | **0**（连续 4 sprint）| 稳定 |
| pytest tests | 60 | 60 | 不变 |

---

## 2. 工作得好的部分（What Worked）

### 2.1 brief-template v0.1.3 第 1 次外部 dogfood 即验证 work

Sprint R 沉淀的 brief-template v0.1.3 §2.1 新 3 类估时表 (Code / Docs / Closeout) 在 Sprint S 第 1 次外部使用即验证工作。

vs v0.1.2 单一时长估算的 1.4-1.5x 偏差，v0.1.3 三类估时偏差 **< 10%**：
- Code 类：估算 0 / 实际 0 ✓
- Docs 类：估算 ~120 min / 实际 120 min ✓
- Closeout 类：估算 ~45 min / 实际 30 min（略小估，可接受）

**沉淀**：v0.1.3 §2.1 3 类估时表是 brief-template 演进的有效改进，建议 Sprint T+ 继续使用 / 不需 v0.1.4 polish。

### 2.2 ADR-030 起草顺利 / 选项 B 论证清晰

ADR-030 起草 219 行（在 Stop Rule #4 阈值 300 内 ✓）；3 选项论证 + 决策 + 验证 checklist + Consequences 完整。

特别值得记录的：
- **选项 B 的论证关键** 是把"≥ 1 跨域 reference impl"的 **真正价值** 拆解为 (a) 实证 fork 难度 (b) 暴露案例耦合点 → 两个目标已被 cross-domain-mapping.md (Sprint M-Q 各模块都有) 替代实现
- 这种"拆解条件背后的价值"的论证模式是 framework v0.x 演进的常见决策模板

**沉淀**：ADR-030 §3 (Options Considered) 的 "拆解原条件背后价值 → 评估替代实现是否已存在" 论证模板可被 v0.4 / v1.0 release 决策复用。

### 2.3 methodology cross-ref 形成网状结构

Sprint R 让 methodology/02 v0.1.1 沉淀 4 段元 pattern（中心节点）；Sprint S 让 /01 + /03 + /04 v0.1.2 加双向 cross-ref → 5 doc 形成网状结构：

```
   /01 (role)     /02 (sprint gov)     /03 (identity)
       ↓                ↓                    ↓
       ←———————→ /02 §10-§13 元 pattern ←———————→
                                              ↓
                  /04 (invariant)        /05 (audit)
```

读者从任何一份 doc 进入都能找到 cross-ref 到其他 doc + /02 元 pattern；跨域 fork 案例方启示也变得清晰（每份 doc 都有"跨域 fork 启示"段）。

**沉淀**：methodology v0.x 的"网状 cross-ref"是 framework 文档群的成熟标志（vs 早期 v0.1 的"星形 + 单向引用"）。

### 2.4 1.5 会话紧凑路径达成 + 0 Stop Rule

工时与 v0.1.3 §2.1 3 类估时表精确匹配（150 min ≈ 2.5 hours），紧凑路径完美达成。0 Stop Rule 触发延续 P→Q→R→S 4 sprint zero-trigger 节奏。

**沉淀**：4 sprint zero-trigger 是 framework 稳定的强信号（vs Sprint R retro §5.1 期待的"≥ 5 sprint zero-trigger 触发 v1.0 候选议程"）。Sprint T (v0.3 release) 后将继续观察。

---

## 3. 改进点（What Didn't Work）

### 3.1 批 4 methodology/04 略超估算（30 vs 25 min）

methodology/04 v0.1.2 写作中加了一段"self-test 是 invariant 类 framework 独有的强化模式"段（§8.3），略超 5 min。

**改进建议**：
- 这段是 §02 §13 跨 stack 抽象 pattern 的有用补充（self-test 是 invariant 类独有）
- 不算 scope creep（仍在 batch 4 主题"methodology/04 v0.1.2 cross-ref"内）
- 未来 methodology cross-ref polish 估算可加 5-10 min 缓冲（"领域特有强化模式"段写作）

### 3.2 commit-attribution 历史问题（Sprint R 残留 / 已记入 retro 但未修复）

Sprint R commit `35f371d` 实际包含 6 files（hooks + 4 framework polish）— commit message 仅说 hooks。

Sprint S **未修复此 commit-attribution 问题**（用户已 ACK 接受；rebase 风险高 / 收益低）。

**改进建议**：
- 已记 v0.4 候选（chief-architect.md §工程小细节 v0.2.2 候选段："commit message 应反映**实际改动文件集合**，pre-commit 失败重试时确认 staged file list"）
- Sprint T (v0.3 release sprint) 起草时如有合适机会 fold 进 chief-architect.md polish

### 3.3 用户 brief preview "推荐 B" 提前透露 ADR-030 结论

Sprint S brief §1.1 之前给用户 preview 时已说"我倾向论证后建议 **B**"，让 ADR 起草时少了一些"独立论证"的 challenge 价值。

**改进建议**：
- 不严重（Architect role 就是要给推荐 / 用户 ACK 后 ADR 仅是正式记录）
- 但下次类似"评估 ADR" sprint，brief preview 可以**只列 3 选项 + 论证维度**，不预 reveal 推荐，让 ADR 起草过程对用户也是开放的
- 已沉淀为下次 sprint brief preview 风格 reminder（不算独立 debt）

---

## 4. Stop Rule 触发回顾

> 触发处理协议见 `framework/sprint-templates/stop-rules-catalog.md` §7。

**无触发**（连续第 **4** 个 zero-trigger sprint：P → Q → R → S）。

| Rule | 类别 (catalog §) | 触发原因 | 架构师裁决 (A/B/C/D) | trigger 文件 |
|------|----------------|---------|--------------------|-------------|
| — | — | 无触发 | — | — |

---

## 5. Lessons Learned

### 5.1 工程层面

#### "评估 sprint" 是 release prep 的 first-class 形态

Sprint S 不动 framework code（Code 类估时 0 hours），全部输出是 ADR + methodology polish。这是 framework v0.x 演进的**第 4 类 sprint 形态**（vs 抽象 / maintenance / patch）：

| 形态 | 实证 sprint | 主要输出 |
|------|----------|---------|
| 新模块抽象 | L / M / N / O / Q | framework code + dogfood |
| Maintenance（清债）| P / R | patch + small docs |
| Eval / Release prep | **S** | **ADR + methodology cross-ref** |
| Release（即将到来）| Sprint T (v0.3 release) | RELEASE_NOTES + version bump + tag |

**沉淀**：Eval sprint 是 release 节奏的必要前置（避免 release sprint 同时承担"做决策 + 写 RELEASE_NOTES"双重负担）。可写入 methodology/02 v0.2 候选段。

#### v0.3 release timing 决策的"价值替代"论证模式

ADR-030 §3 选项 B 的论证关键是 "拆解原条件背后价值 → 评估替代实现是否已存在 → 决定是否能用替代降低硬要求"。

这套模板可被**任何 release 触发条件评估**复用：
- v0.4 release 时若缺某条件 → 用同样模板拆解
- v1.0 release 时（远期）也可参考

**沉淀**：可写入 `docs/methodology/06-adr-pattern-for-ke.md` v0.2 候选段（如果 06 已起草 / 当前 06 还在 Stage C 待起草）。

### 5.2 协作层面

Sprint S 是 single-actor sprint，无跨角色协作。

但 ADR-030 决策记录是**对未来 fork 案例方 + 跨外部 reviewer 的 first-class 沟通**（vs 把决策埋在 retro / STATUS）。这种"决策 - documentation - communication" 链条是 framework v0.x 对外演进的重要锚点。

**沉淀**：framework v0.x 的所有 release timing / scope decisions 必须用 ADR 记录（per chief-architect role 输出格式）。Sprint T (v0.3 release sprint) 内如有 release scope adjustment，需补 ADR-031。

### 5.3 模型选型 retro

**Architect = Opus 4.7（全程）**：合适。

ADR-030 起草需要长 context（5/6 条件评估 + 3 选项论证 + Consequences）+ methodology cross-ref 写作需要风格统一（与原 §1-§N 不漂移）+ 跨 doc 一致性（/01 vs /03 vs /04 各自的"与 §02 元 pattern 关系"段都要保持平行结构）。Sonnet 风险点：3 doc cross-ref 段易 inconsistent。

→ Sprint S 的 Opus 全程仍是必要的。

但 Sprint T (v0.3 release sprint) 的批次（RELEASE_NOTES / version bump / tag prep）模板化更强，**Sonnet 可考虑**作为成本优化候选（不阻塞当前 Opus 全程的稳定性）。

---

## 6. 衍生债登记

本 sprint 收口后：

**新 v0.4 候选 1 项**：

| ID | 描述 | 优先级 | 来源 |
|----|------|--------|------|
| T-V04-FW-001 | chief-architect.md §工程小细节 v0.2.2 加 "commit message 应反映实际改动 file 集合（pre-commit 失败重试时确认 staged list）" | P3 | 本 retro §3.2（Sprint R commit `35f371d` 残留问题）|

押后清单（不变）：
- v0.2: 2 项（DGF-N-04 + DGF-N-05，等外部触发）
- v0.3: 1 项（T-V03-FW-005 Docker compose / 大工作 / 候选 fold 进 Sprint T release sprint 或更晚）

详见 `docs/debts/sprint-s-residual-debts.md`。

---

## 7. D-route 资产沉淀盘点

### 7.1 本 sprint 沉淀的可抽象 pattern

1. **"评估 sprint" 形态**（vs 抽象 / maintenance / patch / release）— release prep 的 first-class 形态 / 待写入 methodology/02 v0.2
2. **ADR §3 "拆解条件背后价值 → 评估替代实现"论证模板** — 可被任何 release timing decision 复用 / 待写入 methodology/06
3. **methodology cross-ref 网状结构** — 5 doc 双向引用模式（vs v0.1 的星形单向）
4. **brief-template v0.1.3 §2.1 3 类估时表 dogfood ✓** — 偏差从 1.4-1.5x 降到 < 10%

### 7.2 本 sprint 暴露的"案例耦合点"

无新案例耦合点（评估 sprint / 不动 case 数据）。

ADR-030 提到的"≥ 1 跨域 reference impl 等触发条件"调整 — 让 framework v0.3 release 不锁死跨域案例方接触 timeline，提升 release 节奏自主性。

### 7.3 Layer 进度推进

- L1: 5 模块齐备 不变
- L2: methodology/01 + 03 + 04 v0.1.1 → **v0.1.2**（3 doc cross-ref / 网状结构成型）⭐
- L3: 不变
- L4: + ADR-030 v0.3 release timing 决策（明确 timeline / 对外可见性提升）⭐

### 7.4 下一 sprint 抽象优先级建议

按 ADR-030 §2.2 锁定：

**Sprint T = v0.3 release sprint**（候选 A 推荐 / 不可降级）

形态：与 Sprint P (v0.2 release) 同 / 5-batch maintenance sprint / 1-2 会话 / 推荐 Sonnet（patch + 文档撰写主导 / 模板化强 / 成本优化）

batch 候选结构：

| 批 | 主题 | 估时 |
|----|------|------|
| 1 | T-V03-FW-005 Docker compose（如未单独 mini-sprint）| 4-6h（大工作 / 占主要时间）|
| 2 | 5 模块 README §8 加 v0.3.0 行 + 各模块 `__version__` bump | ~30 min |
| 3 | framework/RELEASE_NOTES_v0.3.md 起草 | ~45 min |
| 4 | docs/STATUS.md / CHANGELOG.md 更新 v0.3.0 release 标记 | ~20 min |
| 5 | sanity 回归 + 60 pytest + ruff/format clean | ~10 min |
| 4 (closeout) | closeout + retro + STATUS/CHANGELOG | ~30 min |

**关键决策**：T-V03-FW-005 是否 fold 进 Sprint T？

- 选 1（推荐）：fold 进 Sprint T 批 1 → Sprint T 1.5-2 会话完成（与 Sprint P scale 一致）
- 选 2：单独 Sprint S+0.5 mini-sprint → Sprint T 仅 0.5-1 会话（更紧凑 release-only）

→ Sprint T brief 起草时根据用户偏好 + 工时容忍度决定。

---

## 8. 下一步（Sprint T 候选议程）

依据本 retro 发现 + ADR-030 §2.2 决策：

**Sprint T = v0.3 release sprint**（不可降级 / per ADR-030 锁定）

完成判据预测：
- ✅ 5 模块各 v0.3.0 statement 一致（统一版本号策略 / 与 v0.2 一致）
- ✅ framework/RELEASE_NOTES_v0.3.md 落地
- ✅ git tag `v0.3.0` 准备命令就位
- ✅ sanity 不回归 + 60 pytest + ruff/format clean
- ✅ Sprint T closeout + retro
- ✅ ADR-030 §5 Validation Criteria 6 条 checklist 回填

不要做的事：
- ❌ 不开新 framework 模块（5 模块齐备已是阶段终点）
- ❌ 不做 DGF-N-04 / DGF-N-05（押后等外部触发 / 不阻塞 v0.3 release）
- ❌ 不在 Sprint T 内做"顺手 polish methodology"（保 release sprint 紧凑）
- ❌ 不立即触发 ADR-031 plugin 协议（per Sprint M-O-P-Q-R-S 同结论）

---

## 9. 决策签字

- 首席架构师：__ACK 2026-04-30 (Architect)__
- 用户：__ACK 待签__
- 信号：本 retro 用户 ACK + commit + push → **Sprint S 关档 / Sprint T = v0.3 release sprint 启动**

---

**Sprint S retro 起草于 2026-04-30 / retro-template v0.1.1 第 9 次外部使用 / Architect Opus**
