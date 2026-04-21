# T-P0-025 Gate 0a — Wikidata Coverage Probe Report

> **Date**: 2026-04-21 23:22:29
> **Persons**: 320
> **Elapsed**: 245s

---

## 1. 执行摘要

| 指标 | 值 |
|------|-----|
| 全局命中率 | **54.4%** (174/320) |
| Round 1 精确命中 | 49.1% (157/320) |
| 　└ 单候选 | 149 |
| 　└ 多候选 | 8 |
| Round 2 alias 贡献 | 17 |
| 未命中 | 146 |
| **决策矩阵落桶** | **≥ 40% → Sprint B 按 ADR-021 §2.1 全量推进** |

---

## 2. 分层命中率

### 2.1 按 dynasty

| Dynasty | Total | Hit | Hit% |
|---------|-------|-----|------|
| 上古 | 79 | 43 | 54.4% |
| 东周 | 36 | 18 | 50.0% |
| 先周 | 6 | 3 | 50.0% |
| 周 | 1 | 1 | 100.0% |
| 商 | 61 | 43 | 70.5% |
| 夏 | 20 | 9 | 45.0% |
| 战国 | 25 | 11 | 44.0% |
| 春秋 | 22 | 13 | 59.1% |
| 秦 | 1 | 0 | 0.0% |
| 西周 | 67 | 31 | 46.3% |
| 西汉 | 2 | 2 | 100.0% |

### 2.2 按 reality_status

| Status | Total | Hit | Hit% |
|--------|-------|-----|------|
| historical | 184 | 101 | 54.9% |
| legendary | 131 | 73 | 55.7% |
| uncertain | 5 | 0 | 0.0% |

---

## 3. 未命中样本（前 30 / 146 条）

| # | slug | canonical_name | dynasty | reality_status |
|---|------|---------------|---------|----------------|
| 1 | chang-pu | 昌仆 | 上古 | legendary |
| 2 | chui | 倕 | 上古 | legendary |
| 3 | di-ku | 高辛 | 上古 | legendary |
| 4 | feng-hou | 风后 | 上古 | legendary |
| 5 | fu-yue | 傅说 | 商 | historical |
| 6 | gong-gong | 共工 | 上古 | legendary |
| 7 | gu-gong-dan-fu | 古公亶父 | 先周 | historical |
| 8 | huang-di | 轩辕 | 上古 | legendary |
| 9 | jian-di | 简狄 | 上古 | legendary |
| 10 | jiao-ji | 蟜极 | 上古 | legendary |
| 11 | ji-li | 季历 | 西周 | historical |
| 12 | kui | 夔 | 上古 | legendary |
| 13 | lei-zu | 嫘祖 | 上古 | legendary |
| 14 | liu-lei | 刘累 | 夏 | legendary |
| 15 | qiao-niu | 桥牛 | 上古 | legendary |
| 16 | qiong-chan | 穷蝉 | 上古 | legendary |
| 17 | shen-nong-shi | 神农氏 | 上古 | legendary |
| 18 | shu-qi | 叔齐 | 先周 | historical |
| 19 | tai-bo | 太伯 | 西周 | historical |
| 20 | u4e1c-u5468-u60e0-u516c | 东周惠公 | 东周 | historical |
| 21 | u4e2d-u58ec | 中壬 | 商 | legendary |
| 22 | u4e49-u4f2f | 义伯 | 商 | legendary |
| 23 | u4e5d-u4faf | 九侯 | 商 | legendary |
| 24 | u4ef2-u4f2f | 仲伯 | 商 | legendary |
| 25 | u4f2f-u4e0e | 伯与 | 上古 | legendary |
| 26 | u4f2f-u58eb | 伯士 | 西周 | uncertain |
| 27 | u4f2f-u81e9 | 伯臩 | 西周 | historical |
| 28 | u4f2f-u9633 | 伯阳 | 西周 | historical |
| 29 | u4f2f-u9633-u752b | 伯阳甫 | 西周 | historical |
| 30 | u516c-u5b50-u548e | 公子咎 | 战国 | historical |

---

## 4. 多候选样本（前 10 / 8 条）

### 1. 白起 (bai-qi)

- **Q701746** 白起: 戰國四名將之一
- **Q65820802** 白起:

### 2. 比干 (bi-gan)

- **Q1051287** 比干: 商朝贵族
- **Q45519000** 比干:

### 3. 伯夷 (bo-yi)

- **Q61314449** 伯夷: 商朝末年孤竹国王子
- **Q10787522** 伯夷:

### 4. 姚 (u59da)

- **Q65801317** 姚: 王+軖
- **Q45469590** 姚:

### 5. 惠王 (u60e0-u738b)

- **Q497959** 惠王:
- **Q27892394** 惠王:

### 6. 朱虎 (u6731-u864e)

- **Q45424403** 朱虎:
- **Q45554133** 朱虎:

### 7. 申侯 (u7533-u4faf)

- **Q6772561** 申侯: 周幽王时期西申国君主
- **Q15939420** 申侯: 周孝王时期西申国君主
- **Q16077042** 申侯:

### 8. 祖辛 (u7956-u8f9b)

- **Q878449** 祖辛: 商朝君主
- **Q2042552** 祖辛:

---

## 5. Alias 贡献（17 persons）

| slug | canonical_name | alias_used | QID |
|------|---------------|------------|-----|
| jie | 帝履癸 | 夏桀 | Q465081 |
| tang | 汤 | 成汤 | Q471820 |
| u536b-u5eb7-u53d4 | 卫康叔 | 卫康叔 | Q5962686 |
| u5389-u738b | 厉王 | 胡 | Q11832842, Q45430566, Q45508524 |
| u53d4 | 叔 | 思王 | Q45567107 |
| u53f8-u9a6c-u8fc1 | 司马迁 | 太史公 | Q713013, Q15898236, Q9372 |
| u5468-u516c | 周公 | 周文公 | Q468747 |
| u5468-u6b66-u738b | 发 | 武 | Q1039354, Q1564685, Q45433797 |
| u614e-u9753-u738b | 慎靓王 | 定 | Q838433, Q1017968, Q4939946 |
| u70c8-u738b | 烈王 | 喜 | Q10944799 |
| u8521-u53d4 | 蔡叔 | 蔡 | Q45436619, Q45678172 |
| u8944-u738b | 襄王 | 襄王 | Q11093684, Q11094497 |
| u8d67-u738b | 赧王 | 延 | Q45445320, Q45481125 |
| wei-zi-qi | 微子启 | 微子启 | Q855012 |
| xi-bo-chang | 西伯昌 | 西伯 | Q698909 |
| yu | 禹 | 伯禹 | Q45461701 |
| zhuan-xu | 颛顼 | 高阳 | Q198180, Q15913176 |

---

## 6. 执行元数据

| Key | Value |
|-----|-------|
| Endpoint | `https://query.wikidata.org/sparql` |
| Timestamp | 2026-04-21T23:22:29+0800 |
| Elapsed | 245s |
| HTTP requests | see logs |
| HTTP errors | 0 |
| Batch size | 15 |
| Rate limit | 1.1s |
