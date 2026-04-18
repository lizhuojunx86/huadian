-- Migration: 0003_fix_dishun_misattribution
-- Task: T-P0-011 (Related Fix #2 from ADR-010)
-- Date: 2026-04-18
--
-- Fix: T-P0-010 LLM extraction mistakenly attached '帝舜' as a surface_form
-- of 尧 (person_id = 2da772b8-...). 帝舜 only refers to 舜, never to 尧.
-- 舜 already has '帝舜' in their person_names (id = 6ecff6c9-...), so
-- the erroneous row is simply deleted.
--
-- Rollback:
--   INSERT INTO person_names (id, person_id, name, name_type, is_primary)
--   VALUES ('a8396067-0d73-4278-bee3-1589f77bb3a4',
--           '2da772b8-3c0b-4e13-9452-5e85ae34bf26',
--           '帝舜', 'nickname', false);

DELETE FROM person_names
WHERE id = 'a8396067-0d73-4278-bee3-1589f77bb3a4'
  AND person_id = '2da772b8-3c0b-4e13-9452-5e85ae34bf26'
  AND name = '帝舜';
