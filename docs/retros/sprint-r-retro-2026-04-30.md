# Sprint R Retro — v0.3 Patch + methodology v0.2 Polish

> 起草自 `framework/sprint-templates/retro-template.md` v0.1.1
> Dogfood: retro-template **第 8 次**外部使用

## 0. 元信息

- **Sprint ID**: R
- **完成日期**: 2026-04-30
- **主题**: v0.3 patch + methodology v0.2 polish 合并
- **预估工时**: 1-2 个 Cowork 会话
- **实际工时**: **1 个 Cowork 会话 ~95 min + closeout/retro ~30 min**（紧凑路径 ✓）
- **主导角色**: 首席架构师（Claude Opus 4.7）— single-actor sprint

---

## 1. Sprint 任务回顾

### 1.1 Stage 顺序与产出（精简模板 §3.B）

| Stage | 主导 | 状态 | 关键产出 |
|-------|------|------|----------|
| Stage 0 inventory + brief 起草 | Architect | ✅ | brief-template v0.1.2 第 2 次 dogfood / 6 候选 inventory + 1 押后 |
| Stage 1 批 1 — T-V03-FW-001 + -003 | Architect | ✅ | identity_resolver/README §2.5 公共 API + brief-template v0.1.3 |
| Stage 1 批 2 — T-V03-FW-004 | Architect | ✅ | role-templates/chief-architect §工程小细节 + role-templates v0.2.1 |
| Stage 1 批 3 — T-V03-FW-002 methodology/02 v0.1.1 | Architect | ✅ | + 5 段元 pattern (~315 行) |
| Stage 1 批 4 — T-V03-FW-006 pre-commit hook | Architect | ✅ | scripts/check-audit-triage-sync.sh + .pre-commit-config.yaml + 5 scenarios test |
| Stage 1.13 sanity 回归 | Architect | ✅ | 60/60 pytest + ruff/format clean + 5 模块 import OK |
| Stage 4 closeout + retro | Architect | ✅ | 5 docs |

### 1.2 数据 / 工程基线 Δ

| 维度 | Sprint 前 | Sprint 后 | Δ |
|------|---------|---------|-----|
| brief-template 版本 | v0.1.2 | v0.1.3 | +1 polish (3 类估时表) |
| role-templates 版本 | v0.2.0 | v0.2.1 | +1 patch (chief-architect §工程小细节) |
| methodology/02 版本 | v0.1 | v0.1.1 | +1 iter (+5 段元 pattern) |
| identity_resolver/README | 8 段 | **9 段**（+ §2.5 公共 API 速查 / 38 个 export 7 类）| +1 段 |
| pre-commit hooks 数 | 8 | **9** | +1 (services↔framework sync warning) |
| v0.2 累计 patch | 18/20 | 18/20 | 不变 |
| v0.3 累计 land | 0/6 | **5/6** | +5 ⭐ |
| 累计 patch 落地率 | (18+0) / (20+6) = 69.2% | (18+5) / (20+6) = **88.5%** | +19.3pp |
| Stop Rule 触发 | 0 (Sprint Q 接续) | **0**（连续 3 sprint）| 稳定 |
| pytest tests | 60 | 60 | 不变 |
| 5 模块 sanity | OK | OK | 不变 |

---

## 2. 工作得好的部分（What Worked）

### 2.1 5-batch 清债 sprint pattern 第 2 次实战即顺手

Sprint P 实证的"5-batch 清债 sprint pattern"在 Sprint R 第 2 次套用，节奏完全匹配 brief 估算：
- 批 1+2+3+4 实际 ~85 min vs 估算 ~85 min（精确匹配）
- 批 1.13 sanity 实际 ~10 min vs 估算 ~15 min（提前完成）
- 全程紧凑 1 会话内完成 + zero Stop Rule 触发

**沉淀**：5-batch pattern 已被 methodology/02 v0.1.1 §10 正式收录，未来跨域 fork 案例方可直接复用。

### 2.2 brief-template v0.1.2 第 2 次 dogfood + v0.1.3 落地即用

写本 sprint 的 brief 用 v0.1.2（第 2 次外部使用 / 顺手），写完 batch 1 即 bump v0.1.3 加 3 类估时表，**closeout 时立即用 v0.1.3 新表回填**——dogfood 闭环在 1 个 sprint 内完成。

新表实证有效：closeout §2 回填 1160 行（Code 105 + Docs 485 + Closeout/Retro 570）远比单一时长估算更清晰；触发 Stop Rule #4 输出量阈值时也能定位"哪类爆了"。

**沉淀**：brief-template v0.1.3 §2.1 估时表是 v0.1.2 polish 之后第 1 次"brief 内即 polish 即 dogfood"全周期实证。

### 2.3 methodology/02 v0.1.1 4 段元 pattern 全部沉淀自实证

写 §10 (Maintenance Sprint Pattern) / §11 (P3 复发升级 P2) / §12 (5 模块齐备阈值) / §13 (跨 stack 抽象) 时**完全没有"凭空想"**，每段都有 Sprint P+Q 实证锚点：

| 段 | 实证锚点 |
|----|---------|
| §10 | Sprint P (1 会话压缩 5-batch) + Sprint Q (5-batch 加合并补测) |
| §11 | Sprint P DGF-N-02 → Sprint O DGF-O-01 (P3 漏修跨 sprint 复发) |
| §12 | Sprint Q (audit_triage v0.1 落地 = 5 模块齐备 ⭐) |
| §13 | Sprint Q (TS prod → Python framework / soft-equivalent dogfood) |

**沉淀**："元 pattern 必须有 ≥ 1 次实证锚点"是 methodology v0.x 起草的隐性规则。Sprint R 把它默认实践了。

### 2.4 pre-commit hook bash 实现 + 5 scenarios test 一次过

T-V03-FW-006 hook 实现简洁（90 行 bash），5 个 test scenarios 全验证一次过（warning 仅 case 1 触发；2-5 全 silent；exit 0 全过）。

**沉淀**：跨 stack sync 检查 hook pattern 可被复用——未来如果有 services/api/identity.* ↔ framework/identity_resolver/examples/ sync 需求，直接复制此脚本结构 + 改 case path。

---

## 3. 改进点（What Didn't Work）

### 3.1 批 3 methodology/02 略超估算（35 min vs 30 min）

写 5 段元 pattern 略超 5 min 估算。原因：
- §10 / §13 涉及多文件 cross-ref（与 §2 + §13 跨 stack 的关联描述）
- §11 P3 复发升级 P2 暗规则的"为什么必须升级（不是简单再做一次）" §11.3 论证需要思考

**改进建议**：未来 methodology 段写作的估算公式可以是 `30 min × N段 × 1.2 (cross-ref 系数)`。已沉淀为下次 sprint brief 起草参考。

不严重——总工时仍在 1 会话内，未触 Stop Rule #6。

### 3.2 Sprint R 内未使用 v0.1.3 新估时表写 brief

Sprint R brief 写于 v0.1.2 时（v0.1.3 在批 1 才落地），所以 brief §2.1 用单一时长估算（~85 min total）。**Sprint S brief 起草时第一次用 v0.1.3 新格式**——这才是 v0.1.3 真正的下游 dogfood。

**改进建议**：retro §3.2 留作 Sprint S 起草时的 reminder。如果 v0.1.3 估时表 dogfood 暴露问题，会触发 v0.1.4 polish 候选。

---

## 4. Stop Rule 触发回顾

> 触发处理协议见 `framework/sprint-templates/stop-rules-catalog.md` §7。

**无触发**（连续第 **3** 个 zero-trigger sprint：Sprint P → Q → R）。

| Rule | 类别 (catalog §) | 触发原因 | 架构师裁决 (A/B/C/D) | trigger 文件 |
|------|----------------|---------|--------------------|-------------|
| — | — | 无触发 | — | — |

---

## 5. Lessons Learned

### 5.1 工程层面

#### "连续 3 个 zero-trigger sprint" 是 framework 稳定的强信号

Sprint P (清债) → Q (新模块 + 合并补测) → R (清债 + methodology polish) 三个 sprint 形态各异，全部 zero-trigger：

- Sprint P: pure patch，无新设计
- Sprint Q: 新模块抽象 + 跨 stack pattern 首次实证
- Sprint R: pure patch + 元 pattern 沉淀

→ 不同形态都能 zero-trigger = framework v0.2 + 5 模块齐备的稳定信号确认。这是宣布"framework 抽象阶段终点"（per methodology/02 §12）的重要支持。

**沉淀**：未来若 ≥ 5 sprint 都 zero-trigger，可考虑 v1.0 release 候选议程（v0.x → v1.0 的"成熟度阈值"）。当前 3 sprint 还不够，但已是 leading indicator。

#### "周期性 maintenance sprint" 节奏第 2 次实证

Sprint L+M+N+O (4 抽象) → Sprint P (maintenance) 是第 1 次。
Sprint P → Q (新抽象) → R (maintenance) 是第 2 次。

这套"3-5 抽象 sprint 后 1 次 maintenance"的节奏：
- 避免 v0.x 候选堆积（Sprint R 时只剩 6 项 / 不至于失控）
- 让 framework code + methodology 同节律演进
- 给跨 stack abstraction / pytest 套件 等"非主线但重要"的工作专门时间

**沉淀**：methodology/02 v0.1.1 §10.4 已固化此节律。

### 5.2 协作层面

Sprint R 是 single-actor sprint，无跨角色协作。

但**跨 stack sync hook** 揭示一个隐含协作维度：当未来有 BE 工程师改 services/api/triage.service.ts 时，会被 hook 提醒"是否需同步改 framework/audit_triage/"——这是 framework 抽象在跨角色场景的"被动捕获"机制。

**沉淀**：跨 stack 抽象的"sync 提醒"可以是 hook（被动）+ retro 检查（主动）+ Architect 评审（最终保障）三层防御。Sprint R hook 是第一层。

### 5.3 模型选型 retro

**Architect = Opus 4.7（全程）**：合适。

写 5 段 methodology 元 pattern + 各段需要长 context（参考 Sprint P+Q retro + 实证锚点）+ 写作风格统一（与 §1-§8 不漂移）→ Opus 是必要的。

但 batch 1+2 (~25 min 简单 polish) 其实 Sonnet 也可胜任。**未来纯 polish-only sprint 的批次可考虑 Sonnet**（成本优化候选 / 不阻塞当前 Opus 全程的稳定性）。

→ Sprint R 的 Opus 全程仍是合理选择。Sprint S 视主题再评估。

---

## 6. 衍生债登记

本 sprint 收口后：

**新 v0.4 候选 0 项**（Sprint R 是 patch sprint / 未触发新发现）。

**留 Sprint R 内识别的 reminder**（不算独立 debt）：
- Sprint S brief 起草时**首次使用 brief-template v0.1.3 新 3 类估时表** — 如果 dogfood 暴露问题，触发 v0.1.4 polish 候选

押后清单：
- v0.2: 2 项（DGF-N-04 + DGF-N-05，等外部触发）
- v0.3: 1 项（T-V03-FW-005 Docker compose / 大工作）

详见 `docs/debts/sprint-r-residual-debts.md`。

---

## 7. D-route 资产沉淀盘点

### 7.1 本 sprint 沉淀的可抽象 pattern

1. **5-batch 清债 sprint pattern 第 2 次实战实证** — methodology/02 §10 已固化
2. **元 pattern 必须有 ≥ 1 实证锚点的写作约定** — Sprint R retro §2.3 explicit 沉淀
3. **跨 stack sync hook pattern**（services↔framework/examples 提醒）— 可复制到任何"生产 stack ≠ framework stack"场景
4. **brief 内即 polish 即 dogfood 全周期**（v0.1.2 → v0.1.3 在 1 sprint 内闭环）— 加速 methodology v0.x 演进

### 7.2 本 sprint 暴露的"案例耦合点"

无新案例耦合（patch sprint）。

唯一边缘 case：scripts/check-audit-triage-sync.sh 的 path regex 是 huadian-specific（services/api/.../triage.* 路径）；跨域 fork 时需改 path。**已在脚本顶部注释 + .pre-commit-config.yaml 内提示。**

### 7.3 Layer 进度推进

- L1: 5 模块齐备 不变 + 微 polish（identity_resolver §2.5 + role-templates v0.2.1）
- L2: **methodology/02 v0.1 → v0.1.1**（+ 5 段元 pattern / 4 实证锚点）⭐
- L3: 不变（patch sprint 不动 case 数据）
- L4: + 1 pre-commit hook（提升跨 stack 抽象一致性保证 / 微 robustness 增益）

### 7.4 下一 sprint 抽象优先级建议

按价值 / 风险综合判断：

1. **Sprint S 候选 A**：v0.3 release prep sprint（推荐 / 视 v0.3 触发条件评估）
   - 触发条件检查：6 v0.3 候选 5 land + 押后 2 项 v0.2 + 跨域 reference impl 仍未 land
   - 当前未达 v0.3 release 触发条件（押后 v0.2 2 项 + 跨域 0 → 不 release）
   - 形态：评估 sprint，不开 patch / 1 会话内
2. **Sprint S 候选 B**：methodology v0.2 持续 polish（剩余 6 草案的 v0.x 演进）
   - methodology/01 v0.1.1 / 03 v0.1.1 / 04 v0.1.1 加 cross-ref to /02 §10-§13 元 pattern
   - methodology/06 + 07 等仍 Stage C 待起草的草案
   - 形态：纯文档 / Architect 主导 / 1-2 会话
3. **Sprint S 候选 C**（远期）：跨域 reference impl (legal) — 押后等触发
4. **Sprint S 候选 D**（小工作 / 与 A 或 B 合并）：T-V03-FW-005 Docker compose Postgres + seed fixtures

---

## 8. 下一步（Sprint S 候选议程）

依据本 retro 发现，建议 Sprint S 推进：

- **优先选 候选 B**（methodology v0.2 持续 polish） — 趁 §10-§13 元 pattern 沉淀热度高，把 cross-ref 落到 methodology/01 / 03 / 04
- **或 候选 A**（v0.3 release prep 评估） — 1 会话内完成，结论"v0.3 不触发"也算结论
- 候选 C 不主动启动
- 候选 D 可与 B 合并（+ ~4h 工作）

不要做的事：
- ❌ 不开新 framework 模块（5 模块齐备已是阶段终点 / methodology/02 §12 显式约束）
- ❌ 不动 audit_triage v0.1 ABI（保稳定到 v0.2 release）
- ❌ 不在 Sprint S 内做"顺手抽个新模块"（破坏 zero-trigger 节奏 / methodology/02 §10.5 显式反模式）
- ❌ 不立即触发 ADR-031 plugin 协议（per Sprint M-O-P-Q-R 同结论）

---

## 9. 决策签字

- 首席架构师：__ACK 2026-04-30 (Architect)__
- 用户：__ACK 待签__
- 信号：本 retro 用户 ACK + commit + push → **Sprint R 关档 / Sprint S 候选议程激活**

---

**Sprint R retro 起草于 2026-04-30 / retro-template v0.1.1 第 8 次外部使用 / Architect Opus**
