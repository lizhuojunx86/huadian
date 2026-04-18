-- T-P0-014: Non-person entity soft-delete
-- Generated: 2026-04-18 (updated: historian override for 羲氏/和氏)
-- Targets: 5 confirmed non-person entities (荤粥, 昆吾氏, 姒氏, 羲氏, 和氏)
-- Action: soft-delete (deleted_at + merged_into_id=NULL) + audit log
--
-- ⚠️ DO NOT EXECUTE without user confirmation.
-- This file is a dry-run artifact. User must review and approve.
--
-- Run with: psql $DATABASE_URL -f T-P0-014-soft-delete.sql

BEGIN;

-- Generate a shared run_id for this batch
-- Using a deterministic UUID so the SQL is reproducible
-- run_id = md5('T-P0-014-non-person-cleanup')::uuid
DO $$
DECLARE
  v_run_id uuid := 'a7e7d014-0014-4014-8014-a7e7d0140014';
  v_now timestamptz := NOW();
  v_merged_by text := 'pipeline:T-P0-014-non-person';
BEGIN

  -- -----------------------------------------------------------------------
  -- 1. Soft-delete: 荤粥 (tribal_group — 匈奴古称)
  -- -----------------------------------------------------------------------
  UPDATE persons
  SET deleted_at = v_now, merged_into_id = NULL
  WHERE id = 'b40287a2-64ed-4bc3-83bf-3f51a8e1a48f'
    AND deleted_at IS NULL;

  INSERT INTO person_merge_log
    (id, run_id, canonical_id, merged_id, merge_rule, confidence, evidence, merged_by, merged_at)
  VALUES
    (gen_random_uuid(), v_run_id,
     'b40287a2-64ed-4bc3-83bf-3f51a8e1a48f',  -- canonical_id = self (no merge target)
     'b40287a2-64ed-4bc3-83bf-3f51a8e1a48f',  -- merged_id = self
     'R3-non-person', 1.0,
     '{"category": "tribal_group", "reason": "匈奴古称, not an individual person", "name": "荤粥", "slug": "u8364-u7ca5", "rule": "hardcoded_non_person_dict"}'::jsonb,
     v_merged_by, v_now);

  -- -----------------------------------------------------------------------
  -- 2. Soft-delete: 昆吾氏 (tribal_group — 夏代附庸诸侯/部族)
  -- -----------------------------------------------------------------------
  UPDATE persons
  SET deleted_at = v_now, merged_into_id = NULL
  WHERE id = 'be1927a1-1aef-4ae6-9a56-4640fd7c9ab0'
    AND deleted_at IS NULL;

  INSERT INTO person_merge_log
    (id, run_id, canonical_id, merged_id, merge_rule, confidence, evidence, merged_by, merged_at)
  VALUES
    (gen_random_uuid(), v_run_id,
     'be1927a1-1aef-4ae6-9a56-4640fd7c9ab0',
     'be1927a1-1aef-4ae6-9a56-4640fd7c9ab0',
     'R3-non-person', 1.0,
     '{"category": "tribal_group", "reason": "夏代附庸诸侯/部族名, not an individual person", "name": "昆吾氏", "slug": "u6606-u543e-u6c0f", "rule": "shi_suffix_pattern"}'::jsonb,
     v_merged_by, v_now);

  -- -----------------------------------------------------------------------
  -- 3. Soft-delete: 姒氏 (clan_surname — 夏朝国姓/氏族)
  -- -----------------------------------------------------------------------
  UPDATE persons
  SET deleted_at = v_now, merged_into_id = NULL
  WHERE id = '16e09751-1795-4a4b-a0cf-4b5cb8409004'
    AND deleted_at IS NULL;

  INSERT INTO person_merge_log
    (id, run_id, canonical_id, merged_id, merge_rule, confidence, evidence, merged_by, merged_at)
  VALUES
    (gen_random_uuid(), v_run_id,
     '16e09751-1795-4a4b-a0cf-4b5cb8409004',
     '16e09751-1795-4a4b-a0cf-4b5cb8409004',
     'R3-non-person', 1.0,
     '{"category": "clan_surname", "reason": "夏朝国姓/氏族名, not an individual person", "name": "姒氏", "slug": "u59d2-u6c0f", "rule": "shi_suffix_pattern"}'::jsonb,
     v_merged_by, v_now);

  -- -----------------------------------------------------------------------
  -- 4. Soft-delete: 羲氏 (official_clan — 天文世家族称)
  --    Historian override: bare name '羲' is clan abbreviation, not person.
  --    Individual members 羲仲/羲叔 exist as separate person entries.
  -- -----------------------------------------------------------------------
  UPDATE persons
  SET deleted_at = v_now, merged_into_id = NULL
  WHERE id = '411ee7c8-a7fe-4f0b-8018-d1e63b0440bf'
    AND deleted_at IS NULL;

  INSERT INTO person_merge_log
    (id, run_id, canonical_id, merged_id, merge_rule, confidence, evidence, merged_by, merged_at)
  VALUES
    (gen_random_uuid(), v_run_id,
     '411ee7c8-a7fe-4f0b-8018-d1e63b0440bf',
     '411ee7c8-a7fe-4f0b-8018-d1e63b0440bf',
     'R3-non-person', 1.0,
     '{"category": "official_clan", "reason": "天文世家族称, bare name 羲 is clan abbreviation; individual members 羲仲/羲叔 exist separately", "name": "羲氏", "slug": "u7fb2-u6c0f", "rule": "shi_suffix_pattern + historian_override"}'::jsonb,
     v_merged_by, v_now);

  -- -----------------------------------------------------------------------
  -- 5. Soft-delete: 和氏 (official_clan — 天文世家族称)
  --    Historian override: bare name '和' is clan abbreviation, not person.
  --    Individual members 和仲/和叔 exist as separate person entries.
  -- -----------------------------------------------------------------------
  UPDATE persons
  SET deleted_at = v_now, merged_into_id = NULL
  WHERE id = 'c67494ce-eac5-4524-a8d2-0a8c03d24373'
    AND deleted_at IS NULL;

  INSERT INTO person_merge_log
    (id, run_id, canonical_id, merged_id, merge_rule, confidence, evidence, merged_by, merged_at)
  VALUES
    (gen_random_uuid(), v_run_id,
     'c67494ce-eac5-4524-a8d2-0a8c03d24373',
     'c67494ce-eac5-4524-a8d2-0a8c03d24373',
     'R3-non-person', 1.0,
     '{"category": "official_clan", "reason": "天文世家族称, bare name 和 is clan abbreviation; individual members 和仲/和叔 exist separately", "name": "和氏", "slug": "u548c-u6c0f", "rule": "shi_suffix_pattern + historian_override"}'::jsonb,
     v_merged_by, v_now);

  RAISE NOTICE 'T-P0-014: 5 persons soft-deleted, 5 merge_log rows inserted (run_id=%)', v_run_id;
END $$;

-- ⚠️ COMMIT is commented out — user must uncomment after review
-- COMMIT;

-- Verification queries (run after COMMIT):
-- SELECT count(*) FROM persons WHERE deleted_at IS NULL;
--   → should be 152 (was 157)
-- SELECT * FROM person_merge_log WHERE merge_rule = 'R3-non-person';
--   → should show 5 rows
-- SELECT slug, name->>'zh-Hans', deleted_at FROM persons
--   WHERE slug IN ('u8364-u7ca5', 'u6606-u543e-u6c0f', 'u59d2-u6c0f', 'u7fb2-u6c0f', 'u548c-u6c0f');
--   → all should have deleted_at set
