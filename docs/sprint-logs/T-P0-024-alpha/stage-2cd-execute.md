# T-P0-024 Alpha — Stage 2cd: C2 Phase A/B Execute Log

- **Executed**: 2026-04-21T00:05+08:00
- **Operator**: Pipeline Engineer (Claude Opus)
- **Mode**: backfill (fast lane — zero new LLM cost)

---

## V7 Journey

| Milestone | V7 | Delta | Date |
|-----------|-----|-------|------|
| Sprint open | 275/524 = 52.48% | — | 2026-04-20 |
| C1 β Path A | 305/524 = 58.21% | +30 names (+5.73pp) | 2026-04-20 |
| **C2 Phase A/B** | **505/524 = 96.37%** | **+200 names (+38.16pp)** | **2026-04-21** |
| **Total gain** | — | **+230 names (+43.89pp)** | — |

---

## Gate Timeline

| Gate | Time | Key Data |
|------|------|----------|
| 0 — pg_dump (C1) | 2026-04-20 23:03 | `pre-t-p0-024-alpha-stage-1c-*.dump` sha256:`a2673a99` |
| 0 — pg_dump (C2) | 2026-04-21 00:05 | `pre-t-p0-024-alpha-stage-2cd-*.dump` sha256:`2f02b8d2` |
| 1 — pre-state | V7=305/524, SE=266, AB names=44/219/263, AB persons=151 |
| 2 — dry-run | names=340, se=242, no_match=15, ambig=21 (backfill mode, 0 LLM) |
| 3 — irreversibility | ACK: UPDATE NULL→UUID not SQL-reversible |
| 4 — execute | names=200, se=146, no_match=20, ambig=21, errors=0 |

---

## C1 β Path A Detail

- Books: shangshu-yao-dian (7§) + shangshu-shun-dian (20§) = 27 paragraphs
- Mechanism: SHA-256 input_hash → existing llm_calls → _parse_response → match → link
- Result: 30 names linked, 24 SE created, 3 no_match (弃×2, 垂×1)
- LLM cost: $0 (reuse cached responses)
- V7: 52.48% → 58.21% (+5.73pp)

## C2 Phase A/B Path B via Fast Lane Detail

- Books: wu-di-ben-ji (29§) + xia-ben-ji (35§) + yin-ben-ji (35§) = 99 paragraphs
- Mechanism: dry-run reextract (LLM $1.01) → audit to llm_calls → execute via backfill mode (hash reuse)
- Execute cost: **$0 new LLM** (fast lane: backfill reads dry-run llm_calls)

| Book | § | Persons | Link | Skip | No_match | Ambig | Fail |
|------|---|---------|------|------|----------|-------|------|
| wu-di-ben-ji | 29 | 137 | 56 | 90 | 6 | 0 | 0 |
| xia-ben-ji | 35 | 80 | 27 | 56 | 8 | 6 | 0 |
| yin-ben-ji | 35 | 148 | 117 | 59 | 6 | 15 | 0 |
| **Total** | **99** | **365** | **200** | **205** | **20** | **21** | **0** |

---

## AMBIGUOUS_SLUGS Full Audit (21/21)

| name_zh | chosen_slug | Book | Count | White-listed? |
|---------|-------------|------|-------|---------------|
| 启 | qi | xia | 5 | ✅ qi ∈ AMBIGUOUS_SLUGS |
| 汤 | tang | xia | 1 | ✅ tang ∈ AMBIGUOUS_SLUGS |
| 汤 | tang | yin | 9 | ✅ |
| 武丁 | wu-ding | yin | 3 | ✅ wu-ding ∈ AMBIGUOUS_SLUGS |
| 周武王 | u5468-u6b66-u738b | yin | 3 | ✅ ∈ AMBIGUOUS_SLUGS |

All 21 events: slug-first matched the correct person. No bare alias (发/王/武王) used by LLM. Dry-run prediction = execute actual: 100% match.

---

## First-Write-Wins Statistics

| Phase | Dry-run links | Actual links | Ratio | Explanation |
|-------|--------------|--------------|-------|-------------|
| C1 (β) | 44 | 30 | 68% | Lower cross-paragraph overlap (2 books, different content) |
| C2 (A/B) | 340 | 200 | 59% | Higher overlap (same persons across 3 books of same series) |

The ratio gap (68% vs 59%) is structural: Phase A/B's three 本纪 chapters share many recurring persons (黄帝/尧/舜/禹/汤 etc.), causing more first-write-wins collisions. Not a bug.

---

## 19 Uncovered Names (Post-Sprint Residual)

| Category | Count | Names / Cause |
|----------|-------|---------------|
| Pronoun blacklist | 4 | 帝(尧), 帝(舜), 王(汤), 王(武丁) — permanent B-class |
| Short-name 夏 kings | 7 | 予/槐/芒/泄/不降/扃/廑 — DB stores 帝X form, person_names lacks bare X |
| 微子 slug mismatch | 2 | "微子" not in person_names for wei-zi-qi (only "启" and "微子启") |
| Other surface misses | 6 | 子氏/廪辛/周文王/垂/昆吾氏 etc. |

→ T-P1-015 (短名夏王) + T-P1-016 (微子) to close remaining gaps if needed.

---

## Cost Breakdown

| Item | Cost |
|------|------|
| Stage 2a probe (3§) | $0.0347 |
| Stage 2b wu-di dry-run (29§) | $0.2762 |
| Stage 2b xia+yin dry-run (70§) | $0.4682 |
| C1 execute | $0 |
| C2 execute (fast lane) | $0 |
| **Sprint total** | **$0.7791** |
| Budget | $2.00 |
| **Remaining** | **$1.22 (61%)** |

Wall clock: C2 execute < 10 seconds (pure SQL, no LLM).

---

## Script Stats

| Metric | Value |
|--------|-------|
| File | `services/pipeline/scripts/backfill_evidence.py` |
| Lines | 920 (was 624 at C1) |
| Net change | +296 lines |
| Modes | `backfill` (Path A hash reuse) + `reextract` (Path B LLM call) |
| New functions | 8 (find_by_name, _resolve_person, _link_evidence, extract_via_gateway, etc.) |
| Reused from pipeline | 4 (_parse_response, _filter_pronoun, generate_slug, gateway) |
