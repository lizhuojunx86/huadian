-- T-P0-015: Merge 帝鸿氏 into 黄帝 canonical
-- Generated: 2026-04-19
-- Historian ruling: (c) mixed — 帝鸿氏 MERGE, 缙云氏 KEEP-independent
-- Target: 1 person merged, 1 merge_log row, 1 person_name added
--
-- ⚠️ REQUIRES USER CONFIRMATION before execution (红线协议 §5)
-- EXECUTED: 2026-04-19 — 1 person merged (帝鸿氏→黄帝), verified V-1~V-5
-- ⚠️ ALREADY EXECUTED. Do not re-run.

BEGIN;

DO $$
DECLARE
  v_run_id uuid := 'a7e70015-0015-4015-8015-a7e700150015';
  v_now timestamptz := NOW();
  v_merged_by text := 'historian:T-P0-015-honorific-merge';
  v_canonical_id uuid := '3197e202-55e0-4eca-aa91-098d9de33bc9';  -- 黄帝
  v_merged_id uuid := '19ef3926-eaf1-42e1-ba4b-f0fc4b9de9dd';    -- 帝鸿氏
BEGIN

  -- -----------------------------------------------------------------------
  -- 1. Soft-merge: 帝鸿氏 → 黄帝
  --    Set merged_into_id (not deleted_at — this is a merge, not a delete)
  -- -----------------------------------------------------------------------
  UPDATE persons
  SET merged_into_id = v_canonical_id,
      updated_at = v_now
  WHERE id = v_merged_id
    AND merged_into_id IS NULL
    AND deleted_at IS NULL;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'T-P0-015: 帝鸿氏 (%) not found or already merged/deleted', v_merged_id;
  END IF;

  -- -----------------------------------------------------------------------
  -- 2. Audit log
  -- -----------------------------------------------------------------------
  INSERT INTO person_merge_log
    (id, run_id, canonical_id, merged_id, merge_rule, confidence, evidence, merged_by, merged_at)
  VALUES
    (gen_random_uuid(), v_run_id,
     v_canonical_id,
     v_merged_id,
     'R4-honorific-alias', 0.95,
     '{
       "category": "honorific_alias",
       "reason": "帝鸿=黄帝 per 贾逵/杜预/服虔/张守节 unanimous gloss; 帝鸿 is an honorific title for 黄帝",
       "name": "帝鸿氏",
       "slug": "u5e1d-u9e3f-u6c0f",
       "rule": "R4-honorific-alias",
       "sources": ["裴骃《史记集解》引贾逵", "杜预《春秋左传集解》", "张守节《史记正义》", "服虔《左传》注"],
       "text_location": "五帝本纪 P24",
       "kept_independent": ["缙云氏 (u7f19-u4e91-u6c0f) — 黄帝时官名, not 黄帝 himself"]
     }'::jsonb,
     v_merged_by, v_now);

  -- -----------------------------------------------------------------------
  -- 3. Add '帝鸿氏' as an alias name on 黄帝 canonical
  -- -----------------------------------------------------------------------
  INSERT INTO person_names (id, person_id, name, name_type, created_at)
  VALUES (gen_random_uuid(), v_canonical_id, '帝鸿氏', 'alias', v_now)
  ON CONFLICT DO NOTHING;

  RAISE NOTICE 'T-P0-015: 帝鸿氏 merged into 黄帝 (run_id=%)', v_run_id;
END $$;

-- ⚠️ User approved execution on 2026-04-19
COMMIT;

-- =========================================================================
-- Verification queries (run after COMMIT):
-- =========================================================================
-- V-1: Active persons count
--   SELECT count(*) FROM persons WHERE deleted_at IS NULL AND merged_into_id IS NULL;
--   → expected: 151 (was 152)
--
-- V-2: Merge log entry
--   SELECT * FROM person_merge_log WHERE run_id = 'a7e70015-0015-4015-8015-a7e700150015';
--   → expected: 1 row (帝鸿氏 → 黄帝, R4-honorific-alias)
--
-- V-3: 黄帝 names now include 帝鸿氏
--   SELECT * FROM person_names WHERE person_id = '3197e202-55e0-4eca-aa91-098d9de33bc9';
--   → expected: 轩辕(primary), 黄帝(nickname), 帝鸿氏(alias)
--
-- V-4: 帝鸿氏 merged_into_id set
--   SELECT slug, merged_into_id FROM persons WHERE id = '19ef3926-eaf1-42e1-ba4b-f0fc4b9de9dd';
--   → expected: merged_into_id = 3197e202-55e0-4eca-aa91-098d9de33bc9
--
-- V-5: 缙云氏 unchanged
--   SELECT slug, merged_into_id, deleted_at FROM persons WHERE id = 'ae47eddd-804b-4715-974a-d1eb99a19509';
--   → expected: merged_into_id = NULL, deleted_at = NULL
--
-- Rollback (if needed):
--   UPDATE persons SET merged_into_id = NULL, updated_at = NOW()
--     WHERE id = '19ef3926-eaf1-42e1-ba4b-f0fc4b9de9dd';
--   DELETE FROM person_merge_log
--     WHERE run_id = 'a7e70015-0015-4015-8015-a7e700150015';
--   DELETE FROM person_names
--     WHERE person_id = '3197e202-55e0-4eca-aa91-098d9de33bc9' AND name = '帝鸿氏';
