-- T-P0-016: Backfill alias rows with is_primary=false.
-- Root-cause fixes applied in Stage 1a (apply_merges) and Stage 1b (load.py W1)
-- prevent new violations; this migration clears the 18 historical rows
-- produced before those code fixes landed.
--
-- Scope: all name_type='alias' AND is_primary=true, regardless of person state
-- (active / merge_softdelete / pure_softdelete). Stage 0 breakdown:
--   - active: 5 (W1 NER-alias path remnants)
--   - merge_softdelete: 11 (T-P0-022 new 7 + pre-existing 4)
--   - pure_softdelete: 2 (T-P0-014 non-person entities)

UPDATE person_names
SET is_primary = false
WHERE name_type = 'alias' AND is_primary = true;
