# Sprint P Stage 4 — Closeout

> Status: in progress → 待 retro 完成 ACK 后 close
> Date: 2026-04-30
> 主题: v0.2 patch + framework v0.2 release prep

---

## 1. Sprint P 收口判据回填（vs brief §6 / 9 项）

| # | 判据 | 状态 | 证据 |
|---|------|------|------|
| 1 | 8 项 v0.2 待办全部 fix | ✅ | §2.1 表格全列 ✓ |
| 2 | 4 模块 ruff clean + sanity tests pass | ✅ | `ruff check framework/` + Stage 1 批 5 8/8 sanity |
| 3 | 4 模块 README v0.2 版本信息 | ✅ | sprint-templates / role-templates / identity_resolver / invariant_scaffold §8 全更新 |
| 4 | RELEASE_NOTES_v0.2.md 就位 | ✅ | `framework/RELEASE_NOTES_v0.2.md` |
| 5 | docs/STATUS.md / CHANGELOG.md 更新 | ✅ | 本 closeout 同 commit |
| 6 | Sprint P retro 含 D-route 资产盘点 | ✅ | `docs/retros/sprint-p-retro-2026-04-30.md` §7 |
| 7 | 衍生债登记（剩余 6 项） | ✅ | `docs/debts/sprint-p-residual-v02-debts.md` |
| 8 | Sprint Q 候选议程 | ✅ | retro §8 |
| 9 | git tag v0.2.0 命令准备就位 | ✅ | RELEASE_NOTES_v0.2.md §7 |

**判据全 9/9 ✅。**

---

## 2. Sprint P 全 patch 详情（8 项）

### 2.1 P2（1 项）

| ID | 来源 | 改动文件数 | 改动内容 |
|----|------|----------|---------|
| DGF-O-01 | 升级自 Sprint N DGF-N-02（P3 漏修 → 跨 sprint 复发）| 4 | examples 路径硬编码改 `HUADIAN_DATA_DIR` 环境变量优先 + `parents[4]` fallback |

### 2.2 P3（7 项）

| ID | 类型 | 模块 | 改动 |
|----|------|------|------|
| T-P3-FW-001 | template polish | sprint-templates | brief-template §1.2 表格灵活列数说明 |
| T-P3-FW-002 | template cross-ref | sprint-templates | retro-template §4 与 stop-rules-catalog §7 双向 cross-ref |
| T-P3-FW-003 | template polish | sprint-templates | stage-3-review-template §2.0 review 形式选择指南 |
| T-P3-FW-004 | template polish | sprint-templates | brief-template §8 D-route 措辞解耦 C-22 项目宪法专属性 |
| DGF-M-01 | template structure | sprint-templates | brief-template §3 拆分 §3.A 5-stage 与 §3.B 精简模板 + §3.0 选择指南 |
| DGF-N-01 | code generalization | identity_resolver | test_byte_identical compare() 引入 `FIELD_ALIASES` 通用机制 |
| DGF-O-04 | code nit | invariant_scaffold | ContainmentInvariant 用 `inspect.isawaitable()` 替代 `hasattr` |

### 2.3 v0.2 release prep

| 文件 | 改动 |
|------|------|
| `framework/sprint-templates/README.md` | §0 status / §8 加 v0.2.0 行 |
| `framework/role-templates/README.md` | §0 status / §8 加 v0.2.0 行 |
| `framework/identity_resolver/README.md` | §0 status / §8 加 v0.2.0 行 |
| `framework/invariant_scaffold/README.md` | §0 status / §8 加 v0.2.0 行 |
| `framework/identity_resolver/__init__.py` | `__version__` 0.1.0 → 0.2.0 |
| `framework/invariant_scaffold/__init__.py` | `__version__` 0.1.0 → 0.2.0 |
| `framework/RELEASE_NOTES_v0.2.md` | 新文件，顶层 release notes |
| `framework/sprint-templates/brief-template.md` | 文末 footer 升 v0.1.2 + 变更日志 |

### 2.4 sanity 回归（Stage 1 批 5）

8 项 sanity 全过：
1. identity_resolver __version__ = 0.2.0 ✓
2. invariant_scaffold __version__ = 0.2.0 ✓
3. test_byte_identical FIELD_ALIASES (3 aliases) ✓
4. ContainmentInvariant.isawaitable sync + async ✓
5. 4 helpers env-var override + walk-up fallback ✓
6. invariant_scaffold 5 patterns import ✓
7. identity_resolver public API import ✓
8. sprint-templates / role-templates / RELEASE_NOTES_v0.2 文件存在 ✓

ruff check framework/ → All checks passed
ruff format --check framework/ → 53 files already formatted

---

## 3. v0.2 累计债务状态

| Sprint | 总 v0.2 候选 | 已 patch | 仍待 v0.2 |
|--------|-----------|---------|----------|
| L (T-P3-FW-001~004) | 4 | 4 ✓ | 0 |
| M (DGF-M-01~07) | 7 | 7 ✓（v0.1.1 6 项 + Sprint P DGF-M-01）| 0 |
| N (DGF-N-01~05) | 5 | 2 ✓（DGF-N-01 / DGF-N-02 升级 P2 已修）| 3（DGF-N-03 / -04 / -05）|
| O (DGF-O-01~04) | 4 | 3 ✓（DGF-O-01 / -04；O-01 升级 P2 已修）| 1（DGF-O-02 / -03）|
| **合计** | **20** | **14** | **6** |

→ 14 → 6 完成（vs brief 预期一致），6 项押后到 Sprint Q+。

---

## 4. 模型工时审计

- 实际：1 个 Cowork 会话 / Architect (Opus) 主导
- 预算：1-2 会话 / Opus 全程
- 与 Sprint L+M+N+O 同 scale（Sprint L = 1 会话 / M = 2 会话 / N = 1 会话 / O = 1 会话）
- 偏差：无

---

## 5. Stop Rule 触发

**无触发。**

Sprint P 本身设计为低风险 patch + ceremonial release，6 条 stop rule 全部未命中：
- §1 path patch 后 4 模块跑通 → ✓
- §2 brief-template polish 后自我 dogfood 顺手 → 当前会话起草本 closeout 时即下游 dogfood，顺手
- §3 DGF-O-04 改动未破坏任何 ContainmentInvariant 测试 → ✓（sync + async sanity 通过）
- §4 工时未超 2 会话 → 1 会话内完成 ✓
- §5 未触发新 ADR ✓
- §6 release prep 未发现未发现 bug ✓

---

## 6. Layer 进度更新

| Layer | Sprint P 前 | Sprint P 后 | Δ |
|-------|-----------|-----------|---|
| L1 (框架代码抽象) | 4 模块 v0.1 | **4 模块 v0.2.0 公开 release** | ✅ 第一次正式 release tag |
| L2 (方法论文档) | 7 草案 ≥ v0.1 | 7 草案不变 | 0（patch sprint 不产 methodology）|
| L3 (案例库) | huadian 主案例 + dogfood ✓ | 不变 | 0 |
| L4 (社区/培训/商业) | 未触发 | **触发点：v0.2.0 GitHub release tag** | ⭐ 第一刀（公开可见性升级）|

→ Sprint P 是 **L4 第一刀触发** sprint。后续若有跨领域案例方主动接触，可直接 fork v0.2.0 baseline。

---

## 7. 给用户的 commit + push checklist

请用户在 local Terminal 执行（不在 sandbox 内）：

```bash
cd /Users/lizhuojun/Desktop/APP/huadian

# 1. 检查改动
git status
git diff --stat

# 2. commit（建议 2 个 commit 分离 framework 改动 vs docs）
git add framework/
git commit -m "feat(framework): v0.2.0 release — 8 v0.2 patches landed (Sprint P)

Sprint P 收口 Sprint L+M+N+O 累计 8 项 v0.2 patch（1 P2 + 7 P3），
4 模块同步打 v0.2.0 标记。

P2 修复（跨 sprint 复发）：
- DGF-O-01 examples 4 处路径硬编码改 HUADIAN_DATA_DIR env var

P3 修复（7 项）：
- T-P3-FW-001 brief-template §1.2 灵活列数
- T-P3-FW-002 retro/stop-rules cross-ref 紧密化
- T-P3-FW-003 stage-3-review §2.0 review 形式选择指南
- T-P3-FW-004 brief-template §8 D-route 措辞解耦
- DGF-M-01 brief-template §3 拆 §3.A 5-stage / §3.B 精简模板
- DGF-N-01 test_byte_identical FIELD_ALIASES 通用机制
- DGF-O-04 ContainmentInvariant inspect.isawaitable() robust 检测

Release prep:
- 4 模块 README §8 v0.2 行
- 2 模块 __version__ bump 0.1.0 → 0.2.0
- framework/RELEASE_NOTES_v0.2.md 新文件

剩余 6 项 v0.2 候选押后 Sprint Q+（pytest tests / 跨领域 examples / EntityLoader.load_subset）。
"

git add docs/
git commit -m "docs(sprint-p): closeout + retro + status + changelog

- Sprint P stage-0-brief / stage-4-closeout / retro
- STATUS.md / CHANGELOG.md 更新 v0.2.0 release
- debts/sprint-p-residual-v02-debts.md 押后 6 项登记"

# 3. 打 v0.2.0 tag
git tag -a v0.2.0 -m "framework v0.2.0 — Sprint P v0.2 patch + ceremonial release

4 模块统一版本号；8 项累计 patch 落地；
6 项押后 Sprint Q+；公开 GitHub release 触发 L4 第一刀。"

# 4. push
git push origin main
git push origin v0.2.0

# 5. （可选）GitHub UI 创建 Release
# 用 framework/RELEASE_NOTES_v0.2.md 内容贴到 GitHub Release notes
```

---

## 8. Stage 4 信号

```
✅ Sprint P Stage 4 closeout 完成
- 9/9 收口判据全过
- 8 项 patch 全 land
- 4 模块 v0.2.0 release 准备就位
- 14 → 6 v0.2 待办（6 项押后清单已登记）
- L4 第一刀触发点（v0.2.0 GitHub release tag）
- Stop Rule 0 触发
- 工时 1 会话（vs 预算 1-2 会话）

待用户 ACK retro → Sprint P 关档 → Sprint Q 候选议程激活
```

---

**Stage 4 完成于 2026-04-30 / Sprint P / Architect Opus**
