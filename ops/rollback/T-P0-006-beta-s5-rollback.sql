-- T-P0-006-β S-5 rollback — revert ad-hoc model-B merges
-- Date: 2026-04-19
-- Context: S-5 merge apply used ad-hoc SQL with model-B pattern
--   (person_names migrated to canonical + source names DELETE'd),
--   violating ADR-014 model-A (names stay on source person).
-- Pre-rollback snapshot: ops/snapshots/pre_adr014_rollback_20260419T094626Z.dump
--   SHA256: c348a1674a00bce514e9d42a282dbed6befcdf3363dfdce75638cac62e03ce04
--
-- This script reverts the 3 model-B merges (弃/垂/朱).
-- Keeps the 帝鸿氏 T-P0-015 patch (model-A, only deleted_at backfill).
-- After rollback, apply_merges() Python path is used to redo the 3 merges
-- correctly per model-A.

BEGIN;

-- A1: Reactivate β source persons (by ID, not slug — slug has α deleted rows too)
UPDATE persons
  SET deleted_at = NULL, merged_into_id = NULL
  WHERE id IN (
    '3e4f389a-c31d-42f9-b093-f05538f9dd07'::uuid,  -- 弃 (β)
    '34b49774-ec47-440b-8ed9-876cf5d725db'::uuid,  -- 垂 (β)
    '66fccef4-5fa4-4697-83f2-92a9576fd1c5'::uuid   -- 朱 (β)
  );

-- A2: 垂 — revert person_names.person_id back to source
UPDATE person_names
  SET person_id = '34b49774-ec47-440b-8ed9-876cf5d725db'::uuid,
      is_primary = true
  WHERE id = '2520c437-393b-4435-a3ed-42bee0566cef'::uuid;

-- A3: 朱 — revert person_names.person_id back to source
UPDATE person_names
  SET person_id = '66fccef4-5fa4-4697-83f2-92a9576fd1c5'::uuid
  WHERE id IN (
    'd30a423e-9f89-4bb0-9955-b3499e6287e8'::uuid,
    '3e0cdc24-fe9d-476f-9c29-242d563ba573'::uuid
  );
UPDATE person_names SET is_primary = true
  WHERE id = 'd30a423e-9f89-4bb0-9955-b3499e6287e8'::uuid;

-- A4: 弃 — rebuild 3 name rows destroyed by model-B DELETE
-- Note: these are pure-text reconstructions without source_evidence_id
-- (entire person_names table has source_evidence_id=NULL in Phase 0)
INSERT INTO person_names (id, person_id, name, name_type, is_primary)
VALUES
  (gen_random_uuid(), '3e4f389a-c31d-42f9-b093-f05538f9dd07'::uuid,
   '弃', 'primary'::name_type, true),
  (gen_random_uuid(), '3e4f389a-c31d-42f9-b093-f05538f9dd07'::uuid,
   '稷', 'alias'::name_type, false),
  (gen_random_uuid(), '3e4f389a-c31d-42f9-b093-f05538f9dd07'::uuid,
   '后稷', 'alias'::name_type, false);

-- A5: Clean up S-5 merge_log (keep 帝鸿氏 manual-fix)
DELETE FROM person_merge_log
  WHERE run_id = '3d51dbfe-dcaf-4733-bdab-2597418774ee'::uuid
  AND merge_rule IN ('R1', 'R3', 'manual-historian');

COMMIT;
